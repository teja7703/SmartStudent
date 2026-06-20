import '../../../core/network/api_client.dart';
import '../models/career_model.dart';

class CareerRepository {
  final ApiClient _apiClient;

  CareerRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  Future<List<CareerModel>> getCareers({
    String? search,
    String? category,
    int page = 1,
    int limit = 200,
  }) async {
    final response = await _apiClient.get(
      '/api/careers',
      queryParameters: {
        if (search != null && search.isNotEmpty) 'search': search,
        if (category != null && category.isNotEmpty) 'category': category,
        'page': page,
        'limit': limit,
      },
    );

    final List data = response.data['data'] ?? [];
    return data.map((e) => CareerModel.fromJson(e)).toList();
  }

  /// Returns careers grouped by category, preserving the order in which
  /// categories first appear in the API response.
  Future<Map<String, List<CareerModel>>> getCatalog() async {
    final careers = await getCareers(limit: 500);
    final byCategory = <String, List<CareerModel>>{};
    for (final career in careers) {
      final category = career.category.trim();
      if (category.isEmpty || category.toLowerCase() == 'general') {
        continue;
      }
      byCategory.putIfAbsent(category, () => []).add(career);
    }
    return byCategory;
  }

  Future<CareerModel> getCareerById(String id) async {
    final response = await _apiClient.get('/api/careers/$id');
    return CareerModel.fromJson(response.data['data']);
  }
}
