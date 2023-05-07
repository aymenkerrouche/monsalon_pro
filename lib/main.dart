import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:monsalon_pro/Provider/AuthProvider.dart';
import 'package:monsalon_pro/Views/Home/Home.dart';
import 'package:monsalon_pro/Views/Splash/splash.dart';
import 'package:monsalon_pro/theme/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Provider/CategoriesProvider.dart';
import 'Provider/StatisticsProvider.dart';
import 'Provider/UserProvider.dart';
import 'Provider/rdvProvider.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';


SharedPreferences? prefs;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform,);
  prefs = await SharedPreferences.getInstance();
  easyConfig();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthProvider(),),
        ChangeNotifierProvider(create: (context) => CategoriesProvider(),),
        ChangeNotifierProvider(create: (context) => StatisticsProvider(),),
        ChangeNotifierProvider(create: (context) => RdvProvider(),),
        ChangeNotifierProvider(create: (context) => UserProvider(),),
      ],
      child: const MyApp(),
    ),
  );
}

easyConfig(){
  EasyLoading.instance
    ..indicatorType = EasyLoadingIndicatorType.ring
    ..backgroundColor = primaryPro;
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MonSalon pro',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Rubik',
        splashFactory: InkRipple.splashFactory,
        splashColor: primaryLite,
        iconTheme: const IconThemeData(color: primary),
        useMaterial3: true,
        scrollbarTheme: const ScrollbarThemeData().copyWith(
          thumbColor: MaterialStateProperty.all(primary),
        ),
      ),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('fr')
      ],
      home: FirebaseAuth.instance.currentUser?.uid == null ?  const SplashScreen(): const HomePage(),
      builder: EasyLoading.init(),
    );
  }
}

