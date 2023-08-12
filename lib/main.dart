import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hesaplayici/login_views/login_screen.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp, // portraitUp only.
    ]);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Material App',
      theme: ThemeData(
        canvasColor: Colors.transparent,
        chipTheme: ChipThemeData(
          shape: const OvalBorder(),
          side: const BorderSide(color: Colors.purple),
          selectedColor: Colors.purple,
          disabledColor: Colors.black.withOpacity(0.3),
        ),
        iconButtonTheme: const IconButtonThemeData(
          style: ButtonStyle(
            iconColor: MaterialStatePropertyAll(Colors.purple),
          ),
        ),
        elevatedButtonTheme: const ElevatedButtonThemeData(
          style: ButtonStyle(
            textStyle: MaterialStatePropertyAll(
              TextStyle(color: Colors.purple),
            ),
          ),
        ),
        textButtonTheme: const TextButtonThemeData(
          style: ButtonStyle(
            foregroundColor: MaterialStatePropertyAll(Colors.purple),
            textStyle: MaterialStatePropertyAll(
              TextStyle(fontSize: 26),
            ),
          ),
        ),
        colorScheme: const ColorScheme.dark(),
        useMaterial3: true,
        dialogBackgroundColor: Colors.blue.shade900,
        drawerTheme: const DrawerThemeData(
          scrimColor: Colors.transparent,
          width: 250,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          selectedItemColor: Colors.purple,
        ),
      ),
      home: const LoginPage(),
    );
  }
}
