// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';

// class ViewArchiveAdminPage extends StatefulWidget {
//   final dynamic appointmentId;
//   const ViewArchiveAdminPage({Key? key, required this.appointmentId}) : super(key: key);

//   @override
//   State<ViewArchiveAdminPage> createState() => _ViewArchiveAdminPageState();
// }

// class _ViewArchiveAdminPageState extends State<ViewArchiveAdminPage> {
//   final supabase = Supabase.instance.client;
//   final ScrollController _scrollController = ScrollController();
//   List<Map<String, dynamic>> chatMessages = [];
//   bool isLoading = true;
//   bool hasError = false;
//   bool isUnarchiving = false;
//   Map<String, dynamic>? appointmentDetails;
//   Map<String, dynamic>? userDetails;

//   @override
//   void initState() {
//     super.initState();
//     _cleanupOldArchivedMessages();
//     _fetchDetails();
//     _fetchChat();
//   }

//   Future<void> _fetchDetails() async {
//     try {
//       final appointmentResp = await supabase
//           .from('grooming_appointments')
//           .select()
//           .eq('id', widget.appointmentId)
//           .maybeSingle();
//       if (appointmentResp != null) {
//         final userResp = await supabase
//             .from('users')
//             .select()
//             .eq('id', appointmentResp['user_id'])
//             .maybeSingle();
//         setState(() {
//           userDetails = userResp;
//           appointmentDetails = appointmentResp;
//         });
//       }
//     } catch (e) {
//       // ignore
//     }
//   }

//   Future<void> _cleanupOldArchivedMessages() async {
//     try {
//       // Calculate date 30 days ago
//       final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
      
//       // Delete messages older than 30 days from admin_messages_archive
//       await supabase
//           .from('admin_messages_archive')
//           .delete()
//           .lt('archived_at', thirtyDaysAgo.toIso8601String());
      
//       print('Debug: Cleaned up old archived messages (viewarchive_admin)');
//     } catch (e) {
//       print('Error cleaning up old archived messages (viewarchive_admin): $e');
//     }
//   }

//   Future<void> _fetchChat() async {
//     setState(() => isLoading = true);
//     try {
//       final response = await supabase
//           .from('admin_messages_archive')
//           .select('*')
//           .eq('appointment_id', widget.appointmentId)
//           .order('archived_at', ascending: false);
//       setState(() {
//         chatMessages = List<Map<String, dynamic>>.from(response);
//         isLoading = false;
//       });
//     } catch (e) {
//       setState(() {
//         chatMessages = [];
//         isLoading = false;
//       });
//     }
//   }

//   Future<void> _unarchive() async {
//     setState(() => isUnarchiving = true);
//     try {
//       // Fetch all archived messages for this appointment
//       final archived = await supabase
//           .from('admin_messages_archive')
//           .select('*')
//           .eq('appointment_id', widget.appointmentId);
      
//       if (archived is List && archived.isNotEmpty) {
//         // Check if messages already exist in admin_messages table
//         final existingMessages = await supabase
//             .from('admin_messages')
//             .select('*')
//             .eq('appointment_id', widget.appointmentId);
        
//         if (existingMessages is List && existingMessages.isNotEmpty) {
//           // Messages exist, just update them to unarchived
//           await supabase
//               .from('admin_messages')
//               .update({'is_archived': false})
//               .eq('appointment_id', widget.appointmentId);
//         } else {
//           // Messages don't exist, insert them back
//           final toRestore = archived.map((msg) {
//             final data = Map<String, dynamic>.from(msg);
//             data.remove('archived_at');
//             data.remove('id'); // Let DB assign new id
//             data['is_archived'] = false;
//             return data;
//           }).toList();
          
//           // Insert back to both admin_messages and user_messages
//           await supabase.from('admin_messages').insert(toRestore);
//           await supabase.from('user_messages').insert(toRestore);
//         }
        
//         // Also ensure user_messages table has these messages
//         final existingUserMessages = await supabase
//             .from('user_messages')
//             .select('*')
//             .eq('appointment_id', widget.appointmentId);
        
//         if (existingUserMessages is List && existingUserMessages.isEmpty) {
//           // Insert to user_messages table to keep in sync
//           final userRestoreBatch = archived.map((msg) {
//             final data = Map<String, dynamic>.from(msg);
//             data.remove('archived_at');
//             data.remove('id'); // Let DB assign new id
//             data['is_archived'] = false;
//             return data;
//           }).toList();
          
//           await supabase.from('user_messages').insert(userRestoreBatch);
//         } else {
//           // Update existing user_messages to unarchived
//           await supabase
//               .from('user_messages')
//               .update({'is_archived': false})
//               .eq('appointment_id', widget.appointmentId);
//         }
        
//         // Delete from archive table
//         final ids = archived.map((m) => m['id']).toList();
//         await supabase
//             .from('admin_messages_archive')
//             .delete()
//             .inFilter('id', ids);
//       }
      
//       if (mounted) {
//         setState(() => isUnarchiving = false);
        
//         // Show success message
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: const Text('Successfully unarchived conversation'),
//             backgroundColor: Colors.green,
//           ),
//         );
//         Navigator.pop(context, true);
//       }
//     } catch (e) {
//       print('Error unarchiving: $e');
//       setState(() => isUnarchiving = false);
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Failed to unarchive: $e'), backgroundColor: Colors.red),
//         );
//       }
//     }
//   }

//   Future<void> _deleteConversation() async {
//     final confirmed = await showDialog<bool>(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Delete Conversation'),
//         content: const Text('Are you sure you want to delete this conversation? This action cannot be undone.'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context, false),
//             child: const Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () => Navigator.pop(context, true),
//             child: const Text('Delete', style: TextStyle(color: Colors.red)),
//           ),
//         ],
//       ),
//     );
//     if (confirmed != true) return;
    
//     try {
//       // Delete from archive
//       await supabase
//           .from('admin_messages_archive')
//           .delete()
//           .eq('appointment_id', widget.appointmentId);
      
//       // Also delete from admin_messages and user_messages (in case of any duplicates)
//       await supabase
//           .from('admin_messages')
//           .delete()
//           .eq('appointment_id', widget.appointmentId);
//       await supabase
//           .from('user_messages')
//           .delete()
//           .eq('appointment_id', widget.appointmentId);
      
//       if (mounted) {
//         // Show success message
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: const Text('Successfully deleted conversation'),
//             backgroundColor: Colors.green,
//           ),
//         );
//         Navigator.pop(context, true);
//       }
//     } catch (e) {
//       print('Error deleting conversation: $e');
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Failed to delete: $e'), backgroundColor: Colors.red),
//         );
//       }
//     }
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
//         // Convert to 12-hour format
//         int hour12 = localDt.hour;
//         String amPm = 'AM';
//         if (hour12 == 0) {
//           hour12 = 12;
//         } else if (hour12 > 12) {
//           hour12 -= 12;
//           amPm = 'PM';
//         } else if (hour12 == 12) {
//           amPm = 'PM';
//         }
//         final hour = hour12.toString().padLeft(2, '0');
//         final minute = localDt.minute.toString().padLeft(2, '0');
//         final second = localDt.second.toString().padLeft(2, '0');
        
//         formattedTime = '${localDt.year}-${localDt.month.toString().padLeft(2, '0')}-${localDt.day.toString().padLeft(2, '0')} $hour:$minute:$second $amPm';
//       }
//     }
//     return Column(
//       crossAxisAlignment: isFromAdmin ? CrossAxisAlignment.end : CrossAxisAlignment.start,
//       children: [
//         Container(
//           margin: EdgeInsets.only(
//             top: 8,
//             bottom: 8,
//             left: isFromAdmin ? 60 : 8,
//             right: isFromAdmin ? 8 : 60,
//           ),
//           child: Row(
//             mainAxisAlignment: isFromAdmin ? MainAxisAlignment.end : MainAxisAlignment.start,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               if (isFromUser) ...[
//                 CircleAvatar(
//                   radius: 18,
//                   backgroundColor: blue.withOpacity(0.15),
//                   child: Icon(Icons.person, color: blue, size: 18),
//                 ),
//                 const SizedBox(width: 8),
//               ],
//               Flexible(
//                 child: Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//                   decoration: BoxDecoration(
//                     color: isFromAdmin ? orange : Colors.white,
//                     borderRadius: BorderRadius.only(
//                       topLeft: Radius.circular(bubbleRadius),
//                       topRight: Radius.circular(bubbleRadius),
//                       bottomRight: Radius.circular(isFromAdmin ? 4 : bubbleRadius),
//                       bottomLeft: Radius.circular(isFromAdmin ? bubbleRadius : 4),
//                     ),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black.withOpacity(0.09),
//                         blurRadius: 6,
//                         offset: const Offset(0, 2),
//                       ),
//                     ],
//                   ),
//                   child: Text(
//                     msg['message'] ?? '',
//                     style: GoogleFonts.poppins(
//                       color: isFromAdmin ? Colors.white : Colors.black87,
//                       fontSize: 15,
//                       fontWeight: FontWeight.normal,
//                     ),
//                   ),
//                 ),
//               ),
//               if (isFromAdmin) ...[
//                 const SizedBox(width: 8),
//               ],
//             ],
//           ),
//         ),
//         if (formattedTime != null)
//           Padding(
//             padding: EdgeInsets.only(
//               left: 60.0,
//               right: isFromAdmin ? 8.0 : 60.0,
//               bottom: 2.0,
//             ),
//             child: Text(
//               formattedTime,
//               style: GoogleFonts.poppins(
//                 fontSize: 12,
//                 color: Colors.grey[600],
//               ),
//             ),
//           ),
//       ],
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final orange = const Color(0xFFF5A623);
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: const Color(0xFFFFF6E7),
//         elevation: 0,
//         centerTitle: true,
//         iconTheme: const IconThemeData(color: Colors.black87),
//         title: Text(
//           appointmentDetails != null && appointmentDetails!['pet_name'] != null
//               ? 'Appointment for ${appointmentDetails!['pet_name']}'
//               : 'Appointment',
//           style: GoogleFonts.poppins(
//             color: Colors.black87,
//             fontWeight: FontWeight.bold,
//             fontSize: 20,
//           ),
//         ),
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back),
//           onPressed: () {
//             Navigator.pop(context, true);
//           },
//         ),
//       ),
//       body: isLoading
//           ? const Center(child: CircularProgressIndicator(color: Color(0xFFF5A623)))
//           : hasError
//               ? Center(
//                   child: Text('Failed to load details.',
//                       style: GoogleFonts.poppins(color: Colors.red)),
//                 )
//               : Column(
//                   children: [
//                     // Chat Messages
//                     Expanded(
//                       child: Container(
//                         decoration: BoxDecoration(
//                           color: Colors.white,
//                         ),
//                         child: ListView.separated(
//                           padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
//                           itemCount: chatMessages.length,
//                           separatorBuilder: (context, index) => const SizedBox(height: 16),
//                           itemBuilder: (context, index) {
//                             final msg = chatMessages[index];
//                             return _buildChatMessage(msg, index);
//                           },
//                           controller: _scrollController,
//                         ),
//                       ),
//                     ),
//                     // Unarchive Button
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
//                             child: ElevatedButton.icon(
//                               onPressed: isUnarchiving ? null : _deleteConversation,
//                               icon: const Icon(Icons.delete, color: Colors.white),
//                               label: Text('Delete', style: GoogleFonts.poppins()),
//                               style: ElevatedButton.styleFrom(
//                                 backgroundColor: Colors.red,
//                                 foregroundColor: Colors.white,
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(25),
//                                 ),
//                                 padding: const EdgeInsets.symmetric(vertical: 14),
//                                 textStyle: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
//                               ),
//                             ),
//                           ),
//                           const SizedBox(width: 12),
//                           Expanded(
//                             child: ElevatedButton.icon(
//                               onPressed: isUnarchiving ? null : _unarchive,
//                               icon: isUnarchiving
//                                   ? const SizedBox(
//                                       width: 20,
//                                       height: 20,
//                                       child: CircularProgressIndicator(
//                                         color: Colors.white,
//                                         strokeWidth: 2,
//                                       ),
//                                     )
//                                   : const Icon(Icons.unarchive, color: Colors.white),
//                               label: Text('Unarchive', style: GoogleFonts.poppins()),
//                               style: ElevatedButton.styleFrom(
//                                 backgroundColor: orange,
//                                 foregroundColor: Colors.white,
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(25),
//                                 ),
//                                 padding: const EdgeInsets.symmetric(vertical: 14),
//                                 textStyle: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
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
// } 

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ViewArchiveAdminPage extends StatefulWidget {
  final dynamic appointmentId;
  const ViewArchiveAdminPage({Key? key, required this.appointmentId}) : super(key: key);

  @override
  State<ViewArchiveAdminPage> createState() => _ViewArchiveAdminPageState();
}

class _ViewArchiveAdminPageState extends State<ViewArchiveAdminPage> {
  final supabase = Supabase.instance.client;
  final ScrollController _scrollController = ScrollController();
  List<Map<String, dynamic>> chatMessages = [];
  bool isLoading = true;
  bool hasError = false;
  bool isUnarchiving = false;
  Map<String, dynamic>? appointmentDetails;
  Map<String, dynamic>? userDetails;

  @override
  void initState() {
    super.initState();
    _cleanupOldArchivedMessages();
    _fetchDetails();
    _fetchChat();
  }

  Future<void> _fetchDetails() async {
    try {
      final appointmentResp = await supabase
          .from('grooming_appointments')
          .select()
          .eq('id', widget.appointmentId)
          .maybeSingle();
      if (appointmentResp != null) {
        final userResp = await supabase
            .from('users')
            .select()
            .eq('id', appointmentResp['user_id'])
            .maybeSingle();
        setState(() {
          userDetails = userResp;
          appointmentDetails = appointmentResp;
        });
      }
    } catch (e) {
      // ignore
    }
  }

  Future<void> _cleanupOldArchivedMessages() async {
    try {
      // Calculate date 30 days ago
      final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));

      // Delete messages older than 30 days from admin_messages_archive
      await supabase
          .from('admin_messages_archive')
          .delete()
          .lt('archived_at', thirtyDaysAgo.toIso8601String());

      print('Debug: Cleaned up old archived messages (viewarchive_admin)');
    } catch (e) {
      print('Error cleaning up old archived messages (viewarchive_admin): $e');
    }
  }

  Future<void> _fetchChat() async {
    setState(() => isLoading = true);
    try {
      final response = await supabase
          .from('admin_messages_archive')
          .select('*')
          .eq('appointment_id', widget.appointmentId)
          .order('archived_at', ascending: false);
      setState(() {
        chatMessages = List<Map<String, dynamic>>.from(response);
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        chatMessages = [];
        isLoading = false;
        hasError = true;
      });
    }
  }

  Future<void> _refreshChat() async {
    await _fetchChat();
  }

  Future<void> _unarchive() async {
    setState(() => isUnarchiving = true);
    try {
      // Fetch all archived messages for this appointment
      final archived = await supabase
          .from('admin_messages_archive')
          .select('*')
          .eq('appointment_id', widget.appointmentId);

      if (archived is List && archived.isNotEmpty) {
        // Check if messages already exist in admin_messages table
        final existingMessages = await supabase
            .from('admin_messages')
            .select('*')
            .eq('appointment_id', widget.appointmentId);

        if (existingMessages is List && existingMessages.isNotEmpty) {
          // Messages exist, just update them to unarchived
          await supabase
              .from('admin_messages')
              .update({'is_archived': false})
              .eq('appointment_id', widget.appointmentId);
        } else {
          // Messages don't exist, insert them back
          final toRestore = archived.map((msg) {
            final data = Map<String, dynamic>.from(msg);
            data.remove('archived_at');
            data.remove('id'); // Let DB assign new id
            data['is_archived'] = false;
            return data;
          }).toList();

          // Insert back to both admin_messages and user_messages
          await supabase.from('admin_messages').insert(toRestore);
          await supabase.from('user_messages').insert(toRestore);
        }

        // Also ensure user_messages table has these messages
        final existingUserMessages = await supabase
            .from('user_messages')
            .select('*')
            .eq('appointment_id', widget.appointmentId);

        if (existingUserMessages is List && existingUserMessages.isEmpty) {
          // Insert to user_messages table to keep in sync
          final userRestoreBatch = archived.map((msg) {
            final data = Map<String, dynamic>.from(msg);
            data.remove('archived_at');
            data.remove('id'); // Let DB assign new id
            data['is_archived'] = false;
            return data;
          }).toList();

          await supabase.from('user_messages').insert(userRestoreBatch);
        } else {
          // Update existing user_messages to unarchived
          await supabase
              .from('user_messages')
              .update({'is_archived': false})
              .eq('appointment_id', widget.appointmentId);
        }

        // Delete from archive table
        final ids = archived.map((m) => m['id']).toList();
        await supabase
            .from('admin_messages_archive')
            .delete()
            .inFilter('id', ids);
      }

      if (mounted) {
        setState(() => isUnarchiving = false);

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Successfully unarchived conversation'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      print('Error unarchiving: $e');
      setState(() => isUnarchiving = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to unarchive: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _deleteConversation() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Conversation'),
        content: const Text('Are you sure you want to delete this conversation? This action cannot be undone.'),
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
      // Delete from archive
      await supabase
          .from('admin_messages_archive')
          .delete()
          .eq('appointment_id', widget.appointmentId);

      // Also delete from admin_messages and user_messages (in case of any duplicates)
      await supabase
          .from('admin_messages')
          .delete()
          .eq('appointment_id', widget.appointmentId);
      await supabase
          .from('user_messages')
          .delete()
          .eq('appointment_id', widget.appointmentId);

      if (mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Successfully deleted conversation'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      print('Error deleting conversation: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Widget _buildChatMessage(Map<String, dynamic> msg, int index) {
    final orange = const Color(0xFFF5A623);
    final blue = const Color(0xFF5094FF);
    // Robust admin/user detection
    final isFromAdmin = msg['is_from_admin'] == true || msg['is_from_admin'] == 'true' || msg['is_from_admin'] == 1;
    final isFromUser = msg['is_from_admin'] == false || msg['is_from_admin'] == 'false' || msg['is_from_admin'] == 0 || msg['is_from_admin'] == null;
    final bubbleRadius = 18.0;
    final createdAt = msg['created_at'];
    String? formattedTime;
    if (createdAt != null) {
      final dt = DateTime.tryParse(createdAt);
      if (dt != null) {
        final localDt = dt.toLocal();
        // Convert to 12-hour format
        int hour12 = localDt.hour;
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
        final minute = localDt.minute.toString().padLeft(2, '0');
        final second = localDt.second.toString().padLeft(2, '0');

        formattedTime = '${localDt.year}-${localDt.month.toString().padLeft(2, '0')}-${localDt.day.toString().padLeft(2, '0')} $hour:$minute:$second $amPm';
      }
    }
    return Column(
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
                      bottomRight: Radius.circular(isFromAdmin ? 4 : bubbleRadius),
                      bottomLeft: Radius.circular(isFromAdmin ? bubbleRadius : 4),
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
                      color: isFromAdmin ? Colors.white : Colors.black87,
                      fontSize: 15,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
              ),
              if (isFromAdmin) ...[
                const SizedBox(width: 8),
              ],
            ],
          ),
        ),
        if (formattedTime != null)
          Padding(
            padding: EdgeInsets.only(
              left: 60.0,
              right: isFromAdmin ? 8.0 : 60.0,
              bottom: 2.0,
            ),
            child: Text(
              formattedTime,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ),
      ],
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
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: const Color(0xFFF5A623),
              ),
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

  @override
  Widget build(BuildContext context) {
    final orange = const Color(0xFFF5A623);
    return Scaffold(
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
          onPressed: () {
            Navigator.pop(context, true);
          },
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFF5A623)))
          : hasError
              ? Center(
                  child: Text('Failed to load details.',
                      style: GoogleFonts.poppins(color: Colors.red)),
                )
              : Column(
                  children: [
                    // Chat Messages
                    Expanded(
                      child: RefreshIndicator(
                        color: orange,
                        onRefresh: _refreshChat,
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                          itemCount: chatMessages.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 16),
                          itemBuilder: (context, index) {
                            final msg = chatMessages[index];
                            return _buildChatMessage(msg, index);
                          },
                          controller: _scrollController,
                        ),
                      ),
                    ),
                    // Unarchive Button
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
                            child: ElevatedButton.icon(
                              onPressed: isUnarchiving ? null : _deleteConversation,
                              icon: const Icon(Icons.delete, color: Colors.white),
                              label: Text('Delete', style: GoogleFonts.poppins()),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                textStyle: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: isUnarchiving ? null : _unarchive,
                              icon: isUnarchiving
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(Icons.unarchive, color: Colors.white),
                              label: Text('Unarchive', style: GoogleFonts.poppins()),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: orange,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                textStyle: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
                              ),
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
