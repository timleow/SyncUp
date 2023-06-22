import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sync_up/pages/own_event_page.dart';
import 'package:sync_up/pages/group_page.dart';
import 'package:sync_up/pages/home_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sync_up/pages/main_page.dart';
import '../components/bottom_nav_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dot_navigation_bar/dot_navigation_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sync_up/pages/account_page.dart';
import 'package:sync_up/pages/own_event_page.dart';
import 'package:sync_up/pages/group_page.dart';

import '../components/bottom_nav_bar.dart';
import "package:flutter/material.dart";
import 'package:sync_up/components/bottom_nav_bar.dart';
import 'package:sync_up/pages/group_page.dart';
import 'package:sync_up/pages/home_page.dart';
import 'package:sync_up/pages/account_page.dart';
import 'package:googleapis/calendar/v3.dart' as cal;
import "package:googleapis_auth/auth_io.dart" as auth;
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:date_picker_timeline/date_picker_timeline.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:sync_up/services/sync_calendar.dart';

/// Provides the `GoogleSignIn` class
import 'package:google_sign_in/google_sign_in.dart';
import '../components/date_scroller.dart';
import '../components/date_tile.dart';
import '../components/event_tile.dart';

final GoogleSignIn _googleSignIn = GoogleSignIn(
  scopes: [cal.CalendarApi.calendarScope],
);

// this will be the logout page.
class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

Future<String> getUserName() async {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final User? user = auth.currentUser;
  final uid = user!.uid;
  return FirebaseFirestore.instance
      .collection("users")
      .doc(uid)
      .get()
      .then((value) {
    return value.data()!["name"];
  });
}

Future<String> getUserPhotoUrl() async {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final User? user = auth.currentUser;
  final uid = user!.uid;
  return FirebaseFirestore.instance
      .collection("users")
      .doc(uid)
      .get()
      .then((value) {
    return value.data()!["photoUrl"];
  });
}

class _AccountPageState extends State<AccountPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  var _selectedTab = _SelectedTab.account;

  GoogleSignInAccount? _currentUser;
  late DateTime dateTodayFormatted;

  @override
  void initState() {
    super.initState();

    DateTime now = DateTime.now();
    dateTodayFormatted = DateTime(now.year, now.month, now.day);
    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount? account) {
      setState(() {
        _currentUser = account;
      });
      // if (_currentUser != null) {
      //   SyncCalendar.syncCalendarByDay(dateTodayFormatted, _googleSignIn);
      // }
    });
    _googleSignIn.signInSilently();
  }

  void _handleIndexChanged(int i) {
    setState(() {
      _selectedTab = _SelectedTab.values[i];
    });
    switch (i) {
      case 0:
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation1, animation2) => const HomePage(),
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          ),
        );
        break;
      // TODO: fix the case 1 and 2 once Calendar and Database pages are done.
      case 1:
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation1, animation2) =>
                const OwnEventPage(),
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          ),
        );
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation1, animation2) => const GroupPage(),
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          ),
        );
        break;
      case 3:
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation1, animation2) =>
                const AccountPage(),
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          ),
        );
        break;
    }
  }

  String userName = "";
  String url = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade800,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            const SizedBox(width: 10),
            Expanded(
              child: FutureBuilder<String>(
                future: getUserName(),
                builder: (context, snapshot) {
                  if (snapshot.hasData && snapshot.data != null) {
                    userName = snapshot.data!;
                    return Text(
                      "Hello, ${snapshot.data}",
                      style: const TextStyle(
                          fontSize: 25, fontWeight: FontWeight.bold),
                    );
                  } else {
                    return const Text(
                      "Hello, User",
                      style:
                          TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                    );
                  }
                },
              ),
            ),
          ],
        ),
        backgroundColor: Colors.blue.shade800,
        shadowColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              _signOut();
            },
          ),
          const SizedBox(width: 15),
        ],
      ),
      body: Center(
        child: Container(
          height: MediaQuery.of(context).size.height,
          // constraints: const BoxConstraints(maxHeight: double.infinity),
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  FutureBuilder<String>(
                    future: getUserPhotoUrl(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData && snapshot.data != null) {
                        url = snapshot.data!;
                        return CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.blue.shade600,
                          backgroundImage: Image.network(url).image,
                          // backgroundImage: AssetImage('assets/images/user.png'),
                        );
                      } else {
                        return CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.blue.shade600,
                          // backgroundImage: Image.network().image,
                        );
                      }
                    },
                  ),

                  // const SizedBox(height: 20),
                  // Text(
                  //   userName,
                  //   style: const TextStyle(
                  //     fontSize: 20,
                  //     fontWeight: FontWeight.bold,
                  //   ),
                  // ),
                  // // const SizedBox(height: 7),
                  // // const Text(
                  // //   'Joined in 2023',
                  // //   style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  // // ),
                  const SizedBox(height: 20),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextButton.icon(
                            icon: const Icon(
                              Icons.calendar_month,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              if (_currentUser != null) {
                                SyncCalendar.syncCalendarByDay(
                                    dateTodayFormatted, _googleSignIn);
                              }
                            },
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  Colors.orange.shade400),
                            ),
                            label: const Text(
                              'Sync with Google',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 10),
                          TextButton(
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  Colors.blueAccent.shade100),
                            ),
                            onPressed: () {},
                            child: const Text(
                              'Sync with Apple',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
      extendBody: true,
      bottomNavigationBar: BottomNavBar(
        _SelectedTab.values.indexOf(_selectedTab),
        _handleIndexChanged,
        color: Colors.blue.shade800,
      ),
    );
  }

  void _signOut() async {
    await _auth.signOut();
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation1, animation2) => const MainPage(),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }
}

enum _SelectedTab { home, calendar, group, account }
