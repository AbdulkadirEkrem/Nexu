import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../providers/user_provider.dart';
import '../../core/constants/app_colors.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      
      final success = await userProvider.login(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (!mounted) return;

      if (success) {
        if (context.mounted) {
          context.go('/home');
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(userProvider.errorMessage ?? tr('login_failed')),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
                  // Logo Section
                  SizedBox(
                    width: 200,
                    height: 200,
                    child: Image.asset(
                      'assets/images/logo_transparent.png',
                      fit: BoxFit.contain, // Ensures it fits inside the box
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Welcome Text
                  Text(
                    tr('welcome'),
                    style: GoogleFonts.inter(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.headlineMedium?.color,
                      height: 1.2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    tr('login_subtitle'),
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),
                  
                  // Email Field
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: GoogleFonts.inter(
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                    decoration: InputDecoration(
                      labelText: tr('email'),
                      hintText: tr('enter_email'),
                      prefixIcon: Icon(Icons.email_outlined, color: Theme.of(context).iconTheme.color),
                      filled: true,
                      fillColor: Theme.of(context).cardColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AppColors.primary,
                          width: 2,
                        ),
                      ),
                      labelStyle: GoogleFonts.inter(
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                      hintStyle: GoogleFonts.inter(
                        color: Theme.of(context).hintColor,
                      ),
                    ),
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
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    style: GoogleFonts.inter(
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                    decoration: InputDecoration(
                      labelText: tr('password'),
                      hintText: tr('enter_password'),
                      prefixIcon: Icon(Icons.lock_outlined, color: Theme.of(context).iconTheme.color),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                          color: Theme.of(context).iconTheme.color,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      filled: true,
                      fillColor: Theme.of(context).cardColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AppColors.primary,
                          width: 2,
                        ),
                      ),
                      labelStyle: GoogleFonts.inter(
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                      hintStyle: GoogleFonts.inter(
                        color: Theme.of(context).hintColor,
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return tr('please_enter_password');
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),
                  
                  // Sign In Button
                  Consumer<UserProvider>(
                    builder: (context, userProvider, _) {
                      return SizedBox(
                        height: 56,
                        child: ElevatedButton(
                          onPressed: userProvider.isLoading ? null : _handleLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.secondary,
                            foregroundColor: Colors.white,
                            elevation: 0,
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
                                  tr('sign_in'),
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  
                  // Sign Up Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        tr('dont_have_account'),
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                      ),
                      TextButton(
                        onPressed: () => context.push('/register'),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          tr('sign_up'),
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
