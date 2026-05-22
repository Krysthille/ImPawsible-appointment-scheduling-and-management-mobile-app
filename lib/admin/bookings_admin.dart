// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:table_calendar/table_calendar.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:intl/intl.dart';
// import 'home_admin.dart';
// import 'viewbookings_admin.dart';
// // import 'shop_admin.dart';
// import 'messages_admin.dart';
// import '../utils/notification_utils.dart';
// import '../utils/message_tracking_utils.dart';
// import 'settings_admin.dart';
// import 'dart:async';

// class BookingsAdminPage extends StatefulWidget {
//   const BookingsAdminPage({super.key});

//   @override
//   State<BookingsAdminPage> createState() => _BookingsAdminPageState();
// }

// class _BookingsAdminPageState extends State<BookingsAdminPage> {
//   int _selectedIndex = 1;
//   DateTime _focusedDay = DateTime.now();
//   DateTime _selectedDay = DateTime.now();
//   List<Map<String, dynamic>> _appointments = [];
//   String _currentFilter = 'Today';
//   bool _isDateSelected = false;
//   String _searchQuery = '';
//   String _currentSortType = 'date_desc';
//   final ScrollController _scrollController = ScrollController();
//   bool _showScrollToTop = false;

//   final List<String> _filters = [
//     'Today',
//     'Tomorrow',
//     'This Week',
//     'Next Week',
//     'Next Month',
//     'A month ago',
//     'All',
//     'Pending',
//     'Approved',
//     'Cancelled',
//     'Cancelled (by user)',
//     'Completed'
//   ];

//   final Map<String, Color> _filterColors = {
//     'Today': const Color(0xFF5094FF),
//     'Tomorrow': const Color(0xFF5094FF),
//     'This Week': const Color(0xFF5094FF),
//     'Next Week': const Color(0xFF5094FF),
//     'Next Month': const Color(0xFF5094FF),
//     'A month ago': const Color(0xFF5094FF),
//     'All': const Color(0xFF5094FF),
//     'Pending': const Color(0xFFFB8C00),
//     'Approved': Colors.green,
//     'Completed': Colors.blue,
//     'Cancelled': Colors.red,
//     'Cancelled (by user)': Colors.red.shade700,
//   };

//   final Map<String, DateTime> _timePeriods = {
//     'Today': DateTime.now(),
//     'Tomorrow': DateTime.now().add(const Duration(days: 1)),
//     'This Week': DateTime.now().subtract(Duration(days: DateTime.now().weekday - 1)),
//     'Next Week': DateTime.now().add(const Duration(days: 7)),
//     'Next Month': DateTime.now().add(const Duration(days: 30)),
//     'A month ago': DateTime.now().subtract(const Duration(days: 30)),
//   };

//   @override
//   void initState() {
//     super.initState();
//     _fetchAppointments();
//     _scrollController.addListener(_onScroll);
//   }

//   @override
//   void dispose() {
//     _scrollController.removeListener(_onScroll);
//     _scrollController.dispose();
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

//   Future<void> _fetchAppointments() async {
//     try {
//       debugPrint('Fetching appointments...');
//       final response = await Supabase.instance.client
//           .from('grooming_appointments')
//           .select('''
//             id, pet_name, pet_type, pet_type_other, breed, pet_size, age, gender,
//             allergies_medical_conditions, preferred_date, preferred_time, estimated_duration,
//             service_bath, service_haircut, service_nail_trim, service_ear_cleaning,
//             special_requests_notes, estimated_cost, payment_method, consent_photos, status,
//             user_id
//           ''')
//           .order('preferred_date', ascending: true)
//           .order('preferred_time', ascending: true);

//       debugPrint('Raw response: $response');
//       if (response != null && response is List) {
//         setState(() {
//           _appointments = response.cast<Map<String, dynamic>>();
//         });
//         debugPrint('Fetched appointments: ${_appointments.length}');
//       } else {
//         debugPrint('Supabase response is not a list or is null: $response');
//       }
//     } catch (e) {
//       debugPrint('Error fetching appointments: $e');
//     }
//   }

//   List<Map<String, dynamic>> get _filteredAppointments {
//     debugPrint('Filtering appointments. Total: ${_appointments.length}, Current filter: $_currentFilter, Date selected: $_isDateSelected');

//     if (_isDateSelected) {
//       final filtered = _appointments.where((app) {
//         final appointmentDate = DateTime.tryParse(app['preferred_date'] ?? '');
//         if (appointmentDate == null) return false;

//         final selectedDay = DateTime(_selectedDay.year, _selectedDay.month, _selectedDay.day);
//         final appointmentDay = DateTime(appointmentDate.year, appointmentDate.month, appointmentDate.day);
//         return appointmentDay.isAtSameMomentAs(selectedDay);
//       }).toList();

//       filtered.sort((a, b) {
//         final dateA = DateTime.tryParse(a['preferred_date'] ?? '') ?? DateTime(2000);
//         final dateB = DateTime.tryParse(b['preferred_date'] ?? '') ?? DateTime(2000);
//         return dateB.compareTo(dateA);
//       });
//       debugPrint('Date filtered appointments: ${filtered.length}');
//       return filtered;
//     } else if (_timePeriods.containsKey(_currentFilter)) {
//       final periodDate = _timePeriods[_currentFilter]!;
//       final filtered = _appointments.where((app) {
//         final appointmentDate = DateTime.tryParse(app['preferred_date'] ?? '');
//         if (appointmentDate == null) return false;

//         final now = DateTime.now();
//         final today = DateTime(now.year, now.month, now.day);

//         switch (_currentFilter) {
//           case 'Today':
//             final appointmentDay = DateTime(appointmentDate.year, appointmentDate.month, appointmentDate.day);
//             return appointmentDay.isAtSameMomentAs(today);
//           case 'Tomorrow':
//             final tomorrow = today.add(const Duration(days: 1));
//             final appointmentDay = DateTime(appointmentDate.year, appointmentDate.month, appointmentDate.day);
//             return appointmentDay.isAtSameMomentAs(tomorrow);
//           case 'This Week':
//             final startOfWeek = today.subtract(Duration(days: today.weekday - 1));
//             final endOfWeek = startOfWeek.add(const Duration(days: 6));
//             return appointmentDate.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
//                    appointmentDate.isBefore(endOfWeek.add(const Duration(days: 1)));
//           case 'Next Week':
//             final startOfNextWeek = today.add(Duration(days: 8 - today.weekday));
//             final endOfNextWeek = startOfNextWeek.add(const Duration(days: 6));
//             return appointmentDate.isAfter(startOfNextWeek.subtract(const Duration(days: 1))) &&
//                    appointmentDate.isBefore(endOfNextWeek.add(const Duration(days: 1)));
//           case 'Next Month':
//             final startOfNextMonth = DateTime(now.year, now.month + 1, 1);
//             final endOfNextMonth = DateTime(now.year, now.month + 2, 1).subtract(const Duration(days: 1));
//             return appointmentDate.isAfter(startOfNextMonth.subtract(const Duration(days: 1))) &&
//                    appointmentDate.isBefore(endOfNextMonth.add(const Duration(days: 1)));
//           case 'A month ago':
//             final startOfPeriod = DateTime(periodDate.year, periodDate.month, periodDate.day);
//             final endOfPeriod = today;
//             return appointmentDate.isAfter(startOfPeriod.subtract(const Duration(days: 1))) &&
//                    appointmentDate.isBefore(endOfPeriod.add(const Duration(days: 1)));
//           default:
//             return false;
//         }
//       }).toList();

//       filtered.sort((a, b) {
//         final dateA = DateTime.tryParse(a['preferred_date'] ?? '') ?? DateTime(2000);
//         final dateB = DateTime.tryParse(b['preferred_date'] ?? '') ?? DateTime(2000);
//         return dateB.compareTo(dateA);
//       });
//       debugPrint('Time period filtered appointments: ${filtered.length}');
//       return filtered;
//     } else if (_currentFilter == 'All') {
//       final sorted = List<Map<String, dynamic>>.from(_appointments);
//       sorted.sort((a, b) {
//         final dateA = DateTime.tryParse(a['preferred_date'] ?? '') ?? DateTime(2000);
//         final dateB = DateTime.tryParse(b['preferred_date'] ?? '') ?? DateTime(2000);
//         return dateB.compareTo(dateA);
//       });
//       return sorted;
//     } else {
//       final filtered = _appointments.where((app) => app['status'] == _currentFilter).toList();
//       filtered.sort((a, b) {
//         final dateA = DateTime.tryParse(a['preferred_date'] ?? '') ?? DateTime(2000);
//         final dateB = DateTime.tryParse(b['preferred_date'] ?? '') ?? DateTime(2000);
//         return dateB.compareTo(dateA);
//       });
//       debugPrint('Status filtered appointments: ${filtered.length}');
//       return filtered;
//     }
//   }

//   List<Map<String, dynamic>> get _searchedAppointments {
//     List<Map<String, dynamic>> appointmentsToSort = List.from(_filteredAppointments);

//     if (_searchQuery.isNotEmpty) {
//       final query = _searchQuery.toLowerCase();
//       appointmentsToSort = appointmentsToSort.where((app) {
//         final petName = (app['pet_name'] ?? '').toString().toLowerCase();
//         final breed = (app['breed'] ?? '').toString().toLowerCase();
//         final services = <String>[];
//         if (app['service_bath'] == true) services.add('bath');
//         if (app['service_haircut'] == true) services.add('haircut');
//         if (app['service_nail_trim'] == true) services.add('nail trim');
//         if (app['service_ear_cleaning'] == true) services.add('ear cleaning');
//         final servicesString = services.join(', ').toLowerCase();
//         return petName.contains(query) || breed.contains(query) || servicesString.contains(query);
//       }).toList();
//     }

//     appointmentsToSort.sort((a, b) {
//       switch (_currentSortType) {
//         case 'name_asc':
//           return (a['pet_name'] ?? '').toString().toLowerCase().compareTo((b['pet_name'] ?? '').toString().toLowerCase());
//         case 'name_desc':
//           return (b['pet_name'] ?? '').toString().toLowerCase().compareTo((a['pet_name'] ?? '').toString().toLowerCase());
//         case 'date_asc':
//           final dateA = DateTime.tryParse(a['preferred_date'] ?? '') ?? DateTime(2000);
//           final dateB = DateTime.tryParse(b['preferred_date'] ?? '') ?? DateTime(2000);
//           return dateA.compareTo(dateB);
//         case 'date_desc':
//           final dateA = DateTime.tryParse(a['preferred_date'] ?? '') ?? DateTime(2000);
//           final dateB = DateTime.tryParse(b['preferred_date'] ?? '') ?? DateTime(2000);
//           return dateB.compareTo(dateA);
//         default:
//           return 0;
//       }
//     });

//     return appointmentsToSort;
//   }

//   void _onItemTapped(int index) {
//     setState(() => _selectedIndex = index);
//     switch (index) {
//       case 0:
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (context) => const HomeAdminPage()),
//         );
//         break;
//       case 1:
//       //bookings_admin page
//         break;
//       // case 2:
//       //   Navigator.pushReplacement(
//       //     context,
//       //     MaterialPageRoute(builder: (context) => const ShopAdminPage()),
//       //   );
//         break;
//       case 2:
//         Navigator.push(
//           context,
//           MaterialPageRoute(builder: (context) => const MessagesAdminPage()),
//         );
//         break;
//       case 3:
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (context) => const SettingsAdminPage()),
//         );
//         break;
//     }
//   }

//   String _formatTime(String time) {
//     try {
//       final timeOfDay = TimeOfDay(
//         hour: int.parse(time.split(':')[0]),
//         minute: int.parse(time.split(':')[1]),
//       );
//       return timeOfDay.format(context);
//     } catch (e) {
//       return time;
//     }
//   }

//   String _formatDuration(int minutes) {
//     if (minutes < 60) return '$minutes minutes';
//     final hours = minutes ~/ 60;
//     final remainingMinutes = minutes % 60;
//     if (remainingMinutes == 0) return '$hours hour${hours > 1 ? 's' : ''}';
//     return '$hours hour${hours > 1 ? 's' : ''} and $remainingMinutes minutes';
//   }

//   String _getSelectedServices(Map<String, dynamic> appointment) {
//     final services = <String>[];
//     if (appointment['service_bath'] == true) services.add('Bath');
//     if (appointment['service_haircut'] == true) services.add('Haircut');
//     if (appointment['service_nail_trim'] == true) services.add('Nail Trim');
//     if (appointment['service_ear_cleaning'] == true) services.add('Ear Cleaning');
//     return services.join(', ');
//   }

//   List<Map<String, dynamic>> _getAppointmentsForDate(DateTime date) {
//     return _appointments.where((app) {
//       final appointmentDate = DateTime.tryParse(app['preferred_date'] ?? '');
//       if (appointmentDate == null) return false;
//       final targetDay = DateTime(date.year, date.month, date.day);
//       final appointmentDay = DateTime(appointmentDate.year, appointmentDate.month, appointmentDate.day);
//       return appointmentDay.isAtSameMomentAs(targetDay);
//     }).toList();
//   }

//   Widget _buildAppointmentCard({
//     required String id,
//     required String date,
//     required String time,
//     required int duration,
//     required String petName,
//     required String services,
//   }) {
//     final appointment = _appointments.firstWhere((app) => app['id'] == id);
//     final status = appointment['status'] ?? 'Pending';

//     Map<String, Map<String, dynamic>> statusStyles = {
//       'Pending': {
//         'bgColor': const Color(0xFFFFF3E0),
//         'textColor': const Color(0xFFFB8C00),
//         'icon': Icons.schedule,
//       },
//       'Approved': {
//         'bgColor': const Color(0xFFE8F5E9),
//         'textColor': Colors.green,
//         'icon': Icons.check_circle,
//       },
//       'Completed': {
//         'bgColor': const Color(0xFFE3F2FD),
//         'textColor': Colors.blue,
//         'icon': Icons.done_all,
//       },
//       'Cancelled': {
//         'bgColor': const Color(0xFFFFEBEE),
//         'textColor': Colors.red,
//         'icon': Icons.cancel,
//       },
//       'Cancelled (by user)': {
//         'bgColor': const Color(0xFFFFEBEE),
//         'textColor': Colors.red.shade700,
//         'icon': Icons.cancel,
//       },
//     };
//     final style = statusStyles[status] ?? statusStyles['Pending']!;

//     return InkWell(
//       onTap: () async {
//         final appointment = _appointments.firstWhere((app) => app['id'] == id);
//         Map<String, dynamic>? userDetails;
//         try {
//           final userResp = await Supabase.instance.client
//               .from('users')
//               .select('full_name, email, contact_number')
//               .eq('id', appointment['user_id'])
//               .maybeSingle();
//           userDetails = userResp;
//         } catch (e) {
//           userDetails = null;
//         }
//         final result = await Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => ViewBookingsAdmin(
//               appointment: {
//                 ...appointment,
//                 if (userDetails != null) 'user_details': userDetails,
//               },
//             ),
//           ),
//         );
//         if (result == true) _fetchAppointments();
//       },
//       child: Container(
//         margin: const EdgeInsets.only(bottom: 12),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(16),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.05),
//               blurRadius: 6,
//               offset: const Offset(0, 2),
//             ),
//           ],
//         ),
//         child: ClipRRect(
//           borderRadius: BorderRadius.circular(16),
//           child: Material(
//             color: Colors.transparent,
//             child: Padding(
//               padding: const EdgeInsets.all(16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Expanded(
//                         child: Text(
//                           petName,
//                           style: GoogleFonts.poppins(
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold,
//                             color: const Color(0xFF5094FF),
//                           ),
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                       ),
//                       const SizedBox(width: 8),
//                       Container(
//                         padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                         decoration: BoxDecoration(
//                           color: style['bgColor'],
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         child: Row(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             Icon(style['icon'], size: 14, color: style['textColor']),
//                             const SizedBox(width: 4),
//                             Text(
//                               status == 'Cancelled (by user)' ? 'Cancelled' : status,
//                               style: GoogleFonts.poppins(
//                                 fontSize: 11,
//                                 color: style['textColor'],
//                                 fontWeight: FontWeight.w500,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 12),
//                   Wrap(
//                     spacing: 12,
//                     runSpacing: 8,
//                     children: [
//                       Row(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
//                           const SizedBox(width: 4),
//                           Text(
//                             date,
//                             style: GoogleFonts.poppins(
//                               fontSize: 13,
//                               color: Colors.black87,
//                             ),
//                           ),
//                         ],
//                       ),
//                       Row(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           const Icon(Icons.access_time, size: 16, color: Colors.grey),
//                           const SizedBox(width: 4),
//                           Text(
//                             _formatTime(time),
//                             style: GoogleFonts.poppins(
//                               fontSize: 13,
//                               color: Colors.black87,
//                             ),
//                           ),
//                         ],
//                       ),
//                       Row(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           const Icon(Icons.timer, size: 16, color: Color(0xFF5094FF)),
//                           const SizedBox(width: 4),
//                           Text(
//                             _formatDuration(duration),
//                             style: GoogleFonts.poppins(
//                               fontSize: 13,
//                               color: const Color(0xFF5094FF),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 12),
//                   Container(
//                     padding: const EdgeInsets.all(12),
//                     decoration: BoxDecoration(
//                       color: const Color(0xFFF8F9FA),
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: Row(
//                       children: [
//                         const Icon(Icons.pets, size: 18, color: Color(0xFF5094FF)),
//                         const SizedBox(width: 8),
//                         Expanded(
//                           child: Text(
//                             services,
//                             style: GoogleFonts.poppins(
//                               fontSize: 13,
//                               color: Colors.black87,
//                             ),
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   const Align(
//                     alignment: Alignment.centerRight,
//                     child: Icon(
//                       Icons.arrow_forward_ios,
//                       size: 16,
//                       color: Colors.grey,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildEmptyState() {
//     return Container(
//       margin: const EdgeInsets.only(top: 40),
//       child: Column(
//         children: [
//           Icon(
//             Icons.event_note_outlined,
//             size: 60,
//             color: Colors.grey[300],
//           ),
//           const SizedBox(height: 16),
//           Text(
//             'No appointments found',
//             style: GoogleFonts.poppins(
//               fontSize: 16,
//               color: Colors.grey[600],
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             _isDateSelected
//                 ? 'There are no appointments scheduled for this date.'
//                 : 'No appointments match your filters.',
//             style: GoogleFonts.poppins(
//               fontSize: 14,
//               color: Colors.grey[500],
//             ),
//             textAlign: TextAlign.center,
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildCalendarLegend() {
//     return Row(
//       children: [
//         _buildLegendItem(Colors.blue, 'Completed'),
//         const SizedBox(width: 12),
//         _buildLegendItem(Colors.green, 'Today'),
//         const SizedBox(width: 12),
//         _buildLegendItem(Colors.orange, 'Upcoming'),
//       ],
//     );
//   }

//   Widget _buildLegendItem(Color color, String label) {
//     return Row(
//       children: [
//         Container(
//           width: 10,
//           height: 10,
//           decoration: BoxDecoration(
//             color: color,
//             shape: BoxShape.circle,
//           ),
//         ),
//         const SizedBox(width: 4),
//         Text(label, style: GoogleFonts.poppins(fontSize: 10)),
//       ],
//     );
//   }

//   Widget _buildSortMenu() {
//     return PopupMenuButton<String>(
//       onSelected: (value) => setState(() => _currentSortType = value),
//       itemBuilder: (context) => [
//         PopupMenuItem(
//           value: 'name_asc',
//           child: Text('Pet Name (A-Z)', style: GoogleFonts.poppins(fontSize: 13)),
//         ),
//         PopupMenuItem(
//           value: 'name_desc',
//           child: Text('Pet Name (Z-A)', style: GoogleFonts.poppins(fontSize: 13)),
//         ),
//         PopupMenuItem(
//           value: 'date_asc',
//           child: Text('Date (Oldest First)', style: GoogleFonts.poppins(fontSize: 13)),
//         ),
//         PopupMenuItem(
//           value: 'date_desc',
//           child: Text('Date (Newest First)', style: GoogleFonts.poppins(fontSize: 13)),
//         ),
//       ],
//       child: Row(
//         children: [
//           Icon(Icons.sort, color: Colors.grey[600], size: 20),
//           const SizedBox(width: 4),
//           Text(
//             'Sort',
//             style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildFilterChips() {
//     return SingleChildScrollView(
//       scrollDirection: Axis.horizontal,
//       child: Row(
//         children: [
//           Padding(
//             padding: const EdgeInsets.only(right: 8.0),
//             child: PopupMenuButton<String>(
//               child: Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//                 decoration: BoxDecoration(
//                   color: _timePeriods.containsKey(_currentFilter)
//                       ? const Color(0xFF5094FF)
//                       : Colors.white,
//                   borderRadius: BorderRadius.circular(20),
//                   border: Border.all(
//                     color: _timePeriods.containsKey(_currentFilter)
//                         ? const Color(0xFF5094FF)
//                         : Colors.grey[300]!,
//                   ),
//                 ),
//                 child: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Text(
//                       _timePeriods.containsKey(_currentFilter)
//                           ? _currentFilter
//                           : 'Time Period',
//                       style: GoogleFonts.poppins(
//                         color: _timePeriods.containsKey(_currentFilter)
//                             ? Colors.white
//                             : const Color(0xFF5094FF),
//                         fontSize: 12,
//                       ),
//                     ),
//                     const SizedBox(width: 4),
//                     Icon(
//                       Icons.arrow_drop_down,
//                       color: _timePeriods.containsKey(_currentFilter)
//                           ? Colors.white
//                           : const Color(0xFF5094FF),
//                       size: 16,
//                     ),
//                   ],
//                 ),
//               ),
//               itemBuilder: (context) => _timePeriods.keys.map((period) {
//                 return PopupMenuItem<String>(
//                   value: period,
//                   child: Text(period, style: GoogleFonts.poppins(fontSize: 12)),
//                 );
//               }).toList(),
//               onSelected: (value) => setState(() {
//                 _currentFilter = value;
//                 _isDateSelected = false;
//               }),
//             ),
//           ),
//           ..._filters.where((filter) => !_timePeriods.containsKey(filter)).map((filter) {
//             final isSelected = _currentFilter == filter;
//             return Padding(
//               padding: const EdgeInsets.only(right: 8.0),
//               child: FilterChip(
//                 label: Text(
//                   filter,
//                   style: GoogleFonts.poppins(
//                     color: isSelected
//                         ? Colors.white
//                         : _filterColors[filter] ?? const Color(0xFF5094FF),
//                     fontSize: 12,
//                   ),
//                 ),
//                 selected: isSelected,
//                 onSelected: (selected) => setState(() {
//                   _currentFilter = filter;
//                   _isDateSelected = false;
//                 }),
//                 backgroundColor: Colors.white,
//                 selectedColor: _filterColors[filter] ?? const Color(0xFF5094FF),
//                 checkmarkColor: Colors.white,
//                 side: BorderSide(
//                   color: isSelected
//                       ? _filterColors[filter] ?? const Color(0xFF5094FF)
//                       : Colors.grey[300]!,
//                 ),
//               ),
//             );
//           }).toList(),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final orange = const Color(0xFFF5A623);
//     final screenWidth = MediaQuery.of(context).size.width;
//     final isSmallScreen = screenWidth < 360;

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
//           child: CustomScrollView(
//             controller: _scrollController,
//             slivers: [
//               SliverToBoxAdapter(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Padding(
//                       padding: EdgeInsets.symmetric(
//                         horizontal: isSmallScreen ? 12 : 16,
//                         vertical: 12,
//                       ),
//                       child: TextField(
//                         decoration: InputDecoration(
//                           hintText: 'Search by pet name, breed, or service',
//                           hintStyle: TextStyle(
//                             fontSize: 14,
//                             color: Colors.grey[500],
//                           ),
//                           prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
//                           suffixIcon: _searchQuery.isNotEmpty
//                               ? IconButton(
//                                   icon: Icon(Icons.clear, color: Colors.grey[400]),
//                                   onPressed: () {
//                                     setState(() => _searchQuery = '');
//                                     FocusScope.of(context).unfocus();
//                                   },
//                                 )
//                               : null,
//                           filled: true,
//                           fillColor: Colors.grey[100],
//                           contentPadding: const EdgeInsets.symmetric(
//                             vertical: 0,
//                             horizontal: 16,
//                           ),
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(12),
//                             borderSide: BorderSide.none,
//                           ),
//                         ),
//                         onChanged: (value) => setState(() => _searchQuery = value),
//                       ),
//                     ),
//                     Padding(
//                       padding: EdgeInsets.symmetric(
//                         horizontal: isSmallScreen ? 12 : 16,
//                         vertical: 8,
//                       ),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Text(
//                                 'Calendar',
//                                 style: GoogleFonts.poppins(
//                                   fontSize: 18,
//                                   fontWeight: FontWeight.bold,
//                                   color: orange,
//                                 ),
//                               ),
//                               _buildCalendarLegend(),
//                             ],
//                           ),
//                           const SizedBox(height: 12),
//                           Container(
//                             decoration: BoxDecoration(
//                               color: Colors.white,
//                               borderRadius: BorderRadius.circular(12),
//                               boxShadow: [
//                                 BoxShadow(
//                                   color: Colors.orange.withOpacity(0.10),
//                                   blurRadius: 8,
//                                   offset: const Offset(0, 4),
//                                 ),
//                               ],
//                             ),
//                             child: TableCalendar(
//                               firstDay: DateTime.utc(2023, 1, 1),
//                               lastDay: DateTime.utc(2030, 12, 31),
//                               focusedDay: _focusedDay,
//                               selectedDayPredicate: (day) =>
//                                   _isDateSelected && isSameDay(_selectedDay, day),
//                               onDaySelected: (selectedDay, focusedDay) {
//                                 setState(() {
//                                   _selectedDay = selectedDay;
//                                   _focusedDay = focusedDay;
//                                   _isDateSelected = true;
//                                 });
//                               },
//                               calendarStyle: CalendarStyle(
//                                 todayDecoration: BoxDecoration(
//                                   color: Colors.green.withOpacity(0.5),
//                                   shape: BoxShape.circle,
//                                 ),
//                                 selectedDecoration: BoxDecoration(
//                                   color: orange.withOpacity(0.5),
//                                   shape: BoxShape.circle,
//                                 ),
//                               ),
//                               calendarBuilders: CalendarBuilders(
//                                 markerBuilder: (context, date, events) {
//                                   final now = DateTime.now();
//                                   final today = DateTime(now.year, now.month, now.day);
//                                   final targetDay = DateTime(date.year, date.month, date.day);
//                                   final hasAppointment = _appointments.any((app) {
//                                     final appointmentDate =
//                                         DateTime.tryParse(app['preferred_date'] ?? '');
//                                     if (appointmentDate == null) return false;
//                                     final appointmentDay = DateTime(
//                                         appointmentDate.year,
//                                         appointmentDate.month,
//                                         appointmentDate.day);
//                                     return appointmentDay.isAtSameMomentAs(targetDay);
//                                   });

//                                   if (hasAppointment) {
//                                     Color dotColor;
//                                     if (targetDay.isBefore(today)) {
//                                       dotColor = Colors.blue;
//                                     } else if (targetDay.isAtSameMomentAs(today)) {
//                                       dotColor = Colors.green;
//                                     } else {
//                                       dotColor = Colors.orange;
//                                     }
//                                     return Positioned(
//                                       bottom: 1,
//                                       child: Container(
//                                         width: 7,
//                                         height: 7,
//                                         decoration: BoxDecoration(
//                                           color: dotColor,
//                                           shape: BoxShape.circle,
//                                         ),
//                                       ),
//                                     );
//                                   }
//                                   return null;
//                                 },
//                               ),
//                               eventLoader: (day) =>
//                                   _getAppointmentsForDate(day).isNotEmpty ? [1] : [],
//                               headerStyle: HeaderStyle(
//                                 formatButtonVisible: false,
//                                 titleCentered: true,
//                                 titleTextStyle: GoogleFonts.poppins(
//                                   fontWeight: FontWeight.bold,
//                                   fontSize: 16,
//                                   color: Colors.black87,
//                                 ),
//                               ),
//                               calendarFormat: CalendarFormat.month,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     Padding(
//                       padding: EdgeInsets.symmetric(
//                         horizontal: isSmallScreen ? 12 : 16,
//                         vertical: 12,
//                       ),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Text(
//                             _isDateSelected
//                                 ? 'Appointments for ${DateFormat('MMMM dd, yyyy').format(_selectedDay)}'
//                                 : 'All Appointments',
//                             style: GoogleFonts.poppins(
//                               fontSize: 16,
//                               fontWeight: FontWeight.bold,
//                               color: const Color(0xFF5094FF),
//                             ),
//                           ),
//                           _buildSortMenu(),
//                         ],
//                       ),
//                     ),
//                     if (_isDateSelected)
//                       Padding(
//                         padding: EdgeInsets.symmetric(
//                           horizontal: isSmallScreen ? 12 : 16,
//                           vertical: 8,
//                         ),
//                         child: OutlinedButton.icon(
//                           onPressed: () => setState(() => _isDateSelected = false),
//                           icon: const Icon(Icons.clear, size: 16),
//                           label: Text(
//                             'Clear Date Selection',
//                             style: GoogleFonts.poppins(fontSize: 12),
//                           ),
//                           style: OutlinedButton.styleFrom(
//                             padding: const EdgeInsets.symmetric(vertical: 8),
//                             side: BorderSide(color: Colors.grey[300]!),
//                           ),
//                         ),
//                       ),
//                     if (!_isDateSelected)
//                       Padding(
//                         padding: EdgeInsets.symmetric(
//                           horizontal: isSmallScreen ? 12 : 16,
//                           vertical: 8,
//                         ),
//                         child: _buildFilterChips(),
//                       ),
//                   ],
//                 ),
//               ),
//               SliverPadding(
//                 padding: EdgeInsets.symmetric(
//                   horizontal: isSmallScreen ? 12 : 16,
//                   vertical: 8,
//                 ),
//                 sliver: _searchedAppointments.isEmpty
//                     ? SliverToBoxAdapter(child: _buildEmptyState())
//                     : SliverList(
//                         delegate: SliverChildBuilderDelegate(
//                           (context, index) {
//                             final appointment = _searchedAppointments[index];
//                             return _buildAppointmentCard(
//                               id: appointment['id'],
//                               date: appointment['preferred_date'] != null
//                                   ? DateFormat('MMMM dd, yyyy').format(
//                                       DateTime.parse(appointment['preferred_date']))
//                                   : 'N/A',
//                               time: appointment['preferred_time'] ?? 'N/A',
//                               duration: appointment['estimated_duration'] ?? 0,
//                               petName: appointment['pet_name'] ?? 'N/A',
//                               services: _getSelectedServices(appointment),
//                             );
//                           },
//                           childCount: _searchedAppointments.length,
//                         ),
//                       ),
//               ),
//             ],
//           ),
//         ),
//       ),
//       bottomNavigationBar: Container(
//         decoration: BoxDecoration(
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.1),
//               blurRadius: 10,
//               offset: const Offset(0, -5),
//             ),
//           ],
//         ),
//         child: BottomNavigationBar(
//           items: const [
//             BottomNavigationBarItem(
//               icon: Icon(Icons.dashboard),
//               label: 'Dashboard',
//             ),
//             BottomNavigationBarItem(
//               icon: Icon(Icons.calendar_today),
//               label: 'Bookings',
//             ),
//             // BottomNavigationBarItem(
//             //   icon: Icon(Icons.shopping_bag),
//             //   label: 'Shop',
//             // ),
//             BottomNavigationBarItem(
//               icon: Icon(Icons.message),
//               label: 'Messages',
//             ),
//             BottomNavigationBarItem(
//               icon: Icon(Icons.settings),
//               label: 'Settings',
//             ),
//           ],
//           currentIndex: _selectedIndex,
//           selectedItemColor: const Color(0xFFF5A623),
//           unselectedItemColor: Colors.grey,
//           onTap: _onItemTapped,
//           type: BottomNavigationBarType.fixed,
//           backgroundColor: Colors.white,
//         ),
//       ),
//       floatingActionButton: _showScrollToTop
//           ? FloatingActionButton(
//               onPressed: _scrollToTop,
//               backgroundColor: const Color(0xFFF5A623),
//               foregroundColor: Colors.white,
//               mini: true,
//               child: const Icon(Icons.keyboard_arrow_up),
//             )
//           : null,
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'home_admin.dart';
import 'viewbookings_admin.dart';
import 'messages_admin.dart';
import '../utils/notification_utils.dart';
import '../utils/message_tracking_utils.dart';
import 'settings_admin.dart';
import 'dart:async';

class BookingsAdminPage extends StatefulWidget {
  const BookingsAdminPage({super.key});

  @override
  State<BookingsAdminPage> createState() => _BookingsAdminPageState();
}

class _BookingsAdminPageState extends State<BookingsAdminPage> {
  int _selectedIndex = 1;
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  List<Map<String, dynamic>> _appointments = [];
  String _currentFilter = 'Today';
  bool _isDateSelected = false;
  String _searchQuery = '';
  String _currentSortType = 'date_desc';
  final ScrollController _scrollController = ScrollController();
  bool _showScrollToTop = false;
  bool _isRefreshing = false;

  final List<String> _filters = [
    'Today',
    'Tomorrow',
    'This Week',
    'Next Week',
    'Next Month',
    'A month ago',
    'All',
    'Pending',
    'Approved',
    'Cancelled',
    'Cancelled (by user)',
    'Completed'
  ];

  final Map<String, Color> _filterColors = {
    'Today': const Color(0xFF5094FF),
    'Tomorrow': const Color(0xFF5094FF),
    'This Week': const Color(0xFF5094FF),
    'Next Week': const Color(0xFF5094FF),
    'Next Month': const Color(0xFF5094FF),
    'A month ago': const Color(0xFF5094FF),
    'All': const Color(0xFF5094FF),
    'Pending': const Color(0xFFFB8C00),
    'Approved': Colors.green,
    'Completed': Colors.blue,
    'Cancelled': Colors.red,
    'Cancelled (by user)': Colors.red.shade700,
  };

  final Map<String, DateTime> _timePeriods = {
    'Today': DateTime.now(),
    'Tomorrow': DateTime.now().add(const Duration(days: 1)),
    'This Week': DateTime.now().subtract(Duration(days: DateTime.now().weekday - 1)),
    'Next Week': DateTime.now().add(const Duration(days: 7)),
    'Next Month': DateTime.now().add(const Duration(days: 30)),
    'A month ago': DateTime.now().subtract(const Duration(days: 30)),
  };

  @override
  void initState() {
    super.initState();
    _fetchAppointments();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
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

  Future<void> _refreshAppointments() async {
    setState(() => _isRefreshing = true);
    await _fetchAppointments();
    setState(() => _isRefreshing = false);
  }

  Future<void> _fetchAppointments() async {
    try {
      debugPrint('Fetching appointments...');
      final response = await Supabase.instance.client
          .from('grooming_appointments')
          .select('''
            id, pet_name, pet_type, pet_type_other, breed, pet_size, age, gender,
            allergies_medical_conditions, preferred_date, preferred_time, estimated_duration,
            service_bath, service_haircut, service_nail_trim, service_ear_cleaning,
            special_requests_notes, estimated_cost, payment_method, consent_photos, status,
            user_id
          ''')
          .order('preferred_date', ascending: true)
          .order('preferred_time', ascending: true);
      debugPrint('Raw response: $response');
      if (response != null && response is List) {
        setState(() {
          _appointments = response.cast<Map<String, dynamic>>();
        });
        debugPrint('Fetched appointments: ${_appointments.length}');
      } else {
        debugPrint('Supabase response is not a list or is null: $response');
      }
    } catch (e) {
      debugPrint('Error fetching appointments: $e');
    }
  }

  List<Map<String, dynamic>> get _filteredAppointments {
    debugPrint('Filtering appointments. Total: ${_appointments.length}, Current filter: $_currentFilter, Date selected: $_isDateSelected');
    if (_isDateSelected) {
      final filtered = _appointments.where((app) {
        final appointmentDate = DateTime.tryParse(app['preferred_date'] ?? '');
        if (appointmentDate == null) return false;
        final selectedDay = DateTime(_selectedDay.year, _selectedDay.month, _selectedDay.day);
        final appointmentDay = DateTime(appointmentDate.year, appointmentDate.month, appointmentDate.day);
        return appointmentDay.isAtSameMomentAs(selectedDay);
      }).toList();
      filtered.sort((a, b) {
        final dateA = DateTime.tryParse(a['preferred_date'] ?? '') ?? DateTime(2000);
        final dateB = DateTime.tryParse(b['preferred_date'] ?? '') ?? DateTime(2000);
        return dateB.compareTo(dateA);
      });
      debugPrint('Date filtered appointments: ${filtered.length}');
      return filtered;
    } else if (_timePeriods.containsKey(_currentFilter)) {
      final periodDate = _timePeriods[_currentFilter]!;
      final filtered = _appointments.where((app) {
        final appointmentDate = DateTime.tryParse(app['preferred_date'] ?? '');
        if (appointmentDate == null) return false;
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        switch (_currentFilter) {
          case 'Today':
            final appointmentDay = DateTime(appointmentDate.year, appointmentDate.month, appointmentDate.day);
            return appointmentDay.isAtSameMomentAs(today);
          case 'Tomorrow':
            final tomorrow = today.add(const Duration(days: 1));
            final appointmentDay = DateTime(appointmentDate.year, appointmentDate.month, appointmentDate.day);
            return appointmentDay.isAtSameMomentAs(tomorrow);
          case 'This Week':
            final startOfWeek = today.subtract(Duration(days: today.weekday - 1));
            final endOfWeek = startOfWeek.add(const Duration(days: 6));
            return appointmentDate.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
                   appointmentDate.isBefore(endOfWeek.add(const Duration(days: 1)));
          case 'Next Week':
            final startOfNextWeek = today.add(Duration(days: 8 - today.weekday));
            final endOfNextWeek = startOfNextWeek.add(const Duration(days: 6));
            return appointmentDate.isAfter(startOfNextWeek.subtract(const Duration(days: 1))) &&
                   appointmentDate.isBefore(endOfNextWeek.add(const Duration(days: 1)));
          case 'Next Month':
            final startOfNextMonth = DateTime(now.year, now.month + 1, 1);
            final endOfNextMonth = DateTime(now.year, now.month + 2, 1).subtract(const Duration(days: 1));
            return appointmentDate.isAfter(startOfNextMonth.subtract(const Duration(days: 1))) &&
                   appointmentDate.isBefore(endOfNextMonth.add(const Duration(days: 1)));
          case 'A month ago':
            final startOfPeriod = DateTime(periodDate.year, periodDate.month, periodDate.day);
            final endOfPeriod = today;
            return appointmentDate.isAfter(startOfPeriod.subtract(const Duration(days: 1))) &&
                   appointmentDate.isBefore(endOfPeriod.add(const Duration(days: 1)));
          default:
            return false;
        }
      }).toList();
      filtered.sort((a, b) {
        final dateA = DateTime.tryParse(a['preferred_date'] ?? '') ?? DateTime(2000);
        final dateB = DateTime.tryParse(b['preferred_date'] ?? '') ?? DateTime(2000);
        return dateB.compareTo(dateA);
      });
      debugPrint('Time period filtered appointments: ${filtered.length}');
      return filtered;
    } else if (_currentFilter == 'All') {
      final sorted = List<Map<String, dynamic>>.from(_appointments);
      sorted.sort((a, b) {
        final dateA = DateTime.tryParse(a['preferred_date'] ?? '') ?? DateTime(2000);
        final dateB = DateTime.tryParse(b['preferred_date'] ?? '') ?? DateTime(2000);
        return dateB.compareTo(dateA);
      });
      return sorted;
    } else {
      final filtered = _appointments.where((app) => app['status'] == _currentFilter).toList();
      filtered.sort((a, b) {
        final dateA = DateTime.tryParse(a['preferred_date'] ?? '') ?? DateTime(2000);
        final dateB = DateTime.tryParse(b['preferred_date'] ?? '') ?? DateTime(2000);
        return dateB.compareTo(dateA);
      });
      debugPrint('Status filtered appointments: ${filtered.length}');
      return filtered;
    }
  }

  List<Map<String, dynamic>> get _searchedAppointments {
    List<Map<String, dynamic>> appointmentsToSort = List.from(_filteredAppointments);
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      appointmentsToSort = appointmentsToSort.where((app) {
        final petName = (app['pet_name'] ?? '').toString().toLowerCase();
        final breed = (app['breed'] ?? '').toString().toLowerCase();
        final services = <String>[];
        if (app['service_bath'] == true) services.add('bath');
        if (app['service_haircut'] == true) services.add('haircut');
        if (app['service_nail_trim'] == true) services.add('nail trim');
        if (app['service_ear_cleaning'] == true) services.add('ear cleaning');
        final servicesString = services.join(', ').toLowerCase();
        return petName.contains(query) || breed.contains(query) || servicesString.contains(query);
      }).toList();
    }
    appointmentsToSort.sort((a, b) {
      switch (_currentSortType) {
        case 'name_asc':
          return (a['pet_name'] ?? '').toString().toLowerCase().compareTo((b['pet_name'] ?? '').toString().toLowerCase());
        case 'name_desc':
          return (b['pet_name'] ?? '').toString().toLowerCase().compareTo((a['pet_name'] ?? '').toString().toLowerCase());
        case 'date_asc':
          final dateA = DateTime.tryParse(a['preferred_date'] ?? '') ?? DateTime(2000);
          final dateB = DateTime.tryParse(b['preferred_date'] ?? '') ?? DateTime(2000);
          return dateA.compareTo(dateB);
        case 'date_desc':
          final dateA = DateTime.tryParse(a['preferred_date'] ?? '') ?? DateTime(2000);
          final dateB = DateTime.tryParse(b['preferred_date'] ?? '') ?? DateTime(2000);
          return dateB.compareTo(dateA);
        default:
          return 0;
      }
    });
    return appointmentsToSort;
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeAdminPage()),
        );
        break;
      case 1:
        // bookings_admin page
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const MessagesAdminPage()),
        );
        break;
      case 3:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const SettingsAdminPage()),
        );
        break;
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

  String _formatDuration(int minutes) {
    if (minutes < 60) return '$minutes minutes';
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;
    if (remainingMinutes == 0) return '$hours hour${hours > 1 ? 's' : ''}';
    return '$hours hour${hours > 1 ? 's' : ''} and $remainingMinutes minutes';
  }

  String _getSelectedServices(Map<String, dynamic> appointment) {
    final services = <String>[];
    if (appointment['service_bath'] == true) services.add('Bath');
    if (appointment['service_haircut'] == true) services.add('Haircut');
    if (appointment['service_nail_trim'] == true) services.add('Nail Trim');
    if (appointment['service_ear_cleaning'] == true) services.add('Ear Cleaning');
    return services.join(', ');
  }

  List<Map<String, dynamic>> _getAppointmentsForDate(DateTime date) {
    return _appointments.where((app) {
      final appointmentDate = DateTime.tryParse(app['preferred_date'] ?? '');
      if (appointmentDate == null) return false;
      final targetDay = DateTime(date.year, date.month, date.day);
      final appointmentDay = DateTime(appointmentDate.year, appointmentDate.month, appointmentDate.day);
      return appointmentDay.isAtSameMomentAs(targetDay);
    }).toList();
  }

  Widget _buildAppointmentCard({
    required String id,
    required String date,
    required String time,
    required int duration,
    required String petName,
    required String services,
  }) {
    final appointment = _appointments.firstWhere((app) => app['id'] == id);
    final status = appointment['status'] ?? 'Pending';
    Map<String, Map<String, dynamic>> statusStyles = {
      'Pending': {
        'bgColor': const Color(0xFFFFF3E0),
        'textColor': const Color(0xFFFB8C00),
        'icon': Icons.schedule,
      },
      'Approved': {
        'bgColor': const Color(0xFFE8F5E9),
        'textColor': Colors.green,
        'icon': Icons.check_circle,
      },
      'Completed': {
        'bgColor': const Color(0xFFE3F2FD),
        'textColor': Colors.blue,
        'icon': Icons.done_all,
      },
      'Cancelled': {
        'bgColor': const Color(0xFFFFEBEE),
        'textColor': Colors.red,
        'icon': Icons.cancel,
      },
      'Cancelled (by user)': {
        'bgColor': const Color(0xFFFFEBEE),
        'textColor': Colors.red.shade700,
        'icon': Icons.cancel,
      },
    };
    final style = statusStyles[status] ?? statusStyles['Pending']!;
    return InkWell(
      onTap: () async {
        final appointment = _appointments.firstWhere((app) => app['id'] == id);
        Map<String, dynamic>? userDetails;
        try {
          final userResp = await Supabase.instance.client
              .from('users')
              .select('full_name, email, contact_number')
              .eq('id', appointment['user_id'])
              .maybeSingle();
          userDetails = userResp;
        } catch (e) {
          userDetails = null;
        }
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ViewBookingsAdmin(
              appointment: {
                ...appointment,
                if (userDetails != null) 'user_details': userDetails,
              },
            ),
          ),
        );
        if (result == true) _fetchAppointments();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Material(
            color: Colors.transparent,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          petName,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF5094FF),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: style['bgColor'],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(style['icon'], size: 14, color: style['textColor']),
                            const SizedBox(width: 4),
                            Text(
                              status == 'Cancelled (by user)' ? 'Cancelled' : status,
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                color: style['textColor'],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            date,
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.access_time, size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            _formatTime(time),
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.timer, size: 16, color: Color(0xFF5094FF)),
                          const SizedBox(width: 4),
                          Text(
                            _formatDuration(duration),
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: const Color(0xFF5094FF),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F9FA),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.pets, size: 18, color: Color(0xFF5094FF)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            services,
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: Colors.black87,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Align(
                    alignment: Alignment.centerRight,
                    child: Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      margin: const EdgeInsets.only(top: 40),
      child: Column(
        children: [
          Icon(
            Icons.event_note_outlined,
            size: 60,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'No appointments found',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _isDateSelected
                ? 'There are no appointments scheduled for this date.'
                : 'No appointments match your filters.',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarLegend() {
    return Row(
      children: [
        _buildLegendItem(Colors.blue, 'Completed'),
        const SizedBox(width: 12),
        _buildLegendItem(Colors.green, 'Today'),
        const SizedBox(width: 12),
        _buildLegendItem(Colors.orange, 'Upcoming'),
      ],
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: GoogleFonts.poppins(fontSize: 10)),
      ],
    );
  }

  Widget _buildSortMenu() {
    return PopupMenuButton<String>(
      onSelected: (value) => setState(() => _currentSortType = value),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'name_asc',
          child: Text('Pet Name (A-Z)', style: GoogleFonts.poppins(fontSize: 13)),
        ),
        PopupMenuItem(
          value: 'name_desc',
          child: Text('Pet Name (Z-A)', style: GoogleFonts.poppins(fontSize: 13)),
        ),
        PopupMenuItem(
          value: 'date_asc',
          child: Text('Date (Oldest First)', style: GoogleFonts.poppins(fontSize: 13)),
        ),
        PopupMenuItem(
          value: 'date_desc',
          child: Text('Date (Newest First)', style: GoogleFonts.poppins(fontSize: 13)),
        ),
      ],
      child: Row(
        children: [
          Icon(Icons.sort, color: Colors.grey[600], size: 20),
          const SizedBox(width: 4),
          Text(
            'Sort',
            style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: PopupMenuButton<String>(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: _timePeriods.containsKey(_currentFilter)
                      ? const Color(0xFF5094FF)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _timePeriods.containsKey(_currentFilter)
                        ? const Color(0xFF5094FF)
                        : Colors.grey[300]!,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _timePeriods.containsKey(_currentFilter)
                          ? _currentFilter
                          : 'Time Period',
                      style: GoogleFonts.poppins(
                        color: _timePeriods.containsKey(_currentFilter)
                            ? Colors.white
                            : const Color(0xFF5094FF),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_drop_down,
                      color: _timePeriods.containsKey(_currentFilter)
                          ? Colors.white
                          : const Color(0xFF5094FF),
                      size: 16,
                    ),
                  ],
                ),
              ),
              itemBuilder: (context) => _timePeriods.keys.map((period) {
                return PopupMenuItem<String>(
                  value: period,
                  child: Text(period, style: GoogleFonts.poppins(fontSize: 12)),
                );
              }).toList(),
              onSelected: (value) => setState(() {
                _currentFilter = value;
                _isDateSelected = false;
              }),
            ),
          ),
          ..._filters.where((filter) => !_timePeriods.containsKey(filter)).map((filter) {
            final isSelected = _currentFilter == filter;
            return Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: FilterChip(
                label: Text(
                  filter,
                  style: GoogleFonts.poppins(
                    color: isSelected
                        ? Colors.white
                        : _filterColors[filter] ?? const Color(0xFF5094FF),
                    fontSize: 12,
                  ),
                ),
                selected: isSelected,
                onSelected: (selected) => setState(() {
                  _currentFilter = filter;
                  _isDateSelected = false;
                }),
                backgroundColor: Colors.white,
                selectedColor: _filterColors[filter] ?? const Color(0xFF5094FF),
                checkmarkColor: Colors.white,
                side: BorderSide(
                  color: isSelected
                      ? _filterColors[filter] ?? const Color(0xFF5094FF)
                      : Colors.grey[300]!,
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final orange = const Color(0xFFF5A623);
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

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
          child: RefreshIndicator(
            color: orange,
            onRefresh: _refreshAppointments,
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: isSmallScreen ? 12 : 16,
                          vertical: 12,
                        ),
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Search by pet name, breed, or service',
                            hintStyle: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                            prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                            suffixIcon: _searchQuery.isNotEmpty
                                ? IconButton(
                                    icon: Icon(Icons.clear, color: Colors.grey[400]),
                                    onPressed: () {
                                      setState(() => _searchQuery = '');
                                      FocusScope.of(context).unfocus();
                                    },
                                  )
                                : null,
                            filled: true,
                            fillColor: Colors.grey[100],
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 0,
                              horizontal: 16,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          onChanged: (value) => setState(() => _searchQuery = value),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: isSmallScreen ? 12 : 16,
                          vertical: 8,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Calendar',
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: orange,
                                  ),
                                ),
                                _buildCalendarLegend(),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.orange.withOpacity(0.10),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: TableCalendar(
                                firstDay: DateTime.utc(2023, 1, 1),
                                lastDay: DateTime.utc(2030, 12, 31),
                                focusedDay: _focusedDay,
                                selectedDayPredicate: (day) =>
                                    _isDateSelected && isSameDay(_selectedDay, day),
                                onDaySelected: (selectedDay, focusedDay) {
                                  setState(() {
                                    _selectedDay = selectedDay;
                                    _focusedDay = focusedDay;
                                    _isDateSelected = true;
                                  });
                                },
                                calendarStyle: CalendarStyle(
                                  todayDecoration: BoxDecoration(
                                    color: Colors.green.withOpacity(0.5),
                                    shape: BoxShape.circle,
                                  ),
                                  selectedDecoration: BoxDecoration(
                                    color: orange.withOpacity(0.5),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                calendarBuilders: CalendarBuilders(
                                  markerBuilder: (context, date, events) {
                                    final now = DateTime.now();
                                    final today = DateTime(now.year, now.month, now.day);
                                    final targetDay = DateTime(date.year, date.month, date.day);
                                    final hasAppointment = _appointments.any((app) {
                                      final appointmentDate =
                                          DateTime.tryParse(app['preferred_date'] ?? '');
                                      if (appointmentDate == null) return false;
                                      final appointmentDay = DateTime(
                                          appointmentDate.year,
                                          appointmentDate.month,
                                          appointmentDate.day);
                                      return appointmentDay.isAtSameMomentAs(targetDay);
                                    });
                                    if (hasAppointment) {
                                      Color dotColor;
                                      if (targetDay.isBefore(today)) {
                                        dotColor = Colors.blue;
                                      } else if (targetDay.isAtSameMomentAs(today)) {
                                        dotColor = Colors.green;
                                      } else {
                                        dotColor = Colors.orange;
                                      }
                                      return Positioned(
                                        bottom: 1,
                                        child: Container(
                                          width: 7,
                                          height: 7,
                                          decoration: BoxDecoration(
                                            color: dotColor,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      );
                                    }
                                    return null;
                                  },
                                ),
                                eventLoader: (day) =>
                                    _getAppointmentsForDate(day).isNotEmpty ? [1] : [],
                                headerStyle: HeaderStyle(
                                  formatButtonVisible: false,
                                  titleCentered: true,
                                  titleTextStyle: GoogleFonts.poppins(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.black87,
                                  ),
                                ),
                                calendarFormat: CalendarFormat.month,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: isSmallScreen ? 12 : 16,
                          vertical: 12,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _isDateSelected
                                  ? 'Appointments for ${DateFormat('MMMM dd, yyyy').format(_selectedDay)}'
                                  : 'All Appointments',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF5094FF),
                              ),
                            ),
                            _buildSortMenu(),
                          ],
                        ),
                      ),
                      if (_isDateSelected)
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: isSmallScreen ? 12 : 16,
                            vertical: 8,
                          ),
                          child: OutlinedButton.icon(
                            onPressed: () => setState(() => _isDateSelected = false),
                            icon: const Icon(Icons.clear, size: 16),
                            label: Text(
                              'Clear Date Selection',
                              style: GoogleFonts.poppins(fontSize: 12),
                            ),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              side: BorderSide(color: Colors.grey[300]!),
                            ),
                          ),
                        ),
                      if (!_isDateSelected)
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: isSmallScreen ? 12 : 16,
                            vertical: 8,
                          ),
                          child: _buildFilterChips(),
                        ),
                    ],
                  ),
                ),
                SliverPadding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 12 : 16,
                    vertical: 8,
                  ),
                  sliver: _searchedAppointments.isEmpty
                      ? SliverToBoxAdapter(child: _buildEmptyState())
                      : SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final appointment = _searchedAppointments[index];
                              return _buildAppointmentCard(
                                id: appointment['id'],
                                date: appointment['preferred_date'] != null
                                    ? DateFormat('MMMM dd, yyyy').format(
                                        DateTime.parse(appointment['preferred_date']))
                                    : 'N/A',
                                time: appointment['preferred_time'] ?? 'N/A',
                                duration: appointment['estimated_duration'] ?? 0,
                                petName: appointment['pet_name'] ?? 'N/A',
                                services: _getSelectedServices(appointment),
                              );
                            },
                            childCount: _searchedAppointments.length,
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today),
              label: 'Bookings',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.message),
              label: 'Messages',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: const Color(0xFFF5A623),
          unselectedItemColor: Colors.grey,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
        ),
      ),
      floatingActionButton: _showScrollToTop
          ? FloatingActionButton(
              onPressed: _scrollToTop,
              backgroundColor: const Color(0xFFF5A623),
              foregroundColor: Colors.white,
              mini: true,
              child: const Icon(Icons.keyboard_arrow_up),
            )
          : null,
    );
  }
}
