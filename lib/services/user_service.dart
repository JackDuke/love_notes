import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:love_notes/services/lesson_service.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> fetchUsers() async {
    try {
      final querySnapshot = await _firestore
        .collection('users')
        .where('role', isNotEqualTo: 'admin')
        .orderBy('name', descending: false)
        .get();

      final users = querySnapshot.docs.map((doc) async {
        String userId = doc.id;
        int lessonCount = await LessonService().getLessonCount(userId);

        // Fetch lessons for the user
        final lessonSnapshot = await _firestore
          .collection('lessons')
          .where('userId', isEqualTo: _firestore.collection('users').doc(userId))
          .get();

        // Convert lessons to a list of maps
        final lessons = lessonSnapshot.docs.map((lessonDoc) {
          return {
            "lessonId": lessonDoc.id,
            "date": lessonDoc['date'],
            "userId": lessonDoc['userId'],
          };
        }).toList();

        await _firestore.collection('users').doc(userId).update({'lessonsRemaining': (10 - lessonCount)});

        return {
          "userId": userId,
          "name": doc['name'],
          "nickname": doc['nickname'],
          "email": doc['email'],
          "role": doc['role'],
          "lessons": lessons,
          "lessonsRemaining": (10 - lessonCount),
        };
      }).toList();

      return await Future.wait(users);
    } catch (e) {
      if (kDebugMode) {
        print('Errore nel recupero degli utenti: $e');
      }
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> searchUsers(String query, List<Map<String, dynamic>> originalUsers) async {
    if (query.isEmpty) {
      return List.from(originalUsers);
    } else {
      final suggestions = originalUsers.where((user) {
        final userName = user['name']!.toLowerCase();
        final input = query.toLowerCase();
        return userName.contains(input);
      }).toList();

      return suggestions;
    }
  }

  Future<void> renameUser(dynamic user ) async {
    try {
      await _firestore
        .collection('users')
        .doc(user['userId'])
        .update({'nickname': user['nickname']});
    } catch (e) {
      if (kDebugMode) {
        print('Errore durante l\'aggiornamento del nickname: $e');
      }
    }
  }
  
}