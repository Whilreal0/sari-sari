import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserService {
  static final _supabase = Supabase.instance.client;
  static const String _userTypeKey = 'user_type';
  
  static Future<String> getUserType() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return 'guest';
    
    // Try to get cached user type first
    final prefs = await SharedPreferences.getInstance();
    final cachedUserType = prefs.getString(_userTypeKey);
    if (cachedUserType != null) {
      return cachedUserType;
    }
    
    // If not cached, fetch from database and cache it
    try {
      String userType = 'user';
      
      // Check if user is in manager_profiles table first
      final managerResponse = await _supabase
          .from('manager_profiles')
          .select('id')
          .eq('id', user.id)
          .maybeSingle();
      
      if (managerResponse != null) {
        userType = 'manager';
      } else {
        // Check if user is in profiles table (admin/regular user)
        final profileResponse = await _supabase
            .from('profiles')
            .select('id')
            .eq('id', user.id)
            .maybeSingle();
        
        if (profileResponse != null) {
          userType = 'admin';
        }
      }
      
      // Cache the user type
      await prefs.setString(_userTypeKey, userType);
      return userType;
    } catch (e) {
      print('Error getting user type: $e');
      return 'user';
    }
  }
  
  static Future<void> clearUserTypeCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userTypeKey);
  }
  
  static Future<Map<String, dynamic>?> getManagerProfile() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return null;
    
    try {
      final response = await _supabase
          .from('manager_profiles')
          .select('*, stores(*)')
          .eq('id', user.id)
          .maybeSingle();
      
      return response;
    } catch (e) {
      print('Error getting manager profile: $e');
      return null;
    }
  }
}




