import 'package:flutter/material.dart';
// import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:mindmates/professionals.dart';
import 'auth/firebase_auth/firebase_user_provider.dart';
import 'auth/firebase_auth/auth_util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// ignore: duplicate_import
import 'package:cloud_firestore/cloud_firestore.dart';

import 'backend/firebase/firebase_config.dart';
import 'flutter_flow/flutter_flow_theme.dart';
import 'flutter_flow/flutter_flow_util.dart';
import 'flutter_flow/internationalization.dart';
import 'index.dart';
import 'pages/chat_page_remake/chat_tab_page.dart';




void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();
  await initFirebase();
  await FlutterFlowTheme.initialize();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();

  static _MyAppState of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>()!;
}

class _MyAppState extends State<MyApp> {
  Locale? _locale;
  ThemeMode _themeMode = FlutterFlowTheme.themeMode;
  late Stream<BaseAuthUser> userStream;
  late AppStateNotifier _appStateNotifier;
  late GoRouter _router;
  final authUserSub = authenticatedUserStream.listen((_) {});

  @override
  void initState() {
    super.initState();
    _appStateNotifier = AppStateNotifier.instance;
    _router = createRouter(_appStateNotifier);
    userStream = mindmatesFirebaseUserStream()
      ..listen((user) => _appStateNotifier.update(user));
    jwtTokenStream.listen((_) {});
    Future.delayed(
      Duration(seconds: 3),
      () => _appStateNotifier.stopShowingSplashImage(),
    );
  }

  @override
  void dispose() {
    authUserSub.cancel();
    super.dispose();
  }

  void setLocale(String language) {
    setState(() => _locale = createLocale(language));
  }

  void setThemeMode(ThemeMode mode) => setState(() {
        _themeMode = mode;
        FlutterFlowTheme.saveThemeMode(mode);
      });

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'MINDMATES',
      // localizationsDelegates: [
      //   FFLocalizationsDelegate(),
      //   GlobalMaterialLocalizations.delegate,
      //   GlobalWidgetsLocalizations.delegate,
      //   GlobalCupertinoLocalizations.delegate,
      // ],
      locale: _locale,
      supportedLocales: const [Locale('en', '')],
      theme: ThemeData(brightness: Brightness.light),
      darkTheme: ThemeData(brightness: Brightness.dark),
      themeMode: _themeMode,
      routerConfig: _router,
    );
  }
}

class NavBarPage extends StatefulWidget {
  NavBarPage({Key? key, this.initialPage, this.page}) : super(key: key);

  final String? initialPage;
  final Widget? page;

  @override
  _NavBarPageState createState() => _NavBarPageState();
}

class _NavBarPageState extends State<NavBarPage> {
  String _currentPageName = 'homePage';
  late Widget? _currentPage;

  @override
  void initState() {
    super.initState();
    _currentPageName = widget.initialPage ?? _currentPageName;
    _currentPage = widget.page;
  }

  Future<void> _refreshHomePage() async {
    //  Implement the refresh logic for the homepage
    await Future.delayed(Duration(seconds: 2)); // Simulating a delay
  }

  @override
  Widget build(BuildContext context) {
    final tabs = {
      'homePage': HomePageWidget(searchQuery: ''),
      'searchBar': MindmateSearchBar(),
      'allChatsPage': ChatsPage(),
      // 'professionalProfile': MentalHealthProfessionalProfilePage(),
      'Professionals': ProfessionalsPage(),
      'profilePage': ProfilePageWidget(),
    };

    final currentIndex = tabs.keys.toList().indexOf(_currentPageName);

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .where('uid', isEqualTo: currentUser?.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Container();
        }
        if (snapshot.error != null) {
          return const Center(
            child: Text('Error loading data...'),
          );
        }

        final userdata = snapshot.data!.docs.first;
        final userInfo = userdata.data() as Map<String, dynamic>;

        return Scaffold(
          body: _currentPageName != 'homePage'
              ? _currentPage ??
                  RefreshIndicator(
                    onRefresh: _refreshHomePage,
                    child: tabs[_currentPageName]!,
                  )
              : _currentPage ??
                  Container(
                    // onRefresh: _refreshHomePage,
                    child: tabs[_currentPageName]!,
                  ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: currentIndex,
            onTap: (i) => setState(() {
              _currentPage = null;
              _currentPageName = tabs.keys.toList()[i];
            }),
            backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
            selectedItemColor: FlutterFlowTheme.of(context).primary,
            unselectedItemColor: FlutterFlowTheme.of(context).grayIcon,
            showSelectedLabels: true,
            showUnselectedLabels: false,
            type: BottomNavigationBarType.fixed,
            items: <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(
                  Icons.home_outlined,
                  size: 24.0,
                ),
                label: 'Home',
                tooltip: '',
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  Icons.search,
                  size: 24.0,
                ),
                activeIcon: Icon(
                  Icons.search,
                  size: 24.0,
                ),
                label: 'Search',
                tooltip: '',
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  Icons.mail_outline,
                  size: 24.0,
                ),
                activeIcon: Icon(
                  Icons.mail_outline,
                  size: 24.0,
                ),
                label: 'Messages',
                tooltip: '',
              ),
              BottomNavigationBarItem(
                icon: Icon(
                  Icons.medical_services,
                  size: 24.0,
                ),
                label: 'Professional profile',
                tooltip: '',
              ),
              BottomNavigationBarItem(
                icon: CircleAvatar(
                  radius: 21,
                  foregroundImage: userInfo['photo_url'] != null
                      ? NetworkImage(userInfo['photo_url']!)
                      : null,
                  child: const Icon(Icons.person),
                ),
                label: 'Profile',
              ),
            ],
          ),
        );
      },
    );
  }
}






// Future<void> updateSaved() async {
//                               // Get a Firestore instance
//                               FirebaseFirestore firestore =
//                                   FirebaseFirestore.instance;
//                               // Define the query to select the documents to delete
//                               QuerySnapshot querySnapshot = await firestore
//                                   .collection('messages')
//                                   .where('id', isnot: 'aOnrVah44rFk7R3Ipkox')
//                                   .get();

//                               // Use a forEach loop to delete each matching document
//                               querySnapshot.docs.forEach((doc) async {
//                                 await doc.reference.update({
//                                   'replyId':'',
//                                   'replyContent': '',
//                                   'replyType': '',
//                                 });
//                               });
//                             }





// try {
//       flutterEngine.getPlugins().add(new dev.fluttercommunity.plus.packageinfo.PackageInfoPlugin());
//     } catch (Exception e) {
//       Log.e(TAG, "Error registering plugin package_info_plus, dev.fluttercommunity.plus.packageinfo.PackageInfoPlugin", e);
//     }