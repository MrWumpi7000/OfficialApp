import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:version/version.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class AuthService {
  final String _baseUrl = 'http://awesom-o.org:8000';

  Future<bool> login() async {
    final url = Uri.parse('$_baseUrl/login');
    final prefs = await SharedPreferences.getInstance();

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'email': prefs.getString('email'),
        'password': prefs.getString('password'),
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final token = data['access_token'];
      final sixDigitCode = data['6-digit_code'];
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('access_token', token);
      await prefs.setString('sixDigitCode', sixDigitCode ?? '');
      await prefs.setString('name', data['name'] ?? '');
      await prefs.setString('profile_image_data', data['profile_image_data'] ?? '');
      await prefs.setString('profile_image_type', data['profile_image_extension'] ?? '');
      return true;
    } else {
      return false;
    }
  }

  Future<bool> register() async {
    final url = Uri.parse('$_baseUrl/register');
    final prefs = await SharedPreferences.getInstance();
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'username': prefs.getString('name'),
        'email': prefs.getString('email'),
        'birthday': prefs.getString('birthday'),
        'profile_image_data': prefs.getString('profile_image_data'),
        'profile_image_extension': prefs.getString('profile_image_type'), // <-- use correct key for backend!
        'password': prefs.getString('password'),
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final token = data['access_token'];
      final sixDigitCode = data['6-digit_code'];
      await prefs.setString('access_token', token);
      await prefs.setString('sixDigitCode', sixDigitCode ?? '');
      return true;
    } else {
      // You may want to log or show the error
      debugPrint('Register failed: ${response.statusCode} ${response.body}');
      return false;
    }
  }

  Future<bool> verifyCode(String code) async {
  final prefs = await SharedPreferences.getInstance();
  final url = Uri.parse('$_baseUrl/verify-code');
  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json', 'accept': 'application/json'},
    body: jsonEncode({'email': prefs.getString("email"), 'code': code}),
  );

  if (response.statusCode == 200) {
    return true;
  } else {
    return false;
  }
}

  Future<bool> sendVerificationCode() async {
  final prefs = await SharedPreferences.getInstance();
  final url = Uri.parse('http://awesom-o.org:8000/send-verification-code');
  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json', 'accept': 'application/json'},
    body: jsonEncode({'email': prefs.getString("email")}),
  );

  if (response.statusCode == 200) {
    return true;
  } else {
    return false;
  }
}
Future<bool> sendResetCode(String email) async {
    final url = Uri.parse('$_baseUrl/reset-password');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json', 'accept': 'application/json'},
      body: jsonEncode({'email': email}),
    );
    if (response.statusCode == 200) {
      // Optionally check for success message
      return true;
    }
    return false;
  }

  Future<bool> verifyResetCode(String email, String code) async {
    final url = Uri.parse('$_baseUrl/password-reset/verify');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json', 'accept': 'application/json'},
      body: jsonEncode({'email': email, 'code': code}),
    );
    if (response.statusCode == 200) {
      // Optionally check for success message
      return true;
    }
    return false;
  }

  Future<bool> resetPassword(String email, String code, String newPassword) async {
    final url = Uri.parse('$_baseUrl/password-reset/change');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json', 'accept': 'application/json'},
      body: jsonEncode({'email': email, 'code': code, 'new_password': newPassword}),
    );
    if (response.statusCode == 200) {
      // Password reset successful
      return true;
    }
    // Optionally, you can parse the error message from the response if needed
    return false;
  }
  Future<bool> whoAmI() async {
    final url = Uri.parse('$_baseUrl/whoami');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'token': await getToken(),
      }),
    );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    final username = data['username'];
    final email = data['email'];

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', username);
    await prefs.setString('email', email);

    return true;
  } else {
    return false;
  }
}
  Future<ImageProvider> getProfilePictureBytes() async {
    final prefs = await SharedPreferences.getInstance();
    final token = await getToken();
    if (token == null) throw Exception('Token is null');

    // Try cache first
    final cached = prefs.getString('image');
    if (cached != null) {
      final bytes = base64Decode(cached);
      return MemoryImage(bytes);
    }

    // Download from backend
    final url = Uri.parse('$_baseUrl/profile_picture?token=$token');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final bytes = response.bodyBytes;
      await prefs.setString('image', base64Encode(bytes));
      return MemoryImage(bytes);
    } else {
      throw Exception('Failed to load profile picture');
    }
  }

 Future<List<Map<String, dynamic>>> searchUsers(String query) async {
  final url = Uri.parse('$_baseUrl/search_users');
  final token = await getToken(); // your token fetch logic

  final response = await http.post(
    url,
    headers: {
      'accept': 'application/json',
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'token': token,
      'query': query,
    }),
  );

  if (response.statusCode == 200) {
    final decoded = jsonDecode(response.body);
    if (decoded is List) {
      return List<Map<String, dynamic>>.from(decoded);
    } else {
      throw Exception('Invalid response format');
    }
  } else {
    throw Exception('Failed to search users: ${response.statusCode}');
  }
}

Future<String> sendFriendRequest(String friendUsername) async {
  final url = Uri.parse('$_baseUrl/add_friend');

  final token = await getToken();

  final response = await http.post(
    url,
    headers: {
      'accept': 'application/json',
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'friend_username': friendUsername,
      'token': token,
    }),
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return data['message'] ?? 'Friend request sent.';
  } else {
    throw Exception(
      'Failed to send friend request: ${response.statusCode}\n${response.body}',
    );
  }
}
  Future<bool> refreshUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    if (token == null) {
      return false;
    }

    final url = Uri.parse('$_baseUrl/whoami');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({'token': token}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await prefs.setString('username', data['username']);
      await prefs.setString('email', data['email']);
      return true;
    } else {
      return false;
    }
  }

 Future<Map<String, dynamic>> createRound({
  required String name,
  required List<Map<String, dynamic>> players,
}) async {
  final token = await getToken();
  final url = Uri.parse('$_baseUrl/rounds/create');

  final body = jsonEncode({
    'name': name,
    'token': token,
    'players': players,
  });

  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: body,
  );

  if (response.statusCode == 200) {
    print('Round Created Successfully: ${response.body}');
    return jsonDecode(response.body);
  } else {
    throw Exception('Failed to create round: ${response.statusCode}');
  }
}


Future<Map<String, dynamic>> fetchRoundScores(int roundId) async {
  final url = Uri.parse('$_baseUrl/rounds/$roundId/scores');

  final response = await http.get(
    url,
    headers: {
      'accept': 'application/json',
    },
  );

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception('Failed to fetch round scores: ${response.statusCode}');
  }
}

 Future<void> changeScores({
  required int roundId,
  required int roundPlayerId
}) async {
  final token = await getToken();
  final url = Uri.parse('$_baseUrl/points/add');

  final body = jsonEncode({
    'round_id': roundId,
    'round_player_id': roundPlayerId,
    'token': token,
  });

  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: body,
  );

  if (response.statusCode != 200) {
    throw Exception('Failed to change scores: ${response.statusCode}');
  }
}

Future<Map<String, dynamic>> getLatestGitHubReleasePair() async {
  final url = Uri.parse('https://api.github.com/repos/MrWumpi7000/officialapp/releases');
  final headers = {
    'Accept': 'application/vnd.github.v3+json',
  };
  final response = await http.get(url, headers: headers);

  if (response.statusCode != 200) {
    throw Exception('Failed to fetch releases: ${response.statusCode}');
  }

  final List<dynamic> releases = jsonDecode(response.body);

  Map<String, dynamic>? latestStable;
  Map<String, dynamic>? latestPreRelease;
  Version? latestStableVersion;
  Version? latestPreVersion;

  for (final release in releases) {
    if (release['draft'] == true) continue;

    final String tag = release['tag_name'] ?? '';
    if (!tag.startsWith('v')) continue;

    final versionStr = tag.replaceFirst('v', '').split('+').first;

    try {
      final version = Version.parse(versionStr);
      final isPreRelease = release['prerelease'] ?? false;

      if (isPreRelease) {
        if (latestPreVersion == null || version > latestPreVersion) {
          latestPreVersion = version;
          latestPreRelease = release;
        }
      } else {
        if (latestStableVersion == null || version > latestStableVersion) {
          latestStableVersion = version;
          latestStable = release;
        }
      }
    } catch (_) {
      continue; // Skip malformed versions
    }
  }

  return {
    'latestStable': latestStable,
    'latestPre': latestPreRelease,
  };
}
Future<void> toggleBetaTester({required bool value}) async {
  final prefs = await SharedPreferences.getInstance();
  final response = await http.post(
    Uri.parse('$_baseUrl/profile/change/is_beta_tester'),
    headers: {
      'accept': 'application/json',
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'token': await getToken(),
      'is_beta_tester': value,
    }),
  );

  prefs.setBool('is_beta_tester', value);
  if (response.statusCode != 200) {
      throw Exception('Failed to toggle beta tester status: ${response.statusCode}');
    }
}

Future<bool> isBetaTester() async {
  final prefs = await SharedPreferences.getInstance();
  final url = Uri.parse('$_baseUrl/profile/is_beta_tester');

  try {
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'token': await getToken(),
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final isBeta = data['is_beta_tester'] ?? false;

      // Save to shared preferences
      prefs.setBool('is_beta_tester', isBeta);

      // Return as bool
      return isBeta is bool ? isBeta : false;
    }
  } catch (e) {
    // Optionally handle/log error
  }

  // Fallback to stored value or false
  return prefs.getBool('is_beta_tester') ?? false;
}

  Future<bool> deactivateRound({
    required int roundId,
  }) async {
    final url = Uri.parse('$_baseUrl/rounds/$roundId/deactivate');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'token': await getToken()}),
    );

    if (response.statusCode == 200) {
      // Success
      print('Round deactivated successfully');
      return true;
    } else {
      // Failure
      print('Failed to deactivate round: ${response.statusCode} - ${response.body}');
      return false;
    }
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    return token != null;
  }
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}

Future<Map<String, String>> getUserData() async {
  final prefs = await SharedPreferences.getInstance();
  String? username = prefs.getString('username');
  String? email = prefs.getString('email');

  if (username == null || email == null) {
    await AuthService().whoAmI();

    username = prefs.getString('username');
    email = prefs.getString('email');
  }

  return {
    'username': username ?? '',
    'email': email ?? '',
  };
}


