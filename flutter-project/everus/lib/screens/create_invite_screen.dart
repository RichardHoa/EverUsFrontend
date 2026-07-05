import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/auth_helper.dart';

class InviteTemplate {
  final String id;
  final String name;
  final String Function(String sender, String receiver, String date, String time, String location, String duration) getText;

  const InviteTemplate({required this.id, required this.name, required this.getText});
}

final List<InviteTemplate> templates = [
  InviteTemplate(
    id: 'love_letter',
    name: 'Thư Tình ✉️',
    getText: (sender, receiver, date, time, location, duration) =>
        'Gửi $receiver,\n\nCó những buổi hẹn khiến đôi mình nhớ rất lâu, không phải vì đi đến nơi nào quá đặc biệt, mà vì người đi cùng là người khiến mọi thứ trở nên đáng nhớ.\n\n$sender đã dành một chút thời gian để chuẩn bị cho lần gặp này. Không quá cầu kỳ, cũng không phải điều gì quá lớn lao. Chỉ là $sender muốn trong vài tiếng sắp tới, mình có thể tạm gác lại công việc, deadline và những bộn bề ngoài kia để chỉ tập trung vào nhau.\n\n$sender đã tìm được vài nơi mà $sender nghĩ $receiver sẽ thích, một bữa ăn ngon để mình vừa ăn vừa kể nhau nghe những câu chuyện đã bỏ lỡ, và một đoạn đường đủ đẹp để mình đi thật chậm, chẳng cần vội về.\n\nNếu em đồng ý, thì buổi hẹn này sẽ bắt đầu vào:\n📍 Ngày: $date\n🕒 Giờ: $time\n📍 Khu vực: $location\n\nHy vọng khi kết thúc ngày hôm đó, điều $receiver nhớ nhất sẽ không phải là quán ăn hay con đường mình đi qua, mà là cảm giác "thật may vì mình đã nhận lời."\n\n$receiver có muốn cùng $sender viết thêm một kỷ niệm nữa không?',
  ),
  InviteTemplate(
    id: 'secret_mission',
    name: 'Nhiệm Vụ Mật 🕵️‍♂️',
    getText: (sender, receiver, date, time, location, duration) =>
        'Nếu bạn nhận được lá thư này, thì chắc chắn bạn là một người rất đặc biệt.\n\nSau quá trình nghiên cứu, lên kế hoạch và khảo sát địa hình vô cùng nghiêm túc, $sender xin thông báo rằng một nhiệm vụ mới đã được khởi tạo.\n\nTên nhiệm vụ: Operation: Make Us Smile\n\nMục tiêu của chiến dịch rất đơn giản:\n● Cùng nhau khám phá một nơi thú vị.\n● Ăn một món thật ngon.\n● Nói thật nhiều điều mà dạo này mình chưa có dịp kể.\n● Và mang về ít nhất một kỷ niệm đủ đẹp để sau này nhắc lại vẫn còn cười.\n\nThông tin nhiệm vụ:\n📅 Ngày: $date\n🕒 Giờ: $time\n📍 Địa điểm: $location\n⏳ Thời lượng dự kiến: $duration\n💰 Ngân sách: $sender đã chuẩn bị rồi, $receiver chỉ cần mang theo chính mình.\n\nLưu ý:\n- Không yêu cầu kinh nghiệm.\n- Không cần chuẩn bị trước.\n- Được phép cười lớn.\n- Được phép nắm tay nếu thấy vui.\n\nNếu em chấp nhận nhiệm vụ này, chỉ cần nhấn "Đồng ý".\n$sender sẽ lo phần còn lại.',
  ),
  InviteTemplate(
    id: 'boarding_pass',
    name: 'Vé Máy Bay ✈️',
    getText: (sender, receiver, date, time, location, duration) =>
        'Xin chúc mừng!\n\nBạn vừa nhận được tấm vé duy nhất cho chuyến đi mang tên: "A Little Escape With Us."\n\nĐiểm đến lần này không phải là một thành phố xa lạ, mà là vài tiếng đồng hồ mình thật sự dành cho nhau.\n\nTrong hành trình này sẽ có:\n☕ Một điểm dừng để bắt đầu câu chuyện.\n🍽️ Một bữa ăn được chuẩn bị với hy vọng $receiver sẽ thích.\n🌇 Một nơi đủ yên để mình đi cạnh nhau mà không cần nhìn đồng hồ quá nhiều.\n\nThông tin chuyến đi:\n- Boarding Time: $time\n- Departure Date: $date\n- Destination: $location\n- Estimated Duration: $duration\n- Dress Code: Chỉ cần là $receiver.\n\nKhông có chuyến bay nào đúng giờ nếu thiếu hành khách quan trọng nhất.\nVì vậy trước khi cất cánh, $sender chỉ muốn hỏi một câu thôi.\n\nLên chuyến đi này cùng $sender nhé?',
  ),
  InviteTemplate(
    id: 'movie_trailer',
    name: 'Trailer Phim 🎬',
    getText: (sender, receiver, date, time, location, duration) =>
        '🎬 COMING SOON\n\nTrong vài ngày tới...\nSẽ có hai nhân vật chính gặp nhau ở một nơi đã được chuẩn bị từ trước.\nMột người dành thời gian để lên kế hoạch.\nMột người chỉ cần xuất hiện là đủ khiến câu chuyện trở nên đáng nhớ.\n\nBộ phim lần này sẽ có:\n☕ Những cuộc trò chuyện mà mình đã bỏ lỡ.\n🍽️ Một bữa ăn ngon.\n🌇 Một khung cảnh đủ đẹp để khiến thời gian trôi chậm hơn một chút.\n😂 Vài khoảnh khắc chẳng ai viết sẵn kịch bản nhưng sau này sẽ nhớ mãi.\n\nCast:\n⭐ $sender\n⭐ $receiver\n\nShowtime:\n📅 Ngày: $date\n🕒 Giờ: $time\n📍 Địa điểm: $location\n⏳ Thời lượng: $duration\n\nKhông ai biết cái kết của bộ phim này sẽ như thế nào.\nNhưng $sender nghĩ đây là một bộ phim rất đáng để hai mình cùng xem.\n\nTrailer đã kết thúc.\nPhần còn lại sẽ bắt đầu nếu $receiver nhấn "Đồng ý".',
  ),
  InviteTemplate(
    id: 'fairy_tale',
    name: 'Truyện Cổ Tích 📖',
    getText: (sender, receiver, date, time, location, duration) =>
        'Ngày xửa ngày xưa...\n\nCó một người đã dành khá nhiều thời gian chỉ để nghĩ xem làm thế nào cho một buổi gặp gỡ trở nên thật đặc biệt.\nKhông phải bằng những điều xa hoa. Mà bằng những khoảnh khắc đủ nhỏ để sau này vẫn còn nhớ.\n\nMột nơi để bắt đầu câu chuyện.\nMột bữa ăn để kể nhau nghe về những ngày vừa qua.\nMột đoạn đường để đi thật chậm, chẳng cần vội vàng.\n\nVà một người đặc biệt, chính là $receiver. Có lẽ đây không phải là một câu chuyện cổ tích. Sẽ không có phép màu. Không có lâu đài. Cũng chẳng có bà tiên.\n\nNhưng $sender tin rằng, đôi khi điều kỳ diệu nhất chỉ đơn giản là hai người cùng dành thời gian cho nhau.\n\n📅 Ngày: $date\n🕒 Giờ: $time\n📍 Địa điểm: $location\n⏳ Thời lượng: $duration\n\nNếu $receiver đồng ý...\nThì từ hôm đó trở đi, câu chuyện này sẽ không còn bắt đầu bằng ba chữ "Ngày xửa ngày xưa" nữa.\nMà sẽ bắt đầu bằng...\n"Hôm đó, mình đã nhận lời."',
  ),
];

class CreateInviteScreen extends StatefulWidget {
  final String activityKey;
  final String activityName;
  final DateTime initialDate;
  final String initialTime;
  final String initialLocation;
  final String duration;
  final Color primaryColor;
  final Color secondaryColor;
  final String? planId;

  const CreateInviteScreen({
    super.key,
    required this.activityKey,
    required this.activityName,
    required this.initialDate,
    required this.initialTime,
    required this.initialLocation,
    required this.duration,
    required this.primaryColor,
    required this.secondaryColor,
    this.planId,
  });

  @override
  State<CreateInviteScreen> createState() => _CreateInviteScreenState();
}

class _CreateInviteScreenState extends State<CreateInviteScreen> {
  late String templateId;
  late String senderName;
  late String receiverName;
  late DateTime selectedDate;
  late String timeStr;
  late String locationStr;
  late String customText;
  
  bool isCreating = false;
  String? generatedUrl;
  bool copied = false;
  bool isCustomTextEdited = false;

  late TextEditingController customTextController;

  @override
  void initState() {
    super.initState();
    final random = Random();
    templateId = templates[random.nextInt(templates.length)].id;
    senderName = 'Anh';
    receiverName = 'Em';
    selectedDate = widget.initialDate;
    timeStr = widget.initialTime;
    locationStr = widget.initialLocation;
    customText = '';
    customTextController = TextEditingController();
    
    _updateText();
  }

  void _updateText() {
    if (isCustomTextEdited) return;
    final spec = templates.firstWhere((t) => t.id == templateId);
    final dateDisplay = "${selectedDate.day.toString().padLeft(2, '0')}/${selectedDate.month.toString().padLeft(2, '0')}/${selectedDate.year}";
    customText = spec.getText(senderName, receiverName, dateDisplay, timeStr, locationStr, widget.duration);
    customTextController.text = customText;
  }

  @override
  void dispose() {
    customTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(generatedUrl),
        ),
        title: Text(
          generatedUrl == null ? "Tạo Thư Mời Hẹn Hò" : "Lời Mời Đã Sẵn Sàng! 🎉",
          style: GoogleFonts.playfairDisplay(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: generatedUrl == null ? _buildFormBody() : _buildSuccessBody(),
        ),
      ),
    );
  }

  Widget _buildFormBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          widget.activityName.toUpperCase(),
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: widget.primaryColor,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 16),

        // Xưng hô row
        Row(
          children: [
            Expanded(
              child: TextFormField(
                initialValue: senderName,
                decoration: const InputDecoration(
                  labelText: 'Xưng hô của bạn (Sender)',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
                onChanged: (val) {
                  senderName = val;
                  _updateText();
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                initialValue: receiverName,
                decoration: const InputDecoration(
                  labelText: 'Gọi đối phương (Receiver)',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
                onChanged: (val) {
                  receiverName = val;
                  _updateText();
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Date and Time Row
        Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime.now().subtract(const Duration(days: 30)),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (picked != null) {
                    setState(() {
                      selectedDate = picked;
                      _updateText();
                    });
                  }
                },
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Ngày hẹn',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "${selectedDate.day.toString().padLeft(2, '0')}/${selectedDate.month.toString().padLeft(2, '0')}/${selectedDate.year}",
                        style: const TextStyle(fontSize: 14),
                      ),
                      const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                initialValue: timeStr,
                decoration: const InputDecoration(
                  labelText: 'Giờ hẹn gặp',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
                onChanged: (val) {
                  timeStr = val;
                  _updateText();
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Location text field
        TextFormField(
          initialValue: locationStr,
          decoration: const InputDecoration(
            labelText: 'Địa điểm hẹn gặp / Khu vực',
            border: OutlineInputBorder(),
          ),
          onChanged: (val) {
            locationStr = val;
            _updateText();
          },
        ),
        const SizedBox(height: 16),

        // Custom invite text field
        const Text(
          'Nội dung thư mời (Tự do điều chỉnh theo ý muốn):',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54),
        ),
        const SizedBox(height: 8),
        TextField(
          maxLines: 10,
          controller: customTextController,
          style: GoogleFonts.playfairDisplay(fontSize: 13, height: 1.5),
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.all(12),
          ),
          onChanged: (val) {
            customText = val;
            isCustomTextEdited = true;
          },
        ),
        const SizedBox(height: 24),

        // Create Invitation Button
        ElevatedButton(
          onPressed: isCreating ? null : _submitInvitation,
          style: ElevatedButton.styleFrom(
            backgroundColor: widget.primaryColor,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            isCreating ? "Đang xử lý lời mời..." : "Xác Nhận & Tạo Lời Mời 💖",
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 15),
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessBody() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 40),
        const Icon(Icons.check_circle_outline, color: Colors.green, size: 80),
        const SizedBox(height: 24),
        Text(
          'Đường Dẫn Lời Mời Đã Sẵn Sàng!',
          textAlign: TextAlign.center,
          style: GoogleFonts.playfairDisplay(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Sao chép liên kết bên dưới và gửi cho đối phương. Lời mời sẽ mở ra trang web lãng mạn chứa nhạc nền riêng biệt:',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13, color: Colors.grey, height: 1.5),
        ),
        const SizedBox(height: 32),

        // URL display box
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  generatedUrl!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 13, fontFamily: 'monospace', color: Colors.black87),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: generatedUrl!));
                  setState(() {
                    copied = true;
                  });
                  Future.delayed(const Duration(seconds: 2), () {
                    if (mounted) {
                      setState(() {
                        copied = false;
                      });
                    }
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.primaryColor,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  copied ? "Đã chép!" : "Sao chép",
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 48),

        // Back to route button
        OutlinedButton(
          onPressed: () => Navigator.of(context).pop(generatedUrl),
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: Colors.grey.shade300),
            padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text('Quay lại Lộ Trình Hẹn Hò', style: TextStyle(color: Colors.black54)),
        ),
      ],
    );
  }

  Future<void> _submitInvitation() async {
    setState(() {
      isCreating = true;
    });

    final client = HttpClient();
    try {
      final dateDisplay = "${selectedDate.day.toString().padLeft(2, '0')}/${selectedDate.month.toString().padLeft(2, '0')}/${selectedDate.year}";
      final uri = Uri.parse('${AuthHelper.baseUrl}/api/invitations');
      final request = await client.postUrl(uri);
      
      request.headers.contentType = ContentType.json;
      request.write(json.encode({
        'plan_id': widget.planId,
        'activity_key': widget.activityKey,
        'template_id': templateId,
        'sender_name': senderName,
        'receiver_name': receiverName,
        'date': dateDisplay,
        'time': timeStr,
        'location': locationStr,
        'duration': widget.duration,
        'custom_text': customText,
      }));

      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();
      final Map<String, dynamic> responseData = json.decode(responseBody);

      if (response.statusCode >= 400) {
        throw Exception(responseData['detail'] ?? 'Tạo lời mời không thành công.');
      }

      setState(() {
        generatedUrl = responseData['url'] as String;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e')),
        );
      }
    } finally {
      client.close();
      if (mounted) {
        setState(() {
          isCreating = false;
        });
      }
    }
  }
}
