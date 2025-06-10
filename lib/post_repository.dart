import 'package:flutter/material.dart';
import 'services/api_service.dart';

class PostRepository {
  static final ValueNotifier<List<Map<String, dynamic>>> posts =
      ValueNotifier([]);
  static bool isLoading = false;
  static String? error;

  static Future<void> loadPosts() async {
    try {
      isLoading = true;
      error = null;
      final fetchedPosts = await ApiService.getPosts();
      posts.value = fetchedPosts;
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
    }
  }

  static Future<void> addPost({
    required String content,
    String? imagePath,
  }) async {
    try {
      error = null;
      final newPost = await ApiService.createPost(
        content: content,
        imagePath: imagePath,
      );
      posts.value = [newPost, ...posts.value];
    } catch (e) {
      error = e.toString();
      throw Exception(e);
    }
  }

  static Future<void> addComment(String postId, String comment) async {
    try {
      error = null;
      final newComment = await ApiService.createComment(
        postId: postId,
        comment: comment,
      );

      final postIndex =
          posts.value.indexWhere((post) => post['id'].toString() == postId);
      if (postIndex != -1) {
        final post = posts.value[postIndex];
        final comments =
            List<Map<String, dynamic>>.from(post['comments'] ?? []);
        comments.add(newComment);
        posts.value = [
          ...posts.value.sublist(0, postIndex),
          {...post, 'comments': comments, 'comment_count': comments.length},
          ...posts.value.sublist(postIndex + 1),
        ];
      }
    } catch (e) {
      error = e.toString();
      throw Exception(e);
    }
  }

  static Future<void> toggleLike(String postId) async {
    try {
      error = null;
      final response = await ApiService.togglePostLike(postId);

      final postIndex =
          posts.value.indexWhere((post) => post['id'].toString() == postId);
      if (postIndex != -1) {
        final post = posts.value[postIndex];
        posts.value = [
          ...posts.value.sublist(0, postIndex),
          {
            ...post,
            'is_liked': response['is_liked'],
            'like_count': response['like_count'],
          },
          ...posts.value.sublist(postIndex + 1),
        ];
      }
    } catch (e) {
      error = e.toString();
      throw Exception(e);
    }
  }

  static Future<void> deletePost(String postId) async {
    try {
      error = null;
      await ApiService.deletePost(postId);

      final postIndex =
          posts.value.indexWhere((post) => post['id'].toString() == postId);
      if (postIndex != -1) {
        posts.value = [
          ...posts.value.sublist(0, postIndex),
          ...posts.value.sublist(postIndex + 1),
        ];
      }
    } catch (e) {
      error = e.toString();
      throw Exception(e);
    }
  }

  static Future<void> editComment(
      String postId, String commentId, String newContent) async {
    try {
      error = null;
      final updatedComment = await ApiService.updateComment(
        id: commentId,
        comment: newContent,
      );

      final postIndex =
          posts.value.indexWhere((post) => post['id'].toString() == postId);
      if (postIndex != -1) {
        final post = posts.value[postIndex];
        final comments =
            List<Map<String, dynamic>>.from(post['comments'] ?? []);
        final commentIndex = comments
            .indexWhere((comment) => comment['id'].toString() == commentId);

        if (commentIndex != -1) {
          comments[commentIndex] = updatedComment;
          posts.value = [
            ...posts.value.sublist(0, postIndex),
            {...post, 'comments': comments},
            ...posts.value.sublist(postIndex + 1),
          ];
        }
      }
    } catch (e) {
      error = e.toString();
      throw Exception(e);
    }
  }

  static Future<void> deleteComment(String postId, String commentId) async {
    try {
      error = null;
      await ApiService.deleteComment(commentId);

      final postIndex =
          posts.value.indexWhere((post) => post['id'].toString() == postId);
      if (postIndex != -1) {
        final post = posts.value[postIndex];
        final comments =
            List<Map<String, dynamic>>.from(post['comments'] ?? []);
        comments
            .removeWhere((comment) => comment['id'].toString() == commentId);

        posts.value = [
          ...posts.value.sublist(0, postIndex),
          {...post, 'comments': comments, 'comment_count': comments.length},
          ...posts.value.sublist(postIndex + 1),
        ];
      }
    } catch (e) {
      error = e.toString();
      throw Exception(e);
    }
  }

  static Future<void> editPost(String postId, String newContent, List<String> list,
      {String? imagePath}) async {
    try {
      error = null;
      final updatedPost = await ApiService.updatePost(
        id: postId,
        content: newContent,
        imagePath: imagePath,
      );

      final postIndex =
          posts.value.indexWhere((post) => post['id'].toString() == postId);
      if (postIndex != -1) {
        posts.value = [
          ...posts.value.sublist(0, postIndex),
          updatedPost,
          ...posts.value.sublist(postIndex + 1),
        ];
      }
    } catch (e) {
      error = e.toString();
      throw Exception(e);
    }
  }
}
