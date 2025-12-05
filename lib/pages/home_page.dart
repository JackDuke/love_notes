import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:love_notes/model/app_user.dart';
import '../services/user_repository.dart';
import 'package:intl/intl.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final authUser = FirebaseAuth.instance.currentUser!;
    final repo = UserRepository();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            tooltip: 'Logout',
            onPressed: () => FirebaseAuth.instance.signOut(),
            icon: const Icon(Icons.logout),
          )
        ],
      ),
      body: StreamBuilder<AppUser?>(
        stream: repo.watchUser(authUser.uid),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final user = snap.data;

          // Se per qualche motivo il doc non esiste ancora
          if (user == null) {
            return Center(
              child: Text('Ciao ${authUser.email ?? authUser.uid} 💛'),
            );
          }

          final name = (user.displayName?.trim().isNotEmpty ?? false)
              ? user.displayName!.trim()
              : (user.email ?? user.uid);

          final lastLogin = user.lastLoginAt != null
              ? DateFormat('dd/MM/yyyy HH:mm').format(user.lastLoginAt!)
              : null;

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        // CircleAvatar(
                        //   radius: 22,
                        //   backgroundImage: (user.photoUrl != null &&
                        //           user.photoUrl!.isNotEmpty)
                        //       ? NetworkImage(user.photoUrl!)
                        //       : null,
                        //   child: (user.photoUrl == null ||
                        //           user.photoUrl!.isEmpty)
                        //       ? const Icon(Icons.person)
                        //       : null,
                        // ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Ciao $name 💛',
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700)),
                              const SizedBox(height: 6),
                              Text(user.email ?? '',
                                  style: const TextStyle(fontSize: 13)),
                              if (lastLogin != null) ...[
                                const SizedBox(height: 4),
                                Text('Ultimo accesso: $lastLogin',
                                    style: const TextStyle(fontSize: 12)),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'Qui poi mettiamo la lista delle note condivise 🙂',
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
