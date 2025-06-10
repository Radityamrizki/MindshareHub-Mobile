class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

// lib/utils/api_helper.dart
Future<T> handleApiRequest<T>(Future<T> Function() request) async {
  try {
    return await request();
  } on ApiException catch (e) {
    throw e;
  } catch (e) {
    throw ApiException('Terjadi kesalahan: $e');
  }
}
