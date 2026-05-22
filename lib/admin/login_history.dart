import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../config/supabase_config.dart';

class LoginHistoryPage extends StatefulWidget {
  const LoginHistoryPage({Key? key}) : super(key: key);

  @override
  State<LoginHistoryPage> createState() => _LoginHistoryPageState();
}

class _LoginHistoryPageState extends State<LoginHistoryPage> {
  final orange = const Color(0xFFF5A623);
  final lightOrange = const Color(0xFFFFF6E7);
  bool _isLoading = true;
  List<Map<String, dynamic>> _logins = [];
  Map<String, dynamic>? _adminProfile;
  int _visibleLogins = 5;
  int _totalPets = 0;

  @override
  void initState() {
    super.initState();
    _loadAdminProfile();
    _fetchLoginHistory();
    _fetchPetsCount();
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
        });
      }
    } catch (e) {
      print('Error loading admin profile: $e');
    }
  }

  Future<void> _fetchLoginHistory() async {
    setState(() => _isLoading = true);

    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;

      print('Fetching login history for user: ${user?.id}');

      if (user != null) {
        print('Attempting to fetch from login_history table...');
        final response = await supabase
          .from('login_history')
          .select('admin_name, login_date, login_time, timestamp')
          .order('timestamp', ascending: false)
          .limit(50);

        print('Login history response: $response');
        setState(() {
          _logins = List<Map<String, dynamic>>.from(response);
          _isLoading = false;
        });
        print('Parsed logins: $_logins');
      }
    } catch (e) {
      print('Error fetching login history: $e');
      // Mock data if table/query fails
      final now = DateTime.now();
      final adminName = _adminProfile?['full_name'] ?? 'Admin User';
      final mockLogins = List.generate(10, (i) {
        final loginDate = now.subtract(Duration(days: i));
        final loginTime = DateTime(loginDate.year, loginDate.month, loginDate.day, 9 + (i % 3), 30 + (i * 15) % 30);
        return {
          'admin_name': adminName,
          'login_date': loginDate.toIso8601String().split('T')[0],
          'login_time': '${(9 + (i % 3)).toString().padLeft(2, '0')}:${(30 + (i * 15) % 30).toString().padLeft(2, '0')}:00',
          'timestamp': loginTime.toIso8601String(),
        };
      });

      setState(() {
        _logins = mockLogins;
        _isLoading = false;
      });
      print('Using mock data: $_logins');
    }
  }

  Future<void> _fetchPetsCount() async {
    try {
      final response = await SupabaseConfig.client
          .from('grooming_appointments')
          .select('id')
          .count(CountOption.exact);

      if (mounted) {
        setState(() {
          _totalPets = response.count ?? 0;
        });
      }
    } catch (e) {
      print('Error fetching pets count: $e');
      if (mounted) {
        setState(() {
          _totalPets = 0;
        });
      }
    }
  }

  void _collapseLogins() {
    setState(() {
      _visibleLogins = 5;
    });
  }

  Map<String, int> _getLoginsPerDay() {
    final Map<String, int> loginsPerDay = {};

    for (final entry in _logins) {
      DateTime? dt;
      if (entry['timestamp'] != null) {
        dt = DateTime.tryParse(entry['timestamp']);
        if (dt != null && !dt.isUtc) {
          dt = dt.toLocal();
        }
      } else if (entry['login_date'] != null && entry['login_time'] != null) {
        try {
          final date = DateTime.parse(entry['login_date']);
          final timeParts = entry['login_time'].split(':');
          if (timeParts.length >= 2) {
            final hour = int.parse(timeParts[0]);
            final minute = int.parse(timeParts[1]);
            dt = DateTime(date.year, date.month, date.day, hour, minute);
          }
        } catch (e) {
          print('Error parsing date/time: $e');
        }
      }

      dt ??= DateTime.now();
      final key = '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
      loginsPerDay[key] = (loginsPerDay[key] ?? 0) + 1;
    }
    return loginsPerDay;
  }

  Map<String, int> _getLoginsByPeriod() {
    final Map<String, int> loginsByPeriod = {
      'AM': 0, 'PM': 0
    };

    for (final entry in _logins) {
      DateTime? dt;
      if (entry['timestamp'] != null) {
        dt = DateTime.tryParse(entry['timestamp']);
        if (dt != null && !dt.isUtc) {
          dt = dt.toLocal();
        }
      } else if (entry['login_date'] != null && entry['login_time'] != null) {
        try {
          final date = DateTime.parse(entry['login_date']);
          final timeParts = entry['login_time'].split(':');
          if (timeParts.length >= 2) {
            final hour = int.parse(timeParts[0]);
            final minute = int.parse(timeParts[1]);
            dt = DateTime(date.year, date.month, date.day, hour, minute);
          }
        } catch (e) {
          print('Error parsing date/time: $e');
        }
      }

      if (dt != null) {
        final hour = dt.hour;
        if (hour >= 0 && hour < 12) {
          loginsByPeriod['AM'] = loginsByPeriod['AM']! + 1;
        } else {
          loginsByPeriod['PM'] = loginsByPeriod['PM']! + 1;
        }
      }
    }

    return loginsByPeriod;
  }

  @override
  Widget build(BuildContext context) {
    final rawPerDay = _getLoginsPerDay();
    final sortedKeys = rawPerDay.keys.toList()
      ..sort((a, b) => DateTime.parse(a).compareTo(DateTime.parse(b)));
    final loginsPerDayKeys = sortedKeys;
    final loginsPerDayValues = loginsPerDayKeys.map((k) => rawPerDay[k] ?? 0).toList();
    final loginsByPeriod = _getLoginsByPeriod();
    final int totalLogins = _logins.length;
    final int amCount = loginsByPeriod['AM'] ?? 0;
    final int pmCount = loginsByPeriod['PM'] ?? 0;
    final DateFormat dateFmt = DateFormat('MMMM d, yyyy');
    final DateFormat timeFmt = DateFormat('h:mm a');

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
          'Login History',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
       
      ),
      backgroundColor: const Color(0xFFFDF6ED),
      // body: _isLoading
      //     ? const Center(child: CircularProgressIndicator(color: Color(0xFFF5A623)))
      //     : SingleChildScrollView(
      //         padding: const EdgeInsets.all(16),
      //         child: Column(
      //           crossAxisAlignment: CrossAxisAlignment.start,
      //           children: [
      //             Text(
      //               'Recent Logins',
      //               style: GoogleFonts.poppins(
      //                 fontWeight: FontWeight.bold,
      //                 fontSize: 18,
      //                 color: Colors.black87,
      //               ),
      //             ),
      body: _isLoading
    ? const Center(child: CircularProgressIndicator(color: Color(0xFFF5A623)),
    )
    : RefreshIndicator(
        onRefresh: () async {
          await _fetchLoginHistory();
          await _fetchPetsCount(); // optional if you want to refresh pets too
        },
        color: orange,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(), // 👈 ensures pull works even if content is short
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Recent Logins',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.black87,
                ),
              ),
                  const SizedBox(height: 4),
                  Text(
                    '$totalLogins total login(s)',
                    style: GoogleFonts.poppins(fontSize: 12, 
                    color: Colors.black54),
                  ),
                  const SizedBox(height: 12),


                  Container(
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
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade100,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(12),
                              topRight: Radius.circular(12),
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: Text(
                                  'Name of Admin',
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  'Date',
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Text(
                                  'Time',
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (_logins.isEmpty)
                          Container(
                            padding: const EdgeInsets.all(20),
                            child: Center(
                              child: Text(
                                'No login history found',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                          )
                        else
                          Column(
                            children: [
                              ..._logins.take(_visibleLogins).map((entry) {
                                DateTime? dt;
                                if (entry['timestamp'] != null) {
                                  dt = DateTime.tryParse(entry['timestamp']);
                                  if (dt != null && !dt.isUtc) {
                                    dt = dt.toLocal();
                                  }
                                } else if (entry['login_date'] != null && entry['login_time'] != null) {
                                  try {
                                    final date = DateTime.parse(entry['login_date']);
                                    final timeParts = entry['login_time'].split(':');
                                    if (timeParts.length >= 2) {
                                      final hour = int.parse(timeParts[0]);
                                      final minute = int.parse(timeParts[1]);
                                      dt = DateTime(date.year, date.month, date.day, hour, minute);
                                    }
                                  } catch (e) {
                                    print('Error parsing date/time: $e');
                                  }
                                }

                                dt ??= DateTime.now();

                                return Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  decoration: BoxDecoration(
                                    border: Border(
                                      top: BorderSide(color: Colors.grey.shade200),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          entry['admin_name'] ?? 'Admin User',
                                          style: GoogleFonts.poppins(
                                            fontSize: 13,
                                            color: Colors.black87,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          dateFmt.format(dt),
                                          style: GoogleFonts.poppins(
                                            fontSize: 13,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: Text(
                                          timeFmt.format(dt),
                                          style: GoogleFonts.poppins(
                                            fontSize: 13,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ],
                          ),
                        Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              if (_visibleLogins > 5)
                                TextButton(
                                  onPressed: _collapseLogins,
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.black87,
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'Load less',
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
                              if (_visibleLogins <= 5)
                                const Spacer(),
                              if (_visibleLogins < _logins.length)
                                TextButton(
                                  onPressed: () {
                                    setState(() {
                                      _visibleLogins += 5;
                                    });
                                  },
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.black87,
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'Load more',
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
              

                const SizedBox(height: 24),
                Text(
                  'Logins Per Day',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
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
                  child: SizedBox(
                    height: 220, // Increased height to accommodate rotated labels
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        barGroups: List.generate(loginsPerDayValues.length, (i) {
                          return BarChartGroupData(
                            x: i,
                            barRods: [
                              BarChartRodData(
                                toY: loginsPerDayValues[i].toDouble(),
                                color: orange,
                                width: 16, // Slightly reduced bar width for better spacing
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(4),
                                  topRight: Radius.circular(4),
                                ),
                              ),
                            ],
                          );
                        }),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 36, // Increased reserved size for y-axis labels
                              getTitlesWidget: (value, meta) {
                                return Text(
                                  value.toInt().toString(),
                                  style: GoogleFonts.poppins(
                                    fontSize: 10,
                                    color: Colors.grey[600],
                                  ),
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
                              reservedSize: 40, // Increased reserved size for x-axis labels
                              getTitlesWidget: (value, meta) {
                                final idx = value.toInt();
                                if (idx < 0 || idx >= loginsPerDayKeys.length) return const SizedBox();
                                final dateKey = loginsPerDayKeys[idx];
                                final label = DateFormat('MMM d').format(DateTime.parse(dateKey));
                                return Padding(
                                  padding: const EdgeInsets.only(top: 16),
                                  child: Transform.rotate(
                                    angle: -0.5, // Rotate labels by -30 degrees (in radians: -π/6 ≈ -0.5)
                                    child: Text(
                                      label,
                                      style: GoogleFonts.poppins(
                                        fontSize: 10, // Reduced font size for rotated labels
                                        fontWeight: FontWeight.w500,
                                        color: Colors.grey[700],
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        gridData: FlGridData(
                          show: true,
                          horizontalInterval: 1,
                          getDrawingHorizontalLine: (value) {
                            return FlLine(
                              color: Colors.grey[300]!,
                              strokeWidth: 1,
                            );
                          },
                        ),
                        maxY: loginsPerDayValues.isEmpty
                            ? 1
                            : (loginsPerDayValues.reduce((a, b) => a > b ? a : b) * 1.2).toDouble(), // Added 20% padding for maxY
                      ),
                    ),
                  ),
                ),


                  const SizedBox(height: 16),
                  // Logins by Time of Day Chart
                  Text(
                    'Logins by Time of the Day',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$amCount login(s) in AM, $pmCount login(s) in PM',
                    style: GoogleFonts.poppins(fontSize: 12, color: Colors.black54),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
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
                    child: SizedBox(
                      height: 200,
                      child: PieChart(
                        PieChartData(
                          sections: [
                            PieChartSectionData(
                              color: orange,
                              value: loginsByPeriod['AM']!.toDouble(),
                              title: 'AM\n${loginsByPeriod['AM']! > 0 ? ((loginsByPeriod['AM']! / (loginsByPeriod['AM']! + loginsByPeriod['PM']!)) * 100).toStringAsFixed(1) : '0.0'}%',
                              radius: 60,
                              titleStyle: GoogleFonts.poppins(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                            PieChartSectionData(
                              color: Colors.orange.shade300,
                              value: loginsByPeriod['PM']!.toDouble(),
                              title: 'PM\n${loginsByPeriod['PM']! > 0 ? ((loginsByPeriod['PM']! / (loginsByPeriod['AM']! + loginsByPeriod['PM']!)) * 100).toStringAsFixed(1) : '0.0'}%',
                              radius: 60,
                              titleStyle: GoogleFonts.poppins(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                          sectionsSpace: 2,
                          centerSpaceRadius: 40,
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
}
