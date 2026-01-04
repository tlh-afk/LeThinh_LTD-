import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/event_service.dart';

class AddEventScreen extends StatefulWidget {
  const AddEventScreen({super.key});

  @override
  State<AddEventScreen> createState() => _AddEventScreenState();
}

class _AddEventScreenState extends State<AddEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final EventService _eventService = EventService();
  String _title = '';
  String _description = '';
  DateTime? _startTime;
  DateTime? _endTime;

  bool _isLoading = false;

  Future<void> _pickDate(BuildContext context, {required bool isStart}) async {
    final initialDate = (isStart ? _startTime : _endTime) ?? DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (pickedDate != null) {
      // ignore: use_build_context_synchronously
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(initialDate),
      );

      if (pickedTime != null) {
        setState(() {
          final finalDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
          if (isStart) {
            _startTime = finalDateTime;
            if (_endTime == null || _endTime!.isBefore(_startTime!)) {
              _endTime = _startTime!.add(const Duration(hours: 1));
            }
          } else {
            _endTime = finalDateTime;
          }
        });
      }
    }
  }

  void _submitForm() async { // Make this async
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      if (_startTime == null || _endTime == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vui lòng chọn thời gian bắt đầu và kết thúc')),
        );
        return;
      }
      if (_endTime!.isBefore(_startTime!)) {
         ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Thời gian kết thúc không thể trước thời gian bắt đầu')),
        );
        return;
      }
      
      setState(() {
        _isLoading = true;
      });

      final token = Provider.of<AuthProvider>(context, listen: false).token;
      if (token == null) {
        // Handle user not being authenticated
        setState(() {
          _isLoading = false;
        });
        return;
      }

      try {
        final response = await _eventService.createEvent(
          token: token,
          title: _title,
          description: _description,
          startTime: _startTime!,
          endTime: _endTime!,
        );

        if (response.statusCode == 201) { // 201 Created
          // ignore: use_build_context_synchronously
          Navigator.of(context).pop(true); // Return true to indicate success
        } else {
          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Lỗi: ${response.body}')),
          );
        }
      } catch (e) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đã có lỗi xảy ra: $e')),
        );
      }
      
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thêm Sự Kiện Mới'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Tiêu đề sự kiện'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập tiêu đề';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _title = value!;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Mô tả (không bắt buộc)'),
                  maxLines: 3,
                  onSaved: (value) {
                    _description = value ?? '';
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Bắt đầu: ${_startTime == null ? 'Chưa chọn' : DateFormat('dd/MM/yyyy HH:mm').format(_startTime!)}',
                      ),
                    ),
                    TextButton(
                      child: const Text('Chọn'),
                      onPressed: () => _pickDate(context, isStart: true),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Kết thúc: ${_endTime == null ? 'Chưa chọn' : DateFormat('dd/MM/yyyy HH:mm').format(_endTime!)}',
                      ),
                    ),
                    TextButton(
                      child: const Text('Chọn'),
                      onPressed: () => _pickDate(context, isStart: false),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                if (_isLoading)
                  const CircularProgressIndicator()
                else
                  ElevatedButton(
                    onPressed: _submitForm,
                    child: const Text('Lưu Sự Kiện'),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
