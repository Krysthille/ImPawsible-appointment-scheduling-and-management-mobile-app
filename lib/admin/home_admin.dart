// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import '../services/auth_service.dart';
// import '../../config/supabase_config.dart';
// import 'bookings_admin.dart';
// // import 'shop_admin.dart';
// import 'messages_admin.dart';
// import 'all_users_admin.dart';
// import 'all_animals_admin.dart';
// import 'settings_admin.dart';
// import 'dart:async';
// import 'package:intl/intl.dart';
// import 'package:fl_chart/fl_chart.dart';

// class HomeAdminPage extends StatefulWidget {
//   const HomeAdminPage({super.key});

//   @override
//   State<HomeAdminPage> createState() => _HomeAdminPageState();
// }

// class _HomeAdminPageState extends State<HomeAdminPage> {
//   int _selectedIndex = 0;
//   final AuthService _authService = AuthService();
//   final orange = const Color(0xFFF5A623);
//   final lightOrange = const Color(0xFFFFF6E7);

//   int _totalUsersCount = 0;
//   int _totalAnimalsBookedCount = 0;
//   bool _isLoadingData = true;
//   List<Map<String, dynamic>> _recentActivities = [];
//   bool _isLoadingActivities = true;
//   Timer? _refreshTimer;
//   static const int _activitiesPerPage = 5;
//   List<Map<String, dynamic>> _allActivities = [];

//   // Testimonials
//   List<Map<String, dynamic>> _reviews = [];
//   bool _isLoadingReviews = true;
//   late PageController _testimonialController = PageController(viewportFraction: 0.85);

//   // Upcoming Appointments
//   List<Map<String, dynamic>> _upcomingAppointments = [];
//   bool _isLoadingAppointments = true;
//   int _displayedAppointmentsCount = 3;
//   static const int _appointmentsPerPage = 3;
  
//   // Monthly Bookings
//   List<Map<String, dynamic>> _allAnimals = [];
//   bool _isLoadingMonthlyBookings = true;

//   @override
//   void initState() {
//     super.initState();
//     _fetchDashboardData();
//     _fetchRecentActivities();
//     _fetchReviews();
//     _fetchUpcomingAppointments();
//     _fetchMonthlyBookings();
//     _startAutoScroll();
//     // Set up periodic refresh every 30 seconds
//     _refreshTimer = Timer.periodic(const Duration(seconds: 300), (timer) {
//       if (mounted) {
//         _fetchRecentActivities();
//         _fetchUpcomingAppointments();
//         _fetchMonthlyBookings();
//       }
//     });
//   }

//   @override
//   void dispose() {
//     _refreshTimer?.cancel();
//     _testimonialController.dispose();
//     super.dispose();
//   }

//   void _startAutoScroll() {
//     Timer.periodic(const Duration(seconds: 3), (timer) {
//       if (_testimonialController.hasClients && _reviews.isNotEmpty) {
//         final currentPage = _testimonialController.page?.round() ?? 0;
//         final nextPage = (currentPage + 1) % _reviews.length;
//         _testimonialController.animateToPage(
//           nextPage,
//           duration: const Duration(milliseconds: 800),
//           curve: Curves.easeInOut,
//         );
//       }
//     });
//   }



//   Future<void> _fetchDashboardData() async {
//     setState(() {
//       _isLoadingData = true;
//     });

//     try {
//       // First, let's get all users to see what we have
//       final allUsers = await SupabaseConfig.client.from('users').select('*');

//       print('Debug - All users in database: $allUsers');
//       print('Debug - Total number of users: ${allUsers.length}');

//       // Now get the count
//       final userResponse = await SupabaseConfig.client
//           .from('users')
//           .select()
//           .count(CountOption.exact);

//       print('Debug - Count query result: ${userResponse.count}');

//       final bookingResponse = await SupabaseConfig.client
//           .from('grooming_appointments')
//           .select()
//           .count(CountOption.exact);

//       setState(() {
//         // Use the length of allUsers as it's more reliable
//         _totalUsersCount = allUsers.length;
//         _totalAnimalsBookedCount = bookingResponse.count;
//       });
//     } catch (e) {
//       print('Debug - Error fetching data: $e');
//       // Set fallback data when database is unavailable
//       setState(() {
//         _totalUsersCount = 0;
//         _totalAnimalsBookedCount = 0;
//       });
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Unable to connect to database. Showing cached data.'),
//             backgroundColor: Colors.orange,
//             duration: const Duration(seconds: 3),
//           ),
//         );
//       }
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isLoadingData = false;
//         });
//       }
//     }
//   }

//   Future<void> _fetchRecentActivities({bool loadMore = false}) async {
//     if (!mounted) return;

//     if (loadMore) {
//       // This is no longer needed as we load all data at once
//       return;
//     } else {
//       setState(() {
//         _isLoadingActivities = true;
//         _recentActivities = [];
//         _allActivities = [];
//       });
//     }

//     try {
//       List<Map<String, dynamic>> activities = [];

//       // Fetch ALL recent user registrations (last 30 days)
//       final recentUsers = await SupabaseConfig.client
//           .from('users')
//           .select('*')
//           .gte('created_at', DateTime.now().subtract(const Duration(days: 30)).toIso8601String())
//           .order('created_at', ascending: false);

//       for (final user in recentUsers) {
//         activities.add({
//           'type': 'user_registration',
//           'title': 'New User Registered',
//           'subtitle': '${user['full_name']} registered as a new user',
//           'time': user['created_at'],
//           'icon': Icons.person_add,
//           'color': const Color(0xFF5094FF),
//         });
//       }

//       // Fetch ALL recent appointments (last 30 days)
//       final recentAppointments = await SupabaseConfig.client
//           .from('grooming_appointments')
//           .select('id, user_id, pet_name, preferred_date, preferred_time, status, created_at, updated_at')
//           .gte('created_at', DateTime.now().subtract(const Duration(days: 30)).toIso8601String())
//           .order('created_at', ascending: false);

//       for (final appointment in recentAppointments) {
//         // Always add the original booking activity
//         activities.add({
//           'type': 'appointment_booked',
//           'title': 'New Appointment Booked',
//           'subtitle': 'New appointment booked for ${appointment['pet_name']}',
//           'time': appointment['created_at'],
//           'icon': Icons.calendar_today,
//           'color': const Color(0xFFF5A623),
//         });

//         // If appointment was cancelled, add a separate cancellation activity
//         if (appointment['status'] == 'Cancelled') {
//           activities.add({
//             'type': 'appointment_cancelled',
//             'title': 'Appointment Cancelled',
//             'subtitle': 'Appointment cancelled for ${appointment['pet_name']}',
//             'time': appointment['updated_at'] ?? appointment['created_at'], // Use updated_at if available, otherwise created_at
//             'icon': Icons.cancel,
//             'color': Colors.red,
//           });
//         }
//         // If appointment was completed, add a separate completion activity
//         else if (appointment['status'] == 'Completed') {
//           activities.add({
//             'type': 'appointment_completed',
//             'title': 'Appointment Completed',
//             'subtitle': 'Grooming completed for ${appointment['pet_name']}',
//             'time': appointment['updated_at'] ?? appointment['created_at'], // Use updated_at if available, otherwise created_at
//             'icon': Icons.check_circle,
//             'color': Colors.green,
//           });
//         }
//       }

//       // Sort all activities by time (most recent first)
//       activities.sort((a, b) {
//         final timeA = DateTime.parse(a['time']);
//         final timeB = DateTime.parse(b['time']);
//         return timeB.compareTo(timeA);
//       });

//       if (mounted) {
//         setState(() {
//           // Store all activities and show first page
//           _allActivities = activities;
//           _recentActivities = activities.take(_activitiesPerPage).toList();
//           _isLoadingActivities = false;
//         });
//       }
//     } catch (e) {
//       print('Error fetching recent activities: $e');
//       if (mounted) {
//         setState(() {
//           _allActivities = []; // Set empty list when database is unavailable
//           _recentActivities = [];
//           _isLoadingActivities = false;
//         });
//       }
//     }
//   }

//   Future<void> _fetchReviews() async {
//     try {
//       // Try to use the joined query first
//       try {
//         final response = await SupabaseConfig.client
//             .from('rate_review')
//             .select('''
//               id,
//               rating,
//               review_text,
//               created_at,
//               user_id,
//               users!inner(full_name)
//             ''')
//             .order('created_at', ascending: false)
//             .limit(10);
//         if (mounted) {
//           setState(() {
//             _reviews = List<Map<String, dynamic>>.from(response);
//             _isLoadingReviews = false;
//           });
//         }
//       } catch (e) {
//         // If joined query fails, fall back to separate queries
//         final reviewsResponse = await SupabaseConfig.client
//             .from('rate_review')
//             .select('''
//               id,
//               rating,
//               review_text,
//               created_at,
//               user_id
//             ''')
//             .order('created_at', ascending: false)
//             .limit(10);
//         final reviewsWithUsers = <Map<String, dynamic>>[];
//         for (final review in reviewsResponse) {
//           try {
//             final userResponse = await SupabaseConfig.client
//                 .from('users')
//                 .select('full_name')
//                 .eq('id', review['user_id'])
//                 .maybeSingle();
//             final reviewWithUser = Map<String, dynamic>.from(review);
//             reviewWithUser['user_name'] = userResponse?['full_name'] ?? 'Anonymous';
//             reviewsWithUsers.add(reviewWithUser);
//           } catch (e) {
//             final reviewWithUser = Map<String, dynamic>.from(review);
//             reviewWithUser['user_name'] = 'Anonymous';
//             reviewsWithUsers.add(reviewWithUser);
//           }
//         }
//         if (mounted) {
//           setState(() {
//             _reviews = reviewsWithUsers;
//             _isLoadingReviews = false;
//           });
//         }
//       }
//     } catch (e) {
//       print('Error fetching reviews: $e');
//       if (mounted) {
//         setState(() {
//           _reviews = []; // Set empty list when database is unavailable
//           _isLoadingReviews = false;
//         });
//       }
//     }
//   }

//   Future<void> _fetchUpcomingAppointments() async {
//     try {
//       final now = DateTime.now();
//       final response = await SupabaseConfig.client
//           .from('grooming_appointments')
//           .select('''
//             id,
//             pet_name,
//             pet_type,
//             breed,
//             preferred_date,
//             preferred_time,
//             estimated_duration,
//             service_bath,
//             service_haircut,
//             service_nail_trim,
//             service_ear_cleaning,
//             status,
//             user_id,
//             created_at
//           ''')
//           .eq('status', 'Pending')
//           .gte('preferred_date', DateFormat('yyyy-MM-dd').format(now))
//           .order('preferred_date', ascending: true)
//           .order('preferred_time', ascending: true)
//           .limit(10);

//       // Fetch user names separately to avoid relationship issues
//       final appointmentsWithUsers = <Map<String, dynamic>>[];
//       for (final appointment in response) {
//         try {
//           final userResponse = await SupabaseConfig.client
//               .from('users')
//               .select('full_name')
//               .eq('id', appointment['user_id'])
//               .maybeSingle();
          
//           final appointmentWithUser = Map<String, dynamic>.from(appointment);
//           appointmentWithUser['user_name'] = userResponse?['full_name'] ?? 'Unknown User';
//           appointmentsWithUsers.add(appointmentWithUser);
//         } catch (e) {
//           final appointmentWithUser = Map<String, dynamic>.from(appointment);
//           appointmentWithUser['user_name'] = 'Unknown User';
//           appointmentsWithUsers.add(appointmentWithUser);
//         }
//       }

//       if (mounted) {
//         setState(() {
//           _upcomingAppointments = appointmentsWithUsers;
//           _isLoadingAppointments = false;
//         });
//       }
//     } catch (e) {
//       print('Error loading upcoming appointments: $e');
//       if (mounted) {
//         setState(() {
//           _upcomingAppointments = []; // Set empty list when database is unavailable
//           _isLoadingAppointments = false;
//         });
//       }
//     }
//   }

//   String _getCountdownText(Map<String, dynamic> appointment) {
//     try {
//       final date = DateTime.parse(appointment['preferred_date']);
//       final time = appointment['preferred_time'];
//       final timeParts = time.split(':');
//       final appointmentDateTime = DateTime(
//         date.year,
//         date.month,
//         date.day,
//         int.parse(timeParts[0]),
//         int.parse(timeParts[1]),
//       );
      
//       final now = DateTime.now();
//       final difference = appointmentDateTime.difference(now);
      
//       if (difference.isNegative) {
//         return 'Passed';
//       }
      
//       final days = difference.inDays;
//       final hours = difference.inHours % 24;
//       final minutes = difference.inMinutes % 60;
      
//       if (days > 0) {
//         return '$days day${days == 1 ? '' : 's'} $hours hr';
//       } else if (hours > 0) {
//         return '$hours hr $minutes min';
//       } else {
//         return '$minutes min';
//       }
//     } catch (e) {
//       return 'Time unavailable';
//     }
//   }

//   String _formatTimeAgo(String dateTimeString) {
//     try {
//       final dateTime = DateTime.parse(dateTimeString);
//       final now = DateTime.now();
//       final difference = now.difference(dateTime);

//       if (difference.inDays > 0) {
//         return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
//       } else if (difference.inHours > 0) {
//         return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
//       } else if (difference.inMinutes > 0) {
//         return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
//       } else {
//         return 'Just now';
//       }
//     } catch (e) {
//       return 'Unknown time';
//     }
//   }

//   String _formatUserName(String fullName) {
//     if (fullName == 'Anonymous' || fullName.isEmpty) {
//       return 'Anonymous';
//     }
//     final nameParts = fullName.trim().split(' ');
//     if (nameParts.isEmpty) {
//       return 'Anonymous';
//     }
//     if (nameParts.length == 1) {
//       return nameParts[0];
//     }
//     final firstName = nameParts[0];
//     final lastNameInitial = nameParts[nameParts.length - 1][0].toUpperCase();
//     return '$firstName $lastNameInitial.';
//   }

//   Widget _testimonialCardCarousel({required String quote, required String name, int stars = 5, Color accent = const Color(0xFFF5A623)}) {
//     return Container(
//       margin: const EdgeInsets.symmetric(horizontal: 4),
//       padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: Colors.grey.shade200, width: 1),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 8,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             '"$quote"',
//             style: GoogleFonts.poppins(
//               fontSize: 14,
//               color: Colors.black87,
//               fontStyle: FontStyle.italic,
//               height: 1.4,
//             ),
//             maxLines: 4,
//             overflow: TextOverflow.ellipsis,
//           ),
//           const SizedBox(height: 12),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Row(
//                 children: List.generate(stars, (index) => 
//                   const Icon(Icons.star, color: Color(0xFFF5A623), size: 16)
//                 ),
//               ),
//               Text(
//                 '- $name',
//                 style: GoogleFonts.poppins(
//                   fontSize: 13,
//                   color: accent,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }


//   void _collapseActivities() {
//     setState(() {
//       _recentActivities = _allActivities.take(_activitiesPerPage).toList();
//     });
//   }

//   void _expandAppointments() {
//     setState(() {
//       _displayedAppointmentsCount = (_displayedAppointmentsCount + _appointmentsPerPage).clamp(_appointmentsPerPage, _upcomingAppointments.length);
//     });
//   }

//   void _collapseAppointments() {
//     setState(() {
//       _displayedAppointmentsCount = _appointmentsPerPage;
//     });
//   }

//   String _getSelectedServices(Map<String, dynamic> appointment) {
//     final services = <String>[];
//     if (appointment['service_bath'] == true) services.add('Bath');
//     if (appointment['service_haircut'] == true) services.add('Haircut');
//     if (appointment['service_nail_trim'] == true) services.add('Nail Trim');
//     if (appointment['service_ear_cleaning'] == true) services.add('Ear Cleaning');
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

//   // Helper: Monthly bookings for demographics (uses full dataset)
//   Map<int, int> _monthlyBookingsForDemographics() {
//     final Map<int, int> counts = {for (var i = 1; i <= 12; i++) i: 0};
//     for (final animal in _allAnimals) {
//       final dateStr = animal['created_at'] ?? animal['preferred_date'];
//       if (dateStr != null) {
//         final date = DateTime.tryParse(dateStr);
//         if (date != null) {
//           counts[date.month] = counts[date.month]! + 1;
//         }
//       }
//     }
//     return counts;
//   }

//   // Helper: Round up to next multiple of 5 or 10 for chart maxY
//   int _dynamicMaxY(Iterable<int> values, {int step = 5, int min = 5}) {
//     final maxVal = values.isEmpty ? 0 : values.reduce((a, b) => a > b ? a : b);
//     if (maxVal <= min) return min;
//     final rounded = ((maxVal + step - 1) ~/ step) * step;
//     return rounded;
//   }

//   Future<void> _fetchMonthlyBookings() async {
//     try {
//       final response = await SupabaseConfig.client
//           .from('grooming_appointments')
//           .select('''
//             id, pet_name, pet_type, pet_type_other, breed, pet_size, age, gender,
//             allergies_medical_conditions, preferred_date, preferred_time, status,
//             user_id, created_at
//           ''')
//           .order('created_at', ascending: false);
      
//       if (mounted) {
//         setState(() {
//           _allAnimals = List<Map<String, dynamic>>.from(response);
//           _isLoadingMonthlyBookings = false;
//         });
//       }
//     } catch (e) {
//       print('Error fetching monthly bookings: $e');
//       if (mounted) {
//         setState(() {
//           _allAnimals = [];
//           _isLoadingMonthlyBookings = false;
//         });
//       }
//     }
//   }

//   Future<void> _handleLogout() async {
//     try {
//       await _authService.signOut();
//       if (mounted) {
//         Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Error signing out: ${e.toString()}'),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     }
//   }

//   void _onItemTapped(int index) async {
//     setState(() {
//       _selectedIndex = index;
//     });

//     switch (index) {
//       case 0:
//         // Stay on dashboard
//         break;
//       case 1:
//         Navigator.push(
//           context,
//           MaterialPageRoute(builder: (context) => const BookingsAdminPage()),
//         );
//         break;
//       // case 2:
//       //   Navigator.pushReplacement(
//       //     context,
//       //     MaterialPageRoute(builder: (context) => const ShopAdminPage()),
//       //   );
//       //   break;
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

//   // Helper functions
//   Widget _buildStatCard({
//     required String title,
//     required String value,
//     required IconData icon,
//     required Color color,
//     required VoidCallback onTap,
//   }) {
//     return InkWell(
//       onTap: onTap,
//       child: Container(
//         padding: const EdgeInsets.all(20),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(16),
//           boxShadow: [
//             BoxShadow(
//               color: color.withOpacity(0.1),
//               blurRadius: 10,
//               offset: const Offset(0, 4),
//             ),
//           ],
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Container(
//                   padding: const EdgeInsets.all(8),
//                   decoration: BoxDecoration(
//                     color: color.withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: Icon(icon, color: color),
//                 ),
//                 const Spacer(),
//                 Icon(
//                   Icons.arrow_forward_ios,
//                   size: 16,
//                   color: Colors.grey[400],
//                 ),
//               ],
//             ),
//             const SizedBox(height: 16),
//             Text(
//               value,
//               style: GoogleFonts.poppins(
//                 fontSize: 28,
//                 fontWeight: FontWeight.bold,
//                 color: color,
//               ),
//             ),
//             const SizedBox(height: 4),
//             Text(
//               title,
//               style: GoogleFonts.poppins(
//                 fontSize: 14,
//                 color: Colors.grey[600],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }



//   Widget _buildRecentActivitySection() {
//     return Container(
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
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
//           Row(
//             children: [
//               Text(
//                 'Recent Activity',
//                 style: GoogleFonts.poppins(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.black87,
//                 ),
//               ),
//               const Spacer(),
//               if (_isLoadingActivities)
//                 const SizedBox(
//                   width: 16,
//                   height: 16,
//                   child: CircularProgressIndicator(
//                     strokeWidth: 2,
//                     color: Color(0xFF5094FF),
//                   ),
//                 ),
//             ],
//           ),
//           const SizedBox(height: 16),
//           if (_isLoadingActivities)
//             const Center(
//               child: Padding(
//                 padding: EdgeInsets.all(20),
//                 child: CircularProgressIndicator(color: Color(0xFF5094FF)),
//               ),
//             )
//           else if (_recentActivities.isEmpty)
//             Center(
//               child: Padding(
//                 padding: const EdgeInsets.all(20),
//                 child: Text(
//                   'No recent activity',
//                   style: GoogleFonts.poppins(
//                     fontSize: 14,
//                     color: Colors.grey[600],
//                   ),
//                 ),
//               ),
//             )
//           else
//             Column(
//               children: [
//                 ..._recentActivities.asMap().entries.map((entry) {
//                   final index = entry.key;
//                   final activity = entry.value;
                  
//                   return Column(
//                     children: [
//                       _buildActivityItem(
//                         icon: activity['icon'],
//                         title: activity['title'],
//                         subtitle: activity['subtitle'],
//                         time: _formatTimeAgo(activity['time']),
//                         color: activity['color'],
//                       ),
//                       if (index < _recentActivities.length - 1) 
//                         const Divider(
//                           height: 1,
//                           thickness: 0.5,
//                           color: Color(0xFFE0E0E0),
//                         ),
//                     ],
//                   );
//                 }).toList(),
//                 // Load More/Less buttons
//                 if (_allActivities.isNotEmpty)
//                   Padding(
//                     padding: const EdgeInsets.only(top: 16),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         // Load Less button (left side)
//                         if (_recentActivities.length > _activitiesPerPage)
//                           TextButton(
//                             onPressed: _collapseActivities,
//                             style: TextButton.styleFrom(
//                               foregroundColor: Colors.black87,
//                               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                             ),
//                             child: Row(
//                               mainAxisSize: MainAxisSize.min,
//                               children: [
//                                 Text(
//                                   'Load less',
//                                   style: GoogleFonts.poppins(
//                                     fontSize: 14,
//                                     fontWeight: FontWeight.w500,
//                                   ),
//                                 ),
//                                 const SizedBox(width: 4),
//                                 Container(
//                                   width: 20,
//                                   height: 20,
//                                   decoration: const BoxDecoration(
//                                     color: Colors.black87,
//                                     shape: BoxShape.circle,
//                                   ),
//                                   child: const Icon(
//                                     Icons.keyboard_arrow_up,
//                                     color: Colors.white,
//                                     size: 16,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         if (_recentActivities.length <= _activitiesPerPage)
//                           const Spacer(),
//                         // Load More button (right side)
//                         if (_recentActivities.length < _allActivities.length)
//                           TextButton(
//                             onPressed: () {
//                               // Show more activities from the already loaded data
//                               final currentCount = _recentActivities.length;
//                               final nextBatch = _allActivities.take(currentCount + _activitiesPerPage).toList();
//                               setState(() {
//                                 _recentActivities = nextBatch;
//                               });
//                             },
//                             style: TextButton.styleFrom(
//                               foregroundColor: Colors.black87,
//                               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                             ),
//                             child: Row(
//                               mainAxisSize: MainAxisSize.min,
//                               children: [
//                                 Text(
//                                   'Load more',
//                                   style: GoogleFonts.poppins(
//                                     fontSize: 14,
//                                     fontWeight: FontWeight.w500,
//                                   ),
//                                 ),
//                                 const SizedBox(width: 4),
//                                 Container(
//                                   width: 20,
//                                   height: 20,
//                                   decoration: const BoxDecoration(
//                                     color: Colors.black87,
//                                     shape: BoxShape.circle,
//                                   ),
//                                   child: const Icon(
//                                     Icons.keyboard_arrow_down,
//                                     color: Colors.white,
//                                     size: 16,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                       ],
//                     ),
//                   ),

//               ],
//             ),
//         ],
//       ),
//     );
//   }

//   Widget _buildUpcomingAppointmentsSection() {
//     return Container(
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
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
//           Row(
//             children: [
//               Text(
//                 'Upcoming Appointments',
//                 style: GoogleFonts.poppins(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.black87,
//                 ),
//               ),
//               const Spacer(),
//               if (_isLoadingAppointments)
//                 const SizedBox(
//                   width: 16,
//                   height: 16,
//                   child: CircularProgressIndicator(
//                     strokeWidth: 2,
//                     color: Color(0xFFF5A623),
//                   ),
//                 ),
//             ],
//           ),
//           const SizedBox(height: 16),
//           if (_isLoadingAppointments)
//             const Center(
//               child: Padding(
//                 padding: EdgeInsets.all(20),
//                 child: CircularProgressIndicator(color: Color(0xFFF5A623)),
//               ),
//             )
//           else if (_upcomingAppointments.isEmpty)
//             Center(
//               child: Padding(
//                 padding: const EdgeInsets.all(20),
//                 child: Column(
//                   children: [
//                     Icon(
//                       Icons.calendar_today_outlined,
//                       size: 48,
//                       color: orange.withOpacity(0.5),
//                     ),
//                     const SizedBox(height: 12),
//                     Text(
//                       'No upcoming appointments',
//                       style: GoogleFonts.poppins(
//                         fontSize: 16,
//                         color: Colors.black54,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     Text(
//                       'All pending appointments have been processed',
//                       style: GoogleFonts.poppins(
//                         fontSize: 14,
//                         color: Colors.black45,
//                       ),
//                       textAlign: TextAlign.center,
//                     ),
//                   ],
//                 ),
//               ),
//             )
//           else
//             Column(
//               children: [
//                 ..._upcomingAppointments.take(_displayedAppointmentsCount).map((appointment) {
//                   return _buildAppointmentCard(context, appointment, orange);
//                 }).toList(),
//                 // Load More/Less buttons
//                 if (_upcomingAppointments.length > _appointmentsPerPage)
//                   Padding(
//                     padding: const EdgeInsets.only(top: 16),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         // Load Less button (left side)
//                         if (_displayedAppointmentsCount > _appointmentsPerPage)
//                           TextButton(
//                             onPressed: _collapseAppointments,
//                             style: TextButton.styleFrom(
//                               foregroundColor: Colors.black87,
//                               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                             ),
//                             child: Row(
//                               mainAxisSize: MainAxisSize.min,
//                               children: [
//                                 Text(
//                                   'Load less',
//                                   style: GoogleFonts.poppins(
//                                     fontSize: 14,
//                                     fontWeight: FontWeight.w500,
//                                   ),
//                                 ),
//                                 const SizedBox(width: 4),
//                                 Container(
//                                   width: 20,
//                                   height: 20,
//                                   decoration: const BoxDecoration(
//                                     color: Colors.black87,
//                                     shape: BoxShape.circle,
//                                   ),
//                                   child: const Icon(
//                                     Icons.keyboard_arrow_up,
//                                     color: Colors.white,
//                                     size: 16,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         if (_displayedAppointmentsCount <= _appointmentsPerPage)
//                           const Spacer(),
//                         // Load More button (right side)
//                         if (_displayedAppointmentsCount < _upcomingAppointments.length)
//                           TextButton(
//                             onPressed: _expandAppointments,
//                             style: TextButton.styleFrom(
//                               foregroundColor: Colors.black87,
//                               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                             ),
//                             child: Row(
//                               mainAxisSize: MainAxisSize.min,
//                               children: [
//                                 Text(
//                                   'Load more',
//                                   style: GoogleFonts.poppins(
//                                     fontSize: 14,
//                                     fontWeight: FontWeight.w500,
//                                   ),
//                                 ),
//                                 const SizedBox(width: 4),
//                                 Container(
//                                   width: 20,
//                                   height: 20,
//                                   decoration: const BoxDecoration(
//                                     color: Colors.black87,
//                                     shape: BoxShape.circle,
//                                   ),
//                                   child: const Icon(
//                                     Icons.keyboard_arrow_down,
//                                     color: Colors.white,
//                                     size: 16,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                       ],
//                     ),
//                   ),
//               ],
//             ),
//         ],
//       ),
//     );
//   }

//   Widget _buildAppointmentCard(BuildContext context, Map<String, dynamic> appointment, Color orange) {
//     final date = DateTime.parse(appointment['preferred_date']);
//     final time = appointment['preferred_time'];
//     final petName = appointment['pet_name'];
//     final petType = appointment['pet_type'];
//     final breed = appointment['breed'];
//     final services = _getSelectedServices(appointment);
//     final duration = appointment['estimated_duration'] ?? 60;
//     final userName = appointment['user_name'] ?? 'Unknown User';
    
//     return Container(
//       margin: const EdgeInsets.only(bottom: 12),
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.grey[50],
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: Colors.grey[200]!),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(8),
//                 decoration: BoxDecoration(
//                   color: orange.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Icon(
//                   Icons.pets,
//                   color: orange,
//                   size: 20,
//                 ),
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       petName ?? 'Unknown Pet',
//                       style: GoogleFonts.poppins(
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.black87,
//                       ),
//                     ),
//                     Text(
//                       '$petType${breed != null && breed.isNotEmpty ? ' • $breed' : ''}',
//                       style: GoogleFonts.poppins(
//                         fontSize: 14,
//                         color: Colors.grey[600],
//                       ),
//                     ),
//                     Text(
//                       'Owner: $userName',
//                       style: GoogleFonts.poppins(
//                         fontSize: 12,
//                         color: Colors.grey[500],
//                         fontStyle: FontStyle.italic,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                 decoration: BoxDecoration(
//                   color: orange.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Text(
//                   _getCountdownText(appointment),
//                   style: GoogleFonts.poppins(
//                     fontSize: 11,
//                     color: orange,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 8),
//           Wrap(
//             spacing: 16,
//             runSpacing: 8,
//             children: [
//               Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Icon(Icons.calendar_today, color: Colors.grey[600], size: 16),
//                   const SizedBox(width: 6),
//                   Text(
//                     DateFormat('MMM dd, yyyy').format(date),
//                     style: GoogleFonts.poppins(
//                       fontSize: 14,
//                       color: Colors.grey[700],
//                     ),
//                   ),
//                 ],
//               ),
//               Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Icon(Icons.access_time, color: Colors.grey[600], size: 16),
//                   const SizedBox(width: 6),
//                   Text(
//                     _formatTime(time),
//                     style: GoogleFonts.poppins(
//                       fontSize: 14,
//                       color: Colors.grey[700],
//                     ),
//                   ),
//                 ],
//               ),
//               Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Icon(Icons.timer, color: Colors.grey[600], size: 16),
//                   const SizedBox(width: 6),
//                   Text(
//                     _formatDuration(duration),
//                     style: GoogleFonts.poppins(
//                       fontSize: 14,
//                       color: Colors.grey[700],
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//           if (services.isNotEmpty) ...[
//             const SizedBox(height: 8),
//             Row(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Icon(Icons.build, color: Colors.grey[600], size: 16),
//                 const SizedBox(width: 6),
//                 Expanded(
//                   child: Text(
//                     '$services',
//                     style: GoogleFonts.poppins(
//                       fontSize: 14,
//                       color: Colors.grey[700],
//                     ),
//                     overflow: TextOverflow.ellipsis,
//                     maxLines: 2,
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ],
//       ),
//     );
//   }

//   Widget _buildActivityItem({
//     required IconData icon,
//     required String title,
//     required String subtitle,
//     required String time,
//     required Color color,
//   }) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 12),
//       child: Row(
//         children: [
//           Container(
//             width: 32,
//             height: 32,
//             decoration: BoxDecoration(
//               color: color,
//               borderRadius: BorderRadius.circular(6),
//             ),
//             child: Icon(
//               icon,
//               color: Colors.white,
//               size: 18,
//             ),
//           ),
//           const SizedBox(width: 16),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   title,
//                   style: GoogleFonts.poppins(
//                     fontWeight: FontWeight.w600,
//                     fontSize: 14,
//                     color: Colors.black87,
//                   ),
//                 ),
//                 const SizedBox(height: 2),
//                 Text(
//                   subtitle,
//                   style: GoogleFonts.poppins(
//                     fontSize: 12,
//                     color: Colors.grey[600],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           Text(
//             time,
//             style: GoogleFonts.poppins(
//               fontSize: 12,
//               color: Colors.grey[500],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
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
//                 Text(
//                   'Dashboard',
//                   style: GoogleFonts.poppins(
//                     fontSize: 24,
//                     fontWeight: FontWeight.bold,
//                     color: orange,
//                   ),
//                 ),
//                 const SizedBox(height: 24),
//                 Row(
//                   children: [
//                     Expanded(
//                       child: _buildStatCard(
//                         title: 'Total Users',
//                         value: _totalUsersCount.toString(),
//                         icon: Icons.people,
//                         color: const Color(0xFF5094FF),
//                         onTap: () {
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (context) => const AllUsersAdminPage(),
//                             ),
//                           );
//                         },
//                       ),
//                     ),
//                     const SizedBox(width: 16),
//                     Expanded(
//                       child: _buildStatCard(
//                         title: 'Booked Animals',
//                         value: _totalAnimalsBookedCount.toString(),
//                         icon: Icons.pets,
//                         color: orange,
//                         onTap: () {
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (context) => const AllAnimalsAdminPage(),
//                             ),
//                           );
//                         },
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 24),
//                 _buildRecentActivitySection(),
//                 const SizedBox(height: 24),
//                 // Upcoming Appointments Section
//                 _buildUpcomingAppointmentsSection(),
//                 const SizedBox(height: 24),
//                 // Monthly Bookings Section
//                 _buildMonthlyBookingsSection(),
//                 const SizedBox(height: 24),
//                 // Testimonials Section
//                 Text(
//                   'Testimonials',
//                   style: GoogleFonts.poppins(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.black,
//                   ),
//                 ),
//                 const SizedBox(height: 12),
//                 Container(
//                   decoration: BoxDecoration(
//                     color: lightOrange,
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                   padding: const EdgeInsets.all(16),
//                   child: _isLoadingReviews
//                       ? const Center(child: CircularProgressIndicator(color: Color(0xFFF5A623)))
//                       : _reviews.isEmpty
//                           ? Column(
//                               children: [
//                                 Icon(Icons.star_outline, size: 48, color: orange.withOpacity(0.5)),
//                                 const SizedBox(height: 12),
//                                 Text('No reviews yet', style: GoogleFonts.poppins(fontSize: 16, color: Colors.black54, fontWeight: FontWeight.w500)),
//                                 const SizedBox(height: 8),
//                                 Text('No testimonials have been submitted yet.', style: GoogleFonts.poppins(fontSize: 14, color: Colors.black45)),
//                               ],
//                             )
//                           : SizedBox(
//                               height: 140,
//                               child: PageView.builder(
//                                 controller: _testimonialController,
//                                 itemCount: _reviews.length,
//                                 itemBuilder: (context, index) {
//                                   final review = _reviews[index];
//                                   final fullName = review['users']?['full_name'] ?? review['user_name'] ?? 'Anonymous';
//                                   final formattedName = _formatUserName(fullName);
//                                   final reviewText = review['review_text'] ?? '';
//                                   final rating = review['rating'] ?? 5;
//                                   return Padding(
//                                     padding: const EdgeInsets.symmetric(horizontal: 8),
//                                     child: _testimonialCardCarousel(
//                                       quote: reviewText.isNotEmpty ? reviewText : 'Great service!',
//                                       name: formattedName,
//                                       stars: rating,
//                                     ),
//                                   );
//                                 },
//                               ),
//                             ),
//                 ),
//               ],
//             ),
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
//           selectedItemColor: orange,
//           unselectedItemColor: Colors.grey,
//           onTap: _onItemTapped,
//           type: BottomNavigationBarType.fixed,
//           backgroundColor: Colors.white,
//         ),
//       ),
//     );
//   }

//   Widget _buildMonthlyBookingsSection() {
//     final monthlyCounts = _monthlyBookingsForDemographics();
//     final monthlyMaxY = _dynamicMaxY(monthlyCounts.values, step: 5, min: 5);
    
//     return Container(
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
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
//           Row(
//             children: [
//               Text(
//                 'Monthly Bookings',
//                 style: GoogleFonts.poppins(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.black87,
//                 ),
//               ),
//               const Spacer(),
//               if (_isLoadingMonthlyBookings)
//                 const SizedBox(
//                   width: 16,
//                   height: 16,
//                   child: CircularProgressIndicator(
//                     strokeWidth: 2,
//                     color: Color(0xFFF5A623),
//                   ),
//                 ),
//             ],
//           ),
//           const SizedBox(height: 16),
//           if (_isLoadingMonthlyBookings)
//             const Center(
//               child: Padding(
//                 padding: EdgeInsets.all(20),
//                 child: CircularProgressIndicator(color: Color(0xFFF5A623)),
//               ),
//             )
//           else if (_allAnimals.isEmpty)
//             Center(
//               child: Padding(
//                 padding: const EdgeInsets.all(20),
//                 child: Column(
//                   children: [
//                     Icon(
//                       Icons.bar_chart_outlined,
//                       size: 48,
//                       color: orange.withOpacity(0.5),
//                     ),
//                     const SizedBox(height: 12),
//                     Text(
//                       'No booking data available',
//                       style: GoogleFonts.poppins(
//                         fontSize: 16,
//                         color: Colors.black54,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     Text(
//                       'Monthly booking statistics will appear here',
//                       style: GoogleFonts.poppins(
//                         fontSize: 14,
//                         color: Colors.black45,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             )
//           else
//             SizedBox(
//               height: 200,
//               child: LineChart(
//                 LineChartData(
//                   lineBarsData: [
//                     LineChartBarData(
//                       spots: [
//                         for (int i = 1; i <= 12; i++)
//                           FlSpot(i.toDouble(), monthlyCounts[i]!.toDouble()),
//                       ],
//                       isCurved: true,
//                       color: orange,
//                       barWidth: 4,
//                       dotData: FlDotData(
//                         show: true,
//                         getDotPainter: (spot, percent, barData, index) {
//                           return FlDotCirclePainter(
//                             radius: 4,
//                             color: orange,
//                             strokeWidth: 2,
//                             strokeColor: Colors.white,
//                           );
//                         },
//                       ),
//                       belowBarData: BarAreaData(
//                         show: true,
//                         color: orange.withOpacity(0.1),
//                       ),
//                     ),
//                   ],
//                   titlesData: FlTitlesData(
//                     leftTitles: AxisTitles(
//                       sideTitles: SideTitles(
//                         showTitles: true,
//                         reservedSize: 30,
//                         getTitlesWidget: (value, meta) {
//                           return Text(
//                             value.toInt().toString(),
//                             style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey[600]),
//                           );
//                         },
//                         interval: 5,
//                       ),
//                     ),
//                     rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
//                     topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
//                     bottomTitles: AxisTitles(
//                       sideTitles: SideTitles(
//                         showTitles: true,
//                         getTitlesWidget: (value, meta) {
//                           const months = [
//                             '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
//                             'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
//                           ];
//                           if (value >= 1 && value <= 12) {
//                             return Text(months[value.toInt()], style: GoogleFonts.poppins(fontSize: 12));
//                           }
//                           return const SizedBox();
//                         },
//                       ),
//                     ),
//                   ),
//                   borderData: FlBorderData(show: false),
//                   gridData: FlGridData(
//                     show: true,
//                     horizontalInterval: 5,
//                     getDrawingHorizontalLine: (value) {
//                       return FlLine(
//                         color: Colors.grey[300]!,
//                         strokeWidth: 1,
//                       );
//                     },
//                   ),
//                   maxY: monthlyMaxY.toDouble(),
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/auth_service.dart';
import '../../config/supabase_config.dart';
import 'bookings_admin.dart';
import 'messages_admin.dart';
import 'all_users_admin.dart';
import 'all_animals_admin.dart';
import 'settings_admin.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

class HomeAdminPage extends StatefulWidget {
  const HomeAdminPage({super.key});

  @override
  State<HomeAdminPage> createState() => _HomeAdminPageState();
}

class _HomeAdminPageState extends State<HomeAdminPage> {
  int _selectedIndex = 0;
  final AuthService _authService = AuthService();
  final orange = const Color(0xFFF5A623);
  final lightOrange = const Color(0xFFFFF6E7);
  int _totalUsersCount = 0;
  int _totalAnimalsBookedCount = 0;
  bool _isLoadingData = true;
  List<Map<String, dynamic>> _recentActivities = [];
  bool _isLoadingActivities = true;
  Timer? _refreshTimer;
  static const int _activitiesPerPage = 5;
  List<Map<String, dynamic>> _allActivities = [];
  List<Map<String, dynamic>> _reviews = [];
  bool _isLoadingReviews = true;
  late PageController _testimonialController = PageController(viewportFraction: 0.85);
  List<Map<String, dynamic>> _upcomingAppointments = [];
  bool _isLoadingAppointments = true;
  int _displayedAppointmentsCount = 3;
  static const int _appointmentsPerPage = 3;
  List<Map<String, dynamic>> _allAnimals = [];
  bool _isLoadingMonthlyBookings = true;

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
    _fetchRecentActivities();
    _fetchReviews();
    _fetchUpcomingAppointments();
    _fetchMonthlyBookings();
    _startAutoScroll();
    _refreshTimer = Timer.periodic(const Duration(seconds: 300), (timer) {
      if (mounted) {
        _fetchRecentActivities();
        _fetchUpcomingAppointments();
        _fetchMonthlyBookings();
      }
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _testimonialController.dispose();
    super.dispose();
  }

  void _startAutoScroll() {
    Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_testimonialController.hasClients && _reviews.isNotEmpty) {
        final currentPage = _testimonialController.page?.round() ?? 0;
        final nextPage = (currentPage + 1) % _reviews.length;
        _testimonialController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  Future<void> _handleRefresh() async {
    await _fetchDashboardData();
    await _fetchRecentActivities();
    await _fetchReviews();
    await _fetchUpcomingAppointments();
    await _fetchMonthlyBookings();
  }

  Future<void> _fetchDashboardData() async {
    setState(() => _isLoadingData = true);
    try {
      final allUsers = await SupabaseConfig.client.from('users').select('*');
      final userResponse = await SupabaseConfig.client
          .from('users')
          .select()
          .count(CountOption.exact);
      final bookingResponse = await SupabaseConfig.client
          .from('grooming_appointments')
          .select()
          .count(CountOption.exact);
      setState(() {
        _totalUsersCount = allUsers.length;
        _totalAnimalsBookedCount = bookingResponse.count;
      });
    } catch (e) {
      setState(() {
        _totalUsersCount = 0;
        _totalAnimalsBookedCount = 0;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Unable to connect to database. Showing cached data.'),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingData = false);
      }
    }
  }

  Future<void> _fetchRecentActivities({bool loadMore = false}) async {
    if (!mounted) return;
    if (loadMore) return;
    setState(() {
      _isLoadingActivities = true;
      _recentActivities = [];
      _allActivities = [];
    });
    try {
      List<Map<String, dynamic>> activities = [];
      final recentUsers = await SupabaseConfig.client
          .from('users')
          .select('*')
          .gte('created_at', DateTime.now().subtract(const Duration(days: 30)).toIso8601String())
          .order('created_at', ascending: false);
      for (final user in recentUsers) {
        activities.add({
          'type': 'user_registration',
          'title': 'New User Registered',
          'subtitle': '${user['full_name']} registered as a new user',
          'time': user['created_at'],
          'icon': Icons.person_add,
          'color': const Color(0xFF5094FF),
        });
      }
      final recentAppointments = await SupabaseConfig.client
          .from('grooming_appointments')
          .select('id, user_id, pet_name, preferred_date, preferred_time, status, created_at, updated_at')
          .gte('created_at', DateTime.now().subtract(const Duration(days: 30)).toIso8601String())
          .order('created_at', ascending: false);
      for (final appointment in recentAppointments) {
        activities.add({
          'type': 'appointment_booked',
          'title': 'New Appointment Booked',
          'subtitle': 'New appointment booked for ${appointment['pet_name']}',
          'time': appointment['created_at'],
          'icon': Icons.calendar_today,
          'color': const Color(0xFFF5A623),
        });
        if (appointment['status'] == 'Cancelled') {
          activities.add({
            'type': 'appointment_cancelled',
            'title': 'Appointment Cancelled',
            'subtitle': 'Appointment cancelled for ${appointment['pet_name']}',
            'time': appointment['updated_at'] ?? appointment['created_at'],
            'icon': Icons.cancel,
            'color': Colors.red,
          });
        } else if (appointment['status'] == 'Completed') {
          activities.add({
            'type': 'appointment_completed',
            'title': 'Appointment Completed',
            'subtitle': 'Grooming completed for ${appointment['pet_name']}',
            'time': appointment['updated_at'] ?? appointment['created_at'],
            'icon': Icons.check_circle,
            'color': Colors.green,
          });
        }
      }
      activities.sort((a, b) {
        final timeA = DateTime.parse(a['time']);
        final timeB = DateTime.parse(b['time']);
        return timeB.compareTo(timeA);
      });
      if (mounted) {
        setState(() {
          _allActivities = activities;
          _recentActivities = activities.take(_activitiesPerPage).toList();
          _isLoadingActivities = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _allActivities = [];
          _recentActivities = [];
          _isLoadingActivities = false;
        });
      }
    }
  }

  Future<void> _fetchReviews() async {
    try {
      try {
        final response = await SupabaseConfig.client
            .from('rate_review')
            .select('''
              id,
              rating,
              review_text,
              created_at,
              user_id,
              users!inner(full_name)
            ''')
            .order('created_at', ascending: false)
            .limit(10);
        if (mounted) {
          setState(() {
            _reviews = List<Map<String, dynamic>>.from(response);
            _isLoadingReviews = false;
          });
        }
      } catch (e) {
        final reviewsResponse = await SupabaseConfig.client
            .from('rate_review')
            .select('''
              id,
              rating,
              review_text,
              created_at,
              user_id
            ''')
            .order('created_at', ascending: false)
            .limit(10);
        final reviewsWithUsers = <Map<String, dynamic>>[];
        for (final review in reviewsResponse) {
          try {
            final userResponse = await SupabaseConfig.client
                .from('users')
                .select('full_name')
                .eq('id', review['user_id'])
                .maybeSingle();
            final reviewWithUser = Map<String, dynamic>.from(review);
            reviewWithUser['user_name'] = userResponse?['full_name'] ?? 'Anonymous';
            reviewsWithUsers.add(reviewWithUser);
          } catch (e) {
            final reviewWithUser = Map<String, dynamic>.from(review);
            reviewWithUser['user_name'] = 'Anonymous';
            reviewsWithUsers.add(reviewWithUser);
          }
        }
        if (mounted) {
          setState(() {
            _reviews = reviewsWithUsers;
            _isLoadingReviews = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _reviews = [];
          _isLoadingReviews = false;
        });
      }
    }
  }

  Future<void> _fetchUpcomingAppointments() async {
    try {
      final now = DateTime.now();
      final response = await SupabaseConfig.client
          .from('grooming_appointments')
          .select('''
            id,
            pet_name,
            pet_type,
            breed,
            preferred_date,
            preferred_time,
            estimated_duration,
            service_bath,
            service_haircut,
            service_nail_trim,
            service_ear_cleaning,
            status,
            user_id,
            created_at
          ''')
          .eq('status', 'Pending')
          .gte('preferred_date', DateFormat('yyyy-MM-dd').format(now))
          .order('preferred_date', ascending: true)
          .order('preferred_time', ascending: true)
          .limit(10);
      final appointmentsWithUsers = <Map<String, dynamic>>[];
      for (final appointment in response) {
        try {
          final userResponse = await SupabaseConfig.client
              .from('users')
              .select('full_name')
              .eq('id', appointment['user_id'])
              .maybeSingle();
          final appointmentWithUser = Map<String, dynamic>.from(appointment);
          appointmentWithUser['user_name'] = userResponse?['full_name'] ?? 'Unknown User';
          appointmentsWithUsers.add(appointmentWithUser);
        } catch (e) {
          final appointmentWithUser = Map<String, dynamic>.from(appointment);
          appointmentWithUser['user_name'] = 'Unknown User';
          appointmentsWithUsers.add(appointmentWithUser);
        }
      }
      if (mounted) {
        setState(() {
          _upcomingAppointments = appointmentsWithUsers;
          _isLoadingAppointments = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _upcomingAppointments = [];
          _isLoadingAppointments = false;
        });
      }
    }
  }

  Future<void> _fetchMonthlyBookings() async {
    try {
      final response = await SupabaseConfig.client
          .from('grooming_appointments')
          .select('''
            id, pet_name, pet_type, pet_type_other, breed, pet_size, age, gender,
            allergies_medical_conditions, preferred_date, preferred_time, status,
            user_id, created_at
          ''')
          .order('created_at', ascending: false);
      if (mounted) {
        setState(() {
          _allAnimals = List<Map<String, dynamic>>.from(response);
          _isLoadingMonthlyBookings = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _allAnimals = [];
          _isLoadingMonthlyBookings = false;
        });
      }
    }
  }

  String _getCountdownText(Map<String, dynamic> appointment) {
    try {
      final date = DateTime.parse(appointment['preferred_date']);
      final time = appointment['preferred_time'];
      final timeParts = time.split(':');
      final appointmentDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        int.parse(timeParts[0]),
        int.parse(timeParts[1]),
      );
      final now = DateTime.now();
      final difference = appointmentDateTime.difference(now);
      if (difference.isNegative) {
        return 'Passed';
      }
      final days = difference.inDays;
      final hours = difference.inHours % 24;
      final minutes = difference.inMinutes % 60;
      if (days > 0) {
        return '$days day${days == 1 ? '' : 's'} $hours hr';
      } else if (hours > 0) {
        return '$hours hr $minutes min';
      } else {
        return '$minutes min';
      }
    } catch (e) {
      return 'Time unavailable';
    }
  }

  String _formatTimeAgo(String dateTimeString) {
    try {
      final dateTime = DateTime.parse(dateTimeString);
      final now = DateTime.now();
      final difference = now.difference(dateTime);
      if (difference.inDays > 0) {
        return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return 'Unknown time';
    }
  }

  String _formatUserName(String fullName) {
    if (fullName == 'Anonymous' || fullName.isEmpty) {
      return 'Anonymous';
    }
    final nameParts = fullName.trim().split(' ');
    if (nameParts.isEmpty) {
      return 'Anonymous';
    }
    if (nameParts.length == 1) {
      return nameParts[0];
    }
    final firstName = nameParts[0];
    final lastNameInitial = nameParts[nameParts.length - 1][0].toUpperCase();
    return '$firstName $lastNameInitial.';
  }

  Widget _testimonialCardCarousel({required String quote, required String name, int stars = 5, Color accent = const Color(0xFFF5A623)}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '"$quote"',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.black87,
              fontStyle: FontStyle.italic,
              height: 1.4,
            ),
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: List.generate(stars, (index) =>
                  const Icon(Icons.star, color: Color(0xFFF5A623), size: 16)
                ),
              ),
              Text(
                '- $name',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: accent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _collapseActivities() {
    setState(() {
      _recentActivities = _allActivities.take(_activitiesPerPage).toList();
    });
  }

  void _expandAppointments() {
    setState(() {
      _displayedAppointmentsCount = (_displayedAppointmentsCount + _appointmentsPerPage).clamp(_appointmentsPerPage, _upcomingAppointments.length);
    });
  }

  void _collapseAppointments() {
    setState(() {
      _displayedAppointmentsCount = _appointmentsPerPage;
    });
  }

  String _getSelectedServices(Map<String, dynamic> appointment) {
    final services = <String>[];
    if (appointment['service_bath'] == true) services.add('Bath');
    if (appointment['service_haircut'] == true) services.add('Haircut');
    if (appointment['service_nail_trim'] == true) services.add('Nail Trim');
    if (appointment['service_ear_cleaning'] == true) services.add('Ear Cleaning');
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

  Map<int, int> _monthlyBookingsForDemographics() {
    final Map<int, int> counts = {for (var i = 1; i <= 12; i++) i: 0};
    for (final animal in _allAnimals) {
      final dateStr = animal['created_at'] ?? animal['preferred_date'];
      if (dateStr != null) {
        final date = DateTime.tryParse(dateStr);
        if (date != null) {
          counts[date.month] = counts[date.month]! + 1;
        }
      }
    }
    return counts;
  }

  int _dynamicMaxY(Iterable<int> values, {int step = 5, int min = 5}) {
    final maxVal = values.isEmpty ? 0 : values.reduce((a, b) => a > b ? a : b);
    if (maxVal <= min) return min;
    final rounded = ((maxVal + step - 1) ~/ step) * step;
    return rounded;
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color),
                ),
                const Spacer(),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey[400],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivitySection() {
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Recent Activity',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const Spacer(),
              if (_isLoadingActivities)
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Color(0xFF5094FF),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (_isLoadingActivities)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(color: Color(0xFF5094FF)),
              ),
            )
          else if (_recentActivities.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'No recent activity',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            )
          else
            Column(
              children: [
                ..._recentActivities.asMap().entries.map((entry) {
                  final index = entry.key;
                  final activity = entry.value;
                  return Column(
                    children: [
                      _buildActivityItem(
                        icon: activity['icon'],
                        title: activity['title'],
                        subtitle: activity['subtitle'],
                        time: _formatTimeAgo(activity['time']),
                        color: activity['color'],
                      ),
                      if (index < _recentActivities.length - 1)
                        const Divider(
                          height: 1,
                          thickness: 0.5,
                          color: Color(0xFFE0E0E0),
                        ),
                    ],
                  );
                }).toList(),
                if (_allActivities.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (_recentActivities.length > _activitiesPerPage)
                          TextButton(
                            onPressed: _collapseActivities,
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.black87,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Load less',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Container(
                                  width: 20,
                                  height: 20,
                                  decoration: const BoxDecoration(
                                    color: Colors.black87,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.keyboard_arrow_up,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (_recentActivities.length <= _activitiesPerPage)
                          const Spacer(),
                        if (_recentActivities.length < _allActivities.length)
                          TextButton(
                            onPressed: () {
                              final currentCount = _recentActivities.length;
                              final nextBatch = _allActivities.take(currentCount + _activitiesPerPage).toList();
                              setState(() {
                                _recentActivities = nextBatch;
                              });
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.black87,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Load more',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Container(
                                  width: 20,
                                  height: 20,
                                  decoration: const BoxDecoration(
                                    color: Colors.black87,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.keyboard_arrow_down,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildUpcomingAppointmentsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Upcoming Appointments',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const Spacer(),
              if (_isLoadingAppointments)
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Color(0xFFF5A623),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (_isLoadingAppointments)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(color: Color(0xFFF5A623)),
              ),
            )
          else if (_upcomingAppointments.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 48,
                      color: orange.withOpacity(0.5),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No upcoming appointments',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.black54,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'All pending appointments have been processed',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.black45,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          else
            Column(
              children: [
                ..._upcomingAppointments.take(_displayedAppointmentsCount).map((appointment) {
                  return _buildAppointmentCard(context, appointment, orange);
                }).toList(),
                if (_upcomingAppointments.length > _appointmentsPerPage)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (_displayedAppointmentsCount > _appointmentsPerPage)
                          TextButton(
                            onPressed: _collapseAppointments,
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.black87,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Load less',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Container(
                                  width: 20,
                                  height: 20,
                                  decoration: const BoxDecoration(
                                    color: Colors.black87,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.keyboard_arrow_up,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (_displayedAppointmentsCount <= _appointmentsPerPage)
                          const Spacer(),
                        if (_displayedAppointmentsCount < _upcomingAppointments.length)
                          TextButton(
                            onPressed: _expandAppointments,
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.black87,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Load more',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Container(
                                  width: 20,
                                  height: 20,
                                  decoration: const BoxDecoration(
                                    color: Colors.black87,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.keyboard_arrow_down,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildAppointmentCard(BuildContext context, Map<String, dynamic> appointment, Color orange) {
    final date = DateTime.parse(appointment['preferred_date']);
    final time = appointment['preferred_time'];
    final petName = appointment['pet_name'];
    final petType = appointment['pet_type'];
    final breed = appointment['breed'];
    final services = _getSelectedServices(appointment);
    final duration = appointment['estimated_duration'] ?? 60;
    final userName = appointment['user_name'] ?? 'Unknown User';
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.pets,
                  color: orange,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      petName ?? 'Unknown Pet',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      '$petType${breed != null && breed.isNotEmpty ? ' • $breed' : ''}',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      'Owner: $userName',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey[500],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _getCountdownText(appointment),
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: orange,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.calendar_today, color: Colors.grey[600], size: 16),
                  const SizedBox(width: 6),
                  Text(
                    DateFormat('MMM dd, yyyy').format(date),
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.access_time, color: Colors.grey[600], size: 16),
                  const SizedBox(width: 6),
                  Text(
                    _formatTime(time),
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.timer, color: Colors.grey[600], size: 16),
                  const SizedBox(width: 6),
                  Text(
                    _formatDuration(duration),
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (services.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.build, color: Colors.grey[600], size: 16),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '$services',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActivityItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required String time,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyBookingsSection() {
    final monthlyCounts = _monthlyBookingsForDemographics();
    final monthlyMaxY = _dynamicMaxY(monthlyCounts.values, step: 5, min: 5);
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Monthly Bookings',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const Spacer(),
              if (_isLoadingMonthlyBookings)
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Color(0xFFF5A623),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (_isLoadingMonthlyBookings)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(color: Color(0xFFF5A623)),
              ),
            )
          else if (_allAnimals.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Icon(
                      Icons.bar_chart_outlined,
                      size: 48,
                      color: orange.withOpacity(0.5),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No booking data available',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.black54,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Monthly booking statistics will appear here',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.black45,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  lineBarsData: [
                    LineChartBarData(
                      spots: [
                        for (int i = 1; i <= 12; i++)
                          FlSpot(i.toDouble(), monthlyCounts[i]!.toDouble()),
                      ],
                      isCurved: true,
                      color: orange,
                      barWidth: 4,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 4,
                            color: orange,
                            strokeWidth: 2,
                            strokeColor: Colors.white,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        color: orange.withOpacity(0.1),
                      ),
                    ),
                  ],
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey[600]),
                          );
                        },
                        interval: 5,
                      ),
                    ),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          const months = [
                            '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                            'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
                          ];
                          if (value >= 1 && value <= 12) {
                            return Text(months[value.toInt()], style: GoogleFonts.poppins(fontSize: 12));
                          }
                          return const SizedBox();
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  gridData: FlGridData(
                    show: true,
                    horizontalInterval: 5,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.grey[300]!,
                        strokeWidth: 1,
                      );
                    },
                  ),
                  maxY: monthlyMaxY.toDouble(),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _onItemTapped(int index) async {
    setState(() => _selectedIndex = index);
    switch (index) {
      case 0:
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const BookingsAdminPage()),
        );
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

  @override
  Widget build(BuildContext context) {
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
            onRefresh: _handleRefresh,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dashboard',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: orange,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          title: 'Total Users',
                          value: _totalUsersCount.toString(),
                          icon: Icons.people,
                          color: const Color(0xFF5094FF),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AllUsersAdminPage(),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildStatCard(
                          title: 'Booked Animals',
                          value: _totalAnimalsBookedCount.toString(),
                          icon: Icons.pets,
                          color: orange,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AllAnimalsAdminPage(),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildRecentActivitySection(),
                  const SizedBox(height: 24),
                  _buildUpcomingAppointmentsSection(),
                  const SizedBox(height: 24),
                  _buildMonthlyBookingsSection(),
                  const SizedBox(height: 24),
                  Text(
                    'Testimonials',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: lightOrange,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: _isLoadingReviews
                        ? const Center(child: CircularProgressIndicator(color: Color(0xFFF5A623)))
                        : _reviews.isEmpty
                            ? Column(
                                children: [
                                  Icon(Icons.star_outline, size: 48, color: orange.withOpacity(0.5)),
                                  const SizedBox(height: 12),
                                  Text('No reviews yet', style: GoogleFonts.poppins(fontSize: 16, color: Colors.black54, fontWeight: FontWeight.w500)),
                                  const SizedBox(height: 8),
                                  Text('No testimonials have been submitted yet.', style: GoogleFonts.poppins(fontSize: 14, color: Colors.black45)),
                                ],
                              )
                            : SizedBox(
                                height: 140,
                                child: PageView.builder(
                                  controller: _testimonialController,
                                  itemCount: _reviews.length,
                                  itemBuilder: (context, index) {
                                    final review = _reviews[index];
                                    final fullName = review['users']?['full_name'] ?? review['user_name'] ?? 'Anonymous';
                                    final formattedName = _formatUserName(fullName);
                                    final reviewText = review['review_text'] ?? '';
                                    final rating = review['rating'] ?? 5;
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 8),
                                      child: _testimonialCardCarousel(
                                        quote: reviewText.isNotEmpty ? reviewText : 'Great service!',
                                        name: formattedName,
                                        stars: rating,
                                      ),
                                    );
                                  },
                                ),
                              ),
                  ),
                ],
              ),
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
          selectedItemColor: orange,
          unselectedItemColor: Colors.grey,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
        ),
      ),
    );
  }
}
