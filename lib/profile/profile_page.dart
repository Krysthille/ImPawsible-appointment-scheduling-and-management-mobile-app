

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../messages/messages_page.dart';
import '../home.dart';
import '../grooming/grooming_page.dart';
import 'dart:async';
import 'change_password.dart';

// FAQs data
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

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int _selectedIndex = 3;
  Map<String, dynamic>? _userProfile;
  List<Map<String, dynamic>> _pets = [];
  List<Map<String, dynamic>> _allPets = [];
  List<Map<String, dynamic>> _appointments = [];
  List<Map<String, dynamic>> _allAppointments = [];
  bool _isLoading = true;
  String _petSortType = 'name_asc';
  String _appointmentSortType = 'date_desc';
  int _displayedPetsCount = 3;
  int _displayedAppointmentsCount = 3;
  Timer? _refreshTimer;
  String? _profileImageUrl;
  final ImagePicker _picker = ImagePicker();
  final ScrollController _scrollController = ScrollController();
  bool _showScrollToTop = false;

  @override
  void initState() {
    super.initState();
    _fetchProfileData();
    _refreshTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
      _fetchProfileData();
    });
    _scrollController.addListener(_onScroll);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fetchProfileData();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels > 200) {
      if (!_showScrollToTop) {
        setState(() {
          _showScrollToTop = true;
        });
      }
    } else {
      if (_showScrollToTop) {
        setState(() {
          _showScrollToTop = false;
        });
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

  Future<void> _refreshProfileData() async {
    await _fetchProfileData();
  }

  Future<void> _fetchProfileData() async {
    setState(() => _isLoading = true);
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;
    if (user == null) return;

    try {
      final userResp = await supabase
          .from('users')
          .select('full_name, email, contact_number, profile_image_url')
          .eq('id', user.id)
          .maybeSingle();
      print('User profile data: $userResp');

      final petsResp = await supabase
          .from('grooming_appointments')
          .select('pet_name, pet_type, pet_type_other, breed, pet_size, age, gender, user_id')
          .eq('user_id', user.id);

      final apptResp = await supabase
          .from('grooming_appointments')
          .select()
          .eq('user_id', user.id)
          .order('preferred_date', ascending: false);

      final now = DateTime.now();
      final allAppointments = apptResp is List ? List<Map<String, dynamic>>.from(apptResp) : [];
      final pastAppointments = allAppointments.where((appt) {
        final appointmentDate = DateTime.tryParse(appt['preferred_date'] ?? '');
        final status = appt['status'] ?? '';
        if (status.toLowerCase() == 'completed') return true;
        if (appointmentDate != null) {
          final today = DateTime(now.year, now.month, now.day);
          final appointmentDay = DateTime(appointmentDate.year, appointmentDate.month, appointmentDate.day);
          return appointmentDay.isBefore(today);
        }
        return false;
      }).toList();

      setState(() {
        _userProfile = userResp;
        _profileImageUrl = userResp?['profile_image_url'];
        _allPets = petsResp is List ? List<Map<String, dynamic>>.from(petsResp) : [];
        _pets = _allPets.take(_displayedPetsCount).toList();
        _allAppointments = List<Map<String, dynamic>>.from(pastAppointments);
        _appointments = _allAppointments.take(_displayedAppointmentsCount).toList();
        _isLoading = false;
      });

      _applyPetSorting();
      _applyAppointmentSorting();
    } catch (e) {
      print('Error fetching profile data: $e');
      setState(() => _isLoading = false);
    }
  }

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;
    switch (index) {
      case 0:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomePage()));
        break;
      case 1:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const GroomingPage()));
        break;
      case 2:
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MessagesPage()));
        break;
      case 3:
        break;
    }
    setState(() {
      _selectedIndex = index;
    });
  }

  Map<int, int> _getMonthlyAppointmentsData() {
    final Map<int, int> weeklyData = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
    final now = DateTime.now();
    final currentMonth = now.month;
    final currentYear = now.year;

    for (final appointment in _allAppointments) {
      final appointmentDate = DateTime.tryParse(appointment['preferred_date'] ?? '');
      if (appointmentDate != null &&
          appointmentDate.month == currentMonth &&
          appointmentDate.year == currentYear) {
        final week = ((appointmentDate.day - 1) ~/ 7) + 1;
        if (week >= 1 && week <= 5) {
          weeklyData[week] = (weeklyData[week] ?? 0) + 1;
        }
      }
    }
    return weeklyData;
  }

  void _expandPets() {
    setState(() {
      _displayedPetsCount = (_displayedPetsCount + 3).clamp(3, _allPets.length);
      _pets = _allPets.take(_displayedPetsCount).toList();
      _applyPetSorting();
    });
  }

  void _collapsePets() {
    setState(() {
      _displayedPetsCount = 3;
      _pets = _allPets.take(_displayedPetsCount).toList();
      _applyPetSorting();
    });
  }

  void _expandAppointments() {
    setState(() {
      _displayedAppointmentsCount = (_displayedAppointmentsCount + 3).clamp(3, _allAppointments.length);
      _appointments = _allAppointments.take(_displayedAppointmentsCount).toList();
      _applyAppointmentSorting();
    });
  }

  void _collapseAppointments() {
    setState(() {
      _displayedAppointmentsCount = 3;
      _appointments = _allAppointments.take(_displayedAppointmentsCount).toList();
      _applyAppointmentSorting();
    });
  }

  void _applyPetSorting() {
    setState(() {
      _pets.sort((a, b) {
        switch (_petSortType) {
          case 'name_asc':
            final nameA = (a['pet_name'] ?? '').toString().toLowerCase();
            final nameB = (b['pet_name'] ?? '').toString().toLowerCase();
            return nameA.compareTo(nameB);
          case 'name_desc':
            final nameA = (a['pet_name'] ?? '').toString().toLowerCase();
            final nameB = (b['pet_name'] ?? '').toString().toLowerCase();
            return nameB.compareTo(nameA);
          default:
            return 0;
        }
      });
    });
  }

  void _applyAppointmentSorting() {
    setState(() {
      _appointments.sort((a, b) {
        switch (_appointmentSortType) {
          case 'name_asc':
            final nameA = (a['pet_name'] ?? '').toString().toLowerCase();
            final nameB = (b['pet_name'] ?? '').toString().toLowerCase();
            return nameA.compareTo(nameB);
          case 'name_desc':
            final nameA = (a['pet_name'] ?? '').toString().toLowerCase();
            final nameB = (b['pet_name'] ?? '').toString().toLowerCase();
            return nameB.compareTo(nameA);
          case 'date_asc':
            final dateA = DateTime.tryParse(a['preferred_date'] ?? '') ?? DateTime(2000);
            final dateB = DateTime.tryParse(b['preferred_date'] ?? '') ?? DateTime(2000);
            return dateA.compareTo(dateB);
          case 'date_desc':
            final dateA = DateTime.tryParse(a['preferred_date'] ?? '') ?? DateTime(2000);
            final dateB = DateTime.tryParse(b['preferred_date'] ?? '') ?? DateTime(2000);
            return dateB.compareTo(dateA);
          default:
            return 0;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final orange = const Color(0xFFF5A623);
    final lightOrange = const Color(0xFFFFF6E7);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFF6E7), Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: _refreshProfileData,
                  color: Colors.orange,
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 24),
                        Center(
                          child: Column(
                            children: [
                              GestureDetector(
                                onTap: _showImagePickerDialog,
                                child: Stack(
                                  children: [
                                    CircleAvatar(
                                      radius: 48,
                                      backgroundColor: orange.withOpacity(0.15),
                                      backgroundImage: _profileImageUrl != null
                                          ? NetworkImage(_profileImageUrl!)
                                          : null,
                                      child: _profileImageUrl == null
                                          ? Icon(Icons.person, size: 48, color: orange)
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
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    _userProfile?['full_name'] ?? 'Full Name',
                                    style: GoogleFonts.poppins(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: orange,
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
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.email, size: 16, color: Colors.grey[600]),
                                  const SizedBox(width: 6),
                                  Text(
                                    _userProfile?['email'] ?? 'Email',
                                    style: GoogleFonts.poppins(fontSize: 15, color: Colors.black87),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.phone, size: 16, color: Colors.grey[600]),
                                  const SizedBox(width: 6),
                                  Text(
                                    _userProfile?['contact_number'] ?? 'Contact Number',
                                    style: GoogleFonts.poppins(fontSize: 15, color: Colors.black87),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Pet Information',
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: orange,
                                ),
                              ),
                              Row(
                                children: [
                                  if (_allPets.length > 3)
                                    TextButton(
                                      onPressed: _displayedPetsCount < _allPets.length ? _expandPets : _collapsePets,
                                      style: TextButton.styleFrom(
                                        foregroundColor: Colors.black87,
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            _displayedPetsCount < _allPets.length ? 'Show more' : 'Show less',
                                            style: GoogleFonts.poppins(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          Container(
                                            width: 16,
                                            height: 16,
                                            decoration: const BoxDecoration(
                                              color: Colors.black87,
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              _displayedPetsCount < _allPets.length
                                                  ? Icons.keyboard_arrow_down
                                                  : Icons.keyboard_arrow_up,
                                              color: Colors.white,
                                              size: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  if (_allPets.isNotEmpty) ...[
                                    const SizedBox(width: 8),
                                    PopupMenuButton<String>(
                                      onSelected: (value) {
                                        setState(() {
                                          _petSortType = value;
                                        });
                                        _applyPetSorting();
                                      },
                                      itemBuilder: (context) => [
                                        PopupMenuItem(
                                          value: 'name_asc',
                                          child: Text('Name (A–Z)', style: GoogleFonts.poppins(fontSize: 13)),
                                        ),
                                        PopupMenuItem(
                                          value: 'name_desc',
                                          child: Text('Name (Z–A)', style: GoogleFonts.poppins(fontSize: 13)),
                                        ),
                                      ],
                                      child: Row(
                                        children: [
                                          Icon(Icons.sort, color: Colors.grey[600], size: 20),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Sort',
                                            style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                          child: _pets.isEmpty
                              ? Text('No pets found.', style: GoogleFonts.poppins(color: Colors.grey[600]))
                              : Column(
                                  children: _pets.map((pet) => _petCard(pet, orange)).toList(),
                                ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Appointment History',
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: orange,
                                ),
                              ),
                              Row(
                                children: [
                                  if (_allAppointments.length > 3)
                                    TextButton(
                                      onPressed: _displayedAppointmentsCount < _allAppointments.length
                                          ? _expandAppointments
                                          : _collapseAppointments,
                                      style: TextButton.styleFrom(
                                        foregroundColor: Colors.black87,
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            _displayedAppointmentsCount < _allAppointments.length ? 'Show more' : 'Show less',
                                            style: GoogleFonts.poppins(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          Container(
                                            width: 10,
                                            height: 16,
                                            decoration: const BoxDecoration(
                                              color: Colors.black87,
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              _displayedAppointmentsCount < _allAppointments.length
                                                  ? Icons.keyboard_arrow_down
                                                  : Icons.keyboard_arrow_up,
                                              color: Colors.white,
                                              size: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  if (_allAppointments.isNotEmpty) ...[
                                    const SizedBox(width: 8),
                                    PopupMenuButton<String>(
                                      onSelected: (value) {
                                        setState(() {
                                          _appointmentSortType = value;
                                        });
                                        _applyAppointmentSorting();
                                      },
                                      itemBuilder: (context) => [
                                        PopupMenuItem(
                                          value: 'name_asc',
                                          child: Text('Pet Name (A–Z)', style: GoogleFonts.poppins(fontSize: 13)),
                                        ),
                                        PopupMenuItem(
                                          value: 'name_desc',
                                          child: Text('Pet Name (Z–A)', style: GoogleFonts.poppins(fontSize: 13)),
                                        ),
                                        PopupMenuItem(
                                          value: 'date_asc',
                                          child: Text('Date (Oldest First)', style: GoogleFonts.poppins(fontSize: 13)),
                                        ),
                                        PopupMenuItem(
                                          value: 'date_desc',
                                          child: Text('Date (Newest First)', style: GoogleFonts.poppins(fontSize: 13)),
                                        ),
                                      ],
                                      child: Row(
                                        children: [
                                          Icon(Icons.sort, color: Colors.grey[600], size: 20),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Sort',
                                            style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                          child: _appointments.isEmpty
                              ? Text('No past appointments found.', style: GoogleFonts.poppins(color: Colors.grey[600]))
                              : Column(
                                  children: _appointments.map((appt) => _appointmentCard(appt, orange)).toList(),
                                ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: _sectionHeader('Settings'),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: _settingsTile(
                            context,
                            icon: Icons.lock,
                            title: 'Change Password',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const ChangePasswordPage()),
                              );
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: _sectionHeader('Legal & Policies'),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: _settingsTile(
                            context,
                            icon: Icons.description,
                            title: 'Terms and Conditions',
                            onTap: () {
                              _showTermsAndConditionsDialog(context);
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: _settingsTile(
                            context,
                            icon: Icons.privacy_tip,
                            title: 'Privacy Policy',
                            onTap: () {
                              _showPrivacyPolicyDialog(context);
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: _sectionHeader('Feedback'),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: _settingsTile(
                            context,
                            icon: Icons.star,
                            title: 'Rate and Review',
                            onTap: () {
                              _showRateAndReviewDialog(context);
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: _settingsTile(
                            context,
                            icon: Icons.chat,
                            title: 'Chat with Admin',
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (_) => const MessagesPage()));
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: _settingsTile(
                            context,
                            icon: Icons.help_outline,
                            title: 'FAQs',
                            onTap: () {
                              _showFAQsDialog(context);
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: _settingsTile(
                              context,
                              icon: Icons.logout,
                              title: 'Logout',
                              titleColor: Colors.red,
                              iconColor: Colors.red,
                              onTap: () {
                                _showLogoutDialog(context);
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
        ),
      ),
      bottomNavigationBar: _bottomNavBar(orange),
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

  Widget _petCard(Map<String, dynamic> pet, Color orange) {
    final petType = pet['pet_type'] ?? '';
    final petTypeOther = pet['pet_type_other'] ?? '';
    final displayType = petType == 'other' && petTypeOther.isNotEmpty ? petTypeOther : petType;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: orange.withOpacity(0.12),
            child: Icon(Icons.pets, size: 24, color: orange),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pet['pet_name'] ?? 'Pet Name',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16, color: orange),
                ),
                Text(
                  '$displayType | ${pet['breed'] ?? ''}',
                  style: GoogleFonts.poppins(fontSize: 13, color: Colors.black87),
                ),
                Text(
                  '${pet['age'] ?? ''} year(s) old | ${pet['gender'] ?? ''}',
                  style: GoogleFonts.poppins(fontSize: 13, color: Colors.black87),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _appointmentCard(Map<String, dynamic> appt, Color orange) {
    final appointmentDate = DateTime.tryParse(appt['preferred_date'] ?? '');
    final formattedDate = appointmentDate != null
        ? '${appointmentDate.day}/${appointmentDate.month}/${appointmentDate.year}'
        : 'N/A';
    final services = <String>[];
    if (appt['service_bath'] == true) services.add('Bath');
    if (appt['service_haircut'] == true) services.add('Haircut');
    if (appt['service_nail_trim'] == true) services.add('Nail Trim');
    if (appt['service_ear_cleaning'] == true) services.add('Ear Cleaning');
    final servicesText = services.join(', ');
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  appt['pet_name'] ?? 'Pet',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: orange,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(appt['status'] ?? '').withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  appt['status'] ?? 'Pending',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: _getStatusColor(appt['status'] ?? ''),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                formattedDate,
                style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87),
              ),
              const SizedBox(width: 16),
              Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                _formatTime(appt['preferred_time'] ?? 'N/A'),
                style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87),
              ),
            ],
          ),
          if (servicesText.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.pets, size: 16, color: orange),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      servicesText,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.blue;
      case 'cancelled':
      case 'cancelled (by user)':
        return Colors.red;
      case 'approved':
        return Colors.green;
      default:
        return Colors.orange;
    }
  }

  String _formatTime(String time) {
    try {
      final parts = time.split(':');
      if (parts.length >= 2) {
        int hour = int.parse(parts[0]);
        int minute = int.parse(parts[1]);
        String period = hour >= 12 ? 'PM' : 'AM';
        if (hour == 0) hour = 12;
        else if (hour > 12) hour -= 12;
        return '${hour}:${minute.toString().padLeft(2, '0')} $period';
      }
      return time;
    } catch (e) {
      return time;
    }
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error selecting image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _uploadProfileImage(File imageFile) async {
    try {
      setState(() => _isLoading = true);
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;
      if (user == null) return;
      final fileName = 'profile_${user.id}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final response = await supabase.storage.from('profile-images').upload(fileName, imageFile);
      if (response.isNotEmpty) {
        final imageUrl = supabase.storage.from('profile-images').getPublicUrl(fileName);
        await supabase.from('users').update({'profile_image_url': imageUrl}).eq('id', user.id);
        setState(() {
          _profileImageUrl = imageUrl;
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Profile picture updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('Error uploading image: $e');
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error uploading image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showImagePickerDialog() {
    final orange = const Color(0xFFF5A623);
    final lightOrange = const Color(0xFFFFF6E7);
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
                    Icon(Icons.person, size: 48, color: orange),
                    const SizedBox(height: 12),
                    Text(
                      hasProfilePicture ? 'Profile Picture' : 'Select Profile Picture',
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
                                border: Border.all(color: orange.withOpacity(0.3), width: 2),
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
                                          Icon(Icons.person, size: 64, color: orange),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Profile Picture',
                                            style: GoogleFonts.poppins(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: orange,
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
                                  backgroundColor: orange,
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
                                  backgroundColor: orange,
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

  Widget _buildMonthlyChart(Color orange) {
    final monthlyData = _getMonthlyAppointmentsData();
    final maxValue = monthlyData.values.isEmpty ? 1 : monthlyData.values.reduce((a, b) => a > b ? a : b);
    final maxY = maxValue == 0 ? 5 : ((maxValue + 4) ~/ 5) * 5;
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        barGroups: [
          BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: monthlyData[1]?.toDouble() ?? 0, color: orange)]),
          BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: monthlyData[2]?.toDouble() ?? 0, color: orange)]),
          BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: monthlyData[3]?.toDouble() ?? 0, color: orange)]),
          BarChartGroupData(x: 3, barRods: [BarChartRodData(toY: monthlyData[4]?.toDouble() ?? 0, color: orange)]),
          BarChartGroupData(x: 4, barRods: [BarChartRodData(toY: monthlyData[5]?.toDouble() ?? 0, color: orange)]),
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
                  case 0:
                    return Text('Week 1', style: GoogleFonts.poppins(fontSize: 10));
                  case 1:
                    return Text('Week 2', style: GoogleFonts.poppins(fontSize: 10));
                  case 2:
                    return Text('Week 3', style: GoogleFonts.poppins(fontSize: 10));
                  case 3:
                    return Text('Week 4', style: GoogleFonts.poppins(fontSize: 10));
                  case 4:
                    return Text('Week 5', style: GoogleFonts.poppins(fontSize: 10));
                  default:
                    return const SizedBox();
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
        maxY: maxY.toDouble(),
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
    required VoidCallback onTap,
  }) {
    final isLogout = titleColor == Colors.red;
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 1),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: isLogout ? Colors.red : const Color(0xFFF5A623), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.orange.withOpacity(0.06),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        constraints: const BoxConstraints(minHeight: 56, maxWidth: 390),
        child: ListTile(
          leading: Icon(icon, color: iconColor ?? const Color(0xFFF5A623)),
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
          trailing: Icon(Icons.arrow_forward_ios, size: 13, color: Colors.grey[400]),
        ),
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
          color: const Color(0xFFF5A623),
        ),
      ),
    );
  }

  Widget _bottomNavBar(Color orange) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      selectedItemColor: orange,
      unselectedItemColor: Colors.grey[400],
      showSelectedLabels: true,
      showUnselectedLabels: true,
      currentIndex: _selectedIndex,
      onTap: _onItemTapped,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.pets),
          label: 'Grooming',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.message_outlined),
          label: 'Messages',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          label: 'Profile',
        ),
      ],
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
                        '• Personal Info: Full name, email, phone number, etc.\n• Pet Info: Pet name, breed, age, services booked, etc.',
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
            Text(
              'Logout',
              style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 8),
            Text(
              'Are you sure you want to log out of your account?',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: 15, color: Colors.black54),
            ),
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

  void _showFAQsDialog(BuildContext context) {
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
                    Icon(Icons.help_outline, size: 48, color: orange),
                    const SizedBox(height: 12),
                    Text(
                      'Frequently Asked Questions',
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
                    children: _allFAQs
                        .map(
                          (faq) => Column(
                            children: [
                              _buildFAQItem(faq['question'] ?? '', faq['answer'] ?? ''),
                              const SizedBox(height: 16),
                            ],
                          ),
                        )
                        .toList(),
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

  void _showRateAndReviewDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => RateAndReviewDialog(),
    );
  }

  void _showEditProfileDialog() {
    final nameController = TextEditingController(text: _userProfile?['full_name'] ?? '');
    final emailController = TextEditingController(text: _userProfile?['email'] ?? '');
    final contactController = TextEditingController(text: _userProfile?['contact_number'] ?? '');
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
                    Text(
                      'Update Information',
                      style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: _showImagePickerDialog,
                      child: CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.orange.withOpacity(0.15),
                        backgroundImage: _profileImageUrl != null ? NetworkImage(_profileImageUrl!) : null,
                        child: _profileImageUrl == null ? Icon(Icons.person, size: 40, color: Colors.orange) : null,
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
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: () async {
                          final supabase = Supabase.instance.client;
                          final user = supabase.auth.currentUser;
                          if (user == null) return;
                          try {
                            await supabase.from('users').update({
                              'full_name': nameController.text.trim(),
                              'email': emailController.text.trim(),
                              'contact_number': contactController.text.trim(),
                            }).eq('id', user.id);
                            if (mounted) {
                              setState(() {
                                _userProfile = {
                                  ...?_userProfile,
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
        color: Colors.orange.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const SizedBox(width: 8),
          Icon(icon, color: const Color(0xFFF5A623)),
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

class RateAndReviewDialog extends StatefulWidget {
  @override
  _RateAndReviewDialogState createState() => _RateAndReviewDialogState();
}

class _RateAndReviewDialogState extends State<RateAndReviewDialog> {
  int _rating = 0;
  final TextEditingController _reviewController = TextEditingController();
  bool _isSubmitting = false;
  final orange = const Color(0xFFF5A623);
  final lightOrange = const Color(0xFFFFF6E7);

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  void _setRating(int rating) {
    setState(() {
      _rating = rating;
    });
  }

  Future<void> _submitReview() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select a rating', style: GoogleFonts.poppins()),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    setState(() {
      _isSubmitting = true;
    });
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }
      await supabase.from('rate_review').insert({
        'user_id': user.id,
        'rating': _rating,
        'review_text': _reviewController.text.trim(),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Thank you for your review!', style: GoogleFonts.poppins()),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      print('Error submitting review: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error submitting review. Please try again.', style: GoogleFonts.poppins()),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 520),
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
                  Icon(Icons.star, size: 48, color: orange),
                  const SizedBox(height: 12),
                  Text(
                    'Rate and Review',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: orange,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Share your experience with us!',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.black54,
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
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        return GestureDetector(
                          onTap: () => _setRating(index + 1),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Icon(
                              index < _rating ? Icons.star : Icons.star_border,
                              size: 32,
                              color: index < _rating ? orange : Colors.grey[400],
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(Icons.edit, color: Colors.grey[600], size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Write a Review',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: TextField(
                        controller: _reviewController,
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText: 'Share your experience with us...',
                          hintStyle: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.all(16),
                        ),
                        style: GoogleFonts.poppins(fontSize: 14),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _submitReview,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: orange,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: _isSubmitting
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
                                children: [
                                  Icon(Icons.send, color: Colors.white, size: 16),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Submit Review',
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
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
    );
  }
}
