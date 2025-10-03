import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';

class AddPartnerPopup extends StatefulWidget {
  const AddPartnerPopup({Key? key}) : super(key: key);

  @override
  State<AddPartnerPopup> createState() => _AddPartnerPopupState();
}

class _AddPartnerPopupState extends State<AddPartnerPopup> {
  String? partnerName;
  String? partnerImageData;
  bool isLoading = true;
  bool hasPartner = false;
  final TextEditingController _codeController = TextEditingController();
  String errorMessage = "";

  @override
  void initState() {
    super.initState();
    _loadPartnerInfo();
  }

  Future<void> _loadPartnerInfo() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      partnerName = prefs.getString('partner_name');
      partnerImageData = prefs.getString('partner_image_data');
      hasPartner = partnerName != null && partnerName!.isNotEmpty;
      isLoading = false;
    });
  }

  Future<void> _addPartner() async {
    final code = _codeController.text.trim();
    if (code.isEmpty) {
      setState(() => errorMessage = "Please enter the code");
      return;
    }

    setState(() {
      errorMessage = "";
      isLoading = true;
    });

    try {
      print("bool success = await AuthService().sendFriendRequest(code);");
      if (1 == 1) {
        Navigator.pop(context); // close popup
      } else {
        setState(() => errorMessage = "Failed to add partner");
      }
    } catch (e) {
      setState(() => errorMessage = e.toString());
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
        child: Container(
          color: Colors.black.withOpacity(0.3),
          alignment: Alignment.center,
          child: GestureDetector(
            onTap: () {}, // prevents popup closing on inner tap
            child: Container(
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.symmetric(horizontal: 30),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: isLoading
                  ? const CircularProgressIndicator()
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (hasPartner)
                          Column(
                            children: [
                              CircleAvatar(
                                radius: 40,
                                backgroundImage: partnerImageData != null
                                    ? MemoryImage(base64Decode(partnerImageData!))
                                    : const AssetImage('assets/images/default_profile.png')
                                        as ImageProvider,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                partnerName ?? "",
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 20),
                              const Text(
                                  "You already have a partner. You can only remove them in settings."),
                            ],
                          )
                        else
                          Column(
                            children: [
                              const Text(
                                "Enter your partner's 6-digit code",
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 10),
                              TextField(
                                controller: _codeController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  hintText: "Enter code",
                                ),
                              ),
                              if (errorMessage.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    errorMessage,
                                    style: const TextStyle(color: Colors.red),
                                  ),
                                ),
                              const SizedBox(height: 15),
                              ElevatedButton(
                                onPressed: _addPartner,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.teal,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: const Text("Add Partner"),
                              ),
                            ],
                          ),
                        const SizedBox(height: 10),
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("Close"),
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
