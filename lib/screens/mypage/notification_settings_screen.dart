// lib/screens/mypage/notification_settings_screen.dart
// 알림 설정 화면

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../theme/app_theme.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  // 알림 설정값 (SharedPreferences에 저장)
  bool _pushAll        = true;
  bool _pushPurchase   = true;
  bool _pushNewGuide   = true;
  bool _pushCreator    = false;
  bool _pushPromotion  = false;
  bool _emailMarketing = false;

  static const _kPushAll        = 'notif_push_all';
  static const _kPushPurchase   = 'notif_push_purchase';
  static const _kPushNewGuide   = 'notif_push_new_guide';
  static const _kPushCreator    = 'notif_push_creator';
  static const _kPushPromotion  = 'notif_push_promotion';
  static const _kEmailMarketing = 'notif_email_marketing';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _pushAll        = prefs.getBool(_kPushAll)        ?? true;
      _pushPurchase   = prefs.getBool(_kPushPurchase)   ?? true;
      _pushNewGuide   = prefs.getBool(_kPushNewGuide)   ?? true;
      _pushCreator    = prefs.getBool(_kPushCreator)    ?? false;
      _pushPromotion  = prefs.getBool(_kPushPromotion)  ?? false;
      _emailMarketing = prefs.getBool(_kEmailMarketing) ?? false;
    });
  }

  Future<void> _save(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  @override
  Widget build(BuildContext context) {
    final isDark   = Theme.of(context).brightness == Brightness.dark;
    final bgC      = isDark ? GuidyColors.darkBg      : GuidyColors.bg;
    final textC    = isDark ? GuidyColors.darkText     : GuidyColors.ink;
    final subC     = isDark ? GuidyColors.darkSub      : GuidyColors.sub;
    final surfaceC = isDark ? GuidyColors.darkSurface  : GuidyColors.surface;
    final lineC    = isDark ? GuidyColors.darkLine     : GuidyColors.line;
    final primaryC = isDark ? GuidyColors.darkPrimary  : GuidyColors.primary;

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
                    onTap: () => Navigator.pop(context),
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
                  Text('알림 설정', style: GuidyText.h3(textC)),
                ],
              ),
            ),
            const SizedBox(height: 4),

            // ─── 내용 ─────────────────────────────────
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
                children: [
                  // 전체 푸시 알림 마스터 스위치
                  _SectionHeader('푸시 알림', textC),
                  const SizedBox(height: 8),
                  _SwitchTile(
                    icon: Icons.notifications_rounded,
                    title: '푸시 알림 전체',
                    subtitle: '모든 푸시 알림을 켜거나 끕니다',
                    value: _pushAll,
                    primaryC: primaryC,
                    surfaceC: surfaceC,
                    lineC: lineC,
                    textC: textC,
                    subC: subC,
                    isMaster: true,
                    onChanged: (v) {
                      setState(() {
                        _pushAll = v;
                        if (!v) {
                          _pushPurchase  = false;
                          _pushNewGuide  = false;
                          _pushCreator   = false;
                          _pushPromotion = false;
                        }
                      });
                      _save(_kPushAll, v);
                      _save(_kPushPurchase, v ? _pushPurchase : false);
                      _save(_kPushNewGuide, v ? _pushNewGuide : false);
                      _save(_kPushCreator, v ? _pushCreator : false);
                      _save(_kPushPromotion, v ? _pushPromotion : false);
                    },
                  ),
                  const SizedBox(height: 8),
                  // 세부 알림 항목 (전체가 켜진 경우에만 활성)
                  AnimatedOpacity(
                    opacity: _pushAll ? 1.0 : 0.4,
                    duration: const Duration(milliseconds: 200),
                    child: Column(
                      children: [
                        _SwitchTile(
                          icon: Icons.receipt_long_rounded,
                          title: '구매 / 결제 알림',
                          subtitle: '구매 완료, 환불 처리 알림',
                          value: _pushPurchase,
                          primaryC: primaryC,
                          surfaceC: surfaceC,
                          lineC: lineC,
                          textC: textC,
                          subC: subC,
                          enabled: _pushAll,
                          onChanged: (v) {
                            setState(() => _pushPurchase = v);
                            _save(_kPushPurchase, v);
                          },
                        ),
                        const SizedBox(height: 8),
                        _SwitchTile(
                          icon: Icons.headphones_rounded,
                          title: '새 가이드 알림',
                          subtitle: '즐겨찾기한 전시의 새 오디오 가이드 등록',
                          value: _pushNewGuide,
                          primaryC: primaryC,
                          surfaceC: surfaceC,
                          lineC: lineC,
                          textC: textC,
                          subC: subC,
                          enabled: _pushAll,
                          onChanged: (v) {
                            setState(() => _pushNewGuide = v);
                            _save(_kPushNewGuide, v);
                          },
                        ),
                        const SizedBox(height: 8),
                        _SwitchTile(
                          icon: Icons.person_rounded,
                          title: '크리에이터 활동 알림',
                          subtitle: '팔로우한 크리에이터의 새 콘텐츠',
                          value: _pushCreator,
                          primaryC: primaryC,
                          surfaceC: surfaceC,
                          lineC: lineC,
                          textC: textC,
                          subC: subC,
                          enabled: _pushAll,
                          onChanged: (v) {
                            setState(() => _pushCreator = v);
                            _save(_kPushCreator, v);
                          },
                        ),
                        const SizedBox(height: 8),
                        _SwitchTile(
                          icon: Icons.local_offer_rounded,
                          title: '프로모션 · 이벤트 알림',
                          subtitle: '할인, 기획전, 이벤트 정보',
                          value: _pushPromotion,
                          primaryC: primaryC,
                          surfaceC: surfaceC,
                          lineC: lineC,
                          textC: textC,
                          subC: subC,
                          enabled: _pushAll,
                          onChanged: (v) {
                            setState(() => _pushPromotion = v);
                            _save(_kPushPromotion, v);
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 이메일 알림
                  _SectionHeader('이메일 알림', textC),
                  const SizedBox(height: 8),
                  _SwitchTile(
                    icon: Icons.mail_outline_rounded,
                    title: '마케팅 이메일 수신',
                    subtitle: '뉴스레터, 프로모션, 신규 서비스 안내',
                    value: _emailMarketing,
                    primaryC: primaryC,
                    surfaceC: surfaceC,
                    lineC: lineC,
                    textC: textC,
                    subC: subC,
                    onChanged: (v) {
                      setState(() => _emailMarketing = v);
                      _save(_kEmailMarketing, v);
                    },
                  ),

                  const SizedBox(height: 24),

                  // 안내 문구
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: GuidyColors.primarySoft,
                      borderRadius: GuidyRadius.lgBorder,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.info_outline_rounded,
                            size: 15, color: primaryC),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '구매 및 결제 관련 알림은 푸시 알림을 끄더라도 이메일로 발송됩니다.',
                            style: GuidyText.small(subC),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final Color color;
  const _SectionHeader(this.title, this.color);

  @override
  Widget build(BuildContext context) {
    return Text(title, style: GuidyText.h3(color));
  }
}

class _SwitchTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final bool enabled;
  final bool isMaster;
  final ValueChanged<bool> onChanged;
  final Color primaryC, surfaceC, lineC, textC, subC;

  const _SwitchTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    required this.primaryC,
    required this.surfaceC,
    required this.lineC,
    required this.textC,
    required this.subC,
    this.enabled = true,
    this.isMaster = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: surfaceC,
        borderRadius: GuidyRadius.lgBorder,
        border: Border.all(
          color: isMaster && value ? primaryC.withOpacity(0.3) : lineC,
          width: isMaster && value ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 34, height: 34,
            decoration: BoxDecoration(
              color: value
                  ? primaryC.withOpacity(0.10)
                  : GuidyColors.mute.withOpacity(0.08),
              borderRadius: GuidyRadius.mdBorder,
            ),
            child: Icon(icon, size: 17,
                color: value ? primaryC : GuidyColors.mute),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: GuidyText.body(textC)
                        .copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 1),
                Text(subtitle, style: GuidyText.small(subC)),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: enabled ? onChanged : null,
            activeColor: primaryC,
            activeTrackColor: primaryC.withOpacity(0.3),
          ),
        ],
      ),
    );
  }
}
