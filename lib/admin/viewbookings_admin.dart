// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:intl/intl.dart';
// import 'bookings_admin.dart';

// class ViewBookingsAdmin extends StatefulWidget {
//   final Map<String, dynamic> appointment;

//   const ViewBookingsAdmin({
//     super.key,
//     required this.appointment,
//   });

//   @override
//   State<ViewBookingsAdmin> createState() => _ViewBookingsAdminState();
// }

// class _ViewBookingsAdminState extends State<ViewBookingsAdmin> {
//   String _status = 'Pending'; // Pending status (selected in dropdown)
//   String _savedStatus = 'Pending'; // Saved status (from DB)

//   @override
//   void initState() {
//     super.initState();
//     // Initialize status from the appointment data
//     _status = widget.appointment['status'] ?? 'Pending';
//     _savedStatus = widget.appointment['status'] ?? 'Pending';
//     // Fetch user details if not already available
//     if (widget.appointment['user_details'] != null) {
//       _userDetails = widget.appointment['user_details'];
//     } else {
//       _fetchUserDetails();
//     }
//   }

//   Map<String, dynamic>? _userDetails;
//   late Future<void> _userDetailsFuture;

//   Future<void> _fetchUserDetails() async {
//     try {
//       final userId = widget.appointment['user_id'];
//       final userResp = await Supabase.instance.client
//           .from('users')
//           .select('full_name, email, contact_number')
//           .eq('id', userId)
//           .maybeSingle();
//       if (mounted) {
//         setState(() {
//           _userDetails = userResp;
//         });
//       }
//     } catch (e) {
//       // ignore
//     }
//   }

//   Future<void> _updateAppointmentStatus() async {
//     try {
//       await Supabase.instance.client
//           .from('grooming_appointments')
//           .update({'status': _status}).eq('id', widget.appointment['id']);

//       if (mounted) {
//         setState(() {
//           _savedStatus = _status; // Update saved status after saving
//         });
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Appointment status updated to $_status'),
//             backgroundColor: Colors.green,
//           ),
//         );
//         // Status update message is now handled automatically by database trigger
//         // await _sendStatusMessageToUser(); // Commented out - handled by database trigger
//         Navigator.pushAndRemoveUntil(
//           context,
//           MaterialPageRoute(builder: (context) => const BookingsAdminPage()),
//           (route) => false,
//         ); // Always return to BookingsAdminPage after saving
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Error updating status: $e'),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final orange = const Color(0xFFF5A623);
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: Container(
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             colors: [Color(0xFFFFF6E7), Colors.white],
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//           ),
//         ),
//         child: SafeArea(
//           child: SingleChildScrollView(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Move the AppBar row to the top
//                 Row(
//                   children: [
//                     IconButton(
//                       icon: const Icon(Icons.arrow_back),
//                       onPressed: () => Navigator.pop(context),
//                     ),
//                     Text(
//                       'Appointment Details',
//                       style: GoogleFonts.poppins(
//                         fontSize: 20,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.black,
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 16),
//                 if (_userDetails != null) ...[
//                   _buildInfoCard(
//                     title: 'User Details',
//                     children: [
//                       _buildInfoRow('Full Name', _userDetails?['full_name'] ?? '-'),
//                       _buildInfoRow('Email', _userDetails?['email'] ?? '-'),
//                       _buildInfoRow('Contact', _userDetails?['contact_number'] ?? '-'),
//                     ],
//                   ),
//                   const SizedBox(height: 16),
//                 ],
//                 _buildInfoCard(
//                   title: 'Pet Information',
//                   children: [
//                     _buildInfoRow(
//                         'Name', widget.appointment['pet_name'] ?? 'N/A'),
//                     _buildInfoRow(
//                         'Type', widget.appointment['pet_type'] ?? 'N/A'),
//                     _buildInfoRow(
//                         'Breed', widget.appointment['breed'] ?? 'N/A'),
//                     _buildInfoRow(
//                         'Size', widget.appointment['pet_size'] ?? 'N/A'),
//                     _buildInfoRow(
//                         'Age', widget.appointment['age']?.toString() ?? 'N/A'),
//                     _buildInfoRow(
//                         'Gender', widget.appointment['gender'] ?? 'N/A'),
//                   ],
//                 ),
//                 const SizedBox(height: 16),
//                 _buildInfoCard(
//                   title: 'Appointment Details',
//                   children: [
//                     _buildInfoRow(
//                       'Date',
//                       widget.appointment['preferred_date'] != null
//                           ? DateFormat('MMMM dd, yyyy').format(DateTime.parse(
//                               widget.appointment['preferred_date']))
//                           : 'N/A',
//                     ),
//                     _buildInfoRow(
//                         'Time', widget.appointment['preferred_time'] ?? 'N/A'),
//                     _buildInfoRow(
//                       'Duration',
//                       _formatDuration(
//                           widget.appointment['estimated_duration'] ?? 0),
//                     ),
//                     _buildInfoRow(
//                         'Services', _getSelectedServices(widget.appointment)),
//                     if (widget.appointment['haircut_extra_option'] != null && (widget.appointment['haircut_extra_option'] as String).isNotEmpty)
//                       _buildInfoRow(
//                         'Extra Haircut Option',
//                         widget.appointment['haircut_extra_option'] == 'super_furry'
//                           ? 'For Super Furry Hair Coat'
//                           : widget.appointment['haircut_extra_option'] == 'severely_matted'
//                             ? 'For Severely Matted Fur'
//                             : widget.appointment['haircut_extra_option'],
//                       ),
//                   ],
//                 ),
//                 const SizedBox(height: 16),
//                 _buildInfoCard(
//                   title: 'Additional Information',
//                   children: [
//                     _buildInfoRow(
//                       'Medical Conditions',
//                       (widget.appointment['allergies_medical_conditions'] == null ||
//                        (widget.appointment['allergies_medical_conditions'] as String).trim().isEmpty)
//                         ? 'None'
//                         : widget.appointment['allergies_medical_conditions'],
//                     ),
//                     _buildInfoRow(
//                       'Special Requests',
//                       (widget.appointment['special_requests_notes'] == null ||
//                        (widget.appointment['special_requests_notes'] as String).trim().isEmpty)
//                         ? 'None'
//                         : widget.appointment['special_requests_notes'],
//                     ),
//                     _buildInfoRow(
//                       'Payment Method',
//                       widget.appointment['payment_method'] ?? 'N/A',
//                     ),
//                     _buildInfoRow(
//                       'Estimated Cost',
//                       '₱${widget.appointment['estimated_cost']?.toString() ?? 'N/A'}',
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 24),
//                 _buildStatusSection(),
//                 const SizedBox(height: 24),
//                 _buildActionButtons(),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildInfoCard({
//     required String title,
//     required List<Widget> children,
//   }) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 10,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             title,
//             style: GoogleFonts.poppins(
//               fontSize: 16,
//               fontWeight: FontWeight.bold,
//               color: const Color(0xFF5094FF),
//             ),
//           ),
//           const SizedBox(height: 12),
//           ...children,
//         ],
//       ),
//     );
//   }

//   Widget _buildInfoRow(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 8),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           SizedBox(
//             width: 120,
//             child: Text(
//               label,
//               style: GoogleFonts.poppins(
//                 fontSize: 14,
//                 color: Colors.grey[600],
//               ),
//             ),
//           ),
//           Expanded(
//             child: Text(
//               value,
//               style: GoogleFonts.poppins(
//                 fontSize: 14,
//                 fontWeight: FontWeight.w500,
//                 color: Colors.black87,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildStatusSection() {
//     Color statusColor;
//     Color statusTextColor;
//     switch (_status) {
//       case 'Approved':
//         statusColor = const Color(0xFFE8F5E9);
//         statusTextColor = Colors.green;
//         break;
//       case 'Cancelled':
//       case 'Cancelled (by user)': // Handle user cancellation
//         statusColor = const Color(0xFFFFEBEE);
//         statusTextColor = Colors.red;
//         break;
//       case 'Completed':
//         statusColor = const Color(0xFFE3F2FD);
//         statusTextColor = Colors.blue;
//         break;
//       // case 'Rescheduled':
//       //   statusColor = const Color(0xFFE0BBE4);
//       //   statusTextColor = Colors.purple;
//       //   break;
//       default: // Pending
//         statusColor = const Color(0xFFFFF3E0);
//         statusTextColor = const Color(0xFFFB8C00);
//     }

//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 10,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             'Status',
//             style: GoogleFonts.poppins(
//               fontSize: 16,
//               fontWeight: FontWeight.bold,
//               color: const Color(0xFF5094FF),
//             ),
//           ),
//           const SizedBox(height: 12),
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//             decoration: BoxDecoration(
//               color: statusColor,
//               borderRadius: BorderRadius.circular(8),
//               border: Border.all(color: statusTextColor),
//             ),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   _status,
//                   style: GoogleFonts.poppins(
//                     fontSize: 14,
//                     fontWeight: FontWeight.w500,
//                     color: statusTextColor,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           // Only show dropdown if status is not 'Cancelled' (by user or automatic) and not 'Completed'
//           if (_savedStatus != 'Cancelled (by user)' && _savedStatus != 'Cancelled' && _savedStatus != 'Completed') ...[
//           const SizedBox(height: 16),
//           DropdownButtonFormField<String>(
//             value: _status,
//             decoration: InputDecoration(
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               contentPadding:
//                   const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//             ),
//             items: [
//               'Pending',
//               'Approved',
//               'Cancelled',
//               'Completed',
//             ]
//                 .map((status) => DropdownMenuItem(
//                       value: status,
//                       child: Text(status),
//                     ))
//                 .toList(),
//               onChanged: (_savedStatus == 'Completed')
//                     ? null
//                     : (value) {
//                         if (value != null) {
//                           setState(() {
//                             _status = value;
//                           });
//                         }
//                       },
//           ),
//           ],
//         ],
//       ),
//     );
//   }

//   Widget _buildActionButtons() {
//     final isCancelledByUser = _savedStatus == 'Cancelled (by user)';
//     final isCancelledBySystem = _savedStatus == 'Cancelled';
//     final isCompletedAndSaved = _savedStatus == 'Completed';
//     return Row(
//       children: [
//         Expanded(
//           child: ElevatedButton(
//             onPressed: (isCancelledByUser || isCancelledBySystem || isCompletedAndSaved) ? null : _updateAppointmentStatus,
//             style: ElevatedButton.styleFrom(
//               backgroundColor: const Color(0xFF5094FF),
//               padding: const EdgeInsets.symmetric(vertical: 16),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(8),
//               ),
//             ),
//             child: Text(
//               'Save Changes',
//               style: GoogleFonts.poppins(
//                 fontSize: 16,
//                 fontWeight: FontWeight.w600,
//                 color: Colors.white,
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   String _getSelectedServices(Map<String, dynamic> appointment) {
//     final services = <String>[];
//     if (appointment['service_bath'] == true) services.add('Bath');
//     if (appointment['service_haircut'] == true) services.add('Haircut');
//     if (appointment['service_nail_trim'] == true) services.add('Nail Trim');
//     if (appointment['service_ear_cleaning'] == true)
//       services.add('Ear Cleaning');
//     return services.join(', ');
//   }

//   String _formatDuration(int minutes) {
//     if (minutes < 60) {
//       return '$minutes minutes';
//     } else {
//       int hours = minutes ~/ 60;
//       int remainingMinutes = minutes % 60;
//       if (remainingMinutes == 0) {
//         return '$hours hour${hours > 1 ? 's' : ''}';
//       }
//       return '$hours hour${hours > 1 ? 's' : ''} and $remainingMinutes minutes';
//     }
//   }
// }


// --

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'bookings_admin.dart';

class ViewBookingsAdmin extends StatefulWidget {
  final Map<String, dynamic> appointment;

  const ViewBookingsAdmin({
    super.key,
    required this.appointment,
  });

  @override
  State<ViewBookingsAdmin> createState() => _ViewBookingsAdminState();
}

class _ViewBookingsAdminState extends State<ViewBookingsAdmin> {
  String _status = 'Pending'; // Pending status (selected in dropdown)
  String _savedStatus = 'Pending'; // Saved status (from DB)

  @override
  void initState() {
    super.initState();
    // Initialize status from the appointment data
    _status = widget.appointment['status'] ?? 'Pending';
    _savedStatus = widget.appointment['status'] ?? 'Pending';
    // Fetch user details if not already available
    if (widget.appointment['user_details'] != null) {
      _userDetails = widget.appointment['user_details'];
    } else {
      _fetchUserDetails();
    }
  }

  Map<String, dynamic>? _userDetails;
  late Future<void> _userDetailsFuture;

  Future<void> _fetchUserDetails() async {
    try {
      final userId = widget.appointment['user_id'];
      final userResp = await Supabase.instance.client
          .from('users')
          .select('full_name, email, contact_number')
          .eq('id', userId)
          .maybeSingle();
      if (mounted) {
        setState(() {
          _userDetails = userResp;
        });
      }
    } catch (e) {
      // ignore
    }
  }

  Future<void> _updateAppointmentStatus() async {
    try {
      await Supabase.instance.client
          .from('grooming_appointments')
          .update({'status': _status}).eq('id', widget.appointment['id']);

      if (mounted) {
        setState(() {
          _savedStatus = _status; // Update saved status after saving
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Appointment status updated to $_status'),
            backgroundColor: Colors.green,
          ),
        );
        // Send status update message to user
        await _sendStatusMessageToUser();
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const BookingsAdminPage()),
          (route) => false,
        ); // Always return to BookingsAdminPage after saving
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating status: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _sendStatusMessageToUser() async {
    final userId = widget.appointment['user_id'];
    final petName = widget.appointment['pet_name'] ?? '';
    final date = widget.appointment['preferred_date'] != null
        ? DateFormat('yyyy-MM-dd').format(DateTime.parse(widget.appointment['preferred_date']))
        : '';
    final timeRaw = widget.appointment['preferred_time'] ?? '';
    String time = '';
    try {
      if (timeRaw.isNotEmpty) {
        final parsedTime = DateFormat('HH:mm').parse(timeRaw);
        time = DateFormat('h:mm a').format(parsedTime);
      }
    } catch (e) {
      time = timeRaw; // fallback to raw if parsing fails
    }
    String message = '';
    if (_status == 'Approved') {
      message = 'Your grooming appointment for $petName on $date at $time has been APPROVED. Please arrive on time to avoid any inconvenience. Thank you!';
    } else if (_status == 'Cancelled') {
      message = 'Your grooming appointment for $petName on $date at $time has been CANCELLED. We\'re sorry for any inconvenience this may have caused. If you reconsider, you may be able to book an appointment at a later date. Thank you for understanding!';
    } else if (_status == 'Completed') {
      message = 'Your grooming appointment for $petName on $date at $time has been COMPLETED. Thank you for trusting our services! We look forward to seeing you again.';
    } else {
      return;
    }
    await Supabase.instance.client.from('admin_messages').insert({
      'user_id': userId,
      'appointment_id': widget.appointment['id'],
      'message': message,
      'is_from_admin': true,
      'is_read': false,
    });
    await Supabase.instance.client.from('user_messages').insert({
      'user_id': userId,
      'appointment_id': widget.appointment['id'],
      'message': message,
      'is_from_admin': true,
      'is_read': false,
    });
  }

  @override
  Widget build(BuildContext context) {
    final orange = const Color(0xFFF5A623);
    return Scaffold(
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Move the AppBar row to the top
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Text(
                      'Appointment Details',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (_userDetails != null) ...[
                  _buildInfoCard(
                    title: 'User Details',
                    children: [
                      _buildInfoRow('Full Name', _userDetails?['full_name'] ?? '-'),
                      _buildInfoRow('Email', _userDetails?['email'] ?? '-'),
                      _buildInfoRow('Contact', _userDetails?['contact_number'] ?? '-'),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
                _buildInfoCard(
                  title: 'Pet Information',
                  children: [
                    _buildInfoRow(
                        'Name', widget.appointment['pet_name'] ?? 'N/A'),
                    _buildInfoRow(
                        'Type', widget.appointment['pet_type'] ?? 'N/A'),
                    _buildInfoRow(
                        'Breed', widget.appointment['breed'] ?? 'N/A'),
                    _buildInfoRow(
                        'Size', widget.appointment['pet_size'] ?? 'N/A'),
                    _buildInfoRow(
                        'Age', widget.appointment['age']?.toString() ?? 'N/A'),
                    _buildInfoRow(
                        'Gender', widget.appointment['gender'] ?? 'N/A'),
                  ],
                ),
                const SizedBox(height: 16),
                _buildInfoCard(
                  title: 'Appointment Details',
                  children: [
                    _buildInfoRow(
                      'Date',
                      widget.appointment['preferred_date'] != null
                          ? DateFormat('MMMM dd, yyyy').format(DateTime.parse(
                              widget.appointment['preferred_date']))
                          : 'N/A',
                    ),
                    _buildInfoRow(
                        'Time', widget.appointment['preferred_time'] ?? 'N/A'),
                    _buildInfoRow(
                      'Duration',
                      _formatDuration(
                          widget.appointment['estimated_duration'] ?? 0),
                    ),
                    _buildInfoRow(
                        'Services', _getSelectedServices(widget.appointment)),
                    if (widget.appointment['haircut_extra_option'] != null && (widget.appointment['haircut_extra_option'] as String).isNotEmpty)
                      _buildInfoRow(
                        'Extra Haircut Option',
                        widget.appointment['haircut_extra_option'] == 'super_furry'
                          ? 'For Super Furry Hair Coat'
                          : widget.appointment['haircut_extra_option'] == 'severely_matted'
                            ? 'For Severely Matted Fur'
                            : widget.appointment['haircut_extra_option'],
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildInfoCard(
                  title: 'Additional Information',
                  children: [
                    _buildInfoRow(
                      'Medical Conditions',
                      (widget.appointment['allergies_medical_conditions'] == null ||
                       (widget.appointment['allergies_medical_conditions'] as String).trim().isEmpty)
                        ? 'None'
                        : widget.appointment['allergies_medical_conditions'],
                    ),
                    _buildInfoRow(
                      'Special Requests',
                      (widget.appointment['special_requests_notes'] == null ||
                       (widget.appointment['special_requests_notes'] as String).trim().isEmpty)
                        ? 'None'
                        : widget.appointment['special_requests_notes'],
                    ),
                    _buildInfoRow(
                      'Payment Method',
                      widget.appointment['payment_method'] ?? 'N/A',
                    ),
                    _buildInfoRow(
                      'Estimated Cost',
                      '₱${widget.appointment['estimated_cost']?.toString() ?? 'N/A'}',
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _buildStatusSection(),
                const SizedBox(height: 24),
                _buildActionButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF5094FF),
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ),
          
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusSection() {
    Color statusColor;
    Color statusTextColor;
    switch (_status) {
      case 'Approved':
        statusColor = const Color(0xFFE8F5E9);
        statusTextColor = Colors.green;
        break;
      case 'Cancelled':
      case 'Cancelled (by user)': // Handle user cancellation
        statusColor = const Color(0xFFFFEBEE);
        statusTextColor = Colors.red;
        break;
      case 'Completed':
        statusColor = const Color(0xFFE3F2FD);
        statusTextColor = Colors.blue;
        break;
      // case 'Rescheduled':
      //   statusColor = const Color(0xFFE0BBE4);
      //   statusTextColor = Colors.purple;
      //   break;
      default: // Pending
        statusColor = const Color(0xFFFFF3E0);
        statusTextColor = const Color(0xFFFB8C00);
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Status',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF5094FF),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: statusTextColor),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _status,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: statusTextColor,
                  ),
                ),
              ],
            ),
          ),
          // Only show dropdown if status is not 'Cancelled' (by user or automatic) and not 'Completed'
          if (_savedStatus != 'Cancelled (by user)' && _savedStatus != 'Cancelled' && _savedStatus != 'Completed') ...[
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _status,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            items: [
              'Pending',
              'Approved',
              'Cancelled',
              'Completed',
            ]
                .map((status) => DropdownMenuItem(
                      value: status,
                      child: Text(status),
                    ))
                .toList(),
              onChanged: (_savedStatus == 'Completed')
                    ? null
                    : (value) {
                        if (value != null) {
                          setState(() {
                            _status = value;
                          });
                        }
                      },
          ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    final isCancelledByUser = _savedStatus == 'Cancelled (by user)';
    final isCancelledBySystem = _savedStatus == 'Cancelled';
    final isCompletedAndSaved = _savedStatus == 'Completed';
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: (isCancelledByUser || isCancelledBySystem || isCompletedAndSaved) ? null : _updateAppointmentStatus,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5094FF),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Save Changes',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _getSelectedServices(Map<String, dynamic> appointment) {
    final services = <String>[];
    if (appointment['service_bath'] == true) services.add('Bath');
    if (appointment['service_haircut'] == true) services.add('Haircut');
    if (appointment['service_nail_trim'] == true) services.add('Nail Trim');
    if (appointment['service_ear_cleaning'] == true)
      services.add('Ear Cleaning');
    return services.join(', ');
  }

  String _formatDuration(int minutes) {
    if (minutes < 60) {
      return '$minutes minutes';
    } else {
      int hours = minutes ~/ 60;
      int remainingMinutes = minutes % 60;
      if (remainingMinutes == 0) {
        return '$hours hour${hours > 1 ? 's' : ''}';
      }
      return '$hours hour${hours > 1 ? 's' : ''} and $remainingMinutes minutes';
    }
  }
}
