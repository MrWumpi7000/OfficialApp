import 'package:flutter/material.dart';
import '../../widgets/ChainProgressBar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/auth_service.dart';

class RegisterPage1 extends StatefulWidget {
  @override
  State<RegisterPage1> createState() => _RegisterPage1State();
}

class _RegisterPage1State extends State<RegisterPage1> {
  int currentStep = 0;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  String email = "";
  String password = "";
  String confirmPassword = "";
  String? errorMessage; // For showing error to user
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // New: field-specific errors
  String? passwordError;
  String? confirmPasswordError;

  bool get _isValidEmail {
    final email = _emailController.text.trim();
    // Basic email validation
    return RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$").hasMatch(email);
  }

  bool get _isValidPassword {
    // You can improve this with your own password rules
    return _passwordController.text.trim().length >= 6;
  }

  bool get _passwordsMatch {
    return _passwordController.text == _confirmPasswordController.text;
  }

  void _validatePasswordFields() {
    setState(() {
      passwordError = null;
      confirmPasswordError = null;
      if (_passwordController.text.trim().isEmpty) {
        passwordError = "Password cannot be empty.";
      } else if (!_isValidPassword) {
        passwordError = "Password must be at least 6 characters.";
      }

      if (_confirmPasswordController.text.isNotEmpty && !_passwordsMatch) {
        confirmPasswordError = "Passwords do not match.";
      }
    });
  }

  Future<void> nextStep() async {
    if (currentStep < 4) setState(() => currentStep++);
    email = _emailController.text.trim();
    password = _passwordController.text.trim();
    confirmPassword = _confirmPasswordController.text.trim();

    // Clear previous errors
    errorMessage = null;
    passwordError = null;
    confirmPasswordError = null;

    if (!_isValidEmail) {
      setState(() {
        errorMessage = "Please enter a valid email address.";
      });
      return;
    }
    if (!_isValidPassword) {
      setState(() {
        passwordError = "Password must be at least 6 characters.";
        errorMessage = null;
      });
      return;
    }
    if (!_passwordsMatch) {
      setState(() {
        confirmPasswordError = "Passwords do not match.";
        errorMessage = null;
      });
      return;
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('email', email);
    prefs.setString('password', password);

    bool success = await AuthService().sendVerificationCode();
    if (success) {
      setState(() {
        errorMessage = null;
      });
      Navigator.pushReplacementNamed(context, '/register2');
    } else {
      setState(() {
        errorMessage = "Email already registered or error sending code.";
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          ClipPath(
            clipper: TopCurveClipper(),
            child: Container(
              height: 255,
              color: Color(0xFF6246EA),
              child: Center(
                child: ParadeProgressBar(
                  currentStep: currentStep,
                ),
              ),
            ),
          ),

          const SizedBox(height: 40),

          // Consistent heading for email
          Padding(
            padding: const EdgeInsets.only(left: 15, right: 15),
            child: const Text(
              "What's your email?",
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
          ),

          const SizedBox(height: 20),

          SizedBox(
            width: 360,
            child: TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              onChanged: (_) {
                setState(() {
                  errorMessage = null; // clear error on input change
                });
              },
              decoration: const InputDecoration(
                hintText: "Email address*",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(30)),
                  borderSide: BorderSide.none,
                ),
                fillColor: Color.fromARGB(255, 243, 243, 243),
                filled: true,
              ),
            ),
          ),

          const SizedBox(height: 30),

          // Consistent heading for password
          Padding(
            padding: const EdgeInsets.only(left: 15, right: 15),
            child: const Text(
              "What's your Password?",
              style: TextStyle(fontSize: 28.5, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: 360,
            child: TextField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              onChanged: (_) {
                _validatePasswordFields();
                errorMessage = null; // clear error on input change
              },
              decoration: InputDecoration(
                hintText: "Password*",
                errorText: passwordError,
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(30)),
                  borderSide: BorderSide.none,
                ),
                fillColor: const Color.fromARGB(255, 243, 243, 243),
                filled: true,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility : Icons.visibility_off,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          SizedBox(
            width: 360,
            child: TextField(
              controller: _confirmPasswordController,
              obscureText: _obscureConfirmPassword,
              onChanged: (_) {
                _validatePasswordFields();
                errorMessage = null; // clear error on input change
              },
              decoration: InputDecoration(
                hintText: "Confirm Password*",
                errorText: confirmPasswordError,
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(30)),
                  borderSide: BorderSide.none,
                ),
                fillColor: const Color.fromARGB(255, 243, 243, 243),
                filled: true,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureConfirmPassword = !_obscureConfirmPassword;
                    });
                  },
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Show error message if present
          if (errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
              child: Text(
                errorMessage!,
                style: const TextStyle(color: Colors.red, fontSize: 16),
              ),
            ),

          Spacer(),
          Padding(
            padding: const EdgeInsets.only(bottom: 30.0, left: 16, right: 16),
            child: SizedBox(
              width: 360,
              child: ElevatedButton(
                onPressed: (_isValidEmail && _isValidPassword && _passwordsMatch) ? nextStep : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6246EA),
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  "Next",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TopCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();

    path.lineTo(0, size.height - 100);
    path.quadraticBezierTo(
      size.width / 2,
      size.height,
      size.width,
      size.height - 100,
    );
    path.lineTo(size.width, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}