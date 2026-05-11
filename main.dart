import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

// Existing imports
import 'firebase_options.dart';
import 'splash_screen.dart';
import 'login_screen.dart';
import 'home_page.dart';
import 'signup_screen.dart';

// ✅ NEW imports (added)
import 'device_location.dart';
import 'map.dart';
import 'ai_chat.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // ✅ Wrap with Provider (NEW)
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LocationProvider()),
      ],
      child: const AmarProtikkhaApp(),
    ),
  );
}

class AmarProtikkhaApp extends StatelessWidget {
  const AmarProtikkhaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Amar Protikkha',
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),

      // ✅ UPDATED routes (added new screens)
      routes: {
        '/': (_) => const SplashScreen(),
        '/login': (_) => const LoginScreen(),
        '/home': (_) => const HomePage(),
        '/signup': (_) => const SignupScreen(),

        // 🔥 NEW FEATURES
        '/map': (_) => const MapScreen(),
        '/ai-chat': (_) => const AiChatScreen(),
      },

      initialRoute: '/',
    );
  }
}