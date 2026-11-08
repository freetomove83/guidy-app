// lib/screens/mypage/delete_account_screen.dart
// 회원 탈퇴 화면

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../models/models.dart';
import '../../models/user_store.dart';
import '../../services/auth_service.dart';

class DeleteAccountScreen extends StatefulWidget {
  const DeleteAccountScreen({super.key});

  @override
  State<DeleteAccountScreen> createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends State<DeleteAccountScreen> {
  int _step = 0; // 0: 안내, 1: 확인 입력
  final _confirmCtrl = TextEditingController();
  final _pwCtrl = TextEditingController();
  final _hasPassword = AuthService.hasPassword;
  bool _agreed  = false;
  bool _loading = false;

  static const _confirmText = '탈퇴 확인';

  @override
  void dispose() {
    _confirmCtrl.dispose();
    _pwCtrl.dispose();
    super.dispose();
  }

  Future<void> _deleteAccount() async {
    setState(() => _loading = true);
    final userStore = context.read<UserStore>();
    final messenger = ScaffoldMessenger.of(context);
    try {
      final done = await AuthService.deleteAccount(password: _pwCtrl.text);
      if (!done) return; // 본인 확인 취소
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(AuthService.errorMessage(e))));
      return;
    } finally {
      if (mounted) setState(() => _loading = false);
    }
    await userStore.clearAll();
    if (!mounted) return;
    messenger.showSnackBar(const SnackBar(content: Text('탈퇴가 완료되었습니다')));
    Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
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
                    onTap: () {
                      if (_step == 1) {
                        setState(() { _step = 0; _agreed = false; });
                      } else {
                        Navigator.pop(context);
                      }
                    },
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
                  Text('회원 탈퇴', style: GuidyText.h3(pal.text)),
                ],
              ),
            ),
            const SizedBox(height: 4),

            // ─── 내용 ─────────────────────────────────
            Expanded(
              child: _step == 0
                  ? _buildStep0(context, pal.text, pal.sub, pal.mute, pal.surface, pal.line)
                  : _buildStep1(context, pal.text, pal.sub, pal.mute, pal.surface, pal.line),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep0(BuildContext ctx, Color textC, Color subC,
      Color muteC, Color surfaceC, Color lineC) {
    final userStore = ctx.read<UserStore>();
    final purchaseCount = userStore.purchases
        .where((p) => p.status != PurchaseStatus.cancelled).length;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 경고 배너
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.06),
              borderRadius: GuidyRadius.lgBorder,
              border: Border.all(color: Colors.red.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.10),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.warning_amber_rounded,
                      size: 22, color: Colors.red),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('탈퇴 전 꼭 확인하세요',
                          style: GuidyText.body(Colors.red)
                              .copyWith(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 2),
                      Text('탈퇴 후 모든 데이터가 삭제되며 복구할 수 없습니다.',
                          style: GuidyText.small(subC)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 삭제될 데이터 목록
          Text('삭제되는 정보', style: GuidyText.h3(textC)),
          const SizedBox(height: 12),
          _infoCard(surfaceC, lineC, textC, subC, muteC, [
            (Icons.person_rounded,       '계정 정보',       '이름, 이메일, 프로필 사진'),
            (Icons.receipt_long_rounded,  '구매한 가이드',   '$purchaseCount개 전시 가이드 이용 권한'),
            (Icons.bookmark_rounded,      '즐겨찾기 목록',   '저장한 전시 ${userStore.favorites.length}개'),
            (Icons.people_rounded,        '팔로우 정보',     '크리에이터 팔로우 ${userStore.following.length}개'),
            (Icons.headphones_rounded,    '오디오 진행 기록', '이어듣기 및 재생 기록'),
          ]),
          const SizedBox(height: 20),

          // 유의사항
          Text('유의사항', style: GuidyText.h3(textC)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: surfaceC,
              borderRadius: GuidyRadius.lgBorder,
              border: Border.all(color: lineC),
            ),
            child: Column(
              children: [
                _noticeItem('구매한 전시 가이드의 접근 권한이 즉시 사라집니다.', muteC),
                _noticeItem('환불이 필요한 경우 탈퇴 전 고객센터에 문의하세요.', muteC),
                _noticeItem('결제 기록은 전자상거래법에 따라 5년간 보관한 뒤 파기합니다.', muteC),
                _noticeItem('탈퇴 후 동일 이메일로 재가입이 가능합니다.', muteC),
                _noticeItem('탈퇴 처리 후 데이터 복구는 불가능합니다.', muteC, isLast: true),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // 동의 체크박스
          GestureDetector(
            onTap: () => setState(() => _agreed = !_agreed),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 22, height: 22,
                  decoration: BoxDecoration(
                    color: _agreed ? Colors.red : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: _agreed ? Colors.red : lineC,
                      width: 1.5,
                    ),
                  ),
                  child: _agreed
                      ? const Icon(Icons.check_rounded,
                          size: 14, color: Colors.white)
                      : null,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '위 내용을 모두 확인했으며, 회원 탈퇴에 동의합니다.',
                    style: GuidyText.body(textC).copyWith(fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 계속하기 버튼
          SizedBox(
            width: double.infinity,
            child: GestureDetector(
              onTap: _agreed
                  ? () => setState(() => _step = 1)
                  : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                height: 50,
                decoration: BoxDecoration(
                  color: _agreed
                      ? Colors.red.withValues(alpha: 0.9)
                      : lineC,
                  borderRadius: GuidyRadius.lgBorder,
                ),
                child: Center(
                  child: Text('다음 단계로',
                      style: GuidyText.body(
                        _agreed ? Colors.white : muteC,
                      ).copyWith(fontWeight: FontWeight.w700)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep1(BuildContext ctx, Color textC, Color subC,
      Color muteC, Color surfaceC, Color lineC) {
    final pal = GuidyPalette.of(ctx);
    final inputOk  = _confirmCtrl.text == _confirmText &&
        (!_hasPassword || _pwCtrl.text.isNotEmpty);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 진행 표시
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.06),
              borderRadius: GuidyRadius.mdBorder,
            ),
            child: Text('최종 확인 단계',
                style: GuidyText.small(Colors.red)
                    .copyWith(fontWeight: FontWeight.w700)),
          ),
          const SizedBox(height: 20),

          Text('탈퇴를 확인하려면\n아래에 "$_confirmText"를 입력하세요',
              style: GuidyText.h3(textC).copyWith(height: 1.4)),
          const SizedBox(height: 16),

          TextField(
            controller: _confirmCtrl,
            onChanged: (_) => setState(() {}),
            style: GuidyText.body(textC).copyWith(fontWeight: FontWeight.w500),
            decoration: InputDecoration(
              hintText: _confirmText,
              hintStyle: GuidyText.body(muteC),
              filled: true,
              fillColor: surfaceC,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: GuidyRadius.lgBorder,
                borderSide: BorderSide(color: lineC),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: GuidyRadius.lgBorder,
                borderSide: BorderSide(
                  color: inputOk ? GuidyColors.ok : lineC,
                  width: inputOk ? 1.5 : 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: GuidyRadius.lgBorder,
                borderSide: BorderSide(
                  color: inputOk ? GuidyColors.ok : pal.primary,
                  width: 1.5,
                ),
              ),
              suffixIcon: inputOk
                  ? const Icon(Icons.check_circle_rounded,
                      color: GuidyColors.ok, size: 20)
                  : null,
            ),
          ),
          const SizedBox(height: 8),
          if (_hasPassword) ...[
            const SizedBox(height: 16),
            Text('본인 확인을 위해 비밀번호를 입력하세요',
                style: GuidyText.body(textC).copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextField(
              controller: _pwCtrl,
              obscureText: true,
              onChanged: (_) => setState(() {}),
              style: GuidyText.body(textC),
              decoration: InputDecoration(
                hintText: '현재 비밀번호',
                hintStyle: GuidyText.body(muteC),
                filled: true,
                fillColor: surfaceC,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: GuidyRadius.lgBorder,
                  borderSide: BorderSide(color: lineC),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: GuidyRadius.lgBorder,
                  borderSide: BorderSide(color: lineC),
                ),
              ),
            ),
          ],
          const SizedBox(height: 8),
          Text(_hasPassword
                  ? '입력 후 버튼이 활성화됩니다.'
                  : '버튼을 누르면 로그인한 계정으로 한 번 더 확인합니다.',
              style: GuidyText.small(muteC)),
          const SizedBox(height: 32),

          SizedBox(
            width: double.infinity,
            child: GestureDetector(
              onTap: (inputOk && !_loading) ? _deleteAccount : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                height: 50,
                decoration: BoxDecoration(
                  color: inputOk
                      ? Colors.red.withValues(alpha: 0.9)
                      : lineC,
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
                      : Text('회원 탈퇴 완료',
                          style: GuidyText.body(
                            inputOk ? Colors.white : muteC,
                          ).copyWith(fontWeight: FontWeight.w700)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoCard(Color surfaceC, Color lineC, Color textC, Color subC,
      Color muteC, List<(IconData, String, String)> items) {
    return Container(
      decoration: BoxDecoration(
        color: surfaceC,
        borderRadius: GuidyRadius.lgBorder,
        border: Border.all(color: lineC),
      ),
      child: Column(
        children: items.asMap().entries.map((entry) {
          final i = entry.key;
          final item = entry.value;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Row(
                  children: [
                    Icon(item.$1, size: 17,
                        color: Colors.red.withValues(alpha: 0.7)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.$2,
                              style: GuidyText.body(textC)
                                  .copyWith(fontWeight: FontWeight.w600)),
                          Text(item.$3, style: GuidyText.small(subC)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (i < items.length - 1)
                Divider(color: lineC, height: 1, indent: 14, endIndent: 14),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _noticeItem(String text, Color muteC, {bool isLast = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 4, height: 4,
            margin: const EdgeInsets.only(top: 7, right: 8),
            decoration: BoxDecoration(
              color: muteC, shape: BoxShape.circle,
            ),
          ),
          Expanded(child: Text(text, style: GuidyText.small(muteC))),
        ],
      ),
    );
  }
}
