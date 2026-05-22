

// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:intl/intl.dart';
// import 'viewbookings_admin.dart';

// class ViewMessagesAdmin extends StatefulWidget {
//   final Map<String, dynamic> message;

//   const ViewMessagesAdmin({Key? key, required this.message}) : super(key: key);

//   @override
//   _ViewMessagesAdminState createState() => _ViewMessagesAdminState();
// }

// class _ViewMessagesAdminState extends State<ViewMessagesAdmin> {
//   final supabase = Supabase.instance.client;
//   Map<String, dynamic>? userDetails;
//   Map<String, dynamic>? appointmentDetails;
//   bool isLoading = true;
//   bool hasError = false;
//   final TextEditingController _messageController = TextEditingController();
//   List<Map<String, dynamic>> chatMessages = [];
//   bool isSendingMessage = false;
//   final ScrollController _scrollController = ScrollController();
//   int? _selectedMessageIndex;

//   @override
//   void initState() {
//     super.initState();
//     _fetchDetails();
//     _fetchChatMessages();
//   }

//   @override
//   void dispose() {
//     _messageController.dispose();
//     _scrollController.dispose();
//     super.dispose();
//   }

//   Future<void> _fetchDetails() async {
//     if (!mounted) return;
//     setState(() {
//       isLoading = true;
//       hasError = false;
//     });
//     try {
//       final userResp = await supabase
//           .from('users')
//           .select()
//           .eq('id', widget.message['user_id'])
//           .maybeSingle();
//       final appointmentResp = await supabase
//           .from('grooming_appointments')
//           .select()
//           .eq('id', widget.message['appointment_id'])
//           .maybeSingle();
//       if (mounted) {
//         setState(() {
//           userDetails = userResp;
//           appointmentDetails = appointmentResp;
//           isLoading = false;
//         });
//       }
//     } catch (e) {
//       if (mounted) {
//         setState(() {
//           hasError = true;
//           isLoading = false;
//         });
//       }
//     }
//   }

//   Future<void> _fetchChatMessages() async {
//     if (!mounted) return;
//     try {
//       final response = await supabase
//           .from('admin_messages')
//           .select('*')
//           .eq('user_id', widget.message['user_id'])
//           .eq('appointment_id', widget.message['appointment_id'])
//           .order('created_at', ascending: true);
//       if (mounted) {
//         setState(() {
//           chatMessages = response is List ? List<Map<String, dynamic>>.from(response) : [];
//           isLoading = false;
//         });
//         // Scroll to bottom after messages are loaded
//         WidgetsBinding.instance.addPostFrameCallback((_) {
//           if (_scrollController.hasClients) {
//             _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
//           }
//         });
//       }
//     } catch (e) {
//       debugPrint('Error fetching chat messages: $e');
//     }
//   }

//   Future<void> _sendMessage() async {
//     if (_messageController.text.trim().isEmpty || isSendingMessage) return;
//     if (!mounted) return;

//     setState(() => isSendingMessage = true);
//     try {
//       final messageText = _messageController.text.trim();
//       final data = {
//         'user_id': widget.message['user_id'],
//         'appointment_id': widget.message['appointment_id'],
//         'message': messageText,
//         'is_from_admin': true,
//         'is_read': false,
//       };
//       await supabase.from('admin_messages').insert(data);
//       await supabase.from('user_messages').insert(data);

//       // Update appointment status if the message is the apology message
//       if (messageText ==
//           "We're sorry! Your grooming appointment status was not updated before the scheduled time. "
//           "We sincerely apologize for any inconvenience this may have caused. "
//           "Please feel free to reach out to us or rebook your appointment at your convenience. "
//           "Thank you for understanding!") {
//         await supabase
//             .from('grooming_appointments')
//             .update({'status': 'Cancelled'})
//             .eq('id', widget.message['appointment_id']);
//         await _fetchDetails(); // Refresh appointment details
//       }

//       _messageController.clear();
//       await _fetchChatMessages();
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Failed to send message: $e'),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     } finally {
//       if (mounted) {
//         setState(() => isSendingMessage = false);
//       }
//     }
//   }

//   void _showDetailsDialog() {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text('Appointment Details', style: GoogleFonts.poppins()),
//         content: SingleChildScrollView(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Text('User Details', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold)),
//               const SizedBox(height: 8),
//               _buildDetailRow('Full Name', userDetails?['full_name']),
//               _buildDetailRow('Email', userDetails?['email']),
//               _buildDetailRow('Contact', userDetails?['contact_number']),
//               if (appointmentDetails != null &&
//                   appointmentDetails!['haircut_extra_option'] != null &&
//                   (appointmentDetails!['haircut_extra_option'] as String).isNotEmpty)
//                 _buildDetailRow(
//                   'Extra Haircut Option',
//                   appointmentDetails!['haircut_extra_option'] == 'super_furry'
//                       ? 'For Super Furry Hair Coat'
//                       : appointmentDetails!['haircut_extra_option'] == 'severely_matted'
//                           ? 'For Severely Matted Fur'
//                           : appointmentDetails!['haircut_extra_option'],
//                 ),
//             ],
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: Text('Close', style: GoogleFonts.poppins()),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildDetailRow(String label, String? value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 4.0),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           SizedBox(
//             width: 140,
//             child: Text(
//               label,
//               style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: const Color(0xFFF5A623)),
//             ),
//           ),
//           Expanded(
//             child: Text(
//               value ?? '-',
//               style: GoogleFonts.poppins(fontWeight: FontWeight.w400),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildChatMessage(Map<String, dynamic> message, int index) {
//     final orange = const Color(0xFFF5A623);
//     final blue = const Color(0xFF5094FF);
//     final bubbleRadius = 18.0;

//     final isFromAdmin = message['is_from_admin'] == true ||
//                         message['is_from_admin'] == 'true' ||
//                         message['is_from_admin'] == 1;
//     final isFromUser = message['is_from_admin'] == false ||
//                        message['is_from_admin'] == 'false' ||
//                        message['is_from_admin'] == 0 ||
//                        message['is_from_admin'] == null;
//     final isSystemReminder = message['message']?.toString().startsWith('REMINDER:') ?? false;
//     final isAppointmentBooking = message['message']?.toString().startsWith('New grooming appointment booked by') ?? false;

//     String? formattedTime;
//     if (message['created_at'] != null) {
//       final dt = DateTime.tryParse(message['created_at']);
//       if (dt != null) {
//         formattedTime = DateFormat('MMM d, yyyy hh:mm a').format(dt.toLocal());
//       }
//     }

//     // System reminder message
//     if (isSystemReminder) {
//       return _buildSystemMessage(
//         message: message,
//         index: index,
//         icon: Icons.notifications,
//         color: blue,
//         buttonText: 'Update Now',
//         formattedTime: formattedTime,
//         onButtonPressed: () async {
//           final appointmentId = message['appointment_id'];
//           final response = await supabase
//               .from('grooming_appointments')
//               .select()
//               .eq('id', appointmentId)
//               .maybeSingle();
//           if (response != null && mounted) {
//             Navigator.push(
//               context,
//               MaterialPageRoute(builder: (_) => ViewBookingsAdmin(appointment: response)),
//             );
//           }
//         },
//       );
//     }

//     // Appointment booking message
//     if (isAppointmentBooking) {
//       return _buildSystemMessage(
//         message: message,
//         index: index,
//         icon: Icons.calendar_today,
//         color: blue,
//         buttonText: 'See Appointment',
//         formattedTime: formattedTime,
//         onButtonPressed: () async {
//           final appointmentId = message['appointment_id'];
//           final response = await supabase
//               .from('grooming_appointments')
//               .select()
//               .eq('id', appointmentId)
//               .maybeSingle();
//           if (response != null && mounted) {
//             final userId = response['user_id'];
//             final userResponse = await supabase
//                 .from('users')
//                 .select('full_name, email, contact_number')
//                 .eq('id', userId)
//                 .maybeSingle();
//             final appointmentWithUserDetails = Map<String, dynamic>.from(response);
//             if (userResponse != null) {
//               appointmentWithUserDetails['user_details'] = userResponse;
//             }
//             Navigator.push(
//               context,
//               MaterialPageRoute(builder: (_) => ViewBookingsAdmin(appointment: appointmentWithUserDetails)),
//             );
//           }
//         },
//       );
//     }

//     // Regular user/admin message
//     return GestureDetector(
//       onTap: () => setState(() => _selectedMessageIndex = _selectedMessageIndex == index ? null : index),
//       child: Column(
//         crossAxisAlignment: isFromAdmin ? CrossAxisAlignment.end : CrossAxisAlignment.start,
//         children: [
//           Container(
//             margin: EdgeInsets.only(
//               top: 8,
//               bottom: 8,
//               left: isFromAdmin ? 60 : 8,
//               right: isFromAdmin ? 8 : 60,
//             ),
//             child: Row(
//               mainAxisAlignment: isFromAdmin ? MainAxisAlignment.end : MainAxisAlignment.start,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 if (isFromUser) ...[
//                   CircleAvatar(
//                     radius: 18,
//                     backgroundColor: blue.withOpacity(0.15),
//                     child: Icon(Icons.person, color: blue, size: 18),
//                   ),
//                   const SizedBox(width: 8),
//                 ],
//                 Flexible(
//                   child: Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//                     decoration: BoxDecoration(
//                       color: isFromAdmin ? orange : Colors.white,
//                       borderRadius: BorderRadius.only(
//                         topLeft: Radius.circular(bubbleRadius),
//                         topRight: Radius.circular(bubbleRadius),
//                         bottomLeft: Radius.circular(isFromUser ? 4 : bubbleRadius),
//                         bottomRight: Radius.circular(isFromUser ? bubbleRadius : 4),
//                       ),
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.black.withOpacity(0.09),
//                           blurRadius: 6,
//                           offset: const Offset(0, 2),
//                         ),
//                       ],
//                     ),
//                     child: Text(
//                       message['message'] ?? '',
//                       style: GoogleFonts.poppins(
//                         color: isFromAdmin ? Colors.white : Colors.black87,
//                         fontSize: 15,
//                         fontWeight: FontWeight.normal,
//                       ),
//                     ),
//                   ),
//                 ),
//                 if (isFromAdmin) const SizedBox(width: 8),
//               ],
//             ),
//           ),
//           if (_selectedMessageIndex == index && formattedTime != null)
//             Padding(
//               padding: EdgeInsets.only(
//                 left: isFromAdmin ? 0 : 60,
//                 right: isFromAdmin ? 60 : 0,
//                 bottom: 2,
//               ),
//               child: Text(
//                 formattedTime,
//                 style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
//                 textAlign: isFromAdmin ? TextAlign.right : TextAlign.left,
//               ),
//             ),
//         ],
//       ),
//     );
//   }

//   Widget _buildSystemMessage({
//     required Map<String, dynamic> message,
//     required int index,
//     required IconData icon,
//     required Color color,
//     required String buttonText,
//     required String? formattedTime,
//     required VoidCallback onButtonPressed,
//   }) {
//     return GestureDetector(
//       onTap: () => setState(() => _selectedMessageIndex = _selectedMessageIndex == index ? null : index),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Container(
//             margin: const EdgeInsets.only(top: 8, bottom: 8, left: 8, right: 60),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.start,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 CircleAvatar(
//                   radius: 18,
//                   backgroundColor: color.withOpacity(0.15),
//                   child: Icon(icon, color: color, size: 18),
//                 ),
//                 const SizedBox(width: 8),
//                 Flexible(
//                   child: Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.only(
//                         topLeft: Radius.circular(18),
//                         topRight: Radius.circular(18),
//                         bottomLeft: Radius.circular(18),
//                         bottomRight: Radius.circular(4),
//                       ),
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.black.withOpacity(0.09),
//                           blurRadius: 6,
//                           offset: const Offset(0, 2),
//                         ),
//                       ],
//                     ),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           message['message'] ?? '',
//                           style: GoogleFonts.poppins(color: Colors.black87, fontSize: 15, fontWeight: FontWeight.normal),
//                         ),
//                         const SizedBox(height: 8),
//                         ElevatedButton(
//                           onPressed: onButtonPressed,
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: color,
//                             foregroundColor: Colors.white,
//                             padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
//                             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//                             elevation: 0,
//                           ),
//                           child: Text(buttonText, style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           if (_selectedMessageIndex == index && formattedTime != null)
//             Padding(
//               padding: const EdgeInsets.only(left: 60, right: 60, bottom: 2),
//               child: Text(
//                 formattedTime,
//                 style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
//               ),
//             ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final orange = const Color(0xFFF5A623);
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         title: Text(userDetails?['full_name'] ?? '', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
//         backgroundColor: const Color(0xFFFFF6E7),
//         elevation: 0,
//         iconTheme: const IconThemeData(color: Colors.black87),
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back),
//           onPressed: () => Navigator.pop(context, true),
//         ),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.info_outline),
//             onPressed: _showDetailsDialog,
//           ),
//         ],
//       ),
//       body: isLoading
//           ? const Center(child: CircularProgressIndicator(color: Color(0xFFF5A623)))
//           : hasError
//               ? Center(child: Text('Failed to load details.', style: GoogleFonts.poppins(color: Colors.red)))
//               : Column(
//                   children: [
//                     Expanded(
//                       child: ListView.separated(
//                         padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
//                         itemCount: chatMessages.length,
//                         separatorBuilder: (_, __) => const SizedBox(height: 16),
//                         itemBuilder: (context, index) => _buildChatMessage(chatMessages[index], index),
//                         controller: _scrollController,
//                       ),
//                     ),
//                     Container(
//                       padding: const EdgeInsets.all(16),
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.black.withOpacity(0.05),
//                             blurRadius: 10,
//                             offset: const Offset(0, -2),
//                           ),
//                         ],
//                       ),
//                       child: Row(
//                         children: [
//                           Expanded(
//                             child: TextField(
//                               controller: _messageController,
//                               decoration: InputDecoration(
//                                 hintText: 'Type your message...',
//                                 hintStyle: GoogleFonts.poppins(color: Colors.grey[400]),
//                                 border: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(25),
//                                   borderSide: BorderSide.none,
//                                 ),
//                                 filled: true,
//                                 fillColor: Colors.grey[100],
//                                 contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//                               ),
//                               maxLines: null,
//                               onSubmitted: (_) => _sendMessage(),
//                             ),
//                           ),
//                           const SizedBox(width: 12),
//                           Container(
//                             decoration: const BoxDecoration(color: Colors.orange, shape: BoxShape.circle),
//                             child: IconButton(
//                               onPressed: isSendingMessage ? null : _sendMessage,
//                               icon: isSendingMessage
//                                   ? const SizedBox(
//                                       width: 20,
//                                       height: 20,
//                                       child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
//                                     )
//                                   : const Icon(Icons.send, color: Colors.white),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//     );
//   }
// }

// ----

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'viewbookings_admin.dart';

class ViewMessagesAdmin extends StatefulWidget {
  final Map<String, dynamic> message;
  const ViewMessagesAdmin({Key? key, required this.message}) : super(key: key);

  @override
  _ViewMessagesAdminState createState() => _ViewMessagesAdminState();
}

class _ViewMessagesAdminState extends State<ViewMessagesAdmin> {
  final supabase = Supabase.instance.client;
  Map<String, dynamic>? userDetails;
  Map<String, dynamic>? appointmentDetails;
  bool isLoading = true;
  bool hasError = false;
  final TextEditingController _messageController = TextEditingController();
  List<Map<String, dynamic>> chatMessages = [];
  bool isSendingMessage = false;
  final ScrollController _scrollController = ScrollController();
  int? _selectedMessageIndex;

  @override
  void initState() {
    super.initState();
    _fetchDetails();
    _fetchChatMessages();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchDetails() async {
    if (!mounted) return;
    setState(() {
      isLoading = true;
      hasError = false;
    });
    try {
      final userResp = await supabase
          .from('users')
          .select()
          .eq('id', widget.message['user_id'])
          .maybeSingle();
      final appointmentResp = await supabase
          .from('grooming_appointments')
          .select()
          .eq('id', widget.message['appointment_id'])
          .maybeSingle();
      if (mounted) {
        setState(() {
          userDetails = userResp;
          appointmentDetails = appointmentResp;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          hasError = true;
          isLoading = false;
        });
      }
    }
  }

  Future<void> _fetchChatMessages() async {
    if (!mounted) return;
    try {
      final response = await supabase
          .from('admin_messages')
          .select('*')
          .eq('user_id', widget.message['user_id'])
          .eq('appointment_id', widget.message['appointment_id'])
          .order('created_at', ascending: true);
      if (mounted) {
        setState(() {
          chatMessages = response is List ? List<Map<String, dynamic>>.from(response) : [];
          isLoading = false;
        });
        // Scroll to bottom after messages are loaded
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
          }
        });
      }
    } catch (e) {
      debugPrint('Error fetching chat messages: $e');
    }
  }

  Future<void> _refreshMessages() async {
    await _fetchChatMessages();
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty || isSendingMessage) return;
    if (!mounted) return;
    setState(() => isSendingMessage = true);
    try {
      final messageText = _messageController.text.trim();
      final data = {
        'user_id': widget.message['user_id'],
        'appointment_id': widget.message['appointment_id'],
        'message': messageText,
        'is_from_admin': true,
        'is_read': false,
      };
      await supabase.from('admin_messages').insert(data);
      await supabase.from('user_messages').insert(data);
      // Update appointment status if the message is the apology message
      if (messageText ==
          "We're sorry! Your grooming appointment status was not updated before the scheduled time. "
          "We sincerely apologize for any inconvenience this may have caused. "
          "Please feel free to reach out to us or rebook your appointment at your convenience. "
          "Thank you for understanding!") {
        await supabase
            .from('grooming_appointments')
            .update({'status': 'Cancelled'})
            .eq('id', widget.message['appointment_id']);
        await _fetchDetails(); // Refresh appointment details
      }
      _messageController.clear();
      await _fetchChatMessages();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send message: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isSendingMessage = false);
      }
    }
  }

  void _showDetailsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Appointment Details', style: GoogleFonts.poppins()),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('User Details', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              _buildDetailRow('Full Name', userDetails?['full_name']),
              _buildDetailRow('Email', userDetails?['email']),
              _buildDetailRow('Contact', userDetails?['contact_number']),
              if (appointmentDetails != null &&
                  appointmentDetails!['haircut_extra_option'] != null &&
                  (appointmentDetails!['haircut_extra_option'] as String).isNotEmpty)
                _buildDetailRow(
                  'Extra Haircut Option',
                  appointmentDetails!['haircut_extra_option'] == 'super_furry'
                      ? 'For Super Furry Hair Coat'
                      : appointmentDetails!['haircut_extra_option'] == 'severely_matted'
                          ? 'For Severely Matted Fur'
                          : appointmentDetails!['haircut_extra_option'],
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close', style: GoogleFonts.poppins()),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: const Color(0xFFF5A623)),
            ),
          ),
          Expanded(
            child: Text(
              value ?? '-',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w400),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatMessage(Map<String, dynamic> message, int index) {
    final orange = const Color(0xFFF5A623);
    final blue = const Color(0xFF5094FF);
    final bubbleRadius = 18.0;
    final isFromAdmin = message['is_from_admin'] == true ||
                        message['is_from_admin'] == 'true' ||
                        message['is_from_admin'] == 1;
    final isFromUser = message['is_from_admin'] == false ||
                       message['is_from_admin'] == 'false' ||
                       message['is_from_admin'] == 0 ||
                       message['is_from_admin'] == null;
    final isSystemReminder = message['message']?.toString().startsWith('REMINDER:') ?? false;
    final isAppointmentBooking = message['message']?.toString().startsWith('New grooming appointment booked by') ?? false;
    String? formattedTime;
    if (message['created_at'] != null) {
      final dt = DateTime.tryParse(message['created_at']);
      if (dt != null) {
        formattedTime = DateFormat('MMM d, yyyy hh:mm a').format(dt.toLocal());
      }
    }
    // System reminder message
    if (isSystemReminder) {
      return _buildSystemMessage(
        message: message,
        index: index,
        icon: Icons.notifications,
        color: blue,
        buttonText: 'Update Now',
        formattedTime: formattedTime,
        onButtonPressed: () async {
          final appointmentId = message['appointment_id'];
          final response = await supabase
              .from('grooming_appointments')
              .select()
              .eq('id', appointmentId)
              .maybeSingle();
          if (response != null && mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ViewBookingsAdmin(appointment: response)),
            );
          }
        },
      );
    }
    // Appointment booking message
    if (isAppointmentBooking) {
      return _buildSystemMessage(
        message: message,
        index: index,
        icon: Icons.calendar_today,
        color: blue,
        buttonText: 'See Appointment',
        formattedTime: formattedTime,
        onButtonPressed: () async {
          final appointmentId = message['appointment_id'];
          final response = await supabase
              .from('grooming_appointments')
              .select()
              .eq('id', appointmentId)
              .maybeSingle();
          if (response != null && mounted) {
            final userId = response['user_id'];
            final userResponse = await supabase
                .from('users')
                .select('full_name, email, contact_number')
                .eq('id', userId)
                .maybeSingle();
            final appointmentWithUserDetails = Map<String, dynamic>.from(response);
            if (userResponse != null) {
              appointmentWithUserDetails['user_details'] = userResponse;
            }
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ViewBookingsAdmin(appointment: appointmentWithUserDetails)),
            );
          }
        },
      );
    }
    // Regular user/admin message
    return GestureDetector(
      onTap: () => setState(() => _selectedMessageIndex = _selectedMessageIndex == index ? null : index),
      child: Column(
        crossAxisAlignment: isFromAdmin ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(
              top: 8,
              bottom: 8,
              left: isFromAdmin ? 60 : 8,
              right: isFromAdmin ? 8 : 60,
            ),
            child: Row(
              mainAxisAlignment: isFromAdmin ? MainAxisAlignment.end : MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isFromUser) ...[
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: blue.withOpacity(0.15),
                    child: Icon(Icons.person, color: blue, size: 18),
                  ),
                  const SizedBox(width: 8),
                ],
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: isFromAdmin ? orange : Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(bubbleRadius),
                        topRight: Radius.circular(bubbleRadius),
                        bottomLeft: Radius.circular(isFromUser ? 4 : bubbleRadius),
                        bottomRight: Radius.circular(isFromUser ? bubbleRadius : 4),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.09),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      message['message'] ?? '',
                      style: GoogleFonts.poppins(
                        color: isFromAdmin ? Colors.white : Colors.black87,
                        fontSize: 15,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),
                ),
                if (isFromAdmin) const SizedBox(width: 8),
              ],
            ),
          ),
          if (_selectedMessageIndex == index && formattedTime != null)
            Padding(
              padding: EdgeInsets.only(
                left: isFromAdmin ? 0 : 60,
                right: isFromAdmin ? 60 : 0,
                bottom: 2,
              ),
              child: Text(
                formattedTime,
                style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
                textAlign: isFromAdmin ? TextAlign.right : TextAlign.left,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSystemMessage({
    required Map<String, dynamic> message,
    required int index,
    required IconData icon,
    required Color color,
    required String buttonText,
    required String? formattedTime,
    required VoidCallback onButtonPressed,
  }) {
    return GestureDetector(
      onTap: () => setState(() => _selectedMessageIndex = _selectedMessageIndex == index ? null : index),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 8, bottom: 8, left: 8, right: 60),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: color.withOpacity(0.15),
                  child: Icon(icon, color: color, size: 18),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(18),
                        topRight: Radius.circular(18),
                        bottomLeft: Radius.circular(18),
                        bottomRight: Radius.circular(4),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.09),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          message['message'] ?? '',
                          style: GoogleFonts.poppins(color: Colors.black87, fontSize: 15, fontWeight: FontWeight.normal),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: onButtonPressed,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: color,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            elevation: 0,
                          ),
                          child: Text(buttonText, style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_selectedMessageIndex == index && formattedTime != null)
            Padding(
              padding: const EdgeInsets.only(left: 60, right: 60, bottom: 2),
              child: Text(
                formattedTime,
                style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final orange = const Color(0xFFF5A623);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(userDetails?['full_name'] ?? '', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        backgroundColor: const Color(0xFFFFF6E7),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context, true),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _showDetailsDialog,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFF5A623)))
          : hasError
              ? Center(child: Text('Failed to load details.', style: GoogleFonts.poppins(color: Colors.red)))
              : Column(
                  children: [
                    Expanded(
                      child: RefreshIndicator(
                        color: orange,
                        onRefresh: _refreshMessages,
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                          itemCount: chatMessages.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 16),
                          itemBuilder: (context, index) => _buildChatMessage(chatMessages[index], index),
                          controller: _scrollController,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, -2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _messageController,
                              decoration: InputDecoration(
                                hintText: 'Type your message...',
                                hintStyle: GoogleFonts.poppins(color: Colors.grey[400]),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(25),
                                  borderSide: BorderSide.none,
                                ),
                                filled: true,
                                fillColor: Colors.grey[100],
                                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              ),
                              maxLines: null,
                              onSubmitted: (_) => _sendMessage(),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            decoration: const BoxDecoration(color: Colors.orange, shape: BoxShape.circle),
                            child: IconButton(
                              onPressed: isSendingMessage ? null : _sendMessage,
                              icon: isSendingMessage
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                    )
                                  : const Icon(Icons.send, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }
}
