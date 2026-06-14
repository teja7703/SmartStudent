import '../../../core/network/api_client.dart';
import '../models/study_material_model.dart';

class StudyMaterialRepository {
  final ApiClient _apiClient;

  StudyMaterialRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  Future<List<StudyMaterialModel>> getMaterials({
    required String academicLevel,
    required String subject,
    int page = 1,
    int limit = 20,
    String? search,
  }) async {
    final queryParams = <String, dynamic>{
      'academicLevel': academicLevel,
      'subject': subject,
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

  Future<StudyMaterialModel> getMaterialById(String id) async {
    final response = await _apiClient.get('/api/study-materials/$id');
    return StudyMaterialModel.fromJson(response.data['data']);
  }
}
