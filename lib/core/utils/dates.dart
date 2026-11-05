String dateKey(DateTime date) {
  return '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}

DateTime parseDateKey(String key) {
  final parts = key.split('-');
  if (parts.length != 3) return DateTime.now();
  final year = int.tryParse(parts[0]);
  final month = int.tryParse(parts[1]);
  final day = int.tryParse(parts[2]);
  if (year == null || month == null || day == null) return DateTime.now();
  return DateTime(year, month, day);
}

const List<String> _monthsEn = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
const List<String> _monthsUr = ['جنوری', 'فروری', 'مارچ', 'اپریل', 'مئی', 'جون', 'جولائی', 'اگست', 'ستمبر', 'اکتوبر', 'نومبر', 'دسمبر'];

String formatDateLabel(DateTime date, {bool urdu = false}) {
  final months = urdu ? _monthsUr : _monthsEn;
  final index = date.month - 1;
  final month = (index >= 0 && index < months.length) ? months[index] : '';
  return '${date.day} $month ${date.year}';
}
