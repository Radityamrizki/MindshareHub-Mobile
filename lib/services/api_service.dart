import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'http://192.168.1.4:8000/api';
  static const String mainUrl = 'http://192.168.1.4:8000';
  static String? _token;

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
    if (_token != null) {
      await _getCsrfToken();
    }
  }

  static Future<void> setToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  static Future<void> clearToken() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }

  static Map<String, String> get headers {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'X-Requested-With': 'XMLHttpRequest',
      if (_token != null) 'Authorization': 'Bearer $_token',
    };
  }

  // Auth endpoints
  static Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/register');
      print('Attempting to register at URL: $url');
      print('Headers: $headers');

      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode({
          'email': email,
          'password': password,
          'password_confirmation': passwordConfirmation,
          'terms': true,
        }),
      );

      print('Response status: ${response.statusCode}');
      print('Response headers: ${response.headers}');
      print('Response body: ${response.body}');

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception(response.body);
      }
    } catch (e) {
      print('Register error details: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      // Get CSRF token before login
      await _getCsrfToken();

      final url = Uri.parse('$baseUrl/login');
      print('Attempting to login at URL: $url');
      print('Headers: $headers');

      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      print('Response status: ${response.statusCode}');
      print('Response headers: ${response.headers}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['token'] != null) {
          await setToken(data['token']);
          // Get CSRF token again after setting new token
          await _getCsrfToken();
        }
        return data;
      } else {
        throw Exception(response.body);
      }
    } catch (e) {
      print('Login error details: $e');
      rethrow;
    }
  }

  static Future<void> _getCsrfToken() async {
    try {
      print('Getting CSRF token...');
      final response = await http.get(
        Uri.parse('$mainUrl/sanctum/csrf-cookie'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          if (_token != null) 'Authorization': 'Bearer $_token',
        },
      );
      print('CSRF cookie response status: ${response.statusCode}');
      print('CSRF cookie headers: ${response.headers}');

      // Extract and store CSRF token from cookie if needed
      final cookies = response.headers['set-cookie'];
      if (cookies != null) {
        print('Received cookies: $cookies');
      }
    } catch (e) {
      print('Error getting CSRF token: $e');
      rethrow;
    }
  }

  static Future<void> logout() async {
    try {
      print('Attempting to logout with token: $_token');
      final response = await http.post(
        Uri.parse('$baseUrl/logout'),
        headers: headers,
      );

      print('Logout response status: ${response.statusCode}');
      print('Logout response body: ${response.body}');

      if (response.statusCode == 200) {
        print('Successfully logged out and destroyed token');
        await clearToken();
      } else {
        throw Exception('Failed to logout: ${response.body}');
      }
    } catch (e) {
      print('Error during logout: $e');
      // Still clear token locally even if server request fails
      await clearToken();
      rethrow;
    }
  }

  // Posts endpoints
  static Future<List<Map<String, dynamic>>> getPosts() async {
    try {
      print('Getting posts with headers: $headers');
      final response = await http.get(
        Uri.parse('$baseUrl/posts'),
        headers: headers,
      );

      print('Posts response status: ${response.statusCode}');
      print('Posts response body: ${response.body}');

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(jsonDecode(response.body));
      } else {
        throw Exception('Failed to load posts: ${response.body}');
      }
    } catch (e) {
      print('Error in getPosts: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> createPost({
    required String content,
    String? imagePath,
  }) async {
    final request = http.MultipartRequest('POST', Uri.parse('$baseUrl/posts'));
    request.headers.addAll(headers);
    request.fields['content'] = content;

    if (imagePath != null) {
      request.files.add(await http.MultipartFile.fromPath('image', imagePath));
    }

    final response = await request.send();
    final responseData = await response.stream.bytesToString();

    if (response.statusCode == 201) {
      return jsonDecode(responseData);
    } else {
      throw Exception(jsonDecode(responseData)['message']);
    }
  }

  static Future<Map<String, dynamic>> updatePost({
    required String id,
    required String content,
    String? imagePath,
  }) async {
    final request =
        http.MultipartRequest('POST', Uri.parse('$baseUrl/posts/$id'));
    request.headers.addAll(headers);
    request.fields['content'] = content;
    request.fields['_method'] = 'PUT';

    if (imagePath != null) {
      request.files.add(await http.MultipartFile.fromPath('image', imagePath));
    }

    final response = await request.send();
    final responseData = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      return jsonDecode(responseData);
    } else {
      throw Exception(jsonDecode(responseData)['message']);
    }
  }

  static Future<void> deletePost(String id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/posts/$id'),
      headers: headers,
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete post');
    }
  }

  static Future<Map<String, dynamic>> togglePostLike(String id) async {
    try {
      print('Attempting to like post $id with headers: $headers');
      final response = await http.post(
        Uri.parse('$baseUrl/posts/$id/like'),
        headers: headers,
      );

      print('Like response status: ${response.statusCode}');
      print('Like response body: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to toggle like: ${response.body}');
      }
    } catch (e) {
      print('Error in togglePostLike: $e');
      rethrow;
    }
  }

  // Comments endpoints
  static Future<List<Map<String, dynamic>>> getComments() async {
    final response = await http.get(
      Uri.parse('$baseUrl/comments'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body)['data']);
    } else {
      throw Exception('Failed to load comments');
    }
  }

  static Future<Map<String, dynamic>> createComment({
    required String postId,
    required String comment,
    String? parentId,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/comments'),
      headers: headers,
      body: jsonEncode({
        'post_id': postId,
        'comment': comment,
        if (parentId != null) 'parent_id': parentId,
      }),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to create comment');
    }
  }

  static Future<Map<String, dynamic>> updateComment({
    required String id,
    required String comment,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/comments/$id'),
      headers: headers,
      body: jsonEncode({'comment': comment}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to update comment');
    }
  }

  static Future<void> deleteComment(String id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/comments/$id'),
      headers: headers,
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete comment');
    }
  }

  static Future<Map<String, dynamic>> toggleCommentLike(String id) async {
    final response = await http.post(
      Uri.parse('$baseUrl/comments/$id/like'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to toggle comment like');
    }
  }

  // Diary endpoints
  static Future<List<Map<String, dynamic>>> getDiaries() async {
    try {
      print('Getting diaries with headers: $headers');
      final response = await http.get(
        Uri.parse('$baseUrl/diaries'),
        headers: headers,
      );

      print('Diaries response status: ${response.statusCode}');
      print('Diaries response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['data'] ?? []);
      } else {
        print('Error response headers: ${response.headers}');
        throw Exception('Failed to load diaries: ${response.body}');
      }
    } catch (e) {
      print('Error in getDiaries: $e');
      return []; // Return empty list instead of throwing
    }
  }

  static Future<Map<String, dynamic>> createDiary({
    required String title,
    required String content,
  }) async {
    try {
      print('Creating diary with headers: $headers');
      print('Diary data: title=$title, content=$content');

      final response = await http.post(
        Uri.parse('$baseUrl/diaries'),
        headers: headers,
        body: jsonEncode({
          'title': title,
          'content': content,
        }),
      );

      print('Create diary response status: ${response.statusCode}');
      print('Create diary response body: ${response.body}');

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        print('Error response headers: ${response.headers}');
        throw Exception('Failed to create diary: ${response.body}');
      }
    } catch (e) {
      print('Error in createDiary: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> updateDiary({
    required String id,
    required String title,
    required String content,
    String? imagePath,
  }) async {
    final request =
        http.MultipartRequest('POST', Uri.parse('$baseUrl/diaries/$id'));
    request.headers.addAll(headers);
    request.fields['title'] = title;
    request.fields['content'] = content;
    request.fields['_method'] = 'PUT';

    if (imagePath != null) {
      request.files.add(await http.MultipartFile.fromPath('image', imagePath));
    }

    final response = await request.send();
    final responseData = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      return jsonDecode(responseData);
    } else {
      throw Exception(jsonDecode(responseData)['message']);
    }
  }

  static Future<void> deleteDiary(String id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/diaries/$id'),
      headers: headers,
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete diary');
    }
  }

  // Search endpoints
  static Future<List<Map<String, dynamic>>> searchPosts(String query) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/posts/search?q=$query'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(jsonDecode(response.body));
      } else {
        throw Exception('Failed to search posts');
      }
    } catch (e) {
      print('Error in searchPosts: $e');
      rethrow;
    }
  }

  static Future<List<Map<String, dynamic>>> getTrendingTopics() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/trending-topics'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(jsonDecode(response.body));
      } else {
        throw Exception('Failed to load trending topics');
      }
    } catch (e) {
      print('Error in getTrendingTopics: $e');
      rethrow;
    }
  }

  // Profile endpoints
  static Future<Map<String, dynamic>> getUserProfile() async {
    try {
      final posts = await getPosts();
      if (posts.isNotEmpty) {
        // Get user data from the first post's user info
        final userData = posts[0]['user'];
        return {
          'id': userData['id'],
          'name': userData['name'],
          'username': userData['username'],
          'profile_picture': userData['profile_picture'],
        };
      }
      throw Exception('No user data available');
    } catch (e) {
      print('Error in getUserProfile: $e');
      throw Exception('Failed to load user profile');
    }
  }

  static Future<List<Map<String, dynamic>>> getUserComments() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/user/comments'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(jsonDecode(response.body));
      } else {
        throw Exception('Failed to load user comments');
      }
    } catch (e) {
      print('Error in getUserComments: $e');
      rethrow;
    }
  }

  static Future<List<Map<String, dynamic>>> getLikedPosts() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/user/liked-posts'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(jsonDecode(response.body));
      } else {
        throw Exception('Failed to load liked posts');
      }
    } catch (e) {
      print('Error in getLikedPosts: $e');
      rethrow;
    }
  }
}
