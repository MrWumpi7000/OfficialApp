import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../widgets/ChainProgressBar.dart';

class RegisterPage6 extends StatefulWidget {
  @override
  State<RegisterPage6> createState() => _RegisterPage6State();
}

class _RegisterPage6State extends State<RegisterPage6> {
  int currentStep = 4;
  String _partnerCode = "";
  String _yourCode = "A1B2C3"; // Example code, now includes letters

  void nextStep() {
    if (currentStep < 4) setState(() => currentStep++);
    Navigator.pushReplacementNamed(context, '/register7');
  }

  void prevStep() {
    if (currentStep > 0) setState(() => currentStep--);
    Navigator.pushReplacementNamed(context, '/register5');
  }

  void skipStep() {
    Navigator.pushReplacementNamed(context, '/register7');
  }

  void _shareCode() {
    // Implement sharing logic here (e.g., use Share package)
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Share feature not implemented.")),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasInput = _partnerCode.trim().isNotEmpty;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
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
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 16.0, right: 16.0),
                        child: const Text(
                          "Invite your partner to make it Official!",
                          style: TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          "Enter your partner's code",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 36),
                      SixDigitCodeInput(
                        onChanged: (code) {
                          setState(() {
                            _partnerCode = code;
                          });
                        },
                      ),
                      const SizedBox(height: 40),
                      Card(
                        color: const Color(0xFFF6F3FD),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                        child: SizedBox(
                          width: 300,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Text(
                                  "Tap to share your code",
                                  style: TextStyle(
                                    fontSize: 18,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 10),
                                GestureDetector(
                                  onTap: _shareCode,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: hasInput
                                            ? const Color(0xFF6246EA)
                                            : Colors.grey.shade300,
                                        width: 1.5,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.07),
                                          blurRadius: 6,
                                          offset: Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 18, vertical: 10),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.key, color: Color(0xFF6246EA)),
                                        const SizedBox(width: 10),
                                        Text(
                                          _yourCode,
                                          style: TextStyle(
                                            fontSize: 20,
                                            color: Color(0xFF6246EA),
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 3,
                                          ),
                                        ),
                                        const SizedBox(width: 18),
                                        Icon(Icons.ios_share,
                                            color: Color(0xFF6246EA)),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
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
                    child: _partnerCode.length == 6
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
    );
  }
}

class SixDigitCodeInput extends StatefulWidget {
  final void Function(String)? onChanged;

  const SixDigitCodeInput({Key? key, this.onChanged}) : super(key: key);

  @override
  State<SixDigitCodeInput> createState() => _SixDigitCodeInputState();
}

class _SixDigitCodeInputState extends State<SixDigitCodeInput> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Widget _buildCodeFields(String text) {
    List<Widget> fields = [];
    for (int i = 0; i < 6; i++) {
      final digit = (i < text.length) ? text[i].toUpperCase() : '';
      fields.add(
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                digit,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                height: 2,
                color: Colors.grey[400],
                margin: const EdgeInsets.symmetric(horizontal: 4),
              ),
            ],
          ),
        ),
      );
      if (i < 5) fields.add(const SizedBox(width: 6));
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: fields,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _focusNode.requestFocus(),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // The transparent TextField stretches full width for better tap targeting
          TextField(
            controller: _controller,
            focusNode: _focusNode,
            autofocus: false,
            keyboardType: TextInputType.text, // Allow letters and numbers
            maxLength: 6,
            style: const TextStyle(color: Colors.transparent),
            cursorColor: Colors.transparent,
            decoration: const InputDecoration(
              border: InputBorder.none,
              counterText: "",
            ),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
              LengthLimitingTextInputFormatter(6),
            ],
            onChanged: (value) {
              setState(() {});
              if (widget.onChanged != null) widget.onChanged!(value);
            },
          ),
          IgnorePointer(
            ignoring: true,
            child: _buildCodeFields(_controller.text),
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