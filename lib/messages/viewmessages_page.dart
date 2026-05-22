// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:intl/intl.dart';

// class ViewMessagesPage extends StatefulWidget {
//   final dynamic appointmentId;
//   const ViewMessagesPage({Key? key, required this.appointmentId}) : super(key: key);

//   @override
//   State<ViewMessagesPage> createState() => _ViewMessagesPageState();
// }

// class _ViewMessagesPageState extends State<ViewMessagesPage> {
//   final supabase = Supabase.instance.client;
//   final ScrollController _scrollController = ScrollController();
//   final TextEditingController _messageController = TextEditingController();
//   List<Map<String, dynamic>> chatMessages = [];
//   Map<String, dynamic>? userDetails;
//   Map<String, dynamic>? appointmentDetails;
//   bool isLoading = true;
//   bool hasError = false;
//   bool isSending = false;
//   int? _selectedMessageIndex; // Track tapped message

//   @override
//   void initState() {
//     super.initState();
//     _fetchDetails();
//     _fetchChat();
//     _markMessagesAsRead();
//   }

//   Future<void> _fetchDetails() async {
//     setState(() {
//       isLoading = true;
//       hasError = false;
//     });
//     try {
//       final userId = supabase.auth.currentUser?.id;
//       if (userId == null) {
//         setState(() {
//           userDetails = null;
//           appointmentDetails = null;
//           isLoading = false;
//           hasError = true;
//         });
//         return;
//       }
//       final userResp = await supabase
//           .from('users')
//           .select()
//           .eq('id', userId)
//           .maybeSingle();
//       final appointmentResp = await supabase
//           .from('grooming_appointments')
//           .select('id, pet_name, pet_type, pet_type_other, breed, pet_size, age, gender, allergies_medical_conditions, status')
//           .eq('id', widget.appointmentId)
//           .maybeSingle();
//       setState(() {
//         userDetails = userResp;
//         appointmentDetails = appointmentResp;
//         isLoading = false;
//       });
//     } catch (e) {
//       setState(() {
//         hasError = true;
//         isLoading = false;
//       });
//     }
//   }

//   Future<void> _fetchChat() async {
//     setState(() => isLoading = true);
//     final userId = supabase.auth.currentUser?.id;
//     if (userId == null) {
//       setState(() {
//         chatMessages = [];
//         isLoading = false;
//       });
//       return;
//     }
//     final response = await supabase
//         .from('user_messages')
//         .select('*')
//         .eq('user_id', userId)
//         .eq('appointment_id', widget.appointmentId)
//         .order('created_at', ascending: true);
//     setState(() {
//       chatMessages = List<Map<String, dynamic>>.from(response);
//       isLoading = false;
//     });
//     // Always scroll to bottom after messages are loaded
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (_scrollController.hasClients) {
//         _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
//       }
//     });
//   }

//   Future<void> _sendMessage() async {
//     if (_messageController.text.trim().isEmpty) return;
//     setState(() => isSending = true);
//     final userId = supabase.auth.currentUser?.id;
//     if (userId == null) return;
//     try {
//       final data = {
//         'user_id': userId,
//         'appointment_id': widget.appointmentId,
//         'message': _messageController.text.trim(),
//         'is_from_admin': false,
//         'is_read': false,
//       };
//       // Insert into both admin_messages and user_messages tables
//       await supabase.from('admin_messages').insert(data);
//       await supabase.from('user_messages').insert(data);
//       _messageController.clear();
//       await _fetchChat();
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Failed to send message: $e'), backgroundColor: Colors.red),
//       );
//     } finally {
//       setState(() => isSending = false);
//     }
//   }

//   Future<void> _markMessagesAsRead() async {
//     try {
//       final userId = supabase.auth.currentUser?.id;
//       if (userId != null) {
//         // Mark all unread admin messages for this appointment as read in both tables
//         await supabase
//             .from('admin_messages')
//             .update({'is_read': true})
//             .eq('user_id', userId)
//             .eq('appointment_id', widget.appointmentId)
//             .eq('is_from_admin', true)
//             .eq('is_read', false);
//         await supabase
//             .from('user_messages')
//             .update({'is_read': true})
//             .eq('user_id', userId)
//             .eq('appointment_id', widget.appointmentId)
//             .eq('is_from_admin', true)
//             .eq('is_read', false);
//         print('Debug: Marked admin messages as read for appointment ${widget.appointmentId}');
//       }
//     } catch (e) {
//       print('Error marking messages as read: $e');
//     }
//   }

//   // void _showDetailsDialog() {
//   //   showDialog(
//   //     context: context,
//   //     builder: (context) => AlertDialog(
//   //       title: Text('Appointment Details', style: GoogleFonts.poppins()),
//   //       content: SingleChildScrollView(
//   //         child: Column(
//   //           crossAxisAlignment: CrossAxisAlignment.start,
//   //           mainAxisSize: MainAxisSize.min,
//   //           children: [
//   //             Text('User Details',
//   //                 style: GoogleFonts.poppins(
//   //                     fontSize: 16, fontWeight: FontWeight.bold)),
//   //             const SizedBox(height: 8),
//   //             _buildDetailRow('Full Name', userDetails?['full_name']),
//   //             _buildDetailRow('Email', userDetails?['email']),
//   //             _buildDetailRow('Contact', userDetails?['contact_number']),
//   //             const SizedBox(height: 16),
//   //             if (appointmentDetails != null) ...[
//   //               Text('Appointment Details',
//   //                   style: GoogleFonts.poppins(
//   //                       fontSize: 16, fontWeight: FontWeight.bold)),
//   //               const SizedBox(height: 8),
//   //               _buildDetailRow('Pet Name', appointmentDetails?['pet_name']),
//   //               _buildDetailRow('Breed', appointmentDetails?['breed']),
//   //               _buildDetailRow('Service', appointmentDetails?['service']),
//   //               _buildDetailRow('Date', appointmentDetails?['preferred_date']?.toString()),
//   //               _buildDetailRow('Time', appointmentDetails?['preferred_time']?.toString()),
//   //               _buildDetailRow('Payment', appointmentDetails?['payment_method']),
//   //               _buildDetailRow('Cost', appointmentDetails?['cost']?.toString()),
//   //             ],
//   //           ],
//   //         ),
//   //       ),
//   //       actions: [
//   //         TextButton(
//   //           onPressed: () => Navigator.pop(context),
//   //           child: Text('Close', style: GoogleFonts.poppins()),
//   //         ),
//   //       ],
//   //     ),
//   //   );
//   // }

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
//               style: GoogleFonts.poppins(
//                 fontWeight: FontWeight.w600,
//                 color: const Color(0xFFF5A623),
//               ),
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

//   Widget _buildChatMessage(Map<String, dynamic> msg, int index) {
//     final orange = const Color(0xFFF5A623);
//     final blue = const Color(0xFF5094FF);
//     // Robust admin/user detection
//     final isFromAdmin = msg['is_from_admin'] == true || msg['is_from_admin'] == 'true' || msg['is_from_admin'] == 1;
//     final isFromUser = msg['is_from_admin'] == false || msg['is_from_admin'] == 'false' || msg['is_from_admin'] == 0 || msg['is_from_admin'] == null;
//     final bubbleRadius = 18.0;
//     final createdAt = msg['created_at'];
//     String? formattedTime;
//     if (createdAt != null) {
//       final dt = DateTime.tryParse(createdAt);
//       if (dt != null) {
//         final localDt = dt.toLocal();
//         formattedTime = DateFormat('MMM d, yyyy hh:mm a').format(localDt);
//       }
//     }
//     return GestureDetector(
//       onTap: () {
//         setState(() {
//           _selectedMessageIndex = _selectedMessageIndex == index ? null : index;
//         });
//       },
//       child: Column(
//         crossAxisAlignment: isFromUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
//         children: [
//           Container(
//       margin: EdgeInsets.only(
//         top: 8,
//         bottom: 8,
//         left: isFromUser ? 60 : 8,
//         right: isFromUser ? 8 : 60,
//       ),
//       child: Row(
//         mainAxisAlignment: isFromUser ? MainAxisAlignment.end : MainAxisAlignment.start,
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           if (isFromAdmin) ...[
//             CircleAvatar(
//               radius: 18,
//               backgroundColor: orange.withOpacity(0.15),
//               child: Icon(Icons.admin_panel_settings, color: orange, size: 18),
//             ),
//             const SizedBox(width: 8),
//           ],
//           Flexible(
//             child: Container(
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//               decoration: BoxDecoration(
//                 color: isFromUser ? blue : Colors.white,
//                 borderRadius: BorderRadius.only(
//                   topLeft: Radius.circular(bubbleRadius),
//                   topRight: Radius.circular(bubbleRadius),
//                   bottomRight: Radius.circular(isFromUser ? 4 : bubbleRadius),
//                   bottomLeft: Radius.circular(isFromUser ? bubbleRadius : 4),
//                 ),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.09),
//                     blurRadius: 6,
//                     offset: const Offset(0, 2),
//                   ),
//                 ],
//               ),
//               child: Text(
//                 msg['message'] ?? '',
//                 style: GoogleFonts.poppins(
//                   color: isFromUser ? Colors.white : Colors.black87,
//                   fontSize: 15,
//                   fontWeight: FontWeight.normal,
//                 ),
//               ),
//             ),
//           ),
//           if (isFromUser) ...[
//             const SizedBox(width: 8),
//                 ],
//               ],
//             ),
//           ),
//           if (_selectedMessageIndex == index && formattedTime != null)
//             Padding(
//               padding: EdgeInsets.only(
//                 left: 60.0,
//                 right: isFromUser ? 8.0 : 60.0,
//                 bottom: 2.0,
//               ),
//               child: Text(
//                 formattedTime,
//                 style: GoogleFonts.poppins(
//                   fontSize: 12,
//                   color: Colors.grey[600],
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }

//   bool isReminderMessage(String message) {
//     return message.startsWith('⚠️REMINDER');
//   }

  

//   @override
//   Widget build(BuildContext context) {
//     final orange = const Color(0xFFF5A623);
//     final blue = const Color(0xFF5094FF);
//     return GestureDetector(
//       onTap: () {
//         // Dismiss keyboard when tapping outside input fields
//         FocusScope.of(context).unfocus();
//       },
//       child: Scaffold(
//         backgroundColor: Colors.white,
//         appBar: AppBar(
//           backgroundColor: const Color(0xFFFFF6E7),
//           elevation: 0,
//           centerTitle: true,
//           iconTheme: const IconThemeData(color: Colors.black87),
//           title: Text(
//             appointmentDetails != null && appointmentDetails!['pet_name'] != null
//                 ? 'Appointment for ${appointmentDetails!['pet_name']}'
//                 : 'Appointment',
//             style: GoogleFonts.poppins(
//               color: Colors.black87,
//               fontWeight: FontWeight.bold,
//               fontSize: 20,
//             ),
//           ),
//           leading: IconButton(
//             icon: const Icon(Icons.arrow_back),
//             onPressed: () {
//               Navigator.pop(context, true); // Always trigger refresh on return
//             },
//           ),
//           // actions: [
//           //   IconButton(
//           //     icon: const Icon(Icons.info_outline),
//           //     onPressed: () => _showDetailsDialog(),
//           //   ),
//           // ],
//         ),
//         body: isLoading
//             ? const Center(child: CircularProgressIndicator(color: Color(0xFFF5A623)))
//             : hasError
//                 ? Center(
//                     child: Text('Failed to load details.',
//                         style: GoogleFonts.poppins(color: Colors.red)),
//                   )
//                 : Column(
//                     children: [
//                       // Chat Messages
//                       Expanded(
//                         child: Container(
//                           decoration: BoxDecoration(
//                             color: Colors.white,
//                           ),
//                           child: ListView.separated(
//                             padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
//                             itemCount: chatMessages.length,
//                             separatorBuilder: (context, index) => const SizedBox(height: 16),
//                             itemBuilder: (context, index) {
//                               final msg = chatMessages[index];
//                               // If it's a reminder, treat as admin message
//                               if (isReminderMessage(msg['message'])) {
//                                 // Render as admin chat bubble
//                                 return _buildChatMessage({
//                                   ...msg,
//                                   'is_from_admin': true,
//                                 }, index);
//                               } else {
//                                 return _buildChatMessage(msg, index);
//                               }
//                             },
//                             controller: _scrollController,
//                           ),
//                         ),
//                       ),
//                       // Message Input
//                       Container(
//                         padding: const EdgeInsets.all(16),
//                         decoration: BoxDecoration(
//                           color: Colors.white,
//                           boxShadow: [
//                             BoxShadow(
//                               color: Colors.black.withOpacity(0.05),
//                               blurRadius: 10,
//                               offset: const Offset(0, -2),
//                             ),
//                           ],
//                         ),
//                         child: Row(
//                           children: [
//                             Expanded(
//                               child: TextField(
//                                 controller: _messageController,
//                                 decoration: InputDecoration(
//                                   hintText: 'Type your message...',
//                                   hintStyle: GoogleFonts.poppins(color: Colors.grey[400]),
//                                   border: OutlineInputBorder(
//                                     borderRadius: BorderRadius.circular(25),
//                                     borderSide: BorderSide.none,
//                                   ),
//                                   filled: true,
//                                   fillColor: Colors.grey[100],
//                                   contentPadding: const EdgeInsets.symmetric(
//                                     horizontal: 20,
//                                     vertical: 12,
//                                   ),
//                                 ),
//                                 maxLines: null,
//                               ),
//                             ),
//                             const SizedBox(width: 12),
//                             Container(
//                               decoration: BoxDecoration(
//                                 color: blue,
//                                 shape: BoxShape.circle,
//                               ),
//                               child: IconButton(
//                                 onPressed: isSending ? null : _sendMessage,
//                                 icon: isSending
//                                     ? const SizedBox(
//                                         width: 20,
//                                         height: 20,
//                                         child: CircularProgressIndicator(
//                                           color: Colors.white,
//                                           strokeWidth: 2,
//                                         ),
//                                       )
//                                     : const Icon(
//                                         Icons.send,
//                                         color: Colors.white,
//                                       ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//       ),
//     );
//   }
// } 


// ----


import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class ViewMessagesPage extends StatefulWidget {
  final dynamic appointmentId;
  const ViewMessagesPage({Key? key, required this.appointmentId}) : super(key: key);

  @override
  State<ViewMessagesPage> createState() => _ViewMessagesPageState();
}

class _ViewMessagesPageState extends State<ViewMessagesPage> {
  final supabase = Supabase.instance.client;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _messageController = TextEditingController();
  List<Map<String, dynamic>> chatMessages = [];
  Map<String, dynamic>? userDetails;
  Map<String, dynamic>? appointmentDetails;
  bool isLoading = true;
  bool hasError = false;
  bool isSending = false;
  int? _selectedMessageIndex;

  @override
  void initState() {
    super.initState();
    _fetchDetails();
    _fetchChat();
    _markMessagesAsRead();
  }

  Future<void> _fetchDetails() async {
    setState(() {
      isLoading = true;
      hasError = false;
    });
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) {
        setState(() {
          userDetails = null;
          appointmentDetails = null;
          isLoading = false;
          hasError = true;
        });
        return;
      }
      final userResp = await supabase
          .from('users')
          .select()
          .eq('id', userId)
          .maybeSingle();
      final appointmentResp = await supabase
          .from('grooming_appointments')
          .select('id, pet_name, pet_type, pet_type_other, breed, pet_size, age, gender, allergies_medical_conditions, status')
          .eq('id', widget.appointmentId)
          .maybeSingle();
      setState(() {
        userDetails = userResp;
        appointmentDetails = appointmentResp;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        hasError = true;
        isLoading = false;
      });
    }
  }

  Future<void> _fetchChat() async {
    setState(() => isLoading = true);
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) {
      setState(() {
        chatMessages = [];
        isLoading = false;
      });
      return;
    }
    final response = await supabase
        .from('user_messages')
        .select('*')
        .eq('user_id', userId)
        .eq('appointment_id', widget.appointmentId)
        .order('created_at', ascending: true);
    setState(() {
      chatMessages = List<Map<String, dynamic>>.from(response);
      isLoading = false;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  Future<void> _refreshMessages() async {
    await _fetchChat();
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;
    setState(() => isSending = true);
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;
    try {
      final data = {
        'user_id': userId,
        'appointment_id': widget.appointmentId,
        'message': _messageController.text.trim(),
        'is_from_admin': false,
        'is_read': false,
      };
      await supabase.from('admin_messages').insert(data);
      await supabase.from('user_messages').insert(data);
      _messageController.clear();
      await _fetchChat();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send message: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => isSending = false);
    }
  }

  Future<void> _markMessagesAsRead() async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId != null) {
        await supabase
            .from('admin_messages')
            .update({'is_read': true})
            .eq('user_id', userId)
            .eq('appointment_id', widget.appointmentId)
            .eq('is_from_admin', true)
            .eq('is_read', false);
        await supabase
            .from('user_messages')
            .update({'is_read': true})
            .eq('user_id', userId)
            .eq('appointment_id', widget.appointmentId)
            .eq('is_from_admin', true)
            .eq('is_read', false);
      }
    } catch (e) {
      debugPrint('Error marking messages as read: $e');
    }
  }

  Widget _buildChatMessage(Map<String, dynamic> msg, int index) {
    final orange = const Color(0xFFF5A623);
    final blue = const Color(0xFF5094FF);
    final isFromAdmin = msg['is_from_admin'] == true || msg['is_from_admin'] == 'true' || msg['is_from_admin'] == 1;
    final isFromUser = msg['is_from_admin'] == false || msg['is_from_admin'] == 'false' || msg['is_from_admin'] == 0 || msg['is_from_admin'] == null;
    final bubbleRadius = 18.0;
    String? formattedTime;
    if (msg['created_at'] != null) {
      final dt = DateTime.tryParse(msg['created_at']);
      if (dt != null) {
        formattedTime = DateFormat('MMM d, yyyy hh:mm a').format(dt.toLocal());
      }
    }
    return GestureDetector(
      onTap: () => setState(() => _selectedMessageIndex = _selectedMessageIndex == index ? null : index),
      child: Column(
        crossAxisAlignment: isFromUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(
              top: 8,
              bottom: 8,
              left: isFromUser ? 60 : 8,
              right: isFromUser ? 8 : 60,
            ),
            child: Row(
              mainAxisAlignment: isFromUser ? MainAxisAlignment.end : MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isFromAdmin) ...[
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: orange.withOpacity(0.15),
                    child: Icon(Icons.admin_panel_settings, color: orange, size: 18),
                  ),
                  const SizedBox(width: 8),
                ],
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: isFromUser ? blue : Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(bubbleRadius),
                        topRight: Radius.circular(bubbleRadius),
                        bottomRight: Radius.circular(isFromUser ? 4 : bubbleRadius),
                        bottomLeft: Radius.circular(isFromUser ? bubbleRadius : 4),
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
                      msg['message'] ?? '',
                      style: GoogleFonts.poppins(
                        color: isFromUser ? Colors.white : Colors.black87,
                        fontSize: 15,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),
                ),
                if (isFromUser) const SizedBox(width: 8),
              ],
            ),
          ),
          if (_selectedMessageIndex == index && formattedTime != null)
            Padding(
              padding: EdgeInsets.only(
                left: isFromUser ? 0 : 60,
                right: isFromUser ? 60 : 0,
                bottom: 2,
              ),
              child: Text(
                formattedTime,
                style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
                textAlign: isFromUser ? TextAlign.right : TextAlign.left,
              ),
            ),
        ],
      ),
    );
  }

  bool isReminderMessage(String message) {
    return message.startsWith('⚠️REMINDER');
  }

  @override
  Widget build(BuildContext context) {
    final orange = const Color(0xFFF5A623);
    final blue = const Color(0xFF5094FF);
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: const Color(0xFFFFF6E7),
          elevation: 0,
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.black87),
          title: Text(
            appointmentDetails != null && appointmentDetails!['pet_name'] != null
                ? 'Appointment for ${appointmentDetails!['pet_name']}'
                : 'Appointment',
            style: GoogleFonts.poppins(
              color: Colors.black87,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context, true),
          ),
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator(color: Color(0xFFF5A623)))
            : hasError
                ? Center(
                    child: Text('Failed to load details.', style: GoogleFonts.poppins(color: Colors.red)),
                  )
                : Column(
                    children: [
                      Expanded(
                        child: RefreshIndicator(
                          color: orange,
                          onRefresh: _refreshMessages,
                          child: ListView.separated(
                            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                            itemCount: chatMessages.length,
                            separatorBuilder: (context, index) => const SizedBox(height: 16),
                            itemBuilder: (context, index) {
                              final msg = chatMessages[index];
                              if (isReminderMessage(msg['message'])) {
                                return _buildChatMessage({...msg, 'is_from_admin': true}, index);
                              } else {
                                return _buildChatMessage(msg, index);
                              }
                            },
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
                              decoration: BoxDecoration(color: blue, shape: BoxShape.circle),
                              child: IconButton(
                                onPressed: isSending ? null : _sendMessage,
                                icon: isSending
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
      ),
    );
  }
}
