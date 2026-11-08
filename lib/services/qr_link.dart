// lib/services/qr_link.dart
// QR 내용 → 앱 화면 주소. CMS가 만드는 형식(guidy://artwork/{id})과 웹 주소를 받음

import '../models/app_store.dart';

const _webHosts = {'guidy-app.pages.dev', 'guidy.kr', 'www.guidy.kr'};

/// 앱에 있는 콘텐츠를 가리키면 라우트('/player/a1' 등), 아니면 null
String? qrRoute(String raw, AppStore store) {
  final uri = Uri.tryParse(raw.trim());
  if (uri == null) return null;

  final List<String> seg;
  if (uri.scheme == 'guidy') {
    seg = [uri.host, ...uri.pathSegments];
  } else if ((uri.scheme == 'https' || uri.scheme == 'http') && _webHosts.contains(uri.host)) {
    // 웹 앱 주소는 해시 라우트(/#/detail/e1)일 수도 있음
    final path = uri.fragment.startsWith('/') ? uri.fragment : uri.path;
    seg = path.split('/').where((s) => s.isNotEmpty).toList();
  } else {
    return null;
  }
  if (seg.length != 2) return null;

  final id = seg[1];
  return switch (seg[0]) {
    'artwork' || 'player' => store.artworkById(id) != null ? '/player/$id' : null,
    'exhibition' || 'detail' => store.exhibitionById(id) != null ? '/detail/$id' : null,
    'creator' => store.creatorById(id) != null ? '/creator/$id' : null,
    _ => null,
  };
}
