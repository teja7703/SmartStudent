import '../../../core/network/api_client.dart';
import '../models/dashboard_model.dart';

class DashboardRepository {
  final ApiClient _apiClient;

  DashboardRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  Future<DashboardModel> getDashboard() async {
    final response = await _apiClient.get('/api/dashboard');
    return DashboardModel.fromJson(response.data['data']);
  }
}
