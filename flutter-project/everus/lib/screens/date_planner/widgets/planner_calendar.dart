import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../l10n/l10n.dart';

/// Inline month calendar for the Date Planner form.
///
/// Dates before today are disabled, the selected date is filled, and days in
/// [plannedDates] are circled. Sizes are Figma frame units multiplied by [scale].
class PlannerCalendar extends StatefulWidget {
  /// The selected day (date-only).
  final DateTime selectedDate;

  /// Days (date-only) that already have a saved plan.
  final Set<DateTime> plannedDates;

  /// Called with the tapped day.
  final ValueChanged<DateTime> onDateSelected;

  /// Figma frame units → logical pixels.
  final double scale;

  const PlannerCalendar({
    super.key,
    required this.selectedDate,
    required this.plannedDates,
    required this.onDateSelected,
    required this.scale,
  });

  @override
  State<PlannerCalendar> createState() => _PlannerCalendarState();
}

class _PlannerCalendarState extends State<PlannerCalendar> {
  static const _ink = Color(0xFF6F3953);
  static const _muted = Color(0xFFC9C8D0);
  static const _blush = Color(0xFFFDEFF6);
  static const _periwinkle = Color(0xFFC2D0F3);

  late DateTime _month;

  @override
  void initState() {
    super.initState();
    _month = DateTime(widget.selectedDate.year, widget.selectedDate.month);
  }

  DateTime get _thisMonth {
    final now = DateTime.now();
    return DateTime(now.year, now.month);
  }

  void _shiftMonth(int delta) {
    setState(() => _month = DateTime(_month.year, _month.month + delta));
  }

  @override
  Widget build(BuildContext context) {
    final k = widget.scale;
    final canGoBack = _month.isAfter(_thisMonth);
    final monthName = DateFormat.MMMM(Localizations.localeOf(context).toString()).format(_month).toUpperCase();
    final title = _month.year == DateTime.now().year
        ? monthName
        : context.l10n.calendarMonthWithYear(monthName, _month.year.toString());
    // Sunday-first short weekday names.
    final weekdays = context.l10n.calendarWeekdays.split(',');

    return Container(
      padding: EdgeInsets.fromLTRB(136 * k, 121 * k, 136 * k, 130 * k),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(64 * k),
        border: Border.all(color: Colors.white.withValues(alpha: 0.7), width: 3 * k),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFB769A6).withValues(alpha: 0.1),
            offset: Offset(2.91 * k, 2.91 * k),
            blurRadius: 8.32 * k,
          ),
        ],
      ),
      child: Column(
        children: [
          SizedBox(
            height: 96 * k,
            child: Row(
              children: [
                _arrow(left: true, enabled: canGoBack, onTap: () => _shiftMonth(-1)),
                Expanded(
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    style: GoogleFonts.inter(fontSize: 60.9 * k, fontWeight: FontWeight.bold, color: _ink),
                  ),
                ),
                _arrow(left: false, enabled: true, onTap: () => _shiftMonth(1)),
              ],
            ),
          ),
          SizedBox(height: 21 * k),
          Container(
            height: 6.17 * k,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(3.1 * k),
              gradient: const LinearGradient(colors: [_blush, _periwinkle]),
            ),
          ),
          SizedBox(height: 40 * k),
          Row(
            children: [
              for (final day in weekdays)
                Expanded(
                  child: Text(
                    day,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.nunito(
                      fontSize: 48 * k,
                      fontWeight: FontWeight.w500,
                      color: _ink.withValues(alpha: 0.66),
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 22 * k),
          ..._weeks().map((week) => Row(children: [for (final day in week) Expanded(child: _dayCell(day))])),
        ],
      ),
    );
  }

  /// The visible days, Sunday-first, padded with the neighbouring months' days to whole weeks.
  List<List<DateTime>> _weeks() {
    final first = DateTime(_month.year, _month.month, 1);
    final start = first.subtract(Duration(days: first.weekday % 7));
    final daysInMonth = DateUtils.getDaysInMonth(_month.year, _month.month);
    final cellCount = ((first.weekday % 7 + daysInMonth) / 7).ceil() * 7;
    final days = [for (var i = 0; i < cellCount; i++) DateTime(start.year, start.month, start.day + i)];
    return [for (var i = 0; i < days.length; i += 7) days.sublist(i, i + 7)];
  }

  Widget _dayCell(DateTime day) {
    final k = widget.scale;
    final today = DateUtils.dateOnly(DateTime.now());
    final inMonth = day.month == _month.month;
    final enabled = inMonth && !day.isBefore(today);
    final selected = DateUtils.isSameDay(day, widget.selectedDate) && inMonth;
    final planned = inMonth && widget.plannedDates.contains(day);

    final Color color;
    if (!inMonth) {
      color = _muted.withValues(alpha: 0.5);
    } else if (!enabled) {
      color = _muted;
    } else {
      color = _ink;
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: enabled ? () => widget.onDateSelected(day) : null,
      child: SizedBox(
        height: 103.4 * k,
        child: Center(
          child: CustomPaint(
            painter: _DayMarkPainter(selected: selected, planned: planned, ringWidth: 4.3 * k),
            child: SizedBox(
              width: 99.1 * k,
              height: 94.1 * k,
              child: Center(
                child: Text(
                  '${day.day}',
                  style: GoogleFonts.nunito(
                    fontSize: 48 * k,
                    fontWeight: selected ? FontWeight.w500 : FontWeight.w200,
                    color: color,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _arrow({required bool left, required bool enabled, required VoidCallback onTap}) {
    final k = widget.scale;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: enabled ? onTap : null,
      child: SizedBox(
        width: 90 * k,
        height: 96 * k,
        child: Align(
          alignment: left ? Alignment.centerLeft : Alignment.centerRight,
          child: CustomPaint(
            size: Size(34.4 * k, 54.8 * k),
            painter: _ChevronPainter(
              left: left,
              color: _ink.withValues(alpha: enabled ? 0.66 : 0.2),
              strokeWidth: 4.05 * k,
            ),
          ),
        ),
      ),
    );
  }
}

/// Thin chevron used for the month arrows.
class _ChevronPainter extends CustomPainter {
  final bool left;
  final Color color;
  final double strokeWidth;

  _ChevronPainter({required this.left, required this.color, required this.strokeWidth});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final tip = left ? 0.0 : size.width;
    final tail = left ? size.width : 0.0;
    canvas.drawPath(
      Path()
        ..moveTo(tail, 0)
        ..lineTo(tip, size.height / 2)
        ..lineTo(tail, size.height),
      paint,
    );
  }

  @override
  bool shouldRepaint(_ChevronPainter old) =>
      old.left != left || old.color != color || old.strokeWidth != strokeWidth;
}

/// Fills the selected day and rings a day that already has a plan.
class _DayMarkPainter extends CustomPainter {
  final bool selected;
  final bool planned;
  final double ringWidth;

  _DayMarkPainter({required this.selected, required this.planned, required this.ringWidth});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    if (selected) {
      canvas.drawOval(
        rect,
        Paint()
          ..shader = const LinearGradient(
            begin: Alignment(1.13, 0.91),
            end: Alignment(-2.25, -2.27),
            stops: [0.18, 0.66],
            colors: [Color(0xFFFDEFF6), Color(0xFFC2D0F3)],
          ).createShader(rect),
      );
    }
    if (planned) {
      canvas.drawOval(
        rect.deflate(ringWidth / 2),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = ringWidth
          ..shader = const LinearGradient(colors: [Color(0xFFFDEFF6), Color(0xFFC2D0F3)]).createShader(rect),
      );
    }
  }

  @override
  bool shouldRepaint(_DayMarkPainter old) =>
      old.selected != selected || old.planned != planned || old.ringWidth != ringWidth;
}
