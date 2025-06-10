import 'package:flutter/foundation.dart';
import '../services/api_service.dart';

class PostRepository {
  static final ValueNotifier<List<Map<String, dynamic>>> posts =
      ValueNotifier([]);

  static Future<void> fetchPosts() async {
    try {
      final fetchedPosts = await ApiService.getPosts();
      posts.value = fetchedPosts;
    } catch (e) {
      print('Error fetching posts: $e');
      rethrow;
    }
  }

  static Future<void> addPost({
    required String content,
    String? imagePath,
  }) async {
    try {
      final newPost = await ApiService.createPost(
        content: content,
        imagePath: imagePath,
      );
      posts.value = [newPost, ...posts.value];
    } catch (e) {
      print('Error adding post: $e');
      rethrow;
    }
  }

  static Future<void> editPost(
    String id,
    String content,
    String? imagePath,
  ) async {
    try {
      final updatedPost = await ApiService.updatePost(
        id: id,
        content: content,
        imagePath: imagePath,
      );
      final index = posts.value.indexWhere((p) => p['id'].toString() == id);
      if (index != -1) {
        final newPosts = List<Map<String, dynamic>>.from(posts.value);
        newPosts[index] = {
          ...newPosts[index],
          ...updatedPost,
        };
        posts.value = newPosts;
      }
    } catch (e) {
      print('Error editing post: $e');
      rethrow;
    }
  }

  static Future<void> deletePost(String id) async {
    try {
      await ApiService.deletePost(id);
      posts.value = posts.value.where((p) => p['id'].toString() != id).toList();
    } catch (e) {
      print('Error deleting post: $e');
      rethrow;
    }
  }

  static Future<void> toggleLike(String id) async {
    try {
      final response = await ApiService.togglePostLike(id);
      final index = posts.value.indexWhere((p) => p['id'].toString() == id);
      if (index != -1) {
        final newPosts = List<Map<String, dynamic>>.from(posts.value);
        newPosts[index] = {
          ...newPosts[index],
          'likes_count': response['likes_count'],
          'is_liked': response['status'] == 'liked',
        };
        posts.value = newPosts;
      }
    } catch (e) {
      print('Error toggling like: $e');
      rethrow;
    }
  }

  static Future<void> addComment({
    required String postId,
    required String comment,
    String? parentId,
  }) async {
    try {
      final newComment = await ApiService.createComment(
        postId: postId,
        comment: comment,
        parentId: parentId,
      );
      final index = posts.value.indexWhere((p) => p['id'].toString() == postId);
      if (index != -1) {
        final newPosts = List<Map<String, dynamic>>.from(posts.value);
        final comments =
            List<Map<String, dynamic>>.from(newPosts[index]['comments'] ?? []);
        comments.add(newComment);
        newPosts[index] = {
          ...newPosts[index],
          'comments': comments,
          'total_comments': comments.length,
        };
        posts.value = newPosts;
      }
    } catch (e) {
      print('Error adding comment: $e');
      rethrow;
    }
  }

  static Future<void> editComment({
    required String postId,
    required String commentId,
    required String comment,
  }) async {
    try {
      final updatedComment = await ApiService.updateComment(
        id: commentId,
        comment: comment,
      );
      final postIndex =
          posts.value.indexWhere((p) => p['id'].toString() == postId);
      if (postIndex != -1) {
        final newPosts = List<Map<String, dynamic>>.from(posts.value);
        final comments = List<Map<String, dynamic>>.from(
            newPosts[postIndex]['comments'] ?? []);
        final commentIndex =
            comments.indexWhere((c) => c['id'].toString() == commentId);
        if (commentIndex != -1) {
          comments[commentIndex] = updatedComment;
          newPosts[postIndex] = {
            ...newPosts[postIndex],
            'comments': comments,
          };
          posts.value = newPosts;
        }
      }
    } catch (e) {
      print('Error editing comment: $e');
      rethrow;
    }
  }

  static Future<void> deleteComment({
    required String postId,
    required String commentId,
  }) async {
    try {
      await ApiService.deleteComment(commentId);
      final postIndex =
          posts.value.indexWhere((p) => p['id'].toString() == postId);
      if (postIndex != -1) {
        final newPosts = List<Map<String, dynamic>>.from(posts.value);
        final comments = List<Map<String, dynamic>>.from(
            newPosts[postIndex]['comments'] ?? []);
        comments.removeWhere((c) => c['id'].toString() == commentId);
        newPosts[postIndex] = {
          ...newPosts[postIndex],
          'comments': comments,
          'total_comments': comments.length,
        };
        posts.value = newPosts;
      }
    } catch (e) {
      print('Error deleting comment: $e');
      rethrow;
    }
  }

  static Future<void> toggleCommentLike({
    required String postId,
    required String commentId,
  }) async {
    try {
      final response = await ApiService.toggleCommentLike(commentId);
      final postIndex =
          posts.value.indexWhere((p) => p['id'].toString() == postId);
      if (postIndex != -1) {
        final newPosts = List<Map<String, dynamic>>.from(posts.value);
        final comments = List<Map<String, dynamic>>.from(
            newPosts[postIndex]['comments'] ?? []);
        final commentIndex =
            comments.indexWhere((c) => c['id'].toString() == commentId);
        if (commentIndex != -1) {
          comments[commentIndex] = {
            ...comments[commentIndex],
            'likes_count': response['likes_count'],
            'is_liked': response['status'] == 'liked',
          };
          newPosts[postIndex] = {
            ...newPosts[postIndex],
            'comments': comments,
          };
          posts.value = newPosts;
        }
      }
    } catch (e) {
      print('Error toggling comment like: $e');
      rethrow;
    }
  }
}
