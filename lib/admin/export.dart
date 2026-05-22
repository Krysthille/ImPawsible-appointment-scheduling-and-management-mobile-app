import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:open_file/open_file.dart';
import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';


class ExportPage extends StatefulWidget {
  const ExportPage({Key? key}) : super(key: key);

  @override
  State<ExportPage> createState() => _ExportPageState();
}

class _ExportPageState extends State<ExportPage> {
  List<Map<String, dynamic>> _appointments = [];
  List<Map<String, dynamic>> _filteredAppointments = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _sortType = 'name_asc';
  final TextEditingController _searchController = TextEditingController();
  final orange = const Color(0xFFF5A623);
  final lightOrange = const Color(0xFFFFF6E7);

  // Add service price map from grooming_appointment.dart
  final Map<String, Map<String, int>> _servicePrices = {
    'Small': {
      'bath': 300,
      'haircut': 400,
      'nailTrim': 100,
      'earCleaning': 100,
    },
    'Medium': {
      'bath': 400,
      'haircut': 500,
      'nailTrim': 110,
      'earCleaning': 110,
    },
    'Large': {
      'bath': 500,
      'haircut': 600,
      'nailTrim': 120,
      'earCleaning': 120,
    },
  };

  // Helper to calculate total cost for an appointment
  num _calculateAppointmentCost(Map<String, dynamic> appointment) {
    final size = appointment['pet_size'] ?? 'Small';
    final prices = _servicePrices[size] ?? _servicePrices['Small']!;
    num total = 0;
    if (appointment['service_bath'] == true) total += prices['bath']!;
    if (appointment['service_haircut'] == true) total += prices['haircut']!;
    if (appointment['service_nail_trim'] == true) total += prices['nailTrim']!;
    if (appointment['service_ear_cleaning'] == true) total += prices['earCleaning']!;
    return total;
  }

  @override
  void initState() {
    super.initState();
    _loadAppointments();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadAppointments() async {
    try {
      setState(() => _isLoading = true);
      
      final supabase = Supabase.instance.client;
      
      // Fetch appointments
      final appointmentsResponse = await supabase
          .from('grooming_appointments')
          .select('*')
          .order('preferred_date', ascending: false);

      // Fetch user data for all appointments
      final appointments = List<Map<String, dynamic>>.from(appointmentsResponse);
      final userIds = appointments.map((appointment) => appointment['user_id']).toSet().toList();
      
      final usersResponse = await supabase
          .from('users')
          .select('id, full_name, email, contact_number')
          .inFilter('id', userIds);

      // Create a map of user data
      final usersMap = <String, Map<String, dynamic>>{};
      for (final user in usersResponse) {
        usersMap[user['id']] = user;
      }

      // Combine appointment and user data
      final combinedAppointments = appointments.map((appointment) {
        final userData = usersMap[appointment['user_id']] ?? {};
        return {
          ...appointment,
          'users': userData,
        };
      }).toList();

      if (mounted) {
        setState(() {
          _appointments = combinedAppointments;
          _filteredAppointments = List.from(_appointments);
          _isLoading = false;
        });
        _applySearchAndSort();
      }
    } catch (e) {
      print('Error loading appointments: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _applySearchAndSort() {
    List<Map<String, dynamic>> filtered = _appointments;

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((appointment) {
        final userName = appointment['users']?['full_name']?.toString().toLowerCase() ?? '';
        final petName = appointment['pet_name']?.toString().toLowerCase() ?? '';
        final email = appointment['users']?['email']?.toString().toLowerCase() ?? '';
        final contact = appointment['users']?['contact_number']?.toString().toLowerCase() ?? '';
        final status = appointment['status']?.toString().toLowerCase() ?? '';
        
        final query = _searchQuery.toLowerCase();
        return userName.contains(query) ||
               petName.contains(query) ||
               email.contains(query) ||
               contact.contains(query) ||
               status.contains(query);
      }).toList();
    }

         // Apply sorting
     filtered.sort((a, b) {
       final petNameA = a['pet_name']?.toString().toLowerCase() ?? '';
       final petNameB = b['pet_name']?.toString().toLowerCase() ?? '';
       
       switch (_sortType) {
         case 'name_asc':
           return petNameA.compareTo(petNameB);
         case 'name_desc':
           return petNameB.compareTo(petNameA);
         default:
           return 0;
       }
     });

    setState(() {
      _filteredAppointments = filtered;
    });
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'N/A';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'N/A';
    }
  }

  String _formatTime(String? timeString) {
    if (timeString == null) return 'N/A';
    try {
      final parts = timeString.split(':');
      if (parts.length >= 2) {
        final hour = int.parse(parts[0]);
        final minute = int.parse(parts[1]);
        
        final period = hour >= 12 ? 'PM' : 'AM';
        final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
        final displayMinute = minute.toString().padLeft(2, '0');
        
        return '$displayHour:$displayMinute $period';
      }
      return timeString;
    } catch (e) {
             return timeString;
    }
  }

  pw.Widget _buildPdfInfoRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 8),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 120,
            child: pw.Text(
              '$label:',
              style: pw.TextStyle(
                fontSize: 10,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              value,
              style: pw.TextStyle(
                fontSize: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Fix the service row symbols to use simple characters
  pw.Widget _buildPdfServiceRow(String service, bool isSelected) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 4),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            isSelected ? '* ' : 'o ',
            style: pw.TextStyle(
              fontSize: 10,
              color: isSelected ? PdfColors.black : PdfColors.grey600,
              fontWeight: isSelected ? pw.FontWeight.bold : pw.FontWeight.normal,
            ),
          ),
          pw.SizedBox(width: 4),
          pw.Expanded(
            child: pw.Text(
              service,
              style: pw.TextStyle(
                fontSize: 10,
                color: isSelected ? PdfColors.black : PdfColors.grey600,
                fontWeight: isSelected ? pw.FontWeight.bold : pw.FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Update the PDF export function to handle platform compatibility
  Future<void> _exportToPDF(Map<String, dynamic> appointment) async {
    try {
      // Show loading indicator
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              const SizedBox(width: 16),
              Text('Generating PDF...'),
            ],
          ),
          backgroundColor: orange,
          duration: const Duration(seconds: 2),
        ),
      );

      // Load logo image
      final logoBytes = await rootBundle.load('assets/images/logo.png');
      final logoImage = pw.MemoryImage(logoBytes.buffer.asUint8List());

      // Create PDF document
      final pdf = pw.Document();

      // Add page to PDF
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Container(
              padding: const pw.EdgeInsets.all(40),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Header
                  pw.Row(
                    children: [
                      // Logo
                      pw.Container(
                        width: 40,
                        height: 40,
                        decoration: pw.BoxDecoration(
                          color: PdfColors.orange,
                          shape: pw.BoxShape.circle,
                        ),
                        child: pw.Center(
                          child: pw.Image(logoImage, width: 32, height: 32),
                        ),
                      ),
                      pw.SizedBox(width: 12),
                      pw.Expanded(
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              'IMPAWSIBLE',
                              style: pw.TextStyle(
                                fontSize: 18,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColors.orange,
                              ),
                            ),
                            pw.Text(
                              'Pet Grooming Appointment',
                              style: pw.TextStyle(
                                fontSize: 14,
                                color: PdfColors.grey600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      pw.Text(
                        'ID: ${appointment['id']?.toString().length != null && appointment['id'].toString().length >= 8 ? appointment['id'].toString().substring(0, 8) : appointment['id']?.toString() ?? 'N/A'}',
                        style: pw.TextStyle(
                          fontSize: 10,
                          color: PdfColors.grey600,
                        ),
                      ),
                    ],
                  ),
                  pw.Divider(height: 32),
                  
                  // Client Information
                  pw.Text(
                    'CLIENT INFORMATION',
                    style: pw.TextStyle(
                      fontSize: 12,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 12),
                  _buildPdfInfoRow('Name', appointment['users']?['full_name'] ?? 'N/A'),
                  _buildPdfInfoRow('Email', appointment['users']?['email'] ?? 'N/A'),
                  _buildPdfInfoRow('Contact', appointment['users']?['contact_number'] ?? 'N/A'),
                  
                  pw.SizedBox(height: 20),
                  
                  // Pet Information
                  pw.Text(
                    'PET INFORMATION',
                    style: pw.TextStyle(
                      fontSize: 12,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 12),
                  _buildPdfInfoRow('Pet Name', appointment['pet_name'] ?? 'N/A'),
                  _buildPdfInfoRow('Pet Type', appointment['pet_type'] ?? 'N/A'),
                  _buildPdfInfoRow('Breed', appointment['breed'] ?? 'N/A'),
                  _buildPdfInfoRow('Size', appointment['pet_size'] ?? 'N/A'),
                  _buildPdfInfoRow('Age', '${appointment['age'] ?? 'N/A'} year(s)'),
                  _buildPdfInfoRow('Gender', appointment['gender'] ?? 'N/A'),
                  
                  pw.SizedBox(height: 20),
                  
                  // Appointment Details
                  pw.Text(
                    'APPOINTMENT DETAILS',
                    style: pw.TextStyle(
                      fontSize: 12,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 12),
                  _buildPdfInfoRow('Date', _formatDate(appointment['preferred_date'])),
                  _buildPdfInfoRow('Time', _formatTime(appointment['preferred_time'])),
                  _buildPdfInfoRow('Status', appointment['status'] ?? 'Pending'),
                  _buildPdfInfoRow('Total Cost', 'P${_calculateAppointmentCost(appointment)}'),
                  
                  pw.SizedBox(height: 20),
                  
                  // Services
                  pw.Text(
                    'SERVICES REQUESTED',
                    style: pw.TextStyle(
                      fontSize: 12,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 12),
                  _buildPdfServiceRow('Bath', appointment['service_bath'] ?? false),
                  _buildPdfServiceRow('Haircut', appointment['service_haircut'] ?? false),
                  _buildPdfServiceRow('Nail Trim', appointment['service_nail_trim'] ?? false),
                  _buildPdfServiceRow('Ear Cleaning', appointment['service_ear_cleaning'] ?? false),
                  
                  if (appointment['concerns']?.isNotEmpty == true) ...[
                    pw.SizedBox(height: 20),
                    pw.Text(
                      'SPECIAL CONCERNS',
                      style: pw.TextStyle(
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 12),
                    pw.Container(
                      width: double.infinity,
                      padding: const pw.EdgeInsets.all(12),
                      decoration: pw.BoxDecoration(
                        color: PdfColors.grey50,
                        border: pw.Border.all(color: PdfColors.grey300),
                      ),
                      child: pw.Text(
                        appointment['concerns'] ?? 'None',
                        style: pw.TextStyle(
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                  
                  pw.SizedBox(height: 20),
                  
                  // Footer
                  pw.Divider(height: 32),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        'Generated on: ${_formatDate(DateTime.now().toIso8601String())}',
                        style: pw.TextStyle(
                          fontSize: 12,
                          color: PdfColors.grey600,
                        ),
                      ),
                      pw.Text(
                        'Page 1',
                        style: pw.TextStyle(
                          fontSize: 12,
                          color: PdfColors.grey600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      );

      // Generate filename using pet name and user name
      final petName = appointment['pet_name']?.toString().replaceAll(RegExp(r'[^\w\s-]'), '').trim() ?? 'Unknown';
      final userName = appointment['users']?['full_name']?.toString().replaceAll(RegExp(r'[^\w\s-]'), '').trim() ?? 'Unknown';
      final fileName = '$petName-$userName.pdf';

          // Save to documents directory with proper filename
    final directory = await getApplicationDocumentsDirectory();
    final outputFile = '${directory.path}/$fileName';
    
    // Save the PDF
    final file = File(outputFile);
    await file.writeAsBytes(await pdf.save());
      
      // Close the modal
      if (mounted) {
        Navigator.pop(context);
      }
      
      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('PDF saved successfully!'),
            backgroundColor: Colors.green,
            action: SnackBarAction(
              label: 'Open',
              textColor: Colors.white,
              onPressed: () async {
                await OpenFile.open(file.path);
              },
            ),
          ),
        );
      }
    } catch (e) {
      print('Error generating PDF: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error generating PDF: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showAppointmentDetails(Map<String, dynamic> appointment) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
            maxWidth: MediaQuery.of(context).size.width * 0.9,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
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
                      'Appointment Details',
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
              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // A4-style layout
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                                                         // Header
                             Row(
                               children: [
                                 // Logo
                                 Container(
                                   width: 40,
                                   height: 40,
                                   decoration: BoxDecoration(
                                     color: orange,
                                     shape: BoxShape.circle,
                                   ),
                                   child: Center(
                                     child: Image.asset(
                                       'assets/images/logo.png',
                                       width: 32,
                                       height: 32,
                                       fit: BoxFit.contain,
                                     ),
                                   ),
                                 ),
                                 const SizedBox(width: 12),
                                 Expanded(
                                   child: Text(
                                     'IMPAWSIBLE',
                                     style: GoogleFonts.poppins(
                                       fontSize: 16,
                                       fontWeight: FontWeight.bold,
                                       color: orange,
                                     ),
                                   ),
                                 ),
                                 Text(
                                   'ID: ${appointment['id']?.toString().length != null && appointment['id'].toString().length >= 8 ? appointment['id'].toString().substring(0, 8) : appointment['id']?.toString() ?? 'N/A'}',
                                   style: GoogleFonts.poppins(
                                     fontSize: 10,
                                     color: Colors.grey[600],
                                   ),
                                 ),
                               ],
                             ),
                            const Divider(height: 32),
                            
                            // Client Information
                            Text(
                              'CLIENT INFORMATION',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: orange,
                              ),
                            ),
                            const SizedBox(height: 12),
                            _buildInfoRow('Name', appointment['users']?['full_name'] ?? 'N/A'),
                            _buildInfoRow('Email', appointment['users']?['email'] ?? 'N/A'),
                            _buildInfoRow('Contact', appointment['users']?['contact_number'] ?? 'N/A'),
                            
                            const SizedBox(height: 20),
                            
                            // Pet Information
                            Text(
                              'PET INFORMATION',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: orange,
                              ),
                            ),
                            const SizedBox(height: 12),
                            _buildInfoRow('Pet Name', appointment['pet_name'] ?? 'N/A'),
                            _buildInfoRow('Pet Type', appointment['pet_type'] ?? 'N/A'),
                            _buildInfoRow('Breed', appointment['breed'] ?? 'N/A'),
                            _buildInfoRow('Size', appointment['pet_size'] ?? 'N/A'),
                            _buildInfoRow('Age', '${appointment['age'] ?? 'N/A'} year(s)'),
                            _buildInfoRow('Gender', appointment['gender'] ?? 'N/A'),
                            
                            const SizedBox(height: 20),
                            
                            // Appointment Details
                            Text(
                              'APPOINTMENT DETAILS',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: orange,
                              ),
                            ),
                            const SizedBox(height: 12),
                                                         _buildInfoRow('Date', _formatDate(appointment['preferred_date'])),
                             _buildInfoRow('Time', _formatTime(appointment['preferred_time'])),
                             _buildInfoRow('Status', appointment['status'] ?? 'Pending'),
                             _buildInfoRow('Total Cost', 'P${_calculateAppointmentCost(appointment)}'),
                            
                            const SizedBox(height: 20),
                            
                            // Services
                            Text(
                              'SERVICES REQUESTED',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: orange,
                              ),
                            ),
                            const SizedBox(height: 12),
                            _buildServiceRow('Bath', appointment['service_bath'] ?? false),
                            _buildServiceRow('Haircut', appointment['service_haircut'] ?? false),
                            _buildServiceRow('Nail Trim', appointment['service_nail_trim'] ?? false),
                            _buildServiceRow('Ear Cleaning', appointment['service_ear_cleaning'] ?? false),
                            
                            if (appointment['concerns']?.isNotEmpty == true) ...[
                              const SizedBox(height: 20),
                              Text(
                                'SPECIAL CONCERNS',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: orange,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.grey[50],
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.grey.shade300),
                                ),
                                child: Text(
                                  appointment['concerns'] ?? 'None',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            ],
                            
                            const SizedBox(height: 20),
                            
                            // Footer
                            const Divider(height: 32),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Generated on: ${_formatDate(DateTime.now().toIso8601String())}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                Text(
                                  'Page 1 of 1',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Save Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => _exportToPDF(appointment),
                          icon: Icon(Icons.save, color: Colors.white),
                          label: Text(
                            'Save as PDF',
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
                      const SizedBox(height: 16),
                      Center(
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

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceRow(String service, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(
            isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 16,
            color: isSelected ? Colors.green : Colors.grey,
          ),
          const SizedBox(width: 8),
          Text(
            service,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: isSelected ? Colors.black87 : Colors.grey[600],
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Export Data',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        backgroundColor: lightOrange,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: orange),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFF6E7), Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Color(0xFFF5A623)))
            : SafeArea(
                child: Column(
                  children: [
                    // Search and Sort Section
                    Container(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          // Search Bar
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
                                      hintText: 'Search pets and owners... ',
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
                                // Sort Button
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
                                       child: Text('Pet Name (A–Z)', style: GoogleFonts.poppins(fontSize: 13)),
                                     ),
                                     PopupMenuItem(
                                       value: 'name_desc',
                                       child: Text('Pet Name (Z–A)', style: GoogleFonts.poppins(fontSize: 13)),
                                     ),
                                   ],
                                                                     child: Container(
                                     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                     decoration: BoxDecoration(
                                       color: orange.withOpacity(0.1),
                                       borderRadius: BorderRadius.circular(12),
                                       border: Border.all(
                                        //  color: orange.withOpacity(0.3),
                                         width: 1,
                                       ),
                                     ),
                                     child: Row(
                                       mainAxisSize: MainAxisSize.min,
                                       children: [
                                         Icon(Icons.sort, color: Colors.black, size: 20),
                                         const SizedBox(width: 6),
                                         Text(
                                           'Sort',
                                           style: GoogleFonts.poppins(
                                             fontSize: 14,
                                             fontWeight: FontWeight.w600,
                                             color:   Colors.black,
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
                    
                    // Results Count
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Text(
                            '${_filteredAppointments.length} appointment${_filteredAppointments.length == 1 ? '' : 's'} found',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Appointments List
                    // Expanded(
                    //   child: _filteredAppointments.isEmpty
                    //       ? Center(
                    //           child: Column(
                    //             mainAxisAlignment: MainAxisAlignment.center,
                    //             children: [
                    //               Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                    //               const SizedBox(height: 16),
                    //               Text(
                    //                 'No appointments found',
                    //                 style: GoogleFonts.poppins(
                    //                   fontSize: 18,
                    //                   fontWeight: FontWeight.w600,
                    //                   color: Colors.grey[600],
                    //                 ),
                    //               ),
                    //               const SizedBox(height: 8),
                    //               Text(
                    //                 'Try adjusting your search criteria',
                    //                 style: GoogleFonts.poppins(
                    //                   fontSize: 14,
                    //                   color: Colors.grey[500],
                    //                 ),
                    //               ),
                    //             ],
                    //           ),
                    //         )
                    //       : ListView.builder(
                    //           padding: const EdgeInsets.symmetric(horizontal: 16),
                    //           itemCount: _filteredAppointments.length,
                    //           itemBuilder: (context, index) {
                    //             final appointment = _filteredAppointments[index];
                    //             return _buildAppointmentTile(appointment);
                    //           },
                    //         ),
                    // ),

          Expanded(
          child: RefreshIndicator(
          onRefresh: _loadAppointments, // 👈 this reloads data
          color: orange,
          child: _filteredAppointments.isEmpty
        ? ListView( // 👈 wrapped in ListView so pull works even when empty
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.6,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        'No appointments found',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Try adjusting your search criteria',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          )
        : ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(), // 👈 ensures pull works even with few items
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _filteredAppointments.length,
            itemBuilder: (context, index) {
              final appointment = _filteredAppointments[index];
              return _buildAppointmentTile(appointment);
            },
          ),
  ),
),

                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildAppointmentTile(Map<String, dynamic> appointment) {
         return Container(
       margin: const EdgeInsets.only(bottom: 12),
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
             child: ListTile(
         onTap: () => _showAppointmentDetails(appointment),
         leading: Container(
           width: 50,
           height: 50,
           decoration: BoxDecoration(
             color: orange.withOpacity(0.1),
             borderRadius: BorderRadius.circular(12),
             border: Border.all(
               color: orange.withOpacity(0.3),
               width: 1,
             ),
           ),
           child: Icon(
             Icons.pets,
             color: orange,
             size: 24,
           ),
         ),
                 title: Text(
           '${appointment['pet_name'] ?? 'Unknown Pet'}  |  ${appointment['pet_type'] ?? 'Unknown Type'}',
           style: GoogleFonts.poppins(
             fontSize: 16,
             fontWeight: FontWeight.bold,
             color: Colors.black87,
           ),
           overflow: TextOverflow.ellipsis,
         ),
         subtitle: Padding(
           padding: const EdgeInsets.only(top: 4),
           child: Text(
             appointment['users']?['full_name'] ?? 'Unknown User',
             style: GoogleFonts.poppins(
               fontSize: 14,
               color: Colors.black54,
             ),
             overflow: TextOverflow.ellipsis,
           ),
         ),
        trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
      ),
    );
  }
} 