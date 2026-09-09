import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../core/constants/app_colors.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});
  @override State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _bio;
  late final TextEditingController _avatar;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().currentUser;
    _name = TextEditingController(text: user?.fullName ?? '');
    _bio = TextEditingController(text: user?.bio ?? '');
    _avatar = TextEditingController(text: user?.avatarUrl ?? '');
  }
  @override void dispose() { _name.dispose(); _bio.dispose(); _avatar.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('تعديل الملف الشخصي')),
    body: Form(key: _formKey, child: ListView(padding: const EdgeInsets.all(20), children: [
      Center(child: CircleAvatar(radius: 48, backgroundColor: AppColors.primary, backgroundImage: _avatar.text.isNotEmpty ? NetworkImage(_avatar.text) : null, child: _avatar.text.isEmpty ? const Icon(Icons.person, color: Colors.white, size: 44) : null)),
      const SizedBox(height: 24),
      TextFormField(controller: _name, decoration: const InputDecoration(labelText: 'الاسم', prefixIcon: Icon(Icons.person_outline)), validator: (v) => v == null || v.trim().isEmpty ? 'أدخل الاسم' : null),
      const SizedBox(height: 16),
      TextFormField(controller: _bio, maxLines: 3, maxLength: 120, decoration: const InputDecoration(labelText: 'النبذة', prefixIcon: Icon(Icons.notes_outlined))),
      const SizedBox(height: 8),
      TextFormField(controller: _avatar, keyboardType: TextInputType.url, decoration: const InputDecoration(labelText: 'رابط الصورة الشخصية', prefixIcon: Icon(Icons.image_outlined)), onChanged: (_) => setState(() {})),
      const SizedBox(height: 28),
      FilledButton.icon(onPressed: _save, icon: const Icon(Icons.save_outlined), label: const Padding(padding: EdgeInsets.symmetric(vertical: 13), child: Text('حفظ التغييرات'))),
    ])),
  );

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    await context.read<AuthProvider>().updateProfile(fullName: _name.text.trim(), bio: _bio.text.trim(), avatarUrl: _avatar.text.trim());
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم تحديث الملف الشخصي بنجاح')));
    Navigator.pop(context);
  }
}
