class Event {
  final int id;
  final String title;
  final String? description;
  final DateTime startTime;
  final DateTime endTime;

  Event({
    required this.id,
    required this.title,
    this.description,
    required this.startTime,
    required this.endTime,
  });

  // Factory constructor để tạo một Event từ JSON
  // Dữ liệu JSON này được gửi về từ backend .NET của bạn
  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'] ?? 0,
      title: json['title'] ?? 'Không có tiêu đề',
      description: json['description'],
      // Chuyển đổi chuỗi String ISO 8601 từ backend thành đối tượng DateTime của Dart
      startTime: DateTime.parse(json['startTime'] ?? ''),
      endTime: DateTime.parse(json['endTime'] ?? ''),
    );
  }
}
