// lib/models/models.dart
// Guidy 데이터 모델

enum ChannelType { curation, creator, archive }
enum GuideStatus { draft, review, published }
enum CreatorStatus { pending, approved, rejected }

// ─── 크리에이터 활동 항목 ────────────────────────────────
enum ActivityType { youtube, instagram, blog, podcast, lecture, career, other }

class CreatorActivity {
  final String id;
  final ActivityType type;
  final String label;      // 표시 이름 (예: "YouTube")
  final String detail;     // 부제 (예: "구독자 3.7만명")
  final String? url;       // 링크 (null이면 탭 불가)

  const CreatorActivity({
    required this.id,
    required this.type,
    required this.label,
    required this.detail,
    this.url,
  });

  CreatorActivity copyWith({
    ActivityType? type,
    String? label,
    String? detail,
    String? url,
    bool clearUrl = false,
  }) => CreatorActivity(
    id: id,
    type: type ?? this.type,
    label: label ?? this.label,
    detail: detail ?? this.detail,
    url: clearUrl ? null : (url ?? this.url),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.index,
    'label': label,
    'detail': detail,
    'url': url,
  };

  factory CreatorActivity.fromJson(Map<String, dynamic> j) => CreatorActivity(
    id: j['id'] as String,
    type: ActivityType.values[j['type'] as int? ?? 0],
    label: j['label'] as String,
    detail: j['detail'] as String,
    url: j['url'] as String?,
  );
}

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
  final List<CreatorActivity> activities;   // 크리에이터가 직접 관리하는 활동 목록

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
    this.activities = const [],
  });

  Creator copyWith({
    String? name,
    String? title,
    String? bio,
    int? followerCount,
    List<CreatorActivity>? activities,
  }) => Creator(
    id: id,
    name: name ?? this.name,
    title: title ?? this.title,
    bio: bio ?? this.bio,
    avatarUrl: avatarUrl,
    avatarColor: avatarColor,
    followerCount: followerCount ?? this.followerCount,
    totalPlays: totalPlays,
    guideCount: guideCount,
    monthlyRevenue: monthlyRevenue,
    isVerified: isVerified,
    status: status,
    activities: activities ?? this.activities,
  );
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
  /// true이면 아카이브 전시를 결제 없이 무료로 감상할 수 있음.
  /// 추후 관리자가 개별 전시에 무료 접근을 허용할 때 사용.
  final bool isFreeAccess;

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
    this.isFreeAccess = false,
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
  final String? imageUrl;      // 대표 이미지 URL (Firebase Storage용 - 추후 연동)
  final String? imageBase64;   // Base64 인코딩 이미지 (현재 사용 중)
  final int imageSeed;         // 이미지 없을 때 플레이스홀더용
  final List<String> artworkIds;

  const ExhibitionSection({
    required this.id,
    required this.exhibitionId,
    required this.order,
    required this.title,
    this.description = '',
    this.imageUrl,
    this.imageBase64,
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
  final int price;   // 개별 가이드 가격 (0이면 무료)

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
    this.price = 0,
  });
}

// ─── 구매 내역 ───────────────────────────────────────────
enum PurchaseStatus { active, unused, cancelled }

// 구매 타입: exhibition(전시 통합), guide(크리에이터 가이드 개별)
enum PurchaseType { exhibition, guide }

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
  final PurchaseType type;       // 구매 타입
  final String? guideId;         // 크리에이터 가이드 ID (type==guide 일 때)
  final String? guideTitle;      // 가이드 제목
  final String? creatorName;     // 크리에이터 이름

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
    this.type = PurchaseType.exhibition,
    this.guideId,
    this.guideTitle,
    this.creatorName,
  });

  bool get isCancellable => status == PurchaseStatus.unused;
  bool get isGuide       => type == PurchaseType.guide;

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
        type: type,
        guideId: guideId,
        guideTitle: guideTitle,
        creatorName: creatorName,
      );
}

// ─── 더미 데이터 ─────────────────────────────────────────
class DummyData {
  static final List<Creator> creators = [
    Creator(id: 'c1', name: '김도슨트', title: '미술사 큐레이터', bio: '국립현대미술관 10년 경력의 도슨트. 현대미술의 복잡한 맥락을 쉽고 감동적으로 풀어드립니다.', avatarColor: '#0B3D5C', followerCount: 12400, totalPlays: 89300, guideCount: 14, isVerified: true,
      activities: const [
        CreatorActivity(id: 'ca1_1', type: ActivityType.youtube, label: 'YouTube', detail: '구독자 3.7만명', url: 'https://youtube.com/@kimdocent'),
        CreatorActivity(id: 'ca1_2', type: ActivityType.blog, label: '블로그', detail: '월 2.5만회 방문', url: 'https://blog.naver.com/kimdocent'),
        CreatorActivity(id: 'ca1_3', type: ActivityType.lecture, label: '강연', detail: '연간 28회'),
      ],
    ),
    Creator(id: 'c2', name: '박수민', title: '아트 유튜버', bio: '구독자 28만의 아트 유튜버. 작가와의 직접 인터뷰로 만드는 독점 오디오 가이드.', avatarColor: '#D97757', followerCount: 8200, totalPlays: 51200, guideCount: 9, isVerified: true,
      activities: const [
        CreatorActivity(id: 'ca2_1', type: ActivityType.youtube, label: 'YouTube', detail: '구독자 28만명', url: 'https://youtube.com/@parksumin'),
        CreatorActivity(id: 'ca2_2', type: ActivityType.instagram, label: 'Instagram', detail: '팔로워 4.2만명', url: 'https://instagram.com/parksumin.art'),
      ],
    ),
    Creator(id: 'c3', name: '이현우', title: '갤러리 관장', bio: '강남 갤러리 현 관장. 컬렉터 관점의 깊이 있는 해설을 제공합니다.', avatarColor: '#2F8F5C', followerCount: 5100, totalPlays: 34700, guideCount: 7,
      activities: const [
        CreatorActivity(id: 'ca3_1', type: ActivityType.career, label: '갤러리 HW 관장', detail: '2019년~ 현재'),
        CreatorActivity(id: 'ca3_2', type: ActivityType.lecture, label: '강연', detail: '연간 12회'),
      ],
    ),
    Creator(id: 'c4', name: '정재원', title: '독립 큐레이터', bio: '독립 큐레이터이자 미술 평론가. 소외된 작가들의 이야기를 발굴합니다.', avatarColor: '#7D6A94', followerCount: 3800, totalPlays: 22100, guideCount: 5,
      activities: const [
        CreatorActivity(id: 'ca4_1', type: ActivityType.blog, label: '아트 뉴스레터', detail: '구독자 6,200명', url: 'https://stibee.com/jungjaewon'),
        CreatorActivity(id: 'ca4_2', type: ActivityType.podcast, label: '팟캐스트', detail: '미술관 옆 수다', url: 'https://podcasts.apple.com/jungjaewon'),
      ],
    ),
  ];

  static final List<Exhibition> exhibitions = [
    const Exhibition(id: 'e1', title: '빛과 표면', venue: '북서울미술관', description: '13인의 작가가 빛과 물질의 경계를 탐구합니다. 회화, 설치, 영상을 아우르는 대규모 기획전.', coverSeed: 0, channel: ChannelType.curation, workCount: 18, price: 8000, duration: '55분', isActive: true),
    const Exhibition(id: 'e2', title: '도시의 결', venue: '서울시립미술관', description: '도시의 일상적 풍경 속에서 발견한 패턴과 텍스처를 담은 사진 전시.', coverSeed: 1, channel: ChannelType.creator, creatorId: 'c1', creatorName: '김도슨트', workCount: 24, price: 6000, duration: '40분', isActive: true),
    const Exhibition(id: 'e3', title: '기억의 지형', venue: '국립현대미술관', description: '종료된 전설적인 전시. 기억, 공간, 시간의 교차점을 탐구한 설치 미술.', coverSeed: 2, channel: ChannelType.archive, workCount: 12, price: 4900, duration: '35분', isActive: false, rating: 4.8, reviewCount: 234, isFreeAccess: true),
    const Exhibition(id: 'e4', title: '침묵과 소음', venue: '아트선재센터', description: '소리를 시각화하고 침묵을 청각적으로 경험하는 실험적 전시.', coverSeed: 3, channel: ChannelType.creator, creatorId: 'c2', creatorName: '박수민', workCount: 15, price: 7000, duration: '45분', isActive: true),
    const Exhibition(id: 'e5', title: '색채의 언어', venue: '리움미술관', description: '20세기 한국 추상화의 거장 4인의 색채 실험을 아카이브한 특별 소장전.', coverSeed: 5, channel: ChannelType.archive, workCount: 20, price: 5500, duration: '50분', isActive: false, rating: 4.6, reviewCount: 187, isFreeAccess: false),
    const Exhibition(id: 'e6', title: '경계의 조각들', venue: '서울대학교미술관', description: '2023년 종료된 국제 조각 교류전. 한국·독일·일본 조각가 8인의 공간 해석.', coverSeed: 6, channel: ChannelType.archive, workCount: 16, price: 6000, duration: '45분', isActive: false, rating: 4.5, reviewCount: 156, isFreeAccess: false),
    const Exhibition(id: 'e7', title: '사진의 시간', venue: '고은사진미술관', description: '다큐멘터리 사진 50년사를 되짚는 아카이브 전시. 국내외 보도사진 700여 점 수록.', coverSeed: 7, channel: ChannelType.archive, workCount: 28, price: 4000, duration: '60분', isActive: false, rating: 4.9, reviewCount: 312, isFreeAccess: true),
    const Exhibition(id: 'e8', title: '도자의 귀환', venue: '이화여대박물관', description: '전통 도자 기법을 현대적 시각으로 재해석한 현대 도예가들의 아카이브 소장전.', coverSeed: 8, channel: ChannelType.archive, workCount: 10, price: 3500, duration: '30분', isActive: false, rating: 4.3, reviewCount: 98, isFreeAccess: false),
    const Exhibition(id: 'e9', title: '판화의 역사', venue: '국립현대미술관 과천', description: '한국 현대 판화 60년의 역사를 담은 대규모 회고전 아카이브.', coverSeed: 9, channel: ChannelType.archive, workCount: 35, price: 5000, duration: '55분', isActive: false, rating: 4.7, reviewCount: 203, isFreeAccess: false),
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
    // e3: 기억의 지형 (아카이브)
    const ExhibitionSection(
      id: 's6', exhibitionId: 'e3', order: 1,
      title: '입구 · 소개',
      description: '전시 기획 의도와 참여 작가 소개. 기억과 공간이 어떻게 교차하는지 큰 그림을 제시합니다.',
      imageSeed: 25, artworkIds: [],
    ),
    const ExhibitionSection(
      id: 's7', exhibitionId: 'e3', order: 2,
      title: '메인 갤러리',
      description: '기억을 형상화한 핵심 설치 작품군. 관람객이 직접 걸으며 경험하는 공간적 서사.',
      imageSeed: 26, artworkIds: [],
    ),
    const ExhibitionSection(
      id: 's8', exhibitionId: 'e3', order: 3,
      title: '아카이브 룸',
      description: '전시 기간 중 수집된 관람객 기억 조각들. 포스트잇, 편지, 사진이 벽을 가득 채웁니다.',
      imageSeed: 27, artworkIds: [],
    ),
    // e7: 사진의 시간 (아카이브)
    const ExhibitionSection(
      id: 's9', exhibitionId: 'e7', order: 1,
      title: '입구 · 소개',
      description: '다큐멘터리 사진 50년사의 흐름을 연대기 순으로 안내합니다.',
      imageSeed: 30, artworkIds: [],
    ),
    const ExhibitionSection(
      id: 's10', exhibitionId: 'e7', order: 2,
      title: '메인 갤러리',
      description: '국내외 주요 보도사진 700여 점이 집결한 대형 전시실. 역사의 결정적 순간들.',
      imageSeed: 31, artworkIds: [],
    ),
    const ExhibitionSection(
      id: 's11', exhibitionId: 'e7', order: 3,
      title: '특별전시 · 현장의 목소리',
      description: '사진작가 인터뷰 영상과 미공개 원본 필름 아카이브.',
      imageSeed: 32, artworkIds: [],
    ),
    // e5: 색채의 언어 (아카이브)
    const ExhibitionSection(
      id: 's12', exhibitionId: 'e5', order: 1,
      title: '입구 · 소개', imageSeed: 33,
      description: '20세기 한국 추상화 거장 4인의 색채 실험을 소개합니다.',
      artworkIds: [],
    ),
    const ExhibitionSection(
      id: 's13', exhibitionId: 'e5', order: 2,
      title: '메인 갤러리', imageSeed: 34,
      description: '색채를 언어로 삼아 시대를 기록한 대형 유화 컬렉션.',
      artworkIds: [],
    ),
    // e6: 경계의 조각들 (아카이브)
    const ExhibitionSection(
      id: 's14', exhibitionId: 'e6', order: 1,
      title: '입구 · 소개', imageSeed: 35,
      description: '한국·독일·일본 조각가 8인의 국제 교류전 배경 소개.',
      artworkIds: [],
    ),
    const ExhibitionSection(
      id: 's15', exhibitionId: 'e6', order: 2,
      title: '조각 광장', imageSeed: 36,
      description: '국경을 넘어 대화하는 조각들의 공간. 소재와 형태의 경계를 허뭅니다.',
      artworkIds: [],
    ),
    const ExhibitionSection(
      id: 's16', exhibitionId: 'e6', order: 3,
      title: '특별전시실', imageSeed: 37,
      description: '작가들의 제작 과정 영상과 스케치 원본.',
      artworkIds: [],
    ),
    // e8: 도자의 귀환 (아카이브)
    const ExhibitionSection(
      id: 's17', exhibitionId: 'e8', order: 1,
      title: '입구 · 소개', imageSeed: 38,
      description: '전통 도자 기법과 현대 해석의 만남을 소개합니다.',
      artworkIds: [],
    ),
    const ExhibitionSection(
      id: 's18', exhibitionId: 'e8', order: 2,
      title: '메인 갤러리', imageSeed: 39,
      description: '현대 도예가 12인의 작품으로 구성된 대형 전시실.',
      artworkIds: [],
    ),
    // e9: 판화의 역사 (아카이브)
    const ExhibitionSection(
      id: 's19', exhibitionId: 'e9', order: 1,
      title: '입구 · 소개', imageSeed: 40,
      description: '한국 현대 판화 60년의 역사를 시기별로 안내합니다.',
      artworkIds: [],
    ),
    const ExhibitionSection(
      id: 's20', exhibitionId: 'e9', order: 2,
      title: '메인 갤러리', imageSeed: 41,
      description: '목판화, 동판화, 석판화, 실크스크린 등 장르별 대표작.',
      artworkIds: [],
    ),
    const ExhibitionSection(
      id: 's21', exhibitionId: 'e9', order: 3,
      title: '특별전시 · 현대 판화의 지평', imageSeed: 42,
      description: '디지털 기술과 접목된 현대 판화의 가능성을 탐구합니다.',
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
      price: 3900,
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
      price: 2900,
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
      price: 3500,
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
      price: 2500,
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
