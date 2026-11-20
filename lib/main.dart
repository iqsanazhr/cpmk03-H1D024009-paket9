import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/produk_model.dart';
import 'models/produk_adapter.dart';
import 'services/hive_service.dart';
import 'routes/app_pages.dart';

void main() async {
  // 1. Pastikan binding framework Flutter sudah siap
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Inisialisasi penyimpanan lokal Hive untuk Flutter
  await Hive.initFlutter();

  // 3. Daftarkan TypeAdapter sebelum membuka box (Paket 9: typeId = 9)
  Hive.registerAdapter(ProdukAdapter());

  // 4. Buka box penyimpanan Hive sebelum runApp() dijalankan
  await Hive.openBox<Produk>(HiveService.boxName);

  // 5. Jalankan aplikasi
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'KatalogKu UMKM',
      debugShowCheckedModeBanner: false,
      initialRoute: AppPages.initial,
      getPages: AppPages.routes,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF8FAFC), // Slate 50
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF0052FF), // Royal Blue
          secondary: Color(0xFFEEF4FF), // Soft Blue Tint
          surface: Colors.white,
          onPrimary: Colors.white,
          onSurface: Color(0xFF0F172A), // Slate 900
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          elevation: 0,
          scrolledUnderElevation: 0,
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFF0F172A),
        ),
      ),
    );
  }
}
