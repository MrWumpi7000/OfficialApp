import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../widgets/ChainProgressBar.dart';
import 'dart:io';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:typed_data';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class RegisterPage3 extends StatefulWidget {
  @override
  State<RegisterPage3> createState() => _RegisterPage3State();
}

class _RegisterPage3State extends State<RegisterPage3> {
  int currentStep = 1;
  Uint8List? _imageBytes;
  String? _imageExtension; // e.g. 'jpg', 'png'
  final TextEditingController _nameController = TextEditingController();

  bool get _isImagePicked => _imageBytes != null;
  bool get _isNameEntered => _nameController.text.trim().isNotEmpty;
  bool get _canProceed => _isNameEntered; // Or: _isNameEntered && _isImagePicked;

  @override
  void initState() {
    super.initState();
    _loadCachedImage();
    _loadCachedName();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _loadCachedImage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? base64Data = prefs.getString('profile_image_data');
    String? ext = prefs.getString('profile_image_type');
    if (base64Data != null && ext != null) {
      setState(() {
        _imageBytes = base64Decode(base64Data);
        _imageExtension = ext;
      });
    }
  }

  Future<void> _loadCachedName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? name = prefs.getString('name');
    if (name != null) {
      _nameController.text = name;
      setState(() {});
    }
  }

  Future<void> _saveProfileImage(Uint8List bytes, String extension) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('profile_image_data', base64Encode(bytes));
    await prefs.setString('profile_image_type', extension);
    setState(() {
      _imageBytes = bytes;
      _imageExtension = extension;
    });
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      String extension;
      Uint8List bytes;
      if (kIsWeb) {
        extension = pickedFile.mimeType?.split('/').last.toLowerCase() ?? 'png';
        bytes = await pickedFile.readAsBytes();
      } else {
        extension = pickedFile.path.split('.').length > 1
            ? pickedFile.path.split('.').last.toLowerCase()
            : 'jpg';
        bytes = await pickedFile.readAsBytes();
      }
      await _saveProfileImage(bytes, extension);
    }
  }

  void nextStep() async {
    if (!_canProceed) return;
    if (currentStep < 4) setState(() => currentStep++);

    String name = _nameController.text.trim();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('name', name);
    // Image is already cached via _saveProfileImage on pick

    Navigator.pushReplacementNamed(context, '/register4');
  }

  void prevStep() {
    if (currentStep > 0) setState(() => currentStep--);
    Navigator.pushReplacementNamed(context, '/register1');
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
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 24),
                      const Text(
                        "What's your name?",
                        style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20),
                      const SizedBox(
                        width: 300,
                        child: Text(
                          "Please enter your name",
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                          textAlign: TextAlign.start,
                        ),
                      ),
                      SizedBox(
                        width: 330,
                        child: TextField(
                          controller: _nameController,
                          onChanged: (_) => setState(() {}),
                          decoration: const InputDecoration(
                            hintText: "Name*",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(15)),
                              borderSide: BorderSide.none,
                            ),
                            fillColor: Color.fromARGB(255, 243, 243, 243),
                            filled: true,
                          ),
                        ),
                      ),
                      const SizedBox(height: 50),
                      const SizedBox(
                        width: 300,
                        child: Text(
                          "Let's choose a Profile Picture",
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 15),
                      GestureDetector(
                        onTap: _pickImage,
                        child: _imageBytes != null
                            ? CircleAvatar(
                                radius: 48,
                                backgroundImage: MemoryImage(_imageBytes!),
                              )
                            : CircleAvatar(
                                radius: 48,
                                backgroundColor: Colors.white,
                                child: SvgPicture.asset(
                                  'assets/simple_camera_add.svg',
                                  width: 95,
                                  height: 95,
                                ),
                              ),
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),
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
                      onPressed: _canProceed ? nextStep : null,
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