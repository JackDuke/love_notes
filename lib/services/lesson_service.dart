import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:love_notes/model/lesson.dart';

class LessonService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Lesson>> getLessons(String userId) async {
    final userReference = _firestore.collection('users').doc(userId);
    final querySnapshot = await _firestore
        .collection('lessons')
        .where('userId', isEqualTo: userReference)
        .orderBy('date', descending: false)
        .get();

    return querySnapshot.docs.map((doc) => Lesson.fromDocument(doc)).toList();
  }

  Future<void> decreaseLessons(String userId) async {
    final userDoc = FirebaseFirestore.instance.collection('users').doc(userId);
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(userDoc);
      if (!snapshot.exists) {
        throw Exception("User does not exist!");
      }

      final newRemainingLessons = snapshot['lessonsRemaining'] - 1;
      if (newRemainingLessons < 0) {
        throw Exception("Non ci sono abbastanza lezioni da scalare!");
      }

      transaction.update(userDoc, {'lessonsRemaining': newRemainingLessons});
    });
  }

  Future<void> createLesson(String userId, DateTime date) async {
    final lessonsCollection = FirebaseFirestore.instance.collection('lessons');
    final newLessonDoc = lessonsCollection.doc(); // New document reference

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      // Add new lesson with generated document ID
      transaction.set(newLessonDoc, {
        'lessonId': newLessonDoc.id,
        'userId': FirebaseFirestore.instance.collection('users').doc(userId),
        'date': date,
      });

      // Get current lesson number for the user
      final lessonsSnapshot = await FirebaseFirestore.instance
        .collection('lessons')
        .where('userId', isEqualTo: FirebaseFirestore.instance.collection('users').doc(userId))
        .get();

      final lessonCount = (10 - lessonsSnapshot.docs.length);

      // Update lessonsRemaining field for user
      transaction.update(FirebaseFirestore.instance.collection('users').doc(userId), {
        'lessonsRemaining': lessonCount,
      });
    });
  }

  Future<void> restoreLessons(String userId) async {
    final lessonsCollection = FirebaseFirestore.instance.collection('lessons');

    // Get all user lessons
    final lessonsSnapshot = await lessonsCollection.where('userId', isEqualTo: FirebaseFirestore.instance.collection('users').doc(userId)).get();

    // Initiate a transaction to cancel all lessons
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      for (DocumentSnapshot lessonDoc in lessonsSnapshot.docs) {
        transaction.delete(lessonDoc.reference);
      }

      // Restore lessonsRemaining to 10
      transaction.update(FirebaseFirestore.instance.collection('users').doc(userId), {'lessonsRemaining': 10});
    });
  }

  Future<int> getLessonCount(String userId) async {
    QuerySnapshot lessonSnapshot = await _firestore
        .collection('lessons')
        .where('userId', isEqualTo: _firestore.collection('users').doc(userId))
        .get();
    return lessonSnapshot.docs.length;
  }
}