import '../../../core/network/api_client.dart';
import '../models/story_model.dart';

class StoryRepository {
  final ApiClient _apiClient;

  StoryRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  Future<List<StoryModel>> getStories({
    String? search,
    String? category,
    int page = 1,
    int limit = 20,
  }) async {
    final response = await _apiClient.get(
      '/api/stories',
      queryParameters: {
        if (search != null && search.isNotEmpty) 'search': search,
        if (category != null && category.isNotEmpty) 'category': category,
        'page': page,
        'limit': limit,
      },
    );

    final List data = response.data['data'] ?? [];
    return data.map((e) => StoryModel.fromJson(e)).toList();
  }

  Future<StoryModel> getStoryById(String id) async {
    final response = await _apiClient.get('/api/stories/$id');
    return StoryModel.fromJson(response.data['data']);
  }
}
