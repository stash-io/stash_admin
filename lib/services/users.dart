import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:stash_app/config.dart';
import 'package:stash_app/store.dart';

Future<List<User>> usersList(String token) async {
  var response = await http.get(
    Uri.parse('${config['backend_url']}/api/admin/users/list'),
    headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token"
    },
  );

  if (response.statusCode != 200) {
    final message = "${response.statusCode} ${response.body}";
    throw Exception(message);
  }

  final users = (jsonDecode(utf8.decode(response.bodyBytes)) as List<dynamic>)
      .map((e) => User.fromJson({...e, 'token': ''}))
      .toList();

  return users;
}

Future<void> usersDelete(String token, int id) async {
  var response = await http.delete(
    Uri.parse('${config['backend_url']}/api/admin/users/$id'),
    headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token"
    },
  );

  if (response.statusCode != 200) {
    throw Exception("${response.statusCode} ${response.body}");
  }
}

Future<void> usersBan(String token, int id) async {
  var response = await http.put(
    Uri.parse('${config['backend_url']}/api/admin/users/$id/ban'),
    headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token"
    },
  );

  if (response.statusCode != 204) {
    throw Exception("${response.statusCode} ${response.body}");
  }
}

Future<void> usersUnban(String token, int id) async {
  var response = await http.put(
    Uri.parse('${config['backend_url']}/api/admin/users/$id/unban'),
    headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token"
    },
  );

  if (response.statusCode != 204) {
    throw Exception("${response.statusCode} ${response.body}");
  }
}
