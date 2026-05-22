// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:image_picker/image_picker.dart';
// import 'dart:io';
// import 'home_admin.dart';
// import 'bookings_admin.dart';
// import 'shop_admin.dart';
// import 'messages_admin.dart';
// import 'export.dart';
// import 'registered_users_pet.dart';
// import 'login_history.dart';
// import 'package:fl_chart/fl_chart.dart';
// import 'package:intl/intl.dart';
// import 'change_password_admin.dart';

// class SettingsAdminPage extends StatefulWidget {
//   const SettingsAdminPage({Key? key}) : super(key: key);

//   @override
//   State<SettingsAdminPage> createState() => _SettingsAdminPageState();
// }

// class _SettingsAdminPageState extends State<SettingsAdminPage> {
//   Map<String, dynamic>? _adminProfile;
//   bool _isLoading = true;
//   String? _profileImageUrl;
//   final ImagePicker _picker = ImagePicker();
//   final orange = const Color(0xFFF5A623);
//   final lightOrange = const Color(0xFFFFF6E7);

//   @override
//   void initState() {
//     super.initState();
//     _loadAdminProfile();
//     // _logAdminLogin(); // Log admin login when page loads
//     // _insertTestLoginData(); // Insert test login data when page loads
//   }

//   Future<void> _loadAdminProfile() async {
//     try {
//       final supabase = Supabase.instance.client;
//       final user = supabase.auth.currentUser;
//       if (user != null) {
//         final response = await supabase
//             .from('users')
//             .select('full_name, email, contact_number, profile_image_url')
//             .eq('id', user.id)
//             .maybeSingle();
        
//         setState(() {
//           _adminProfile = response;
//           _profileImageUrl = response?['profile_image_url'];
//           _isLoading = false;
//         });
//         // Log admin login after profile is loaded
//         // await _logAdminLogin(); // Commented out to avoid logging on every page visit
//         // Insert test data after profile is loaded (optional, for testing)
//         // await _insertTestLoginData();
//       }
//     } catch (e) {
//       print('Error loading admin profile: $e');
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     int _selectedIndex = 4;
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           'Settings',
//           style: GoogleFonts.poppins(
//             fontSize: 28,
//             fontWeight: FontWeight.bold,
//             color: orange,
//           ),
//         ),
//         backgroundColor: const Color(0xFFFFF6E7),
//         elevation: 0,
//         iconTheme: const IconThemeData(color: Colors.black87),
//         automaticallyImplyLeading: false,
//       ),
//       body: Container(
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             colors: [Color(0xFFFFF6E7), Colors.white],
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//           ),
//         ),
//         child: SafeArea(
//           child: ListView(
//             padding: const EdgeInsets.all(16),
//             children: [
//               // Admin Profile Section
//               if (_isLoading)
//                 const Center(child: CircularProgressIndicator(color: Color(0xFFF5A623)))
//               else
//                 Container(
//                   margin: const EdgeInsets.only(bottom: 24),
//                   padding: const EdgeInsets.all(20),
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(16),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black.withOpacity(0.05),
//                         blurRadius: 8,
//                         offset: const Offset(0, 2),
//                       ),
//                     ],
//                   ),
//                   child: Column(
//                     children: [
//                       // Profile Picture
//                       GestureDetector(
//                         onTap: _showImagePickerDialog,
//                         child: Stack(
//                           children: [
//                             CircleAvatar(
//                               radius: 48,
//                               backgroundColor: orange.withOpacity(0.15),
//                               backgroundImage: _profileImageUrl != null 
//                                   ? NetworkImage(_profileImageUrl!) 
//                                   : null,
//                               child: _profileImageUrl == null 
//                                   ? Icon(Icons.person, size: 48, color: orange)
//                                   : null,
//                             ),
//                             Positioned(
//                               bottom: 0,
//                               right: 0,
//                               child: Container(
//                                 width: 32,
//                                 height: 32,
//                                 decoration: BoxDecoration(
//                                   color: Colors.black,
//                                   shape: BoxShape.circle,
//                                   border: Border.all(color: Colors.white, width: 2),
//                                 ),
//                                 child: Icon(
//                                   Icons.camera_alt,
//                                   color: Colors.white,
//                                   size: 16,
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                       const SizedBox(height: 16),
//                       // Admin Name + Edit icon inline
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Text(
//                             _adminProfile?['full_name'] ?? 'Admin Name',
//                             style: GoogleFonts.poppins(
//                               fontSize: 22,
//                               fontWeight: FontWeight.bold,
//                               color: orange,
                             
//                             ),
//                              textAlign: TextAlign.center,
//                           ),
//                           // const SizedBox(width: 2),
//                           IconButton(
//                             icon: const Icon(Icons.edit, color: Colors.black87, size: 20),
//                             tooltip: 'Edit profile',
//                             onPressed: _showEditProfileDialog,
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 8),
//                       // Email
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Icon(Icons.email, size: 16, color: Colors.grey[600]),
//                           const SizedBox(width: 6),
//                           Text(
//                             _adminProfile?['email'] ?? 'admin@email.com',
//                             style: GoogleFonts.poppins(
//                               fontSize: 15,
//                               color: Colors.black87,
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 6),
//                       // Contact Number
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Icon(Icons.phone, size: 16, color: Colors.grey[600]),
//                           const SizedBox(width: 6),
//                           Text(
//                             _adminProfile?['contact_number'] ?? 'Contact Number',
//                             style: GoogleFonts.poppins(
//                               fontSize: 15,
//                               color: Colors.black87,
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 16),
//                       // Admin Badge
//                       Container(
//                         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                         decoration: BoxDecoration(
//                           color: orange.withOpacity(0.1),
//                           borderRadius: BorderRadius.circular(20),
//                           border: Border.all(color: orange, width: 1),
//                         ),
//                         child: Row(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             Icon(Icons.admin_panel_settings, size: 16, color: orange),
//                             const SizedBox(width: 6),
//                             Text(
//                               'Administrator',
//                               style: GoogleFonts.poppins(
//                                 fontSize: 14,
//                                 fontWeight: FontWeight.w600,
//                                 color: orange,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               // const SizedBox(height: 14),
//               // _sectionHeader('Appointment Management Settings'),
//               // _settingsTile(
//               //   context,
//               //   icon: Icons.event_available,
//               //   title: 'Set Maximum Daily Bookings',
//               //   subtitle: 'Limit daily appointments to prevent overbooking',
//               //   onTap: () => _showComingSoon(context),
//               // ),
//               // const SizedBox(height: 14),
//               // _sectionHeader('Service Management'),
//               // _settingsTile(
//               //   context,
//               //   icon: Icons.add_box,
//               //   title: 'Add Grooming Service',
//               //   onTap: () => _showComingSoon(context),
//               // ),
//               // const SizedBox(height: 8),
//               // _settingsTile(
//               //   context,
//               //   icon: Icons.edit,
//               //   title: 'Edit/Delete Grooming Services',
//               //   onTap: () => _showComingSoon(context),
//               // ),
//               // const SizedBox(height: 8),
//               // _settingsTile(
//               //   context,
//               //   icon: Icons.price_change,
//                 // title: 'Edit Services',
//                 // onTap: () {
//                 //   Navigator.push(
//                 //     context,
//                 //     MaterialPageRoute(
//                 //       builder: (context) => const EditServicesPage(),
//                 //     ),
//                 //   );
//                 // },
//               // ),
//               // const SizedBox(height: 14),
//               _sectionHeader('Data Management Control'),
//               _settingsTile(
//                 context,
//                 icon: Icons.picture_as_pdf,
//                 title: 'Export Booking Data as PDF',
//                 onTap: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => const ExportPage(),
//                     ),
//                   );
//                 },
//               ),
//               // const SizedBox(height: 8),
//               // _settingsTile(
//               //   context,
//               //   icon: Icons.delete_forever,
//               //   title: 'Clear Appointment Data',
//               //   subtitle: 'Manually or auto-delete appointments older than 3 months',
//               //   onTap: () => _showComingSoon(context),
//               // ),
//               // const SizedBox(height: 8),
//               // _settingsTile(
//               //   context,
//               //   icon: Icons.delete_sweep,
//               //   title: 'Delete Old Messages',
//               //   subtitle: 'Automatically delete messages older than 3 months',
//               //   onTap: () => _showComingSoon(context),
//               // ),
//               const SizedBox(height: 8),
//               // _sectionHeader('User Management Control'),
//               _settingsTile(
//                 context,
//                 icon: Icons.people,
//                 title: 'View Registered Users & Pets',
//                 onTap: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => const RegisteredUsersPetPage(),
//                     ),
//                   );
//                 },
//               ),
//               const SizedBox(height: 14),
//               _sectionHeader('Dashboard Customization'),
//               _settingsTile(
//                 context,
//                 icon: Icons.brightness_6,
//                 title: 'Switch Light/Dark Mode',
//                 onTap: () => _showComingSoon(context),
//               ),
//               const SizedBox(height: 8),
//               _settingsTile(
//                 context,
//                 icon: Icons.palette,
//                 title: 'Customize Theme',
//                 onTap: () => _showComingSoon(context),
//               ),
//               const SizedBox(height: 14),
//               _sectionHeader('Security Settings'),
//               _settingsTile(
//                 context,
//                 icon: Icons.security,
//                 title: 'View Login History',
//                 // subtitle: 'See recent logins (optionally as a chart)',
//                 onTap: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => const LoginHistoryPage(),
//                     ),
//                   );
//                 },
//               ),
//               const SizedBox(height: 8),
//               _settingsTile(
//                 context,
//                 icon: Icons.lock,
//                 title: 'Change Password',
//                 // subtitle: 'Update your admin account password',
//                 onTap: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => const ChangePasswordAdminPage(),
//                     ),
//                   );
//                 },
//               ),
//               const SizedBox(height: 14),
//               _sectionHeader('Legal and Policies'),
//               _settingsTile(
//                 context,
//                 icon: Icons.description,
//                 title: 'Terms & Conditions',
//                 onTap: () => _showTermsAndConditionsDialog(context),
//               ),
//               const SizedBox(height: 8),
//               _settingsTile(
//                 context,
//                 icon: Icons.privacy_tip,
//                 title: 'Privacy Policy',
//                 onTap: () => _showPrivacyPolicyDialog(context),
//               ),
//               const SizedBox(height: 14),
//               _settingsTile(
//                 context,
//                 icon: Icons.logout,
//                 title: 'Logout',
//                 titleColor: Colors.red,
//                 iconColor: Colors.red,
//                 onTap: () => _showLogoutDialog(context),
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
//             BottomNavigationBarItem(
//               icon: Icon(Icons.shopping_bag),
//               label: 'Shop',
//             ),
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
//           onTap: (index) {
//             if (index == _selectedIndex) return;
//             switch (index) {
//               case 0:
//                 Navigator.pushReplacement(
//                   context,
//                   MaterialPageRoute(builder: (context) => const HomeAdminPage()),
//                 );
//                 break;
//               case 1:
//                 Navigator.pushReplacement(
//                   context,
//                   MaterialPageRoute(builder: (context) => const BookingsAdminPage()),
//                 );
//                 break;
//               case 2:
//                 Navigator.pushReplacement(
//                   context,
//                   MaterialPageRoute(builder: (context) => const ShopAdminPage()),
//                 );
//                 break;
//               case 3:
//                 Navigator.pushReplacement(
//                   context,
//                   MaterialPageRoute(builder: (context) => const MessagesAdminPage()),
//                 );
//                 break;
//               case 4:
//                 // Already on settings
//                 break;
//             }
//           },
//           type: BottomNavigationBarType.fixed,
//           backgroundColor: Colors.white,
//         ),
//       ),
//     );
//   }

//   Widget _sectionHeader(String title) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 8),
//       child: Text(
//         title,
//         style: GoogleFonts.poppins(
//           fontSize: 16,
//           fontWeight: FontWeight.bold,
//           color: const Color(0xFFF5A623),
//         ),
//       ),
//     );
//   }

//   Widget _settingsTile(
//     BuildContext context, {
//     required IconData icon,
//     required String title,
//     String? subtitle,
//     Color? titleColor,
//     Color? iconColor,
//     required VoidCallback onTap,
//   }) {
//     final isLogout = titleColor == Colors.red;
//     return Container(
//       margin: const EdgeInsets.symmetric(vertical: 1),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(14),
//         border: Border.all(color: isLogout ? Colors.red : const Color(0xFFF5A623), width: 1),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.orange.withOpacity(0.06),
//             blurRadius: 6,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: ListTile(
//         leading: Icon(icon, color: iconColor ?? const Color(0xFFF5A623)),
//         title: Text(
//           title,
//           style: GoogleFonts.poppins(
//             fontSize: 14,
//             // fontWeight: FontWeight.w600,
//             color: titleColor ?? Colors.black,
//           ),
//         ),
//         subtitle: subtitle != null
//             ? Text(
//                 subtitle,
//                 style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey[700]),
//               )
//             : null,
//         onTap: onTap,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
//         contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
//         trailing: Icon(Icons.arrow_forward_ios, size: 13, color: Colors.grey[400]),
//       ),
//     );
//   }

//   void _showComingSoon(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Coming Soon'),
//         content: const Text('This feature will be available in a future update.'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('OK'),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showLogoutDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//         contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Icon(Icons.warning_amber_rounded, color: Colors.red, size: 48),
//             const SizedBox(height: 12),
//             Text('Logout',
//                 style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87)),
//             const SizedBox(height: 8),
//             Text('Are you sure you want to log out of your account?',
//                 textAlign: TextAlign.center,
//                 style: GoogleFonts.poppins(fontSize: 15, color: Colors.black54)),
//             const SizedBox(height: 24),
//             Row(
//               children: [
//                 Expanded(
//                   child: OutlinedButton(
//                     onPressed: () => Navigator.pop(context),
//                     style: OutlinedButton.styleFrom(
//                       side: const BorderSide(color: Colors.black),
//                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//                     ),
//                     child: Text('Cancel', style: GoogleFonts.poppins(color: Colors.black)),
//                   ),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: ElevatedButton(
//                     onPressed: () {
//                       Navigator.pop(context);
//                       Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
//                     },
//                     style: ElevatedButton.styleFrom(
//                       // backgroundColor: Colors.red,
//                       side: const BorderSide(color: Colors.red),
//                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//                     ),
//                     child: Text('Logout', style: GoogleFonts.poppins(color: Colors.red)),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
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

//   Widget _buildTermsSection(String title, String content) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             title,
//             style: GoogleFonts.poppins(
//               fontSize: 15,
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

//   Widget _buildPrivacySection(String title, String content) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             title,
//             style: GoogleFonts.poppins(
//               fontSize: 15,
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

//   Future<void> _pickImage(ImageSource source) async {
//     try {
//       final XFile? image = await _picker.pickImage(
//         source: ImageSource.gallery, // Only allow gallery selection
//         maxWidth: 512,
//         maxHeight: 512,
//         imageQuality: 80,
//       );
      
//       if (image != null) {
//         await _uploadProfileImage(File(image.path));
//       }
//     } catch (e) {
//       print('Error picking image: $e');
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Error selecting image: $e'),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     }
//   }

//   Future<void> _uploadProfileImage(File imageFile) async {
//     try {
//       setState(() => _isLoading = true);
      
//       final supabase = Supabase.instance.client;
//       final user = supabase.auth.currentUser;
//       if (user == null) return;

//       // Upload image to Supabase Storage
//       final fileName = 'profile_${user.id}_${DateTime.now().millisecondsSinceEpoch}.jpg';
//       final response = await supabase.storage
//           .from('profile-images')
//           .upload(fileName, imageFile);

//       if (response.isNotEmpty) {
//         // Get the public URL
//         final imageUrl = supabase.storage
//             .from('profile-images')
//             .getPublicUrl(fileName);

//         // Update user profile in database
//         await supabase
//             .from('users')
//             .update({'profile_image_url': imageUrl})
//             .eq('id', user.id);

//         // Update local state
//         setState(() {
//           _profileImageUrl = imageUrl;
//           _isLoading = false;
//         });

//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text('Profile picture updated successfully!'),
//               backgroundColor: Colors.green,
//             ),
//           );
//         }
//       }
//     } catch (e) {
//       print('Error uploading image: $e');
//       setState(() => _isLoading = false);
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Error uploading image: $e'),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     }
//   }

//   void _showImagePickerDialog() {
//     // Check if profile picture exists
//     final hasProfilePicture = _profileImageUrl != null && _profileImageUrl!.isNotEmpty;
    
//     showDialog(
//       context: context,
//       builder: (context) => Dialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//         child: Container(
//           constraints: BoxConstraints(
//             maxHeight: MediaQuery.of(context).size.height * 0.7,
//             maxWidth: MediaQuery.of(context).size.width * 0.9,
//           ),
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
//                     Icon(Icons.person, size: 48, color: orange),
//                     const SizedBox(height: 12),
//                     Text(
//                       hasProfilePicture ? 'Profile Picture' : 'Select Profile Picture',
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
//               Flexible(
//                 child: SingleChildScrollView(
//                   padding: const EdgeInsets.all(20),
//                   child: hasProfilePicture
//                       ? Column(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             // Selected Image Display
//                             Container(
//                               width: double.infinity,
//                               height: 180,
//                               decoration: BoxDecoration(
//                                 color: lightOrange,
//                                 borderRadius: BorderRadius.circular(16),
//                                 border: Border.all(color: orange.withOpacity(0.3), width: 2),
//                               ),
//                               child: ClipRRect(
//                                 borderRadius: BorderRadius.circular(14),
//                                 child: Image.network(
//                                   _profileImageUrl!,
//                                   fit: BoxFit.cover,
//                                   errorBuilder: (context, error, stackTrace) {
//                                     return Center(
//                                       child: Column(
//                                         mainAxisAlignment: MainAxisAlignment.center,
//                                         children: [
//                                           Icon(Icons.person, size: 64, color: orange),
//                                           const SizedBox(height: 8),
//                                           Text(
//                                             'Profile Picture',
//                                             style: GoogleFonts.poppins(
//                                               fontSize: 16,
//                                               fontWeight: FontWeight.w600,
//                                               color: orange,
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     );
//                                   },
//                                 ),
//                               ),
//                             ),
//                             const SizedBox(height: 20),
//                             // Select from Gallery Button
//                             SizedBox(
//                               width: double.infinity,
//                               child: ElevatedButton.icon(
//                                 onPressed: () {
//                                   Navigator.pop(context);
//                                   _pickImage(ImageSource.gallery);
//                                 },
//                                 icon: Icon(Icons.photo_library, color: Colors.white),
//                                 label: Text(
//                                   'Select another from Gallery',
//                                   style: GoogleFonts.poppins(
//                                     fontSize: 16,
//                                     fontWeight: FontWeight.w600,
//                                     color: Colors.white,
//                                   ),
//                                 ),
//                                 style: ElevatedButton.styleFrom(
//                                   backgroundColor: orange,
//                                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                                   padding: const EdgeInsets.symmetric(vertical: 16),
//                                 ),
//                               ),
//                             ),
//                           ],
//                         )
//                       : Column(
//                           mainAxisSize: MainAxisSize.min,
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             // Select from Gallery Button (for no profile picture)
//                             SizedBox(
//                               width: double.infinity,
//                               child: ElevatedButton.icon(
//                                 onPressed: () {
//                                   Navigator.pop(context);
//                                   _pickImage(ImageSource.gallery);
//                                 },
//                                 icon: Icon(Icons.photo_library, color: Colors.white),
//                                 label: Text(
//                                   'Select from Gallery',
//                                   style: GoogleFonts.poppins(
//                                     fontSize: 16,
//                                     fontWeight: FontWeight.w600,
//                                     color: Colors.white,
//                                   ),
//                                 ),
//                                 style: ElevatedButton.styleFrom(
//                                   backgroundColor: orange,
//                                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                                   padding: const EdgeInsets.symmetric(vertical: 16),
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   // Function to log admin login
//   Future<void> _logAdminLogin() async {
//     try {
//       final supabase = Supabase.instance.client;
//       final user = supabase.auth.currentUser;
//       if (user != null && _adminProfile != null) {
//         print('Logging admin login for user: ${user.id}');
//         print('Admin profile: $_adminProfile');
        
//         final now = DateTime.now();
//         final loginData = {
//           'user_id': user.id,
//           'admin_name': _adminProfile!['full_name'] ?? 'Admin User',
//           'login_date': now.toIso8601String().split('T')[0],
//           'login_time': '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}',
//         };
        
//         print('Inserting login data: $loginData');
        
//         final result = await supabase.from('login_history').insert(loginData);
//         print('Login history insert result: $result');
//         if (result == null || (result is List && result.isEmpty)) {
//           print('Login history insert failed or returned empty. Possible RLS issue.');
//         } else {
//           if (mounted) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(
//                 content: Text('Login logged successfully'),
//                 backgroundColor: Colors.green,
//                 duration: const Duration(seconds: 1),
//               ),
//             );
//           }
//         }
//       } else {
//         print('Cannot log login: user=${user?.id}, profile=${_adminProfile != null}');
//       }
//     } catch (e) {
//       print('Error logging admin login: $e');
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Error logging login: $e'),
//             backgroundColor: Colors.red,
//             duration: const Duration(seconds: 2),
//           ),
//         );
//       }
//     }
//   }

//   // Function to insert test login data
//   Future<void> _insertTestLoginData() async {
//     try {
//       final supabase = Supabase.instance.client;
//       final user = supabase.auth.currentUser;
//       if (user != null) {
//         final adminName = _adminProfile?['full_name'] ?? 'Admin User';
//         final now = DateTime.now();
        
//         // Insert some test data for the last few days
//         for (int i = 0; i < 5; i++) {
//           final testDate = now.subtract(Duration(days: i));
//           final loginData = {
//             'user_id': user.id,
//             'admin_name': adminName,
//             'login_date': testDate.toIso8601String().split('T')[0],
//             'login_time': '${(9 + i * 2).clamp(0, 23).toString().padLeft(2, '0')}:${(30 + i * 15).clamp(0, 59).toString().padLeft(2, '0')}:00',
//           };
          
//           await supabase.from('login_history').insert(loginData);
//         }
        
//         print('Test login data inserted successfully');
//       }
//     } catch (e) {
//       print('Error inserting test login data: $e');
//     }
//   }

//   // Edit Profile Modal
//   void _showEditProfileDialog() {
//     final nameController = TextEditingController(text: _adminProfile?['full_name'] ?? '');
//     final emailController = TextEditingController(text: _adminProfile?['email'] ?? '');
//     final contactController = TextEditingController(text: _adminProfile?['contact_number'] ?? '');

//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (context) {
//         return Dialog(
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//           child: StatefulBuilder(
//             builder: (context, setLocal) {
//               return Container(
//                 padding: const EdgeInsets.all(20),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(20),
//                 ),
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Text('Update Information',
//                         style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold)),
//                     const SizedBox(height: 16),
//                     // Avatar preview
//                     GestureDetector(
//                       onTap: _showImagePickerDialog,
//                       child: CircleAvatar(
//                         radius: 40,
//                         backgroundColor: orange.withOpacity(0.15),
//                         backgroundImage: _profileImageUrl != null ? NetworkImage(_profileImageUrl!) : null,
//                         child: _profileImageUrl == null ? Icon(Icons.person, size: 40, color: orange) : null,
//                       ),
//                     ),
//                     const SizedBox(height: 16),
//                     // Name field
//                     _iconInputRow(icon: Icons.person, controller: nameController, hint: 'Full name'),
//                     const SizedBox(height: 10),
//                     // Email field
//                     _iconInputRow(icon: Icons.email, controller: emailController, hint: 'Email'),
//                     const SizedBox(height: 10),
//                     // Contact field
//                     _iconInputRow(icon: Icons.phone, controller: contactController, hint: 'Contact number'),
//                     const SizedBox(height: 16),
//                     SizedBox(
//                       width: double.infinity,
//                       child: ElevatedButton.icon(
//                         icon: const Icon(Icons.sync),
//                         label: Text('Update', style: GoogleFonts.poppins()),
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: orange,
//                           foregroundColor: Colors.white,
//                           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//                           padding: const EdgeInsets.symmetric(vertical: 14),
//                         ),
//                         onPressed: () async {
//                           final supabase = Supabase.instance.client;
//                           final user = supabase.auth.currentUser;
//                           if (user == null) return;
//                           try {
//                             await supabase
//                                 .from('users')
//                                 .update({
//                                   'full_name': nameController.text.trim(),
//                                   'email': emailController.text.trim(),
//                                   'contact_number': contactController.text.trim(),
//                                 })
//                                 .eq('id', user.id);
//                             if (mounted) {
//                               setState(() {
//                                 _adminProfile = {
//                                   ...?_adminProfile,
//                                   'full_name': nameController.text.trim(),
//                                   'email': emailController.text.trim(),
//                                   'contact_number': contactController.text.trim(),
//                                 };
//                               });
//                               Navigator.pop(context);
//                               ScaffoldMessenger.of(context).showSnackBar(
//                                 SnackBar(content: Text('Profile updated'), backgroundColor: Colors.green),
//                               );
//                             }
//                           } catch (e) {
//                             if (mounted) {
//                               ScaffoldMessenger.of(context).showSnackBar(
//                                 SnackBar(content: Text('Update failed: $e'), backgroundColor: Colors.red),
//                               );
//                             }
//                           }
//                         },
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     GestureDetector(
//                       onTap: () => Navigator.pop(context),
//                       child: Text('Close', style: GoogleFonts.poppins(color: Colors.black)),
//                     ),
//                   ],
//                 ),
//               );
//             },
//           ),
//         );
//       },
//     );
//   }

//   Widget _iconInputRow({required IconData icon, required TextEditingController controller, required String hint}) {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.orange.withOpacity(0.15),
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: Row(
//         children: [
//           const SizedBox(width: 8),
//           Icon(icon, color: const Color(0xFFF5A623)),
//           const SizedBox(width: 8),
//           Expanded(
//             child: TextField(
//               controller: controller,
//               decoration: InputDecoration(
//                 hintText: hint,
//                 border: InputBorder.none,
//                 contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// } 

//__________________________________________________________________________________________________________________________________________


// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:image_picker/image_picker.dart';
// import 'dart:io';
// import 'home_admin.dart';
// import 'bookings_admin.dart';
// // import 'shop_admin.dart';
// import 'messages_admin.dart';
// import 'export.dart';
// import 'registered_users_pet.dart';
// import 'login_history.dart';
// import 'package:fl_chart/fl_chart.dart';
// import 'package:intl/intl.dart';
// import 'change_password_admin.dart';

// class SettingsAdminPage extends StatefulWidget {
//   const SettingsAdminPage({Key? key}) : super(key: key);

//   @override
//   State<SettingsAdminPage> createState() => _SettingsAdminPageState();
// }

// class _SettingsAdminPageState extends State<SettingsAdminPage> {
//   Map<String, dynamic>? _adminProfile;
//   bool _isLoading = true;
//   String? _profileImageUrl;
//   final ImagePicker _picker = ImagePicker();
//   Color _selectedThemeColor = const Color(0xFFF5A623);
//   ThemeMode _themeMode = ThemeMode.light;
//   final lightOrange = const Color(0xFFFFF6E7);

//   @override
//   void initState() {
//     super.initState();
//     _loadAdminProfile();
//   }

//   Future<void> _loadAdminProfile() async {
//     try {
//       final supabase = Supabase.instance.client;
//       final user = supabase.auth.currentUser;
//       if (user != null) {
//         final response = await supabase
//             .from('users')
//             .select('full_name, email, contact_number, profile_image_url')
//             .eq('id', user.id)
//             .maybeSingle();

//         setState(() {
//           _adminProfile = response;
//           _profileImageUrl = response?['profile_image_url'];
//           _isLoading = false;
//         });
//       }
//     } catch (e) {
//       print('Error loading admin profile: $e');
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     int _selectedIndex = 3;
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           'Settings',
//           style: GoogleFonts.poppins(
//             fontSize: 28,
//             fontWeight: FontWeight.bold,
//             color: _selectedThemeColor,
//           ),
//         ),
//         backgroundColor: lightOrange,
//         elevation: 0,
//         iconTheme: const IconThemeData(color: Colors.black87),
//         automaticallyImplyLeading: false,
//       ),
//       body: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             colors: [lightOrange, Colors.white],
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//           ),
//         ),
//         child: SafeArea(
//           child: ListView(
//             padding: const EdgeInsets.all(16),
//             children: [
//               // Admin Profile Section
//               if (_isLoading)
//                 const Center(child: CircularProgressIndicator(color: Color(0xFFF5A623)))
//               else
//                 Container(
//                   margin: const EdgeInsets.only(bottom: 24),
//                   padding: const EdgeInsets.all(20),
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(16),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black.withOpacity(0.05),
//                         blurRadius: 8,
//                         offset: const Offset(0, 2),
//                       ),
//                     ],
//                   ),
//                   child: Column(
//                     children: [
//                       // Profile Picture
//                       GestureDetector(
//                         onTap: _showImagePickerDialog,
//                         child: Stack(
//                           children: [
//                             CircleAvatar(
//                               radius: 48,
//                               backgroundColor: _selectedThemeColor.withOpacity(0.15),
//                               backgroundImage: _profileImageUrl != null
//                                   ? NetworkImage(_profileImageUrl!)
//                                   : null,
//                               child: _profileImageUrl == null
//                                   ? Icon(Icons.person, size: 48, color: _selectedThemeColor)
//                                   : null,
//                             ),
//                             Positioned(
//                               bottom: 0,
//                               right: 0,
//                               child: Container(
//                                 width: 32,
//                                 height: 32,
//                                 decoration: BoxDecoration(
//                                   color: Colors.black,
//                                   shape: BoxShape.circle,
//                                   border: Border.all(color: Colors.white, width: 2),
//                                 ),
//                                 child: Icon(
//                                   Icons.camera_alt,
//                                   color: Colors.white,
//                                   size: 16,
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                       const SizedBox(height: 16),
//                       // Admin Name + Edit icon inline
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Text(
//                             _adminProfile?['full_name'] ?? 'Admin Name',
//                             style: GoogleFonts.poppins(
//                               fontSize: 22,
//                               fontWeight: FontWeight.bold,
//                               color: _selectedThemeColor,
//                             ),
//                             textAlign: TextAlign.center,
//                           ),
//                           IconButton(
//                             icon: const Icon(Icons.edit, color: Colors.black87, size: 20),
//                             tooltip: 'Edit profile',
//                             onPressed: _showEditProfileDialog,
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 8),
//                       // Email
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Icon(Icons.email, size: 16, color: Colors.grey[600]),
//                           const SizedBox(width: 6),
//                           Text(
//                             _adminProfile?['email'] ?? 'admin@email.com',
//                             style: GoogleFonts.poppins(
//                               fontSize: 15,
//                               color: Colors.black87,
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 6),
//                       // Contact Number
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Icon(Icons.phone, size: 16, color: Colors.grey[600]),
//                           const SizedBox(width: 6),
//                           Text(
//                             _adminProfile?['contact_number'] ?? 'Contact Number',
//                             style: GoogleFonts.poppins(
//                               fontSize: 15,
//                               color: Colors.black87,
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 16),
//                       // Admin Badge
//                       Container(
//                         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                         decoration: BoxDecoration(
//                           color: _selectedThemeColor.withOpacity(0.1),
//                           borderRadius: BorderRadius.circular(20),
//                           border: Border.all(color: _selectedThemeColor, width: 1),
//                         ),
//                         child: Row(
//                           mainAxisSize: MainAxisSize.min,
//                           children: [
//                             Icon(Icons.admin_panel_settings, size: 16, color: _selectedThemeColor),
//                             const SizedBox(width: 6),
//                             Text(
//                               'Administrator',
//                               style: GoogleFonts.poppins(
//                                 fontSize: 14,
//                                 fontWeight: FontWeight.w600,
//                                 color: _selectedThemeColor,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               const SizedBox(height: 14),
//               _sectionHeader('Data Management Control'),
//               _settingsTile(
//                 context,
//                 icon: Icons.picture_as_pdf,
//                 title: 'Export Booking Data as PDF',
//                 onTap: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => const ExportPage(),
//                     ),
//                   );
//                 },
//               ),
//               const SizedBox(height: 8),
//               _settingsTile(
//                 context,
//                 icon: Icons.people,
//                 title: 'View Registered Users & Pets',
//                 onTap: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => const RegisteredUsersPetPage(),
//                     ),
//                   );
//                 },
//               ),
//               // _sectionHeader('Dashboard Customization'),
//               // // const SizedBox(height: 8),
//               // _settingsTile(
//               //   context,
//               //   icon: Icons.palette,
//               //   title: 'Customize Theme',
//               //   onTap: () => _showThemeCustomizationDialog(context),
//               // ),
//               const SizedBox(height: 14),
//               _sectionHeader('Security Settings'),
//               _settingsTile(
//                 context,
//                 icon: Icons.security,
//                 title: 'View Login History',
//                 onTap: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => const LoginHistoryPage(),
//                     ),
//                   );
//                 },
//               ),
//               const SizedBox(height: 8),
//               _settingsTile(
//                 context,
//                 icon: Icons.lock,
//                 title: 'Change Password',
//                 onTap: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => const ChangePasswordAdminPage(),
//                     ),
//                   );
//                 },
//               ),
//               const SizedBox(height: 14),
//               _sectionHeader('Legal and Policies'),
//               _settingsTile(
//                 context,
//                 icon: Icons.description,
//                 title: 'Terms & Conditions',
//                 onTap: () => _showTermsAndConditionsDialog(context),
//               ),
//               const SizedBox(height: 8),
//               _settingsTile(
//                 context,
//                 icon: Icons.privacy_tip,
//                 title: 'Privacy Policy',
//                 onTap: () => _showPrivacyPolicyDialog(context),
//               ),
//               const SizedBox(height: 14),
//               _settingsTile(
//                 context,
//                 icon: Icons.logout,
//                 title: 'Logout',
//                 titleColor: Colors.red,
//                 iconColor: Colors.red,
//                 onTap: () => _showLogoutDialog(context),
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
//           selectedItemColor: _selectedThemeColor,
//           unselectedItemColor: Colors.grey,
//           onTap: (index) {
//             if (index == _selectedIndex) return;
//             switch (index) {
//               case 0:
//                 Navigator.pushReplacement(
//                   context,
//                   MaterialPageRoute(builder: (context) => const HomeAdminPage()),
//                 );
//                 break;
//               case 1:
//                 Navigator.pushReplacement(
//                   context,
//                   MaterialPageRoute(builder: (context) => const BookingsAdminPage()),
//                 );
//                 break;
//               // case 2:
//               //   Navigator.pushReplacement(
//               //     context,
//               //     MaterialPageRoute(builder: (context) => const ShopAdminPage()),
//               //   );
//               //   break;
//               case 2:
//                 Navigator.pushReplacement(
//                   context,
//                   MaterialPageRoute(builder: (context) => const MessagesAdminPage()),
//                 );
//                 break;
//               case 3:
//               // settings_admin page
//                 break;
//             }
//           },
//           type: BottomNavigationBarType.fixed,
//           backgroundColor: Colors.white,
//         ),
//       ),
//     );
//   }

//   Widget _sectionHeader(String title) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 8),
//       child: Text(
//         title,
//         style: GoogleFonts.poppins(
//           fontSize: 16,
//           fontWeight: FontWeight.bold,
//           color: _selectedThemeColor,
//         ),
//       ),
//     );
//   }

//   Widget _settingsTile(
//     BuildContext context, {
//     required IconData icon,
//     required String title,
//     String? subtitle,
//     Color? titleColor,
//     Color? iconColor,
//     VoidCallback? onTap,
//     Widget? trailing,
//   }) {
//     final isLogout = titleColor == Colors.red;
//     return Container(
//       margin: const EdgeInsets.symmetric(vertical: 1),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(14),
//         border: Border.all(color: isLogout ? Colors.red : _selectedThemeColor, width: 1),
//         boxShadow: [
//           BoxShadow(
//             color: _selectedThemeColor.withOpacity(0.06),
//             blurRadius: 6,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: ListTile(
//         leading: Icon(icon, color: iconColor ?? _selectedThemeColor),
//         title: Text(
//           title,
//           style: GoogleFonts.poppins(
//             fontSize: 14,
//             color: titleColor ?? Colors.black,
//           ),
//         ),
//         subtitle: subtitle != null
//             ? Text(
//                 subtitle,
//                 style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey[700]),
//               )
//             : null,
//         onTap: onTap,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
//         contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
//         trailing: trailing ?? Icon(Icons.arrow_forward_ios, size: 13, color: Colors.grey[400]),
//       ),
//     );
//   }

//   void _showThemeCustomizationDialog(BuildContext context) {
//     final List<Color> themeColors = [
//       const Color(0xFFF9943B),
//       const Color(0xFFE6B800),
//       const Color(0xFFFF0000),
//       const Color(0xFFFF9999),
//       const Color(0xFF7A0000),
//     ];

//     showDialog(
//       context: context,
//       builder: (context) => Dialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//         child: Container(
//           padding: const EdgeInsets.all(20),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(20),
//           ),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Text(
//                 'Choose a Theme Color',
//                 style: GoogleFonts.poppins(
//                   fontSize: 20,
//                   fontWeight: FontWeight.bold,
//                   color: _selectedThemeColor,
//                 ),
//               ),
//               const SizedBox(height: 20),
//               Wrap(
//                 spacing: 12,
//                 runSpacing: 12,
//                 children: themeColors.map((color) {
//                   return GestureDetector(
//                     onTap: () {
//                       setState(() {
//                         _selectedThemeColor = color;
//                       });
//                       Navigator.pop(context);
//                     },
//                     child: Container(
//                       width: 50,
//                       height: 50,
//                       decoration: BoxDecoration(
//                         color: color,
//                         shape: BoxShape.circle,
//                         border: Border.all(
//                           color: _selectedThemeColor == color ? Colors.black : Colors.transparent,
//                           width: 2,
//                         ),
//                       ),
//                     ),
//                   );
//                 }).toList(),
//               ),
//               const SizedBox(height: 20),
//               TextButton(
//                 onPressed: () => Navigator.pop(context),
//                 child: Text(
//                   'Close',
//                   style: GoogleFonts.poppins(color: Colors.black),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'home_admin.dart';
import 'bookings_admin.dart';
import 'messages_admin.dart';
import 'export.dart';
import 'registered_users_pet.dart';
import 'login_history.dart';
import 'change_password_admin.dart';

class SettingsAdminPage extends StatefulWidget {
  const SettingsAdminPage({Key? key}) : super(key: key);

  @override
State<SettingsAdminPage> createState() => _SettingsAdminPageState();
}

class _SettingsAdminPageState extends State<SettingsAdminPage> {
  Map<String, dynamic>? _adminProfile;
  bool _isLoading = true;
  String? _profileImageUrl;
  final ImagePicker _picker = ImagePicker();
  Color _selectedThemeColor = const Color(0xFFF5A623);
  int _selectedIndex = 3;
  final lightOrange = const Color(0xFFFFF6E7);

  @override
  void initState() {
    super.initState();
    _loadAdminProfile();
  }

  Future<void> _loadAdminProfile() async {
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;
      if (user != null) {
        final response = await supabase
            .from('users')
            .select('full_name, email, contact_number, profile_image_url')
            .eq('id', user.id)
            .maybeSingle();
        setState(() {
          _adminProfile = response;
          _profileImageUrl = response?['profile_image_url'];
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading admin profile: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshProfile() async {
    setState(() => _isLoading = true);
    await _loadAdminProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: _selectedThemeColor,
          ),
        ),
        backgroundColor: lightOrange,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        automaticallyImplyLeading: false,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [lightOrange, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: _refreshProfile,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Admin Profile Section
                if (_isLoading)
                  const Center(child: CircularProgressIndicator(color: Colors.orange))
                else
                  _buildProfileCard(),
                const SizedBox(height: 16),
                _sectionHeader('Data Management'),
                _settingsTile(
                  context,
                  icon: Icons.picture_as_pdf,
                  title: 'Export Booking Data as PDF',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ExportPage()),
                  ),
                ),
                const SizedBox(height: 8),
                _settingsTile(
                  context,
                  icon: Icons.people,
                  title: 'View Registered Users & Pets',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const RegisteredUsersPetPage()),
                  ),
                ),
                const SizedBox(height: 16),
                _sectionHeader('Security Settings'),
                _settingsTile(
                  context,
                  icon: Icons.security,
                  title: 'View Login History',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginHistoryPage()),
                  ),
                ),
                const SizedBox(height: 8),
                _settingsTile(
                  context,
                  icon: Icons.lock,
                  title: 'Change Password',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ChangePasswordAdminPage()),
                  ),
                ),
                const SizedBox(height: 16),
                _sectionHeader('Legal and Policies'),
                _settingsTile(
                  context,
                  icon: Icons.description,
                  title: 'Terms & Conditions',
                  onTap: () => _showTermsAndConditionsDialog(context),
                ),
                const SizedBox(height: 8),
                _settingsTile(
                  context,
                  icon: Icons.privacy_tip,
                  title: 'Privacy Policy',
                  onTap: () => _showPrivacyPolicyDialog(context),
                ),
                const SizedBox(height: 16),
                _settingsTile(
                  context,
                  icon: Icons.logout,
                  title: 'Logout',
                  titleColor: Colors.red,
                  iconColor: Colors.red,
                  onTap: () => _showLogoutDialog(context),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildProfileCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Profile Picture
          GestureDetector(
            onTap: _showImagePickerDialog,
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 48,
                  backgroundColor: _selectedThemeColor.withOpacity(0.15),
                  backgroundImage: _profileImageUrl != null
                      ? NetworkImage(_profileImageUrl!)
                      : null,
                  child: _profileImageUrl == null
                      ? Icon(Icons.person, size: 48, color: _selectedThemeColor)
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Admin Name + Edit icon inline
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _adminProfile?['full_name'] ?? 'Admin Name',
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: _selectedThemeColor,
                ),
                textAlign: TextAlign.center,
              ),
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.black87, size: 20),
                tooltip: 'Edit profile',
                onPressed: _showEditProfileDialog,
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Email
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.email, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 6),
              Text(
                _adminProfile?['email'] ?? 'admin@email.com',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          // Contact Number
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.phone, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 6),
              Text(
                _adminProfile?['contact_number'] ?? 'Contact Number',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Admin Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: _selectedThemeColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _selectedThemeColor, width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.admin_panel_settings, size: 16, color: _selectedThemeColor),
                const SizedBox(width: 6),
                Text(
                  'Administrator',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _selectedThemeColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: _selectedThemeColor,
        ),
      ),
    );
  }

  Widget _settingsTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    Color? titleColor,
    Color? iconColor,
    VoidCallback? onTap,
    Widget? trailing,
  }) {
    final isLogout = titleColor == Colors.red;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isLogout ? Colors.red : _selectedThemeColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: _selectedThemeColor.withOpacity(0.06),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Icon(icon, color: iconColor ?? _selectedThemeColor),
        title: Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: titleColor ?? Colors.black,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey[700]),
              )
            : null,
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        trailing: trailing ?? Icon(Icons.arrow_forward_ios, size: 13, color: Colors.grey[400]),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
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
        selectedItemColor: _selectedThemeColor,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          if (index == _selectedIndex) return;
          setState(() => _selectedIndex = index);
          switch (index) {
            case 0:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const HomeAdminPage()),
              );
              break;
            case 1:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const BookingsAdminPage()),
              );
              break;
            case 2:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const MessagesAdminPage()),
              );
              break;
            case 3:
              // Already on settings page
              break;
          }
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red, size: 48),
            const SizedBox(height: 12),
            Text('Logout',
                style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87)),
            const SizedBox(height: 8),
            Text('Are you sure you want to log out of your account?',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(fontSize: 15, color: Colors.black54)),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.black),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Text('Cancel', style: GoogleFonts.poppins(color: Colors.black)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
                    },
                    style: ElevatedButton.styleFrom(
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Text('Logout', style: GoogleFonts.poppins(color: Colors.red)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showTermsAndConditionsDialog(BuildContext context) {
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
                    Icon(Icons.description, size: 48, color: _selectedThemeColor),
                    const SizedBox(height: 12),
                    Text(
                      'Terms and Conditions',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: _selectedThemeColor,
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

  Widget _buildTermsSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 15,
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

  void _showPrivacyPolicyDialog(BuildContext context) {
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
                    Icon(Icons.privacy_tip, size: 48, color: _selectedThemeColor),
                    const SizedBox(height: 12),
                    Text(
                      'Privacy Policy',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: _selectedThemeColor,
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
                        '• Personal Info: Full name, email, phone number, etc.\n• Pet Info: Pet name, breed, age, services booked, etc.',
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
                        'You can view and update your information anytime through your profile. If you want to delete your account, just let us know.',
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

  Widget _buildPrivacySection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 15,
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

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );

      if (image != null) {
        await _uploadProfileImage(File(image.path));
      }
    } catch (e) {
      print('Error picking image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error selecting image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _uploadProfileImage(File imageFile) async {
    try {
      setState(() => _isLoading = true);

      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;
      if (user == null) return;
      final fileName = 'profile_${user.id}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final response = await supabase.storage
          .from('profile-images')
          .upload(fileName, imageFile);
      if (response.isNotEmpty) {
        final imageUrl = supabase.storage
            .from('profile-images')
            .getPublicUrl(fileName);
        await supabase
            .from('users')
            .update({'profile_image_url': imageUrl})
            .eq('id', user.id);
        setState(() {
          _profileImageUrl = imageUrl;
          _isLoading = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Profile picture updated successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      print('Error uploading image: $e');
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error uploading image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showImagePickerDialog() {
    final hasProfilePicture = _profileImageUrl != null && _profileImageUrl!.isNotEmpty;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.7,
            maxWidth: MediaQuery.of(context).size.width * 0.9,
          ),
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
                    Icon(Icons.person, size: 48, color: _selectedThemeColor),
                    const SizedBox(height: 12),
                    Text(
                      hasProfilePicture ? 'Profile Picture' : 'Select Profile Picture',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: _selectedThemeColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: hasProfilePicture
                      ? Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: double.infinity,
                              height: 180,
                              decoration: BoxDecoration(
                                color: lightOrange,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: _selectedThemeColor.withOpacity(0.3), width: 2),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(14),
                                child: Image.network(
                                  _profileImageUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.person, size: 64, color: _selectedThemeColor),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Profile Picture',
                                            style: GoogleFonts.poppins(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: _selectedThemeColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.pop(context);
                                  _pickImage(ImageSource.gallery);
                                },
                                icon: Icon(Icons.photo_library, color: Colors.white),
                                label: Text(
                                  'Select another from Gallery',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _selectedThemeColor,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                ),
                              ),
                            ),
                          ],
                        )
                      : Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.pop(context);
                                  _pickImage(ImageSource.gallery);
                                },
                                icon: Icon(Icons.photo_library, color: Colors.white),
                                label: Text(
                                  'Select from Gallery',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _selectedThemeColor,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                ),
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditProfileDialog() {
    final nameController = TextEditingController(text: _adminProfile?['full_name'] ?? '');
    final emailController = TextEditingController(text: _adminProfile?['email'] ?? '');
    final contactController = TextEditingController(text: _adminProfile?['contact_number'] ?? '');
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: StatefulBuilder(
            builder: (context, setLocal) {
              return Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Update Information',
                        style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: _showImagePickerDialog,
                      child: CircleAvatar(
                        radius: 40,
                        backgroundColor: _selectedThemeColor.withOpacity(0.15),
                        backgroundImage: _profileImageUrl != null ? NetworkImage(_profileImageUrl!) : null,
                        child: _profileImageUrl == null ? Icon(Icons.person, size: 40, color: _selectedThemeColor) : null,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _iconInputRow(icon: Icons.person, controller: nameController, hint: 'Full name'),
                    const SizedBox(height: 10),
                    _iconInputRow(icon: Icons.email, controller: emailController, hint: 'Email'),
                    const SizedBox(height: 10),
                    _iconInputRow(icon: Icons.phone, controller: contactController, hint: 'Contact number'),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.sync),
                        label: Text('Update', style: GoogleFonts.poppins()),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _selectedThemeColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: () async {
                          final supabase = Supabase.instance.client;
                          final user = supabase.auth.currentUser;
                          if (user == null) return;
                          try {
                            await supabase
                                .from('users')
                                .update({
                                  'full_name': nameController.text.trim(),
                                  'email': emailController.text.trim(),
                                  'contact_number': contactController.text.trim(),
                                })
                                .eq('id', user.id);
                            if (mounted) {
                              setState(() {
                                _adminProfile = {
                                  ...?_adminProfile,
                                  'full_name': nameController.text.trim(),
                                  'email': emailController.text.trim(),
                                  'contact_number': contactController.text.trim(),
                                };
                              });
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Profile updated'), backgroundColor: Colors.green),
                              );
                            }
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Update failed: $e'), backgroundColor: Colors.red),
                              );
                            }
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Text('Close', style: GoogleFonts.poppins(color: Colors.black)),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _iconInputRow({required IconData icon, required TextEditingController controller, required String hint}) {
    return Container(
      decoration: BoxDecoration(
        color: _selectedThemeColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const SizedBox(width: 8),
          Icon(icon, color: _selectedThemeColor),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: hint,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
