import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'landing.dart';
import 'login.dart';
import 'signup.dart';
import 'home.dart';
import 'config/supabase_config.dart';
import 'grooming/grooming_page.dart';
// import 'shop/shop_page.dart';
// import 'shop/shop_cart.dart';
// import 'shop/shop_myorders.dart';
import 'admin/home_admin.dart';
import 'messages/messages_page.dart';
import 'reset_password_page.dart';
// import 'password_reset_page.dart';
import 'profile/profile_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await SupabaseConfig.initialize();
  } catch (e) {
    // Handle initialization errors, e.g., show a persistent error screen
    // or log the error and proceed with a state indicating no backend connection.
    debugPrint('Failed to initialize Supabase: $e');
    // Depending on the app's requirements, you might want to show a critical error screen here.
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ImPawsible',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4A90E2),
          primary: const Color(0xFF4A90E2),
          secondary: const Color(0xFFF5A623),
        ),
        textTheme: GoogleFonts.poppinsTextTheme(),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const LandingPage(),
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignupPage(),
        '/home': (context) => const HomePage(),
        '/home_admin': (context) => const HomeAdminPage(),
        '/grooming': (context) => const GroomingPage(),
        // '/shop': (context) => const ShopPage(),
        // '/shop_cart': (context) => const ShopCartPage(),
        // '/shop_myorders': (context) => const ShopMyOrders(),
        '/messages': (context) => const MessagesPage(),
        '/reset_password': (context) => const ResetPasswordPage(),
        // '/password_reset': (context) => const PasswordResetPage(),
        '/profile_page' : (context) => const ProfilePage(),
      },
    );
  }
}


// ---

// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'landing.dart';
// import 'login.dart';
// import 'signup.dart';
// import 'home.dart';
// import 'config/supabase_config.dart';
// import 'grooming/grooming_page.dart';
// import 'shop/shop_page.dart';
// import 'shop/shop_cart.dart';
// import 'shop/shop_myorders.dart';
// import 'admin/home_admin.dart';
// import 'messages/messages_page.dart';
// import 'reset_password_page.dart';
// import 'update_password_page.dart'; // <-- Add this import
// import 'profile/profile_page.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   try {
//     await SupabaseConfig.initialize();
//   } catch (e) {
//     debugPrint('Failed to initialize Supabase: $e');
//   }
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'ImPawsible',
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         colorScheme: ColorScheme.fromSeed(
//           seedColor: const Color(0xFF4A90E2),
//           primary: const Color(0xFF4A90E2),
//           secondary: const Color(0xFFF5A623),
//         ),
//         textTheme: GoogleFonts.poppinsTextTheme(),
//         useMaterial3: true,
//       ),
//       initialRoute: '/',
//       routes: {
//         '/': (context) => const LandingPage(),
//         '/login': (context) => const LoginPage(),
//         '/signup': (context) => const SignupPage(),
//         '/home': (context) => const HomePage(),
//         '/home_admin': (context) => const HomeAdminPage(),
//         '/grooming': (context) => const GroomingPage(),
//         '/shop': (context) => const ShopPage(),
//         '/shop_cart': (context) => const ShopCartPage(),
//         '/shop_myorders': (context) => const ShopMyOrders(),
//         '/messages': (context) => const MessagesPage(),
//         '/reset_password': (context) => const ResetPasswordPage(),
//         '/update-password': (context) => UpdatePasswordPage(newPassword: ModalRoute.of(context)!.settings.arguments as String), // <-- Add this route
//         '/profile_page': (context) => const ProfilePage(),
//       },
//     );
//   }
// }
