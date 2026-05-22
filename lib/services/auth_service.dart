import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';

class AuthService {
  final SupabaseClient _client = SupabaseConfig.client;
  final Logger _logger = Logger('AuthService');

  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;

  AuthService._internal() {
    Logger.root.level = Level.ALL;
    Logger.root.onRecord.listen((record) {
      debugPrint('[${record.level.name}] ${record.time}: ${record.message}');
    });
  }

  User? getCurrentUser() {
    if (!_checkInit()) return null;
    return _client.auth.currentUser;
  }

  Future<Map<String, dynamic>?> getCurrentUserProfile() async {
    if (!_checkInit()) return null;
    final user = getCurrentUser();
    if (user == null) return null;
    return await _client.from('users').select().eq('id', user.id).single();
  }

  bool isAuthenticated() => _client.auth.currentUser != null;

  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
    required String contactNumber,
  }) async {
    if (!_checkInit()) _throwNotInitialized();

    _validateFields({
      'Email': email,
      'Password': password,
      'Full Name': fullName,
      'Contact Number': contactNumber,
    });

    if (await isEmailExists(email)) {
      throw Exception('This email is already registered.');
    }
    if (await isContactExists(contactNumber)) {
      throw Exception('This contact number is already registered.');
    }

    final authResponse = await _client.auth.signUp(
      email: email,
      password: password,
      data: {
        'full_name': fullName,
        'contact_number': contactNumber,
      },
      emailRedirectTo: 'io.supabase.impawsible://login-callback/',
    );

    if (authResponse.user == null) {
      throw Exception('Failed to create user account');
    }

    // Insert into public.users table
    try {
    await _client.from('users').insert({
      'id': authResponse.user!.id,
      'email': email,
      'full_name': fullName,
      'contact_number': contactNumber,
    });
    } catch (e) {
      // If it's a duplicate key error, ignore it
      if (e.toString().contains('duplicate key value') && e.toString().contains('users_email_key')) {
        // Optionally log: user already exists in users table
      } else {
        rethrow; // Only rethrow if it's a different error
      }
    }

    _logger.info('User created: ${authResponse.user!.email}');
    return authResponse;
  }

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    if (!_checkInit()) _throwNotInitialized();
    _validateFields({'Email': email, 'Password': password});

    final response =
        await _client.auth.signInWithPassword(email: email, password: password);

    // Get user profile to check role
    if (response.user != null) {
      final profile = await getCurrentUserProfile();
      if (profile != null) {
        await _client
            .from('users')
            .update({'role': profile['role']}).eq('id', response.user!.id);
      }
    }

    return response;
  }

  Future<void> signOut() async {
    if (!_checkInit()) return;
    await _client.auth.signOut();
  }

  Future<bool> resendEmailVerification(String email) async {
    if (!_checkInit()) return false;
    await _client.auth.resend(type: OtpType.signup, email: email);
    return true;
  }

  Future<Map<String, dynamic>?> updateUserProfile({
    required String userId,
    String? fullName,
    String? contactNumber,
  }) async {
    if (!_checkInit()) return null;

    final updates = <String, dynamic>{
      if (fullName != null) 'full_name': fullName,
      if (contactNumber != null) 'contact_number': contactNumber,
      'updated_at': DateTime.now().toIso8601String(),
    };

    return await _client
        .from('users')
        .update(updates)
        .eq('id', userId)
        .select()
        .single();
  }

  Future<bool> updateUserEmail(String newEmail) async {
    if (!_checkInit()) return false;
    await _client.auth.updateUser(UserAttributes(email: newEmail));
    return true;
  }

  Future<bool> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    if (!_checkInit()) _throwNotInitialized();
    if (getCurrentUser() == null) throw Exception('No user signed in');

    await _client.auth.updateUser(UserAttributes(password: newPassword));
    return true;
  }

  Future<bool> verifyPassword({
    required String email,
    required String password,
  }) async {
    if (!_checkInit()) _throwNotInitialized();

    try {
      // Attempt to sign in with the provided credentials
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      
      // If successful, sign out immediately to not change the current session
      if (response.user != null) {
        await _client.auth.signOut();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> verifyEmailAndPhone({
    required String email,
    required String phoneNumber,
  }) async {
    if (!_checkInit()) _throwNotInitialized();

    try {
      // Check if the email and phone number combination exists in the users table
      final result = await _client
          .from('users')
          .select('id, last_password_reset')
          .eq('email', email.trim())
          .eq('contact_number', phoneNumber.trim())
          .maybeSingle();
      
      if (result == null) return false;
      
      // Check if password reset is allowed (30 days restriction)
      final canReset = await _client.rpc('can_reset_password', params: {'user_id': result['id']});
      return canReset == true;
    } catch (e) {
      _logger.severe('Error verifying email and phone: ${e.toString()}');
      return false;
    }
  }

  Future<Map<String, dynamic>?> getUserForPasswordReset({
    required String email,
    required String phoneNumber,
  }) async {
    if (!_checkInit()) _throwNotInitialized();

    try {
      final result = await _client
          .from('users')
          .select('id, full_name, last_password_reset')
          .eq('email', email.trim())
          .eq('contact_number', phoneNumber.trim())
          .maybeSingle();
      
      return result;
    } catch (e) {
      _logger.severe('Error getting user for password reset: ${e.toString()}');
      return null;
    }
  }

  Future<void> updatePasswordResetTimestamp(String userId) async {
    if (!_checkInit()) _throwNotInitialized();

    try {
      await _client.rpc('update_password_reset_timestamp', params: {'user_id': userId});
      _logger.info('Password reset timestamp updated for user: $userId');
    } catch (e) {
      _logger.severe('Error updating password reset timestamp: ${e.toString()}');
      throw e;
    }
  }

  Future<bool> resetPassword({
    required String email,
    required String newPassword,
  }) async {
    if (!_checkInit()) _throwNotInitialized();

    _logger.info('Attempting to initiate password reset for email: $email');

    try {
      // Send password reset email
      // The user will receive an email with a link to reset their password
      await _client.auth.resetPasswordForEmail(
        email.trim(),
        redirectTo: 'io.supabase.impawsible://password_reset',
      );

      _logger.info('Successfully initiated password reset email for: $email');

      return true;
    } catch (e) {
      _logger.severe('Error in resetPassword initiation: ${e.toString()}');
      throw e;
    }
  }

  // Method to handle password reset when user clicks the email link
  Future<bool> updatePasswordFromReset({
    required String newPassword,
  }) async {
    if (!_checkInit()) _throwNotInitialized();
    
    try {
      await _client.auth.updateUser(UserAttributes(password: newPassword));
      _logger.info('Password updated successfully from reset flow');
      return true;
    } catch (e) {
      _logger.severe('Error updating password from reset: ${e.toString()}');
      throw e;
    }
  }

  // Method to handle the password reset callback from email link
  Future<bool> handlePasswordResetCallback({
    required String newPassword,
  }) async {
    if (!_checkInit()) _throwNotInitialized();
    
    try {
      // Check if we're in a recovery session
      final session = _client.auth.currentSession;
      if (session == null) {
        throw Exception('No valid recovery session found');
      }

      // Update the user's password in Supabase Auth
      final response = await _client.auth.updateUser(UserAttributes(password: newPassword));
      
      if (response.user != null) {
        // Update users table with timestamp
        await _client
          .from('users')
          .update({'last_password_change': DateTime.now().toIso8601String()})
          .eq('id', response.user!.id);
        
        _logger.info('Password updated for user: ${response.user!.email}');
        return true;
      } else {
        throw Exception('Failed to update password');
      }
    } catch (e) {
      _logger.severe('Error handling password reset callback: ${e.toString()}');
      throw e;
    }
  }

  Future<bool> isEmailExists(String email) async {
    if (!_checkInit()) return false;
    final result = await _client
        .from('users')
        .select('email')
        .eq('email', email)
        .maybeSingle();
    return result != null;
  }

  Future<bool> isContactExists(String contact) async {
    if (!_checkInit()) return false;
    final result = await _client
        .from('users')
        .select('contact_number')
        .eq('contact_number', contact)
        .maybeSingle();
    return result != null;
  }

  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  void _validateFields(Map<String, String> fields) {
    for (final entry in fields.entries) {
      if (entry.value.trim().isEmpty) {
        throw Exception('${entry.key} is required');
      }
    }
  }

  bool _checkInit() {
    final isReady = SupabaseConfig.isInitialized;
    if (!isReady) _logger.warning('Supabase not initialized.');
    return isReady;
  }

  Never _throwNotInitialized() => throw Exception(
      'Backend service is unavailable. Please check your internet connection.');

  Future<bool> isAdmin() async {
    if (!_checkInit()) return false;
    final user = getCurrentUser();
    if (user == null) return false;

    final profile = await getCurrentUserProfile();
    return profile?['role'] == 'admin';
  }
}
