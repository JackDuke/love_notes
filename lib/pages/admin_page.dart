import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
// import 'package:intl/intl.dart';
import 'package:love_notes/common/loading_dialog.dart';
import 'package:love_notes/custom/custom_alert_dialog.dart';
import 'package:love_notes/custom/custom_tile_action.dart';
import 'package:love_notes/custom/nickname_alert_dialog.dart';
import 'package:love_notes/model/firestore_user.dart';
import 'package:love_notes/pages/new_user_page.dart';
import 'package:love_notes/services/lesson_service.dart';
import 'package:love_notes/services/user_service.dart';

// import 'package:timezone/timezone.dart' as tz;
// import 'package:timezone/data/latest.dart' as tz;

class AdminPage extends StatefulWidget {
  final FirestoreUser user;
  const AdminPage({super.key, required this.user});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final _key = GlobalKey<ExpandableFabState>();

  final TextEditingController controller = TextEditingController();
  final TextEditingController editingController = TextEditingController();
  // Lista originale degli utenti
  List<Map<String, dynamic>> originalUsers = [];
  // Lista filtrata degli utenti
  List<Map<String, dynamic>> users = [];
  // Elenco di utenti selezionati
  Set<String> selectedUsers = {};

  int? _expandedIndex;

  @override
  void initState() {
    super.initState();
    // tz.initializeTimeZones();
    fetchUsers();
    controller.addListener(() {
      searchUser(controller.text);
    });
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
    editingController.dispose();
  }

  void searchUser(String query) async {
    try {
      final searchResults =
          await UserService().searchUsers(query, originalUsers);
      if (mounted) {
        setState(() {
          users = searchResults;
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Errore nella ricerca degli utenti: $e');
      }
    }
  }

  Future<void> fetchUsers() async {
    try {
      final fetchedUsers = await UserService().fetchUsers();
      if (mounted) {
        setState(() {
          originalUsers = fetchedUsers;
          users = fetchedUsers;
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Errore nel recupero degli utenti: $e');
      }
    }
  }

  void _openVoidActionBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.8,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          builder: (ctx, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              child: const Wrap(
                children: [
                  NewUserPage(),
                ],
              ),
            );
          },
        );
      }
    );
  }

  void _decreaseLessons(dynamic userIds) async {
    try {
      LoadingDialog.showLoadingDialog(context, "Sto scalando una lezione...");

      if (userIds is String) {
        await LessonService().createLesson(userIds, DateTime.now());
        await LessonService().decreaseLessons(userIds);
      } else if (userIds is List<String> || userIds is Set<String>) {
        for (String userId in userIds) {
          await LessonService().createLesson(userId, DateTime.now());
          await LessonService().decreaseLessons(userId);
        }
      } else {
        throw ArgumentError(
            "Il parametro userIds deve essere una stringa o una lista/set di stringhe.");
      }

      if (mounted) {
        setState(() {
          fetchUsers();
        });
      }
    } catch (e) {
      throw Error();
    } finally {
      if (mounted) {
        LoadingDialog.hideLoadingDialog(context);
      }
    }
  }

  void _restoreLessons(dynamic userIds) async {
    try {
      LoadingDialog.showLoadingDialog(context, "Sto ripristinando...");

      if (userIds is String) {
        await LessonService().restoreLessons(userIds);
      } else if (userIds is List<String> || userIds is Set<String>) {
        for (String userId in userIds) {
          await LessonService().restoreLessons(userId);
        }
      } else {
        throw ArgumentError(
            "Il parametro userIds deve essere una stringa o una lista/set di stringhe.");
      }

      if (mounted) {
        setState(() {
          fetchUsers();
        });
      }
    } catch (e) {
      throw Error();
    } finally {
      if (mounted) {
        LoadingDialog.hideLoadingDialog(context);
      }
    }
  }

  void _renameUser(dynamic user) async {
    await UserService().renameUser(user);
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SlidableAutoCloseBehavior(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Utenti',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                          color: Colors.grey[900],
                          borderRadius: BorderRadius.circular(12)),
                      child: IconButton(
                        icon: const Icon(
                          Icons.logout_rounded,
                          color: Colors.white,
                        ),
                        onPressed: () => showDialog<String>(
                          context: context,
                          builder: (BuildContext context) => CustomAlertDialog(
                            title: 'Logout',
                            message:
                                'Sei sicuro di voler effettuare il logout?',
                            onPressed: () {
                              FirebaseAuth.instance.signOut();
                              Navigator.pop(context, 'Sì');
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 50),
                Container(
                  margin: const EdgeInsets.all(12),
                  padding: const EdgeInsets.all(12),
                  child: TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search, color: Colors.white,),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.white),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      hintText: "Cerca",
                      hintStyle: const TextStyle(color: Colors.white60)),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                if (selectedUsers.isNotEmpty)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[800],
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () => showDialog<String>(
                          context: context,
                          builder: (BuildContext context) => CustomAlertDialog(
                            title: 'Scala',
                            message:
                                'Scalare una lezione agli utenti selezionati?',
                            onPressed: () {
                              _decreaseLessons(selectedUsers);
                              Navigator.pop(context, 'Sì');
                            },
                          ),
                        ),
                        child: const Icon(Icons.plus_one, color: Colors.white,),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[800],
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () => showDialog<String>(
                          context: context,
                          builder: (BuildContext context) => CustomAlertDialog(
                            title: 'Ripristina',
                            message:
                                'Ripristinare le lezioni degli utenti selezionati?',
                            onPressed: () {
                              _restoreLessons(selectedUsers);
                              Navigator.pop(context, 'Sì');
                            },
                          ),
                        ),
                        child: const Icon(Icons.restart_alt, color: Colors.white,),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[800],
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          setState(() {
                            for (var user in users) {
                              selectedUsers.add(user['userId']);
                            }
                          });
                        },
                        child: const Icon(Icons.select_all, color: Colors.white,),
                      ),
                      IconButton(
                        icon: const Icon(Icons.cancel, color: Colors.white,),
                        onPressed: () {
                          setState(() {
                            selectedUsers.clear();
                          });
                        },
                      ),
                    ],
                  ),
                Expanded(
                  child: ListView.builder(
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      final user = users[index];
                      final isSelected = selectedUsers.contains(user['userId']);
                      bool isExpanded = _expandedIndex == index;

                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10.0),
                          child: Material(
                            color: isSelected
                                ? Colors.blue.withOpacity(0.5)
                                : Colors.grey[900],
                            child: InkWell(
                              splashColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              onLongPress: () {
                                setState(() {
                                  if (!isSelected) {
                                    selectedUsers.add(user['userId']);
                                  }
                                });
                              },
                              onTap: () {
                                setState(() {
                                  if (selectedUsers.isNotEmpty) {
                                    if (isSelected) {
                                      selectedUsers.remove(user['userId']);
                                    } else {
                                      selectedUsers.add(user['userId']);
                                    }
                                  } else {
                                    if (isExpanded) {
                                      _expandedIndex = null;
                                    } else {
                                      _expandedIndex = index;
                                    }
                                  }
                                });
                              },
                              child: AnimatedSize(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                                child: Container(
                                  color: isSelected
                                      ? Colors.blue.withOpacity(0.5)
                                      : Colors.grey[900],
                                  child: Column(
                                    children: [
                                      selectedUsers.isEmpty
                                          ? Slidable(
                                              key: ValueKey(user['nickname']),
                                              endActionPane: ActionPane(
                                                motion: const ScrollMotion(),
                                                extentRatio: 1 / 3,
                                                children: [
                                                  CustomTileAction(
                                                    onPressed: () =>
                                                        showDialog<String>(
                                                      context: context,
                                                      builder: (BuildContext context) => CustomAlertDialog(
                                                        title: 'Scala',
                                                        message:
                                                          'Scalare una lezione a ${user['nickname']}?',
                                                        onPressed: () {
                                                          _decreaseLessons(
                                                            user['userId']);
                                                          Navigator.pop(
                                                            context, 'Sì');
                                                        },
                                                      ),
                                                    ),
                                                    backgroundColor: Colors.red,
                                                    icon: Icons.plus_one,
                                                    iconColor: Colors.white,
                                                    padding: const EdgeInsets.all(8.0),
                                                  ),
                                                  CustomTileAction(
                                                    onPressed: () =>
                                                      showDialog<String>(
                                                        context: context, 
                                                        builder: (BuildContext context) => CustomAlertDialog(
                                                        title: 'Ripristina',
                                                        message: 'Ripristinare le lezioni di ${user['nickname']}?',
                                                        onPressed: () {
                                                          _restoreLessons(user['userId']);
                                                          Navigator.pop(context, 'Sì');
                                                        },
                                                      ),
                                                    ),
                                                    backgroundColor: Colors.green,
                                                    icon: Icons.restart_alt_rounded,
                                                    iconColor: Colors.white,
                                                    padding: const EdgeInsets.all(8.0),
                                                  ),
                                                ],
                                              ),
                                              child: ListTile(
                                                contentPadding: const EdgeInsets.only(left: 12),
                                                leading: const Icon(
                                                  Icons.person,
                                                  color: Colors.white
                                                ),
                                                title: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    isExpanded ?
                                                      Row(
                                                        children: [
                                                          Text(user['nickname'], style: const TextStyle(color: Colors.white),),
                                                          IconButton(
                                                            onPressed: () => showDialog<String>(
                                                              context: context, 
                                                              builder: (BuildContext context) => NicknameAlertDialog(
                                                                title: 'Cambia nickname',
                                                                message: 'Inserisci il nuovo nickname per ${user['nickname']}',
                                                                nickname: user['nickname'],
                                                                onNicknameChanged: (newNickname) {
                                                                  setState(() {
                                                                    user['nickname'] = newNickname;
                                                                    _renameUser(user);
                                                                  });
                                                                },
                                                              )
                                                            ),
                                                            icon: const Icon(
                                                              Icons.edit,
                                                              color: Colors.white,
                                                            ),
                                                          ),
                                                        ],
                                                      )
                                                    : Text(
                                                        user['nickname'],
                                                        style: const TextStyle(color: Colors.white),
                                                      ),
                                                    Padding(
                                                      padding: const EdgeInsets.only(right: 24),
                                                      child: Text(
                                                        user['lessons'].length.toString(),
                                                        style: const TextStyle(color: Colors.white),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            )
                                          : ListTile(
                                              contentPadding: const EdgeInsets.only(left: 12),
                                              leading: const Icon(Icons.person, color: Colors.white),
                                              title: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Text(
                                                    user['name'],
                                                    style: const TextStyle(color: Colors.white),
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets.only(right: 24),
                                                    child: Text(
                                                      user['lessons'].length.toString(),
                                                      style: const TextStyle(color: Colors.white),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                      if (isExpanded)
                                        Padding(
                                          padding: const EdgeInsets.all(12.0),
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              ListView.builder(
                                                shrinkWrap: true,
                                                physics: const NeverScrollableScrollPhysics(),
                                                itemCount: user['lessons'].length,
                                                itemBuilder: (context, itemIndex) {
                                                  // final lesson = user['lessons'][itemIndex];

                                                  // final romeTimeZone = tz.getLocation('Europe/Rome');
                                                  // final romeDate = tz.TZDateTime.from(lesson['date'].toDate(), romeTimeZone);

                                                  // final formattedDate = DateFormat('dd/MM/yyyy').format(romeDate);
                                                  
                                                  return ListTile(
                                                    title: Text(
                                                      'Lezione ${itemIndex + 1}', 
                                                      style: const TextStyle(color: Colors.white),
                                                    ),
                                                    subtitle: const Text(
                                                      'Data: Data',
                                                      style: TextStyle(color: Colors.white70),
                                                    ),
                                                  );
                                                },
                                              ),
                                              if ((user['lessons']?.length ?? 0) == 0)
                                                const Text('Ancora nessuna lezione')
                                            ],
                                          ),
                                        )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                )
              ],
            ),
          ),
        ),
      ),
      // floatingActionButton: Padding(
      //   padding: const EdgeInsets.only(right: 12, bottom: 32),
      //   child: FloatingActionButton(
      //     onPressed: () {
      //       // _openVoidActionBottomSheet();
      //     },
      //     backgroundColor: Colors.red[900],
      //     foregroundColor: Colors.white,
      //     child: const Icon(Icons.info),
      //   ),
      // ),
      floatingActionButton: ExpandableFab(
        key: _key,
        // duration: const Duration(milliseconds: 500),
        distance: 50.0,
        type: ExpandableFabType.up,
        pos: ExpandableFabPos.right,
        childrenOffset: const Offset(0, 20),
        fanAngle: 45,
        openButtonBuilder: RotateFloatingActionButtonBuilder(
          fabSize: ExpandableFabSize.regular,
          foregroundColor: Colors.white,
          backgroundColor: Colors.red[900],
          child: const Icon(Icons.info),
          angle: 3.14,
        ),
        closeButtonBuilder: RotateFloatingActionButtonBuilder(
          fabSize: ExpandableFabSize.regular,
          foregroundColor: Colors.white,
          backgroundColor: Colors.red[900],
          child: const Icon(Icons.info),
          angle: 3.14,
        ),
        overlayStyle: const ExpandableFabOverlayStyle(
          // color: Colors.black.withOpacity(0.5),
          blur: 5,
        ),
        onOpen: () {
          // debugPrint('onOpen');
        },
        afterOpen: () {
          // debugPrint('afterOpen');
        },
        onClose: () {
          // debugPrint('onClose');
        },
        afterClose: () {
          // debugPrint('afterClose');
        },
        children: [
          FloatingActionButton.small(
            heroTag: null,
            foregroundColor: Colors.white,
            backgroundColor: Colors.red[900],
            child: const Icon(Icons.edit),
            onPressed: () {
            },
          ),
          FloatingActionButton.small(
            heroTag: null,
            foregroundColor: Colors.white,
            backgroundColor: Colors.red[900],
            child: const Icon(Icons.search),
            onPressed: () {
            },
          ),
          FloatingActionButton.small(
            heroTag: null,
            foregroundColor: Colors.white,
            backgroundColor: Colors.red[900],
            child: const Icon(Icons.share),
            onPressed: () {
              // final state = _key.currentState;
              // if (state != null) {
              //   debugPrint('isOpen:${state.isOpen}');
              //   state.toggle();
              // }
            },
          ),
        ],
      ),
      floatingActionButtonLocation: ExpandableFab.location,
    );
  }
}
