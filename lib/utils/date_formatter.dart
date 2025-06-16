String getRelativeTime(String dateString) {
  final date = DateTime.parse(dateString);
  final now = DateTime.now();
  final difference = now.difference(date);

  if (difference.inDays > 365) {
    return '${(difference.inDays / 365).floor()} tahun yang lalu';
  } else if (difference.inDays > 30) {
    return '${(difference.inDays / 30).floor()} bulan yang lalu';
  } else if (difference.inDays > 0) {
    return '${difference.inDays} hari yang lalu';
  } else if (difference.inHours > 0) {
    return '${difference.inHours} jam yang lalu';
  } else if (difference.inMinutes > 0) {
    return '${difference.inMinutes} menit yang lalu';
  } else {
    return 'Baru saja';
  }
}
