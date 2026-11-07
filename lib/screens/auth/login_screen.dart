// lib/screens/auth/login_screen.dart
// 로그인 화면 - 소셜 로그인 (Google, Apple, Naver, Kakao) + 이메일

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user_store.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';
import 'signup_screen.dart';
import 'email_login_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final pal = GuidyPalette.of(context);

    return Scaffold(
      backgroundColor: pal.bg,
      body: SafeArea(
        child: Column(
          children: [
            // 상단 닫기 버튼
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    // 로그아웃·탈퇴 후엔 스택에 로그인 화면만 남으므로 pop 대신 홈으로 복귀
                    onTap: () => Navigator.canPop(context)
                        ? Navigator.pop(context)
                        : Navigator.pushReplacementNamed(context, '/home'),
                    child: Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(
                        color: pal.surface,
                        shape: BoxShape.circle,
                        border: Border.all(color: pal.line),
                      ),
                      child: Icon(Icons.close_rounded, size: 18, color: pal.mute),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 32),

                    // 로고
                    Container(
                      width: 88, height: 88,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(88 * 0.225),
                        boxShadow: GuidyShadow.pop,
                      ),
                      child: Image.asset(
                        'assets/icon/app_icon.png',
                        width: 88, height: 88,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text('Guidy', style: TextStyle(
                      fontFamily: GuidyText.fontFamily,
                      fontSize: 28, fontWeight: FontWeight.w800,
                      letterSpacing: -1.0, color: pal.text,
                    )),
                    const SizedBox(height: 6),
                    Text('오디오 가이드 마켓플레이스', style: GuidyText.small(pal.sub)),

                    const SizedBox(height: 40),

                    // 타이틀
                    Text('로그인', style: GuidyText.h2(pal.text)),
                    const SizedBox(height: 6),
                    Text('계속하려면 로그인해 주세요', style: GuidyText.body(pal.sub)),

                    const SizedBox(height: 32),

                    // 소셜 로그인 버튼들
                    _SocialLoginButton(
                      label: 'Google로 계속하기',
                      iconWidget: _GoogleIcon(),
                      bgColor: Colors.white,
                      textColor: const Color(0xFF3C4043),
                      borderColor: const Color(0xFFDADCE0),
                      onTap: () => _handleSocialLogin(context, 'google'),
                    ),
                    const SizedBox(height: 10),

                    _SocialLoginButton(
                      label: 'Apple로 계속하기',
                      iconWidget: Icon(
                        Icons.apple,
                        color: isDark ? Colors.black : Colors.white,
                        size: 22,
                      ),
                      bgColor: isDark ? Colors.white : Colors.black,
                      textColor: isDark ? Colors.black : Colors.white,
                      onTap: () => _handleSocialLogin(context, 'apple'),
                    ),
                    const SizedBox(height: 10),

                    _SocialLoginButton(
                      label: '네이버로 계속하기',
                      iconWidget: const _NaverIcon(),
                      bgColor: const Color(0xFF03C75A),
                      textColor: Colors.white,
                      onTap: () => _handleSocialLogin(context, 'naver'),
                    ),
                    const SizedBox(height: 10),

                    _SocialLoginButton(
                      label: '카카오로 계속하기',
                      iconWidget: const _KakaoIcon(),
                      bgColor: const Color(0xFFFEE500),
                      textColor: const Color(0xFF191919),
                      onTap: () => _handleSocialLogin(context, 'kakao'),
                    ),

                    // 구분선
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Row(
                        children: [
                          Expanded(child: Divider(color: pal.line)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            child: Text('또는', style: GuidyText.small(pal.mute)),
                          ),
                          Expanded(child: Divider(color: pal.line)),
                        ],
                      ),
                    ),

                    // 이메일 로그인
                    _SocialLoginButton(
                      label: '이메일로 로그인',
                      iconWidget: Icon(Icons.email_outlined, color: pal.text, size: 20),
                      bgColor: pal.surface,
                      textColor: pal.text,
                      borderColor: pal.line,
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(
                          builder: (_) => const EmailLoginScreen(),
                        ));
                      },
                    ),

                    const SizedBox(height: 24),

                    // 회원가입 링크
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('계정이 없으신가요? ', style: GuidyText.small(pal.sub)),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(
                              builder: (_) => const SignupScreen(),
                            ));
                          },
                          child: Text('회원가입', style: GuidyText.small(pal.primary).copyWith(
                            fontWeight: FontWeight.w800,
                          )),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // 약관 동의
                    Text(
                      '계속하면 Guidy의 이용약관 및 개인정보처리방침에 동의하는 것으로 간주됩니다.',
                      style: GuidyText.kicker(pal.mute),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSocialLogin(BuildContext context, String provider) async {
    if (provider == 'google') return _handleGoogleLogin(context);
    // Apple·네이버·카카오는 아직 SDK 미연동
    _showMessage(context, '$provider 로그인 연동 준비 중입니다');
  }

  Future<void> _handleGoogleLogin(BuildContext context) async {
    final userStore = context.read<UserStore>();
    final navigator = Navigator.of(context);
    try {
      final user = await AuthService.signInWithGoogle();
      if (user == null) return; // 사용자가 취소
      await userStore.updateProfile(name: user.displayName, email: user.email);
      if (navigator.canPop()) {
        navigator.pop();
      } else {
        navigator.pushReplacementNamed('/home');
      }
    } on AccountBlockedException catch (e) {
      if (context.mounted) _showMessage(context, e.message);
    } catch (e) {
      debugPrint('[Auth] Google login failed: $e');
      if (context.mounted) _showMessage(context, 'Google 로그인에 실패했습니다. 잠시 후 다시 시도해주세요');
    }
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: GuidyColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: GuidyRadius.lgBorder),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}

// ─── 소셜 로그인 버튼 공통 컴포넌트 ──────────────────────
class _SocialLoginButton extends StatelessWidget {
  final String label;
  final Widget iconWidget;
  final Color bgColor;
  final Color textColor;
  final Color? borderColor;
  final VoidCallback onTap;

  const _SocialLoginButton({
    required this.label,
    required this.iconWidget,
    required this.bgColor,
    required this.textColor,
    this.borderColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: GuidyRadius.lgBorder,
          border: borderColor != null ? Border.all(color: borderColor!) : null,
          boxShadow: borderColor == null ? [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ] : null,
        ),
        child: Row(
          children: [
            SizedBox(width: 24, height: 24, child: iconWidget),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontFamily: GuidyText.fontFamily,
                  fontSize: 15, fontWeight: FontWeight.w700,
                  color: textColor,
                  letterSpacing: -0.2,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(width: 36), // 아이콘 폭만큼 오프셋
          ],
        ),
      ),
    );
  }
}

// ─── 소셜 아이콘들 ────────────────────────────────────────
class _GoogleIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _GoogleIconPainter(),
    );
  }
}

class _GoogleIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..style = PaintingStyle.fill;
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width / 2;

    // 전체 원 (회색 배경)
    p.color = const Color(0xFFE8EAED);
    canvas.drawCircle(Offset(cx, cy), r, p);

    // G 텍스트를 대신하는 간단한 표현
    final textPainter = TextPainter(
      text: const TextSpan(
        text: 'G',
        style: TextStyle(
          color: Color(0xFF4285F4),
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(cx - textPainter.width / 2, cy - textPainter.height / 2));
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

class _NaverIcon extends StatelessWidget {
  const _NaverIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF03C75A),
        shape: BoxShape.circle,
      ),
      child: const Center(
        child: Text('N', style: TextStyle(
          color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14,
        )),
      ),
    );
  }
}

class _KakaoIcon extends StatelessWidget {
  const _KakaoIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFFEE500),
        shape: BoxShape.circle,
      ),
      child: const Center(
        child: Text('K', style: TextStyle(
          color: Color(0xFF191919), fontWeight: FontWeight.w900, fontSize: 14,
        )),
      ),
    );
  }
}
