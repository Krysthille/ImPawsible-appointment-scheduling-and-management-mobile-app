// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'services/auth_service.dart';
// import 'utils/network_utils.dart';
// import '../config/supabase_config.dart';

// class SignupPage extends StatefulWidget {
//   const SignupPage({super.key});

//   @override
//   State<SignupPage> createState() => _SignupPageState();
// }

// class _SignupPageState extends State<SignupPage> {
//   final orange = const Color(0xFFF5A623);
//   final nameController = TextEditingController();
//   final emailController = TextEditingController();
//   final contactController = TextEditingController();
//   final passwordController = TextEditingController();
//   final confirmPasswordController = TextEditingController();
//   bool _obscurePassword = true;
//   bool _obscureConfirmPassword = true;
//   bool _isLoading = false;
//   AuthService? _authService;
  
//   // Password strength indicators
//   bool _hasMinLength = false;
//   bool _hasUppercase = false;
//   bool _hasLowercase = false;
//   bool _hasNumber = false;
//   bool _hasSpecialChar = false;

//   Future<void> _handleSignUp() async {
//     final name = nameController.text.trim();
//     final email = emailController.text.trim();
//     final contact = contactController.text.trim();
//     final password = passwordController.text;
//     final confirmPassword = confirmPasswordController.text;

//     // Check for internet connection FIRST
//     final networkUtils = NetworkUtils();
//     final hasInternet = await networkUtils.hasInternetConnection();

//     if (!hasInternet) {
//       if (!mounted) return;
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(
//             'No internet connection. Please check your network settings and try again.',
//             style: GoogleFonts.poppins(),
//           ),
//           backgroundColor: Colors.red,
//           duration: const Duration(seconds: 3),
//         ),
//       );
//       return;
//     }

//     // Validation - only check fields if online
//     if (name.isEmpty ||
//         email.isEmpty ||
//         contact.isEmpty ||
//         password.isEmpty ||
//         confirmPassword.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(
//             'Please fill in all fields.',
//             style: GoogleFonts.poppins(),
//           ),
//           backgroundColor: Colors.red,
//         ),
//       );
//       return;
//     }

//     // Check password requirements - only if online
//     if (!_isPasswordValid()) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(
//             'Please ensure your password meets all requirements.',
//             style: GoogleFonts.poppins(),
//           ),
//           backgroundColor: Colors.red,
//         ),
//       );
//       return;
//     }

//     if (password != confirmPassword) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(
//             'Passwords do not match.',
//             style: GoogleFonts.poppins(),
//           ),
//           backgroundColor: Colors.red,
//         ),
//       );
//       return;
//     }

//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       // If Supabase is not initialized, try initializing it
//       if (!SupabaseConfig.isInitialized) {
//         try {
//           await SupabaseConfig.initialize();
//         } catch (e) {
//           // Handle potential re-initialization errors
//           if (!mounted) return;
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text(
//                 'Failed to connect to the backend. Please check your internet connection.',
//               ),
//               backgroundColor: Colors.red,
//             ),
//           );
//           setState(() {
//             _isLoading = false;
//           });
//           return; // Stop if re-initialization fails
//         }
//       }

//       // Initialize AuthService only if online and Supabase is initialized
//       _authService ??= AuthService();

//       // Now perform checks that require internet/Supabase
//       final emailExists = await _authService!.isEmailExists(email);
//       final contactExists = await _authService!.isContactExists(contact);

//       if (emailExists && contactExists) {
//         if (!mounted) return;
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(
//               'This email and contact number are already registered. Please sign in or use a different email and contact number to register.',
//               style: GoogleFonts.poppins(),
//             ),
//             backgroundColor: Colors.red,
//           ),
//         );
//         return;
//       }

//       // Check if only email exists
//       if (emailExists) {
//         if (!mounted) return;
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(
//               'This email is already registered. Please sign in or use a different email to register.',
//               style: GoogleFonts.poppins(),
//             ),
//             backgroundColor: Colors.red,
//           ),
//         );
//         return;
//       }

//       // Check if only contact number exists
//       if (contactExists) {
//         if (!mounted) return;
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(
//               'This contact number is already registered. Please sign in or use a different contact number to register.',
//               style: GoogleFonts.poppins(),
//             ),
//             backgroundColor: Colors.red,
//           ),
//         );
//         return;
//       }

//       final response = await _authService!.signUp(
//         email: email,
//         password: password,
//         fullName: name,
//         contactNumber: contact,
//       );

//       if (response.user != null) {
//         if (!mounted) return;

//         // Show success message
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(
//               'Account created successfully! Please check your email for verification.',
//               style: GoogleFonts.poppins(),
//             ),
//             backgroundColor: Colors.green,
//             duration: const Duration(seconds: 3),
//           ),
//         );

//         // Wait a moment before navigating
//         await Future.delayed(const Duration(seconds: 3));

//         if (!mounted) return;
//         Navigator.pushNamedAndRemoveUntil(
//           context,
//           '/login',
//           (route) => false,
//         );
//       }
//     } catch (e) {
//       if (!mounted) return;
//       String errorMessage = e.toString().replaceAll('Exception: ', '');

//       if (errorMessage.contains('Backend service is unavailable')) {
//         errorMessage =
//             'No internet connection. Please check your network settings and try again.';
//       }

//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(
//             errorMessage,
//             style: GoogleFonts.poppins(),
//           ),
//           backgroundColor: Colors.red,
//           duration: const Duration(seconds: 3),
//         ),
//       );
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isLoading = false;
//         });
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         backgroundColor: Colors.white,
//         appBar: AppBar(
//           backgroundColor: Colors.white,
//           elevation: 0,
//           leading: IconButton(
//             icon: Icon(Icons.arrow_back, color: orange),
//             onPressed: () => Navigator.pop(context),
//           ),
//           title: Text('Sign Up',
//               style: GoogleFonts.poppins(
//                   color: orange, fontWeight: FontWeight.w600)),
//           centerTitle: false,
//         ),
//       body: GestureDetector(
//         onTap: () {
//           // Dismiss keyboard when tapping outside input fields
//           FocusScope.of(context).unfocus();
//         },
//         child: SingleChildScrollView(
//           child: Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 24.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 const SizedBox(height: 12),
//                 Center(
//                   child: Image.asset(
//                     'assets/images/logo1.png',
//                     height: 130,
//                     fit: BoxFit.contain,
//                   ),
//                 ),
//                 const SizedBox(height: 24),
//                 Text(
//                   'Create Account',
//                   style: GoogleFonts.poppins(
//                     fontSize: 24,
//                     fontWeight: FontWeight.bold,
//                     color: orange,
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   'Sign up to get started',
//                   style: GoogleFonts.poppins(
//                     fontSize: 15,
//                     color: Colors.grey[500],
//                   ),
//                 ),
//                 const SizedBox(height: 32),
//                 // Full Name
//                 TextField(
//                   controller: nameController,
//                   decoration: InputDecoration(
//                     prefixIcon: Icon(Icons.person, color: orange),
//                     labelText: 'Full Name',
//                     labelStyle: GoogleFonts.poppins(color: Colors.grey[600]),
//                     enabledBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                       borderSide: BorderSide(color: orange, width: 1.5),
//                     ),
//                     focusedBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                       borderSide: BorderSide(color: orange, width: 2),
//                     ),
//                     contentPadding:
//                         const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 // Email
//                 TextField(
//                   controller: emailController,
//                   decoration: InputDecoration(
//                     prefixIcon: Icon(Icons.mail_outline, color: orange),
//                     labelText: 'Email',
//                     labelStyle: GoogleFonts.poppins(color: Colors.grey[600]),
//                     enabledBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                       borderSide: BorderSide(color: orange, width: 1.5),
//                     ),
//                     focusedBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                       borderSide: BorderSide(color: orange, width: 2),
//                     ),
//                     contentPadding:
//                         const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 // Contact Number
//                 TextField(
//                   controller: contactController,
//                   decoration: InputDecoration(
//                     prefixIcon: Icon(Icons.phone, color: orange),
//                     labelText: 'Contact Number',
//                     labelStyle: GoogleFonts.poppins(color: Colors.grey[600]),
//                     enabledBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                       borderSide: BorderSide(color: orange, width: 1.5),
//                     ),
//                     focusedBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                       borderSide: BorderSide(color: orange, width: 2),
//                     ),
//                     contentPadding:
//                         const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 // Password
//                 TextField(
//                   controller: passwordController,
//                   obscureText: _obscurePassword,
//                   decoration: InputDecoration(
//                     prefixIcon: Icon(Icons.lock_outline, color: orange),
//                     labelText: 'Password',
//                     labelStyle: GoogleFonts.poppins(color: Colors.grey[600]),
//                     enabledBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                       borderSide: BorderSide(color: orange, width: 1.5),
//                     ),
//                     focusedBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                       borderSide: BorderSide(color: orange, width: 2),
//                     ),
//                     contentPadding:
//                         const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
//                     suffixIcon: IconButton(
//                       icon: Icon(
//                         _obscurePassword
//                             ? Icons.visibility_off
//                             : Icons.visibility,
//                         color: orange,
//                       ),
//                       onPressed: () {
//                         setState(() {
//                           _obscurePassword = !_obscurePassword;
//                         });
//                       },
//                     ),
//                   ),
//                   onChanged: _checkPasswordStrength,
//                 ),
//                 // Password Strength Indicators
//                 const SizedBox(height: 12),
//                 Container(
//                   padding: const EdgeInsets.all(12),
//                   decoration: BoxDecoration(
//                     color: Colors.grey[50],
//                     borderRadius: BorderRadius.circular(8),
//                     border: Border.all(color: Colors.grey[200]!),
//                   ),
                  
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'Password Requirements:',
//                         style: GoogleFonts.poppins(
//                           fontSize: 12,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.black87,
//                         ),
//                       ),
//                       const SizedBox(height: 8),
//                       _buildRequirementRow('Minimum 8 characters', _hasMinLength),
//                       _buildRequirementRow('At least 1 uppercase letter', _hasUppercase),
//                       _buildRequirementRow('At least 1 lowercase letter', _hasLowercase),
//                       _buildRequirementRow('At least 1 number', _hasNumber),
//                       _buildRequirementRow('At least 1 special character [e.g. !@#%^&*(),.?":{}|<> ]', _hasSpecialChar),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 // Confirm Password
//                 TextField(
//                   controller: confirmPasswordController,
//                   obscureText: _obscureConfirmPassword,
//                   decoration: InputDecoration(
//                     prefixIcon: Icon(Icons.lock_outline, color: orange),
//                     labelText: 'Confirm Password',
//                     labelStyle: GoogleFonts.poppins(color: Colors.grey[600]),
//                     enabledBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                       borderSide: BorderSide(color: orange, width: 1.5),
//                     ),
//                     focusedBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                       borderSide: BorderSide(color: orange, width: 2),
//                     ),
//                     contentPadding:
//                         const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
//                     suffixIcon: IconButton(
//                       icon: Icon(
//                         _obscureConfirmPassword
//                             ? Icons.visibility_off
//                             : Icons.visibility,
//                         color: orange,
//                       ),
//                       onPressed: () {
//                         setState(() {
//                           _obscureConfirmPassword = !_obscureConfirmPassword;
//                         });
//                       },
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 28),
//                 // Sign Up Button
//                 SizedBox(
//                   width: double.infinity,
//                   child: ElevatedButton(
//                     onPressed: _isLoading ? null : _handleSignUp,
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: orange,
//                       padding: const EdgeInsets.symmetric(vertical: 16),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       elevation: 2,
//                     ),
//                     child: _isLoading
//                         ? const SizedBox(
//                             height: 20,
//                             width: 20,
//                             child: CircularProgressIndicator(
//                               color: Colors.white,
//                               strokeWidth: 2,
//                             ),
//                           )
//                         : Row(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             mainAxisSize: MainAxisSize.min,
//                             children: [
//                               Icon(Icons.person, color: Colors.white),
//                               const SizedBox(width: 8),
//                               Text('Sign Up',
//                                   style: GoogleFonts.poppins(
//                                     fontSize: 18,
//                                     color: Colors.white,
//                                     fontWeight: FontWeight.w600,
//                                   )),
//                             ],
//                           ),
//                   ),
//                 ),
//                 const SizedBox(height: 12),
//                 // Terms and Privacy Policy
//                 Column(
//                      mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Text(
//                       'By registering, you agree to our',
//                     style: GoogleFonts.poppins(
//                       fontSize: 11,
//                       color: Colors.black54,
//                       ),
//                     ),
//                     const SizedBox(height: 4),
//                     GestureDetector(
//                       onTap: () => _showTermsAndConditionsDialog(context),
//                       child: Text(
//                         'Terms and Conditions ',
//                         style: GoogleFonts.poppins(
//                           fontSize: 11,
//                           color: orange,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                     ),
//                     Text(
//                       'and',
//                     style: GoogleFonts.poppins(
//                       fontSize: 11,
//                       color: Colors.black54,
//                       ),
//                     ),
//                     GestureDetector(
//                       onTap: () => _showPrivacyPolicyDialog(context),
//                       child: Text(
//                         'Privacy Policy ',
//                         style: GoogleFonts.poppins(
//                           fontSize: 11,
//                           color: orange,
//                           fontWeight: FontWeight.w600,
//                         ),
                        
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 24),
//                 // Login prompt
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Text(
//                       "Already have an account? ",
//                       style: GoogleFonts.poppins(color: Colors.grey[500]),
//                     ),
//                     GestureDetector(
//                       onTap: () {
//                         Navigator.pushNamedAndRemoveUntil(
//                           context,
//                           '/login',
//                           (route) => false,
//                         );
//                       },
//                       child: Text(
//                         'Login',
//                         style: GoogleFonts.poppins(
//                           color: orange,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 24),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   void _checkPasswordStrength(String password) {
//     setState(() {
//       _hasMinLength = password.length >= 8;
//       _hasUppercase = password.contains(RegExp(r'[A-Z]'));
//       _hasLowercase = password.contains(RegExp(r'[a-z]'));
//       _hasNumber = password.contains(RegExp(r'[0-9]'));
//       _hasSpecialChar = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
//     });
//   }

//   bool _isPasswordValid() {
//     return _hasMinLength && _hasUppercase && _hasLowercase && _hasNumber && _hasSpecialChar;
//   }

//   Widget _buildRequirementRow(String text, bool isMet) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 4),
//       child: Row(
//         children: [
//           Icon(
//             isMet ? Icons.check_circle : Icons.circle_outlined,
//             size: 16,
//             color: isMet ? Colors.green : Colors.grey,
//           ),
//           const SizedBox(width: 8),
//           Text(
//             text,
//             style: GoogleFonts.poppins(
//               fontSize: 11,
//               color: isMet ? Colors.green[700] : Colors.grey[600],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showTermsAndConditionsDialog(BuildContext context) {
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
//                         '• Personal Info: Full name, email, phone number\n• Pet Info: Pet name, breed, age, services booked\n• App Usage Data: Time of login, activity logs (for improvement purposes)',
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
//                         'Your data is stored securely in our system. We use encryption and other safety measures to protect your information.',
//                       ),
//                       _buildPrivacySection(
//                         '5. User Control',
//                         'You can view, update, or delete your information anytime through your profile. If you want to delete your account, just let us know.',
//                       ),
//                       _buildPrivacySection(
//                         '6. Children\'s Privacy',
//                         'This app is not intended for users under the age of 16. We do not knowingly collect data from children.',
//                       ),
//                       const SizedBox(height: 16),
//                       Text(
//                         'If you have any questions about these policies, feel free to contact us at impawpetshop@email.com.',
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


// NEW

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'services/auth_service.dart';
import 'utils/network_utils.dart';
import '../config/supabase_config.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final orange = const Color(0xFFF5A623);
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final contactController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  AuthService? _authService;

  // Password strength indicators
  bool _hasMinLength = false;
  bool _hasUppercase = false;
  bool _hasLowercase = false;
  bool _hasNumber = false;
  bool _hasSpecialChar = false;

  Future<void> _handleRefresh() async {
    // Recheck network connection
    final networkUtils = NetworkUtils();
    final hasInternet = await networkUtils.hasInternetConnection();
    if (!hasInternet) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'No internet connection. Please check your network settings and try again.',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Network connection is active.',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _handleSignUp() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final contact = contactController.text.trim();
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;

    // Check for internet connection FIRST
    final networkUtils = NetworkUtils();
    final hasInternet = await networkUtils.hasInternetConnection();
    if (!hasInternet) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'No internet connection. Please check your network settings and try again.',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    // Validation - only check fields if online
    if (name.isEmpty ||
        email.isEmpty ||
        contact.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please fill in all fields.',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Check password requirements - only if online
    if (!_isPasswordValid()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please ensure your password meets all requirements.',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Passwords do not match.',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // If Supabase is not initialized, try initializing it
      if (!SupabaseConfig.isInitialized) {
        try {
          await SupabaseConfig.initialize();
        } catch (e) {
          // Handle potential re-initialization errors
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Failed to connect to the backend. Please check your internet connection.',
              ),
              backgroundColor: Colors.red,
            ),
          );
          setState(() {
            _isLoading = false;
          });
          return;
        }
      }

      // Initialize AuthService only if online and Supabase is initialized
      _authService ??= AuthService();

      // Now perform checks that require internet/Supabase
      final emailExists = await _authService!.isEmailExists(email);
      final contactExists = await _authService!.isContactExists(contact);

      if (emailExists && contactExists) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'This email and contact number are already registered. Please sign in or use a different email and contact number to register.',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Check if only email exists
      if (emailExists) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'This email is already registered. Please sign in or use a different email to register.',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Check if only contact number exists
      if (contactExists) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'This contact number is already registered. Please sign in or use a different contact number to register.',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final response = await _authService!.signUp(
        email: email,
        password: password,
        fullName: name,
        contactNumber: contact,
      );

      if (response.user != null) {
        if (!mounted) return;
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Account created successfully! Please check your email for verification.',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );

        // Wait a moment before navigating
        await Future.delayed(const Duration(seconds: 3));
        if (!mounted) return;
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/login',
          (route) => false,
        );
      }
    } catch (e) {
      if (!mounted) return;
      String errorMessage = e.toString().replaceAll('Exception: ', '');
      if (errorMessage.contains('Backend service is unavailable')) {
        errorMessage =
            'No internet connection. Please check your network settings and try again.';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            errorMessage,
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: orange),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Sign Up',
            style: GoogleFonts.poppins(
                color: orange, fontWeight: FontWeight.w600)),
        centerTitle: false,
      ),
      body: GestureDetector(
        onTap: () {
          // Dismiss keyboard when tapping outside input fields
          FocusScope.of(context).unfocus();
        },
        child: RefreshIndicator(
          color: orange,
          onRefresh: _handleRefresh,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 12),
                  Center(
                    child: Image.asset(
                      'assets/images/logo1.png',
                      height: 130,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Create Account',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: orange,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sign up to get started',
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      color: Colors.grey[500],
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Full Name
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.person, color: orange),
                      labelText: 'Full Name',
                      labelStyle: GoogleFonts.poppins(color: Colors.grey[600]),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: orange, width: 1.5),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: orange, width: 2),
                      ),
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Email
                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.mail_outline, color: orange),
                      labelText: 'Email',
                      labelStyle: GoogleFonts.poppins(color: Colors.grey[600]),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: orange, width: 1.5),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: orange, width: 2),
                      ),
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Contact Number
                  TextField(
                    controller: contactController,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.phone, color: orange),
                      labelText: 'Contact Number',
                      labelStyle: GoogleFonts.poppins(color: Colors.grey[600]),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: orange, width: 1.5),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: orange, width: 2),
                      ),
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Password
                  TextField(
                    controller: passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.lock_outline, color: orange),
                      labelText: 'Password',
                      labelStyle: GoogleFonts.poppins(color: Colors.grey[600]),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: orange, width: 1.5),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: orange, width: 2),
                      ),
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: orange,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                    onChanged: _checkPasswordStrength,
                  ),
                  // Password Strength Indicators
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Password Requirements:',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildRequirementRow('Minimum 8 characters', _hasMinLength),
                        _buildRequirementRow('At least 1 uppercase letter', _hasUppercase),
                        _buildRequirementRow('At least 1 lowercase letter', _hasLowercase),
                        _buildRequirementRow('At least 1 number', _hasNumber),
                        _buildRequirementRow('At least 1 special character [e.g. !@#%^&*(),.?":{}|<> ]', _hasSpecialChar),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Confirm Password
                  TextField(
                    controller: confirmPasswordController,
                    obscureText: _obscureConfirmPassword,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.lock_outline, color: orange),
                      labelText: 'Confirm Password',
                      labelStyle: GoogleFonts.poppins(color: Colors.grey[600]),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: orange, width: 1.5),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: orange, width: 2),
                      ),
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: orange,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureConfirmPassword = !_obscureConfirmPassword;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  // Sign Up Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleSignUp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: orange,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.person, color: Colors.white),
                                const SizedBox(width: 8),
                                Text('Sign Up',
                                    style: GoogleFonts.poppins(
                                      fontSize: 18,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    )),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Terms and Privacy Policy
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'By registering, you agree to our',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 4),
                      GestureDetector(
                        onTap: () => _showTermsAndConditionsDialog(context),
                        child: Text(
                          'Terms and Conditions ',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: orange,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Text(
                        'and',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: Colors.black54,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _showPrivacyPolicyDialog(context),
                        child: Text(
                          'Privacy Policy ',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: orange,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Login prompt
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Already have an account? ",
                        style: GoogleFonts.poppins(color: Colors.grey[500]),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            '/login',
                            (route) => false,
                          );
                        },
                        child: Text(
                          'Login',
                          style: GoogleFonts.poppins(
                            color: orange,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _checkPasswordStrength(String password) {
    setState(() {
      _hasMinLength = password.length >= 8;
      _hasUppercase = password.contains(RegExp(r'[A-Z]'));
      _hasLowercase = password.contains(RegExp(r'[a-z]'));
      _hasNumber = password.contains(RegExp(r'[0-9]'));
      _hasSpecialChar = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    });
  }

  bool _isPasswordValid() {
    return _hasMinLength && _hasUppercase && _hasLowercase && _hasNumber && _hasSpecialChar;
  }

  Widget _buildRequirementRow(String text, bool isMet) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(
            isMet ? Icons.check_circle : Icons.circle_outlined,
            size: 16,
            color: isMet ? Colors.green : Colors.grey,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: isMet ? Colors.green[700] : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  void _showTermsAndConditionsDialog(BuildContext context) {
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
                        '• Personal Info: Full name, email, phone number\n• Pet Info: Pet name, breed, age, services booked\n• App Usage Data: Time of login, activity logs (for improvement purposes)',
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
                        'Your data is stored securely in our system. We use encryption and other safety measures to protect your information.',
                      ),
                      _buildPrivacySection(
                        '5. User Control',
                        'You can view, update, or delete your information anytime through your profile. If you want to delete your account, just let us know.',
                      ),
                      _buildPrivacySection(
                        '6. Children\'s Privacy',
                        'This app is not intended for users under the age of 16. We do not knowingly collect data from children.',
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'If you have any questions about these policies, feel free to contact us at impawpetshop@email.com.',
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
