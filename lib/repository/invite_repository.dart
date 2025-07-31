import 'dart:async';
import 'dart:math';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/user_service.dart';

class InviteRepository {
  final supabase = Supabase.instance.client;

  // Generate a 6-digit login code for managers
  String _generateManagerCode() {
    final random = Random.secure();
    return List.generate(6, (index) => random.nextInt(10)).join();
  }

  // Generate a random token for the invite
  String _generateInviteToken() {
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random.secure();
    return List.generate(32, (index) => chars[random.nextInt(chars.length)]).join();
  }

  Future<int> getManagerCount(String storeId) async {
    final response = await supabase
        .from('manager_invites')
        .select('id')
        .eq('store_id', storeId)
        .eq('status', 'accepted');
    
    return (response as List).length;
  }

  Future<void> inviteManager({
    required String email,
    required String storeId,
    required String invitedBy,
  }) async {
    // Validate inputs
    if (email.isEmpty) {
      throw Exception('Email cannot be empty');
    }
    if (storeId.isEmpty) {
      throw Exception('Store ID cannot be empty');
    }
    if (invitedBy.isEmpty) {
      throw Exception('Invited by cannot be empty');
    }

    // Check store plan first
    final storeResponse = await supabase
        .from('stores')
        .select('plan')
        .eq('id', storeId)
        .single();
    
    final plan = storeResponse['plan'] as String;
    
    if (plan == 'free') {
      throw Exception('Upgrade to Pro or Premium to add managers');
    }
    
    // Check current manager count
    final managerCount = await getManagerCount(storeId);
    final maxManagers = plan == 'pro' ? 1 : 2;
    
    if (managerCount >= maxManagers) {
      throw Exception('Maximum managers reached for $plan plan');
    }

    // Check if invite already exists
    final existingInvite = await supabase
        .from('manager_invites')
        .select('id')
        .eq('email', email)
        .eq('store_id', storeId)
        .maybeSingle();

    if (existingInvite != null) {
      throw Exception('Manager already invited');
    }

    // Generate unique token for the invite
    final token = _generateInviteToken();

    // Insert invite with token
    await supabase.from('manager_invites').insert({
      'email': email,
      'store_id': storeId,
      'invited_by': invitedBy,
      'token': token,
      'status': 'pending',
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<List<Map<String, dynamic>>> getPendingInvites(String storeId) async {
    final response = await supabase
        .from('manager_invites')
        .select('*')
        .eq('store_id', storeId)
        .eq('status', 'pending')
        .order('created_at', ascending: false);
    
    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> acceptInvite(String inviteId) async {
    await supabase
        .from('manager_invites')
        .update({'status': 'accepted'})
        .eq('id', inviteId);
  }

  Future<void> rejectInvite(String inviteId) async {
    await supabase
        .from('manager_invites')
        .update({'status': 'rejected'})
        .eq('id', inviteId);
  }

  Future<void> inviteManagerSimple({
    required String email,
    required String storeId,
    required String invitedBy,
  }) async {
    final token = _generateInviteToken();
    
    try {
      await supabase.from('manager_invites').insert({
        'email': email,
        'store_id': storeId,
        'invited_by': invitedBy,
        'token': token,
      });
      
    } catch (e) {
      rethrow;
    }
  }

  // Generate new code for existing manager (only by the admin who invited them)
  Future<String> regenerateManagerCode(String managerEmail, String storeId, String currentAdminId) async {
    // Verify this admin is the one who invited this manager
    final inviteCheck = await supabase
        .from('manager_invites')
        .select('invited_by')
        .eq('email', managerEmail)
        .eq('store_id', storeId)
        .eq('status', 'accepted')
        .maybeSingle();
    
    if (inviteCheck == null) {
      throw Exception('Manager invite not found');
    }
    
    if (inviteCheck['invited_by'] != currentAdminId) {
      throw Exception('Only the admin who invited this manager can regenerate the code');
    }

    final newCode = _generateManagerCode();
    
    await supabase
        .from('manager_invites')
        .update({'manager_code': newCode})
        .eq('email', managerEmail)
        .eq('store_id', storeId);
    
    return newCode;
  }

  // Get current manager code (only by the admin who invited them)
  Future<String?> getCurrentManagerCode(String managerEmail, String storeId, String currentAdminId) async {
    final response = await supabase
        .from('manager_invites')
        .select('manager_code, invited_by')
        .eq('email', managerEmail)
        .eq('store_id', storeId)
        .eq('status', 'accepted')
        .maybeSingle();
    
    if (response == null) {
      throw Exception('Manager not found');
    }
    
    if (response['invited_by'] != currentAdminId) {
      throw Exception('Only the admin who invited this manager can view the code');
    }
    
    return response['manager_code'];
  }

  // Generate one-time invite code (6 digits)
  String generateOneTimeInviteCode() {
    final random = Random.secure();
    return List.generate(6, (index) => random.nextInt(10)).join();
  }

  // Create one-time invite code for manager registration
  Future<String> createManagerInviteCode({
    required String storeId,
    required String adminId,
  }) async {
    final inviteCode = generateOneTimeInviteCode();
    final now = DateTime.now();
    
    await supabase.from('manager_invite_codes').insert({
      'code': inviteCode,
      'store_id': storeId,
      'created_by': adminId,
      'expires_at': now.add(const Duration(days: 7)).toIso8601String(),
      'created_at': now.toIso8601String(),
    });
    
    return inviteCode;
  }

  // Verify and use one-time invite code
  Future<Map<String, dynamic>?> verifyInviteCode(String code) async {
    final response = await supabase
        .from('manager_invite_codes')
        .select('*, stores(name)')
        .eq('code', code)
        .gt('expires_at', DateTime.now().toIso8601String())
        .maybeSingle();
    
    return response;
  }

  // Mark invite code as used with manager info
  Future<void> useInviteCode(String code, {String? managerId}) async {
    try {
      // First, check if the code exists
      final existingCode = await supabase
          .from('manager_invite_codes')
          .select('*')
          .eq('code', code)
          .maybeSingle();
      
      if (existingCode == null) {
        throw Exception('Invite code not found: $code');
      }
      
      final updateData = {
        'used_at': DateTime.now().toUtc().toIso8601String(),
        'used_by': managerId,
      };
      
      final result = await supabase
          .from('manager_invite_codes')
          .update(updateData)
          .eq('code', code)
          .select();
      
      // Verify the update worked
      final updatedCode = await supabase
          .from('manager_invite_codes')
          .select('*')
          .eq('code', code)
          .maybeSingle();
      
    } catch (e) {
      rethrow;
    }
  }

  // Complete manager registration
  Future<void> completeManagerRegistration({
    required String inviteCode,
    required String email,
    required String fullName,
    required String password,
  }) async {

    // Verify code is still valid and not used
    final codeData = await supabase
        .from('manager_invite_codes')
        .select('*, stores(name)')
        .eq('code', inviteCode)
        .gt('expires_at', DateTime.now().toIso8601String())
        .maybeSingle();
    
    if (codeData == null) {
      throw Exception('Invalid or expired invite code');
    }

    // Check if already used
    if (codeData['used_at'] != null) {
      throw Exception('Invite code has already been used');
    }

    try {
      // Create user first
      final authResponse = await supabase.auth.signUp(
        email: email,
        password: password,
      );

      if (authResponse.user == null) {
        throw Exception('Failed to create user account');
      }

      // Create manager profile
      await supabase.from('manager_profiles').insert({
        'id': authResponse.user!.id,
        'email': email,
        'full_name': fullName,
        'store_id': codeData['store_id'],
        'invited_by': codeData['created_by'],
        'role': 'manager',
        'status': 'active',
        'created_at': DateTime.now().toUtc().toIso8601String(),
      });

      // Try to mark code as used with the existing RPC function
      try {
        await supabase.rpc('update_invite_code_manager', params: {
          'code_param': inviteCode,
          'manager_id_param': authResponse.user!.id,
        });
      } catch (markError) {
        // Continue anyway - the important parts (user and profile) are created
      }

      // Clear any cached user type to ensure fresh lookup
      await UserService.clearUserTypeCache();

    } catch (e) {
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getInviteCodesForStore(String storeId) async {
    try {
      final response = await supabase
          .from('manager_invite_codes')
          .select('code, created_at, used_at, used_by')
          .eq('store_id', storeId)
          .order('created_at', ascending: false);
      
      List<Map<String, dynamic>> result = [];
      
      for (var invite in response) {
        bool isUsed = invite['used_at'] != null;
        String? managerName;
        
        if (isUsed && invite['used_by'] != null) {
          // Get the specific manager who used this code
          final managerResponse = await supabase
              .from('manager_profiles')
              .select('full_name')
              .eq('id', invite['used_by'])
              .maybeSingle();
          
          managerName = managerResponse?['full_name'];
        }
        
        result.add({
          'code': invite['code'],
          'status': isUsed ? 'used' : 'pending',
          'created_at': invite['created_at'],
          'used_at': invite['used_at'],
          'used_by_name': managerName,
        });
      }
      
      return result;
    } catch (e) {
      return [];
    }
  }

  // Fix existing data - mark codes as used if there are active managers
  // Future<void> fixExistingCodeStatus(String storeId) async { ... }

  // Add this test method temporarily
  Future<void> testMarkCodeAsUsed(String code, String managerId) async {
    await useInviteCode(code, managerId: managerId);
  }
}
