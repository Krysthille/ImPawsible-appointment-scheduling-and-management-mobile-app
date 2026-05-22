import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'services/auth_service.dart';
import 'utils/network_utils.dart';
import 'config/supabase_config.dart';
import 'dart:async'; // Added for Timer
import 'package:supabase_flutter/supabase_flutter.dart'; // Added for Supabase

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final Color orange = const Color(0xFFF5A623);

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;
  int _loginAttempts = 0;
  bool _isCooldownActive = false;
  Timer? _cooldownTimer;

  late final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    _cooldownTimer?.cancel();
    super.dispose();
  }



  void _startCooldown() {
    setState(() {
      _isCooldownActive = true;
    });
    
    _cooldownTimer = Timer(const Duration(seconds: 30), () {
      if (mounted) {
        setState(() {
          _isCooldownActive = false;
          _loginAttempts = 0;
        });
      }
    });
  }

  void _dismissKeyboard() {
    FocusScope.of(context).unfocus();
  }

  Future<void> _showSnackBar(String message, {bool isError = true}) async {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.poppins()),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  Future<void> _handleLogin() async {
    if (_isCooldownActive) {
      return _showSnackBar('Please wait before trying again.');
    }

    final email = emailController.text.trim();
    final password = passwordController.text;

    if ([email, password].any((field) => field.isEmpty)) {
      return _showSnackBar('Please fill in all fields.');
    }

    final hasInternet = await NetworkUtils().hasInternetConnection();
    if (!hasInternet) {
      return _showSnackBar('No internet connection.');
    }

    setState(() => _isLoading = true);

    try {
      if (!SupabaseConfig.isInitialized) {
        await SupabaseConfig.initialize();
      }
      final response =
          await _authService.signIn(email: email, password: password);
      if (response.user != null && mounted) {
        // Reset login attempts on successful login
        _loginAttempts = 0;

        _showSnackBar('Login successful!', isError: false);

        // Check if user is admin
        final isAdmin = await _authService.isAdmin();

        // Log admin login if user is admin
        if (isAdmin) {
          await _logAdminLogin();
        }

        // Redirect based on role
        if (isAdmin) {
          Navigator.pushNamedAndRemoveUntil(
              context, '/home_admin', (_) => false);
        } else {
          Navigator.pushNamedAndRemoveUntil(context, '/home', (_) => false);
        }
      } else {
        _handleFailedLogin();
      }
    } catch (e) {
      _handleFailedLogin();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _handleFailedLogin() {
    _loginAttempts++;
    
    if (_loginAttempts >= 3) {
      _startCooldown();
      _showSnackBar('Too many failed attempts. Please try again in 30 seconds.');
    } else {
      final errorMessage = 'Login failed. Please check your credentials.';
      _showSnackBar(errorMessage);
    }
  }

  // Add function to log admin login with correct local time
  Future<void> _logAdminLogin() async {
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;
      if (user != null) {
        // Get admin profile
        final profileResponse = await supabase
            .from('users')
            .select('full_name')
            .eq('id', user.id)
            .maybeSingle();
        
        final adminName = profileResponse?['full_name'] ?? 'Admin User';
        final now = DateTime.now(); // Use local time
        
        // Format the time in local timezone
        final loginData = {
          'user_id': user.id,
          'admin_name': adminName,
          'login_date': '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}',
          'login_time': '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}',
          'timestamp': now.toIso8601String(), // This will be in local time
        };
        
        await supabase.from('login_history').insert(loginData);
        print('Admin login logged successfully at ${now.hour}:${now.minute}');
      }
    } catch (e) {
      print('Error logging admin login: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenHeight < 700;
    
    return GestureDetector(
      onTap: _dismissKeyboard,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: BackButton(color: orange),
          title: Text('Login',
              style: GoogleFonts.poppins(
                  color: orange, fontWeight: FontWeight.w600)),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: isSmallScreen ? 16.0 : 24.0,
            ),
            child: Column(
              children: [
                SizedBox(height: isSmallScreen ? 8 : 12),
                Image.asset(
                  'assets/images/logo1.png', 
                  height: isSmallScreen ? 100 : 130,
                ),
                SizedBox(height: isSmallScreen ? 16 : 24),
                Text(
                  'Welcome Back!',
                  style: GoogleFonts.poppins(
                    fontSize: isSmallScreen ? 20 : 24, 
                    fontWeight: FontWeight.bold, 
                    color: orange,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Sign in to continue',
                  style: GoogleFonts.poppins(color: Colors.grey[500]),
                ),
                SizedBox(height: isSmallScreen ? 24 : 32),
                _buildTextField(
                  controller: emailController,
                  label: 'Email',
                  icon: Icons.mail_outline,
                ),
                SizedBox(height: isSmallScreen ? 16 : 20),
                _buildTextField(
                  controller: passwordController,
                  label: 'Password',
                  icon: Icons.lock_outline,
                  obscureText: _obscurePassword,
                  toggleVisibility: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
                SizedBox(height: isSmallScreen ? 20 : 28),
                _buildLoginButton(),
                if (_isCooldownActive) ...[
                  // const SizedBox(height: 12),
                  // Text(
                  //   'Try again in 30 seconds',
                  //   style: GoogleFonts.poppins(
                  //     color: Colors.red,
                  //     fontSize: 12,
                  //     fontWeight: FontWeight.w500,
                  //   ),
                  // ),
                ],
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/reset_password'),
                  child: Text(
                    'Forgot Password?',
                    style: GoogleFonts.poppins(
                      color: orange, 
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                // SizedBox(height:20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: GoogleFonts.poppins(color: Colors.grey[500]),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pushNamedAndRemoveUntil(
                          context, '/signup', (_) => false),
                      child: Text(
                        'Sign Up',
                        style: GoogleFonts.poppins(
                          color: orange, 
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 16),
                // Terms and Privacy Policy
                // RichText(
                //   textAlign: TextAlign.center,
                //   text: TextSpan(
                //     style: GoogleFonts.poppins(
                //       color: Colors.grey[600],
                //       fontSize: 12,
                //     ),
                //     children: [
                //       const TextSpan(text: 'By continuing, you agree to our '),
                //       WidgetSpan(
                //         child: GestureDetector(
                //           onTap: () {
                //             // Navigate to Terms page
                //             // Navigator.pushNamed(context, '/terms');
                //           },
                //           child: Text(
                //             'Terms',
                //             style: GoogleFonts.poppins(
                //               color: orange,
                //               fontWeight: FontWeight.w600,
                //               fontSize: 12,
                //             ),
                //           ),
                //         ),
                //       ),
                //       const TextSpan(text: ' and '),
                //       WidgetSpan(
                //         child: GestureDetector(
                //           onTap: () {
                //             // Navigate to Privacy Policy page
                //             // Navigator.pushNamed(context, '/privacy');
                //           },
                //           child: Text(
                //             'Privacy Policy',
                //             style: GoogleFonts.poppins(
                //               color: orange,
                //               fontWeight: FontWeight.w600,
                //               fontSize: 12,
                //             ),
                //           ),
                //         ),
                //       ),
                //     ],
                //   ),
                // ),
                // SizedBox(height: isSmallScreen ? 16 : 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    VoidCallback? toggleVisibility,
    ValueChanged<String>? onChanged,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      onChanged: onChanged,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: orange),
        labelText: label,
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
        suffixIcon: toggleVisibility != null
            ? IconButton(
                icon: Icon(
                  obscureText ? Icons.visibility_off : Icons.visibility,
                  color: orange,
                ),
                onPressed: toggleVisibility,
              )
            : null,
      ),
    );
  }

  Widget _buildLoginButton() {
    final isDisabled = _isLoading || _isCooldownActive;
    
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isDisabled ? null : _handleLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: isDisabled ? Colors.grey : orange,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: isDisabled ? 0 : 2,
        ),
        child: _isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2))
            : Text(
                _isCooldownActive ? 'Login Disabled' : 'Login',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}

// ---

// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'services/auth_service.dart';
// import 'utils/network_utils.dart';
// import 'config/supabase_config.dart';
// import 'dart:async';
// import 'package:supabase_flutter/supabase_flutter.dart';

// class LoginPage extends StatefulWidget {
//   const LoginPage({super.key});

//   @override
//   State<LoginPage> createState() => _LoginPageState();
// }

// class _LoginPageState extends State<LoginPage> {
//   final Color orange = const Color(0xFFF5A623);
//   final TextEditingController emailController = TextEditingController();
//   final TextEditingController passwordController = TextEditingController();
//   bool _obscurePassword = true;
//   bool _isLoading = false;
//   int _loginAttempts = 0;
//   bool _isCooldownActive = false;
//   Timer? _cooldownTimer;
//   late final AuthService _authService = AuthService();
//   final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

//   @override
//   void initState() {
//     super.initState();
//   }

//   @override
//   void dispose() {
//     emailController.dispose();
//     passwordController.dispose();
//     _cooldownTimer?.cancel();
//     super.dispose();
//   }

//   Future<void> _handleRefresh() async {
//     // Recheck network connection
//     final hasInternet = await NetworkUtils().hasInternetConnection();
//     if (!hasInternet) {
//       _showSnackBar('No internet connection.');
//     } else {
//       _showSnackBar('Network connection is active.', isError: false);
//     }
//   }

//   void _startCooldown() {
//     setState(() {
//       _isCooldownActive = true;
//     });
//     _cooldownTimer = Timer(const Duration(seconds: 30), () {
//       if (mounted) {
//         setState(() {
//           _isCooldownActive = false;
//           _loginAttempts = 0;
//         });
//       }
//     });
//   }

//   void _dismissKeyboard() {
//     FocusScope.of(context).unfocus();
//   }

//   Future<void> _showSnackBar(String message, {bool isError = true}) async {
//     if (!mounted) return;
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message, style: GoogleFonts.poppins()),
//         backgroundColor: isError ? Colors.red : Colors.green,
//       ),
//     );
//   }

//   Future<void> _handleLogin() async {
//     if (_isCooldownActive) {
//       return _showSnackBar('Please wait before trying again.');
//     }
//     final email = emailController.text.trim();
//     final password = passwordController.text;
//     if ([email, password].any((field) => field.isEmpty)) {
//       return _showSnackBar('Please fill in all fields.');
//     }
//     final hasInternet = await NetworkUtils().hasInternetConnection();
//     if (!hasInternet) {
//       return _showSnackBar('No internet connection.');
//     }
//     setState(() => _isLoading = true);
//     try {
//       if (!SupabaseConfig.isInitialized) {
//         await SupabaseConfig.initialize();
//       }
//       final response =
//           await _authService.signIn(email: email, password: password);
//       if (response.user != null && mounted) {
//         _loginAttempts = 0;
//         _showSnackBar('Login successful!', isError: false);
//         final isAdmin = await _authService.isAdmin();
//         if (isAdmin) {
//           await _logAdminLogin();
//         }
//         if (isAdmin) {
//           Navigator.pushNamedAndRemoveUntil(
//               context, '/home_admin', (_) => false);
//         } else {
//           Navigator.pushNamedAndRemoveUntil(context, '/home', (_) => false);
//         }
//       } else {
//         _handleFailedLogin();
//       }
//     } catch (e) {
//       _handleFailedLogin();
//     } finally {
//       if (mounted) setState(() => _isLoading = false);
//     }
//   }

//   void _handleFailedLogin() {
//     _loginAttempts++;
//     if (_loginAttempts >= 3) {
//       _startCooldown();
//       _showSnackBar('Too many failed attempts. Please try again in 30 seconds.');
//     } else {
//       final errorMessage = 'Login failed. Please check your credentials.';
//       _showSnackBar(errorMessage);
//     }
//   }

//   Future<void> _logAdminLogin() async {
//     try {
//       final supabase = Supabase.instance.client;
//       final user = supabase.auth.currentUser;
//       if (user != null) {
//         final profileResponse = await supabase
//             .from('users')
//             .select('full_name')
//             .eq('id', user.id)
//             .maybeSingle();
//         final adminName = profileResponse?['full_name'] ?? 'Admin User';
//         final now = DateTime.now();
//         final loginData = {
//           'user_id': user.id,
//           'admin_name': adminName,
//           'login_date': '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}',
//           'login_time': '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}',
//           'timestamp': now.toIso8601String(),
//         };
//         await supabase.from('login_history').insert(loginData);
//         print('Admin login logged successfully at ${now.hour}:${now.minute}');
//       }
//     } catch (e) {
//       print('Error logging admin login: $e');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final screenHeight = MediaQuery.of(context).size.height;
//     final isSmallScreen = screenHeight < 700;

//     return GestureDetector(
//       onTap: _dismissKeyboard,
//       child: Scaffold(
//         key: _scaffoldKey,
//         backgroundColor: Colors.white,
//         appBar: AppBar(
//           backgroundColor: Colors.white,
//           elevation: 0,
//           leading: BackButton(color: orange),
//           title: Text('Login',
//               style: GoogleFonts.poppins(
//                   color: orange, fontWeight: FontWeight.w600)),
//         ),
//         body: SafeArea(
//           child: RefreshIndicator(
//             color: orange,
//             onRefresh: _handleRefresh,
//             child: SingleChildScrollView(
//               physics: const AlwaysScrollableScrollPhysics(),
//               padding: EdgeInsets.symmetric(
//                 horizontal: 24.0,
//                 vertical: isSmallScreen ? 16.0 : 24.0,
//               ),
//               child: Column(
//                 children: [
//                   SizedBox(height: isSmallScreen ? 8 : 12),
//                   Image.asset(
//                     'assets/images/logo1.png',
//                     height: isSmallScreen ? 100 : 130,
//                   ),
//                   SizedBox(height: isSmallScreen ? 16 : 24),
//                   Text(
//                     'Welcome Back!',
//                     style: GoogleFonts.poppins(
//                       fontSize: isSmallScreen ? 20 : 24,
//                       fontWeight: FontWeight.bold,
//                       color: orange,
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     'Sign in to continue',
//                     style: GoogleFonts.poppins(color: Colors.grey[500]),
//                   ),
//                   SizedBox(height: isSmallScreen ? 24 : 32),
//                   _buildTextField(
//                     controller: emailController,
//                     label: 'Email',
//                     icon: Icons.mail_outline,
//                   ),
//                   SizedBox(height: isSmallScreen ? 16 : 20),
//                   _buildTextField(
//                     controller: passwordController,
//                     label: 'Password',
//                     icon: Icons.lock_outline,
//                     obscureText: _obscurePassword,
//                     toggleVisibility: () =>
//                         setState(() => _obscurePassword = !_obscurePassword),
//                   ),
//                   SizedBox(height: isSmallScreen ? 20 : 28),
//                   _buildLoginButton(),
//                   if (_isCooldownActive) ...[
//                     const SizedBox(height: 12),
//                     Text(
//                       'Try again in 30 seconds',
//                       style: GoogleFonts.poppins(
//                         color: Colors.red,
//                         fontSize: 12,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                   ],
//                   const SizedBox(height: 16),
//                   TextButton(
//                     onPressed: () => Navigator.pushNamed(context, '/reset_password'),
//                     child: Text(
//                       'Forgot Password?',
//                       style: GoogleFonts.poppins(
//                         color: orange,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                   ),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Text(
//                         "Don't have an account? ",
//                         style: GoogleFonts.poppins(color: Colors.grey[500]),
//                       ),
//                       GestureDetector(
//                         onTap: () => Navigator.pushNamedAndRemoveUntil(
//                             context, '/signup', (_) => false),
//                         child: Text(
//                           'Sign Up',
//                           style: GoogleFonts.poppins(
//                             color: orange,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                       )
//                     ],
//                   ),
//                   const SizedBox(height: 50),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildTextField({
//     required TextEditingController controller,
//     required String label,
//     required IconData icon,
//     bool obscureText = false,
//     VoidCallback? toggleVisibility,
//     ValueChanged<String>? onChanged,
//   }) {
//     return TextField(
//       controller: controller,
//       obscureText: obscureText,
//       onChanged: onChanged,
//       decoration: InputDecoration(
//         prefixIcon: Icon(icon, color: orange),
//         labelText: label,
//         labelStyle: GoogleFonts.poppins(color: Colors.grey[600]),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: BorderSide(color: orange, width: 1.5),
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: BorderSide(color: orange, width: 2),
//         ),
//         contentPadding:
//             const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
//         suffixIcon: toggleVisibility != null
//             ? IconButton(
//                 icon: Icon(
//                   obscureText ? Icons.visibility_off : Icons.visibility,
//                   color: orange,
//                 ),
//                 onPressed: toggleVisibility,
//               )
//             : null,
//       ),
//     );
//   }

//   Widget _buildLoginButton() {
//     final isDisabled = _isLoading || _isCooldownActive;
//     return SizedBox(
//       width: double.infinity,
//       child: ElevatedButton(
//         onPressed: isDisabled ? null : _handleLogin,
//         style: ElevatedButton.styleFrom(
//           backgroundColor: isDisabled ? Colors.grey : orange,
//           padding: const EdgeInsets.symmetric(vertical: 16),
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//           elevation: isDisabled ? 0 : 2,
//         ),
//         child: _isLoading
//             ? const SizedBox(
//                 height: 20,
//                 width: 20,
//                 child: CircularProgressIndicator(
//                     color: Colors.white, strokeWidth: 2))
//             : Text(
//                 _isCooldownActive ? 'Login Disabled' : 'Login',
//                 style: GoogleFonts.poppins(
//                   fontSize: 18,
//                   color: Colors.white,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//       ),
//     );
//   }
// }

