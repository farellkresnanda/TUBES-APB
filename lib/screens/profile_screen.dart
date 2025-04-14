// profile_screen.dart
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
import 'package:path/path.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _supabase = Supabase.instance.client;
  String? _profileImageUrl;

  @override
  void initState() {
    super.initState();
    _loadProfileImage();
  }

  Future<void> _loadProfileImage() async {
    final user = _supabase.auth.currentUser;
    if (user != null) {
      final response = await _supabase.from('users').select('profile_picture').eq('id', user.id).single();
      if (mounted) {
        setState(() {
          _profileImageUrl = response['profile_picture'] as String?;
        });
      }
    }
  }

  Future<void> _pickAndUploadImage(BuildContext context) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    final user = _supabase.auth.currentUser;
    if (user == null) return;

    final file = File(pickedFile.path);
    final fileName = '${user.id}_${basename(file.path)}';
    final filePath = 'profile_pictures/$fileName';

    try {
      await _supabase.storage.from('profile_pictures').upload(filePath, file);
      final imageUrl = _supabase.storage.from('profile_pictures').getPublicUrl(filePath);

      await _supabase.from('users').update({'profile_picture': imageUrl}).eq('id', user.id);

      if (mounted) {
        setState(() {
          _profileImageUrl = imageUrl;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Foto profil berhasil diperbarui!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengunggah gambar: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: _profileImageUrl != null
                  ? NetworkImage(_profileImageUrl!)
                  : const AssetImage('assets/default_profile.png') as ImageProvider,
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => _pickAndUploadImage(context),
              child: const Text('Ubah Foto Profil'),
            ),
          ],
        ),
      ),
    );
  }
}
