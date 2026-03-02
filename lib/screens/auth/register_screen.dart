import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../providers/user_provider.dart';
import '../../widgets/custom_text_field.dart';
import '../../core/constants/app_colors.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      if (_passwordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(tr('passwords_not_match')),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }

      final userProvider = Provider.of<UserProvider>(context, listen: false);
      
      final success = await userProvider.register(
        _emailController.text.trim(),
        _passwordController.text,
        _nameController.text.trim(),
      );

      if (!mounted) return;

      if (success) {
        if (context.mounted) {
          context.go('/home');
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(userProvider.errorMessage ?? tr('registration_failed')),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: Theme.of(context).iconTheme.color,
          ),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header Text
                  Text(
                    tr('create_account'),
                    style: GoogleFonts.inter(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.headlineMedium?.color,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    tr('join_team_planner'),
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // Name Field
                  CustomTextField(
                    label: tr('full_name'),
                    hint: tr('enter_full_name'),
                    controller: _nameController,
                    prefixIcon: Icons.person_outline,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return tr('please_enter_name');
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Email Field
                  CustomTextField(
                    label: tr('email'),
                    hint: tr('enter_email'),
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: Icons.email_outlined,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return tr('please_enter_email');
                      }
                      if (!value.contains('@')) {
                        return tr('please_enter_valid_email');
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Password Field
                  CustomTextField(
                    label: tr('password'),
                    hint: tr('create_password'),
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    prefixIcon: Icons.lock_outlined,
                    suffixIcon: _obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    onSuffixIconTap: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return tr('please_enter_password_register');
                      }
                      if (value.length < 6) {
                        return tr('password_min_length');
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Confirm Password Field
                  CustomTextField(
                    label: tr('confirm_password'),
                    hint: tr('confirm_password_hint'),
                    controller: _confirmPasswordController,
                    obscureText: _obscureConfirmPassword,
                    prefixIcon: Icons.lock_outlined,
                    suffixIcon: _obscureConfirmPassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    onSuffixIconTap: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return tr('please_confirm_password');
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),

                  // Sign Up Button
                  Consumer<UserProvider>(
                    builder: (context, userProvider, _) {
                      return SizedBox(
                        height: 56,
                        child: ElevatedButton(
                          onPressed: userProvider.isLoading ? null : _handleRegister,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: userProvider.isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : Text(
                                  tr('sign_up'),
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),

                  // Login Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        tr('already_have_account'),
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                      ),
                      TextButton(
                        onPressed: () => context.go('/login'),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          tr('sign_in'),
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}