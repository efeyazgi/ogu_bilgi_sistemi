class Course {
  final String name;
  final String shortName;
  final String classroom;
  final String day;
  final String time;

  Course({
    required this.name,
    required this.shortName,
    required this.classroom,
    required this.day,
    required this.time,
  });

  @override
  String toString() {
    return 'Course(name: $name, shortName: $shortName, classroom: $classroom, day: $day, time: $time)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Course &&
        other.name == name &&
        other.shortName == shortName &&
        other.classroom == classroom &&
        other.day == day &&
        other.time == time;
  }

  @override
  int get hashCode {
    return name.hashCode ^
        shortName.hashCode ^
        classroom.hashCode ^
        day.hashCode ^
        time.hashCode;
  }
}
