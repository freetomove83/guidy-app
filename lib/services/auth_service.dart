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
    await _ensureUserDoc(user);
    return user;
  }

  /// users/{uid} 회원 문서 — 처음이면 만들고, 있으면 정지 여부 확인 후 접속 시각 기록
  /// (role·status는 규칙상 관리자만 지정)
  static Future<void> _ensureUserDoc(User user) async {
    final ref = FirebaseFirestore.instance.collection('users').doc(user.uid);
    final doc = await ref.get();
    if (!doc.exists) {
      await ref.set({
        'name': user.displayName ?? '',
        'email': user.email ?? '',
        'provider': 'google',
        'created_at': FieldValue.serverTimestamp(),
        'last_login_at': FieldValue.serverTimestamp(),
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
