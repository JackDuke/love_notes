import 'package:cloud_firestore/cloud_firestore.dart';

class Lesson {
  final String lessonId;
  final DocumentReference userId;
  final DateTime date;

  Lesson({
    required this.lessonId,
    required this.userId,
    required this.date,
  });

  factory Lesson.fromDocument(DocumentSnapshot doc) {
    return Lesson(
      lessonId: doc['lessonId'],
      userId: doc['userId'],
      date: (doc['date'] as Timestamp).toDate(),
    );
  }

  @override
  String toString() {
    return 'Lesson {userId: $userId, lessonId: $lessonId, date: $date}';
  }
}