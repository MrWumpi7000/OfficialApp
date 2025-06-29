import 'package:flutter/material.dart';
import 'package:officialapp/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../widgets/ChainProgressBar.dart';
import '../../widgets/DatePickerDropdown.dart';

class RegisterPage4 extends StatefulWidget {
  @override
  State<RegisterPage4> createState() => _RegisterPage4State();
}

class _RegisterPage4State extends State<RegisterPage4> {
  int currentStep = 2;
  DateTime? _selectedDate;
  bool success = false;

  bool get _isOldEnough {
    if (_selectedDate == null) return false;
    final today = DateTime.now();
    final age = today.year - _selectedDate!.year - ((today.month < _selectedDate!.month || (today.month == _selectedDate!.month && today.day < _selectedDate!.day)) ? 1 : 0);
    return age >= 18;
  }

  Future<void> nextStep() async {
    if (_selectedDate != null && _isOldEnough) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('birthday', _selectedDate!.toIso8601String());

      if (currentStep < 4) setState(() => currentStep++);

      success = await AuthService().register();
      if (success) {
        Navigator.pushReplacementNamed(context, '/register5');
      } else {
        Navigator.pushReplacementNamed(context, '/register1');
      }
    }
  }

  void prevStep() {
    if (currentStep > 0) setState(() => currentStep--);
    Navigator.pushReplacementNamed(context, '/register3');
  }

  @override
  Widget build(BuildContext context) {
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
                      color: Color(0xFF6246EA),
                      child: Center(
                        child: ParadeProgressBar(
                          currentStep: currentStep,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    "What's your birthday?",
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  SizedBox(
                    width: 330,
                    height: 60,
                    child: DatePickerDropdown(
                      onDateSelected: (date) {
                        setState(() {
                          _selectedDate = date;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 30),
                  // Only show the info text if user is NOT old enough
                  if (_selectedDate == null || !_isOldEnough)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center, // <--- center vertically
                        children: [
                          Icon(Icons.info, color: Colors.red),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "You must be at least 18 years old to register for this app. Please ensure that you are of legal age before proceeding.",
                              style: TextStyle(fontSize: 16, color: Colors.grey),
                              textAlign: TextAlign.left,
                              softWrap: true,
                            ),
                          ),
                        ],
                      ),
                    ),
                  Spacer(),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 30.0, left: 16, right: 16),
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
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: (_selectedDate != null && _isOldEnough)
                                ? nextStep
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: (_selectedDate != null && _isOldEnough)
                                  ? const Color(0xFF6246EA)
                                  : Colors.grey.shade400,
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