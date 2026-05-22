// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import '../services/auth_service.dart';

// class ChangePasswordPage extends StatefulWidget {
//   const ChangePasswordPage({super.key});

//   @override
//   State<ChangePasswordPage> createState() => _ChangePasswordPageState();
// }

// class _ChangePasswordPageState extends State<ChangePasswordPage> {
//   final _emailController = TextEditingController();
//   final _phoneController = TextEditingController();
//   final _currentPasswordController = TextEditingController();
//   final _newPasswordController = TextEditingController();
//   final _confirmPasswordController = TextEditingController();
//   bool _isLoading = false;
//   bool _credentialsValidated = false;
//   bool _obscureCurrentPassword = true;
//   bool _obscureNewPassword = true;
//   bool _obscureConfirmPassword = true;
//   String? _userId;
//   late final AuthService _authService = AuthService();
  
//   // Password strength indicators
//   bool _hasMinLength = false;
//   bool _hasUppercase = false;
//   bool _hasLowercase = false;
//   bool _hasNumber = false;
//   bool _hasSpecialChar = false;
//   bool _isDifferentFromCurrent = false;

//   @override
//   void dispose() {
//     _emailController.dispose();
//     _phoneController.dispose();
//     _currentPasswordController.dispose();
//     _newPasswordController.dispose();
//     _confirmPasswordController.dispose();
//     super.dispose();
//   }

//   void _showSnackBar(String message, {bool isError = false}) {
//     if (!mounted) return;
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message, style: GoogleFonts.poppins()),
//         backgroundColor: isError ? Colors.red : Colors.green,
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
//       _isDifferentFromCurrent = password != _currentPasswordController.text;
//     });
//   }

//   bool _isPasswordValid() {
//     return _hasMinLength && _hasUppercase && _hasLowercase && _hasNumber && _hasSpecialChar && _isDifferentFromCurrent;
//   }

//   Future<void> _validateCredentials() async {
//     setState(() { _isLoading = true; });
//     final email = _emailController.text.trim();
//     final phone = _phoneController.text.trim();
//     if (email.isEmpty || phone.isEmpty) {
//       _showSnackBar('Please enter both email and contact number.', isError: true);
//       setState(() { _isLoading = false; });
//       return;
//     }
    
//     try {
//       final userData = await _authService.getUserForPasswordReset(email: email, phoneNumber: phone);
//       if (userData != null) {
//         final isValid = await _authService.verifyEmailAndPhone(email: email, phoneNumber: phone);
//         if (isValid) {
//           setState(() { 
//             _credentialsValidated = true;
//             _userId = userData['id'];
//           });
//           _showSnackBar('Credentials validated successfully!');
//         } else {
//           _showSnackBar('Invalid email or contact number.', isError: true);
//         }
//       } else {
//         _showSnackBar('Invalid email or contact number.', isError: true);
//       }
//     } catch (e) {
//       _showSnackBar('Error validating credentials. Please try again.', isError: true);
//     }
//     setState(() { _isLoading = false; });
//   }

//   Future<void> _changePassword() async {
//     // Validate password requirements
//     if (!_isPasswordValid()) {
//       _showSnackBar('Please ensure your new password meets all requirements.', isError: true);
//       return;
//     }

//     // Check if passwords match
//     if (_newPasswordController.text != _confirmPasswordController.text) {
//       _showSnackBar('Passwords do not match.', isError: true);
//       return;
//     }

//     // Check if current password is provided
//     if (_currentPasswordController.text.isEmpty) {
//       _showSnackBar('Please enter your current password.', isError: true);
//       return;
//     }

//     setState(() => _isLoading = true);

//     try {
//       final supabase = Supabase.instance.client;
//       final user = supabase.auth.currentUser;

//       if (user == null) {
//         throw Exception('User not authenticated');
//       }

//       // Update password using Supabase Auth
//       await supabase.auth.updateUser(
//         UserAttributes(
//           password: _newPasswordController.text,
//         ),
//       );

//       if (mounted) {
//         _showSnackBar('Password changed successfully!');
//         Navigator.pop(context);
//       }
//     } catch (e) {
//       print('Error changing password: $e');
//       if (mounted) {
//         String errorMessage = 'Failed to change password';
//         if (e.toString().contains('Invalid login credentials')) {
//           errorMessage = 'Current password is incorrect';
//         } else if (e.toString().contains('Password should be at least')) {
//           errorMessage = 'Password should be at least 8 characters long';
//         }
        
//         _showSnackBar(errorMessage, isError: true);
//       }
//     } finally {
//       if (mounted) {
//         setState(() => _isLoading = false);
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     const orange = Color(0xFFF5A623);

//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         leading: BackButton(color: orange),
//         title: Text('Change Password', style: GoogleFonts.poppins(color: orange, fontWeight: FontWeight.w600)),
//       ),
//       body: GestureDetector(
//         onTap: () {
//           // Dismiss keyboard when tapping outside input fields
//           FocusScope.of(context).unfocus();
//         },
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.symmetric(horizontal: 24.0),
//           child: Column(
//             children: [
//               const SizedBox(height: 40),
//               Image.asset('assets/images/logo1.png', height: 100),
//               const SizedBox(height: 32),
//               Text('Change Password', style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: orange)),
//               const SizedBox(height: 8),
//               Text('Step 1: Validate your credentials', style: GoogleFonts.poppins(color: Colors.grey[500])),
//               const SizedBox(height: 24),
//               // Email Field
//               TextField(
//                 controller: _emailController,
//                 enabled: !_credentialsValidated,
//                 decoration: InputDecoration(
//                   prefixIcon: Icon(Icons.mail_outline, color: orange),
//                   labelText: 'Email',
//                   labelStyle: GoogleFonts.poppins(color: Colors.grey[600]),
//                   enabledBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                     borderSide: BorderSide(color: orange, width: 1.5),
//                   ),
//                   focusedBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                     borderSide: BorderSide(color: orange, width: 2),
//                   ),
//                   disabledBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                     borderSide: BorderSide(color: Colors.grey[400]!, width: 1.5),
//                   ),
//                   contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
//                   filled: _credentialsValidated,
//                   fillColor: _credentialsValidated ? Colors.grey[100]! : null,
//                 ),
//               ),
//               const SizedBox(height: 16),
//               // Contact Number Field
//               TextField(
//                 controller: _phoneController,
//                 enabled: !_credentialsValidated,
//                 decoration: InputDecoration(
//                   prefixIcon: Icon(Icons.phone_outlined, color: orange),
//                   labelText: 'Contact Number',
//                   labelStyle: GoogleFonts.poppins(color: Colors.grey[600]),
//                   enabledBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                     borderSide: BorderSide(color: orange, width: 1.5),
//                   ),
//                   focusedBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                     borderSide: BorderSide(color: orange, width: 2),
//                   ),
//                   disabledBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                     borderSide: BorderSide(color: Colors.grey[400]!, width: 1.5),
//                   ),
//                   contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
//                   filled: _credentialsValidated,
//                   fillColor: _credentialsValidated ? Colors.grey[100]! : null,
//                 ),
//               ),
//               const SizedBox(height: 16),
//               // Validate Credentials Button
//               if (!_credentialsValidated)
//                 SizedBox(
//                   width: double.infinity,
//                   child: ElevatedButton(
//                     onPressed: _isLoading ? null : _validateCredentials,
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: orange,
//                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                     ),
//                     child: _isLoading
//                         ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
//                         : Text('Validate Credentials', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
//                   ),
//                 ),
//               // Success Message
//               if (_credentialsValidated) ...[
//                 const SizedBox(height: 16),
//                 Container(
//                   padding: const EdgeInsets.all(12),
//                   decoration: BoxDecoration(
//                     color: Colors.green[50],
//                     borderRadius: BorderRadius.circular(8),
//                     border: Border.all(color: Colors.green[200]!),
//                   ),
//                   child: Row(
//                     children: [
//                       Icon(Icons.check_circle, color: Colors.green[600], size: 20),
//                       const SizedBox(width: 8),
//                       Expanded(
//                         child: Text(
//                           'Credentials validated successfully!',
//                           style: GoogleFonts.poppins(
//                             color: Colors.green[700],
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//               // Password Change Section
//               if (_credentialsValidated) ...[
//                 const SizedBox(height: 24),
//                 Text('Step 2: Enter your current and new password', style: GoogleFonts.poppins(color: Colors.grey[500])),
//                 const SizedBox(height: 16),
//                 // Current Password Field
//                 TextField(
//                   controller: _currentPasswordController,
//                   obscureText: _obscureCurrentPassword,
//                   decoration: InputDecoration(
//                     prefixIcon: Icon(Icons.lock, color: orange),
//                     labelText: 'Current Password',
//                     labelStyle: GoogleFonts.poppins(color: Colors.grey[600]),
//                     enabledBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                       borderSide: BorderSide(color: orange, width: 1.5),
//                     ),
//                     focusedBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                       borderSide: BorderSide(color: orange, width: 2),
//                     ),
//                     contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
//                     suffixIcon: IconButton(
//                       icon: Icon(_obscureCurrentPassword ? Icons.visibility_off : Icons.visibility, color: orange),
//                       onPressed: () => setState(() => _obscureCurrentPassword = !_obscureCurrentPassword),
//                     ),
//                   ),
//                   onChanged: (value) {
//                     _checkPasswordStrength(_newPasswordController.text);
//                   },
//                 ),
//                 const SizedBox(height: 16),
//                 // New Password Field
//                 TextField(
//                   controller: _newPasswordController,
//                   obscureText: _obscureNewPassword,
//                   decoration: InputDecoration(
//                     prefixIcon: Icon(Icons.lock_outline, color: orange),
//                     labelText: 'New Password',
//                     labelStyle: GoogleFonts.poppins(color: Colors.grey[600]),
//                     enabledBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                       borderSide: BorderSide(color: orange, width: 1.5),
//                     ),
//                     focusedBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                       borderSide: BorderSide(color: orange, width: 2),
//                     ),
//                     contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
//                     suffixIcon: IconButton(
//                       icon: Icon(_obscureNewPassword ? Icons.visibility_off : Icons.visibility, color: orange),
//                       onPressed: () => setState(() => _obscureNewPassword = !_obscureNewPassword),
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
//                       _buildRequirementRow('Different from current password', _isDifferentFromCurrent),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 // Confirm Password Field
//                 TextField(
//                   controller: _confirmPasswordController,
//                   obscureText: _obscureConfirmPassword,
//                   decoration: InputDecoration(
//                     prefixIcon: Icon(Icons.lock_outline, color: orange),
//                     labelText: 'Confirm New Password',
//                     labelStyle: GoogleFonts.poppins(color: Colors.grey[600]),
//                     enabledBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                       borderSide: BorderSide(color: orange, width: 1.5),
//                     ),
//                     focusedBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                       borderSide: BorderSide(color: orange, width: 2),
//                     ),
//                     contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
//                     suffixIcon: IconButton(
//                       icon: Icon(_obscureConfirmPassword ? Icons.visibility_off : Icons.visibility, color: orange),
//                       onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 24),
//                 // Change Password Button
//                 SizedBox(
//                   width: double.infinity,
//                   child: ElevatedButton(
//                     onPressed: _isLoading ? null : _changePassword,
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: orange,
//                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                     ),
//                     child: _isLoading
//                         ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
//                         : Text('Change Password', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
//                   ),
//                 ),
//               ],
//               const SizedBox(height: 24),
//             ],
//           ),
//         ),
//       ),
//     );
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
// } 

// // new

// // import 'package:flutter/material.dart';
// // import 'package:google_fonts/google_fonts.dart';
// // import 'package:supabase_flutter/supabase_flutter.dart';
// // import '../services/auth_service.dart';

// // class ChangePasswordPage extends StatefulWidget {
// //   const ChangePasswordPage({super.key});

// //   @override
// //   State<ChangePasswordPage> createState() => _ChangePasswordPageState();
// // }

// // class _ChangePasswordPageState extends State<ChangePasswordPage> {
// //   final _emailController = TextEditingController();
// //   final _phoneController = TextEditingController();
// //   final _currentPasswordController = TextEditingController();
// //   final _newPasswordController = TextEditingController();
// //   final _confirmPasswordController = TextEditingController();
// //   bool _isLoading = false;
// //   bool _credentialsValidated = false;
// //   bool _obscureCurrentPassword = true;
// //   bool _obscureNewPassword = true;
// //   bool _obscureConfirmPassword = true;
// //   String? _userId;
// //   late final AuthService _authService = AuthService();
  
// //   // Password strength indicators
// //   bool _hasMinLength = false;
// //   bool _hasUppercase = false;
// //   bool _hasLowercase = false;
// //   bool _hasNumber = false;
// //   bool _hasSpecialChar = false;
// //   bool _isDifferentFromCurrent = false;

// //   @override
// //   void dispose() {
// //     _emailController.dispose();
// //     _phoneController.dispose();
// //     _currentPasswordController.dispose();
// //     _newPasswordController.dispose();
// //     _confirmPasswordController.dispose();
// //     super.dispose();
// //   }

// //   void _showSnackBar(String message, {bool isError = false}) {
// //     if (!mounted) return;
// //     ScaffoldMessenger.of(context).showSnackBar(
// //       SnackBar(
// //         content: Text(message, style: GoogleFonts.poppins()),
// //         backgroundColor: isError ? Colors.red : Colors.green,
// //       ),
// //     );
// //   }

// //   void _checkPasswordStrength(String password) {
// //     setState(() {
// //       _hasMinLength = password.length >= 8;
// //       _hasUppercase = password.contains(RegExp(r'[A-Z]'));
// //       _hasLowercase = password.contains(RegExp(r'[a-z]'));
// //       _hasNumber = password.contains(RegExp(r'[0-9]'));
// //       _hasSpecialChar = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
// //       _isDifferentFromCurrent = password != _currentPasswordController.text;
// //     });
// //   }

// //   bool _isPasswordValid() {
// //     return _hasMinLength && _hasUppercase && _hasLowercase && _hasNumber && _hasSpecialChar && _isDifferentFromCurrent;
// //   }

// //   Future<void> _validateCredentials() async {
// //     setState(() { _isLoading = true; });
// //     final email = _emailController.text.trim();
// //     final phone = _phoneController.text.trim();
// //     if (email.isEmpty || phone.isEmpty) {
// //       _showSnackBar('Please enter both email and contact number.', isError: true);
// //       setState(() { _isLoading = false; });
// //       return;
// //     }
    
// //     try {
// //       final userData = await _authService.getUserForPasswordReset(email: email, phoneNumber: phone);
// //       if (userData != null) {
// //         final isValid = await _authService.verifyEmailAndPhone(email: email, phoneNumber: phone);
// //         if (isValid) {
// //           setState(() { 
// //             _credentialsValidated = true;
// //             _userId = userData['id'];
// //           });
// //           _showSnackBar('Credentials validated successfully!');
// //         } else {
// //           _showSnackBar('Invalid email or contact number.', isError: true);
// //         }
// //       } else {
// //         _showSnackBar('Invalid email or contact number.', isError: true);
// //       }
// //     } catch (e) {
// //       _showSnackBar('Error validating credentials. Please try again.', isError: true);
// //     }
// //     setState(() { _isLoading = false; });
// //   }

// //   Future<void> _changePassword() async {
// //     // Validate password requirements
// //     if (!_isPasswordValid()) {
// //       _showSnackBar('Please ensure your new password meets all requirements.', isError: true);
// //       return;
// //     }

// //     // Check if passwords match
// //     if (_newPasswordController.text != _confirmPasswordController.text) {
// //       _showSnackBar('Passwords do not match.', isError: true);
// //       return;
// //     }

// //     // Check if current password is provided
// //     if (_currentPasswordController.text.isEmpty) {
// //       _showSnackBar('Please enter your current password.', isError: true);
// //       return;
// //     }

// //     setState(() => _isLoading = true);

// //     try {
// //       final supabase = Supabase.instance.client;
// //       final user = supabase.auth.currentUser;

// //       if (user == null) {
// //         throw Exception('User not authenticated');
// //       }

// //       // Update password using Supabase Auth
// //       await supabase.auth.updateUser(
// //         UserAttributes(
// //           password: _newPasswordController.text,
// //         ),
// //       );

// //       if (mounted) {
// //         _showSnackBar('Password changed successfully!');
// //         Navigator.pop(context);
// //       }
// //     } catch (e) {
// //       print('Error changing password: $e');
// //       if (mounted) {
// //         String errorMessage = 'Failed to change password';
// //         if (e.toString().contains('Invalid login credentials')) {
// //           errorMessage = 'Current password is incorrect';
// //         } else if (e.toString().contains('Password should be at least')) {
// //           errorMessage = 'Password should be at least 8 characters long';
// //         }
        
// //         _showSnackBar(errorMessage, isError: true);
// //       }
// //     } finally {
// //       if (mounted) {
// //         setState(() => _isLoading = false);
// //       }
// //     }
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     const orange = Color(0xFFF5A623);

// //     return Scaffold(
// //       backgroundColor: Colors.white,
// //       appBar: AppBar(
// //         backgroundColor: Colors.white,
// //         elevation: 0,
// //         leading: BackButton(color: orange),
// //         title: Text('Change Password', style: GoogleFonts.poppins(color: orange, fontWeight: FontWeight.w600)),
// //       ),
// //       body: GestureDetector(
// //         onTap: () {
// //           // Dismiss keyboard when tapping outside input fields
// //           FocusScope.of(context).unfocus();
// //         },
// //         child: SingleChildScrollView(
// //           padding: const EdgeInsets.symmetric(horizontal: 24.0),
// //           child: Column(
// //             children: [
// //               const SizedBox(height: 40),
// //               Image.asset('assets/images/logo1.png', height: 100),
// //               const SizedBox(height: 32),
// //               Text('Change Password', style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: orange)),
// //               const SizedBox(height: 8),
// //               Text('Step 1: Validate your credentials', style: GoogleFonts.poppins(color: Colors.grey[500])),
// //               const SizedBox(height: 24),
// //               // Email Field
// //               TextField(
// //                 controller: _emailController,
// //                 enabled: !_credentialsValidated,
// //                 decoration: InputDecoration(
// //                   prefixIcon: Icon(Icons.mail_outline, color: orange),
// //                   labelText: 'Email',
// //                   labelStyle: GoogleFonts.poppins(color: Colors.grey[600]),
// //                   enabledBorder: OutlineInputBorder(
// //                     borderRadius: BorderRadius.circular(12),
// //                     borderSide: BorderSide(color: orange, width: 1.5),
// //                   ),
// //                   focusedBorder: OutlineInputBorder(
// //                     borderRadius: BorderRadius.circular(12),
// //                     borderSide: BorderSide(color: orange, width: 2),
// //                   ),
// //                   disabledBorder: OutlineInputBorder(
// //                     borderRadius: BorderRadius.circular(12),
// //                     borderSide: BorderSide(color: Colors.grey[400]!, width: 1.5),
// //                   ),
// //                   contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
// //                   filled: _credentialsValidated,
// //                   fillColor: _credentialsValidated ? Colors.grey[100]! : null,
// //                 ),
// //               ),
// //               const SizedBox(height: 16),
// //               // Contact Number Field
// //               TextField(
// //                 controller: _phoneController,
// //                 enabled: !_credentialsValidated,
// //                 decoration: InputDecoration(
// //                   prefixIcon: Icon(Icons.phone_outlined, color: orange),
// //                   labelText: 'Contact Number',
// //                   labelStyle: GoogleFonts.poppins(color: Colors.grey[600]),
// //                   enabledBorder: OutlineInputBorder(
// //                     borderRadius: BorderRadius.circular(12),
// //                     borderSide: BorderSide(color: orange, width: 1.5),
// //                   ),
// //                   focusedBorder: OutlineInputBorder(
// //                     borderRadius: BorderRadius.circular(12),
// //                     borderSide: BorderSide(color: orange, width: 2),
// //                   ),
// //                   disabledBorder: OutlineInputBorder(
// //                     borderRadius: BorderRadius.circular(12),
// //                     borderSide: BorderSide(color: Colors.grey[400]!, width: 1.5),
// //                   ),
// //                   contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
// //                   filled: _credentialsValidated,
// //                   fillColor: _credentialsValidated ? Colors.grey[100]! : null,
// //                 ),
// //               ),
// //               const SizedBox(height: 16),
// //               // Validate Credentials Button
// //               if (!_credentialsValidated)
// //                 SizedBox(
// //                   width: double.infinity,
// //                   child: ElevatedButton(
// //                     onPressed: _isLoading ? null : _validateCredentials,
// //                     style: ElevatedButton.styleFrom(
// //                       backgroundColor: orange,
// //                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
// //                     ),
// //                     child: _isLoading
// //                         ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
// //                         : Text('Validate Credentials', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
// //                   ),
// //                 ),
// //               // Success Message
// //               if (_credentialsValidated) ...[
// //                 const SizedBox(height: 16),
// //                 Container(
// //                   padding: const EdgeInsets.all(12),
// //                   decoration: BoxDecoration(
// //                     color: Colors.green[50],
// //                     borderRadius: BorderRadius.circular(8),
// //                     border: Border.all(color: Colors.green[200]!),
// //                   ),
// //                   child: Row(
// //                     children: [
// //                       Icon(Icons.check_circle, color: Colors.green[600], size: 20),
// //                       const SizedBox(width: 8),
// //                       Expanded(
// //                         child: Text(
// //                           'Credentials validated successfully!',
// //                           style: GoogleFonts.poppins(
// //                             color: Colors.green[700],
// //                             fontWeight: FontWeight.w500,
// //                           ),
// //                         ),
// //                       ),
// //                     ],
// //                   ),
// //                 ),
// //               ],
// //               // Password Change Section
// //               if (_credentialsValidated) ...[
// //                 const SizedBox(height: 24),
// //                 Text('Step 2: Enter your current and new password', style: GoogleFonts.poppins(color: Colors.grey[500])),
// //                 const SizedBox(height: 16),
// //                 // Current Password Field
// //                 TextField(
// //                   controller: _currentPasswordController,
// //                   obscureText: _obscureCurrentPassword,
// //                   decoration: InputDecoration(
// //                     prefixIcon: Icon(Icons.lock, color: orange),
// //                     labelText: 'Current Password',
// //                     labelStyle: GoogleFonts.poppins(color: Colors.grey[600]),
// //                     enabledBorder: OutlineInputBorder(
// //                       borderRadius: BorderRadius.circular(12),
// //                       borderSide: BorderSide(color: orange, width: 1.5),
// //                     ),
// //                     focusedBorder: OutlineInputBorder(
// //                       borderRadius: BorderRadius.circular(12),
// //                       borderSide: BorderSide(color: orange, width: 2),
// //                     ),
// //                     contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
// //                     suffixIcon: IconButton(
// //                       icon: Icon(_obscureCurrentPassword ? Icons.visibility_off : Icons.visibility, color: orange),
// //                       onPressed: () => setState(() => _obscureCurrentPassword = !_obscureCurrentPassword),
// //                     ),
// //                   ),
// //                   onChanged: (value) {
// //                     _checkPasswordStrength(_newPasswordController.text);
// //                   },
// //                 ),
// //                 const SizedBox(height: 16),
// //                 // New Password Field
// //                 TextField(
// //                   controller: _newPasswordController,
// //                   obscureText: _obscureNewPassword,
// //                   decoration: InputDecoration(
// //                     prefixIcon: Icon(Icons.lock_outline, color: orange),
// //                     labelText: 'New Password',
// //                     labelStyle: GoogleFonts.poppins(color: Colors.grey[600]),
// //                     enabledBorder: OutlineInputBorder(
// //                       borderRadius: BorderRadius.circular(12),
// //                       borderSide: BorderSide(color: orange, width: 1.5),
// //                     ),
// //                     focusedBorder: OutlineInputBorder(
// //                       borderRadius: BorderRadius.circular(12),
// //                       borderSide: BorderSide(color: orange, width: 2),
// //                     ),
// //                     contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
// //                     suffixIcon: IconButton(
// //                       icon: Icon(_obscureNewPassword ? Icons.visibility_off : Icons.visibility, color: orange),
// //                       onPressed: () => setState(() => _obscureNewPassword = !_obscureNewPassword),
// //                     ),
// //                   ),
// //                   onChanged: _checkPasswordStrength,
// //                 ),
// //                 // Password Strength Indicators
// //                 const SizedBox(height: 12),
// //                 Container(
// //                   padding: const EdgeInsets.all(12),
// //                   decoration: BoxDecoration(
// //                     color: Colors.grey[50],
// //                     borderRadius: BorderRadius.circular(8),
// //                     border: Border.all(color: Colors.grey[200]!),
// //                   ),
// //                   child: Column(
// //                     crossAxisAlignment: CrossAxisAlignment.start,
// //                     children: [
// //                       Text(
// //                         'Password Requirements:',
// //                         style: GoogleFonts.poppins(
// //                           fontSize: 12,
// //                           fontWeight: FontWeight.bold,
// //                           color: Colors.black87,
// //                         ),
// //                       ),
// //                       const SizedBox(height: 8),
// //                       _buildRequirementRow('Minimum 8 characters', _hasMinLength),
// //                       _buildRequirementRow('At least 1 uppercase letter', _hasUppercase),
// //                       _buildRequirementRow('At least 1 lowercase letter', _hasLowercase),
// //                       _buildRequirementRow('At least 1 number', _hasNumber),
// //                       _buildRequirementRow('At least 1 special character [e.g. !@#%^&*(),.?":{}|<> ]', _hasSpecialChar),
// //                       _buildRequirementRow('Different from current password', _isDifferentFromCurrent),
// //                     ],
// //                   ),
// //                 ),
// //                 const SizedBox(height: 16),
// //                 // Confirm Password Field
// //                 TextField(
// //                   controller: _confirmPasswordController,
// //                   obscureText: _obscureConfirmPassword,
// //                   decoration: InputDecoration(
// //                     prefixIcon: Icon(Icons.lock_outline, color: orange),
// //                     labelText: 'Confirm New Password',
// //                     labelStyle: GoogleFonts.poppins(color: Colors.grey[600]),
// //                     enabledBorder: OutlineInputBorder(
// //                       borderRadius: BorderRadius.circular(12),
// //                       borderSide: BorderSide(color: orange, width: 1.5),
// //                     ),
// //                     focusedBorder: OutlineInputBorder(
// //                       borderRadius: BorderRadius.circular(12),
// //                       borderSide: BorderSide(color: orange, width: 2),
// //                     ),
// //                     contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
// //                     suffixIcon: IconButton(
// //                       icon: Icon(_obscureConfirmPassword ? Icons.visibility_off : Icons.visibility, color: orange),
// //                       onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
// //                     ),
// //                   ),
// //                 ),
// //                 const SizedBox(height: 24),
// //                 // Change Password Button
// //                 SizedBox(
// //                   width: double.infinity,
// //                   child: ElevatedButton(
// //                     onPressed: _isLoading ? null : _changePassword,
// //                     style: ElevatedButton.styleFrom(
// //                       backgroundColor: orange,
// //                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
// //                     ),
// //                     child: _isLoading
// //                         ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
// //                         : Text('Change Password', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
// //                   ),
// //                 ),
// //               ],
// //               const SizedBox(height: 24),
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }

// //   Widget _buildRequirementRow(String text, bool isMet) {
// //     return Padding(
// //       padding: const EdgeInsets.only(bottom: 4),
// //       child: Row(
// //         children: [
// //           Icon(
// //             isMet ? Icons.check_circle : Icons.circle_outlined,
// //             size: 16,
// //             color: isMet ? Colors.green : Colors.grey,
// //           ),
// //           const SizedBox(width: 8),
// //           Text(
// //             text,
// //             style: GoogleFonts.poppins(
// //               fontSize: 11,
// //               color: isMet ? Colors.green[700] : Colors.grey[600],
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }




import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _credentialsValidated = false;
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  // Password strength indicators
  bool _hasMinLength = false;
  bool _hasUppercase = false;
  bool _hasLowercase = false;
  bool _hasNumber = false;
  bool _hasSpecialChar = false;
  bool _isDifferentFromCurrent = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.poppins()),
        backgroundColor: isError ? Colors.red : Colors.green,
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
      _isDifferentFromCurrent = password != _currentPasswordController.text;
    });
  }

  bool _isPasswordValid() {
    return _hasMinLength &&
           _hasUppercase &&
           _hasLowercase &&
           _hasNumber &&
           _hasSpecialChar &&
           _isDifferentFromCurrent;
  }

  Future<void> _validateCurrentPassword() async {
    setState(() { _isLoading = true; });
    final currentPassword = _currentPasswordController.text.trim();

    if (currentPassword.isEmpty) {
      _showSnackBar('Please enter your current password.', isError: true);
      setState(() { _isLoading = false; });
      return;
    }

    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Re-authenticate the user with their current password
      final response = await supabase.auth.signInWithPassword(
        email: user.email!,
        password: currentPassword,
      );

      if (response.user != null) {
        setState(() { _credentialsValidated = true; });
        _showSnackBar('Current password verified successfully!');
      } else {
        _showSnackBar('Current password is incorrect.', isError: true);
      }
    } catch (e) {
      _showSnackBar('Current password is incorrect.', isError: true);
    } finally {
      setState(() { _isLoading = false; });
    }
  }

  Future<void> _changePassword() async {
    if (!_isPasswordValid()) {
      _showSnackBar('Please ensure your new password meets all requirements.', isError: true);
      return;
    }

    if (_newPasswordController.text != _confirmPasswordController.text) {
      _showSnackBar('Passwords do not match.', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Update the password
      await supabase.auth.updateUser(
        UserAttributes(password: _newPasswordController.text),
      );

      if (mounted) {
        _showSnackBar('Password changed successfully!');
        Navigator.pop(context);
      }
    } catch (e) {
      print('Error changing password: $e');
      if (mounted) {
        String errorMessage = 'Failed to change password';
        if (e.toString().contains('Invalid login credentials')) {
          errorMessage = 'Current password is incorrect';
        } else if (e.toString().contains('Password should be at least')) {
          errorMessage = 'Password should be at least 8 characters long';
        }
        _showSnackBar(errorMessage, isError: true);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const orange = Color(0xFFF5A623);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: BackButton(color: orange),
        title: Text('Change Password', style: GoogleFonts.poppins(color: orange, fontWeight: FontWeight.w600)),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const SizedBox(height: 40),
              Image.asset('assets/images/logo1.png', height: 100),
              const SizedBox(height: 32),
              Text('Change Password', style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: orange)),
              const SizedBox(height: 8),
              Text('Step 1: Verify your current password', style: GoogleFonts.poppins(color: Colors.grey[500])),
              const SizedBox(height: 24),
              // Current Password Field
              TextField(
                controller: _currentPasswordController,
                obscureText: _obscureCurrentPassword,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.lock, color: orange),
                  labelText: 'Current Password',
                  labelStyle: GoogleFonts.poppins(color: Colors.grey[600]),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: orange, width: 1.5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: orange, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                  suffixIcon: IconButton(
                    icon: Icon(_obscureCurrentPassword ? Icons.visibility_off : Icons.visibility, color: orange),
                    onPressed: () => setState(() => _obscureCurrentPassword = !_obscureCurrentPassword),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Validate Current Password Button
              if (!_credentialsValidated)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _validateCurrentPassword,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: orange,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _isLoading
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : Text('Verify Current Password', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
                  ),
                ),
              // Success Message
              if (_credentialsValidated)
                Column(
                  children: [
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green[200]!),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.green[600], size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Current password verified successfully!',
                              style: GoogleFonts.poppins(
                                color: Colors.green[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text('Step 2: Enter your new password', style: GoogleFonts.poppins(color: Colors.grey[500])),
                    const SizedBox(height: 16),
                    // New Password Field
                    TextField(
                      controller: _newPasswordController,
                      obscureText: _obscureNewPassword,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.lock_outline, color: orange),
                        labelText: 'New Password',
                        labelStyle: GoogleFonts.poppins(color: Colors.grey[600]),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: orange, width: 1.5),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: orange, width: 2),
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                        suffixIcon: IconButton(
                          icon: Icon(_obscureNewPassword ? Icons.visibility_off : Icons.visibility, color: orange),
                          onPressed: () => setState(() => _obscureNewPassword = !_obscureNewPassword),
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
                          _buildRequirementRow('Different from current password', _isDifferentFromCurrent),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Confirm Password Field
                    TextField(
                      controller: _confirmPasswordController,
                      obscureText: _obscureConfirmPassword,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.lock_outline, color: orange),
                        labelText: 'Confirm New Password',
                        labelStyle: GoogleFonts.poppins(color: Colors.grey[600]),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: orange, width: 1.5),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: orange, width: 2),
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                        suffixIcon: IconButton(
                          icon: Icon(_obscureConfirmPassword ? Icons.visibility_off : Icons.visibility, color: orange),
                          onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Change Password Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _changePassword,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: orange,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: _isLoading
                            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : Text('Change Password', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
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
}
