import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../utils/love_counter_helper.dart';
import '../widgets/heart_mascot.dart';

class LoveCounterScreen extends StatefulWidget {
  const LoveCounterScreen({super.key});

  @override
  State<LoveCounterScreen> createState() => _LoveCounterScreenState();
}

class _LoveCounterScreenState extends State<LoveCounterScreen> with TickerProviderStateMixin {
  bool _loading = true;
  bool _isSetup = false;

  // Settings state
  String _userName = '';
  String _loverName = '';
  DateTime? _anniversaryDate;
  String? _userImagePath;
  String? _loverImagePath;
  bool _useDetailedView = false;

  // Live calculation
  Timer? _timer;
  Duration _elapsed = Duration.zero;

  // Setup form fields
  final _formKey = GlobalKey<FormState>();
  final _userController = TextEditingController();
  final _loverController = TextEditingController();
  DateTime? _setupAnniversaryDate;
  String? _setupUserImagePath;
  String? _setupLoverImagePath;

  // Animation controller for pulsing heart
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _loadSettings();

    // Pulse animation for the heart icon between profile pictures
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.25).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    _userController.dispose();
    _loverController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final configured = await LoveCounterHelper.isConfigured();
    final data = await LoveCounterHelper.loadSettings();
    
    if (mounted) {
      setState(() {
        _isSetup = configured;
        _userName = data['userName'];
        _loverName = data['loverName'];
        _anniversaryDate = data['anniversaryDate'];
        _userImagePath = data['userImagePath'];
        _loverImagePath = data['loverImagePath'];
        _useDetailedView = data['useDetailedView'];

        if (_isSetup && _anniversaryDate != null) {
          _elapsed = DateTime.now().difference(_anniversaryDate!);
          _startTimer();
        } else {
          // Defaults for setup
          _setupAnniversaryDate = _anniversaryDate ?? DateTime.now();
          _userController.text = _userName;
          _loverController.text = _loverName;
          _setupUserImagePath = _userImagePath;
          _setupLoverImagePath = _loverImagePath;
        }
        _loading = false;
      });
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted && _anniversaryDate != null) {
        setState(() {
          _elapsed = DateTime.now().difference(_anniversaryDate!);
        });
      }
    });
  }

  Future<void> _pickImage(String targetKey) async {
    // Show premium bottom sheet to choose between camera and gallery
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Text(
                'Upload Photo',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildPickerOption(
                    icon: Icons.photo_library_outlined,
                    label: 'Gallery',
                    onTap: () async {
                      Navigator.pop(context);
                      final path = await LoveCounterHelper.pickAndSaveImage(ImageSource.gallery);
                      if (path != null) {
                        setState(() {
                          if (targetKey == 'user') {
                            _setupUserImagePath = path;
                          } else {
                            _setupLoverImagePath = path;
                          }
                        });
                      }
                    },
                  ),
                  _buildPickerOption(
                    icon: Icons.camera_alt_outlined,
                    label: 'Camera',
                    onTap: () async {
                      Navigator.pop(context);
                      final path = await LoveCounterHelper.pickAndSaveImage(ImageSource.camera);
                      if (path != null) {
                        setState(() {
                          if (targetKey == 'user') {
                            _setupUserImagePath = path;
                          } else {
                            _setupLoverImagePath = path;
                          }
                        });
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPickerOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 110,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade200),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: const Color(0xFF8B5CF6)),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF4B5563),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectAnniversaryDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _setupAnniversaryDate ?? DateTime.now(),
      firstDate: DateTime(1970),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF8B5CF6), // header background color
              onPrimary: Colors.white, // header text color
              onSurface: Color(0xFF1F2937), // body text color
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _setupAnniversaryDate = picked;
      });
    }
  }

  Future<void> _saveSetup() async {
    if (_formKey.currentState!.validate()) {
      if (_setupAnniversaryDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select your anniversary date.')),
        );
        return;
      }

      await LoveCounterHelper.saveSettings(
        userName: _userController.text.trim(),
        loverName: _loverController.text.trim(),
        anniversaryDate: _setupAnniversaryDate!,
        userImagePath: _setupUserImagePath,
        loverImagePath: _setupLoverImagePath,
      );

      _timer?.cancel();
      _pulseController.repeat(reverse: true);

      setState(() {
        _userName = _userController.text.trim();
        _loverName = _loverController.text.trim();
        _anniversaryDate = _setupAnniversaryDate;
        _userImagePath = _setupUserImagePath;
        _loverImagePath = _setupLoverImagePath;
        _elapsed = DateTime.now().difference(_anniversaryDate!);
        _isSetup = true;
      });

      _startTimer();
    }
  }

  void _openSettings() {
    setState(() {
      _userController.text = _userName;
      _loverController.text = _loverName;
      _setupAnniversaryDate = _anniversaryDate;
      _setupUserImagePath = _userImagePath;
      _setupLoverImagePath = _loverImagePath;
      _isSetup = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8B5CF6)),
          ),
        ),
      );
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFFFF5F5), // ultra-light pink
              Colors.white,
              Color(0xFFFAF5FF), // ultra-light purple
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: _isSetup ? _buildDashboardView() : _buildSetupView(),
            ),
          ),
        ),
      ),
    );
  }

  // MARK: - Dashboard View
  Widget _buildDashboardView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Top Bar
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Color(0xFF6B7280)),
              onPressed: () => Navigator.of(context).pop(),
            ),
            const SizedBox(width: 8),
            Text(
              'EverUs',
              style: GoogleFonts.playfairDisplay(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                foreground: Paint()
                  ..shader = const LinearGradient(
                    colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
                  ).createShader(const Rect.fromLTWH(0, 0, 150, 30)),
              ),
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(
                Icons.settings_outlined,
                color: Color(0xFF6B7280),
                size: 26,
              ),
              onPressed: _openSettings,
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        // Cute beating mascot
        const HeartMascot(
          emotion: 'love',
          showComment: false,
        ),
        const SizedBox(height: 24),

        // Couple Photos with Beating Heart
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // User photo
            _buildProfileAvatar(_userName, _userImagePath),
            
            // Beating Heart
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ScaleTransition(
                scale: _pulseAnimation,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x1F8B5CF6),
                        blurRadius: 8,
                        offset: Offset(0, 3),
                      )
                    ],
                  ),
                  child: const Icon(
                    Icons.favorite,
                    color: Color(0xFFEC4899),
                    size: 32,
                  ),
                ),
              ),
            ),

            // Lover photo
            _buildProfileAvatar(_loverName, _loverImagePath),
          ],
        ),
        const SizedBox(height: 32),

        // Glass Counter Card
        _GlassCard(
          child: Column(
            children: [
              Text(
                'WE HAVE BEEN TOGETHER FOR',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                  color: const Color(0xFF8B5CF6),
                ),
              ),
              const SizedBox(height: 16),
              
              // Animated Shader Days text
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ).createShader(bounds),
                child: Text(
                  '${_elapsed.inDays}',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 72,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    height: 1.0,
                  ),
                ),
              ),
              Text(
                'DAYS',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2.0,
                  color: const Color(0xFF1F2937),
                ),
              ),
              
              const SizedBox(height: 24),
              const Divider(color: Color(0xFFF3E8FF), height: 1),
              const SizedBox(height: 16),

              // Detailed Toggle Button
              TextButton(
                onPressed: () {
                  setState(() {
                    _useDetailedView = !_useDetailedView;
                  });
                  LoveCounterHelper.saveUseDetailedView(_useDetailedView);
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _useDetailedView ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      size: 16,
                      color: const Color(0xFF8B5CF6),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _useDetailedView ? 'Hide Details' : 'Show Details (Hours/Mins)',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF8B5CF6),
                      ),
                    ),
                  ],
                ),
              ),

              if (_useDetailedView) ...[
                const SizedBox(height: 16),
                _buildDetailedGrid(),
              ],
            ],
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildProfileAvatar(String name, String? imagePath) {
    final size = 100.0;
    return Column(
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3.5),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0F000000),
                blurRadius: 10,
                offset: Offset(0, 4),
              )
            ],
          ),
          child: ClipOval(
            child: imagePath != null && File(imagePath).existsSync()
                ? Image.file(
                    File(imagePath),
                    width: size,
                    height: size,
                    fit: BoxFit.cover,
                  )
                : Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFFF3E8FF), Color(0xFFFCE7F3)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        name.isNotEmpty ? name[0].toUpperCase() : '♥',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF8B5CF6),
                        ),
                      ),
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          name.isNotEmpty ? name : 'Love',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF374151),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailedGrid() {
    final hours = _elapsed.inHours % 24;
    final minutes = _elapsed.inMinutes % 60;
    final seconds = _elapsed.inSeconds % 60;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildDetailUnit('${_elapsed.inDays}', 'Days'),
        _buildDetailUnit('$hours', 'Hours'),
        _buildDetailUnit('$minutes', 'Mins'),
        _buildDetailUnit('$seconds', 'Secs'),
      ],
    );
  }

  Widget _buildDetailUnit(String value, String label) {
    return Container(
      width: 65,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF3E8FF), width: 1),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.playfairDisplay(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label.toUpperCase(),
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF6B7280),
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  // MARK: - Setup View
  Widget _buildSetupView() {
    final df = _setupAnniversaryDate == null
        ? 'Select Date'
        : '${_setupAnniversaryDate!.day}/${_setupAnniversaryDate!.month}/${_setupAnniversaryDate!.year}';

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Color(0xFF6B7280)),
                onPressed: () => Navigator.of(context).pop(),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 48.0),
                  child: Text(
                    'Create Love Counter',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1F2937),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Record your milestone. All data is kept 100% locally on your phone.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: const Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 32),

          // Side by side profile selectors
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildSetupProfileButton('user', 'You', _setupUserImagePath),
              _buildSetupProfileButton('lover', 'Partner', _setupLoverImagePath),
            ],
          ),
          const SizedBox(height: 32),

          // Anniversary Date Selector
          _GlassCard(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: InkWell(
              onTap: _selectAnniversaryDate,
              child: Row(
                children: [
                  const Icon(Icons.calendar_today, color: Color(0xFF8B5CF6)),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Anniversary Date',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        df,
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1F2937),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  const Icon(Icons.arrow_drop_down, color: Color(0xFF6B7280)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Name Input Fields
          _GlassCard(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              children: [
                TextFormField(
                  controller: _userController,
                  validator: (val) =>
                      (val == null || val.trim().isEmpty) ? 'Enter your name' : null,
                  style: GoogleFonts.inter(fontSize: 15),
                  decoration: InputDecoration(
                    labelText: 'Your Name',
                    labelStyle: GoogleFonts.inter(color: const Color(0xFF6B7280)),
                    prefixIcon: const Icon(Icons.person_outline, color: Color(0xFF8B5CF6)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: Color(0xFF8B5CF6), width: 1.5),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _loverController,
                  validator: (val) =>
                      (val == null || val.trim().isEmpty) ? 'Enter their name' : null,
                  style: GoogleFonts.inter(fontSize: 15),
                  decoration: InputDecoration(
                    labelText: 'Partner\'s Name',
                    labelStyle: GoogleFonts.inter(color: const Color(0xFF6B7280)),
                    prefixIcon: const Icon(Icons.favorite_border, color: Color(0xFFEC4899)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: Color(0xFFEC4899), width: 1.5),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Save Button
          Container(
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              gradient: const LinearGradient(
                colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF8B5CF6).withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: _saveSetup,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
              child: Text(
                'Save & Count Love Days',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          
          if (_userName.isNotEmpty && _loverName.isNotEmpty) ...[
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                setState(() {
                  _isSetup = true;
                });
                _startTimer();
              },
              child: Text(
                'Cancel',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF6B7280),
                ),
              ),
            ),
          ],
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSetupProfileButton(String key, String label, String? imagePath) {
    final size = 110.0;
    final imageExists = imagePath != null && File(imagePath).existsSync();

    return Column(
      children: [
        InkWell(
          onTap: () => _pickImage(key),
          borderRadius: BorderRadius.circular(size / 2),
          child: Stack(
            children: [
              Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(
                    color: key == 'user' ? const Color(0xFF8B5CF6) : const Color(0xFFEC4899),
                    width: 2.5,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x0F000000),
                      blurRadius: 8,
                      offset: Offset(0, 3),
                    )
                  ],
                ),
                child: ClipOval(
                  child: imageExists
                      ? Image.file(
                          File(imagePath),
                          width: size,
                          height: size,
                          fit: BoxFit.cover,
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_a_photo_outlined,
                              color: key == 'user' ? const Color(0xFF8B5CF6) : const Color(0xFFEC4899),
                              size: 28,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Add Photo',
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: key == 'user' ? const Color(0xFF8B5CF6) : const Color(0xFFEC4899),
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              if (imageExists)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: key == 'user' ? const Color(0xFF8B5CF6) : const Color(0xFFEC4899),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(
                      Icons.edit,
                      size: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF374151),
          ),
        ),
      ],
    );
  }
}

// MARK: - Local GlassCard implementation
class _GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const _GlassCard({
    required this.child,
    this.padding = const EdgeInsets.all(24),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 15,
            offset: Offset(0, 8),
          ),
        ],
      ),
      padding: padding,
      child: child,
    );
  }
}
