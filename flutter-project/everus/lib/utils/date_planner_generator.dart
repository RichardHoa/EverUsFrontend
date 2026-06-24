import 'package:flutter/material.dart';
import '../models/activity.dart';

class DateStage {
  final int stageNum;
  final String name;      // e.g. "Warm-up", "Shared Activity", "Slow Ending"
  final String title;     // e.g. "Khởi động nhẹ nhàng"
  final String purpose;   // e.g. "ăn nhẹ, dễ nói chuyện"
  final String category;  // e.g. "casual restaurant / pasta / Japanese"
  final int durationMinutes;
  final String startTime;
  final String endTime;
  final String placeTypeHint;
  final List<String> tasks;
  final List<String> tips;

  const DateStage({
    required this.stageNum,
    required this.name,
    required this.title,
    required this.purpose,
    required this.category,
    required this.durationMinutes,
    required this.startTime,
    required this.endTime,
    required this.placeTypeHint,
    required this.tasks,
    required this.tips,
  });
}

class DatePlan {
  final String dateType;
  final String vibe;
  final String emoji;
  final int totalDurationMinutes;
  final ActivityTheme theme;
  final List<DateStage> stages;
  final String oath;
  final String endingQuote;

  const DatePlan({
    required this.dateType,
    required this.vibe,
    required this.emoji,
    required this.totalDurationMinutes,
    required this.theme,
    required this.stages,
    required this.oath,
    required this.endingQuote,
  });
}

class DatePlannerInput {
  final TimeOfDay startTime;
  final double totalDurationHours;
  final String area;
  final int budgetPerPerson;
  final String vibe; // 'romantic' | 'active' | 'creative' | 'quiet'
  final int stageCount;
  final String transportation; // 'walking' | 'motorbike' | 'taxi'
  final List<String> preferences;

  const DatePlannerInput({
    required this.startTime,
    required this.totalDurationHours,
    required this.area,
    required this.budgetPerPerson,
    required this.vibe,
    required this.stageCount,
    required this.transportation,
    required this.preferences,
  });
}

class DatePlannerGenerator {
  static DatePlan generate(DatePlannerInput input) {
    // 1. Determine theme and names based on Vibe
    String dateType = "Kế hoạch Hẹn hò";
    String emoji = "📅";
    String oath = "Hôm nay, chúng ta hứa sẽ đặt điện thoại xuống và dành trọn vẹn sự chú ý cho nhau.";
    String endingQuote = "Hẹn hò không chỉ là đi chơi, mà là cách chúng ta tưới mát tình yêu của mình.";
    ActivityTheme theme;

    switch (input.vibe) {
      case 'romantic':
        dateType = "Romantic Getaway Date (Hẹn Hò Lãng Mạn)";
        emoji = "💖";
        theme = ActivityTheme.fromHex(
          primary: '#EC4899',
          secondary: '#F43F5E',
          accent: '#DB2777',
          light: '#FFF1F2',
          dark: '#9D174D',
        );
        oath = "Tôi hứa sẽ trao đi những lời ngọt ngào và trân trọng từng khoảnh khắc lãng mạn bên bạn hôm nay.";
        endingQuote = "Dưới ánh đèn lung linh hay hoàng hôn buông xuống, điều đẹp đẽ nhất chính là nụ cười của bạn.";
        break;
      case 'active':
        dateType = "High Energy Adventure (Phiêu Lưu Năng Động)";
        emoji = "⚡";
        theme = ActivityTheme.fromHex(
          primary: '#F97316',
          secondary: '#FBBF24',
          accent: '#EA580C',
          light: '#FFF7ED',
          dark: '#7C2D12',
        );
        oath = "Chúng ta hứa sẽ cùng chơi hết sức, cười hết ga và sẵn sàng cho những bất ngờ thú vị phía trước!";
        endingQuote = "Năng lượng hôm nay có thể đã tiêu hao, nhưng tiếng cười và sự sảng khoái thì còn đọng lại mãi.";
        break;
      case 'creative':
        dateType = "Creative Workshop Date (Sáng Tạo Nghệ Thuật)";
        emoji = "🎨";
        theme = ActivityTheme.fromHex(
          primary: '#8B5CF6',
          secondary: '#A78BFA',
          accent: '#7C3AED',
          light: '#F5F3FF',
          dark: '#4C1D95',
        );
        oath = "Dù tác phẩm làm ra có hoàn hảo hay ngộ nghĩnh, chúng ta vẫn sẽ trân trọng sự đồng điệu trong tư duy.";
        endingQuote = "Hai bạn không chỉ tạo ra một sản phẩm thủ công, hai bạn đã dệt thêm một mảnh ký ức rực rỡ sắc màu.";
        break;
      case 'quiet':
      default:
        dateType = "Quiet Reconnection Date (Kết Nối Bình Yên)";
        emoji = "🍃";
        theme = ActivityTheme.fromHex(
          primary: '#0D9488',
          secondary: '#2DD4BF',
          accent: '#0F766E',
          light: '#F0FDFA',
          dark: '#115E59',
        );
        oath = "Tôi hứa sẽ lắng nghe bạn bằng cả trái tim, chia sẻ những suy nghĩ sâu kín nhất trong bầu không khí ấm áp này.";
        endingQuote = "Thành phố ồn ào ngoài kia dường như lùi lại phía sau, chỉ còn sự bình yên lan tỏa giữa hai tâm hồn.";
        break;
    }

    // 2. Distribute total duration among stages
    int totalMinutes = (input.totalDurationHours * 60).round();
    
    // Allocate stage durations (approximate proportions)
    List<int> stageDurations = [];
    if (input.stageCount == 2) {
      stageDurations = [
        (totalMinutes * 0.45).round(),
        (totalMinutes * 0.55).round(),
      ];
    } else if (input.stageCount == 3) {
      stageDurations = [
        (totalMinutes * 0.3).round(),
        (totalMinutes * 0.4).round(),
        (totalMinutes * 0.3).round(),
      ];
    } else { // 4 stages
      stageDurations = [
        (totalMinutes * 0.2).round(),
        (totalMinutes * 0.3).round(),
        (totalMinutes * 0.3).round(),
        (totalMinutes * 0.2).round(),
      ];
    }

    // Adjust sum of stage durations to match totalMinutes exactly
    int sum = stageDurations.reduce((a, b) => a + b);
    if (sum != totalMinutes) {
      stageDurations[0] += (totalMinutes - sum);
    }

    // 3. Build Stages
    List<DateStage> stages = [];
    int currentHour = input.startTime.hour;
    int currentMinute = input.startTime.minute;

    String formatTime(int h, int m) {
      final hourStr = h.toString().padLeft(2, '0');
      final minStr = m.toString().padLeft(2, '0');
      return "$hourStr:$minStr";
    }

    for (int i = 0; i < input.stageCount; i++) {
      int duration = stageDurations[i];
      
      // Calculate start time for stage
      String stageStartStr = formatTime(currentHour, currentMinute);
      
      // Calculate end time
      currentMinute += duration;
      while (currentMinute >= 60) {
        currentHour = (currentHour + 1) % 24;
        currentMinute -= 60;
      }
      String stageEndStr = formatTime(currentHour, currentMinute);

      // Determine stage role:
      // i == 0: Warm-up / Ice-breaker
      // i == last: Slow Ending / Wrap-up
      // middle stages: Shared Activity / Challenge / Meal
      int stageRole = 0; // 0: start, 1: middle, 2: end
      if (i == 0) {
        stageRole = 0;
      } else if (i == input.stageCount - 1) {
        stageRole = 2;
      } else {
        stageRole = 1;
      }

      // Generate details based on Role + Vibe + Budget + Preferences
      String name = "Giai đoạn ${i + 1}";
      String title = "Chặng Hẹn Hò";
      String purpose = "Kết nối & trải nghiệm";
      String category = "Không gian công cộng";
      String placeTypeHint = "Khu vực ${input.area}";
      List<String> tasks = [];
      List<String> tips = [];

      // Customize content
      if (stageRole == 0) {
        name = "Stage 1: Warm-up";
        title = "Khởi động & Chuyện trò";
        purpose = "Ăn nhẹ, trò chuyện thoải mái để bắt nhịp";
        
        if (input.vibe == 'romantic') {
          category = "Pasta / Bistro / Italian / French bistro / Aesthetic Cafe";
          placeTypeHint = "Nhà hàng Âu lãng mạn tại ${input.area}";
          tasks = [
            "Hỏi đối phương về điều vui nhất trong tuần qua",
            "Gọi một món ăn nhẹ hoặc món pasta ấm cúng để chia sẻ",
            "Lén nhìn mắt đối phương khi họ đang order đồ ăn"
          ];
        } else if (input.vibe == 'active') {
          category = "Snacks / Street food / Burgers / Fast food";
          placeTypeHint = "Quán ăn trẻ trung hoặc khu ẩm thực tại ${input.area}";
          tasks = [
            "Mỗi người gọi một món ăn nhanh mà mình thích nhất",
            "Chơi trò bốc thăm xem ai trả tiền cho chặng này",
            "Selfie một tấm chu mỏ hài hước cùng nhau"
          ];
        } else if (input.vibe == 'creative') {
          category = "Aesthetic Cafe / Gallery Cafe / Tea room";
          placeTypeHint = "Quán cafe nghệ thuật hoặc phòng triển lãm tại ${input.area}";
          tasks = [
            "Đến quán nước có cách bài trí sáng tạo, độc đáo",
            "Mỗi người gọi một món nước có màu sắc khác biệt",
            "Mô tả tâm trạng hôm nay bằng một tính từ nghệ thuật"
          ];
        } else { // quiet
          category = "Cozy Cafe / Tea house / Comfort food / Soup";
          placeTypeHint = "Quán cafe yên tĩnh hoặc tiệm ăn ấm cúng tại ${input.area}";
          tasks = [
            "Tìm một góc bàn khuất, ấm áp ở quán cafe nhỏ",
            "Thưởng thức ly trà ấm hoặc bát súp nóng hổi",
            "Cùng kể cho nhau nghe về một bộ phim/cuốn sách bình yên gần đây"
          ];
        }
      } else if (stageRole == 2) {
        name = "Stage ${input.stageCount}: Slow Ending";
        title = "Lắng đọng & Gắn kết";
        purpose = "Ngồi lâu, chia sẻ sâu sắc trước khi kết thúc";
        
        bool noBar = input.preferences.contains('không đi bar');

        if (input.vibe == 'romantic') {
          category = noBar ? "Rooftop Mocktails / Dessert Place / Riverside Walk" : "Rooftop Bar / Wine Lounge / Dessert Place";
          placeTypeHint = "Không gian ngắm cảnh từ trên cao hoặc ven sông tại ${input.area}";
          tasks = [
            "Ghé quán rooftop ngắm thành phố lên đèn lung linh",
            "Nắm tay đi dạo nhẹ nhàng và lắng nghe âm thanh đêm muộn",
            "Cảm ơn đối phương vì đã dành thời gian trọn vẹn cho mình"
          ];
        } else if (input.vibe == 'active') {
          category = "Vibrant Night Market / Street Juice / Walking Street";
          placeTypeHint = "Phố đi bộ náo nhiệt hoặc khu phố ẩm thực đêm tại ${input.area}";
          tasks = [
            "Ghé quầy nước ép vỉa hè hoặc trà chanh lộng gió",
            "Cùng nghe nhạc đường phố hoặc xem các nhóm nhảy",
            "Chơi một mini-game nhỏ: nói lời cảm ơn kèm theo 1 biểu cảm ngộ nghĩnh"
          ];
        } else if (input.vibe == 'creative') {
          category = "Book Cafe / Acoustic Cafe / Rooftop Dessert";
          placeTypeHint = "Quán nước có nhạc acoustic nhẹ nhàng hoặc tiệm sách mở muộn tại ${input.area}";
          tasks = [
            "Lắng nghe những giai điệu acoustic mộc mạc",
            "Viết tặng nhau một tấm postcard nhỏ xinh hoặc lời nhắn giấy gửi lại quán",
            "Thảo luận về ý tưởng điên rồ nhất mà hai bạn muốn thực hiện cùng nhau"
          ];
        } else { // quiet
          category = "Quiet Cafe / Stargazing Spot / Dessert Shop";
          placeTypeHint = "Quán trà thảo mộc tĩnh lặng hoặc góc công viên mát mẻ tại ${input.area}";
          tasks = [
            "Tìm không gian tĩnh lặng để ngắm nhìn đường phố chậm rãi",
            "Uống một tách trà thảo mộc thư giãn đầu óc",
            "Trả lời câu hỏi: 'Điều gì ở người kia khiến bạn cảm thấy an tâm nhất?'"
          ];
        }
      } else {
        // Middle stages (Stage 2 or 3)
        name = "Stage ${i + 1}: Shared Activity";
        title = "Trải nghiệm chung & Kỷ niệm";
        purpose = "Tham gia hoạt động chung để tăng tính kết nối";

        if (input.vibe == 'romantic') {
          category = "Photobooth / River Cruise / Art Museum / Flowers";
          placeTypeHint = "Khu vực nghệ thuật hoặc tiệm chụp ảnh lấy liền ở ${input.area}";
          tasks = [
            "Ghé tiệm photobooth, chụp một dải ảnh lãng mạn",
            "Cùng ngắm nhìn các tác phẩm nghệ thuật và đoán xem đối phương thích bức nào nhất",
            "Tặng người kia một bông hoa nhỏ ngẫu nhiên mua bên đường"
          ];
        } else if (input.vibe == 'active') {
          category = "Arcade / Bowling / Boardgame Cafe / Roller Skating";
          placeTypeHint = "Trung tâm giải trí hoặc quán boardgame sôi động tại ${input.area}";
          tasks = [
            "Chơi bóng bàn, ném bóng rổ hoặc đua xe tại khu arcade",
            "Đấu 1-1 một ván game nhanh, ai thua sẽ chịu phạt mua đồ uống",
            "Hò reo hết mình và đập tay ăn mừng mỗi lần ghi điểm"
          ];
        } else if (input.vibe == 'creative') {
          category = "Pottery workshop / Painting studio / DIY candle making / Lego building";
          placeTypeHint = "Xưởng làm gốm, tranh vẽ hoặc không gian lắp ráp Lego ở ${input.area}";
          tasks = [
            "Cùng nhào nặn đất sét hoặc vẽ lên một chiếc cốc gốm",
            "Đổ hai bộ Lego nhỏ vào nhau và cùng lắp một ngôi nhà tưởng tượng",
            "Chọn một mùi hương tinh dầu gợi nhớ đến tính cách người kia để làm nến thơm"
          ];
        } else { // quiet
          category = "Quiet Park Walk / Tea Ceremony / Bookstore / Couple Massage";
          placeTypeHint = "Công viên cây xanh mát mẻ hoặc nhà sách yên ắng tại ${input.area}";
          tasks = [
            "Cùng dạo quanh những hàng sách cũ, chọn cho đối phương 1 cuốn sách bất ngờ",
            "Ngồi dưới tán cây công viên, lắng nghe tiếng chim hót",
            "Tham gia buổi trà đạo tĩnh lặng hoặc đi thư giãn vai cổ gáy"
          ];
        }
      }

      // 4. Adjustments based on budget
      if (input.budgetPerPerson < 150000) {
        // Adjust categories for low budget
        category = category
            .replaceAll("French bistro", "Local food")
            .replaceAll("Italian", "Street food")
            .replaceAll("Bistro", "Street vendor")
            .replaceAll("Wine Lounge", "Lemon tea shop")
            .replaceAll("River Cruise", "Riverside walking")
            .replaceAll("Billiard", "Street walk")
            .replaceAll("Pottery workshop", "Lego building at cafe");
        placeTypeHint = "Quán bình dân/vỉa hè hoặc địa điểm công cộng ở ${input.area}";
        tips.add("💰 Chặng tiết kiệm: Sử dụng các dịch vụ công cộng hoặc hàng quán bình dân để có chi phí tối ưu.");
      } else if (input.budgetPerPerson > 400000) {
        tips.add("✨ Trải nghiệm cao cấp: Hãy cân nhắc đặt chỗ trước để được phục vụ chu đáo nhất.");
      }

      // 5. Add transport details
      String transportTip = "";
      if (input.transportation == 'walking') {
        transportTip = "🚶 Đi bộ: Các điểm đến chặng này rất gần nhau. Thong thả đi bộ giúp tăng thời gian tương tác.";
      } else if (input.transportation == 'motorbike') {
        transportTip = "🏍️ Xe máy: Cùng vi vu ngắm đường phố mát mẻ, đừng quên ôm eo người ấy nhé!";
      } else {
        transportTip = "🚕 Taxi: Di chuyển bằng ô tô giúp giữ nếp tóc đẹp và tránh được khói bụi thành phố.";
      }
      tips.add(transportTip);

      // 6. Preferences adjustments
      if (input.preferences.contains('ít đông')) {
        tips.add("🤫 Mẹo tránh đông: Ưu tiên chọn bàn sâu phía trong quán hoặc ghé vào các góc khuất.");
        if (stageRole == 0) tasks.add("Chọn chỗ ngồi có khoảng cách riêng tư để dễ nói chuyện");
      }
      if (input.preferences.contains('chụp hình đẹp')) {
        tips.add("📸 Góc sống ảo: Hãy bật camera điện thoại, bắt những khoảnh khắc tự nhiên nhất của đối phương.");
        tasks.add("Chụp cho đối phương ít nhất 3 tấm ảnh 'xuất thần'");
      }
      if (input.preferences.contains('nói chuyện nhiều')) {
        tips.add("💬 Chuyện trò: Đặt điện thoại ở chế độ im lặng, dành trọn ánh mắt cho người đối diện.");
        if (stageRole == 2) tasks.add("Chia sẻ một bí mật nhỏ chưa bao giờ kể với người kia");
      }
      if (input.preferences.contains('hoạt động vui')) {
        tasks.add("Thử thách nói một câu đùa nhạt xem đối phương có cười không");
      }
      if (input.preferences.contains('tiết kiệm')) {
        tasks.add("Tìm và áp dụng mã giảm giá khi thanh toán chặng này");
      }
      if (input.preferences.contains('bất ngờ')) {
        tasks.add("Nhiệm vụ bí mật: Lén viết một câu chúc đáng yêu lên khăn giấy gửi người ấy");
      }
      if (input.preferences.contains('không ăn cay')) {
        tips.add("🌶️ Lưu ý ăn uống: Dặn nhân viên không bỏ ớt/tiêu khi chế biến món ăn.");
      }

      stages.add(
        DateStage(
          stageNum: i + 1,
          name: name,
          title: title,
          purpose: purpose,
          category: category,
          durationMinutes: duration,
          startTime: stageStartStr,
          endTime: stageEndStr,
          placeTypeHint: placeTypeHint,
          tasks: tasks,
          tips: tips,
        ),
      );

      // Add 15 minutes transit time between stages (except for the last stage)
      if (i < input.stageCount - 1) {
        currentMinute += 15;
        while (currentMinute >= 60) {
          currentHour = (currentHour + 1) % 24;
          currentMinute -= 60;
        }
      }
    }

    return DatePlan(
      dateType: dateType,
      vibe: input.vibe,
      emoji: emoji,
      totalDurationMinutes: totalMinutes,
      theme: theme,
      stages: stages,
      oath: oath,
      endingQuote: endingQuote,
    );
  }
}
