// // import 'package:flutter/material.dart';
// // import 'package:google_fonts/google_fonts.dart';
// // import 'package:supabase_flutter/supabase_flutter.dart';
// // import 'package:intl/intl.dart';
// // import '../config/supabase_config.dart';
// // import '../utils/message_tracking_utils.dart';

// // class ServiceDuration {
// //   final int bath;
// //   final int haircut;
// //   final int earCleaning;
// //   final int nailTrim;

// //   const ServiceDuration({
// //     required this.bath,
// //     required this.haircut,
// //     required this.earCleaning,
// //     required this.nailTrim,
// //   });

// //   int getTotalDuration(
// //       bool hasBath, bool hasHaircut, bool hasEarCleaning, bool hasNailTrim) {
// //     int total = 0;
// //     if (hasBath) total += bath;
// //     if (hasHaircut) total += haircut;
// //     if (hasEarCleaning) total += earCleaning;
// //     if (hasNailTrim) total += nailTrim;
// //     return total;
// //   }

// //   String formatDuration(int minutes) {
// //     if (minutes < 60) {
// //       return '$minutes minutes';
// //     } else {
// //       int hours = minutes ~/ 60;
// //       int remainingMinutes = minutes % 60;
// //       if (remainingMinutes == 0) {
// //         return '$hours hour${hours > 1 ? 's' : ''}';
// //       }
// //       return '$hours hour${hours > 1 ? 's' : ''} and $remainingMinutes minutes';
// //     }
// //   }
// // }

// // class GroomingAppointmentPage extends StatefulWidget {
// //   final Map<String, dynamic>? appointment;
// //   const GroomingAppointmentPage({super.key, this.appointment});

// //   @override
// //   State<GroomingAppointmentPage> createState() =>
// //       _GroomingAppointmentPageState();
// // }

// // class _GroomingAppointmentPageState extends State<GroomingAppointmentPage> {
// //   final _supabase = Supabase.instance.client;
// //   bool _isLoading = false;

// //   // Service durations based on pet size
// //   final Map<String, Map<String, int>> _serviceDurations = {
// //     'Small': {
// //       'bath': 30,
// //       'haircut': 40,
// //       'earCleaning': 10,
// //       'nailTrim': 10,
// //     },
// //     'Medium': {
// //       'bath': 40,
// //       'haircut': 60,
// //       'earCleaning': 10,
// //       'nailTrim': 10,
// //     },
// //     'Large': {
// //       'bath': 50,
// //       'haircut': 80,
// //       'earCleaning': 10,
// //       'nailTrim': 10,
// //     },
// //   };

// //   // Service prices based on pet size
// //   final Map<String, Map<String, int>> _servicePrices = {
// //     'Small': {
// //       'bath': 300,
// //       'haircut': 400,
// //       'nailTrim': 100,
// //       'earCleaning': 100,
// //     },
// //     'Medium': {
// //       'bath': 400,
// //       'haircut': 500,
// //       'nailTrim': 110,
// //       'earCleaning': 110,
// //     },
// //     'Large': {
// //       'bath': 500,
// //       'haircut': 600,
// //       'nailTrim': 120,
// //       'earCleaning': 120,
// //     },
// //   };

// //   String _formatDuration(int minutes) {
// //     if (minutes < 60) {
// //       return '$minutes minutes';
// //     } else {
// //       int hours = minutes ~/ 60;
// //       int remainingMinutes = minutes % 60;
// //       if (remainingMinutes == 0) {
// //         return '$hours hour${hours > 1 ? 's' : ''}';
// //       }
// //       return '$hours hour${hours > 1 ? 's' : ''} and $remainingMinutes minutes';
// //     }
// //   }

// //   int _calculateTotalDuration() {
// //     if (_selectedPetSize == null) return 0;

// //     final durations = _serviceDurations[_selectedPetSize]!;
// //     int total = 0;

// //     if (_serviceBath) total += durations['bath']!;
// //     if (_serviceHaircut) total += durations['haircut']!;
// //     if (_serviceEarCleaning) total += durations['earCleaning']!;
// //     if (_serviceNailTrim) total += durations['nailTrim']!;

// //     // Add extra time for haircut options
// //     if (_serviceHaircut) {
// //       if (_haircutExtraOption == 'super_furry') {
// //         total += 20; // Add 20 minutes for super furry coat
// //       } else if (_haircutExtraOption == 'severely_matted') {
// //         total += 30; // Add 30 minutes for severely matted fur
// //       }
// //     }

// //     return total;
// //   }

// //   // Pet Information
// //   final _petNameController = TextEditingController();
// //   String? _selectedPetType;
// //   final _petTypeOtherController = TextEditingController();
// //   final _breedController = TextEditingController();
// //   String? _selectedPetSize;
// //   final _ageController = TextEditingController();
// //   String? _selectedGender;
// //   final _allergiesController = TextEditingController();

// //   // Grooming Services Details
// //   bool _serviceBath = false;
// //   bool _serviceHaircut = false;
// //   bool _serviceNailTrim = false;
// //   bool _serviceEarCleaning = false;
// //   final _specialRequestsController = TextEditingController();

// //   // Add state for extra haircut options
// //   String? _haircutExtraOption; // null, 'super_furry', or 'severely_matted'

// //   // Appointment Details
// //   DateTime? _preferredDate;
// //   TimeOfDay? _preferredTime;

// //   // Payment Information
// //   double _estimatedCost = 0.0;
// //   String? _selectedPaymentMethod;
// //   bool _consentPhotos = false;

// //   // Function to get available time slots for a date
// //   Future<List<TimeOfDay>> _getAvailableTimeSlots(DateTime date) async {
// //     try {
// //       final formattedDate = date.toIso8601String().split('T')[0];

// //       final response = await _supabase
// //           .from('grooming_appointments')
// //           .select('preferred_time, estimated_duration, status')
// //           .eq('preferred_date', formattedDate)
// //           .not('status', 'in', ['Cancelled', 'Cancelled (by user)']); // Exclude cancelled appointments

// //       // Convert booked times and durations to TimeOfDay ranges
// //       final bookedRanges = response.map((appointment) {
// //         final parts = appointment['preferred_time'].split(':');
// //         final startTime =
// //             TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));

// //         // Calculate end time based on duration + 10 min buffer
// //         final duration = appointment['estimated_duration'] as int;
// //         final totalMinutes = startTime.hour * 60 + startTime.minute + duration + 10;
// //         final endHour = totalMinutes ~/ 60;
// //         final endMinute = totalMinutes % 60;
// //         final endTime = TimeOfDay(hour: endHour, minute: endMinute);

// //         return [startTime, endTime];
// //       }).toList();

// //       // Generate all possible time slots (business hours 9 AM to 12 PM and 1 PM to 5 PM, 10 min intervals)
// //       final allTimeSlots = <TimeOfDay>[];
// //       // 9:00 AM to 11:50 AM
// //       for (int hour = 9; hour < 12; hour++) {
// //         for (int minute = 0; minute < 60; minute += 10) {
// //           allTimeSlots.add(TimeOfDay(hour: hour, minute: minute));
// //         }
// //       }
// //       // 1:00 PM to 4:50 PM
// //       for (int hour = 13; hour < 17; hour++) {
// //         for (int minute = 0; minute < 60; minute += 10) {
// //           allTimeSlots.add(TimeOfDay(hour: hour, minute: minute));
// //         }
// //       }

// //       // Calculate the end time for the current service
// //       final currentDuration = _calculateTotalDuration();

// //       // Filter out slots that would overlap with existing appointments (including 10 min buffer)
// //       return allTimeSlots.where((slot) {
// //         // Calculate end time for this slot + 10 min buffer
// //         final slotTotalMinutes = slot.hour * 60 + slot.minute + currentDuration + 10;
// //         final slotEndHour = slotTotalMinutes ~/ 60;
// //         final slotEndMinute = slotTotalMinutes % 60;
// //         final slotEndTime = TimeOfDay(hour: slotEndHour, minute: slotEndMinute);

// //         // Business logic: Service must not span across 12 PM to 1 PM
// //         final slotStartMinutes = slot.hour * 60 + slot.minute;
// //         final slotEndMinutes = slotEndHour * 60 + slotEndMinute;
// //         // If the slot starts before 12:00 and ends after 12:00, it crosses the break
// //         if (slotStartMinutes < 12 * 60 && slotEndMinutes > 12 * 60) {
// //           return false;
// //         }
// //         // If the slot starts before 13:00 and ends after 13:00, it crosses into the afternoon block
// //         if (slotStartMinutes < 13 * 60 && slotEndMinutes > 13 * 60 && slotStartMinutes >= 12 * 60) {
// //           return false;
// //         }
// //         // If the slot ends after 17:00, it's outside business hours
// //         if (slotEndMinutes > 17 * 60) {
// //           return false;
// //         }

// //         // Check if this slot would overlap with any existing appointment
// //         for (var range in bookedRanges) {
// //           final existingStart = range[0] as TimeOfDay;
// //           final existingEnd = range[1] as TimeOfDay;

// //           // Convert all times to minutes for easier comparison
// //           final existingStartMinutes =
// //               existingStart.hour * 60 + existingStart.minute;
// //           final existingEndMinutes = existingEnd.hour * 60 + existingEnd.minute;

// //           // Check for overlap
// //           if (slotStartMinutes < existingEndMinutes &&
// //               slotEndMinutes > existingStartMinutes) {
// //             return false; // This slot overlaps with an existing appointment
// //           }
// //         }
// //         return true; // This slot is available
// //       }).toList();
// //     } catch (e) {
// //       print('Error getting available time slots: $e');
// //       return [];
// //     }
// //   }

// //   // Function to show available time slots
// //   Future<void> _showAvailableTimeSlots(
// //       BuildContext context, DateTime date) async {
// //     final availableSlots = await _getAvailableTimeSlots(date);

// //     if (availableSlots.isEmpty) {
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         const SnackBar(
// //           content: Text(
// //               'No available time slots for this date. Please select another date.'),
// //           backgroundColor: Colors.red,
// //         ),
// //       );
// //       return;
// //     }

// //     if (!mounted) return;

// //     final currentDuration = _calculateTotalDuration();
// //     final durationText = _formatDuration(currentDuration);

// //     showDialog(
// //       context: context,
// //       builder: (BuildContext context) {
// //         return AlertDialog(
// //           title: Text(
// //             'Available Time Slots',
// //             style: GoogleFonts.poppins(
// //               fontWeight: FontWeight.w600,
// //               color: const Color(0xFFF5A623),
// //             ),
// //           ),
// //           content: SingleChildScrollView(
// //             child: Column(
// //               mainAxisSize: MainAxisSize.min,
// //               crossAxisAlignment: CrossAxisAlignment.start,
// //               children: [
// //                 Text(
// //                   'Service Duration: $durationText',
// //                   style: GoogleFonts.poppins(
// //                     fontSize: 14,
// //                     color: Colors.grey[600],
// //                   ),
// //                 ),
// //                 const SizedBox(height: 8),
// //                 // Text(
// //                 //   'Note: The full duration of the service will be reserved.',
// //                 //   style: GoogleFonts.poppins(
// //                 //     fontSize: 12,
// //                 //     color: Colors.grey[600],
// //                 //     fontStyle: FontStyle.italic,
// //                 //   ),
// //                 // ),
// //                 const SizedBox(height: 16),
// //                 ...availableSlots.map((time) {
// //                   final endTime = TimeOfDay(
// //                     hour:
// //                         (time.hour * 60 + time.minute + currentDuration) ~/ 60,
// //                     minute:
// //                         (time.hour * 60 + time.minute + currentDuration) % 60,
// //                   );
// //                   return ListTile(
// //                     title: Text(
// //                       '${time.format(context)} - ${endTime.format(context)}',
// //                       style: GoogleFonts.poppins(),
// //                     ),
// //                     onTap: () {
// //                       setState(() {
// //                         _preferredTime = time;
// //                       });
// //                       Navigator.pop(context);
// //                     },
// //                   );
// //                 }).toList(),
// //               ],
// //             ),
// //           ),
// //           actions: [
// //             TextButton(
// //               onPressed: () => Navigator.pop(context),
// //               child: Text(
// //                 'Cancel',
// //                 style: GoogleFonts.poppins(
// //                   color: Colors.grey[600],
// //                 ),
// //               ),
// //             ),
// //           ],
// //         );
// //       },
// //     );
// //   }

// //   // Calculate estimated cost
// //   void _calculateEstimatedCost() {
// //     _estimatedCost = 0.0;
// //     if (_selectedPetSize != null) {
// //       final prices = _servicePrices[_selectedPetSize]!;
// //       if (_serviceBath) _estimatedCost += prices['bath']!;
// //       if (_serviceHaircut) _estimatedCost += prices['haircut']!;
// //       if (_serviceNailTrim) _estimatedCost += prices['nailTrim']!;
// //       if (_serviceEarCleaning) _estimatedCost += prices['earCleaning']!;
// //     }

// //     // Add extra cost for haircut options
// //     if (_serviceHaircut) {
// //       if (_haircutExtraOption == 'super_furry') {
// //         _estimatedCost += 200.0;
// //       } else if (_haircutExtraOption == 'severely_matted') {
// //         _estimatedCost += 300.0;
// //       }
// //     } else {
// //       _haircutExtraOption = null; // Reset if haircut is unchecked
// //     }
// //     setState(() {}); // Update the UI to show the new cost
// //   }

// //   // Dispose controllers
// //   @override
// //   void dispose() {
// //     _petNameController.dispose();
// //     _petTypeOtherController.dispose();
// //     _breedController.dispose();
// //     _ageController.dispose();
// //     _allergiesController.dispose();
// //     _specialRequestsController.dispose();
// //     super.dispose();
// //   }

// //   // Add this function after the existing functions but before the build method
// //   Future<void> _checkAndSendReminders() async {
// //     try {
// //       final supabase = Supabase.instance.client;
// //       final now = DateTime.now();
// //       final response = await supabase
// //           .from('grooming_appointments')
// //           .select('id, user_id, pet_name, preferred_date, preferred_time, status')
// //           .eq('status', 'Pending');
// //         for (final appointment in response) {
// //           final appointmentDate = DateTime.parse(appointment['preferred_date']);
// //           final appointmentTime = appointment['preferred_time'];
// //           final timeParts = appointmentTime.split(':');
// //           final appointmentHour = int.parse(timeParts[0]);
// //           final appointmentMinute = int.parse(timeParts[1]);
// //           final appointmentDateTime = DateTime(
// //             appointmentDate.year,
// //             appointmentDate.month,
// //             appointmentDate.day,
// //             appointmentHour,
// //             appointmentMinute,
// //           );
// //         // Calculate the reminder time (24 hours before appointment)
// //         final reminderTime = appointmentDateTime.subtract(const Duration(hours: 24));
// //         // Send reminder if we're within the 24-hour period before the appointment time
// //         if (now.isBefore(appointmentDateTime) && now.isAfter(reminderTime)) {
// //             final userResponse = await supabase
// //                 .from('users')
// //                 .select('full_name')
// //                 .eq('id', appointment['user_id'])
// //                 .maybeSingle();
// //             final userFullName = userResponse != null ? userResponse['full_name'] ?? 'Unknown' : 'Unknown';
// //             final reminderMessage = 'REMINDER: Appointment approaching - Status still PENDING\n\n'
// //                   'Pet: ${appointment['pet_name']}\n'
// //                 'Date: ${DateFormat('MMMM dd, yyyy').format(DateTime.parse(appointment['preferred_date']))}\n'
// //                 'Time: ${_formatTime(appointment['preferred_time'])}\n'
// //                 'Owner: $userFullName\n\n'
// //                   'Please update the appointment status.';

// //           // Use the tracking utility to send reminder only if not already sent
// //           await MessageTrackingUtils.sendReminderIfNotSent(
// //             appointment['id'],
// //             appointment['user_id'],
// //             reminderMessage,
// //           );
// //         }
// //       }
// //     } catch (e) {
// //       print('Error checking for reminders: $e');
// //     }
// //   }

// //   @override
// //   void initState() {
// //     super.initState();
// //     if (widget.appointment != null) {
// //       debugPrint(
// //           'Appointment data received for editing: ${widget.appointment}');

// //       try {
// //         // Always pre-fill pet details with safe null handling
// //         _petNameController.text = widget.appointment!['pet_name']?.toString() ?? '';
// //         _selectedPetType = widget.appointment!['pet_type']?.toString();
// //         if (_selectedPetType == 'Others') {
// //           _petTypeOtherController.text =
// //               widget.appointment!['pet_type_other']?.toString() ?? '';
// //         }
// //         _breedController.text = widget.appointment!['breed']?.toString() ?? '';
// //         _selectedPetSize = widget.appointment!['pet_size']?.toString();
// //         _ageController.text = widget.appointment!['age']?.toString() ?? '';
// //         _selectedGender = widget.appointment!['gender']?.toString();
// //         _allergiesController.text =
// //             widget.appointment!['allergies_medical_conditions']?.toString() ?? '';

// //         // Recalculate cost after pre-filling pet details
// //         _calculateEstimatedCost();

// //         // Force UI update to reflect pre-filled pet size
// //         setState(() {});
// //       } catch (e) {
// //         print('Error pre-filling appointment data: $e');
// //         // Continue with empty form if there's an error
// //       }

// //       // Pre-fill appointment details for editing
// //         _serviceBath = widget.appointment!['service_bath'] ?? false;
// //         _serviceHaircut = widget.appointment!['service_haircut'] ?? false;
// //         _serviceNailTrim = widget.appointment!['service_nail_trim'] ?? false;
// //         _serviceEarCleaning =
// //             widget.appointment!['service_ear_cleaning'] ?? false;
// //         _specialRequestsController.text =
// //             widget.appointment!['special_requests_notes'] ?? '';
// //         // _haircutExtraOption is not loaded from DB, keep as null or set by UI only
// //         _preferredDate = widget.appointment!['preferred_date'] != null
// //             ? DateTime.parse(widget.appointment!['preferred_date'])
// //             : null;
// //         _preferredTime = widget.appointment!['preferred_time'] != null
// //             ? TimeOfDay(
// //                 hour: int.parse(
// //                     widget.appointment!['preferred_time'].split(':')[0]),
// //                 minute: int.parse(
// //                     widget.appointment!['preferred_time'].split(':')[1]))
// //             : null;
// //         _estimatedCost =
// //             (widget.appointment!['estimated_cost'] ?? 0.0).toDouble();
// //         _selectedPaymentMethod = widget.appointment!['payment_method'];
// //         _consentPhotos = widget.appointment!['consent_photos'] ?? false;
// //     }
// //     _calculateEstimatedCost();

// //     // Check for reminders when the page loads
// //     // _checkAndSendReminders(); // Disabled - server-side handles this
// //   }

// //   Widget _buildSectionTitle(String title) {
// //     return Padding(
// //       padding: const EdgeInsets.only(bottom: 16),
// //       child: Row(
// //         children: [
// //           Container(
// //             width: 4,
// //             height: 24,
// //             decoration: BoxDecoration(
// //               color: const Color(0xFFF5A623),
// //               borderRadius: BorderRadius.circular(2),
// //             ),
// //           ),
// //           const SizedBox(width: 12),
// //           Text(
// //             title,
// //             style: GoogleFonts.poppins(
// //               fontSize: 20,
// //               fontWeight: FontWeight.w600,
// //               color: const Color(0xFFF5A623),
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   Widget _buildInputField({
// //     required TextEditingController controller,
// //     required String label,
// //     int maxLines = 1,
// //     TextInputType? keyboardType,
// //   }) {
// //     return Container(
// //       margin: const EdgeInsets.only(bottom: 16),
// //       child: TextFormField(
// //         controller: controller,
// //         keyboardType: keyboardType,
// //         maxLines: maxLines,
// //         style: GoogleFonts.poppins(),
// //         decoration: InputDecoration(
// //           labelText: label,
// //           labelStyle: GoogleFonts.poppins(color: Colors.grey[600]),
// //           border: OutlineInputBorder(
// //             borderRadius: BorderRadius.circular(12),
// //             borderSide: BorderSide(color: Colors.grey[300]!),
// //           ),
// //           enabledBorder: OutlineInputBorder(
// //             borderRadius: BorderRadius.circular(12),
// //             borderSide: BorderSide(color: Colors.grey[300]!),
// //           ),
// //           focusedBorder: OutlineInputBorder(
// //             borderRadius: BorderRadius.circular(12),
// //             borderSide: const BorderSide(color: Color(0xFFF5A623)),
// //           ),
// //           filled: true,
// //           fillColor: Colors.grey[50],
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _buildDropdownField({
// //     required String label,
// //     required String? value,
// //     required List<String> items,
// //     required Function(String?) onChanged,
// //   }) {
// //     return Container(
// //       margin: const EdgeInsets.only(bottom: 16),
// //       child: DropdownButtonFormField<String>(
// //         value: value,
// //         decoration: InputDecoration(
// //           labelText: label,
// //           labelStyle: GoogleFonts.poppins(color: Colors.grey[600]),
// //           border: OutlineInputBorder(
// //             borderRadius: BorderRadius.circular(12),
// //             borderSide: BorderSide(color: Colors.grey[300]!),
// //           ),
// //           enabledBorder: OutlineInputBorder(
// //             borderRadius: BorderRadius.circular(12),
// //             borderSide: BorderSide(color: Colors.grey[300]!),
// //           ),
// //           focusedBorder: OutlineInputBorder(
// //             borderRadius: BorderRadius.circular(12),
// //             borderSide: const BorderSide(color: Color(0xFFF5A623)),
// //           ),
// //           filled: true,
// //           fillColor: Colors.grey[50],
// //         ),
// //         items: items.map((String item) {
// //           return DropdownMenuItem<String>(
// //             value: item,
// //             child: Text(item, style: GoogleFonts.poppins()),
// //           );
// //         }).toList(),
// //         onChanged: onChanged,
// //       ),
// //     );
// //   }

// //   Widget _buildServiceCheckbox({
// //     required String title,
// //     required String price,
// //     required bool value,
// //     required Function(bool?) onChanged,
// //   }) {
// //     String durationText = '';
// //     String dynamicPrice = price;
// //     if (_selectedPetSize != null) {
// //       final durations = _serviceDurations[_selectedPetSize]!;
// //       final prices = _servicePrices[_selectedPetSize]!;
// //       switch (title) {
// //         case 'Bath':
// //           durationText = ' (${_formatDuration(durations['bath']!)})';
// //           dynamicPrice = 'P${prices['bath']}';
// //           break;
// //         case 'Haircut':
// //           durationText = ' (${_formatDuration(durations['haircut']!)})';
// //           dynamicPrice = 'P${prices['haircut']}';
// //           break;
// //         case 'Ear Cleaning':
// //           durationText = ' (${_formatDuration(durations['earCleaning']!)})';
// //           dynamicPrice = 'P${prices['earCleaning']}';
// //           break;
// //         case 'Nail Trim':
// //           durationText = ' (${_formatDuration(durations['nailTrim']!)})';
// //           dynamicPrice = 'P${prices['nailTrim']}';
// //           break;
// //       }
// //     }

// //     return Container(
// //       margin: const EdgeInsets.only(bottom: 8),
// //       decoration: BoxDecoration(
// //         color: Colors.grey[50],
// //         borderRadius: BorderRadius.circular(12),
// //         border: Border.all(color: Colors.grey[300]!),
// //       ),
// //       child: CheckboxListTile(
// //         title: Row(
// //           children: [
// //             Expanded(
// //               child: Column(
// //                 crossAxisAlignment: CrossAxisAlignment.start,
// //                 children: [
// //                   Text(title, style: GoogleFonts.poppins()),
// //                   if (_selectedPetSize != null)
// //                     Text(
// //                       durationText,
// //                       style: GoogleFonts.poppins(
// //                         fontSize: 12,
// //                         color: Colors.blue[600],
// //                       ),
// //                     ),
// //                 ],
// //               ),
// //             ),
// //             Container(
// //               padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
// //               decoration: BoxDecoration(
// //                 color: const Color(0xFFF5A623).withOpacity(0.1),
// //                 borderRadius: BorderRadius.circular(4),
// //               ),
// //               child: Text(
// //                 dynamicPrice,
// //                 style: GoogleFonts.poppins(
// //                   color: const Color(0xFFF5A623),
// //                   fontWeight: FontWeight.w500,
// //                 ),
// //               ),
// //             ),
// //           ],
// //         ),
// //         value: value,
// //         onChanged: onChanged,
// //         controlAffinity: ListTileControlAffinity.leading,
// //         contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
// //         shape: RoundedRectangleBorder(
// //           borderRadius: BorderRadius.circular(12),
// //         ),
// //       ),
// //     );
// //   }

// //   List<Widget> _buildServiceConfirmationRows() {
// //     final prices = _servicePrices[_selectedPetSize]!;
// //     final List<Widget> rows = [];
// //     if (_serviceBath) rows.add(_buildConfirmationRow('Bath', 'P${prices['bath']}'));
// //     if (_serviceHaircut) {
// //       rows.add(_buildConfirmationRow('Haircut', 'P${prices['haircut']}'));
// //       if (_haircutExtraOption == 'super_furry') {
// //         rows.add(_buildConfirmationRow('For Super Furry Hair Coat', 'P200'));
// //       }
// //       if (_haircutExtraOption == 'severely_matted') {
// //         rows.add(_buildConfirmationRow('For Severely Matted Fur', 'P300'));
// //       }
// //     }
// //     if (_serviceNailTrim) rows.add(_buildConfirmationRow('Nail Trim', 'P${prices['nailTrim']}'));
// //     if (_serviceEarCleaning) rows.add(_buildConfirmationRow('Ear Cleaning', 'P${prices['earCleaning']}'));
// //     return rows;
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return GestureDetector(
// //       onTap: () {
// //         // Dismiss keyboard when tapping outside input fields
// //         FocusScope.of(context).unfocus();
// //       },
// //       child: Scaffold(
// //         backgroundColor: Colors.grey[100],
// //         appBar: AppBar(
// //           title: Text(
// //             'Book Appointment',
// //             style: GoogleFonts.poppins(
// //               color: const Color(0xFFF5A623),
// //               fontWeight: FontWeight.w600,
// //             ),
// //           ),
// //           backgroundColor: Colors.white,
// //           elevation: 0,
// //           centerTitle: true,
// //         ),
// //         body: SingleChildScrollView(
// //           child: Padding(
// //             padding: const EdgeInsets.all(16.0),
// //             child: Column(
// //               crossAxisAlignment: CrossAxisAlignment.start,
// //               children: [
// //                 Card(
// //                   elevation: 0,
// //                   shape: RoundedRectangleBorder(
// //                     borderRadius: BorderRadius.circular(16),
// //                   ),
// //                   child: Padding(
// //                     padding: const EdgeInsets.all(16.0),
// //                     child: Column(
// //                       crossAxisAlignment: CrossAxisAlignment.start,
// //                       children: [
// //                         _buildSectionTitle('Pet Information'),
// //                         _buildInputField(
// //                           controller: _petNameController,
// //                           label: 'Pet Name',
// //                         ),
// //                         _buildDropdownField(
// //                           label: 'Pet Type',
// //                           value: _selectedPetType,
// //                           items: ['Dog', 'Cat', 'Others'],
// //                           onChanged: (String? newValue) {
// //                             setState(() {
// //                               _selectedPetType = newValue;
// //                             });
// //                           },
// //                         ),
// //                         if (_selectedPetType == 'Others')
// //                           _buildInputField(
// //                             controller: _petTypeOtherController,
// //                             label: 'Specify Pet Type',
// //                           ),
// //                         _buildInputField(
// //                           controller: _breedController,
// //                           label: 'Breed',
// //                         ),
// //                         _buildDropdownField(
// //                           label: 'Pet Size',
// //                           value: _selectedPetSize,
// //                           items: ['Small', 'Medium', 'Large'],
// //                           onChanged: (String? newValue) {
// //                             setState(() {
// //                               _selectedPetSize = newValue;
// //                             });
// //                           },
// //                         ),
// //                         _buildInputField(
// //                           controller: _ageController,
// //                           label: 'Age',
// //                           keyboardType: TextInputType.number,
// //                         ),
// //                         _buildDropdownField(
// //                           label: 'Gender',
// //                           value: _selectedGender,
// //                           items: ['Male', 'Female'],
// //                           onChanged: (String? newValue) {
// //                             setState(() {
// //                               _selectedGender = newValue;
// //                             });
// //                           },
// //                         ),
// //                         _buildInputField(
// //                           controller: _allergiesController,
// //                           label: 'Allergies / Medical Conditions (Optional)',
// //                           maxLines: 3,
// //                         ),
// //                       ],
// //                     ),
// //                   ),
// //                 ),
// //                 const SizedBox(height: 16),
// //                 Card(
// //                   elevation: 0,
// //                   shape: RoundedRectangleBorder(
// //                     borderRadius: BorderRadius.circular(16),
// //                   ),
// //                   child: Padding(
// //                     padding: const EdgeInsets.all(16.0),
// //                     child: Column(
// //                       crossAxisAlignment: CrossAxisAlignment.start,
// //                       children: [
// //                         _buildSectionTitle('Grooming Services'),
// //                         _buildServiceCheckbox(
// //                           title: 'Bath',
// //                           price: 'P300',
// //                           value: _serviceBath,
// //                           onChanged: (bool? newValue) {
// //                             setState(() {
// //                               _serviceBath = newValue ?? false;
// //                               _calculateEstimatedCost();
// //                             });
// //                           },
// //                         ),
// //                         _buildServiceCheckbox(
// //                           title: 'Haircut',
// //                           price: 'P400',
// //                           value: _serviceHaircut,
// //                           onChanged: (bool? newValue) {
// //                             setState(() {
// //                               _serviceHaircut = newValue ?? false;
// //                               _calculateEstimatedCost();
// //                               if (!_serviceHaircut) {
// //                                 _haircutExtraOption = null;
// //                               }
// //                             });
// //                           },
// //                         ),
// //                         if (_serviceHaircut)
// //                           Container(
// //                             margin: const EdgeInsets.only(bottom: 8, left: 8, right: 8),
// //                             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
// //                             decoration: BoxDecoration(
// //                               color: Colors.orange[50],
// //                               borderRadius: BorderRadius.circular(8),
// //                               border: Border.all(color: Colors.orange[200]!),
// //                             ),
// //                             child: Column(
// //                               crossAxisAlignment: CrossAxisAlignment.start,
// //                               children: [
// //                                 Text(
// //                                   'Extra Haircut Options',
// //                                   style: GoogleFonts.poppins(
// //                                     fontSize: 13,
// //                                     fontWeight: FontWeight.w600,
// //                                     color: Colors.orange[800],
// //                                   ),
// //                                 ),
// //                                 const SizedBox(height: 4),
// //                                 DropdownButtonFormField<String>(
// //                                   value: _haircutExtraOption,
// //                                   isExpanded: true,
// //                                   decoration: InputDecoration(
// //                                     contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
// //                                     border: OutlineInputBorder(
// //                                       borderRadius: BorderRadius.circular(8),
// //                                       borderSide: BorderSide(color: Colors.orange[200]!),
// //                                     ),
// //                                     filled: true,
// //                                     fillColor: Colors.white,
// //                                   ),
// //                                   style: GoogleFonts.poppins(fontSize: 12, color: Colors.orange[900]),
// //                                   items: const [
// //                                     DropdownMenuItem(
// //                                       value: null,
// //                                       child: Text('None', style: TextStyle(fontSize: 11)),
// //                                     ),
// //                                     DropdownMenuItem(
// //                                       value: 'super_furry',
// //                                       child: Text('For Super Furry Hair Coat (+₱200, +20 mins)', style: TextStyle(fontSize: 11)),
// //                                     ),
// //                                     DropdownMenuItem(
// //                                       value: 'severely_matted',
// //                                       child: Text('For Severely Matted Fur (+₱300, +30 mins)', style: TextStyle(fontSize: 11)),
// //                                     ),
// //                                   ],
// //                                   onChanged: (String? value) {
// //                                     setState(() {
// //                                       _haircutExtraOption = value;
// //                                       _calculateEstimatedCost();
// //                                     });
// //                                   },
// //                                   hint: Text('Select extra option (if applicable)', style: GoogleFonts.poppins(fontSize: 12)),
// //                                 ),
// //                                 const SizedBox(height: 4),
// //                                 Text(
// //                                   'Note: If your dog has a super furry coat or severely matted fur, please select the appropriate option. Additional charges and grooming time will apply',
// //                                   style: GoogleFonts.poppins(fontSize: 10, color: Colors.orange[800]),
// //                                 ),
// //                               ],
// //                             ),
// //                           ),
// //                         _buildServiceCheckbox(
// //                           title: 'Nail Trim',
// //                           price: 'P100',
// //                           value: _serviceNailTrim,
// //                           onChanged: (bool? newValue) {
// //                             setState(() {
// //                               _serviceNailTrim = newValue ?? false;
// //                               _calculateEstimatedCost();
// //                             });
// //                           },
// //                         ),
// //                         _buildServiceCheckbox(
// //                           title: 'Ear Cleaning',
// //                           price: 'P100',
// //                           value: _serviceEarCleaning,
// //                           onChanged: (bool? newValue) {
// //                             setState(() {
// //                               _serviceEarCleaning = newValue ?? false;
// //                               _calculateEstimatedCost();
// //                             });
// //                           },
// //                         ),
// //                         if (_selectedPetSize != null) ...[
// //                           const SizedBox(height: 16),
// //                           Container(
// //                             width: double.infinity,
// //                             padding: const EdgeInsets.all(16),
// //                             decoration: BoxDecoration(
// //                               color: const Color(0xFFF5A623).withOpacity(0.1),
// //                               borderRadius: BorderRadius.circular(12),
// //                             ),
// //                             child: Column(
// //                               crossAxisAlignment: CrossAxisAlignment.start,
// //                               children: [
// //                                 Text(
// //                                   'Estimated Duration:',
// //                                   style: GoogleFonts.poppins(
// //                                     fontSize: 16,
// //                                     fontWeight: FontWeight.w500,
// //                                   ),
// //                                 ),
// //                                 const SizedBox(height: 12),
// //                                 Text(
// //                                   _formatDuration(_calculateTotalDuration()),
// //                                   style: GoogleFonts.poppins(
// //                                     fontSize: 18,
// //                                     fontWeight: FontWeight.w600,
// //                                     color: const Color(0xFFF5A623),
// //                                   ),
// //                                 ),
// //                               ],
// //                             ),
// //                           ),
// //                         ],
// //                         const SizedBox(height: 16),
// //                         _buildInputField(
// //                           controller: _specialRequestsController,
// //                           label: 'Special Requests/ Notes (Optional)',
// //                           maxLines: 3,
// //                         ),
// //                       ],
// //                     ),
// //                   ),
// //                 ),
// //                 const SizedBox(height: 16),
// //                 Card(
// //                   elevation: 0,
// //                   shape: RoundedRectangleBorder(
// //                     borderRadius: BorderRadius.circular(16),
// //                   ),
// //                   child: Padding(
// //                     padding: const EdgeInsets.all(16.0),
// //                     child: Column(
// //                       crossAxisAlignment: CrossAxisAlignment.start,
// //                       children: [
// //                         _buildSectionTitle('Appointment Details'),
// //                         Container(
// //                           margin: const EdgeInsets.only(bottom: 16),
// //                           decoration: BoxDecoration(
// //                             color: Colors.grey[50],
// //                             borderRadius: BorderRadius.circular(12),
// //                             border: Border.all(color: Colors.grey[300]!),
// //                           ),
// //                           child: ListTile(
// //                             title: Text(
// //                               _preferredDate == null
// //                                   ? 'Select Preferred Date'
// //                                   : 'Date: ${_preferredDate!.toLocal().toString().split(' ')[0]}',
// //                               style: GoogleFonts.poppins(),
// //                             ),
// //                             trailing: const Icon(Icons.calendar_today,
// //                                 color: Color(0xFFF5A623)),
// //                             onTap: () async {
// //                               final DateTime? picked = await showDatePicker(
// //                                 context: context,
// //                                 initialDate: _preferredDate ?? DateTime.now(),
// //                                 firstDate: DateTime.now(),
// //                                 lastDate: DateTime(2101),
// //                               );
// //                               if (picked != null && picked != _preferredDate) {
// //                                 setState(() {
// //                                   _preferredDate = picked;
// //                                   _preferredTime =
// //                                       null; // Reset time when date changes
// //                                 });
// //                                 // Show available time slots for the selected date
// //                                 _showAvailableTimeSlots(context, picked);
// //                               }
// //                             },
// //                           ),
// //                         ),
// //                         Container(
// //                           margin: const EdgeInsets.only(bottom: 16),
// //                           decoration: BoxDecoration(
// //                             color: Colors.grey[50],
// //                             borderRadius: BorderRadius.circular(12),
// //                             border: Border.all(color: Colors.grey[300]!),
// //                           ),
// //                           child: ListTile(
// //                             title: Text(
// //                               _preferredTime == null
// //                                   ? 'Select Preferred Time'
// //                                   : 'Time: ${_preferredTime!.format(context)}',
// //                               style: GoogleFonts.poppins(),
// //                             ),
// //                             trailing: const Icon(Icons.access_time,
// //                                 color: Color(0xFFF5A623)),
// //                             onTap: () async {
// //                               if (_preferredDate == null) {
// //                                 ScaffoldMessenger.of(context).showSnackBar(
// //                                   const SnackBar(
// //                                     content: Text('Please select a date first'),
// //                                     backgroundColor: Colors.red,
// //                                   ),
// //                                 );
// //                                 return;
// //                               }
// //                               _showAvailableTimeSlots(context, _preferredDate!);
// //                             },
// //                           ),
// //                         ),
// //                       ],
// //                     ),
// //                   ),
// //                 ),
// //                 const SizedBox(height: 16),
// //                 Card(
// //                   elevation: 0,
// //                   shape: RoundedRectangleBorder(
// //                     borderRadius: BorderRadius.circular(16),
// //                   ),
// //                   child: Padding(
// //                     padding: const EdgeInsets.all(16.0),
// //                     child: Column(
// //                       crossAxisAlignment: CrossAxisAlignment.start,
// //                       children: [
// //                         _buildSectionTitle('Payment Information'),
// //                         Container(
// //                           padding: const EdgeInsets.all(16),
// //                           decoration: BoxDecoration(
// //                             color: const Color(0xFFF5A623).withOpacity(0.1),
// //                             borderRadius: BorderRadius.circular(12),
// //                           ),
// //                           child: Row(
// //                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                             children: [
// //                               Text(
// //                                 'Estimated Cost:',
// //                                 style: GoogleFonts.poppins(
// //                                   fontSize: 16,
// //                                   fontWeight: FontWeight.w500,
// //                                 ),
// //                               ),
// //                               Text(
// //                                 'P${_estimatedCost.toStringAsFixed(2)}',
// //                                 style: GoogleFonts.poppins(
// //                                   fontSize: 18,
// //                                   fontWeight: FontWeight.w600,
// //                                   color: const Color(0xFFF5A623),
// //                                 ),
// //                               ),
// //                             ],
// //                           ),
// //                         ),
// //                         const SizedBox(height: 16),
// //                         _buildDropdownField(
// //                           label: 'Payment Method',
// //                           value: _selectedPaymentMethod,
// //                           items: ['Cash', 'Gcash'],
// //                           onChanged: (String? newValue) {
// //                             setState(() {
// //                               _selectedPaymentMethod = newValue;
// //                             });
// //                           },
// //                         ),
// //                         if (_selectedPaymentMethod == 'Gcash') ...[
// //                           const SizedBox(height: 16),
// //                           Container(
// //                             padding: const EdgeInsets.all(16),
// //                             decoration: BoxDecoration(
// //                               color: Colors.blue[50],
// //                               borderRadius: BorderRadius.circular(12),
// //                               border: Border.all(color: Colors.blue[200]!),
// //                             ),
// //                             child: Column(
// //                               children: [
// //                                 Text(
// //                                   '0915 548 5814',
// //                                   style: GoogleFonts.poppins(
// //                                     color: Colors.blue[700],
// //                                     fontSize: 14,
// //                                     fontWeight: FontWeight.w500,
// //                                   ),
// //                                   textAlign: TextAlign.center,
// //                                 ),
// //                                 const SizedBox(height: 16),
// //                                 Image.asset(
// //                                   'assets/images/gcash_qr.png',
// //                                   height: 200,
// //                                   width: 200,
// //                                 ),
// //                                 const SizedBox(height: 12),
// //                                 Row(
// //                                   children: [
// //                                     const Icon(Icons.info_outline,
// //                                         color: Colors.blue),
// //                                     const SizedBox(width: 12),
// //                                     Expanded(
// //                                       child: Text(
// //                                         'The payment receipt must be presented to the groomer before the appointment.',
// //                                         style: GoogleFonts.poppins(
// //                                           color: Colors.blue[700],
// //                                           fontSize: 12,
// //                                         ),
// //                                       ),
// //                                     ),
// //                                   ],
// //                                 ),
// //                               ],
// //                             ),
// //                           ),
// //                         ],
// //                         const SizedBox(height: 16),
// //                         Container(
// //                           decoration: BoxDecoration(
// //                             color: Colors.grey[50],
// //                             borderRadius: BorderRadius.circular(12),
// //                             border: Border.all(color: Colors.grey[300]!),
// //                           ),
// //                           child: CheckboxListTile(
// //                             title: Text(
// //                               'I consent to the use of before and after photos of my pet for social media purposes',
// //                               style: GoogleFonts.poppins(fontSize: 14),
// //                             ),
// //                             value: _consentPhotos,
// //                             onChanged: (bool? newValue) {
// //                               setState(() {
// //                                 _consentPhotos = newValue ?? false;
// //                               });
// //                             },
// //                             controlAffinity: ListTileControlAffinity.leading,
// //                             contentPadding:
// //                                 const EdgeInsets.symmetric(horizontal: 16),
// //                           ),
// //                         ),
// //                       ],
// //                     ),
// //                   ),
// //                 ),
// //                 const SizedBox(height: 32),
// //                 SizedBox(
// //                   width: double.infinity,
// //                   child: ElevatedButton(
// //                     onPressed: _isLoading
// //                         ? null
// //                         : () async {
// //                             // Basic validation
// //                             if (_petNameController.text.isEmpty ||
// //                                 _selectedPetType == null ||
// //                                 (_selectedPetType == 'Others' &&
// //                                     _petTypeOtherController.text.isEmpty) ||
// //                                 _selectedPetSize == null ||
// //                                 _selectedGender == null ||
// //                                 _preferredDate == null ||
// //                                 _preferredTime == null ||
// //                                 _selectedPaymentMethod == null ||
// //                                 _estimatedCost <= 0) {
// //                               ScaffoldMessenger.of(context).showSnackBar(
// //                                 const SnackBar(
// //                                   content: Text(
// //                                       'Please fill in all required fields and select at least one service.'),
// //                                   backgroundColor: Colors.red,
// //                                 ),
// //                               );
// //                               return;
// //                             }

// //                             // Calculate end time
// //                             final currentDuration = _calculateTotalDuration();
// //                             final endTime = TimeOfDay(
// //                               hour: (_preferredTime!.hour * 60 +
// //                                       _preferredTime!.minute +
// //                                       currentDuration) ~/
// //                                   60,
// //                               minute: (_preferredTime!.hour * 60 +
// //                                       _preferredTime!.minute +
// //                                       currentDuration) %
// //                                   60,
// //                             );

// //                             // Show confirmation dialog
// //                             final confirmed = await showDialog<bool>(
// //                               context: context,
// //                               builder: (BuildContext context) {
// //                                 return AlertDialog(
// //                                   title: Text(
// //                                     widget.appointment != null
// //                                         ? 'Confirm Update'
// //                                         : 'Confirm Appointment',
// //                                     style: GoogleFonts.poppins(
// //                                       fontWeight: FontWeight.w600,
// //                                       color: const Color(0xFFF5A623),
// //                                     ),
// //                                   ),
// //                                   content: SingleChildScrollView(
// //                                     child: Column(
// //                                       crossAxisAlignment:
// //                                           CrossAxisAlignment.start,
// //                                       mainAxisSize: MainAxisSize.min,
// //                                       children: [
// //                                         Text(
// //                                           'Please review your appointment details: ',
// //                                           style: GoogleFonts.poppins(
// //                                             fontWeight: FontWeight.w500,
// //                                           ),
// //                                         ),
// //                                         const SizedBox(height: 16),
// //                                         _buildConfirmationRow(
// //                                             'Pet Name', _petNameController.text),
// //                                         _buildConfirmationRow(
// //                                             'Pet Type', _selectedPetType!),
// //                                         if (_selectedPetType == 'Others')
// //                                           _buildConfirmationRow('Other Pet Type',
// //                                               _petTypeOtherController.text),
// //                                         _buildConfirmationRow(
// //                                             'Breed', _breedController.text),
// //                                         _buildConfirmationRow(
// //                                             'Size', _selectedPetSize!),
// //                                         _buildConfirmationRow(
// //                                             'Age', _ageController.text),
// //                                         _buildConfirmationRow(
// //                                             'Gender', _selectedGender!),
// //                                         if (_allergiesController.text.isNotEmpty)
// //                                           _buildConfirmationRow(
// //                                               'Allergies/Medical Conditions',
// //                                               _allergiesController.text),
// //                                         const Divider(),
// //                                         Text(
// //                                           'Selected Services:',
// //                                           style: GoogleFonts.poppins(
// //                                             fontWeight: FontWeight.w500,
// //                                           ),
// //                                         ),
// //                                         if (_selectedPetSize != null) ..._buildServiceConfirmationRows(),
// //                                         const Divider(),
// //                                         _buildConfirmationRow(
// //                                             'Date',
// //                                             _preferredDate!
// //                                                 .toLocal()
// //                                                 .toString()
// //                                                 .split(' ')[0]),
// //                                         _buildConfirmationRow('Time',
// //                                             '${_preferredTime!.format(context)} - ${endTime.format(context)}'),
// //                                         _buildConfirmationRow('Duration',
// //                                             _formatDuration(currentDuration)),
// //                                         _buildConfirmationRow('Total Cost',
// //                                             'P${_estimatedCost.toStringAsFixed(2)}'),
// //                                         _buildConfirmationRow('Payment Method',
// //                                             _selectedPaymentMethod!),
// //                                         const SizedBox(height: 16),
// //                                         Container(
// //                                           padding: const EdgeInsets.all(12),
// //                                           decoration: BoxDecoration(
// //                                             color: Colors.orange[50],
// //                                             borderRadius:
// //                                                 BorderRadius.circular(8),
// //                                             border: Border.all(
// //                                                 color: Colors.orange[200]!),
// //                                           ),
// //                                           child: Row(
// //                                             children: [
// //                                               Icon(Icons.info_outline,
// //                                                   color: Colors.orange[700],
// //                                                   size: 20),
// //                                               const SizedBox(width: 8),
// //                                               Expanded(
// //                                                 child: Text(
// //                                                   'Note: Timely arrival is requested to maintain scheduling efficiency and avoid overlaps with other bookings. We appreciate your understanding and cooperation.',
// //                                                   style: GoogleFonts.poppins(
// //                                                     fontSize: 12,
// //                                                     color: Colors.orange[900],
// //                                                   ),
// //                                                 ),
// //                                               ),
// //                                             ],
// //                                           ),
// //                                         ),
// //                                       ],
// //                                     ),
// //                                   ),
// //                                   actions: [
// //                                     TextButton(
// //                                       onPressed: () =>
// //                                           Navigator.pop(context, false),
// //                                       child: Text(
// //                                         'Cancel',
// //                                         style: GoogleFonts.poppins(
// //                                           color: Colors.grey[600],
// //                                         ),
// //                                       ),
// //                                     ),
// //                                     ElevatedButton(
// //                                       onPressed: () =>
// //                                           Navigator.pop(context, true),
// //                                       style: ElevatedButton.styleFrom(
// //                                         backgroundColor: const Color(0xFFF5A623),
// //                                         foregroundColor: Colors.white,
// //                                       ),
// //                                       child: Text(
// //                                         'Confirm Booking',
// //                                         style: GoogleFonts.poppins(
// //                                           fontWeight: FontWeight.w500,
// //                                         ),
// //                                       ),
// //                                     ),
// //                                   ],
// //                                 );
// //                               },
// //                             );

// //                             if (confirmed != true) return;

// //                             setState(() {
// //                               _isLoading = true;
// //                             });

// //                             try {
// //                               // Get current user ID
// //                               final userId = _supabase.auth.currentUser?.id;
// //                               if (userId == null) {
// //                                 throw Exception('User not logged in');
// //                               }

// //                               // Prepare data for Supabase
// //                               final data = {
// //                                 'user_id': userId,
// //                                 'pet_name': _petNameController.text,
// //                                 'pet_type': _selectedPetType,
// //                                 'pet_type_other': _selectedPetType == 'Others'
// //                                     ? _petTypeOtherController.text
// //                                     : null,
// //                                 'breed': _breedController.text,
// //                                 'pet_size': _selectedPetSize,
// //                                 'age': int.tryParse(_ageController.text),
// //                                 'gender': _selectedGender,
// //                                 'allergies_medical_conditions':
// //                                     _allergiesController.text,
// //                                 'service_bath': _serviceBath,
// //                                 'service_haircut': _serviceHaircut,
// //                                 'service_nail_trim': _serviceNailTrim,
// //                                 'service_ear_cleaning': _serviceEarCleaning,
// //                                 'special_requests_notes':
// //                                     _specialRequestsController.text,
// //                                 'preferred_date': _preferredDate!
// //                                     .toIso8601String()
// //                                     .split('T')[0],
// //                                 'preferred_time':
// //                                     '${_preferredTime!.hour.toString().padLeft(2, '0')}:${_preferredTime!.minute.toString().padLeft(2, '0')}',
// //                                 'estimated_cost': _estimatedCost,
// //                                 'payment_method': _selectedPaymentMethod,
// //                                 'consent_photos': _consentPhotos,
// //                                 'estimated_duration': _calculateTotalDuration(),
// //                                 'status':
// //                                     'Pending', // Add default status for new appointments
// //                               };

// //                               if (widget.appointment != null) {
// //                                 // Update existing appointment
// //                                 await _supabase
// //                                     .from('grooming_appointments')
// //                                     .update(data)
// //                                     .eq('id', widget.appointment!['id']);
// //                               } else {
// //                                 // Insert new appointment
// //                                 final inserted = await _supabase
// //                                     .from('grooming_appointments')
// //                                     .insert(data)
// //                                     .select()
// //                                     .single();

// //                                 // Fetch user details
// //                                 final userProfile = await _supabase
// //                                     .from('users')
// //                                     .select('full_name, contact_number')
// //                                     .eq('id', userId)
// //                                     .single();

// //                                 // Compose message
// //                                 final services = <String>[];
// //                                 if (_serviceBath) services.add('Bath');
// //                                 if (_serviceHaircut) services.add('Haircut');
// //                                 if (_serviceNailTrim) services.add('Nail Trim');
// //                                 if (_serviceEarCleaning) services.add('Ear Cleaning');

// //                                 final petType = _selectedPetType == 'Others' ? _petTypeOtherController.text : _selectedPetType;
// //                                 final dateFormatted = '${_preferredDate!.month.toString().padLeft(2, '0')}-${_preferredDate!.day.toString().padLeft(2, '0')}-${_preferredDate!.year}';

// //                                 final message =
// //                                     'New grooming appointment booked by ${userProfile['full_name']} (${userProfile['contact_number']}):\n'
// //                                     'Pet: ${_petNameController.text}\n'
// //                                     'Type: $petType\n'
// //                                     'Breed: ${_breedController.text}\n'
// //                                     'Size: $_selectedPetSize\n'
// //                                     'Age: ${_ageController.text}\n'
// //                                     'Gender: $_selectedGender\n\n'
// //                                     'Services: ${services.join(', ')}\n'
// //                                     'Date: $dateFormatted\n'
// //                                     'Time: ${_preferredTime!.format(context)}\n'
// //                                     'Payment Method: $_selectedPaymentMethod\n'
// //                                     'Cost: ₱${_estimatedCost.toStringAsFixed(2)}';

// //                                 // Insert message for admin
// //                                 await _supabase
// //                                     .from('admin_messages')
// //                                     .insert({
// //                                   'user_id': userId,
// //                                   'appointment_id': inserted['id'],
// //                                   'message': message,
// //                                 });
// //                                 // For every insert into admin_messages, also insert into user_messages
// //                                 await _supabase.from('user_messages').insert({
// //                                   'user_id': userId,
// //                                   'appointment_id': inserted['id'],
// //                                   'message': message,
// //                                   'is_from_admin': false,
// //                                   'is_read': false,
// //                                 });
// //                               }

// //                               if (mounted) {
// //                                 // Show success message
// //                                 ScaffoldMessenger.of(context).showSnackBar(
// //                                   SnackBar(
// //                                     content: Text(widget.appointment != null
// //                                         ? 'Appointment updated successfully!'
// //                                         : 'Appointment booked successfully!'),
// //                                     backgroundColor: Colors.green,
// //                                     duration: const Duration(seconds: 3),
// //                                   ),
// //                                 );

// //                                 // Navigate back to home page and clear the navigation stack
// //                                 Navigator.pushNamedAndRemoveUntil(
// //                                   context,
// //                                   '/home',
// //                                   (route) => false
// //                                 );

// //                                 // Trigger refresh for all relevant pages
// //                                 _triggerGlobalRefresh();
// //                               }
// //                             } catch (error) {
// //                               if (mounted) {
// //                                 ScaffoldMessenger.of(context).showSnackBar(
// //                                   SnackBar(
// //                                     content: Text(widget.appointment != null
// //                                         ? 'Error updating appointment: ${error.toString()}'
// //                                         : 'Error booking appointment: ${error.toString()}'),
// //                                     backgroundColor: Colors.red,
// //                                   ),
// //                                 );
// //                               }
// //                             } finally {
// //                               if (mounted) {
// //                                 setState(() {
// //                                   _isLoading = false;
// //                                 });
// //                               }
// //                             }
// //                           },
// //                     style: ElevatedButton.styleFrom(
// //                       backgroundColor: const Color(0xFFF5A623),
// //                       foregroundColor: Colors.white,
// //                       shape: RoundedRectangleBorder(
// //                         borderRadius: BorderRadius.circular(12),
// //                       ),
// //                       padding: const EdgeInsets.symmetric(vertical: 16),
// //                       elevation: 0,
// //                     ),
// //                     child: _isLoading
// //                         ? const SizedBox(
// //                             width: 24,
// //                             height: 24,
// //                             child: CircularProgressIndicator(
// //                               color: Colors.white,
// //                               strokeWidth: 2,
// //                             ),
// //                           )
// //                         : Text(
// //                             widget.appointment != null
// //                                 ? 'Update Appointment'
// //                                 : 'Book Appointment',
// //                             style: GoogleFonts.poppins(
// //                               fontSize: 16,
// //                               fontWeight: FontWeight.w600,
// //                             ),
// //                           ),
// //                   ),
// //                 ),
// //                 const SizedBox(height: 16),
// //               ],
// //             ),
// //           ),
// //         ),
// //       ),
// //     );
// //   }

// //   String _formatTime(String time) {
// //     try {
// //       final timeOfDay = TimeOfDay(
// //         hour: int.parse(time.split(':')[0]),
// //         minute: int.parse(time.split(':')[1]),
// //       );
// //       return timeOfDay.format(context);
// //     } catch (e) {
// //       return time;
// //     }
// //   }

// //   // Global refresh trigger function
// //   void _triggerGlobalRefresh() {
// //     // This will trigger a refresh of all relevant pages
// //     // The home page will automatically refresh when navigated to
// //     // Other pages will refresh when the user navigates to them
// //     print('Global refresh triggered - new appointment booked');
// //   }

// //   Widget _buildConfirmationRow(String label, String value) {
// //     return Padding(
// //       padding: const EdgeInsets.only(bottom: 8),
// //       child: Row(
// //         crossAxisAlignment: CrossAxisAlignment.start,
// //         children: [
// //           SizedBox(
// //             width: 160,
// //             child: Text(
// //               '$label:',
// //               style: GoogleFonts.poppins(
// //                 fontWeight: FontWeight.w500,
// //                 color: Colors.grey[700],
// //               ),
// //             ),
// //           ),
// //           Expanded(
// //             child: Text(
// //               value,
// //               style: GoogleFonts.poppins(),
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }

// // ---

// // import 'package:flutter/material.dart';
// // import 'package:google_fonts/google_fonts.dart';
// // import 'package:supabase_flutter/supabase_flutter.dart';
// // import 'package:intl/intl.dart';
// // import '../config/supabase_config.dart';
// // import '../utils/message_tracking_utils.dart';

// // class ServiceDuration {
// //   final int bath;
// //   final int haircut;
// //   final int earCleaning;
// //   final int nailTrim;
// //   const ServiceDuration({
// //     required this.bath,
// //     required this.haircut,
// //     required this.earCleaning,
// //     required this.nailTrim,
// //   });

// //   int getTotalDuration(
// //       bool hasBath, bool hasHaircut, bool hasEarCleaning, bool hasNailTrim) {
// //     int total = 0;
// //     if (hasBath) total += bath;
// //     if (hasHaircut) total += haircut;
// //     if (hasEarCleaning) total += earCleaning;
// //     if (hasNailTrim) total += nailTrim;
// //     return total;
// //   }

// //   String formatDuration(int minutes) {
// //     if (minutes < 60) {
// //       return '$minutes minutes';
// //     } else {
// //       int hours = minutes ~/ 60;
// //       int remainingMinutes = minutes % 60;
// //       if (remainingMinutes == 0) {
// //         return '$hours hour${hours > 1 ? 's' : ''}';
// //       }
// //       return '$hours hour${hours > 1 ? 's' : ''} and $remainingMinutes minutes';
// //     }
// //   }
// // }

// // class GroomingAppointmentPage extends StatefulWidget {
// //   final Map<String, dynamic>? appointment;
// //   const GroomingAppointmentPage({super.key, this.appointment});

// //   @override
// //   State<GroomingAppointmentPage> createState() =>
// //       _GroomingAppointmentPageState();
// // }

// // class _GroomingAppointmentPageState extends State<GroomingAppointmentPage> {
// //   final _supabase = Supabase.instance.client;
// //   bool _isLoading = false;

// //   // Service durations based on pet size
// //   final Map<String, Map<String, int>> _serviceDurations = {
// //     'Small': {
// //       'bath': 30,
// //       'haircut': 40,
// //       'earCleaning': 10,
// //       'nailTrim': 10,
// //     },
// //     'Medium': {
// //       'bath': 40,
// //       'haircut': 60,
// //       'earCleaning': 10,
// //       'nailTrim': 10,
// //     },
// //     'Large': {
// //       'bath': 50,
// //       'haircut': 80,
// //       'earCleaning': 10,
// //       'nailTrim': 10,
// //     },
// //   };

// //   // Service prices based on pet size
// //   final Map<String, Map<String, int>> _servicePrices = {
// //     'Small': {
// //       'bath': 300,
// //       'haircut': 400,
// //       'nailTrim': 100,
// //       'earCleaning': 100,
// //     },
// //     'Medium': {
// //       'bath': 400,
// //       'haircut': 500,
// //       'nailTrim': 110,
// //       'earCleaning': 110,
// //     },
// //     'Large': {
// //       'bath': 500,
// //       'haircut': 600,
// //       'nailTrim': 120,
// //       'earCleaning': 120,
// //     },
// //   };

// //   // Pet Information
// //   final _petNameController = TextEditingController();
// //   String? _selectedPetType;
// //   final _petTypeOtherController = TextEditingController();
// //   final _breedController = TextEditingController();
// //   String? _selectedPetSize;
// //   final _ageController = TextEditingController();
// //   String? _selectedGender;
// //   final _allergiesController = TextEditingController();

// //   // Grooming Services Details
// //   bool _serviceBath = false;
// //   bool _serviceHaircut = false;
// //   bool _serviceNailTrim = false;
// //   bool _serviceEarCleaning = false;
// //   final _specialRequestsController = TextEditingController();
// //   String? _haircutExtraOption;

// //   // Appointment Details
// //   DateTime? _preferredDate;
// //   TimeOfDay? _preferredTime;

// //   // Payment Information
// //   double _estimatedCost = 0.0;
// //   String? _selectedPaymentMethod;
// //   bool _consentPhotos = false;

// //   // Format duration
// //   String _formatDuration(int minutes) {
// //     if (minutes < 60) {
// //       return '$minutes minutes';
// //     } else {
// //       int hours = minutes ~/ 60;
// //       int remainingMinutes = minutes % 60;
// //       if (remainingMinutes == 0) {
// //         return '$hours hour${hours > 1 ? 's' : ''}';
// //       }
// //       return '$hours hour${hours > 1 ? 's' : ''} and $remainingMinutes minutes';
// //     }
// //   }

// //   // Calculate total duration
// //   int _calculateTotalDuration() {
// //     if (_selectedPetSize == null) return 0;
// //     final durations = _serviceDurations[_selectedPetSize]!;
// //     int total = 0;
// //     if (_serviceBath) total += durations['bath']!;
// //     if (_serviceHaircut) total += durations['haircut']!;
// //     if (_serviceEarCleaning) total += durations['earCleaning']!;
// //     if (_serviceNailTrim) total += durations['nailTrim']!;
// //     if (_serviceHaircut) {
// //       if (_haircutExtraOption == 'super_furry') {
// //         total += 20;
// //       } else if (_haircutExtraOption == 'severely_matted') {
// //         total += 30;
// //       }
// //     }
// //     return total;
// //   }

// //   // Calculate estimated cost
// //   void _calculateEstimatedCost() {
// //     _estimatedCost = 0.0;
// //     if (_selectedPetSize != null) {
// //       final prices = _servicePrices[_selectedPetSize]!;
// //       if (_serviceBath) _estimatedCost += prices['bath']!;
// //       if (_serviceHaircut) _estimatedCost += prices['haircut']!;
// //       if (_serviceNailTrim) _estimatedCost += prices['nailTrim']!;
// //       if (_serviceEarCleaning) _estimatedCost += prices['earCleaning']!;
// //       if (_serviceHaircut) {
// //         if (_haircutExtraOption == 'super_furry') {
// //           _estimatedCost += 200.0;
// //         } else if (_haircutExtraOption == 'severely_matted') {
// //           _estimatedCost += 300.0;
// //         }
// //       } else {
// //         _haircutExtraOption = null;
// //       }
// //     }
// //     setState(() {});
// //   }

// //   // Get available time slots
// //   Future<List<TimeOfDay>> _getAvailableTimeSlots(DateTime date) async {
// //     try {
// //       final formattedDate = date.toIso8601String().split('T')[0];
// //       final response = await _supabase
// //           .from('grooming_appointments')
// //           .select('preferred_time, estimated_duration, status')
// //           .eq('preferred_date', formattedDate)
// //           .not('status', 'in', ['Cancelled', 'Cancelled (by user)']);
// //       final bookedRanges = response.map((appointment) {
// //         final parts = appointment['preferred_time'].split(':');
// //         final startTime =
// //             TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
// //         final duration = appointment['estimated_duration'] as int;
// //         final totalMinutes = startTime.hour * 60 + startTime.minute + duration + 10;
// //         final endHour = totalMinutes ~/ 60;
// //         final endMinute = totalMinutes % 60;
// //         final endTime = TimeOfDay(hour: endHour, minute: endMinute);
// //         return [startTime, endTime];
// //       }).toList();
// //       final allTimeSlots = <TimeOfDay>[];
// //       for (int hour = 9; hour < 12; hour++) {
// //         for (int minute = 0; minute < 60; minute += 10) {
// //           allTimeSlots.add(TimeOfDay(hour: hour, minute: minute));
// //         }
// //       }
// //       for (int hour = 13; hour < 17; hour++) {
// //         for (int minute = 0; minute < 60; minute += 10) {
// //           allTimeSlots.add(TimeOfDay(hour: hour, minute: minute));
// //         }
// //       }
// //       final currentDuration = _calculateTotalDuration();
// //       return allTimeSlots.where((slot) {
// //         final slotTotalMinutes = slot.hour * 60 + slot.minute + currentDuration + 10;
// //         final slotEndHour = slotTotalMinutes ~/ 60;
// //         final slotEndMinute = slotTotalMinutes % 60;
// //         final slotEndTime = TimeOfDay(hour: slotEndHour, minute: slotEndMinute);
// //         final slotStartMinutes = slot.hour * 60 + slot.minute;
// //         final slotEndMinutes = slotEndHour * 60 + slotEndMinute;
// //         if (slotStartMinutes < 12 * 60 && slotEndMinutes > 12 * 60) {
// //           return false;
// //         }
// //         if (slotStartMinutes < 13 * 60 && slotEndMinutes > 13 * 60 && slotStartMinutes >= 12 * 60) {
// //           return false;
// //         }
// //         if (slotEndMinutes > 17 * 60) {
// //           return false;
// //         }
// //         for (var range in bookedRanges) {
// //           final existingStart = range[0] as TimeOfDay;
// //           final existingEnd = range[1] as TimeOfDay;
// //           final existingStartMinutes =
// //               existingStart.hour * 60 + existingStart.minute;
// //           final existingEndMinutes = existingEnd.hour * 60 + existingEnd.minute;
// //           if (slotStartMinutes < existingEndMinutes &&
// //               slotEndMinutes > existingStartMinutes) {
// //             return false;
// //           }
// //         }
// //         return true;
// //       }).toList();
// //     } catch (e) {
// //       print('Error getting available time slots: $e');
// //       return [];
// //     }
// //   }

// //   // Show available time slots
// //   Future<void> _showAvailableTimeSlots(
// //       BuildContext context, DateTime date) async {
// //     final availableSlots = await _getAvailableTimeSlots(date);
// //     if (availableSlots.isEmpty) {
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         const SnackBar(
// //           content: Text(
// //               'No available time slots for this date. Please select another date.'),
// //           backgroundColor: Colors.red,
// //         ),
// //       );
// //       return;
// //     }
// //     if (!mounted) return;
// //     final currentDuration = _calculateTotalDuration();
// //     final durationText = _formatDuration(currentDuration);
// //     showDialog(
// //       context: context,
// //       builder: (BuildContext context) {
// //         return AlertDialog(
// //           title: Text(
// //             'Available Time Slots',
// //             style: GoogleFonts.poppins(
// //               fontWeight: FontWeight.w600,
// //               color: const Color(0xFFF5A623),
// //             ),
// //           ),
// //           content: SingleChildScrollView(
// //             child: Column(
// //               mainAxisSize: MainAxisSize.min,
// //               crossAxisAlignment: CrossAxisAlignment.start,
// //               children: [
// //                 Text(
// //                   'Service Duration: $durationText',
// //                   style: GoogleFonts.poppins(
// //                     fontSize: 14,
// //                     color: Colors.grey[600],
// //                   ),
// //                 ),
// //                 const SizedBox(height: 16),
// //                 ...availableSlots.map((time) {
// //                   final endTime = TimeOfDay(
// //                     hour:
// //                         (time.hour * 60 + time.minute + currentDuration) ~/ 60,
// //                     minute:
// //                         (time.hour * 60 + time.minute + currentDuration) % 60,
// //                   );
// //                   return ListTile(
// //                     title: Text(
// //                       '${time.format(context)} - ${endTime.format(context)}',
// //                       style: GoogleFonts.poppins(),
// //                     ),
// //                     onTap: () {
// //                       setState(() {
// //                         _preferredTime = time;
// //                       });
// //                       Navigator.pop(context);
// //                     },
// //                   );
// //                 }).toList(),
// //               ],
// //             ),
// //           ),
// //           actions: [
// //             TextButton(
// //               onPressed: () => Navigator.pop(context),
// //               child: Text(
// //                 'Cancel',
// //                 style: GoogleFonts.poppins(
// //                   color: Colors.grey[600],
// //                 ),
// //               ),
// //             ),
// //           ],
// //         );
// //       },
// //     );
// //   }

// //   // Check and send reminders
// //   // Future<void> _checkAndSendReminders() async {
// //   //   try {
// //   //     final supabase = Supabase.instance.client;
// //   //     final now = DateTime.now();
// //   //     final response = await supabase
// //   //         .from('grooming_appointments')
// //   //         .select('id, user_id, pet_name, preferred_date, preferred_time, status')
// //   //         .eq('status', 'Pending');
// //   //     for (final appointment in response) {
// //   //       final appointmentDate = DateTime.parse(appointment['preferred_date']);
// //   //       final appointmentTime = appointment['preferred_time'];
// //   //       final timeParts = appointmentTime.split(':');
// //   //       final appointmentHour = int.parse(timeParts[0]);
// //   //       final appointmentMinute = int.parse(timeParts[1]);
// //   //       final appointmentDateTime = DateTime(
// //   //         appointmentDate.year,
// //   //         appointmentDate.month,
// //   //         appointmentDate.day,
// //   //         appointmentHour,
// //   //         appointmentMinute,
// //   //       );
// //   //       final reminderTime = appointmentDateTime.subtract(const Duration(hours: 24));
// //   //       if (now.isBefore(appointmentDateTime) && now.isAfter(reminderTime)) {
// //   //         final userResponse = await supabase
// //   //             .from('users')
// //   //             .select('full_name')
// //   //             .eq('id', appointment['user_id'])
// //   //             .maybeSingle();
// //   //         final userFullName = userResponse != null ? userResponse['full_name'] ?? 'Unknown' : 'Unknown';
// //   //         final reminderMessage = 'REMINDER: Appointment approaching - Status still PENDING\n\n'
// //   //             'Pet: ${appointment['pet_name']}\n'
// //   //             'Date: ${DateFormat('MMMM dd, yyyy').format(DateTime.parse(appointment['preferred_date']))}\n'
// //   //             'Time: ${_formatTime(appointment['preferred_time'])}\n'
// //   //             'Owner: $userFullName\n\n'
// //   //             'Please update the appointment status.';
// //   //         await MessageTrackingUtils.sendReminderIfNotSent(
// //   //           appointment['id'],
// //   //           appointment['user_id'],
// //   //           reminderMessage,
// //   //         );
// //   //       }
// //   //     }
// //   //   } catch (e) {
// //   //     print('Error checking for reminders: $e');
// //   //   }
// //   // }

// //     // Add this function after the existing functions but before the build method
// //   Future<void> _checkAndSendReminders() async {
// //     try {
// //       final supabase = Supabase.instance.client;
// //       final now = DateTime.now();
// //       final response = await supabase
// //           .from('grooming_appointments')
// //           .select('id, user_id, pet_name, preferred_date, preferred_time, status')
// //           .eq('status', 'Pending');
// //         for (final appointment in response) {
// //           final appointmentDate = DateTime.parse(appointment['preferred_date']);
// //           final appointmentTime = appointment['preferred_time'];
// //           final timeParts = appointmentTime.split(':');
// //           final appointmentHour = int.parse(timeParts[0]);
// //           final appointmentMinute = int.parse(timeParts[1]);
// //           final appointmentDateTime = DateTime(
// //             appointmentDate.year,
// //             appointmentDate.month,
// //             appointmentDate.day,
// //             appointmentHour,
// //             appointmentMinute,
// //           );
// //         // Calculate the reminder time (24 hours before appointment)
// //         final reminderTime = appointmentDateTime.subtract(const Duration(hours: 24));
// //         // Send reminder if we're within the 24-hour period before the appointment time
// //         if (now.isBefore(appointmentDateTime) && now.isAfter(reminderTime)) {
// //             final userResponse = await supabase
// //                 .from('users')
// //                 .select('full_name')
// //                 .eq('id', appointment['user_id'])
// //                 .maybeSingle();
// //             final userFullName = userResponse != null ? userResponse['full_name'] ?? 'Unknown' : 'Unknown';
// //             final reminderMessage = 'REMINDER: Appointment approaching - Status still PENDING\n\n'
// //                   'Pet: ${appointment['pet_name']}\n'
// //                 'Date: ${DateFormat('MMMM dd, yyyy').format(DateTime.parse(appointment['preferred_date']))}\n'
// //                 'Time: ${_formatTime(appointment['preferred_time'])}\n'
// //                 'Owner: $userFullName\n\n'
// //                   'Please update the appointment status.';

// //           // Use the tracking utility to send reminder only if not already sent
// //           await MessageTrackingUtils.sendReminderIfNotSent(
// //             appointment['id'],
// //             appointment['user_id'],
// //             reminderMessage,
// //           );
// //         }
// //       }
// //     } catch (e) {
// //       print('Error checking for reminders: $e');
// //     }
// //   }

// //   @override
// //   void initState() {
// //     super.initState();
// //     if (widget.appointment != null) {
// //       try {
// //         _petNameController.text = widget.appointment!['pet_name']?.toString() ?? '';
// //         _selectedPetType = widget.appointment!['pet_type']?.toString();
// //         if (_selectedPetType == 'Others') {
// //           _petTypeOtherController.text =
// //               widget.appointment!['pet_type_other']?.toString() ?? '';
// //         }
// //         _breedController.text = widget.appointment!['breed']?.toString() ?? '';
// //         _selectedPetSize = widget.appointment!['pet_size']?.toString();
// //         _ageController.text = widget.appointment!['age']?.toString() ?? '';
// //         _selectedGender = widget.appointment!['gender']?.toString();
// //         _allergiesController.text =
// //             widget.appointment!['allergies_medical_conditions']?.toString() ?? '';
// //         _serviceBath = widget.appointment!['service_bath'] ?? false;
// //         _serviceHaircut = widget.appointment!['service_haircut'] ?? false;
// //         _serviceNailTrim = widget.appointment!['service_nail_trim'] ?? false;
// //         _serviceEarCleaning =
// //             widget.appointment!['service_ear_cleaning'] ?? false;
// //         _specialRequestsController.text =
// //             widget.appointment!['special_requests_notes'] ?? '';
// //         _preferredDate = widget.appointment!['preferred_date'] != null
// //             ? DateTime.parse(widget.appointment!['preferred_date'])
// //             : null;
// //         _preferredTime = widget.appointment!['preferred_time'] != null
// //             ? TimeOfDay(
// //                 hour: int.parse(
// //                     widget.appointment!['preferred_time'].split(':')[0]),
// //                 minute: int.parse(
// //                     widget.appointment!['preferred_time'].split(':')[1]))
// //             : null;
// //         _estimatedCost =
// //             (widget.appointment!['estimated_cost'] ?? 0.0).toDouble();
// //         _selectedPaymentMethod = widget.appointment!['payment_method'];
// //         _consentPhotos = widget.appointment!['consent_photos'] ?? false;
// //       } catch (e) {
// //         print('Error pre-filling appointment data: $e');
// //       }
// //     }
// //     _calculateEstimatedCost();
// //   }

// //   @override
// //   void dispose() {
// //     _petNameController.dispose();
// //     _petTypeOtherController.dispose();
// //     _breedController.dispose();
// //     _ageController.dispose();
// //     _allergiesController.dispose();
// //     _specialRequestsController.dispose();
// //     super.dispose();
// //   }

// //   // Build section title
// //   Widget _buildSectionTitle(String title) {
// //     return Padding(
// //       padding: const EdgeInsets.only(bottom: 16),
// //       child: Row(
// //         children: [
// //           Container(
// //             width: 4,
// //             height: 24,
// //             decoration: BoxDecoration(
// //               color: const Color(0xFFF5A623),
// //               borderRadius: BorderRadius.circular(2),
// //             ),
// //           ),
// //           const SizedBox(width: 12),
// //           Text(
// //             title,
// //             style: GoogleFonts.poppins(
// //               fontSize: 20,
// //               fontWeight: FontWeight.w600,
// //               color: const Color(0xFFF5A623),
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   // Build input field
// //   Widget _buildInputField({
// //     required TextEditingController controller,
// //     required String label,
// //     int maxLines = 1,
// //     TextInputType? keyboardType,
// //   }) {
// //     return Container(
// //       margin: const EdgeInsets.only(bottom: 16),
// //       child: TextFormField(
// //         controller: controller,
// //         keyboardType: keyboardType,
// //         maxLines: maxLines,
// //         style: GoogleFonts.poppins(),
// //         decoration: InputDecoration(
// //           labelText: label,
// //           labelStyle: GoogleFonts.poppins(color: Colors.grey[600]),
// //           border: OutlineInputBorder(
// //             borderRadius: BorderRadius.circular(12),
// //             borderSide: BorderSide(color: Colors.grey[300]!),
// //           ),
// //           enabledBorder: OutlineInputBorder(
// //             borderRadius: BorderRadius.circular(12),
// //             borderSide: BorderSide(color: Colors.grey[300]!),
// //           ),
// //           focusedBorder: OutlineInputBorder(
// //             borderRadius: BorderRadius.circular(12),
// //             borderSide: const BorderSide(color: Color(0xFFF5A623)),
// //           ),
// //           filled: true,
// //           fillColor: Colors.grey[50],
// //         ),
// //       ),
// //     );
// //   }

// //   // Build dropdown field
// //   Widget _buildDropdownField({
// //     required String label,
// //     required String? value,
// //     required List<String> items,
// //     required Function(String?) onChanged,
// //   }) {
// //     return Container(
// //       margin: const EdgeInsets.only(bottom: 16),
// //       child: DropdownButtonFormField<String>(
// //         value: value,
// //         decoration: InputDecoration(
// //           labelText: label,
// //           labelStyle: GoogleFonts.poppins(color: Colors.grey[600]),
// //           border: OutlineInputBorder(
// //             borderRadius: BorderRadius.circular(12),
// //             borderSide: BorderSide(color: Colors.grey[300]!),
// //           ),
// //           enabledBorder: OutlineInputBorder(
// //             borderRadius: BorderRadius.circular(12),
// //             borderSide: BorderSide(color: Colors.grey[300]!),
// //           ),
// //           focusedBorder: OutlineInputBorder(
// //             borderRadius: BorderRadius.circular(12),
// //             borderSide: const BorderSide(color: Color(0xFFF5A623)),
// //           ),
// //           filled: true,
// //           fillColor: Colors.grey[50],
// //         ),
// //         items: items.map((String item) {
// //           return DropdownMenuItem<String>(
// //             value: item,
// //             child: Text(item, style: GoogleFonts.poppins()),
// //           );
// //         }).toList(),
// //         onChanged: onChanged,
// //       ),
// //     );
// //   }

// //   // Build service checkbox
// //   Widget _buildServiceCheckbox({
// //     required String title,
// //     required String defaultPrice,
// //     required bool value,
// //     required Function(bool?) onChanged,
// //   }) {
// //     String durationText = '';
// //     String dynamicPrice = defaultPrice;

// //     if (_selectedPetSize != null) {
// //       final durations = _serviceDurations[_selectedPetSize]!;
// //       final prices = _servicePrices[_selectedPetSize]!;

// //       switch (title) {
// //         case 'Bath':
// //           durationText = ' (${_formatDuration(durations['bath']!)})';
// //           dynamicPrice = 'P${prices['bath']}';
// //           break;
// //         case 'Haircut':
// //           durationText = ' (${_formatDuration(durations['haircut']!)})';
// //           dynamicPrice = 'P${prices['haircut']}';
// //           break;
// //         case 'Ear Cleaning':
// //           durationText = ' (${_formatDuration(durations['earCleaning']!)})';
// //           dynamicPrice = 'P${prices['earCleaning']}';
// //           break;
// //         case 'Nail Trim':
// //           durationText = ' (${_formatDuration(durations['nailTrim']!)})';
// //           dynamicPrice = 'P${prices['nailTrim']}';
// //           break;
// //       }
// //     }

// //     return Container(
// //       margin: const EdgeInsets.only(bottom: 8),
// //       decoration: BoxDecoration(
// //         color: Colors.grey[50],
// //         borderRadius: BorderRadius.circular(12),
// //         border: Border.all(color: Colors.grey[300]!),
// //       ),
// //       child: CheckboxListTile(
// //         title: Row(
// //           children: [
// //             Expanded(
// //               child: Column(
// //                 crossAxisAlignment: CrossAxisAlignment.start,
// //                 children: [
// //                   Text(title, style: GoogleFonts.poppins()),
// //                   if (_selectedPetSize != null)
// //                     Text(
// //                       durationText,
// //                       style: GoogleFonts.poppins(
// //                         fontSize: 12,
// //                         color: Colors.blue[600],
// //                       ),
// //                     ),
// //                 ],
// //               ),
// //             ),
// //             if (_selectedPetSize != null)
// //               Container(
// //                 padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
// //                 decoration: BoxDecoration(
// //                   color: const Color(0xFFF5A623).withOpacity(0.1),
// //                   borderRadius: BorderRadius.circular(4),
// //                 ),
// //                 child: Text(
// //                   dynamicPrice,
// //                   style: GoogleFonts.poppins(
// //                     color: const Color(0xFFF5A623),
// //                     fontWeight: FontWeight.w500,
// //                   ),
// //                 ),
// //               ),
// //           ],
// //         ),
// //         value: value,
// //         onChanged: onChanged,
// //         controlAffinity: ListTileControlAffinity.leading,
// //         contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
// //         shape: RoundedRectangleBorder(
// //           borderRadius: BorderRadius.circular(12),
// //         ),
// //       ),
// //     );
// //   }

// //   // Build confirmation row
// //   Widget _buildConfirmationRow(String label, String value) {
// //     return Padding(
// //       padding: const EdgeInsets.only(bottom: 8),
// //       child: Row(
// //         crossAxisAlignment: CrossAxisAlignment.start,
// //         children: [
// //           SizedBox(
// //             width: 160,
// //             child: Text(
// //               '$label:',
// //               style: GoogleFonts.poppins(
// //                 fontWeight: FontWeight.w500,
// //                 color: Colors.grey[700],
// //               ),
// //             ),
// //           ),
// //           Expanded(
// //             child: Text(
// //               value,
// //               style: GoogleFonts.poppins(),
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   // Build service confirmation rows
// //   List<Widget> _buildServiceConfirmationRows() {
// //     final prices = _servicePrices[_selectedPetSize]!;
// //     final List<Widget> rows = [];
// //     if (_serviceBath) rows.add(_buildConfirmationRow('Bath', 'P${prices['bath']}'));
// //     if (_serviceHaircut) {
// //       rows.add(_buildConfirmationRow('Haircut', 'P${prices['haircut']}'));
// //       if (_haircutExtraOption == 'super_furry') {
// //         rows.add(_buildConfirmationRow('For Super Furry Hair Coat', 'P200'));
// //       }
// //       if (_haircutExtraOption == 'severely_matted') {
// //         rows.add(_buildConfirmationRow('For Severely Matted Fur', 'P300'));
// //       }
// //     }
// //     if (_serviceNailTrim) rows.add(_buildConfirmationRow('Nail Trim', 'P${prices['nailTrim']}'));
// //     if (_serviceEarCleaning) rows.add(_buildConfirmationRow('Ear Cleaning', 'P${prices['earCleaning']}'));
// //     return rows;
// //   }

// //   // Format time
// //   String _formatTime(String time) {
// //     try {
// //       final timeOfDay = TimeOfDay(
// //         hour: int.parse(time.split(':')[0]),
// //         minute: int.parse(time.split(':')[1]),
// //       );
// //       return timeOfDay.format(context);
// //     } catch (e) {
// //       return time;
// //     }
// //   }

// //   // Trigger global refresh
// //   void _triggerGlobalRefresh() {
// //     print('Global refresh triggered - new appointment booked');
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return GestureDetector(
// //       onTap: () {
// //         FocusScope.of(context).unfocus();
// //       },
// //       child: Scaffold(
// //         backgroundColor: Colors.grey[100],
// //         appBar: AppBar(
// //           title: Text(
// //             'Book Appointment',
// //             style: GoogleFonts.poppins(
// //               color: const Color(0xFFF5A623),
// //               fontWeight: FontWeight.w600,
// //             ),
// //           ),
// //           backgroundColor: Colors.white,
// //           elevation: 0,
// //           centerTitle: true,
// //         ),
// //         body: SingleChildScrollView(
// //           child: Padding(
// //             padding: const EdgeInsets.all(16.0),
// //             child: Column(
// //               crossAxisAlignment: CrossAxisAlignment.start,
// //               children: [
// //                 // Pet Information Section
// //                 Card(
// //                   elevation: 0,
// //                   shape: RoundedRectangleBorder(
// //                     borderRadius: BorderRadius.circular(16),
// //                   ),
// //                   child: Padding(
// //                     padding: const EdgeInsets.all(16.0),
// //                     child: Column(
// //                       crossAxisAlignment: CrossAxisAlignment.start,
// //                       children: [
// //                         _buildSectionTitle('Pet Information'),
// //                         _buildInputField(
// //                           controller: _petNameController,
// //                           label: 'Pet Name',
// //                         ),
// //                         _buildDropdownField(
// //                           label: 'Pet Type',
// //                           value: _selectedPetType,
// //                           items: ['Dog', 'Cat', 'Others'],
// //                           onChanged: (String? newValue) {
// //                             setState(() {
// //                               _selectedPetType = newValue;
// //                             });
// //                           },
// //                         ),
// //                         if (_selectedPetType == 'Others')
// //                           _buildInputField(
// //                             controller: _petTypeOtherController,
// //                             label: 'Specify Pet Type',
// //                           ),
// //                         _buildInputField(
// //                           controller: _breedController,
// //                           label: 'Breed',
// //                         ),
// //                         _buildDropdownField(
// //                           label: 'Pet Size',
// //                           value: _selectedPetSize,
// //                           items: ['Small', 'Medium', 'Large'],
// //                           onChanged: (String? newValue) {
// //                             setState(() {
// //                               _selectedPetSize = newValue;
// //                               _calculateEstimatedCost();
// //                             });
// //                           },
// //                         ),
// //                         _buildInputField(
// //                           controller: _ageController,
// //                           label: 'Age',
// //                           keyboardType: TextInputType.number,
// //                         ),
// //                         _buildDropdownField(
// //                           label: 'Gender',
// //                           value: _selectedGender,
// //                           items: ['Male', 'Female'],
// //                           onChanged: (String? newValue) {
// //                             setState(() {
// //                               _selectedGender = newValue;
// //                             });
// //                           },
// //                         ),
// //                         _buildInputField(
// //                           controller: _allergiesController,
// //                           label: 'Allergies / Medical Conditions (Optional)',
// //                           maxLines: 3,
// //                         ),
// //                       ],
// //                     ),
// //                   ),
// //                 ),
// //                 const SizedBox(height: 16),

// //                 // Grooming Services Section
// //                 Card(
// //                   elevation: 0,
// //                   shape: RoundedRectangleBorder(
// //                     borderRadius: BorderRadius.circular(16),
// //                   ),
// //                   child: Padding(
// //                     padding: const EdgeInsets.all(16.0),
// //                     child: Column(
// //                       crossAxisAlignment: CrossAxisAlignment.start,
// //                       children: [
// //                         _buildSectionTitle('Grooming Services'),
// //                         _buildServiceCheckbox(
// //                           title: 'Bath',
// //                           defaultPrice: 'Select pet size',
// //                           value: _serviceBath,
// //                           onChanged: (bool? newValue) {
// //                             setState(() {
// //                               _serviceBath = newValue ?? false;
// //                               _calculateEstimatedCost();
// //                             });
// //                           },
// //                         ),
// //                         _buildServiceCheckbox(
// //                           title: 'Haircut',
// //                           defaultPrice: 'Select pet size',
// //                           value: _serviceHaircut,
// //                           onChanged: (bool? newValue) {
// //                             setState(() {
// //                               _serviceHaircut = newValue ?? false;
// //                               _calculateEstimatedCost();
// //                               if (!_serviceHaircut) {
// //                                 _haircutExtraOption = null;
// //                               }
// //                             });
// //                           },
// //                         ),
// //                         if (_serviceHaircut && _selectedPetSize != null)
// //                           Container(
// //                             margin: const EdgeInsets.only(bottom: 8, left: 8, right: 8),
// //                             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
// //                             decoration: BoxDecoration(
// //                               color: Colors.orange[50],
// //                               borderRadius: BorderRadius.circular(8),
// //                               border: Border.all(color: Colors.orange[200]!),
// //                             ),
// //                             child: Column(
// //                               crossAxisAlignment: CrossAxisAlignment.start,
// //                               children: [
// //                                 Text(
// //                                   'Extra Haircut Options',
// //                                   style: GoogleFonts.poppins(
// //                                     fontSize: 13,
// //                                     fontWeight: FontWeight.w600,
// //                                     color: Colors.orange[800],
// //                                   ),
// //                                 ),
// //                                 const SizedBox(height: 4),
// //                                 DropdownButtonFormField<String>(
// //                                   value: _haircutExtraOption,
// //                                   isExpanded: true,
// //                                   decoration: InputDecoration(
// //                                     contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
// //                                     border: OutlineInputBorder(
// //                                       borderRadius: BorderRadius.circular(8),
// //                                       borderSide: BorderSide(color: Colors.orange[200]!),
// //                                     ),
// //                                     filled: true,
// //                                     fillColor: Colors.white,
// //                                   ),
// //                                   style: GoogleFonts.poppins(fontSize: 12, color: Colors.orange[900]),
// //                                   items: const [
// //                                     DropdownMenuItem(
// //                                       value: null,
// //                                       child: Text('None', style: TextStyle(fontSize: 11)),
// //                                     ),
// //                                     DropdownMenuItem(
// //                                       value: 'super_furry',
// //                                       child: Text('For Super Furry Hair Coat (+₱200, +20 mins)', style: TextStyle(fontSize: 11)),
// //                                     ),
// //                                     DropdownMenuItem(
// //                                       value: 'severely_matted',
// //                                       child: Text('For Severely Matted Fur (+₱300, +30 mins)', style: TextStyle(fontSize: 11)),
// //                                     ),
// //                                   ],
// //                                   onChanged: (String? value) {
// //                                     setState(() {
// //                                       _haircutExtraOption = value;
// //                                       _calculateEstimatedCost();
// //                                     });
// //                                   },
// //                                   hint: Text('Select extra option (if applicable)', style: GoogleFonts.poppins(fontSize: 12)),
// //                                 ),
// //                                 const SizedBox(height: 4),
// //                                 Text(
// //                                   'Note: If your dog has a super furry coat or severely matted fur, please select the appropriate option. Additional charges and grooming time will apply',
// //                                   style: GoogleFonts.poppins(fontSize: 10, color: Colors.orange[800]),
// //                                 ),
// //                               ],
// //                             ),
// //                           ),
// //                         _buildServiceCheckbox(
// //                           title: 'Nail Trim',
// //                           defaultPrice: 'Select pet size',
// //                           value: _serviceNailTrim,
// //                           onChanged: (bool? newValue) {
// //                             setState(() {
// //                               _serviceNailTrim = newValue ?? false;
// //                               _calculateEstimatedCost();
// //                             });
// //                           },
// //                         ),
// //                         _buildServiceCheckbox(
// //                           title: 'Ear Cleaning',
// //                           defaultPrice: 'Select pet size',
// //                           value: _serviceEarCleaning,
// //                           onChanged: (bool? newValue) {
// //                             setState(() {
// //                               _serviceEarCleaning = newValue ?? false;
// //                               _calculateEstimatedCost();
// //                             });
// //                           },
// //                         ),
// //                         if (_selectedPetSize != null) ...[
// //                           const SizedBox(height: 16),
// //                           Container(
// //                             width: double.infinity,
// //                             padding: const EdgeInsets.all(16),
// //                             decoration: BoxDecoration(
// //                               color: const Color(0xFFF5A623).withOpacity(0.1),
// //                               borderRadius: BorderRadius.circular(12),
// //                             ),
// //                             child: Column(
// //                               crossAxisAlignment: CrossAxisAlignment.start,
// //                               children: [
// //                                 Text(
// //                                   'Estimated Duration:',
// //                                   style: GoogleFonts.poppins(
// //                                     fontSize: 16,
// //                                     fontWeight: FontWeight.w500,
// //                                   ),
// //                                 ),
// //                                 const SizedBox(height: 12),
// //                                 Text(
// //                                   _formatDuration(_calculateTotalDuration()),
// //                                   style: GoogleFonts.poppins(
// //                                     fontSize: 18,
// //                                     fontWeight: FontWeight.w600,
// //                                     color: const Color(0xFFF5A623),
// //                                   ),
// //                                 ),
// //                               ],
// //                             ),
// //                           ),
// //                         ],
// //                         const SizedBox(height: 16),
// //                         _buildInputField(
// //                           controller: _specialRequestsController,
// //                           label: 'Special Requests/ Notes (Optional)',
// //                           maxLines: 3,
// //                         ),
// //                       ],
// //                     ),
// //                   ),
// //                 ),
// //                 const SizedBox(height: 16),

// //                 // Appointment Details Section
// //                 Card(
// //                   elevation: 0,
// //                   shape: RoundedRectangleBorder(
// //                     borderRadius: BorderRadius.circular(16),
// //                   ),
// //                   child: Padding(
// //                     padding: const EdgeInsets.all(16.0),
// //                     child: Column(
// //                       crossAxisAlignment: CrossAxisAlignment.start,
// //                       children: [
// //                         _buildSectionTitle('Appointment Details'),
// //                         Container(
// //                           margin: const EdgeInsets.only(bottom: 16),
// //                           decoration: BoxDecoration(
// //                             color: Colors.grey[50],
// //                             borderRadius: BorderRadius.circular(12),
// //                             border: Border.all(color: Colors.grey[300]!),
// //                           ),
// //                           child: ListTile(
// //                             title: Text(
// //                               _preferredDate == null
// //                                   ? 'Select Preferred Date'
// //                                   : 'Date: ${_preferredDate!.toLocal().toString().split(' ')[0]}',
// //                               style: GoogleFonts.poppins(),
// //                             ),
// //                             trailing: const Icon(Icons.calendar_today,
// //                                 color: Color(0xFFF5A623)),
// //                             onTap: () async {
// //                               final DateTime? picked = await showDatePicker(
// //                                 context: context,
// //                                 initialDate: _preferredDate ?? DateTime.now(),
// //                                 firstDate: DateTime.now(),
// //                                 lastDate: DateTime(2101),
// //                               );
// //                               if (picked != null && picked != _preferredDate) {
// //                                 setState(() {
// //                                   _preferredDate = picked;
// //                                   _preferredTime = null;
// //                                 });
// //                                 _showAvailableTimeSlots(context, picked);
// //                               }
// //                             },
// //                           ),
// //                         ),
// //                         Container(
// //                           margin: const EdgeInsets.only(bottom: 16),
// //                           decoration: BoxDecoration(
// //                             color: Colors.grey[50],
// //                             borderRadius: BorderRadius.circular(12),
// //                             border: Border.all(color: Colors.grey[300]!),
// //                           ),
// //                           child: ListTile(
// //                             title: Text(
// //                               _preferredTime == null
// //                                   ? 'Select Preferred Time'
// //                                   : 'Time: ${_preferredTime!.format(context)}',
// //                               style: GoogleFonts.poppins(),
// //                             ),
// //                             trailing: const Icon(Icons.access_time,
// //                                 color: Color(0xFFF5A623)),
// //                             onTap: () async {
// //                               if (_preferredDate == null) {
// //                                 ScaffoldMessenger.of(context).showSnackBar(
// //                                   const SnackBar(
// //                                     content: Text('Please select a date first'),
// //                                     backgroundColor: Colors.red,
// //                                   ),
// //                                 );
// //                                 return;
// //                               }
// //                               _showAvailableTimeSlots(context, _preferredDate!);
// //                             },
// //                           ),
// //                         ),
// //                       ],
// //                     ),
// //                   ),
// //                 ),
// //                 const SizedBox(height: 16),

// //                 // Payment Information Section
// //                 Card(
// //                   elevation: 0,
// //                   shape: RoundedRectangleBorder(
// //                     borderRadius: BorderRadius.circular(16),
// //                   ),
// //                   child: Padding(
// //                     padding: const EdgeInsets.all(16.0),
// //                     child: Column(
// //                       crossAxisAlignment: CrossAxisAlignment.start,
// //                       children: [
// //                         _buildSectionTitle('Payment Information'),
// //                         if (_selectedPetSize != null) ...[
// //                           Container(
// //                             padding: const EdgeInsets.all(16),
// //                             decoration: BoxDecoration(
// //                               color: const Color(0xFFF5A623).withOpacity(0.1),
// //                               borderRadius: BorderRadius.circular(12),
// //                             ),
// //                             child: Row(
// //                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                               children: [
// //                                 Text(
// //                                   'Estimated Cost:',
// //                                   style: GoogleFonts.poppins(
// //                                     fontSize: 16,
// //                                     fontWeight: FontWeight.w500,
// //                                   ),
// //                                 ),
// //                                 Text(
// //                                   'P${_estimatedCost.toStringAsFixed(2)}',
// //                                   style: GoogleFonts.poppins(
// //                                     fontSize: 18,
// //                                     fontWeight: FontWeight.w600,
// //                                     color: const Color(0xFFF5A623),
// //                                   ),
// //                                 ),
// //                               ],
// //                             ),
// //                           ),
// //                           const SizedBox(height: 16),
// //                         ],
// //                         _buildDropdownField(
// //                           label: 'Payment Method',
// //                           value: _selectedPaymentMethod,
// //                           items: ['Cash', 'Gcash'],
// //                           onChanged: (String? newValue) {
// //                             setState(() {
// //                               _selectedPaymentMethod = newValue;
// //                             });
// //                           },
// //                         ),
// //                         if (_selectedPaymentMethod == 'Gcash') ...[
// //                           const SizedBox(height: 16),
// //                           Container(
// //                             padding: const EdgeInsets.all(16),
// //                             decoration: BoxDecoration(
// //                               color: Colors.blue[50],
// //                               borderRadius: BorderRadius.circular(12),
// //                               border: Border.all(color: Colors.blue[200]!),
// //                             ),
// //                             child: Column(
// //                               children: [
// //                                 Text(
// //                                   '0915 548 5814',
// //                                   style: GoogleFonts.poppins(
// //                                     color: Colors.blue[700],
// //                                     fontSize: 14,
// //                                     fontWeight: FontWeight.w500,
// //                                   ),
// //                                   textAlign: TextAlign.center,
// //                                 ),
// //                                 const SizedBox(height: 16),
// //                                 Image.asset(
// //                                   'assets/images/gcash_qr.png',
// //                                   height: 200,
// //                                   width: 200,
// //                                 ),
// //                                 const SizedBox(height: 12),
// //                                 Row(
// //                                   children: [
// //                                     const Icon(Icons.info_outline,
// //                                         color: Colors.blue),
// //                                     const SizedBox(width: 12),
// //                                     Expanded(
// //                                       child: Text(
// //                                         'The payment receipt must be presented to the groomer before the appointment.',
// //                                         style: GoogleFonts.poppins(
// //                                           color: Colors.blue[700],
// //                                           fontSize: 12,
// //                                         ),
// //                                       ),
// //                                     ),
// //                                   ],
// //                                 ),
// //                               ],
// //                             ),
// //                           ),
// //                         ],
// //                         const SizedBox(height: 16),
// //                         Container(
// //                           decoration: BoxDecoration(
// //                             color: Colors.grey[50],
// //                             borderRadius: BorderRadius.circular(12),
// //                             border: Border.all(color: Colors.grey[300]!),
// //                           ),
// //                           child: CheckboxListTile(
// //                             title: Text(
// //                               'I consent to the use of before and after photos of my pet for social media purposes',
// //                               style: GoogleFonts.poppins(fontSize: 14),
// //                             ),
// //                             value: _consentPhotos,
// //                             onChanged: (bool? newValue) {
// //                               setState(() {
// //                                 _consentPhotos = newValue ?? false;
// //                               });
// //                             },
// //                             controlAffinity: ListTileControlAffinity.leading,
// //                             contentPadding:
// //                                 const EdgeInsets.symmetric(horizontal: 16),
// //                           ),
// //                         ),
// //                       ],
// //                     ),
// //                   ),
// //                 ),
// //                 const SizedBox(height: 32),
// //                 SizedBox(
// //                   width: double.infinity,
// //                   child: ElevatedButton(
// //                     onPressed: _isLoading
// //                         ? null
// //                         : () async {
// //                             if (_petNameController.text.isEmpty ||
// //                                 _selectedPetType == null ||
// //                                 (_selectedPetType == 'Others' &&
// //                                     _petTypeOtherController.text.isEmpty) ||
// //                                 _selectedPetSize == null ||
// //                                 _selectedGender == null ||
// //                                 _preferredDate == null ||
// //                                 _preferredTime == null ||
// //                                 _selectedPaymentMethod == null ||
// //                                 _estimatedCost <= 0) {
// //                               ScaffoldMessenger.of(context).showSnackBar(
// //                                 const SnackBar(
// //                                   content: Text(
// //                                       'Please fill in all required fields and select at least one service.'),
// //                                   backgroundColor: Colors.red,
// //                                 ),
// //                               );
// //                               return;
// //                             }
// //                             final currentDuration = _calculateTotalDuration();
// //                             final endTime = TimeOfDay(
// //                               hour: (_preferredTime!.hour * 60 +
// //                                       _preferredTime!.minute +
// //                                       currentDuration) ~/
// //                                   60,
// //                               minute: (_preferredTime!.hour * 60 +
// //                                       _preferredTime!.minute +
// //                                       currentDuration) %
// //                                   60,
// //                             );
// //                             final confirmed = await showDialog<bool>(
// //                               context: context,
// //                               builder: (BuildContext context) {
// //                                 return AlertDialog(
// //                                   title: Text(
// //                                     widget.appointment != null
// //                                         ? 'Confirm Update'
// //                                         : 'Confirm Appointment',
// //                                     style: GoogleFonts.poppins(
// //                                       fontWeight: FontWeight.w600,
// //                                       color: const Color(0xFFF5A623),
// //                                     ),
// //                                   ),
// //                                   content: SingleChildScrollView(
// //                                     child: Column(
// //                                       crossAxisAlignment:
// //                                           CrossAxisAlignment.start,
// //                                       mainAxisSize: MainAxisSize.min,
// //                                       children: [
// //                                         Text(
// //                                           'Please review your appointment details: ',
// //                                           style: GoogleFonts.poppins(
// //                                             fontWeight: FontWeight.w500,
// //                                           ),
// //                                         ),
// //                                         const SizedBox(height: 16),
// //                                         _buildConfirmationRow(
// //                                             'Pet Name', _petNameController.text),
// //                                         _buildConfirmationRow(
// //                                             'Pet Type', _selectedPetType!),
// //                                         if (_selectedPetType == 'Others')
// //                                           _buildConfirmationRow('Other Pet Type',
// //                                               _petTypeOtherController.text),
// //                                         _buildConfirmationRow(
// //                                             'Breed', _breedController.text),
// //                                         _buildConfirmationRow(
// //                                             'Size', _selectedPetSize!),
// //                                         _buildConfirmationRow(
// //                                             'Age', _ageController.text),
// //                                         _buildConfirmationRow(
// //                                             'Gender', _selectedGender!),
// //                                         if (_allergiesController.text.isNotEmpty)
// //                                           _buildConfirmationRow(
// //                                               'Allergies/Medical Conditions',
// //                                               _allergiesController.text),
// //                                         const Divider(),
// //                                         Text(
// //                                           'Selected Services:',
// //                                           style: GoogleFonts.poppins(
// //                                             fontWeight: FontWeight.w500,
// //                                           ),
// //                                         ),
// //                                         if (_selectedPetSize != null) ..._buildServiceConfirmationRows(),
// //                                         const Divider(),
// //                                         _buildConfirmationRow(
// //                                             'Date',
// //                                             _preferredDate!
// //                                                 .toLocal()
// //                                                 .toString()
// //                                                 .split(' ')[0]),
// //                                         _buildConfirmationRow('Time',
// //                                             '${_preferredTime!.format(context)} - ${endTime.format(context)}'),
// //                                         _buildConfirmationRow('Duration',
// //                                             _formatDuration(currentDuration)),
// //                                         _buildConfirmationRow('Total Cost',
// //                                             'P${_estimatedCost.toStringAsFixed(2)}'),
// //                                         _buildConfirmationRow('Payment Method',
// //                                             _selectedPaymentMethod!),
// //                                         const SizedBox(height: 16),
// //                                         Container(
// //                                           padding: const EdgeInsets.all(12),
// //                                           decoration: BoxDecoration(
// //                                             color: Colors.orange[50],
// //                                             borderRadius:
// //                                                 BorderRadius.circular(8),
// //                                             border: Border.all(
// //                                                 color: Colors.orange[200]!),
// //                                           ),
// //                                           child: Row(
// //                                             children: [
// //                                               Icon(Icons.info_outline,
// //                                                   color: Colors.orange[700],
// //                                                   size: 20),
// //                                               const SizedBox(width: 8),
// //                                               Expanded(
// //                                                 child: Text(
// //                                                   'Note: Timely arrival is requested to maintain scheduling efficiency and avoid overlaps with other bookings. We appreciate your understanding and cooperation.',
// //                                                   style: GoogleFonts.poppins(
// //                                                     fontSize: 12,
// //                                                     color: Colors.orange[900],
// //                                                   ),
// //                                                 ),
// //                                               ),
// //                                             ],
// //                                           ),
// //                                         ),
// //                                       ],
// //                                     ),
// //                                   ),
// //                                   actions: [
// //                                     TextButton(
// //                                       onPressed: () =>
// //                                           Navigator.pop(context, false),
// //                                       child: Text(
// //                                         'Cancel',
// //                                         style: GoogleFonts.poppins(
// //                                           color: Colors.grey[600],
// //                                         ),
// //                                       ),
// //                                     ),
// //                                     ElevatedButton(
// //                                       onPressed: () =>
// //                                           Navigator.pop(context, true),
// //                                       style: ElevatedButton.styleFrom(
// //                                         backgroundColor: const Color(0xFFF5A623),
// //                                         foregroundColor: Colors.white,
// //                                       ),
// //                                       child: Text(
// //                                         'Confirm Booking',
// //                                         style: GoogleFonts.poppins(
// //                                           fontWeight: FontWeight.w500,
// //                                         ),
// //                                       ),
// //                                     ),
// //                                   ],
// //                                 );
// //                               },
// //                             );
// //                             if (confirmed != true) return;
// //                             setState(() {
// //                               _isLoading = true;
// //                             });
// //                             try {
// //                               final userId = _supabase.auth.currentUser?.id;
// //                               if (userId == null) {
// //                                 throw Exception('User not logged in');
// //                               }
// //                               final data = {
// //                                 'user_id': userId,
// //                                 'pet_name': _petNameController.text,
// //                                 'pet_type': _selectedPetType,
// //                                 'pet_type_other': _selectedPetType == 'Others'
// //                                     ? _petTypeOtherController.text
// //                                     : null,
// //                                 'breed': _breedController.text,
// //                                 'pet_size': _selectedPetSize,
// //                                 'age': int.tryParse(_ageController.text),
// //                                 'gender': _selectedGender,
// //                                 'allergies_medical_conditions':
// //                                     _allergiesController.text,
// //                                 'service_bath': _serviceBath,
// //                                 'service_haircut': _serviceHaircut,
// //                                 'service_nail_trim': _serviceNailTrim,
// //                                 'service_ear_cleaning': _serviceEarCleaning,
// //                                 'special_requests_notes':
// //                                     _specialRequestsController.text,
// //                                 'preferred_date': _preferredDate!
// //                                     .toIso8601String()
// //                                     .split('T')[0],
// //                                 'preferred_time':
// //                                     '${_preferredTime!.hour.toString().padLeft(2, '0')}:${_preferredTime!.minute.toString().padLeft(2, '0')}',
// //                                 'estimated_cost': _estimatedCost,
// //                                 'payment_method': _selectedPaymentMethod,
// //                                 'consent_photos': _consentPhotos,
// //                                 'estimated_duration': _calculateTotalDuration(),
// //                                 'status': 'Pending',
// //                               };
// //                               if (widget.appointment != null) {
// //                                 await _supabase
// //                                     .from('grooming_appointments')
// //                                     .update(data)
// //                                     .eq('id', widget.appointment!['id']);
// //                               } else {
// //                                 final inserted = await _supabase
// //                                     .from('grooming_appointments')
// //                                     .insert(data)
// //                                     .select()
// //                                     .single();
// //                                 final userProfile = await _supabase
// //                                     .from('users')
// //                                     .select('full_name, contact_number')
// //                                     .eq('id', userId)
// //                                     .single();
// //                                 final services = <String>[];
// //                                 if (_serviceBath) services.add('Bath');
// //                                 if (_serviceHaircut) services.add('Haircut');
// //                                 if (_serviceNailTrim) services.add('Nail Trim');
// //                                 if (_serviceEarCleaning) services.add('Ear Cleaning');
// //                                 final petType = _selectedPetType == 'Others' ? _petTypeOtherController.text : _selectedPetType;
// //                                 final dateFormatted = '${_preferredDate!.month.toString().padLeft(2, '0')}-${_preferredDate!.day.toString().padLeft(2, '0')}-${_preferredDate!.year}';
// //                                 final message =
// //                                     'New grooming appointment booked by ${userProfile['full_name']} (${userProfile['contact_number']}):\n'
// //                                     'Pet: ${_petNameController.text}\n'
// //                                     'Type: $petType\n'
// //                                     'Breed: ${_breedController.text}\n'
// //                                     'Size: $_selectedPetSize\n'
// //                                     'Age: ${_ageController.text}\n'
// //                                     'Gender: $_selectedGender\n\n'
// //                                     'Services: ${services.join(', ')}\n'
// //                                     'Date: $dateFormatted\n'
// //                                     'Time: ${_preferredTime!.format(context)}\n'
// //                                     'Payment Method: $_selectedPaymentMethod\n'
// //                                     'Cost: ₱${_estimatedCost.toStringAsFixed(2)}';
// //                                 await _supabase
// //                                     .from('admin_messages')
// //                                     .insert({
// //                                   'user_id': userId,
// //                                   'appointment_id': inserted['id'],
// //                                   'message': message,
// //                                 });
// //                                 await _supabase.from('user_messages').insert({
// //                                   'user_id': userId,
// //                                   'appointment_id': inserted['id'],
// //                                   'message': message,
// //                                   'is_from_admin': false,
// //                                   'is_read': false,
// //                                 });
// //                               }
// //                               if (mounted) {
// //                                 ScaffoldMessenger.of(context).showSnackBar(
// //                                   SnackBar(
// //                                     content: Text(widget.appointment != null
// //                                         ? 'Appointment updated successfully!'
// //                                         : 'Appointment booked successfully!'),
// //                                     backgroundColor: Colors.green,
// //                                     duration: const Duration(seconds: 3),
// //                                   ),
// //                                 );
// //                                 Navigator.pushNamedAndRemoveUntil(
// //                                   context,
// //                                   '/home',
// //                                   (route) => false
// //                                 );
// //                                 _triggerGlobalRefresh();
// //                               }
// //                             } catch (error) {
// //                               if (mounted) {
// //                                 ScaffoldMessenger.of(context).showSnackBar(
// //                                   SnackBar(
// //                                     content: Text(widget.appointment != null
// //                                         ? 'Error updating appointment: ${error.toString()}'
// //                                         : 'Error booking appointment: ${error.toString()}'),
// //                                     backgroundColor: Colors.red,
// //                                   ),
// //                                 );
// //                               }
// //                             } finally {
// //                               if (mounted) {
// //                                 setState(() {
// //                                   _isLoading = false;
// //                                 });
// //                               }
// //                             }
// //                           },
// //                     style: ElevatedButton.styleFrom(
// //                       backgroundColor: const Color(0xFFF5A623),
// //                       foregroundColor: Colors.white,
// //                       shape: RoundedRectangleBorder(
// //                         borderRadius: BorderRadius.circular(12),
// //                       ),
// //                       padding: const EdgeInsets.symmetric(vertical: 16),
// //                       elevation: 0,
// //                     ),
// //                     child: _isLoading
// //                         ? const SizedBox(
// //                             width: 24,
// //                             height: 24,
// //                             child: CircularProgressIndicator(
// //                               color: Colors.white,
// //                               strokeWidth: 2,
// //                             ),
// //                           )
// //                         : Text(
// //                             widget.appointment != null
// //                                 ? 'Update Appointment'
// //                                 : 'Book Appointment',
// //                             style: GoogleFonts.poppins(
// //                               fontSize: 16,
// //                               fontWeight: FontWeight.w600,
// //                             ),
// //                           ),
// //                   ),
// //                 ),
// //                 const SizedBox(height: 16),
// //               ],
// //             ),
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }

// // ----

// // import 'package:flutter/material.dart';
// // import 'package:google_fonts/google_fonts.dart';
// // import 'package:supabase_flutter/supabase_flutter.dart';
// // import 'package:intl/intl.dart';
// // import '../config/supabase_config.dart';
// // import '../utils/message_tracking_utils.dart';
// // class ServiceDuration {
// //   final int bath;
// //   final int haircut;
// //   final int earCleaning;
// //   final int nailTrim;
// //   const ServiceDuration({
// //     required this.bath,
// //     required this.haircut,
// //     required this.earCleaning,
// //     required this.nailTrim,
// //   });
// //   int getTotalDuration(
// //       bool hasBath, bool hasHaircut, bool hasEarCleaning, bool hasNailTrim) {
// //     int total = 0;
// //     if (hasBath) total += bath;
// //     if (hasHaircut) total += haircut;
// //     if (hasEarCleaning) total += earCleaning;
// //     if (hasNailTrim) total += nailTrim;
// //     return total;
// //   }
// //   String formatDuration(int minutes) {
// //     if (minutes < 60) {
// //       return '$minutes minutes';
// //     } else {
// //       int hours = minutes ~/ 60;
// //       int remainingMinutes = minutes % 60;
// //       if (remainingMinutes == 0) {
// //         return '$hours hour${hours > 1 ? 's' : ''}';
// //       }
// //       return '$hours hour${hours > 1 ? 's' : ''} and $remainingMinutes minutes';
// //     }
// //   }
// // }
// // class GroomingAppointmentPage extends StatefulWidget {
// //   final Map<String, dynamic>? appointment;
// //   const GroomingAppointmentPage({super.key, this.appointment});
// //   @override
// //   State<GroomingAppointmentPage> createState() =>
// //       _GroomingAppointmentPageState();
// // }
// // class _GroomingAppointmentPageState extends State<GroomingAppointmentPage> {
// //   final _supabase = Supabase.instance.client;
// //   bool _isLoading = false;
// //   // Service durations based on pet size
// //   final Map<String, Map<String, int>> _serviceDurations = {
// //     'Small': {
// //       'bath': 30,
// //       'haircut': 40,
// //       'earCleaning': 10,
// //       'nailTrim': 10,
// //     },
// //     'Medium': {
// //       'bath': 40,
// //       'haircut': 60,
// //       'earCleaning': 10,
// //       'nailTrim': 10,
// //     },
// //     'Large': {
// //       'bath': 50,
// //       'haircut': 80,
// //       'earCleaning': 10,
// //       'nailTrim': 10,
// //     },
// //   };
// //   // Service prices based on pet size
// //   final Map<String, Map<String, int>> _servicePrices = {
// //     'Small': {
// //       'bath': 300,
// //       'haircut': 400,
// //       'nailTrim': 100,
// //       'earCleaning': 100,
// //     },
// //     'Medium': {
// //       'bath': 400,
// //       'haircut': 500,
// //       'nailTrim': 110,
// //       'earCleaning': 110,
// //     },
// //     'Large': {
// //       'bath': 500,
// //       'haircut': 600,
// //       'nailTrim': 120,
// //       'earCleaning': 120,
// //     },
// //   };
// //   // Pet Information
// //   final _petNameController = TextEditingController();
// //   String? _selectedPetType;
// //   final _petTypeOtherController = TextEditingController();
// //   final _breedController = TextEditingController();
// //   String? _selectedPetSize;
// //   final _ageController = TextEditingController();
// //   String? _selectedGender;
// //   final _allergiesController = TextEditingController();
// //   // Grooming Services Details
// //   bool _serviceBath = false;
// //   bool _serviceHaircut = false;
// //   bool _serviceNailTrim = false;
// //   bool _serviceEarCleaning = false;
// //   final _specialRequestsController = TextEditingController();
// //   String? _haircutExtraOption;
// //   // Appointment Details
// //   DateTime? _preferredDate;
// //   TimeOfDay? _preferredTime;
// //   // Payment Information
// //   double _estimatedCost = 0.0;
// //   String? _selectedPaymentMethod;
// //   bool _consentPhotos = false;
// //   // Format duration
// //   String _formatDuration(int minutes) {
// //     if (minutes < 60) {
// //       return '$minutes minutes';
// //     } else {
// //       int hours = minutes ~/ 60;
// //       int remainingMinutes = minutes % 60;
// //       if (remainingMinutes == 0) {
// //         return '$hours hour${hours > 1 ? 's' : ''}';
// //       }
// //       return '$hours hour${hours > 1 ? 's' : ''} and $remainingMinutes minutes';
// //     }
// //   }
// //   // Calculate total duration
// //   int _calculateTotalDuration() {
// //     if (_selectedPetSize == null) return 0;
// //     final durations = _serviceDurations[_selectedPetSize]!;
// //     int total = 0;
// //     if (_serviceBath) total += durations['bath']!;
// //     if (_serviceHaircut) total += durations['haircut']!;
// //     if (_serviceEarCleaning) total += durations['earCleaning']!;
// //     if (_serviceNailTrim) total += durations['nailTrim']!;
// //     if (_serviceHaircut) {
// //       if (_haircutExtraOption == 'super_furry') {
// //         total += 20;
// //       } else if (_haircutExtraOption == 'severely_matted') {
// //         total += 30;
// //       }
// //     }
// //     return total;
// //   }
// //   // Calculate estimated cost
// //   void _calculateEstimatedCost() {
// //     _estimatedCost = 0.0;
// //     if (_selectedPetSize != null) {
// //       final prices = _servicePrices[_selectedPetSize]!;
// //       if (_serviceBath) _estimatedCost += prices['bath']!;
// //       if (_serviceHaircut) _estimatedCost += prices['haircut']!;
// //       if (_serviceNailTrim) _estimatedCost += prices['nailTrim']!;
// //       if (_serviceEarCleaning) _estimatedCost += prices['earCleaning']!;
// //       if (_serviceHaircut) {
// //         if (_haircutExtraOption == 'super_furry') {
// //           _estimatedCost += 200.0;
// //         } else if (_haircutExtraOption == 'severely_matted') {
// //           _estimatedCost += 300.0;
// //         }
// //       } else {
// //         _haircutExtraOption = null;
// //       }
// //     }
// //     setState(() {});
// //   }
// //   // Get available time slots
// //   Future<List<TimeOfDay>> _getAvailableTimeSlots(DateTime date) async {
// //     try {
// //       final formattedDate = date.toIso8601String().split('T')[0];
// //       final response = await _supabase
// //           .from('grooming_appointments')
// //           .select('preferred_time, estimated_duration, status')
// //           .eq('preferred_date', formattedDate)
// //           .not('status', 'in', ['Cancelled', 'Cancelled (by user)']);
// //       final bookedRanges = response.map((appointment) {
// //         final parts = appointment['preferred_time'].split(':');
// //         final startTime =
// //             TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
// //         final duration = appointment['estimated_duration'] as int;
// //         final totalMinutes = startTime.hour * 60 + startTime.minute + duration + 10;
// //         final endHour = totalMinutes ~/ 60;
// //         final endMinute = totalMinutes % 60;
// //         final endTime = TimeOfDay(hour: endHour, minute: endMinute);
// //         return [startTime, endTime];
// //       }).toList();
// //       final allTimeSlots = <TimeOfDay>[];
// //       for (int hour = 9; hour < 12; hour++) {
// //         for (int minute = 0; minute < 60; minute += 10) {
// //           allTimeSlots.add(TimeOfDay(hour: hour, minute: minute));
// //         }
// //       }
// //       for (int hour = 13; hour < 17; hour++) {
// //         for (int minute = 0; minute < 60; minute += 10) {
// //           allTimeSlots.add(TimeOfDay(hour: hour, minute: minute));
// //         }
// //       }
// //       final currentDuration = _calculateTotalDuration();
// //       return allTimeSlots.where((slot) {
// //         final slotTotalMinutes = slot.hour * 60 + slot.minute + currentDuration + 10;
// //         final slotEndHour = slotTotalMinutes ~/ 60;
// //         final slotEndMinute = slotTotalMinutes % 60;
// //         final slotEndTime = TimeOfDay(hour: slotEndHour, minute: slotEndMinute);
// //         final slotStartMinutes = slot.hour * 60 + slot.minute;
// //         final slotEndMinutes = slotEndHour * 60 + slotEndMinute;
// //         if (slotStartMinutes < 12 * 60 && slotEndMinutes > 12 * 60) {
// //           return false;
// //         }
// //         if (slotStartMinutes < 13 * 60 && slotEndMinutes > 13 * 60 && slotStartMinutes >= 12 * 60) {
// //           return false;
// //         }
// //         if (slotEndMinutes > 17 * 60) {
// //           return false;
// //         }
// //         for (var range in bookedRanges) {
// //           final existingStart = range[0] as TimeOfDay;
// //           final existingEnd = range[1] as TimeOfDay;
// //           final existingStartMinutes =
// //               existingStart.hour * 60 + existingStart.minute;
// //           final existingEndMinutes = existingEnd.hour * 60 + existingEnd.minute;
// //           if (slotStartMinutes < existingEndMinutes &&
// //               slotEndMinutes > existingStartMinutes) {
// //             return false;
// //           }
// //         }
// //         return true;
// //       }).toList();
// //     } catch (e) {
// //       print('Error getting available time slots: $e');
// //       return [];
// //     }
// //   }
// //   // Show available time slots
// //   Future<void> _showAvailableTimeSlots(
// //       BuildContext context, DateTime date) async {
// //     final availableSlots = await _getAvailableTimeSlots(date);
// //     if (availableSlots.isEmpty) {
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         const SnackBar(
// //           content: Text(
// //               'No available time slots for this date. Please select another date.'),
// //           backgroundColor: Colors.red,
// //         ),
// //       );
// //       return;
// //     }
// //     if (!mounted) return;
// //     final currentDuration = _calculateTotalDuration();
// //     final durationText = _formatDuration(currentDuration);
// //     showDialog(
// //       context: context,
// //       builder: (BuildContext context) {
// //         return AlertDialog(
// //           title: Text(
// //             'Available Time Slots',
// //             style: GoogleFonts.poppins(
// //               fontWeight: FontWeight.w600,
// //               color: const Color(0xFFF5A623),
// //             ),
// //           ),
// //           content: SingleChildScrollView(
// //             child: Column(
// //               mainAxisSize: MainAxisSize.min,
// //               crossAxisAlignment: CrossAxisAlignment.start,
// //               children: [
// //                 Text(
// //                   'Service Duration: $durationText',
// //                   style: GoogleFonts.poppins(
// //                     fontSize: 14,
// //                     color: Colors.grey[600],
// //                   ),
// //                 ),
// //                 const SizedBox(height: 16),
// //                 ...availableSlots.map((time) {
// //                   final endTime = TimeOfDay(
// //                     hour:
// //                         (time.hour * 60 + time.minute + currentDuration) ~/ 60,
// //                     minute:
// //                         (time.hour * 60 + time.minute + currentDuration) % 60,
// //                   );
// //                   return ListTile(
// //                     title: Text(
// //                       '${time.format(context)} - ${endTime.format(context)}',
// //                       style: GoogleFonts.poppins(),
// //                     ),
// //                     onTap: () {
// //                       setState(() {
// //                         _preferredTime = time;
// //                       });
// //                       Navigator.pop(context);
// //                     },
// //                   );
// //                 }).toList(),
// //               ],
// //             ),
// //           ),
// //           actions: [
// //             TextButton(
// //               onPressed: () => Navigator.pop(context),
// //               child: Text(
// //                 'Cancel',
// //                 style: GoogleFonts.poppins(
// //                   color: Colors.grey[600],
// //                 ),
// //               ),
// //             ),
// //           ],
// //         );
// //       },
// //     );
// //   }
// //   // Check and send reminders
// //   // Future<void> _checkAndSendReminders() async {
// //   //   try {
// //   //     final supabase = Supabase.instance.client;
// //   //     final now = DateTime.now();
// //   //     final response = await supabase
// //   //         .from('grooming_appointments')
// //   //         .select('id, user_id, pet_name, preferred_date, preferred_time, status')
// //   //         .eq('status', 'Pending');
// //   //     for (final appointment in response) {
// //   //       final appointmentDate = DateTime.parse(appointment['preferred_date']);
// //   //       final appointmentTime = appointment['preferred_time'];
// //   //       final timeParts = appointmentTime.split(':');
// //   //       final appointmentHour = int.parse(timeParts[0]);
// //   //       final appointmentMinute = int.parse(timeParts[1]);
// //   //       final appointmentDateTime = DateTime(
// //   //         appointmentDate.year,
// //   //         appointmentDate.month,
// //   //         appointmentDate.day,
// //   //         appointmentHour,
// //   //         appointmentMinute,
// //   //       );
// //   //       final reminderTime = appointmentDateTime.subtract(const Duration(hours: 24));
// //   //       if (now.isBefore(appointmentDateTime) && now.isAfter(reminderTime)) {
// //   //         final userResponse = await supabase
// //   //             .from('users')
// //   //             .select('full_name')
// //   //             .eq('id', appointment['user_id'])
// //   //             .maybeSingle();
// //   //         final userFullName = userResponse != null ? userResponse['full_name'] ?? 'Unknown' : 'Unknown';
// //   //         final reminderMessage = 'REMINDER: Appointment approaching - Status still PENDING\n\n'
// //   //             'Pet: ${appointment['pet_name']}\n'
// //   //             'Date: ${DateFormat('MMMM dd, yyyy').format(DateTime.parse(appointment['preferred_date']))}\n'
// //   //             'Time: ${_formatTime(appointment['preferred_time'])}\n'
// //   //             'Owner: $userFullName\n\n'
// //   //             'Please update the appointment status.';
// //   //         await MessageTrackingUtils.sendReminderIfNotSent(
// //   //           appointment['id'],
// //   //           appointment['user_id'],
// //   //           reminderMessage,
// //   //         );
// //   //       }
// //   //     }
// //   //   } catch (e) {
// //   //     print('Error checking for reminders: $e');
// //   //   }
// //   // }
// //     // Add this function after the existing functions but before the build method
// //   Future<void> _checkAndSendReminders() async {
// //     try {
// //       final supabase = Supabase.instance.client;
// //       final now = DateTime.now();
// //       final response = await supabase
// //           .from('grooming_appointments')
// //           .select('id, user_id, pet_name, preferred_date, preferred_time, status')
// //           .eq('status', 'Pending');
// //         for (final appointment in response) {
// //           final appointmentDate = DateTime.parse(appointment['preferred_date']);
// //           final appointmentTime = appointment['preferred_time'];
// //           final timeParts = appointmentTime.split(':');
// //           final appointmentHour = int.parse(timeParts[0]);
// //           final appointmentMinute = int.parse(timeParts[1]);
// //           final appointmentDateTime = DateTime(
// //             appointmentDate.year,
// //             appointmentDate.month,
// //             appointmentDate.day,
// //             appointmentHour,
// //             appointmentMinute,
// //           );
// //         // Calculate the reminder time (24 hours before appointment)
// //         final reminderTime = appointmentDateTime.subtract(const Duration(hours: 24));
// //         // Send reminder if we're within the 24-hour period before the appointment time
// //         if (now.isBefore(appointmentDateTime) && now.isAfter(reminderTime)) {
// //             final userResponse = await supabase
// //                 .from('users')
// //                 .select('full_name')
// //                 .eq('id', appointment['user_id'])
// //                 .maybeSingle();
// //             final userFullName = userResponse != null ? userResponse['full_name'] ?? 'Unknown' : 'Unknown';
// //             final reminderMessage = 'REMINDER: Appointment approaching - Status still PENDING\n\n'
// //                   'Pet: ${appointment['pet_name']}\n'
// //                 'Date: ${DateFormat('MMMM dd, yyyy').format(DateTime.parse(appointment['preferred_date']))}\n'
// //                 'Time: ${_formatTime(appointment['preferred_time'])}\n'
// //                 'Owner: $userFullName\n\n'
// //                   'Please update the appointment status.';

// //           // Use the tracking utility to send reminder only if not already sent
// //           await MessageTrackingUtils.sendReminderIfNotSent(
// //             appointment['id'],
// //             appointment['user_id'],
// //             reminderMessage,
// //           );
// //         }
// //       }
// //     } catch (e) {
// //       print('Error checking for reminders: $e');
// //     }
// //   }
// //   @override
// //   void initState() {
// //     super.initState();
// //     if (widget.appointment != null) {
// //       try {
// //         _petNameController.text = widget.appointment!['pet_name']?.toString() ?? '';
// //         _selectedPetType = widget.appointment!['pet_type']?.toString();
// //         if (_selectedPetType == 'Others') {
// //           _petTypeOtherController.text =
// //               widget.appointment!['pet_type_other']?.toString() ?? '';
// //         }
// //         _breedController.text = widget.appointment!['breed']?.toString() ?? '';
// //         _selectedPetSize = widget.appointment!['pet_size']?.toString();
// //         _ageController.text = widget.appointment!['age']?.toString() ?? '';
// //         _selectedGender = widget.appointment!['gender']?.toString();
// //         _allergiesController.text =
// //             widget.appointment!['allergies_medical_conditions']?.toString() ?? '';
// //         _serviceBath = widget.appointment!['service_bath'] ?? false;
// //         _serviceHaircut = widget.appointment!['service_haircut'] ?? false;
// //         _serviceNailTrim = widget.appointment!['service_nail_trim'] ?? false;
// //         _serviceEarCleaning =
// //             widget.appointment!['service_ear_cleaning'] ?? false;
// //         _specialRequestsController.text =
// //             widget.appointment!['special_requests_notes'] ?? '';
// //         _preferredDate = widget.appointment!['preferred_date'] != null
// //             ? DateTime.parse(widget.appointment!['preferred_date'])
// //             : null;
// //         _preferredTime = widget.appointment!['preferred_time'] != null
// //             ? TimeOfDay(
// //                 hour: int.parse(
// //                     widget.appointment!['preferred_time'].split(':')[0]),
// //                 minute: int.parse(
// //                     widget.appointment!['preferred_time'].split(':')[1]))
// //             : null;
// //         _estimatedCost =
// //             (widget.appointment!['estimated_cost'] ?? 0.0).toDouble();
// //         _selectedPaymentMethod = widget.appointment!['payment_method'];
// //         _consentPhotos = widget.appointment!['consent_photos'] ?? false;
// //       } catch (e) {
// //         print('Error pre-filling appointment data: $e');
// //       }
// //     }
// //     _calculateEstimatedCost();
// //   }
// //   @override
// //   void dispose() {
// //     _petNameController.dispose();
// //     _petTypeOtherController.dispose();
// //     _breedController.dispose();
// //     _ageController.dispose();
// //     _allergiesController.dispose();
// //     _specialRequestsController.dispose();
// //     super.dispose();
// //   }
// //   // Build section title
// //   Widget _buildSectionTitle(String title) {
// //     return Padding(
// //       padding: const EdgeInsets.only(bottom: 16),
// //       child: Row(
// //         children: [
// //           Container(
// //             width: 4,
// //             height: 24,
// //             decoration: BoxDecoration(
// //               color: const Color(0xFFF5A623),
// //               borderRadius: BorderRadius.circular(2),
// //             ),
// //           ),
// //           const SizedBox(width: 12),
// //           Text(
// //             title,
// //             style: GoogleFonts.poppins(
// //               fontSize: 20,
// //               fontWeight: FontWeight.w600,
// //               color: const Color(0xFFF5A623),
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// //   // Build input field
// //   Widget _buildInputField({
// //     required TextEditingController controller,
// //     required String label,
// //     int maxLines = 1,
// //     TextInputType? keyboardType,
// //   }) {
// //     return Container(
// //       margin: const EdgeInsets.only(bottom: 16),
// //       child: TextFormField(
// //         controller: controller,
// //         keyboardType: keyboardType,
// //         maxLines: maxLines,
// //         style: GoogleFonts.poppins(),
// //         decoration: InputDecoration(
// //           labelText: label,
// //           labelStyle: GoogleFonts.poppins(color: Colors.grey[600]),
// //           border: OutlineInputBorder(
// //             borderRadius: BorderRadius.circular(12),
// //             borderSide: BorderSide(color: Colors.grey[300]!),
// //           ),
// //           enabledBorder: OutlineInputBorder(
// //             borderRadius: BorderRadius.circular(12),
// //             borderSide: BorderSide(color: Colors.grey[300]!),
// //           ),
// //           focusedBorder: OutlineInputBorder(
// //             borderRadius: BorderRadius.circular(12),
// //             borderSide: const BorderSide(color: Color(0xFFF5A623)),
// //           ),
// //           filled: true,
// //           fillColor: Colors.grey[50],
// //         ),
// //       ),
// //     );
// //   }
// //   // Build dropdown field
// //   Widget _buildDropdownField({
// //     required String label,
// //     required String? value,
// //     required List<String> items,
// //     required Function(String?) onChanged,
// //   }) {
// //     return Container(
// //       margin: const EdgeInsets.only(bottom: 16),
// //       child: DropdownButtonFormField<String>(
// //         value: value,
// //         decoration: InputDecoration(
// //           labelText: label,
// //           labelStyle: GoogleFonts.poppins(color: Colors.grey[600]),
// //           border: OutlineInputBorder(
// //             borderRadius: BorderRadius.circular(12),
// //             borderSide: BorderSide(color: Colors.grey[300]!),
// //           ),
// //           enabledBorder: OutlineInputBorder(
// //             borderRadius: BorderRadius.circular(12),
// //             borderSide: BorderSide(color: Colors.grey[300]!),
// //           ),
// //           focusedBorder: OutlineInputBorder(
// //             borderRadius: BorderRadius.circular(12),
// //             borderSide: const BorderSide(color: Color(0xFFF5A623)),
// //           ),
// //           filled: true,
// //           fillColor: Colors.grey[50],
// //         ),
// //         items: items.map((String item) {
// //           return DropdownMenuItem<String>(
// //             value: item,
// //             child: Text(item, style: GoogleFonts.poppins()),
// //           );
// //         }).toList(),
// //         onChanged: onChanged,
// //       ),
// //     );
// //   }
// //   // Build service checkbox
// //   Widget _buildServiceCheckbox({
// //     required String title,
// //     required String defaultPrice,
// //     required bool value,
// //     required Function(bool?) onChanged,
// //   }) {
// //     String durationText = '';
// //     String dynamicPrice = defaultPrice;
// //     if (_selectedPetSize != null) {
// //       final durations = _serviceDurations[_selectedPetSize]!;
// //       final prices = _servicePrices[_selectedPetSize]!;
// //       switch (title) {
// //         case 'Bath':
// //           durationText = ' (${_formatDuration(durations['bath']!)})';
// //           dynamicPrice = 'P${prices['bath']}';
// //           break;
// //         case 'Haircut':
// //           durationText = ' (${_formatDuration(durations['haircut']!)})';
// //           dynamicPrice = 'P${prices['haircut']}';
// //           break;
// //         case 'Ear Cleaning':
// //           durationText = ' (${_formatDuration(durations['earCleaning']!)})';
// //           dynamicPrice = 'P${prices['earCleaning']}';
// //           break;
// //         case 'Nail Trim':
// //           durationText = ' (${_formatDuration(durations['nailTrim']!)})';
// //           dynamicPrice = 'P${prices['nailTrim']}';
// //           break;
// //       }
// //     }
// //     return Container(
// //       margin: const EdgeInsets.only(bottom: 8),
// //       decoration: BoxDecoration(
// //         color: Colors.grey[50],
// //         borderRadius: BorderRadius.circular(12),
// //         border: Border.all(color: Colors.grey[300]!),
// //       ),
// //       child: CheckboxListTile(
// //         title: Row(
// //           children: [
// //             Expanded(
// //               child: Column(
// //                 crossAxisAlignment: CrossAxisAlignment.start,
// //                 children: [
// //                   Text(title, style: GoogleFonts.poppins()),
// //                   if (_selectedPetSize != null)
// //                     Text(
// //                       durationText,
// //                       style: GoogleFonts.poppins(
// //                         fontSize: 12,
// //                         color: Colors.blue[600],
// //                       ),
// //                     ),
// //                 ],
// //               ),
// //             ),
// //             if (_selectedPetSize != null)
// //               Container(
// //                 padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
// //                 decoration: BoxDecoration(
// //                   color: const Color(0xFFF5A623).withOpacity(0.1),
// //                   borderRadius: BorderRadius.circular(4),
// //                 ),
// //                 child: Text(
// //                   dynamicPrice,
// //                   style: GoogleFonts.poppins(
// //                     color: const Color(0xFFF5A623),
// //                     fontWeight: FontWeight.w500,
// //                   ),
// //                 ),
// //               ),
// //           ],
// //         ),
// //         value: value,
// //         onChanged: onChanged,
// //         controlAffinity: ListTileControlAffinity.leading,
// //         contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
// //         shape: RoundedRectangleBorder(
// //           borderRadius: BorderRadius.circular(12),
// //         ),
// //       ),
// //     );
// //   }
// //   // Build confirmation row
// //   Widget _buildConfirmationRow(String label, String value) {
// //     return Padding(
// //       padding: const EdgeInsets.only(bottom: 8),
// //       child: Row(
// //         crossAxisAlignment: CrossAxisAlignment.start,
// //         children: [
// //           SizedBox(
// //             width: 160,
// //             child: Text(
// //               '$label:',
// //               style: GoogleFonts.poppins(
// //                 fontWeight: FontWeight.w500,
// //                 color: Colors.grey[700],
// //               ),
// //             ),
// //           ),
// //           Expanded(
// //             child: Text(
// //               value,
// //               style: GoogleFonts.poppins(),
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// //   // Build service confirmation rows
// //   List<Widget> _buildServiceConfirmationRows() {
// //     final prices = _servicePrices[_selectedPetSize]!;
// //     final List<Widget> rows = [];
// //     if (_serviceBath) rows.add(_buildConfirmationRow('Bath', 'P${prices['bath']}'));
// //     if (_serviceHaircut) {
// //       rows.add(_buildConfirmationRow('Haircut', 'P${prices['haircut']}'));
// //       if (_haircutExtraOption == 'super_furry') {
// //         rows.add(_buildConfirmationRow('For Super Furry Hair Coat', 'P200'));
// //       }
// //       if (_haircutExtraOption == 'severely_matted') {
// //         rows.add(_buildConfirmationRow('For Severely Matted Fur', 'P300'));
// //       }
// //     }
// //     if (_serviceNailTrim) rows.add(_buildConfirmationRow('Nail Trim', 'P${prices['nailTrim']}'));
// //     if (_serviceEarCleaning) rows.add(_buildConfirmationRow('Ear Cleaning', 'P${prices['earCleaning']}'));
// //     return rows;
// //   }
// //   // Format time
// //   String _formatTime(String time) {
// //     try {
// //       final timeOfDay = TimeOfDay(
// //         hour: int.parse(time.split(':')[0]),
// //         minute: int.parse(time.split(':')[1]),
// //       );
// //       return timeOfDay.format(context);
// //     } catch (e) {
// //       return time;
// //     }
// //   }
// //   // Trigger global refresh
// //   void _triggerGlobalRefresh() {
// //     print('Global refresh triggered - new appointment booked');
// //   }
// //   @override
// //   Widget build(BuildContext context) {
// //     return GestureDetector(
// //       onTap: () {
// //         FocusScope.of(context).unfocus();
// //       },
// //       child: Scaffold(
// //         backgroundColor: Colors.grey[100],
// //         appBar: AppBar(
// //           title: Text(
// //             'Book Appointment',
// //             style: GoogleFonts.poppins(
// //               color: const Color(0xFFF5A623),
// //               fontWeight: FontWeight.w600,
// //             ),
// //           ),
// //           backgroundColor: Colors.white,
// //           elevation: 0,
// //           centerTitle: true,
// //         ),
// //         body: SingleChildScrollView(
// //           child: Padding(
// //             padding: const EdgeInsets.all(16.0),
// //             child: Column(
// //               crossAxisAlignment: CrossAxisAlignment.start,
// //               children: [
// //                 // Pet Information Section
// //                 Card(
// //                   elevation: 0,
// //                   shape: RoundedRectangleBorder(
// //                     borderRadius: BorderRadius.circular(16),
// //                   ),
// //                   child: Padding(
// //                     padding: const EdgeInsets.all(16.0),
// //                     child: Column(
// //                       crossAxisAlignment: CrossAxisAlignment.start,
// //                       children: [
// //                         _buildSectionTitle('Pet Information'),
// //                         _buildInputField(
// //                           controller: _petNameController,
// //                           label: 'Pet Name',
// //                         ),
// //                         _buildDropdownField(
// //                           label: 'Pet Type',
// //                           value: _selectedPetType,
// //                           items: ['Dog', 'Cat', 'Others'],
// //                           onChanged: (String? newValue) {
// //                             setState(() {
// //                               _selectedPetType = newValue;
// //                             });
// //                           },
// //                         ),
// //                         if (_selectedPetType == 'Others')
// //                           _buildInputField(
// //                             controller: _petTypeOtherController,
// //                             label: 'Specify Pet Type',
// //                           ),
// //                         _buildInputField(
// //                           controller: _breedController,
// //                           label: 'Breed',
// //                         ),
// //                         _buildDropdownField(
// //                           label: 'Pet Size',
// //                           value: _selectedPetSize,
// //                           items: ['Small', 'Medium', 'Large'],
// //                           onChanged: (String? newValue) {
// //                             setState(() {
// //                               _selectedPetSize = newValue;
// //                               _calculateEstimatedCost();
// //                             });
// //                           },
// //                         ),
// //                         _buildInputField(
// //                           controller: _ageController,
// //                           label: 'Age',
// //                           keyboardType: TextInputType.number,
// //                         ),
// //                         _buildDropdownField(
// //                           label: 'Gender',
// //                           value: _selectedGender,
// //                           items: ['Male', 'Female'],
// //                           onChanged: (String? newValue) {
// //                             setState(() {
// //                               _selectedGender = newValue;
// //                             });
// //                           },
// //                         ),
// //                         _buildInputField(
// //                           controller: _allergiesController,
// //                           label: 'Allergies / Medical Conditions (Optional)',
// //                           maxLines: 3,
// //                         ),
// //                       ],
// //                     ),
// //                   ),
// //                 ),
// //                 const SizedBox(height: 16),
// //                 // Grooming Services Section
// //                 Card(
// //                   elevation: 0,
// //                   shape: RoundedRectangleBorder(
// //                     borderRadius: BorderRadius.circular(16),
// //                   ),
// //                   child: Padding(
// //                     padding: const EdgeInsets.all(16.0),
// //                     child: Column(
// //                       crossAxisAlignment: CrossAxisAlignment.start,
// //                       children: [
// //                         _buildSectionTitle('Grooming Services'),
// //                         _buildServiceCheckbox(
// //                           title: 'Bath',
// //                           defaultPrice: 'Select pet size',
// //                           value: _serviceBath,
// //                           onChanged: (bool? newValue) {
// //                             setState(() {
// //                               _serviceBath = newValue ?? false;
// //                               _calculateEstimatedCost();
// //                             });
// //                           },
// //                         ),
// //                         _buildServiceCheckbox(
// //                           title: 'Haircut',
// //                           defaultPrice: 'Select pet size',
// //                           value: _serviceHaircut,
// //                           onChanged: (bool? newValue) {
// //                             setState(() {
// //                               _serviceHaircut = newValue ?? false;
// //                               _calculateEstimatedCost();
// //                               if (!_serviceHaircut) {
// //                                 _haircutExtraOption = null;
// //                               }
// //                             });
// //                           },
// //                         ),
// //                         if (_serviceHaircut && _selectedPetSize != null)
// //                           Container(
// //                             margin: const EdgeInsets.only(bottom: 8, left: 8, right: 8),
// //                             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
// //                             decoration: BoxDecoration(
// //                               color: Colors.orange[50],
// //                               borderRadius: BorderRadius.circular(8),
// //                               border: Border.all(color: Colors.orange[200]!),
// //                             ),
// //                             child: Column(
// //                               crossAxisAlignment: CrossAxisAlignment.start,
// //                               children: [
// //                                 Text(
// //                                   'Extra Haircut Options',
// //                                   style: GoogleFonts.poppins(
// //                                     fontSize: 13,
// //                                     fontWeight: FontWeight.w600,
// //                                     color: Colors.orange[800],
// //                                   ),
// //                                 ),
// //                                 const SizedBox(height: 4),
// //                                 DropdownButtonFormField<String>(
// //                                   value: _haircutExtraOption,
// //                                   isExpanded: true,
// //                                   decoration: InputDecoration(
// //                                     contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
// //                                     border: OutlineInputBorder(
// //                                       borderRadius: BorderRadius.circular(8),
// //                                       borderSide: BorderSide(color: Colors.orange[200]!),
// //                                     ),
// //                                     filled: true,
// //                                     fillColor: Colors.white,
// //                                   ),
// //                                   style: GoogleFonts.poppins(fontSize: 12, color: Colors.orange[900]),
// //                                   items: const [
// //                                     DropdownMenuItem(
// //                                       value: null,
// //                                       child: Text('None', style: TextStyle(fontSize: 11)),
// //                                     ),
// //                                     DropdownMenuItem(
// //                                       value: 'super_furry',
// //                                       child: Text('For Super Furry Hair Coat (+₱200, +20 mins)', style: TextStyle(fontSize: 11)),
// //                                     ),
// //                                     DropdownMenuItem(
// //                                       value: 'severely_matted',
// //                                       child: Text('For Severely Matted Fur (+₱300, +30 mins)', style: TextStyle(fontSize: 11)),
// //                                     ),
// //                                   ],
// //                                   onChanged: (String? value) {
// //                                     setState(() {
// //                                       _haircutExtraOption = value;
// //                                       _calculateEstimatedCost();
// //                                     });
// //                                   },
// //                                   hint: Text('Select extra option (if applicable)', style: GoogleFonts.poppins(fontSize: 12)),
// //                                 ),
// //                                 const SizedBox(height: 4),
// //                                 Text(
// //                                   'Note: If your dog has a super furry coat or severely matted fur, please select the appropriate option. Additional charges and grooming time will apply',
// //                                   style: GoogleFonts.poppins(fontSize: 10, color: Colors.orange[800]),
// //                                 ),
// //                               ],
// //                             ),
// //                           ),
// //                         _buildServiceCheckbox(
// //                           title: 'Nail Trim',
// //                           defaultPrice: 'Select pet size',
// //                           value: _serviceNailTrim,
// //                           onChanged: (bool? newValue) {
// //                             setState(() {
// //                               _serviceNailTrim = newValue ?? false;
// //                               _calculateEstimatedCost();
// //                             });
// //                           },
// //                         ),
// //                         _buildServiceCheckbox(
// //                           title: 'Ear Cleaning',
// //                           defaultPrice: 'Select pet size',
// //                           value: _serviceEarCleaning,
// //                           onChanged: (bool? newValue) {
// //                             setState(() {
// //                               _serviceEarCleaning = newValue ?? false;
// //                               _calculateEstimatedCost();
// //                             });
// //                           },
// //                         ),
// //                         if (_selectedPetSize != null) ...[
// //                           const SizedBox(height: 16),
// //                           Container(
// //                             width: double.infinity,
// //                             padding: const EdgeInsets.all(16),
// //                             decoration: BoxDecoration(
// //                               color: const Color(0xFFF5A623).withOpacity(0.1),
// //                               borderRadius: BorderRadius.circular(12),
// //                             ),
// //                             child: Column(
// //                               crossAxisAlignment: CrossAxisAlignment.start,
// //                               children: [
// //                                 Text(
// //                                   'Estimated Duration:',
// //                                   style: GoogleFonts.poppins(
// //                                     fontSize: 16,
// //                                     fontWeight: FontWeight.w500,
// //                                   ),
// //                                 ),
// //                                 const SizedBox(height: 12),
// //                                 Text(
// //                                   _formatDuration(_calculateTotalDuration()),
// //                                   style: GoogleFonts.poppins(
// //                                     fontSize: 18,
// //                                     fontWeight: FontWeight.w600,
// //                                     color: const Color(0xFFF5A623),
// //                                   ),
// //                                 ),
// //                               ],
// //                             ),
// //                           ),
// //                         ],
// //                         const SizedBox(height: 16),
// //                         _buildInputField(
// //                           controller: _specialRequestsController,
// //                           label: 'Special Requests/ Notes (Optional)',
// //                           maxLines: 3,
// //                         ),
// //                       ],
// //                     ),
// //                   ),
// //                 ),
// //                 const SizedBox(height: 16),
// //                 // Appointment Details Section
// //                 Card(
// //                   elevation: 0,
// //                   shape: RoundedRectangleBorder(
// //                     borderRadius: BorderRadius.circular(16),
// //                   ),
// //                   child: Padding(
// //                     padding: const EdgeInsets.all(16.0),
// //                     child: Column(
// //                       crossAxisAlignment: CrossAxisAlignment.start,
// //                       children: [
// //                         _buildSectionTitle('Appointment Details'),
// //                         Container(
// //                           margin: const EdgeInsets.only(bottom: 16),
// //                           decoration: BoxDecoration(
// //                             color: Colors.grey[50],
// //                             borderRadius: BorderRadius.circular(12),
// //                             border: Border.all(color: Colors.grey[300]!),
// //                           ),
// //                           child: ListTile(
// //                             title: Text(
// //                               _preferredDate == null
// //                                   ? 'Select Preferred Date'
// //                                   : 'Date: ${_preferredDate!.toLocal().toString().split(' ')[0]}',
// //                               style: GoogleFonts.poppins(),
// //                             ),
// //                             trailing: const Icon(Icons.calendar_today,
// //                                 color: Color(0xFFF5A623)),
// //                             onTap: () async {
// //                               final DateTime? picked = await showDatePicker(
// //                                 context: context,
// //                                 initialDate: _preferredDate ?? DateTime.now(),
// //                                 firstDate: DateTime.now(),
// //                                 lastDate: DateTime(2101),
// //                               );
// //                               if (picked != null && picked != _preferredDate) {
// //                                 setState(() {
// //                                   _preferredDate = picked;
// //                                   _preferredTime = null;
// //                                 });
// //                                 _showAvailableTimeSlots(context, picked);
// //                               }
// //                             },
// //                           ),
// //                         ),
// //                         Container(
// //                           margin: const EdgeInsets.only(bottom: 16),
// //                           decoration: BoxDecoration(
// //                             color: Colors.grey[50],
// //                             borderRadius: BorderRadius.circular(12),
// //                             border: Border.all(color: Colors.grey[300]!),
// //                           ),
// //                           child: ListTile(
// //                             title: Text(
// //                               _preferredTime == null
// //                                   ? 'Select Preferred Time'
// //                                   : 'Time: ${_preferredTime!.format(context)}',
// //                               style: GoogleFonts.poppins(),
// //                             ),
// //                             trailing: const Icon(Icons.access_time,
// //                                 color: Color(0xFFF5A623)),
// //                             onTap: () async {
// //                               if (_preferredDate == null) {
// //                                 ScaffoldMessenger.of(context).showSnackBar(
// //                                   const SnackBar(
// //                                     content: Text('Please select a date first'),
// //                                     backgroundColor: Colors.red,
// //                                   ),
// //                                 );
// //                                 return;
// //                               }
// //                               _showAvailableTimeSlots(context, _preferredDate!);
// //                             },
// //                           ),
// //                         ),
// //                       ],
// //                     ),
// //                   ),
// //                 ),
// //                 const SizedBox(height: 16),
// //                 // Payment Information Section
// //                 Card(
// //                   elevation: 0,
// //                   shape: RoundedRectangleBorder(
// //                     borderRadius: BorderRadius.circular(16),
// //                   ),
// //                   child: Padding(
// //                     padding: const EdgeInsets.all(16.0),
// //                     child: Column(
// //                       crossAxisAlignment: CrossAxisAlignment.start,
// //                       children: [
// //                         _buildSectionTitle('Payment Information'),
// //                         if (_selectedPetSize != null) ...[
// //                           Container(
// //                             padding: const EdgeInsets.all(16),
// //                             decoration: BoxDecoration(
// //                               color: const Color(0xFFF5A623).withOpacity(0.1),
// //                               borderRadius: BorderRadius.circular(12),
// //                             ),
// //                             child: Row(
// //                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                               children: [
// //                                 Text(
// //                                   'Estimated Cost:',
// //                                   style: GoogleFonts.poppins(
// //                                     fontSize: 16,
// //                                     fontWeight: FontWeight.w500,
// //                                   ),
// //                                 ),
// //                                 Text(
// //                                   'P${_estimatedCost.toStringAsFixed(2)}',
// //                                   style: GoogleFonts.poppins(
// //                                     fontSize: 18,
// //                                     fontWeight: FontWeight.w600,
// //                                     color: const Color(0xFFF5A623),
// //                                   ),
// //                                 ),
// //                               ],
// //                             ),
// //                           ),
// //                           const SizedBox(height: 16),
// //                         ],
// //                         _buildDropdownField(
// //                           label: 'Payment Method',
// //                           value: _selectedPaymentMethod,
// //                           items: ['Cash', 'Gcash'],
// //                           onChanged: (String? newValue) {
// //                             setState(() {
// //                               _selectedPaymentMethod = newValue;
// //                             });
// //                           },
// //                         ),
// //                         if (_selectedPaymentMethod == 'Gcash') ...[
// //                           const SizedBox(height: 16),
// //                           Container(
// //                             padding: const EdgeInsets.all(16),
// //                             decoration: BoxDecoration(
// //                               color: Colors.blue[50],
// //                               borderRadius: BorderRadius.circular(12),
// //                               border: Border.all(color: Colors.blue[200]!),
// //                             ),
// //                             child: Column(
// //                               children: [
// //                                 Text(
// //                                   '0915 548 5814',
// //                                   style: GoogleFonts.poppins(
// //                                     color: Colors.blue[700],
// //                                     fontSize: 14,
// //                                     fontWeight: FontWeight.w500,
// //                                   ),
// //                                   textAlign: TextAlign.center,
// //                                 ),
// //                                 const SizedBox(height: 16),
// //                                 Image.asset(
// //                                   'assets/images/gcash_qr.png',
// //                                   height: 200,
// //                                   width: 200,
// //                                 ),
// //                                 const SizedBox(height: 12),
// //                                 Row(
// //                                   children: [
// //                                     const Icon(Icons.info_outline,
// //                                         color: Colors.blue),
// //                                     const SizedBox(width: 12),
// //                                     Expanded(
// //                                       child: Text(
// //                                         'The payment receipt must be presented to the groomer before the appointment.',
// //                                         style: GoogleFonts.poppins(
// //                                           color: Colors.blue[700],
// //                                           fontSize: 12,
// //                                         ),
// //                                       ),
// //                                     ),
// //                                   ],
// //                                 ),
// //                               ],
// //                             ),
// //                           ),
// //                         ],
// //                         const SizedBox(height: 16),
// //                         Container(
// //                           decoration: BoxDecoration(
// //                             color: Colors.grey[50],
// //                             borderRadius: BorderRadius.circular(12),
// //                             border: Border.all(color: Colors.grey[300]!),
// //                           ),
// //                           child: CheckboxListTile(
// //                             title: Text(
// //                               'I consent to the use of before and after photos of my pet for social media purposes',
// //                               style: GoogleFonts.poppins(fontSize: 14),
// //                             ),
// //                             value: _consentPhotos,
// //                             onChanged: (bool? newValue) {
// //                               setState(() {
// //                                 _consentPhotos = newValue ?? false;
// //                               });
// //                             },
// //                             controlAffinity: ListTileControlAffinity.leading,
// //                             contentPadding:
// //                                 const EdgeInsets.symmetric(horizontal: 16),
// //                           ),
// //                         ),
// //                       ],
// //                     ),
// //                   ),
// //                 ),
// //                 const SizedBox(height: 32),
// //                 SizedBox(
// //                   width: double.infinity,
// //                   child: ElevatedButton(
// //                     onPressed: _isLoading
// //                         ? null
// //                         : () async {
// //                             if (_petNameController.text.isEmpty ||
// //                                 _selectedPetType == null ||
// //                                 (_selectedPetType == 'Others' &&
// //                                     _petTypeOtherController.text.isEmpty) ||
// //                                 _selectedPetSize == null ||
// //                                 _selectedGender == null ||
// //                                 _preferredDate == null ||
// //                                 _preferredTime == null ||
// //                                 _selectedPaymentMethod == null ||
// //                                 _estimatedCost <= 0) {
// //                               ScaffoldMessenger.of(context).showSnackBar(
// //                                 const SnackBar(
// //                                   content: Text(
// //                                       'Please fill in all required fields and select at least one service.'),
// //                                   backgroundColor: Colors.red,
// //                                 ),
// //                               );
// //                               return;
// //                             }
// //                             final currentDuration = _calculateTotalDuration();
// //                             final endTime = TimeOfDay(
// //                               hour: (_preferredTime!.hour * 60 +
// //                                       _preferredTime!.minute +
// //                                       currentDuration) ~/
// //                                   60,
// //                               minute: (_preferredTime!.hour * 60 +
// //                                       _preferredTime!.minute +
// //                                       currentDuration) %
// //                                   60,
// //                             );
// //                             final confirmed = await showDialog<bool>(
// //                               context: context,
// //                               builder: (BuildContext context) {
// //                                 return AlertDialog(
// //                                   title: Text(
// //                                     widget.appointment != null
// //                                         ? 'Confirm Update'
// //                                         : 'Confirm Appointment',
// //                                     style: GoogleFonts.poppins(
// //                                       fontWeight: FontWeight.w600,
// //                                       color: const Color(0xFFF5A623),
// //                                     ),
// //                                   ),
// //                                   content: SingleChildScrollView(
// //                                     child: Column(
// //                                       crossAxisAlignment:
// //                                           CrossAxisAlignment.start,
// //                                       mainAxisSize: MainAxisSize.min,
// //                                       children: [
// //                                         Text(
// //                                           'Please review your appointment details: ',
// //                                           style: GoogleFonts.poppins(
// //                                             fontWeight: FontWeight.w500,
// //                                           ),
// //                                         ),
// //                                         const SizedBox(height: 16),
// //                                         _buildConfirmationRow(
// //                                             'Pet Name', _petNameController.text),
// //                                         _buildConfirmationRow(
// //                                             'Pet Type', _selectedPetType!),
// //                                         if (_selectedPetType == 'Others')
// //                                           _buildConfirmationRow('Other Pet Type',
// //                                               _petTypeOtherController.text),
// //                                         _buildConfirmationRow(
// //                                             'Breed', _breedController.text),
// //                                         _buildConfirmationRow(
// //                                             'Size', _selectedPetSize!),
// //                                         _buildConfirmationRow(
// //                                             'Age', _ageController.text),
// //                                         _buildConfirmationRow(
// //                                             'Gender', _selectedGender!),
// //                                         if (_allergiesController.text.isNotEmpty)
// //                                           _buildConfirmationRow(
// //                                               'Allergies/Medical Conditions',
// //                                               _allergiesController.text),
// //                                         const Divider(),
// //                                         Text(
// //                                           'Selected Services:',
// //                                           style: GoogleFonts.poppins(
// //                                             fontWeight: FontWeight.w500,
// //                                           ),
// //                                         ),
// //                                         if (_selectedPetSize != null) ..._buildServiceConfirmationRows(),
// //                                         const Divider(),
// //                                         _buildConfirmationRow(
// //                                             'Date',
// //                                             _preferredDate!
// //                                                 .toLocal()
// //                                                 .toString()
// //                                                 .split(' ')[0]),
// //                                         _buildConfirmationRow('Time',
// //                                             '${_preferredTime!.format(context)} - ${endTime.format(context)}'),
// //                                         _buildConfirmationRow('Duration',
// //                                             _formatDuration(currentDuration)),
// //                                         _buildConfirmationRow('Total Cost',
// //                                             'P${_estimatedCost.toStringAsFixed(2)}'),
// //                                         _buildConfirmationRow('Payment Method',
// //                                             _selectedPaymentMethod!),
// //                                         const SizedBox(height: 16),
// //                                         Container(
// //                                           padding: const EdgeInsets.all(12),
// //                                           decoration: BoxDecoration(
// //                                             color: Colors.orange[50],
// //                                             borderRadius:
// //                                                 BorderRadius.circular(8),
// //                                             border: Border.all(
// //                                                 color: Colors.orange[200]!),
// //                                           ),
// //                                           child: Row(
// //                                             children: [
// //                                               Icon(Icons.info_outline,
// //                                                   color: Colors.orange[700],
// //                                                   size: 20),
// //                                               const SizedBox(width: 8),
// //                                               Expanded(
// //                                                 child: Text(
// //                                                   'Note: Timely arrival is requested to maintain scheduling efficiency and avoid overlaps with other bookings. We appreciate your understanding and cooperation.',
// //                                                   style: GoogleFonts.poppins(
// //                                                     fontSize: 12,
// //                                                     color: Colors.orange[900],
// //                                                   ),
// //                                                 ),
// //                                               ),
// //                                             ],
// //                                           ),
// //                                         ),
// //                                       ],
// //                                     ),
// //                                   ),
// //                                   actions: [
// //                                     TextButton(
// //                                       onPressed: () =>
// //                                           Navigator.pop(context, false),
// //                                       child: Text(
// //                                         'Cancel',
// //                                         style: GoogleFonts.poppins(
// //                                           color: Colors.grey[600],
// //                                         ),
// //                                       ),
// //                                     ),
// //                                     ElevatedButton(
// //                                       onPressed: () =>
// //                                           Navigator.pop(context, true),
// //                                       style: ElevatedButton.styleFrom(
// //                                         backgroundColor: const Color(0xFFF5A623),
// //                                         foregroundColor: Colors.white,
// //                                       ),
// //                                       child: Text(
// //                                         'Confirm Booking',
// //                                         style: GoogleFonts.poppins(
// //                                           fontWeight: FontWeight.w500,
// //                                         ),
// //                                       ),
// //                                     ),
// //                                   ],
// //                                 );
// //                               },
// //                             );
// //                             if (confirmed != true) return;
// //                             setState(() {
// //                               _isLoading = true;
// //                             });
// //                             try {
// //                               final userId = _supabase.auth.currentUser?.id;
// //                               if (userId == null) {
// //                                 throw Exception('User not logged in');
// //                               }
// //                               final data = {
// //                                 'user_id': userId,
// //                                 'pet_name': _petNameController.text,
// //                                 'pet_type': _selectedPetType,
// //                                 'pet_type_other': _selectedPetType == 'Others'
// //                                     ? _petTypeOtherController.text
// //                                     : null,
// //                                 'breed': _breedController.text,
// //                                 'pet_size': _selectedPetSize,
// //                                 'age': int.tryParse(_ageController.text),
// //                                 'gender': _selectedGender,
// //                                 'allergies_medical_conditions':
// //                                     _allergiesController.text,
// //                                 'service_bath': _serviceBath,
// //                                 'service_haircut': _serviceHaircut,
// //                                 'service_nail_trim': _serviceNailTrim,
// //                                 'service_ear_cleaning': _serviceEarCleaning,
// //                                 'special_requests_notes':
// //                                     _specialRequestsController.text,
// //                                 'preferred_date': _preferredDate!
// //                                     .toIso8601String()
// //                                     .split('T')[0],
// //                                 'preferred_time':
// //                                     '${_preferredTime!.hour.toString().padLeft(2, '0')}:${_preferredTime!.minute.toString().padLeft(2, '0')}',
// //                                 'estimated_cost': _estimatedCost,
// //                                 'payment_method': _selectedPaymentMethod,
// //                                 'consent_photos': _consentPhotos,
// //                                 'estimated_duration': _calculateTotalDuration(),
// //                                 'status': 'Pending',
// //                               };
// //                               if (widget.appointment != null) {
// //                                 await _supabase
// //                                     .from('grooming_appointments')
// //                                     .update(data)
// //                                     .eq('id', widget.appointment!['id']);
// //                               } else {
// //                                 final inserted = await _supabase
// //                                     .from('grooming_appointments')
// //                                     .insert(data)
// //                                     .select()
// //                                     .single();
// //                                 final userProfile = await _supabase
// //                                     .from('users')
// //                                     .select('full_name, contact_number')
// //                                     .eq('id', userId)
// //                                     .single();
// //                                 final services = <String>[];
// //                                 if (_serviceBath) services.add('Bath');
// //                                 if (_serviceHaircut) services.add('Haircut');
// //                                 if (_serviceNailTrim) services.add('Nail Trim');
// //                                 if (_serviceEarCleaning) services.add('Ear Cleaning');
// //                                 final petType = _selectedPetType == 'Others' ? _petTypeOtherController.text : _selectedPetType;
// //                                 final dateFormatted = '${_preferredDate!.month.toString().padLeft(2, '0')}-${_preferredDate!.day.toString().padLeft(2, '0')}-${_preferredDate!.year}';
// //                                 final message =
// //                                     'New grooming appointment booked by ${userProfile['full_name']} (${userProfile['contact_number']}):\n'
// //                                     'Pet: ${_petNameController.text}\n'
// //                                     'Type: $petType\n'
// //                                     'Breed: ${_breedController.text}\n'
// //                                     'Size: $_selectedPetSize\n'
// //                                     'Age: ${_ageController.text}\n'
// //                                     'Gender: $_selectedGender\n\n'
// //                                     'Services: ${services.join(', ')}\n'
// //                                     'Date: $dateFormatted\n'
// //                                     'Time: ${_preferredTime!.format(context)}\n'
// //                                     'Payment Method: $_selectedPaymentMethod\n'
// //                                     'Cost: ₱${_estimatedCost.toStringAsFixed(2)}';
// //                                 await _supabase
// //                                     .from('admin_messages')
// //                                     .insert({
// //                                   'user_id': userId,
// //                                   'appointment_id': inserted['id'],
// //                                   'message': message,
// //                                 });
// //                                 await _supabase.from('user_messages').insert({
// //                                   'user_id': userId,
// //                                   'appointment_id': inserted['id'],
// //                                   'message': message,
// //                                   'is_from_admin': false,
// //                                   'is_read': false,
// //                                 });
// //                               }
// //                               if (mounted) {
// //                                 ScaffoldMessenger.of(context).showSnackBar(
// //                                   SnackBar(
// //                                     content: Text(widget.appointment != null
// //                                         ? 'Appointment updated successfully!'
// //                                         : 'Appointment booked successfully!'),
// //                                     backgroundColor: Colors.green,
// //                                     duration: const Duration(seconds: 3),
// //                                   ),
// //                                 );
// //                                 Navigator.pushNamedAndRemoveUntil(
// //                                   context,
// //                                   '/home',
// //                                   (route) => false
// //                                 );
// //                                 _triggerGlobalRefresh();
// //                               }
// //                             } catch (error) {
// //                               if (mounted) {
// //                                 ScaffoldMessenger.of(context).showSnackBar(
// //                                   SnackBar(
// //                                     content: Text(widget.appointment != null
// //                                         ? 'Error updating appointment: ${error.toString()}'
// //                                         : 'Error booking appointment: ${error.toString()}'),
// //                                     backgroundColor: Colors.red,
// //                                   ),
// //                                 );
// //                               }
// //                             } finally {
// //                               if (mounted) {
// //                                 setState(() {
// //                                   _isLoading = false;
// //                                 });
// //                               }
// //                             }
// //                           },
// //                     style: ElevatedButton.styleFrom(
// //                       backgroundColor: const Color(0xFFF5A623),
// //                       foregroundColor: Colors.white,
// //                       shape: RoundedRectangleBorder(
// //                         borderRadius: BorderRadius.circular(12),
// //                       ),
// //                       padding: const EdgeInsets.symmetric(vertical: 16),
// //                       elevation: 0,
// //                     ),
// //                     child: _isLoading
// //                         ? const SizedBox(
// //                             width: 24,
// //                             height: 24,
// //                             child: CircularProgressIndicator(
// //                               color: Colors.white,
// //                               strokeWidth: 2,
// //                             ),
// //                           )
// //                         : Text(
// //                             widget.appointment != null
// //                                 ? 'Update Appointment'
// //                                 : 'Book Appointment',
// //                             style: GoogleFonts.poppins(
// //                               fontSize: 16,
// //                               fontWeight: FontWeight.w600,
// //                             ),
// //                           ),
// //                   ),
// //                 ),
// //                 const SizedBox(height: 16),
// //               ],
// //             ),
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }

// // ----

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import '../config/supabase_config.dart';
import '../utils/message_tracking_utils.dart';

class ServiceDuration {
  final int bath;
  final int haircut;
  final int earCleaning;
  final int nailTrim;

  const ServiceDuration({
    required this.bath,
    required this.haircut,
    required this.earCleaning,
    required this.nailTrim,
  });

  int getTotalDuration(
    bool hasBath,
    bool hasHaircut,
    bool hasEarCleaning,
    bool hasNailTrim,
  ) {
    int total = 0;
    if (hasBath) total += bath;
    if (hasHaircut) total += haircut;
    if (hasEarCleaning) total += earCleaning;
    if (hasNailTrim) total += nailTrim;
    return total;
  }

  String formatDuration(int minutes) {
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

class GroomingAppointmentPage extends StatefulWidget {
  final Map<String, dynamic>? appointment;

  const GroomingAppointmentPage({super.key, this.appointment});

  @override
  State<GroomingAppointmentPage> createState() =>
      _GroomingAppointmentPageState();
}

class _GroomingAppointmentPageState extends State<GroomingAppointmentPage> {
  final _supabase = Supabase.instance.client;
  bool _isLoading = false;

  // Service durations and prices
  final Map<String, Map<String, int>> _serviceDurations = {
    'Small': {
      'bath': 30,
      'haircut': 40,
      'earCleaning': 10,
      'nailTrim': 10,
    },
    'Medium': {
      'bath': 40,
      'haircut': 60,
      'earCleaning': 10,
      'nailTrim': 10,
    },
    'Large': {
      'bath': 50,
      'haircut': 80,
      'earCleaning': 10,
      'nailTrim': 10,
    },
  };

  final Map<String, Map<String, int>> _servicePrices = {
    'Small': {
      'bath': 300,
      'haircut': 400,
      'nailTrim': 100,
      'earCleaning': 100,
    },
    'Medium': {
      'bath': 400,
      'haircut': 500,
      'nailTrim': 110,
      'earCleaning': 110,
    },
    'Large': {
      'bath': 500,
      'haircut': 600,
      'nailTrim': 120,
      'earCleaning': 120,
    },
  };

  // Controllers and state variables
  final _petNameController = TextEditingController();
  String? _selectedPetType;
  final _petTypeOtherController = TextEditingController();
  final _breedController = TextEditingController();
  String? _selectedPetSize;
  final _ageController = TextEditingController();
  String? _selectedGender;
  final _allergiesController = TextEditingController();

  bool _serviceBath = false;
  bool _serviceHaircut = false;
  bool _serviceNailTrim = false;
  bool _serviceEarCleaning = false;
  final _specialRequestsController = TextEditingController();
  String? _haircutExtraOption;

  DateTime? _preferredDate;
  TimeOfDay? _preferredTime;

  double _estimatedCost = 0.0;
  String? _selectedPaymentMethod;
  bool _consentPhotos = false;

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  void _initializeForm() {
    if (widget.appointment != null) {
      try {
        _petNameController.text =
            widget.appointment!['pet_name']?.toString() ?? '';
        _selectedPetType = widget.appointment!['pet_type']?.toString();
        if (_selectedPetType == 'Others') {
          _petTypeOtherController.text =
              widget.appointment!['pet_type_other']?.toString() ?? '';
        }
        _breedController.text = widget.appointment!['breed']?.toString() ?? '';
        _selectedPetSize = widget.appointment!['pet_size']?.toString();
        _ageController.text = widget.appointment!['age']?.toString() ?? '';
        _selectedGender = widget.appointment!['gender']?.toString();
        _allergiesController.text =
            widget.appointment!['allergies_medical_conditions']?.toString() ??
                '';
        _serviceBath = widget.appointment!['service_bath'] ?? false;
        _serviceHaircut = widget.appointment!['service_haircut'] ?? false;
        _serviceNailTrim = widget.appointment!['service_nail_trim'] ?? false;
        _serviceEarCleaning =
            widget.appointment!['service_ear_cleaning'] ?? false;
        _specialRequestsController.text =
            widget.appointment!['special_requests_notes'] ?? '';
        _preferredDate = widget.appointment!['preferred_date'] != null
            ? DateTime.parse(widget.appointment!['preferred_date'])
            : null;
        _preferredTime = widget.appointment!['preferred_time'] != null
            ? TimeOfDay(
                hour: int.parse(
                    widget.appointment!['preferred_time'].split(':')[0]),
                minute: int.parse(
                    widget.appointment!['preferred_time'].split(':')[1]),
              )
            : null;
        _estimatedCost =
            (widget.appointment!['estimated_cost'] ?? 0.0).toDouble();
        _selectedPaymentMethod = widget.appointment!['payment_method'];
        _consentPhotos = widget.appointment!['consent_photos'] ?? false;
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading appointment data: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
    _calculateEstimatedCost();
  }

  @override
  void dispose() {
    _petNameController.dispose();
    _petTypeOtherController.dispose();
    _breedController.dispose();
    _ageController.dispose();
    _allergiesController.dispose();
    _specialRequestsController.dispose();
    super.dispose();
  }

  // Helper methods
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

  int _calculateTotalDuration() {
    if (_selectedPetSize == null) return 0;
    final durations = _serviceDurations[_selectedPetSize]!;
    int total = 0;
    if (_serviceBath) total += durations['bath']!;
    if (_serviceHaircut) total += durations['haircut']!;
    if (_serviceEarCleaning) total += durations['earCleaning']!;
    if (_serviceNailTrim) total += durations['nailTrim']!;
    if (_serviceHaircut) {
      if (_haircutExtraOption == 'super_furry') {
        total += 20;
      } else if (_haircutExtraOption == 'severely_matted') {
        total += 30;
      }
    }
    return total;
  }

  void _calculateEstimatedCost() {
    _estimatedCost = 0.0;
    if (_selectedPetSize != null) {
      final prices = _servicePrices[_selectedPetSize]!;
      if (_serviceBath) _estimatedCost += prices['bath']!;
      if (_serviceHaircut) _estimatedCost += prices['haircut']!;
      if (_serviceNailTrim) _estimatedCost += prices['nailTrim']!;
      if (_serviceEarCleaning) _estimatedCost += prices['earCleaning']!;
      if (_serviceHaircut) {
        if (_haircutExtraOption == 'super_furry') {
          _estimatedCost += 200.0;
        } else if (_haircutExtraOption == 'severely_matted') {
          _estimatedCost += 300.0;
        }
      } else {
        _haircutExtraOption = null;
      }
    }
    setState(() {});
  }

  Future<List<TimeOfDay>> _getAvailableTimeSlots(DateTime date) async {
    try {
      final formattedDate = date.toIso8601String().split('T')[0];
      final response = await _supabase
          .from('grooming_appointments')
          .select('preferred_time, estimated_duration, status')
          .eq('preferred_date', formattedDate)
          .not('status', 'in', ['Cancelled', 'Cancelled (by user)']);

      final bookedRanges = response.map((appointment) {
        final parts = appointment['preferred_time'].split(':');
        final startTime =
            TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
        final duration = appointment['estimated_duration'] as int;
        final totalMinutes =
            startTime.hour * 60 + startTime.minute + duration + 10;
        final endHour = totalMinutes ~/ 60;
        final endMinute = totalMinutes % 60;
        final endTime = TimeOfDay(hour: endHour, minute: endMinute);
        return [startTime, endTime];
      }).toList();

      final allTimeSlots = <TimeOfDay>[];
      for (int hour = 9; hour < 12; hour++) {
        for (int minute = 0; minute < 60; minute += 10) {
          allTimeSlots.add(TimeOfDay(hour: hour, minute: minute));
        }
      }
      for (int hour = 13; hour < 17; hour++) {
        for (int minute = 0; minute < 60; minute += 10) {
          allTimeSlots.add(TimeOfDay(hour: hour, minute: minute));
        }
      }

      final currentDuration = _calculateTotalDuration();
      return allTimeSlots.where((slot) {
        final slotTotalMinutes =
            slot.hour * 60 + slot.minute + currentDuration + 10;
        final slotEndHour = slotTotalMinutes ~/ 60;
        final slotEndMinute = slotTotalMinutes % 60;
        final slotEndTime = TimeOfDay(hour: slotEndHour, minute: slotEndMinute);
        final slotStartMinutes = slot.hour * 60 + slot.minute;
        final slotEndMinutes = slotEndHour * 60 + slotEndMinute;

        if (slotStartMinutes < 12 * 60 && slotEndMinutes > 12 * 60)
          return false;
        if (slotStartMinutes < 13 * 60 &&
            slotEndMinutes > 13 * 60 &&
            slotStartMinutes >= 12 * 60) return false;
        if (slotEndMinutes > 17 * 60) return false;

        for (var range in bookedRanges) {
          final existingStart = range[0] as TimeOfDay;
          final existingEnd = range[1] as TimeOfDay;
          final existingStartMinutes =
              existingStart.hour * 60 + existingStart.minute;
          final existingEndMinutes = existingEnd.hour * 60 + existingEnd.minute;
          if (slotStartMinutes < existingEndMinutes &&
              slotEndMinutes > existingStartMinutes) {
            return false;
          }
        }
        return true;
      }).toList();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error fetching time slots: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
      return [];
    }
  }

  Future<void> _showAvailableTimeSlots(
      BuildContext context, DateTime date) async {
    final availableSlots = await _getAvailableTimeSlots(date);
    if (availableSlots.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'No available time slots for this date. Please select another date.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (!mounted) return;

    final currentDuration = _calculateTotalDuration();
    final durationText = _formatDuration(currentDuration);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Available Time Slots',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              color: const Color(0xFFF5A623),
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Service Duration: $durationText',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 16),
                ...availableSlots.map((time) {
                  final endTime = TimeOfDay(
                    hour:
                        (time.hour * 60 + time.minute + currentDuration) ~/ 60,
                    minute:
                        (time.hour * 60 + time.minute + currentDuration) % 60,
                  );
                  return ListTile(
                    title: Text(
                      '${time.format(context)} - ${endTime.format(context)}',
                      style: GoogleFonts.poppins(),
                    ),
                    onTap: () {
                      setState(() {
                        _preferredTime = time;
                      });
                      Navigator.pop(context);
                    },
                  );
                }).toList(),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: GoogleFonts.poppins(
                  color: Colors.grey[600],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _checkAndSendReminders() async {
    try {
      final now = DateTime.now();
      final response = await _supabase
          .from('grooming_appointments')
          .select(
              'id, user_id, pet_name, preferred_date, preferred_time, status')
          .eq('status', 'Pending');

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
        final reminderTime =
            appointmentDateTime.subtract(const Duration(hours: 24));

        if (now.isBefore(appointmentDateTime) && now.isAfter(reminderTime)) {
          final userResponse = await _supabase
              .from('users')
              .select('full_name')
              .eq('id', appointment['user_id'])
              .maybeSingle();
          final userFullName = userResponse != null
              ? userResponse['full_name'] ?? 'Unknown'
              : 'Unknown';
          final reminderMessage =
              'REMINDER: Appointment approaching - Status still PENDING\n\n'
              'Pet: ${appointment['pet_name']}\n'
              'Date: ${DateFormat('MMMM dd, yyyy').format(appointmentDate)}\n'
              'Time: $appointmentTime\n'
              'Owner: $userFullName\n\n'
              'Please update the appointment status.';

          await MessageTrackingUtils.sendReminderIfNotSent(
            appointment['id'],
            appointment['user_id'],
            reminderMessage,
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error sending reminders: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _refreshData() async {
    await Future.delayed(const Duration(seconds: 1));
    if (widget.appointment != null) {
      _initializeForm();
    }
    await _checkAndSendReminders();
  }

  // UI Builders
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 24,
            decoration: BoxDecoration(
              color: const Color(0xFFF5A623),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: const Color(0xFFF5A623),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        style: GoogleFonts.poppins(),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.poppins(color: Colors.grey[600]),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFF5A623)),
          ),
          filled: true,
          fillColor: Colors.grey[50],
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.poppins(color: Colors.grey[600]),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFF5A623)),
          ),
          filled: true,
          fillColor: Colors.grey[50],
        ),
        items: items.map((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item, style: GoogleFonts.poppins()),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildServiceCheckbox({
    required String title,
    required String defaultPrice,
    required bool value,
    required Function(bool?) onChanged,
  }) {
    String durationText = '';
    String dynamicPrice = defaultPrice;
    if (_selectedPetSize != null) {
      final durations = _serviceDurations[_selectedPetSize]!;
      final prices = _servicePrices[_selectedPetSize]!;
      switch (title) {
        case 'Bath':
          durationText = ' (${_formatDuration(durations['bath']!)})';
          dynamicPrice = 'P${prices['bath']}';
          break;
        case 'Haircut':
          durationText = ' (${_formatDuration(durations['haircut']!)})';
          dynamicPrice = 'P${prices['haircut']}';
          break;
        case 'Ear Cleaning':
          durationText = ' (${_formatDuration(durations['earCleaning']!)})';
          dynamicPrice = 'P${prices['earCleaning']}';
          break;
        case 'Nail Trim':
          durationText = ' (${_formatDuration(durations['nailTrim']!)})';
          dynamicPrice = 'P${prices['nailTrim']}';
          break;
      }
    }
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: CheckboxListTile(
        title: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: GoogleFonts.poppins()),
                  if (_selectedPetSize != null)
                    Text(
                      durationText,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.blue[600],
                      ),
                    ),
                ],
              ),
            ),
            if (_selectedPetSize != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5A623).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  dynamicPrice,
                  style: GoogleFonts.poppins(
                    color: const Color(0xFFF5A623),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
        value: value,
        onChanged: onChanged,
        controlAffinity: ListTileControlAffinity.leading,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildConfirmationRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 160,
            child: Text(
              '$label:',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildServiceConfirmationRows() {
    final prices = _servicePrices[_selectedPetSize]!;
    final List<Widget> rows = [];
    if (_serviceBath)
      rows.add(_buildConfirmationRow('Bath', 'P${prices['bath']}'));
    if (_serviceHaircut) {
      rows.add(_buildConfirmationRow('Haircut', 'P${prices['haircut']}'));
      if (_haircutExtraOption == 'super_furry') {
        rows.add(_buildConfirmationRow('For Super Furry Hair Coat', 'P200'));
      }
      if (_haircutExtraOption == 'severely_matted') {
        rows.add(_buildConfirmationRow('For Severely Matted Fur', 'P300'));
      }
    }
    if (_serviceNailTrim)
      rows.add(_buildConfirmationRow('Nail Trim', 'P${prices['nailTrim']}'));
    if (_serviceEarCleaning)
      rows.add(
          _buildConfirmationRow('Ear Cleaning', 'P${prices['earCleaning']}'));
    return rows;
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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          title: Text(
            'Book Appointment',
            style: GoogleFonts.poppins(
              color: const Color(0xFFF5A623),
              fontWeight: FontWeight.w600,
            ),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),
        body: RefreshIndicator(
          onRefresh: _refreshData,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Pet Information Section
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionTitle('Pet Information'),
                          _buildInputField(
                            controller: _petNameController,
                            label: 'Pet Name',
                          ),
                          _buildDropdownField(
                            label: 'Pet Type',
                            value: _selectedPetType,
                            items: ['Dog', 'Cat', 'Others'],
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedPetType = newValue;
                              });
                            },
                          ),
                          if (_selectedPetType == 'Others')
                            _buildInputField(
                              controller: _petTypeOtherController,
                              label: 'Specify Pet Type',
                            ),
                          _buildInputField(
                            controller: _breedController,
                            label: 'Breed',
                          ),
                          _buildDropdownField(
                            label: 'Pet Size',
                            value: _selectedPetSize,
                            items: ['Small', 'Medium', 'Large'],
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedPetSize = newValue;
                                _calculateEstimatedCost();
                              });
                            },
                          ),
                          _buildInputField(
                            controller: _ageController,
                            label: 'Age',
                            keyboardType: TextInputType.number,
                          ),
                          _buildDropdownField(
                            label: 'Gender',
                            value: _selectedGender,
                            items: ['Male', 'Female'],
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedGender = newValue;
                              });
                            },
                          ),
                          _buildInputField(
                            controller: _allergiesController,
                            label: 'Allergies / Medical Conditions (Optional)',
                            maxLines: 3,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Grooming Services Section
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionTitle('Grooming Services'),
                          _buildServiceCheckbox(
                            title: 'Bath',
                            defaultPrice: 'Select pet size',
                            value: _serviceBath,
                            onChanged: (bool? newValue) {
                              setState(() {
                                _serviceBath = newValue ?? false;
                                _calculateEstimatedCost();
                              });
                            },
                          ),
                          _buildServiceCheckbox(
                            title: 'Haircut',
                            defaultPrice: 'Select pet size',
                            value: _serviceHaircut,
                            onChanged: (bool? newValue) {
                              setState(() {
                                _serviceHaircut = newValue ?? false;
                                _calculateEstimatedCost();
                                if (!_serviceHaircut) {
                                  _haircutExtraOption = null;
                                }
                              });
                            },
                          ),
                          if (_serviceHaircut && _selectedPetSize != null)
                            Container(
                              margin: const EdgeInsets.only(
                                  bottom: 8, left: 8, right: 8),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.orange[50],
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.orange[200]!),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Extra Haircut Options',
                                    style: GoogleFonts.poppins(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.orange[800],
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  DropdownButtonFormField<String>(
                                    value: _haircutExtraOption,
                                    isExpanded: true,
                                    decoration: InputDecoration(
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 8),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(
                                            color: Colors.orange[200]!),
                                      ),
                                      filled: true,
                                      fillColor: Colors.white,
                                    ),
                                    style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        color: Colors.orange[900]),
                                    items: const [
                                      DropdownMenuItem(
                                        value: null,
                                        child: Text('None',
                                            style: TextStyle(fontSize: 11)),
                                      ),
                                      DropdownMenuItem(
                                        value: 'super_furry',
                                        child: Text(
                                            'For Super Furry Hair Coat (+₱200, +20 mins)',
                                            style: TextStyle(fontSize: 11)),
                                      ),
                                      DropdownMenuItem(
                                        value: 'severely_matted',
                                        child: Text(
                                            'For Severely Matted Fur (+₱300, +30 mins)',
                                            style: TextStyle(fontSize: 11)),
                                      ),
                                    ],
                                    onChanged: (String? value) {
                                      setState(() {
                                        _haircutExtraOption = value;
                                        _calculateEstimatedCost();
                                      });
                                    },
                                    hint: Text(
                                        'Select extra option (if applicable)',
                                        style:
                                            GoogleFonts.poppins(fontSize: 12)),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Note: If your dog has a super furry coat or severely matted fur, please select the appropriate option. Additional charges and grooming time will apply',
                                    style: GoogleFonts.poppins(
                                        fontSize: 10,
                                        color: Colors.orange[800]),
                                  ),
                                ],
                              ),
                            ),
                          _buildServiceCheckbox(
                            title: 'Nail Trim',
                            defaultPrice: 'Select pet size',
                            value: _serviceNailTrim,
                            onChanged: (bool? newValue) {
                              setState(() {
                                _serviceNailTrim = newValue ?? false;
                                _calculateEstimatedCost();
                              });
                            },
                          ),
                          _buildServiceCheckbox(
                            title: 'Ear Cleaning',
                            defaultPrice: 'Select pet size',
                            value: _serviceEarCleaning,
                            onChanged: (bool? newValue) {
                              setState(() {
                                _serviceEarCleaning = newValue ?? false;
                                _calculateEstimatedCost();
                              });
                            },
                          ),
                          if (_selectedPetSize != null) ...[
                            const SizedBox(height: 16),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF5A623).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Estimated Duration:',
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    _formatDuration(_calculateTotalDuration()),
                                    style: GoogleFonts.poppins(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFFF5A623),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          const SizedBox(height: 16),
                          _buildInputField(
                            controller: _specialRequestsController,
                            label: 'Special Requests/ Notes (Optional)',
                            maxLines: 3,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Appointment Details Section
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionTitle('Appointment Details'),
                          Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: ListTile(
                              title: Text(
                                _preferredDate == null
                                    ? 'Select Preferred Date'
                                    : 'Date: ${_preferredDate!.toLocal().toString().split(' ')[0]}',
                                style: GoogleFonts.poppins(),
                              ),
                              trailing: const Icon(Icons.calendar_today,
                                  color: Color(0xFFF5A623)),
                              onTap: () async {
                                final DateTime? picked = await showDatePicker(
                                  context: context,
                                  initialDate: _preferredDate ?? DateTime.now(),
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime(2101),
                                );
                                if (picked != null &&
                                    picked != _preferredDate) {
                                  setState(() {
                                    _preferredDate = picked;
                                    _preferredTime = null;
                                  });
                                  _showAvailableTimeSlots(context, picked);
                                }
                              },
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: ListTile(
                              title: Text(
                                _preferredTime == null
                                    ? 'Select Preferred Time'
                                    : 'Time: ${_preferredTime!.format(context)}',
                                style: GoogleFonts.poppins(),
                              ),
                              trailing: const Icon(Icons.access_time,
                                  color: Color(0xFFF5A623)),
                              onTap: () async {
                                if (_preferredDate == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content:
                                          Text('Please select a date first'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                  return;
                                }
                                _showAvailableTimeSlots(
                                    context, _preferredDate!);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Payment Information Section
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionTitle('Payment Information'),
                          if (_selectedPetSize != null) ...[
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF5A623).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Estimated Cost:',
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    'P${_estimatedCost.toStringAsFixed(2)}',
                                    style: GoogleFonts.poppins(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFFF5A623),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                          _buildDropdownField(
                            label: 'Payment Method',
                            value: _selectedPaymentMethod,
                            items: ['Cash', 'Gcash'],
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedPaymentMethod = newValue;
                              });
                            },
                          ),
                          if (_selectedPaymentMethod == 'Gcash') ...[
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.blue[50],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.blue[200]!),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    '0915 548 5814',
                                    style: GoogleFonts.poppins(
                                      color: Colors.blue[700],
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 16),
                                  Image.asset(
                                    'assets/images/gcash_qr.png',
                                    height: 200,
                                    width: 200,
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      const Icon(Icons.info_outline,
                                          color: Colors.blue),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          'The payment receipt must be presented to the groomer before the appointment.',
                                          style: GoogleFonts.poppins(
                                            color: Colors.blue[700],
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                          const SizedBox(height: 16),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: CheckboxListTile(
                              title: Text(
                                'I consent to the use of before and after photos of my pet for social media purposes',
                                style: GoogleFonts.poppins(fontSize: 14),
                              ),
                              value: _consentPhotos,
                              onChanged: (bool? newValue) {
                                setState(() {
                                  _consentPhotos = newValue ?? false;
                                });
                              },
                              controlAffinity: ListTileControlAffinity.leading,
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading
                          ? null
                          : () async {
                              if (_petNameController.text.isEmpty ||
                                  _selectedPetType == null ||
                                  (_selectedPetType == 'Others' &&
                                      _petTypeOtherController.text.isEmpty) ||
                                  _selectedPetSize == null ||
                                  _selectedGender == null ||
                                  _preferredDate == null ||
                                  _preferredTime == null ||
                                  _selectedPaymentMethod == null ||
                                  _estimatedCost <= 0) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        'Please fill in all required fields and select at least one service.'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                                return;
                              }

                              final currentDuration = _calculateTotalDuration();
                              final endTime = TimeOfDay(
                                hour: (_preferredTime!.hour * 60 +
                                        _preferredTime!.minute +
                                        currentDuration) ~/
                                    60,
                                minute: (_preferredTime!.hour * 60 +
                                        _preferredTime!.minute +
                                        currentDuration) %
                                    60,
                              );

                              final confirmed = await showDialog<bool>(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text(
                                      widget.appointment != null
                                          ? 'Confirm Update'
                                          : 'Confirm Appointment',
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFFF5A623),
                                      ),
                                    ),
                                    content: SingleChildScrollView(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            'Please review your appointment details: ',
                                            style: GoogleFonts.poppins(
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          const SizedBox(height: 16),
                                          _buildConfirmationRow('Pet Name',
                                              _petNameController.text),
                                          _buildConfirmationRow(
                                              'Pet Type', _selectedPetType!),
                                          if (_selectedPetType == 'Others')
                                            _buildConfirmationRow(
                                                'Other Pet Type',
                                                _petTypeOtherController.text),
                                          _buildConfirmationRow(
                                              'Breed', _breedController.text),
                                          _buildConfirmationRow(
                                              'Size', _selectedPetSize!),
                                          _buildConfirmationRow(
                                              'Age', _ageController.text),
                                          _buildConfirmationRow(
                                              'Gender', _selectedGender!),
                                          if (_allergiesController
                                              .text.isNotEmpty)
                                            _buildConfirmationRow(
                                                'Allergies/Medical Conditions',
                                                _allergiesController.text),
                                          const Divider(),
                                          Text(
                                            'Selected Services:',
                                            style: GoogleFonts.poppins(
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          if (_selectedPetSize != null)
                                            ..._buildServiceConfirmationRows(),
                                          const Divider(),
                                          _buildConfirmationRow(
                                            'Date',
                                            _preferredDate!
                                                .toLocal()
                                                .toString()
                                                .split(' ')[0],
                                          ),
                                          _buildConfirmationRow(
                                            'Time',
                                            '${_preferredTime!.format(context)} - ${endTime.format(context)}',
                                          ),
                                          _buildConfirmationRow(
                                            'Duration',
                                            _formatDuration(currentDuration),
                                          ),
                                          _buildConfirmationRow(
                                            'Total Cost',
                                            'P${_estimatedCost.toStringAsFixed(2)}',
                                          ),
                                          _buildConfirmationRow(
                                            'Payment Method',
                                            _selectedPaymentMethod!,
                                          ),
                                          const SizedBox(height: 16),
                                          Container(
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color: Colors.orange[50],
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              border: Border.all(
                                                  color: Colors.orange[200]!),
                                            ),
                                            child: Row(
                                              children: [
                                                Icon(Icons.info_outline,
                                                    color: Colors.orange[700],
                                                    size: 20),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                  child: Text(
                                                    'Note: Timely arrival is requested to maintain scheduling efficiency and avoid overlaps with other bookings. We appreciate your understanding and cooperation.',
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 12,
                                                      color: Colors.orange[900],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, false),
                                        child: Text(
                                          'Cancel',
                                          style: GoogleFonts.poppins(
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ),
                                      ElevatedButton(
                                        onPressed: () =>
                                            Navigator.pop(context, true),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              const Color(0xFFF5A623),
                                          foregroundColor: Colors.white,
                                        ),
                                        child: Text(
                                          'Confirm Booking',
                                          style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              );

                              if (confirmed != true) return;

                              setState(() => _isLoading = true);

                              try {
                                final userId = _supabase.auth.currentUser?.id;
                                if (userId == null) {
                                  throw Exception('User not logged in');
                                }

                                final data = {
                                  'user_id': userId,
                                  'pet_name': _petNameController.text,
                                  'pet_type': _selectedPetType,
                                  'pet_type_other': _selectedPetType == 'Others'
                                      ? _petTypeOtherController.text
                                      : null,
                                  'breed': _breedController.text,
                                  'pet_size': _selectedPetSize,
                                  'age': int.tryParse(_ageController.text),
                                  'gender': _selectedGender,
                                  'allergies_medical_conditions':
                                      _allergiesController.text,
                                  'service_bath': _serviceBath,
                                  'service_haircut': _serviceHaircut,
                                  'service_nail_trim': _serviceNailTrim,
                                  'service_ear_cleaning': _serviceEarCleaning,
                                  'special_requests_notes':
                                      _specialRequestsController.text,
                                  'preferred_date': _preferredDate!
                                      .toIso8601String()
                                      .split('T')[0],
                                  'preferred_time':
                                      '${_preferredTime!.hour.toString().padLeft(2, '0')}:${_preferredTime!.minute.toString().padLeft(2, '0')}',
                                  'estimated_cost': _estimatedCost,
                                  'payment_method': _selectedPaymentMethod,
                                  'consent_photos': _consentPhotos,
                                  'estimated_duration':
                                      _calculateTotalDuration(),
                                  'status': 'Pending',
                                };

                                if (widget.appointment != null) {
                                  await _supabase
                                      .from('grooming_appointments')
                                      .update(data)
                                      .eq('id', widget.appointment!['id']);
                                } else {
                                  final inserted = await _supabase
                                      .from('grooming_appointments')
                                      .insert(data)
                                      .select()
                                      .single();
                                  final userProfile = await _supabase
                                      .from('users')
                                      .select('full_name, contact_number')
                                      .eq('id', userId)
                                      .single();
                                  final services = <String>[];
                                  if (_serviceBath) services.add('Bath');
                                  if (_serviceHaircut) services.add('Haircut');
                                  if (_serviceNailTrim)
                                    services.add('Nail Trim');
                                  if (_serviceEarCleaning)
                                    services.add('Ear Cleaning');
                                  final petType = _selectedPetType == 'Others'
                                      ? _petTypeOtherController.text
                                      : _selectedPetType;
                                  final dateFormatted =
                                      '${_preferredDate!.month.toString().padLeft(2, '0')}-${_preferredDate!.day.toString().padLeft(2, '0')}-${_preferredDate!.year}';
                                  final message =
                                      'New grooming appointment booked by ${userProfile['full_name']} (${userProfile['contact_number']}):\n'
                                      'Pet: ${_petNameController.text}\n'
                                      'Type: $petType\n'
                                      'Breed: ${_breedController.text}\n'
                                      'Size: $_selectedPetSize\n'
                                      'Age: ${_ageController.text}\n'
                                      'Gender: $_selectedGender\n\n'
                                      'Services: ${services.join(', ')}\n'
                                      'Date: $dateFormatted\n'
                                      'Time: ${_preferredTime!.format(context)}\n'
                                      'Payment Method: $_selectedPaymentMethod\n'
                                      'Cost: ₱${_estimatedCost.toStringAsFixed(2)}';

                                  await _supabase
                                      .from('admin_messages')
                                      .insert({
                                    'user_id': userId,
                                    'appointment_id': inserted['id'],
                                    'message': message,
                                  });

                                  await _supabase.from('user_messages').insert({
                                    'user_id': userId,
                                    'appointment_id': inserted['id'],
                                    'message': message,
                                    'is_from_admin': false,
                                    'is_read': false,
                                  });
                                }

                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(widget.appointment != null
                                          ? 'Appointment updated successfully!'
                                          : 'Appointment booked successfully!'),
                                      backgroundColor: Colors.green,
                                      duration: const Duration(seconds: 3),
                                    ),
                                  );
                                  Navigator.pushNamedAndRemoveUntil(
                                    context,
                                    '/home',
                                    (route) => false,
                                  );
                                }
                              } catch (error) {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(widget.appointment != null
                                          ? 'Error updating appointment: ${error.toString()}'
                                          : 'Error booking appointment: ${error.toString()}'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              } finally {
                                if (mounted) {
                                  setState(() => _isLoading = false);
                                }
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF5A623),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 0,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              widget.appointment != null
                                  ? 'Update Appointment'
                                  : 'Book Appointment',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
// -------------------------------------------------

