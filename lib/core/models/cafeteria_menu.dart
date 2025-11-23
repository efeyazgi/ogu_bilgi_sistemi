class CafeteriaMenu {
  final String date;
  final List<String> items;

  CafeteriaMenu({
    required this.date,
    required this.items,
  });

  @override
  String toString() {
    return 'CafeteriaMenu(date: $date, items: $items)';
  }
}
