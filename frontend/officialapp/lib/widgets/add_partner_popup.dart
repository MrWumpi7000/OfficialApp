import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
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

      bool success = await AuthService.sendFriendRequest(code);

      if (success) {
        Navigator.pop(context);
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
    final size = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Scaffold(
        backgroundColor: Colors.black.withOpacity(0.4),
        body: Center(
          child: GestureDetector(
            onTap: () {}, // prevents closing on inner tap
            child: ClipRRect(
              borderRadius: BorderRadius.circular(25),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
                child: Container(
                  width: size.width * 0.85,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: Colors.white70,
                          ),
                        )
                      : SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(height: 10),
                              Text(
                                hasPartner
                                    ? "Your Partner"
                                    : "Connect with Partner",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white.withOpacity(0.9),
                                ),
                              ),
                              const SizedBox(height: 20),
                              if (hasPartner)
                                Column(
                                  children: [
                                    CircleAvatar(
                                      radius: 45,
                                      backgroundImage: partnerImageData != null
                                          ? MemoryImage(
                                              base64Decode(partnerImageData!))
                                          : const AssetImage(
                                                  'assets/images/default_profile.png')
                                              as ImageProvider,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      partnerName ?? "",
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.white.withOpacity(0.9),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      "You already have a partner.\nYou can remove them in settings.",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.7),
                                      ),
                                    ),
                                  ],
                                )
                              else
                                Column(
                                  children: [
                                    Text(
                                      "Enter your partner's 6-digit code",
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.white.withOpacity(0.9),
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 16),
                                    Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        color:
                                            Colors.white.withOpacity(0.15),
                                      ),
                                      child: TextField(
                                        controller: _codeController,
                                        keyboardType: TextInputType.number,
                                        style: const TextStyle(
                                            color: Colors.white),
                                        decoration: InputDecoration(
                                          hintText: "Enter code",
                                          hintStyle: TextStyle(
                                            color:
                                                Colors.white.withOpacity(0.5),
                                          ),
                                          border: InputBorder.none,
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 16, vertical: 14),
                                        ),
                                      ),
                                    ),
                                    if (errorMessage.isNotEmpty)
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(top: 8.0),
                                        child: Text(
                                          errorMessage,
                                          style: const TextStyle(
                                              color: Colors.redAccent),
                                        ),
                                      ),
                                    const SizedBox(height: 24),
                                    ElevatedButton(
                                      onPressed: _addPartner,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            Colors.white.withOpacity(0.2),
                                        foregroundColor: Colors.white,
                                        elevation: 0,
                                        minimumSize: const Size.fromHeight(48),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(14),
                                        ),
                                      ),
                                      child: const Text(
                                        "Add Partner",
                                        style: TextStyle(
                                            fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                  ],
                                ),
                              const SizedBox(height: 20),
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text(
                                  "Close",
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.7),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
