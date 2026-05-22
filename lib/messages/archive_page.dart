import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'viewarchive_page.dart';

class ArchivePage extends StatefulWidget {
  const ArchivePage({Key? key}) : super(key: key);

  @override
  State<ArchivePage> createState() => _ArchivePageState();
}

class _ArchivePageState extends State<ArchivePage> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _archivedMessages = [];
  Map<String, dynamic> _appointmentDetailsMap = {};
  bool _isLoading = true;
  // Selection mode state
  bool _selectionMode = false;
  Set<String> _selectedMessageIds = {};

  // Selection mode helpers and actions
  void _toggleSelectionMode(bool? value) {
    setState(() {
      _selectionMode = value ?? false;
      if (!_selectionMode) {
        _selectedMessageIds.clear();
      }
    });
  }
  void _toggleMessageSelection(String messageId, bool? selected) {
    setState(() {
      if (selected == true) {
        _selectedMessageIds.add(messageId);
      } else {
        _selectedMessageIds.remove(messageId);
      }
    });
  }
  void _selectAllMessages(List<Map<String, dynamic>> visibleMessages) {
    setState(() {
      _selectedMessageIds.clear();
      for (final message in visibleMessages) {
        _selectedMessageIds.add(message['id'].toString());
      }
    });
  }
  void _deselectAllMessages() {
    setState(() {
      _selectedMessageIds.clear();
    });
  }
  void _exitSelectionMode() {
    setState(() {
      _selectionMode = false;
      _selectedMessageIds.clear();
    });
  }

  Future<void> _cleanupOldArchivedMessages() async {
    try {
      // Calculate date 30 days ago
      final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
      
      // Delete messages older than 30 days from user_messages_archive
      await supabase
          .from('user_messages_archive')
          .delete()
          .lt('archived_at', thirtyDaysAgo.toIso8601String());
      
      print('Debug: Cleaned up old archived messages (user)');
    } catch (e) {
      print('Error cleaning up old archived messages (user): $e');
    }
  }
  Future<void> _deleteSelectedMessages() async {
    if (_selectedMessageIds.isEmpty) return;
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Conversation'),
        content: const Text('Are you sure you want to delete the selected conversation(s)? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    
    if (confirmed != true) return;
    
    try {
      final deletedCount = _selectedMessageIds.length;
      
      for (final messageId in _selectedMessageIds) {
        final msg = _archivedMessages.firstWhere(
          (c) => c['id'].toString() == messageId,
          orElse: () => <String, dynamic>{},
        );
        if (msg.isEmpty) continue;
        
        final userId = msg['user_id'];
        final appointmentId = msg['appointment_id'];
        if (userId == null || appointmentId == null) continue;
        
        // Delete from both tables
        await supabase
            .from('user_messages_archive')
            .delete()
            .eq('user_id', userId)
            .eq('appointment_id', appointmentId);
            
        await supabase
            .from('user_messages')
            .delete()
            .eq('user_id', userId)
            .eq('appointment_id', appointmentId);
      }
      
      // Clear selection and refresh UI
      setState(() {
        _selectedMessageIds.clear();
        _selectionMode = false;
      });
      
      // Wait for database operations to complete
      await Future.delayed(const Duration(milliseconds: 1000));
      
      // Refresh the data
      await _fetchArchivedMessages();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Successfully deleted $deletedCount conversation(s)'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('Error deleting archived messages: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete archived messages: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
    Future<void> _unarchiveSelectedMessages() async {
    if (_selectedMessageIds.isEmpty) return;
    
    try {
      final unarchivedCount = _selectedMessageIds.length;
      
      for (final messageId in _selectedMessageIds) {
        final msg = _archivedMessages.firstWhere(
          (c) => c['id'].toString() == messageId,
          orElse: () => <String, dynamic>{},
        );
        if (msg.isEmpty) continue;
        
        final userId = msg['user_id'];
        final appointmentId = msg['appointment_id'];
        if (userId == null || appointmentId == null) continue;
        
        // Get all archived messages for this appointment
        final archivedMessages = await supabase
            .from('user_messages_archive')
            .select('*')
            .eq('user_id', userId)
            .eq('appointment_id', appointmentId);
        
        if (archivedMessages is List && archivedMessages.isNotEmpty) {
          // Insert/Update messages in user_messages table
          final existingMessages = await supabase
              .from('user_messages')
              .select('*')
              .eq('user_id', userId)
              .eq('appointment_id', appointmentId);
          
          if (existingMessages is List && existingMessages.isNotEmpty) {
            // Update existing messages to unarchived
            await supabase
                .from('user_messages')
                .update({'is_archived': false})
                .eq('user_id', userId)
                .eq('appointment_id', appointmentId);
          } else {
            // Insert messages from archive back to user_messages
            final restoreBatch = archivedMessages.map((msg) {
              final restoreData = Map<String, dynamic>.from(msg);
              restoreData.remove('archived_at');
              restoreData['is_archived'] = false;
              return restoreData;
            }).toList();
            
            await supabase.from('user_messages').insert(restoreBatch);
          }
          
          // Delete from archive table
          await supabase
              .from('user_messages_archive')
              .delete()
              .eq('user_id', userId)
              .eq('appointment_id', appointmentId);
        }
      }
      
      // Clear selection and refresh UI
      setState(() {
        _selectedMessageIds.clear();
        _selectionMode = false;
      });
      
      // Wait for database operations to complete
      await Future.delayed(const Duration(milliseconds: 1000));
      
      // Refresh the data
      await _fetchArchivedMessages();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Successfully unarchived $unarchivedCount conversation(s)'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('Error unarchiving messages: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to unarchive messages: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _cleanupOldArchivedMessages();
    _fetchArchivedMessages();
  }

  Future<void> _fetchArchivedMessages() async {
    setState(() => _isLoading = true);
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) {
      setState(() {
        _archivedMessages = [];
        _appointmentDetailsMap = {};
        _isLoading = false;
      });
      return;
    }
    try {
      final response = await supabase
          .from('user_messages_archive')
          .select('*')
          .eq('user_id', userId)
          .order('archived_at', ascending: false);
      final archived = List<Map<String, dynamic>>.from(response);
      
      // Get all unique appointment_ids
      final appointmentIds = archived.map((m) => m['appointment_id']).toSet().toList();
      Map<String, dynamic> appointmentDetailsMap = {};
      if (appointmentIds.isNotEmpty) {
        final appointments = await supabase
            .from('grooming_appointments')
            .select('id, pet_name, pet_type, breed, preferred_date, preferred_time, status, special_requests_notes')
            .inFilter('id', appointmentIds);
        for (final appt in appointments) {
          appointmentDetailsMap[appt['id'].toString()] = appt;
        }
      }
      setState(() {
        _archivedMessages = archived;
        _appointmentDetailsMap = appointmentDetailsMap;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _archivedMessages = [];
        _appointmentDetailsMap = {};
        _isLoading = false;
      });
    }
  }

  String _formatTimestamp(String? timestamp) {
    if (timestamp == null) return '';
    try {
      final dt = DateTime.parse(timestamp).toLocal();
      return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return timestamp;
    }
  }

  @override
  Widget build(BuildContext context) {
    final orange = const Color(0xFFF5A623);
    // Group messages by appointment_id and keep only the latest message per appointment
    final Map<String, Map<String, dynamic>> latestByAppointment = {};
    for (final msg in _archivedMessages) {
      final apptId = msg['appointment_id']?.toString();
      if (apptId == null) continue;
      if (!latestByAppointment.containsKey(apptId)) {
        latestByAppointment[apptId] = msg;
      } else {
        // Compare created_at to keep the latest
        final existing = latestByAppointment[apptId]!;
        final existingTime = DateTime.tryParse(existing['created_at'] ?? existing['archived_at'] ?? '') ?? DateTime(1970);
        final msgTime = DateTime.tryParse(msg['created_at'] ?? msg['archived_at'] ?? '') ?? DateTime(1970);
        if (msgTime.isAfter(existingTime)) {
          latestByAppointment[apptId] = msg;
        }
      }
    }
    final List<Map<String, dynamic>> conversationList = latestByAppointment.values.toList()
      ..sort((a, b) {
        final aTime = DateTime.tryParse(a['created_at'] ?? a['archived_at'] ?? '') ?? DateTime(1970);
        final bTime = DateTime.tryParse(b['created_at'] ?? b['archived_at'] ?? '') ?? DateTime(1970);
        return bTime.compareTo(aTime);
      });
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text('Archived Messages', style: GoogleFonts.poppins(color: orange, fontWeight: FontWeight.w600)),
            const Spacer(),
            if (_selectionMode) ...[
              IconButton(
                onPressed: _exitSelectionMode,
                icon: const Icon(Icons.close, color: Colors.grey),
              ),
              Checkbox(
                value: _selectedMessageIds.length == _archivedMessages.length && _archivedMessages.isNotEmpty,
                onChanged: (selected) {
                  if (selected == true) {
                    _selectAllMessages(_archivedMessages);
                  } else {
                    _deselectAllMessages();
                  }
                },
              ),
            ] else
              TextButton(
                onPressed: () => _toggleSelectionMode(true),
                child: Text(
                  'Select',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: orange,
                  ),
                ),
              ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: orange),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context, true);
          },
        ),
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Unarchive/Delete buttons below search bar, right aligned
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (_selectionMode && _selectedMessageIds.isNotEmpty) ...[
                  ElevatedButton.icon(
                    onPressed: _unarchiveSelectedMessages,
                    icon: const Icon(Icons.unarchive),
                    label: const Text('Unarchive'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.withOpacity(0.15),
                      foregroundColor: Colors.blue,
                      elevation: 0,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      textStyle: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: _deleteSelectedMessages,
                    icon: const Icon(Icons.delete),
                    label: const Text('Delete'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.withOpacity(0.15),
                      foregroundColor: Colors.red,
                      elevation: 0,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      textStyle: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFF5A623)))
                : conversationList.isEmpty
              ? Center(child: Text('No archived messages.', style: GoogleFonts.poppins(color: Colors.grey[600], fontSize: 16)))
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        itemCount: conversationList.length,
                  separatorBuilder: (context, i) => const SizedBox(height: 12),
                  itemBuilder: (context, i) {
                          final msg = conversationList[i];
                          final appt = _appointmentDetailsMap[msg['appointment_id']?.toString()];
                          final petName = appt != null ? appt['pet_name'] ?? 'Unknown Pet' : 'Unknown Pet';
                          final message = msg['message'] ?? '';
                          final createdAt = msg['created_at'] ?? msg['archived_at'];
                          String formattedTimestamp = '';
                          String relativeTime = '';
                          if (createdAt != null) {
                            final dt = DateTime.parse(createdAt).toLocal();
                            formattedTimestamp = '${_monthName(dt.month)} ${dt.day}, ${dt.year}, '
                              '${_format12Hour(dt)}';
                            relativeTime = _relativeTime(dt);
                          }
                          return InkWell(
                            onTap: _selectionMode
                                ? () => _toggleMessageSelection(msg['id'].toString(), !_selectedMessageIds.contains(msg['id'].toString()))
                                : () async {
                                    final result = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => ViewArchivePage(appointmentId: msg['appointment_id']),
                                      ),
                                    );
                                    if (result == true) {
                                      // Add a small delay to ensure database operations complete
                                      await Future.delayed(const Duration(milliseconds: 1000));
                                      
                                      // Refresh the data
                                      await _fetchArchivedMessages();
                                    }
                                  },
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                      padding: const EdgeInsets.all(20.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Icon
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: orange.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(Icons.pets, color: orange, size: 20),
                                  ),
                                  const SizedBox(width: 12),
                                  // Content
                                  Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                                        // Pet Name
                                        Text(
                                          'Appointment for $petName',
                                          style: GoogleFonts.poppins(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        // Message
                          Text(
                                          message,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.grey[700],
                              height: 1.4,
                            ),
                                          maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                                        const SizedBox(height: 4),
                                        // Timestamp
                                        Text(
                                          formattedTimestamp,
                                          style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        // Relative time
                          Text(
                                          relativeTime,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                                    ),
                                  ),
                                  // Checkbox on the right
                                  if (_selectionMode)
                                    Padding(
                                      padding: const EdgeInsets.only(left: 8.0, top: 8.0),
                                      child: Checkbox(
                                        value: _selectedMessageIds.contains(msg['id'].toString()),
                                        onChanged: (selected) => _toggleMessageSelection(msg['id'].toString(), selected),
                                      ),
                                    ),
                                ],
                              ),
                      ),
                    );
                  },
                      ),
          ),
        ],
                ),
    );
  }
}

// Add helpers at the end of the class
String _monthName(int month) {
  const months = [
    '', 'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];
  return months[month];
}
String _format12Hour(DateTime dt) {
  int hour = dt.hour;
  String ampm = 'AM';
  if (hour == 0) hour = 12;
  else if (hour >= 12) {
    if (hour > 12) hour -= 12;
    ampm = 'PM';
  }
  final minute = dt.minute.toString().padLeft(2, '0');
  final second = dt.second.toString().padLeft(2, '0');
  return '$hour:$minute:$second $ampm';
}
String _relativeTime(DateTime dt) {
  final now = DateTime.now();
  final diff = now.difference(dt);
  if (diff.inDays > 0) {
    return '${diff.inDays} day${diff.inDays > 1 ? 's' : ''} ago';
  } else if (diff.inHours > 0) {
    return '${diff.inHours} hour${diff.inHours > 1 ? 's' : ''} ago';
  } else if (diff.inMinutes > 0) {
    return '${diff.inMinutes} minute${diff.inMinutes > 1 ? 's' : ''} ago';
  } else {
    return 'Just now';
  }
} 