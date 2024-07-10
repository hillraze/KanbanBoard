import 'package:dio/dio.dart';

class ApiService {
  final Dio _dio = Dio();

  ApiService() {
    _dio.options.baseUrl = 'https://development.kpi-drive.ru/_api';
    _dio.options.headers['Authorization'] =
        'Bearer 48ab34464a5573519725deb5865cc74c';
  }

  Future<Map<String, dynamic>?> postIndicators(
      Map<String, dynamic> formData) async {
    try {
      final response = await _dio.post(
        '/indicators/get_mo_indicators',
        data: FormData.fromMap(formData),
      );
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>?;
      } else {
        print('Failed to load data: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }

  Future<void> saveTaskData(Map<String, dynamic> formData) async {
    try {
      final response = await _dio.post(
        '/indicators/save_indicator_instance_field',
        data: FormData.fromMap(formData),
      );
      if (response.statusCode == 200) {
        print('Task data saved successfully');
      } else {
        print('Failed to save task data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }
}
