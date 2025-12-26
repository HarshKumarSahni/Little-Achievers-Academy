import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lla_sample/pages/design_course_app_theme.dart';
import 'package:lla_sample/services/auth_service.dart';
import 'package:lla_sample/models/userprofile.dart';

class EditProfilePage extends StatefulWidget {
  final UserProfile currentProfile;
  
  const EditProfilePage({Key? key, required this.currentProfile}) : super(key: key);

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  File? _selectedImage;
  String? _currentPhotoUrl;

  // Controllers
  late TextEditingController _nameController;
  late TextEditingController _schoolController;
  late TextEditingController _addressController;
  late TextEditingController _phoneController;
  late TextEditingController _guardianNameController;
  late TextEditingController _guardianPhoneController;
  
  String _selectedClass = "Class 8";
  final List<String> _classes = [
    "Class 5", "Class 6", "Class 7", "Class 8", "Class 9", "Class 10"
  ];

  @override
  void initState() {
    super.initState();
    // Pre-fill with current profile data
    _nameController = TextEditingController(text: widget.currentProfile.name ?? "");
    _schoolController = TextEditingController(text: widget.currentProfile.schoolName ?? "");
    _addressController = TextEditingController(text: widget.currentProfile.address ?? "");
    _phoneController = TextEditingController(text: widget.currentProfile.phoneNumber ?? "");
    _guardianNameController = TextEditingController(text: widget.currentProfile.guardianName ?? "");
    _guardianPhoneController = TextEditingController(text: widget.currentProfile.guardianPhone ?? "");
    _selectedClass = widget.currentProfile.classLevel.isNotEmpty ? widget.currentProfile.classLevel : "Class 8";
    _currentPhotoUrl = widget.currentProfile.photoUrl;
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

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    
    // Show bottom sheet to choose camera or gallery
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take Photo'),
              onTap: () async {
                Navigator.pop(context);
                final XFile? image = await picker.pickImage(source: ImageSource.camera);
                if (image != null) {
                  setState(() => _selectedImage = File(image.path));
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () async {
                Navigator.pop(context);
                final XFile? image = await picker.pickImage(source: ImageSource.gallery);
                if (image != null) {
                  setState(() => _selectedImage = File(image.path));
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<String?> _uploadImage(File imageFile) async {
    try {
      final user = _authService.currentUser;
      if (user == null) return null;

      final ref = FirebaseStorage.instance
          .ref()
          .child('profile_pictures')
          .child('${user.uid}.jpg');
      
      await ref.putFile(imageFile);
      return await ref.getDownloadURL();
    } catch (e) {
      print("Upload error: $e");
      return null;
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      String? photoUrl = _currentPhotoUrl;
      
      // Upload new image if selected
      if (_selectedImage != null) {
        photoUrl = await _uploadImage(_selectedImage!);
      }

      // Update profile in Firestore
      final user = _authService.currentUser;
      if (user == null) throw Exception("Not authenticated");

      await FirebaseFirestore.instance.collection('students').doc(user.uid).update({
        'name': _nameController.text.trim(),
        'schoolName': _schoolController.text.trim(),
        'address': _addressController.text.trim(),
        'phoneNumber': _phoneController.text.trim(),
        'guardianName': _guardianNameController.text.trim(),
        'guardianPhone': _guardianPhoneController.text.trim(),
        'classLevel': _selectedClass,
        if (photoUrl != null) 'photoUrl': photoUrl,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
        Navigator.pop(context);
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
        title: const Text("Edit Profile", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
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
                _buildTextField("Phone", _phoneController, Icons.phone, inputType: TextInputType.phone),
                _buildTextField("Address", _addressController, Icons.home, maxLines: 2),

                const SizedBox(height: 24),
                _buildSectionTitle("Guardian Details"),
                _buildTextField("Guardian Name", _guardianNameController, Icons.person_outline),
                _buildTextField("Guardian Phone", _guardianPhoneController, Icons.phone_android, inputType: TextInputType.phone),

                const SizedBox(height: 40),
                _buildSaveButton(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarSection() {
    return Center(
      child: GestureDetector(
        onTap: _pickImage,
        child: Stack(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: DesignCourseAppTheme.nearlyBlue.withOpacity(0.1),
              backgroundImage: _selectedImage != null 
                  ? FileImage(_selectedImage!) 
                  : (_currentPhotoUrl != null ? NetworkImage(_currentPhotoUrl!) as ImageProvider : null),
              child: (_selectedImage == null && _currentPhotoUrl == null)
                  ? const Icon(Icons.person, size: 50, color: DesignCourseAppTheme.nearlyBlue) 
                  : null,
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: DesignCourseAppTheme.nearlyBlue,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
              ),
            ),
          ],
        ),
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
        value: _classes.contains(_selectedClass) ? _selectedClass : _classes.first,
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

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _saveProfile,
        style: ElevatedButton.styleFrom(
          backgroundColor: DesignCourseAppTheme.nearlyBlue,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 4,
        ),
        child: _isLoading 
          ? const CircularProgressIndicator(color: Colors.white)
          : const Text(
              "Save Changes",
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
