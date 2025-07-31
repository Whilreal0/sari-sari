import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class UserService {
  static final _supabase = Supabase.instance.client;
  static const String _userTypeKey = 'user_type';
  static const String _fullNameKey = 'full_name';
  static const String _subscriptionDataKey = 'subscription_data';
  
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
  
  static Future<String?> getFullName() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return null;
    
    // Try to get cached full name first
    final prefs = await SharedPreferences.getInstance();
    final cachedFullName = prefs.getString(_fullNameKey);
    if (cachedFullName != null) {
      return cachedFullName;
    }
    
    // If not cached, fetch from database and cache it
    try {
      final userType = await getUserType();
      String? name;
      
      if (userType == 'admin') {
        final response = await _supabase
            .from('profiles')
            .select('full_name')
            .eq('id', user.id)
            .maybeSingle();
        name = response?['full_name'] as String?;
      } else if (userType == 'manager') {
        final response = await _supabase
            .from('manager_profiles')
            .select('full_name')
            .eq('id', user.id)
            .maybeSingle();
        name = response?['full_name'] as String?;
      }
      
      // Cache the full name
      if (name != null) {
        await prefs.setString(_fullNameKey, name);
      }
      return name;
    } catch (e) {
      return null;
    }
  }
  
  static Future<void> clearUserTypeCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userTypeKey);
    await prefs.remove(_fullNameKey);
    await prefs.remove(_subscriptionDataKey);
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
  
  static Future<Map<String, dynamic>?> getSubscriptionData() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return null;
    
    // Try to get cached subscription data first
    final prefs = await SharedPreferences.getInstance();
    final cachedData = prefs.getString(_subscriptionDataKey);
    if (cachedData != null) {
      return Map<String, dynamic>.from(json.decode(cachedData));
    }
    
    // If not cached, fetch from database and cache it
    try {
      final userType = await getUserType();
      Map<String, dynamic>? data;
      
      if (userType == 'manager') {
        final response = await _supabase
            .from('manager_profiles')
            .select()
            .eq('id', user.id)
            .maybeSingle();
        data = response;
      } else {
        final response = await _supabase
            .from('profiles')
            .select()
            .eq('id', user.id)
            .maybeSingle();
        data = response;
      }
      
      // Cache the subscription data
      if (data != null) {
        await prefs.setString(_subscriptionDataKey, json.encode(data));
      }
      return data;
    } catch (e) {
      print('Error getting subscription data: $e');
      return null;
    }
  }
}








