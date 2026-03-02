import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../providers/user_provider.dart';
import '../../services/firestore_service.dart';
import '../../core/constants/app_avatars.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/app_colors.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _positionController = TextEditingController();
  final FirestoreService _firestoreService = FirestoreService();
  
  String _selectedDepartment = 'General';
  int? _selectedAvatarId;
  bool _isLoading = false;

  final List<String> _departments = [
    'Engineering',
    'Sales',
    'Marketing',
    'HR',
    'Management',
    'General',
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.currentUser;
    if (user != null) {
      _nameController.text = user.name;
      _positionController.text = user.position;
      _selectedDepartment = user.department;
      _selectedAvatarId = user.avatarId;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _positionController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final currentUser = userProvider.currentUser;
      
      if (currentUser == null) {
        throw Exception('User not found');
      }

      final updatedUser = currentUser.copyWith(
        name: _nameController.text.trim(),
        department: _selectedDepartment,
        position: _positionController.text.trim(),
        avatarId: _selectedAvatarId,
      );

      await _firestoreService.updateUser(updatedUser);
      
      // Update the user provider
      await userProvider.refreshUser();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(tr('profile_updated_success')),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${tr('failed_to_update_profile_param')} ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(tr('edit_profile_title')),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Avatar Selector
              Text(
                tr('select_avatar'),
                style: AppTextStyles.h4,
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: AppAvatars.avatars.length,
                  itemBuilder: (context, index) {
                    final avatar = AppAvatars.avatars[index];
                    final isSelected = _selectedAvatarId == avatar.id;
                    
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedAvatarId = avatar.id;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : Colors.transparent,
                            width: 3,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 40,
                          backgroundColor: avatar.backgroundColor,
                          child: Icon(
                            avatar.icon,
                            size: 48,
                            color: avatar.iconColor,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 32),
              
              // Name Field
              CustomTextField(
                label: tr('label_name'),
                hint: tr('enter_your_name'),
                controller: _nameController,
                prefixIcon: Icons.person,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return tr('please_enter_name');
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Department Dropdown
              DropdownButtonFormField<String>(
                value: _selectedDepartment,
                decoration: InputDecoration(
                  labelText: tr('department'),
                  prefixIcon: const Icon(Icons.business),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: _departments.map((dept) {
                  String displayText;
                  switch (dept) {
                    case 'Engineering':
                      displayText = tr('dept_engineering');
                      break;
                    case 'Sales':
                      displayText = tr('dept_sales');
                      break;
                    case 'Marketing':
                      displayText = tr('dept_marketing');
                      break;
                    case 'HR':
                      displayText = tr('dept_hr');
                      break;
                    case 'Management':
                      displayText = tr('dept_management');
                      break;
                    case 'General':
                      displayText = tr('dept_general');
                      break;
                    default:
                      displayText = dept;
                  }
                  return DropdownMenuItem(
                    value: dept,
                    child: Text(displayText),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedDepartment = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              
              // Position Field
              CustomTextField(
                label: tr('position'),
                hint: tr('enter_your_position'),
                controller: _positionController,
                prefixIcon: Icons.work,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return tr('please_enter_position');
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              
              // Save Button
              CustomButton(
                text: tr('save_changes'),
                onPressed: _isLoading ? null : _saveProfile,
                isLoading: _isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

