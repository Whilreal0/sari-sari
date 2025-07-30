import 'package:supabase_flutter/supabase_flutter.dart';

class StoreRepository {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> getStoresByOwner(String ownerId) async {
    final response = await _client
        .from('stores')
        .select('id, name, created_at')
        .eq('owner_id', ownerId)
        .order('created_at', ascending: true); // Changed to ascending order
    if (response is List) {
      return List<Map<String, dynamic>>.from(response);
    } else {
      throw Exception('Failed to fetch stores');
    }
  }

  Future<void> addStore(String name, String ownerId) async {
    try {
      await _client.from('stores').insert({
        'name': name,
        'owner_id': ownerId,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to add store: $e');
    }
  }

  Future<void> deleteStore(String storeId) async {
    try {
      await _client.from('stores').delete().eq('id', storeId);
    } catch (e) {
      throw Exception('Failed to delete store: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getManagersForStore(String storeId) async {
    try {
      final response = await _client
          .from('manager_profiles')
          .select('id, email, full_name, status, created_at')
          .eq('store_id', storeId)
          .order('created_at', ascending: false);
      
      if (response is List) {
        List<Map<String, dynamic>> managers = List<Map<String, dynamic>>.from(response);
        
        // Check email confirmation status for each manager
        for (var manager in managers) {
          try {
            final userResponse = await _client.auth.admin.getUserById(manager['id']);
            final isEmailConfirmed = userResponse.user?.emailConfirmedAt != null;
            manager['email_confirmed'] = isEmailConfirmed;
            
            // Use database status if it's 'active', otherwise check email confirmation
            if (manager['status'] == 'active') {
              manager['display_status'] = 'Active';
            } else {
              manager['display_status'] = isEmailConfirmed ? 'Active' : 'Not Active';
            }
          } catch (e) {
            manager['email_confirmed'] = false;
            // Use database status as fallback
            manager['display_status'] = manager['status'] == 'active' ? 'Active' : 'Not Active';
          }
        }
        
        return managers;
      } else {
        return [];
      }
    } catch (e) {
      print('Error fetching managers: $e');
      return [];
    }
  }

  Future<void> renameStore(String storeId, String newName) async {
    try {
      await _client.from('stores').update({
        'name': newName,
      }).eq('id', storeId);
    } catch (e) {
      throw Exception('Failed to rename store: $e');
    }
  }
} 
