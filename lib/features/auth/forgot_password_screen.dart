import 'package:flutter/material.dart';

// Forgot Password Screen
// This screen asks the user for their email address.
// Later, Firebase will send a password reset link to that email.
// For now it is UI only — no Firebase logic yet.

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  // _formKey validates the form when user taps the button
  final _formKey = GlobalKey<FormState>();

  // Controller reads what the user types in the email field
  final TextEditingController _emailController = TextEditingController();

  // This boolean controls which "page" to show:
  // false = show the email input form
  // true  = show the success message after submitting
  bool _emailSent = false;

  // Always dispose controllers to free memory
  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  // This runs when user taps "Send Reset Link" button
  void _handleResetPassword() {
    if (_formKey.currentState!.validate()) {
      // TODO: Add Firebase reset password logic here later
      // For now we just switch to the success view
      setState(() {
        _emailSent = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      // AppBar with back button to return to Login screen
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F7FA),
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xFF1E293B),
            size: 20,
          ),
        ),
      ),
      // Show different content based on whether email was sent or not
      body: SafeArea(
        child: _emailSent ? _buildSuccessView() : _buildFormView(),
      ),
    );
  }

  // ── VIEW 1: Email Input Form ────────────────────────────────────────
  // This is shown FIRST — user enters their email here
  Widget _buildFormView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 20.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            // ── Icon ──────────────────────────────────────────────
            Center(
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: const Color(0xFFBFDBFE),
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.lock_reset_rounded,
                  color: Color(0xFF2563EB),
                  size: 46,
                ),
              ),
            ),

            const SizedBox(height: 32),

            // ── Title ─────────────────────────────────────────────
            const Text(
              'Forgot Password?',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1E293B),
                letterSpacing: -0.5,
              ),
            ),

            const SizedBox(height: 10),

            // ── Description ───────────────────────────────────────
            const Text(
              'No worries! Enter your registered email address and we will send you a link to reset your password.',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF64748B),
                height: 1.6, // line spacing
              ),
            ),

            const SizedBox(height: 36),

            // ── Email Label ───────────────────────────────────────
            const Text(
              'Email Address',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF374151),
              ),
            ),

            const SizedBox(height: 8),

            // ── Email Input Field ─────────────────────────────────
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email address';
                }
                if (!value.contains('@') || !value.contains('.')) {
                  return 'Please enter a valid email address';
                }
                return null; // null means no error
              },
              decoration: InputDecoration(
                hintText: 'you@example.com',
                hintStyle: const TextStyle(
                  color: Color(0xFFCBD5E1),
                  fontSize: 14,
                ),
                prefixIcon: const Icon(
                  Icons.email_outlined,
                  color: Color(0xFF94A3B8),
                  size: 20,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFF2563EB),
                    width: 2,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFEF4444)),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFFEF4444),
                    width: 2,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // ── Send Reset Link Button ────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _handleResetPassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Send Reset Link',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 28),

            // ── Back to Login ─────────────────────────────────────
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.arrow_back_rounded,
                    size: 14,
                    color: Color(0xFF64748B),
                  ),
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Text(
                      'Back to Login',
                      style: TextStyle(
                        color: Color(0xFF2563EB),
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── VIEW 2: Success Message ─────────────────────────────────────────
  // This is shown AFTER user submits their email
  // It replaces the form with a confirmation message
  Widget _buildSuccessView() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // ── Success Icon ────────────────────────────────────────
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: const Color(0xFFECFDF5),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: const Color(0xFF6EE7B7),
                width: 2,
              ),
            ),
            child: const Icon(
              Icons.mark_email_read_rounded,
              color: Color(0xFF10B981),
              size: 52,
            ),
          ),

          const SizedBox(height: 32),

          // ── Success Title ───────────────────────────────────────
          const Text(
            'Check Your Email! 📬',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1E293B),
              letterSpacing: -0.5,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 14),

          // ── Success Description ─────────────────────────────────
          // Shows the email the user entered using the controller
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF64748B),
                height: 1.6,
              ),
              children: [
                const TextSpan(text: 'We have sent a password reset link to\n'),
                // Shows the actual email typed by the user
                TextSpan(
                  text: _emailController.text,
                  style: const TextStyle(
                    color: Color(0xFF2563EB),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const TextSpan(
                  text: '\n\nPlease check your inbox and follow the instructions.',
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ── Tip Box ─────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFBEB),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFDE68A)),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline_rounded,
                    color: Color(0xFFF59E0B), size: 18),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "Don't see the email? Check your spam or junk folder.",
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF92400E),
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 36),

          // ── Back to Login Button ────────────────────────────────
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              // pop() closes this screen and goes back to Login
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Back to Login',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // ── Resend option ───────────────────────────────────────
          GestureDetector(
            onTap: () {
              // Goes back to the form so user can try again
              setState(() {
                _emailSent = false;
                _emailController.clear(); // clears the email field
              });
            },
            child: const Text(
              "Didn't receive it? Try a different email",
              style: TextStyle(
                color: Color(0xFF64748B),
                fontSize: 13,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }
}