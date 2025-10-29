import 'package:bus_ticket_app/utils/helper/pick_image.dart';
import 'package:bus_ticket_app/widgets/logout_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bus_ticket_app/core/user/cubit/user_cubit.dart';
import 'package:bus_ticket_app/core/user/cubit/user_state.dart';
import 'package:redacted/redacted.dart';
import 'package:image_picker/image_picker.dart';

class ProfileUserScreen extends StatefulWidget {
  const ProfileUserScreen({super.key});

  @override
  State<ProfileUserScreen> createState() => _ProfileUserScreenState();
}

class _ProfileUserScreenState extends State<ProfileUserScreen> {
  Uint8List? _image;

  @override
  void initState() {
    super.initState();
    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser != null && firebaseUser.email != null) {
      context.read<UserCubit>().loadUser(firebaseUser.email!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<UserCubit, UserState>(
        listener: (context, state) {
          if (state is UserLoaded && _image != null) {
            setState(() {
              _image = null;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Cập nhật ảnh đại diện thành công!'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
              ),
            );
          }
        },
        builder: (context, state) {
          final bool isLoading = state is UserLoading;
          final user = state is UserLoaded ? state.user : null;
          return SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF00424B), Color(0xFF013E46)],
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Column(
                        children: [
                          // Avatar
                          Stack(
                            children: [
                              Hero(
                                tag: 'user-avatar',
                                child: CircleAvatar(
                                  radius: 60,
                                  backgroundColor: Colors.white,
                                  backgroundImage: _getAvatarImage(user),
                                  child:
                                      isLoading
                                          ? Container(
                                            decoration: BoxDecoration(
                                              color: Colors.black.withOpacity(
                                                0.3,
                                              ),
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Center(
                                              child: CircularProgressIndicator(
                                                color: Colors.white,
                                                strokeWidth: 3,
                                              ),
                                            ),
                                          )
                                          : null,
                                ).redacted(
                                  context: context,
                                  redact: isLoading && _image == null,
                                ),
                              ),
                              if (!isLoading)
                                Positioned(
                                  bottom: 2,
                                  right: 2,
                                  child: Container(
                                    height: 40,
                                    width: 40,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: const Color(0xFF1E88E5),
                                        width: 2,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.2),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: IconButton(
                                      padding: EdgeInsets.zero,
                                      icon: const Icon(
                                        Icons.camera_alt,
                                        size: 20,
                                        color: Color(0xFF1E88E5),
                                      ),
                                      onPressed: () {
                                        _showAvatarOptions(context, user);
                                      },
                                    ),
                                  ),
                                ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                child: Text(
                                  user?.fullName ?? 'Người dùng',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ).redacted(context: context, redact: isLoading),
                              ),
                              if (!isLoading)
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  color: Colors.blue.shade300,
                                  iconSize: 24,
                                  onPressed: () {
                                    _showEditDialog(
                                      context,
                                      title: 'Chỉnh sửa tên',
                                      label: 'Họ và tên',
                                      currentValue: user?.fullName ?? '',
                                      fieldName: 'full_name',
                                      icon: Icons.person,
                                    );
                                  },
                                ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          Text(
                            user?.email ?? 'email@example.com',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ).redacted(context: context, redact: isLoading),
                          const SizedBox(height: 12),

                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.white, width: 1),
                            ),
                            child: Text(
                              user?.role ?? 'Chưa xác định',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ).redacted(context: context, redact: isLoading),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Thông tin cá nhân',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 16),

                      _buildInfoCard(
                        icon: Icons.email,
                        title: 'Email',
                        value: user?.email ?? 'Chưa có email',
                        color: Colors.blue,
                        isLoading: isLoading,
                        showEditIcon: false,
                      ).redacted(context: context, redact: isLoading),
                      const SizedBox(height: 12),

                      _buildInfoCard(
                        icon: Icons.phone,
                        title: 'Số điện thoại',
                        value: user?.phone ?? 'Chưa có số điện thoại',
                        color: Colors.green,
                        isLoading: isLoading,
                        showEditIcon: !isLoading,
                        onEdit: () {
                          _showEditDialog(
                            context,
                            title: 'Chỉnh sửa số điện thoại',
                            label: 'Số điện thoại',
                            currentValue: user?.phone ?? '',
                            fieldName: 'phone',
                            icon: Icons.phone,
                            keyboardType: TextInputType.phone,
                          );
                        },
                      ).redacted(context: context, redact: isLoading),
                      const SizedBox(height: 12),

                      _buildInfoCard(
                        icon: Icons.calendar_today,
                        title: 'Ngày tham gia',
                        value:
                            user?.createdAt != null
                                ? '${user!.createdAt!.day}/${user.createdAt!.month}/${user.createdAt!.year}'
                                : 'DD/MM/YYYY',
                        color: Colors.orange,
                        isLoading: isLoading,
                      ).redacted(context: context, redact: isLoading),
                      const SizedBox(height: 30),

                      const LogoutButton(),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    required bool isLoading,
    bool showEditIcon = false,
    VoidCallback? onEdit,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (showEditIcon)
            IconButton(
              icon: Icon(Icons.edit, color: color, size: 20),
              onPressed: onEdit,
            ),
        ],
      ),
    );
  }

  void _showEditDialog(
    BuildContext context, {
    required String title,
    required String label,
    required String currentValue,
    required String fieldName,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    final TextEditingController controller = TextEditingController(
      text: currentValue,
    );

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(title),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              labelText: label,
              border: const OutlineInputBorder(),
              prefixIcon: Icon(icon),
            ),
            keyboardType: keyboardType,
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Hủy', style: TextStyle(color: Colors.red)),
            ),
            ElevatedButton(
              onPressed: () {
                if (controller.text.trim().isNotEmpty) {
                  context.read<UserCubit>().updateUserProfile({
                    fieldName: controller.text.trim(),
                  });
                  Navigator.pop(dialogContext);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Cập nhật thông tin thành công!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Giá trị không được để trống!'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: const Text('Lưu'),
            ),
          ],
        );
      },
    );
  }

  void _showAvatarOptions(BuildContext context, dynamic user) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Chọn ảnh đại diện',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.photo_library, color: Colors.blue),
                  ),
                  title: const Text('Chọn từ thư viện'),
                  onTap: () {
                    Navigator.pop(context);
                    _selectImage(ImageSource.gallery);
                  },
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.camera_alt, color: Colors.green),
                  ),
                  title: const Text('Chụp ảnh'),
                  onTap: () {
                    Navigator.pop(context);
                    _selectImage(ImageSource.camera);
                  },
                ),
              ],
            ),
          ),
    );
  }

  Future<void> _selectImage(ImageSource source) async {
    try {
      final Uint8List img = await pickImage(source);
      setState(() {
        _image = img;
      });
      if (mounted) {
        context.read<UserCubit>().uploadAvatar(img);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Chưa chọn ảnh'), backgroundColor: Colors.red),
        );
      }
    }
  }

  ImageProvider _getAvatarImage(dynamic user) {
    if (_image != null) {
      return MemoryImage(_image!);
    } else if (user?.avatarUrl != null && user!.avatarUrl!.isNotEmpty) {
      return NetworkImage(user.avatarUrl!);
    } else {
      return const AssetImage('assets/images/user.png');
    }
  }
}
