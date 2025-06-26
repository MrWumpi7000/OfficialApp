import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  @override
  State<LoginPage> createState() => _LoginPage();
}

class _LoginPage extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _obscurePassword = true;
  String? emailError;
  String? passwordError;
  String? errorMessage;
  bool _isLoading = false;

  bool get _isValidEmail {
    final email = _emailController.text.trim();
    return RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$").hasMatch(email);
  }

  bool get _isValidPassword {
    return _passwordController.text.trim().length >= 6;
  }

  void _validateEmailField() {
    setState(() {
      emailError = null;
      final emailText = _emailController.text.trim();
      if (emailText.isEmpty) {
        emailError = null; // Don't show error until user tries to login
      } else if (!_isValidEmail) {
        emailError = "Please enter a valid email address.";
      }
    });
  }

  void _validatePasswordField() {
    setState(() {
      passwordError = null;
      final passwordText = _passwordController.text.trim();
      if (passwordText.isEmpty) {
        passwordError = null; // Don't show error until user tries to login
      } else if (!_isValidPassword) {
        passwordError = "Password must be at least 6 characters.";
      }
    });
  }

  void _validateFields() {
    setState(() {
      emailError = null;
      passwordError = null;

      final emailText = _emailController.text.trim();
      final passwordText = _passwordController.text.trim();

      if (emailText.isEmpty) {
        emailError = "Email cannot be empty.";
      } else if (!_isValidEmail) {
        emailError = "Please enter a valid email address.";
      }

      if (passwordText.isEmpty) {
        passwordError = "Password cannot be empty.";
      } else if (!_isValidPassword) {
        passwordError = "Password must be at least 6 characters.";
      }
    });
  }

  Future<void> _login() async {
    setState(() {
      errorMessage = null;
      _isLoading = true;
    });
    _validateFields();

    if (emailError != null || passwordError != null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('email', _emailController.text.trim());
    prefs.setString('password', _passwordController.text.trim());


    // Replace with your own authentication logic
    if (await AuthService().login()) {
      setState(() {
        errorMessage = null;
        _isLoading = false;
      });
      Navigator.pushReplacementNamed(context, '/');
    } else {
      setState(() {
        errorMessage = "Invalid email or password.";
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            ClipPath(
              clipper: TopCurveClipper(),
              child: Stack(
                children: [
                  Container(
                    color: const Color(0xFF6246EA),
                    height: 300,
                    width: double.infinity,
                    child: Image.asset(
                      'assets/StartRegisterPage0.jpg',
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    left: 80,
                    top: 70,
                    child: RichText(
                      text: TextSpan(
                        text: "Welcome back to",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        children: [
                          TextSpan(text: " Official!", style: TextStyle(color: Colors.orange[300])),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
            const Text(
              "Login to your account",
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 4),
                child: Column(
                  children: [
                    SizedBox(
                      width: 325,
                      child: TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        onChanged: (_) {
                          _validateEmailField();
                          setState(() {
                            errorMessage = null;
                          });
                        },
                        decoration: InputDecoration(
                          hintText: "Email address*",
                          errorText: emailError,
                          border: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(30)),
                            borderSide: BorderSide.none,
                          ),
                          fillColor: const Color.fromARGB(255, 243, 243, 243),
                          filled: true,
                          suffixIcon: (_emailController.text.isNotEmpty && emailError == null)
                              ? Icon(Icons.check_circle, color: Colors.green)
                              : (_emailController.text.isNotEmpty && emailError != null)
                                  ? Icon(Icons.error, color: Colors.red)
                                  : null,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: 325,
                      child: TextField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        onChanged: (_) {
                          _validatePasswordField();
                          setState(() {
                            errorMessage = null;
                          });
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
                    if (errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0, bottom: 4.0),
                        child: Text(
                          errorMessage!,
                          style: const TextStyle(color: Colors.red, fontSize: 16),
                        ),
                      ),
                    // Row for Register and Forgot Password
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, "/register1");
                          },
                          child: const Text(
                            "Register account!",
                            style: TextStyle(
                              color: Color(0xFF6246EA),
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, "/reset-password");
                          },
                          child: const Text(
                            "Forgot password?",
                            style: TextStyle(
                              color: Color(0xFF6246EA),
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 30.0, left: 16, right: 16),
              child: SizedBox(
                width: 325,
                child: ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : (_isValidEmail && _isValidPassword ? _login : null),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6246EA),
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        )
                      : const Text(
                          "Login",
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
      ),
    );
  }
}

// Custom clipper for the curved top
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