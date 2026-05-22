// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import '/profile/profile_page.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'grooming/grooming_appointment.dart';
// // import 'shop/shop_page.dart';
// import 'messages/messages_page.dart';
// import 'package:intl/intl.dart';
// import 'dart:async';
// import 'package:url_launcher/url_launcher.dart';

// class HomePage extends StatefulWidget {
//   const HomePage({super.key});

//   @override
//   State<HomePage> createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage> {
//   int _selectedIndex = 0;
//   List<Map<String, dynamic>> _upcomingAppointments = [];
//   List<Map<String, dynamic>> _reviews = [];
//   bool _isLoading = true;
//   bool _isLoadingReviews = true;
//   Timer? _countdownTimer;

//   int _displayedAppointmentsCount = 3;
//   final ScrollController _scrollController = ScrollController();
//   bool _showScrollToTop = false;
//   int _displayedFAQsCount = 3;
//   static const int _appointmentsPerPage = 3;
//   static const int _faqsPerPage = 3;
//   late PageController _testimonialController = PageController(viewportFraction: 0.85);
//   Timer? _autoScrollTimer;

//   @override
//   void initState() {
//     super.initState();
//     _loadUpcomingAppointments();
//     _loadReviews();
//     _startCountdownTimer();
//     _startAutoScroll();
//     _scrollController.addListener(_onScroll);
//   }

//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     // Refresh appointments when the page becomes active
//     _loadUpcomingAppointments();
//     _loadReviews();
//   }



//   Future<void> _loadUpcomingAppointments() async {
//     try {
//       final user = Supabase.instance.client.auth.currentUser;
//       if (user != null) {
//         final now = DateTime.now();
//         final response = await Supabase.instance.client
//             .from('grooming_appointments')
//             .select('''
//               id,
//               pet_name,
//               pet_type,
//               breed,
//               preferred_date,
//               preferred_time,
//               estimated_duration,
//               service_bath,
//               service_haircut,
//               service_nail_trim,
//               service_ear_cleaning,
//               status,
//               user_id,
//               created_at
//             ''')
//             .eq('user_id', user.id)
//             .eq('status', 'Pending')
//             .gte('preferred_date', DateFormat('yyyy-MM-dd').format(now))
//             .order('preferred_date', ascending: true)
//             .order('preferred_time', ascending: true)
//             .limit(5);

//         if (mounted) {
//           setState(() {
//             _upcomingAppointments = List<Map<String, dynamic>>.from(response);
//             _isLoading = false;
//           });
//         }
//       }
//     } catch (e) {
//       print('Error loading appointments: $e');
//       if (mounted) {
//         setState(() {
//           _isLoading = false;
//         });
//       }
//     }
//   }

//   Future<void> _loadReviews() async {
//     try {
//       // Try to use the joined query first
//       try {
//         final response = await Supabase.instance.client
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
//         print('Joined query failed, using fallback: $e');
        
//         // First, get the reviews
//         final reviewsResponse = await Supabase.instance.client
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

//         // Then, get user names for each review
//         final reviewsWithUsers = <Map<String, dynamic>>[];
        
//         for (final review in reviewsResponse) {
//           try {
//             final userResponse = await Supabase.instance.client
//                 .from('users')
//                 .select('full_name')
//                 .eq('id', review['user_id'])
//                 .maybeSingle();
            
//             final reviewWithUser = Map<String, dynamic>.from(review);
//             reviewWithUser['user_name'] = userResponse?['full_name'] ?? 'Anonymous';
//             reviewsWithUsers.add(reviewWithUser);
//           } catch (e) {
//             // If user not found, add review with anonymous name
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
//       print('Error loading reviews: $e');
//       if (mounted) {
//         setState(() {
//           _isLoadingReviews = false;
//         });
//       }
//     }
//   }

//   void _startCountdownTimer() {
//     _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
//       if (mounted) {
//         setState(() {
//           // This will trigger a rebuild to update countdown timers
//         });
//       }
//     });
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

//   void _startAutoScroll() {
//     _autoScrollTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
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

//   void _expandFAQs() {
//     setState(() {
//       _displayedFAQsCount = (_displayedFAQsCount + _faqsPerPage).clamp(_faqsPerPage, _allFAQs.length);
//     });
//   }

//   void _collapseFAQs() {
//     setState(() {
//       _displayedFAQsCount = _faqsPerPage;
//     });
//   }

//   List<Map<String, String>> _getDisplayedFAQs() {
//     return _allFAQs.take(_displayedFAQsCount).toList();
//   }

//   @override
//   void dispose() {
//     _countdownTimer?.cancel();
//     _testimonialController.dispose();
//     _autoScrollTimer?.cancel();
//     _scrollController.removeListener(_onScroll);
//     _scrollController.dispose();
//     super.dispose();
//   }

//   void _onScroll() {
//     if (_scrollController.position.pixels > 200) {
//       if (!_showScrollToTop) {
//         setState(() {
//           _showScrollToTop = true;
//         });
//       }
//     } else {
//       if (_showScrollToTop) {
//         setState(() {
//           _showScrollToTop = false;
//         });
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
//     // Do not call setState before navigation for navigation actions
//     switch (index) {
//       case 0:
//         // Stay on Home page or navigate to a dedicated Home route if needed
//         break;
//       case 1:
//         Navigator.pushReplacementNamed(context, '/grooming');
//         break;
//       // case 2:
//       //   Navigator.pushReplacementNamed(context, '/shop');
//       //   break;
//       case 2:
//         Navigator.pushReplacementNamed(context, '/messages');
//         break;
//       case 3:
//            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ProfilePage()));
//         break;
//     }
//     setState(() {
//       _selectedIndex = index;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final orange = const Color(0xFFF5A623);
//     final lightOrange = const Color(0xFFFFF6E7);
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SafeArea(
//         child: SingleChildScrollView(
//           controller: _scrollController,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Header with logo matching landing page style
//               Container(
//                 width: double.infinity,
//                 padding: const EdgeInsets.only(top: 24, bottom: 12),
//                 decoration: const BoxDecoration(
//                   gradient: LinearGradient(
//                     colors: [Color(0xFFFFF6E7), Colors.white],
//                     begin: Alignment.topCenter,
//                     end: Alignment.bottomCenter,
//                   ),
//                 ),
//                 child: Center(
//                   child: Image.asset(
//                     'assets/images/logo1.png',
//                     height: 120,
//                     fit: BoxFit.contain,
//                   ),
//                 ),
//               ),
//               // Quick Actions
//               Padding(
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
//                 child: Text(
//                   'Quick Actions',
//                   style: GoogleFonts.poppins(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                     color: orange,
//                   ),
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 12.0),
//                 child: Container(
//                   decoration: BoxDecoration(
//                     color: lightOrange,
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                   padding:
//                       const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
//                   child: Column(
//                     children: [
//                       _quickAction(
//                         context,
//                         icon: Icons.pets,
//                         label: 'Book Grooming',
//                         orange: orange,
//                         onTap: () {
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (context) => const GroomingAppointmentPage(),
//                             ),
//                           );
//                         },
//                       ),
//                       const SizedBox(height: 12),
//                       // _quickAction(
//                       //   context,
//                       //   icon: Icons.shopping_bag_outlined,
//                       //   label: 'Shop Products',
//                       //   orange: orange,
//                       //   onTap: () {
//                       //     Navigator.push(
//                       //       context,
//                       //       MaterialPageRoute(
//                       //         builder: (context) => const ShopPage(),
//                       //       ),
//                       //     );
//                       //   },
//                       // ),
//                       // const SizedBox(height: 12),
//                       _quickAction(
//                         context,
//                         icon: Icons.message_outlined,
//                         label: 'Message Groomer',
//                         orange: orange,
//                         onTap: () {
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (context) => const MessagesPage(),
//                             ),
//                           );
//                         },
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
              
//               // Upcoming Appointments
//               Padding(
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16),
//                 child: Text(
//                   'Upcoming Appointments',
//                   style: GoogleFonts.poppins(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                     color: orange,
//                   ),
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 12.0),
//                 child: Container(
//                   decoration: BoxDecoration(
//                     color: lightOrange,
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                   padding: const EdgeInsets.all(16),
//                   child: _isLoading
//                       ? const Center(
//                           child: CircularProgressIndicator(color: Color(0xFFF5A623)),
//                         )
//                       : _upcomingAppointments.isEmpty
//                           ? _buildNoAppointments(orange)
//                           : Column(
//                               children: [
//                                 ..._upcomingAppointments.take(_displayedAppointmentsCount).map((appointment) {
//                                   return _buildAppointmentCard(context, appointment, orange);
//                                 }).toList(),
//                                 // Load More/Less buttons
//                                 if (_upcomingAppointments.length > _appointmentsPerPage)
//                                   Padding(
//                                     padding: const EdgeInsets.only(top: 16),
//                                     child: Row(
//                                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                       children: [
//                                         // Load Less button (left side)
//                                         if (_displayedAppointmentsCount > _appointmentsPerPage)
//                                           TextButton(
//                                             onPressed: _collapseAppointments,
//                                             style: TextButton.styleFrom(
//                                               foregroundColor: orange,
//                                               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                                             ),
//                                             child: Row(
//                                               mainAxisSize: MainAxisSize.min,
//                                               children: [
//                                                 Text(
//                                                   'Show less',
//                                                   style: GoogleFonts.poppins(
//                                                     fontSize: 14,
//                                                     fontWeight: FontWeight.w500,
//                                                   ),
//                                                 ),
//                                                 const SizedBox(width: 4),
//                                                 Container(
//                                                   width: 20,
//                                                   height: 20,
//                                                   decoration: BoxDecoration(
//                                                     color: orange,
//                                                     shape: BoxShape.circle,
//                                                   ),
//                                                   child: const Icon(
//                                                     Icons.keyboard_arrow_up,
//                                                     color: Colors.white,
//                                                     size: 16,
//                                                   ),
//                                                 ),
//                                               ],
//                                             ),
//                                           ),
//                                         if (_displayedAppointmentsCount <= _appointmentsPerPage)
//                                           const Spacer(),
//                                         // Load More button (right side)
//                                         if (_displayedAppointmentsCount < _upcomingAppointments.length)
//                                           TextButton(
//                                             onPressed: _expandAppointments,
//                                             style: TextButton.styleFrom(
//                                               foregroundColor: orange,
//                                               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                                             ),
//                                             child: Row(
//                                               mainAxisSize: MainAxisSize.min,
//                                               children: [
//                                                 Text(
//                                                   'Show more',
//                                                   style: GoogleFonts.poppins(
//                                                     fontSize: 14,
//                                                     fontWeight: FontWeight.w500,
//                                                   ),
//                                                 ),
//                                                 const SizedBox(width: 4),
//                                                 Container(
//                                                   width: 20,
//                                                   height: 20,
//                                                   decoration: BoxDecoration(
//                                                     color: orange,
//                                                     shape: BoxShape.circle,
//                                                   ),
//                                                   child: const Icon(
//                                                     Icons.keyboard_arrow_down,
//                                                     color: Colors.white,
//                                                     size: 16,
//                                                   ),
//                                                 ),
//                                               ],
//                                             ),
//                                           ),
//                                       ],
//                                     ),
//                                   ),
//                                 // const SizedBox(height: 10),
//                                 SizedBox(
//                                   width: double.infinity,
//                                   child: ElevatedButton(
//                                     onPressed: () {
//                                       Navigator.push(
//                                         context,
//                                         MaterialPageRoute(
//                                           builder: (context) => const GroomingAppointmentPage(),
//                                         ),
//                                       );
//                                     },
//                                     style: ElevatedButton.styleFrom(
//                                       backgroundColor: orange,
//                                       padding: const EdgeInsets.symmetric(vertical: 14),
//                                       shape: RoundedRectangleBorder(
//                                         borderRadius: BorderRadius.circular(10),
//                                       ),
//                                       elevation: 1,
//                                     ),
//                                     child: Text('Book New Appointment',
//                                         style: GoogleFonts.poppins(
//                                           fontSize: 14,
//                                           color: Colors.white,
//                                           fontWeight: FontWeight.w600,
//                                         )),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                 ),
//               ),
//               const SizedBox(height: 24),

//               // Testimonials and Reviews Section
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
//                 child: Text(
//                   'Testimonials',
//                   style: GoogleFonts.poppins(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                     color: orange,
//                   ),
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 12.0),
//                 child: Container(
//                   decoration: BoxDecoration(
//                     color: lightOrange,
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                   padding: const EdgeInsets.all(16),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       _isLoadingReviews
//                           ? const Center(
//                               child: CircularProgressIndicator(color: Color(0xFFF5A623)),
//                             )
//                           : _reviews.isEmpty
//                               ? _buildNoReviews(orange)
//                               : SizedBox(
//                                   height: 140,
//                                   child: PageView.builder(
//                                     controller: _testimonialController,
//                                     itemCount: _reviews.length,
//                                     itemBuilder: (context, index) {
//                                       final review = _reviews[index];
//                                       // Handle both joined query result and fallback result
//                                       final fullName = review['users']?['full_name'] ?? 
//                                                      review['user_name'] ?? 
//                                                      'Anonymous';
                                      
//                                       // Format name to show first name and last name initial
//                                       final formattedName = _formatUserName(fullName);
//                                       final reviewText = review['review_text'] ?? '';
//                                       final rating = review['rating'] ?? 5;
                                      
//                                       return Padding(
//                                         padding: const EdgeInsets.symmetric(horizontal: 8),
//                                         child: _testimonialCardCarousel(
//                                           quote: reviewText.isNotEmpty ? reviewText : 'Great service!',
//                                           name: formattedName,
//                                           stars: rating,
//                                         ),
//                                       );
//                                     },
//                                   ),
//                                 ),
//                     ],
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 24),
//                             // Tips Section
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
//                 child: Text(
//                   'Grooming Tips & Care Reminders',
//                   style: GoogleFonts.poppins(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                     color: orange,
//                   ),
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 12.0),
//                 child: Container(
//                   decoration: BoxDecoration(
//                     color: lightOrange,
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                   padding: const EdgeInsets.all(16),
//                   child: Column(
//                     children: [
//                       _buildTipCard(
//                         icon: Icons.bathroom,
//                         title: 'Pre-Grooming Preparation',
//                         description: 'Brush your pet\'s coat before the appointment to remove tangles and make grooming easier.',
//                         color: orange,
//                       ),
//                       const SizedBox(height: 12),
//                       _buildTipCard(
//                         icon: Icons.health_and_safety,
//                         title: 'Health Check',
//                         description: 'Ensure your pet is up-to-date on vaccinations and inform us of any health concerns.',
//                         color: orange,
//                       ),
//                       const SizedBox(height: 12),
//                       _buildTipCard(
//                         icon: Icons.schedule,
//                         title: 'Arrival Time',
//                         description: 'Arrive 10-15 minutes early to allow your pet to settle in and get comfortable.',
//                         color: orange,
//                       ),
//                       const SizedBox(height: 12),
//                       _buildTipCard(
//                         icon: Icons.favorite,
//                         title: 'Post-Grooming Care',
//                         description: 'Keep your pet warm and dry after grooming, especially in cooler weather.',
//                         color: orange,
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 24),
//               // Follow Us on Facebook Section
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
//                 child: Text(
//                   'Follow Us on Facebook',
//                   style: GoogleFonts.poppins(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                     color: orange,
//                   ),
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 12.0),
//                 child: Container(
//                   decoration: BoxDecoration(
//                     color: lightOrange,
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                   padding: const EdgeInsets.all(16),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Row(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Expanded(
//                             child: Text(
//                               'Check out our latest posts and updates on Facebook!',
//                               style: GoogleFonts.poppins(
//                                 fontSize: 14,
//                                 color: Colors.black87,
//                                 fontWeight: FontWeight.w500,
//                               ),
//                             ),
//                           ),
//                           const SizedBox(width: 12),
//                           GestureDetector(
//                             onTap: () {
//                               launchUrl(Uri.parse('https://www.facebook.com/profile.php?id=100064116609541'));
//                             },
//                             child: Container(
//                               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                               decoration: BoxDecoration(
//                                 color: const Color(0xFF1877F3),
//                                 borderRadius: BorderRadius.circular(8),
//                               ),
//                               child: Row(
//                                 mainAxisSize: MainAxisSize.min,
//                                 children: [
//                                   const Icon(Icons.facebook, color: Colors.white, size: 24),
//                                   const SizedBox(width: 8),
//                                   Text(
//                                     'Follow',
//                                     style: GoogleFonts.poppins(
//                                       color: Colors.white,
//                                       fontWeight: FontWeight.bold,
//                                       fontSize: 14,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 20),
//                       Container(
//                         width: double.infinity,
//                         decoration: BoxDecoration(
//                           color: Colors.white,
//                           borderRadius: BorderRadius.circular(16),
//                           border: Border.all(color: Colors.black26, width: 2),
//                         ),
//                         child: ClipRRect(
//                           borderRadius: BorderRadius.circular(12),
//                           child: Image.asset(
//                             'assets/images/facebook.jpeg',
//                             width: double.infinity,
//                             height: 160,
//                             fit: BoxFit.cover,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 24),
//               // FAQs Section
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
//                 child: Text(
//                   'Frequently Asked Questions',
//                   style: GoogleFonts.poppins(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                     color: orange,
//                   ),
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 12.0),
//                 child: Container(
//                   decoration: BoxDecoration(
//                     color: lightOrange,
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                   padding: const EdgeInsets.all(16),
//                   child: Column(
//                     children: [
//                       ..._getDisplayedFAQs().map((faq) => Column(
//                         children: [
//                           _buildFAQItem(
//                             question: faq['question'] ?? '',
//                             answer: faq['answer'] ?? '',
//                           ),
//                           const SizedBox(height: 12),
//                         ],
//                       )).toList(),
//                       // Load More/Less buttons
//                       if (_allFAQs.length > _faqsPerPage)
//                         Padding(
//                           padding: const EdgeInsets.only(top: 16),
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               // Load Less button (left side)
//                               if (_displayedFAQsCount > _faqsPerPage)
//                                 TextButton(
//                                   onPressed: _collapseFAQs,
//                                   style: TextButton.styleFrom(
//                                     foregroundColor: Colors.black87,
//                                     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                                   ),
//                                   child: Row(
//                                     mainAxisSize: MainAxisSize.min,
//                                     children: [
//                                       Text(
//                                         'Show less',
//                                         style: GoogleFonts.poppins(
//                                           fontSize: 14,
//                                           fontWeight: FontWeight.w500,
//                                         ),
//                                       ),
//                                       const SizedBox(width: 4),
//                                       Container(
//                                         width: 20,
//                                         height: 20,
//                                         decoration: const BoxDecoration(
//                                           color: Colors.black87,
//                                           shape: BoxShape.circle,
//                                         ),
//                                         child: const Icon(
//                                           Icons.keyboard_arrow_up,
//                                           color: Colors.white,
//                                           size: 16,
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               if (_displayedFAQsCount <= _faqsPerPage)
//                                 const Spacer(),
//                               // Load More button (right side)
//                               if (_displayedFAQsCount < _allFAQs.length)
//                                 TextButton(
//                                   onPressed: _expandFAQs,
//                                   style: TextButton.styleFrom(
//                                     foregroundColor: Colors.black87,
//                                     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                                   ),
//                                   child: Row(
//                                     mainAxisSize: MainAxisSize.min,
//                                     children: [
//                                       Text(
//                                         'Show more',
//                                         style: GoogleFonts.poppins(
//                                           fontSize: 14,
//                                           fontWeight: FontWeight.w500,
//                                         ),
//                                       ),
//                                       const SizedBox(width: 4),
//                                       Container(
//                                         width: 20,
//                                         height: 20,
//                                         decoration: const BoxDecoration(
//                                           color: Colors.black87,
//                                           shape: BoxShape.circle,
//                                         ),
//                                         child: const Icon(
//                                           Icons.keyboard_arrow_down,
//                                           color: Colors.white,
//                                           size: 16,
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                             ],
//                           ),
//                         ),
//                     ],
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 24),
//               // Footer Section
//               Container(
//                 width: double.infinity,
//                 padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24),
//                 decoration: const BoxDecoration(
//                   gradient: LinearGradient(
//                     colors: [Color(0xFFFFF6E7), Colors.white],
//                     begin: Alignment.topCenter,
//                     end: Alignment.bottomCenter,
//                   ),
//                 ),
//                 child: Column(
//                   children: [
//                     // Terms and Privacy Policy Links
//                     Center(
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           GestureDetector(
//                             onTap: () => _showTermsAndConditionsDialog(context),
//                             child: Text(
//                               'Terms and Conditions',
//                               style: GoogleFonts.poppins(
//                                 fontSize: 13,
//                                 color: orange,
//                                 fontWeight: FontWeight.w500,
//                               ),
//                             ),
//                           ),
//                           Text(
//                             '  |  ',
//                             style: GoogleFonts.poppins(
//                               fontSize: 13,
//                               color: Colors.black45,
//                               fontWeight: FontWeight.w400,
//                             ),
//                           ),
//                           GestureDetector(
//                             onTap: () => _showPrivacyPolicyDialog(context),
//                             child: Text(
//                               'Privacy Policy',
//                               style: GoogleFonts.poppins(
//                                 fontSize: 13,
//                                 color: orange,
//                                 fontWeight: FontWeight.w500,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     const SizedBox(height: 16),
//                     Center(
//                       child: Text(
//                         '© 2025 ImPawsible',
//                         style: GoogleFonts.poppins(
//                           fontSize: 13,
//                           color: Colors.black45,
//                           fontWeight: FontWeight.w400,
//                         ),
//                         textAlign: TextAlign.center,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//       bottomNavigationBar: _bottomNavBar(orange),
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

//   Widget _buildNoAppointments(Color orange) {
//     return Column(
//       children: [
//         Icon(
//           Icons.calendar_today_outlined,
//           size: 48,
//           color: orange.withOpacity(0.5),
//         ),
//         const SizedBox(height: 12),
//         Text(
//           'No upcoming appointments',
//           style: GoogleFonts.poppins(
//             fontSize: 16,
//             color: Colors.black54,
//             fontWeight: FontWeight.w500,
//           ),
//         ),
//         const SizedBox(height: 8),
//         Text(
//           'All pending appointments have been processed',
//           style: GoogleFonts.poppins(
//             fontSize: 14,
//             color: Colors.black45,
//           ),
//         ),
//         const SizedBox(height: 16),
//         SizedBox(
//           width: double.infinity,
//           child: ElevatedButton(
//             onPressed: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => const GroomingAppointmentPage(),
//                 ),
//               );
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: orange,
//               padding: const EdgeInsets.symmetric(vertical: 14),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               elevation: 1,
//             ),
//             child: Text('Book New Appointment',
//                 style: GoogleFonts.poppins(
//                   fontSize: 16,
//                   color: Colors.white,
//                   fontWeight: FontWeight.w600,
//                 )),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildNoReviews(Color orange) {
//     return Column(
//       children: [
//         Icon(
//           Icons.star_outline,
//           size: 48,
//           color: orange.withOpacity(0.5),
//         ),
//         const SizedBox(height: 12),
//         Text(
//           'No reviews yet',
//           style: GoogleFonts.poppins(
//             fontSize: 16,
//             color: Colors.black54,
//             fontWeight: FontWeight.w500,
//           ),
//         ),
//         const SizedBox(height: 8),
//         Text(
//           'Be the first to share your experience!',
//           style: GoogleFonts.poppins(
//             fontSize: 14,
//             color: Colors.black45,
//           ),
//         ),
//         const SizedBox(height: 16),
//         SizedBox(
//           width: double.infinity,
//           child: ElevatedButton(
//             onPressed: () {
//               // Navigate to profile page to rate and review
//               Navigator.pushReplacement(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => const ProfilePage(),
//                 ),
//               );
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: orange,
//               padding: const EdgeInsets.symmetric(vertical: 14),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               elevation: 1,
//             ),
//             child: Text('Rate and Review',
//                 style: GoogleFonts.poppins(
//                   fontSize: 16,
//                   color: Colors.white,
//                   fontWeight: FontWeight.w600,
//                 )),
//           ),
//         ),
//       ],
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
    
//     // Return first name + last name initial
//     final firstName = nameParts[0];
//     final lastNameInitial = nameParts[nameParts.length - 1][0].toUpperCase();
//     return '$firstName $lastNameInitial.';
//   }

//   Widget _buildTipCard({
//     required IconData icon,
//     required String title,
//     required String description,
//     required Color color,
//   }) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: color.withOpacity(0.2)),
//       ),
//       child: Row(
//         children: [
//           Container(
//             padding: const EdgeInsets.all(8),
//             decoration: BoxDecoration(
//               color: color.withOpacity(0.1),
//               borderRadius: BorderRadius.circular(8),
//             ),
//             child: Icon(icon, color: color, size: 24),
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   title,
//                   style: GoogleFonts.poppins(
//                     fontSize: 14,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.black87,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   description,
//                   style: GoogleFonts.poppins(
//                     fontSize: 12,
//                     color: Colors.black54,
//                     height: 1.3,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildFAQItem({
//     required String question,
//     required String answer,
//   }) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: Colors.grey.shade200),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             question,
//             style: GoogleFonts.poppins(
//               fontSize: 14,
//               fontWeight: FontWeight.bold,
//               color: Colors.black87,
//             ),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             answer,
//             style: GoogleFonts.poppins(
//               fontSize: 12,
//               color: Colors.black54,
//               height: 1.4,
//             ),
//           ),
//         ],
//       ),
//     );
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

//   Widget _quickAction(BuildContext context,
//       {required IconData icon,
//       required String label,
//       required Color orange,
//       required VoidCallback onTap}) {
//     return InkWell(
//       onTap: onTap,
//       borderRadius: BorderRadius.circular(14),
//       child: Container(
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(14),
//         ),
//         padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
//         child: Row(
//           children: [
//             Container(
//               decoration: BoxDecoration(
//                 color: orange.withOpacity(0.12),
//                 shape: BoxShape.circle,
//               ),
//               padding: const EdgeInsets.all(8),
//               child: Icon(icon, color: orange, size: 28),
//             ),
//             const SizedBox(width: 16),
//             Expanded(
//               child: Text(
//                 label,
//                 style: GoogleFonts.poppins(
//                   fontSize: 16,
//                   fontWeight: FontWeight.w500,
//                   color: Colors.black87,
//                 ),
//               ),
//             ),
//             Icon(Icons.chevron_right, color: orange, size: 28),
//           ],
//         ),
//       ),
//     );
//   }



//   Widget _bottomNavBar(Color orange) {
//     return BottomNavigationBar(
//       type: BottomNavigationBarType.fixed,
//       backgroundColor: Colors.white,
//       selectedItemColor: orange,
//       unselectedItemColor: Colors.grey[400],
//       showSelectedLabels: true,
//       showUnselectedLabels: true,
//       currentIndex: _selectedIndex,
//       onTap: _onItemTapped,
//       items: const [
//         BottomNavigationBarItem(
//           icon: Icon(Icons.home),
//           label: 'Home',
//         ),
//         BottomNavigationBarItem(
//           icon: Icon(Icons.pets),
//           label: 'Grooming',
//         ),
//         // BottomNavigationBarItem(
//         //   icon: Icon(Icons.shopping_bag_outlined),
//         //   label: 'Shop',
//         // ),
//         BottomNavigationBarItem(
//           icon: Icon(Icons.message_outlined),
//           label: 'Messages',
//         ),
//         BottomNavigationBarItem(
//           icon: Icon(Icons.person_outline),
//           label: 'Profile',
//         ),
//       ],
//     );
//   }

//   void _showTermsAndConditionsDialog(BuildContext context) {
//     final orange = const Color(0xFFF5A623);
//     final lightOrange = const Color(0xFFFFF6E7);
    
//     showDialog(
//       context: context,
//       builder: (context) => Dialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//         child: Container(
//           constraints: const BoxConstraints(maxHeight: 600),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(20),
//           ),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               // Header
//               Container(
//                 width: double.infinity,
//                 padding: const EdgeInsets.all(20),
//                 decoration: BoxDecoration(
//                   color: lightOrange,
//                   borderRadius: const BorderRadius.only(
//                     topLeft: Radius.circular(20),
//                     topRight: Radius.circular(20),
//                   ),
//                 ),
//                 child: Column(
//                   children: [
//                     Icon(Icons.description, size: 48, color: orange),
//                     const SizedBox(height: 12),
//                     Text(
//                       'Terms and Conditions',
//                       style: GoogleFonts.poppins(
//                         fontSize: 20,
//                         fontWeight: FontWeight.bold,
//                         color: orange,
//                       ),
//                       textAlign: TextAlign.center,
//                     ),
//                   ],
//                 ),
//               ),
//               // Content
//               Expanded(
//                 child: SingleChildScrollView(
//                   padding: const EdgeInsets.all(20),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'Welcome to Impawsible, your go-to mobile app for booking pet grooming appointments with ease! By using our app, you agree to the following terms:',
//                         style: GoogleFonts.poppins(
//                           fontSize: 14,
//                           color: Colors.black87,
//                           height: 1.4,
//                         ),
//                       ),
//                       const SizedBox(height: 16),
//                       _buildTermsSection(
//                         '1. Use of the App',
//                         'You agree to use Impawsible only for lawful purposes and to make genuine grooming appointments for your pet. You must not use the app to cause harm, distribute spam, or attempt to access other users\' data.',
//                       ),
//                       _buildTermsSection(
//                         '2. User Accounts',
//                         'To book appointments, you need to create an account. You are responsible for keeping your login information safe. Please keep your account info updated.',
//                       ),
//                       _buildTermsSection(
//                         '3. Appointments',
//                         'You can schedule or cancel appointments using the app. Make sure to follow our cancellation policy and respect time slots for better service experience.',
//                       ),
//                       // _buildTermsSection(
//                       //   '4. Service Availability',
//                       //   'We aim to provide a reliable scheduling experience. However, service availability depends on the groomer\'s schedule and may vary.',
//                       // ),
//                       _buildTermsSection(
//                         '4. Prohibited Behavior',
//                         'You agree not to:\n• Misuse the app\n• Post inappropriate content\n• Try to harm or hack the system',
//                       ),
//                       // _buildTermsSection(
//                       //   '6. Termination',
//                       //   'We may suspend or delete your account if you break the rules or misuse the app.',
//                       // ),
//                       _buildTermsSection(
//                         '5. Updates',
//                         'We may update these terms from time to time. Continued use of the app means you accept any changes.',
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//               // Close Button
//               Container(
//                 width: double.infinity,
//                 padding: const EdgeInsets.all(20),
//                 child: Center(
//                   child: GestureDetector(
//                     onTap: () => Navigator.pop(context),
//                     child: Text(
//                       'Close',
//                       style: GoogleFonts.poppins(
//                         fontSize: 14,
//                         fontWeight: FontWeight.w500,
//                         color: Colors.black,
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   void _showPrivacyPolicyDialog(BuildContext context) {
//     final orange = const Color(0xFFF5A623);
//     final lightOrange = const Color(0xFFFFF6E7);
    
//     showDialog(
//       context: context,
//       builder: (context) => Dialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//         child: Container(
//           constraints: const BoxConstraints(maxHeight: 600),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(20),
//           ),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               // Header
//               Container(
//                 width: double.infinity,
//                 padding: const EdgeInsets.all(20),
//                 decoration: BoxDecoration(
//                   color: lightOrange,
//                   borderRadius: const BorderRadius.only(
//                     topLeft: Radius.circular(20),
//                     topRight: Radius.circular(20),
//                   ),
//                 ),
//                 child: Column(
//                   children: [
//                     Icon(Icons.privacy_tip, size: 48, color: orange),
//                     const SizedBox(height: 12),
//                     Text(
//                       'Privacy Policy',
//                       style: GoogleFonts.poppins(
//                         fontSize: 20,
//                         fontWeight: FontWeight.bold,
//                         color: orange,
//                       ),
//                       textAlign: TextAlign.center,
//                     ),
//                   ],
//                 ),
//               ),
//               // Content
//               Expanded(
//                 child: SingleChildScrollView(
//                   padding: const EdgeInsets.all(20),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'Your privacy matters to us! Here\'s how we collect, use, and protect your information when using the Impawsible app.',
//                         style: GoogleFonts.poppins(
//                           fontSize: 14,
//                           color: Colors.black87,
//                           height: 1.4,
//                         ),
//                       ),
//                       const SizedBox(height: 16),
//                       _buildPrivacySection(
//                         '1. Information We Collect',
//                         '• Personal Info: Full name, email, phone number, etc.\n• Pet Info: Pet name, breed, age, services booked, etc.',
//                       ),
//                       _buildPrivacySection(
//                         '2. How We Use Your Info',
//                         '• To manage appointments\n• To send confirmations, reminders, or updates\n• To improve the app experience\n• For customer support',
//                       ),
//                       _buildPrivacySection(
//                         '3. Data Sharing',
//                         'We do not sell or share your data with third parties except:\n• Service providers directly involved in your appointment\n• When required by law',
//                       ),
//                       _buildPrivacySection(
//                         '4. Security',
//                         'Your data is stored securely in our system. We use safety measures to protect your information.',
//                       ),
//                       _buildPrivacySection(
//                         '5. User Control',
//                         'You can view and update your information anytime through your profile. If you want to delete your account, just let us know.',
//                       ),
//                       _buildPrivacySection(
//                         '6. Children\'s Privacy',
//                         'This app is not intended for users under the age of 16. We do not knowingly collect data from children.',
//                       ),
//                       const SizedBox(height: 16),
//                       Text(
//                         'If you have any questions about these policies, feel free to contact us at impawsiblepetshop@email.com.',
//                         style: GoogleFonts.poppins(
//                           fontSize: 13,
//                           color: Colors.black87,
//                           height: 1.4,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//               // Close Button
//               Container(
//                 width: double.infinity,
//                 padding: const EdgeInsets.all(20),
//                 child: Center(
//                   child: GestureDetector(
//                     onTap: () => Navigator.pop(context),
//                     child: Text(
//                       'Close',
//                       style: GoogleFonts.poppins(
//                         fontSize: 14,
//                         fontWeight: FontWeight.w500,
//                         color: Colors.black,
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildTermsSection(String title, String content) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             title,
//             style: GoogleFonts.poppins(
//               fontSize: 14,
//               fontWeight: FontWeight.bold,
//               color: Colors.black87,
//             ),
//           ),
//           const SizedBox(height: 6),
//           Text(
//             content,
//             style: GoogleFonts.poppins(
//               fontSize: 13,
//               color: Colors.black87,
//               height: 1.4,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildPrivacySection(String title, String content) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             title,
//             style: GoogleFonts.poppins(
//               fontSize: 14,
//               fontWeight: FontWeight.bold,
//               color: Colors.black87,
//             ),
//           ),
//           const SizedBox(height: 6),
//           Text(
//             content,
//             style: GoogleFonts.poppins(
//               fontSize: 13,
//               color: Colors.black87,
//               height: 1.4,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }



// final List<Map<String, String>> _allFAQs = [
//   {
//     'question': 'How long does grooming take?',
//     'answer': 'Grooming sessions typically take 1-2 hours depending on your pet\'s size, coat condition, and services chosen.',
//   },
//   {
//     'question': 'What should I bring to the appointment?',
//     'answer': 'Just bring your pet! We provide all necessary supplies. However, if your pet has specific dietary needs, please bring their food.',
//   },
//   {
//     'question': 'Can I stay with my pet during grooming?',
//     'answer': 'For safety reasons, we ask that you drop off your pet and return at the scheduled pickup time.',
//   },
//   {
//     'question': 'What if my pet has anxiety or special needs?',
//     'answer': 'Please inform us in advance. Our groomers are trained to handle pets with anxiety and special requirements.',
//   },
//   {
//     'question': 'How often should I groom my pet?',
//     'answer': 'Most pets benefit from grooming every 4-8 weeks, depending on their breed and coat type.',
//   },
//   {
//     'question': 'What if I need to cancel my appointment?',
//     'answer': 'You can cancel up to 24 hours before your appointment through the app or by contacting us directly.',
//   },
// ];

// --

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '/profile/profile_page.dart';
import 'grooming/grooming_appointment.dart';
import 'messages/messages_page.dart';
import 'dart:async';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Constants
  static const Color _orange = Color(0xFFF5A623);
  static const Color _lightOrange = Color(0xFFFFF6E7);
  static const int _appointmentsPerPage = 3;
  static const int _faqsPerPage = 3;
  static const int _testimonialAutoScrollInterval = 3;

  // State variables
  int _selectedIndex = 0;
  List<Map<String, dynamic>> _upcomingAppointments = [];
  List<Map<String, dynamic>> _reviews = [];
  bool _isLoading = true;
  bool _isLoadingReviews = true;
  int _displayedAppointmentsCount = _appointmentsPerPage;
  int _displayedFAQsCount = _faqsPerPage;
  final ScrollController _scrollController = ScrollController();
  bool _showScrollToTop = false;
  late PageController _testimonialController;
  Timer? _countdownTimer;
  Timer? _autoScrollTimer;

  @override
  void initState() {
    super.initState();
    _initializePage();
  }

  @override
  void dispose() {
    _disposeResources();
    super.dispose();
  }

  // ========== Initialization ==========
  void _initializePage() {
    _testimonialController = PageController(viewportFraction: 0.85);
    _loadData();
    _setupTimers();
    _scrollController.addListener(_handleScroll);
  }

  void _disposeResources() {
    _countdownTimer?.cancel();
    _autoScrollTimer?.cancel();
    _testimonialController.dispose();
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
  }

  void _setupTimers() {
    _countdownTimer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) => mounted ? setState(() {}) : null,
    );

    _autoScrollTimer = Timer.periodic(
      const Duration(seconds: _testimonialAutoScrollInterval),
      (timer) => _autoScrollTestimonials(),
    );
  }

  // ========== Data Loading ==========
  Future<void> _loadData() async {
    await Future.wait([
      _loadUpcomingAppointments(),
      _loadReviews(),
    ]);
  }

  Future<void> _refreshData() async {
    await Future.wait([
      _loadUpcomingAppointments(),
      _loadReviews(),
    ]);
  }

  Future<void> _loadUpcomingAppointments() async {
    setState(() => _isLoading = true);
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        final now = DateTime.now();
        final response = await Supabase.instance.client
            .from('grooming_appointments')
            .select('''
              id, pet_name, pet_type, breed, preferred_date, preferred_time,
              estimated_duration, service_bath, service_haircut,
              service_nail_trim, service_ear_cleaning, status, user_id
            ''')
            .eq('user_id', user.id)
            .eq('status', 'Pending')
            .gte('preferred_date', DateFormat('yyyy-MM-dd').format(now))
            .order('preferred_date', ascending: true)
            .order('preferred_time', ascending: true)
            .limit(5);

        if (mounted) {
          setState(() {
            _upcomingAppointments = List<Map<String, dynamic>>.from(response);
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
      print('Error loading appointments: $e');
    }
  }

  Future<void> _loadReviews() async {
    setState(() => _isLoadingReviews = true);
    try {
      // Try joined query first
      try {
        final response = await Supabase.instance.client
            .from('rate_review')
            .select('''
              id, rating, review_text, created_at, user_id,
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
        // Fallback to separate queries
        print('Joined query failed: $e');
        final reviewsResponse = await Supabase.instance.client
            .from('rate_review')
            .select('id, rating, review_text, created_at, user_id')
            .order('created_at', ascending: false)
            .limit(10);

        final reviewsWithUsers = await Future.wait(
          reviewsResponse.map((review) async {
            try {
              final userResponse = await Supabase.instance.client
                  .from('users')
                  .select('full_name')
                  .eq('id', review['user_id'])
                  .maybeSingle();

              return {
                ...review,
                'user_name': userResponse?['full_name'] ?? 'Anonymous'
              };
            } catch (e) {
              return {...review, 'user_name': 'Anonymous'};
            }
          })
        );

        if (mounted) {
          setState(() {
            _reviews = reviewsWithUsers;
            _isLoadingReviews = false;
          });
        }
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingReviews = false);
      print('Error loading reviews: $e');
    }
  }

  // ========== UI Interaction ==========
  void _handleScroll() {
    setState(() {
      _showScrollToTop = _scrollController.position.pixels > 200;
    });
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  void _autoScrollTestimonials() {
    if (_testimonialController.hasClients && _reviews.isNotEmpty) {
      final currentPage = _testimonialController.page?.round() ?? 0;
      final nextPage = (currentPage + 1) % _reviews.length;
      _testimonialController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOut,
      );
    }
  }

  void _onItemTapped(int index) {
    switch (index) {
      case 0: break;
      case 1:
        Navigator.pushReplacementNamed(context, '/grooming');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/messages');
        break;
      case 3:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ProfilePage())
        );
        break;
    }
    setState(() => _selectedIndex = index);
  }

  // ========== UI Builders ==========
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshData,
          color: Colors.orange,
          child: SingleChildScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                _buildQuickActions(),
                _buildUpcomingAppointments(),
                _buildTestimonials(),
                _buildTipsSection(),
                _buildFacebookSection(),
                _buildFAQsSection(),
                _buildFooter(),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
      floatingActionButton: _showScrollToTop
          ? FloatingActionButton(
              onPressed: _scrollToTop,
              backgroundColor: _orange,
              child: const Icon(Icons.arrow_upward, color: Colors.white),
            )
          : null,
    );
  }

  // ========== Section Builders ==========
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 24, bottom: 12),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [_lightOrange, Colors.white],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Center(
        child: Image.asset(
          'assets/images/logo1.png',
          height: 120,
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: _orange,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: _lightOrange,
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            child: Column(
              children: [
                _buildQuickAction(
                  icon: Icons.pets,
                  label: 'Book Grooming',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const GroomingAppointmentPage())
                  ),
                ),
                const SizedBox(height: 12),
                _buildQuickAction(
                  icon: Icons.message_outlined,
                  label: 'Message Groomer',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const MessagesPage())
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingAppointments() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Upcoming Appointments',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: _orange,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: _lightOrange,
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.all(16),
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: _orange))
                : _upcomingAppointments.isEmpty
                    ? _buildNoAppointments()
                    : Column(
                        children: [
                          ..._upcomingAppointments.take(_displayedAppointmentsCount)
                              .map((appointment) => _buildAppointmentCard(appointment))
                              .toList(),
                          _buildAppointmentControls(),
                          _buildBookAppointmentButton(),
                        ],
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildTestimonials() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Testimonials',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: _orange,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: _lightOrange,
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.all(16),
            child: _isLoadingReviews
                ? const Center(child: CircularProgressIndicator(color: _orange))
                : _reviews.isEmpty
                    ? _buildNoReviews()
                    : SizedBox(
                        height: 140,
                        child: PageView.builder(
                          controller: _testimonialController,
                          itemCount: _reviews.length,
                          itemBuilder: (context, index) {
                            final review = _reviews[index];
                            final fullName = review['users']?['full_name'] ??
                                           review['user_name'] ??
                                           'Anonymous';
                            final formattedName = _formatUserName(fullName);
                            final reviewText = review['review_text'] ?? '';
                            final rating = review['rating'] ?? 5;

                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              child: _buildTestimonialCard(
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
    );
  }

  // ========== Helper Widgets ==========
  Widget _buildQuickAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: _orange.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(8),
              child: Icon(icon, color: _orange, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ),
            const Icon(Icons.chevron_right, color: _orange, size: 28),
          ],
        ),
      ),
    );
  }

  Widget _buildAppointmentCard(Map<String, dynamic> appointment) {
    final date = DateTime.parse(appointment['preferred_date']);
    final time = appointment['preferred_time'];
    final petName = appointment['pet_name'];
    final petType = appointment['pet_type'];
    final breed = appointment['breed'];
    final services = _getSelectedServices(appointment);
    final duration = appointment['estimated_duration'] ?? 60;

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
                  color: _orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.pets, color: _orange, size: 20),
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
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _getCountdownText(appointment),
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: _orange,
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
              _buildInfoRow(Icons.calendar_today, DateFormat('MMM dd, yyyy').format(date)),
              _buildInfoRow(Icons.access_time, _formatTime(time)),
              _buildInfoRow(Icons.timer, _formatDuration(duration)),
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
                    services,
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

  // ========== Helper Methods ==========
  String _getCountdownText(Map<String, dynamic> appointment) {
    try {
      final date = DateTime.parse(appointment['preferred_date']);
      final timeParts = appointment['preferred_time'].split(':');
      final appointmentTime = DateTime(
        date.year, date.month, date.day,
        int.parse(timeParts[0]), int.parse(timeParts[1])
      );

      final difference = appointmentTime.difference(DateTime.now());
      if (difference.isNegative) return 'Passed';

      final days = difference.inDays;
      final hours = difference.inHours % 24;
      final minutes = difference.inMinutes % 60;

      if (days > 0) return '$days day${days == 1 ? '' : 's'} $hours hr';
      if (hours > 0) return '$hours hr $minutes min';
      return '$minutes min';
    } catch (e) {
      return 'Time unavailable';
    }
  }

  String _formatUserName(String fullName) {
    if (fullName == 'Anonymous' || fullName.isEmpty) return 'Anonymous';

    final nameParts = fullName.trim().split(' ');
    if (nameParts.length == 1) return nameParts[0];

    final firstName = nameParts[0];
    final lastNameInitial = nameParts.last[0].toUpperCase();
    return '$firstName $lastNameInitial.';
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

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.grey[600], size: 16),
        const SizedBox(width: 6),
        Text(
          text,
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }

  Widget _buildNoAppointments() {
    return Column(
      children: [
        Icon(
          Icons.calendar_today_outlined,
          size: 48,
          color: _orange.withOpacity(0.5),
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
        ),
        const SizedBox(height: 16),
        _buildBookAppointmentButton(),
      ],
    );
  }

  Widget _buildNoReviews() {
    return Column(
      children: [
        Icon(
          Icons.star_outline,
          size: 48,
          color: _orange.withOpacity(0.5),
        ),
        const SizedBox(height: 12),
        Text(
          'No reviews yet',
          style: GoogleFonts.poppins(
            fontSize: 16,
            color: Colors.black54,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Be the first to share your experience!',
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.black45,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const ProfilePage()),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: _orange,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              'Rate and Review',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAppointmentControls() {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (_displayedAppointmentsCount > _appointmentsPerPage)
            TextButton(
              onPressed: () => setState(() => _displayedAppointmentsCount = _appointmentsPerPage),
              style: TextButton.styleFrom(
                foregroundColor: _orange,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Show less',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 4),
                  _buildActionIcon(Icons.keyboard_arrow_up),
                ],
              ),
            ),
          if (_displayedAppointmentsCount <= _appointmentsPerPage)
            const Spacer(),
          if (_displayedAppointmentsCount < _upcomingAppointments.length)
            TextButton(
              onPressed: () => setState(() {
                _displayedAppointmentsCount = (_displayedAppointmentsCount + _appointmentsPerPage)
                    .clamp(_appointmentsPerPage, _upcomingAppointments.length);
              }),
              style: TextButton.styleFrom(
                foregroundColor: _orange,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Show more',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 4),
                  _buildActionIcon(Icons.keyboard_arrow_down),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBookAppointmentButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const GroomingAppointmentPage()),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: _orange,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(
          'Book New Appointment',
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildTestimonialCard({
    required String quote,
    required String name,
    required int stars,
  }) {
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
                children: List.generate(
                  stars,
                  (index) => const Icon(
                    Icons.star,
                    color: _orange,
                    size: 16,
                  ),
                ),
              ),
              Text(
                '- $name',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: _orange,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionIcon(IconData icon) {
    return Container(
      width: 20,
      height: 20,
      decoration: const BoxDecoration(
        color: _orange,
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        color: Colors.white,
        size: 16,
      ),
    );
  }

  Widget _buildTipsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Grooming Tips & Care Reminders',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: _orange,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: _lightOrange,
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildTipCard(
                  icon: Icons.bathroom,
                  title: 'Pre-Grooming Preparation',
                  description: 'Brush your pet\'s coat before the appointment to remove tangles and make grooming easier.',
                ),
                const SizedBox(height: 12),
                _buildTipCard(
                  icon: Icons.health_and_safety,
                  title: 'Health Check',
                  description: 'Ensure your pet is up-to-date on vaccinations and inform us of any health concerns.',
                ),
                const SizedBox(height: 12),
                _buildTipCard(
                  icon: Icons.schedule,
                  title: 'Arrival Time',
                  description: 'Arrive 10-15 minutes early to allow your pet to settle in and get comfortable.',
                ),
                const SizedBox(height: 12),
                _buildTipCard(
                  icon: Icons.favorite,
                  title: 'Post-Grooming Care',
                  description: 'Keep your pet warm and dry after grooming, especially in cooler weather.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _orange.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: _orange, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.black54,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFacebookSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Follow Us on Facebook',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: _orange,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: _lightOrange,
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        'Check out our latest posts and updates on Facebook!',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.black87,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () => launchUrl(
                        Uri.parse('https://www.facebook.com/profile.php?id=100064116609541')
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1877F3),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.facebook, color: Colors.white, size: 24),
                            const SizedBox(width: 8),
                            Text(
                              'Follow',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.black26, width: 2),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      'assets/images/facebook.jpeg',
                      width: double.infinity,
                      height: 160,
                      fit: BoxFit.cover,
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

  Widget _buildFAQsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Frequently Asked Questions',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: _orange,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: _lightOrange,
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                ..._getDisplayedFAQs().map((faq) => Column(
                  children: [
                    _buildFAQItem(
                      question: faq['question'] ?? '',
                      answer: faq['answer'] ?? '',
                    ),
                    const SizedBox(height: 12),
                  ],
                )).toList(),
                _buildFAQControls(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAQItem({required String question, required String answer}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            answer,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.black54,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAQControls() {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (_displayedFAQsCount > _faqsPerPage)
            TextButton(
              onPressed: () => setState(() => _displayedFAQsCount = _faqsPerPage),
              style: TextButton.styleFrom(
                foregroundColor: Colors.black87,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Show less',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 4),
                  _buildActionIcon(Icons.keyboard_arrow_up),
                ],
              ),
            ),
          if (_displayedFAQsCount <= _faqsPerPage)
            const Spacer(),
          if (_displayedFAQsCount < _allFAQs.length)
            TextButton(
              onPressed: () => setState(() {
                _displayedFAQsCount = (_displayedFAQsCount + _faqsPerPage)
                    .clamp(_faqsPerPage, _allFAQs.length);
              }),
              style: TextButton.styleFrom(
                foregroundColor: Colors.black87,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Show more',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 4),
                  _buildActionIcon(Icons.keyboard_arrow_down),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [_lightOrange, Colors.white],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        children: [
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () => _showTermsDialog(context),
                  child: Text(
                    'Terms and Conditions',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: _orange,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Text(
                  '  |  ',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.black45,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                GestureDetector(
                  onTap: () => _showPrivacyDialog(context),
                  child: Text(
                    'Privacy Policy',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: _orange,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              '© 2025 ImPawsible',
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.black45,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      selectedItemColor: _orange,
      unselectedItemColor: Colors.grey[400],
      showSelectedLabels: true,
      showUnselectedLabels: true,
      currentIndex: _selectedIndex,
      onTap: _onItemTapped,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.pets),
          label: 'Grooming',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.message_outlined),
          label: 'Messages',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          label: 'Profile',
        ),
      ],
    );
  }

  // ========== Dialog Methods ==========
  void _showTermsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _buildPolicyDialog(
        title: 'Terms and Conditions',
        icon: Icons.description,
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome to Impawsible, your go-to mobile app for booking pet grooming appointments with ease! By using our app, you agree to the following terms:',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.black87,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            _buildPolicySection(
              '1. Use of the App',
              'You agree to use Impawsible only for lawful purposes and to make genuine grooming appointments for your pet. You must not use the app to cause harm, distribute spam, or attempt to access other users\' data.',
            ),
            _buildPolicySection(
              '2. User Accounts',
              'To book appointments, you need to create an account. You are responsible for keeping your login information safe. Please keep your account info updated.',
            ),
            _buildPolicySection(
              '3. Appointments',
              'You can schedule or cancel appointments using the app. Make sure to follow our cancellation policy and respect time slots for better service experience.',
            ),
            _buildPolicySection(
              '4. Prohibited Behavior',
              'You agree not to:\n• Misuse the app\n• Post inappropriate content\n• Try to harm or hack the system',
            ),
            _buildPolicySection(
              '5. Updates',
              'We may update these terms from time to time. Continued use of the app means you accept any changes.',
            ),
          ],
        ),
      ),
    );
  }

  void _showPrivacyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _buildPolicyDialog(
        title: 'Privacy Policy',
        icon: Icons.privacy_tip,
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your privacy matters to us! Here\'s how we collect, use, and protect your information when using the Impawsible app.',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.black87,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            _buildPolicySection(
              '1. Information We Collect',
              '• Personal Info: Full name, email, phone number, etc.\n• Pet Info: Pet name, breed, age, services booked, etc.',
            ),
            _buildPolicySection(
              '2. How We Use Your Info',
              '• To manage appointments\n• To send confirmations, reminders, or updates\n• To improve the app experience\n• For customer support',
            ),
            _buildPolicySection(
              '3. Data Sharing',
              'We do not sell or share your data with third parties except:\n• Service providers directly involved in your appointment\n• When required by law',
            ),
            _buildPolicySection(
              '4. Security',
              'Your data is stored securely in our system. We use safety measures to protect your information.',
            ),
            _buildPolicySection(
              '5. User Control',
              'You can view and update your information anytime through your profile. If you want to delete your account, just let us know.',
            ),
            _buildPolicySection(
              '6. Children\'s Privacy',
              'This app is not intended for users under the age of 16. We do not knowingly collect data from children.',
            ),
            const SizedBox(height: 16),
            Text(
              'If you have any questions about these policies, feel free to contact us at impawsiblepetshop@email.com.',
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.black87,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPolicyDialog({
    required String title,
    required IconData icon,
    required Widget content,
  }) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 600),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _lightOrange,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  Icon(icon, size: 48, color: _orange),
                  const SizedBox(height: 12),
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: _orange,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: content,
              ),
            ),
            // Close Button
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              child: Center(
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Text(
                    'Close',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPolicySection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            content,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: Colors.black87,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, String>> _getDisplayedFAQs() {
    return _allFAQs.take(_displayedFAQsCount).toList();
  }
}

// FAQ Data
final List<Map<String, String>> _allFAQs = [
  {
    'question': 'How long does grooming take?',
    'answer': 'Grooming sessions typically take 1-2 hours depending on your pet\'s size, coat condition, and services chosen.',
  },
  {
    'question': 'What should I bring to the appointment?',
    'answer': 'Just bring your pet! We provide all necessary supplies. However, if your pet has specific dietary needs, please bring their food.',
  },
  {
    'question': 'Can I stay with my pet during grooming?',
    'answer': 'For safety reasons, we ask that you drop off your pet and return at the scheduled pickup time.',
  },
  {
    'question': 'What if my pet has anxiety or special needs?',
    'answer': 'Please inform us in advance. Our groomers are trained to handle pets with anxiety and special requirements.',
  },
  {
    'question': 'How often should I groom my pet?',
    'answer': 'Most pets benefit from grooming every 4-8 weeks, depending on their breed and coat type.',
  },
  {
    'question': 'What if I need to cancel my appointment?',
    'answer': 'You can cancel up to 24 hours before your appointment through the app or by contacting us directly.',
  },
];
