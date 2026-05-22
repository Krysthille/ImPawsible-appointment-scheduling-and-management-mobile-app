// // import 'package:flutter/material.dart';
// // import 'package:google_fonts/google_fonts.dart';
// // import 'package:table_calendar/table_calendar.dart';
// // import 'package:supabase_flutter/supabase_flutter.dart';
// // import 'package:intl/intl.dart';
// // import '../utils/notification_utils.dart';
// // import '../profile/profile_page.dart';
// // import 'grooming_appointment.dart';

// // class GroomingPage extends StatefulWidget {
// //   const GroomingPage({super.key});

// //   @override
// //   State<GroomingPage> createState() => _GroomingPageState();
// // }

// // class _GroomingPageState extends State<GroomingPage> {
// //   int _selectedIndex = 1;
// //   DateTime _focusedDay = DateTime.now();
// //   DateTime _selectedDay = DateTime.now();
// //   List<Map<String, dynamic>> _appointments = [];
// //   String _searchQuery = '';
// //   bool _isDateSelected = false;
// //   String _currentSortType = 'date_desc'; // Track current sort type
// //   String _currentFilter = 'All'; // Add filter state
// //   final ScrollController _scrollController = ScrollController();
// //   bool _showScrollToTop = false;

// //   // Add list of available filters
// //   final List<String> _filters = [
// //     'All',
// //     'Pending',
// //     'Approved',
// //     'Cancelled',
// //     'Cancelled (by user)',
// //     'Completed'
// //   ];

// //   // Define colors for each filter
// //   final Map<String, Color> _filterColors = {
// //     'All': const Color(0xFF5094FF),
// //     'Pending': const Color(0xFFFB8C00),
// //     'Approved': Colors.green,
// //     'Completed': Colors.blue,
// //     'Cancelled': Colors.red,
// //     'Cancelled (by user)': Colors.red.shade700,
// //   };

// //   @override
// //   void initState() {
// //     super.initState();
// //     _fetchAppointments();
// //     _scrollController.addListener(_onScroll);
// //   }

// //   @override
// //   void didChangeDependencies() {
// //     super.didChangeDependencies();
// //     // Refresh appointments when the page becomes active
// //     _fetchAppointments();
// //   }

// //   @override
// //   void dispose() {
// //     _scrollController.removeListener(_onScroll);
// //     _scrollController.dispose();
// //     super.dispose();
// //   }

// //   void _onScroll() {
// //     if (_scrollController.position.pixels > 200) {
// //       if (!_showScrollToTop) {
// //         setState(() {
// //           _showScrollToTop = true;
// //         });
// //       }
// //     } else {
// //       if (_showScrollToTop) {
// //         setState(() {
// //           _showScrollToTop = false;
// //         });
// //       }
// //     }
// //   }

// //   void _scrollToTop() {
// //     _scrollController.animateTo(
// //       0,
// //       duration: const Duration(milliseconds: 500),
// //       curve: Curves.easeInOut,
// //     );
// //   }

// //   void _onItemTapped(int index) {
// //     switch (index) {
// //       case 0:
// //         Navigator.pushReplacementNamed(context, '/home');
// //         break;
// //       case 1:
// //         // Stay on Grooming page
// //         break;
// //       case 2:
// //         Navigator.pushReplacementNamed(context, '/shop');
// //         break;
// //       case 3:
// //         Navigator.pushReplacementNamed(context, '/messages');
// //         break;
// //       case 4:
// //           Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ProfilePage()));
// //         break;
// //     }
// //     setState(() {
// //       _selectedIndex = index;
// //     });
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     final orange = const Color(0xFFF5A623);
// //     return GestureDetector(
// //       onTap: () {
// //         // Dismiss keyboard when tapping outside input fields
// //         FocusScope.of(context).unfocus();
// //       },
// //       child: Scaffold(
// //       backgroundColor: Colors.white,
// //       body: Container(
// //         decoration: const BoxDecoration(
// //           gradient: LinearGradient(
// //             colors: [Color(0xFFFFF6E7), Colors.white],
// //             begin: Alignment.topCenter,
// //             end: Alignment.bottomCenter,
// //           ),
// //         ),
// //         child: SafeArea(
// //           child: SingleChildScrollView(
// //               controller: _scrollController,
// //             child: Column(
// //               crossAxisAlignment: CrossAxisAlignment.start,
// //               children: [
// //                 // Search bar
// //                 Padding(
// //                   padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
// //                   child: TextField(
// //                     decoration: InputDecoration(
// //                       hintText: 'Search by pet name, breed, or service',
// //                       hintStyle: TextStyle(
// //                         fontSize: 14,
// //                         color: Colors.grey[500],
// //                       ),
// //                       prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
// //                       filled: true,
// //                       fillColor: Colors.grey[100],
// //                       contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
// //                       border: OutlineInputBorder(
// //                         borderRadius: BorderRadius.circular(12),
// //                         borderSide: BorderSide.none,
// //                       ),
// //                     ),
// //                     onChanged: (value) {
// //                       setState(() {
// //                         _searchQuery = value;
// //                       });
// //                     },
// //                   ),
// //                 ),
// //                 Padding(
// //                   padding: const EdgeInsets.symmetric(
// //                       horizontal: 16.0, vertical: 8.0),
// //                   child: Row(
// //                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                     children: [
// //                       Text(
// //                         'Calendar',
// //                         style: GoogleFonts.poppins(
// //                           fontSize: 18,
// //                           fontWeight: FontWeight.bold,
// //                           color: orange,
// //                         ),
// //                       ),
// //                       Row(
// //                         children: [
// //                           Container(
// //                             width: 10,
// //                             height: 10,
// //                             decoration: const BoxDecoration(
// //                               color: Colors.blue,
// //                               shape: BoxShape.circle,
// //                             ),
// //                           ),
// //                           const SizedBox(width: 4),
// //                           Text('Completed', style: GoogleFonts.poppins(fontSize: 10)),
// //                           const SizedBox(width: 12),
// //                           Container(
// //                             width: 10,
// //                             height: 10,
// //                             decoration: const BoxDecoration(
// //                               color: Colors.green,
// //                               shape: BoxShape.circle,
// //                             ),
// //                           ),
// //                           const SizedBox(width: 4),
// //                           Text('Today', style: GoogleFonts.poppins(fontSize: 10)),
// //                           const SizedBox(width: 12),
// //                           Container(
// //                             width: 10,
// //                             height: 10,
// //                             decoration: const BoxDecoration(
// //                               color: Colors.orange,
// //                               shape: BoxShape.circle,
// //                             ),
// //                           ),
// //                           const SizedBox(width: 4),
// //                           Text('Upcoming', style: GoogleFonts.poppins(fontSize: 10)),
// //                         ],
// //                       ),
// //                     ],
// //                   ),
// //                 ),
// //                 Padding(
// //                   padding:
// //                       const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
// //                   child: Container(
// //                     decoration: BoxDecoration(
// //                       color: Colors.white,
// //                       borderRadius: BorderRadius.circular(12),
// //                       boxShadow: [
// //                         BoxShadow(
// //                           color: Colors.orange.withOpacity(0.10),
// //                           blurRadius: 8,
// //                           offset: const Offset(0, 4),
// //                         ),
// //                       ],
// //                     ),
// //                     child: TableCalendar(
// //                       firstDay: DateTime.utc(2023, 1, 1),
// //                       lastDay: DateTime.utc(2030, 12, 31),
// //                       focusedDay: _focusedDay,
// //                       selectedDayPredicate: (day) {
// //                         if (!_isDateSelected) return false;
// //                         return isSameDay(_selectedDay, day);
// //                       },
// //                       onDaySelected: (selectedDay, focusedDay) {
// //                         setState(() {
// //                           _selectedDay = selectedDay;
// //                           _focusedDay = focusedDay;
// //                           _isDateSelected = true;
// //                         });
// //                       },
// //                       calendarStyle: CalendarStyle(
// //                         todayDecoration: BoxDecoration(
// //                           color: Colors.green.withOpacity(0.5),
// //                           shape: BoxShape.circle,
// //                         ),
// //                         selectedDecoration: BoxDecoration(
// //                           color: orange.withOpacity(0.5),
// //                           shape: BoxShape.circle,
// //                         ),
// //                       ),
// //                       calendarBuilders: CalendarBuilders(
// //                         markerBuilder: (context, date, events) {
// //                           final now = DateTime.now();
// //                           final today = DateTime(now.year, now.month, now.day);
// //                           final targetDay = DateTime(date.year, date.month, date.day);
// //                           final hasAppointment = _appointments.any((app) {
// //                             final appointmentDate = DateTime.tryParse(app['preferred_date'] ?? '');
// //                             if (appointmentDate == null) return false;
// //                             final appointmentDay = DateTime(appointmentDate.year, appointmentDate.month, appointmentDate.day);
// //                             return appointmentDay.isAtSameMomentAs(targetDay);
// //                           });
// //                           if (hasAppointment) {
// //                             Color dotColor;
// //                             if (targetDay.isBefore(today)) {
// //                               dotColor = Colors.blue;
// //                             } else if (targetDay.isAtSameMomentAs(today)) {
// //                               dotColor = Colors.green;
// //                             } else {
// //                               dotColor = Colors.orange;
// //                             }
// //                             return Positioned(
// //                               bottom: 1,
// //                               child: Container(
// //                                 width: 7,
// //                                 height: 7,
// //                                 decoration: BoxDecoration(
// //                                   color: dotColor,
// //                                   shape: BoxShape.circle,
// //                                 ),
// //                               ),
// //                             );
// //                           }
// //                           return null;
// //                         },
// //                       ),
// //                       eventLoader: (day) {
// //                         final appointments = _getAppointmentsForDate(day);
// //                         if (appointments.isNotEmpty) {
// //                           return [1];
// //                         } else {
// //                           return [];
// //                         }
// //                       },
// //                       headerStyle: HeaderStyle(
// //                         formatButtonVisible: false,
// //                         titleCentered: true,
// //                         titleTextStyle: GoogleFonts.poppins(
// //                             fontWeight: FontWeight.bold,
// //                             fontSize: 16,
// //                             color: Colors.black87),
// //                       ),
// //                       calendarFormat: CalendarFormat.month,
// //                     ),
// //                   ),
// //                 ),
// //                 const SizedBox(height: 16),
// //                 // Book Now button below calendar
// //                 Padding(
// //                   padding: const EdgeInsets.symmetric(horizontal: 16.0),
// //                   child: Align(
// //                     alignment: Alignment.centerRight,
// //                     child: ElevatedButton(
// //                       onPressed: () async {
// //                         // Navigate to the Grooming Appointment page
// //                         await Navigator.push(
// //                           context,
// //                           MaterialPageRoute(
// //                             builder: (context) =>
// //                                 const GroomingAppointmentPage(),
// //                           ),
// //                         );
                        
// //                         // Always refresh appointments when returning from appointment page
// //                         _fetchAppointments();
// //                       },
// //                       style: ElevatedButton.styleFrom(
// //                         backgroundColor: orange,
// //                         foregroundColor: Colors.white,
// //                         shape: RoundedRectangleBorder(
// //                           borderRadius: BorderRadius.circular(20),
// //                         ),
// //                         padding: const EdgeInsets.symmetric(
// //                             horizontal: 20, vertical: 8),
// //                         elevation: 0,
// //                       ),
// //                       child: Text('Book Now',
// //                           style: GoogleFonts.poppins(
// //                               fontSize: 14, fontWeight: FontWeight.bold)),
// //                     ),
// //                   ),
// //                 ),
// //                 const SizedBox(height: 24),
// //                 Padding(
// //                   padding: const EdgeInsets.symmetric(horizontal: 16.0),
// //                   child: Row(
// //                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                     children: [
// //                       Text(
// //                         _isDateSelected
// //                             ? 'Appointments for ${DateFormat('MMMM dd, yyyy').format(_selectedDay)}'
// //                             : 'All Appointments',
// //                         style: GoogleFonts.poppins(
// //                           fontSize: 16,
// //                           fontWeight: FontWeight.bold,
// //                           color: const Color(0xFF5094FF),
// //                         ),
// //                       ),
// //                       PopupMenuButton<String>(
// //                         onSelected: (value) {
// //                           setState(() {
// //                             _currentSortType = value;
// //                           });
// //                         },
// //                         itemBuilder: (context) => [
// //                           PopupMenuItem(
// //                             value: 'name_asc',
// //                             child: Text('Name (A–Z)', style: GoogleFonts.poppins(fontSize: 13)),
// //                           ),
// //                           PopupMenuItem(
// //                             value: 'name_desc',
// //                             child: Text('Name (Z–A)', style: GoogleFonts.poppins(fontSize: 13)),
// //                           ),
// //                           PopupMenuItem(
// //                             value: 'date_asc',
// //                             child: Text('By Appointment (Oldest First)', style: GoogleFonts.poppins(fontSize: 13)),
// //                           ),
// //                           PopupMenuItem(
// //                             value: 'date_desc',
// //                             child: Text('By Appointment (Newest First)', style: GoogleFonts.poppins(fontSize: 13)),
// //                           ),
// //                         ],
// //                         child: Row(
// //                           children: [
// //                             Icon(Icons.sort, color: Colors.grey[600], size: 20),
// //                             const SizedBox(width: 4),
// //                             Text(
// //                               'Sort',
// //                               style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
// //                             ),
// //                           ],
// //                         ),
// //                       ),
// //                     ],
// //                   ),
// //                 ),
// //                 const SizedBox(height: 16),
// //                 if (_isDateSelected) ...[
// //                   Padding(
// //                     padding: const EdgeInsets.symmetric(horizontal: 16.0),
// //                     child: Row(
// //                       children: [
// //                         Expanded(
// //                           child: OutlinedButton.icon(
// //                             onPressed: () {
// //                               setState(() {
// //                                 _isDateSelected = false;
// //                               });
// //                             },
// //                             icon: const Icon(Icons.clear, size: 16),
// //                             label: Text(
// //                               'Clear Date Selection',
// //                               style: GoogleFonts.poppins(fontSize: 12),
// //                             ),
// //                             style: OutlinedButton.styleFrom(
// //                               padding: const EdgeInsets.symmetric(vertical: 8),
// //                               side: BorderSide(color: Colors.grey[300]!),
// //                             ),
// //                           ),
// //                         ),
// //                       ],
// //                     ),
// //                   ),
// //                   const SizedBox(height: 8),
// //                 ],
// //                 // Add filter buttons (only show when not in date selection mode)
// //                 if (!_isDateSelected) ...[
// //                   SingleChildScrollView(
// //                     scrollDirection: Axis.horizontal,
// //                     padding: const EdgeInsets.symmetric(horizontal: 16.0),
// //                     child: Row(
// //                       children: _filters.map((filter) {
// //                         final isSelected = _currentFilter == filter;
// //                         return Padding(
// //                           padding: const EdgeInsets.only(right: 8.0),
// //                           child: FilterChip(
// //                             label: Text(
// //                               filter,
// //                               style: GoogleFonts.poppins(
// //                                 color: isSelected
// //                                     ? Colors.white
// //                                       : _filterColors[filter] ?? const Color(0xFF5094FF),
// //                                 fontSize: 12,
// //                               ),
// //                             ),
// //                             selected: isSelected,
// //                             onSelected: (selected) {
// //                               setState(() {
// //                                 _currentFilter = filter;
// //                               });
// //                             },
// //                             backgroundColor: Colors.white,
// //                               selectedColor: _filterColors[filter] ?? const Color(0xFF5094FF),
// //                             checkmarkColor: Colors.white,
// //                             side: BorderSide(
// //                               color: isSelected
// //                                     ? _filterColors[filter] ?? const Color(0xFF5094FF)
// //                                   : Colors.grey[300]!,
// //                             ),
// //                           ),
// //                         );
// //                       }).toList(),
// //                     ),
// //                   ),
// //                 ],
// //                 Container(
// //                   margin: const EdgeInsets.symmetric(horizontal: 16.0),
// //                   padding: const EdgeInsets.all(16.0),
// //                   decoration: BoxDecoration(
// //                     color: const Color(0xFFE6F0FF),
// //                     borderRadius: BorderRadius.circular(16),
// //                   ),
// //                   child: _filteredAndSearchedAppointments.isEmpty
// //                       ? Center(
// //                           child: Text(
// //                             'No appointments found',
// //                             style: GoogleFonts.poppins(
// //                               fontSize: 16,
// //                               color: Colors.grey,
// //                             ),
// //                           ),
// //                         )
// //                       : Column(
// //                           children: _filteredAndSearchedAppointments.map((appointment) {
// //                             // Determine status color based on appointment status
// //                             Color statusColor;
// //                             Color statusTextColor;
// //                             String status = appointment['status'] ?? 'Pending';
// //                             switch (status) {
// //                               case 'Approved':
// //                                 statusColor = const Color(0xFFE8F5E9);
// //                                 statusTextColor = Colors.green;
// //                                 break;
// //                               case 'Cancelled':
// //                               case 'Cancelled (by user)':
// //                                 statusColor = const Color(0xFFFFEBEE);
// //                                 statusTextColor = Colors.red;
// //                                 break;
// //                               case 'Completed':
// //                                 statusColor = const Color(0xFFE3F2FD);
// //                                 statusTextColor = Colors.blue;
// //                                 break;
// //                               default: // Pending
// //                                 statusColor = const Color(0xFFFFF3E0);
// //                                 statusTextColor = const Color(0xFFFB8C00);
// //                             }
// //                             return _buildAppointmentCard(
// //                               id: appointment['id'],
// //                               date: appointment['preferred_date'] != null
// //                                   ? DateFormat('MMMM dd, yyyy').format(
// //                                       DateTime.parse(
// //                                           appointment['preferred_date']))
// //                                   : 'N/A',
// //                               time: appointment['preferred_time'] ?? 'N/A',
// //                               duration: appointment['estimated_duration'] ?? 0,
// //                               status: status,
// //                               petName: appointment['pet_name'] ?? 'N/A',
// //                               services: _getSelectedServices(appointment),
// //                               statusColor: statusColor,
// //                               statusTextColor: statusTextColor,
// //                               onEdit: () => _editAppointment(appointment),
// //                             );
// //                           }).toList(),
// //                         ),
// //                 ),
// //               ],
// //             ),
// //           ),
// //         ),
// //       ),
// //       bottomNavigationBar: _bottomNavBar(orange),
// //         floatingActionButton: _showScrollToTop
// //             ? FloatingActionButton(
// //                 onPressed: _scrollToTop,
// //                 backgroundColor: orange,
// //                 foregroundColor: Colors.white,
// //                 mini: true,
// //                 child: const Icon(Icons.keyboard_arrow_up),
// //               )
// //             : null,
// //       ),
// //     );
// //   }

// //   // Filter appointments by selected date and search query
// //   List<Map<String, dynamic>> get _filteredAndSearchedAppointments {
// //     List<Map<String, dynamic>> appointmentsToSort;
    
// //     if (_isDateSelected) {
// //       appointmentsToSort = _appointments.where((app) {
// //         final appointmentDate = DateTime.tryParse(app['preferred_date'] ?? '');
// //         if (appointmentDate == null) return false;
// //         final selectedDay = DateTime(_selectedDay.year, _selectedDay.month, _selectedDay.day);
// //         final appointmentDay = DateTime(appointmentDate.year, appointmentDate.month, appointmentDate.day);
// //         return appointmentDay.isAtSameMomentAs(selectedDay);
// //       }).toList();
// //     } else {
// //       appointmentsToSort = _appointments;
// //     }
    
// //     // Apply status filter
// //     if (_currentFilter != 'All') {
// //       appointmentsToSort = appointmentsToSort.where((app) => app['status'] == _currentFilter).toList();
// //     }
    
// //     // Apply search filter
// //     if (_searchQuery.isNotEmpty) {
// //       final query = _searchQuery.toLowerCase();
// //       appointmentsToSort = appointmentsToSort.where((app) {
// //         final petName = (app['pet_name'] ?? '').toString().toLowerCase();
// //         final breed = (app['breed'] ?? '').toString().toLowerCase();
// //         final services = <String>[];
// //         if (app['service_bath'] == true) services.add('bath');
// //         if (app['service_haircut'] == true) services.add('haircut');
// //         if (app['service_nail_trim'] == true) services.add('nail trim');
// //         if (app['service_ear_cleaning'] == true) services.add('ear cleaning');
// //         final servicesString = services.join(', ').toLowerCase();
// //         return petName.contains(query) || breed.contains(query) || servicesString.contains(query);
// //       }).toList();
// //     }
    
// //     // Apply sorting based on current sort type
// //     appointmentsToSort.sort((a, b) {
// //       switch (_currentSortType) {
// //         case 'name_asc':
// //           final nameA = (a['pet_name'] ?? '').toString().toLowerCase();
// //           final nameB = (b['pet_name'] ?? '').toString().toLowerCase();
// //           return nameA.compareTo(nameB);
// //         case 'name_desc':
// //           final nameA = (a['pet_name'] ?? '').toString().toLowerCase();
// //           final nameB = (b['pet_name'] ?? '').toString().toLowerCase();
// //           return nameB.compareTo(nameA);
// //         case 'date_asc':
// //           final dateA = DateTime.tryParse(a['preferred_date'] ?? '') ?? DateTime(2000);
// //           final dateB = DateTime.tryParse(b['preferred_date'] ?? '') ?? DateTime(2000);
// //           return dateA.compareTo(dateB);
// //         case 'date_desc':
// //           final dateA = DateTime.tryParse(a['preferred_date'] ?? '') ?? DateTime(2000);
// //           final dateB = DateTime.tryParse(b['preferred_date'] ?? '') ?? DateTime(2000);
// //           return dateB.compareTo(dateA);
// //         default:
// //           final dateA = DateTime.tryParse(a['preferred_date'] ?? '') ?? DateTime(2000);
// //           final dateB = DateTime.tryParse(b['preferred_date'] ?? '') ?? DateTime(2000);
// //           return dateA.compareTo(dateB);
// //       }
// //     });
    
// //     return appointmentsToSort;
// //   }

// //   // Get appointments for a specific date
// //   List<Map<String, dynamic>> _getAppointmentsForDate(DateTime date) {
// //     return _appointments.where((app) {
// //       final appointmentDate = DateTime.tryParse(app['preferred_date'] ?? '');
// //       if (appointmentDate == null) return false;
// //       final targetDay = DateTime(date.year, date.month, date.day);
// //       final appointmentDay = DateTime(appointmentDate.year, appointmentDate.month, appointmentDate.day);
// //       return appointmentDay.isAtSameMomentAs(targetDay);
// //     }).toList();
// //   }

// //   Widget _bottomNavBar(Color orange) {
// //     return BottomNavigationBar(
// //       type: BottomNavigationBarType.fixed,
// //       backgroundColor: Colors.white,
// //       selectedItemColor: orange,
// //       unselectedItemColor: Colors.grey[400],
// //       showSelectedLabels: true,
// //       showUnselectedLabels: true,
// //       currentIndex: _selectedIndex,
// //       onTap: _onItemTapped,
// //       items: const [
// //         BottomNavigationBarItem(
// //           icon: Icon(Icons.home),
// //           label: 'Home',
// //         ),
// //         BottomNavigationBarItem(
// //           icon: Icon(Icons.pets),
// //           label: 'Grooming',
// //         ),
// //         BottomNavigationBarItem(
// //           icon: Icon(Icons.shopping_bag_outlined),
// //           label: 'Shop',
// //         ),
// //         BottomNavigationBarItem(
// //           icon: Icon(Icons.message_outlined),
// //           label: 'Messages',
// //         ),
// //         BottomNavigationBarItem(
// //           icon: Icon(Icons.person_outline),
// //           label: 'Profile',
// //         ),
// //       ],
// //     );
// //   }

// //   Widget _buildAppointmentCard({
// //     required String id,
// //     required String date,
// //     required String time,
// //     required int duration,
// //     required String status,
// //     required String petName,
// //     required String services,
// //     required Color statusColor,
// //     required Color statusTextColor,
// //     required VoidCallback onEdit,
// //   }) {
// //     return Container(
// //       margin: const EdgeInsets.only(bottom: 12.0),
// //       padding: const EdgeInsets.all(16.0),
// //       decoration: BoxDecoration(
// //         color: Colors.white,
// //         borderRadius: BorderRadius.circular(12),
// //         boxShadow: [
// //           BoxShadow(
// //             color: Colors.black.withOpacity(0.05),
// //             blurRadius: 4,
// //             offset: const Offset(0, 2),
// //           ),
// //         ],
// //       ),
// //       child: Column(
// //         crossAxisAlignment: CrossAxisAlignment.start,
// //         children: [
// //           Row(
// //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //             children: [
// //               Column(
// //                 crossAxisAlignment: CrossAxisAlignment.start,
// //                 children: [
// //                   Text(
// //                     petName,
// //                     style: GoogleFonts.poppins(
// //                       fontSize: 16,
// //                       fontWeight: FontWeight.bold,
// //                       color: const Color(0xFF5094FF),
// //                     ),
// //                   ),
// //                   const SizedBox(height: 4),
// //                   Text(
// //                     date,
// //                     style: GoogleFonts.poppins(
// //                       fontSize: 14,
// //                       color: Colors.black87,
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //               Row(
// //                 children: [
// //                   Container(
// //                     padding:
// //                         const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
// //                     decoration: BoxDecoration(
// //                       color: statusColor,
// //                       borderRadius: BorderRadius.circular(8),
// //                     ),
// //                     child: Text(
// //                       status,
// //                       style: GoogleFonts.poppins(
// //                         fontSize: status == 'Cancelled (by user)' ? 10 : 12,
// //                         color: statusTextColor,
// //                       ),
// //                     ),
// //                   ),
// //                   const SizedBox(width: 8),
// //                   IconButton(
// //                     icon: Icon(Icons.edit,
// //                         size: 20,
// //                         color: status == 'Pending'
// //                             ? Colors.blue
// //                             : Colors.grey),
// //                     onPressed: status == 'Pending' ? onEdit : null,
// //                     visualDensity: VisualDensity.compact,
// //                     tooltip: status == 'Pending'
// //                         ? 'Edit appointment'
// //                         : 'Cannot edit ${status.toLowerCase()} appointment',
// //                   ),
// //                   IconButton(
// //                     icon: Icon(Icons.cancel_outlined,
// //                         size: 20,
// //                         color:
// //                             status == 'Pending' ? Colors.red : Colors.grey),
// //                     onPressed: status == 'Pending'
// //                         ? () => _cancelAppointment(id)
// //                         : null,
// //                     visualDensity: VisualDensity.compact,
// //                     tooltip: status == 'Pending'
// //                         ? 'Cancel appointment'
// //                         : 'Cannot cancel ${status.toLowerCase()} appointment',
// //                   ),
// //                 ],
// //               ),
// //             ],
// //           ),
// //           const SizedBox(height: 12),
// //           Row(
// //             children: [
// //               const Icon(Icons.access_time, size: 16, color: Colors.black54),
// //               const SizedBox(width: 4),
// //               Text(
// //                 _formatTime(time),
// //                 style: GoogleFonts.poppins(
// //                   fontSize: 14,
// //                   color: Colors.black87,
// //                 ),
// //               ),
// //               const SizedBox(width: 16),
// //               const Icon(Icons.timer_outlined,
// //                   size: 16, color: Color(0xFF5094FF)),
// //               const SizedBox(width: 4),
// //               Text(
// //                 _formatDuration(duration),
// //                 style: GoogleFonts.poppins(
// //                   fontSize: 14,
// //                   color: const Color(0xFF5094FF),
// //                 ),
// //               ),
// //             ],
// //           ),
// //           const SizedBox(height: 12),
// //           Container(
// //             padding: const EdgeInsets.all(12),
// //             decoration: BoxDecoration(
// //               color: const Color(0xFFF8F9FA),
// //               borderRadius: BorderRadius.circular(8),
// //             ),
// //             child: Row(
// //               children: [
// //                 const Icon(Icons.pets, size: 20, color: Color(0xFF5094FF)),
// //                 const SizedBox(width: 8),
// //                 Expanded(
// //                   child: Text(
// //                     services,
// //                     style: GoogleFonts.poppins(
// //                       fontSize: 14,
// //                       fontWeight: FontWeight.w500,
// //                       color: Colors.black87,
// //                     ),
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   Future<void> _fetchAppointments() async {
// //     try {
// //       final userId = Supabase.instance.client.auth.currentUser?.id;
// //       if (userId == null) {
// //         debugPrint('User not logged in');
// //         return;
// //       }
// //       debugPrint('Fetching appointments for user ID: $userId');
// //       final response = await Supabase.instance.client
// //           .from('grooming_appointments')
// //           .select(
// //               'id, pet_name, pet_type, pet_type_other, breed, pet_size, age, gender, allergies_medical_conditions, preferred_date, preferred_time, estimated_duration, service_bath, service_haircut, service_nail_trim, service_ear_cleaning, special_requests_notes, estimated_cost, payment_method, consent_photos, status')
// //           .eq('user_id', userId)
// //           .order('preferred_date', ascending: true);

// //       if (response != null && response is List) {
// //         debugPrint('Supabase response: $response');
// //         setState(() {
// //           _appointments = response.cast<Map<String, dynamic>>();
// //         });
// //         debugPrint('Appointments fetched: ${_appointments.length}');
// //       } else {
// //         debugPrint(
// //             'No appointments found or unexpected response format: $response');
// //       }
// //     } catch (e) {
// //       debugPrint('Error fetching appointments: $e');
// //     }
// //   }

// //   String _getSelectedServices(Map<String, dynamic> appointment) {
// //     final services = <String>[];
// //     if (appointment['service_bath'] == true) services.add('Bath');
// //     if (appointment['service_haircut'] == true) services.add('Haircut');
// //     if (appointment['service_nail_trim'] == true) services.add('Nail Trim');
// //     if (appointment['service_ear_cleaning'] == true)
// //       services.add('Ear Cleaning');
// //     return services.join(', ');
// //   }

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

// //   String _formatTime(String time) {
// //     try {
// //       final timeOfDay = TimeOfDay(
// //         hour: int.parse(time.split(':')[0]),
// //         minute: int.parse(time.split(':')[1]),
// //       );
// //       return timeOfDay.format(context);
// //     } catch (e) {
// //       return time; // Return original time if parsing fails
// //     }
// //   }

// //   Future<void> _cancelAppointment(String appointmentId) async {
// //     final confirm = await showDialog<bool>(
// //   context: context,
// //   builder: (context) => AlertDialog(
// //     title: const Text(
// //       'Cancel Appointment',
// //       style: TextStyle(
// //         color: Colors.orange,
// //         fontWeight: FontWeight.bold,
// //         fontSize: 18,
// //       ),
// //     ),
// //     content: const Text(
// //       'Are you sure you want to cancel this appointment? This will free up the time slot for other users to book. This action cannot be undone.',
// //       style: TextStyle(fontSize: 16),
// //     ),
// //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
// //     actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
// //     actions: [
// //       ElevatedButton(
// //         style: ElevatedButton.styleFrom(
// //           backgroundColor: Colors.grey[400],
// //           foregroundColor: Colors.white,
// //           shape: RoundedRectangleBorder(
// //             borderRadius: BorderRadius.circular(10),
// //           ),
// //           padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
// //           elevation: 0,
// //         ),
// //         onPressed: () => Navigator.pop(context, false),
// //         child: const Text('No'),
// //       ),
// //       ElevatedButton(
// //         style: ElevatedButton.styleFrom(
// //           backgroundColor: Colors.orange.withOpacity(0.7),
// //           foregroundColor: Colors.white,
// //           shape: RoundedRectangleBorder(
// //             borderRadius: BorderRadius.circular(10),
// //           ),
// //           padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
// //           elevation: 2,
// //           shadowColor: Colors.orange.withOpacity(0.2),
// //         ),
// //         onPressed: () => Navigator.pop(context, true),
// //         child: const Text('Yes', style: TextStyle(fontWeight: FontWeight.bold)),
// //       ),
// //     ],
// //   ),
// // );

// // if (confirm != true) return;

// //     try {
// //       await Supabase.instance.client
// //           .from('grooming_appointments')
// //           .update({'status': 'Cancelled (by user)'}).eq('id', appointmentId);

// //       // Fetch appointment details for the message
// //       Map<String, dynamic>? appointment;
// //       try {
// //         appointment = _appointments.firstWhere((a) => a['id'] == appointmentId);
// //       } catch (_) {
// //         appointment = null;
// //       }
// //       final user = Supabase.instance.client.auth.currentUser;
// //       if (appointment != null && user != null) {
// //         final petName = appointment['pet_name'] ?? '';
// //         final date = appointment['preferred_date'] ?? '';
// //         final time = appointment['preferred_time'] ?? '';
// //         // Fetch user's full name from the users table
// //         String userFullName = '';
// //         try {
// //           final userResp = await Supabase.instance.client
// //               .from('users')
// //               .select('full_name')
// //               .eq('id', user.id)
// //               .maybeSingle();
// //           userFullName = userResp != null ? userResp['full_name'] ?? user.id : user.id;
// //         } catch (e) {
// //           userFullName = user.id;
// //         }
// //         final message = 'User $userFullName has cancelled the grooming appointment for $petName on $date at $time. The time slot is now available for booking.';
// //         await Supabase.instance.client
// //             .from('admin_messages')
// //             .insert({
// //               'user_id': user.id,
// //               'appointment_id': appointmentId,
// //               'message': message,
// //             });
// //       }

// //       if (mounted) {
// //         ScaffoldMessenger.of(context).showSnackBar(
// //           const SnackBar(
// //             content: Text('Appointment cancelled successfully! The time slot is now available for other users.'),
// //             backgroundColor: Colors.green,
// //             duration: Duration(seconds: 4),
// //           ),
// //         );
// //       }
// //       // Refresh the list after cancellation
// //       _fetchAppointments();
// //     } catch (e) {
// //       if (mounted) {
// //         ScaffoldMessenger.of(context).showSnackBar(
// //           SnackBar(
// //             content: Text('Error cancelling appointment: $e'),
// //             backgroundColor: Colors.red,
// //           ),
// //         );
// //       }
// //     }
// //   }

// //   void _editAppointment(Map<String, dynamic> appointment) async {
// //     await Navigator.push(
// //       context,
// //       MaterialPageRoute(
// //         builder: (context) => GroomingAppointmentPage(appointment: appointment),
// //       ),
// //     );

// //     // Always refresh appointments when returning from edit appointment page
// //     _fetchAppointments();
// //   }
// // }


// // NEW


// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:table_calendar/table_calendar.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:intl/intl.dart';
// import '../utils/notification_utils.dart';
// import '../profile/profile_page.dart';
// import 'grooming_appointment.dart';

// class GroomingPage extends StatefulWidget {
//   const GroomingPage({super.key});

//   @override
//   State<GroomingPage> createState() => _GroomingPageState();
// }

// class _GroomingPageState extends State<GroomingPage> {
//   int _selectedIndex = 1;
//   DateTime _focusedDay = DateTime.now();
//   DateTime _selectedDay = DateTime.now();
//   List<Map<String, dynamic>> _appointments = [];
//   String _searchQuery = '';
//   bool _isDateSelected = false;
//   String _currentSortType = 'date_desc';
//   String _currentFilter = 'All';
//   final ScrollController _scrollController = ScrollController();
//   bool _showScrollToTop = false;

//   final List<String> _filters = [
//     'All',
//     'Pending',
//     'Approved',
//     'Cancelled',
//     'Cancelled (by user)',
//     'Completed'
//   ];

//   final Map<String, Color> _filterColors = {
//     'All': const Color(0xFF5094FF),
//     'Pending': const Color(0xFFFB8C00),
//     'Approved': Colors.green,
//     'Completed': Colors.blue,
//     'Cancelled': Colors.red,
//     'Cancelled (by user)': Colors.red.shade700,
//   };

//   @override
//   void initState() {
//     super.initState();
//     _fetchAppointments();
//     _scrollController.addListener(_onScroll);
//   }

//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     _fetchAppointments();
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

//   void _onItemTapped(int index) {
//     switch (index) {
//       case 0:
//         Navigator.pushReplacementNamed(context, '/home');
//         break;
//       case 1:
//         // Navigator.pushReplacementNamed(context, '/shop');
//         break;
//       case 2:
//         Navigator.pushReplacementNamed(context, '/messages');
//         break;
//       case 3:
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (_) => const ProfilePage())
//         );
//         break;
//     }
//     setState(() => _selectedIndex = index);
//   }

//   // Helper method to format time
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

//   // Helper method to format duration
//   String _formatDuration(int minutes) {
//     if (minutes < 60) return '$minutes minutes';
//     final hours = minutes ~/ 60;
//     final remainingMinutes = minutes % 60;
//     if (remainingMinutes == 0) return '$hours hour${hours > 1 ? 's' : ''}';
//     return '$hours hour${hours > 1 ? 's' : ''} and $remainingMinutes minutes';
//   }

//   // Helper method to get selected services
//   String _getSelectedServices(Map<String, dynamic> appointment) {
//     final services = <String>[];
//     if (appointment['service_bath'] == true) services.add('Bath');
//     if (appointment['service_haircut'] == true) services.add('Haircut');
//     if (appointment['service_nail_trim'] == true) services.add('Nail Trim');
//     if (appointment['service_ear_cleaning'] == true) services.add('Ear Cleaning');
//     return services.join(', ');
//   }

//   // Fetch appointments from Supabase
//   Future<void> _fetchAppointments() async {
//     try {
//       final userId = Supabase.instance.client.auth.currentUser?.id;
//       if (userId == null) return;

//       final response = await Supabase.instance.client
//           .from('grooming_appointments')
//           .select('''
//             id, pet_name, pet_type, pet_type_other, breed, pet_size, age, gender,
//             allergies_medical_conditions, preferred_date, preferred_time,
//             estimated_duration, service_bath, service_haircut, service_nail_trim,
//             service_ear_cleaning, special_requests_notes, estimated_cost,
//             payment_method, consent_photos, status
//           ''')
//           .eq('user_id', userId)
//           .order('preferred_date', ascending: true);

//       if (response is List) {
//         setState(() => _appointments = response.cast<Map<String, dynamic>>());
//       }
//     } catch (e) {
//       debugPrint('Error fetching appointments: $e');
//     }
//   }

//   // Get appointments for a specific date
//   List<Map<String, dynamic>> _getAppointmentsForDate(DateTime date) {
//     return _appointments.where((app) {
//       final appointmentDate = DateTime.tryParse(app['preferred_date'] ?? '');
//       if (appointmentDate == null) return false;
//       final targetDay = DateTime(date.year, date.month, date.day);
//       final appointmentDay = DateTime(appointmentDate.year, appointmentDate.month, appointmentDate.day);
//       return appointmentDay.isAtSameMomentAs(targetDay);
//     }).toList();
//   }

//   // Filtered and sorted appointments
//   List<Map<String, dynamic>> get _filteredAndSearchedAppointments {
//     List<Map<String, dynamic>> appointmentsToSort = _isDateSelected
//         ? _appointments.where((app) {
//             final appointmentDate = DateTime.tryParse(app['preferred_date'] ?? '');
//             if (appointmentDate == null) return false;
//             final selectedDay = DateTime(_selectedDay.year, _selectedDay.month, _selectedDay.day);
//             final appointmentDay = DateTime(appointmentDate.year, appointmentDate.month, appointmentDate.day);
//             return appointmentDay.isAtSameMomentAs(selectedDay);
//           }).toList()
//         : List.from(_appointments);

//     // Apply status filter
//     if (_currentFilter != 'All') {
//       appointmentsToSort = appointmentsToSort.where((app) => app['status'] == _currentFilter).toList();
//     }

//     // Apply search filter
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

//     // Apply sorting
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

//   // Cancel appointment
//   Future<void> _cancelAppointment(String appointmentId) async {
//     final confirm = await showDialog<bool>(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text(
//           'Cancel Appointment',
//           style: TextStyle(
//             color: Colors.red,
//             fontWeight: FontWeight.bold,
//             fontSize: 18,
//           ),
//         ),
//         content: const Text(
//           'Are you sure you want to cancel this appointment? This will free up the time slot for other users to book. This action cannot be undone.',
//           style: TextStyle(fontSize: 16),
//         ),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//         actions: [
//           ElevatedButton(
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.grey[400],
//               foregroundColor: Colors.white,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
//               elevation: 0,
//             ),
//             onPressed: () => Navigator.pop(context, false),
//             child: const Text('No'),
//           ),
//           ElevatedButton(
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.red.withOpacity(0.7),
//               foregroundColor: Colors.white,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
//               elevation: 2,
//               shadowColor: Colors.orange.withOpacity(0.2),
//             ),
//             onPressed: () => Navigator.pop(context, true),
//             child: const Text('Yes', style: TextStyle(fontWeight: FontWeight.bold)),
//           ),
//         ],
//       ),
//     );

//     if (confirm != true) return;

//     try {
//       await Supabase.instance.client
//           .from('grooming_appointments')
//           .update({'status': 'Cancelled (by user)'})
//           .eq('id', appointmentId);

//       // Send notification to admin
//       final user = Supabase.instance.client.auth.currentUser;
//       if (user != null) {
//         final appointment = _appointments.firstWhere((a) => a['id'] == appointmentId);
//         final petName = appointment['pet_name'] ?? '';
//         final date = appointment['preferred_date'] ?? '';
//         final time = appointment['preferred_time'] ?? '';

//         String userFullName = user.id;
//         try {
//           final userResp = await Supabase.instance.client
//               .from('users')
//               .select('full_name')
//               .eq('id', user.id)
//               .maybeSingle();
//           userFullName = userResp?['full_name'] ?? user.id;
//         } catch (e) {
//           debugPrint('Error fetching user name: $e');
//         }

//         final message = 'User $userFullName has cancelled the grooming appointment for $petName on $date at $time. The time slot is now available for booking.';
//         await Supabase.instance.client.from('admin_messages').insert({
//           'user_id': user.id,
//           'appointment_id': appointmentId,
//           'message': message,
//           'is_from_admin': false,
//         });
//       }

//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Appointment cancelled successfully! The time slot is now available for other users.'),
//             backgroundColor: Colors.green,
//             duration: Duration(seconds: 4),
//           ),
//         );
//         _fetchAppointments();
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Error cancelling appointment: $e'),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     }
//   }

//   // Edit appointment
//   void _editAppointment(Map<String, dynamic> appointment) async {
//     await Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => GroomingAppointmentPage(appointment: appointment),
//       ),
//     );
//     _fetchAppointments();
//   }

//   // Build appointment card with responsive layout
//   Widget _buildAppointmentCard({
//     required Map<String, dynamic> appointment,
//     required VoidCallback onEdit,
//     required VoidCallback onCancel,
//   }) {
//     final status = appointment['status'] ?? 'Pending';
//     final petName = appointment['pet_name'] ?? 'Unknown Pet';
//     final date = appointment['preferred_date'] != null
//         ? DateFormat('MMMM dd, yyyy').format(DateTime.parse(appointment['preferred_date']))
//         : 'N/A';
//     final time = appointment['preferred_time'] ?? 'N/A';
//     final duration = appointment['estimated_duration'] ?? 0;
//     final services = _getSelectedServices(appointment);

//     // Status styling
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
//     final isEditable = status == 'Pending';
//     final screenWidth = MediaQuery.of(context).size.width;
//     final isSmallScreen = screenWidth < 360;

//     return Container(
//       margin: const EdgeInsets.only(bottom: 12),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 6,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(16),
//         child: Material(
//           color: Colors.transparent,
//           child: InkWell(
//             onTap: () => _editAppointment(appointment),
//             child: Padding(
//               padding: const EdgeInsets.all(16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Header with pet name and status
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
//                         constraints: BoxConstraints(
//                           maxWidth: isSmallScreen ? 90 : 110,
//                         ),
//                         child: Row(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             Icon(style['icon'], size: 14, color: style['textColor']),
//                             const SizedBox(width: 4),
//                             Flexible(
//                               child: Text(
//                                 status == 'Cancelled (by user)' ? 'Cancelled' : status,
//                                 style: GoogleFonts.poppins(
//                                   fontSize: 11,
//                                   color: style['textColor'],
//                                   fontWeight: FontWeight.w500,
//                                 ),
//                                 overflow: TextOverflow.ellipsis,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),

//                   const SizedBox(height: 12),

//                   // Date, time, and duration row
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

//                   // Services section
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

//                   const SizedBox(height: 12),

//                   // Action buttons
//                   if (isEditable)
//                     isSmallScreen
//                         ? Column(
//                             children: [
//                               SizedBox(
//                                 width: double.infinity,
//                                 child: OutlinedButton.icon(
//                                   onPressed: onCancel,
//                                   icon: const Icon(Icons.cancel, size: 16, color: Colors.red),
//                                   label: Text(
//                                     'Cancel',
//                                     style: GoogleFonts.poppins(
//                                       fontSize: 12,
//                                       color: Colors.red,
//                                     ),
//                                   ),
//                                   style: OutlinedButton.styleFrom(
//                                     padding: const EdgeInsets.symmetric(vertical: 8),
//                                   ),
//                                 ),
//                               ),
//                               const SizedBox(height: 8),
//                               SizedBox(
//                                 width: double.infinity,
//                                 child: ElevatedButton.icon(
//                                   onPressed: onEdit,
//                                   icon: const Icon(Icons.edit, size: 16, color: Colors.white),
//                                   label: Text(
//                                     'Edit',
//                                     style: GoogleFonts.poppins(
//                                       fontSize: 12,
//                                       color: Colors.white,
//                                       fontWeight: FontWeight.w500,
//                                     ),
//                                   ),
//                                   style: ElevatedButton.styleFrom(
//                                     backgroundColor: const Color(0xFFF5A623),
//                                     shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(8),
//                                     ),
//                                     padding: const EdgeInsets.symmetric(vertical: 8),
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           )
//                         : Row(
//                             mainAxisAlignment: MainAxisAlignment.end,
//                             children: [
//                               TextButton.icon(
//                                 onPressed: onCancel,
//                                 icon: const Icon(Icons.cancel, size: 16, color: Colors.red),
//                                 label: Text(
//                                   'Cancel',
//                                   style: GoogleFonts.poppins(
//                                     fontSize: 12,
//                                     color: Colors.red,
//                                   ),
//                                 ),
//                               ),
//                               const SizedBox(width: 12),
//                               ElevatedButton.icon(
//                                 onPressed: onEdit,
//                                 icon: const Icon(Icons.edit, size: 16, color: Colors.white),
//                                 label: Text(
//                                   'Edit',
//                                   style: GoogleFonts.poppins(
//                                     fontSize: 12,
//                                     color: Colors.white,
//                                     fontWeight: FontWeight.w500,
//                                   ),
//                                 ),
//                                 style: ElevatedButton.styleFrom(
//                                   backgroundColor: const Color(0xFFF5A623),
//                                   shape: RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.circular(8),
//                                   ),
//                                   padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//                                 ),
//                               ),
//                             ],
//                           ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   // Build calendar legend
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

//   // Build legend item
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

//   // Build empty state
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
//                 : 'You don\'t have any appointments yet.',
//             style: GoogleFonts.poppins(
//               fontSize: 14,
//               color: Colors.grey[500],
//             ),
//             textAlign: TextAlign.center,
//           ),
//           const SizedBox(height: 20),
//           ElevatedButton(
//             onPressed: () async {
//               await Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => const GroomingAppointmentPage(),
//                 ),
//               );
//               _fetchAppointments();
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: const Color(0xFFF5A623),
//               foregroundColor: Colors.white,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(20),
//               ),
//               padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
//             ),
//             child: Text(
//               'Book Your First Appointment',
//               style: GoogleFonts.poppins(
//                 fontSize: 14,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // Build sort menu
//   Widget _buildSortMenu() {
//     return PopupMenuButton<String>(
//       onSelected: (value) => setState(() => _currentSortType = value),
//       itemBuilder: (context) => [
//         PopupMenuItem(
//           value: 'name_asc',
//           child: Text('Name (A-Z)', style: GoogleFonts.poppins(fontSize: 13)),
//         ),
//         PopupMenuItem(
//           value: 'name_desc',
//           child: Text('Name (Z-A)', style: GoogleFonts.poppins(fontSize: 13)),
//         ),
//         PopupMenuItem(
//           value: 'date_asc',
//           child: Text('Oldest First', style: GoogleFonts.poppins(fontSize: 13)),
//         ),
//         PopupMenuItem(
//           value: 'date_desc',
//           child: Text('Newest First', style: GoogleFonts.poppins(fontSize: 13)),
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

//   // Build filter chips
//   Widget _buildFilterChips() {
//     return SingleChildScrollView(
//       scrollDirection: Axis.horizontal,
//       child: Row(
//         children: _filters.map((filter) {
//           final isSelected = _currentFilter == filter;
//           return Padding(
//             padding: const EdgeInsets.only(right: 8),
//             child: FilterChip(
//               label: Text(
//                 filter,
//                 style: GoogleFonts.poppins(
//                   color: isSelected
//                       ? Colors.white
//                       : _filterColors[filter] ?? const Color(0xFF5094FF),
//                   fontSize: 12,
//                 ),
//               ),
//               selected: isSelected,
//               onSelected: (selected) => setState(() => _currentFilter = filter),
//               backgroundColor: Colors.white,
//               selectedColor: _filterColors[filter] ?? const Color(0xFF5094FF),
//               checkmarkColor: Colors.white,
//               side: BorderSide(
//                 color: isSelected
//                     ? _filterColors[filter] ?? const Color(0xFF5094FF)
//                     : Colors.grey[300]!,
//               ),
//             ),
//           );
//         }).toList(),
//       ),
//     );
//   }

//   // Build bottom navigation bar
//   Widget _buildBottomNavBar() {
//     return Container(
//       decoration: BoxDecoration(
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.1),
//             blurRadius: 10,
//             offset: const Offset(0, -2),
//           ),
//         ],
//       ),
//       child: BottomNavigationBar(
//         type: BottomNavigationBarType.fixed,
//         backgroundColor: Colors.white,
//         selectedItemColor: const Color(0xFFF5A623),
//         unselectedItemColor: Colors.grey[600],
//         showSelectedLabels: true,
//         showUnselectedLabels: true,
//         currentIndex: _selectedIndex,
//         onTap: _onItemTapped,
//         items: const [
//           BottomNavigationBarItem(
//             icon: Icon(Icons.home_outlined),
//             activeIcon: Icon(Icons.home),
//             label: 'Home',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.pets_outlined),
//             activeIcon: Icon(Icons.pets),
//             label: 'Grooming',
//           ),
//           // BottomNavigationBarItem(
//           //   icon: Icon(Icons.shopping_bag_outlined),
//           //   activeIcon: Icon(Icons.shopping_bag),
//           //   label: 'Shop',
//           // ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.message_outlined),
//             activeIcon: Icon(Icons.message),
//             label: 'Messages',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.person_outline),
//             activeIcon: Icon(Icons.person),
//             label: 'Profile',
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;
//     final isSmallScreen = screenWidth < 360;

//     return GestureDetector(
//       onTap: () => FocusScope.of(context).unfocus(),
//       child: Scaffold(
//         backgroundColor: Colors.white,
//         body: Container(
//           decoration: const BoxDecoration(
//             gradient: LinearGradient(
//               colors: [Color(0xFFFFF6E7), Colors.white],
//               begin: Alignment.topCenter,
//               end: Alignment.bottomCenter,
//             ),
//           ),
//           child: SafeArea(
//             child: CustomScrollView(
//               controller: _scrollController,
//               slivers: [
//                 SliverToBoxAdapter(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       // Search bar
//                       Padding(
//                         padding: EdgeInsets.symmetric(
//                           horizontal: isSmallScreen ? 12 : 16,
//                           vertical: 12,
//                         ),
//                         child: TextField(
//                           decoration: InputDecoration(
//                             hintText: 'Search by pet name, breed, or service',
//                             hintStyle: TextStyle(
//                               fontSize: 14,
//                               color: Colors.grey[500],
//                             ),
//                             prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
//                             filled: true,
//                             fillColor: Colors.grey[100],
//                             contentPadding: const EdgeInsets.symmetric(
//                               vertical: 0,
//                               horizontal: 16,
//                             ),
//                             border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(12),
//                               borderSide: BorderSide.none,
//                             ),
//                           ),
//                           onChanged: (value) => setState(() => _searchQuery = value),
//                         ),
//                       ),

//                       // Calendar section
//                       Padding(
//                         padding: EdgeInsets.symmetric(
//                           horizontal: isSmallScreen ? 12 : 16,
//                           vertical: 8,
//                         ),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: [
//                                 Text(
//                                   'Calendar',
//                                   style: GoogleFonts.poppins(
//                                     fontSize: 18,
//                                     fontWeight: FontWeight.bold,
//                                     color: const Color(0xFFF5A623),
//                                   ),
//                                 ),
//                                 _buildCalendarLegend(),
//                               ],
//                             ),
//                             const SizedBox(height: 12),
//                             Container(
//                               decoration: BoxDecoration(
//                                 color: Colors.white,
//                                 borderRadius: BorderRadius.circular(12),
//                                 boxShadow: [
//                                   BoxShadow(
//                                     color: Colors.orange.withOpacity(0.10),
//                                     blurRadius: 8,
//                                     offset: const Offset(0, 4),
//                                   ),
//                                 ],
//                               ),
//                               child: TableCalendar(
//                                 firstDay: DateTime.utc(2023, 1, 1),
//                                 lastDay: DateTime.utc(2030, 12, 31),
//                                 focusedDay: _focusedDay,
//                                 selectedDayPredicate: (day) =>
//                                     _isDateSelected && isSameDay(_selectedDay, day),
//                                 onDaySelected: (selectedDay, focusedDay) {
//                                   setState(() {
//                                     _selectedDay = selectedDay;
//                                     _focusedDay = focusedDay;
//                                     _isDateSelected = true;
//                                   });
//                                 },
//                                 calendarStyle: CalendarStyle(
//                                   todayDecoration: BoxDecoration(
//                                     color: Colors.green.withOpacity(0.5),
//                                     shape: BoxShape.circle,
//                                   ),
//                                   selectedDecoration: BoxDecoration(
//                                     color: const Color(0xFFF5A623).withOpacity(0.5),
//                                     shape: BoxShape.circle,
//                                   ),
//                                 ),
//                                 calendarBuilders: CalendarBuilders(
//                                   markerBuilder: (context, date, events) {
//                                     final now = DateTime.now();
//                                     final today = DateTime(now.year, now.month, now.day);
//                                     final targetDay = DateTime(date.year, date.month, date.day);
//                                     final hasAppointment = _appointments.any((app) {
//                                       final appointmentDate =
//                                           DateTime.tryParse(app['preferred_date'] ?? '');
//                                       if (appointmentDate == null) return false;
//                                       final appointmentDay = DateTime(
//                                           appointmentDate.year,
//                                           appointmentDate.month,
//                                           appointmentDate.day);
//                                       return appointmentDay.isAtSameMomentAs(targetDay);
//                                     });

//                                     if (hasAppointment) {
//                                       Color dotColor;
//                                       if (targetDay.isBefore(today)) {
//                                         dotColor = Colors.blue;
//                                       } else if (targetDay.isAtSameMomentAs(today)) {
//                                         dotColor = Colors.green;
//                                       } else {
//                                         dotColor = Colors.orange;
//                                       }
//                                       return Positioned(
//                                         bottom: 1,
//                                         child: Container(
//                                           width: 7,
//                                           height: 7,
//                                           decoration: BoxDecoration(
//                                             color: dotColor,
//                                             shape: BoxShape.circle,
//                                           ),
//                                         ),
//                                       );
//                                     }
//                                     return null;
//                                   },
//                                 ),
//                                 eventLoader: (day) =>
//                                     _getAppointmentsForDate(day).isNotEmpty ? [1] : [],
//                                 headerStyle: HeaderStyle(
//                                   formatButtonVisible: false,
//                                   titleCentered: true,
//                                   titleTextStyle: GoogleFonts.poppins(
//                                     fontWeight: FontWeight.bold,
//                                     fontSize: 16,
//                                     color: Colors.black87,
//                                   ),
//                                 ),
//                                 calendarFormat: CalendarFormat.month,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),

//                       // Book Now button
//                       Padding(
//                         padding: EdgeInsets.symmetric(
//                           horizontal: isSmallScreen ? 12 : 16,
//                           vertical: 12,
//                         ),
//                         child: Align(
//                           alignment: Alignment.centerRight,
//                           child: ElevatedButton(
//                             onPressed: () async {
//                               await Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder: (context) => const GroomingAppointmentPage(),
//                                 ),
//                               );
//                               _fetchAppointments();
//                             },
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: const Color(0xFFF5A623),
//                               foregroundColor: Colors.white,
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(20),
//                               ),
//                               padding: const EdgeInsets.symmetric(
//                                 horizontal: 20,
//                                 vertical: 8,
//                               ),
//                               elevation: 0,
//                             ),
//                             child: Text(
//                               'Book Now',
//                               style: GoogleFonts.poppins(
//                                 fontSize: 14,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),

//                 // Appointments header
//                 SliverToBoxAdapter(
//                   child: Padding(
//                     padding: EdgeInsets.symmetric(
//                       horizontal: isSmallScreen ? 12 : 16,
//                       vertical: 12,
//                     ),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Text(
//                               _isDateSelected
//                                   ? 'Appointments for ${DateFormat('MMMM dd, yyyy').format(_selectedDay)}'
//                                   : 'All Appointments',
//                               style: GoogleFonts.poppins(
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.bold,
//                                 color: const Color(0xFF5094FF),
//                               ),
//                             ),
//                             _buildSortMenu(),
//                           ],
//                         ),
//                         if (_isDateSelected)
//                           Padding(
//                             padding: const EdgeInsets.only(top: 8),
//                             child: OutlinedButton.icon(
//                               onPressed: () => setState(() => _isDateSelected = false),
//                               icon: const Icon(Icons.clear, size: 16),
//                               label: Text(
//                                 'Clear Date Selection',
//                                 style: GoogleFonts.poppins(fontSize: 12),
//                               ),
//                               style: OutlinedButton.styleFrom(
//                                 padding: const EdgeInsets.symmetric(vertical: 8),
//                                 side: BorderSide(color: Colors.grey[300]!),
//                               ),
//                             ),
//                           ),
//                         if (!_isDateSelected)
//                           Padding(
//                             padding: const EdgeInsets.only(top: 12),
//                             child: _buildFilterChips(),
//                           ),
//                       ],
//                     ),
//                   ),
//                 ),

//                 // Appointments list
//                 SliverPadding(
//                   padding: EdgeInsets.symmetric(
//                     horizontal: isSmallScreen ? 12 : 16,
//                     vertical: 8,
//                   ),
//                   sliver: _filteredAndSearchedAppointments.isEmpty
//                       ? SliverToBoxAdapter(child: _buildEmptyState())
//                       : SliverList(
//                           delegate: SliverChildBuilderDelegate(
//                             (context, index) {
//                               final appointment = _filteredAndSearchedAppointments[index];
//                               return _buildAppointmentCard(
//                                 appointment: appointment,
//                                 onEdit: () => _editAppointment(appointment),
//                                 onCancel: () => _cancelAppointment(appointment['id']),
//                               );
//                             },
//                             childCount: _filteredAndSearchedAppointments.length,
//                           ),
//                         ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//         bottomNavigationBar: _buildBottomNavBar(),
//         floatingActionButton: _showScrollToTop
//             ? FloatingActionButton(
//                 onPressed: _scrollToTop,
//                 backgroundColor: const Color(0xFFF5A623),
//                 foregroundColor: Colors.white,
//                 mini: true,
//                 child: const Icon(Icons.keyboard_arrow_up),
//               )
//             : null,
//       ),
//     );
//   }
// }


// ----

// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:table_calendar/table_calendar.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:intl/intl.dart';
// import '../utils/notification_utils.dart';
// import '../profile/profile_page.dart';
// import 'grooming_appointment.dart';

// class GroomingPage extends StatefulWidget {
//   const GroomingPage({super.key});

//   @override
//   State<GroomingPage> createState() => _GroomingPageState();
// }

// class _GroomingPageState extends State<GroomingPage> {
//   int _selectedIndex = 1;
//   DateTime _focusedDay = DateTime.now();
//   DateTime _selectedDay = DateTime.now();
//   List<Map<String, dynamic>> _appointments = [];
//   String _searchQuery = '';
//   bool _isDateSelected = false;
//   String _currentSortType = 'date_desc';
//   String _currentFilter = 'All';
//   final ScrollController _scrollController = ScrollController();
//   bool _showScrollToTop = false;
//   bool _isRefreshing = false;

//   final List<String> _filters = [
//     'All',
//     'Pending',
//     'Approved',
//     'Cancelled',
//     'Cancelled (by user)',
//     'Completed'
//   ];

//   final Map<String, Color> _filterColors = {
//     'All': const Color(0xFF5094FF),
//     'Pending': const Color(0xFFFB8C00),
//     'Approved': Colors.green,
//     'Completed': Colors.blue,
//     'Cancelled': Colors.red,
//     'Cancelled (by user)': Colors.red.shade700,
//   };

//   @override
//   void initState() {
//     super.initState();
//     _fetchAppointments();
//     _scrollController.addListener(_onScroll);
//   }

//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     _fetchAppointments();
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

//   Future<void> _refreshAppointments() async {
//     setState(() => _isRefreshing = true);
//     await _fetchAppointments();
//     setState(() => _isRefreshing = false);
//   }

//   void _onItemTapped(int index) {
//     switch (index) {
//       case 0:
//         Navigator.pushReplacementNamed(context, '/home');
//         break;
//       case 1:
//         break;
//       case 2:
//         Navigator.pushReplacementNamed(context, '/messages');
//         break;
//       case 3:
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (_) => const ProfilePage()),
//         );
//         break;
//     }
//     setState(() => _selectedIndex = index);
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

//   Future<void> _fetchAppointments() async {
//     try {
//       final userId = Supabase.instance.client.auth.currentUser?.id;
//       if (userId == null) return;
//       final response = await Supabase.instance.client
//           .from('grooming_appointments')
//           .select('''
//             id, pet_name, pet_type, pet_type_other, breed, pet_size, age, gender,
//             allergies_medical_conditions, preferred_date, preferred_time,
//             estimated_duration, service_bath, service_haircut, service_nail_trim,
//             service_ear_cleaning, special_requests_notes, estimated_cost,
//             payment_method, consent_photos, status
//           ''')
//           .eq('user_id', userId)
//           .order('preferred_date', ascending: true);
//       if (response is List) {
//         setState(() => _appointments = response.cast<Map<String, dynamic>>());
//       }
//     } catch (e) {
//       debugPrint('Error fetching appointments: $e');
//     }
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

//   List<Map<String, dynamic>> get _filteredAndSearchedAppointments {
//     List<Map<String, dynamic>> appointmentsToSort = _isDateSelected
//         ? _appointments.where((app) {
//             final appointmentDate = DateTime.tryParse(app['preferred_date'] ?? '');
//             if (appointmentDate == null) return false;
//             final selectedDay = DateTime(_selectedDay.year, _selectedDay.month, _selectedDay.day);
//             final appointmentDay = DateTime(appointmentDate.year, appointmentDate.month, appointmentDate.day);
//             return appointmentDay.isAtSameMomentAs(selectedDay);
//           }).toList()
//         : List.from(_appointments);

//     if (_currentFilter != 'All') {
//       appointmentsToSort = appointmentsToSort.where((app) => app['status'] == _currentFilter).toList();
//     }

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

//   Future<void> _cancelAppointment(String appointmentId) async {
//     final confirm = await showDialog<bool>(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text(
//           'Cancel Appointment',
//           style: TextStyle(
//             color: Colors.red,
//             fontWeight: FontWeight.bold,
//             fontSize: 18,
//           ),
//         ),
//         content: const Text(
//           'Are you sure you want to cancel this appointment? This will free up the time slot for other users to book. This action cannot be undone.',
//           style: TextStyle(fontSize: 16),
//         ),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//         actions: [
//           ElevatedButton(
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.grey[400],
//               foregroundColor: Colors.white,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
//               elevation: 0,
//             ),
//             onPressed: () => Navigator.pop(context, false),
//             child: const Text('No'),
//           ),
//           ElevatedButton(
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.red.withOpacity(0.7),
//               foregroundColor: Colors.white,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
//               elevation: 2,
//               shadowColor: Colors.orange.withOpacity(0.2),
//             ),
//             onPressed: () => Navigator.pop(context, true),
//             child: const Text('Yes', style: TextStyle(fontWeight: FontWeight.bold)),
//           ),
//         ],
//       ),
//     );
//     if (confirm != true) return;
//     try {
//       await Supabase.instance.client
//           .from('grooming_appointments')
//           .update({'status': 'Cancelled (by user)'})
//           .eq('id', appointmentId);

//       final user = Supabase.instance.client.auth.currentUser;
//       if (user != null) {
//         final appointment = _appointments.firstWhere((a) => a['id'] == appointmentId);
//         final petName = appointment['pet_name'] ?? '';
//         final date = appointment['preferred_date'] ?? '';
//         final time = appointment['preferred_time'] ?? '';
//         String userFullName = user.id;
//         try {
//           final userResp = await Supabase.instance.client
//               .from('users')
//               .select('full_name')
//               .eq('id', user.id)
//               .maybeSingle();
//           userFullName = userResp?['full_name'] ?? user.id;
//         } catch (e) {
//           debugPrint('Error fetching user name: $e');
//         }
//         final message = 'User $userFullName has cancelled the grooming appointment for $petName on $date at $time. The time slot is now available for booking.';
//         await Supabase.instance.client.from('admin_messages').insert({
//           'user_id': user.id,
//           'appointment_id': appointmentId,
//           'message': message,
//           'is_from_admin': false,
//         });
//       }
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Appointment cancelled successfully! The time slot is now available for other users.'),
//             backgroundColor: Colors.green,
//             duration: Duration(seconds: 4),
//           ),
//         );
//         _fetchAppointments();
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Error cancelling appointment: $e'),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     }
//   }

//   void _editAppointment(Map<String, dynamic> appointment) async {
//     await Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => GroomingAppointmentPage(appointment: appointment),
//       ),
//     );
//     _fetchAppointments();
//   }

//   Widget _buildAppointmentCard({
//     required Map<String, dynamic> appointment,
//     required VoidCallback onEdit,
//     required VoidCallback onCancel,
//   }) {
//     final status = appointment['status'] ?? 'Pending';
//     final petName = appointment['pet_name'] ?? 'Unknown Pet';
//     final date = appointment['preferred_date'] != null
//         ? DateFormat('MMMM dd, yyyy').format(DateTime.parse(appointment['preferred_date']))
//         : 'N/A';
//     final time = appointment['preferred_time'] ?? 'N/A';
//     final duration = appointment['estimated_duration'] ?? 0;
//     final services = _getSelectedServices(appointment);

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
//     final isEditable = status == 'Pending';
//     final screenWidth = MediaQuery.of(context).size.width;
//     final isSmallScreen = screenWidth < 360;

//     return Container(
//       margin: const EdgeInsets.only(bottom: 12),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 6,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(16),
//         child: Material(
//           color: Colors.transparent,
//           child: InkWell(
//             onTap: () => _editAppointment(appointment),
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
//                         constraints: BoxConstraints(
//                           maxWidth: isSmallScreen ? 90 : 110,
//                         ),
//                         child: Row(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             Icon(style['icon'], size: 14, color: style['textColor']),
//                             const SizedBox(width: 4),
//                             Flexible(
//                               child: Text(
//                                 status == 'Cancelled (by user)' ? 'Cancelled' : status,
//                                 style: GoogleFonts.poppins(
//                                   fontSize: 11,
//                                   color: style['textColor'],
//                                   fontWeight: FontWeight.w500,
//                                 ),
//                                 overflow: TextOverflow.ellipsis,
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
//                   const SizedBox(height: 12),
//                   if (isEditable)
//                     isSmallScreen
//                         ? Column(
//                             children: [
//                               SizedBox(
//                                 width: double.infinity,
//                                 child: OutlinedButton.icon(
//                                   onPressed: onCancel,
//                                   icon: const Icon(Icons.cancel, size: 16, color: Colors.red),
//                                   label: Text(
//                                     'Cancel',
//                                     style: GoogleFonts.poppins(
//                                       fontSize: 12,
//                                       color: Colors.red,
//                                     ),
//                                   ),
//                                   style: OutlinedButton.styleFrom(
//                                     padding: const EdgeInsets.symmetric(vertical: 8),
//                                   ),
//                                 ),
//                               ),
//                               const SizedBox(height: 8),
//                               SizedBox(
//                                 width: double.infinity,
//                                 child: ElevatedButton.icon(
//                                   onPressed: onEdit,
//                                   icon: const Icon(Icons.edit, size: 16, color: Colors.white),
//                                   label: Text(
//                                     'Edit',
//                                     style: GoogleFonts.poppins(
//                                       fontSize: 12,
//                                       color: Colors.white,
//                                       fontWeight: FontWeight.w500,
//                                     ),
//                                   ),
//                                   style: ElevatedButton.styleFrom(
//                                     backgroundColor: const Color(0xFFF5A623),
//                                     shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(8),
//                                     ),
//                                     padding: const EdgeInsets.symmetric(vertical: 8),
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           )
//                         : Row(
//                             mainAxisAlignment: MainAxisAlignment.end,
//                             children: [
//                               TextButton.icon(
//                                 onPressed: onCancel,
//                                 icon: const Icon(Icons.cancel, size: 16, color: Colors.red),
//                                 label: Text(
//                                   'Cancel',
//                                   style: GoogleFonts.poppins(
//                                     fontSize: 12,
//                                     color: Colors.red,
//                                   ),
//                                 ),
//                               ),
//                               const SizedBox(width: 12),
//                               ElevatedButton.icon(
//                                 onPressed: onEdit,
//                                 icon: const Icon(Icons.edit, size: 16, color: Colors.white),
//                                 label: Text(
//                                   'Edit',
//                                   style: GoogleFonts.poppins(
//                                     fontSize: 12,
//                                     color: Colors.white,
//                                     fontWeight: FontWeight.w500,
//                                   ),
//                                 ),
//                                 style: ElevatedButton.styleFrom(
//                                   backgroundColor: const Color(0xFFF5A623),
//                                   shape: RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.circular(8),
//                                   ),
//                                   padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//                                 ),
//                               ),
//                             ],
//                           ),
//                 ],
//               ),
//             ),
//           ),
//         ),
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
//                 : 'You don\'t have any appointments yet.',
//             style: GoogleFonts.poppins(
//               fontSize: 14,
//               color: Colors.grey[500],
//             ),
//             textAlign: TextAlign.center,
//           ),
//           const SizedBox(height: 20),
//           ElevatedButton(
//             onPressed: () async {
//               await Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => const GroomingAppointmentPage(),
//                 ),
//               );
//               _fetchAppointments();
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: const Color(0xFFF5A623),
//               foregroundColor: Colors.white,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(20),
//               ),
//               padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
//             ),
//             child: Text(
//               'Book Your Appointment',
//               style: GoogleFonts.poppins(
//                 fontSize: 14,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildSortMenu() {
//     return PopupMenuButton<String>(
//       onSelected: (value) => setState(() => _currentSortType = value),
//       itemBuilder: (context) => [
//         PopupMenuItem(
//           value: 'name_asc',
//           child: Text('Name (A-Z)', style: GoogleFonts.poppins(fontSize: 13)),
//         ),
//         PopupMenuItem(
//           value: 'name_desc',
//           child: Text('Name (Z-A)', style: GoogleFonts.poppins(fontSize: 13)),
//         ),
//         PopupMenuItem(
//           value: 'date_asc',
//           child: Text('Oldest First', style: GoogleFonts.poppins(fontSize: 13)),
//         ),
//         PopupMenuItem(
//           value: 'date_desc',
//           child: Text('Newest First', style: GoogleFonts.poppins(fontSize: 13)),
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
//         children: _filters.map((filter) {
//           final isSelected = _currentFilter == filter;
//           return Padding(
//             padding: const EdgeInsets.only(right: 8),
//             child: FilterChip(
//               label: Text(
//                 filter,
//                 style: GoogleFonts.poppins(
//                   color: isSelected
//                       ? Colors.white
//                       : _filterColors[filter] ?? const Color(0xFF5094FF),
//                   fontSize: 12,
//                 ),
//               ),
//               selected: isSelected,
//               onSelected: (selected) => setState(() => _currentFilter = filter),
//               backgroundColor: Colors.white,
//               selectedColor: _filterColors[filter] ?? const Color(0xFF5094FF),
//               checkmarkColor: Colors.white,
//               side: BorderSide(
//                 color: isSelected
//                     ? _filterColors[filter] ?? const Color(0xFF5094FF)
//                     : Colors.grey[300]!,
//               ),
//             ),
//           );
//         }).toList(),
//       ),
//     );
//   }

//   Widget _buildBottomNavBar() {
//     return Container(
//       decoration: BoxDecoration(
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.1),
//             blurRadius: 10,
//             offset: const Offset(0, -2),
//           ),
//         ],
//       ),
//       child: BottomNavigationBar(
//         type: BottomNavigationBarType.fixed,
//         backgroundColor: Colors.white,
//         selectedItemColor: const Color(0xFFF5A623),
//         unselectedItemColor: Colors.grey[600],
//         showSelectedLabels: true,
//         showUnselectedLabels: true,
//         currentIndex: _selectedIndex,
//         onTap: _onItemTapped,
//         items: const [
//           BottomNavigationBarItem(
//             icon: Icon(Icons.home_outlined),
//             activeIcon: Icon(Icons.home),
//             label: 'Home',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.pets_outlined),
//             activeIcon: Icon(Icons.pets),
//             label: 'Grooming',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.message_outlined),
//             activeIcon: Icon(Icons.message),
//             label: 'Messages',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.person_outline),
//             activeIcon: Icon(Icons.person),
//             label: 'Profile',
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;
//     final isSmallScreen = screenWidth < 360;
//     return GestureDetector(
//       onTap: () => FocusScope.of(context).unfocus(),
//       child: Scaffold(
//         backgroundColor: Colors.white,
//         body: Container(
//           decoration: const BoxDecoration(
//             gradient: LinearGradient(
//               colors: [Color(0xFFFFF6E7), Colors.white],
//               begin: Alignment.topCenter,
//               end: Alignment.bottomCenter,
//             ),
//           ),
//           child: SafeArea(
//             child: RefreshIndicator(
//               color: Colors.orange,
//               onRefresh: _refreshAppointments,
//               child: CustomScrollView(
//                 controller: _scrollController,
//                 slivers: [
//                   SliverToBoxAdapter(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Padding(
//                           padding: EdgeInsets.symmetric(
//                             horizontal: isSmallScreen ? 12 : 16,
//                             vertical: 12,
//                           ),
//                           child: TextField(
//                             decoration: InputDecoration(
//                               hintText: 'Search by pet name, breed, or service',
//                               hintStyle: TextStyle(
//                                 fontSize: 14,
//                                 color: Colors.grey[500],
//                               ),
//                               prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
//                               filled: true,
//                               fillColor: Colors.grey[100],
//                               contentPadding: const EdgeInsets.symmetric(
//                                 vertical: 0,
//                                 horizontal: 16,
//                               ),
//                               border: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(12),
//                                 borderSide: BorderSide.none,
//                               ),
//                             ),
//                             onChanged: (value) => setState(() => _searchQuery = value),
//                           ),
//                         ),
//                         Padding(
//                           padding: EdgeInsets.symmetric(
//                             horizontal: isSmallScreen ? 12 : 16,
//                             vertical: 8,
//                           ),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Row(
//                                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                 children: [
//                                   Text(
//                                     'Calendar',
//                                     style: GoogleFonts.poppins(
//                                       fontSize: 18,
//                                       fontWeight: FontWeight.bold,
//                                       color: const Color(0xFFF5A623),
//                                     ),
//                                   ),
//                                   _buildCalendarLegend(),
//                                 ],
//                               ),
//                               const SizedBox(height: 12),
//                               Container(
//                                 decoration: BoxDecoration(
//                                   color: Colors.white,
//                                   borderRadius: BorderRadius.circular(12),
//                                   boxShadow: [
//                                     BoxShadow(
//                                       color: Colors.orange.withOpacity(0.10),
//                                       blurRadius: 8,
//                                       offset: const Offset(0, 4),
//                                     ),
//                                   ],
//                                 ),
//                                 child: TableCalendar(
//                                   firstDay: DateTime.utc(2023, 1, 1),
//                                   lastDay: DateTime.utc(2030, 12, 31),
//                                   focusedDay: _focusedDay,
//                                   selectedDayPredicate: (day) =>
//                                       _isDateSelected && isSameDay(_selectedDay, day),
//                                   onDaySelected: (selectedDay, focusedDay) {
//                                     setState(() {
//                                       _selectedDay = selectedDay;
//                                       _focusedDay = focusedDay;
//                                       _isDateSelected = true;
//                                     });
//                                   },
//                                   calendarStyle: CalendarStyle(
//                                     todayDecoration: BoxDecoration(
//                                       color: Colors.green.withOpacity(0.5),
//                                       shape: BoxShape.circle,
//                                     ),
//                                     selectedDecoration: BoxDecoration(
//                                       color: const Color(0xFFF5A623).withOpacity(0.5),
//                                       shape: BoxShape.circle,
//                                     ),
//                                   ),
//                                   calendarBuilders: CalendarBuilders(
//                                     markerBuilder: (context, date, events) {
//                                       final now = DateTime.now();
//                                       final today = DateTime(now.year, now.month, now.day);
//                                       final targetDay = DateTime(date.year, date.month, date.day);
//                                       final hasAppointment = _appointments.any((app) {
//                                         final appointmentDate =
//                                             DateTime.tryParse(app['preferred_date'] ?? '');
//                                         if (appointmentDate == null) return false;
//                                         final appointmentDay = DateTime(
//                                             appointmentDate.year,
//                                             appointmentDate.month,
//                                             appointmentDate.day);
//                                         return appointmentDay.isAtSameMomentAs(targetDay);
//                                       });
//                                       if (hasAppointment) {
//                                         Color dotColor;
//                                         if (targetDay.isBefore(today)) {
//                                           dotColor = Colors.blue;
//                                         } else if (targetDay.isAtSameMomentAs(today)) {
//                                           dotColor = Colors.green;
//                                         } else {
//                                           dotColor = Colors.orange;
//                                         }
//                                         return Positioned(
//                                           bottom: 1,
//                                           child: Container(
//                                             width: 7,
//                                             height: 7,
//                                             decoration: BoxDecoration(
//                                               color: dotColor,
//                                               shape: BoxShape.circle,
//                                             ),
//                                           ),
//                                         );
//                                       }
//                                       return null;
//                                     },
//                                   ),
//                                   eventLoader: (day) =>
//                                       _getAppointmentsForDate(day).isNotEmpty ? [1] : [],
//                                   headerStyle: HeaderStyle(
//                                     formatButtonVisible: false,
//                                     titleCentered: true,
//                                     titleTextStyle: GoogleFonts.poppins(
//                                       fontWeight: FontWeight.bold,
//                                       fontSize: 16,
//                                       color: Colors.black87,
//                                     ),
//                                   ),
//                                   calendarFormat: CalendarFormat.month,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                         Padding(
//                           padding: EdgeInsets.symmetric(
//                             horizontal: isSmallScreen ? 12 : 16,
//                             vertical: 12,
//                           ),
//                           child: Align(
//                             alignment: Alignment.centerRight,
//                             child: ElevatedButton(
//                               onPressed: () async {
//                                 await Navigator.push(
//                                   context,
//                                   MaterialPageRoute(
//                                     builder: (context) => const GroomingAppointmentPage(),
//                                   ),
//                                 );
//                                 _fetchAppointments();
//                               },
//                               style: ElevatedButton.styleFrom(
//                                 backgroundColor: const Color(0xFFF5A623),
//                                 foregroundColor: Colors.white,
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(20),
//                                 ),
//                                 padding: const EdgeInsets.symmetric(
//                                   horizontal: 20,
//                                   vertical: 8,
//                                 ),
//                                 elevation: 0,
//                               ),
//                               child: Text(
//                                 'Book Now',
//                                 style: GoogleFonts.poppins(
//                                   fontSize: 14,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   SliverToBoxAdapter(
//                     child: Padding(
//                       padding: EdgeInsets.symmetric(
//                         horizontal: isSmallScreen ? 12 : 16,
//                         vertical: 12,
//                       ),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Text(
//                                 _isDateSelected
//                                     ? 'Appointments for ${DateFormat('MMMM dd, yyyy').format(_selectedDay)}'
//                                     : 'All Appointments',
//                                 style: GoogleFonts.poppins(
//                                   fontSize: 16,
//                                   fontWeight: FontWeight.bold,
//                                   color: const Color(0xFF5094FF),
//                                 ),
//                               ),
//                               _buildSortMenu(),
//                             ],
//                           ),
//                           if (_isDateSelected)
//                             Padding(
//                               padding: const EdgeInsets.only(top: 8),
//                               child: OutlinedButton.icon(
//                                 onPressed: () => setState(() => _isDateSelected = false),
//                                 icon: const Icon(Icons.clear, size: 16),
//                                 label: Text(
//                                   'Clear Date Selection',
//                                   style: GoogleFonts.poppins(fontSize: 12),
//                                 ),
//                                 style: OutlinedButton.styleFrom(
//                                   padding: const EdgeInsets.symmetric(vertical: 8),
//                                   side: BorderSide(color: Colors.grey[300]!),
//                                 ),
//                               ),
//                             ),
//                           if (!_isDateSelected)
//                             Padding(
//                               padding: const EdgeInsets.only(top: 12),
//                               child: _buildFilterChips(),
//                             ),
//                         ],
//                       ),
//                     ),
//                   ),
//                   SliverPadding(
//                     padding: EdgeInsets.symmetric(
//                       horizontal: isSmallScreen ? 12 : 16,
//                       vertical: 8,
//                     ),
//                     sliver: _filteredAndSearchedAppointments.isEmpty
//                         ? SliverToBoxAdapter(child: _buildEmptyState())
//                         : SliverList(
//                             delegate: SliverChildBuilderDelegate(
//                               (context, index) {
//                                 final appointment = _filteredAndSearchedAppointments[index];
//                                 return _buildAppointmentCard(
//                                   appointment: appointment,
//                                   onEdit: () => _editAppointment(appointment),
//                                   onCancel: () => _cancelAppointment(appointment['id']),
//                                 );
//                               },
//                               childCount: _filteredAndSearchedAppointments.length,
//                             ),
//                           ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//         bottomNavigationBar: _buildBottomNavBar(),
//         floatingActionButton: _showScrollToTop
//             ? FloatingActionButton(
//                 onPressed: _scrollToTop,
//                 backgroundColor: const Color(0xFFF5A623),
//                 foregroundColor: Colors.white,
//                 mini: true,
//                 child: const Icon(Icons.keyboard_arrow_up),
//               )
//             : null,
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import '../utils/notification_utils.dart';
import '../profile/profile_page.dart';
import 'grooming_appointment.dart';

class GroomingPage extends StatefulWidget {
  const GroomingPage({super.key});

  @override
  State<GroomingPage> createState() => _GroomingPageState();
}

class _GroomingPageState extends State<GroomingPage> {
  int _selectedIndex = 1;
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  List<Map<String, dynamic>> _appointments = [];
  String _searchQuery = '';
  bool _isDateSelected = false;
  String _currentSortType = 'date_desc';
  String _currentFilter = 'All';
  final ScrollController _scrollController = ScrollController();
  bool _showScrollToTop = false;
  bool _isRefreshing = false;

  final List<String> _filters = [
    'All',
    'Pending',
    'Approved',
    'Cancelled',
    'Cancelled (by user)',
    'Completed'
  ];

  final Map<String, Color> _filterColors = {
    'All': const Color(0xFF5094FF),
    'Pending': const Color(0xFFFB8C00),
    'Approved': Colors.green,
    'Completed': Colors.blue,
    'Cancelled': Colors.red,
    'Cancelled (by user)': Colors.red.shade700,
  };

  @override
  void initState() {
    super.initState();
    _fetchAppointments();
    _scrollController.addListener(_onScroll);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fetchAppointments();
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

  void _onItemTapped(int index) {
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/home');
        break;
      case 1:
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/messages');
        break;
      case 3:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ProfilePage()),
        );
        break;
    }
    setState(() => _selectedIndex = index);
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

  Future<void> _fetchAppointments() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) return;
      final response = await Supabase.instance.client
          .from('grooming_appointments')
          .select('''
            id, pet_name, pet_type, pet_type_other, breed, pet_size, age, gender,
            allergies_medical_conditions, preferred_date, preferred_time,
            estimated_duration, service_bath, service_haircut, service_nail_trim,
            service_ear_cleaning, special_requests_notes, estimated_cost,
            payment_method, consent_photos, status
          ''')
          .eq('user_id', userId)
          .order('preferred_date', ascending: true);
      if (response is List) {
        setState(() => _appointments = response.cast<Map<String, dynamic>>());
      }
    } catch (e) {
      debugPrint('Error fetching appointments: $e');
    }
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

  List<Map<String, dynamic>> get _filteredAndSearchedAppointments {
    List<Map<String, dynamic>> appointmentsToSort = _isDateSelected
        ? _appointments.where((app) {
            final appointmentDate = DateTime.tryParse(app['preferred_date'] ?? '');
            if (appointmentDate == null) return false;
            final selectedDay = DateTime(_selectedDay.year, _selectedDay.month, _selectedDay.day);
            final appointmentDay = DateTime(appointmentDate.year, appointmentDate.month, appointmentDate.day);
            return appointmentDay.isAtSameMomentAs(selectedDay);
          }).toList()
        : List.from(_appointments);

    if (_currentFilter != 'All') {
      appointmentsToSort = appointmentsToSort.where((app) => app['status'] == _currentFilter).toList();
    }

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

  Future<void> _cancelAppointment(String appointmentId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Cancel Appointment',
          style: TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        content: const Text(
          'Are you sure you want to cancel this appointment? This will free up the time slot for other users to book. This action cannot be undone.',
          style: TextStyle(fontSize: 16),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[400],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
              elevation: 0,
            ),
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.withOpacity(0.7),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
              elevation: 2,
              shadowColor: Colors.orange.withOpacity(0.2),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Yes', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await Supabase.instance.client
          .from('grooming_appointments')
          .update({'status': 'Cancelled (by user)'})
          .eq('id', appointmentId);

      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        final appointment = _appointments.firstWhere((a) => a['id'] == appointmentId);
        final petName = appointment['pet_name'] ?? '';
        final date = appointment['preferred_date'] ?? '';
        final time = appointment['preferred_time'] ?? '';
        String userFullName = user.id;
        try {
          final userResp = await Supabase.instance.client
              .from('users')
              .select('full_name')
              .eq('id', user.id)
              .maybeSingle();
          userFullName = userResp?['full_name'] ?? user.id;
        } catch (e) {
          debugPrint('Error fetching user name: $e');
        }

        final message = 'User $userFullName has cancelled the grooming appointment for $petName on $date at $time. The time slot is now available for booking.';
        await Supabase.instance.client.from('admin_messages').insert({
          'user_id': user.id,
          'appointment_id': appointmentId,
          'message': message,
          'is_from_admin': false,
        });
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Appointment cancelled successfully! The time slot is now available for other users.'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 4),
          ),
        );
        _fetchAppointments();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error cancelling appointment: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _editAppointment(Map<String, dynamic> appointment) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GroomingAppointmentPage(appointment: appointment),
      ),
    );
    _fetchAppointments();
  }

  Widget _buildAppointmentCard({
    required Map<String, dynamic> appointment,
    required VoidCallback onEdit,
    required VoidCallback onCancel,
  }) {
    final status = appointment['status'] ?? 'Pending';
    final petName = appointment['pet_name'] ?? 'Unknown Pet';
    final date = appointment['preferred_date'] != null
        ? DateFormat('MMMM dd, yyyy').format(DateTime.parse(appointment['preferred_date']))
        : 'N/A';
    final time = appointment['preferred_time'] ?? 'N/A';
    final duration = appointment['estimated_duration'] ?? 0;
    final services = _getSelectedServices(appointment);

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
    final isEditable = status == 'Pending';
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    return Container(
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
                      constraints: BoxConstraints(
                        maxWidth: isSmallScreen ? 90 : 110,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(style['icon'], size: 14, color: style['textColor']),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              status == 'Cancelled (by user)' ? 'Cancelled' : status,
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                color: style['textColor'],
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
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
                const SizedBox(height: 12),
                if (isEditable)
                  isSmallScreen
                      ? Column(
                          children: [
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: onCancel,
                                icon: const Icon(Icons.cancel, size: 16, color: Colors.red),
                                label: Text(
                                  'Cancel',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: Colors.red,
                                  ),
                                ),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: onEdit,
                                icon: const Icon(Icons.edit, size: 16, color: Colors.white),
                                label: Text(
                                  'Edit',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFF5A623),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                ),
                              ),
                            ),
                          ],
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton.icon(
                              onPressed: onCancel,
                              icon: const Icon(Icons.cancel, size: 16, color: Colors.red),
                              label: Text(
                                'Cancel',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: Colors.red,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            ElevatedButton.icon(
                              onPressed: onEdit,
                              icon: const Icon(Icons.edit, size: 16, color: Colors.white),
                              label: Text(
                                'Edit',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFF5A623),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              ),
                            ),
                          ],
                        ),
              ],
            ),
          ),
        ),
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
                : 'You don\'t have any appointments yet.',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const GroomingAppointmentPage(),
                ),
              );
              _fetchAppointments();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF5A623),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            ),
            child: Text(
              'Book Your Appointment',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSortMenu() {
    return PopupMenuButton<String>(
      onSelected: (value) => setState(() => _currentSortType = value),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'name_asc',
          child: Text('Name (A-Z)', style: GoogleFonts.poppins(fontSize: 13)),
        ),
        PopupMenuItem(
          value: 'name_desc',
          child: Text('Name (Z-A)', style: GoogleFonts.poppins(fontSize: 13)),
        ),
        PopupMenuItem(
          value: 'date_asc',
          child: Text('Oldest First', style: GoogleFonts.poppins(fontSize: 13)),
        ),
        PopupMenuItem(
          value: 'date_desc',
          child: Text('Newest First', style: GoogleFonts.poppins(fontSize: 13)),
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
        children: _filters.map((filter) {
          final isSelected = _currentFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
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
              onSelected: (selected) => setState(() => _currentFilter = filter),
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
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFFF5A623),
        unselectedItemColor: Colors.grey[600],
        showSelectedLabels: true,
        showUnselectedLabels: true,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.pets_outlined),
            activeIcon: Icon(Icons.pets),
            label: 'Grooming',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message_outlined),
            activeIcon: Icon(Icons.message),
            label: 'Messages',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

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
            child: RefreshIndicator(
              color: Colors.orange,
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
                                      color: const Color(0xFFF5A623),
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
                                      color: const Color(0xFFF5A623).withOpacity(0.5),
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
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: ElevatedButton(
                              onPressed: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const GroomingAppointmentPage(),
                                  ),
                                );
                                _fetchAppointments();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFF5A623),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 8,
                                ),
                                elevation: 0,
                              ),
                              child: Text(
                                'Book Now',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: isSmallScreen ? 12 : 16,
                        vertical: 12,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
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
                          if (_isDateSelected)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
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
                              padding: const EdgeInsets.only(top: 12),
                              child: _buildFilterChips(),
                            ),
                        ],
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isSmallScreen ? 12 : 16,
                      vertical: 8,
                    ),
                    sliver: _filteredAndSearchedAppointments.isEmpty
                        ? SliverToBoxAdapter(child: _buildEmptyState())
                        : SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final appointment = _filteredAndSearchedAppointments[index];
                                return _buildAppointmentCard(
                                  appointment: appointment,
                                  onEdit: () => _editAppointment(appointment),
                                  onCancel: () => _cancelAppointment(appointment['id']),
                                );
                              },
                              childCount: _filteredAndSearchedAppointments.length,
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: _buildBottomNavBar(),
        floatingActionButton: _showScrollToTop
            ? FloatingActionButton(
                onPressed: _scrollToTop,
                backgroundColor: const Color(0xFFF5A623),
                foregroundColor: Colors.white,
                mini: true,
                child: const Icon(Icons.keyboard_arrow_up),
              )
            : null,
      ),
    );
  }
}
