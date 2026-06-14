import '../../../core/network/api_client.dart';
import '../models/career_model.dart';

class CareerRepository {
  final ApiClient _apiClient;

  CareerRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  Future<List<CareerModel>> getCareers({
    String? search,
    int page = 1,
    int limit = 20,
  }) async {
    final response = await _apiClient.get(
      '/api/careers',
      queryParameters: {
        if (search != null && search.isNotEmpty) 'search': search,
        'page': page,
        'limit': limit,
      },
    );

    final List data = response.data['data'] ?? [];
    return data.map((e) => CareerModel.fromJson(e)).toList();
  }

  Future<CareerModel> getCareerById(String id) async {
    final response = await _apiClient.get('/api/careers/$id');
    return CareerModel.fromJson(response.data['data']);
  }
}
