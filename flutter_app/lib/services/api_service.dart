import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  final String baseUrl = "http://127.0.0.1:8000";
  final _storage = const FlutterSecureStorage();

  Future<String?> _getToken() async => await _storage.read(key: 'token');
  Future<void> _saveToken(String token) async => await _storage.write(key: 'token', value: token);

  Future<Map<String, String>> _headers() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<Map<String, dynamic>> login(String u, String p) async {
    final res = await http.post(Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': u, 'password': p}));
    final data = jsonDecode(res.body);
    if (data['access_token'] != null) await _saveToken(data['access_token']);
    return data;
  }

  Future<List<dynamic>> getAgents() async {
    final h = await _headers();
    return jsonDecode((await http.get(Uri.parse('$baseUrl/agents'), headers: h)).body);
  }

  Future<Map<String, dynamic>> invokeAgent(String type, String prompt) async {
    final h = await _headers();
    final res = await http.post(Uri.parse('$baseUrl/agents/invoke'), headers: h,
        body: jsonEncode({'agent_type': type, 'prompt': prompt}));
    return jsonDecode(res.body);
  }

  Future<Map<String, dynamic>> sendChat(String msg, {String model = "qwen3:8b"}) async {
    final h = await _headers();
    final res = await http.post(Uri.parse('$baseUrl/chat'), headers: h,
        body: jsonEncode({'content': msg, 'model': model}));
    return jsonDecode(res.body);
  }

  Future<Map<String, dynamic>> execTerminal(String cmd) async {
    final h = await _headers();
    final res = await http.post(Uri.parse('$baseUrl/terminal/exec'), headers: h,
        body: jsonEncode({'command': cmd}));
    return jsonDecode(res.body);
  }

  Future<Map<String, dynamic>> getOllamaStatus() async {
    return jsonDecode((await http.get(Uri.parse('$baseUrl/ollama/status'))).body);
  }

  Future<List<dynamic>> getOllamaModels() async {
    return jsonDecode((await http.get(Uri.parse('$baseUrl/ollama/models'))).body);
  }

  Future<void> pullOllamaModel(String model) async {
    final h = await _headers();
    await http.post(Uri.parse('$baseUrl/ollama/pull'), headers: h, body: jsonEncode({'model': model}));
  }

  Future<Map<String, dynamic>> getDashboard() async {
    final h = await _headers();
    return jsonDecode((await http.get(Uri.parse('$baseUrl/dashboard/stats'), headers: h)).body);
  }

  Future<List<dynamic>> getWorkflows() async {
    final h = await _headers();
    return jsonDecode((await http.get(Uri.parse('$baseUrl/workflows'), headers: h)).body);
  }

  Future<Map<String, dynamic>> createWorkflow(Map<String, dynamic> def) async {
    final h = await _headers();
    final res = await http.post(Uri.parse('$baseUrl/workflows'), headers: h, body: jsonEncode(def));
    return jsonDecode(res.body);
  }

  Future<Map<String, dynamic>> runWorkflow(int id) async {
    final h = await _headers();
    final res = await http.post(Uri.parse('$baseUrl/workflows/$id/run'), headers: h);
    return jsonDecode(res.body);
  }

  Future<Map<String, dynamic>> ingestKnowledge(String content, {String title = "", int kbId = 1}) async {
    final h = await _headers();
    final res = await http.post(Uri.parse('$baseUrl/knowledge/ingest'), headers: h,
        body: jsonEncode({'content': content, 'title': title, 'kb_id': kbId}));
    return jsonDecode(res.body);
  }

  Future<List<dynamic>> searchKnowledge(String query, {int kbId = 1}) async {
    final h = await _headers();
    final res = await http.post(Uri.parse('$baseUrl/knowledge/search'), headers: h,
        body: jsonEncode({'query': query, 'knowledge_base_id': kbId}));
    return jsonDecode(res.body)['results'] ?? [];
  }

  Future<Map<String, dynamic>> uploadDocument(File file, int kbId) async {
    final token = await _getToken();
    final req = http.MultipartRequest('POST', Uri.parse('$baseUrl/knowledge/upload?kb_id=$kbId'));
    if (token != null) req.headers['Authorization'] = 'Bearer $token';
    req.files.add(await http.MultipartFile.fromPath('file', file.path));
    final res = await req.send();
    return jsonDecode(await res.stream.bytesToString());
  }
}
