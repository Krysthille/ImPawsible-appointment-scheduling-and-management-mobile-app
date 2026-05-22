import 'package:supabase_flutter/supabase_flutter.dart';

class AutoMessageService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  /// Manually trigger the auto message sending function
  /// This can be called for testing or immediate message sending
  static Future<Map<String, dynamic>> triggerAutoMessages() async {
    try {
      final response = await _supabase.rpc('auto_send_messages');
      
      if (response != null) {
        print('Auto message service result: $response');
        return {
          'success': true,
          'reminders_sent': response['reminders_sent'] ?? 0,
          'apologies_sent': response['apologies_sent'] ?? 0,
        };
      } else {
        return {
          'success': false,
          'error': 'No response from auto message function',
        };
      }
    } catch (e) {
      print('Error triggering auto messages: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Check if there are any pending appointments that need messages
  static Future<List<Map<String, dynamic>>> getPendingAppointments() async {
    try {
      final response = await _supabase
          .from('grooming_appointments')
          .select('id, user_id, pet_name, preferred_date, preferred_time, status')
          .eq('status', 'Pending');
      
      if (response is List) {
        return List<Map<String, dynamic>>.from(response);
      }
      return [];
    } catch (e) {
      print('Error fetching pending appointments: $e');
      return [];
    }
  }

  /// Get message tracking status for an appointment
  static Future<Map<String, bool>> getMessageTrackingStatus(String appointmentId) async {
    try {
      final response = await _supabase
          .from('message_tracking')
          .select('message_type')
          .eq('appointment_id', appointmentId);
      
      final tracking = <String, bool>{'reminder': false, 'apology': false};
      
      if (response is List) {
        for (final record in response) {
          final messageType = record['message_type'] as String?;
          if (messageType != null) {
            tracking[messageType] = true;
          }
        }
      }
      
      return tracking;
    } catch (e) {
      print('Error getting message tracking status: $e');
      return {'reminder': false, 'apology': false};
    }
  }
} 