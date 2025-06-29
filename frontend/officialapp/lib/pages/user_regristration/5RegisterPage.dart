import 'package:flutter/material.dart';
import '../../widgets/ChainProgressBar.dart';

class RegisterPage5 extends StatefulWidget {
  @override
  State<RegisterPage5> createState() => _RegisterPage5State();
}

class _RegisterPage5State extends State<RegisterPage5> {
  int currentStep = 3;
  final TextEditingController _controller = TextEditingController();
  static const int maxChars = 100;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void nextStep() {
    if (currentStep < 4) setState(() => currentStep++);
    Navigator.pushReplacementNamed(context, '/register6');
  }

  void prevStep() {
    if (currentStep > 0) setState(() => currentStep--);
    Navigator.pushReplacementNamed(context, '/register4');
  }

  void skipStep() {
    // You can handle skip logic here if needed
    Navigator.pushReplacementNamed(context, '/register6');
  }

  @override
  Widget build(BuildContext context) {
    final hasInput = _controller.text.trim().isNotEmpty;
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top,
            ),
            child: IntrinsicHeight(
              child: Column(
                children: [
                  ClipPath(
                    clipper: TopCurveClipper(),
                    child: Container(
                      height: 255,
                      color: const Color(0xFF6246EA),
                      child: Center(
                        child: ParadeProgressBar(
                          currentStep: currentStep,
                        ),
                      ),
                    ),
                  ),
                  const Text(
                    "Dive deeper into what matters to you with the Daily Question. Answer your first one!",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    color: const Color.fromARGB(255, 250, 250, 250),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 16.0, right: 16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  color: const Color(0xFFF5E4E6),
                                  child: const Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    child: Text(
                                      "#1",
                                      style: TextStyle(color: Color.fromARGB(255, 227, 144, 153)),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  color: const Color.fromARGB(255, 255, 255, 255),
                                  child: const Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    child: Row(
                                      children: [
                                        Icon(Icons.lightbulb, color: Color(0xFFF1E9DC)),
                                        SizedBox(width: 4),
                                        Text(
                                          "Goods and Dreams",
                                          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            "What is something new that you would like to try with your partner this year?",
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          Stack(
                            children: [
                              TextField(
                                controller: _controller,
                                minLines: 5,
                                maxLines: 7,
                                maxLength: maxChars,
                                decoration: InputDecoration(
                                  counterText: "",
                                  filled: true,
                                  fillColor: Color(0xFFFAF6F7),
                                  hintText: "Type your answer here",
                                  contentPadding: EdgeInsets.all(16),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Color(0xFFEDEDED),
                                      width: 1,
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Color(0xFFD5D5D5),
                                      width: 1.2,
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Color(0xFFEDEDED),
                                      width: 1,
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                style: TextStyle(fontSize: 16),
                                onChanged: (_) => setState(() {}),
                              ),
                              Positioned(
                                right: 12,
                                bottom: 12,
                                child: Text(
                                  "${_controller.text.length}/$maxChars",
                                  style: TextStyle(
                                    color: _controller.text.length >= maxChars
                                        ? Colors.red
                                        : Colors.grey,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Spacer(),
                  Padding(
                    padding: const EdgeInsets.only(
                        bottom: 30.0, left: 16, right: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: prevStep,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6246EA),
                              minimumSize: const Size.fromHeight(50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: const Text(
                              "Back",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: hasInput
                              ? ElevatedButton(
                                  onPressed: nextStep,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF6246EA),
                                    minimumSize: const Size.fromHeight(50),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                  ),
                                  child: const Text(
                                    "Submit",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                )
                              : ElevatedButton(
                                  onPressed: skipStep,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.grey.shade400,
                                    minimumSize: const Size.fromHeight(50),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                  ),
                                  child: const Text(
                                    "Skip",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
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