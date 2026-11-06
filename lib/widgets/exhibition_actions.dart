// lib/widgets/exhibition_actions.dart
// 전시 감상·구매 공통 동작 (상세·아카이브 화면 공용)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../models/app_store.dart';
import '../models/user_store.dart';
import 'common_widgets.dart';

/// 전시의 첫 작품 플레이어로 이동. 작품이 없으면 안내만 표시
void openExhibitionPlayer(BuildContext context, Exhibition exhibition) {
  final artworks = context.read<AppStore>().artworksFor(exhibition.id);
  if (artworks.isEmpty) {
    // 다른 전시의 오디오로 대체 재생하지 않는다
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('이 전시의 오디오 가이드가 준비 중입니다')),
    );
    return;
  }
  Navigator.pushNamed(context, '/player/${artworks.first.id}');
}

// shortcut: 결제 연동 전이라 확인 후 바로 구매 기록만 추가, PG 연동 시 교체
Future<void> confirmPurchase(BuildContext context, Exhibition exhibition) async {
  final pal = GuidyPalette.of(context);

  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: pal.surface,
      title: Text('구매 확인', style: GuidyText.h3(pal.text)),
      content: Text(
        '「${exhibition.title}」 오디오 가이드를\n₩${formatPrice(exhibition.price)}에 구매하시겠습니까?',
        style: GuidyText.body(pal.sub)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: Text('취소', style: GuidyText.body(pal.mute)),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: Text('구매하기',
            style: GuidyText.body(GuidyColors.primary).copyWith(fontWeight: FontWeight.w700)),
        ),
      ],
    ),
  );
  if (confirmed != true || !context.mounted) return;

  await context.read<UserStore>().addPurchase(Purchase(
    id: 'p_${DateTime.now().millisecondsSinceEpoch}',
    exhibitionId: exhibition.id,
    exhibitionTitle: exhibition.title,
    venueName: exhibition.venue,
    coverSeed: exhibition.coverSeed,
    pricePaid: exhibition.price,
    purchasedAt: DateTime.now(),
    status: PurchaseStatus.unused,
  ));
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('「${exhibition.title}」 구매가 완료되었습니다'),
      backgroundColor: GuidyColors.ok,
    ),
  );
}
