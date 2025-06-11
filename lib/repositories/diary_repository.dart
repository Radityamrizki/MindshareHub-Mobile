import 'package:flutter/foundation.dart';
import '../services/api_service.dart';

class DiaryRepository {
  static final ValueNotifier<List<Map<String, dynamic>>> diaries =
      ValueNotifier([]);

  static Future<void> fetchDiaries() async {
    try {
      final List<Map<String, dynamic>> fetchedDiaries =
          await ApiService.getDiaries();
      // Convert ID to int if it's a string
      for (var diary in fetchedDiaries) {
        if (diary['id'] is String) {
          diary['id'] = int.parse(diary['id']);
        }
      }
      diaries.value = fetchedDiaries;
    } catch (e) {
      print('Error fetching diaries: $e');
      diaries.value = [];
    }
  }

  static Future<void> addDiary({
    required String title,
    required String content,
  }) async {
    try {
      final Map<String, dynamic> newDiary = await ApiService.createDiary(
        title: title,
        content: content,
      );
      // Convert ID to int if it's a string
      if (newDiary['id'] is String) {
        newDiary['id'] = int.parse(newDiary['id']);
      }
      diaries.value = [...diaries.value, newDiary];
    } catch (e) {
      print('Error adding diary: $e');
    }
  }

  static Future<void> editDiary({
    required String id,
    required String title,
    required String content,
  }) async {
    try {
      final updatedDiary = await ApiService.updateDiary(
        id: id,
        title: title,
        content: content,
      );
      final index = diaries.value.indexWhere((d) => d['id'].toString() == id);
      if (index != -1) {
        final newDiaries = List<Map<String, dynamic>>.from(diaries.value);
        newDiaries[index] = updatedDiary;
        diaries.value = newDiaries;
      }
    } catch (e) {
      print('Error editing diary: $e');
      rethrow;
    }
  }

  static Future<void> deleteDiary(String id) async {
    try {
      await ApiService.deleteDiary(id);
      diaries.value =
          diaries.value.where((d) => d['id'].toString() != id).toList();
    } catch (e) {
      print('Error deleting diary: $e');
    }
  }
}
