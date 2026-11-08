import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:guidy_audio_guide/services/auth_service.dart';

void main() {
  test('Firebase auth errors map to user-facing Korean messages', () {
    String msg(String code) => AuthService.errorMessage(FirebaseAuthException(code: code));
    expect(msg('invalid-credential'), '이메일 또는 비밀번호가 맞지 않습니다');
    expect(msg('wrong-password'), '이메일 또는 비밀번호가 맞지 않습니다');
    expect(msg('email-already-in-use'), contains('이미 가입된 이메일'));
    expect(msg('weak-password'), contains('8자 이상'));
    expect(msg('too-many-requests'), contains('잠시 후'));
    expect(msg('something-new'), '잠시 후 다시 시도해주세요');
    expect(AuthService.errorMessage(Exception('x')), '잠시 후 다시 시도해주세요');
    expect(AuthService.errorMessage(const AccountBlockedException('가입 중지')), '가입 중지');
  });

  test('without Firebase there is no signed-in user and no password', () {
    expect(AuthService.currentUser, isNull);
    expect(AuthService.hasPassword, isFalse);
  });
}
