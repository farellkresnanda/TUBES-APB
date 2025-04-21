import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

const Color primaryYellow = Color(0xFFFFB800);
const Color secondaryYellow = Color(0xFFFFD976);
const Color lightYellow = Color(0xFFFFE39C);
const Color cream = Color(0xFFFFECBA);
const Color white = Color(0xFFFFFFFF);
const Color darkText = Color(0xFF333333);

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final supabase = Supabase.instance.client;
  final String bucketName = 'profilepictures';
  final _formKey = GlobalKey<FormState>();

  late final String fileName;
  String? imageUrl;
  bool _isLoading = false;
  Map<String, dynamic>? userData;
  bool _isEditing = false;
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  

  @override
  void initState() {
    super.initState();
    final userId = supabase.auth.currentUser?.id ?? 'guest';
    fileName = '$userId.jpg';
    _loadUserData();
    _loadImageUrl();
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId != null) {
        final response = await supabase
            .from('users')
            .select()
            .eq('id', userId)
            .single();
        setState(() {
          userData = response;
          _usernameController.text = response['username'] ?? '';
          _fullNameController.text = response['full_name'] ?? '';
          _emailController.text = response['email'] ?? '';
          _phoneController.text = response['phone'] ?? '';
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error loading user data: $e")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadImageUrl() async {
    try {
      final signedUrl = await supabase.storage
          .from(bucketName)
          .createSignedUrl(fileName, 60 * 60);
      setState(() => imageUrl = signedUrl);
    } catch (_) {
      setState(() => imageUrl = null);
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      final bytes = await picked.readAsBytes();

      Uint8List uploadData = bytes;
      if (!kIsWeb) {
        uploadData = await FlutterImageCompress.compressWithList(
          bytes,
          minWidth: 600,
          minHeight: 600,
          quality: 70,
        );
      }

      await _uploadImage(uploadData);
    }
  }

  Future<void> _uploadImage(Uint8List bytes) async {
    setState(() => _isLoading = true);
    try {
      await supabase.storage.from(bucketName).uploadBinary(
            fileName,
            bytes,
            fileOptions: const FileOptions(upsert: true),
          );
      await _loadImageUrl();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile picture updated successfully")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Upload failed: $e")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteImage() async {
    setState(() => _isLoading = true);
    try {
      await supabase.storage.from(bucketName).remove([fileName]);
      setState(() => imageUrl = null);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile picture removed")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Delete failed: $e")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId != null) {
        await supabase.from('users').update({
          'username': _usernameController.text,
          'full_name': _fullNameController.text,
          'phone': _phoneController.text,
          'updated_at': DateTime.now().toIso8601String(),
        }).eq('id', userId);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile updated successfully")),
        );
        setState(() => _isEditing = false);
        await _loadUserData();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Update failed: $e")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile', style: TextStyle(color: darkText)),
        backgroundColor: primaryYellow,
        iconTheme: const IconThemeData(color: darkText),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => setState(() => _isEditing = true),
              color: darkText,
            ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: primaryYellow))
          : Container(
              color: white,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: primaryYellow,
                              width: 3,
                            ),
                          ),
                          child: CircleAvatar(
                            radius: 70,
                            backgroundColor: cream,
                            backgroundImage:
                                imageUrl != null ? NetworkImage(imageUrl!) : null,
                            child: imageUrl == null
                                ? Icon(Icons.person,
                                    size: 70, color: darkText.withOpacity(0.5))
                                : null,
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: FloatingActionButton.small(
                            onPressed: _pickImage,
                            backgroundColor: primaryYellow,
                            child: const Icon(Icons.camera_alt, size: 20, color: darkText),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    if (imageUrl != null)
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: secondaryYellow,
                          foregroundColor: darkText,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 30, vertical: 12),
                        ),
                        onPressed: _deleteImage,
                        child: const Text("Remove Photo"),
                      ),
                    const SizedBox(height: 30),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          _buildInfoField(
                            label: "Username",
                            controller: _usernameController,
                            icon: Icons.person,
                            isEditable: _isEditing,
                          ),
                          _buildInfoField(
                            label: "Full Name",
                            controller: _fullNameController,
                            icon: Icons.badge,
                            isEditable: _isEditing,
                          ),
                          _buildInfoField(
                            label: "Email",
                            controller: _emailController,
                            icon: Icons.email,
                            isEditable: false,
                          ),
                          _buildInfoField(
                            label: "Phone",
                            controller: _phoneController,
                            icon: Icons.phone,
                            isEditable: _isEditing,
                            keyboardType: TextInputType.phone,
                          ),
                          if (_isEditing) ...[
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ElevatedButton(
                                  onPressed: _updateProfile,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: primaryYellow,
                                    foregroundColor: darkText,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 30, vertical: 12),
                                  ),
                                  child: const Text("Save Changes"),
                                ),
                                const SizedBox(width: 15),
                                TextButton(
                                  onPressed: () {
                                    _formKey.currentState!.reset();
                                    setState(() => _isEditing = false);
                                  },
                                  style: TextButton.styleFrom(
                                    foregroundColor: darkText,
                                  ),
                                  child: const Text("Cancel"),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    Text(
                      "Member since ${userData?['created_at'] != null ? DateTime.parse(userData!['created_at']).toLocal().toString().split(' ')[0] : '--'}",
                      style: TextStyle(
                        color: darkText.withOpacity(0.7),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildInfoField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required bool isEditable,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: darkText),
          prefixIcon: Icon(icon, color: primaryYellow),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: primaryYellow),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: secondaryYellow),
          ),
          filled: !isEditable,
          fillColor: cream,
          contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        ),
        style: TextStyle(color: darkText),
        readOnly: !isEditable,
        keyboardType: keyboardType,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter $label';
          }
          return null;
        },
      ),
    );
  }
}