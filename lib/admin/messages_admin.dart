
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:intl/intl.dart';
// import 'home_admin.dart';
// import 'bookings_admin.dart';
// // import 'shop_admin.dart';
// import 'viewmessages_admin.dart';
// import 'viewbookings_admin.dart';
// import 'archive_admin.dart';
// import 'settings_admin.dart';
// import '../utils/notification_utils.dart';
// import '../utils/message_tracking_utils.dart';
// import '../utils/auto_message_service.dart';
// import 'dart:async';

// class MessagesAdminPage extends StatefulWidget {
//   const MessagesAdminPage({super.key});

//   @override
// State<MessagesAdminPage> createState() => _MessagesAdminPageState();
// }

// class _MessagesAdminPageState extends State<MessagesAdminPage> {
//   final supabase = Supabase.instance.client;
//   late Future<List<Map<String, dynamic>>> _messagesFuture;
//   int _selectedIndex = 2;
//   String _searchQuery = '';
//   List<Map<String, dynamic>> _appointments = [];
//   bool _selectionMode = false;
//   Set<String> _selectedMessageIds = {};
//   final ScrollController _scrollController = ScrollController();
//   bool _showScrollToTop = false;
//   Timer? _reminderTimer;

//   @override
//   void initState() {
//     super.initState();
//     _messagesFuture = _fetchAdminMessages();
//     _fetchAppointments();
//     _checkAndSendReminders();
//     _startPeriodicReminderCheck();
//     _scrollController.addListener(_onScroll);
//   }

//   @override
//   void dispose() {
//     _scrollController.removeListener(_onScroll);
//     _scrollController.dispose();
//     _reminderTimer?.cancel();
//     super.dispose();
//   }

//   void _onScroll() {
//     if (_scrollController.position.pixels > 200) {
//       if (!_showScrollToTop) {
//         setState(() => _showScrollToTop = true);
//       }
//     } else {
//       if (_showScrollToTop) {
//         setState(() => _showScrollToTop = false);
//       }
//     }
//   }

//   void _scrollToTop() {
//     _scrollController.animateTo(
//       0,
//       duration: const Duration(milliseconds: 500),
//       curve: Curves.easeInOut,
//     );
//   }

//   void _startPeriodicReminderCheck() {
//     _reminderTimer = Timer.periodic(const Duration(hours: 1), (timer) {
//       _checkAndSendReminders();
//     });
//   }

//   Future<List<Map<String, dynamic>>> _fetchAdminMessages() async {
//     final response = await supabase
//         .from('admin_messages')
//         .select('id, user_id, appointment_id, message, is_read, created_at, is_from_admin, is_archived')
//         .or('is_archived.is.false,is_archived.is.null')
//         .order('created_at', ascending: false);

//     if (response is! List) return [];

//     final Map<String, Map<String, dynamic>> latestMessages = {};
//     for (final msg in response) {
//       final key = '${msg['user_id']}_${msg['appointment_id']}';
//       if (!latestMessages.containsKey(key)) {
//         latestMessages[key] = msg;
//       }
//     }
//     return latestMessages.values.toList();
//   }

//   Future<Map<String, dynamic>?> _fetchUserDetails(String userId) async {
//     return await supabase.from('users').select().eq('id', userId).maybeSingle();
//   }

//   void _onItemTapped(int index) {
//     setState(() => _selectedIndex = index);
//     switch (index) {
//       case 0:
//         Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeAdminPage()));
//         break;
//       case 1:
//         Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const BookingsAdminPage()));
//         break;
//       // case 2:
//       //   Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ShopAdminPage()));
//       //   break;
//       case 2:
//       // messages_admin page
//       break;
//       case 3:
//         Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const SettingsAdminPage()));
//         break;
//       default:
//         break;
//     }
//   }

//   // Future<void> _markMessageAsRead(String messageId) async {
//   //   await supabase.from('admin_messages').update({'is_read': true}).eq('id', messageId);
//   //   setState(() => _messagesFuture = _fetchAdminMessages());
//   // }

//   // void _goToViewMessages(Map<String, dynamic> message) async {
//   //   if (!(message['is_read'] ?? false)) {
//   //     await _markMessageAsRead(message['id']);
//   //   }
//   //   final result = await Navigator.push(
//   //     context,
//   //     MaterialPageRoute(builder: (_) => ViewMessagesAdmin(message: message)),
//   //   );
//   //   if (result == true) {
//   //     setState(() => _messagesFuture = _fetchAdminMessages());
//   //   }
//   // }

//   Future<void> _markMessageAsRead(String messageId) async {
//   // First perform the async operation
//   await supabase.from('admin_messages').update({'is_read': true}).eq('id', messageId);

//   // Then update the state
//   setState(() {
//     _messagesFuture = _fetchAdminMessages();
//   });
// }

// void _goToViewMessages(Map<String, dynamic> message) async {
//   // Mark as read first (without setState)
//   if (!(message['is_read'] ?? false)) {
//     await _markMessageAsRead(message['id']);
//   }

//   // Then navigate
//   final result = await Navigator.push(
//     context,
//     MaterialPageRoute(builder: (_) => ViewMessagesAdmin(message: message)),
//   );

//   // Update state after returning
//   if (result == true) {
//     setState(() {
//       _messagesFuture = _fetchAdminMessages();
//     });
//   }
// }

//   String _formatDateTime(DateTime dateTime) {
//     final now = DateTime.now();
//     final difference = now.difference(dateTime);
//     if (difference.inDays > 0) {
//       return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
//     } else if (difference.inHours > 0) {
//       return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
//     } else if (difference.inMinutes > 0) {
//       return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
//     } else {
//       return 'Just now';
//     }
//   }

//   String _formatTime(String time) {
//     try {
//       final timeOfDay = TimeOfDay(hour: int.parse(time.split(':')[0]), minute: int.parse(time.split(':')[1]));
//       return timeOfDay.format(context);
//     } catch (_) {
//       return time;
//     }
//   }

//   String _formatTimestamp(String timestamp) {
//     try {
//       final utcDateTime = DateTime.parse(timestamp).toUtc();
//       final localDateTime = utcDateTime.toLocal();
//       final year = localDateTime.year.toString().padLeft(4, '0');
//       final month = localDateTime.month.toString().padLeft(2, '0');
//       final day = localDateTime.day.toString().padLeft(2, '0');
//       int hour12 = localDateTime.hour;
//       String amPm = 'AM';
//       if (hour12 == 0) {
//         hour12 = 12;
//       } else if (hour12 > 12) {
//         hour12 -= 12;
//         amPm = 'PM';
//       } else if (hour12 == 12) {
//         amPm = 'PM';
//       }
//       final hour = hour12.toString().padLeft(2, '0');
//       final minute = localDateTime.minute.toString().padLeft(2, '0');
//       final second = localDateTime.second.toString().padLeft(2, '0');
//       return '$year-$month-$day $hour:$minute:$second $amPm';
//     } catch (_) {
//       return 'Invalid date';
//     }
//   }

//   String _formatMessagePreview(String message) {
//     return message.replaceAll('\\n', '\n').replaceAll('\\', '').replaceAll('\n', '\n');
//   }

//   bool _isAppointmentBookingMessage(String message) {
//     return message.startsWith('New grooming appointment booked by');
//   }

//   Future<void> _navigateToAppointmentDetails(String appointmentId) async {
//     try {
//       final response = await supabase.from('grooming_appointments').select().eq('id', appointmentId).maybeSingle();
//       if (response != null && mounted) {
//         Navigator.push(context, MaterialPageRoute(builder: (_) => ViewBookingsAdmin(appointment: response)));
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Error loading appointment details: $e'), backgroundColor: Colors.red),
//         );
//       }
//     }
//   }

//   Future<void> _fetchAppointments() async {
//     final response = await supabase.from('grooming_appointments').select(
//           'id, pet_name, breed, service_bath, service_haircut, service_nail_trim, service_ear_cleaning, preferred_date',
//         );
//     if (response is List) {
//       setState(() => _appointments = response.cast<Map<String, dynamic>>());
//     }
//   }

//   Future<void> _checkAndSendReminders() async {
//     try {
//       final now = DateTime.now();
//       final response = await supabase
//           .from('grooming_appointments')
//           .select('id, user_id, pet_name, preferred_date, preferred_time, status')
//           .eq('status', 'Pending');

//       if (response is! List || response.isEmpty) return;

//       for (final appointment in response) {
//         final appointmentDate = DateTime.parse(appointment['preferred_date']);
//         final timeParts = appointment['preferred_time'].split(':');
//         final appointmentDateTime = DateTime(
//           appointmentDate.year,
//           appointmentDate.month,
//           appointmentDate.day,
//           int.parse(timeParts[0]),
//           int.parse(timeParts[1]),
//         );
//         final reminderTime = appointmentDateTime.subtract(const Duration(hours: 24));

//         if (now.isBefore(appointmentDateTime) && now.isAfter(reminderTime)) {
//           final userResponse = await supabase.from('users').select('full_name').eq('id', appointment['user_id']).maybeSingle();
//           final userFullName = userResponse?['full_name'] ?? 'Unknown';
//           final reminderMessage = 'REMINDER: Appointment approaching - Status still PENDING\n\n'
//               'Pet: ${appointment['pet_name']}\n'
//               'Date: ${DateFormat('MMMM dd, yyyy').format(appointmentDate)}\n'
//               'Time: ${_formatTime(appointment['preferred_time'])}\n'
//               'Owner: $userFullName\n\n'
//               'Please update the appointment status.';
//           await MessageTrackingUtils.sendReminderIfNotSent(appointment['id'], appointment['user_id'], reminderMessage);
//         }

//         if (now.isAfter(appointmentDateTime)) {
//           const apologyMessage = "We're sorry! Your grooming appointment status was not updated before the scheduled time. "
//               "We sincerely apologize for the inconvenience this may have caused. "
//               "Please feel free to reach out to us or rebook your appointment at your convenience. "
//               "Thank you for your understanding!";
//           await MessageTrackingUtils.sendApologyIfNotSent(appointment['id'], appointment['user_id'], apologyMessage);
//         }
//       }
//     } catch (e) {
//       debugPrint('Error checking for reminders: $e');
//     }
//   }

//   Map<String, dynamic>? _findAppointment(String? appointmentId) {
//     if (appointmentId == null) return null;
//     try {
//       return _appointments.firstWhere((a) => a['id'].toString() == appointmentId.toString());
//     } catch (_) {
//       return null;
//     }
//   }

//   void _toggleSelectionMode(bool? value) {
//     setState(() {
//       _selectionMode = value ?? false;
//       if (!_selectionMode) _selectedMessageIds.clear();
//     });
//   }

//   void _toggleMessageSelection(String messageId, bool? selected) {
//     setState(() {
//       if (selected == true) {
//         _selectedMessageIds.add(messageId);
//       } else {
//         _selectedMessageIds.remove(messageId);
//       }
//     });
//   }

//   void _selectAllMessages(List<Map<String, dynamic>> visibleMessages) {
//     setState(() => _selectedMessageIds = visibleMessages.map((m) => m['id'].toString()).toSet());
//   }

//   void _deselectAllMessages() {
//     setState(() => _selectedMessageIds.clear());
//   }

//   void _exitSelectionMode() {
//     setState(() {
//       _selectionMode = false;
//       _selectedMessageIds.clear();
//     });
//   }

//   Future<void> _deleteSelectedMessages() async {
//     if (_selectedMessageIds.isEmpty) return;

//     final confirmed = await showDialog<bool>(
//       context: context,
//       builder: (_) => AlertDialog(
//         title: const Text('Delete Conversation'),
//         content: const Text('Are you sure you want to delete the selected conversation(s)? This action cannot be undone.'),
//         actions: [
//           TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
//           TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
//         ],
//       ),
//     );

//     if (confirmed != true) return;

//     try {
//       final deletedCount = _selectedMessageIds.length;
//       final currentMessages = await _fetchAdminMessages();

//       for (final messageId in _selectedMessageIds) {
//         final message = currentMessages.firstWhere((m) => m['id'].toString() == messageId, orElse: () => {});
//         if (message.isEmpty) continue;

//         final userId = message['user_id'];
//         final appointmentId = message['appointment_id'];
//         if (userId == null || appointmentId == null) continue;

//         await supabase.from('admin_messages').delete().eq('user_id', userId).eq('appointment_id', appointmentId);
//         await supabase.from('user_messages').delete().eq('user_id', userId).eq('appointment_id', appointmentId);
//         await supabase.from('admin_messages_archive').delete().eq('user_id', userId).eq('appointment_id', appointmentId);
//       }

//       setState(() {
//         _selectedMessageIds.clear();
//         _selectionMode = false;
//         _messagesFuture = _fetchAdminMessages();
//       });

//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Successfully deleted $deletedCount conversation(s)'), backgroundColor: Colors.green),
//         );
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Failed to delete messages: $e'), backgroundColor: Colors.red),
//         );
//       }
//     }
//   }

//   Future<void> _archiveSelectedMessages() async {
//     if (_selectedMessageIds.isEmpty) return;

//     try {
//       final archivedCount = _selectedMessageIds.length;
//       final currentMessages = await _fetchAdminMessages();
//       final nowIso = DateTime.now().toUtc().toIso8601String();

//       for (final messageId in _selectedMessageIds) {
//         final message = currentMessages.firstWhere((m) => m['id'].toString() == messageId, orElse: () => {});
//         if (message.isEmpty) continue;

//         final userId = message['user_id'];
//         final appointmentId = message['appointment_id'];
//         if (userId == null || appointmentId == null) continue;

//         final allMessages = await supabase.from('admin_messages').select('*').eq('user_id', userId).eq('appointment_id', appointmentId);
//         if (allMessages is! List || allMessages.isEmpty) continue;

//         final existingArchived = await supabase.from('admin_messages_archive').select('id').inFilter('id', allMessages.map((m) => m['id']).toList());
//         if (existingArchived is List && existingArchived.isNotEmpty) {
//           await supabase.from('admin_messages').update({'is_archived': true}).inFilter('id', allMessages.map((m) => m['id']).toList());
//         } else {
//           final archiveBatch = allMessages.map((msg) {
//             final archiveData = Map<String, dynamic>.from(msg);
//             archiveData['archived_at'] = nowIso;
//             archiveData['is_archived'] = true;
//             return archiveData;
//           }).toList();
//           await supabase.from('admin_messages_archive').insert(archiveBatch);
//           await supabase.from('admin_messages').update({'is_archived': true}).inFilter('id', allMessages.map((m) => m['id']).toList());
//         }
//       }

//       setState(() {
//         _selectedMessageIds.clear();
//         _selectionMode = false;
//         _messagesFuture = _fetchAdminMessages();
//       });

//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Successfully archived $archivedCount conversation(s)'), backgroundColor: Colors.green),
//         );
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text(e.toString().contains('duplicate key') ? 'Messages are already archived' : 'Failed to archive messages'), backgroundColor: Colors.red),
//         );
//       }
//     }
//   }

//   void _showMessageOptions(BuildContext context, Map<String, dynamic> message) {
//     showModalBottomSheet(
//       context: context,
//       builder: (_) => Container(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             ListTile(
//               leading: const Icon(Icons.archive, color: Colors.blue),
//               title: const Text('Archive'),
//               onTap: () {
//                 Navigator.pop(context);
//                 setState(() => _selectedMessageIds.add(message['id']));
//                 _archiveSelectedMessages();
//               },
//             ),
//             ListTile(
//               leading: const Icon(Icons.delete, color: Colors.red),
//               title: const Text('Delete'),
//               onTap: () {
//                 Navigator.pop(context);
//                 setState(() => _selectedMessageIds.add(message['id']));
//                 _deleteSelectedMessages();
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final orange = const Color(0xFFF5A623);
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: Container(
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(colors: [Color(0xFFFFF6E7), Colors.white], begin: Alignment.topCenter, end: Alignment.bottomCenter),
//         ),
//         child: SafeArea(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [


//               Expanded(
//                 child: FutureBuilder<List<Map<String, dynamic>>>(
//                   future: _messagesFuture,
//                   builder: (context, snapshot) {
//                     if (snapshot.connectionState == ConnectionState.waiting) {
//                       return const Center(child: CircularProgressIndicator(color: Color(0xFFF5A623)));
//                     }
//                     if (snapshot.hasError) {
//                       return Center(
//                         child: Column(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
//                             const SizedBox(height: 16),
//                             Text('Error loading messages', style: GoogleFonts.poppins(fontSize: 18, color: Colors.grey[600])),
//                           ],
//                         ),
//                       );
//                     }

//                     final messages = snapshot.data ?? [];
//                     final filteredMessages = _searchQuery.isEmpty
//                         ? messages
//                         : messages.where((msg) {
//                             final userName = msg['user_name']?.toString().toLowerCase() ?? '';
//                             final messageContent = (msg['message'] ?? '').toString().toLowerCase();
//                             final query = _searchQuery.toLowerCase();
//                             final appointment = _findAppointment(msg['appointment_id']);
//                             final petName = (appointment?['pet_name'] ?? '').toString().toLowerCase();
//                             final breed = (appointment?['breed'] ?? '').toString().toLowerCase();
//                             final services = <String>[
//                               if (appointment?['service_bath'] == true) 'bath',
//                               if (appointment?['service_haircut'] == true) 'haircut',
//                               if (appointment?['service_nail_trim'] == true) 'nail trim',
//                               if (appointment?['service_ear_cleaning'] == true) 'ear cleaning',
//                             ];
//                             final servicesString = services.join(', ').toLowerCase();
//                             final dateString = (appointment?['preferred_date'] ?? '').toString().toLowerCase();
//                             return userName.contains(query) ||
//                                    messageContent.contains(query) ||
//                                    petName.contains(query) ||
//                                    breed.contains(query) ||
//                                    servicesString.contains(query) ||
//                                    dateString.contains(query);
//                           }).toList();

//                     return Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Padding(
//                           padding: const EdgeInsets.all(24.0),
//                           child: Row(
//                             children: [
//                               Text('Messages', style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.bold, color: orange)),
//                               const Spacer(),
//                               IconButton(
//                                 icon: const Icon(Icons.archive_outlined, color: Colors.blue),
//                                 tooltip: 'View Archive',
//                                 onPressed: () async {
//                                   final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => const ArchiveAdminPage()));
//                                   if (result == true) setState(() => _messagesFuture = _fetchAdminMessages());
//                                 },
//                               ),
//                               if (_selectionMode) ...[
//                                 IconButton(onPressed: _exitSelectionMode, icon: const Icon(Icons.close, color: Colors.grey)),
//                                 Checkbox(
//                                   value: _selectedMessageIds.length == filteredMessages.length && filteredMessages.isNotEmpty,
//                                   onChanged: (selected) => selected == true ? _selectAllMessages(filteredMessages) : _deselectAllMessages(),
//                                 ),
//                               ] else
//                                 TextButton(
//                                   onPressed: () => _toggleSelectionMode(true),
//                                   child: Text('Select', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500, color: orange)),
//                                 ),
//                             ],
//                           ),
//                         ),
//                         Padding(
//                           padding: const EdgeInsets.symmetric(horizontal: 24.0),
//                           child: TextField(
//                             decoration: InputDecoration(
//                               hintText: 'Search messages',
//                               hintStyle: TextStyle(fontSize: 14, color: Colors.grey[500]),
//                               prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
//                               suffixIcon: _searchQuery.isNotEmpty
//                                   ? IconButton(icon: Icon(Icons.clear, color: Colors.grey[400]), onPressed: () => setState(() => _searchQuery = ''))
//                                   : null,
//                               filled: true,
//                               fillColor: Colors.grey[100],
//                               contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
//                               border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
//                             ),
//                             onChanged: (value) => setState(() => _searchQuery = value),
//                           ),
//                         ),
//                         Padding(
//                           padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.end,
//                             children: [
//                               if (_selectionMode && _selectedMessageIds.isNotEmpty) ...[
//                                 ElevatedButton.icon(
//                                   onPressed: _archiveSelectedMessages,
//                                   icon: const Icon(Icons.archive),
//                                   label: const Text('Archive'),
//                                   style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.withOpacity(0.15), foregroundColor: Colors.blue, elevation: 0, padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
//                                 ),
//                                 const SizedBox(width: 8),
//                                 ElevatedButton.icon(
//                                   onPressed: _deleteSelectedMessages,
//                                   icon: const Icon(Icons.delete),
//                                   label: const Text('Delete'),
//                                   style: ElevatedButton.styleFrom(backgroundColor: Colors.red.withOpacity(0.15), foregroundColor: Colors.red, elevation: 0, padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
//                                 ),
//                               ],
//                             ],
//                           ),
//                         ),
//                         const SizedBox(height: 8),
//                         Expanded(
//                           child: filteredMessages.isEmpty
//                               ? Center(
//                                   child: Column(
//                                     mainAxisAlignment: MainAxisAlignment.center,
//                                     children: [
//                                       Icon(Icons.message_outlined, size: 64, color: Colors.grey[400]),
//                                       const SizedBox(height: 16),
//                                       Text('No messages found', style: GoogleFonts.poppins(fontSize: 18, color: Colors.grey[600])),
//                                     ],
//                                   ),
//                                 )
//                               : ListView.separated(
//                                   controller: _scrollController,
//                                   padding: const EdgeInsets.symmetric(horizontal: 24.0),
//                                   itemCount: filteredMessages.length,
//                                   separatorBuilder: (_, __) => const SizedBox(height: 16),
//                                   itemBuilder: (context, index) {
//                                     final msg = filteredMessages[index];
//                                     final isRead = msg['is_read'] ?? false;
//                                     final val = msg['is_from_admin'];
//                                     final isFromAdmin = val is bool
//                                         ? val
//                                         : val is String
//                                             ? val.toLowerCase() == 'true' || val == '1'
//                                             : val is int
//                                                 ? val == 1
//                                                 : false;
//                                     return FutureBuilder<Map<String, dynamic>?>(
//                                       future: _fetchUserDetails(msg['user_id']),
//                                       builder: (context, userSnapshot) {
//                                         final userName = userSnapshot.data?['full_name'] ?? '';
//                                         msg['user_name'] = userName;
//                                         final appointment = _findAppointment(msg['appointment_id']);
//                                         return GestureDetector(
//                                           onTap: () => _goToViewMessages(msg),
//                                           child: Container(
//                                             padding: const EdgeInsets.all(20.0),
//                                             decoration: BoxDecoration(
//                                               color: Colors.white,
//                                               borderRadius: BorderRadius.circular(16),
//                                               boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
//                                             ),
//                                             child: Row(
//                                               crossAxisAlignment: CrossAxisAlignment.start,
//                                               children: [
//                                                 Container(
//                                                   padding: const EdgeInsets.all(8),
//                                                   decoration: BoxDecoration(color: orange.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
//                                                   child: const Icon(Icons.pets, color: Color(0xFFF5A623), size: 20),
//                                                 ),
//                                                 const SizedBox(width: 12),
//                                                 Expanded(
//                                                   child: Column(
//                                                     crossAxisAlignment: CrossAxisAlignment.start,
//                                                     children: [
//                                                       if (appointment != null && appointment['pet_name'] != null)
//                                                         Text('Appointment for ${appointment['pet_name']}', style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w500, color: Colors.grey[600])),
//                                                       if (userName.isNotEmpty)
//                                                         Text(userName, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
//                                                       const SizedBox(height: 4),
//                                                       Text(_formatMessagePreview(msg['message'] ?? ''), style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[700], height: 1.4), maxLines: 2, overflow: TextOverflow.ellipsis),
//                                                       const SizedBox(height: 4),
//                                                       Text(msg['created_at'] != null ? _formatTimestamp(msg['created_at']) : 'Unknown time', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600])),
//                                                       Text(msg['created_at'] != null ? _formatDateTime(DateTime.parse(msg['created_at']).toLocal()) : 'Unknown time', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600])),
//                                                     ],
//                                                   ),
//                                                 ),
//                                                 if (!isRead && !isFromAdmin)
//                                                   Container(
//                                                     margin: const EdgeInsets.only(left: 12, top: 8),
//                                                     width: 10,
//                                                     height: 10,
//                                                     decoration: const BoxDecoration(color: Color(0xFFF5A623), shape: BoxShape.circle),
//                                                   ),
//                                                 if (_selectionMode)
//                                                   Padding(
//                                                     padding: const EdgeInsets.only(left: 8.0, top: 8.0),
//                                                     child: Checkbox(
//                                                       value: _selectedMessageIds.contains(msg['id']),
//                                                       onChanged: (selected) => _toggleMessageSelection(msg['id'], selected),
//                                                     ),
//                                                   ),
//                                               ],
//                                             ),
//                                           ),
//                                         );
//                                       },
//                                     );
//                                   },
//                                 ),
//                         ),
//                       ],
//                     );
//                   },
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//       bottomNavigationBar: Container(
//         decoration: BoxDecoration(boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, -5))]),
//         child: BottomNavigationBar(
//           items: const [
//             BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
//             BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Bookings'),
//             // BottomNavigationBarItem(icon: Icon(Icons.shopping_bag), label: 'Shop'),
//             BottomNavigationBarItem(icon: Icon(Icons.message), label: 'Messages'),
//             BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
//           ],
//           currentIndex: _selectedIndex,
//           selectedItemColor: orange,
//           unselectedItemColor: Colors.grey,
//           onTap: _onItemTapped,
//           type: BottomNavigationBarType.fixed,
//           backgroundColor: Colors.white,
//         ),
//       ),
//       floatingActionButton: _showScrollToTop
//           ? FloatingActionButton(
//               onPressed: _scrollToTop,
//               backgroundColor: orange,
//               foregroundColor: Colors.white,
//               mini: true,
//               child: const Icon(Icons.keyboard_arrow_up),
//             )
//           : null,
//     );
//   }
// }

// ---

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'home_admin.dart';
import 'bookings_admin.dart';
import 'viewmessages_admin.dart';
import 'viewbookings_admin.dart';
import 'archive_admin.dart';
import 'settings_admin.dart';
import '../utils/notification_utils.dart';
import '../utils/message_tracking_utils.dart';
import '../utils/auto_message_service.dart';
import 'dart:async';

class MessagesAdminPage extends StatefulWidget {
  const MessagesAdminPage({super.key});

  @override
  State<MessagesAdminPage> createState() => _MessagesAdminPageState();
}

class _MessagesAdminPageState extends State<MessagesAdminPage> {
  final supabase = Supabase.instance.client;
  late Future<List<Map<String, dynamic>>> _messagesFuture;
  int _selectedIndex = 2;
  String _searchQuery = '';
  List<Map<String, dynamic>> _appointments = [];
  bool _selectionMode = false;
  Set<String> _selectedMessageIds = {};
  final ScrollController _scrollController = ScrollController();
  bool _showScrollToTop = false;
  Timer? _reminderTimer;

  @override
  void initState() {
    super.initState();
    _messagesFuture = _fetchAdminMessages();
    _fetchAppointments();
    _checkAndSendReminders();
    _startPeriodicReminderCheck();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _reminderTimer?.cancel();
    super.dispose();
  }

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
    _reminderTimer = Timer.periodic(const Duration(hours: 1), (timer) {
      _checkAndSendReminders();
    });
  }

  Future<List<Map<String, dynamic>>> _fetchAdminMessages() async {
    final response = await supabase
        .from('admin_messages')
        .select('id, user_id, appointment_id, message, is_read, created_at, is_from_admin, is_archived')
        .or('is_archived.is.false,is_archived.is.null')
        .order('created_at', ascending: false);
    if (response is! List) return [];
    final Map<String, Map<String, dynamic>> latestMessages = {};
    for (final msg in response) {
      final key = '${msg['user_id']}_${msg['appointment_id']}';
      if (!latestMessages.containsKey(key)) {
        latestMessages[key] = msg;
      }
    }
    return latestMessages.values.toList();
  }

  Future<Map<String, dynamic>?> _fetchUserDetails(String userId) async {
    return await supabase.from('users').select().eq('id', userId).maybeSingle();
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
    switch (index) {
      case 0:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeAdminPage()));
        break;
      case 1:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const BookingsAdminPage()));
        break;
      case 2:
        break;
      case 3:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const SettingsAdminPage()));
        break;
      default:
        break;
    }
  }

  Future<void> _markMessageAsRead(String messageId) async {
    await supabase.from('admin_messages').update({'is_read': true}).eq('id', messageId);
    setState(() {
      _messagesFuture = _fetchAdminMessages();
    });
  }

  void _goToViewMessages(Map<String, dynamic> message) async {
    if (!(message['is_read'] ?? false)) {
      await _markMessageAsRead(message['id']);
    }
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ViewMessagesAdmin(message: message)),
    );
    if (result == true) {
      setState(() {
        _messagesFuture = _fetchAdminMessages();
      });
    }
  }

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
      final timeOfDay = TimeOfDay(hour: int.parse(time.split(':')[0]), minute: int.parse(time.split(':')[1]));
      return timeOfDay.format(context);
    } catch (_) {
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
    } catch (_) {
      return 'Invalid date';
    }
  }

  String _formatMessagePreview(String message) {
    return message.replaceAll('\\n', '\n').replaceAll('\\', '').replaceAll('\n', '\n');
  }

  bool _isAppointmentBookingMessage(String message) {
    return message.startsWith('New grooming appointment booked by');
  }

  Future<void> _navigateToAppointmentDetails(String appointmentId) async {
    try {
      final response = await supabase.from('grooming_appointments').select().eq('id', appointmentId).maybeSingle();
      if (response != null && mounted) {
        Navigator.push(context, MaterialPageRoute(builder: (_) => ViewBookingsAdmin(appointment: response)));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading appointment details: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _fetchAppointments() async {
    final response = await supabase.from('grooming_appointments').select(
          'id, pet_name, breed, service_bath, service_haircut, service_nail_trim, service_ear_cleaning, preferred_date',
        );
    if (response is List) {
      setState(() => _appointments = response.cast<Map<String, dynamic>>());
    }
  }

  Future<void> _checkAndSendReminders() async {
    try {
      final now = DateTime.now();
      final response = await supabase
          .from('grooming_appointments')
          .select('id, user_id, pet_name, preferred_date, preferred_time, status')
          .eq('status', 'Pending');
      if (response is! List || response.isEmpty) return;
      for (final appointment in response) {
        final appointmentDate = DateTime.parse(appointment['preferred_date']);
        final timeParts = appointment['preferred_time'].split(':');
        final appointmentDateTime = DateTime(
          appointmentDate.year,
          appointmentDate.month,
          appointmentDate.day,
          int.parse(timeParts[0]),
          int.parse(timeParts[1]),
        );
        final reminderTime = appointmentDateTime.subtract(const Duration(hours: 24));
        if (now.isBefore(appointmentDateTime) && now.isAfter(reminderTime)) {
          final userResponse = await supabase.from('users').select('full_name').eq('id', appointment['user_id']).maybeSingle();
          final userFullName = userResponse?['full_name'] ?? 'Unknown';
          final reminderMessage = 'REMINDER: Appointment approaching - Status still PENDING\n\n'
              'Pet: ${appointment['pet_name']}\n'
              'Date: ${DateFormat('MMMM dd, yyyy').format(appointmentDate)}\n'
              'Time: ${_formatTime(appointment['preferred_time'])}\n'
              'Owner: $userFullName\n\n'
              'Please update the appointment status.';
          await MessageTrackingUtils.sendReminderIfNotSent(appointment['id'], appointment['user_id'], reminderMessage);
        }
        if (now.isAfter(appointmentDateTime)) {
          const apologyMessage = "We're sorry! Your grooming appointment status was not updated before the scheduled time. "
              "We sincerely apologize for the inconvenience this may have caused. "
              "Please feel free to reach out to us or rebook your appointment at your convenience. "
              "Thank you for your understanding!";
          await MessageTrackingUtils.sendApologyIfNotSent(appointment['id'], appointment['user_id'], apologyMessage);
        }
      }
    } catch (e) {
      debugPrint('Error checking for reminders: $e');
    }
  }

  Map<String, dynamic>? _findAppointment(String? appointmentId) {
    if (appointmentId == null) return null;
    try {
      return _appointments.firstWhere((a) => a['id'].toString() == appointmentId.toString());
    } catch (_) {
      return null;
    }
  }

  void _toggleSelectionMode(bool? value) {
    setState(() {
      _selectionMode = value ?? false;
      if (!_selectionMode) _selectedMessageIds.clear();
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
    setState(() => _selectedMessageIds = visibleMessages.map((m) => m['id'].toString()).toSet());
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
      builder: (_) => AlertDialog(
        title: const Text('Delete Conversation'),
        content: const Text('Are you sure you want to delete the selected conversation(s)? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      final deletedCount = _selectedMessageIds.length;
      final currentMessages = await _fetchAdminMessages();
      for (final messageId in _selectedMessageIds) {
        final message = currentMessages.firstWhere((m) => m['id'].toString() == messageId, orElse: () => {});
        if (message.isEmpty) continue;
        final userId = message['user_id'];
        final appointmentId = message['appointment_id'];
        if (userId == null || appointmentId == null) continue;
        await supabase.from('admin_messages').delete().eq('user_id', userId).eq('appointment_id', appointmentId);
        await supabase.from('user_messages').delete().eq('user_id', userId).eq('appointment_id', appointmentId);
        await supabase.from('admin_messages_archive').delete().eq('user_id', userId).eq('appointment_id', appointmentId);
      }
      setState(() {
        _selectedMessageIds.clear();
        _selectionMode = false;
        _messagesFuture = _fetchAdminMessages();
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Successfully deleted $deletedCount conversation(s)'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
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
      final currentMessages = await _fetchAdminMessages();
      final nowIso = DateTime.now().toUtc().toIso8601String();
      for (final messageId in _selectedMessageIds) {
        final message = currentMessages.firstWhere((m) => m['id'].toString() == messageId, orElse: () => {});
        if (message.isEmpty) continue;
        final userId = message['user_id'];
        final appointmentId = message['appointment_id'];
        if (userId == null || appointmentId == null) continue;
        final allMessages = await supabase.from('admin_messages').select('*').eq('user_id', userId).eq('appointment_id', appointmentId);
        if (allMessages is! List || allMessages.isEmpty) continue;
        final existingArchived = await supabase.from('admin_messages_archive').select('id').inFilter('id', allMessages.map((m) => m['id']).toList());
        if (existingArchived is List && existingArchived.isNotEmpty) {
          await supabase.from('admin_messages').update({'is_archived': true}).inFilter('id', allMessages.map((m) => m['id']).toList());
        } else {
          final archiveBatch = allMessages.map((msg) {
            final archiveData = Map<String, dynamic>.from(msg);
            archiveData['archived_at'] = nowIso;
            archiveData['is_archived'] = true;
            return archiveData;
          }).toList();
          await supabase.from('admin_messages_archive').insert(archiveBatch);
          await supabase.from('admin_messages').update({'is_archived': true}).inFilter('id', allMessages.map((m) => m['id']).toList());
        }
      }
      setState(() {
        _selectedMessageIds.clear();
        _selectionMode = false;
        _messagesFuture = _fetchAdminMessages();
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Successfully archived $archivedCount conversation(s)'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().contains('duplicate key') ? 'Messages are already archived' : 'Failed to archive messages'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _showMessageOptions(BuildContext context, Map<String, dynamic> message) {
    showModalBottomSheet(
      context: context,
      builder: (_) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.archive, color: Colors.blue),
              title: const Text('Archive'),
              onTap: () {
                Navigator.pop(context);
                setState(() => _selectedMessageIds.add(message['id']));
                _archiveSelectedMessages();
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete'),
              onTap: () {
                Navigator.pop(context);
                setState(() => _selectedMessageIds.add(message['id']));
                _deleteSelectedMessages();
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final orange = const Color(0xFFF5A623);
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(colors: [Color(0xFFFFF6E7), Colors.white], begin: Alignment.topCenter, end: Alignment.bottomCenter),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: _messagesFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator(color: Color(0xFFF5A623)));
                    }
                    if (snapshot.hasError) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text('Error loading messages', style: GoogleFonts.poppins(fontSize: 18, color: Colors.grey[600])),
                          ],
                        ),
                      );
                    }
                    final messages = snapshot.data ?? [];
                    final filteredMessages = _searchQuery.isEmpty
                        ? messages
                        : messages.where((msg) {
                            final userName = msg['user_name']?.toString().toLowerCase() ?? '';
                            final messageContent = (msg['message'] ?? '').toString().toLowerCase();
                            final query = _searchQuery.toLowerCase();
                            final appointment = _findAppointment(msg['appointment_id']);
                            final petName = (appointment?['pet_name'] ?? '').toString().toLowerCase();
                            final breed = (appointment?['breed'] ?? '').toString().toLowerCase();
                            final services = <String>[
                              if (appointment?['service_bath'] == true) 'bath',
                              if (appointment?['service_haircut'] == true) 'haircut',
                              if (appointment?['service_nail_trim'] == true) 'nail trim',
                              if (appointment?['service_ear_cleaning'] == true) 'ear cleaning',
                            ];
                            final servicesString = services.join(', ').toLowerCase();
                            final dateString = (appointment?['preferred_date'] ?? '').toString().toLowerCase();
                            return userName.contains(query) ||
                                   messageContent.contains(query) ||
                                   petName.contains(query) ||
                                   breed.contains(query) ||
                                   servicesString.contains(query) ||
                                   dateString.contains(query);
                          }).toList();
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Row(
                            children: [
                              Text('Messages', style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.bold, color: orange)),
                              const Spacer(),
                              IconButton(
                                icon: const Icon(Icons.archive_outlined, color: Colors.blue),
                                tooltip: 'View Archive',
                                onPressed: () async {
                                  final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => const ArchiveAdminPage()));
                                  if (result == true) setState(() => _messagesFuture = _fetchAdminMessages());
                                },
                              ),
                              if (_selectionMode) ...[
                                IconButton(onPressed: _exitSelectionMode, icon: const Icon(Icons.close, color: Colors.grey)),
                                Checkbox(
                                  value: _selectedMessageIds.length == filteredMessages.length && filteredMessages.isNotEmpty,
                                  onChanged: (selected) => selected == true ? _selectAllMessages(filteredMessages) : _deselectAllMessages(),
                                ),
                              ] else
                                TextButton(
                                  onPressed: () => _toggleSelectionMode(true),
                                  child: Text('Select', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500, color: orange)),
                                ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'Search messages',
                              hintStyle: TextStyle(fontSize: 14, color: Colors.grey[500]),
                              prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                              suffixIcon: _searchQuery.isNotEmpty
                                  ? IconButton(icon: Icon(Icons.clear, color: Colors.grey[400]), onPressed: () => setState(() => _searchQuery = ''))
                                  : null,
                              filled: true,
                              fillColor: Colors.grey[100],
                              contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                            ),
                            onChanged: (value) => setState(() => _searchQuery = value),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              if (_selectionMode && _selectedMessageIds.isNotEmpty) ...[
                                ElevatedButton.icon(
                                  onPressed: _archiveSelectedMessages,
                                  icon: const Icon(Icons.archive),
                                  label: const Text('Archive'),
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.withOpacity(0.15), foregroundColor: Colors.blue, elevation: 0, padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton.icon(
                                  onPressed: _deleteSelectedMessages,
                                  icon: const Icon(Icons.delete),
                                  label: const Text('Delete'),
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red.withOpacity(0.15), foregroundColor: Colors.red, elevation: 0, padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: RefreshIndicator(
                            color: orange,
                            onRefresh: () async {
                              setState(() {
                                _messagesFuture = _fetchAdminMessages();
                              });
                              await _fetchAppointments();
                            },
                            child: filteredMessages.isEmpty
                                ? Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.message_outlined, size: 64, color: Colors.grey[400]),
                                        const SizedBox(height: 16),
                                        Text('No messages found', style: GoogleFonts.poppins(fontSize: 18, color: Colors.grey[600])),
                                      ],
                                    ),
                                  )
                                : ListView.separated(
                                    controller: _scrollController,
                                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                                    itemCount: filteredMessages.length,
                                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                                    itemBuilder: (context, index) {
                                      final msg = filteredMessages[index];
                                      final isRead = msg['is_read'] ?? false;
                                      final val = msg['is_from_admin'];
                                      final isFromAdmin = val is bool
                                          ? val
                                          : val is String
                                              ? val.toLowerCase() == 'true' || val == '1'
                                              : val is int
                                                  ? val == 1
                                                  : false;
                                      return FutureBuilder<Map<String, dynamic>?>(
                                        future: _fetchUserDetails(msg['user_id']),
                                        builder: (context, userSnapshot) {
                                          final userName = userSnapshot.data?['full_name'] ?? '';
                                          msg['user_name'] = userName;
                                          final appointment = _findAppointment(msg['appointment_id']);
                                          return GestureDetector(
                                            onTap: () => _goToViewMessages(msg),
                                            child: Container(
                                              padding: const EdgeInsets.all(20.0),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.circular(16),
                                                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
                                              ),
                                              child: Row(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Container(
                                                    padding: const EdgeInsets.all(8),
                                                    decoration: BoxDecoration(color: orange.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                                                    child: const Icon(Icons.pets, color: Color(0xFFF5A623), size: 20),
                                                  ),
                                                  const SizedBox(width: 12),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        if (appointment != null && appointment['pet_name'] != null)
                                                          Text('Appointment for ${appointment['pet_name']}', style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w500, color: Colors.grey[600])),
                                                        if (userName.isNotEmpty)
                                                          Text(userName, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
                                                        const SizedBox(height: 4),
                                                        Text(_formatMessagePreview(msg['message'] ?? ''), style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[700], height: 1.4), maxLines: 2, overflow: TextOverflow.ellipsis),
                                                        const SizedBox(height: 4),
                                                        Text(msg['created_at'] != null ? _formatTimestamp(msg['created_at']) : 'Unknown time', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600])),
                                                        Text(msg['created_at'] != null ? _formatDateTime(DateTime.parse(msg['created_at']).toLocal()) : 'Unknown time', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600])),
                                                      ],
                                                    ),
                                                  ),
                                                  if (!isRead && !isFromAdmin)
                                                    Container(
                                                      margin: const EdgeInsets.only(left: 12, top: 8),
                                                      width: 10,
                                                      height: 10,
                                                      decoration: const BoxDecoration(color: Color(0xFFF5A623), shape: BoxShape.circle),
                                                    ),
                                                  if (_selectionMode)
                                                    Padding(
                                                      padding: const EdgeInsets.only(left: 8.0, top: 8.0),
                                                      child: Checkbox(
                                                        value: _selectedMessageIds.contains(msg['id']),
                                                        onChanged: (selected) => _toggleMessageSelection(msg['id'], selected),
                                                      ),
                                                    ),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, -5))]),
        child: BottomNavigationBar(
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
            BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Bookings'),
            BottomNavigationBarItem(icon: Icon(Icons.message), label: 'Messages'),
            BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: orange,
          unselectedItemColor: Colors.grey,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
        ),
      ),
      floatingActionButton: _showScrollToTop
          ? FloatingActionButton(
              onPressed: _scrollToTop,
              backgroundColor: orange,
              foregroundColor: Colors.white,
              mini: true,
              child: const Icon(Icons.keyboard_arrow_up),
            )
          : null,
    );
  }
}
