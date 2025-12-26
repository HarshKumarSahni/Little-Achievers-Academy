import 'package:flutter/material.dart';
import 'package:lla_sample/pages/design_course_app_theme.dart';
import 'package:lla_sample/services/auth_service.dart';
import 'package:lla_sample/models/userprofile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lla_sample/pages/homepage_UI.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({Key? key}) : super(key: key);

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  // Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _schoolController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _guardianNameController = TextEditingController();
  final TextEditingController _guardianPhoneController = TextEditingController();
  
  String _selectedClass = "Class 8";
  final List<String> _classes = [
    "Class 5", "Class 6", "Class 7", "Class 8", "Class 9", "Class 10"
  ];

  @override
  void initState() {
    super.initState();
    // Pre-fill name/email from Google Auth if available
    final user = _authService.currentUser;
    if (user != null) {
      _nameController.text = user.displayName ?? "";
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _schoolController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _guardianNameController.dispose();
    _guardianPhoneController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final user = _authService.currentUser;
      if (user == null) throw Exception("No authenticated user found");

      // Create Profile Object
      final newProfile = UserProfile(
        id: user.uid,
        name: _nameController.text.trim(),
        email: user.email,
        photoUrl: user.photoURL, // Keep Google photo for now, can add upload later
        classLevel: _selectedClass,
        schoolName: _schoolController.text.trim(),
        address: _addressController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        guardianName: _guardianNameController.text.trim(),
        guardianPhone: _guardianPhoneController.text.trim(),
        stats: UserStats.empty(),
        createdAt: Timestamp.now(),
        isProfileComplete: true, // Mark as complete!
      );

      // Save to Firestore
      await _authService.completeRegistration(newProfile);

      // Navigate to Home
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DesignCourseAppTheme.nearlyWhite,
      appBar: AppBar(
        title: const Text("Complete Profile", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAvatarSection(),
                const SizedBox(height: 32),
                
                _buildSectionTitle("Student Details"),
                _buildTextField("Full Name", _nameController, Icons.person),
                _buildClassDropdown(),
                _buildTextField("School Name", _schoolController, Icons.school),
                _buildTextField("Student Phone", _phoneController, Icons.phone, inputType: TextInputType.phone),
                _buildTextField("Address", _addressController, Icons.home, maxLines: 2),

                const SizedBox(height: 24),
                _buildSectionTitle("Guardian Details"),
                _buildTextField("Guardian Name", _guardianNameController, Icons.person_outline),
                _buildTextField("Guardian Phone", _guardianPhoneController, Icons.phone_android, inputType: TextInputType.phone),

                const SizedBox(height: 40),
                _buildSubmitButton(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarSection() {
    final user = _authService.currentUser;
    return Center(
      child: Stack(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: DesignCourseAppTheme.nearlyBlue.withOpacity(0.1),
            backgroundImage: user?.photoURL != null ? NetworkImage(user!.photoURL!) : null,
            child: user?.photoURL == null 
                ? const Icon(Icons.person, size: 50, color: DesignCourseAppTheme.nearlyBlue) 
                : null,
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: DesignCourseAppTheme.nearlyBlue,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: DesignCourseAppTheme.darkerText,
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon, {TextInputType inputType = TextInputType.text, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        keyboardType: inputType,
        maxLines: maxLines,
        validator: (value) => value == null || value.isEmpty ? 'Required' : null,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: DesignCourseAppTheme.grey),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: DesignCourseAppTheme.grey.withOpacity(0.5)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: DesignCourseAppTheme.grey.withOpacity(0.3)),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }

  Widget _buildClassDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: DropdownButtonFormField<String>(
        value: _selectedClass,
        decoration: InputDecoration(
          labelText: "Class",
          prefixIcon: const Icon(Icons.school_outlined, color: DesignCourseAppTheme.grey),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
        items: _classes.map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        onChanged: (newValue) {
          setState(() {
            _selectedClass = newValue!;
          });
        },
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submitForm,
        style: ElevatedButton.styleFrom(
          backgroundColor: DesignCourseAppTheme.nearlyBlue,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 4,
        ),
        child: _isLoading 
          ? const CircularProgressIndicator(color: Colors.white)
          : const Text(
              "Get Started",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
      ),
    );
  }
}
