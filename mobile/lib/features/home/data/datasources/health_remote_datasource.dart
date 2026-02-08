import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';

/// Remote data source for the health check feature.
class HealthRemoteDatasource {
  final ApiClient _apiClient;

  /// Creates a HealthRemoteDatasource with the given API client.
  HealthRemoteDatasource({required ApiClient apiClient})
      : _apiClient = apiClient;

  /// Fetches the health status from the backend API.
  /// Returns a map containing status, timestamp, service, and version.
  Future<Map<String, dynamic>> fetchHealthStatus() async {
    return _apiClient.get(ApiConstants.healthEndpoint);
  }
}
