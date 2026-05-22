

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import '../profile/profile_page.dart';
import '../messages/archive_page.dart';
import '../utils/message_tracking_utils.dart';
import '../messages/viewmessages_page.dart';

class MessagesPage extends StatefulWidget {
  const MessagesPage({Key? key}) : super(key: key);

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

class _MessagesPageState extends State<MessagesPage> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _conversations = [];
  String _searchQuery = '';
  bool _isLoading = true;
  int _selectedIndex = 2;
  bool _selectionMode = false;
  Set<String> _selectedMessageIds = {};
  final FocusNode _searchFocusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  bool _showScrollToTop = false;
  bool _isCheckingReminders = false;
  static bool _hasCheckedRemindersThisSession = false;
  Timer? _reminderTimer;

  @override
  void initState() {
    super.initState();
    _syncMessagesFromAdmin();
    _fetchConversations();
    _checkAndSendReminders();
    _scrollController.addListener(_onScroll);
    _startPeriodicReminderCheck();
    _startPeriodicMessageRefresh();
  }

  @override
  void dispose() {
    _searchFocusNode.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _reminderTimer?.cancel();
    super.dispose();
  }

  // --- Helper Methods ---
  void _onScroll() {
    if (_scrollController.position.pixels > 200) {
      if (!_showScrollToTop) {
        setState(() => _showScrollToTop = true);
      }
    } else {
      if (_showScrollToTop) {
        setState(() => _showScrollToTop = false);
      }
    }
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  void _startPeriodicReminderCheck() {
    _reminderTimer = Timer.periodic(
      const Duration(hours: 1),
      (timer) => _checkRemindersOnPageActive(),
    );
  }

  void _startPeriodicMessageRefresh() {
    Timer.periodic(
      const Duration(minutes: 5),
      (timer) {
        if (mounted) {
          _checkForNewMessages();
        }
      },
    );
  }

  Future<void> _checkForNewMessages() async {
    try {
      final currentCount = _conversations.length;
      await _fetchConversations();
      if (_conversations.length > currentCount) {
        _showNewMessageNotification();
      }
    } catch (e) {
      print('Error checking for new messages: $e');
    }
  }

  void _showNewMessageNotification() {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.message, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'New messages received!',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
          action: SnackBarAction(
            label: 'View',
            textColor: Colors.white,
            onPressed: _scrollToTop,
          ),
        ),
      );
    }
  }

  Future<void> _refreshMessages() async {
    await _syncMessagesFromAdmin();
    await _fetchConversations();
  }

  Future<void> _syncMessagesFromAdmin() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;
    try {
      final userMessages = await supabase
          .from('user_messages')
          .select('id')
          .eq('user_id', userId);
      if (userMessages is List && userMessages.isEmpty) {
        final adminMessages = await supabase
            .from('admin_messages')
            .select('*')
            .eq('user_id', userId);
        if (adminMessages is List && adminMessages.isNotEmpty) {
          await supabase.from('user_messages').insert(adminMessages);
          print('Debug: Copied ${adminMessages.length} messages from admin_messages to user_messages');
        }
      }
    } catch (e) {
      print('Error syncing messages from admin: $e');
    }
  }

  Future<void> _fetchConversations() async {
    setState(() => _isLoading = true);
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) {
      setState(() {
        _conversations = [];
        _isLoading = false;
      });
      return;
    }
    try {
      final response = await supabase
          .from('user_messages')
          .select('''
            id,
            appointment_id,
            message,
            is_read,
            created_at,
            is_from_admin,
            is_archived,
            user_id
          ''')
          .eq('user_id', userId)
          .or('is_archived.is.false,is_archived.is.null')
          .order('created_at', ascending: false);
      if (response == null) {
        setState(() {
          _conversations = [];
          _isLoading = false;
        });
        return;
      }
      final Set<String> appointmentIds = response.map((msg) => msg['appointment_id'].toString()).toSet();
      final appointmentResponse = await supabase
          .from('grooming_appointments')
          .select('id, pet_name, pet_type, breed, preferred_date, preferred_time, status, special_requests_notes')
          .inFilter('id', appointmentIds.toList());
      final Map<String, Map<String, dynamic>> appointmentMap = {};
      for (final appointment in appointmentResponse) {
        appointmentMap[appointment['id'].toString()] = appointment;
      }
      final userResponse = await supabase
          .from('users')
          .select('id, full_name, email, contact_number')
          .eq('id', userId)
          .maybeSingle();
      final List<Map<String, dynamic>> enrichedResponse = response.map((msg) {
        final appointmentId = msg['appointment_id'].toString();
        return {
          ...msg,
          'grooming_appointments': appointmentMap[appointmentId] ?? {},
          'users': userResponse ?? {},
        };
      }).toList();
      final Map<String, Map<String, dynamic>> latest = {};
      final Map<String, List<Map<String, dynamic>>> allMessages = {};
      for (final msg in enrichedResponse) {
        final key = msg['appointment_id'].toString();
        if (!allMessages.containsKey(key)) {
          allMessages[key] = [];
        }
        allMessages[key]!.add(msg);
        if (!latest.containsKey(key)) {
          latest[key] = msg;
        }
      }
      for (final entry in latest.entries) {
        entry.value['all_messages'] = allMessages[entry.key] ?? [];
      }
      setState(() {
        _conversations = latest.values.toList();
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching conversations: $e');
      setState(() {
        _conversations = [];
        _isLoading = false;
      });
    }
  }

  Future<void> _checkAndSendReminders() async {
    if (_hasCheckedRemindersThisSession) return;
    if (_isCheckingReminders) return;
    _isCheckingReminders = true;
    _hasCheckedRemindersThisSession = true;
    try {
      final now = DateTime.now();
      final response = await supabase
          .from('grooming_appointments')
          .select('id, user_id, pet_name, preferred_date, preferred_time, status')
          .eq('status', 'Pending')
          .order('preferred_date', ascending: true);
      for (final appointment in response) {
        final appointmentDate = DateTime.parse(appointment['preferred_date']);
        final appointmentTime = appointment['preferred_time'];
        final timeParts = appointmentTime.split(':');
        final appointmentHour = int.parse(timeParts[0]);
        final appointmentMinute = int.parse(timeParts[1]);
        final appointmentDateTime = DateTime(
          appointmentDate.year,
          appointmentDate.month,
          appointmentDate.day,
          appointmentHour,
          appointmentMinute,
        );
        final reminderTime = appointmentDateTime.subtract(const Duration(hours: 24));
        final isWithin24Hours = now.isBefore(appointmentDateTime) && now.isAfter(reminderTime);
        if (isWithin24Hours) {
          final hasReminderBeenSent = await MessageTrackingUtils.hasReminderBeenSent(appointment['id']);
          if (hasReminderBeenSent) continue;
          final reminderMessage = 'REMINDER: Appointment approaching - Status still PENDING\n\n'
              'Pet: ${appointment['pet_name']}\n'
              'Date: ${DateFormat('MMMM dd, yyyy').format(appointmentDate)}\n'
              'Time: ${_formatTime(appointment['preferred_time'])}\n'
              'Please update the appointment status.';
          await MessageTrackingUtils.sendReminderIfNotSent(
            appointment['id'],
            appointment['user_id'],
            reminderMessage,
          );
        }
        if (now.isAfter(appointmentDateTime)) {
          final hasApologyBeenSent = await MessageTrackingUtils.hasApologyBeenSent(appointment['id']);
          if (hasApologyBeenSent) continue;
          const apologyMessage = "We're sorry! Your grooming appointment status was not updated before the scheduled time. We sincerely apologize for the inconvenience this may have caused. Please feel free to reach out to us or rebook your appointment at your convenience. Thank you for your understanding!";
          await MessageTrackingUtils.sendApologyIfNotSent(
            appointment['id'],
            appointment['user_id'],
            apologyMessage,
          );
        }
      }
    } catch (e) {
      print('Error checking for reminders: $e');
    } finally {
      _isCheckingReminders = false;
    }
  }

  Future<void> _checkRemindersOnPageActive() async {
    try {
      final now = DateTime.now();
      final response = await supabase
          .from('grooming_appointments')
          .select('id, user_id, pet_name, preferred_date, preferred_time, status')
          .eq('status', 'Pending')
          .order('preferred_date', ascending: true);
      for (final appointment in response) {
        final appointmentDate = DateTime.parse(appointment['preferred_date']);
        final appointmentTime = appointment['preferred_time'];
        final timeParts = appointmentTime.split(':');
        final appointmentHour = int.parse(timeParts[0]);
        final appointmentMinute = int.parse(timeParts[1]);
        final appointmentDateTime = DateTime(
          appointmentDate.year,
          appointmentDate.month,
          appointmentDate.day,
          appointmentHour,
          appointmentMinute,
        );
        final reminderTime = appointmentDateTime.subtract(const Duration(hours: 24));
        final isWithin24Hours = now.isBefore(appointmentDateTime) && now.isAfter(reminderTime);
        if (isWithin24Hours) {
          final hasReminderBeenSent = await MessageTrackingUtils.hasReminderBeenSent(appointment['id']);
          if (hasReminderBeenSent) continue;
          final reminderMessage = 'REMINDER: Appointment approaching - Status still PENDING\n\n'
              'Pet: ${appointment['pet_name']}\n'
              'Date: ${DateFormat('MMMM dd, yyyy').format(appointmentDate)}\n'
              'Time: ${_formatTime(appointment['preferred_time'])}\n'
              'Please update the appointment status.';
          await MessageTrackingUtils.sendReminderIfNotSent(
            appointment['id'],
            appointment['user_id'],
            reminderMessage,
          );
        }
      }
    } catch (e) {
      print('Error checking reminders on page active: $e');
    }
  }

  // --- UI Helpers ---
  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }

  String _formatTime(String time) {
    try {
      final timeOfDay = TimeOfDay(
        hour: int.parse(time.split(':')[0]),
        minute: int.parse(time.split(':')[1]),
      );
      return timeOfDay.format(context);
    } catch (e) {
      return time;
    }
  }

  String _formatTimestamp(String timestamp) {
    try {
      final utcDateTime = DateTime.parse(timestamp).toUtc();
      final localDateTime = utcDateTime.toLocal();
      final year = localDateTime.year.toString().padLeft(4, '0');
      final month = localDateTime.month.toString().padLeft(2, '0');
      final day = localDateTime.day.toString().padLeft(2, '0');
      int hour12 = localDateTime.hour;
      String amPm = 'AM';
      if (hour12 == 0) {
        hour12 = 12;
      } else if (hour12 > 12) {
        hour12 -= 12;
        amPm = 'PM';
      } else if (hour12 == 12) {
        amPm = 'PM';
      }
      final hour = hour12.toString().padLeft(2, '0');
      final minute = localDateTime.minute.toString().padLeft(2, '0');
      final second = localDateTime.second.toString().padLeft(2, '0');
      return '$year-$month-$day $hour:$minute:$second $amPm';
    } catch (e) {
      return 'Invalid date';
    }
  }

  bool _hasUnreadAdminMessages(Map<String, dynamic> conversation) {
    final allMessages = conversation['all_messages'] as List<Map<String, dynamic>>? ?? [];
    for (final msg in allMessages) {
      final isFromAdmin = msg['is_from_admin'] == true;
      final isUnread = msg['is_read'] == false || msg['is_read'] == null;
      if (isFromAdmin && isUnread) {
        return true;
      }
    }
    return false;
  }

  // --- Selection Mode Helpers ---
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
    setState(() => _selectedMessageIds.clear());
  }

  void _exitSelectionMode() {
    setState(() {
      _selectionMode = false;
      _selectedMessageIds.clear();
    });
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
      for (final conversationId in _selectedMessageIds) {
        final conversation = _conversations.firstWhere(
          (c) => c['id'].toString() == conversationId,
          orElse: () => <String, dynamic>{},
        );
        if (conversation.isEmpty) continue;
        final userId = conversation['users']?['id'] ?? conversation['user_id'];
        final appointmentId = conversation['appointment_id'];
        if (userId == null || appointmentId == null) continue;
        await supabase
            .from('user_messages')
            .delete()
            .eq('user_id', userId)
            .eq('appointment_id', appointmentId);
      }
      await Future.delayed(const Duration(milliseconds: 500));
      await _fetchConversations();
      if (mounted) {
        setState(() {
          _selectedMessageIds.clear();
          _selectionMode = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Successfully deleted $deletedCount conversation(s)'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('Error deleting messages: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete messages: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _archiveSelectedMessages() async {
    if (_selectedMessageIds.isEmpty) return;
    try {
      final archivedCount = _selectedMessageIds.length;
      for (final conversationId in _selectedMessageIds) {
        final conversation = _conversations.firstWhere(
          (c) => c['id'].toString() == conversationId,
          orElse: () => <String, dynamic>{},
        );
        if (conversation.isEmpty) continue;
        final userId = conversation['users']?['id'] ?? conversation['user_id'];
        final appointmentId = conversation['appointment_id'];
        if (userId == null || appointmentId == null) continue;
        final allMessages = await supabase
            .from('user_messages')
            .select('*')
            .eq('user_id', userId)
            .eq('appointment_id', appointmentId);
        if (allMessages is List && allMessages.isNotEmpty) {
          final nowIso = DateTime.now().toUtc().toIso8601String();
          final existingArchived = await supabase
              .from('user_messages_archive')
              .select('id')
              .inFilter('id', allMessages.map((m) => m['id']).toList());
          if (existingArchived is List && existingArchived.isNotEmpty) {
            final ids = allMessages.map((m) => m['id']).toList();
            await supabase
                .from('user_messages')
                .update({'is_archived': true})
                .inFilter('id', ids);
          } else {
            final archiveBatch = allMessages.map((msg) {
              final archiveData = Map<String, dynamic>.from(msg);
              archiveData['archived_at'] = nowIso;
              archiveData['is_archived'] = true;
              return archiveData;
            }).toList();
            await supabase.from('user_messages_archive').insert(archiveBatch);
            final ids = allMessages.map((m) => m['id']).toList();
            await supabase
                .from('user_messages')
                .update({'is_archived': true})
                .inFilter('id', ids);
          }
        }
      }
      await Future.delayed(const Duration(milliseconds: 500));
      await _fetchConversations();
      if (mounted) {
        setState(() {
          _selectedMessageIds.clear();
          _selectionMode = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Successfully archived $archivedCount conversation(s)'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('Error archiving messages: $e');
      if (mounted) {
        String errorMessage = 'Failed to archive messages';
        if (e.toString().contains('duplicate key')) {
          errorMessage = 'Messages are already archived';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
        );
      }
    }
  }

  // --- Navigation Helpers ---
  void _onItemTapped(int index) {
    _searchFocusNode.unfocus();
    setState(() => _selectedIndex = index);
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/home');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/grooming');
        break;
      case 2:
        break;
      case 3:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ProfilePage()),
        );
        break;
    }
  }

  void _goToChat(Map<String, dynamic> conversation) async {
    _searchFocusNode.unfocus();
    await _markMessagesAsRead(conversation['appointment_id']);
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ViewMessagesPage(
          appointmentId: conversation['appointment_id'],
        ),
      ),
    );
    if (result == true) {
      _fetchConversations();
    }
  }

  Future<void> _markMessagesAsRead(String appointmentId) async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId != null) {
        await supabase
            .from('admin_messages')
            .update({'is_read': true})
            .eq('user_id', userId)
            .eq('appointment_id', appointmentId)
            .eq('is_from_admin', true)
            .eq('is_read', false);
        await supabase
            .from('user_messages')
            .update({'is_read': true})
            .eq('user_id', userId)
            .eq('appointment_id', appointmentId)
            .eq('is_from_admin', true)
            .eq('is_read', false);
      }
    } catch (e) {
      print('Error marking messages as read: $e');
    }
  }

  // --- Build Method ---
  @override
  Widget build(BuildContext context) {
    final orange = const Color(0xFFF5A623);
    final filteredConversations = _searchQuery.isEmpty
        ? _conversations
        : _conversations.where((msg) {
            final searchLower = _searchQuery.toLowerCase();
            final message = msg['message']?.toString().toLowerCase() ?? '';
            final petName = msg['grooming_appointments']?['pet_name']?.toString().toLowerCase() ?? '';
            final petType = msg['grooming_appointments']?['pet_type']?.toString().toLowerCase() ?? '';
            final breed = msg['grooming_appointments']?['breed']?.toString().toLowerCase() ?? '';
            final appointmentDate = msg['grooming_appointments']?['preferred_date']?.toString().toLowerCase() ?? '';
            final appointmentTime = msg['grooming_appointments']?['preferred_time']?.toString().toLowerCase() ?? '';
            final status = msg['grooming_appointments']?['status']?.toString().toLowerCase() ?? '';
            final specialRequests = msg['grooming_appointments']?['special_requests_notes']?.toString().toLowerCase() ?? '';
            final userName = msg['users']?['full_name']?.toString().toLowerCase() ?? '';
            final userEmail = msg['users']?['email']?.toString().toLowerCase() ?? '';
            final userContact = msg['users']?['contact_number']?.toString().toLowerCase() ?? '';
            bool messageFound = false;
            final allMessages = msg['all_messages'] as List<Map<String, dynamic>>? ?? [];
            for (final chatMsg in allMessages) {
              final chatMessageText = chatMsg['message']?.toString().toLowerCase() ?? '';
              if (chatMessageText.contains(searchLower)) {
                messageFound = true;
                break;
              }
            }
            return message.contains(searchLower) ||
                petName.contains(searchLower) ||
                petType.contains(searchLower) ||
                breed.contains(searchLower) ||
                appointmentDate.contains(searchLower) ||
                appointmentTime.contains(searchLower) ||
                status.contains(searchLower) ||
                specialRequests.contains(searchLower) ||
                userName.contains(searchLower) ||
                userEmail.contains(searchLower) ||
                userContact.contains(searchLower) ||
                messageFound;
          }).toList();

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFFFF6E7), Colors.white],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                // --- Header ---
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Row(
                    children: [
                      Text(
                        'Messages',
                        style: GoogleFonts.poppins(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: orange,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.archive_outlined, color: Colors.blue),
                        tooltip: 'View Archive',
                        onPressed: () async {
                          _searchFocusNode.unfocus();
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const ArchivePage()),
                          );
                          if (result == true) {
                            _fetchConversations();
                          }
                        },
                      ),
                      if (_selectionMode) ...[
                        IconButton(
                          onPressed: _exitSelectionMode,
                          icon: const Icon(Icons.close, color: Colors.grey),
                        ),
                        Checkbox(
                          value: _selectedMessageIds.length == filteredConversations.length && filteredConversations.isNotEmpty,
                          onChanged: (selected) {
                            if (selected == true) {
                              _selectAllMessages(filteredConversations);
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
                ),

                // --- Search Bar ---
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: TextField(
                    focusNode: _searchFocusNode,
                    decoration: InputDecoration(
                      hintText: 'Search messages',
                      prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (value) {
                      setState(() => _searchQuery = value);
                    },
                  ),
                ),

                // --- Selection Mode Actions ---
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (_selectionMode && _selectedMessageIds.isNotEmpty) ...[
                        ElevatedButton.icon(
                          onPressed: _archiveSelectedMessages,
                          icon: const Icon(Icons.archive),
                          label: const Text('Archive'),
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

                // --- Messages List ---
                const SizedBox(height: 8),
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator(color: Color(0xFFF5A623)))
                      : filteredConversations.isEmpty
                          ? Center(
                              child: Text(
                                'No messages yet.',
                                style: GoogleFonts.poppins(color: Colors.grey[600], fontSize: 16),
                              ),
                            )
                          : RefreshIndicator(
                              onRefresh: _refreshMessages,
                              color: orange,
                              child: ListView.separated(
                                controller: _scrollController,
                                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                                itemCount: filteredConversations.length,
                                separatorBuilder: (context, i) => const SizedBox(height: 12),
                                itemBuilder: (context, i) {
                                  final msg = filteredConversations[i];
                                  return Column(
                                    children: [
                                      const SizedBox(height: 8), // Non-pressable SizedBox
                                      InkWell(
                                        onTap: _selectionMode
                                            ? () => _toggleMessageSelection(msg['id'].toString(), !_selectedMessageIds.contains(msg['id'].toString()))
                                            : () => _goToChat(msg),
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
                                              Container(
                                                padding: const EdgeInsets.all(8),
                                                decoration: BoxDecoration(
                                                  color: orange.withOpacity(0.1),
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                child: Icon(Icons.pets, color: orange, size: 20),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      'Appointment for ${msg['grooming_appointments']?['pet_name'] ?? 'Unknown Pet'}',
                                                      style: GoogleFonts.poppins(
                                                        fontSize: 16,
                                                        fontWeight: FontWeight.bold,
                                                        color: Colors.black87,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      msg['message'] ?? '',
                                                      style: GoogleFonts.poppins(
                                                        fontSize: 14,
                                                        color: Colors.grey[700],
                                                        height: 1.4,
                                                      ),
                                                      maxLines: 2,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      msg['created_at'] != null ? _formatTimestamp(msg['created_at']) : 'Unknown time',
                                                      style: GoogleFonts.poppins(
                                                        fontSize: 12,
                                                        color: Colors.grey[600],
                                                      ),
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      msg['created_at'] != null ? _formatDateTime(DateTime.parse(msg['created_at']).toUtc().toLocal()) : 'Unknown time',
                                                      style: GoogleFonts.poppins(
                                                        fontSize: 12,
                                                        color: Colors.grey[600],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              if (_hasUnreadAdminMessages(msg))
                                                Container(
                                                  margin: const EdgeInsets.only(left: 12, top: 8),
                                                  width: 10,
                                                  height: 10,
                                                  decoration: BoxDecoration(
                                                    color: orange,
                                                    shape: BoxShape.circle,
                                                  ),
                                                ),
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
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                ),
              ],
            ),
          ),
        ),

        // --- Bottom Navigation Bar ---
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: orange,
          unselectedItemColor: Colors.grey[400],
          showSelectedLabels: true,
          showUnselectedLabels: true,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.pets), label: 'Grooming'),
            BottomNavigationBarItem(icon: Icon(Icons.message_outlined), label: 'Messages'),
            BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
          ],
        ),

        // --- Floating Action Button ---
        floatingActionButton: _showScrollToTop
            ? FloatingActionButton(
                onPressed: _scrollToTop,
                backgroundColor: orange,
                foregroundColor: Colors.white,
                mini: true,
                child: const Icon(Icons.keyboard_arrow_up),
              )
            : null,
      ),
    );
  }
}
