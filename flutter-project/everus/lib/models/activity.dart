import 'package:flutter/material.dart';

class Level {
  final int num;
  final String name;
  final String time;
  final String place;
  final String context;
  final String? spice;
  final List<String> tasks;
  final String photoHint;

  const Level({
    required this.num,
    required this.name,
    required this.time,
    required this.place,
    required this.context,
    this.spice,
    required this.tasks,
    required this.photoHint,
  });
}

class ActivityTheme {
  final Color primary;
  final Color secondary;
  final Color accent;
  final Color light;
  final Color dark;

  const ActivityTheme({
    required this.primary,
    required this.secondary,
    required this.accent,
    required this.light,
    required this.dark,
  });

  static Color parseHexColor(String hex) {
    hex = hex.replaceFirst('#', '');
    if (hex.length == 6) {
      hex = 'FF$hex';
    }
    return Color(int.parse(hex, radix: 16));
  }

  factory ActivityTheme.fromHex({
    required String primary,
    required String secondary,
    required String accent,
    required String light,
    required String dark,
  }) {
    return ActivityTheme(
      primary: parseHexColor(primary),
      secondary: parseHexColor(secondary),
      accent: parseHexColor(accent),
      light: parseHexColor(light),
      dark: parseHexColor(dark),
    );
  }
}

class ActivityEnding {
  final String title;
  final String text;
  final String quote;

  const ActivityEnding({
    required this.title,
    required this.text,
    required this.quote,
  });
}

class Activity {
  final String key;
  final String emoji;
  final String name;
  final String subtitle;
  final String suitFor;
  final List<double> vec; // Length 5
  final int cost;
  final int minStage;
  final String oath;
  final String? secret;
  final String duration;
  final ActivityTheme theme;
  final String musicUrl;
  final List<Level> levels;
  final ActivityEnding ending;

  const Activity({
    required this.key,
    required this.emoji,
    required this.name,
    required this.subtitle,
    required this.suitFor,
    required this.vec,
    required this.cost,
    required this.minStage,
    required this.oath,
    this.secret,
    required this.duration,
    required this.theme,
    required this.musicUrl,
    required this.levels,
    required this.ending,
  });
}

final Map<String, Activity> activities = {
  'cooking': Activity(
    key: 'cooking',
    emoji: '🍳',
    name: 'Cooking Show',
    subtitle: 'Cook Your Love',
    suitFor: 'Cặp đôi thích sáng tạo và nấu ăn cùng nhau',
    vec: [10.0, 4.0, 9.0, 9.0, 6.0],
    cost: 350000,
    minStage: 0,
    oath: 'Dù kết quả có là món mặn hay món ngọt, chúng ta vẫn sẽ thưởng thức nó bằng cả trái tim.',
    secret: 'Nghĩ một tính từ để mô tả đối phương — đừng nói ra nhé!',
    duration: '~3 giờ',
    theme: ActivityTheme.fromHex(
      primary: '#E8764F',
      secondary: '#F4B183',
      accent: '#C4956A',
      light: '#FFF3E0',
      dark: '#5D4037',
    ),
    musicUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
    levels: [
      const Level(
        num: 1,
        name: 'Blind Grocery Challenge',
        time: '45–60 phút',
        place: 'Siêu thị',
        context: 'Hai người đi siêu thị cùng nhau. Mỗi người được tặng 1 "Gia vị bí mật" — nghĩ xem đối phương có vị gì (ngọt ngào, cay, mặn...).',
        spice: 'Chọn 5 nguyên liệu bám sát tính từ đó — đừng để lộ!',
        tasks: ['Đi siêu thị cùng nhau', 'Mỗi người chọn tối đa 5 nguyên liệu (không chọn mì gói, trứng)', 'Không nói món mình định nấu', 'Chụp hình check-in bằng bill hoặc túi đồ đã mua'],
        photoHint: 'Chụp bill siêu thị hoặc túi đồ hai người đã mua',
      ),
      const Level(
        num: 2,
        name: 'Cooking Chaos',
        time: '60–90 phút',
        place: 'Nhà bếp',
        context: 'ĐỔI GIỎ NGUYÊN LIỆU! Nấu từ nguyên liệu của đối phương — không biết họ định nấu gì.',
        spice: 'Được 1 quyền "Trợ giúp từ đối thủ" — dùng hành động, không dùng lời trong 30 giây!',
        tasks: ['Đổi giỏ nguyên liệu cho nhau', 'Cho đối phương hint: "Hôm nay em muốn nấu vị…"', 'Cùng nấu — mỗi người nấu phần từ đồ của người kia', 'Không hỏi "Bạn nấu gì?" — chỉ quan sát và đoán'],
        photoHint: 'Selfie lúc đang nấu — cười hay nhăn mặt đều được!',
      ),
      const Level(
        num: 3,
        name: 'Secret Drink Sync',
        time: '15–20 phút',
        place: 'Quán nước trên đường',
        context: 'Ghé vào một quán nước bắt đầu bằng chữ cái đầu tên một trong hai người.',
        spice: 'Order lần lượt — không cho người kia biết. Cố order món gợi nhớ kỷ niệm đầu tiên.',
        tasks: ['Tìm quán bắt đầu bằng chữ cái đầu tên một trong hai', 'Lần lượt vào order — không order cùng lúc', 'Order món gợi nhớ kỷ niệm đầu tiên', 'Đừng tiết lộ mình order gì cho đến khi cầm ly ra'],
        photoHint: 'Hai ly nước đặt cạnh nhau — chụp từ trên xuống',
      ),
      const Level(
        num: 4,
        name: 'Picnic Reveal',
        time: '60+ phút',
        place: 'Công viên / Bãi cỏ',
        context: 'Thưởng thức thành quả. Cùng ngồi và reveal tất cả suy nghĩ trong suốt hành trình.',
        spice: null,
        tasks: ['Đoán: ban đầu người kia định nấu món gì?', 'Kể: khi chọn nguyên liệu, bạn nghĩ gì?', 'Nhận xét: món ăn thành phẩm như thế nào?', 'Chụp ảnh kỷ niệm'],
        photoHint: 'Chụp mâm cơm và nụ cười của cả hai',
      ),
    ],
    ending: const ActivityEnding(
      title: 'Bữa ăn tình yêu hoàn tất!',
      text: 'Món ăn có thể đã hết, nhưng dư vị của sự nỗ lực dành cho nhau sẽ còn mãi.',
      quote: 'Hôm nay, hai bạn không chỉ nấu một bữa ăn — hai bạn đã nấu chín thêm một phần tình yêu.',
    ),
  ),
  'traveler': Activity(
    key: 'traveler',
    emoji: '⏳',
    name: 'The Time Traveler',
    subtitle: 'The Lost Tapes',
    suitFor: 'Cặp đôi thích sự hoài cổ và muốn tìm hiểu về quá khứ của nhau',
    vec: [9.0, 5.0, 9.0, 4.0, 5.0],
    cost: 300000,
    minStage: 1,
    oath: 'Tôi hứa sẽ bước vào quá khứ của bạn với sự tò mò và trân trọng.',
    secret: 'Giữ một mốc thời gian mà bạn ước gì đối phương có thể xuất hiện ở đó cùng mình.',
    duration: '~4 giờ',
    theme: ActivityTheme.fromHex(
      primary: '#8B6F47',
      secondary: '#C4956A',
      accent: '#D4A574',
      light: '#F5EBE0',
      dark: '#5D4037',
    ),
    musicUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3',
    levels: [
      const Level(
        num: 1,
        name: 'The Artifact Hunt',
        time: '20–30 phút',
        place: 'Tiệm sách cũ / Đồ Vintage / Chợ si',
        context: 'Đến một không gian lưu giữ thời gian. Tìm một "Cổ vật" đại diện cho phiên bản trẻ con của mình.',
        spice: 'Chọn món đồ bám sát "tính cách cốt lõi" của bạn ngày xưa. Không được giải thích tại sao!',
        tasks: ['Tìm không gian hoài niệm (tiệm sách cũ, đồ vintage, chợ si)', 'Mỗi người có 20 phút tìm 1 "Cổ vật" đại diện phiên bản trẻ con', 'Không được giải thích tại sao chọn món đó', 'Chụp ảnh món đồ trên nền đen trắng'],
        photoHint: 'Chụp cổ vật trên nền đen trắng — filter vintage!',
      ),
      const Level(
        num: 2,
        name: 'The Parallel Universe',
        time: '30 phút',
        place: 'Trên đường di chuyển',
        context: 'ĐỔI CỔ VẬT. Bạn đang cầm "mảnh linh hồn" thời thơ ấu của người kia. Viết "Bản tin dự báo quá khứ" tối đa 5 câu.',
        spice: 'Trong suốt di chuyển, không dùng ngôn ngữ hiện đại — chỉ nói theo kiểu "thời ông bà anh"!',
        tasks: ['Đổi cổ vật cho nhau', 'Viết "Bản tin dự báo quá khứ" tối đa 5 câu về đối phương', 'Không dùng slang hay tiếng Anh khi di chuyển', 'Nói chuyện theo kiểu "ngày xưa thời ông bà"'],
        photoHint: 'Chụp hai cổ vật đặt cạnh nhau',
      ),
      const Level(
        num: 3,
        name: 'The Rewind Sip',
        time: '20–30 phút',
        place: 'Quán hoài niệm',
        context: 'Tìm quán có không gian hoài niệm. Tên quán có ít nhất một chữ trùng năm sinh.',
        spice: 'Một người order trước — chọn món tin người kia thích hoặc ghét nhất khi còn bé. Được nhắn 1 emoji duy nhất!',
        tasks: ['Tìm quán hoài niệm, tên có chữ trùng năm sinh', 'Một người order trước — không cho người kia biết', 'Chọn đồ uống gợi về ký ức tuổi thơ của đối phương', 'Được nhắn 1 emoji duy nhất làm gợi ý'],
        photoHint: 'Chụp không gian quán retro + hai ly nước',
      ),
      const Level(
        num: 4,
        name: 'The Truth Unfold',
        time: '60+ phút',
        place: 'Không gian yên tĩnh',
        context: 'Mở "Bản tin dự báo" và reveal tất cả. Cuối cùng: viết thư thời gian gửi nhau sau 1 năm qua Gmail.',
        spice: null,
        tasks: ['Đọc "Bản tin dự báo" — chấm điểm độ chính xác (%)', 'Kể: Tại sao món đồ Level 1 quan trọng với bạn?', 'Chụp ảnh chung bằng app giả lập máy phim', 'Vào Gmail, viết thư thời gian gửi sau 1 năm kèm ảnh'],
        photoHint: 'Chụp bằng app máy phim — thêm date stamp!',
      ),
    ],
    ending: const ActivityEnding(
      title: 'Chuyến du hành hoàn tất!',
      text: 'Hôm nay, bạn không chỉ đi chơi, mà còn du hành qua những tầng ký ức của người mình yêu.',
      quote: 'Cảm ơn quá khứ đã là một phần của mỗi chúng ta hiện tại.',
    ),
  ),
  'lego': Activity(
    key: 'lego',
    emoji: '🧩',
    name: 'Silent Lego',
    subtitle: 'Architects of Sync',
    suitFor: 'Cặp đôi muốn khám phá sự đồng điệu mà không cần lời nói',
    vec: [7.0, 6.0, 10.0, 8.0, 7.0],
    cost: 400000,
    minStage: 0,
    oath: 'Hôm nay, chúng ta sẽ tắt âm thanh để lắng nghe nhịp điệu của tư duy.',
    secret: null,
    duration: '~2 giờ',
    theme: ActivityTheme.fromHex(
      primary: '#4A90E2',
      secondary: '#7CB9E8',
      accent: '#357ABD',
      light: '#EBF4FF',
      dark: '#1A3A52',
    ),
    musicUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-3.mp3',
    levels: [
      const Level(
        num: 1,
        name: 'The Fragment Gathering',
        time: '15 phút',
        place: 'Cửa hàng đồ chơi / Lego shop',
        context: 'Hai bạn có 15 phút. Mỗi người chọn 1 bộ lắp ráp dưới 100 mảnh.',
        spice: 'Nếu bạn thực tế → chọn bộ Lego xe cộ/nhà cửa. Nếu mộng mơ → hoa lá/sinh vật huyền bí. Giấu vào túi giấy kín!',
        tasks: ['Đến cửa hàng đồ chơi', 'Mỗi người chọn 1 bộ lắp ráp dưới 100 mảnh', 'Chọn "trái dấu" với tính cách của mình', 'Giấu bộ vào túi giấy — không cho người kia thấy'],
        photoHint: 'Chụp hai túi giấy kín — bí ẩn nhé!',
      ),
      const Level(
        num: 2,
        name: 'The Hybrid Build',
        time: '45–60 phút',
        place: 'Góc cafe yên tĩnh / Phòng riêng',
        context: 'ĐỔ TẤT CẢ VÀO MỘT TÚI. Bật nhạc Lofi hoặc Jazz. Cùng nhau xây dựng từ hai thế giới.',
        spice: 'SILENT MODE: Không được nói. Chỉ dùng hành động. Nhìn vào mắt nhau khi muốn xin mảnh ghép.',
        tasks: ['Đổ hai bộ Lego vào một khay chung', 'Bật nhạc không lời (Lofi / Jazz)', 'Cùng xây — lần lượt, xen kẽ, không nói chuyện', 'Chỉ được dùng hành động để giao tiếp'],
        photoHint: 'Selfie đang xây Lego!',
      ),
      const Level(
        num: 3,
        name: 'The Energy Sync',
        time: '20–30 phút',
        place: 'Hàng ăn vỉa hè / Quầy thức ăn nhanh',
        context: 'Hệ thống cần nạp năng lượng! Tìm món ăn yêu cầu sự hợp tác.',
        spice: 'Tay trái - Tay phải: cùng cầm chung một ổ bánh mì dài. Ăn nhịp nhàng — không ai nhanh hơn ai!',
        tasks: ['Ghé hàng ăn vỉa hè hoặc quầy thức ăn nhanh', 'Tìm món ăn yêu cầu hợp tác', 'Mỗi người là 1 tay — tay trái hoặc tay phải', 'Ăn nhịp nhàng, không ai để ai chờ'],
        photoHint: 'Chụp hai người đang chia sẻ một món ăn!',
      ),
      const Level(
        num: 4,
        name: 'The Name Reveal',
        time: '20 phút',
        place: 'Quay lại góc xây Lego',
        context: 'Nhìn "công trình" kỳ lạ đã tạo ra. Phá vỡ im lặng và đặt tên cho nó.',
        spice: null,
        tasks: ['Hít thở, nói từ đầu tiên nghĩ đến khi nhìn thành quả', 'Kết hợp hai từ của hai người thành tên công trình', 'Trả lời: "Chúng ta đã hiểu ý nhau bao nhiêu %?"', 'Chụp ảnh cận cảnh công trình + tên viết tay'],
        photoHint: 'Chụp cận cảnh Lego + tên công trình viết tay',
      ),
    ],
    ending: const ActivityEnding(
      title: 'Giao thức tình yêu thiết lập!',
      text: 'Hôm nay, hai bạn không chỉ lắp Lego, mà còn xây một giao thức giao tiếp mới.',
      quote: 'Ngôn ngữ có thể đánh lừa, nhưng sự phối hợp giữa những ngón tay thì không.',
    ),
  ),
  'mapper': Activity(
    key: 'mapper',
    emoji: '🗺️',
    name: 'Mystery Mapper',
    subtitle: 'The Urban Explorers',
    suitFor: 'Cặp đôi thích khám phá thành phố và những điều bất ngờ',
    vec: [7.0, 10.0, 8.0, 2.0, 9.0],
    cost: 200000,
    minStage: 0,
    oath: 'Bản đồ không chỉ để chỉ đường, nó để ghi lại nơi chúng ta đã cùng nhau đi qua.',
    secret: 'Nghĩ một con số may mắn từ 1 đến 10 — nó sẽ là chìa khóa cho những quyết định sắp tới.',
    duration: '~3 giờ',
    theme: ActivityTheme.fromHex(
      primary: '#2ECC71',
      secondary: '#58D68D',
      accent: '#27AE60',
      light: '#E8F8F5',
      dark: '#145A32',
    ),
    musicUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-4.mp3',
    levels: [
      const Level(
        num: 1,
        name: 'The Co-ordinate Pick',
        time: '15 phút',
        place: 'Ngã tư hoặc điểm mốc quen thuộc',
        context: 'Hai bạn đứng quay lưng vào nhau. Mở Google Maps vệ tinh, nhắm mắt xoay bản đồ rồi thả pin ngẫu nhiên trong bán kính 2km.',
        spice: 'Nếu pin rơi vào nhà dân → chọn điểm công cộng gần nhất. Không được than vãn!',
        tasks: ['Đứng quay lưng vào nhau — không nhìn điện thoại của nhau', 'Mở Google Maps, nhắm mắt, xoay rồi thả pin ngẫu nhiên', 'Chọn điểm công cộng gần nhất nếu pin rơi vào nhà dân', 'Ghi lại tọa độ của người kia'],
        photoHint: 'Chụp màn hình Google Maps với 2 cái pin đã thả',
      ),
      const Level(
        num: 2,
        name: 'The Photo Quest',
        time: '30–45 phút',
        place: 'Tọa độ của đối phương đã chọn',
        context: 'ĐỔI ĐIỂM ĐẾN. Bạn phải đến tọa độ mà người kia chọn. Tìm một chi tiết duy nhất "đắt giá" nhất.',
        spice: 'Dùng đôi mắt của nghệ sĩ. Đây là "món quà thị giác" tặng đối phương.',
        tasks: ['Di chuyển đến tọa độ của đối phương', 'Tìm 1 chi tiết "đắt giá" nhất (graffiti, ánh nắng, cửa sổ cũ...)', 'Chụp ảnh theo cách nghệ thuật nhất có thể', 'Gửi tọa độ GPS + ảnh vào tin nhắn cho đối phương'],
        photoHint: 'Bức ảnh nghệ thuật của chi tiết bạn tìm thấy',
      ),
      const Level(
        num: 3,
        name: 'The Random Sip',
        time: '20 phút',
        place: 'Quán nước đầu tiên trong tầm mắt',
        context: 'Ghé vào quán nước đầu tiên cả hai nhìn thấy trên đường gặp nhau.',
        spice: 'Luật Doppelgänger: Không nhìn menu — gọi y hệt món của khách đứng trước!',
        tasks: ['Ghé vào quán nước đầu tiên trong tầm mắt', 'Không được nhìn menu', 'Gọi y hệt món của khách đứng trước (hoặc nhờ nhân viên chọn màu trùng áo)', 'Ngồi xuống và trao đổi về hành trình'],
        photoHint: 'Hai ly nước ngẫu nhiên + góc đường phố',
      ),
      const Level(
        num: 4,
        name: 'The Journey Log',
        time: '30–45 phút',
        place: 'Công viên / Không gian mở',
        context: 'Ngồi lại. Trao ảnh "quà thị giác". Nối hai tọa độ trên Google Maps tạo "vector tình yêu".',
        spice: null,
        tasks: ['Trao ảnh nghệ thuật — kể tại sao chọn chi tiết đó', 'Mở Google Maps, dùng tính năng vẽ nối hai tọa độ lại', 'Đặt tên cho "vector tình yêu" hôm nay', 'Chụp ảnh hai bàn tay chỉ vào hai điểm trên màn hình'],
        photoHint: 'Hai bàn tay chỉ vào hai điểm trên bản đồ',
      ),
    ],
    ending: const ActivityEnding(
      title: 'Bản đồ tình yêu đã được vẽ!',
      text: 'Những địa điểm ngẫu nhiên hôm nay có thể không có trên bản đồ du lịch, nhưng từ giờ trở đi hai bạn sẽ nhớ về nhau khi đi ngang qua.',
      quote: 'Hành trình không nằm ở đích đến, mà nằm ở người cùng ta đi lạc.',
    ),
  ),
  'fashion': Activity(
    key: 'fashion',
    emoji: '👗',
    name: 'Fashion Flip',
    subtitle: 'Alter Ego',
    suitFor: 'Cặp đôi muốn vượt ra khỏi vùng an toàn và nhập vai bản thể mới',
    vec: [7.0, 8.0, 9.0, 5.0, 8.0],
    cost: 300000,
    minStage: 1,
    oath: 'Tôi hứa sẽ không phán xét, không ngại ngùng, và sẽ hoàn toàn nhập tâm vào bản thể mới mà bạn đã chọn cho tôi.',
    secret: null,
    duration: '~2–3 giờ',
    theme: ActivityTheme.fromHex(
      primary: '#E74C3C',
      secondary: '#EC7063',
      accent: '#C0392B',
      light: '#FADBD8',
      dark: '#78281F',
    ),
    musicUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-5.mp3',
    levels: [
      const Level(
        num: 1,
        name: 'The Stylist Choice',
        time: '15 phút',
        place: 'Cửa hàng thời trang / Tiệm đồ Si',
        context: 'Hai bạn đến cửa hàng thời trang. Mỗi người chọn cho đối phương một món phụ kiện hoặc đồ.',
        spice: 'Món đồ phải nằm ngoài "vùng an toàn" của người kia. Nhận đồ → mặc lên ngay, không được phản kháng!',
        tasks: ['Đến cửa hàng thời trang hoặc tiệm đồ si', 'Mỗi người có 15 phút chọn 1 món cho đối phương', 'Chọn thứ "ngoài vùng an toàn" của người kia', 'Nhận đồ → mặc lên ngay, không được phản kháng'],
        photoHint: 'Chụp Before & After — trước và sau khi mặc đồ mới',
      ),
      const Level(
        num: 2,
        name: 'The Persona',
        time: 'Trong suốt hành trình',
        place: 'Trên phố',
        context: 'Dựa trên món đồ nhận được, mỗi người có một Persona tương ứng. Phải duy trì phong thái nhân vật.',
        spice: 'Kính mát đen → Vệ sĩ. Khăn điệu đà → Minh tinh trốn paparazzi. Mũ tai bèo → Khách du lịch lần đầu!',
        tasks: ['Xác định Persona dựa trên món đồ nhận', 'Duy trì cách đi đứng, ánh mắt của nhân vật', 'Không được "thoát vai" khi đi ngoài đường', 'Quay clip ngắn đang diễn ngoài đường'],
        photoHint: 'Street style shot — diễn đúng nhân vật!',
      ),
      const Level(
        num: 3,
        name: 'The Character Drink',
        time: '20–30 phút',
        place: 'Quán cafe / Trà sữa',
        context: 'Đến quầy order và dùng giọng điệu của nhân vật nói chuyện với nhân viên.',
        spice: 'Ai bật cười trước hoặc thoát vai sẽ phải trả tiền chặng này!',
        tasks: ['Đến quán cafe hoặc trà sữa', 'Order theo đúng giọng điệu nhân vật của mình', 'Người kia đứng cạnh — giữ mặt tỉnh bơ hoặc phối hợp diễn', 'Ai cười trước hoặc thoát vai → trả tiền!'],
        photoHint: 'Chụp lúc đang order — bắt được khoảnh khắc tự nhiên nhất',
      ),
      const Level(
        num: 4,
        name: 'The Review',
        time: '30 phút',
        place: 'Không gian ngồi thoải mái',
        context: 'Ngồi lại, nhìn ngắm nhau. Chụp bộ ảnh Street Style. Rồi tháo đồ ra và trao kèm một cái ôm.',
        spice: null,
        tasks: ['Chụp bộ ảnh "Street Style" cho nhau', 'Trả lời: "Khía cạnh nào bộc lộ khi diện đồ khác người?"', 'Trả lời: "If you met for the first time, what would you notice first?"', 'Tháo đồ ra, trao cho nhau kèm một cái ôm'],
        photoHint: 'Bộ ảnh street style đẹp nhất trong ngày',
      ),
    ],
    ending: const ActivityEnding(
      title: 'Sàn diễn tình yêu khép lại!',
      text: 'Đôi khi chúng ta yêu vì sự quen thuộc, nhưng hôm nay hai bạn đã yêu vì sự thú vị của những điều mới lạ.',
      quote: 'Trong bộ phim của cuộc đời, cảm ơn vì đã là bạn diễn của nhau!',
    ),
  ),
  'blind': Activity(
    key: 'blind',
    emoji: '🫶',
    name: 'Blind Trust',
    subtitle: 'The Soul Guidance',
    suitFor: 'Cặp đôi muốn trải nghiệm sự tin tưởng tuyệt đối và đánh thức các giác quan',
    vec: [10.0, 3.0, 6.0, 4.0, 5.0],
    cost: 500000,
    minStage: 2,
    oath: 'Kể từ giây phút này, đôi mắt của anh/em cũng là của anh/em. Anh/em hứa sẽ là bệ đỡ, là ánh sáng và là sự an toàn.',
    secret: 'Chọn 1 từ khóa an toàn (Safe Word) — ví dụ "Hết pin" — để dừng bất cứ lúc nào.',
    duration: '~7 giờ',
    theme: ActivityTheme.fromHex(
      primary: '#C41E3A',
      secondary: '#E75480',
      accent: '#A01830',
      light: '#FCE4EC',
      dark: '#880E4F',
    ),
    musicUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-6.mp3',
    levels: [
      const Level(
        num: 1,
        name: 'The Sensory Deprivation',
        time: '60–90 phút',
        place: 'Đường phố → Khu vực ăn uống',
        context: 'Người Dẫn Đường nhẹ nhàng thắt khăn lụa cho Người Khám Phá. Di chuyển từ điểm dừng xe đến khu vực ăn uống.',
        spice: '"Vẽ" thế giới bằng lời nói. Dừng lại và hỏi người khám phá kể 3 âm thanh đang nghe.',
        tasks: ['Chọn Safe Word với nhau trước khi bắt đầu', 'Thắt khăn — kiểm tra không có khe hở sáng', 'Dắt đi và "vẽ" thế giới bằng lời mô tả xung quanh', 'Người Khám Phá kể 3 âm thanh khác nhau đang nghe'],
        photoHint: 'Chụp hai người đang đi — khăn trên mắt người được dẫn',
      ),
      const Level(
        num: 2,
        name: 'The Mystery Meal',
        time: '120 phút',
        place: 'Nhà hàng yên tĩnh',
        context: 'Người Dẫn Đường bí mật gọi món. Mô tả vị trí đồ dùng theo hướng đồng hồ.',
        spice: 'Mô tả: "Ly nước ở hướng 2 giờ, muỗng ở hướng 6 giờ". Đoán món trước khi ăn!',
        tasks: ['Người Dẫn Đường bí mật chọn món (đa dạng kết cấu)', 'Mô tả vị trí đồ dùng theo kiểu đồng hồ', 'Đút cho đối phương hoặc hướng dẫn họ tự cầm', 'Đoán món trước khi ăn — vị gì? món gì?'],
        photoHint: 'Chụp góc bàn ăn',
      ),
      const Level(
        num: 3,
        name: 'The Invisible Gift',
        time: '30–60 phút',
        place: 'Vẫn tại nhà hàng',
        context: 'Chọn 1 đồ vật trong tầm mắt. Mô tả bằng cảm giác và năng lượng — không được nói tên. Người Khám Phá đoán.',
        spice: null,
        tasks: ['Chọn 1 đồ vật trong tầm mắt (đèn, tranh, đồ trang trí...)', 'Mô tả chỉ bằng năng lượng và cảm giác — không nói tên đồ vật', 'Người khám phá dùng tay "hình dung" và đoán', 'Đoán hình dáng và màu sắc của vật đó'],
        photoHint: 'Chụp khoảnh khắc người khám phá đang hình dung',
      ),
      const Level(
        num: 4,
        name: 'The Vision Return',
        time: '60+ phút',
        place: 'Rooftop / Bãi cỏ / Ven sông lúc hoàng hôn',
        context: 'Di chuyển đến không gian đẹp. Từ từ tháo khăn. Đổi vai — người được dẫn đặt tay lên tim người kia và kể khoảnh khắc yêu nhất.',
        spice: null,
        tasks: ['Di chuyển đến địa điểm đẹp (rooftop, bãi cỏ, ven sông hoàng hôn)', 'Từ từ tháo khăn — để mắt quen với ánh sáng vài giây', 'Trả lời: "Khoảnh khắc nào em hoàn toàn có thể giao phó cuộc đời?"', 'Đổi vai: người vừa được dẫn đặt tay lên tim, kể khoảnh khắc yêu nhất'],
        photoHint: 'Chụp khoảnh khắc mở khăn — ánh sáng hoàng hôn',
      ),
    ],
    ending: const ActivityEnding(
      title: 'Linh hồn đã chạm đến nhau!',
      text: 'Cánh cửa của thị giác đã đóng lại suốt thời gian dài để cánh cửa của linh hồn được mở ra.',
      quote: 'Hai bạn không chỉ đi qua một con phố — đã đi qua ranh giới của sự hoài nghi để chạm đến sự phó thác.',
    ),
  ),
};

class DimensionInfo {
  final String icon;
  final String label;

  const DimensionInfo({required this.icon, required this.label});
}

const List<DimensionInfo> dimensions = [
  DimensionInfo(icon: '💕', label: 'Romance'),
  DimensionInfo(icon: '🧗', label: 'Adventure'),
  DimensionInfo(icon: '🎨', label: 'Creativity'),
  DimensionInfo(icon: '🏠', label: 'Indoor'),
  DimensionInfo(icon: '⚡', label: 'Energy'),
];
