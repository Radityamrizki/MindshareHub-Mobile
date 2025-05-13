import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

// Repository untuk mengelola data post dan komentar
class PostRepository {
  // ValueNotifier untuk menyimpan daftar post
  static final ValueNotifier<List<Map<String, dynamic>>> posts = ValueNotifier([
    {
      'name': 'User 766',
      'username': '@user766',
      'avatar': 'assets/images/Profile.png',
      'time': '12h',
      'content': 'alhamdulillah yah',
      'media': <String>[],
      'likeCount': 28,
      'commentCount': 5,
      'shareCount': 21,
      'likedBy': 'user123 and user333',
      'isLiked': true,
      'showThread': false,
      'comments': [
        {
          'name': 'User 5234',
          'username': '@user5234',
          'avatar': 'assets/images/Profile2.png',
          'content': 'Mantap!',
          'time': '1h',
        },
      ],
    },
    {
      'name': 'User 5234',
      'username': '@user5234',
      'avatar': 'assets/images/Profile2.png',
      'time': '3h',
      'content': 'Cara agar kuat mental gimana y?',
      'media': <String>[],
      'likeCount': 46,
      'commentCount': 18,
      'shareCount': 363,
      'likedBy': 'User43543',
      'isLiked': true,
      'showThread': false,
      'comments': [],
    },
    {
      'name': 'User 2352',
      'username': '@user2352',
      'avatar': 'assets/images/Profile.png',
      'time': '10h',
      'content': 'kalian pernah ga takut kehilangan barang yg diimpikan?',
      'media': <String>[],
      'likeCount': 1906,
      'commentCount': 1249,
      'shareCount': 7461,
      'likedBy': 'User43543',
      'isLiked': true,
      'showThread': false,
      'comments': [],
    },
    {
      'name': 'User 24356',
      'username': '@user24356',
      'avatar': 'assets/images/Profile2.png',
      'time': '3h',
      'content': 'pertama kali pake mind min',
      'media': <String>[],
      'likeCount': 46,
      'commentCount': 18,
      'shareCount': 363,
      'likedBy': 'User43543',
      'isLiked': true,
      'showThread': false,
      'comments': [],
    },
  ]);

  // Fungsi untuk menambah post baru
  static void addPost({
    required String content,
    required String avatar,
    required String name,
    required String username,
    required List<String> media,
  }) {
    posts.value = [
      {
        'name': name,
        'username': username,
        'avatar': avatar,
        'time': 'now',
        'content': content,
        'media': media,
        'likeCount': 0,
        'commentCount': 0,
        'shareCount': 0,
        'likedBy': '',
        'isLiked': false,
        'showThread': false,
        'comments': [],
      },
      ...posts.value,
    ];
  }

  // Fungsi untuk menambah komentar baru ke dalam post
  static void addComment(int postIndex, Map<String, String> comment) {
    final post = posts.value[postIndex];
    final comments = List<Map<String, String>>.from(post['comments'] ?? []);
    comments.add(comment);
    posts.value = [
      ...posts.value.sublist(0, postIndex),
      {...post, 'comments': comments, 'commentCount': comments.length},
      ...posts.value.sublist(postIndex + 1),
    ];
  }

  // Fungsi untuk mengedit komentar yang sudah ada
  static void editComment(
      int postIndex, Map<String, String> oldComment, String newContent) {
    final post = posts.value[postIndex];
    final comments = List<Map<String, String>>.from(post['comments'] ?? []);
    final index = comments.indexWhere((c) =>
        c['username'] == oldComment['username'] &&
        c['content'] == oldComment['content']);
    if (index != -1) {
      comments[index]['content'] = newContent;
      posts.value = [
        ...posts.value.sublist(0, postIndex),
        {...post, 'comments': comments, 'commentCount': comments.length},
        ...posts.value.sublist(postIndex + 1),
      ];
    }
  }

  // Fungsi untuk menghapus komentar
  static void deleteComment(int postIndex, Map<String, String> comment) {
    final post = posts.value[postIndex];
    final comments = List<Map<String, String>>.from(post['comments'] ?? []);
    comments.removeWhere((c) =>
        c['username'] == comment['username'] &&
        c['content'] == comment['content']);
    posts.value = [
      ...posts.value.sublist(0, postIndex),
      {...post, 'comments': comments, 'commentCount': comments.length},
      ...posts.value.sublist(postIndex + 1),
    ];
  }

  // Fungsi untuk menambah like pada post
  static void toggleLike(int index) {
    final post = posts.value[index];
    final isLiked = post['isLiked'] as bool;
    final likeCount = post['likeCount'] as int;
    posts.value = [
      ...posts.value.sublist(0, index),
      {
        ...post,
        'isLiked': !isLiked,
        'likeCount': isLiked ? likeCount - 1 : likeCount + 1,
      },
      ...posts.value.sublist(index + 1),
    ];
  }

  static void deletePost(int index) {
    posts.value = [
      ...posts.value.sublist(0, index),
      ...posts.value.sublist(index + 1),
    ];
  }

  static void editPost(int index, String newContent, List<String> newMedia) {
    final post = posts.value[index];
    posts.value = [
      ...posts.value.sublist(0, index),
      {...post, 'content': newContent, 'media': newMedia},
      ...posts.value.sublist(index + 1),
    ];
  }
}
