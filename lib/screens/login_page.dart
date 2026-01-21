import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  // --- FUNGSI LOGIN GOOGLE ---
  Future<void> signInWithGoogle(BuildContext context) async {
    try {
      if (kIsWeb) {
        // Khusus Web: Menggunakan Popup agar lebih stabil
        GoogleAuthProvider googleProvider = GoogleAuthProvider();
        await FirebaseAuth.instance.signInWithPopup(googleProvider);
      } else {
        // Khusus Mobile: Menggunakan plugin google_sign_in
        final GoogleSignIn googleSignIn = GoogleSignIn();
        final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

        if (googleUser != null) {
          final GoogleSignInAuthentication googleAuth =
              await googleUser.authentication;
          final AuthCredential credential = GoogleAuthProvider.credential(
            accessToken: googleAuth.accessToken,
            idToken: googleAuth.idToken,
          );
          await FirebaseAuth.instance.signInWithCredential(credential);
        }
      }
      // AuthGate akan otomatis mendeteksi perubahan status login
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal login Google: ${e.toString()}")),
      );
    }
  }

  // --- FUNGSI LOGIN/DAFTAR EMAIL ---
  void openEmailAuth(BuildContext context, bool isLogin) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _EmailAuthSheet(isLogin: isLogin),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double horizontalPadding = screenWidth > 600 ? 40 : 24;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 400),
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: 20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- LOGO DUITQUE (Aset Lokal) ---
                  Center(
                    child: Image.asset(
                      'assets/icon/iconDuitque.png',
                      height: 100,
                      fit: BoxFit.contain,
                      errorBuilder: (c, e, s) => const Icon(
                        Icons.wallet,
                        size: 80,
                        color: Colors.purple,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  Text(
                    "Welcome to",
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black54,
                    ),
                  ),

                  // --- NAMA APLIKASI GRADASI ---
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [
                          Color(0xFF6A5AE0),
                          Color(0xFF00D2FF),
                          Color(0xFF00F5A0),
                        ],
                      ).createShader(bounds),
                      child: Text(
                        "DuitQue",
                        style: GoogleFonts.poppins(
                          fontSize: 42,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -1.5,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),
                  Text(
                    "A place where you can track all your\nexpenses and incomes...",
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      color: Colors.black45,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 50),

                  Text(
                    "Let's Get Started...",
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // --- TOMBOL GOOGLE ---
                  _buildSocialButton(
                    onPressed: () => signInWithGoogle(context),
                    label: "Continue with Google",
                    icon: Image.asset(
                      'assets/icon/google-logo.png',
                      height: 24,
                      errorBuilder: (c, e, s) =>
                          const Icon(Icons.g_mobiledata, color: Colors.blue),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // --- TOMBOL EMAIL ---
                  _buildSocialButton(
                    onPressed: () => openEmailAuth(context, true),
                    label: "Login with Email",
                    icon: Image.asset(
                      'assets/icon/email-logo.png',
                      height: 24,
                      errorBuilder: (c, e, s) => const Icon(
                        Icons.email_outlined,
                        color: Colors.indigo,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // --- FOOTER (Menggunakan Wrap agar tidak Overflow) ---
                  Center(
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          "Don't have an account? ",
                          style: GoogleFonts.inter(
                            color: Colors.black54,
                            fontSize: 14,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => openEmailAuth(context, false),
                          child: Text(
                            "Sign Up",
                            style: GoogleFonts.inter(
                              color: const Color(0xFF3F51B5),
                              fontWeight: FontWeight.w700,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Widget Button yang Aman dari Overflow
  Widget _buildSocialButton({
    required VoidCallback onPressed,
    required String label,
    required Widget icon,
  }) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 54),
        side: const BorderSide(color: Colors.black12, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        foregroundColor: Colors.black87,
      ),
      child: Row(
        children: [
          const SizedBox(width: 8),
          SizedBox(width: 30, child: Center(child: icon)),
          Expanded(
            child: Center(
              child: Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis, // Mencegah teks meluber
              ),
            ),
          ),
          const SizedBox(width: 38),
        ],
      ),
    );
  }
}

// --- SHEET AUTENTIKASI EMAIL MODERN ---
class _EmailAuthSheet extends StatefulWidget {
  final bool isLogin;
  const _EmailAuthSheet({super.key, required this.isLogin});

  @override
  State<_EmailAuthSheet> createState() => _EmailAuthSheetState();
}

class _EmailAuthSheetState extends State<_EmailAuthSheet> {
  late bool _isLogin;
  bool _isPasswordVisible = false;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _isLogin = widget.isLogin;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      if (_isLogin) {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
      } else {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
      }
      if (mounted) Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      // Penanganan error spesifik untuk kemudahan user
      String message = 'Terjadi kesalahan';
      if (e.code == 'user-not-found')
        message = 'Email belum terdaftar. Silakan Sign Up.';
      if (e.code == 'wrong-password') message = 'Password salah.';
      if (e.code == 'invalid-email') message = 'Format email tidak valid.';
      if (e.code == 'email-already-in-use')
        message = 'Email sudah terdaftar. Silakan Sign In.';

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        24,
        20,
        24,
        MediaQuery.of(context).viewInsets.bottom + 32,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(
              _isLogin ? 'Welcome Back!' : 'Create Account',
              style: GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0D1B3E),
              ),
            ),
            const SizedBox(height: 32),

            // Field Email
            _buildField(
              'Email Address',
              _emailController,
              Icons.email_outlined,
              false,
            ),
            const SizedBox(height: 16),

            // Field Password
            _buildField(
              'Password',
              _passwordController,
              Icons.lock_outline,
              true,
            ),
            const SizedBox(height: 24),

            // Tombol Submit
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3F51B5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        _isLogin ? 'Sign In' : 'Sign Up',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 16),

            // Toggle Login/SignUp
            Center(
              child: TextButton(
                onPressed: () => setState(() => _isLogin = !_isLogin),
                child: Text(
                  _isLogin
                      ? "New to DuitQue? Create account"
                      : "Already have an account? Sign In",
                  style: GoogleFonts.inter(color: Colors.black54),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(
    String label,
    TextEditingController controller,
    IconData icon,
    bool isPass,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: isPass && !_isPasswordVisible,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, size: 20),
            suffixIcon: isPass
                ? IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                      size: 20,
                    ),
                    onPressed: () => setState(
                      () => _isPasswordVisible = !_isPasswordVisible,
                    ),
                  )
                : null,
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
          ),
          validator: (v) => v!.isEmpty ? 'Tidak boleh kosong' : null,
        ),
      ],
    );
  }
}
