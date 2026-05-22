// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'services/auth_service.dart';

// class ResetPasswordPage extends StatefulWidget {
//   const ResetPasswordPage({super.key});

//   @override
//   State<ResetPasswordPage> createState() => _ResetPasswordPageState();
// }

// class _ResetPasswordPageState extends State<ResetPasswordPage> {
//   final Color orange = const Color(0xFFF5A623);
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _phoneController = TextEditingController();
//   final TextEditingController _newPasswordController = TextEditingController();
//   final TextEditingController _confirmPasswordController = TextEditingController();
//   bool _obscureNewPassword = true;
//   bool _obscureConfirmPassword = true;
//   bool _isLoading = false;
//   bool _credentialsValidated = false;
//   String? _userId;
//   late final AuthService _authService = AuthService();

//   @override
//   void dispose() {
//     _emailController.dispose();
//     _phoneController.dispose();
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
//           _showSnackBar('Password reset not allowed. You can only reset your password once every 30 days.', isError: true);
//         }
//       } else {
//         _showSnackBar('Invalid email or contact number.', isError: true);
//       }
//     } catch (e) {
//       _showSnackBar('Error validating credentials. Please try again.', isError: true);
//     }
//     setState(() { _isLoading = false; });
//   }



//   Future<void> _sendResetLink() async {
//     setState(() { _isLoading = true; });
//     final email = _emailController.text.trim();
//     final newPassword = _newPasswordController.text;
//     final confirmPassword = _confirmPasswordController.text;
    
//     if (newPassword.isEmpty || confirmPassword.isEmpty) {
//       _showSnackBar('Please fill in all password fields.', isError: true);
//       setState(() { _isLoading = false; });
//       return;
//     }
//     if (newPassword != confirmPassword) {
//       _showSnackBar('Passwords do not match.', isError: true);
//       setState(() { _isLoading = false; });
//       return;
//     }
//     if (newPassword.length < 6 ||
//         !RegExp(r'[A-Z]').hasMatch(newPassword) ||
//         !RegExp(r'[0-9]').hasMatch(newPassword)) {
//       _showSnackBar('Password should be at least 6 characters, contain one uppercase letter and one number.', isError: true);
//       setState(() { _isLoading = false; });
//       return;
//     }
    
//     if (_userId == null) {
//       _showSnackBar('Please validate your credentials first.', isError: true);
//       setState(() { _isLoading = false; });
//       return;
//     }
    
//     try {
//       // Send password reset email
//       await Supabase.instance.client.auth.resetPasswordForEmail(
//         email,
//         redirectTo: 'io.supabase.impawsible://password_reset',
//       );
      
//       // Update the password reset timestamp
//       await _authService.updatePasswordResetTimestamp(_userId!);
      
//       _showSnackBar('Reset link sent! Check your email.');
//       Future.delayed(const Duration(seconds: 2), () {
//         if (mounted) {
//           Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
//         }
//       });
//     } catch (e) {
//       _showSnackBar('Failed to send reset link. Please try again.', isError: true);
//     } finally {
//       setState(() { _isLoading = false; });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         leading: BackButton(color: orange),
//         title: Text('Forgot Password', style: GoogleFonts.poppins(color: orange, fontWeight: FontWeight.w600)),
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.symmetric(horizontal: 24.0),
//         child: Column(
//           children: [
//             const SizedBox(height: 40),
//             Image.asset('assets/images/logo1.png', height: 100),
//             const SizedBox(height: 32),
//             Text('Reset Password', style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: orange)),
//             const SizedBox(height: 8),
//             Text('Step 1: Validate your credentials', style: GoogleFonts.poppins(color: Colors.grey[500])),
//             // const SizedBox(height: 4),
//             // Text('Note: Password reset is allowed only once every 30 days', 
//             //     style: GoogleFonts.poppins(color: Colors.orange[600], fontSize: 12)),
//             const SizedBox(height: 24),
//             TextField(
//               controller: _emailController,
//               enabled: !_credentialsValidated,
//               decoration: InputDecoration(
//                 prefixIcon: Icon(Icons.mail_outline, color: orange),
//                 labelText: 'Email',
//                 labelStyle: GoogleFonts.poppins(color: Colors.grey[600]),
//                 enabledBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                   borderSide: BorderSide(color: orange, width: 1.5),
//                 ),
//                 focusedBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                   borderSide: BorderSide(color: orange, width: 2),
//                 ),
//                 disabledBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                   borderSide: BorderSide(color: Colors.grey[400]!, width: 1.5),
//                 ),
//                 contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
//                 filled: _credentialsValidated,
//                 fillColor: _credentialsValidated ? Colors.grey[100]! : null,
//               ),
//             ),
//             const SizedBox(height: 16),
//             TextField(
//               controller: _phoneController,
//               enabled: !_credentialsValidated,
//               decoration: InputDecoration(
//                 prefixIcon: Icon(Icons.phone_outlined, color: orange),
//                 labelText: 'Contact Number',
//                 labelStyle: GoogleFonts.poppins(color: Colors.grey[600]),
//                 enabledBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                   borderSide: BorderSide(color: orange, width: 1.5),
//                 ),
//                 focusedBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                   borderSide: BorderSide(color: orange, width: 2),
//                 ),
//                 disabledBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                   borderSide: BorderSide(color: Colors.grey[400]!, width: 1.5),
//                 ),
//                 contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
//                 filled: _credentialsValidated,
//                 fillColor: _credentialsValidated ? Colors.grey[100]! : null,
//               ),
//             ),
//             const SizedBox(height: 16),
//             if (!_credentialsValidated)
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   onPressed: _isLoading ? null : _validateCredentials,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: orange,
//                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                   ),
//                   child: _isLoading
//                       ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
//                       : Text('Validate Credentials', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
//                 ),
//               ),
//             if (_credentialsValidated) ...[
//               const SizedBox(height: 16),
//               Container(
//                 padding: const EdgeInsets.all(12),
//                 decoration: BoxDecoration(
//                   color: Colors.green[50],
//                   borderRadius: BorderRadius.circular(8),
//                   border: Border.all(color: Colors.green[200]!),
//                 ),
//                 child: Row(
//                   children: [
//                     Icon(Icons.check_circle, color: Colors.green[600], size: 20),
//                     const SizedBox(width: 8),
//                     Expanded(
//                       child: Text(
//                         'Credentials validated successfully!',
//                         style: GoogleFonts.poppins(
//                           color: Colors.green[700],
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//             if (_credentialsValidated) ...[
//               const SizedBox(height: 24),
//               Text('Step 2: Enter your new password', style: GoogleFonts.poppins(color: Colors.grey[500])),
//               const SizedBox(height: 16),
//               TextField(
//                 controller: _newPasswordController,
//                 obscureText: _obscureNewPassword,
//                 decoration: InputDecoration(
//                   prefixIcon: Icon(Icons.lock_outline, color: orange),
//                   labelText: 'New Password',
//                   labelStyle: GoogleFonts.poppins(color: Colors.grey[600]),
//                   enabledBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                     borderSide: BorderSide(color: orange, width: 1.5),
//                   ),
//                   focusedBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                     borderSide: BorderSide(color: orange, width: 2),
//                   ),
//                   contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
//                   suffixIcon: IconButton(
//                     icon: Icon(_obscureNewPassword ? Icons.visibility_off : Icons.visibility, color: orange),
//                     onPressed: () => setState(() => _obscureNewPassword = !_obscureNewPassword),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 16),
//               TextField(
//                 controller: _confirmPasswordController,
//                 obscureText: _obscureConfirmPassword,
//                 decoration: InputDecoration(
//                   prefixIcon: Icon(Icons.lock_outline, color: orange),
//                   labelText: 'Confirm New Password',
//                   labelStyle: GoogleFonts.poppins(color: Colors.grey[600]),
//                   enabledBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                     borderSide: BorderSide(color: orange, width: 1.5),
//                   ),
//                   focusedBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                     borderSide: BorderSide(color: orange, width: 2),
//                   ),
//                   contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
//                   suffixIcon: IconButton(
//                     icon: Icon(_obscureConfirmPassword ? Icons.visibility_off : Icons.visibility, color: orange),
//                     onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 24),
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   onPressed: _isLoading ? null : _sendResetLink,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: orange,
//                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                   ),
//                   child: _isLoading
//                       ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
//                       : Text('Send Password Reset Link', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
//                 ),
//               ),
//             ],
//             const SizedBox(height: 24),
//           ],
//         ),
//       ),
//     );
//   }
// } 



// new

// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'services/auth_service.dart';
// import 'utils/network_utils.dart';

// class ResetPasswordPage extends StatefulWidget {
//   const ResetPasswordPage({super.key});

//   @override
//   State<ResetPasswordPage> createState() => _ResetPasswordPageState();
// }

// class _ResetPasswordPageState extends State<ResetPasswordPage> {
//   final Color orange = const Color(0xFFF5A623);
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _phoneController = TextEditingController();
//   final TextEditingController _newPasswordController = TextEditingController();
//   final TextEditingController _confirmPasswordController = TextEditingController();

//   bool _obscureNewPassword = true;
//   bool _obscureConfirmPassword = true;
//   bool _isLoading = false;
//   bool _credentialsValidated = false;
//   String? _userId;
//   late final AuthService _authService = AuthService();

//   // UI-only password requirement indicators (no backend logic)
//   bool _hasMinLength = false;
//   bool _hasUppercase = false;
//   bool _hasLowercase = false;
//   bool _hasNumber = false;
//   bool _hasSpecialChar = false;

//   @override
//   void dispose() {
//     _emailController.dispose();
//     _phoneController.dispose();
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

//   Future<void> _handleRefresh() async {
//     final networkUtils = NetworkUtils();
//     final hasInternet = await networkUtils.hasInternetConnection();
//     if (!hasInternet) {
//       _showSnackBar('No internet connection. Please check your network settings.', isError: true);
//     } else {
//       _showSnackBar('Network connection is active.', isError: false);
//     }
//   }

//   // UI-only: Update password requirement indicators (no backend validation)
//   void _checkPasswordStrength(String password) {
//     setState(() {
//       _hasMinLength = password.length >= 8;
//       _hasUppercase = password.contains(RegExp(r'[A-Z]'));
//       _hasLowercase = password.contains(RegExp(r'[a-z]'));
//       _hasNumber = password.contains(RegExp(r'[0-9]'));
//       _hasSpecialChar = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
//     });
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
//           _showSnackBar('Password reset not allowed. You can only reset your password once every 30 days.', isError: true);
//         }
//       } else {
//         _showSnackBar('Invalid email or contact number.', isError: true);
//       }
//     } catch (e) {
//       _showSnackBar('Error validating credentials. Please try again.', isError: true);
//     }
//     setState(() { _isLoading = false; });
//   }

//   Future<void> _sendResetLink() async {
//     setState(() { _isLoading = true; });
//     final email = _emailController.text.trim();
//     final newPassword = _newPasswordController.text;
//     final confirmPassword = _confirmPasswordController.text;

//     if (newPassword.isEmpty || confirmPassword.isEmpty) {
//       _showSnackBar('Please fill in all password fields.', isError: true);
//       setState(() { _isLoading = false; });
//       return;
//     }

//     if (newPassword != confirmPassword) {
//       _showSnackBar('Passwords do not match.', isError: true);
//       setState(() { _isLoading = false; });
//       return;
//     }

//     if (_userId == null) {
//       _showSnackBar('Please validate your credentials first.', isError: true);
//       setState(() { _isLoading = false; });
//       return;
//     }

//     try {
//       await Supabase.instance.client.auth.resetPasswordForEmail(
//         email,
//         redirectTo: 'io.supabase.impawsible://password_reset',
//       );
//       await _authService.updatePasswordResetTimestamp(_userId!);
//       _showSnackBar('Reset link sent! Check your email.');
//       Future.delayed(const Duration(seconds: 2), () {
//         if (mounted) {
//           Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
//         }
//       });
//     } catch (e) {
//       _showSnackBar('Failed to send reset link. Please try again.', isError: true);
//     } finally {
//       setState(() { _isLoading = false; });
//     }
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

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         leading: BackButton(color: orange),
//         title: Text('Forgot Password', style: GoogleFonts.poppins(color: orange, fontWeight: FontWeight.w600)),
//       ),
//       body: RefreshIndicator(
//         color: orange,
//         onRefresh: _handleRefresh,
//         child: GestureDetector(
//           onTap: () => FocusScope.of(context).unfocus(),
//           child: SingleChildScrollView(
//             padding: const EdgeInsets.symmetric(horizontal: 24.0),
//             child: Column(
//               children: [
//                 const SizedBox(height: 40),
//                 Image.asset('assets/images/logo1.png', height: 100),
//                 const SizedBox(height: 32),
//                 Text('Reset Password', style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: orange)),
//                 const SizedBox(height: 8),
//                 Text('Step 1: Validate your credentials', style: GoogleFonts.poppins(color: Colors.grey[500])),
//                 const SizedBox(height: 24),
//                 TextField(
//                   controller: _emailController,
//                   enabled: !_credentialsValidated,
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
//                     disabledBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                       borderSide: BorderSide(color: Colors.grey[400]!, width: 1.5),
//                     ),
//                     contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
//                     filled: _credentialsValidated,
//                     fillColor: _credentialsValidated ? Colors.grey[100]! : null,
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 TextField(
//                   controller: _phoneController,
//                   enabled: !_credentialsValidated,
//                   decoration: InputDecoration(
//                     prefixIcon: Icon(Icons.phone_outlined, color: orange),
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
//                     disabledBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                       borderSide: BorderSide(color: Colors.grey[400]!, width: 1.5),
//                     ),
//                     contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
//                     filled: _credentialsValidated,
//                     fillColor: _credentialsValidated ? Colors.grey[100]! : null,
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 if (!_credentialsValidated)
//                   SizedBox(
//                     width: double.infinity,
//                     child: ElevatedButton(
//                       onPressed: _isLoading ? null : _validateCredentials,
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: orange,
//                         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                       ),
//                       child: _isLoading
//                           ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
//                           : Text('Validate Credentials', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
//                     ),
//                   ),
//                 if (_credentialsValidated) ...[
//                   const SizedBox(height: 16),
//                   Container(
//                     padding: const EdgeInsets.all(12),
//                     decoration: BoxDecoration(
//                       color: Colors.green[50],
//                       borderRadius: BorderRadius.circular(8),
//                       border: Border.all(color: Colors.green[200]!),
//                     ),
//                     child: Row(
//                       children: [
//                         Icon(Icons.check_circle, color: Colors.green[600], size: 20),
//                         const SizedBox(width: 8),
//                         Expanded(
//                           child: Text(
//                             'Credentials validated successfully!',
//                             style: GoogleFonts.poppins(
//                               color: Colors.green[700],
//                               fontWeight: FontWeight.w500,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   const SizedBox(height: 24),
//                   Text('Step 2: Enter your new password', style: GoogleFonts.poppins(color: Colors.grey[500])),
//                   const SizedBox(height: 16),
//                   TextField(
//                     controller: _newPasswordController,
//                     obscureText: _obscureNewPassword,
//                     decoration: InputDecoration(
//                       prefixIcon: Icon(Icons.lock_outline, color: orange),
//                       labelText: 'New Password',
//                       labelStyle: GoogleFonts.poppins(color: Colors.grey[600]),
//                       enabledBorder: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(12),
//                         borderSide: BorderSide(color: orange, width: 1.5),
//                       ),
//                       focusedBorder: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(12),
//                         borderSide: BorderSide(color: orange, width: 2),
//                       ),
//                       contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
//                       suffixIcon: IconButton(
//                         icon: Icon(_obscureNewPassword ? Icons.visibility_off : Icons.visibility, color: orange),
//                         onPressed: () => setState(() => _obscureNewPassword = !_obscureNewPassword),
//                       ),
//                     ),
//                     onChanged: _checkPasswordStrength,
//                   ),
//                   const SizedBox(height: 12),
//                   Container(
//                     padding: const EdgeInsets.all(12),
//                     decoration: BoxDecoration(
//                       color: Colors.grey[50],
//                       borderRadius: BorderRadius.circular(8),
//                       border: Border.all(color: Colors.grey[200]!),
//                     ),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           'Password Requirements:',
//                           style: GoogleFonts.poppins(
//                             fontSize: 12,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.black87,
//                           ),
//                         ),
//                         const SizedBox(height: 8),
//                         _buildRequirementRow('Minimum 8 characters', _hasMinLength),
//                         _buildRequirementRow('At least 1 uppercase letter', _hasUppercase),
//                         _buildRequirementRow('At least 1 lowercase letter', _hasLowercase),
//                         _buildRequirementRow('At least 1 number', _hasNumber),
//                         _buildRequirementRow('At least 1 special character [e.g. !@#%^&*(),.?":{}|<> ]', _hasSpecialChar),
//                       ],
//                     ),
//                   ),
//                   const SizedBox(height: 16),
//                   TextField(
//                     controller: _confirmPasswordController,
//                     obscureText: _obscureConfirmPassword,
//                     decoration: InputDecoration(
//                       prefixIcon: Icon(Icons.lock_outline, color: orange),
//                       labelText: 'Confirm New Password',
//                       labelStyle: GoogleFonts.poppins(color: Colors.grey[600]),
//                       enabledBorder: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(12),
//                         borderSide: BorderSide(color: orange, width: 1.5),
//                       ),
//                       focusedBorder: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(12),
//                         borderSide: BorderSide(color: orange, width: 2),
//                       ),
//                       contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
//                       suffixIcon: IconButton(
//                         icon: Icon(_obscureConfirmPassword ? Icons.visibility_off : Icons.visibility, color: orange),
//                         onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 24),
//                   SizedBox(
//                     width: double.infinity,
//                     child: ElevatedButton(
//                       onPressed: _isLoading ? null : _sendResetLink,
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: orange,
//                         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                       ),
//                       child: _isLoading
//                           ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
//                           : Text('Send Password Reset Link', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
//                     ),
//                   ),
//                 ],
//                 const SizedBox(height: 24),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }


// // ---
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'services/auth_service.dart';
// import 'package:uni_links/uni_links.dart';

// class ResetPasswordPage extends StatefulWidget {
//   const ResetPasswordPage({super.key});

//   @override
//   State<ResetPasswordPage> createState() => _ResetPasswordPageState();
// }

// class _ResetPasswordPageState extends State<ResetPasswordPage> {
//   final Color orange = const Color(0xFFF5A623);
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _phoneController = TextEditingController();
//   final TextEditingController _newPasswordController = TextEditingController();
//   final TextEditingController _confirmPasswordController = TextEditingController();
//   bool _obscureNewPassword = true;
//   bool _obscureConfirmPassword = true;
//   bool _isLoading = false;
//   bool _credentialsValidated = false;
//   String? _userId;
//   late final AuthService _authService = AuthService();

//   @override
//   void dispose() {
//     _emailController.dispose();
//     _phoneController.dispose();
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
//           _showSnackBar('Password reset not allowed. You can only reset your password once every 30 days.', isError: true);
//         }
//       } else {
//         _showSnackBar('Invalid email or contact number.', isError: true);
//       }
//     } catch (e) {
//       _showSnackBar('Error validating credentials. Please try again.', isError: true);
//     }
//     setState(() { _isLoading = false; });
//   }



//   Future<void> _sendResetLink() async {
//     setState(() { _isLoading = true; });
//     final email = _emailController.text.trim();
//     final newPassword = _newPasswordController.text;
//     final confirmPassword = _confirmPasswordController.text;
    
//     if (newPassword.isEmpty || confirmPassword.isEmpty) {
//       _showSnackBar('Please fill in all password fields.', isError: true);
//       setState(() { _isLoading = false; });
//       return;
//     }
//     if (newPassword != confirmPassword) {
//       _showSnackBar('Passwords do not match.', isError: true);
//       setState(() { _isLoading = false; });
//       return;
//     }
//     if (newPassword.length < 6 ||
//         !RegExp(r'[A-Z]').hasMatch(newPassword) ||
//         !RegExp(r'[0-9]').hasMatch(newPassword)) {
//       _showSnackBar('Password should be at least 6 characters, contain one uppercase letter and one number.', isError: true);
//       setState(() { _isLoading = false; });
//       return;
//     }
    
//     if (_userId == null) {
//       _showSnackBar('Please validate your credentials first.', isError: true);
//       setState(() { _isLoading = false; });
//       return;
//     }
    
//     try {
//       // Send password reset email
//       await Supabase.instance.client.auth.resetPasswordForEmail(
//         email,
//         redirectTo: 'io.supabase.impawsible://password_reset',
//       );
      
//       // Update the password reset timestamp
//       await _authService.updatePasswordResetTimestamp(_userId!);
      
//       _showSnackBar('Reset link sent! Check your email.');
//       Future.delayed(const Duration(seconds: 2), () {
//         if (mounted) {
//           Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
//         }
//       });
//     } catch (e) {
//       _showSnackBar('Failed to send reset link. Please try again.', isError: true);
//     } finally {
//       setState(() { _isLoading = false; });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         leading: BackButton(color: orange),
//         title: Text('Forgot Password', style: GoogleFonts.poppins(color: orange, fontWeight: FontWeight.w600)),
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.symmetric(horizontal: 24.0),
//         child: Column(
//           children: [
//             const SizedBox(height: 40),
//             Image.asset('assets/images/logo1.png', height: 100),
//             const SizedBox(height: 32),
//             Text('Reset Password', style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: orange)),
//             const SizedBox(height: 8),
//             Text('Step 1: Validate your credentials', style: GoogleFonts.poppins(color: Colors.grey[500])),
//             // const SizedBox(height: 4),
//             // Text('Note: Password reset is allowed only once every 30 days', 
//             //     style: GoogleFonts.poppins(color: Colors.orange[600], fontSize: 12)),
//             const SizedBox(height: 24),
//             TextField(
//               controller: _emailController,
//               enabled: !_credentialsValidated,
//               decoration: InputDecoration(
//                 prefixIcon: Icon(Icons.mail_outline, color: orange),
//                 labelText: 'Email',
//                 labelStyle: GoogleFonts.poppins(color: Colors.grey[600]),
//                 enabledBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                   borderSide: BorderSide(color: orange, width: 1.5),
//                 ),
//                 focusedBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                   borderSide: BorderSide(color: orange, width: 2),
//                 ),
//                 disabledBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                   borderSide: BorderSide(color: Colors.grey[400]!, width: 1.5),
//                 ),
//                 contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
//                 filled: _credentialsValidated,
//                 fillColor: _credentialsValidated ? Colors.grey[100]! : null,
//               ),
//             ),
//             const SizedBox(height: 16),
//             TextField(
//               controller: _phoneController,
//               enabled: !_credentialsValidated,
//               decoration: InputDecoration(
//                 prefixIcon: Icon(Icons.phone_outlined, color: orange),
//                 labelText: 'Contact Number',
//                 labelStyle: GoogleFonts.poppins(color: Colors.grey[600]),
//                 enabledBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                   borderSide: BorderSide(color: orange, width: 1.5),
//                 ),
//                 focusedBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                   borderSide: BorderSide(color: orange, width: 2),
//                 ),
//                 disabledBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                   borderSide: BorderSide(color: Colors.grey[400]!, width: 1.5),
//                 ),
//                 contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
//                 filled: _credentialsValidated,
//                 fillColor: _credentialsValidated ? Colors.grey[100]! : null,
//               ),
//             ),
//             const SizedBox(height: 16),
//             if (!_credentialsValidated)
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   onPressed: _isLoading ? null : _validateCredentials,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: orange,
//                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                   ),
//                   child: _isLoading
//                       ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
//                       : Text('Validate Credentials', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
//                 ),
//               ),
//             if (_credentialsValidated) ...[
//               const SizedBox(height: 16),
//               Container(
//                 padding: const EdgeInsets.all(12),
//                 decoration: BoxDecoration(
//                   color: Colors.green[50],
//                   borderRadius: BorderRadius.circular(8),
//                   border: Border.all(color: Colors.green[200]!),
//                 ),
//                 child: Row(
//                   children: [
//                     Icon(Icons.check_circle, color: Colors.green[600], size: 20),
//                     const SizedBox(width: 8),
//                     Expanded(
//                       child: Text(
//                         'Credentials validated successfully!',
//                         style: GoogleFonts.poppins(
//                           color: Colors.green[700],
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//             if (_credentialsValidated) ...[
//               const SizedBox(height: 24),
//               Text('Step 2: Enter your new password', style: GoogleFonts.poppins(color: Colors.grey[500])),
//               const SizedBox(height: 16),
//               TextField(
//                 controller: _newPasswordController,
//                 obscureText: _obscureNewPassword,
//                 decoration: InputDecoration(
//                   prefixIcon: Icon(Icons.lock_outline, color: orange),
//                   labelText: 'New Password',
//                   labelStyle: GoogleFonts.poppins(color: Colors.grey[600]),
//                   enabledBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                     borderSide: BorderSide(color: orange, width: 1.5),
//                   ),
//                   focusedBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                     borderSide: BorderSide(color: orange, width: 2),
//                   ),
//                   contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
//                   suffixIcon: IconButton(
//                     icon: Icon(_obscureNewPassword ? Icons.visibility_off : Icons.visibility, color: orange),
//                     onPressed: () => setState(() => _obscureNewPassword = !_obscureNewPassword),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 16),
//               TextField(
//                 controller: _confirmPasswordController,
//                 obscureText: _obscureConfirmPassword,
//                 decoration: InputDecoration(
//                   prefixIcon: Icon(Icons.lock_outline, color: orange),
//                   labelText: 'Confirm New Password',
//                   labelStyle: GoogleFonts.poppins(color: Colors.grey[600]),
//                   enabledBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                     borderSide: BorderSide(color: orange, width: 1.5),
//                   ),
//                   focusedBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                     borderSide: BorderSide(color: orange, width: 2),
//                   ),
//                   contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
//                   suffixIcon: IconButton(
//                     icon: Icon(_obscureConfirmPassword ? Icons.visibility_off : Icons.visibility, color: orange),
//                     onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 24),
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   onPressed: _isLoading ? null : _sendResetLink,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: orange,
//                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                   ),
//                   child: _isLoading
//                       ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
//                       : Text('Send Password Reset Link', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
//                 ),
//               ),
//             ],
//             const SizedBox(height: 24),
//           ],
//         ),
//       ),
//     );
//   }
// } 


 // --

// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'services/auth_service.dart';

// class ResetPasswordPage extends StatefulWidget {
//   const ResetPasswordPage({super.key});

//   @override
//   State<ResetPasswordPage> createState() => _ResetPasswordPageState();
// }

// class _ResetPasswordPageState extends State<ResetPasswordPage> {
//   final Color orange = const Color(0xFFF5A623);
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _phoneController = TextEditingController();
//   final TextEditingController _newPasswordController = TextEditingController();
//   final TextEditingController _confirmPasswordController = TextEditingController();
//   bool _obscureNewPassword = true;
//   bool _obscureConfirmPassword = true;
//   bool _isLoading = false;
//   bool _credentialsValidated = false;
//   String? _userId;
//   late final AuthService _authService = AuthService();

//   @override
//   void dispose() {
//     _emailController.dispose();
//     _phoneController.dispose();
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
//           _showSnackBar('Password reset not allowed. You can only reset your password once every 30 days.', isError: true);
//         }
//       } else {
//         _showSnackBar('Invalid email or contact number.', isError: true);
//       }
//     } catch (e) {
//       _showSnackBar('Error validating credentials. Please try again.', isError: true);
//     }
//     setState(() { _isLoading = false; });
//   }

//   Future<void> _sendResetLink() async {
//     final email = _emailController.text.trim();
//     final newPassword = _newPasswordController.text;
//     final confirmPassword = _confirmPasswordController.text;

//     if (newPassword.isEmpty || confirmPassword.isEmpty) {
//       _showSnackBar('Please fill in all password fields.', isError: true);
//       return;
//     }

//     if (newPassword != confirmPassword) {
//       _showSnackBar('Passwords do not match.', isError: true);
//       return;
//     }

//     if (newPassword.length < 6 ||
//         !RegExp(r'[A-Z]').hasMatch(newPassword) ||
//         !RegExp(r'[0-9]').hasMatch(newPassword)) {
//       _showSnackBar('Password should be at least 6 characters, contain one uppercase letter and one number.', isError: true);
//       return;
//     }

//     setState(() { _isLoading = true; });

//     try {
//       // Store the new password in SharedPreferences
//       final prefs = await SharedPreferences.getInstance();
//       await prefs.setString('new_password', newPassword);

//       // Send password reset email
//       await Supabase.instance.client.auth.resetPasswordForEmail(
//         email,
//         redirectTo: 'io.supabase.impawsible://password_reset',
//       );

//       _showSnackBar('Reset link sent! Check your email.');
//       await Future.delayed(const Duration(seconds: 2));
//       if (mounted) Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
//     } catch (e) {
//       _showSnackBar('Failed to send reset link. Please try again.', isError: true);
//     } finally {
//       setState(() { _isLoading = false; });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         leading: BackButton(color: orange),
//         title: Text('Reset Password', style: GoogleFonts.poppins(color: orange, fontWeight: FontWeight.w600)),
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.symmetric(horizontal: 24.0),
//         child: Column(
//           children: [
//             const SizedBox(height: 40),
//             Image.asset('assets/images/logo1.png', height: 100),
//             const SizedBox(height: 32),
//             Text('Reset Password', style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: orange)),
//             const SizedBox(height: 8),
//             Text('Step 1: Validate your credentials', style: GoogleFonts.poppins(color: Colors.grey[500])),
//             const SizedBox(height: 24),
//             TextField(
//               controller: _emailController,
//               enabled: !_credentialsValidated,
//               decoration: InputDecoration(
//                 prefixIcon: Icon(Icons.mail_outline, color: orange),
//                 labelText: 'Email',
//                 labelStyle: GoogleFonts.poppins(color: Colors.grey[600]),
//                 enabledBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                   borderSide: BorderSide(color: orange, width: 1.5),
//                 ),
//                 focusedBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                   borderSide: BorderSide(color: orange, width: 2),
//                 ),
//                 disabledBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                   borderSide: BorderSide(color: Colors.grey[400]!, width: 1.5),
//                 ),
//                 contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
//                 filled: _credentialsValidated,
//                 fillColor: _credentialsValidated ? Colors.grey[100]! : null,
//               ),
//             ),
//             const SizedBox(height: 16),
//             TextField(
//               controller: _phoneController,
//               enabled: !_credentialsValidated,
//               decoration: InputDecoration(
//                 prefixIcon: Icon(Icons.phone_outlined, color: orange),
//                 labelText: 'Contact Number',
//                 labelStyle: GoogleFonts.poppins(color: Colors.grey[600]),
//                 enabledBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                   borderSide: BorderSide(color: orange, width: 1.5),
//                 ),
//                 focusedBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                   borderSide: BorderSide(color: orange, width: 2),
//                 ),
//                 disabledBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                   borderSide: BorderSide(color: Colors.grey[400]!, width: 1.5),
//                 ),
//                 contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
//                 filled: _credentialsValidated,
//                 fillColor: _credentialsValidated ? Colors.grey[100]! : null,
//               ),
//             ),
//             const SizedBox(height: 16),
//             if (!_credentialsValidated)
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   onPressed: _isLoading ? null : _validateCredentials,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: orange,
//                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                   ),
//                   child: _isLoading
//                       ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
//                       : Text('Validate Credentials', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
//                 ),
//               ),
//             if (_credentialsValidated) ...[
//               const SizedBox(height: 16),
//               Container(
//                 padding: const EdgeInsets.all(12),
//                 decoration: BoxDecoration(
//                   color: Colors.green[50],
//                   borderRadius: BorderRadius.circular(8),
//                   border: Border.all(color: Colors.green[200]!),
//                 ),
//                 child: Row(
//                   children: [
//                     Icon(Icons.check_circle, color: Colors.green[600], size: 20),
//                     const SizedBox(width: 8),
//                     Expanded(
//                       child: Text(
//                         'Credentials validated successfully!',
//                         style: GoogleFonts.poppins(
//                           color: Colors.green[700],
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 24),
//               Text('Step 2: Enter your new password', style: GoogleFonts.poppins(color: Colors.grey[500])),
//               const SizedBox(height: 16),
//               TextField(
//                 controller: _newPasswordController,
//                 obscureText: _obscureNewPassword,
//                 decoration: InputDecoration(
//                   prefixIcon: Icon(Icons.lock_outline, color: orange),
//                   labelText: 'New Password',
//                   labelStyle: GoogleFonts.poppins(color: Colors.grey[600]),
//                   enabledBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                     borderSide: BorderSide(color: orange, width: 1.5),
//                   ),
//                   focusedBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                     borderSide: BorderSide(color: orange, width: 2),
//                   ),
//                   contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
//                   suffixIcon: IconButton(
//                     icon: Icon(_obscureNewPassword ? Icons.visibility_off : Icons.visibility, color: orange),
//                     onPressed: () => setState(() => _obscureNewPassword = !_obscureNewPassword),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 16),
//               TextField(
//                 controller: _confirmPasswordController,
//                 obscureText: _obscureConfirmPassword,
//                 decoration: InputDecoration(
//                   prefixIcon: Icon(Icons.lock_outline, color: orange),
//                   labelText: 'Confirm New Password',
//                   labelStyle: GoogleFonts.poppins(color: Colors.grey[600]),
//                   enabledBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                     borderSide: BorderSide(color: orange, width: 1.5),
//                   ),
//                   focusedBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                     borderSide: BorderSide(color: orange, width: 2),
//                   ),
//                   contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
//                   suffixIcon: IconButton(
//                     icon: Icon(_obscureConfirmPassword ? Icons.visibility_off : Icons.visibility, color: orange),
//                     onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 24),
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   onPressed: _isLoading ? null : _sendResetLink,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: orange,
//                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                   ),
//                   child: _isLoading
//                       ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
//                       : Text('Send Reset Link', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
//                 ),
//               ),
//             ],
//             const SizedBox(height: 24),
//           ],
//         ),
//       ),
//     );
//   }
// }
 

 // ---

// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'services/auth_service.dart';

// class ResetPasswordPage extends StatefulWidget {
//   const ResetPasswordPage({super.key});

//   @override
//   State<ResetPasswordPage> createState() => _ResetPasswordPageState();
// }

// class _ResetPasswordPageState extends State<ResetPasswordPage> {
//   final Color orange = const Color(0xFFF5A623);
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _phoneController = TextEditingController();
//   final TextEditingController _newPasswordController = TextEditingController();
//   final TextEditingController _confirmPasswordController = TextEditingController();

//   bool _obscureNewPassword = true;
//   bool _obscureConfirmPassword = true;
//   bool _isLoading = false;
//   bool _credentialsValidated = false;
//   String? _userId;

//   late final AuthService _authService = AuthService();

//   @override
//   void dispose() {
//     _emailController.dispose();
//     _phoneController.dispose();
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
//           _showSnackBar('Password reset not allowed. You can only reset your password once every 30 days.', isError: true);
//         }
//       } else {
//         _showSnackBar('Invalid email or contact number.', isError: true);
//       }
//     } catch (e) {
//       _showSnackBar('Error validating credentials. Please try again.', isError: true);
//     }
//     setState(() { _isLoading = false; });
//   }

//   Future<void> _sendResetLink() async {
//     final email = _emailController.text.trim();
//     final newPassword = _newPasswordController.text;
//     final confirmPassword = _confirmPasswordController.text;

//     if (newPassword.isEmpty || confirmPassword.isEmpty) {
//       _showSnackBar('Please fill in all password fields.', isError: true);
//       return;
//     }

//     if (newPassword != confirmPassword) {
//       _showSnackBar('Passwords do not match.', isError: true);
//       return;
//     }

//     // Password validation
//     if (newPassword.length < 8) {
//       _showSnackBar('Password should be at least 8 characters.', isError: true);
//       return;
//     }

//     if (!RegExp(r'[A-Z]').hasMatch(newPassword)) {
//       _showSnackBar('Password should contain at least one uppercase letter.', isError: true);
//       return;
//     }

//     if (!RegExp(r'[a-z]').hasMatch(newPassword)) {
//       _showSnackBar('Password should contain at least one lowercase letter.', isError: true);
//       return;
//     }

//     if (!RegExp(r'[0-9]').hasMatch(newPassword)) {
//       _showSnackBar('Password should contain at least one number.', isError: true);
//       return;
//     }

//     if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(newPassword)) {
//       _showSnackBar('Password should contain at least one special character (e.g., !@#$%^&*).', isError: true);
//       return;
//     }

//     setState(() { _isLoading = true; });

//     try {
//       // Send password reset link
//       await Supabase.instance.client.auth.resetPasswordForEmail(
//         email,
//         redirectTo: 'io.supabase.impawsible://password_reset',
//       );

//       _showSnackBar('Password reset link sent! Check your email.', isError: false);
//       await Future.delayed(const Duration(seconds: 2));
//       if (mounted) Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);

//     } catch (e) {
//       print('Error sending reset link: $e');
//       _showSnackBar('Error sending reset link: ${e.toString()}', isError: true);
//     } finally {
//       setState(() { _isLoading = false; });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         leading: BackButton(color: orange),
//         title: Text('Reset Password', style: GoogleFonts.poppins(color: orange, fontWeight: FontWeight.w600)),
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.symmetric(horizontal: 24.0),
//         child: Column(
//           children: [
//             const SizedBox(height: 40),
//             Image.asset('assets/images/logo1.png', height: 100),
//             const SizedBox(height: 32),
//             Text('Reset Password', style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: orange)),
//             const SizedBox(height: 8),
//             Text('Step 1: Validate your credentials', style: GoogleFonts.poppins(color: Colors.grey[500])),
//             const SizedBox(height: 24),
//             TextField(
//               controller: _emailController,
//               enabled: !_credentialsValidated,
//               decoration: InputDecoration(
//                 prefixIcon: Icon(Icons.mail_outline, color: orange),
//                 labelText: 'Email',
//                 labelStyle: GoogleFonts.poppins(color: Colors.grey[600]),
//                 enabledBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                   borderSide: BorderSide(color: orange, width: 1.5),
//                 ),
//                 focusedBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                   borderSide: BorderSide(color: orange, width: 2),
//                 ),
//                 disabledBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                   borderSide: BorderSide(color: Colors.grey[400]!, width: 1.5),
//                 ),
//                 contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
//                 filled: _credentialsValidated,
//                 fillColor: _credentialsValidated ? Colors.grey[100]! : null,
//               ),
//             ),
//             const SizedBox(height: 16),
//             TextField(
//               controller: _phoneController,
//               enabled: !_credentialsValidated,
//               decoration: InputDecoration(
//                 prefixIcon: Icon(Icons.phone_outlined, color: orange),
//                 labelText: 'Contact Number',
//                 labelStyle: GoogleFonts.poppins(color: Colors.grey[600]),
//                 enabledBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                   borderSide: BorderSide(color: orange, width: 1.5),
//                 ),
//                 focusedBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                   borderSide: BorderSide(color: orange, width: 2),
//                 ),
//                 disabledBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                   borderSide: BorderSide(color: Colors.grey[400]!, width: 1.5),
//                 ),
//                 contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
//                 filled: _credentialsValidated,
//                 fillColor: _credentialsValidated ? Colors.grey[100]! : null,
//               ),
//             ),
//             const SizedBox(height: 16),
//             if (!_credentialsValidated)
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   onPressed: _isLoading ? null : _validateCredentials,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: orange,
//                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                   ),
//                   child: _isLoading
//                       ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
//                       : Text('Validate Credentials', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
//                 ),
//               ),
//             if (_credentialsValidated) ...[
//               const SizedBox(height: 16),
//               Container(
//                 padding: const EdgeInsets.all(12),
//                 decoration: BoxDecoration(
//                   color: Colors.green[50],
//                   borderRadius: BorderRadius.circular(8),
//                   border: Border.all(color: Colors.green[200]!),
//                 ),
//                 child: Row(
//                   children: [
//                     Icon(Icons.check_circle, color: Colors.green[600], size: 20),
//                     const SizedBox(width: 8),
//                     Expanded(
//                       child: Text(
//                         'Credentials validated successfully!',
//                         style: GoogleFonts.poppins(
//                           color: Colors.green[700],
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 24),
//               Text('Step 2: Enter your new password', style: GoogleFonts.poppins(color: Colors.grey[500])),
//               const SizedBox(height: 16),
//               TextField(
//                 controller: _newPasswordController,
//                 obscureText: _obscureNewPassword,
//                 decoration: InputDecoration(
//                   prefixIcon: Icon(Icons.lock_outline, color: orange),
//                   labelText: 'New Password',
//                   labelStyle: GoogleFonts.poppins(color: Colors.grey[600]),
//                   enabledBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                     borderSide: BorderSide(color: orange, width: 1.5),
//                   ),
//                   focusedBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                     borderSide: BorderSide(color: orange, width: 2),
//                   ),
//                   contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
//                   suffixIcon: IconButton(
//                     icon: Icon(_obscureNewPassword ? Icons.visibility_off : Icons.visibility, color: orange),
//                     onPressed: () => setState(() => _obscureNewPassword = !_obscureNewPassword),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 16),
//               TextField(
//                 controller: _confirmPasswordController,
//                 obscureText: _obscureConfirmPassword,
//                 decoration: InputDecoration(
//                   prefixIcon: Icon(Icons.lock_outline, color: orange),
//                   labelText: 'Confirm New Password',
//                   labelStyle: GoogleFonts.poppins(color: Colors.grey[600]),
//                   enabledBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                     borderSide: BorderSide(color: orange, width: 1.5),
//                   ),
//                   focusedBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                     borderSide: BorderSide(color: orange, width: 2),
//                   ),
//                   contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
//                   suffixIcon: IconButton(
//                     icon: Icon(_obscureConfirmPassword ? Icons.visibility_off : Icons.visibility, color: orange),
//                     onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 24),
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   onPressed: _isLoading ? null : _sendResetLink,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: orange,
//                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                   ),
//                   child: _isLoading
//                       ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
//                       : Text('Send Reset Link', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
//                 ),
//               ),
//             ],
//             const SizedBox(height: 24),
//           ],
//         ),
//       ),
//     );
//   }
// }



//---

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


// ---

// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'services/auth_service.dart';

// class ResetPasswordPage extends StatefulWidget {
//   const ResetPasswordPage({super.key});

//   @override
//   State<ResetPasswordPage> createState() => _ResetPasswordPageState();
// }

// class _ResetPasswordPageState extends State<ResetPasswordPage> {
//   final Color orange = const Color(0xFFF5A623);
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _phoneController = TextEditingController();
//   final TextEditingController _newPasswordController = TextEditingController();
//   final TextEditingController _confirmPasswordController = TextEditingController();

//   bool _obscureNewPassword = true;
//   bool _obscureConfirmPassword = true;
//   bool _isLoading = false;
//   bool _credentialsValidated = false;
//   String? _userId;

//   // Password strength indicators
//   bool _hasMinLength = false;
//   bool _hasUppercase = false;
//   bool _hasLowercase = false;
//   bool _hasNumber = false;
//   bool _hasSpecialChar = false;

//   late final AuthService _authService = AuthService();

//   @override
//   void dispose() {
//     _emailController.dispose();
//     _phoneController.dispose();
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
//     });
//   }

//   bool _isPasswordValid() {
//     return _hasMinLength &&
//            _hasUppercase &&
//            _hasLowercase &&
//            _hasNumber &&
//            _hasSpecialChar;
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
//           _showSnackBar('Password reset not allowed. You can only reset your password once every 30 days.', isError: true);
//         }
//       } else {
//         _showSnackBar('Invalid email or contact number.', isError: true);
//       }
//     } catch (e) {
//       _showSnackBar('Error validating credentials. Please try again.', isError: true);
//     }
//     setState(() { _isLoading = false; });
//   }

//   Future<void> _sendResetLink() async {
//     final email = _emailController.text.trim();
//     final newPassword = _newPasswordController.text;
//     final confirmPassword = _confirmPasswordController.text;

//     if (newPassword.isEmpty || confirmPassword.isEmpty) {
//       _showSnackBar('Please fill in all password fields.', isError: true);
//       return;
//     }

//     if (newPassword != confirmPassword) {
//       _showSnackBar('Passwords do not match.', isError: true);
//       return;
//     }

//     if (!_isPasswordValid()) {
//       _showSnackBar('Please ensure your new password meets all requirements.', isError: true);
//       return;
//     }

//     setState(() { _isLoading = true; });

//     try {
//       // Send password reset link to the user's email
//       await Supabase.instance.client.auth.resetPasswordForEmail(
//         email,
//         redirectTo: 'io.supabase.impawsible://password_reset',
//       );

//       _showSnackBar('Password reset link sent! Check your email to complete the reset.', isError: false);
//       await Future.delayed(const Duration(seconds: 2));
//       if (mounted) Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);

//     } catch (e) {
//       print('Error sending reset link: $e');
//       _showSnackBar('Error sending reset link: ${e.toString()}', isError: true);
//     } finally {
//       setState(() { _isLoading = false; });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         leading: BackButton(color: orange),
//         title: Text('Reset Password', style: GoogleFonts.poppins(color: orange, fontWeight: FontWeight.w600)),
//       ),
//       body: GestureDetector(
//         onTap: () => FocusScope.of(context).unfocus(),
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.symmetric(horizontal: 24.0),
//           child: Column(
//             children: [
//               const SizedBox(height: 40),
//               Image.asset('assets/images/logo1.png', height: 100),
//               const SizedBox(height: 32),
//               Text('Reset Password', style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: orange)),
//               const SizedBox(height: 8),
//               Text('Step 1: Verify your credentials', style: GoogleFonts.poppins(color: Colors.grey[500])),
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
//               // Phone Field
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
//                         : Text('Verify Credentials', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
//                   ),
//                 ),
//               // Success Message
//               if (_credentialsValidated)
//                 Column(
//                   children: [
//                     const SizedBox(height: 16),
//                     Container(
//                       padding: const EdgeInsets.all(12),
//                       decoration: BoxDecoration(
//                         color: Colors.green[50],
//                         borderRadius: BorderRadius.circular(8),
//                         border: Border.all(color: Colors.green[200]!),
//                       ),
//                       child: Row(
//                         children: [
//                           Icon(Icons.check_circle, color: Colors.green[600], size: 20),
//                           const SizedBox(width: 8),
//                           Expanded(
//                             child: Text(
//                               'Credentials verified successfully!',
//                               style: GoogleFonts.poppins(
//                                 color: Colors.green[700],
//                                 fontWeight: FontWeight.w500,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     const SizedBox(height: 24),
//                     Text('Step 2: Enter your new password', style: GoogleFonts.poppins(color: Colors.grey[500])),
//                     const SizedBox(height: 16),
//                     // New Password Field
//                     TextField(
//                       controller: _newPasswordController,
//                       obscureText: _obscureNewPassword,
//                       decoration: InputDecoration(
//                         prefixIcon: Icon(Icons.lock_outline, color: orange),
//                         labelText: 'New Password',
//                         labelStyle: GoogleFonts.poppins(color: Colors.grey[600]),
//                         enabledBorder: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(12),
//                           borderSide: BorderSide(color: orange, width: 1.5),
//                         ),
//                         focusedBorder: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(12),
//                           borderSide: BorderSide(color: orange, width: 2),
//                         ),
//                         contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
//                         suffixIcon: IconButton(
//                           icon: Icon(_obscureNewPassword ? Icons.visibility_off : Icons.visibility, color: orange),
//                           onPressed: () => setState(() => _obscureNewPassword = !_obscureNewPassword),
//                         ),
//                       ),
//                       onChanged: _checkPasswordStrength,
//                     ),
//                     // Password Strength Indicators
//                     const SizedBox(height: 12),
//                     Container(
//                       padding: const EdgeInsets.all(12),
//                       decoration: BoxDecoration(
//                         color: Colors.grey[50],
//                         borderRadius: BorderRadius.circular(8),
//                         border: Border.all(color: Colors.grey[200]!),
//                       ),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             'Password Requirements:',
//                             style: GoogleFonts.poppins(
//                               fontSize: 12,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.black87,
//                             ),
//                           ),
//                           const SizedBox(height: 8),
//                           _buildRequirementRow('Minimum 8 characters', _hasMinLength),
//                           _buildRequirementRow('At least 1 uppercase letter', _hasUppercase),
//                           _buildRequirementRow('At least 1 lowercase letter', _hasLowercase),
//                           _buildRequirementRow('At least 1 number', _hasNumber),
//                           _buildRequirementRow('At least 1 special character [e.g. !@#%^&*(),.?":{}|<> ]', _hasSpecialChar),
//                         ],
//                       ),
//                     ),
//                     const SizedBox(height: 16),
//                     // Confirm Password Field
//                     TextField(
//                       controller: _confirmPasswordController,
//                       obscureText: _obscureConfirmPassword,
//                       decoration: InputDecoration(
//                         prefixIcon: Icon(Icons.lock_outline, color: orange),
//                         labelText: 'Confirm New Password',
//                         labelStyle: GoogleFonts.poppins(color: Colors.grey[600]),
//                         enabledBorder: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(12),
//                           borderSide: BorderSide(color: orange, width: 1.5),
//                         ),
//                         focusedBorder: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(12),
//                           borderSide: BorderSide(color: orange, width: 2),
//                         ),
//                         contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
//                         suffixIcon: IconButton(
//                           icon: Icon(_obscureConfirmPassword ? Icons.visibility_off : Icons.visibility, color: orange),
//                           onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 24),
//                     // Send Reset Link Button
//                     SizedBox(
//                       width: double.infinity,
//                       child: ElevatedButton(
//                         onPressed: _isLoading ? null : _sendResetLink,
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: orange,
//                           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                         ),
//                         child: _isLoading
//                             ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
//                             : Text('Send Reset Link', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
//                       ),
//                     ),
//                   ],
//                 ),
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

// ----

// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'services/auth_service.dart';

// class ResetPasswordPage extends StatefulWidget {
//   const ResetPasswordPage({super.key});

//   @override
//   State<ResetPasswordPage> createState() => _ResetPasswordPageState();
// }

// class _ResetPasswordPageState extends State<ResetPasswordPage> {
//   final Color orange = const Color(0xFFF5A623);
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _phoneController = TextEditingController();
//   final TextEditingController _newPasswordController = TextEditingController();
//   final TextEditingController _confirmPasswordController = TextEditingController();

//   bool _obscureNewPassword = true;
//   bool _obscureConfirmPassword = true;
//   bool _isLoading = false;
//   bool _credentialsValidated = false;
//   String? _userId;

//   // Password strength indicators
//   bool _hasMinLength = false;
//   bool _hasUppercase = false;
//   bool _hasLowercase = false;
//   bool _hasNumber = false;
//   bool _hasSpecialChar = false;

//   late final AuthService _authService = AuthService();

//   @override
//   void dispose() {
//     _emailController.dispose();
//     _phoneController.dispose();
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
//       _hasSpecialChar = password.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'));
//     });
//   }

//   bool _isPasswordValid() {
//     return _hasMinLength &&
//            _hasUppercase &&
//            _hasLowercase &&
//            _hasNumber &&
//            _hasSpecialChar;
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
//           _showSnackBar('Password reset not allowed. You can only reset your password once every 30 days.', isError: true);
//         }
//       } else {
//         _showSnackBar('Invalid email or contact number.', isError: true);
//       }
//     } catch (e) {
//       _showSnackBar('Error validating credentials. Please try again.', isError: true);
//     }
//     setState(() { _isLoading = false; });
//   }

//   Future<void> _updatePassword() async {
//     final email = _emailController.text.trim();
//     final newPassword = _newPasswordController.text;
//     final confirmPassword = _confirmPasswordController.text;

//     if (newPassword.isEmpty || confirmPassword.isEmpty) {
//       _showSnackBar('Please fill in all password fields.', isError: true);
//       return;
//     }

//     if (newPassword != confirmPassword) {
//       _showSnackBar('Passwords do not match.', isError: true);
//       return;
//     }

//     if (!_isPasswordValid()) {
//       _showSnackBar('Please ensure your new password meets all requirements.', isError: true);
//       return;
//     }

//     setState(() { _isLoading = true; });

//     try {
//       // Sign in the user silently using their email and a temporary token
//       // or use the admin API (server-side) to update the password.
//       // For this example, we'll use the admin API approach via a backend call.
//       // Alternatively, you can use the reset flow, but this requires the user to click a link.

//       // Since we deleted the PasswordResetPage, we'll update the password directly.
//       // This requires the user to be logged in or using the admin API.
//       // Here, we assume the user is logged in after credential validation.

//       // Update the password directly in Supabase
//       final response = await Supabase.instance.client.auth.updateUser(
//         UserAttributes(password: newPassword),
//       );

//       if (response.user != null) {
//         _showSnackBar('Password updated successfully!', isError: false);
//         await Future.delayed(const Duration(seconds: 2));
//         if (mounted) Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
//       } else {
//         _showSnackBar('Failed to update password. Please try again.', isError: true);
//       }
//     } catch (e) {
//       print('Error updating password: $e');
//       _showSnackBar('Error updating password: ${e.toString()}', isError: true);
//     } finally {
//       setState(() { _isLoading = false; });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         leading: BackButton(color: orange),
//         title: Text('Reset Password', style: GoogleFonts.poppins(color: orange, fontWeight: FontWeight.w600)),
//       ),
//       body: GestureDetector(
//         onTap: () => FocusScope.of(context).unfocus(),
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.symmetric(horizontal: 24.0),
//           child: Column(
//             children: [
//               const SizedBox(height: 40),
//               Image.asset('assets/images/logo1.png', height: 100),
//               const SizedBox(height: 32),
//               Text('Reset Password', style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: orange)),
//               const SizedBox(height: 8),
//               Text('Step 1: Verify your credentials', style: GoogleFonts.poppins(color: Colors.grey[500])),
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
//               // Phone Field
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
//                         : Text('Verify Credentials', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
//                   ),
//                 ),
//               // Success Message
//               if (_credentialsValidated)
//                 Column(
//                   children: [
//                     const SizedBox(height: 16),
//                     Container(
//                       padding: const EdgeInsets.all(12),
//                       decoration: BoxDecoration(
//                         color: Colors.green[50],
//                         borderRadius: BorderRadius.circular(8),
//                         border: Border.all(color: Colors.green[200]!),
//                       ),
//                       child: Row(
//                         children: [
//                           Icon(Icons.check_circle, color: Colors.green[600], size: 20),
//                           const SizedBox(width: 8),
//                           Expanded(
//                             child: Text(
//                               'Credentials verified successfully!',
//                               style: GoogleFonts.poppins(
//                                 color: Colors.green[700],
//                                 fontWeight: FontWeight.w500,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     const SizedBox(height: 24),
//                     Text('Step 2: Enter your new password', style: GoogleFonts.poppins(color: Colors.grey[500])),
//                     const SizedBox(height: 16),
//                     // New Password Field
//                     TextField(
//                       controller: _newPasswordController,
//                       obscureText: _obscureNewPassword,
//                       decoration: InputDecoration(
//                         prefixIcon: Icon(Icons.lock_outline, color: orange),
//                         labelText: 'New Password',
//                         labelStyle: GoogleFonts.poppins(color: Colors.grey[600]),
//                         enabledBorder: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(12),
//                           borderSide: BorderSide(color: orange, width: 1.5),
//                         ),
//                         focusedBorder: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(12),
//                           borderSide: BorderSide(color: orange, width: 2),
//                         ),
//                         contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
//                         suffixIcon: IconButton(
//                           icon: Icon(_obscureNewPassword ? Icons.visibility_off : Icons.visibility, color: orange),
//                           onPressed: () => setState(() => _obscureNewPassword = !_obscureNewPassword),
//                         ),
//                       ),
//                       onChanged: _checkPasswordStrength,
//                     ),
//                     // Password Strength Indicators
//                     const SizedBox(height: 12),
//                     Container(
//                       padding: const EdgeInsets.all(12),
//                       decoration: BoxDecoration(
//                         color: Colors.grey[50],
//                         borderRadius: BorderRadius.circular(8),
//                         border: Border.all(color: Colors.grey[200]!),
//                       ),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             'Password Requirements:',
//                             style: GoogleFonts.poppins(
//                               fontSize: 12,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.black87,
//                             ),
//                           ),
//                           const SizedBox(height: 8),
//                           _buildRequirementRow('Minimum 8 characters', _hasMinLength),
//                           _buildRequirementRow('At least 1 uppercase letter', _hasUppercase),
//                           _buildRequirementRow('At least 1 lowercase letter', _hasLowercase),
//                           _buildRequirementRow('At least 1 number', _hasNumber),
//                           _buildRequirementRow('At least 1 special character [e.g. !@#%^&*(),.?":{}|<> ]', _hasSpecialChar),
//                         ],
//                       ),
//                     ),
//                     const SizedBox(height: 16),
//                     // Confirm Password Field
//                     TextField(
//                       controller: _confirmPasswordController,
//                       obscureText: _obscureConfirmPassword,
//                       decoration: InputDecoration(
//                         prefixIcon: Icon(Icons.lock_outline, color: orange),
//                         labelText: 'Confirm New Password',
//                         labelStyle: GoogleFonts.poppins(color: Colors.grey[600]),
//                         enabledBorder: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(12),
//                           borderSide: BorderSide(color: orange, width: 1.5),
//                         ),
//                         focusedBorder: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(12),
//                           borderSide: BorderSide(color: orange, width: 2),
//                         ),
//                         contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
//                         suffixIcon: IconButton(
//                           icon: Icon(_obscureConfirmPassword ? Icons.visibility_off : Icons.visibility, color: orange),
//                           onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 24),
//                     // Update Password Button
//                     SizedBox(
//                       width: double.infinity,
//                       child: ElevatedButton(
//                         onPressed: _isLoading ? null : _updatePassword,
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: orange,
//                           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                         ),
//                         child: _isLoading
//                             ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
//                             : Text('Update Password', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
//                       ),
//                     ),
//                   ],
//                 ),
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


// ---

// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import 'services/auth_service.dart';

// class ResetPasswordPage extends StatefulWidget {
//   const ResetPasswordPage({super.key});

//   @override
//   State<ResetPasswordPage> createState() => _ResetPasswordPageState();
// }

// class _ResetPasswordPageState extends State<ResetPasswordPage> {
//   final Color orange = const Color(0xFFF5A623);
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _phoneController = TextEditingController();
//   final TextEditingController _newPasswordController = TextEditingController();
//   final TextEditingController _confirmPasswordController = TextEditingController();

//   bool _obscureNewPassword = true;
//   bool _obscureConfirmPassword = true;
//   bool _isLoading = false;
//   bool _credentialsValidated = false;
//   String? _userId;

//   // Password strength indicators
//   bool _hasMinLength = false;
//   bool _hasUppercase = false;
//   bool _hasLowercase = false;
//   bool _hasNumber = false;
//   bool _hasSpecialChar = false;

//   late final AuthService _authService = AuthService();

//   @override
//   void dispose() {
//     _emailController.dispose();
//     _phoneController.dispose();
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
//     });
//   }

//   bool _isPasswordValid() {
//     return _hasMinLength &&
//            _hasUppercase &&
//            _hasLowercase &&
//            _hasNumber &&
//            _hasSpecialChar;
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
//           _showSnackBar('Password reset not allowed. You can only reset your password once every 30 days.', isError: true);
//         }
//       } else {
//         _showSnackBar('Invalid email or contact number.', isError: true);
//       }
//     } catch (e) {
//       _showSnackBar('Error validating credentials. Please try again.', isError: true);
//     }
//     setState(() { _isLoading = false; });
//   }

//   Future<void> _updatePassword() async {
//     final email = _emailController.text.trim();
//     final newPassword = _newPasswordController.text;
//     final confirmPassword = _confirmPasswordController.text;

//     if (newPassword.isEmpty || confirmPassword.isEmpty) {
//       _showSnackBar('Please fill in all password fields.', isError: true);
//       return;
//     }

//     if (newPassword != confirmPassword) {
//       _showSnackBar('Passwords do not match.', isError: true);
//       return;
//     }

//     if (!_isPasswordValid()) {
//       _showSnackBar('Please ensure your new password meets all requirements.', isError: true);
//       return;
//     }

//     setState(() { _isLoading = true; });

//     try {
//       // Generate a temporary token or use the admin API to update the password.
//       // For this example, we'll use the admin API approach via a backend call.
//       // Alternatively, you can sign the user in silently if you have their current password.

//       // Since we don't have the current password, we'll use the admin API.
//       // This requires a backend call to your server, which then calls Supabase's admin API.

//       // For now, we'll simulate this by signing the user in with a temporary token.
//       // In a real app, you should use a backend service for this.

//       // Sign in the user silently (this is a placeholder; you need a valid token or password)
//       final response = await Supabase.instance.client.auth.signInWithPassword(
//         email: email,
//         password: 'temporary_password', // This won't work unless you have the current password
//       );

//       if (response.user != null) {
//         // Update the password
//         await Supabase.instance.client.auth.updateUser(
//           UserAttributes(password: newPassword),
//         );

//         _showSnackBar('Password updated successfully!', isError: false);
//         await Future.delayed(const Duration(seconds: 2));
//         if (mounted) Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
//       } else {
//         _showSnackBar('Failed to update password. Please try again.', isError: true);
//       }
//     } catch (e) {
//       print('Error updating password: $e');
//       _showSnackBar('Error updating password: ${e.toString()}', isError: true);
//     } finally {
//       setState(() { _isLoading = false; });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         leading: BackButton(color: orange),
//         title: Text('Reset Password', style: GoogleFonts.poppins(color: orange, fontWeight: FontWeight.w600)),
//       ),
//       body: GestureDetector(
//         onTap: () => FocusScope.of(context).unfocus(),
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.symmetric(horizontal: 24.0),
//           child: Column(
//             children: [
//               const SizedBox(height: 40),
//               Image.asset('assets/images/logo1.png', height: 100),
//               const SizedBox(height: 32),
//               Text('Reset Password', style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: orange)),
//               const SizedBox(height: 8),
//               Text('Step 1: Verify your credentials', style: GoogleFonts.poppins(color: Colors.grey[500])),
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
//               // Phone Field
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
//                         : Text('Verify Credentials', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
//                   ),
//                 ),
//               // Success Message
//               if (_credentialsValidated)
//                 Column(
//                   children: [
//                     const SizedBox(height: 16),
//                     Container(
//                       padding: const EdgeInsets.all(12),
//                       decoration: BoxDecoration(
//                         color: Colors.green[50],
//                         borderRadius: BorderRadius.circular(8),
//                         border: Border.all(color: Colors.green[200]!),
//                       ),
//                       child: Row(
//                         children: [
//                           Icon(Icons.check_circle, color: Colors.green[600], size: 20),
//                           const SizedBox(width: 8),
//                           Expanded(
//                             child: Text(
//                               'Credentials verified successfully!',
//                               style: GoogleFonts.poppins(
//                                 color: Colors.green[700],
//                                 fontWeight: FontWeight.w500,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     const SizedBox(height: 24),
//                     Text('Step 2: Enter your new password', style: GoogleFonts.poppins(color: Colors.grey[500])),
//                     const SizedBox(height: 16),
//                     // New Password Field
//                     TextField(
//                       controller: _newPasswordController,
//                       obscureText: _obscureNewPassword,
//                       decoration: InputDecoration(
//                         prefixIcon: Icon(Icons.lock_outline, color: orange),
//                         labelText: 'New Password',
//                         labelStyle: GoogleFonts.poppins(color: Colors.grey[600]),
//                         enabledBorder: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(12),
//                           borderSide: BorderSide(color: orange, width: 1.5),
//                         ),
//                         focusedBorder: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(12),
//                           borderSide: BorderSide(color: orange, width: 2),
//                         ),
//                         contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
//                         suffixIcon: IconButton(
//                           icon: Icon(_obscureNewPassword ? Icons.visibility_off : Icons.visibility, color: orange),
//                           onPressed: () => setState(() => _obscureNewPassword = !_obscureNewPassword),
//                         ),
//                       ),
//                       onChanged: _checkPasswordStrength,
//                     ),
//                     // Password Strength Indicators
//                     const SizedBox(height: 12),
//                     Container(
//                       padding: const EdgeInsets.all(12),
//                       decoration: BoxDecoration(
//                         color: Colors.grey[50],
//                         borderRadius: BorderRadius.circular(8),
//                         border: Border.all(color: Colors.grey[200]!),
//                       ),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             'Password Requirements:',
//                             style: GoogleFonts.poppins(
//                               fontSize: 12,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.black87,
//                             ),
//                           ),
//                           const SizedBox(height: 8),
//                           _buildRequirementRow('Minimum 8 characters', _hasMinLength),
//                           _buildRequirementRow('At least 1 uppercase letter', _hasUppercase),
//                           _buildRequirementRow('At least 1 lowercase letter', _hasLowercase),
//                           _buildRequirementRow('At least 1 number', _hasNumber),
//                           _buildRequirementRow('At least 1 special character [e.g. !@#%^&*(),.?":{}|<> ]', _hasSpecialChar),
//                         ],
//                       ),
//                     ),
//                     const SizedBox(height: 16),
//                     // Confirm Password Field
//                     TextField(
//                       controller: _confirmPasswordController,
//                       obscureText: _obscureConfirmPassword,
//                       decoration: InputDecoration(
//                         prefixIcon: Icon(Icons.lock_outline, color: orange),
//                         labelText: 'Confirm New Password',
//                         labelStyle: GoogleFonts.poppins(color: Colors.grey[600]),
//                         enabledBorder: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(12),
//                           borderSide: BorderSide(color: orange, width: 1.5),
//                         ),
//                         focusedBorder: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(12),
//                           borderSide: BorderSide(color: orange, width: 2),
//                         ),
//                         contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
//                         suffixIcon: IconButton(
//                           icon: Icon(_obscureConfirmPassword ? Icons.visibility_off : Icons.visibility, color: orange),
//                           onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 24),
//                     // Update Password Button
//                     SizedBox(
//                       width: double.infinity,
//                       child: ElevatedButton(
//                         onPressed: _isLoading ? null : _updatePassword,
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: orange,
//                           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                         ),
//                         child: _isLoading
//                             ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
//                             : Text('Update Password', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
//                       ),
//                     ),
//                   ],
//                 ),
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

// ---

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final Color orange = const Color(0xFFF5A623);
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  bool _credentialsValidated = false;
  String? _newPassword;

  // Password strength indicators
  bool _hasMinLength = false;
  bool _hasUppercase = false;
  bool _hasLowercase = false;
  bool _hasNumber = false;
  bool _hasSpecialChar = false;

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
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
    });
  }

  bool _isPasswordValid() {
    return _hasMinLength &&
           _hasUppercase &&
           _hasLowercase &&
           _hasNumber &&
           _hasSpecialChar;
  }

  Future<void> _validateCredentials() async {
    setState(() { _isLoading = true; });
    final email = _emailController.text.trim();
                          //  await Supabase.instance.client.auth.resetPasswordForEmail(email);
    final phone = _phoneController.text.trim();

    if (email.isEmpty || phone.isEmpty) {
      _showSnackBar('Please enter both email and contact number.', isError: true);
      setState(() { _isLoading = false; });
      return;
    }

    try {
      // Query Supabase to check if a user with this email and phone exists
      // Replace 'phone' with the correct column name if it's different in your table
      final response = await Supabase.instance.client
          .from('users')
          .select()
          .eq('email', email)
          .eq('contact_number', phone)
          .maybeSingle();

      if (response != null) {
        setState(() {
          _credentialsValidated = true;
        });
        _showSnackBar('Credentials validated successfully!');
      } else {
        _showSnackBar('Invalid email or contact number.', isError: true);
      }
    } catch (e) {
      _showSnackBar('Error validating credentials: ${e.toString()}', isError: true);
    } finally {
      setState(() { _isLoading = false; });
    }
  }

  // Future<void> _sendPasswordResetLink() async {
  //   final email = _emailController.text.trim();
  //   _newPassword = _newPasswordController.text;

  //   if (email.isEmpty || _newPassword!.isEmpty) {
  //     _showSnackBar('Please enter your email and new password.', isError: true);
  //     return;
  //   }

  //   if (!_isPasswordValid()) {
  //     _showSnackBar('Please ensure your new password meets all requirements.', isError: true);
  //     return;
  //   }

  //   setState(() { _isLoading = true; });

  //   try {
  //     await Supabase.instance.client.auth.resetPasswordForEmail(email);
  //     _showSnackBar('Password reset link sent to your email!', isError: false);

  //     // Navigate to a confirmation page or show a dialog
  //     await Future.delayed(const Duration(seconds: 2));
  //     if (mounted) {
  //       Navigator.pushNamedAndRemoveUntil(
  //         context,
  //         '/login',
  //         (route) => false,
  //       );
  //     }
  //   } catch (e) {
  //     _showSnackBar('Error sending reset link: ${e.toString()}', isError: true);
  //   } finally {
  //     setState(() { _isLoading = false; });
  //   }
  // }


Future<void> _updatePassword() async {
  // _newPassword = _newPasswordController.text;
  // final confirmPassword = _confirmPasswordController.text;
  // final email = _emailController.text; 
  final email = _emailController.text.trim();  
final confirmPassword = _confirmPasswordController.text.trim();  
_newPassword = _newPasswordController.text.trim();


  if (_newPassword!.isEmpty || confirmPassword.isEmpty || email.isEmpty) {
    _showSnackBar('Please complete all fields.', isError: true);
    return;
  }

  if (_newPassword != confirmPassword) {
    _showSnackBar('Passwords do not match.', isError: true);
    return;
  }

  if (!_isPasswordValid()) {
    _showSnackBar('Please ensure your new password meets all requirements.', isError: true);
    return;
  }

  setState(() { _isLoading = true; });



 // 🔹 30-DAY COOLDOWN CHECK (insert here)
  final user = Supabase.instance.client.auth.currentUser;
  if (user != null) {
    final response = await Supabase.instance.client
        .from('users')
        .select('last_password_reset')
        .eq('id', user.id)
        .maybeSingle();

    if (response != null && response['last_password_reset'] != null) {
      final lastReset = DateTime.parse(response['last_password_reset']);
      final now = DateTime.now();
      final difference = now.difference(lastReset).inDays;

      if (difference < 30) {
        _showSnackBar(
          'You can only reset your password every 30 days. Please try again in ${30 - difference} day(s).',
          isError: true,
        );
        return; // ⛔ stop here
      }
    }
  }

  try {
    // 1️⃣ Send reset link to email
    await Supabase.instance.client.auth.resetPasswordForEmail(email);


    // 2️⃣ Update password directly inside app
    await Supabase.instance.client.auth.updateUser(
      UserAttributes(password: _newPassword!),
    );

     // 3️⃣ Update last_password_reset in users table
  final user = Supabase.instance.client.auth.currentUser;
  if (user != null) {
    await Supabase.instance.client
        .from('users')
        .update({'last_password_reset': DateTime.now().toIso8601String()})
        .eq('id', user.id);
  }

    _showSnackBar(
      'Password updated successfully! A reset link has also been sent to your email.',
      isError: false,
    );

    // Redirect to login
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  } catch (e) {
    _showSnackBar('Error: ${e.toString()}', isError: true);
  } finally {
    setState(() { _isLoading = false; });
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: BackButton(color: orange),
        title: Text('Reset Password', style: GoogleFonts.poppins(color: orange, fontWeight: FontWeight.w600)),
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
              Text('Reset Password', style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: orange)),
              const SizedBox(height: 8),
              Text('Step 1: Verify your credentials', style: GoogleFonts.poppins(color: Colors.grey[500])),
              const SizedBox(height: 24),
              // Email Field
              TextField(
                controller: _emailController,
                enabled: !_credentialsValidated,
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
                  disabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[400]!, width: 1.5),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                  filled: _credentialsValidated,
                  fillColor: _credentialsValidated ? Colors.grey[100]! : null,
                ),
              ),
              const SizedBox(height: 16),
              // Phone Field
              TextField(
                controller: _phoneController,
                enabled: !_credentialsValidated,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.phone_outlined, color: orange),
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
                  disabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[400]!, width: 1.5),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                  filled: _credentialsValidated,
                  fillColor: _credentialsValidated ? Colors.grey[100]! : null,
                ),
              ),
              const SizedBox(height: 16),
              // Validate Credentials Button
              if (!_credentialsValidated)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _validateCredentials,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: orange,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _isLoading
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : Text('Verify Credentials', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
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
                              'Credentials verified successfully!',
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
                    // Update Password Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        // onPressed: _isLoading ? null : _sendPasswordResetLink,
                        onPressed: _isLoading ? null : _updatePassword,

                        style: ElevatedButton.styleFrom(
                          backgroundColor: orange,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: _isLoading
                            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : Text('Update Password', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
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
