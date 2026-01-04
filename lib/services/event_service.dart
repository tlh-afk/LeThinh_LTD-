import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';
import '../models/event.dart';

class EventService {
  Future<List<Event>> getEvents(String token) async {
    final response = await http.get(
      Uri.parse('$BASE_URL/Events'), // Endpoint to get events
      headers: {
        'Content-Type': 'application/json',
        // Gửi JWT token để xác thực bạn là ai
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      // Nếu thành công, chuyển đổi danh sách JSON thành danh sách các đối tượng Event
      final List<dynamic> responseData = json.decode(response.body);
      return responseData.map((data) => Event.fromJson(data)).toList();
    } else {
      // Nếu có lỗi, ném ra một exception
      throw Exception('Failed to load events from backend');
    }
  }

  // Hàm mới để tạo sự kiện
  Future<http.Response> createEvent({
    required String token,
    required String title,
    String? description,
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    final response = await http.post(
      Uri.parse('$BASE_URL/Events'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({
        'title': title,
        'description': description,
        // Chuyển đổi DateTime thành chuỗi String ISO 8601 để gửi đi
        'startTime': startTime.toIso8601String(),
        'endTime': endTime.toIso8601String(),
      }),
    );
    return response;
  }
}
