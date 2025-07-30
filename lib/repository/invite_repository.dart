import 'dart:async';
import 'dart:math';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

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
    print('Simple invite - email: $email, storeId: $storeId, invitedBy: $invitedBy');
    
    final token = _generateInviteToken();
    
    try {
      await supabase.from('manager_invites').insert({
        'email': email,
        'store_id': storeId,
        'invited_by': invitedBy,
        'token': token,
      });
      print('Simple insert successful');
    } catch (e) {
      print('Simple insert error: $e');
      throw e;
    }
  }

  // Optional: Send email using a service like EmailJS, SendGrid, etc.
  // Future<void> _sendInviteEmail(String email, String storeId) async {
  //   // Implement email sending logic here
  // }

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
    
    await supabase.from('manager_invite_codes').insert({
      'code': inviteCode,
      'store_id': storeId,
      'created_by': adminId,
      'status': 'pending',
      'expires_at': DateTime.now().add(const Duration(days: 7)).toIso8601String(),
      'created_at': DateTime.now().toIso8601String(),
    });
    
    return inviteCode;
  }

  // Verify and use one-time invite code
  Future<Map<String, dynamic>?> verifyInviteCode(String code) async {
    final response = await supabase
        .from('manager_invite_codes')
        .select('*, stores(name)')
        .eq('code', code)
        .eq('status', 'pending')
        .gt('expires_at', DateTime.now().toIso8601String())
        .maybeSingle();
    
    return response;
  }

  // Mark invite code as used
  Future<void> useInviteCode(String code) async {
    await supabase
        .from('manager_invite_codes')
        .update({'status': 'used', 'used_at': DateTime.now().toIso8601String()})
        .eq('code', code);
  }

  // Complete manager registration
  Future<void> completeManagerRegistration({
    required String inviteCode,
    required String email,
    required String fullName,
    required String password,
  }) async {
    // Verify code is still valid
    final codeData = await verifyInviteCode(inviteCode);
    if (codeData == null) {
      throw Exception('Invalid or expired invite code');
    }
    
    // Create auth user
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
      'created_at': DateTime.now().toIso8601String(),
    });
    
    // Mark invite code as used
    await useInviteCode(inviteCode);
  }

  // Get invite codes for a store with usage status
  Future<List<Map<String, dynamic>>> getInviteCodesForStore(String storeId) async {
    final response = await supabase
        .from('manager_invite_codes')
        .select('''
          code,
          status,
          created_at,
          used_at,
          manager_profiles!inner(full_name)
        ''')
        .eq('store_id', storeId)
        .order('created_at', ascending: false);
    
    return List<Map<String, dynamic>>.from(response).map((invite) {
      return {
        'code': invite['code'],
        'status': invite['status'],
        'created_at': invite['created_at'],
        'used_at': invite['used_at'],
        'used_by_name': invite['manager_profiles']?['full_name'],
      };
    }).toList();
  }
}
