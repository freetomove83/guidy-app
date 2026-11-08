// lib/screens/mypage/change_password_screen.dart
// 비밀번호 변경 화면

import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey     = GlobalKey<FormState>();
  final _currentCtrl = TextEditingController();
  final _newCtrl     = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _showCurrent = false;
  bool _showNew     = false;
  bool _showConfirm = false;
  bool _loading     = false;

  // 비밀번호 강도 판정
  _PwStrength get _strength {
    final pw = _newCtrl.text;
    if (pw.length < 6) return _PwStrength.none;
    int score = 0;
    if (pw.length >= 8) score++;
    if (RegExp(r'[A-Za-z]').hasMatch(pw)) score++;
    if (RegExp(r'[0-9]').hasMatch(pw)) score++;
    if (RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(pw)) score++;
    if (score <= 1) return _PwStrength.weak;
    if (score == 2) return _PwStrength.medium;
    if (score == 3) return _PwStrength.good;
    return _PwStrength.strong;
  }

  @override
  void dispose() {
    _currentCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  void _snack(String message, Color color) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: color,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: GuidyRadius.mdBorder),
        ),
      );

  Future<void> _submit() async {
    // Google·Apple로 가입한 계정은 비밀번호가 없음 — 해당 계정 설정에서 관리
    if (!AuthService.hasPassword) {
      return _snack('Google·Apple 로그인 계정은 비밀번호가 없습니다. 해당 계정에서 관리해주세요',
          GuidyColors.warn);
    }
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await AuthService.changePassword(_currentCtrl.text, _newCtrl.text);
      if (!mounted) return;
      _snack('비밀번호가 성공적으로 변경되었습니다', GuidyColors.ok);
      Navigator.pop(context);
    } catch (e) {
      if (mounted) _snack(AuthService.errorMessage(e), Colors.red.shade400);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final pal = GuidyPalette.of(context);

    return Scaffold(
      backgroundColor: pal.bg,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // ─── 헤더 ─────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(
                        color: pal.surface,
                        borderRadius: GuidyRadius.mdBorder,
                        border: Border.all(color: pal.line),
                      ),
                      child: Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: pal.text),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text('비밀번호 변경', style: GuidyText.h3(pal.text)),
                ],
              ),
            ),
            const SizedBox(height: 4),

            // ─── 내용 ─────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 보안 안내
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: GuidyColors.primarySoft,
                          borderRadius: GuidyRadius.lgBorder,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.security_rounded,
                                size: 16, color: pal.primary),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '비밀번호는 8자 이상, 영문·숫자·특수문자를 조합하면 더욱 안전합니다.',
                                style: GuidyText.small(pal.sub),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // 현재 비밀번호
                      Text('현재 비밀번호', style: GuidyText.body(pal.text)
                          .copyWith(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 8),
                      _PwField(
                        controller: _currentCtrl,
                        hint: '현재 비밀번호를 입력하세요',
                        show: _showCurrent,
                        onToggle: () => setState(() => _showCurrent = !_showCurrent),
                        surfaceC: pal.surface,
                        lineC: pal.line,
                        textC: pal.text,
                        muteC: pal.mute,
                        primaryC: pal.primary,
                        validator: (v) {
                          if (v == null || v.isEmpty) return '현재 비밀번호를 입력해주세요';
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // 새 비밀번호
                      Text('새 비밀번호', style: GuidyText.body(pal.text)
                          .copyWith(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 8),
                      _PwField(
                        controller: _newCtrl,
                        hint: '새 비밀번호를 입력하세요 (8자 이상)',
                        show: _showNew,
                        onToggle: () => setState(() => _showNew = !_showNew),
                        surfaceC: pal.surface,
                        lineC: pal.line,
                        textC: pal.text,
                        muteC: pal.mute,
                        primaryC: pal.primary,
                        onChanged: (_) => setState(() {}),
                        validator: (v) {
                          if (v == null || v.isEmpty) return '새 비밀번호를 입력해주세요';
                          if (v.length < 8) return '8자 이상 입력해주세요';
                          if (!RegExp(r'[A-Za-z]').hasMatch(v) || !RegExp(r'[0-9]').hasMatch(v)) {
                            return '영문과 숫자를 함께 써주세요';
                          }
                          if (v == _currentCtrl.text) return '현재 비밀번호와 다르게 설정해주세요';
                          return null;
                        },
                      ),
                      // 비밀번호 강도 표시
                      if (_newCtrl.text.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        _StrengthBar(strength: _strength),
                      ],
                      const SizedBox(height: 20),

                      // 새 비밀번호 확인
                      Text('비밀번호 확인', style: GuidyText.body(pal.text)
                          .copyWith(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 8),
                      _PwField(
                        controller: _confirmCtrl,
                        hint: '새 비밀번호를 다시 입력하세요',
                        show: _showConfirm,
                        onToggle: () => setState(() => _showConfirm = !_showConfirm),
                        surfaceC: pal.surface,
                        lineC: pal.line,
                        textC: pal.text,
                        muteC: pal.mute,
                        primaryC: pal.primary,
                        validator: (v) {
                          if (v == null || v.isEmpty) return '비밀번호 확인을 입력해주세요';
                          if (v != _newCtrl.text) return '새 비밀번호와 일치하지 않습니다';
                          return null;
                        },
                      ),
                      const SizedBox(height: 32),

                      // 변경 버튼
                      SizedBox(
                        width: double.infinity,
                        child: GestureDetector(
                          onTap: _loading ? null : _submit,
                          child: Container(
                            height: 50,
                            decoration: BoxDecoration(
                              color: pal.accent,
                              borderRadius: GuidyRadius.lgBorder,
                            ),
                            child: Center(
                              child: _loading
                                  ? const SizedBox(
                                      width: 20, height: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white, strokeWidth: 2,
                                      ),
                                    )
                                  : Text('비밀번호 변경',
                                      style: GuidyText.body(Colors.white)
                                          .copyWith(fontWeight: FontWeight.w700)),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum _PwStrength { none, weak, medium, good, strong }

class _StrengthBar extends StatelessWidget {
  final _PwStrength strength;
  const _StrengthBar({required this.strength});

  @override
  Widget build(BuildContext context) {
    final pal = GuidyPalette.of(context);

    final (label, color, filled) = switch (strength) {
      _PwStrength.none   => ('', Colors.transparent, 0),
      _PwStrength.weak   => ('약함',    Colors.red,    1),
      _PwStrength.medium => ('보통',    const Color(0xFFF59E0B), 2),
      _PwStrength.good   => ('좋음',    GuidyColors.primary, 3),
      _PwStrength.strong => ('강력',    GuidyColors.ok,  4),
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: List.generate(4, (i) => Expanded(
            child: Container(
              height: 4,
              margin: EdgeInsets.only(right: i < 3 ? 4 : 0),
              decoration: BoxDecoration(
                color: i < filled ? color : pal.line,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          )),
        ),
        const SizedBox(height: 4),
        Text('비밀번호 강도: $label',
            style: GuidyText.small(color)
                .copyWith(fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _PwField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool show;
  final VoidCallback onToggle;
  final Color surfaceC, lineC, textC, muteC, primaryC;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;

  const _PwField({
    required this.controller,
    required this.hint,
    required this.show,
    required this.onToggle,
    required this.surfaceC,
    required this.lineC,
    required this.textC,
    required this.muteC,
    required this.primaryC,
    this.validator,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: !show,
      onChanged: onChanged,
      style: GuidyText.body(textC).copyWith(fontWeight: FontWeight.w500),
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GuidyText.body(muteC),
        filled: true,
        fillColor: surfaceC,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: GuidyRadius.lgBorder,
          borderSide: BorderSide(color: lineC),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: GuidyRadius.lgBorder,
          borderSide: BorderSide(color: lineC),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: GuidyRadius.lgBorder,
          borderSide: BorderSide(color: primaryC, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: GuidyRadius.lgBorder,
          borderSide: const BorderSide(color: GuidyColors.danger),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: GuidyRadius.lgBorder,
          borderSide: const BorderSide(color: GuidyColors.danger, width: 1.5),
        ),
        suffixIcon: GestureDetector(
          onTap: onToggle,
          child: Icon(
            show ? Icons.visibility_rounded : Icons.visibility_off_rounded,
            size: 18, color: muteC,
          ),
        ),
      ),
    );
  }
}
