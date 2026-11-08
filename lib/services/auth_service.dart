// lib/services/auth_service.dart
// Google 로그인 — Firebase Auth (웹은 팝업, iOS·Android는 google_sign_in)

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// CMS에서 정지·탈퇴 처리된 계정
class AccountBlockedException implements Exception {
  final String message;
  const AccountBlockedException(this.message);
}

class AuthService {
  static bool _googleReady = false;

  /// 로그인 성공 시 Firebase 사용자, 사용자가 취소하면 null
  static Future<User?> signInWithGoogle() async {
    final UserCredential cred;
    if (kIsWeb) {
      cred = await FirebaseAuth.instance.signInWithPopup(GoogleAuthProvider());
    } else {
      final google = GoogleSignIn.instance;
      if (!_googleReady) {
        // 클라이언트 ID는 iOS Info.plist(GIDClientID), Android google-services.json에서 읽음
        await google.initialize();
        _googleReady = true;
      }
      final GoogleSignInAccount account;
      try {
        account = await google.authenticate();
      } on GoogleSignInException catch (e) {
        if (e.code == GoogleSignInExceptionCode.canceled) return null;
        rethrow;
      }
      cred = await FirebaseAuth.instance.signInWithCredential(
        GoogleAuthProvider.credential(idToken: account.authentication.idToken),
      );
    }
    final user = cred.user!;
    await _ensureUserDoc(user, 'google');
    return user;
  }

  /// Apple 로그인은 지금 iOS에서만 (Android·웹은 Apple 서비스 ID 설정이 더 필요)
  static bool get appleAvailable => !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

  /// 로그인 성공 시 Firebase 사용자, 사용자가 취소하면 null
  static Future<User?> signInWithApple() async {
    final provider = AppleAuthProvider()
      ..addScope('email')
      ..addScope('name');
    final UserCredential cred;
    try {
      cred = await FirebaseAuth.instance.signInWithProvider(provider);
    } on FirebaseAuthException catch (e) {
      // 사용자 취소: SDK가 'canceled'로 주거나 'unknown' + AuthorizationError 1001로 줌
      if (e.code == 'canceled' || e.code == 'web-context-cancelled' ||
          (e.message?.contains('AuthorizationError error 1001') ?? false)) {
        return null;
      }
      rethrow;
    }
    final user = cred.user!;
    await _ensureUserDoc(user, 'apple');
    return user;
  }

  // ── 이메일·비밀번호 ────────────────────────────────

  static Future<User> signInWithEmail(String email, String password) async {
    final cred = await FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email, password: password);
    await _ensureUserDoc(cred.user!, 'email');
    return cred.user!;
  }

  /// 가입 후 이름을 저장하고 인증 메일을 보냄 (메일 인증 전에도 이용 가능)
  static Future<User> signUpWithEmail(String name, String email, String password,
      {bool marketingAgreed = false}) async {
    final cred = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: email, password: password);
    final user = cred.user!;
    await user.updateDisplayName(name);
    await _ensureUserDoc(user, 'email', name: name, extra: {'marketing_agreed': marketingAgreed});
    try {
      await user.sendEmailVerification();
    } catch (e) {
      debugPrint('[Auth] 인증 메일 발송 실패: $e'); // 가입 자체는 성공
    }
    return user;
  }

  static Future<void> sendPasswordReset(String email) =>
      FirebaseAuth.instance.sendPasswordResetEmail(email: email);

  /// 이메일 가입 회원인지 (Google·Apple 계정은 비밀번호가 없음)
  static bool get hasPassword =>
      currentUser?.providerData.any((p) => p.providerId == 'password') ?? false;

  /// 현재 비밀번호로 다시 확인한 뒤 변경 (Firebase는 최근 로그인을 요구함)
  static Future<void> changePassword(String current, String next) async {
    final user = currentUser!;
    await user.reauthenticateWithCredential(
        EmailAuthProvider.credential(email: user.email!, password: current));
    await user.updatePassword(next);
  }

  /// Firebase 오류 코드 → 사용자 안내 문구
  static String errorMessage(Object e) {
    if (e is! FirebaseAuthException) return '잠시 후 다시 시도해주세요';
    return switch (e.code) {
      'invalid-credential' || 'invalid-login-credentials' || 'wrong-password' || 'user-not-found' =>
        '이메일 또는 비밀번호가 맞지 않습니다',
      'invalid-email' => '이메일 형식이 올바르지 않습니다',
      'email-already-in-use' => '이미 가입된 이메일입니다. 로그인하거나 다른 로그인 방법을 사용해주세요',
      'weak-password' => '비밀번호가 너무 쉽습니다. 8자 이상, 영문과 숫자를 섞어주세요',
      'user-disabled' => '사용이 중지된 계정입니다. 고객센터로 문의해주세요',
      'too-many-requests' => '시도가 너무 많습니다. 잠시 후 다시 시도해주세요',
      'network-request-failed' => '인터넷 연결을 확인해주세요',
      'requires-recent-login' => '보안을 위해 다시 로그인한 뒤 시도해주세요',
      _ => '잠시 후 다시 시도해주세요',
    };
  }

  /// users/{uid} 회원 문서 — 처음이면 만들고, 있으면 정지 여부 확인 후 접속 시각 기록
  /// (role·status는 규칙상 관리자만 지정)
  static Future<void> _ensureUserDoc(User user, String provider,
      {String? name, Map<String, Object?> extra = const {}}) async {
    final ref = FirebaseFirestore.instance.collection('users').doc(user.uid);
    final doc = await ref.get();
    if (!doc.exists) {
      await ref.set({
        'name': name ?? user.displayName ?? '',
        'email': user.email ?? '',
        'provider': provider,
        'created_at': FieldValue.serverTimestamp(),
        'last_login_at': FieldValue.serverTimestamp(),
        ...extra,
      });
      return;
    }
    final status = doc.data()?['status'];
    if (status == 'suspended' || status == 'deleted') {
      await signOut();
      throw AccountBlockedException(status == 'suspended'
          ? '이용이 정지된 계정입니다. 고객센터로 문의해주세요'
          : '탈퇴 처리된 계정입니다');
    }
    await ref.update({'last_login_at': FieldValue.serverTimestamp()});
  }

  /// 로그인 상태 — Firebase가 없으면(설정 파일 없음·테스트) 항상 로그아웃
  static User? get currentUser =>
      Firebase.apps.isEmpty ? null : FirebaseAuth.instance.currentUser;

  static Stream<User?> authStateChanges() => Firebase.apps.isEmpty
      ? Stream.value(null)
      : FirebaseAuth.instance.authStateChanges();

  static Future<void> signOut() async {
    if (Firebase.apps.isEmpty) return;
    await FirebaseAuth.instance.signOut();
    if (!kIsWeb && _googleReady) await GoogleSignIn.instance.signOut();
  }
}
