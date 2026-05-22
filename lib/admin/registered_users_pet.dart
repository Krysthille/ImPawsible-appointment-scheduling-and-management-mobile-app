// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';

// class RegisteredUsersPetPage extends StatefulWidget {
//   const RegisteredUsersPetPage({Key? key}) : super(key: key);

//   @override
//   State<RegisteredUsersPetPage> createState() => _RegisteredUsersPetPageState();
// }

// class _RegisteredUsersPetPageState extends State<RegisteredUsersPetPage> {
//   final orange = const Color(0xFFF5A623);
//   final lightOrange = const Color(0xFFFFF6E7);
//   bool _isLoading = true;
//   List<Map<String, dynamic>> _userPets = [];
//   List<Map<String, dynamic>> _filteredUserPets = [];
//   String _searchQuery = '';
//   String _sortType = 'name_asc';
//   final TextEditingController _searchController = TextEditingController();
//   int _totalPets = 0;

//   @override
//   void initState() {
//     super.initState();
//     _fetchData();
//   }

//   @override
//   void dispose() {
//     _searchController.dispose();
//     super.dispose();
//   }

//   Future<void> _fetchData() async {
//     setState(() => _isLoading = true);
//     final supabase = Supabase.instance.client;
//     try {
//       // Fetch all users except admins
//       final users = await supabase.from('users').select('id, full_name, role').neq('role', 'admin');
//       // Fetch all pets (assuming pets are stored in grooming_appointments)
//       final appointments = await supabase.from('grooming_appointments').select('user_id, pet_name');

//       // Map userId to pet names
//       final Map<String, Set<String>> userPetsMap = {};
//       for (final appt in appointments) {
//         final userId = appt['user_id'] ?? '';
//         final petName = appt['pet_name'] ?? '';
//         if (userId.isNotEmpty && petName.isNotEmpty) {
//           userPetsMap.putIfAbsent(userId, () => {});
//           userPetsMap[userId]!.add(petName);
//         }
//       }

//       // Build user-pet list
//       final List<Map<String, dynamic>> userPets = [];
//       for (final user in users) {
//         final pets = userPetsMap[user['id']]?.toList() ?? [];
//         userPets.add({
//           'user': user['full_name'] ?? 'Unknown',
//           'pets': pets,
//         });
//       }

//       // Calculate total pets count
//       int totalPets = 0;
//       for (final userPet in userPets) {
//         totalPets += (userPet['pets'] as List).length;
//       }

//       setState(() {
//         _userPets = userPets;
//         _filteredUserPets = userPets; // Initialize filtered list with all data
//         _totalPets = totalPets;
//         _isLoading = false;
//       });
//       _applySearchAndSort();
//     } catch (e) {
//       setState(() => _isLoading = false);
//     }
//   }

//   void _applySearchAndSort() {
//     List<Map<String, dynamic>> filtered = _userPets;

//     // Apply search filter
//     if (_searchQuery.isNotEmpty) {
//       filtered = filtered.where((entry) {
//         final userName = entry['user'].toString().toLowerCase();
//         final pets = entry['pets'] as List;
//         final petNames = pets.map((pet) => pet.toString().toLowerCase()).join(' ');
        
//         final query = _searchQuery.toLowerCase();
//         return userName.contains(query) || petNames.contains(query);
//       }).toList();
//     }

//     // Apply sorting
//     filtered.sort((a, b) {
//       final userNameA = a['user'].toString().toLowerCase();
//       final userNameB = b['user'].toString().toLowerCase();
      
//       switch (_sortType) {
//         case 'name_asc':
//           return userNameA.compareTo(userNameB);
//         case 'name_desc':
//           return userNameB.compareTo(userNameA);
//         default:
//           return 0;
//       }
//     });

//     // Recalculate total pets count for filtered results
//     int totalPets = 0;
//     for (final userPet in filtered) {
//       totalPets += (userPet['pets'] as List).length;
//     }

//     setState(() {
//       _filteredUserPets = filtered;
//       _totalPets = totalPets;
//     });
//   }

//   String _getInitials(String name) {
//     final parts = name.trim().split(' ');
//     if (parts.length == 1) return parts[0][0].toUpperCase();
//     return (parts[0][0] + parts.last[0]).toUpperCase();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: lightOrange,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back),
//           color: orange,
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: Text(
//           'Registered Users and Pets',
//           style: GoogleFonts.poppins(
//             fontSize: 20,
//             fontWeight: FontWeight.bold,
//             color: Colors.black,
//           ),
//         ),
//       ),
//       backgroundColor: const Color(0xFFFDF6ED),
//       body: Column(
//         children: [
//           // Search and Sort Section
//           Container(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               children: [
//                 // Search Bar
//                 Container(
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(16),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black.withOpacity(0.08),
//                         blurRadius: 12,
//                         offset: const Offset(0, 4),
//                       ),
//                     ],
//                     border: Border.all(
//                       color: Colors.grey.withOpacity(0.1),
//                       width: 1,
//                     ),
//                   ),
//                   child: Row(
//                     children: [
//                       Expanded(
//                         child: TextField(
//                           controller: _searchController,
//                           onChanged: (value) {
//                             setState(() {
//                               _searchQuery = value;
//                             });
//                             _applySearchAndSort();
//                           },
//                           decoration: InputDecoration(
//                             hintText: 'Search users and pets...',
//                             hintStyle: GoogleFonts.poppins(
//                               fontSize: 14,
//                               color: Colors.grey[500],
//                             ),
//                             prefixIcon: Icon(Icons.search, color: orange),
//                             border: InputBorder.none,
//                             contentPadding: const EdgeInsets.symmetric(
//                               horizontal: 16,
//                               vertical: 12,
//                             ),
//                           ),
//                           style: GoogleFonts.poppins(fontSize: 14),
//                         ),
//                       ),
//                       // Sort Button
//                       PopupMenuButton<String>(
//                         onSelected: (value) {
//                           setState(() {
//                             _sortType = value;
//                           });
//                           _applySearchAndSort();
//                         },
//                         itemBuilder: (context) => [
//                           PopupMenuItem(
//                             value: 'name_asc',
//                             child: Text('User Name (A–Z)', style: GoogleFonts.poppins(fontSize: 13)),
//                           ),
//                           PopupMenuItem(
//                             value: 'name_desc',
//                             child: Text('User Name (Z–A)', style: GoogleFonts.poppins(fontSize: 13)),
//                           ),
//                         ],
//                         child: Container(
//                           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//                           decoration: BoxDecoration(
//                             color: orange.withOpacity(0.1),
//                             borderRadius: BorderRadius.circular(12),
//                             border: Border.all(
//                               width: 1,
//                             ),
//                           ),
//                           child: Row(
//                             mainAxisSize: MainAxisSize.min,
//                             children: [
//                               Icon(Icons.sort, color: orange, size: 20),
//                               const SizedBox(width: 6),
//                               Text(
//                                 'Sort',
//                                 style: GoogleFonts.poppins(
//                                   fontSize: 14,
//                                   fontWeight: FontWeight.w600,
//                                   color: Colors.black,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           // Results count
//           // Padding(
//           //   padding: const EdgeInsets.symmetric(horizontal: 16),
//           //   child: Row(
//           //     children: [
//           //       Text(
//           //         '${_filteredUserPets.length} user${_filteredUserPets.length == 1 ? '' : 's'} found',
//           //         style: GoogleFonts.poppins(
//           //           fontSize: 14,
//           //           color: Colors.grey[600],
//           //         ),
//           //       ),
//           //     ],
//           //   ),
//           // ),
//           // const SizedBox(height: 8),
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//               child: Text(
//                 '${_filteredUserPets.length} user(s) found, $_totalPets pet(s) found',
//                 style: GoogleFonts.poppins(
//                   fontSize: 12,
//                   color: Colors.grey[600],
//                   fontStyle: FontStyle.italic,
//                 ),
//               ),
//             ),
//                   // const SizedBox(height: 8),
                  
//           // Two-column header with rounded top corners
//           Container(
//             margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//             decoration: BoxDecoration(
//               color: lightOrange,
//               borderRadius: const BorderRadius.only(
//                 topLeft: Radius.circular(12),
//                 topRight: Radius.circular(12),
//               ),
//             ),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: Padding(
//                     padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
//                     child: Text(
//                       'Name of the User',
//                       style: GoogleFonts.poppins(
//                         fontWeight: FontWeight.bold,
//                         fontSize: 16,
//                         color: Colors.black87,
//                       ),
//                     ),
//                   ),
//                 ),
//                 Container(
//                   width: 1,
//                   height: 40,
//                   color: orange.withOpacity(0.3),
//                 ),
//                 Expanded(
//                   child: Padding(
//                     padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
//                     child: Text(
//                       'Name of Pets',
//                       style: GoogleFonts.poppins(
//                         fontWeight: FontWeight.bold,
//                         fontSize: 16,
//                         color: Colors.black87,
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           // Content area
//           Expanded(
//             child: _isLoading
//                 ? const Center(child: CircularProgressIndicator(color: Color(0xFFF5A623)))
//                 : _filteredUserPets.isEmpty
//                     ? Center(
//                         child: Column(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
//                             const SizedBox(height: 16),
//                             Text(
//                               'No users found',
//                               style: GoogleFonts.poppins(
//                                 fontSize: 18,
//                                 fontWeight: FontWeight.w600,
//                                 color: Colors.grey[600],
//                               ),
//                             ),
//                             const SizedBox(height: 8),
//                             Text(
//                               'Try adjusting your search criteria',
//                               style: GoogleFonts.poppins(
//                                 fontSize: 14,
//                                 color: Colors.grey[500],
//                               ),
//                             ),
//                           ],
//                         ),
//                       )
//                     : ListView.separated(
//                         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                         itemCount: _filteredUserPets.length,
//                         separatorBuilder: (context, index) => const SizedBox(height: 12),
//                         itemBuilder: (context, index) {
//                           final entry = _filteredUserPets[index];
//                           final pets = entry['pets'] as List;
                      
//                           return Container(
//                             decoration: BoxDecoration(
//                               color: Colors.white,
//                               borderRadius: BorderRadius.circular(12),
//                               boxShadow: [
//                                 BoxShadow(
//                                   color: Colors.black.withOpacity(0.05),
//                                   blurRadius: 8,
//                                   offset: const Offset(0, 2),
//                                 ),
//                               ],
//                             ),
//                             child: Row(
//                               children: [
//                                 // Left column - User info
//                                 Expanded(
//                                   child: Padding(
//                                     padding: const EdgeInsets.all(16),
//                                     child: Row(
//                                       children: [
//                                         // User initials in circular icon
//                                         CircleAvatar(
//                                           backgroundColor: orange.withOpacity(0.15),
//                                           radius: 20,
//                                           child: Text(
//                                             _getInitials(entry['user']),
//                                             style: GoogleFonts.poppins(
//                                               color: orange,
//                                               fontWeight: FontWeight.bold,
//                                               fontSize: 16,
//                                             ),
//                                           ),
//                                         ),
//                                         const SizedBox(width: 12),
//                                         Expanded(
//                                           child: Text(
//                                             entry['user'],
//                                             style: GoogleFonts.poppins(
//                                               fontSize: 15,
//                                               fontWeight: FontWeight.w600,
//                                               color: Colors.black87,
//                                             ),
//                                             maxLines: 2,
//                                             overflow: TextOverflow.visible,
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 ),
//                                 // Vertical divider
//                                 Container(
//                                   width: 1,
//                                   height: 60,
//                                   color: orange.withOpacity(0.2),
//                                 ),
//                                 // Right column - Pet names
//                                 Expanded(
//                                   child: Padding(
//                                     padding: const EdgeInsets.all(16),
//                                     child: pets.isNotEmpty
//                                         ? Column(
//                                             crossAxisAlignment: CrossAxisAlignment.start,
//                                             children: [
//                                               Wrap(
//                                                 spacing: 8,
//                                                 runSpacing: 6,
//                                                 children: pets.map<Widget>((pet) => Container(
//                                                   padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                                                   decoration: BoxDecoration(
//                                                     color: orange.withOpacity(0.6),
//                                                     borderRadius: BorderRadius.circular(20),
//                                                     boxShadow: [
//                                                       BoxShadow(
//                                                         color: orange.withOpacity(0.2),
//                                                         blurRadius: 2,
//                                                         offset: const Offset(0, 1),
//                                                       ),
//                                                     ],
//                                                   ),
//                                                   child: Text(
//                                                     pet,
//                                                     style: GoogleFonts.poppins(
//                                                       fontSize: 13,
//                                                       color: Colors.white,
//                                                       fontWeight: FontWeight.w500,
//                                                     ),
//                                                   ),
//                                                 )).toList(),
//                                               ),
//                                               const SizedBox(height: 8),
//                                               Align(
//                                                 alignment: Alignment.centerRight,
//                                                 child: Container(
//                                                   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                                                   decoration: BoxDecoration(
//                                                     color: orange.withOpacity(0.1),
//                                                     borderRadius: BorderRadius.circular(8),
//                                                     border: Border.all(color: orange.withOpacity(0.3)),
//                                                   ),
//                                                   child: Text(
//                                                     'Total: ${pets.length}',
//                                                     style: GoogleFonts.poppins(
//                                                       fontSize: 12,
//                                                       color: orange,
//                                                       fontWeight: FontWeight.w600,
//                                                     ),
//                                                   ),
//                                                 ),
//                                               ),
//                                             ],
//                                           )
//                                         : Column(
//                                             crossAxisAlignment: CrossAxisAlignment.start,
//                                             children: [
//                                               Text(
//                                                 'No pets',
//                                                 style: GoogleFonts.poppins(
//                                                   fontSize: 14,
//                                                   color: Colors.grey[600],
//                                                   fontStyle: FontStyle.italic,
//                                                 ),
//                                               ),
//                                               const SizedBox(height: 8),
//                                               Align(
//                                                 alignment: Alignment.centerRight,
//                                                 child: Container(
//                                                   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                                                   decoration: BoxDecoration(
//                                                     color: Colors.grey.withOpacity(0.1),
//                                                     borderRadius: BorderRadius.circular(8),
//                                                     border: Border.all(color: Colors.grey.withOpacity(0.3)),
//                                                   ),
//                                                   child: Text(
//                                                     'Total: 0',
//                                                     style: GoogleFonts.poppins(
//                                                       fontSize: 12,
//                                                       color: Colors.grey[600],
//                                                       fontWeight: FontWeight.w600,
//                                                     ),
//                                                   ),
//                                                 ),
//                                               ),
//                                             ],
//                                           ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           );
//                         },
//                       ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegisteredUsersPetPage extends StatefulWidget {
  const RegisteredUsersPetPage({Key? key}) : super(key: key);

  @override
  State<RegisteredUsersPetPage> createState() => _RegisteredUsersPetPageState();
}

class _RegisteredUsersPetPageState extends State<RegisteredUsersPetPage> {
  final orange = const Color(0xFFF5A623);
  final lightOrange = const Color(0xFFFFF6E7);
  bool _isLoading = true;
  List<Map<String, dynamic>> _userPets = [];
  List<Map<String, dynamic>> _filteredUserPets = [];
  String _searchQuery = '';
  String _sortType = 'name_asc';
  final TextEditingController _searchController = TextEditingController();
  int _totalPets = 0;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    final supabase = Supabase.instance.client;
    try {
      final users = await supabase
          .from('users')
          .select('id, full_name, role')
          .neq('role', 'admin');

      final appointments = await supabase
          .from('grooming_appointments')
          .select('user_id, pet_name');

      final Map<String, Set<String>> userPetsMap = {};
      for (final appt in appointments) {
        final userId = appt['user_id'] ?? '';
        final petName = appt['pet_name'] ?? '';
        if (userId.isNotEmpty && petName.isNotEmpty) {
          userPetsMap.putIfAbsent(userId, () => {});
          userPetsMap[userId]!.add(petName);
        }
      }

      final List<Map<String, dynamic>> userPets = [];
      for (final user in users) {
        final pets = userPetsMap[user['id']]?.toList() ?? [];
        userPets.add({
          'user': user['full_name'] ?? 'Unknown',
          'pets': pets,
        });
      }

      int totalPets = 0;
      for (final userPet in userPets) {
        totalPets += (userPet['pets'] as List).length;
      }

      setState(() {
        _userPets = userPets;
        _filteredUserPets = userPets;
        _totalPets = totalPets;
        _isLoading = false;
      });
      _applySearchAndSort();
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _applySearchAndSort() {
    List<Map<String, dynamic>> filtered = _userPets;

    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((entry) {
        final userName = entry['user'].toString().toLowerCase();
        final pets = entry['pets'] as List;
        final petNames =
            pets.map((pet) => pet.toString().toLowerCase()).join(' ');
        final query = _searchQuery.toLowerCase();
        return userName.contains(query) || petNames.contains(query);
      }).toList();
    }

    filtered.sort((a, b) {
      final userNameA = a['user'].toString().toLowerCase();
      final userNameB = b['user'].toString().toLowerCase();

      switch (_sortType) {
        case 'name_asc':
          return userNameA.compareTo(userNameB);
        case 'name_desc':
          return userNameB.compareTo(userNameA);
        default:
          return 0;
      }
    });

    int totalPets = 0;
    for (final userPet in filtered) {
      totalPets += (userPet['pets'] as List).length;
    }

    setState(() {
      _filteredUserPets = filtered;
      _totalPets = totalPets;
    });
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return (parts[0][0] + parts.last[0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: lightOrange,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: orange,
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Registered Users and Pets',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      backgroundColor: const Color(0xFFFDF6ED),
      body: Column(
        children: [
          // Search + Sort
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    border: Border.all(
                      color: Colors.grey.withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          onChanged: (value) {
                            setState(() {
                              _searchQuery = value;
                            });
                            _applySearchAndSort();
                          },
                          decoration: InputDecoration(
                            hintText: 'Search users and pets...',
                            hintStyle: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                            prefixIcon: Icon(Icons.search, color: orange),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                          style: GoogleFonts.poppins(fontSize: 14),
                        ),
                      ),
                      PopupMenuButton<String>(
                        onSelected: (value) {
                          setState(() {
                            _sortType = value;
                          });
                          _applySearchAndSort();
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'name_asc',
                            child: Text('User Name (A–Z)',
                                style: GoogleFonts.poppins(fontSize: 13)),
                          ),
                          PopupMenuItem(
                            value: 'name_desc',
                            child: Text('User Name (Z–A)',
                                style: GoogleFonts.poppins(fontSize: 13)),
                          ),
                        ],
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(width: 1),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.sort, color: orange, size: 20),
                              const SizedBox(width: 6),
                              Text(
                                'Sort',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Results count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
            child: Text(
              '${_filteredUserPets.length} user(s) found, $_totalPets pet(s) found',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ),

          // Header row
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
            decoration: BoxDecoration(
              color: lightOrange,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 20),
                    child: Text(
                      'Name of the User',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: orange.withOpacity(0.3),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 20),
                    child: Text(
                      'Name of Pets',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Main list with pull-to-refresh
          Expanded(
            child: RefreshIndicator(
              onRefresh: _fetchData,
              color: orange,
              child: _isLoading
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: const [
                        SizedBox(
                          height: 400,
                          child: Center(
                            child: CircularProgressIndicator(
                                color: Color(0xFFF5A623)),
                          ),
                        ),
                      ],
                    )
                  : _filteredUserPets.isEmpty
                      ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: const [
                            SizedBox(
                              height: 400,
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.search_off,
                                        size: 64, color: Colors.grey),
                                    SizedBox(height: 16),
                                    Text(
                                      'No users found',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'Try adjusting your search criteria',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        )
                      : ListView.separated(
                          physics:
                              const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          itemCount: _filteredUserPets.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final entry = _filteredUserPets[index];
                            final pets = entry['pets'] as List;

                            return Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  // User column
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Row(
                                        children: [
                                          CircleAvatar(
                                            backgroundColor:
                                                orange.withOpacity(0.15),
                                            radius: 20,
                                            child: Text(
                                              _getInitials(entry['user']),
                                              style: GoogleFonts.poppins(
                                                color: orange,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              entry['user'],
                                              style: GoogleFonts.poppins(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.black87,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.visible,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Container(
                                    width: 1,
                                    height: 60,
                                    color: orange.withOpacity(0.2),
                                  ),
                                  // Pets column
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: pets.isNotEmpty
                                          ? Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Wrap(
                                                  spacing: 8,
                                                  runSpacing: 6,
                                                  children: pets
                                                      .map<Widget>(
                                                          (pet) => Container(
                                                                padding: const EdgeInsets
                                                                        .symmetric(
                                                                    horizontal:
                                                                        12,
                                                                    vertical:
                                                                        6),
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color: orange
                                                                      .withOpacity(
                                                                          0.6),
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              20),
                                                                  boxShadow: [
                                                                    BoxShadow(
                                                                      color: orange
                                                                          .withOpacity(
                                                                              0.2),
                                                                      blurRadius:
                                                                          2,
                                                                      offset:
                                                                          const Offset(
                                                                              0,
                                                                              1),
                                                                    ),
                                                                  ],
                                                                ),
                                                                child: Text(
                                                                  pet,
                                                                  style: GoogleFonts
                                                                      .poppins(
                                                                    fontSize:
                                                                        13,
                                                                    color: Colors
                                                                        .white,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                  ),
                                                                ),
                                                              ))
                                                      .toList(),
                                                ),
                                                const SizedBox(height: 8),
                                                Align(
                                                  alignment:
                                                      Alignment.centerRight,
                                                  child: Container(
                                                    padding: const EdgeInsets
                                                            .symmetric(
                                                        horizontal: 8,
                                                        vertical: 4),
                                                    decoration: BoxDecoration(
                                                      color: orange
                                                          .withOpacity(0.1),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                      border: Border.all(
                                                          color: orange
                                                              .withOpacity(
                                                                  0.3)),
                                                    ),
                                                    child: Text(
                                                      'Total: ${pets.length}',
                                                      style:
                                                          GoogleFonts.poppins(
                                                        fontSize: 12,
                                                        color: orange,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            )
                                          : Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'No pets',
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 14,
                                                    color: Colors.grey[600],
                                                    fontStyle: FontStyle.italic,
                                                  ),
                                                ),
                                                const SizedBox(height: 8),
                                                Align(
                                                  alignment:
                                                      Alignment.centerRight,
                                                  child: Container(
                                                    padding: const EdgeInsets
                                                            .symmetric(
                                                        horizontal: 8,
                                                        vertical: 4),
                                                    decoration: BoxDecoration(
                                                      color: Colors.grey
                                                          .withOpacity(0.1),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                      border: Border.all(
                                                          color: Colors.grey
                                                              .withOpacity(
                                                                  0.3)),
                                                    ),
                                                    child: Text(
                                                      'Total: 0',
                                                      style:
                                                          GoogleFonts.poppins(
                                                        fontSize: 12,
                                                        color: Colors.grey[600],
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                    ),
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
    );
  }
}
