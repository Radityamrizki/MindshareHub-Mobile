import 'package:intl/intl.dart';

String getRelativeTime(String dateString) {
  final date = DateTime.parse(dateString);
  final now = DateTime.now();
  final difference = now.difference(date);

  if (difference.inSeconds < 60) {
    return 'Baru saja';
  } else if (difference.inMinutes < 60) {
    return '${difference.inMinutes} menit yang lalu';
  } else if (difference.inHours < 24) {
    return '${difference.inHours} jam yang lalu';
  } else if (difference.inDays < 7) {
    return '${difference.inDays} hari yang lalu';
  } else if (difference.inDays < 30) {
    return '${(difference.inDays / 7).floor()} minggu yang lalu';
  } else if (difference.inDays < 365) {
    return '${(difference.inDays / 30).floor()} bulan yang lalu';
  } else {
    return DateFormat('dd MMM yyyy').format(date);
  }
}
