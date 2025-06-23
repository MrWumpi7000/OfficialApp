import 'package:flutter/material.dart';
import '../../widgets/ChainProgressBar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterPage1 extends StatefulWidget {
  @override
  State<RegisterPage1> createState() => _RegisterPage1State();
}

class _RegisterPage1State extends State<RegisterPage1> {
  int currentStep = 0;
  final TextEditingController _emailController = TextEditingController();
  String email = "";
  bool get _isValidEmail {
    final email = _emailController.text.trim();
    // Basic email validation
    return RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$").hasMatch(email);
  }

  void nextStep() {
    if (currentStep < 4) setState(() => currentStep++);
    email = _emailController.text.trim();
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString('email', email);
    });
    Navigator.pushReplacementNamed(context, '/register2');
  }

  @override
  void dispose() {
    _emailController.dispose();
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

          const Text(
            "What's your email?",
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 20),

          SizedBox(
            width: 360,
            child: TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              onChanged: (_) => setState(() {}),
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

          const SizedBox(height: 20),

          Spacer(),
          Padding(
            padding: const EdgeInsets.only(bottom: 30.0, left: 16, right: 16),
            child: SizedBox(
              width: 360,
              child: ElevatedButton(
                onPressed: _isValidEmail ? nextStep : null,
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