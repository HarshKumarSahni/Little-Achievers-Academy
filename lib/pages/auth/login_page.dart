import 'package:flutter/material.dart';
import 'package:lla_sample/pages/design_course_app_theme.dart';
import 'package:lla_sample/services/auth_service.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isLoading = false;
  final AuthService _authService = AuthService();

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);
    try {
      final user = await _authService.signInWithGoogle();
      if (user != null) {
        // Navigation is handled by AuthWrapper in main.dart
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sign in cancelled or failed')),
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
      body: Stack(
        children: [
          // Background decoration (optional circles or gradient)
          Positioned(
            top: -50,
            left: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: DesignCourseAppTheme.nearlyBlue.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),
          
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo or Icon
                  Hero(
                    tag: 'app_logo',
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 20,
                            offset: Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.school_rounded,
                        size: 64,
                        color: DesignCourseAppTheme.nearlyBlue,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  Text(
                    "Welcome Back!",
                    style: DesignCourseAppTheme.title.copyWith(fontSize: 28),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Sign in to track your progress",
                    style: DesignCourseAppTheme.subtitle.copyWith(fontSize: 16),
                  ),
                  
                  const SizedBox(height: 48),

                  if (_isLoading)
                     const CircularProgressIndicator()
                  else
                    _buildGoogleButton(),
                    
                  const SizedBox(height: 24),
                  
                  TextButton(
                    onPressed: () async {
                      setState(() => _isLoading = true);
                      try {
                        final user = await _authService.signInAnonymously();
                        if (user != null) {
                           // Navigation handled by AuthWrapper
                        } else {
                           ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Guest login failed')),
                          );
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: $e')),
                        );
                      } finally {
                        if (mounted) setState(() => _isLoading = false);
                      }
                    },
                    child: Text(
                      "Continue as Guest",
                      style: TextStyle(
                        color: DesignCourseAppTheme.grey,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoogleButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: _handleGoogleSignIn,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Placeholder for Google Logo - usually an asset
            const Icon(Icons.login, color: Colors.blue), // Replace with Image.asset('assets/google_logo.png')
            const SizedBox(width: 12),
            const Text(
              "Continue with Google",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
