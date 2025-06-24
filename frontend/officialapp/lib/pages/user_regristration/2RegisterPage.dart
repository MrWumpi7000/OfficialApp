import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../widgets/ChainProgressBar.dart';
import '../../services/auth_service.dart';

class RegisterPage2 extends StatefulWidget {
  @override
  State<RegisterPage2> createState() => _RegisterPage2State();
}

class _RegisterPage2State extends State<RegisterPage2> {
  int currentStep = 0;
  String code = "";
  String? errorMessage; // To show error message

  Future<void> ValidateCode(code) async {
    await AuthService().verifyCode(code).then((isValid) {
      if (isValid) {
        setState(() {
          errorMessage = null; // Clear error message if successful
        });
        Navigator.pushReplacementNamed(context, '/register3');
      } else {
        setState(() {
          errorMessage = "Invalid verification code. Please try again.";
        });
      }
    }).catchError((error) {
      setState(() {
        errorMessage = "Error validating code: $error";
      });
    });
  }

  void nextStep() {
    if (currentStep < 4) setState(() => currentStep++);
    ValidateCode(code);
  }

  void prevStep() {
    if (currentStep > 0) setState(() => currentStep--);
    Navigator.pushReplacementNamed(context, '/register1');
  }

  void onCodeChanged(String value) {
    setState(() {
      code = value;
      errorMessage = null; 
    });
    if (value.length == 6) {
      ValidateCode(value);
    }
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
            const SizedBox(height: 24),
            // Title section
            const Text(
              "Verify your email",
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const SizedBox(
              width: 250,
              child: Text(
                "Please enter the verification code sent to your email address.",
                style: TextStyle(fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 32),
            // 6-digit code input
            SizedBox(
              width: 300,
              height: 60,
              child: SixDigitCodeInput(
                onChanged: onCodeChanged,
              ),
            ),
            // Show error message if code is wrong
            if (errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: Text(
                  errorMessage!,
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 16,
                  ),
                ),
              ),
            const Spacer(),
            // Only ONE row of navigation buttons at the bottom
            Padding(
              padding: const EdgeInsets.only(bottom: 30.0, left: 16, right: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back always enabled
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
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Next only enabled if code is 6 digits
                  Expanded(
                    child: ElevatedButton(
                      onPressed: code.length == 6 ? nextStep : null,
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
      final digit = (i < text.length) ? text[i] : '';
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
            keyboardType: TextInputType.number,
            maxLength: 6,
            style: const TextStyle(color: Colors.transparent),
            cursorColor: Colors.transparent,
            decoration: const InputDecoration(
              border: InputBorder.none,
              counterText: "",
            ),
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
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