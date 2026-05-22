// // import 'package:flutter/material.dart';
// // import 'package:google_fonts/google_fonts.dart';
// // import 'package:supabase_flutter/supabase_flutter.dart';
// // import '../config/supabase_config.dart';
// // import 'home_admin.dart';

// // class AllUsersAdminPage extends StatefulWidget {
// //   const AllUsersAdminPage({Key? key}) : super(key: key);

// //   @override
// //   State<AllUsersAdminPage> createState() => _AllUsersAdminPageState();
// // }

// // class _AllUsersAdminPageState extends State<AllUsersAdminPage> {
// //   List<Map<String, dynamic>> _users = [];
// //   bool _isLoading = true;
// //   String _searchQuery = '';
// //   bool _sortByNameAsc = true;
// //   bool _sortByDateAsc = false;
// //   String _selectedRole = 'all'; // Changed default to 'all' to show all users
// //   final ScrollController _scrollController = ScrollController();
// //   bool _showScrollToTop = false;

// //   @override
// //   void initState() {
// //     super.initState();
// //     _fetchUsers();
// //     _scrollController.addListener(_onScroll);
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

// //   Future<void> _fetchUsers() async {
// //     setState(() {
// //       _isLoading = true;
// //     });
    
// //     try {
// //       print('Fetching users from Supabase...');
// //       final response = await SupabaseConfig.client
// //           .from('users')
// //           .select('*')
// //           .order('created_at', ascending: false);
      
// //       print('Raw response: $response');
      
// //       if (response is List) {
// //         setState(() {
// //           _users = List<Map<String, dynamic>>.from(response);
// //         });
// //         print('Successfully loaded ${_users.length} users');
// //         print('Users: ${_users.map((u) => '${u['full_name']} (${u['role']})').toList()}');
// //       } else {
// //         print('Response is not a List: ${response.runtimeType}');
// //         setState(() {
// //           _users = [];
// //         });
// //       }
// //     } catch (e) {
// //       print('Error fetching users: $e');
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         SnackBar(
// //           content: Text('Error fetching users: $e'),
// //           backgroundColor: Colors.red,
// //         ),
// //       );
// //       setState(() {
// //         _users = [];
// //       });
// //     } finally {
// //       setState(() {
// //         _isLoading = false;
// //       });
// //     }
// //   }

// //   void _sortByName() {
// //     setState(() {
// //       _sortByNameAsc = !_sortByNameAsc;
// //       _users.sort((a, b) {
// //         final nameA = (a['full_name'] ?? '').toString().toLowerCase();
// //         final nameB = (b['full_name'] ?? '').toString().toLowerCase();
// //         return _sortByNameAsc ? nameA.compareTo(nameB) : nameB.compareTo(nameA);
// //       });
// //     });
// //   }

// //   void _sortByDate() {
// //     setState(() {
// //       _sortByDateAsc = !_sortByDateAsc;
// //       _users.sort((a, b) {
// //         final dateA = DateTime.tryParse(a['created_at'] ?? '') ?? DateTime(2000);
// //         final dateB = DateTime.tryParse(b['created_at'] ?? '') ?? DateTime(2000);
// //         return _sortByDateAsc ? dateA.compareTo(dateB) : dateB.compareTo(dateA);
// //       });
// //     });
// //   }

// //   List<Map<String, dynamic>> get _filteredUsers {
// //     List<Map<String, dynamic>> filteredUsers = _users;
    
// //     // Filter by role
// //     if (_selectedRole != 'all') {
// //       filteredUsers = filteredUsers.where((user) => 
// //         (user['role'] ?? '').toString().toLowerCase() == _selectedRole.toLowerCase()
// //       ).toList();
// //     }
    
// //     // Filter by search query
// //     if (_searchQuery.isNotEmpty) {
// //       final query = _searchQuery.toLowerCase();
// //       filteredUsers = filteredUsers.where((user) {
// //         return (user['full_name'] ?? '').toString().toLowerCase().contains(query) ||
// //             (user['email'] ?? '').toString().toLowerCase().contains(query) ||
// //             (user['contact_number'] ?? '').toString().toLowerCase().contains(query) ||
// //             (user['role'] ?? '').toString().toLowerCase().contains(query);
// //       }).toList();
// //     }
    
// //     return filteredUsers;
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     final orange = const Color(0xFFF5A623);
// //     final blue = const Color(0xFF5094FF);
// //     return Scaffold(
// //       backgroundColor: Colors.white,
// //       appBar: AppBar(
// //         backgroundColor: const Color(0xFFFFF6E7),
// //         elevation: 0,
// //         iconTheme: const IconThemeData(color: Colors.black87),
// //         title: Text(
// //           'All Users',
// //           style: GoogleFonts.poppins(
// //             fontWeight: FontWeight.bold,
// //             color: orange,
// //           ),
// //         ),
// //         leading: IconButton(
// //           icon: const Icon(Icons.arrow_back),
// //           onPressed: () {
// //             Navigator.pop(context);
// //           },
// //         ),
// //         actions: [
// //           IconButton(
// //             icon: Icon(Icons.refresh, color: orange),
// //             onPressed: _fetchUsers,
// //           ),
// //         ],
// //       ),
// //       body: SafeArea(
// //         child: Padding(
// //           padding: const EdgeInsets.all(16.0),
// //           child: Column(
// //             crossAxisAlignment: CrossAxisAlignment.start,
// //             children: [
// //               TextField(
// //                 decoration: InputDecoration(
// //                   hintText: 'Search users',
// //                   hintStyle: TextStyle(fontSize: 14, color: Colors.grey[500]),
// //                   prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
// //                   suffixIcon: _searchQuery.isNotEmpty
// //                       ? IconButton(
// //                           icon: Icon(Icons.clear, color: Colors.grey[400]),
// //                           onPressed: () {
// //                             setState(() {
// //                               _searchQuery = '';
// //                             });
// //                             FocusScope.of(context).unfocus();
// //                           },
// //                         )
// //                       : null,
// //                   filled: true,
// //                   fillColor: Colors.grey[100],
// //                   contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
// //                   border: OutlineInputBorder(
// //                     borderRadius: BorderRadius.circular(12),
// //                     borderSide: BorderSide.none,
// //                   ),
// //                 ),
// //                 onChanged: (value) {
// //                   setState(() {
// //                     _searchQuery = value;
// //                   });
// //                 },
// //               ),
// //               const SizedBox(height: 16),
// //               // Role toggle and sort button in same row
// //               Row(
// //                 children: [
// //                   GestureDetector(
// //                     onTap: () {
// //                       setState(() {
// //                         _selectedRole = 'all';
// //                       });
// //                     },
// //                     child: Container(
// //                       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
// //                       decoration: BoxDecoration(
// //                         color: _selectedRole == 'all' ? Colors.grey[600] : Colors.transparent,
// //                         borderRadius: BorderRadius.circular(8),
// //                         border: Border.all(color: Colors.grey[600]!, width: 1.2),
// //                       ),
// //                       child: Text(
// //                         'All',
// //                         style: GoogleFonts.poppins(
// //                           color: _selectedRole == 'all' ? Colors.white : Colors.grey[600],
// //                           fontWeight: FontWeight.bold,
// //                         ),
// //                       ),
// //                     ),
// //                   ),
// //                   const SizedBox(width: 8),
// //                   GestureDetector(
// //                     onTap: () {
// //                       setState(() {
// //                         _selectedRole = 'user';
// //                       });
// //                     },
// //                     child: Container(
// //                       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
// //                       decoration: BoxDecoration(
// //                         color: _selectedRole == 'user' ? orange : Colors.transparent,
// //                         borderRadius: BorderRadius.circular(8),
// //                         border: Border.all(color: orange, width: 1.2),
// //                       ),
// //                       child: Text(
// //                         'User',
// //                         style: GoogleFonts.poppins(
// //                           color: _selectedRole == 'user' ? Colors.white : orange,
// //                           fontWeight: FontWeight.bold,
// //                         ),
// //                       ),
// //                     ),
// //                   ),
// //                   const SizedBox(width: 8),
// //                   GestureDetector(
// //                     onTap: () {
// //                       setState(() {
// //                         _selectedRole = 'admin';
// //                       });
// //                     },
// //                     child: Container(
// //                       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
// //                       decoration: BoxDecoration(
// //                         color: _selectedRole == 'admin' ? blue : Colors.transparent,
// //                         borderRadius: BorderRadius.circular(8),
// //                         border: Border.all(color: blue, width: 1.2),
// //                       ),
// //                       child: Text(
// //                         'Admin',
// //                         style: GoogleFonts.poppins(
// //                           color: _selectedRole == 'admin' ? Colors.white : blue,
// //                           fontWeight: FontWeight.bold,
// //                         ),
// //                       ),
// //                     ),
// //                   ),
// //                   const Spacer(),
// //                   PopupMenuButton<String>(
// //                     onSelected: (value) {
// //                       if (value == 'name_asc') {
// //                         setState(() {
// //                           _sortByNameAsc = true;
// //                           _users.sort((a, b) {
// //                             final nameA = (a['full_name'] ?? '').toString().toLowerCase();
// //                             final nameB = (b['full_name'] ?? '').toString().toLowerCase();
// //                             return nameA.compareTo(nameB);
// //                           });
// //                         });
// //                       } else if (value == 'name_desc') {
// //                         setState(() {
// //                           _sortByNameAsc = false;
// //                           _users.sort((a, b) {
// //                             final nameA = (a['full_name'] ?? '').toString().toLowerCase();
// //                             final nameB = (b['full_name'] ?? '').toString().toLowerCase();
// //                             return nameB.compareTo(nameA);
// //                           });
// //                         });
// //                       } else if (value == 'date_asc') {
// //                         setState(() {
// //                           _sortByDateAsc = true;
// //                           _users.sort((a, b) {
// //                             final dateA = DateTime.tryParse(a['created_at'] ?? '') ?? DateTime(2000);
// //                             final dateB = DateTime.tryParse(b['created_at'] ?? '') ?? DateTime(2000);
// //                             return dateA.compareTo(dateB);
// //                           });
// //                         });
// //                       } else if (value == 'date_desc') {
// //                         setState(() {
// //                           _sortByDateAsc = false;
// //                           _users.sort((a, b) {
// //                             final dateA = DateTime.tryParse(a['created_at'] ?? '') ?? DateTime(2000);
// //                             final dateB = DateTime.tryParse(b['created_at'] ?? '') ?? DateTime(2000);
// //                             return dateB.compareTo(dateA);
// //                           });
// //                         });
// //                       }
// //                     },
// //                     itemBuilder: (context) => [
// //                       PopupMenuItem(
// //                         value: 'name_asc',
// //                         child: Text('Name (A–Z)', style: GoogleFonts.poppins(fontSize: 13)),
// //                       ),
// //                       PopupMenuItem(
// //                         value: 'name_desc',
// //                         child: Text('Name (Z–A)', style: GoogleFonts.poppins(fontSize: 13)),
// //                       ),
// //                       PopupMenuItem(
// //                         value: 'date_asc',
// //                         child: Text('Date Joined (Oldest First)', style: GoogleFonts.poppins(fontSize: 13)),
// //                       ),
// //                       PopupMenuItem(
// //                         value: 'date_desc',
// //                         child: Text('Date Joined (Newest First)', style: GoogleFonts.poppins(fontSize: 13)),
// //                       ),
// //                     ],
// //                     child: Row(
// //                       children: [
// //                         Icon(Icons.sort, color: Colors.grey[600], size: 20),
// //                         const SizedBox(width: 4),
// //                         Text(
// //                           'Sort',
// //                           style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[600]),
// //                         ),
// //                       ],
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //               const SizedBox(height: 8),
// //               // User count display
// //               Padding(
// //                 padding: const EdgeInsets.symmetric(horizontal: 4.0),
// //                 child: Text(
// //                   '${_filteredUsers.length} ${_selectedRole == 'all' ? 'Total' : _selectedRole == 'user' ? 'User(s)' : 'Admin(s)'}',
// //                   style: GoogleFonts.poppins(
// //                     fontSize: 14,
// //                     color: Colors.grey[600],
// //                     fontWeight: FontWeight.w500,
// //                   ),
// //                 ),
// //               ),
// //               Expanded(
// //                 child: _isLoading
// //                     ? const Center(child: CircularProgressIndicator(color: Color(0xFFF5A623)))
// //                     : _filteredUsers.isEmpty
// //                         ? Center(
// //                             child: Column(
// //                               mainAxisAlignment: MainAxisAlignment.center,
// //                               children: [
// //                                 Icon(
// //                                   Icons.people_outline,
// //                                   size: 64,
// //                                   color: Colors.grey[400],
// //                                 ),
// //                                 const SizedBox(height: 16),
// //                                 Text(
// //                                   _users.isEmpty ? 'No users found in database.' : 'No users match your filters.',
// //                                   style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey[600]),
// //                                   textAlign: TextAlign.center,
// //                                 ),
// //                                 const SizedBox(height: 8),
// //                                 Text(
// //                                   'Total users loaded: ${_users.length}',
// //                                   style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[500]),
// //                                 ),
// //                               ],
// //                             ),
// //                           )
// //                         : ListView.separated(
// //                             controller: _scrollController,
// //                             itemCount: _filteredUsers.length,
// //                             separatorBuilder: (context, index) => const SizedBox(height: 12),
// //                             itemBuilder: (context, index) {
// //                               final user = _filteredUsers[index];
// //                               return Container(
// //                                 padding: const EdgeInsets.all(16),
// //                                 decoration: BoxDecoration(
// //                                   color: Colors.white,
// //                                   borderRadius: BorderRadius.circular(12),
// //                                   boxShadow: [
// //                                     BoxShadow(
// //                                       color: Colors.black.withOpacity(0.05),
// //                                       blurRadius: 6,
// //                                       offset: const Offset(0, 2),
// //                                     ),
// //                                   ],
// //                                 ),
// //                                 child: Column(
// //                                   crossAxisAlignment: CrossAxisAlignment.start,
// //                                   children: [
// //                                     Row(
// //                                       children: [
// //                                         Icon(Icons.person, color: orange, size: 28),
// //                                         const SizedBox(width: 12),
// //                                         Expanded(
// //                                           child: Text(
// //                                             user['full_name'] ?? '-',
// //                                             style: GoogleFonts.poppins(
// //                                               fontSize: 18,
// //                                               fontWeight: FontWeight.w600,
// //                                               color: Colors.black87,
// //                                             ),
// //                                           ),
// //                                         ),
// //                                         Container(
// //                                           padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
// //                                           decoration: BoxDecoration(
// //                                             color: user['role'] == 'admin' ? blue : Colors.transparent,
// //                                             border: user['role'] == 'user'
// //                                                 ? Border.all(color: orange, width: 1.2)
// //                                                 : null,
// //                                             borderRadius: BorderRadius.circular(8),
// //                                           ),
// //                                           child: Text(
// //                                             user['role'] ?? '-',
// //                                             style: GoogleFonts.poppins(
// //                                               fontSize: 12,
// //                                               fontWeight: FontWeight.w500,
// //                                               color: user['role'] == 'admin' ? Colors.white : orange,
// //                                             ),
// //                                           ),
// //                                         ),
// //                                       ],
// //                                     ),
// //                                     const SizedBox(height: 8),
// //                                     Row(
// //                                       children: [
// //                                         Icon(Icons.email, color: Colors.grey[400], size: 18),
// //                                         const SizedBox(width: 6),
// //                                         Expanded(
// //                                           child: Text(
// //                                             user['email'] ?? '-',
// //                                             style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[700]),
// //                                           ),
// //                                         ),
// //                                       ],
// //                                     ),
// //                                     const SizedBox(height: 4),
// //                                     Row(
// //                                       children: [
// //                                         Icon(Icons.phone, color: Colors.grey[400], size: 18),
// //                                         const SizedBox(width: 6),
// //                                         Expanded(
// //                                           child: Text(
// //                                             user['contact_number'] ?? '-',
// //                                             style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[700]),
// //                                           ),
// //                                         ),
// //                                       ],
// //                                     ),
// //                                     const SizedBox(height: 4),
// //                                     Row(
// //                                       children: [
// //                                         Icon(Icons.calendar_today, color: Colors.grey[400], size: 18),
// //                                         const SizedBox(width: 6),
// //                                         Expanded(
// //                                           child: Text(
// //                                             user['created_at'] != null
// //                                                 ? _formatDate(user['created_at'])
// //                                                 : '-',
// //                                             style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[700]),
// //                                           ),
// //                                         ),
// //                                       ],
// //                                     ),
// //                                   ],
// //                                 ),
// //                               );
// //                             },
// //                           ),
// //               ),
// //             ],
// //           ),
// //         ),
// //       ),
// //       floatingActionButton: _showScrollToTop
// //           ? FloatingActionButton(
// //               onPressed: _scrollToTop,
// //               backgroundColor: orange,
// //               foregroundColor: Colors.white,
// //               mini: true,
// //               child: const Icon(Icons.keyboard_arrow_up),
// //             )
// //           : null,
// //     );
// //   }

// //   String _formatDate(String dateStr) {
// //     try {
// //       final date = DateTime.parse(dateStr);
// //       return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
// //     } catch (e) {
// //       return dateStr;
// //     }
// //   }
// // } 

// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import '../config/supabase_config.dart';
// import 'home_admin.dart';

// class AllUsersAdminPage extends StatefulWidget {
//   const AllUsersAdminPage({Key? key}) : super(key: key);

//   @override
//   State<AllUsersAdminPage> createState() => _AllUsersAdminPageState();
// }

// class _AllUsersAdminPageState extends State<AllUsersAdminPage> {
//   List<Map<String, dynamic>> _users = [];
//   bool _isLoading = true;
//   String _searchQuery = '';
//   bool _sortByNameAsc = true;
//   bool _sortByDateAsc = false;
//   String _selectedRole = 'all';
//   final ScrollController _scrollController = ScrollController();
//   bool _showScrollToTop = false;

//   @override
//   void initState() {
//     super.initState();
//     _fetchUsers();
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

//   Future<void> _fetchUsers() async {
//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       print('Fetching users from Supabase...');
//       final response = await SupabaseConfig.client
//           .from('users')
//           .select('*')
//           .order('created_at', ascending: false);

//       print('Raw response: $response');

//       if (response is List) {
//         setState(() {
//           _users = List<Map<String, dynamic>>.from(response);
//         });
//         print('Successfully loaded ${_users.length} users');
//         print('Users: ${_users.map((u) => '${u['full_name']} (${u['role']})').toList()}');
//       } else {
//         print('Response is not a List: ${response.runtimeType}');
//         setState(() {
//           _users = [];
//         });
//       }
//     } catch (e) {
//       print('Error fetching users: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Error fetching users: $e'),
//           backgroundColor: Colors.red,
//         ),
//       );
//       setState(() {
//         _users = [];
//       });
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   Future<void> _handleRefresh() async {
//     await _fetchUsers();
//   }

//   void _sortByName() {
//     setState(() {
//       _sortByNameAsc = !_sortByNameAsc;
//       _users.sort((a, b) {
//         final nameA = (a['full_name'] ?? '').toString().toLowerCase();
//         final nameB = (b['full_name'] ?? '').toString().toLowerCase();
//         return _sortByNameAsc ? nameA.compareTo(nameB) : nameB.compareTo(nameA);
//       });
//     });
//   }

//   void _sortByDate() {
//     setState(() {
//       _sortByDateAsc = !_sortByDateAsc;
//       _users.sort((a, b) {
//         final dateA = DateTime.tryParse(a['created_at'] ?? '') ?? DateTime(2000);
//         final dateB = DateTime.tryParse(b['created_at'] ?? '') ?? DateTime(2000);
//         return _sortByDateAsc ? dateA.compareTo(dateB) : dateB.compareTo(dateA);
//       });
//     });
//   }

//   List<Map<String, dynamic>> get _filteredUsers {
//     List<Map<String, dynamic>> filteredUsers = _users;

//     if (_selectedRole != 'all') {
//       filteredUsers = filteredUsers.where((user) =>
//         (user['role'] ?? '').toString().toLowerCase() == _selectedRole.toLowerCase()
//       ).toList();
//     }

//     if (_searchQuery.isNotEmpty) {
//       final query = _searchQuery.toLowerCase();
//       filteredUsers = filteredUsers.where((user) {
//         return (user['full_name'] ?? '').toString().toLowerCase().contains(query) ||
//             (user['email'] ?? '').toString().toLowerCase().contains(query) ||
//             (user['contact_number'] ?? '').toString().toLowerCase().contains(query) ||
//             (user['role'] ?? '').toString().toLowerCase().contains(query);
//       }).toList();
//     }

//     return filteredUsers;
//   }

//   @override
//   Widget build(BuildContext context) {
//     final orange = const Color(0xFFF5A623);
//     final blue = const Color(0xFF5094FF);
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: const Color(0xFFFFF6E7),
//         elevation: 0,
//         iconTheme: const IconThemeData(color: Colors.black87),
//         title: Text(
//           'All Users',
//           style: GoogleFonts.poppins(
//             fontWeight: FontWeight.bold,
//             color: orange,
//           ),
//         ),
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back),
//           onPressed: () {
//             Navigator.pop(context);
//           },
//         ),
//       ),
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               TextField(
//                 decoration: InputDecoration(
//                   hintText: 'Search users',
//                   hintStyle: TextStyle(fontSize: 14, color: Colors.grey[500]),
//                   prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
//                   suffixIcon: _searchQuery.isNotEmpty
//                       ? IconButton(
//                           icon: Icon(Icons.clear, color: Colors.grey[400]),
//                           onPressed: () {
//                             setState(() {
//                               _searchQuery = '';
//                             });
//                             FocusScope.of(context).unfocus();
//                           },
//                         )
//                       : null,
//                   filled: true,
//                   fillColor: Colors.grey[100],
//                   contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                     borderSide: BorderSide.none,
//                   ),
//                 ),
//                 onChanged: (value) {
//                   setState(() {
//                     _searchQuery = value;
//                   });
//                 },
//               ),
//               const SizedBox(height: 16),
//               Row(
//                 children: [
//                   GestureDetector(
//                     onTap: () {
//                       setState(() {
//                         _selectedRole = 'all';
//                       });
//                     },
//                     child: Container(
//                       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                       decoration: BoxDecoration(
//                         color: _selectedRole == 'all' ? Colors.grey[600] : Colors.transparent,
//                         borderRadius: BorderRadius.circular(8),
//                         border: Border.all(color: Colors.grey[600]!, width: 1.2),
//                       ),
//                       child: Text(
//                         'All',
//                         style: GoogleFonts.poppins(
//                           color: _selectedRole == 'all' ? Colors.white : Colors.grey[600],
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(width: 8),
//                   GestureDetector(
//                     onTap: () {
//                       setState(() {
//                         _selectedRole = 'user';
//                       });
//                     },
//                     child: Container(
//                       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                       decoration: BoxDecoration(
//                         color: _selectedRole == 'user' ? orange : Colors.transparent,
//                         borderRadius: BorderRadius.circular(8),
//                         border: Border.all(color: orange, width: 1.2),
//                       ),
//                       child: Text(
//                         'User',
//                         style: GoogleFonts.poppins(
//                           color: _selectedRole == 'user' ? Colors.white : orange,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(width: 8),
//                   GestureDetector(
//                     onTap: () {
//                       setState(() {
//                         _selectedRole = 'admin';
//                       });
//                     },
//                     child: Container(
//                       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                       decoration: BoxDecoration(
//                         color: _selectedRole == 'admin' ? blue : Colors.transparent,
//                         borderRadius: BorderRadius.circular(8),
//                         border: Border.all(color: blue, width: 1.2),
//                       ),
//                       child: Text(
//                         'Admin',
//                         style: GoogleFonts.poppins(
//                           color: _selectedRole == 'admin' ? Colors.white : blue,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                   ),
//                   const Spacer(),
//                   PopupMenuButton<String>(
//                     onSelected: (value) {
//                       if (value == 'name_asc') {
//                         setState(() {
//                           _sortByNameAsc = true;
//                           _users.sort((a, b) {
//                             final nameA = (a['full_name'] ?? '').toString().toLowerCase();
//                             final nameB = (b['full_name'] ?? '').toString().toLowerCase();
//                             return nameA.compareTo(nameB);
//                           });
//                         });
//                       } else if (value == 'name_desc') {
//                         setState(() {
//                           _sortByNameAsc = false;
//                           _users.sort((a, b) {
//                             final nameA = (a['full_name'] ?? '').toString().toLowerCase();
//                             final nameB = (b['full_name'] ?? '').toString().toLowerCase();
//                             return nameB.compareTo(nameA);
//                           });
//                         });
//                       } else if (value == 'date_asc') {
//                         setState(() {
//                           _sortByDateAsc = true;
//                           _users.sort((a, b) {
//                             final dateA = DateTime.tryParse(a['created_at'] ?? '') ?? DateTime(2000);
//                             final dateB = DateTime.tryParse(b['created_at'] ?? '') ?? DateTime(2000);
//                             return dateA.compareTo(dateB);
//                           });
//                         });
//                       } else if (value == 'date_desc') {
//                         setState(() {
//                           _sortByDateAsc = false;
//                           _users.sort((a, b) {
//                             final dateA = DateTime.tryParse(a['created_at'] ?? '') ?? DateTime(2000);
//                             final dateB = DateTime.tryParse(b['created_at'] ?? '') ?? DateTime(2000);
//                             return dateB.compareTo(dateA);
//                           });
//                         });
//                       }
//                     },
//                     itemBuilder: (context) => [
//                       PopupMenuItem(
//                         value: 'name_asc',
//                         child: Text('Name (A–Z)', style: GoogleFonts.poppins(fontSize: 13)),
//                       ),
//                       PopupMenuItem(
//                         value: 'name_desc',
//                         child: Text('Name (Z–A)', style: GoogleFonts.poppins(fontSize: 13)),
//                       ),
//                       PopupMenuItem(
//                         value: 'date_asc',
//                         child: Text('Date Joined (Oldest First)', style: GoogleFonts.poppins(fontSize: 13)),
//                       ),
//                       PopupMenuItem(
//                         value: 'date_desc',
//                         child: Text('Date Joined (Newest First)', style: GoogleFonts.poppins(fontSize: 13)),
//                       ),
//                     ],
//                     child: Row(
//                       children: [
//                         Icon(Icons.sort, color: Colors.grey[600], size: 20),
//                         const SizedBox(width: 4),
//                         Text(
//                           'Sort',
//                           style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[600]),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 8),
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 4.0),
//                 child: Text(
//                   '${_filteredUsers.length} ${_selectedRole == 'all' ? 'Total' : _selectedRole == 'user' ? 'User(s)' : 'Admin(s)'}',
//                   style: GoogleFonts.poppins(
//                     fontSize: 14,
//                     color: Colors.grey[600],
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//               ),
//               Expanded(
//                 child: RefreshIndicator(
//                   color: orange,
//                   onRefresh: _handleRefresh,
//                   child: _isLoading
//                       ? const Center(child: CircularProgressIndicator(color: Color(0xFFF5A623)))
//                       : _filteredUsers.isEmpty
//                           ? Center(
//                               child: Column(
//                                 mainAxisAlignment: MainAxisAlignment.center,
//                                 children: [
//                                   Icon(
//                                     Icons.people_outline,
//                                     size: 64,
//                                     color: Colors.grey[400],
//                                   ),
//                                   const SizedBox(height: 16),
//                                   Text(
//                                     _users.isEmpty ? 'No users found in database.' : 'No users match your filters.',
//                                     style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey[600]),
//                                     textAlign: TextAlign.center,
//                                   ),
//                                   const SizedBox(height: 8),
//                                   Text(
//                                     'Total users loaded: ${_users.length}',
//                                     style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[500]),
//                                   ),
//                                 ],
//                               )
//                           : ListView.separated(
//                               controller: _scrollController,
//                               itemCount: _filteredUsers.length,
//                               separatorBuilder: (context, index) => const SizedBox(height: 12),
//                               itemBuilder: (context, index) {
//                                 final user = _filteredUsers[index];
//                                 return Container(
//                                   padding: const EdgeInsets.all(16),
//                                   decoration: BoxDecoration(
//                                     color: Colors.white,
//                                     borderRadius: BorderRadius.circular(12),
//                                     boxShadow: [
//                                       BoxShadow(
//                                         color: Colors.black.withOpacity(0.05),
//                                         blurRadius: 6,
//                                         offset: const Offset(0, 2),
//                                       ),
//                                     ],
//                                   ),
//                                   child: Column(
//                                     crossAxisAlignment: CrossAxisAlignment.start,
//                                     children: [
//                                       Row(
//                                         children: [
//                                           Icon(Icons.person, color: orange, size: 28),
//                                           const SizedBox(width: 12),
//                                           Expanded(
//                                             child: Text(
//                                               user['full_name'] ?? '-',
//                                               style: GoogleFonts.poppins(
//                                                 fontSize: 18,
//                                                 fontWeight: FontWeight.w600,
//                                                 color: Colors.black87,
//                                               ),
//                                             ),
//                                           ),
//                                           Container(
//                                             padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//                                             decoration: BoxDecoration(
//                                               color: user['role'] == 'admin' ? blue : Colors.transparent,
//                                               border: user['role'] == 'user'
//                                                   ? Border.all(color: orange, width: 1.2)
//                                                   : null,
//                                               borderRadius: BorderRadius.circular(8),
//                                             ),
//                                             child: Text(
//                                               user['role'] ?? '-',
//                                               style: GoogleFonts.poppins(
//                                                 fontSize: 12,
//                                                 fontWeight: FontWeight.w500,
//                                                 color: user['role'] == 'admin' ? Colors.white : orange,
//                                               ),
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                       const SizedBox(height: 8),
//                                       Row(
//                                         children: [
//                                           Icon(Icons.email, color: Colors.grey[400], size: 18),
//                                           const SizedBox(width: 6),
//                                           Expanded(
//                                             child: Text(
//                                               user['email'] ?? '-',
//                                               style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[700]),
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                       const SizedBox(height: 4),
//                                       Row(
//                                         children: [
//                                           Icon(Icons.phone, color: Colors.grey[400], size: 18),
//                                           const SizedBox(width: 6),
//                                           Expanded(
//                                             child: Text(
//                                               user['contact_number'] ?? '-',
//                                               style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[700]),
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                       const SizedBox(height: 4),
//                                       Row(
//                                         children: [
//                                           Icon(Icons.calendar_today, color: Colors.grey[400], size: 18),
//                                           const SizedBox(width: 6),
//                                           Expanded(
//                                             child: Text(
//                                               user['created_at'] != null
//                                                   ? _formatDate(user['created_at'])
//                                                   : '-',
//                                               style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[700]),
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     ],
//                                   ),
//                                 );
//                               },
//                             ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
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

//   String _formatDate(String dateStr) {
//     try {
//       final date = DateTime.parse(dateStr);
//       return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
//     } catch (e) {
//       return dateStr;
//     }
//   }
// }

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import 'home_admin.dart';

class AllUsersAdminPage extends StatefulWidget {
  const AllUsersAdminPage({Key? key}) : super(key: key);

  @override
  State<AllUsersAdminPage> createState() => _AllUsersAdminPageState();
}

class _AllUsersAdminPageState extends State<AllUsersAdminPage> {
  List<Map<String, dynamic>> _users = [];
  bool _isLoading = true;
  String _searchQuery = '';
  bool _sortByNameAsc = true;
  bool _sortByDateAsc = false;
  String _selectedRole = 'all';
  final ScrollController _scrollController = ScrollController();
  bool _showScrollToTop = false;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
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

  Future<void> _fetchUsers() async {
    setState(() => _isLoading = true);
    try {
      final response = await SupabaseConfig.client
          .from('users')
          .select('*')
          .order('created_at', ascending: false);
      if (response is List) {
        setState(() => _users = List<Map<String, dynamic>>.from(response));
      } else {
        setState(() => _users = []);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error fetching users: $e'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() => _users = []);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleRefresh() async {
    await _fetchUsers();
  }

  void _sortByName() {
    setState(() {
      _sortByNameAsc = !_sortByNameAsc;
      _users.sort((a, b) {
        final nameA = (a['full_name'] ?? '').toString().toLowerCase();
        final nameB = (b['full_name'] ?? '').toString().toLowerCase();
        return _sortByNameAsc ? nameA.compareTo(nameB) : nameB.compareTo(nameA);
      });
    });
  }

  void _sortByDate() {
    setState(() {
      _sortByDateAsc = !_sortByDateAsc;
      _users.sort((a, b) {
        final dateA = DateTime.tryParse(a['created_at'] ?? '') ?? DateTime(2000);
        final dateB = DateTime.tryParse(b['created_at'] ?? '') ?? DateTime(2000);
        return _sortByDateAsc ? dateA.compareTo(dateB) : dateB.compareTo(dateA);
      });
    });
  }

  List<Map<String, dynamic>> get _filteredUsers {
    List<Map<String, dynamic>> filteredUsers = _users;
    if (_selectedRole != 'all') {
      filteredUsers = filteredUsers.where((user) =>
        (user['role'] ?? '').toString().toLowerCase() == _selectedRole.toLowerCase()
      ).toList();
    }
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filteredUsers = filteredUsers.where((user) {
        return (user['full_name'] ?? '').toString().toLowerCase().contains(query) ||
            (user['email'] ?? '').toString().toLowerCase().contains(query) ||
            (user['contact_number'] ?? '').toString().toLowerCase().contains(query) ||
            (user['role'] ?? '').toString().toLowerCase().contains(query);
      }).toList();
    }
    return filteredUsers;
  }

  @override
  Widget build(BuildContext context) {
    final orange = const Color(0xFFF5A623);
    final blue = const Color(0xFF5094FF);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF6E7),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: Text(
          'All Users',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: orange,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                decoration: InputDecoration(
                  hintText: 'Search users',
                  hintStyle: TextStyle(fontSize: 14, color: Colors.grey[500]),
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
                  contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (value) => setState(() => _searchQuery = value),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  GestureDetector(
                    onTap: () => setState(() => _selectedRole = 'all'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: _selectedRole == 'all' ? Colors.grey[600] : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[600]!, width: 1.2),
                      ),
                      child: Text(
                        'All',
                        style: GoogleFonts.poppins(
                          color: _selectedRole == 'all' ? Colors.white : Colors.grey[600],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => setState(() => _selectedRole = 'user'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: _selectedRole == 'user' ? orange : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: orange, width: 1.2),
                      ),
                      child: Text(
                        'User',
                        style: GoogleFonts.poppins(
                          color: _selectedRole == 'user' ? Colors.white : orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => setState(() => _selectedRole = 'admin'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: _selectedRole == 'admin' ? blue : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: blue, width: 1.2),
                      ),
                      child: Text(
                        'Admin',
                        style: GoogleFonts.poppins(
                          color: _selectedRole == 'admin' ? Colors.white : blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'name_asc') {
                        _sortByName();
                      } else if (value == 'name_desc') {
                        setState(() => _sortByNameAsc = false);
                        _sortByName();
                      } else if (value == 'date_asc') {
                        setState(() => _sortByDateAsc = true);
                        _sortByDate();
                      } else if (value == 'date_desc') {
                        setState(() => _sortByDateAsc = false);
                        _sortByDate();
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'name_asc',
                        child: Text('Name (A–Z)'),
                      ),
                      const PopupMenuItem(
                        value: 'name_desc',
                        child: Text('Name (Z–A)'),
                      ),
                      const PopupMenuItem(
                        value: 'date_asc',
                        child: Text('Date Joined (Oldest First)'),
                      ),
                      const PopupMenuItem(
                        value: 'date_desc',
                        child: Text('Date Joined (Newest First)'),
                      ),
                    ],
                    child: Row(
                      children: [
                        Icon(Icons.sort, color: Colors.grey[600], size: 20),
                        const SizedBox(width: 4),
                        Text(
                          'Sort',
                          style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Text(
                  '${_filteredUsers.length} ${_selectedRole == 'all' ? 'Total' : _selectedRole == 'user' ? 'User(s)' : 'Admin(s)'}',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: RefreshIndicator(
                  color: orange,
                  onRefresh: _handleRefresh,
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator(color: Color(0xFFF5A623)))
                      : _filteredUsers.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.people_outline,
                                    size: 64,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    _users.isEmpty ? 'No users found in database.' : 'No users match your filters.',
                                    style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey[600]),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Total users loaded: ${_users.length}',
                                    style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[500]),
                                  ),
                                ],
                              ),
                            )
                          : ListView.separated(
                              controller: _scrollController,
                              itemCount: _filteredUsers.length,
                              separatorBuilder: (context, index) => const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final user = _filteredUsers[index];
                                return Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(Icons.person, color: orange, size: 28),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              user['full_name'] ?? '-',
                                              style: GoogleFonts.poppins(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.black87,
                                              ),
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: user['role'] == 'admin' ? blue : Colors.transparent,
                                              border: user['role'] == 'user'
                                                  ? Border.all(color: orange, width: 1.2)
                                                  : null,
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              user['role'] ?? '-',
                                              style: GoogleFonts.poppins(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                                color: user['role'] == 'admin' ? Colors.white : orange,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Icon(Icons.email, color: Colors.grey[400], size: 18),
                                          const SizedBox(width: 6),
                                          Expanded(
                                            child: Text(
                                              user['email'] ?? '-',
                                              style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[700]),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Icon(Icons.phone, color: Colors.grey[400], size: 18),
                                          const SizedBox(width: 6),
                                          Expanded(
                                            child: Text(
                                              user['contact_number'] ?? '-',
                                              style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[700]),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Icon(Icons.calendar_today, color: Colors.grey[400], size: 18),
                                          const SizedBox(width: 6),
                                          Expanded(
                                            child: Text(
                                              user['created_at'] != null
                                                  ? _formatDate(user['created_at'])
                                                  : '-',
                                              style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[700]),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
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
      floatingActionButton: _showScrollToTop
          ? FloatingActionButton(
              onPressed: _scrollToTop,
              backgroundColor: orange,
              foregroundColor: Colors.white,
              mini: true,
              child: const Icon(Icons.keyboard_arrow_up),
            )
          : null,
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateStr;
    }
  }
}
