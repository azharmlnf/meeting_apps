import 'package:flutter/material.dart';
import 'services/auth_service.dart';
import 'pages/dashboard_page.dart';
import 'pages/login_page.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // Import package

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    print("Mencoba memuat file .env...");
    await dotenv.load(fileName: ".env");
    print("File .env berhasil dimuat.");
  } catch (e) {
    print("=============================================");
    print("ERROR: Gagal memuat file .env. Pastikan file ada di root proyek.");
    print("Detail Error: $e");
    print("=============================================");
  }
  
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Plinplan - Meeting Reminder',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: FutureBuilder(
        // Cek apakah ada user yang sedang login
        future: _authService.getCurrentUser(),
        builder: (context, snapshot) {
          // Tampilkan loading indicator saat proses pengecekan
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          // Jika ada data user (berhasil login), tampilkan DashboardPage
          if (snapshot.hasData && snapshot.data != null) {
            return const DashboardPage();
          }

          // Jika tidak ada data, tampilkan LoginPage
          return const LoginPage();
        },
      ),
    );
  }
}