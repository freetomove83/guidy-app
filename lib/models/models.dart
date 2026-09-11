// lib/models/models.dart
// Guidy 데이터 모델

enum ChannelType { curation, creator, archive }
enum GuideStatus { draft, review, published }
enum CreatorStatus { pending, approved, rejected }

// ─── 크리에이터 ──────────────────────────────────────────
class Creator {
  final String id;
  final String name;
  final String title;
  final String bio;
  final String? avatarUrl;
  final String avatarColor;
  final int followerCount;
  final int totalPlays;
  final int guideCount;
  final double monthlyRevenue;
  final bool isVerified;
  final CreatorStatus status;

  const Creator({
    required this.id,
    required this.name,
    required this.title,
    required this.bio,
    this.avatarUrl,
    required this.avatarColor,
    required this.followerCount,
    required this.totalPlays,
    required this.guideCount,
    this.monthlyRevenue = 0,
    this.isVerified = false,
    this.status = CreatorStatus.approved,
  });
}

// ─── 전시/가이드 ─────────────────────────────────────────
class Exhibition {
  final String id;
  final String title;
  final String venue;
  final String description;
  final String? coverUrl;
  final int coverSeed;
  final ChannelType channel;
  final String? creatorId;
  final String? creatorName;
  final int workCount;
  final int price;
  final String duration;
  final bool isActive;
  final DateTime? archivedAt;
  final double rating;
  final int reviewCount;

  const Exhibition({
    required this.id,
    required this.title,
    required this.venue,
    required this.description,
    this.coverUrl,
    required this.coverSeed,
    required this.channel,
    this.creatorId,
    this.creatorName,
    required this.workCount,
    required this.price,
    required this.duration,
    this.isActive = true,
    this.archivedAt,
    this.rating = 0,
    this.reviewCount = 0,
  });
}

// ─── 작품 ────────────────────────────────────────────────
class Artwork {
  final String id;
  final String exhibitionId;
  final String title;
  final String artist;
  final String material;
  final String? imageUrl;
  final int imageSeed;
  final String? audioUrl;
  final int durationSec;
  final List<Caption> captions;
  final String description;
  final String curatorNote;

  const Artwork({
    required this.id,
    required this.exhibitionId,
    required this.title,
    required this.artist,
    required this.material,
    this.imageUrl,
    required this.imageSeed,
    this.audioUrl,
    required this.durationSec,
    required this.captions,
    required this.description,
    required this.curatorNote,
  });
}

// ─── 자막 ────────────────────────────────────────────────
class Caption {
  final double startSec;
  final double endSec;
  final String text;

  const Caption({
    required this.startSec,
    required this.endSec,
    required this.text,
  });
}

// ─── 팔로잉 피드 ─────────────────────────────────────────
enum FeedItemType { newGuide, announcement, reply, live }

class FeedItem {
  final String id;
  final Creator creator;
  final FeedItemType type;
  final String? title;
  final String? description;
  final Exhibition? exhibition;
  final DateTime time;
  final int likes;
  final int plays;

  const FeedItem({
    required this.id,
    required this.creator,
    required this.type,
    this.title,
    this.description,
    this.exhibition,
    required this.time,
    this.likes = 0,
    this.plays = 0,
  });
}

// ─── 섹션 (전시 구성 단위) ──────────────────────────────
class ExhibitionSection {
  final String id;
  final String exhibitionId;
  final int order;
  final String title;
  final String description;
  final String? imageUrl;   // 대표 이미지 URL (CMS 업로드)
  final int imageSeed;      // 이미지 없을 때 플레이스홀더용
  final List<String> artworkIds; // 이 섹션에 속한 작품 ID 목록

  const ExhibitionSection({
    required this.id,
    required this.exhibitionId,
    required this.order,
    required this.title,
    this.description = '',
    this.imageUrl,
    this.imageSeed = 0,
    this.artworkIds = const [],
  });
}

// ─── 크리에이터 가이드 (같은 전시의 크리에이터 버전) ────
class CreatorGuide {
  final String id;
  final String exhibitionId;
  final String creatorId;
  final String creatorName;
  final String creatorTitle;
  final String avatarColor;
  final bool isVerified;
  final String guideTitle;
  final String description;
  final int durationSec;
  final int plays;
  final double rating;
  final String? firstArtworkId;

  const CreatorGuide({
    required this.id,
    required this.exhibitionId,
    required this.creatorId,
    required this.creatorName,
    required this.creatorTitle,
    this.avatarColor = '#0B3D5C',
    this.isVerified = false,
    required this.guideTitle,
    this.description = '',
    this.durationSec = 0,
    this.plays = 0,
    this.rating = 0,
    this.firstArtworkId,
  });
}

// ─── 구매 내역 ───────────────────────────────────────────
enum PurchaseStatus { active, unused, cancelled }

class Purchase {
  final String id;
  final String exhibitionId;
  final String exhibitionTitle;
  final String venueName;
  final int coverSeed;
  final int pricePaid;
  final DateTime purchasedAt;
  final PurchaseStatus status;
  final DateTime? cancelledAt;

  const Purchase({
    required this.id,
    required this.exhibitionId,
    required this.exhibitionTitle,
    required this.venueName,
    required this.coverSeed,
    required this.pricePaid,
    required this.purchasedAt,
    this.status = PurchaseStatus.unused,
    this.cancelledAt,
  });

  bool get isCancellable =>
      status == PurchaseStatus.unused;

  Purchase copyWith({PurchaseStatus? status, DateTime? cancelledAt}) =>
      Purchase(
        id: id,
        exhibitionId: exhibitionId,
        exhibitionTitle: exhibitionTitle,
        venueName: venueName,
        coverSeed: coverSeed,
        pricePaid: pricePaid,
        purchasedAt: purchasedAt,
        status: status ?? this.status,
        cancelledAt: cancelledAt ?? this.cancelledAt,
      );
}

// ─── 더미 데이터 ─────────────────────────────────────────
class DummyData {
  static final List<Creator> creators = [
    const Creator(id: 'c1', name: '김도슨트', title: '미술사 큐레이터', bio: '국립현대미술관 10년 경력의 도슨트. 현대미술의 복잡한 맥락을 쉽고 감동적으로 풀어드립니다.', avatarColor: '#0B3D5C', followerCount: 12400, totalPlays: 89300, guideCount: 14, isVerified: true),
    const Creator(id: 'c2', name: '박수민', title: '아트 유튜버', bio: '구독자 28만의 아트 유튜버. 작가와의 직접 인터뷰로 만드는 독점 오디오 가이드.', avatarColor: '#D97757', followerCount: 8200, totalPlays: 51200, guideCount: 9, isVerified: true),
    const Creator(id: 'c3', name: '이현우', title: '갤러리 관장', bio: '강남 갤러리 현 관장. 컬렉터 관점의 깊이 있는 해설을 제공합니다.', avatarColor: '#2F8F5C', followerCount: 5100, totalPlays: 34700, guideCount: 7),
    const Creator(id: 'c4', name: '정재원', title: '독립 큐레이터', bio: '독립 큐레이터이자 미술 평론가. 소외된 작가들의 이야기를 발굴합니다.', avatarColor: '#7D6A94', followerCount: 3800, totalPlays: 22100, guideCount: 5),
  ];

  static final List<Exhibition> exhibitions = [
    const Exhibition(id: 'e1', title: '빛과 표면', venue: '북서울미술관', description: '13인의 작가가 빛과 물질의 경계를 탐구합니다. 회화, 설치, 영상을 아우르는 대규모 기획전.', coverSeed: 0, channel: ChannelType.curation, workCount: 18, price: 8000, duration: '55분', isActive: true),
    const Exhibition(id: 'e2', title: '도시의 결', venue: '서울시립미술관', description: '도시의 일상적 풍경 속에서 발견한 패턴과 텍스처를 담은 사진 전시.', coverSeed: 1, channel: ChannelType.creator, creatorId: 'c1', creatorName: '김도슨트', workCount: 24, price: 6000, duration: '40분', isActive: true),
    const Exhibition(id: 'e3', title: '기억의 지형', venue: '국립현대미술관', description: '종료된 전설적인 전시. 기억, 공간, 시간의 교차점을 탐구한 설치 미술.', coverSeed: 2, channel: ChannelType.archive, workCount: 12, price: 4900, duration: '35분', isActive: false),
    const Exhibition(id: 'e4', title: '침묵과 소음', venue: '아트선재센터', description: '소리를 시각화하고 침묵을 청각적으로 경험하는 실험적 전시.', coverSeed: 3, channel: ChannelType.creator, creatorId: 'c2', creatorName: '박수민', workCount: 15, price: 7000, duration: '45분', isActive: true),
  ];

  static final List<Artwork> artworks = [
    Artwork(id: 'a1', exhibitionId: 'e1', title: '무제 #7', artist: '오세열', material: '캔버스에 유채', imageSeed: 10,
      audioUrl: 'assets/audio/sample_guide_01.mp3',
      durationSec: 372, description: '오세열 작가의 무제 시리즈는 순수한 시각적 체험을 추구합니다. 이 작품에서 빛은 단순한 조명이 아닌 재료 자체가 됩니다.', curatorNote: '이 작품 앞에 10분 이상 머물러 보세요. 처음엔 보이지 않던 것들이 보이기 시작합니다.', captions: [
      Caption(startSec: 0, endSec: 12, text: '오세열 작가의 무제 시리즈는 1990년대부터 시작된'),
      Caption(startSec: 12, endSec: 24, text: '순수한 시각적 체험을 추구하는 작업입니다.'),
      Caption(startSec: 24, endSec: 38, text: '이 작품에서 빛은 단순한 조명이 아닌'),
      Caption(startSec: 38, endSec: 55, text: '재료 자체가 되어 화면을 가득 채웁니다.'),
      Caption(startSec: 55, endSec: 72, text: '작가는 캔버스 위에 수십 겹의 유채를 덧칠하며'),
      Caption(startSec: 72, endSec: 90, text: '빛이 표면에 스며드는 순간을 포착합니다.'),
      Caption(startSec: 90, endSec: 110, text: '관객은 작품 앞에 서서 시간이 흐를수록'),
      Caption(startSec: 110, endSec: 130, text: '보이지 않던 색의 층위를 발견하게 됩니다.'),
    ]),
    Artwork(id: 'a2', exhibitionId: 'e1', title: '표면의 기억', artist: '양혜규', material: '블라인드, 전구', imageSeed: 11,
      audioUrl: 'assets/audio/sample_guide_02.mp3',
      durationSec: 425, description: '양혜규의 설치 작품은 일상적인 블라인드를 통해 빛과 그림자의 드라마를 만들어냅니다.', curatorNote: '작품을 천천히 걸으며 보는 각도에 따라 달라지는 빛의 변화를 경험해보세요.', captions: [
      Caption(startSec: 0, endSec: 15, text: '양혜규 작가는 베니스 비엔날레 한국관 대표작가로'),
      Caption(startSec: 15, endSec: 32, text: '일상의 오브제에 특별한 의미를 부여합니다.'),
      Caption(startSec: 32, endSec: 50, text: '이 작품에서 수백 개의 금속 블라인드는'),
      Caption(startSec: 50, endSec: 68, text: '빛을 분절하고 재조합하는 악기가 됩니다.'),
      Caption(startSec: 68, endSec: 90, text: '전구의 온기와 블라인드의 차가운 금속이'),
      Caption(startSec: 90, endSec: 115, text: '서로 충돌하며 독특한 공간감을 만들어냅니다.'),
    ]),
  ];

  static final List<FeedItem> feedItems = [
    FeedItem(id: 'f1', creator: creators[0], type: FeedItemType.newGuide, title: '새 가이드: 빛과 표면', description: '북서울미술관 기획전 오디오 가이드를 새로 출시했습니다. 13명 작가의 이야기를 55분 동안 담았어요.', exhibition: exhibitions[0], time: DateTime.now().subtract(const Duration(hours: 2)), likes: 128, plays: 892),
    FeedItem(id: 'f2', creator: creators[1], type: FeedItemType.announcement, title: '이번 주 라이브 해설', description: '이번 주 토요일 오후 2시, 서울시립미술관에서 라이브 해설 진행합니다. 현장에서 만나요!', time: DateTime.now().subtract(const Duration(hours: 6)), likes: 64, plays: 0),
    FeedItem(id: 'f3', creator: creators[2], type: FeedItemType.newGuide, title: '도시의 결 가이드 업데이트', description: '큐레이터 인터뷰 추가 및 작가 노트 보완. 더욱 깊은 감상 경험을 선사합니다.', exhibition: exhibitions[1], time: DateTime.now().subtract(const Duration(days: 1)), likes: 45, plays: 312),
  ];

  // ─── 섹션 더미 데이터 ──────────────────────────────────
  static final List<ExhibitionSection> sections = [
    // e1: 빛과 표면
    const ExhibitionSection(
      id: 's1', exhibitionId: 'e1', order: 1,
      title: '입구 · 프롤로그',
      description: '빛이 물질 위에 남기는 첫 번째 흔적. 전시의 시작점으로, 13인 작가가 공유하는 공통 질문을 소개합니다. 관람객이 이 공간에 들어서는 순간부터 감각이 열리기 시작합니다.',
      imageSeed: 20,
      artworkIds: ['a1'],
    ),
    const ExhibitionSection(
      id: 's2', exhibitionId: 'e1', order: 2,
      title: '메인 갤러리 · 물질의 기억',
      description: '빛과 물질이 교차하는 핵심 작품들이 모인 공간. 오세열과 양혜규의 대형 설치작이 서로 대화를 나누듯 배치되어 있습니다. 두 작품 사이의 공간을 천천히 걷는 경험을 추천합니다.',
      imageSeed: 21,
      artworkIds: ['a1', 'a2'],
    ),
    const ExhibitionSection(
      id: 's3', exhibitionId: 'e1', order: 3,
      title: '특별전시실 · 빛의 언어',
      description: '미디어 설치와 퍼포먼스 기록이 함께하는 특별 섹션. 참여 작가들의 작업 노트와 스케치가 함께 전시되어 창작 과정의 이면을 들여다볼 수 있습니다.',
      imageSeed: 22,
      artworkIds: ['a2'],
    ),
    // e2: 도시의 결
    const ExhibitionSection(
      id: 's4', exhibitionId: 'e2', order: 1,
      title: '1부 · 도시의 표면',
      description: '콘크리트, 아스팔트, 유리창에 새겨진 시간의 흔적. 임동식 작가가 10년간 기록한 서울의 표피를 대형 인화로 만납니다.',
      imageSeed: 23,
      artworkIds: [],
    ),
    const ExhibitionSection(
      id: 's5', exhibitionId: 'e2', order: 2,
      title: '2부 · 소음과 침묵 사이',
      description: '도시의 소리를 색으로 번역한 시리즈. 사운드 스펙트럼을 시각 데이터로 변환해 캔버스 위에 펼쳐낸 독창적인 작업입니다.',
      imageSeed: 24,
      artworkIds: [],
    ),
  ];

  // ─── 크리에이터 가이드 더미 데이터 ────────────────────
  static final List<CreatorGuide> creatorGuides = [
    // e1: 빛과 표면 — 크리에이터 가이드
    const CreatorGuide(
      id: 'cg1',
      exhibitionId: 'e1',
      creatorId: 'c1',
      creatorName: '김도슨트',
      creatorTitle: '미술사 큐레이터',
      avatarColor: '#0B3D5C',
      isVerified: true,
      guideTitle: '빛과 표면: 큐레이터의 시선',
      description: '13인 작가 개인 인터뷰 기반의 심층 해설. 전시 기획 의도부터 작품 배치의 숨은 맥락까지 담았습니다.',
      durationSec: 3120,
      plays: 4280,
      rating: 4.9,
      firstArtworkId: 'a1',
    ),
    const CreatorGuide(
      id: 'cg2',
      exhibitionId: 'e1',
      creatorId: 'c2',
      creatorName: '박수민',
      creatorTitle: '아트 유튜버',
      avatarColor: '#D97757',
      isVerified: true,
      guideTitle: '빛과 표면: 유튜버의 솔직 리뷰',
      description: '2시간 현장 탐방의 솔직한 감상. MZ 관람객 관점에서 꼭 봐야 할 작품과 포토스팟을 알려드립니다.',
      durationSec: 2400,
      plays: 2150,
      rating: 4.7,
      firstArtworkId: 'a2',
    ),
    // e2: 도시의 결 — 크리에이터 가이드
    const CreatorGuide(
      id: 'cg3',
      exhibitionId: 'e2',
      creatorId: 'c3',
      creatorName: '이현우',
      creatorTitle: '갤러리 관장',
      avatarColor: '#2F8F5C',
      isVerified: false,
      guideTitle: '도시의 결: 컬렉터의 관점',
      description: '작품 가치와 시장성을 함께 분석. 컬렉터가 주목하는 신진 작가들의 숨은 가능성을 짚어드립니다.',
      durationSec: 2640,
      plays: 1890,
      rating: 4.6,
    ),
    // e4: 침묵과 소음 — 크리에이터 가이드
    const CreatorGuide(
      id: 'cg4',
      exhibitionId: 'e4',
      creatorId: 'c4',
      creatorName: '정재원',
      creatorTitle: '독립 큐레이터',
      avatarColor: '#7D6A94',
      isVerified: false,
      guideTitle: '침묵과 소음: 소외된 서사',
      description: '주류 미술계가 외면한 작가들의 목소리. 사운드 아트의 역사적 맥락과 현재적 의미를 탐구합니다.',
      durationSec: 2880,
      plays: 980,
      rating: 4.8,
    ),
  ];

  // ─── 구매 더미 데이터 ──────────────────────────────────
  static final List<Purchase> purchases = [
    Purchase(
      id: 'p1',
      exhibitionId: 'e1',
      exhibitionTitle: '빛과 표면',
      venueName: '북서울미술관',
      coverSeed: 0,
      pricePaid: 8000,
      purchasedAt: DateTime.now().subtract(const Duration(days: 3)),
      status: PurchaseStatus.active,
    ),
    Purchase(
      id: 'p2',
      exhibitionId: 'e2',
      exhibitionTitle: '도시의 결',
      venueName: '서울시립미술관',
      coverSeed: 1,
      pricePaid: 6000,
      purchasedAt: DateTime.now().subtract(const Duration(days: 10)),
      status: PurchaseStatus.unused,
    ),
    Purchase(
      id: 'p3',
      exhibitionId: 'e3',
      exhibitionTitle: '기억의 지형',
      venueName: '국립현대미술관',
      coverSeed: 2,
      pricePaid: 4900,
      purchasedAt: DateTime.now().subtract(const Duration(days: 30)),
      status: PurchaseStatus.cancelled,
      cancelledAt: DateTime.now().subtract(const Duration(days: 28)),
    ),
  ];
}
