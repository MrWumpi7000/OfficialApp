import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class StartRegisterPage0 extends StatefulWidget {
  @override
  State<StartRegisterPage0> createState() => _StartRegisterPage0();
}

class _StartRegisterPage0 extends State<StartRegisterPage0> {
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
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
                  left: 110,
                  top: 70,
                  child: RichText(
                    text: TextSpan(
                      text: "Welcome to",
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

          Padding(
            padding: const EdgeInsets.only(right: 40, left: 40),
            child: const Text( textAlign: TextAlign.center,
              "Your relationship's new best friend",
              style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold,),
              
            ),
          ),

          SizedBox(height: 20,),
          Padding(
            padding: const EdgeInsets.only(left: 35, right: 35),
            child: RichText(
              textAlign: TextAlign.center,
              text: const TextSpan(
                text: 'Plan ',
                style: TextStyle(
                    fontSize: 15, color: Colors.black, fontFamily: 'Montserrat', fontWeight: FontWeight.normal),
                children: [
                  TextSpan(
                    text: 'better dates, ',
                    style: TextStyle(color: Color(0xFF6246EA)),
                  ),
                  TextSpan(
                    text: "have ",
                    style: TextStyle(color: Colors.black)
                  ),
                  TextSpan(
                    text: "more fun ",
                    style: TextStyle(color: Color(0xFF6246EA)),
                  ),
                  TextSpan(text: "and be ",
                  style: TextStyle(color: Colors.black)),
                  TextSpan(
                    text: "better partners ",
                    style: TextStyle(color: Color(0xFF6246EA)),
                  ),
                  TextSpan(
                    text: "with Official!",
                    style: TextStyle(color: Colors.black)
                  )
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          SvgPicture.asset(
            'assets/pfadForRegister.svg',
            width: 200,
            height: 250,
          ),
          const SizedBox(height: 50),
              Column(
              children: [
                SizedBox(
                  width: 325,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, "/register1");
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6246EA),
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text("Let's go! 🥳", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ),
            )],
        ),
      ]),
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
