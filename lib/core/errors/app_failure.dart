// Typed failures used across the data layer.
//
// The UI maps each failure to a localized message + retry action, so
// raw exceptions and platform messages never leak to the user.
sealed class AppFailure {
  const AppFailure();
}

/// No connectivity or socket-level error. Callers fall back to cache.
final class NetworkFailure extends AppFailure {
  const NetworkFailure([this.detail = '']);
  final String detail;
}

/// Server answered but the request timed out. Callers fall back to cache.
final class TimeoutFailure extends AppFailure {
  const TimeoutFailure();
}

/// HTTP status was not 200, or the body could not be parsed.
final class ServerFailure extends AppFailure {
  const ServerFailure(this.statusCode, [this.detail = '']);
  final int statusCode;
  final String detail;
}

/// Response JSON was missing required fields.
final class ParseFailure extends AppFailure {
  const ParseFailure([this.detail = '']);
  final String detail;
}

/// Location-service specific failure (permission, disabled service…).
final class LocationFailure extends AppFailure {
  const LocationFailure(this.kind, [this.detail = '']);
  final LocationFailureKind kind;
  final String detail;
}

enum LocationFailureKind {
  permissionDenied,
  permissionDeniedForever,
  serviceDisabled,
  timeout,
  unknown,
}

/// Result wrapper that avoids throwing across repository boundaries.
sealed class Result<T> {
  const Result();
}

final class Ok<T> extends Result<T> {
  const Ok(this.value);
  final T value;
}

final class Err<T> extends Result<T> {
  const Err(this.failure);
  final AppFailure failure;
}
