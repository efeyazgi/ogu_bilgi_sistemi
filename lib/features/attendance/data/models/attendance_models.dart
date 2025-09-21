class WeeklySlot {
  final int dayOfWeek; // 1=Mon ... 7=Sun
  final String time;   // '09:00'
  final String classroom;
  const WeeklySlot({required this.dayOfWeek, required this.time, required this.classroom});

  Map<String, dynamic> toJson() => {
    'dayOfWeek': dayOfWeek,
    'time': time,
    'classroom': classroom,
  };
  factory WeeklySlot.fromJson(Map<String, dynamic> j) => WeeklySlot(
    dayOfWeek: j['dayOfWeek'] as int,
    time: j['time'] as String,
    classroom: j['classroom'] as String,
  );
}

class AttendanceCourse {
  final String code;
  final String name;
  final double thresholdRatio; // default 0.30
  final List<WeeklySlot> weeklySlots;
  const AttendanceCourse({
    required this.code,
    required this.name,
    required this.thresholdRatio,
    required this.weeklySlots,
  });

  AttendanceCourse copyWith({double? thresholdRatio}) => AttendanceCourse(
    code: code,
    name: name,
    thresholdRatio: thresholdRatio ?? this.thresholdRatio,
    weeklySlots: weeklySlots,
  );

  Map<String, dynamic> toJson() => {
    'code': code,
    'name': name,
    'thresholdRatio': thresholdRatio,
    'weeklySlots': weeklySlots.map((e) => e.toJson()).toList(),
  };
  factory AttendanceCourse.fromJson(Map<String, dynamic> j) => AttendanceCourse(
    code: j['code'] as String,
    name: j['name'] as String,
    thresholdRatio: (j['thresholdRatio'] as num).toDouble(),
    weeklySlots: (j['weeklySlots'] as List).map((e) => WeeklySlot.fromJson(Map<String, dynamic>.from(e))).toList(),
  );
}

class AttendanceEntry {
  final String courseCode;
  final String date; // yyyy-MM-dd
  final String time; // '09:00'
  final int durationSlots; // default 1
  final String? note;
  const AttendanceEntry({
    required this.courseCode,
    required this.date,
    required this.time,
    this.durationSlots = 1,
    this.note,
  });

  Map<String, dynamic> toJson() => {
    'courseCode': courseCode,
    'date': date,
    'time': time,
    'durationSlots': durationSlots,
    'note': note,
  };
  factory AttendanceEntry.fromJson(Map<String, dynamic> j) => AttendanceEntry(
    courseCode: j['courseCode'] as String,
    date: j['date'] as String,
    time: j['time'] as String,
    durationSlots: (j['durationSlots'] ?? 1) as int,
    note: j['note'] as String?,
  );
}