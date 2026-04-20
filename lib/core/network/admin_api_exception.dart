class AdminApiException implements Exception {
  AdminApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => 'AdminApiException($statusCode): $message';
}
