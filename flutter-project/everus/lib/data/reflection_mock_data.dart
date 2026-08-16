import 'package:flutter/material.dart';
import '../models/reflection_models.dart';

/// Centralized repository for all Reflection mock data.
/// Easily modify, add, or replace mock data here in the future.
class ReflectionMockData {
  /// Default pre-seeded reflections for rich initial experience
  static List<ReflectionItem> get defaultReflections {
    final now = DateTime.now();
    return [
      ReflectionItem(
        id: 'ref_1',
        title: 'Chờ đợi tin nhắn khi người ấy đang online',
        situation: 'Anh ấy online mà mấy tiếng không rep mình, mình bực kinh khủng.',
        emotions: 'Bực bội, bất an và cảm giác không được ưu tiên.',
        underlyingNeed: 'Cần sự an tâm và một expectation rõ ràng về cách giao tiếp khi bận rộn.',
        relatedPattern: 'Khi communication đột ngột giảm, bạn dễ bắt đầu nghi ngờ mức độ ưu tiên của đối phương.',
        whatHappened: 'Anh ấy không trả lời tin nhắn trong 3 tiếng dù trạng thái hiển thị online.',
        whatInterpreted: 'Mình nghĩ anh ấy xem nhẹ mình hoặc cố tình phớt lờ.',
        aiPerspective: 'Có thể đối phương đang tập trung xử lý công việc gấp hoặc cần không gian hạ nhiệt sau giờ làm việc căng thẳng.',
        draftedMessage: 'Em không cần anh phải trả lời em ngay khi anh đang bận. Nhưng khi communication đột ngột mất đi, em hơi bất an. Nếu lúc đó anh báo em một câu là đang bận và sẽ nói chuyện sau thì em sẽ thấy yên tâm hơn nhiều.',
        createdAt: now.subtract(const Duration(days: 3)),
        actionTaken: 'shared',
        isBookmarked: true,
      ),
      ReflectionItem(
        id: 'ref_2',
        title: 'Bất đồng về kế hoạch cuối tuần',
        situation: 'Hai đứa lên kế hoạch đi chơi từ đầu tuần nhưng đến thứ 6 người ấy lại bảo mệt muốn ở nhà.',
        emotions: 'Hụt hẫng, thất vọng và cảm thấy công sức chuẩn bị bị lãng quên.',
        underlyingNeed: 'Mong muốn được trân trọng thời gian chất lượng bên nhau (Quality Time).',
        relatedPattern: 'Nhạy cảm khi kế hoạch chung bị thay đổi vào phút chót.',
        whatHappened: 'Người ấy hủy buổi hẹn ngoài trời vì kiệt sức sau tuần làm việc 60 tiếng.',
        whatInterpreted: 'Mình nghĩ người ấy không còn hào hứng đi cùng mình nữa.',
        aiPerspective: 'Sự kiệt sức của người ấy là về mặt thể chất, không phải là giảm sút tình cảm.',
        draftedMessage: 'Em rất mong chờ buổi đi chơi cuối tuần nên lúc nghe anh mệt em có hơi hụt hẫng. Em hiểu tuần qua anh vất vả, tụi mình đổi sang nấu ăn tại nhà và xem phim thư giãn nhé.',
        createdAt: now.subtract(const Duration(days: 8)),
        actionTaken: 'private',
        isBookmarked: false,
      ),
      ReflectionItem(
        id: 'ref_3',
        title: 'Cảm giác bị so sánh ngầm',
        situation: 'Người ấy kể về người yêu cũ của bạn thân mua quà bất ngờ.',
        emotions: 'Tự ti, chạnh lòng.',
        underlyingNeed: 'Cần được công nhận những nỗ lực chăm sóc thầm lặng của bản thân.',
        relatedPattern: 'So sánh gián tiếp khơi dậy nỗi sợ không đủ tốt.',
        whatHappened: 'Đối phương chỉ chia sẻ câu chuyện như một tin tức thường nhật.',
        whatInterpreted: 'Mình nghĩ đối phương ngầm nhắc nhở mình chưa lãng mạn.',
        aiPerspective: 'Người ấy hoàn toàn vô tư chia sẻ chuyện bạn bè mà không có hàm ý chê trách.',
        draftedMessage: 'Đôi khi nghe chuyện người khác làm được điều lãng mạn, em cũng muốn tạo thêm bất ngờ cho anh, nhưng cũng mong anh ghi nhận những điều nhỏ em vẫn làm mỗi ngày nhé.',
        createdAt: now.subtract(const Duration(days: 14)),
        actionTaken: 'private',
        isBookmarked: false,
      ),
      ReflectionItem(
        id: 'ref_4',
        title: 'Tranh luận về việc chi tiêu mua sắm',
        situation: 'Khác biệt trong cách nhìn nhận các khoản chi mua sắm thiết bị gia đình.',
        emotions: 'Căng thẳng, lo lắng về tương lai tài chính.',
        underlyingNeed: 'Cần sự đồng thuận và cảm giác an toàn về tài chính chung.',
        relatedPattern: 'Khác biệt về định nghĩa "cần thiết" vs "tiện nghi".',
        whatHappened: 'Hai người có quan điểm khác nhau về ngân sách món đồ gia dụng.',
        whatInterpreted: 'Nghĩ rằng người kia không biết nhìn xa trông rộng.',
        aiPerspective: 'Cả hai đều muốn điều tốt nhất cho tổ ấm nhưng góc nhìn ưu tiên khác nhau.',
        draftedMessage: 'Em nghĩ tụi mình nên lập một ngân sách chung rõ ràng cho các món đồ trên 2 triệu để cả hai đều thoải mái trước khi quyết định.',
        createdAt: now.subtract(const Duration(days: 20)),
        actionTaken: 'shared',
        isBookmarked: false,
      ),
      ReflectionItem(
        id: 'ref_5',
        title: 'Khoảng lặng sau một ngày dài',
        situation: 'Buổi tối gặp nhau nhưng người ấy chỉ lướt điện thoại và ít nói chuyện.',
        emotions: 'Cô đơn ngay khi ở cạnh nhau.',
        underlyingNeed: 'Kết nối cảm xúc (Emotional Connection).',
        relatedPattern: 'Cần tín hiệu hiện diện tích cực khi ở cùng không gian.',
        whatHappened: 'Người ấy im lặng lướt điện thoại 45 phút sau bữa tối.',
        whatInterpreted: 'Cho rằng người ấy thấy nhàm chán khi ở bên mình.',
        aiPerspective: 'Đối phương đang dùng điện thoại như một cơ chế "xả van" sau ngày dài quá tải.',
        draftedMessage: 'Em rất thích được ở gần anh. Nếu anh cần 30 phút để xả stress với điện thoại cứ bảo em nhé, sau đó tụi mình ôm nhau nói chuyện 15 phút trước khi ngủ nha.',
        createdAt: now.subtract(const Duration(days: 27)),
        actionTaken: 'private',
        isBookmarked: false,
      ),
      ReflectionItem(
        id: 'ref_6',
        title: 'Cảm giác bị ngắt lời khi đang chia sẻ',
        situation: 'Đang kể chuyện ở cơ quan thì người ấy vội đưa ra giải pháp thay vì lắng nghe.',
        emotions: 'Bức bối, cảm thấy không được thấu cảm.',
        underlyingNeed: 'Chỉ cần một người lắng nghe và ôm vỗ về, chưa cần giải pháp logic.',
        relatedPattern: 'Khác biệt giữa nhu cầu "Empathy" và phản xạ "Problem Solving".',
        whatHappened: 'Người ấy liên tục đưa ra lời khuyên logic khi bạn đang xúc động.',
        whatInterpreted: 'Nghĩ người ấy coi thường khả năng tự xử lý vấn đề của mình.',
        aiPerspective: 'Đối phương yêu thương bạn và bản năng muốn giải quyết khó khăn giúp bạn ngay lập tức.',
        draftedMessage: 'Khi em kể chuyện bực mình ở cty, em chỉ cần anh lắng nghe và đứng về phía em thôi á, chưa cần tìm cách giải quyết ngay đâu nè.',
        createdAt: now.subtract(const Duration(days: 35)),
        actionTaken: 'shared',
        isBookmarked: true,
      ),
    ];
  }

  /// Default memory patterns recognized
  static List<MemoryPattern> get defaultPatterns {
    return [
      MemoryPattern(
        id: 'pat_1',
        trigger: 'Communication đột ngột giảm',
        description: 'Khi đối phương online mà không trả lời, bạn thường nhanh chóng tự hỏi liệu mình còn được ưu tiên hay không.',
        confidence: 0.88,
        count: 4,
        lastObserved: DateTime.now().subtract(const Duration(days: 3)),
      ),
      MemoryPattern(
        id: 'pat_2',
        trigger: 'Kế hoạch chung bị thay đổi phút chót',
        description: 'Bạn dễ cảm thấy hụt hẫng và đặt dấu hỏi về mức độ cam kết nếu lịch trình bị hủy đột ngột.',
        confidence: 0.82,
        count: 3,
        lastObserved: DateTime.now().subtract(const Duration(days: 8)),
      ),
      MemoryPattern(
        id: 'pat_3',
        trigger: 'Nhận lời khuyên logic khi đang xúc động',
        description: 'Xu hướng cảm thấy bị ngắt kết nối nếu đối phương lập tức phân tích đúng sai thay vì lắng nghe cảm xúc.',
        confidence: 0.79,
        count: 2,
        lastObserved: DateTime.now().subtract(const Duration(days: 35)),
      ),
    ];
  }

  /// Shared insights for the "Us" (Chúng mình) tab
  static List<SharedRelationshipInsight> get sharedInsights {
    return [
      SharedRelationshipInsight(
        id: 'shared_1',
        title: 'Khi căng thẳng hoặc quá tải xuất hiện',
        triggerScenario: 'Sự khác biệt trong nhịp xử lý áp lực cá nhân',
        dynamicExplanation: 'Một người có xu hướng tìm thêm kết nối và trò chuyện để giải tỏa bất an. Người kia lại có xu hướng thu mình (withdraw), cần thêm không gian riêng để tái tạo năng lượng.',
        communicationLoop: 'Need reassurance ➔ Hỏi dồn dập ➔ Cảm thấy bị áp lực ➔ Thu mình né tránh ➔ Gia tăng bất an',
        helpfulTips: [
          'Nói rõ khi cần space: "Anh/Em cần một chút thời gian yên tĩnh, nhưng tối nay tụi mình nói chuyện nhé."',
          'Đặt thời điểm reconnect rõ ràng thay vì im lặng không rõ bao lâu.',
          'Người tìm kết nối hãy tự chăm sóc bản thân trong lúc chờ đợi, không suy diễn.',
        ],
        reflectionQuestion: 'Khi một người cần space và người kia cần reassurance, hai bạn muốn gặp nhau ở điểm giữa như thế nào?',
      ),
      SharedRelationshipInsight(
        id: 'shared_2',
        title: 'Lắng nghe cảm xúc vs. Tìm giải pháp',
        triggerScenario: 'Khi một người chia sẻ về một ngày mệt mỏi',
        dynamicExplanation: 'Một người cần sự thấu cảm (Empathy First), trong khi người kia vì thương nên lập tức nhảy vào tìm cách sửa chữa vấn đề (Fix-it mode).',
        communicationLoop: 'Chia sẻ chuyện buồn ➔ Nhận lời khuyên logic ➔ Thấy không được hiểu ➔ Khép lòng ➔ Thất vọng',
        helpfulTips: [
          'Hỏi trước khi phản hồi: "Lúc này em muốn anh chỉ lắng nghe hay cùng tìm giải pháp nhé?"',
          'Người chia sẻ hãy gợi ý trước nhu cầu của mình: "Hôm nay em chỉ muốn xả một chút thôi nha."',
        ],
        reflectionQuestion: 'Câu nói nào khiến bạn cảm thấy được thấu hiểu nhất khi đang có tâm trạng không tốt?',
      ),
    ];
  }

  /// Topics available on ReflectionTopicScreen
  static List<Map<String, dynamic>> get topicOptions {
    return [
      {
        'id': 'incident',
        'icon': Icons.bolt_rounded,
        'color': const Color(0xFFEC4899),
        'title': 'Có chuyện vừa xảy ra',
        'subtitle':
            'Một cuộc cãi nhau, một hành động khiến bạn buồn hoặc điều gì đó chưa giải quyết được.',
        'initialPrompt':
            'Hôm nay ảnh online mà mấy tiếng không rep mình, mình bực kinh khủng.',
        'initialAiQuestion':
            'Nghe như chuyện làm bạn khó chịu không chỉ là việc phải chờ đợi tin nhắn.\nLúc đó, cảm giác nào gần với bạn nhất?',
        'initialChips': [
          'Bị bỏ quên',
          'Không được ưu tiên',
          'Không được quan tâm',
          'Mình cũng không biết',
        ],
      },
      {
        'id': 'vague_feeling',
        'icon': Icons.bubble_chart_rounded,
        'color': const Color(0xFF8B5CF6),
        'title': 'Mình đang có cảm xúc khó hiểu',
        'subtitle':
            'Bạn biết mình đang không ổn nhưng chưa thực sự gọi tên được cảm giác đó.',
        'initialPrompt':
            'Dạo này ở cạnh người ấy mình cứ thấy trống trải và nặng lòng mà không rõ lý do.',
        'initialAiQuestion':
            'Cảm giác mơ hồ này thường dễ khiến tâm trí bạn kiệt sức.\nNếu thử hình dung cảm giác nặng lòng đó, nó giống như điều gì nhất?',
        'initialChips': [
          'Khoảng cách vô hình',
          'Thiếu sự kết nối sâu',
          'Sợ mình đang phiền',
          'Chỉ là mình hơi mệt',
        ],
      },
      {
        'id': 'pattern_analysis',
        'icon': Icons.auto_awesome_rounded,
        'color': const Color(0xFF6366F1),
        'title': 'Mình muốn hiểu hơn về hai đứa',
        'subtitle':
            'Nhìn lại một pattern, khoảng cách hoặc một điều lặp đi lặp lại trong mối quan hệ.',
        'initialPrompt':
            'Mỗi lần có bất đồng là tụi mình lại im lặng mấy ngày, mình muốn hiểu tại sao lại như vậy.',
        'initialAiQuestion':
            'Nhận ra vòng lặp là bước đầu tiên để thay đổi nó.\nKhi sự im lặng bắt đầu diễn ra, bạn thường cảm nhận điều gì ở bản thân mình?',
        'initialChips': [
          'Chờ người kia mở lời',
          'Sợ nói ra sẽ tệ hơn',
          'Cảm thấy kiệt sức',
          'Cần thời gian bình tĩnh',
        ],
      },
    ];
  }

  /// Text template for custom topic flow
  static String get defaultCustomAiQuestion =>
      'Cảm ơn bạn đã tin tưởng chia sẻ cùng EverUs.\nKhi nghĩ về điều này, cảm xúc nào đang đọng lại trong bạn rõ ràng nhất?';

  static List<String> get defaultCustomChips => const [
        'Bực bội',
        'Bất an, lo lắng',
        'Hụt hẫng, buồn',
        'Bối rối, khó hiểu',
      ];

  /// Highlighted insight banner text on Personal Sanctuary home tab
  static String get insightOfTheMoment =>
      '"Những khoảng thời gian giao tiếp ít hơn thường khiến bạn cảm thấy bất an hơn."';

  /// Returns existing chatHistory or builds a realistic 5-step transcript for past reflections
  static List<ReflectionChatMessage> getOrCreateChatHistory(ReflectionItem item) {
    if (item.chatHistory != null && item.chatHistory!.isNotEmpty) {
      return item.chatHistory!;
    }
    final t = item.createdAt;
    return [
      ReflectionChatMessage(
        id: 'msg_user_1',
        type: MessageType.user,
        content: item.situation,
        timestamp: t,
      ),
      ReflectionChatMessage(
        id: 'msg_ai_1',
        type: MessageType.ai,
        content:
            'Cảm ơn bạn đã tin tưởng chia sẻ cùng EverUs.\nKhi nghĩ về điều này, cảm xúc nào đang đọng lại trong bạn rõ ràng nhất?',
        selectedOption: item.emotions,
        timestamp: t.add(const Duration(seconds: 2)),
      ),
      ReflectionChatMessage(
        id: 'msg_user_2',
        type: MessageType.user,
        content: item.emotions,
        timestamp: t.add(const Duration(seconds: 15)),
      ),
      ReflectionChatMessage(
        id: 'msg_mem_1',
        type: MessageType.memoryRecall,
        content:
            'Có một điều EverUs nhớ từ những lần trước:\n"${item.relatedPattern}"\n\nBạn nghĩ cảm giác hôm nay có liên quan đến điều đó không?',
        selectedOption: 'Có, khá giống',
        timestamp: t.add(const Duration(seconds: 20)),
      ),
      ReflectionChatMessage(
        id: 'msg_user_3',
        type: MessageType.user,
        content: 'Có, khá giống với cảm giác lần trước.',
        timestamp: t.add(const Duration(seconds: 35)),
      ),
      ReflectionChatMessage(
        id: 'msg_persp_1',
        type: MessageType.perspectiveReframing,
        content:
            'Có vẻ phần khiến bạn bối rối là: "${item.whatInterpreted}"\n\nNhưng sự thật cụ thể là: "${item.whatHappened}"\n\n${item.aiPerspective}',
        selectedOption: item.whatHappened,
        timestamp: t.add(const Duration(seconds: 40)),
      ),
      ReflectionChatMessage(
        id: 'msg_user_4',
        type: MessageType.user,
        content: item.whatHappened,
        timestamp: t.add(const Duration(seconds: 55)),
      ),
      ReflectionChatMessage(
        id: 'msg_ai_2',
        type: MessageType.ai,
        content:
            'Việc phân biệt được sự thật và suy đoán giúp tâm trí nhẹ đi nhiều.\n\nĐiều bạn thực sự mong nhận được từ người ấy lúc này là gì?',
        selectedOption: item.underlyingNeed,
        timestamp: t.add(const Duration(seconds: 60)),
      ),
      ReflectionChatMessage(
        id: 'msg_user_5',
        type: MessageType.user,
        content: item.underlyingNeed,
        timestamp: t.add(const Duration(seconds: 75)),
      ),
      ReflectionChatMessage(
        id: 'msg_ready_1',
        type: MessageType.summaryReady,
        content:
            'EverUs đã cùng bạn đi qua từng lớp cảm xúc.\nMọi thứ giờ đây dường như đã rõ ràng hơn rất nhiều.',
        timestamp: t.add(const Duration(seconds: 80)),
      ),
    ];
  }
}
