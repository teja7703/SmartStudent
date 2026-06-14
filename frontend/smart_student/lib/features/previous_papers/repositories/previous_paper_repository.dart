import '../../../core/network/api_client.dart';
import '../models/previous_paper_model.dart';

class PreviousPaperRepository {
  final ApiClient _apiClient;

  PreviousPaperRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  Future<List<PreviousPaperModel>> getPapers({
    required String academicLevel,
    required String subject,
    int? year,
  }) async {
    final queryParams = <String, dynamic>{
      'academicLevel': academicLevel,
      'subject': subject,
    };
    if (year != null) queryParams['year'] = year;

    final response = await _apiClient.get(
      '/api/previous-papers',
      queryParameters: queryParams,
    );

    final List data = response.data['data'] ?? [];
    return data.map((e) => PreviousPaperModel.fromJson(e)).toList();
  }

  Future<PreviousPaperModel> getPaperById(String id) async {
    final response = await _apiClient.get('/api/previous-papers/$id');
    return PreviousPaperModel.fromJson(response.data['data']);
  }
}
