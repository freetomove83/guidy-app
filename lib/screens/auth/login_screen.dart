// lib/screens/auth/login_screen.dart
// 로그인 화면 - 소셜 로그인 (Google, Apple, Naver, Kakao) + 이메일

import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'signup_screen.dart';
import 'email_login_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgC = isDark ? GuidyColors.darkBg : GuidyColors.bg;
    final textC = isDark ? GuidyColors.darkText : GuidyColors.ink;
    final subC = isDark ? GuidyColors.darkSub : GuidyColors.sub;
    final muteC = isDark ? GuidyColors.darkMute : GuidyColors.mute;
    final lineC = isDark ? GuidyColors.darkLine : GuidyColors.line;
    final primaryC = isDark ? GuidyColors.darkPrimary : GuidyColors.primary;

    return Scaffold(
      backgroundColor: bgC,
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
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(
                        color: isDark ? GuidyColors.darkSurface : GuidyColors.surface,
                        shape: BoxShape.circle,
                        border: Border.all(color: lineC),
                      ),
                      child: Icon(Icons.close_rounded, size: 18, color: muteC),
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
                      width: 64, height: 64,
                      decoration: BoxDecoration(
                        borderRadius: GuidyRadius.lgBorder,
                        boxShadow: GuidyShadow.pop,
                      ),
                      child: ClipRRect(
                        borderRadius: GuidyRadius.lgBorder,
                        child: Image.asset(
                          'assets/icon/app_icon.png',
                          width: 64, height: 64,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text('Guidy', style: TextStyle(
                      fontFamily: GuidyText.fontFamily,
                      fontSize: 28, fontWeight: FontWeight.w900,
                      letterSpacing: -1.0, color: textC,
                    )),
                    const SizedBox(height: 6),
                    Text('오디오 가이드 마켓플레이스', style: GuidyText.small(subC)),

                    const SizedBox(height: 40),

                    // 타이틀
                    Text('로그인', style: GuidyText.h2(textC)),
                    const SizedBox(height: 6),
                    Text('계속하려면 로그인해 주세요', style: GuidyText.body(subC)),

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
                          Expanded(child: Divider(color: lineC)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            child: Text('또는', style: GuidyText.small(muteC)),
                          ),
                          Expanded(child: Divider(color: lineC)),
                        ],
                      ),
                    ),

                    // 이메일 로그인
                    _SocialLoginButton(
                      label: '이메일로 로그인',
                      iconWidget: Icon(Icons.email_outlined, color: textC, size: 20),
                      bgColor: isDark ? GuidyColors.darkSurface : GuidyColors.surface,
                      textColor: textC,
                      borderColor: lineC,
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
                        Text('계정이 없으신가요? ', style: GuidyText.small(subC)),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(
                              builder: (_) => const SignupScreen(),
                            ));
                          },
                          child: Text('회원가입', style: GuidyText.small(primaryC).copyWith(
                            fontWeight: FontWeight.w800,
                          )),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // 약관 동의
                    Text(
                      '계속하면 Guidy의 이용약관 및 개인정보처리방침에 동의하는 것으로 간주됩니다.',
                      style: GuidyText.kicker(muteC),
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

  void _handleSocialLogin(BuildContext context, String provider) {
    // 소셜 로그인 처리 (실제 구현 시 각 SDK 연동)
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$provider 로그인 연동 준비 중입니다'),
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
              color: Colors.black.withOpacity(0.06),
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
