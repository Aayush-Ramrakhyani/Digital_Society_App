import 'dart:convert';
import 'package:http/http.dart' as http;
import 'models.dart';

class ApiService {
  // Android emulator : http://10.0.2.2:8000
  // Flutter Web / physical device : http://localhost:8000  (or your PC's local IP)
  static const String baseUrl = 'http://localhost:8000';

  static Future<T> _get<T>(String path, T Function(dynamic) parser) async {
    final res = await http.get(Uri.parse('$baseUrl$path'));
    if (res.statusCode == 200) return parser(jsonDecode(res.body));
    throw Exception('GET $path failed (${res.statusCode})');
  }

  static Future<Map<String, dynamic>> _post(
      String path, Map<String, dynamic> body) async {
    final res = await http.post(
      Uri.parse('$baseUrl$path'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    if (res.statusCode == 200) return jsonDecode(res.body) as Map<String, dynamic>;
    final err = jsonDecode(res.body);
    throw Exception(err['detail'] ?? 'POST $path failed');
  }

  static Future<Map<String, dynamic>> _put(
      String path, Map<String, dynamic> body) async {
    final res = await http.put(
      Uri.parse('$baseUrl$path'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    if (res.statusCode == 200) return jsonDecode(res.body) as Map<String, dynamic>;
    throw Exception('PUT $path failed (${res.statusCode})');
  }

  static Future<void> _delete(String path) async {
    await http.delete(Uri.parse('$baseUrl$path'));
  }

  // ── Members ────────────────────────────────────────────────────────────────

  static Future<List<MemberCredential>> getMembers() => _get(
        '/members',
        (d) => (d as List).map((e) => MemberCredential.fromJson(e)).toList(),
      );

  static Future<List<MemberWithFamily>> getAllDetails() => _get(
        '/all_details',
        (d) => (d as List).map((e) => MemberWithFamily.fromJson(e)).toList(),
      );

  static Future<void> addMember(Map<String, dynamic> data) =>
      _post('/members', data);

  static Future<void> addFamilyMember(Map<String, dynamic> data) =>
      _post('/family_members', data);

  // ── Notices ────────────────────────────────────────────────────────────────

  static Future<List<Notice>> getNotices() => _get(
        '/notices',
        (d) => (d as List).map((e) => Notice.fromJson(e)).toList(),
      );

  static Future<void> addNotice(Map<String, dynamic> data) =>
      _post('/notices', data);

  static Future<void> deleteNotice(int id) => _delete('/notices/$id');

  // ── Complaints ─────────────────────────────────────────────────────────────

  static Future<List<Complaint>> getComplaints() => _get(
        '/complaints',
        (d) => (d as List).map((e) => Complaint.fromJson(e)).toList(),
      );

  static Future<List<Complaint>> getMemberComplaints(String houseno) => _get(
        '/complaints/$houseno',
        (d) => (d as List).map((e) => Complaint.fromJson(e)).toList(),
      );

  static Future<void> addComplaint(Map<String, dynamic> data) =>
      _post('/complaints', data);

  static Future<void> updateComplaint(int id, Map<String, dynamic> data) =>
      _put('/complaints/$id', data);

  // ── Maintenance ────────────────────────────────────────────────────────────

  static Future<List<Maintenance>> getMaintenance() => _get(
        '/maintenance',
        (d) => (d as List).map((e) => Maintenance.fromJson(e)).toList(),
      );

  static Future<List<Maintenance>> getMemberMaintenance(String houseno) => _get(
        '/maintenance/$houseno',
        (d) => (d as List).map((e) => Maintenance.fromJson(e)).toList(),
      );

  static Future<void> addMaintenance(Map<String, dynamic> data) =>
      _post('/maintenance', data);

  static Future<void> updateMaintenance(int id, Map<String, dynamic> data) =>
      _put('/maintenance/$id', data);

  // ── Stats ──────────────────────────────────────────────────────────────────

  static Future<DashboardStats> getStats() => _get(
        '/stats',
        (d) => DashboardStats.fromJson(d as Map<String, dynamic>),
      );
}
