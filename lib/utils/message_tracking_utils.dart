import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';

class MessageTrackingUtils {
  static const String _reminderMessageType = 'reminder';
  static const String _apologyMessageType = 'apology';

  /// Check if a reminder message has already been sent for an appointment
  static Future<bool> hasReminderBeenSent(String appointmentId) async {
    try {
      final response = await SupabaseConfig.client
          .from('message_tracking')
          .select('id')
          .eq('appointment_id', appointmentId)
          .eq('message_type', _reminderMessageType)
          .maybeSingle();
      
      return response != null;
    } catch (e) {
      print('Error checking reminder tracking: $e');
      return false;
    }
  }

  /// Check if an apology message has already been sent for an appointment
  static Future<bool> hasApologyBeenSent(String appointmentId) async {
    try {
      final response = await SupabaseConfig.client
          .from('message_tracking')
          .select('id')
          .eq('appointment_id', appointmentId)
          .eq('message_type', _apologyMessageType)
          .maybeSingle();
      
      return response != null;
    } catch (e) {
      print('Error checking apology tracking: $e');
      return false;
    }
  }

  /// Record that a reminder message has been sent
  static Future<void> recordReminderSent(String appointmentId, String messageContent) async {
    try {
      await SupabaseConfig.client
          .from('message_tracking')
          .insert({
            'appointment_id': appointmentId,
            'message_type': _reminderMessageType,
            'message_content': messageContent,
          });
      print('Recorded reminder sent for appointment $appointmentId');
    } catch (e) {
      print('Error recording reminder tracking: $e');
    }
  }

  /// Record that an apology message has been sent
  static Future<void> recordApologySent(String appointmentId, String messageContent) async {
    try {
      await SupabaseConfig.client
          .from('message_tracking')
          .insert({
            'appointment_id': appointmentId,
            'message_type': _apologyMessageType,
            'message_content': messageContent,
          });
      print('Recorded apology sent for appointment $appointmentId');
    } catch (e) {
      print('Error recording apology tracking: $e');
    }
  }

  /// Send a reminder message only if it hasn't been sent before
  static Future<bool> sendReminderIfNotSent(
    String appointmentId,
    String userId,
    String messageContent,
  ) async {
    try {
      // Check if reminder already sent
      if (await hasReminderBeenSent(appointmentId)) {
        print('Reminder already sent for appointment $appointmentId');
        return false;
      }

      // Double-check if message already exists in either table
      final existingAdminMessage = await SupabaseConfig.client
          .from('admin_messages')
          .select('id')
          .eq('appointment_id', appointmentId)
          .eq('message', messageContent)
          .maybeSingle();
      
      final existingUserMessage = await SupabaseConfig.client
          .from('user_messages')
          .select('id')
          .eq('appointment_id', appointmentId)
          .eq('message', messageContent)
          .maybeSingle();
      
      if (existingAdminMessage != null || existingUserMessage != null) {
        print('Reminder message already exists in database for appointment $appointmentId');
        // Record that reminder was sent even if we didn't send it (to prevent future attempts)
        await recordReminderSent(appointmentId, messageContent);
        return false;
      }

      // Send message to both admin_messages and user_messages
      print('Sending reminder message to admin_messages for appointment $appointmentId');
      await SupabaseConfig.client
          .from('admin_messages')
          .insert({
            'user_id': userId,
            'appointment_id': appointmentId,
            'message': messageContent,
            'is_from_admin': false,
            'is_read': false,
          });

      print('Sending reminder message to user_messages for appointment $appointmentId');
      await SupabaseConfig.client
          .from('user_messages')
          .insert({
            'user_id': userId,
            'appointment_id': appointmentId,
            'message': messageContent,
            'is_from_admin': false,
            'is_read': false,
          });

      // Record that reminder was sent
      await recordReminderSent(appointmentId, messageContent);
      
      print('Successfully sent reminder for appointment $appointmentId');
      return true;
    } catch (e) {
      print('Error sending reminder: $e');
      return false;
    }
  }

  /// Send an apology message only if it hasn't been sent before
  static Future<bool> sendApologyIfNotSent(
    String appointmentId,
    String userId,
    String messageContent,
  ) async {
    try {
      // Check if apology already sent
      if (await hasApologyBeenSent(appointmentId)) {
        print('Apology already sent for appointment $appointmentId');
        return false;
      }

      // Double-check if message already exists in either table
      final existingAdminMessage = await SupabaseConfig.client
          .from('admin_messages')
          .select('id')
          .eq('appointment_id', appointmentId)
          .eq('message', messageContent)
          .maybeSingle();
      
      final existingUserMessage = await SupabaseConfig.client
          .from('user_messages')
          .select('id')
          .eq('appointment_id', appointmentId)
          .eq('message', messageContent)
          .maybeSingle();
      
      if (existingAdminMessage != null || existingUserMessage != null) {
        print('Apology message already exists in database for appointment $appointmentId');
        // Record that apology was sent even if we didn't send it (to prevent future attempts)
        await recordApologySent(appointmentId, messageContent);
        return false;
      }

      // Send message to both admin_messages and user_messages
      await SupabaseConfig.client
          .from('admin_messages')
          .insert({
            'user_id': userId,
            'appointment_id': appointmentId,
            'message': messageContent,
            'is_from_admin': true,
            'is_read': false,
          });

      await SupabaseConfig.client
          .from('user_messages')
          .insert({
            'user_id': userId,
            'appointment_id': appointmentId,
            'message': messageContent,
            'is_from_admin': true,
            'is_read': false,
          });

      // Update appointment status to Cancelled
      await SupabaseConfig.client
          .from('grooming_appointments')
          .update({'status': 'Cancelled'})
          .eq('id', appointmentId);

      // Record that apology was sent
      await recordApologySent(appointmentId, messageContent);
      
      print('Sent apology for appointment $appointmentId');
      return true;
    } catch (e) {
      print('Error sending apology: $e');
      return false;
    }
  }
} 