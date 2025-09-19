class RegisteredCourse {
  final String code;
  final String name;
  final String classroom;
  final String subGroup;
  final String lecturer;
  final int theory; // TEO
  final int practice; // UYG
  final int credit; // KREDI
  final int ects; // AKTS

  const RegisteredCourse({
    required this.code,
    required this.name,
    required this.classroom,
    required this.subGroup,
    required this.lecturer,
    required this.theory,
    required this.practice,
    required this.credit,
    required this.ects,
  });

  String get normalizedName => _normalize(name);

  static String _normalize(String s) => s
      .toUpperCase()
      .replaceAll('İ', 'I')
      .replaceAll('Ş', 'S')
      .replaceAll('Ğ', 'G')
      .replaceAll('Ü', 'U')
      .replaceAll('Ö', 'O')
      .replaceAll('Ç', 'C')
      .replaceAll(RegExp(r"\s+"), ' ')
      .trim();
}
