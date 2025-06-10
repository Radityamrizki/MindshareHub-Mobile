import 'package:flutter/foundation.dart';
import '../services/api_service.dart';

class DiaryRepository {
  static final ValueNotifier<List<Map<String, dynamic>>> diaries =
      ValueNotifier([]);

  static Future<void> fetchDiaries() async {
    try {
      final fetchedDiaries = await ApiService.getDiaries();
      diaries.value = fetchedDiaries;
    } catch (e) {
      print('Error fetching diaries: $e');
      rethrow;
    }
  }

  static Future<void> addDiary({
    required String title,
    required String content,
  }) async {
    try {
      final newDiary = await ApiService.createDiary(
        title: title,
        content: content,
      );
      diaries.value = [newDiary, ...diaries.value];
    } catch (e) {
      print('Error adding diary: $e');
      rethrow;
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
      rethrow;
    }
  }
}
