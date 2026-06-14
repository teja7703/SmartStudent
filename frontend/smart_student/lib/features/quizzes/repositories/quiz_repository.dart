import '../../../core/network/api_client.dart';
import '../models/quiz_model.dart';

class QuizRepository {
  final ApiClient _apiClient;

  QuizRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  Future<List<QuizModel>> getQuizzes({
    String? classLevel,
    String? category,
    String? difficulty,
    int page = 1,
    int limit = 20,
  }) async {
    final response = await _apiClient.get(
      '/api/quizzes',
      queryParameters: {
        if (classLevel != null && classLevel.isNotEmpty) 'classLevel': classLevel,
        if (category != null && category.isNotEmpty) 'category': category,
        if (difficulty != null && difficulty.isNotEmpty) 'difficulty': difficulty,
        'page': page,
        'limit': limit,
      },
    );

    final List data = response.data['data'] ?? [];
    return data.map((e) => QuizModel.fromJson(e)).toList();
  }

  Future<QuizModel> getQuizById(String id) async {
    final response = await _apiClient.get('/api/quizzes/$id');
    return QuizModel.fromJson(response.data['data']);
  }
}
