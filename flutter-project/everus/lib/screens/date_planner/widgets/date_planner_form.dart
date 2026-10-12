import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../models/date_plan.dart';
import '../../../utils/auth_helper.dart';
import '../../../utils/distance_preference.dart';
import '../../../utils/vnd_budget.dart';
import '../../saved_plans_screen.dart';
import '../date_planner_controller.dart';
import 'planner_calendar.dart';
import 'vibe_carousel.dart';
import '../../../l10n/l10n.dart';

/// Form widget displaying the date planning inputs (date, time, vibe, distance, transport, budget).
///
/// Laid out from the Figma `date_planner` frame: sizes are frame units scaled by
/// the screen width over the frame width.
class DatePlannerForm extends StatelessWidget {
  /// The state controller managing parameters and lifecycle.
  final DatePlannerController controller;

  /// Const constructor for [DatePlannerForm].
  const DatePlannerForm({super.key, required this.controller});

  /// Width of the Figma `date_planner` frame.
  static const double frameWidth = 1316;

  static const _ink = Color(0xFF6F3953);
  static const _pink = Color(0xFFDB74A3);
  static const _budgetPresets = [100000, 200000, 300000, 500000];
  static const _transportKeys = ['walking', 'motorbike', 'taxi'];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final k = constraints.maxWidth / frameWidth;
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.only(top: 40 * k),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 113.5 * k),
                child: PlannerCalendar(
                  selectedDate: controller.selectedDate,
                  plannedDates: controller.plannedDates,
                  onDateSelected: controller.setSelectedDate,
                  scale: k,
                ),
              ),
              SizedBox(height: 113 * k),
              _buildDateRow(context, k),
              SizedBox(height: 51 * k),
              _buildTimeRow(context, k),
              if (_showLocationRow) ...[
                SizedBox(height: 36 * k),
                _buildLocationRow(context, k),
              ],
              SizedBox(height: 40 * k),
              Text(
                context.l10n.plannerVibeTitle,
                textAlign: TextAlign.center,
                style: _title(k),
              ),
              SizedBox(height: 15 * k),
              VibeCarousel(
                selectedVibe: controller.selectedVibe,
                onVibeSelected: controller.setSelectedVibe,
                scale: k,
              ),
              SizedBox(height: 20 * k),
              _buildOptionsPanel(context, k),
              SizedBox(height: 70 * k),
              _buildHistoryLink(context, k),
              SizedBox(height: 60 * k),
              _buildSubmitButton(context, k),
              const SizedBox(height: 100), // Space for floating bottom bar
            ],
          ),
        );
      },
    );
  }

  TextStyle _title(double k) =>
      GoogleFonts.nunito(fontSize: 49.44 * k, fontWeight: FontWeight.w700, color: _ink);

  /// White glass fill shared by the pills, chips and budget field.
  BoxDecoration _glass(double k, double radius, {bool border = false, bool selected = false}) {
    return BoxDecoration(
      color: selected ? _pink.withValues(alpha: 0.85) : Colors.white.withValues(alpha: 0.56),
      borderRadius: BorderRadius.circular(radius * k),
      border: border ? Border.all(color: Colors.white.withValues(alpha: 0.56), width: 1.56 * k) : null,
      boxShadow: [
        BoxShadow(
          color: const Color(0xFFB769A6).withValues(alpha: 0.1),
          offset: Offset(2.91 * k, 2.91 * k),
          blurRadius: 8.32 * k,
        ),
      ],
    );
  }

  Widget _pill(double k, {required double width, required double height, required String text, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width * k,
        height: height * k,
        alignment: Alignment.center,
        decoration: _glass(k, height * 0.42),
        child: Text(
          text,
          maxLines: 1,
          style: GoogleFonts.nunito(fontSize: 42.46 * k, fontWeight: FontWeight.w300, color: _pink),
        ),
      ),
    );
  }

  String _formatSelectedDate(BuildContext context, DateTime date) {
    final weekday = DateFormat.EEEE(Localizations.localeOf(context).toString()).format(date);
    return '$weekday, ${date.day}/${date.month}';
  }

  String _formatTime(TimeOfDay time) =>
      '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

  Widget _buildDateRow(BuildContext context, double k) {
    return Padding(
      padding: EdgeInsets.only(left: 127.5 * k, right: 150 * k),
      child: Row(
        children: [
          Expanded(child: Text(context.l10n.plannerDateLabel, style: _title(k))),
          _pill(k, width: 405.6, height: 100.5, text: _formatSelectedDate(context, controller.selectedDate)),
        ],
      ),
    );
  }

  Widget _buildTimeRow(BuildContext context, double k) {
    return Padding(
      padding: EdgeInsets.only(left: 127.5 * k, right: 150 * k),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            children: [
              Expanded(child: Text(context.l10n.plannerTimeLabel, style: _title(k))),
              _pill(
                k,
                width: 191.7,
                height: 97.4,
                text: _formatTime(controller.startTime),
                onTap: () => _pickTime(context, isStart: true),
              ),
              SizedBox(width: 46 * k),
              Text(
                context.l10n.plannerTimeTo,
                style: GoogleFonts.nunito(fontSize: 42.46 * k, fontWeight: FontWeight.w300, color: _ink),
              ),
              SizedBox(width: 46 * k),
              _pill(
                k,
                width: 191.7,
                height: 97.4,
                text: _formatTime(controller.endTime),
                onTap: () => _pickTime(context, isStart: false),
              ),
            ],
          ),
          if (controller.isEndNextDay)
            SizedBox(
              width: 191.7 * k,
              child: Padding(
                padding: EdgeInsets.only(top: 10 * k),
                child: Text(
                  context.l10n.plannerNextDay,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.nunito(fontSize: 32 * k, fontWeight: FontWeight.w300, color: _pink),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _pickTime(BuildContext context, {required bool isStart}) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart ? controller.startTime : controller.endTime,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(
                primary: Color(0xFF653851),
                onPrimary: Colors.white,
                onSurface: Color(0xFF5A384C),
              ),
            ),
            child: child!,
          ),
        );
      },
    );
    if (picked == null) return;
    if (isStart) {
      controller.setStartTime(picked);
    } else if (!controller.setEndTime(picked) && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.plannerMinDuration),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  bool get _showLocationRow =>
      controller.isLocating || controller.locationPermissionDenied || controller.userLocation == null;

  /// One-line location status, shown only while detecting or when the device position isn't available.
  Widget _buildLocationRow(BuildContext context, double k) {
    final textStyle = GoogleFonts.nunito(fontSize: 38 * k, fontWeight: FontWeight.w400, color: _ink);
    final Widget content;
    if (controller.isLocating) {
      content = Row(
        children: [
          SizedBox(
            width: 34 * k,
            height: 34 * k,
            child: const CircularProgressIndicator(strokeWidth: 2, color: _pink),
          ),
          SizedBox(width: 20 * k),
          Expanded(child: Text(context.l10n.plannerLocating, style: textStyle, maxLines: 1)),
        ],
      );
    } else if (controller.locationPermissionDenied) {
      content = Row(
        children: [
          Icon(
            controller.userLocation != null ? Icons.check_circle_outline : Icons.location_off_outlined,
            size: 44 * k,
            color: _pink,
          ),
          SizedBox(width: 20 * k),
          Expanded(
            child: TextField(
              key: const ValueKey('manual-address-field'),
              controller: controller.addressController,
              textInputAction: TextInputAction.search,
              onSubmitted: controller.setManualAddress,
              style: textStyle,
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                hintText: context.l10n.plannerAddressHint,
                hintStyle: textStyle.copyWith(fontWeight: FontWeight.w200, color: _pink),
              ),
            ),
          ),
          GestureDetector(
            onTap: () => controller.setManualAddress(controller.addressController.text),
            child: Padding(
              padding: EdgeInsets.only(left: 20 * k),
              child: Text(context.l10n.plannerAddressSearch, style: textStyle.copyWith(fontWeight: FontWeight.w700, color: _pink)),
            ),
          ),
        ],
      );
    } else {
      content = Row(
        children: [
          Icon(Icons.location_searching, size: 44 * k, color: _pink),
          SizedBox(width: 20 * k),
          Expanded(child: Text(context.l10n.plannerNoLocation, style: textStyle, maxLines: 1)),
          GestureDetector(
            onTap: controller.useCurrentLocation,
            child: Text(context.l10n.commonRetry, style: textStyle.copyWith(fontWeight: FontWeight.w700, color: _pink)),
          ),
        ],
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 113.5 * k),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 36 * k, vertical: 22 * k),
            decoration: _glass(k, 45, border: true),
            child: content,
          ),
          if (controller.locationError != null)
            Padding(
              padding: EdgeInsets.only(top: 10 * k, left: 36 * k),
              child: Text(
                controller.locationError!,
                style: GoogleFonts.nunito(fontSize: 32 * k, color: Colors.red.shade700),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildOptionsPanel(BuildContext context, double k) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 21 * k),
      padding: EdgeInsets.fromLTRB(46 * k, 26.6 * k, 47 * k, 70 * k),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(50 * k),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _panelTitle(context.l10n.plannerDistanceTitle, k),
          SizedBox(height: 31.7 * k),
          _chipRow(k, [
            for (final choice in DistanceChoice.values)
              _optionChip(
                k,
                label: choice.label,
                hint: choice.hint,
                selected: controller.distanceChoice == choice,
                onTap: () => controller.setDistanceChoice(choice),
              ),
          ]),
          SizedBox(height: 46 * k),
          _panelTitle(context.l10n.plannerTransportTitle, k),
          SizedBox(height: 31.7 * k),
          _chipRow(k, [
            for (final key in _transportKeys)
              _optionChip(
                k,
                label: transportLabel(context.l10n, key),
                selected: controller.transportation == key,
                onTap: () => controller.setTransportation(key),
              ),
          ]),
          SizedBox(height: 60 * k),
          _panelTitle(context.l10n.plannerBudgetTitle, k),
          SizedBox(height: 40 * k),
          _buildBudgetField(context, k),
          SizedBox(height: 55 * k),
          Padding(
            padding: EdgeInsets.only(left: 40 * k, right: 30 * k),
            child: Row(
              children: [
                for (final amount in _budgetPresets) ...[
                  if (amount != _budgetPresets.first) SizedBox(width: 45 * k),
                  Expanded(child: _budgetChip(k, amount)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _panelTitle(String text, double k) =>
      Padding(padding: EdgeInsets.only(left: 22.3 * k), child: Text(text, style: _title(k)));

  Widget _chipRow(double k, List<Widget> chips) {
    return SizedBox(
      height: 154.6 * k,
      child: Row(
        children: [
          for (var i = 0; i < chips.length; i++) ...[
            if (i > 0) SizedBox(width: 57 * k),
            Expanded(child: chips[i]),
          ],
        ],
      ),
    );
  }

  Widget _optionChip(double k, {required String label, String? hint, required bool selected, required VoidCallback onTap}) {
    final color = selected ? Colors.white : _pink;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        alignment: Alignment.center,
        decoration: _glass(k, 40, border: true, selected: selected),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              maxLines: 1,
              style: GoogleFonts.nunito(fontSize: 40 * k, fontWeight: FontWeight.w700, color: color),
            ),
            if (hint != null) ...[
              SizedBox(height: 12 * k),
              Text(
                hint,
                maxLines: 1,
                style: GoogleFonts.nunito(fontSize: 30 * k, fontWeight: FontWeight.w300, color: color),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBudgetField(BuildContext context, double k) {
    final style = GoogleFonts.nunito(fontSize: 40 * k, fontWeight: FontWeight.w600, color: _pink);
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(left: 45 * k),
        width: 518.8 * k,
        height: 100 * k,
        padding: EdgeInsets.symmetric(horizontal: 30.8 * k),
        alignment: Alignment.centerLeft,
        decoration: _glass(k, 42),
        child: TextField(
          key: const ValueKey('budget-field'),
          controller: controller.budgetController,
          keyboardType: TextInputType.number,
          inputFormatters: const [VndInputFormatter()],
          onChanged: (text) => controller.setBudgetPerPerson(parseVnd(text)),
          style: style,
          decoration: InputDecoration(
            isDense: true,
            border: InputBorder.none,
            contentPadding: EdgeInsets.zero,
            hintText: context.l10n.plannerBudgetHint,
            hintStyle: style.copyWith(fontWeight: FontWeight.w200),
            suffixText: 'VND',
            suffixStyle: style,
          ),
        ),
      ),
    );
  }

  Widget _budgetChip(double k, int amount) {
    final selected = controller.budgetPerPerson == amount;
    return GestureDetector(
      onTap: () => controller.setBudgetPerPerson(amount),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: 85 * k,
        alignment: Alignment.center,
        decoration: _glass(k, 26, border: true, selected: selected),
        child: Text(
          '${amount ~/ 1000}K',
          style: GoogleFonts.nunito(
            fontSize: 40 * k,
            fontWeight: FontWeight.w700,
            color: selected ? Colors.white : _pink,
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryLink(BuildContext context, double k) {
    return Center(
      child: GestureDetector(
        onTap: () async {
          if (!AuthHelper.isLoggedIn && controller.savedPlan != null) {
            controller.setGeneratedPlan(controller.savedPlan);
            return;
          }
          final selectedPlan = await Navigator.push<DatePlan>(
            context,
            MaterialPageRoute(builder: (context) => const SavedPlansScreen()),
          );
          if (selectedPlan != null) {
            controller.setGeneratedPlan(selectedPlan);
          }
        },
        child: Text(
          context.l10n.plannerHistoryLink,
          style: GoogleFonts.nunito(fontSize: 50 * k, fontWeight: FontWeight.w300, color: const Color(0xFFAF6389)),
        ),
      ),
    );
  }

  Widget _buildSubmitButton(BuildContext context, double k) {
    final enabled = controller.canGenerate;
    final radius = BorderRadius.circular(60 * k);
    return Center(
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 150),
        opacity: enabled ? 1 : 0.45,
        child: Material(
          color: const Color(0xFF81003B).withValues(alpha: 0.56),
          shape: RoundedRectangleBorder(
            borderRadius: radius,
            side: BorderSide(color: _pink.withValues(alpha: 0.56), width: 1.56 * k),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: enabled ? () => _handleSubmit(context) : null,
            child: SizedBox(
              width: 681 * k,
              height: 148 * k,
              child: Center(
                child: Text(
                  context.l10n.plannerSubmit,
                  style: GoogleFonts.nunito(fontSize: 50 * k, fontWeight: FontWeight.w700, color: Colors.white),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _handleSubmit(BuildContext context) async {
    try {
      await controller.generatePlan();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }
}
