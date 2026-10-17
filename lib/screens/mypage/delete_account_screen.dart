// lib/screens/mypage/delete_account_screen.dart
// 회원 탈퇴 화면

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../models/models.dart';
import '../../models/user_store.dart';

class DeleteAccountScreen extends StatefulWidget {
  const DeleteAccountScreen({super.key});

  @override
  State<DeleteAccountScreen> createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends State<DeleteAccountScreen> {
  int _step = 0; // 0: 안내, 1: 확인 입력
  final _confirmCtrl = TextEditingController();
  bool _agreed  = false;
  bool _loading = false;

  static const _confirmText = '탈퇴 확인';

  @override
  void dispose() {
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _deleteAccount() async {
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 1000));
    if (!mounted) return;
    setState(() => _loading = false);
    // 실제 환경에서는 Firebase Auth 계정 삭제 + Firestore 데이터 삭제
    Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final isDark   = Theme.of(context).brightness == Brightness.dark;
    final bgC      = isDark ? GuidyColors.darkBg      : GuidyColors.bg;
    final textC    = isDark ? GuidyColors.darkText     : GuidyColors.ink;
    final subC     = isDark ? GuidyColors.darkSub      : GuidyColors.sub;
    final muteC    = isDark ? GuidyColors.darkMute     : GuidyColors.mute;
    final surfaceC = isDark ? GuidyColors.darkSurface  : GuidyColors.surface;
    final lineC    = isDark ? GuidyColors.darkLine     : GuidyColors.line;

    return Scaffold(
      backgroundColor: bgC,
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
                        color: surfaceC,
                        borderRadius: GuidyRadius.mdBorder,
                        border: Border.all(color: lineC),
                      ),
                      child: Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: textC),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text('회원 탈퇴', style: GuidyText.h3(textC)),
                ],
              ),
            ),
            const SizedBox(height: 4),

            // ─── 내용 ─────────────────────────────────
            Expanded(
              child: _step == 0
                  ? _buildStep0(context, textC, subC, muteC, surfaceC, lineC)
                  : _buildStep1(context, textC, subC, muteC, surfaceC, lineC),
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
              color: Colors.red.withOpacity(0.06),
              borderRadius: GuidyRadius.lgBorder,
              border: Border.all(color: Colors.red.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.10),
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
            (Icons.receipt_long_rounded,  '구매 내역',       '$purchaseCount개 구매한 전시 이용 기록'),
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
                      ? Colors.red.withOpacity(0.9)
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
    final isDark   = Theme.of(ctx).brightness == Brightness.dark;
    final primaryC = isDark ? GuidyColors.darkPrimary : GuidyColors.primary;
    final inputOk  = _confirmCtrl.text == _confirmText;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 진행 표시
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.06),
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
                  color: inputOk ? GuidyColors.ok : primaryC,
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
          Text('입력 후 버튼이 활성화됩니다.',
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
                      ? Colors.red.withOpacity(0.9)
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
                        color: Colors.red.withOpacity(0.7)),
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
