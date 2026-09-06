// lib/screens/search/search_screen.dart
// 검색 화면

import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/models.dart';
import '../../widgets/common_widgets.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  String _query = '';
  bool _hasFocus = false;
  final _focusNode = FocusNode();

  static const List<String> _recentSearches = ['빛과 표면', '현대미술', '김도슨트', '서울시립미술관'];
  static const List<String> _popularKeywords = ['#큐레이션', '#오디오가이드', '#미술관', '#국립현대미술관', '#크리에이터', '#설치미술', '#사진전', '#아카이브'];

  List<Exhibition> get _searchResults {
    if (_query.isEmpty) return [];
    return DummyData.exhibitions.where((e) {
      final q = _query.toLowerCase();
      return e.title.toLowerCase().contains(q) ||
             e.venue.toLowerCase().contains(q) ||
             (e.creatorName?.toLowerCase().contains(q) ?? false) ||
             e.description.toLowerCase().contains(q);
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() => setState(() => _hasFocus = _focusNode.hasFocus));
    WidgetsBinding.instance.addPostFrameCallback((_) => _focusNode.requestFocus());
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
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
    final accentC = isDark ? GuidyColors.darkAccent : GuidyColors.accent;

    return Scaffold(
      backgroundColor: bgC,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // 검색바 헤더
            Container(
              color: bgC,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Row(
                children: [
                  // 뒤로가기
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
                  const SizedBox(width: 10),
                  // 검색 입력창
                  Expanded(
                    child: Container(
                      height: 42,
                      decoration: BoxDecoration(
                        color: surfaceC,
                        borderRadius: GuidyRadius.lgBorder,
                        border: Border.all(color: _hasFocus ? primaryC : lineC, width: _hasFocus ? 1.5 : 1),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 12),
                          Icon(Icons.search_rounded, size: 18, color: muteC),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              focusNode: _focusNode,
                              onChanged: (v) => setState(() => _query = v),
                              style: GuidyText.body(textC),
                              decoration: InputDecoration(
                                hintText: '전시, 크리에이터, 미술관 검색',
                                hintStyle: GuidyText.body(muteC),
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ),
                          if (_query.isNotEmpty)
                            GestureDetector(
                              onTap: () {
                                _searchController.clear();
                                setState(() => _query = '');
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(right: 10),
                                child: Icon(Icons.cancel_rounded, size: 16, color: muteC),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 콘텐츠
            Expanded(
              child: _query.isEmpty
                  ? _buildEmptyState(context, textC, subC, muteC, surfaceC, lineC, primaryC, accentC, bgC, isDark)
                  : _buildSearchResults(context, textC, subC, muteC),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, Color textC, Color subC, Color muteC,
      Color surfaceC, Color lineC, Color primaryC, Color accentC, Color bgC, bool isDark) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
      children: [
        // 최근 검색어
        if (_recentSearches.isNotEmpty) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('최근 검색어', style: GuidyText.h3(textC)),
              Text('전체 삭제', style: GuidyText.small(muteC).copyWith(fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _recentSearches.map((keyword) => GestureDetector(
              onTap: () => setState(() {
                _query = keyword;
                _searchController.text = keyword;
              }),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: surfaceC,
                  borderRadius: GuidyRadius.pillBorder,
                  border: Border.all(color: lineC),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.history_rounded, size: 14, color: muteC),
                    const SizedBox(width: 4),
                    Text(keyword, style: GuidyText.small(textC).copyWith(fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            )).toList(),
          ),
          const SizedBox(height: 28),
        ],

        // 인기 검색 키워드
        Text('인기 검색어', style: GuidyText.h3(textC)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _popularKeywords.map((tag) => GestureDetector(
            onTap: () => setState(() {
              final clean = tag.replaceAll('#', '');
              _query = clean;
              _searchController.text = clean;
            }),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: accentC.withValues(alpha: 0.10),
                borderRadius: GuidyRadius.pillBorder,
              ),
              child: Text(tag, style: TextStyle(
                fontFamily: GuidyText.fontFamily, fontSize: 13,
                fontWeight: FontWeight.w600, color: accentC,
                letterSpacing: -0.2,
              )),
            ),
          )).toList(),
        ),

        const SizedBox(height: 28),

        // 추천 전시
        Text('추천 전시', style: GuidyText.h3(textC)),
        const SizedBox(height: 12),
        ...DummyData.exhibitions.take(3).map((e) => Container(
          margin: const EdgeInsets.only(bottom: 10),
          child: GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/detail/${e.id}'),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: surfaceC,
                borderRadius: GuidyRadius.lgBorder,
                border: Border.all(color: lineC),
              ),
              child: Row(
                children: [
                  GuidyCover(seed: e.coverSeed, width: 56, height: 56, borderRadius: GuidyRadius.mdBorder),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ChannelBadge(type: e.channel),
                        const SizedBox(height: 4),
                        Text(e.title, style: GuidyText.body(textC).copyWith(fontWeight: FontWeight.w700),
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 2),
                        Text(e.venue, style: GuidyText.small(subC)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    e.price == 0 ? '무료' : '₩${_formatPrice(e.price)}',
                    style: GuidyText.small(textC).copyWith(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
          ),
        )),
      ],
    );
  }

  Widget _buildSearchResults(BuildContext context, Color textC, Color subC, Color muteC) {
    final results = _searchResults;

    if (results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off_rounded, size: 56, color: muteC),
            const SizedBox(height: 14),
            Text("'$_query'에 대한 결과가 없습니다", style: GuidyText.body(muteC)),
            const SizedBox(height: 6),
            Text('다른 검색어로 시도해보세요', style: GuidyText.small(muteC)),
          ],
        ),
      );
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceC = isDark ? GuidyColors.darkSurface : GuidyColors.surface;
    final lineC = isDark ? GuidyColors.darkLine : GuidyColors.line;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
      children: [
        Text('검색 결과 ${results.length}개', style: GuidyText.small(muteC).copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        ...results.map((e) => Container(
          margin: const EdgeInsets.only(bottom: 10),
          child: GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/detail/${e.id}'),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: surfaceC,
                borderRadius: GuidyRadius.lgBorder,
                border: Border.all(color: lineC),
              ),
              child: Row(
                children: [
                  GuidyCover(seed: e.coverSeed, width: 64, height: 64, borderRadius: GuidyRadius.mdBorder),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          ChannelBadge(type: e.channel),
                          if (e.isActive) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(color: GuidyColors.ok, borderRadius: GuidyRadius.pillBorder),
                              child: const Text('진행 중', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800)),
                            ),
                          ],
                        ]),
                        const SizedBox(height: 5),
                        Text(e.title, style: GuidyText.body(textC).copyWith(fontWeight: FontWeight.w700),
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 2),
                        Text(e.venue, style: GuidyText.small(subC)),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            Text('${e.workCount}작품 · ${e.duration}', style: GuidyText.kicker(muteC)),
                            const Spacer(),
                            Text(
                              e.price == 0 ? '무료' : '₩${_formatPrice(e.price)}',
                              style: GuidyText.small(textC).copyWith(fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        )),
      ],
    );
  }

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );
  }
}
