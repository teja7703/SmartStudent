import '../../../core/network/api_client.dart';
import '../models/study_material_model.dart';

class StudyMaterialRepository {
  final ApiClient _apiClient;

  StudyMaterialRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  Future<List<StudyMaterialModel>> getMaterials({
    required String academicLevel,
    required String subject,
    String language = 'English',
    int page = 1,
    int limit = 100,
    String? search,
  }) async {
    final queryParams = <String, dynamic>{
      'academicLevel': academicLevel,
      'subject': subject,
      'language': language,
      'page': page,
      'limit': limit,
    };
    if (search != null && search.isNotEmpty) {
      queryParams['chapter'] = search;
    }

    final response = await _apiClient.get(
      '/api/study-materials',
      queryParameters: queryParams,
    );

    final List data = response.data['data'] ?? [];
    return data.map((e) => StudyMaterialModel.fromJson(e)).toList();
  }

  /// Free-text search across study material chapters (used by global search).
  Future<List<StudyMaterialModel>> searchMaterials(
    String query, {
    int limit = 20,
  }) async {
    if (query.trim().isEmpty) return [];
    final response = await _apiClient.get(
      '/api/study-materials',
      queryParameters: {
        'search': query,
        'limit': limit,
      },
    );
    final List data = response.data['data'] ?? [];
    return data.map((e) => StudyMaterialModel.fromJson(e)).toList();
  }

  Future<StudyMaterialModel> getMaterialById(String id) async {
    final response = await _apiClient.get('/api/study-materials/$id');
    return StudyMaterialModel.fromJson(response.data['data']);
  }
}
