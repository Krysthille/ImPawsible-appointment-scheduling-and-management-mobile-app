// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'login.dart';
// import 'signup.dart';
// import 'utils/network_utils.dart';
// import 'package:connectivity_plus/connectivity_plus.dart';
// import 'dart:async';
// import 'package:url_launcher/url_launcher.dart';
// import 'config/supabase_config.dart';

// const Color kOrange = Color(0xFFF5A623);

// class LandingPage extends StatefulWidget {
//   const LandingPage({super.key});

//   @override
//   State<LandingPage> createState() => _LandingPageState();
// }

// class _LandingPageState extends State<LandingPage> {
//   late StreamSubscription<ConnectivityResult> _connectivitySubscription;
//   ConnectivityResult _connectionStatus = ConnectivityResult.none;
//   final Connectivity _connectivity = Connectivity();
//   late PageController _testimonialController = PageController(viewportFraction: 0.85);
//   Timer? _autoScrollTimer;
//   bool _showAllFAQs = false;
//   int _displayedFAQsCount = 4;
//   static const int _faqsPerPage = 4;

//   // Testimonials
//   List<Map<String, dynamic>> _reviews = [];
//   bool _isLoadingReviews = true;

//   @override
//   void initState() {
//     super.initState();
//     _checkNetworkConnection();
//     _initConnectivity();
//     _connectivitySubscription =
//         _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);

//     // Start auto-scroll for testimonial carousel
//     _startAutoScroll();
//     _fetchReviews();
//   }

//   @override
//   void dispose() {
//     _connectivitySubscription.cancel();
//     _testimonialController.dispose();
//     _autoScrollTimer?.cancel();
//     super.dispose();
//   }

//   Future<void> _handleRefresh() async {
//     await _fetchReviews();
//     await _checkNetworkConnection();
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

//   Future<void> _fetchReviews() async {
//     try {
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
//           _reviews = [];
//           _isLoadingReviews = false;
//         });
//       }
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

//   List<Map<String, String>> _getDisplayedFAQs() {
//     return _allFAQs.take(_displayedFAQsCount).toList();
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

//   Future<void> _checkNetworkConnection() async {
//     final networkUtils = NetworkUtils();
//     final hasInternet = await networkUtils.hasInternetConnection();
//     if (!mounted) return;
//     if (!hasInternet) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(
//             'No internet connection. Some features may be limited.',
//             style: GoogleFonts.poppins(),
//           ),
//           backgroundColor: Colors.red,
//           duration: const Duration(seconds: 3),
//         ),
//       );
//     }
//   }

//   Future<void> _initConnectivity() async {
//     late ConnectivityResult result;
//     try {
//       result = await _connectivity.checkConnectivity();
//     } on Exception catch (e) {
//       print('Couldn\'t check connectivity status: $e');
//       return;
//     }
//     if (!mounted) {
//       return Future.value(null);
//     }
//     _connectionStatus = result;
//     return;
//   }

//   Future<void> _updateConnectionStatus(ConnectivityResult result) async {
//     if (_connectionStatus == result) {
//       return;
//     }
//     final previousStatus = _connectionStatus;
//     _connectionStatus = result;
//     if (previousStatus == ConnectivityResult.none &&
//         (_connectionStatus == ConnectivityResult.wifi ||
//             _connectionStatus == ConnectivityResult.mobile ||
//             _connectionStatus == ConnectivityResult.ethernet)) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(
//               'Internet connection restored!',
//               style: GoogleFonts.poppins(),
//             ),
//             backgroundColor: Colors.green,
//             duration: const Duration(seconds: 3),
//           ),
//         );
//       }
//     } else if (_connectionStatus == ConnectivityResult.none) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(
//               'Connection lost. Some features may be limited.',
//               style: GoogleFonts.poppins(),
//             ),
//             backgroundColor: Colors.red,
//             duration: const Duration(seconds: 3),
//           ),
//         );
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFFDFDFD),
//       body: RefreshIndicator(
//         color: kOrange,
//         onRefresh: _handleRefresh,
//         child: SingleChildScrollView(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               const SizedBox(height: 32),
//               Container(
//                 width: double.infinity,
//                 padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
//                 decoration: const BoxDecoration(
//                   gradient: LinearGradient(
//                     colors: [Color(0xFFFFF6E7), Colors.white],
//                     begin: Alignment.topCenter,
//                     end: Alignment.bottomCenter,
//                   ),
//                 ),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.end,
//                   children: [
//                     OutlinedButton(
//                       onPressed: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                               builder: (context) => const LoginPage()),
//                         );
//                       },
//                       style: OutlinedButton.styleFrom(
//                         side: BorderSide(color: kOrange),
//                         foregroundColor: kOrange,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(24),
//                         ),
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 24, vertical: 10),
//                       ),
//                       child: const Text('+ Log in'),
//                     ),
//                     const SizedBox(width: 12),
//                     ElevatedButton(
//                       onPressed: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                               builder: (context) => const SignupPage()),
//                         );
//                       },
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: kOrange,
//                         foregroundColor: Colors.white,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(24),
//                         ),
//                         padding: const EdgeInsets.symmetric(
//                             horizontal: 24, vertical: 10),
//                         elevation: 0,
//                       ),
//                       child: const Text('+ Sign up'),
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 16),
//               Center(
//                 child: Image.asset(
//                   'assets/images/logo1.png',
//                   height: 120,
//                   fit: BoxFit.contain,
//                 ),
//               ),
//               const SizedBox(height: 32),
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 16.0),
//                 child: Container(
//                   width: double.infinity,
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(18),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.orange.withOpacity(0.08),
//                         blurRadius: 16,
//                         offset: const Offset(0, 8),
//                       ),
//                     ],
//                   ),
//                   padding: const EdgeInsets.all(18),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'Services',
//                         style: GoogleFonts.poppins(
//                           fontSize: 21,
//                           fontWeight: FontWeight.bold,
//                           color: kOrange,
//                         ),
//                       ),
//                       const SizedBox(height: 20),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                         children: [
//                           _circleService('assets/images/bath.jpg', 'Bath', kOrange),
//                           _circleService('assets/images/haircut.jpg', 'Haircut', kOrange),
//                           _circleService('assets/images/earcleaning.jpg', 'Ear Cleaning', kOrange),
//                           _circleService('assets/images/nailtrimming.jpg', 'Nail Trimming', kOrange),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 32),
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 16.0),
//                 child: Container(
//                   width: double.infinity,
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(18),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.orange.withOpacity(0.08),
//                         blurRadius: 16,
//                         offset: const Offset(0, 8),
//                       ),
//                     ],
//                   ),
//                   padding: const EdgeInsets.all(18),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'About Us',
//                         style: GoogleFonts.poppins(
//                           fontSize: 20,
//                           fontWeight: FontWeight.bold,
//                           color: kOrange,
//                         ),
//                       ),
//                       const SizedBox(height: 16),
//                       Text(
//                         "I'mPawsible is a pet grooming scheduling app designed to provide a seamless and hassle-free booking experience for pet owners and grooming services. Our goal is to streamline pet care services by offering a convenient, reliable, and user-friendly platform for managing appointments efficiently.",
//                         style: GoogleFonts.poppins(fontSize: 15, color: Colors.black87),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 32),
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 16.0),
//                 child: Container(
//                   width: double.infinity,
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.orange.withOpacity(0.08),
//                         blurRadius: 16,
//                         offset: const Offset(0, 8),
//                       ),
//                     ],
//                     borderRadius: BorderRadius.circular(18),
//                     border: Border.all(color: Colors.white, width: 1),
//                   ),
//                   padding: const EdgeInsets.all(18),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'Why Choose Us?',
//                         style: GoogleFonts.poppins(
//                           fontSize: 20,
//                           fontWeight: FontWeight.bold,
//                           color: kOrange,
//                         ),
//                       ),
//                       GridView.count(
//                         crossAxisCount: 1,
//                         shrinkWrap: true,
//                         physics: const NeverScrollableScrollPhysics(),
//                         childAspectRatio: 5,
//                         children: [
//                           _whyChooseUsItem(
//                             icon: Icons.schedule,
//                             title: 'Easy online scheduling',
//                             description: 'Book appointments quickly and easily online.',
//                             accent: kOrange,
//                           ),
//                           _whyChooseUsItem(
//                             icon: Icons.pets,
//                             title: 'Pet-first, gentle handling',
//                             description: 'We prioritize your pet\'s comfort and safety.',
//                             accent: kOrange,
//                           ),
//                           _whyChooseUsItem(
//                             icon: Icons.chat_bubble_outline,
//                             title: 'Friendly, customer support',
//                             description: 'Our team is always ready to help you.',
//                             accent: kOrange,
//                           ),
//                           _whyChooseUsItem(
//                             icon: Icons.attach_money,
//                             title: 'Affordable, budget friendly',
//                             description: 'Quality grooming at a price you\'ll love.',
//                             accent: kOrange,
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 32),
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 16.0),
//                 child: Container(
//                   width: double.infinity,
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(18),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.orange.withOpacity(0.08),
//                         blurRadius: 16,
//                         offset: const Offset(0, 8),
//                       ),
//                     ],
//                   ),
//                   padding: const EdgeInsets.all(18),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'Testimonials',
//                         style: GoogleFonts.poppins(
//                           fontSize: 20,
//                           fontWeight: FontWeight.bold,
//                           color: kOrange,
//                         ),
//                       ),
//                       const SizedBox(height: 16),
//                       Container(
//                         padding: const EdgeInsets.all(6),
//                         child: _isLoadingReviews
//                             ? const Center(child: CircularProgressIndicator(color: kOrange))
//                             : _reviews.isEmpty
//                                 ? Column(
//                                     children: [
//                                       Icon(Icons.star_outline, size: 48, color: kOrange.withOpacity(0.5)),
//                                       const SizedBox(height: 12),
//                                       Text('No reviews yet', style: GoogleFonts.poppins(fontSize: 16, color: Colors.black54, fontWeight: FontWeight.w500)),
//                                       const SizedBox(height: 8),
//                                       Text('No testimonials have been submitted yet.', style: GoogleFonts.poppins(fontSize: 14, color: Colors.black45)),
//                                     ],
//                                   )
//                                 : SizedBox(
//                                     height: 140,
//                                     child: PageView.builder(
//                                       controller: _testimonialController,
//                                       itemCount: _reviews.length,
//                                       itemBuilder: (context, index) {
//                                         final review = _reviews[index];
//                                         final fullName = review['users']?['full_name'] ?? review['user_name'] ?? 'Anonymous';
//                                         final formattedName = _formatUserName(fullName);
//                                         final reviewText = review['review_text'] ?? '';
//                                         final rating = review['rating'] ?? 5;
//                                         return Padding(
//                                           padding: const EdgeInsets.symmetric(horizontal: 8),
//                                           child: _testimonialCardCarousel(
//                                             quote: reviewText.isNotEmpty ? reviewText : 'Great service!',
//                                             name: formattedName,
//                                             stars: rating,
//                                           ),
//                                         );
//                                       },
//                                     ),
//                                   ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 32),
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 16.0),
//                 child: Container(
//                   width: double.infinity,
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(18),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.orange.withOpacity(0.08),
//                         blurRadius: 16,
//                         offset: const Offset(0, 8),
//                       ),
//                     ],
//                   ),
//                   padding: const EdgeInsets.all(18),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'Location and Availability',
//                         style: GoogleFonts.poppins(
//                           fontSize: 20,
//                           fontWeight: FontWeight.bold,
//                           color: kOrange,
//                         ),
//                       ),
//                       const SizedBox(height: 12),
//                       Row(
//                         children: [
//                           Icon(Icons.location_on, color: kOrange, size: 28),
//                           const SizedBox(width: 8),
//                           Expanded(
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   'Vicentillo Street, Naval, Biliran',
//                                   style: GoogleFonts.poppins(
//                                     fontSize: 16,
//                                     color: Colors.black87,
//                                     fontWeight: FontWeight.w600,
//                                   ),
//                                 ),
//                                 const SizedBox(height: 2),
//                                 Text(
//                                   'Monday–Saturday: 9:00 AM – 6:00 PM',
//                                   style: GoogleFonts.poppins(
//                                     color: Colors.black54,
//                                     fontSize: 14,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 16),
//                       Divider(height: 1, thickness: 1, color: Colors.grey[300]),
//                       const SizedBox(height: 16),
//                       ClipRRect(
//                         borderRadius: BorderRadius.circular(12),
//                         child: Image.asset(
//                           'assets/images/location_map.jpeg',
//                           height: 160,
//                           width: double.infinity,
//                           fit: BoxFit.cover,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 32),
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 16.0),
//                 child: Container(
//                   width: double.infinity,
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(18),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.orange.withOpacity(0.08),
//                         blurRadius: 16,
//                         offset: const Offset(0, 8),
//                       ),
//                     ],
//                   ),
//                   padding: const EdgeInsets.all(18),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'Follow us on Facebook',
//                         style: GoogleFonts.poppins(
//                           fontSize: 20,
//                           fontWeight: FontWeight.bold,
//                           color: kOrange,
//                         ),
//                       ),
//                       const SizedBox(height: 12),
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
//               const SizedBox(height: 32),
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 16.0),
//                 child: Container(
//                   width: double.infinity,
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(18),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.orange.withOpacity(0.08),
//                         blurRadius: 16,
//                         offset: const Offset(0, 8),
//                       ),
//                     ],
//                   ),
//                   padding: const EdgeInsets.all(18),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'Frequently Asked Questions',
//                         style: GoogleFonts.poppins(
//                           fontSize: 20,
//                           fontWeight: FontWeight.bold,
//                           color: kOrange,
//                         ),
//                       ),
//                       const SizedBox(height: 16),
//                       ..._getDisplayedFAQs().map((faq) => Column(
//                             children: [
//                               _buildFAQItem(faq['question'] ?? '', faq['answer'] ?? ''),
//                               const SizedBox(height: 12),
//                             ],
//                           )).toList(),
//                       const SizedBox(height: 16),
//                       if (_allFAQs.length > _faqsPerPage)
//                         Padding(
//                           padding: const EdgeInsets.only(top: 16),
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
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
//               const SizedBox(height: 32),
//               Center(
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     GestureDetector(
//                       onTap: () => _showTermsAndConditionsDialog(context),
//                       child: Text(
//                         'Terms and Conditions',
//                         style: GoogleFonts.poppins(
//                           fontSize: 13,
//                           color: kOrange,
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                     ),
//                     Text(
//                       '  |  ',
//                       style: GoogleFonts.poppins(
//                         fontSize: 13,
//                         color: Colors.black45,
//                         fontWeight: FontWeight.w400,
//                       ),
//                     ),
//                     GestureDetector(
//                       onTap: () => _showPrivacyPolicyDialog(context),
//                       child: Text(
//                         'Privacy Policy',
//                         style: GoogleFonts.poppins(
//                           fontSize: 13,
//                           color: kOrange,
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 24),
//               Center(
//                 child: Text(
//                   '© 2025 ImPawsible',
//                   style: GoogleFonts.poppins(
//                     fontSize: 13,
//                     color: Colors.black45,
//                     fontWeight: FontWeight.w400,
//                   ),
//                   textAlign: TextAlign.center,
//                 ),
//               ),
//               const SizedBox(height: 12),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _circleService(String img, String label, Color borderColor) {
//     return Expanded(
//       child: Container(
//         height: 130,
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             Container(
//               width: 70,
//               height: 70,
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 border: Border.all(color: borderColor, width: 3),
//               ),
//               child: ClipOval(
//                 child: SizedBox(
//                   width: 70,
//                   height: 70,
//                   child: Image.asset(
//                     img,
//                     fit: BoxFit.cover,
//                   ),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 12),
//             Container(
//               width: double.infinity,
//               height: 40,
//               child: Text(
//                 label,
//                 textAlign: TextAlign.center,
//                 maxLines: 2,
//                 overflow: TextOverflow.ellipsis,
//                 style: GoogleFonts.poppins(
//                   fontSize: 13,
//                   color: Colors.orange,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _testimonialCardCarousel({required String quote, required String name, int stars = 5, Color accent = kOrange}) {
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

//   Widget _whyChooseUsItem({required IconData icon, required String title, required String description, Color accent = kOrange}) {
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Container(
//           margin: const EdgeInsets.only(top: 2),
//           child: Icon(icon, color: accent, size: 32),
//         ),
//         const SizedBox(width: 12),
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 title,
//                 style: GoogleFonts.poppins(fontSize: 15, color: Colors.black87, fontWeight: FontWeight.bold),
//                 maxLines: 2,
//                 overflow: TextOverflow.ellipsis,
//               ),
//               const SizedBox(height: 2),
//               Text(
//                 description,
//                 style: GoogleFonts.poppins(fontSize: 12, color: Colors.black54),
//                 maxLines: 3,
//                 overflow: TextOverflow.ellipsis,
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildFAQItem(String question, String answer) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.grey.shade50,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: Colors.grey.shade200, width: 1),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             question,
//             style: GoogleFonts.poppins(
//               fontSize: 15,
//               fontWeight: FontWeight.bold,
//               color: Colors.black87,
//             ),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             answer,
//             style: GoogleFonts.poppins(
//               fontSize: 14,
//               color: Colors.black54,
//               height: 1.4,
//             ),
//           ),
//         ],
//       ),
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
//                       _buildTermsSection(
//                         '4. Prohibited Behavior',
//                         'You agree not to:\n• Misuse the app\n• Post inappropriate content\n• Try to harm or hack the system',
//                       ),
//                       _buildTermsSection(
//                         '5. Updates',
//                         'We may update these terms from time to time. Continued use of the app means you accept any changes.',
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
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
//                         '• Personal Info: Full name, email, phone number, etc. \n• Pet Info: Pet name, breed, age, services booked, etc.',
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
//                         'You can view and update information anytime through your profile. If you want to delete your account, just let us know.',
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
//           const SizedBox(height: 8),
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
//           const SizedBox(height: 8),
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
//     'question': 'How do I book an appointment?',
//     'answer': 'Simply create an account, select your preferred service, choose a date and time, and confirm your booking.',
//   },
//   {
//     'question': 'What services do you offer?',
//     'answer': 'We offer comprehensive pet grooming services including baths, haircuts, ear cleaning, and nail trimming.',
//   },
//   {
//     'question': 'How far in advance should I book?',
//     'answer': 'We recommend booking at least 2-3 days in advance to ensure availability for your preferred time slot.',
//   },
//   {
//     'question': 'What if I need to cancel my appointment?',
//     'answer': 'You can cancel our appointment through the app up to 24 hours before your scheduled time.',
//   },
//   {
//     'question': 'Do I need to bring anything to my pet\'s appointment?',
//     'answer': 'No need! The app already provides a form where you can include any concerns or allergies your pet may have before the appointment.',
//   },
//   {
//     'question': 'How long does a grooming session take?',
//     'answer': 'Grooming sessions usually take between 1 to 2 hours, depending on your pet\'s size, coat condition, and the services chosen.',
//   },
//   {
//     'question': 'What if my pet has special needs or anxiety?',
//     'answer': 'Please let us know in advance by filling out the concerns section in the appointment form. Our team is trained to handle pets with special needs and will ensure they are treated with extra care and attention.',
//   },
//   {
//     'question': 'Are walk-ins accepted?',
//     'answer': 'We prioritize scheduled appointments to keep everything on time. However, walk-ins may be accommodated if there\'s availability.',
//   },
// ];



// ----

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'login.dart';
import 'signup.dart';
import 'utils/network_utils.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';
import 'package:url_launcher/url_launcher.dart';
import 'config/supabase_config.dart';

const Color kOrange = Color(0xFFF5A623);

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;
  ConnectivityResult _connectionStatus = ConnectivityResult.none;
  final Connectivity _connectivity = Connectivity();
  late PageController _testimonialController = PageController(viewportFraction: 0.85);
  Timer? _autoScrollTimer;
  bool _showAllFAQs = false;
  int _displayedFAQsCount = 4;
  static const int _faqsPerPage = 4;
  List<Map<String, dynamic>> _reviews = [];
  bool _isLoadingReviews = true;

  @override
  void initState() {
    super.initState();
    _checkNetworkConnection();
    _initConnectivity();
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
    _startAutoScroll();
    _fetchReviews();
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    _testimonialController.dispose();
    _autoScrollTimer?.cancel();
    super.dispose();
  }

  Future<void> _handleRefresh() async {
    await _fetchReviews();
    await _checkNetworkConnection();
  }

  void _startAutoScroll() {
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
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
      print('Error fetching reviews: $e');
      if (mounted) {
        setState(() {
          _reviews = [];
          _isLoadingReviews = false;
        });
      }
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

  List<Map<String, String>> _getDisplayedFAQs() {
    return _allFAQs.take(_displayedFAQsCount).toList();
  }

  void _expandFAQs() {
    if (_connectionStatus == ConnectivityResult.none) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'No internet connection. Please check your network settings.',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }
    setState(() {
      _displayedFAQsCount = (_displayedFAQsCount + _faqsPerPage).clamp(_faqsPerPage, _allFAQs.length);
    });
  }

  void _collapseFAQs() {
    setState(() {
      _displayedFAQsCount = _faqsPerPage;
    });
  }

  Future<void> _checkNetworkConnection() async {
    final networkUtils = NetworkUtils();
    final hasInternet = await networkUtils.hasInternetConnection();
    if (!mounted) return;
    if (!hasInternet) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'No internet connection. Some features may be limited.',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _initConnectivity() async {
    late ConnectivityResult result;
    try {
      result = await _connectivity.checkConnectivity();
    } on Exception catch (e) {
      print('Couldn\'t check connectivity status: $e');
      return;
    }
    if (!mounted) {
      return Future.value(null);
    }
    _connectionStatus = result;
    return;
  }

  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    if (_connectionStatus == result) {
      return;
    }
    final previousStatus = _connectionStatus;
    _connectionStatus = result;
    if (previousStatus == ConnectivityResult.none &&
        (_connectionStatus == ConnectivityResult.wifi ||
            _connectionStatus == ConnectivityResult.mobile ||
            _connectionStatus == ConnectivityResult.ethernet)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Internet connection restored!',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } else if (_connectionStatus == ConnectivityResult.none) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Connection lost. Some features may be limited.',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _showNoInternetSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'No internet connection. Please check your network settings.',
          style: GoogleFonts.poppins(),
        ),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFDFD),
      body: RefreshIndicator(
        color: kOrange,
        onRefresh: _handleRefresh,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 32),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFFFF6E7), Colors.white],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: () {
                        if (_connectionStatus == ConnectivityResult.none) {
                          _showNoInternetSnackbar();
                          return;
                        }
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const LoginPage()),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: kOrange),
                        foregroundColor: kOrange,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                      ),
                      child: const Text('+ Log in'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: () {
                        if (_connectionStatus == ConnectivityResult.none) {
                          _showNoInternetSnackbar();
                          return;
                        }
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const SignupPage()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kOrange,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                        elevation: 0,
                      ),
                      child: const Text('+ Sign up'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Image.asset(
                  'assets/images/logo1.png',
                  height: 120,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 32),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.withOpacity(0.08),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Services',
                        style: GoogleFonts.poppins(
                          fontSize: 21,
                          fontWeight: FontWeight.bold,
                          color: kOrange,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _circleService('assets/images/bath.jpg', 'Bath', kOrange),
                          _circleService('assets/images/haircut.jpg', 'Haircut', kOrange),
                          _circleService('assets/images/earcleaning.jpg', 'Ear Cleaning', kOrange),
                          _circleService('assets/images/nailtrimming.jpg', 'Nail Trimming', kOrange),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.withOpacity(0.08),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'About Us',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: kOrange,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "I'mPawsible is a pet grooming scheduling app designed to provide a seamless and hassle-free booking experience for pet owners and grooming services. Our goal is to streamline pet care services by offering a convenient, reliable, and user-friendly platform for managing appointments efficiently.",
                        style: GoogleFonts.poppins(fontSize: 15, color: Colors.black87),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.withOpacity(0.08),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.white, width: 1),
                  ),
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Why Choose Us?',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: kOrange,
                        ),
                      ),
                      GridView.count(
                        crossAxisCount: 1,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        childAspectRatio: 5,
                        children: [
                          _whyChooseUsItem(
                            icon: Icons.schedule,
                            title: 'Easy online scheduling',
                            description: 'Book appointments quickly and easily online.',
                            accent: kOrange,
                          ),
                          _whyChooseUsItem(
                            icon: Icons.pets,
                            title: 'Pet-first, gentle handling',
                            description: 'We prioritize your pet\'s comfort and safety.',
                            accent: kOrange,
                          ),
                          _whyChooseUsItem(
                            icon: Icons.chat_bubble_outline,
                            title: 'Friendly, customer support',
                            description: 'Our team is always ready to help you.',
                            accent: kOrange,
                          ),
                          _whyChooseUsItem(
                            icon: Icons.attach_money,
                            title: 'Affordable, budget friendly',
                            description: 'Quality grooming at a price you\'ll love.',
                            accent: kOrange,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.withOpacity(0.08),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Testimonials',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: kOrange,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(6),
                        child: _isLoadingReviews
                            ? const Center(child: CircularProgressIndicator(color: kOrange))
                            : _reviews.isEmpty
                                ? Column(
                                    children: [
                                      Icon(Icons.star_outline, size: 48, color: kOrange.withOpacity(0.5)),
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
              const SizedBox(height: 32),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.withOpacity(0.08),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Location and Availability',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: kOrange,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(Icons.location_on, color: kOrange, size: 28),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Vicentillo Street, Naval, Biliran',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Monday–Saturday: 9:00 AM – 6:00 PM',
                                  style: GoogleFonts.poppins(
                                    color: Colors.black54,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Divider(height: 1, thickness: 1, color: Colors.grey[300]),
                      const SizedBox(height: 16),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(
                          'assets/images/location_map.jpeg',
                          height: 160,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.withOpacity(0.08),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Follow us on Facebook',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: kOrange,
                        ),
                      ),
                      const SizedBox(height: 12),
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
                            onTap: () {
                              if (_connectionStatus == ConnectivityResult.none) {
                                _showNoInternetSnackbar();
                                return;
                              }
                              launchUrl(Uri.parse('https://www.facebook.com/profile.php?id=100064116609541'));
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1877F3),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
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
              ),
              const SizedBox(height: 32),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.withOpacity(0.08),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Frequently Asked Questions',
                        style: GoogleFonts.poppins(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: kOrange,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ..._getDisplayedFAQs().map((faq) => Column(
                            children: [
                              _buildFAQItem(faq['question'] ?? '', faq['answer'] ?? ''),
                              const SizedBox(height: 12),
                            ],
                          )).toList(),
                      const SizedBox(height: 16),
                      if (_allFAQs.length > _faqsPerPage)
                        Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              if (_displayedFAQsCount > _faqsPerPage)
                                TextButton(
                                  onPressed: _collapseFAQs,
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
                              if (_displayedFAQsCount <= _faqsPerPage)
                                const Spacer(),
                              if (_displayedFAQsCount < _allFAQs.length)
                                TextButton(
                                  onPressed: _expandFAQs,
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
                ),
              ),
              const SizedBox(height: 32),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (_connectionStatus == ConnectivityResult.none) {
                          _showNoInternetSnackbar();
                          return;
                        }
                        _showTermsAndConditionsDialog(context);
                      },
                      child: Text(
                        'Terms and Conditions',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: kOrange,
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
                      onTap: () {
                        if (_connectionStatus == ConnectivityResult.none) {
                          _showNoInternetSnackbar();
                          return;
                        }
                        _showPrivacyPolicyDialog(context);
                      },
                      child: Text(
                        'Privacy Policy',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: kOrange,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: Text(
                  '© 2025 ImPawsible',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.black45,
                    fontWeight: FontWeight.w400,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _circleService(String img, String label, Color borderColor) {
    return Expanded(
      child: Container(
        height: 130,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: borderColor, width: 3),
              ),
              child: ClipOval(
                child: SizedBox(
                  width: 70,
                  height: 70,
                  child: Image.asset(
                    img,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              height: 40,
              child: Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: Colors.orange,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _testimonialCardCarousel({required String quote, required String name, int stars = 5, Color accent = kOrange}) {
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

  Widget _whyChooseUsItem({required IconData icon, required String title, required String description, Color accent = kOrange}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 2),
          child: Icon(icon, color: accent, size: 32),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(fontSize: 15, color: Colors.black87, fontWeight: FontWeight.bold),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: GoogleFonts.poppins(fontSize: 12, color: Colors.black54),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            answer,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.black54,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  void _showTermsAndConditionsDialog(BuildContext context) {
    final orange = const Color(0xFFF5A623);
    final lightOrange = const Color(0xFFFFF6E7);
    showDialog(
      context: context,
      builder: (context) => Dialog(
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
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: lightOrange,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Column(
                  children: [
                    Icon(Icons.description, size: 48, color: orange),
                    const SizedBox(height: 12),
                    Text(
                      'Terms and Conditions',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: orange,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
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
                      _buildTermsSection(
                        '1. Use of the App',
                        'You agree to use Impawsible only for lawful purposes and to make genuine grooming appointments for your pet. You must not use the app to cause harm, distribute spam, or attempt to access other users\' data.',
                      ),
                      _buildTermsSection(
                        '2. User Accounts',
                        'To book appointments, you need to create an account. You are responsible for keeping your login information safe. Please keep your account info updated.',
                      ),
                      _buildTermsSection(
                        '3. Appointments',
                        'You can schedule or cancel appointments using the app. Make sure to follow our cancellation policy and respect time slots for better service experience.',
                      ),
                      _buildTermsSection(
                        '4. Prohibited Behavior',
                        'You agree not to:\n• Misuse the app\n• Post inappropriate content\n• Try to harm or hack the system',
                      ),
                      _buildTermsSection(
                        '5. Updates',
                        'We may update these terms from time to time. Continued use of the app means you accept any changes.',
                      ),
                    ],
                  ),
                ),
              ),
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
      ),
    );
  }

  void _showPrivacyPolicyDialog(BuildContext context) {
    final orange = const Color(0xFFF5A623);
    final lightOrange = const Color(0xFFFFF6E7);
    showDialog(
      context: context,
      builder: (context) => Dialog(
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
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: lightOrange,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Column(
                  children: [
                    Icon(Icons.privacy_tip, size: 48, color: orange),
                    const SizedBox(height: 12),
                    Text(
                      'Privacy Policy',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: orange,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
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
                      _buildPrivacySection(
                        '1. Information We Collect',
                        '• Personal Info: Full name, email, phone number, etc. \n• Pet Info: Pet name, breed, age, services booked, etc.',
                      ),
                      _buildPrivacySection(
                        '2. How We Use Your Info',
                        '• To manage appointments\n• To send confirmations, reminders, or updates\n• To improve the app experience\n• For customer support',
                      ),
                      _buildPrivacySection(
                        '3. Data Sharing',
                        'We do not sell or share your data with third parties except:\n• Service providers directly involved in your appointment\n• When required by law',
                      ),
                      _buildPrivacySection(
                        '4. Security',
                        'Your data is stored securely in our system. We use safety measures to protect your information.',
                      ),
                      _buildPrivacySection(
                        '5. User Control',
                        'You can view and update information anytime through your profile. If you want to delete your account, just let us know.',
                      ),
                      _buildPrivacySection(
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
              ),
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
      ),
    );
  }

  Widget _buildTermsSection(String title, String content) {
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
          const SizedBox(height: 8),
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

  Widget _buildPrivacySection(String title, String content) {
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
          const SizedBox(height: 8),
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
}

final List<Map<String, String>> _allFAQs = [
  {
    'question': 'How do I book an appointment?',
    'answer': 'Simply create an account, select your preferred service, choose a date and time, and confirm your booking.',
  },
  {
    'question': 'What services do you offer?',
    'answer': 'We offer comprehensive pet grooming services including baths, haircuts, ear cleaning, and nail trimming.',
  },
  {
    'question': 'How far in advance should I book?',
    'answer': 'We recommend booking at least 2-3 days in advance to ensure availability for your preferred time slot.',
  },
  {
    'question': 'What if I need to cancel my appointment?',
    'answer': 'You can cancel our appointment through the app up to 24 hours before your scheduled time.',
  },
  {
    'question': 'Do I need to bring anything to my pet\'s appointment?',
    'answer': 'No need! The app already provides a form where you can include any concerns or allergies your pet may have before the appointment.',
  },
  {
    'question': 'How long does a grooming session take?',
    'answer': 'Grooming sessions usually take between 1 to 2 hours, depending on your pet\'s size, coat condition, and the services chosen.',
  },
  {
    'question': 'What if my pet has special needs or anxiety?',
    'answer': 'Please let us know in advance by filling out the concerns section in the appointment form. Our team is trained to handle pets with special needs and will ensure they are treated with extra care and attention.',
  },
  {
    'question': 'Are walk-ins accepted?',
    'answer': 'We prioritize scheduled appointments to keep everything on time. However, walk-ins may be accommodated if there\'s availability.',
  },
];
