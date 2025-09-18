import 'package:supabase_flutter/supabase_flutter.dart';

final userID = supabase.auth.currentUser?.id;

final supabase = Supabase.instance.client;
