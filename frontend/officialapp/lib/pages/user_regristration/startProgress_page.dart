import 'package:flutter/material.dart';
import '../../services/auth_service.dart'; // Adjust the path based on your structure

class StartprogressPage extends StatefulWidget {
  @override
  State<StartprogressPage> createState() => _StartprogressPage();
}

class _StartprogressPage extends State<StartprogressPage> {
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          ClipPath(
            clipper: TopCurveClipper(),
            child: Container(
              color: const Color(0xFF6246EA), // Example purple background
              height: 300,
              width: double.infinity,
              child: Image.asset(
                'assets/startProgress_page1.png', // Use your uploaded image here
                fit: BoxFit.cover,
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Title section
          const Text(
            "Already made it",
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          RichText(
            text: const TextSpan(
              text: 'Official',
              style: TextStyle(
                  fontSize: 28, color: Color(0xFF6246EA), fontWeight: FontWeight.bold),
              children: [
                TextSpan(
                  text: '?',
                  style: TextStyle(color: Colors.black),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            "Check what your partner\nhas been up to",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 20),

          // Sign In button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                side: const BorderSide(color: Color(0xFF6246EA), width: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                "Sign in",
                style: TextStyle(color: Color(0xFF6246EA), fontSize: 16),
              ),
            ),
          ),

          const SizedBox(height: 40),

          Spacer(),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(20),
            alignment: Alignment.bottomCenter,
            
            decoration: BoxDecoration(
              color: const Color(0xFFF5F2FF),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                const Text(
                  "New to Official?",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Start having more fun in your relationship",
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 15),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, "/start-progress");
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6246EA),
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text("Sign Up", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
                ),
            )],
            ),
          ),
        SizedBox(height: 30,)],
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
