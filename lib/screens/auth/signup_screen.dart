// lib/screens/auth/signup_screen.dart
// 회원가입 화면 - 이메일 + 소셜 + 추천인 코드

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user_store.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _referralController = TextEditingController(); // 추천인 코드
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _agreeTerms = false;
  bool _agreeMarketing = false;
  bool _isLoading = false;
  bool _referralVerified = false; // 추천인 코드 확인 상태
  String? _referralError;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    _referralController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 딥링크/쿼리파라미터로 추천인 코드 자동 입력 지원
    // 예: Navigator.pushNamed(context, '/signup', arguments: {'referralCode': 'ABC123'})
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map && args.containsKey('referralCode')) {
      final code = args['referralCode'] as String;
      if (code.isNotEmpty && _referralController.text.isEmpty) {
        _referralController.text = code.toUpperCase();
        setState(() => _referralVerified = false);
      }
    }
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
            GuidyHeader(title: '회원가입', showBack: true),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 소셜 가입 섹션
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? GuidyColors.darkBgAlt : GuidyColors.bgAlt,
                        borderRadius: GuidyRadius.lgBorder,
                        border: Border.all(color: lineC),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('소셜 계정으로 가입', style: GuidyText.small(textC).copyWith(fontWeight: FontWeight.w700)),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              _SocialIconButton(
                                label: 'Google',
                                onTap: () => _handleSocialSignup(context, 'Google'),
                                bgColor: Colors.white,
                                borderColor: const Color(0xFFDADCE0),
                                child: _GoogleCircleIcon(),
                              ),
                              const SizedBox(width: 10),
                              _SocialIconButton(
                                label: 'Apple',
                                onTap: () => _handleSocialSignup(context, 'Apple'),
                                bgColor: Colors.black,
                                child: const Icon(Icons.apple, color: Colors.white, size: 22),
                              ),
                              const SizedBox(width: 10),
                              _SocialIconButton(
                                label: '네이버',
                                onTap: () => _handleSocialSignup(context, '네이버'),
                                bgColor: const Color(0xFF03C75A),
                                child: const Text('N', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 15)),
                              ),
                              const SizedBox(width: 10),
                              _SocialIconButton(
                                label: '카카오',
                                onTap: () => _handleSocialSignup(context, '카카오'),
                                bgColor: const Color(0xFFFEE500),
                                child: const Text('K', style: TextStyle(color: Color(0xFF191919), fontWeight: FontWeight.w900, fontSize: 15)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // 구분선
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Row(
                        children: [
                          Expanded(child: Divider(color: lineC)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            child: Text('이메일로 가입', style: GuidyText.small(muteC)),
                          ),
                          Expanded(child: Divider(color: lineC)),
                        ],
                      ),
                    ),

                    // 이름
                    GuidyInputLabel(label: '이름', textC: textC),
                    const SizedBox(height: 6),
                    GuidyInputField(
                      controller: _nameController,
                      hint: '이름을 입력해주세요',
                      surfaceC: surfaceC, lineC: lineC, textC: textC, subC: subC,
                    ),
                    const SizedBox(height: 14),

                    // 이메일
                    GuidyInputLabel(label: '이메일', textC: textC),
                    const SizedBox(height: 6),
                    GuidyInputField(
                      controller: _emailController,
                      hint: 'example@email.com',
                      keyboardType: TextInputType.emailAddress,
                      surfaceC: surfaceC, lineC: lineC, textC: textC, subC: subC,
                    ),
                    const SizedBox(height: 14),

                    // 비밀번호
                    GuidyInputLabel(label: '비밀번호', textC: textC),
                    const SizedBox(height: 6),
                    GuidyInputField(
                      controller: _passwordController,
                      hint: '8자 이상 영문, 숫자 포함',
                      obscureText: _obscurePassword,
                      surfaceC: surfaceC, lineC: lineC, textC: textC, subC: subC,
                      suffix: GestureDetector(
                        onTap: () => setState(() => _obscurePassword = !_obscurePassword),
                        child: Icon(
                          _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                          size: 20, color: muteC,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // 비밀번호 확인
                    GuidyInputLabel(label: '비밀번호 확인', textC: textC),
                    const SizedBox(height: 6),
                    GuidyInputField(
                      controller: _confirmController,
                      hint: '비밀번호를 다시 입력해주세요',
                      obscureText: _obscureConfirm,
                      surfaceC: surfaceC, lineC: lineC, textC: textC, subC: subC,
                      suffix: GestureDetector(
                        onTap: () => setState(() => _obscureConfirm = !_obscureConfirm),
                        child: Icon(
                          _obscureConfirm ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                          size: 20, color: muteC,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // ─── 추천인 코드 (선택) ───────────────────
                    Row(
                      children: [
                        GuidyInputLabel(label: '추천인 코드', textC: textC),
                        const SizedBox(width: 6),
                        Text('(선택)', style: GuidyText.small(muteC)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              GuidyInputField(
                                controller: _referralController,
                                hint: '초대 코드 6자리 입력 (예: GUIDY1)',
                                surfaceC: _referralVerified
                                    ? GuidyColors.ok.withValues(alpha: 0.08)
                                    : surfaceC,
                                lineC: _referralVerified
                                    ? GuidyColors.ok
                                    : (_referralError != null
                                        ? Colors.red.shade300
                                        : lineC),
                                textC: textC,
                                subC: subC,
                                suffix: _referralVerified
                                    ? const Icon(
                                        Icons.check_circle_rounded,
                                        color: GuidyColors.ok,
                                        size: 18,
                                      )
                                    : null,
                                onChanged: (v) {
                                  if (_referralVerified || _referralError != null) {
                                    setState(() {
                                      _referralVerified = false;
                                      _referralError = null;
                                    });
                                  }
                                  // 6자리 자동 대문자
                                  final up = v.toUpperCase();
                                  if (up != v) {
                                    _referralController.value =
                                        _referralController.value.copyWith(
                                      text: up,
                                      selection: TextSelection.collapsed(
                                          offset: up.length),
                                    );
                                  }
                                },
                              ),
                              if (_referralError != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4, left: 2),
                                  child: Text(_referralError!,
                                      style: GuidyText.kicker(
                                          Colors.red.shade400)),
                                ),
                              if (_referralVerified)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4, left: 2),
                                  child: Text('추천인 코드가 확인되었습니다 🎉',
                                      style: GuidyText.kicker(GuidyColors.ok)),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: _referralVerified ? null : _verifyReferralCode,
                          child: Container(
                            height: 50,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16),
                            decoration: BoxDecoration(
                              color: _referralVerified
                                  ? GuidyColors.ok.withValues(alpha: 0.15)
                                  : primaryC,
                              borderRadius: GuidyRadius.lgBorder,
                            ),
                            child: Center(
                              child: Text(
                                _referralVerified ? '확인됨' : '확인',
                                style: TextStyle(
                                  fontFamily: GuidyText.fontFamily,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: _referralVerified
                                      ? GuidyColors.ok
                                      : Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    // 추천인 혜택 안내
                    if (!_referralVerified)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Row(
                          children: [
                            Icon(Icons.card_giftcard_rounded,
                                size: 13, color: muteC),
                            const SizedBox(width: 5),
                            Text('친구의 초대 코드를 입력하면 가입 혜택이 제공됩니다',
                                style: GuidyText.kicker(muteC)),
                          ],
                        ),
                      ),

                    const SizedBox(height: 20),
                    _CheckItem(
                      value: _agreeTerms,
                      label: '[필수] 이용약관 및 개인정보처리방침 동의',
                      onChanged: (v) => setState(() => _agreeTerms = v ?? false),
                      textC: textC, primaryC: primaryC, lineC: lineC,
                      showArrow: true,
                      onArrowTap: () => _showTermsDialog(context, bgC, textC, subC, primaryC),
                    ),
                    const SizedBox(height: 8),
                    _CheckItem(
                      value: _agreeMarketing,
                      label: '[선택] 마케팅 정보 수신 동의',
                      onChanged: (v) => setState(() => _agreeMarketing = v ?? false),
                      textC: subC, primaryC: primaryC, lineC: lineC,
                    ),

                    const SizedBox(height: 28),

                    // 가입 버튼
                    GestureDetector(
                      onTap: (_isLoading || !_agreeTerms) ? null : () => _handleSignup(context),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: _agreeTerms ? primaryC : (isDark ? GuidyColors.darkLine : GuidyColors.line),
                          borderRadius: GuidyRadius.lgBorder,
                          boxShadow: _agreeTerms ? GuidyShadow.pop : null,
                        ),
                        child: _isLoading
                            ? const Center(child: SizedBox(width: 20, height: 20,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)))
                            : Text('가입하기', style: TextStyle(
                                fontFamily: GuidyText.fontFamily,
                                fontSize: 16, fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ), textAlign: TextAlign.center),
                      ),
                    ),

                    const SizedBox(height: 16),
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('이미 계정이 있으신가요? ', style: GuidyText.small(subC)),
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Text('로그인', style: GuidyText.small(primaryC).copyWith(fontWeight: FontWeight.w800)),
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

  void _verifyReferralCode() {
    final code = _referralController.text.trim().toUpperCase();
    if (code.isEmpty) {
      setState(() => _referralError = '코드를 입력해주세요');
      return;
    }
    if (code.length != 6) {
      setState(() => _referralError = '6자리 코드를 입력해주세요');
      return;
    }
    // 실제 환경에서는 서버 API 호출로 검증.
    // 데모에서는 길이 6자리 = 유효한 코드로 처리
    setState(() {
      _referralVerified = true;
      _referralError = null;
    });
  }

  void _handleSocialSignup(BuildContext context, String provider) {
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

  void _handleSignup(BuildContext context) {
    if (_nameController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty ||
        _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('모든 항목을 입력해주세요'),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: GuidyRadius.lgBorder),
          margin: const EdgeInsets.all(16),
        ),
      );
      return;
    }

    if (_passwordController.text != _confirmController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('비밀번호가 일치하지 않습니다'),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: GuidyRadius.lgBorder),
          margin: const EdgeInsets.all(16),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    Future.delayed(const Duration(milliseconds: 1500), () async {
      if (!mounted) return;

      // 추천인 코드가 확인된 경우 UserStore에 저장
      if (_referralVerified && _referralController.text.isNotEmpty) {
        final userStore = context.read<UserStore>();
        await userStore.applyReferralCode(_referralController.text.trim());
      }

      if (!mounted) return;
      setState(() => _isLoading = false);
      final isVerified = _referralVerified;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isVerified
              ? '가입 완료! 추천인 코드가 적용되었습니다 🎉'
              : '회원가입 기능 연동 준비 중입니다'),
          backgroundColor: GuidyColors.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: GuidyRadius.lgBorder),
          margin: const EdgeInsets.all(16),
        ),
      );
    });
  }

  void _showTermsDialog(BuildContext context, Color bgC, Color textC, Color subC, Color primaryC) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: bgC,
        shape: RoundedRectangleBorder(borderRadius: GuidyRadius.xlBorder),
        title: Text('이용약관', style: GuidyText.h3(textC)),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: SingleChildScrollView(
            child: Text(
              'Guidy 서비스 이용약관\n\n'
              '제1조 (목적)\n이 약관은 Guidy 서비스의 이용조건 및 절차, 회사와 회원 간의 권리, 의무 및 책임사항 등을 규정함을 목적으로 합니다.\n\n'
              '제2조 (이용약관의 효력)\n① 이 약관은 서비스를 이용하고자 하는 모든 회원에 대하여 그 효력을 발생합니다.\n'
              '② 이 약관에 동의함으로써 회원은 Guidy의 개인정보처리방침에도 동의한 것으로 간주됩니다.\n\n'
              '제3조 (서비스 이용)\n회원은 Guidy의 오디오 가이드 콘텐츠를 이용약관에 따라 이용할 수 있습니다.',
              style: GuidyText.small(subC),
            ),
          ),
        ),
        actions: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(color: primaryC, borderRadius: GuidyRadius.pillBorder),
              child: const Text('확인', style: TextStyle(
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

// ─── 소셜 아이콘 버튼 ─────────────────────────────────────
class _SocialIconButton extends StatelessWidget {
  final Widget child;
  final String label;
  final VoidCallback onTap;
  final Color bgColor;
  final Color? borderColor;

  const _SocialIconButton({
    required this.child,
    required this.label,
    required this.onTap,
    required this.bgColor,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(
                color: bgColor,
                shape: BoxShape.circle,
                border: borderColor != null ? Border.all(color: borderColor!) : null,
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 6, offset: const Offset(0, 2))],
              ),
              child: Center(child: child),
            ),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(
              fontFamily: GuidyText.fontFamily, fontSize: 10, color: GuidyColors.mute,
            )),
          ],
        ),
      ),
    );
  }
}

class _GoogleCircleIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Text('G', style: TextStyle(
      color: Color(0xFF4285F4), fontWeight: FontWeight.w900, fontSize: 18,
    ));
  }
}

class _CheckItem extends StatelessWidget {
  final bool value;
  final String label;
  final ValueChanged<bool?> onChanged;
  final Color textC;
  final Color primaryC;
  final Color lineC;
  final bool showArrow;
  final VoidCallback? onArrowTap;

  const _CheckItem({
    required this.value,
    required this.label,
    required this.onChanged,
    required this.textC,
    required this.primaryC,
    required this.lineC,
    this.showArrow = false,
    this.onArrowTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 22, height: 22,
          child: Checkbox(
            value: value,
            onChanged: onChanged,
            activeColor: primaryC,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            side: BorderSide(color: lineC, width: 1.5),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(label, style: TextStyle(
            fontFamily: GuidyText.fontFamily, fontSize: 13,
            color: textC, letterSpacing: -0.1,
          )),
        ),
        if (showArrow && onArrowTap != null)
          GestureDetector(
            onTap: onArrowTap,
            child: const Icon(Icons.chevron_right_rounded, size: 18, color: GuidyColors.mute),
          ),
      ],
    );
  }
}
