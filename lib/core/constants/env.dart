/// Environment configuration
/// Replace these with your actual Supabase credentials
class Env {
  Env._();

  /// Supabase project URL
  /// Get this from your Supabase project settings -> API
  static const String supabaseUrl = 'https://fwzamuvgwkuqiathkobz.supabase.co';

  /// Supabase anonymous key
  /// Get this from your Supabase project settings -> API
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZ3emFtdXZnd2t1cWlhdGhrb2J6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzA4NjkyOTEsImV4cCI6MjA4NjQ0NTI5MX0.NWGldiAy7KKm-qLhRUvtOaNfv8InCjOv5HG6QxMhjdM';

  /// RevenueCat API key for iOS
  static const String revenueCatIosKey = 'YOUR_REVENUECAT_IOS_KEY';

  /// RevenueCat API key for Android
  static const String revenueCatAndroidKey = 'YOUR_REVENUECAT_ANDROID_KEY';

  /// App version
  static const String appVersion = '1.0.0';

  /// Build number
  static const int buildNumber = 1;

  /// Is development mode
  static const bool isDevelopment = true;
}
