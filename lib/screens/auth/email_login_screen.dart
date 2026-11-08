// lib/screens/auth/email_login_screen.dart
// 이메일 로그인 화면

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user_store.dart';
import '../../services/auth_service.dart';
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
    final pal = GuidyPalette.of(context);

    return Scaffold(
      backgroundColor: pal.bg,
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
                    Text('환영합니다', style: GuidyText.h2(pal.text)),
                    const SizedBox(height: 6),
                    Text('이메일과 비밀번호를 입력해주세요', style: GuidyText.body(pal.sub)),
                    const SizedBox(height: 32),

                    // 이메일 입력
                    GuidyInputLabel(label: '이메일', textC: pal.text),
                    const SizedBox(height: 6),
                    GuidyInputField(
                      controller: _emailController,
                      hint: 'example@email.com',
                      keyboardType: TextInputType.emailAddress,
                      surfaceC: pal.surface,
                      lineC: pal.line,
                      textC: pal.text,
                      subC: pal.sub,
                    ),
                    const SizedBox(height: 16),

                    // 비밀번호 입력
                    GuidyInputLabel(label: '비밀번호', textC: pal.text),
                    const SizedBox(height: 6),
                    GuidyInputField(
                      controller: _passwordController,
                      hint: '비밀번호 입력',
                      obscureText: _obscurePassword,
                      surfaceC: pal.surface,
                      lineC: pal.line,
                      textC: pal.text,
                      subC: pal.sub,
                      suffix: GestureDetector(
                        onTap: () => setState(() => _obscurePassword = !_obscurePassword),
                        child: Icon(
                          _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                          size: 20, color: pal.mute,
                        ),
                      ),
                    ),

                    // 비밀번호 찾기
                    Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: GestureDetector(
                          onTap: () => _showForgotPasswordDialog(context, pal.primary, pal.bg, pal.text, pal.sub, pal.surface, pal.line, pal.mute),
                          child: Text('비밀번호 찾기', style: GuidyText.small(pal.primary).copyWith(fontWeight: FontWeight.w700)),
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
                          color: pal.primary,
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
                          Text('계정이 없으신가요? ', style: GuidyText.small(pal.sub)),
                          GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.pushNamed(context, '/signup');
                            },
                            child: Text('회원가입', style: GuidyText.small(pal.primary).copyWith(fontWeight: FontWeight.w800)),
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

  void _snack(String message, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: error ? Colors.red.shade400 : GuidyColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: GuidyRadius.lgBorder),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Future<void> _handleLogin(BuildContext context) async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (email.isEmpty || password.isEmpty) {
      return _snack('이메일과 비밀번호를 입력해주세요', error: true);
    }

    setState(() => _isLoading = true);
    final userStore = context.read<UserStore>();
    final navigator = Navigator.of(context);
    try {
      final user = await AuthService.signInWithEmail(email, password);
      await userStore.updateProfile(name: user.displayName, email: user.email);
      // 이메일 로그인 화면을 닫고, 그 아래 로그인 화면도 닫거나(뒤에 화면이 있을 때) 홈으로
      navigator.pop();
      if (navigator.canPop()) {
        navigator.pop();
      } else {
        navigator.pushReplacementNamed('/home');
      }
    } on AccountBlockedException catch (e) {
      if (mounted) _snack(e.message, error: true);
    } catch (e) {
      debugPrint('[Auth] email login failed: $e');
      if (mounted) _snack(AuthService.errorMessage(e), error: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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
            onTap: () async {
              final email = emailCtrl.text.trim();
              if (!email.contains('@')) return _snack('이메일을 정확히 입력해주세요', error: true);
              Navigator.pop(context);
              try {
                await AuthService.sendPasswordReset(email);
                // 가입 여부를 알려주지 않는 것이 Firebase 기본 동작 (계정 존재 여부 노출 방지)
                if (mounted) _snack('가입된 이메일이면 재설정 링크를 보냈습니다. 메일함을 확인해주세요');
              } catch (e) {
                if (mounted) _snack(AuthService.errorMessage(e), error: true);
              }
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
