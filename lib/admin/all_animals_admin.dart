// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';
// import '../config/supabase_config.dart';
// import 'home_admin.dart';
// import 'package:fl_chart/fl_chart.dart';
// import 'dart:async';

// class AllAnimalsAdminPage extends StatefulWidget {
//   const AllAnimalsAdminPage({Key? key}) : super(key: key);

//   @override
//   State<AllAnimalsAdminPage> createState() => _AllAnimalsAdminPageState();
// }

// class _AllAnimalsAdminPageState extends State<AllAnimalsAdminPage> with RouteAware {
//   List<Map<String, dynamic>> _animals = [];
//   bool _isLoading = true;
//   String _searchQuery = '';
//   bool _sortByNameAsc = true;
//   bool _sortByDateAsc = false;
//   String _selectedPetType = 'all';
//   Timer? _refreshTimer;
//   final ScrollController _scrollController = ScrollController();
//   bool _showScrollToTop = false;

//   @override
//   void initState() {
//     super.initState();
//     _fetchAnimals();
//     _scrollController.addListener(_onScroll);
//     _refreshTimer = Timer.periodic(const Duration(minutes: 2), (timer) {
//       _fetchAnimals();
//     });
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

//   @override
//   void dispose() {
//     _refreshTimer?.cancel();
//     _scrollController.removeListener(_onScroll);
//     _scrollController.dispose();
//     super.dispose();
//   }

//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     // Register this page as a route observer
//     RouteObserver<PageRoute>().subscribe(this, ModalRoute.of(context)! as PageRoute);
//   }

//   @override
//   void didPopNext() {
//     // Called when coming back to this page
//     _fetchAnimals();
//   }

//   Future<void> _fetchAnimals() async {
//     setState(() {
//       _isLoading = true;
//     });
//     try {
//       final response = await SupabaseConfig.client
//           .from('grooming_appointments')
//           .select('''
//             id, pet_name, pet_type, pet_type_other, breed, pet_size, age, gender,
//             allergies_medical_conditions, preferred_date, preferred_time, status,
//             user_id, created_at
//           ''')
//           .order('created_at', ascending: false);
      
//       if (response is List) {
//         setState(() {
//           _animals = List<Map<String, dynamic>>.from(response);
//         });
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Error fetching animals: $e'),
//           backgroundColor: Colors.red,
//         ),
//       );
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   void _sortByName() {
//     setState(() {
//       _sortByNameAsc = !_sortByNameAsc;
//       _animals.sort((a, b) {
//         final nameA = (a['pet_name'] ?? '').toString().toLowerCase();
//         final nameB = (b['pet_name'] ?? '').toString().toLowerCase();
//         return _sortByNameAsc ? nameA.compareTo(nameB) : nameB.compareTo(nameA);
//       });
//     });
//   }

//   void _sortByDate() {
//     setState(() {
//       _sortByDateAsc = !_sortByDateAsc;
//       _animals.sort((a, b) {
//         final dateA = DateTime.tryParse(a['created_at'] ?? '') ?? DateTime(2000);
//         final dateB = DateTime.tryParse(b['created_at'] ?? '') ?? DateTime(2000);
//         return _sortByDateAsc ? dateA.compareTo(dateB) : dateB.compareTo(dateA);
//       });
//     });
//   }

//   List<Map<String, dynamic>> get _filteredAnimals {
//     final filteredByType = _selectedPetType == 'all' 
//         ? _animals 
//         : _animals.where((animal) => (animal['pet_type'] ?? '').toString().toLowerCase() == _selectedPetType).toList();
    
//     if (_searchQuery.isEmpty) return filteredByType;
    
//     final query = _searchQuery.toLowerCase();
//     return filteredByType.where((animal) {
//       return (animal['pet_name'] ?? '').toString().toLowerCase().contains(query) ||
//           (animal['breed'] ?? '').toString().toLowerCase().contains(query) ||
//           (animal['pet_type'] ?? '').toString().toLowerCase().contains(query) ||
//           (animal['status'] ?? '').toString().toLowerCase().contains(query);
//     }).toList();
//   }

//   // Helper: Gender counts for demographics (uses full dataset)
//   Map<String, int> _genderCountsForDemographics() {
//     final Map<String, int> counts = {'male': 0, 'female': 0};
//     for (final animal in _animals) {
//       final gender = (animal['gender'] ?? '').toString().toLowerCase();
//       if (gender == 'male') counts['male'] = counts['male']! + 1;
//       else if (gender == 'female') counts['female'] = counts['female']! + 1;
//     }
//     return counts;
//   }

//   // Helper: Species counts for demographics (uses full dataset)
//   Map<String, int> _speciesCountsForDemographics() {
//     final Map<String, int> counts = {'dog': 0, 'cat': 0, 'other': 0};
//     for (final animal in _animals) {
//       final type = (animal['pet_type'] ?? '').toString().toLowerCase();
//       if (type == 'dog') counts['dog'] = counts['dog']! + 1;
//       else if (type == 'cat') counts['cat'] = counts['cat']! + 1;
//       else counts['other'] = counts['other']! + 1;
//     }
//     return counts;
//   }

//   // Helper: Age group counts for demographics (uses full dataset)
//   Map<String, int> _ageGroupCountsForDemographics() {
//     final Map<String, int> counts = {
//       '1': 0,
//       '2-5': 0,
//       '6-9': 0,
//       '10+': 0,
//     };
//     for (final animal in _animals) {
//       final age = int.tryParse((animal['age'] ?? '').toString()) ?? 0;
//       if (age == 1) counts['1'] = counts['1']! + 1;
//       else if (age >= 2 && age <= 5) counts['2-5'] = counts['2-5']! + 1;
//       else if (age >= 6 && age <= 9) counts['6-9'] = counts['6-9']! + 1;
//       else if (age >= 10) counts['10+'] = counts['10+']! + 1;
//     }
//     return counts;
//   }

//   // Helper: Monthly bookings for demographics (uses full dataset)
//   Map<int, int> _monthlyBookingsForDemographics() {
//     final Map<int, int> counts = {for (var i = 1; i <= 12; i++) i: 0};
//     for (final animal in _animals) {
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

//   Widget _buildDemographicsCharts() {
//     final genderCounts = _genderCountsForDemographics();
//     final speciesCounts = _speciesCountsForDemographics();
//     final ageCounts = _ageGroupCountsForDemographics();
//     final monthlyCounts = _monthlyBookingsForDemographics();
//     final orange = const Color(0xFFF5A623);
//     final blue = const Color(0xFF5094FF);
//     final maleColor = const Color(0xFF36ABFF);
//     final femaleColor = const Color(0xFFFFB4FE);
//     final green = Colors.green;
//     final purple = Colors.purple;
//     final grey = Colors.grey;
    
//     // Age group colors
//     final age1Color = const Color(0xFFFF741E);
//     final age2to5Color = const Color(0xFFFF3131);
//     final age6to9Color = const Color(0xFFFFDE59);
//     final age10PlusColor = const Color(0xFFFFBD59);
    
//     // Calculate percentages for gender
//     final totalGender = genderCounts['male']! + genderCounts['female']!;
//     final malePercentage = totalGender > 0 ? (genderCounts['male']! / totalGender * 100).round() : 0;
//     final femalePercentage = totalGender > 0 ? (genderCounts['female']! / totalGender * 100).round() : 0;
    
//     // Calculate dynamic maxY for each chart
//     final speciesMaxY = _dynamicMaxY([speciesCounts['dog']!, speciesCounts['cat']!, speciesCounts['other']!], step: 5, min: 5);
//     final ageMaxY = _dynamicMaxY([ageCounts['1']!, ageCounts['2-5']!, ageCounts['6-9']!, ageCounts['10+']!], step: 5, min: 5);
//     final monthlyMaxY = _dynamicMaxY(monthlyCounts.values, step: 5, min: 5);

//     return SingleChildScrollView(
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Gender Pie Chart
//           Text('Gender Distribution', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16, color: blue)),
//           SizedBox(
//             height: 180,
//             child: PieChart(
//               PieChartData(
//                 sections: [
//                   PieChartSectionData(
//                     color: maleColor,
//                     value: genderCounts['male']!.toDouble(),
//                     title: '${malePercentage}%\n${genderCounts['male']}',
//                     titleStyle: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
//                     titlePositionPercentageOffset: 0.6,
//                   ),
//                   PieChartSectionData(
//                     color: femaleColor,
//                     value: genderCounts['female']!.toDouble(),
//                     title: '${femalePercentage}%\n${genderCounts['female']}',
//                     titleStyle: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
//                     titlePositionPercentageOffset: 0.6,
//                   ),
//                 ],
//                 sectionsSpace: 2,
//                 centerSpaceRadius: 32,
//               ),
//             ),
//           ),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               _legendDot(maleColor), Text(' Male', style: GoogleFonts.poppins()),
//               const SizedBox(width: 16),
//               _legendDot(femaleColor), Text(' Female', style: GoogleFonts.poppins()),
//             ],
//           ),
//           const SizedBox(height: 24),
//           // Species Chart
//           Text('Species Booked', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16, color: blue)),
//           const SizedBox(height: 16),
//           SizedBox(
//             height: 180,
//             child: BarChart(
//               BarChartData(
//                 alignment: BarChartAlignment.spaceAround,
//                 barGroups: [
//                   BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: speciesCounts['dog']!.toDouble(), color: Colors.orange)]),
//                   BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: speciesCounts['cat']!.toDouble(), color: Colors.red)]),
//                   BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: speciesCounts['other']!.toDouble(), color: Colors.yellow )]),
//                 ],
//                 titlesData: FlTitlesData(
//                   leftTitles: AxisTitles(
//                     sideTitles: SideTitles(
//                       showTitles: true,
//                       reservedSize: 30,
//                       getTitlesWidget: (value, meta) {
//                         return Text(
//                           value.toInt().toString(),
//                           style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey[600]),
//                         );
//                       },
//                       interval: 5,
//                     ),
//                   ),
//                   rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
//                   topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
//                   bottomTitles: AxisTitles(
//                     sideTitles: SideTitles(
//                       showTitles: true,
//                       getTitlesWidget: (value, meta) {
//                         switch (value.toInt()) {
//                           case 0: return Text('Dog', style: GoogleFonts.poppins(fontSize: 12));
//                           case 1: return Text('Cat', style: GoogleFonts.poppins(fontSize: 12));
//                           case 2: return Text('Others', style: GoogleFonts.poppins(fontSize: 12));
//                           default: return const SizedBox();
//                         }
//                       },
//                     ),
//                   ),
//                 ),
//                 borderData: FlBorderData(show: false),
//                 gridData: FlGridData(
//                   show: true,
//                   horizontalInterval: 5,
//                   getDrawingHorizontalLine: (value) {
//                     return FlLine(
//                       color: Colors.grey[300]!,
//                       strokeWidth: 1,
//                     );
//                   },
//                 ),
//                 maxY: speciesMaxY.toDouble(),
//               ),
//             ),
//           ),
//           const SizedBox(height: 24),
//           // Age Bar Chart
//           Text('Age Groups', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16, color: blue)),
//           const SizedBox(height: 16),
//           SizedBox(
//             height: 180,
//             child: BarChart(
//               BarChartData(
//                 alignment: BarChartAlignment.spaceAround,
//                 barGroups: [
//                   BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: ageCounts['1']!.toDouble(), color: age1Color)]),
//                   BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: ageCounts['2-5']!.toDouble(), color: age2to5Color)]),
//                   BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: ageCounts['6-9']!.toDouble(), color: age6to9Color)]),
//                   BarChartGroupData(x: 3, barRods: [BarChartRodData(toY: ageCounts['10+']!.toDouble(), color: age10PlusColor)]),
//                 ],
//                 titlesData: FlTitlesData(
//                   leftTitles: AxisTitles(
//                     sideTitles: SideTitles(
//                       showTitles: true,
//                       reservedSize: 30,
//                       getTitlesWidget: (value, meta) {
//                         return Text(
//                           value.toInt().toString(),
//                           style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey[600]),
//                         );
//                       },
//                       interval: 5,
//                     ),
//                   ),
//                   rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
//                   topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
//                   bottomTitles: AxisTitles(
//                     sideTitles: SideTitles(
//                       showTitles: true,
//                       getTitlesWidget: (value, meta) {
//                         switch (value.toInt()) {
//                           case 0: return Text('1', style: GoogleFonts.poppins(fontSize: 12));
//                           case 1: return Text('2-5', style: GoogleFonts.poppins(fontSize: 12));
//                           case 2: return Text('6-9', style: GoogleFonts.poppins(fontSize: 12));
//                           case 3: return Text('10+', style: GoogleFonts.poppins(fontSize: 12));
//                           default: return const SizedBox();
//                         }
//                       },
//                     ),
//                   ),
//                 ),
//                 borderData: FlBorderData(show: false),
//                 gridData: FlGridData(
//                   show: true,
//                   horizontalInterval: 5,
//                   getDrawingHorizontalLine: (value) {
//                     return FlLine(
//                       color: Colors.grey[300]!,
//                       strokeWidth: 1,
//                     );
//                   },
//                 ),
//                 maxY: ageMaxY.toDouble(),
//               ),
//             ),
//           ),
//           // Age Groups Legend
//           Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               _legendDot(age1Color), Text(' 1', style: GoogleFonts.poppins(fontSize: 12)),
//               const SizedBox(width: 12),
//               _legendDot(age2to5Color), Text(' 2-5', style: GoogleFonts.poppins(fontSize: 12)),
//               const SizedBox(width: 12),
//               _legendDot(age6to9Color), Text(' 6-9', style: GoogleFonts.poppins(fontSize: 12)),
//               const SizedBox(width: 12),
//               _legendDot(age10PlusColor), Text(' 10+', style: GoogleFonts.poppins(fontSize: 12)),
//             ],
//           ),
//           const SizedBox(height: 24),
//           // Monthly Bookings Line Chart
//           Text('Monthly Bookings', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16, color: blue)),
//           const SizedBox(height: 16),
//           SizedBox(
//             height: 180,
//             child: LineChart(
//               LineChartData(
//                 lineBarsData: [
//                   LineChartBarData(
//                     spots: [
//                       for (int i = 1; i <= 12; i++)
//                         FlSpot(i.toDouble(), monthlyCounts[i]!.toDouble()),
//                     ],
//                     isCurved: true,
//                     color: orange,
//                     barWidth: 4,
//                     dotData: FlDotData(
//                       show: true,
//                       getDotPainter: (spot, percent, barData, index) {
//                         return FlDotCirclePainter(
//                           radius: 4,
//                           color: orange,
//                           strokeWidth: 2,
//                           strokeColor: Colors.white,
//                         );
//                       },
//                     ),
//                     belowBarData: BarAreaData(
//                       show: true,
//                       color: orange.withOpacity(0.1),
//                     ),
//                   ),
//                 ],
//                 titlesData: FlTitlesData(
//                   leftTitles: AxisTitles(
//                     sideTitles: SideTitles(
//                       showTitles: true,
//                       reservedSize: 30,
//                       getTitlesWidget: (value, meta) {
//                         return Text(
//                           value.toInt().toString(),
//                           style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey[600]),
//                         );
//                       },
//                       interval: 5,
//                     ),
//                   ),
//                   rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
//                   topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
//                   bottomTitles: AxisTitles(
//                     sideTitles: SideTitles(
//                       showTitles: true,
//                       getTitlesWidget: (value, meta) {
//                         const months = [
//                           '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
//                           'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
//                         ];
//                         if (value >= 1 && value <= 12) {
//                           return Text(months[value.toInt()], style: GoogleFonts.poppins(fontSize: 12));
//                         }
//                         return const SizedBox();
//                       },
//                     ),
//                   ),
//                 ),
//                 borderData: FlBorderData(show: false),
//                 gridData: FlGridData(
//                   show: true,
//                   horizontalInterval: 5,
//                   getDrawingHorizontalLine: (value) {
//                     return FlLine(
//                       color: Colors.grey[300]!,
//                       strokeWidth: 1,
//                     );
//                   },
//                 ),
//                 maxY: monthlyMaxY.toDouble(),
//               ),
//             ),
//           ),
//           const SizedBox(height: 24),
//         ],
//       ),
//     );
//   }

//   Widget _legendDot(Color color) {
//     return Container(
//       width: 14,
//       height: 14,
//       margin: const EdgeInsets.only(right: 4),
//       decoration: BoxDecoration(
//         color: color,
//         shape: BoxShape.circle,
//       ),
//     );
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
//           'All Animals',
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
//               if (_selectedPetType != 'dog')
//                 TextField(
//                   decoration: InputDecoration(
//                     hintText: 'Search animals by name and species',
//                     hintStyle: TextStyle(fontSize: 14, color: Colors.grey[500]),
//                     prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
//                     suffixIcon: _searchQuery.isNotEmpty
//                         ? IconButton(
//                             icon: Icon(Icons.clear, color: Colors.grey[400]),
//                             onPressed: () {
//                               setState(() {
//                                 _searchQuery = '';
//                               });
//                               FocusScope.of(context).unfocus();
//                             },
//                           )
//                         : null,
//                     filled: true,
//                     fillColor: Colors.grey[100],
//                     contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                       borderSide: BorderSide.none,
//                     ),
//                   ),
//                   onChanged: (value) {
//                     setState(() {
//                       _searchQuery = value;
//                     });
//                   },
//                 ),
//               const SizedBox(height: 16),
//               // Pet type filter and sort button in same row
//               Row(
//                 children: [
//                   GestureDetector(
//                     onTap: () {
//                       setState(() {
//                         _selectedPetType = 'all';
//                       });
//                     },
//                     child: Container(
//                       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                       decoration: BoxDecoration(
//                         color: _selectedPetType == 'all' ? orange : Colors.transparent,
//                         borderRadius: BorderRadius.circular(8),
//                         border: Border.all(color: orange, width: 1.2),
//                       ),
//                       child: Text(
//                         'All',
//                         style: GoogleFonts.poppins(
//                           color: _selectedPetType == 'all' ? Colors.white : orange,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(width: 8),
//                   GestureDetector(
//                     onTap: () {
//                       setState(() {
//                         _selectedPetType = 'dog';
//                       });
//                     },
//                     child: Container(
//                       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                       decoration: BoxDecoration(
//                         color: _selectedPetType == 'dog' ? Colors.blue : Colors.transparent,
//                         borderRadius: BorderRadius.circular(8),
//                         border: Border.all(color: Colors.blue, width: 1.2),
//                       ),
//                       child: Text(
//                         'Demographics',
//                         style: GoogleFonts.poppins(
//                           color: _selectedPetType == 'dog' ? Colors.white : Colors.blue,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                   ),
//                   const Spacer(),
//                   if (_selectedPetType != 'dog') PopupMenuButton<String>(
//                     onSelected: (value) {
//                       if (value == 'name_asc') {
//                         setState(() {
//                           _sortByNameAsc = true;
//                           _animals.sort((a, b) {
//                             final nameA = (a['pet_name'] ?? '').toString().toLowerCase();
//                             final nameB = (b['pet_name'] ?? '').toString().toLowerCase();
//                             return nameA.compareTo(nameB);
//                           });
//                         });
//                       } else if (value == 'name_desc') {
//                         setState(() {
//                           _sortByNameAsc = false;
//                           _animals.sort((a, b) {
//                             final nameA = (a['pet_name'] ?? '').toString().toLowerCase();
//                             final nameB = (b['pet_name'] ?? '').toString().toLowerCase();
//                             return nameB.compareTo(nameA);
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
//               Expanded(
//                 child: _isLoading
//                     ? const Center(child: CircularProgressIndicator(color: Color(0xFFF5A623)))
//                     : _filteredAnimals.isEmpty
//                         ? Center(
//                             child: Text(
//                               'No animals found.',
//                               style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey[600]),
//                             ),
//                           )
//                         : _selectedPetType == 'dog'
//                             ? _buildDemographicsCharts()
//                             : ListView.separated(
//                                 controller: _scrollController,
//                                 itemCount: _filteredAnimals.length,
//                                 separatorBuilder: (context, index) => const SizedBox(height: 12),
//                                 itemBuilder: (context, index) {
//                                   final animal = _filteredAnimals[index];
//                                   return Container(
//                                     padding: const EdgeInsets.all(16),
//                                     decoration: BoxDecoration(
//                                       color: Colors.white,
//                                       borderRadius: BorderRadius.circular(12),
//                                       boxShadow: [
//                                         BoxShadow(
//                                           color: Colors.black.withOpacity(0.05),
//                                           blurRadius: 6,
//                                           offset: const Offset(0, 2),
//                                         ),
//                                       ],
//                                     ),
//                                     child: Column(
//                                       crossAxisAlignment: CrossAxisAlignment.start,
//                                       children: [
//                                         Row(
//                                           children: [
//                                             Icon(
//                                               animal['pet_type'] == 'dog' ? Icons.pets : Icons.pets,
//                                               color: animal['pet_type'] == 'dog' ? orange : Colors.orange,
//                                               size: 28,
//                                             ),
//                                             const SizedBox(width: 12),
//                                             Expanded(
//                                               child: Text(
//                                                 animal['pet_name'] ?? '-',
//                                                 style: GoogleFonts.poppins(
//                                                   fontSize: 18,
//                                                   fontWeight: FontWeight.w600,
//                                                   color: Colors.black87,
//                                                 ),
//                                               ),
//                                             ),
//                                             // Status removed
//                                           ],
//                                         ),
//                                         const SizedBox(height: 8),
//                                         Row(
//                                           children: [
//                                             Icon(Icons.category, color: Colors.grey[400], size: 18),
//                                             const SizedBox(width: 6),
//                                             Expanded(
//                                               child: Text(
//                                                 '${animal['pet_type'] ?? '-'}${animal['pet_type_other'] != null && animal['pet_type_other'].toString().isNotEmpty ? ' (${animal['pet_type_other']})' : ''}',
//                                                 style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[700]),
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                         const SizedBox(height: 4),
//                                         Row(
//                                           children: [
//                                             Icon(Icons.pets, color: Colors.grey[400], size: 18),
//                                             const SizedBox(width: 6),
//                                             Expanded(
//                                               child: Text(
//                                                 animal['breed'] ?? '-',
//                                                 style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[700]),
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                         const SizedBox(height: 4),
//                                         Row(
//                                           children: [
//                                             Icon(Icons.straighten, color: Colors.grey[400], size: 18),
//                                             const SizedBox(width: 6),
//                                             Expanded(
//                                               child: Text(
//                                                 '${animal['age'] ?? '-'} years old, ${animal['gender'] ?? '-'}',
//                                                 style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[700]),
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                         const SizedBox(height: 4),
//                                         Row(
//                                           children: [
//                                             Icon(Icons.calendar_today, color: Colors.grey[400], size: 18),
//                                             const SizedBox(width: 6),
//                                             Expanded(
//                                               child: Text(
//                                                 animal['preferred_date'] != null
//                                                     ? _formatDate(animal['preferred_date'])
//                                                     : '-',
//                                                 style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[700]),
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                       ],
//                                     ),
//                                   );
//                                 },
//                               ),
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

// new

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import 'home_admin.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:async';

class AllAnimalsAdminPage extends StatefulWidget {
  const AllAnimalsAdminPage({Key? key}) : super(key: key);

  @override
  State<AllAnimalsAdminPage> createState() => _AllAnimalsAdminPageState();
}

class _AllAnimalsAdminPageState extends State<AllAnimalsAdminPage> with RouteAware {
  List<Map<String, dynamic>> _animals = [];
  bool _isLoading = true;
  String _searchQuery = '';
  bool _sortByNameAsc = true;
  bool _sortByDateAsc = false;
  String _selectedPetType = 'all';
  Timer? _refreshTimer;
  final ScrollController _scrollController = ScrollController();
  bool _showScrollToTop = false;

  @override
  void initState() {
    super.initState();
    _fetchAnimals();
    _scrollController.addListener(_onScroll);
    _refreshTimer = Timer.periodic(const Duration(minutes: 2), (timer) {
      _fetchAnimals();
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    RouteObserver<PageRoute>().subscribe(this, ModalRoute.of(context)! as PageRoute);
  }

  @override
  void didPopNext() {
    _fetchAnimals();
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

  Future<void> _fetchAnimals() async {
    setState(() => _isLoading = true);
    try {
      final response = await SupabaseConfig.client
          .from('grooming_appointments')
          .select('''
            id, pet_name, pet_type, pet_type_other, breed, pet_size, age, gender,
            allergies_medical_conditions, preferred_date, preferred_time, status,
            user_id, created_at
          ''')
          .order('created_at', ascending: false);

      if (response is List) {
        setState(() => _animals = List<Map<String, dynamic>>.from(response));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error fetching animals: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleRefresh() async {
    await _fetchAnimals();
  }

  void _sortByName() {
    setState(() {
      _sortByNameAsc = !_sortByNameAsc;
      _animals.sort((a, b) {
        final nameA = (a['pet_name'] ?? '').toString().toLowerCase();
        final nameB = (b['pet_name'] ?? '').toString().toLowerCase();
        return _sortByNameAsc ? nameA.compareTo(nameB) : nameB.compareTo(nameA);
      });
    });
  }

  void _sortByDate() {
    setState(() {
      _sortByDateAsc = !_sortByDateAsc;
      _animals.sort((a, b) {
        final dateA = DateTime.tryParse(a['created_at'] ?? '') ?? DateTime(2000);
        final dateB = DateTime.tryParse(b['created_at'] ?? '') ?? DateTime(2000);
        return _sortByDateAsc ? dateA.compareTo(dateB) : dateB.compareTo(dateA);
      });
    });
  }

  List<Map<String, dynamic>> get _filteredAnimals {
    final filteredByType = _selectedPetType == 'all'
        ? _animals
        : _animals.where((animal) => (animal['pet_type'] ?? '').toString().toLowerCase() == _selectedPetType).toList();

    if (_searchQuery.isEmpty) return filteredByType;

    final query = _searchQuery.toLowerCase();
    return filteredByType.where((animal) {
      return (animal['pet_name'] ?? '').toString().toLowerCase().contains(query) ||
          (animal['breed'] ?? '').toString().toLowerCase().contains(query) ||
          (animal['pet_type'] ?? '').toString().toLowerCase().contains(query) ||
          (animal['status'] ?? '').toString().toLowerCase().contains(query);
    }).toList();
  }

  Map<String, int> _genderCountsForDemographics() {
    final Map<String, int> counts = {'male': 0, 'female': 0};
    for (final animal in _animals) {
      final gender = (animal['gender'] ?? '').toString().toLowerCase();
      if (gender == 'male') counts['male'] = counts['male']! + 1;
      else if (gender == 'female') counts['female'] = counts['female']! + 1;
    }
    return counts;
  }

  Map<String, int> _speciesCountsForDemographics() {
    final Map<String, int> counts = {'dog': 0, 'cat': 0, 'other': 0};
    for (final animal in _animals) {
      final type = (animal['pet_type'] ?? '').toString().toLowerCase();
      if (type == 'dog') counts['dog'] = counts['dog']! + 1;
      else if (type == 'cat') counts['cat'] = counts['cat']! + 1;
      else counts['other'] = counts['other']! + 1;
    }
    return counts;
  }

  Map<String, int> _ageGroupCountsForDemographics() {
    final Map<String, int> counts = {
      '1': 0,
      '2-5': 0,
      '6-9': 0,
      '10+': 0,
    };
    for (final animal in _animals) {
      final age = int.tryParse((animal['age'] ?? '').toString()) ?? 0;
      if (age == 1) counts['1'] = counts['1']! + 1;
      else if (age >= 2 && age <= 5) counts['2-5'] = counts['2-5']! + 1;
      else if (age >= 6 && age <= 9) counts['6-9'] = counts['6-9']! + 1;
      else if (age >= 10) counts['10+'] = counts['10+']! + 1;
    }
    return counts;
  }

  Map<int, int> _monthlyBookingsForDemographics() {
    final Map<int, int> counts = {for (var i = 1; i <= 12; i++) i: 0};
    for (final animal in _animals) {
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

  Widget _buildDemographicsCharts() {
    final genderCounts = _genderCountsForDemographics();
    final speciesCounts = _speciesCountsForDemographics();
    final ageCounts = _ageGroupCountsForDemographics();
    final monthlyCounts = _monthlyBookingsForDemographics();
    final orange = const Color(0xFFF5A623);
    final blue = const Color(0xFF5094FF);
    final maleColor = const Color(0xFF36ABFF);
    final femaleColor = const Color(0xFFFFB4FE);
    final age1Color = const Color(0xFFFF741E);
    final age2to5Color = const Color(0xFFFF3131);
    final age6to9Color = const Color(0xFFFFDE59);
    final age10PlusColor = const Color(0xFFFFBD59);

    final totalGender = genderCounts['male']! + genderCounts['female']!;
    final malePercentage = totalGender > 0 ? (genderCounts['male']! / totalGender * 100).round() : 0;
    final femalePercentage = totalGender > 0 ? (genderCounts['female']! / totalGender * 100).round() : 0;

    final speciesMaxY = _dynamicMaxY([speciesCounts['dog']!, speciesCounts['cat']!, speciesCounts['other']!], step: 5, min: 5);
    final ageMaxY = _dynamicMaxY([ageCounts['1']!, ageCounts['2-5']!, ageCounts['6-9']!, ageCounts['10+']!], step: 5, min: 5);
    final monthlyMaxY = _dynamicMaxY(monthlyCounts.values, step: 5, min: 5);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Gender Distribution', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16, color: blue)),
          SizedBox(
            height: 180,
            child: PieChart(
              PieChartData(
                sections: [
                  PieChartSectionData(
                    color: maleColor,
                    value: genderCounts['male']!.toDouble(),
                    title: '${malePercentage}%\n${genderCounts['male']}',
                    titleStyle: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                    titlePositionPercentageOffset: 0.6,
                  ),
                  PieChartSectionData(
                    color: femaleColor,
                    value: genderCounts['female']!.toDouble(),
                    title: '${femalePercentage}%\n${genderCounts['female']}',
                    titleStyle: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                    titlePositionPercentageOffset: 0.6,
                  ),
                ],
                sectionsSpace: 2,
                centerSpaceRadius: 32,
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _legendDot(maleColor), Text(' Male', style: GoogleFonts.poppins()),
              const SizedBox(width: 16),
              _legendDot(femaleColor), Text(' Female', style: GoogleFonts.poppins()),
            ],
          ),
          const SizedBox(height: 24),
          Text('Species Booked', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16, color: blue)),
          const SizedBox(height: 16),
          SizedBox(
            height: 180,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                barGroups: [
                  BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: speciesCounts['dog']!.toDouble(), color: Colors.orange)]),
                  BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: speciesCounts['cat']!.toDouble(), color: Colors.red)]),
                  BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: speciesCounts['other']!.toDouble(), color: Colors.yellow)]),
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
                        switch (value.toInt()) {
                          case 0: return Text('Dog', style: GoogleFonts.poppins(fontSize: 12));
                          case 1: return Text('Cat', style: GoogleFonts.poppins(fontSize: 12));
                          case 2: return Text('Others', style: GoogleFonts.poppins(fontSize: 12));
                          default: return const SizedBox();
                        }
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
                maxY: speciesMaxY.toDouble(),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text('Age Groups', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16, color: blue)),
          const SizedBox(height: 16),
          SizedBox(
            height: 180,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                barGroups: [
                  BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: ageCounts['1']!.toDouble(), color: age1Color)]),
                  BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: ageCounts['2-5']!.toDouble(), color: age2to5Color)]),
                  BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: ageCounts['6-9']!.toDouble(), color: age6to9Color)]),
                  BarChartGroupData(x: 3, barRods: [BarChartRodData(toY: ageCounts['10+']!.toDouble(), color: age10PlusColor)]),
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
                        switch (value.toInt()) {
                          case 0: return Text('1', style: GoogleFonts.poppins(fontSize: 12));
                          case 1: return Text('2-5', style: GoogleFonts.poppins(fontSize: 12));
                          case 2: return Text('6-9', style: GoogleFonts.poppins(fontSize: 12));
                          case 3: return Text('10+', style: GoogleFonts.poppins(fontSize: 12));
                          default: return const SizedBox();
                        }
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
                maxY: ageMaxY.toDouble(),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _legendDot(age1Color), Text(' 1', style: GoogleFonts.poppins(fontSize: 12)),
              const SizedBox(width: 12),
              _legendDot(age2to5Color), Text(' 2-5', style: GoogleFonts.poppins(fontSize: 12)),
              const SizedBox(width: 12),
              _legendDot(age6to9Color), Text(' 6-9', style: GoogleFonts.poppins(fontSize: 12)),
              const SizedBox(width: 12),
              _legendDot(age10PlusColor), Text(' 10+', style: GoogleFonts.poppins(fontSize: 12)),
            ],
          ),
          const SizedBox(height: 24),
          Text('Monthly Bookings', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16, color: blue)),
          const SizedBox(height: 16),
          SizedBox(
            height: 180,
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
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _legendDot(Color color) {
    return Container(
      width: 14,
      height: 14,
      margin: const EdgeInsets.only(right: 4),
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
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
          'All Animals',
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
              if (_selectedPetType != 'dog')
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search animals by name and species',
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
                    onTap: () => setState(() => _selectedPetType = 'all'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: _selectedPetType == 'all' ? orange : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: orange, width: 1.2),
                      ),
                      child: Text(
                        'All',
                        style: GoogleFonts.poppins(
                          color: _selectedPetType == 'all' ? Colors.white : orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => setState(() => _selectedPetType = 'dog'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: _selectedPetType == 'dog' ? Colors.blue : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue, width: 1.2),
                      ),
                      child: Text(
                        'Demographics',
                        style: GoogleFonts.poppins(
                          color: _selectedPetType == 'dog' ? Colors.white : Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (_selectedPetType != 'dog')
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'name_asc') {
                          setState(() => _sortByNameAsc = true);
                          _sortByName();
                        } else if (value == 'name_desc') {
                          setState(() => _sortByNameAsc = false);
                          _sortByName();
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
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator(color: Color(0xFFF5A623)))
                    : _filteredAnimals.isEmpty
                        ? Center(
                            child: Text(
                              'No animals found.',
                              style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey[600]),
                            ),
                          )
                        : _selectedPetType == 'dog'
                            ? _buildDemographicsCharts()
                            : RefreshIndicator(
                                color: orange,
                                onRefresh: _handleRefresh,
                                child: ListView.separated(
                                  controller: _scrollController,
                                  itemCount: _filteredAnimals.length,
                                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                                  itemBuilder: (context, index) {
                                    final animal = _filteredAnimals[index];
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
                                              Icon(
                                                animal['pet_type'] == 'dog' ? Icons.pets : Icons.pets,
                                                color: animal['pet_type'] == 'dog' ? orange : Colors.orange,
                                                size: 28,
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Text(
                                                  animal['pet_name'] ?? '-',
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.black87,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          Row(
                                            children: [
                                              Icon(Icons.category, color: Colors.grey[400], size: 18),
                                              const SizedBox(width: 6),
                                              Expanded(
                                                child: Text(
                                                  '${animal['pet_type'] ?? '-'}${animal['pet_type_other'] != null && animal['pet_type_other'].toString().isNotEmpty ? ' (${animal['pet_type_other']})' : ''}',
                                                  style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[700]),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              Icon(Icons.pets, color: Colors.grey[400], size: 18),
                                              const SizedBox(width: 6),
                                              Expanded(
                                                child: Text(
                                                  animal['breed'] ?? '-',
                                                  style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[700]),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              Icon(Icons.straighten, color: Colors.grey[400], size: 18),
                                              const SizedBox(width: 6),
                                              Expanded(
                                                child: Text(
                                                  '${animal['age'] ?? '-'} years old, ${animal['gender'] ?? '-'}',
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
                                                  animal['preferred_date'] != null
                                                      ? _formatDate(animal['preferred_date'])
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
