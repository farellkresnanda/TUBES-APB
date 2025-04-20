// profile_screen.dart
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _supabase = Supabase.instance.client;
  String? _profileImageUrl;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _loadProfileImage();
  }

  Future<void> _loadProfileImage() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user != null) {
        final response =
            await _supabase
                .from('users')
                .select('profile_picture')
                .eq('id', user.id)
                .single();

        if (mounted) {
          setState(() {
            _profileImageUrl = response['profile_picture'] as String?;
          });
        }
      }
    } catch (e) {
      debugPrint('Gagal memuat foto profil: $e');
    }
  }

  Future<void> _pickAndUploadImage(BuildContext context) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    final user = _supabase.auth.currentUser;
    if (user == null) return;

    final fileBytes = await pickedFile.readAsBytes();
    final fileName = '${user.id}_${basename(pickedFile.path)}';
    final filePath = 'profilepictures/$fileName';

    final contentType =
        lookupMimeType(pickedFile.path) ?? 'application/octet-stream';

    try {
      setState(() {
        _isUploading = true;
      });

      await _supabase.storage
          .from('profilepictures')
          .uploadBinary(
            filePath,
            fileBytes,
            fileOptions: FileOptions(upsert: true, contentType: contentType),
          );

      final imageUrl = _supabase.storage
          .from('profilepictures')
          .getPublicUrl(filePath);

      await _supabase
          .from('users')
          .update({'profile_picture': imageUrl})
          .eq('id', user.id);

      if (mounted) {
        setState(() {
          _profileImageUrl =
              imageUrl; // opsional: tambah '?v=${DateTime.now().millisecondsSinceEpoch}' untuk cache bust
          _isUploading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Foto profil berhasil diperbarui!')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUploading = false);

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal mengunggah gambar: $e')));
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
            _isUploading
                ? const CircularProgressIndicator()
                : CircleAvatar(
                  radius: 50,
                  backgroundImage:
                      _profileImageUrl != null
                          ? NetworkImage(_profileImageUrl!)
                          : const AssetImage('assets/default_profile.png')
                              as ImageProvider,
                ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed:
                  _isUploading ? null : () => _pickAndUploadImage(context),
              child: const Text('Ubah Foto Profil'),
            ),
          ],
        ),
      ),
    );
  }
}
