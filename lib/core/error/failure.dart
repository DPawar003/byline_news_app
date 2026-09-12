sealed class Failure {
  final String message;
  const Failure(this.message);
}

class NoInternetFailure extends Failure {
  const NoInternetFailure([super.message = "No internet connection. Please check your network."]);
}

class TimeoutFailure extends Failure {
  const TimeoutFailure([super.message = "The request timed out. Please try again."]);
}

class InvalidDataFailure extends Failure {
  const InvalidDataFailure([super.message = "Received invalid or malformed data from the server."]);
}

class UnknownFailure extends Failure {
  const UnknownFailure([super.message = "An unexpected error occurred. Please try again."]);
}
