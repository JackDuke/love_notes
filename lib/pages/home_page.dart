import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
import 'package:love_notes/custom/custom_alert_dialog.dart';
import 'package:love_notes/model/firestore_user.dart';
import 'package:love_notes/model/lesson.dart';
import 'package:love_notes/services/lesson_service.dart';

// import 'package:timezone/data/latest.dart' as tz;
// import 'package:timezone/timezone.dart' as tz;

class HomePage extends StatefulWidget {
  final FirestoreUser user;
  const HomePage({
    required this.user,
    super.key
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Lista filtrata degli utenti
  List<Lesson> lessons = [];

  @override
  void initState() {
    super.initState();
    // tz.initializeTimeZones();
    fetchLessons();
  }

  void fetchLessons() async {
    final fetchedLessons = await LessonService().getLessons(widget.user.userId);

    if (mounted) {
      setState(() {
        lessons = fetchedLessons;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      // drawer: const Drawer(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Ciao ${widget.user.name}!', 
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.circular(12)
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.logout_rounded, 
                        color: Colors.white,
                      ), 
                      onPressed: () => showDialog<String>(
                        context: context,
                        builder: (BuildContext context) => CustomAlertDialog(
                          title: 'Logout',
                          message: 'Sei sicuro di voler effettuare il logout?',
                          onPressed: () {
                            if (mounted) {
                              FirebaseAuth.instance.signOut();
                              Navigator.pop(context, 'Sì');
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 101, 10, 10),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            '${lessons.length}',
                            style: const TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 120),
                  const Flexible(
                    child: Text(
                      'Lezioni usate',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 50),
              // Upcoming trainings section
              const Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    'Storico lezioni',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: lessons.length,
                itemBuilder: (context, index) {
                  // final lesson = lessons[index];
                  
                  // final romeTimeZone = tz.getLocation('Europe/Rome');
                  // final romeDate = tz.TZDateTime.from(lesson.date, romeTimeZone);
                  
                  // final formattedDate = DateFormat('dd/MM/yyyy').format(romeDate);

                  return Card(
                    color: Colors.grey[900],
                    child: ListTile(
                      title: Text('Lezione ${index + 1}', style: const TextStyle(color: Colors.white),),
                      subtitle: const Text(
                        'Data: Data',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white
                        ),
                      ),
                      trailing: const Text(
                        'Frequentata',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                          fontSize: 14
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TrainingBooking {
  final String date;
  final String status;

  TrainingBooking({ required this.date, required this.status });
}