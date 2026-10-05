import 'package:flutter/material.dart' show TimeOfDay;

/// Shortest date the planner accepts, in minutes.
const int minDateDurationMinutes = 60;

/// Minutes from [start] to [end]. An [end] earlier than [start] is on the next day;
/// an [end] equal to [start] gives 0.
int dateDurationMinutes(TimeOfDay start, TimeOfDay end) {
  final diff = _minutesOfDay(end) - _minutesOfDay(start);
  return diff < 0 ? diff + Duration.minutesPerDay : diff;
}

/// Whether [end] falls on the day after [start].
bool endsNextDay(TimeOfDay start, TimeOfDay end) => _minutesOfDay(end) < _minutesOfDay(start);

/// Whether the span from [start] to [end] is long enough to plan a date.
bool isValidDateSpan(TimeOfDay start, TimeOfDay end) =>
    dateDurationMinutes(start, end) >= minDateDurationMinutes;

/// The time [minutes] after [time], wrapping past midnight.
TimeOfDay addMinutes(TimeOfDay time, int minutes) {
  final total = (_minutesOfDay(time) + minutes) % Duration.minutesPerDay;
  return TimeOfDay(hour: total ~/ 60, minute: total % 60);
}

int _minutesOfDay(TimeOfDay t) => t.hour * 60 + t.minute;
