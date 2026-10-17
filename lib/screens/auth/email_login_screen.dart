// lib/screens/auth/email_login_screen.dart
// 이메일 로그인 화면

import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';

class EmailLoginScreen extends StatefulWidget {
  const EmailLoginScreen({super.key});

  @override
  State<EmailLoginScreen> createState() => _EmailLoginScreenState();
}

class _EmailLoginScreenState extends State<EmailLoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgC = isDark ? GuidyColors.darkBg : GuidyColors.bg;
    final textC = isDark ? GuidyColors.darkText : GuidyColors.ink;
    final subC = isDark ? GuidyColors.darkSub : GuidyColors.sub;
    final muteC = isDark ? GuidyColors.darkMute : GuidyColors.mute;
    final surfaceC = isDark ? GuidyColors.darkSurface : GuidyColors.surface;
    final lineC = isDark ? GuidyColors.darkLine : GuidyColors.line;
    final primaryC = isDark ? GuidyColors.darkPrimary : GuidyColors.primary;

    return Scaffold(
      backgroundColor: bgC,
      body: SafeArea(
        child: Column(
          children: [
            GuidyHeader(title: '이메일 로그인', showBack: true),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('환영합니다', style: GuidyText.h2(textC)),
                    const SizedBox(height: 6),
                    Text('이메일과 비밀번호를 입력해주세요', style: GuidyText.body(subC)),
                    const SizedBox(height: 32),

                    // 이메일 입력
                    GuidyInputLabel(label: '이메일', textC: textC),
                    const SizedBox(height: 6),
                    GuidyInputField(
                      controller: _emailController,
                      hint: 'example@email.com',
                      keyboardType: TextInputType.emailAddress,
                      surfaceC: surfaceC,
                      lineC: lineC,
                      textC: textC,
                      subC: subC,
                    ),
                    const SizedBox(height: 16),

                    // 비밀번호 입력
                    GuidyInputLabel(label: '비밀번호', textC: textC),
                    const SizedBox(height: 6),
                    GuidyInputField(
                      controller: _passwordController,
                      hint: '비밀번호 입력',
                      obscureText: _obscurePassword,
                      surfaceC: surfaceC,
                      lineC: lineC,
                      textC: textC,
                      subC: subC,
                      suffix: GestureDetector(
                        onTap: () => setState(() => _obscurePassword = !_obscurePassword),
                        child: Icon(
                          _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                          size: 20, color: muteC,
                        ),
                      ),
                    ),

                    // 비밀번호 찾기
                    Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: GestureDetector(
                          onTap: () => _showForgotPasswordDialog(context, primaryC, bgC, textC, subC, surfaceC, lineC, muteC),
                          child: Text('비밀번호 찾기', style: GuidyText.small(primaryC).copyWith(fontWeight: FontWeight.w700)),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // 로그인 버튼
                    GestureDetector(
                      onTap: _isLoading ? null : () => _handleLogin(context),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: primaryC,
                          borderRadius: GuidyRadius.lgBorder,
                          boxShadow: GuidyShadow.pop,
                        ),
                        child: _isLoading
                            ? const Center(child: SizedBox(width: 20, height: 20,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)))
                            : Text('로그인', style: const TextStyle(
                                fontFamily: GuidyText.fontFamily,
                                fontSize: 16, fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ), textAlign: TextAlign.center),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // 회원가입 링크
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('계정이 없으신가요? ', style: GuidyText.small(subC)),
                          GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.pushNamed(context, '/signup');
                            },
                            child: Text('회원가입', style: GuidyText.small(primaryC).copyWith(fontWeight: FontWeight.w800)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleLogin(BuildContext context) {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('이메일과 비밀번호를 입력해주세요'),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: GuidyRadius.lgBorder),
          margin: const EdgeInsets.all(16),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    final messenger = ScaffoldMessenger.of(context);
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      setState(() => _isLoading = false);
      messenger.showSnackBar(
        SnackBar(
          content: const Text('로그인 기능 연동 준비 중입니다'),
          backgroundColor: GuidyColors.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: GuidyRadius.lgBorder),
          margin: const EdgeInsets.all(16),
        ),
      );
    });
  }

  void _showForgotPasswordDialog(BuildContext context, Color primaryC, Color bgC, Color textC, Color subC, Color surfaceC, Color lineC, Color muteC) {
    final emailCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: bgC,
        shape: RoundedRectangleBorder(borderRadius: GuidyRadius.xlBorder),
        title: Text('비밀번호 재설정', style: GuidyText.h3(textC)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('가입한 이메일로 재설정 링크를 보내드립니다', style: GuidyText.small(subC)),
            const SizedBox(height: 16),
            GuidyInputField(
              controller: emailCtrl,
              hint: 'example@email.com',
              keyboardType: TextInputType.emailAddress,
              surfaceC: surfaceC,
              lineC: lineC,
              textC: textC,
              subC: subC,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('취소', style: GuidyText.body(muteC)),
          ),
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('재설정 링크를 이메일로 전송했습니다'),
                  backgroundColor: GuidyColors.primary,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: GuidyRadius.lgBorder),
                  margin: const EdgeInsets.all(16),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(color: primaryC, borderRadius: GuidyRadius.pillBorder),
              child: const Text('전송', style: TextStyle(
                fontFamily: GuidyText.fontFamily, color: Colors.white,
                fontWeight: FontWeight.w700, fontSize: 14,
              )),
            ),
          ),
        ],
      ),
    );
  }
}
