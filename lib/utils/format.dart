// R8: our own date formatting — no intl package.

const _months = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', //
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

String _two(int n) => n.toString().padLeft(2, '0');

/// 18 Oct
String formatDate(DateTime d) => '${d.day} ${_months[d.month - 1]}';

/// 10:00
String formatTime(DateTime d) => '${_two(d.hour)}:${_two(d.minute)}';

/// 18 Oct, 10:00
String formatDateTime(DateTime d) => '${formatDate(d)}, ${formatTime(d)}';

/// 2 d 3 h · 3 h 05 min · 12 min
String formatDuration(Duration d) => d.inDays > 0
    ? '${d.inDays} d ${d.inHours % 24} h'
    : d.inHours > 0
    ? '${d.inHours} h ${_two(d.inMinutes % 60)} min'
    : '${d.inMinutes} min';
