import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const supabaseUrl = 'https://wzsvtxhhffkzdaonynnd.supabase.co';
const supabaseAnonKey =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Ind6c3Z0eGhoZmZremRhb255bm5kIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzk3ODgxMzQsImV4cCI6MjA5NTM2NDEzNH0.VoBc72T6IPHaYhPz0pzm_vme327DRwEXQQ7GxGAm1JU';

final supabaseClientProvider = Provider<SupabaseClient>(
  (_) => Supabase.instance.client,
);
