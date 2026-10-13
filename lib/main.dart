import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'core/services/hive_service.dart';
import 'core/services/supabase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set orientasi potrait saja
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Muat variabel environment
  await dotenv.load(fileName: '.env');

  // Inisialisasi Hive local storage
  await HiveService.init();

  // Inisialisasi Supabase
  await SupabaseService.init();

  runApp(
    const ProviderScope(
      child: CareCycleApp(),
    ),
  );
}
