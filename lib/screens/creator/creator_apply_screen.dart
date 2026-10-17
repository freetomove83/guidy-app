// lib/screens/creator/creator_apply_screen.dart
// 크리에이터 신청 / 진행 상황 화면

import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../theme/app_theme.dart';
import '../../models/user_store.dart';

// SharedPreferences 키 — CMS와 동일 키 사용
const _kTermsService = 'guidy_terms_service';
const _kTermsCreator = 'guidy_terms_creator';

// 약관 로드 함수
Future<String> _loadTerms(String key, String fallback) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString(key) ?? fallback;
}

// 약관 모달 표시
void _showTermsModal(
  BuildContext context, {
  required String title,
  required Future<String> contentFuture,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _TermsModal(title: title, contentFuture: contentFuture),
  );
}

class CreatorApplyScreen extends StatelessWidget {
  const CreatorApplyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<UserStore>(
      builder: (context, userStore, _) {
        return switch (userStore.creatorStatus) {
          CreatorApplyStatus.none     => const _ApplyFormView(),
          CreatorApplyStatus.pending  => const _PendingView(),
          CreatorApplyStatus.approved => const _ApprovedView(),
        };
      },
    );
  }
}

// ─── 진행 스텝 인디케이터 ───────────────────────────────────
class _StepIndicator extends StatelessWidget {
  final int currentStep; // 0: 신청, 1: 검토 중, 2: 승인 완료
  const _StepIndicator(this.currentStep);

  static const _steps = ['신청서 작성', '검토 중', '승인 완료'];

  @override
  Widget build(BuildContext context) {
    final isDark   = Theme.of(context).brightness == Brightness.dark;
    final lineC    = isDark ? GuidyColors.darkLine    : GuidyColors.line;
    final muteC    = isDark ? GuidyColors.darkMute    : GuidyColors.mute;
    final textC    = isDark ? GuidyColors.darkText    : GuidyColors.ink;
    final primaryC = isDark ? GuidyColors.darkPrimary : GuidyColors.primary;

    return Row(
      children: List.generate(_steps.length * 2 - 1, (i) {
        if (i.isOdd) {
          // 연결선
          final filled = (i ~/ 2) < currentStep;
          return Expanded(
            child: Container(
              height: 2,
              color: filled ? primaryC : lineC,
            ),
          );
        }
        final stepIdx = i ~/ 2;
        final isDone   = stepIdx < currentStep;
        final isCurrent = stepIdx == currentStep;

        return Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 28, height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDone || isCurrent ? primaryC : Colors.transparent,
                border: Border.all(
                  color: isDone || isCurrent ? primaryC : lineC,
                  width: 1.5,
                ),
              ),
              child: Center(
                child: isDone
                    ? const Icon(Icons.check_rounded,
                        size: 14, color: Colors.white)
                    : Text('${stepIdx + 1}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: isCurrent ? Colors.white : muteC,
                        )),
              ),
            ),
            const SizedBox(height: 4),
            Text(_steps[stepIdx],
                style: TextStyle(
                  fontSize: 10,
                  fontFamily: GuidyText.fontFamily,
                  fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w400,
                  color: isCurrent || isDone ? textC : muteC,
                )),
          ],
        );
      }),
    );
  }
}

// ─── 1단계: 신청서 작성 ─────────────────────────────────────
class _ApplyFormView extends StatefulWidget {
  const _ApplyFormView();

  @override
  State<_ApplyFormView> createState() => _ApplyFormViewState();
}

class _ApplyFormViewState extends State<_ApplyFormView> {
  final _nameCtrl  = TextEditingController();
  final _introCtrl = TextEditingController();
  final _linkCtrl  = TextEditingController();
  String? _selectedField;
  bool _agreed  = false;
  bool _loading = false;

  static const _fields = [
    '미술·현대미술', '사진', '조각·설치', '공예·디자인',
    '음악', '공연·연극', '역사·문화유산', '건축', '기타',
  ];

  bool get _canSubmit =>
      _nameCtrl.text.trim().isNotEmpty &&
      _introCtrl.text.trim().isNotEmpty &&
      _selectedField != null &&
      _agreed;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _introCtrl.dispose();
    _linkCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    await context.read<UserStore>().applyCreator();
    setState(() => _loading = false);
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
    final primaryC = isDark ? GuidyColors.darkPrimary  : GuidyColors.primary;
    final accentC  = isDark ? GuidyColors.darkAccent   : GuidyColors.accent;

    return Scaffold(
      backgroundColor: bgC,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // 헤더
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(
                        color: surfaceC,
                        borderRadius: GuidyRadius.mdBorder,
                        border: Border.all(color: lineC),
                      ),
                      child: Icon(Icons.arrow_back_ios_new_rounded,
                          size: 16, color: textC),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text('크리에이터 신청', style: GuidyText.h3(textC)),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 스텝 인디케이터
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: const _StepIndicator(0),
            ),
            const SizedBox(height: 8),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 안내 배너
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: GuidyColors.primarySoft,
                        borderRadius: GuidyRadius.lgBorder,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.mic_rounded, color: primaryC, size: 18),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('크리에이터가 되어 수익을 창출하세요',
                                    style: GuidyText.body(primaryC)
                                        .copyWith(fontWeight: FontWeight.w700)),
                                const SizedBox(height: 4),
                                Text(
                                    '오디오 가이드를 제작하고 전시 큐레이터로 활동하며\n'
                                    '판매 수익의 70%를 받으세요.',
                                    style: GuidyText.small(subC)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 이름
                    _fieldLabel('활동 이름 *', textC),
                    const SizedBox(height: 6),
                    _inputField(
                      controller: _nameCtrl,
                      hint: '크리에이터 이름 또는 채널명',
                      surfaceC: surfaceC, lineC: lineC,
                      textC: textC, muteC: muteC, primaryC: primaryC,
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 16),

                    // 전문 분야
                    _fieldLabel('전문 분야 *', textC),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8, runSpacing: 8,
                      children: _fields.map((f) {
                        final selected = _selectedField == f;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedField = f),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 7),
                            decoration: BoxDecoration(
                              color: selected ? primaryC : surfaceC,
                              borderRadius: GuidyRadius.pillBorder,
                              border: Border.all(
                                color: selected ? primaryC : lineC,
                                width: selected ? 1.5 : 1,
                              ),
                            ),
                            child: Text(f,
                                style: GuidyText.small(
                                    selected ? Colors.white : subC)
                                    .copyWith(fontWeight: FontWeight.w600)),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),

                    // 자기소개
                    _fieldLabel('자기 소개 *', textC),
                    const SizedBox(height: 6),
                    Container(
                      decoration: BoxDecoration(
                        color: surfaceC,
                        borderRadius: GuidyRadius.lgBorder,
                        border: Border.all(color: lineC),
                      ),
                      child: TextField(
                        controller: _introCtrl,
                        minLines: 4,
                        maxLines: 6,
                        maxLength: 300,
                        onChanged: (_) => setState(() {}),
                        style: GuidyText.body(textC)
                            .copyWith(fontWeight: FontWeight.w500),
                        decoration: InputDecoration(
                          hintText: '예술·문화에 대한 열정과 경험을 소개해주세요. (최대 300자)',
                          hintStyle: GuidyText.body(muteC),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.all(14),
                          counterStyle: GuidyText.kicker(muteC),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 포트폴리오/SNS 링크 (선택)
                    _fieldLabel('포트폴리오 / SNS 링크 (선택)', textC),
                    const SizedBox(height: 6),
                    _inputField(
                      controller: _linkCtrl,
                      hint: 'https://instagram.com/yourname',
                      surfaceC: surfaceC, lineC: lineC,
                      textC: textC, muteC: muteC, primaryC: primaryC,
                      keyboardType: TextInputType.url,
                    ),
                    const SizedBox(height: 24),

                    // 동의 + 약관 링크
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 체크박스
                        GestureDetector(
                          onTap: () => setState(() => _agreed = !_agreed),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            width: 20, height: 20,
                            margin: const EdgeInsets.only(top: 2),
                            decoration: BoxDecoration(
                              color: _agreed ? primaryC : Colors.transparent,
                              borderRadius: BorderRadius.circular(5),
                              border: Border.all(
                                color: _agreed ? primaryC : lineC,
                                width: 1.5,
                              ),
                            ),
                            child: _agreed
                                ? const Icon(Icons.check_rounded,
                                    size: 13, color: Colors.white)
                                : null,
                          ),
                        ),
                        const SizedBox(width: 10),
                        // 약관 텍스트 (링크 포함)
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              style: GuidyText.body(subC)
                                  .copyWith(fontWeight: FontWeight.w500),
                              children: [
                                const TextSpan(text: '크리에이터 운영 정책 및 '),
                                TextSpan(
                                  text: '수익·정산 약관',
                                  style: GuidyText.body(primaryC).copyWith(
                                    fontWeight: FontWeight.w700,
                                    decoration: TextDecoration.underline,
                                    decorationColor: primaryC,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () => _showTermsModal(
                                      context,
                                      title: '크리에이터 수익·정산 약관',
                                      contentFuture: _loadTerms(
                                        _kTermsCreator,
                                        '약관을 불러오는 중입니다...\n관리자 페이지에서 약관을 등록해 주세요.',
                                      ),
                                    ),
                                ),
                                const TextSpan(text: ' 및 '),
                                TextSpan(
                                  text: '이용약관',
                                  style: GuidyText.body(primaryC).copyWith(
                                    fontWeight: FontWeight.w700,
                                    decoration: TextDecoration.underline,
                                    decorationColor: primaryC,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () => _showTermsModal(
                                      context,
                                      title: '서비스 이용약관',
                                      contentFuture: _loadTerms(
                                        _kTermsService,
                                        '약관을 불러오는 중입니다...\n관리자 페이지에서 약관을 등록해 주세요.',
                                      ),
                                    ),
                                ),
                                const TextSpan(text: '에 동의합니다.'),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),

                    // 신청 버튼
                    SizedBox(
                      width: double.infinity,
                      child: GestureDetector(
                        onTap: (_canSubmit && !_loading) ? _submit : null,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          height: 50,
                          decoration: BoxDecoration(
                            color: _canSubmit ? accentC : lineC,
                            borderRadius: GuidyRadius.lgBorder,
                          ),
                          child: Center(
                            child: _loading
                                ? const SizedBox(
                                    width: 20, height: 20,
                                    child: CircularProgressIndicator(
                                        color: Colors.white, strokeWidth: 2),
                                  )
                                : Text('신청서 제출',
                                    style: GuidyText.body(
                                      _canSubmit ? Colors.white : muteC,
                                    ).copyWith(fontWeight: FontWeight.w700)),
                          ),
                        ),
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

  Widget _fieldLabel(String text, Color color) =>
      Text(text, style: GuidyText.body(color).copyWith(fontWeight: FontWeight.w700));

  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    required Color surfaceC,
    required Color lineC,
    required Color textC,
    required Color muteC,
    required Color primaryC,
    TextInputType keyboardType = TextInputType.text,
    ValueChanged<String>? onChanged,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      onChanged: onChanged,
      style: GuidyText.body(textC).copyWith(fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GuidyText.body(muteC),
        filled: true,
        fillColor: surfaceC,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
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
      ),
    );
  }
}

// ─── 2단계: 검토 중 (승인 대기) ─────────────────────────────
class _PendingView extends StatelessWidget {
  const _PendingView();

  @override
  Widget build(BuildContext context) {
    final isDark   = Theme.of(context).brightness == Brightness.dark;
    final bgC      = isDark ? GuidyColors.darkBg      : GuidyColors.bg;
    final textC    = isDark ? GuidyColors.darkText     : GuidyColors.ink;
    final subC     = isDark ? GuidyColors.darkSub      : GuidyColors.sub;
    final muteC    = isDark ? GuidyColors.darkMute     : GuidyColors.mute;
    final surfaceC = isDark ? GuidyColors.darkSurface  : GuidyColors.surface;
    final lineC    = isDark ? GuidyColors.darkLine     : GuidyColors.line;
    final primaryC = isDark ? GuidyColors.darkPrimary  : GuidyColors.primary;

    final userStore   = context.watch<UserStore>();
    final appliedAt   = userStore.creatorAppliedAt;
    final appliedText = appliedAt != null
        ? '${appliedAt.year}.${appliedAt.month.toString().padLeft(2, '0')}'
          '.${appliedAt.day.toString().padLeft(2, '0')} 접수'
        : '신청 접수됨';

    return Scaffold(
      backgroundColor: bgC,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(
                        color: surfaceC,
                        borderRadius: GuidyRadius.mdBorder,
                        border: Border.all(color: lineC),
                      ),
                      child: Icon(Icons.arrow_back_ios_new_rounded,
                          size: 16, color: textC),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text('크리에이터 신청', style: GuidyText.h3(textC)),
                ],
              ),
            ),
            const SizedBox(height: 16),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: const _StepIndicator(1),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 28, 20, 100),
                child: Column(
                  children: [
                    // 상태 아이콘
                    _PulsingIcon(primaryC: primaryC),
                    const SizedBox(height: 20),

                    Text('신청서가 접수되었습니다',
                        style: GuidyText.h2(textC)
                            .copyWith(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 8),
                    Text('팀이 신청서를 검토 중입니다.\n영업일 기준 3~5일 내에 결과를 알려드립니다.',
                        style: GuidyText.body(subC),
                        textAlign: TextAlign.center),
                    const SizedBox(height: 28),

                    // 타임라인
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: surfaceC,
                        borderRadius: GuidyRadius.lgBorder,
                        border: Border.all(color: lineC),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('진행 상황', style: GuidyText.body(textC)
                              .copyWith(fontWeight: FontWeight.w700)),
                          const SizedBox(height: 16),
                          _timelineItem(
                            icon: Icons.check_circle_rounded,
                            color: GuidyColors.ok,
                            title: '신청서 제출 완료',
                            desc: appliedText,
                            isDone: true,
                            lineC: lineC,
                            textC: textC,
                            muteC: muteC,
                          ),
                          _timelineItem(
                            icon: Icons.manage_search_rounded,
                            color: primaryC,
                            title: '서류 검토 중',
                            desc: '신청서 내용을 확인하고 있습니다',
                            isDone: false,
                            isActive: true,
                            lineC: lineC,
                            textC: textC,
                            muteC: muteC,
                          ),
                          _timelineItem(
                            icon: Icons.verified_rounded,
                            color: muteC,
                            title: '승인 완료',
                            desc: '크리에이터 활동 시작',
                            isDone: false,
                            isLast: true,
                            lineC: lineC,
                            textC: textC,
                            muteC: muteC,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 안내 사항
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: GuidyColors.primarySoft,
                        borderRadius: GuidyRadius.lgBorder,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            Icon(Icons.info_outline_rounded,
                                size: 14, color: primaryC),
                            const SizedBox(width: 6),
                            Text('검토 안내',
                                style: GuidyText.small(primaryC)
                                    .copyWith(fontWeight: FontWeight.w700)),
                          ]),
                          const SizedBox(height: 8),
                          ...[
                            '결과는 이메일로도 발송됩니다.',
                            '검토 기간 중에는 신청 내용을 수정할 수 없습니다.',
                            '문의사항은 고객센터를 이용해주세요.',
                          ].map((t) => Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 3, height: 3,
                                  margin: const EdgeInsets.only(top: 7, right: 7),
                                  decoration: BoxDecoration(
                                    color: subC, shape: BoxShape.circle),
                                ),
                                Expanded(child: Text(t,
                                    style: GuidyText.small(subC))),
                              ],
                            ),
                          )),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 개발 테스트용: 승인 시뮬레이션 버튼
                    GestureDetector(
                      onTap: () => context.read<UserStore>().approveCreator(),
                      child: Container(
                        width: double.infinity,
                        height: 44,
                        decoration: BoxDecoration(
                          color: surfaceC,
                          borderRadius: GuidyRadius.lgBorder,
                          border: Border.all(color: lineC),
                        ),
                        child: Center(
                          child: Text('[개발용] 승인 시뮬레이션',
                              style: GuidyText.small(muteC)
                                  .copyWith(fontWeight: FontWeight.w600)),
                        ),
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
}

// ─── 3단계: 승인 완료 ───────────────────────────────────────
class _ApprovedView extends StatelessWidget {
  const _ApprovedView();

  @override
  Widget build(BuildContext context) {
    final isDark   = Theme.of(context).brightness == Brightness.dark;
    final bgC      = isDark ? GuidyColors.darkBg      : GuidyColors.bg;
    final textC    = isDark ? GuidyColors.darkText     : GuidyColors.ink;
    final subC     = isDark ? GuidyColors.darkSub      : GuidyColors.sub;
    final muteC    = isDark ? GuidyColors.darkMute     : GuidyColors.mute;
    final surfaceC = isDark ? GuidyColors.darkSurface  : GuidyColors.surface;
    final lineC    = isDark ? GuidyColors.darkLine     : GuidyColors.line;
    final primaryC = isDark ? GuidyColors.darkPrimary  : GuidyColors.primary;
    final accentC  = isDark ? GuidyColors.darkAccent   : GuidyColors.accent;

    final userStore   = context.watch<UserStore>();
    final approvedAt  = userStore.creatorApprovedAt;
    final approvedText = approvedAt != null
        ? '${approvedAt.year}.${approvedAt.month.toString().padLeft(2, '0')}'
          '.${approvedAt.day.toString().padLeft(2, '0')} 승인'
        : '승인됨';

    return Scaffold(
      backgroundColor: bgC,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(
                        color: surfaceC,
                        borderRadius: GuidyRadius.mdBorder,
                        border: Border.all(color: lineC),
                      ),
                      child: Icon(Icons.arrow_back_ios_new_rounded,
                          size: 16, color: textC),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text('크리에이터 신청', style: GuidyText.h3(textC)),
                ],
              ),
            ),
            const SizedBox(height: 16),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: const _StepIndicator(2),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 28, 20, 100),
                child: Column(
                  children: [
                    // 완료 아이콘
                    Container(
                      width: 80, height: 80,
                      decoration: BoxDecoration(
                        color: GuidyColors.ok.withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.verified_rounded,
                          size: 40, color: GuidyColors.ok),
                    ),
                    const SizedBox(height: 20),

                    Text('크리에이터 승인이 완료되었습니다!',
                        style: GuidyText.h2(textC)
                            .copyWith(fontWeight: FontWeight.w800),
                        textAlign: TextAlign.center),
                    const SizedBox(height: 8),
                    Text('이제 오디오 가이드를 제작하고\n수익을 창출할 수 있습니다.',
                        style: GuidyText.body(subC),
                        textAlign: TextAlign.center),
                    const SizedBox(height: 28),

                    // 승인 정보 카드
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: GuidyColors.ok.withOpacity(0.06),
                        borderRadius: GuidyRadius.lgBorder,
                        border: Border.all(
                            color: GuidyColors.ok.withOpacity(0.2)),
                      ),
                      child: Column(
                        children: [
                          Row(children: [
                            Icon(Icons.check_circle_rounded,
                                size: 16, color: GuidyColors.ok),
                            const SizedBox(width: 8),
                            Text(approvedText,
                                style: GuidyText.body(GuidyColors.ok)
                                    .copyWith(fontWeight: FontWeight.w700)),
                          ]),
                          const SizedBox(height: 12),
                          _benefitRow(Icons.mic_rounded,
                              '오디오 가이드 제작 · 업로드', primaryC, subC),
                          _benefitRow(Icons.attach_money_rounded,
                              '판매 수익의 70% 정산', primaryC, subC),
                          _benefitRow(Icons.people_rounded,
                              '팔로워와 소통하는 크리에이터 채널', primaryC, subC),
                          _benefitRow(Icons.analytics_rounded,
                              '실시간 재생 · 수익 통계 대시보드', primaryC, subC),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 크리에이터 스튜디오 이동
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/creator-studio');
                      },
                      child: Container(
                        width: double.infinity,
                        height: 50,
                        decoration: BoxDecoration(
                          color: accentC,
                          borderRadius: GuidyRadius.lgBorder,
                        ),
                        child: Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.mic_rounded,
                                  size: 18, color: Colors.white),
                              const SizedBox(width: 8),
                              Text('크리에이터 스튜디오 시작하기',
                                  style: GuidyText.body(Colors.white)
                                      .copyWith(fontWeight: FontWeight.w700)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // 신청 초기화 (개발용)
                    GestureDetector(
                      onTap: () => context.read<UserStore>().resetCreatorStatus(),
                      child: Container(
                        width: double.infinity,
                        height: 44,
                        decoration: BoxDecoration(
                          color: surfaceC,
                          borderRadius: GuidyRadius.lgBorder,
                          border: Border.all(color: lineC),
                        ),
                        child: Center(
                          child: Text('[개발용] 상태 초기화',
                              style: GuidyText.small(muteC)
                                  .copyWith(fontWeight: FontWeight.w600)),
                        ),
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

  Widget _benefitRow(IconData icon, String text,
      Color primaryC, Color subC) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          Icon(icon, size: 15, color: primaryC),
          const SizedBox(width: 8),
          Text(text, style: GuidyText.body(subC)),
        ],
      ),
    );
  }
}

// ─── 애니메이션 아이콘 (검토 중) ────────────────────────────
class _PulsingIcon extends StatefulWidget {
  final Color primaryC;
  const _PulsingIcon({required this.primaryC});

  @override
  State<_PulsingIcon> createState() => _PulsingIconState();
}

class _PulsingIconState extends State<_PulsingIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Transform.scale(
        scale: _anim.value,
        child: Container(
          width: 80, height: 80,
          decoration: BoxDecoration(
            color: widget.primaryC.withOpacity(0.10 + 0.05 * _anim.value),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.manage_search_rounded,
              size: 38, color: widget.primaryC),
        ),
      ),
    );
  }
}

// ─── 타임라인 아이템 ────────────────────────────────────────
Widget _timelineItem({
  required IconData icon,
  required Color color,
  required String title,
  required String desc,
  required bool isDone,
  required Color lineC,
  required Color textC,
  required Color muteC,
  bool isActive = false,
  bool isLast = false,
}) {
  return IntrinsicHeight(
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 28, height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDone
                    ? color.withOpacity(0.12)
                    : isActive
                        ? color.withOpacity(0.12)
                        : Colors.transparent,
                border: Border.all(
                  color: isDone || isActive ? color : lineC,
                  width: 1.5,
                ),
              ),
              child: Icon(icon, size: 14, color: isDone || isActive ? color : muteC),
            ),
            if (!isLast)
              Expanded(
                child: Container(
                  width: 2,
                  margin: const EdgeInsets.symmetric(vertical: 3),
                  color: isDone ? color.withOpacity(0.4) : lineC,
                ),
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(title,
                    style: TextStyle(
                      fontFamily: GuidyText.fontFamily,
                      fontSize: 14,
                      fontWeight: isDone || isActive
                          ? FontWeight.w700 : FontWeight.w400,
                      color: isDone || isActive ? textC : muteC,
                    )),
                const SizedBox(height: 2),
                Text(desc, style: GuidyText.small(muteC)),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

// ─── 약관 모달 ─────────────────────────────────────────────────
class _TermsModal extends StatefulWidget {
  final String title;
  final Future<String> contentFuture;
  const _TermsModal({required this.title, required this.contentFuture});

  @override
  State<_TermsModal> createState() => _TermsModalState();
}

class _TermsModalState extends State<_TermsModal> {
  String? _content;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    widget.contentFuture.then((text) {
      if (mounted) setState(() { _content = text; _loading = false; });
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark    = Theme.of(context).brightness == Brightness.dark;
    final bgC       = isDark ? GuidyColors.darkSurface : GuidyColors.surface;
    final textC     = isDark ? GuidyColors.darkText    : GuidyColors.ink;
    final subC      = isDark ? GuidyColors.darkSub     : GuidyColors.sub;
    final lineC     = isDark ? GuidyColors.darkLine    : GuidyColors.line;
    final primaryC  = isDark ? GuidyColors.darkPrimary : GuidyColors.primary;
    final h         = MediaQuery.of(context).size.height;

    return Container(
      height: h * 0.85,
      decoration: BoxDecoration(
        color: bgC,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // 드래그 핸들
          Container(
            margin: const EdgeInsets.only(top: 10),
            width: 40, height: 4,
            decoration: BoxDecoration(
              color: lineC,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // 헤더
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 16, 0),
            child: Row(
              children: [
                Icon(Icons.gavel_rounded, color: primaryC, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(widget.title,
                      style: GuidyText.h3(textC)),
                ),
                IconButton(
                  icon: Icon(Icons.close_rounded, color: subC, size: 20),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 36, minHeight: 36,
                  ),
                ),
              ],
            ),
          ),
          Divider(color: lineC, height: 1),
          // 내용
          Expanded(
            child: _loading
                ? Center(
                    child: CircularProgressIndicator(
                        color: primaryC, strokeWidth: 2))
                : SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                    child: Text(
                      _content ?? '',
                      style: GuidyText.body(subC).copyWith(
                        height: 1.8,
                        fontSize: 13,
                      ),
                    ),
                  ),
          ),
          // 확인 버튼
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: SizedBox(
                width: double.infinity,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: primaryC,
                      borderRadius: GuidyRadius.lgBorder,
                    ),
                    child: Center(
                      child: Text('확인',
                          style: GuidyText.body(Colors.white)
                              .copyWith(fontWeight: FontWeight.w700)),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
