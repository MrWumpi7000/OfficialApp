import 'package:flutter/material.dart';
import 'package:officialapp/services/auth_service.dart';
import '../widgets/base_scaffold.dart';
import '../widgets/add_partner_popup.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  SharedPreferences? prefs;
  int unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

 Future<void> _loadPreferences() async {
  prefs = await SharedPreferences.getInstance();
  setState(() {});

  await _fetchPartnerInfo();
  await _fetchUnreadCount();
}

Future<void> _fetchPartnerInfo() async {
  final token = prefs?.getString("access_token") ?? "";
  final url = Uri.parse("http://awesom-o.org:8000/partner/info?token=$token");

  try {
    final response = await http.get(url, headers: {
      "Accept": "application/json",
    });

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      // Save partner email to prefs
      await prefs?.setString('partner_email', data["partner_email"] ?? "");

      // Save partner profile image to prefs
      await prefs?.setString('partner_profile_image_data', data["profile_image_data"] ?? "");
      await prefs?.setString('partner_profile_image_extension', data["profile_image_extension"] ?? "");

      setState(() {});
    } else {
      print("Error fetching partner info: ${response.statusCode}");
    }
  } catch (e) {
    print("Exception fetching partner info: $e");
  }
}


  Future<void> _fetchUnreadCount() async {

    final token = prefs?.getString("access_token") ?? "";
    final url = Uri.parse(
        "http://awesom-o.org:8000/inbox/unread/count?token=$token");

    try {
      final response = await http.get(url, headers: {
        "Accept": "application/json",
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          unreadCount = data['unread_count'] ?? 0;
        });
      } else {
        print("Error fetching unread count: ${response.statusCode}");
      }
    } catch (e) {
      print("Exception fetching unread count: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (prefs == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final partnerEmail = prefs!.getString('partner_email') ?? "none";
    final hasPartner = partnerEmail.isNotEmpty && partnerEmail != "none";
    print("Partner email: $partnerEmail, hasPartner: $hasPartner");

    return BaseScaffold(
      currentIndex: 0,
      child: Column(
        children: [
          Container(
            height: 250,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(15),
                bottomRight: Radius.circular(15),
              ),
              gradient: LinearGradient(
                begin: Alignment.bottomLeft,
                end: Alignment.topRight,
                colors: [
                  Color(0xFFfbbdf6),
                  Color(0xFFe2d5fc),
                ],
              ),
            ),
            child: Column(
              children: [
                Stack(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding:
                              const EdgeInsets.only(left: 20.0, top: 50.0),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50),
                              color: Colors.white,
                            ),
                            child: const Padding(
                              padding: EdgeInsets.all(4.0),
                              child: Icon(Icons.favorite,
                                  size: 20, color: Color(0xFFa082ad)),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 50.0, right: 10),
                          child: Row(
                            children: [
                              Stack(
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      Navigator.pushReplacementNamed(
                                          context, '/inbox');
                                    },
                                    icon: const Icon(Icons.notifications,
                                        color: Color(0xFF603a62)),
                                  ),
                                  if (unreadCount > 0)
                                    Positioned(
                                      right: 6,
                                      top: 6,
                                      child: Container(
                                        padding: const EdgeInsets.all(2),
                                        decoration: BoxDecoration(
                                          color: Colors.redAccent,
                                          shape: BoxShape.circle,
                                        ),
                                        constraints: const BoxConstraints(
                                          minWidth: 18,
                                          minHeight: 18,
                                        ),
                                        child: Text(
                                          '$unreadCount',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              IconButton(
                                onPressed: () {},
                                icon: const Icon(Icons.settings,
                                    color: Color(0xFF603a62)),
                              ),
                              const SizedBox(width: 20),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Align(
                      alignment: Alignment.topCenter,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 55.0),
                        child: Text(
                          prefs!.getString('name') ?? 'User',
                          style: const TextStyle(
                            fontSize: 20,
                            color: Color(0xFF603a62),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Center(
                  child: SizedBox(
                    height: 100,
                    width: 175,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Positioned(
                          left: 0,
                          child: CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.white,
                            backgroundImage:
                                prefs!.getString('profile_image_data') != null
                                    ? MemoryImage(base64Decode(
                                        prefs!.getString(
                                            'profile_image_data')!))
                                    : const AssetImage(
                                            'assets/images/default_profile.png')
                                        as ImageProvider,
                          ),
                        ),
                        Positioned(
  left: 85,
  top: 0,
  child: CircleAvatar(
    radius: 50,
    backgroundColor: Colors.white,
    backgroundImage: prefs!.getString('partner_profile_image_data') != null &&
            prefs!.getString('partner_profile_image_data')!.isNotEmpty
        ? MemoryImage(base64Decode(prefs!.getString('partner_profile_image_data')!))
        : null,
    child: prefs!.getString('partner_profile_image_data') == null ||
            prefs!.getString('partner_profile_image_data')!.isEmpty
        ? IconButton(
            icon: Icon(
              hasPartner ? Icons.check_circle_outline : Icons.person_add_alt_1,
              color: hasPartner ? Colors.green : const Color(0xFFd5a4a8),
              size: 30,
            ),
            onPressed: () {
              if (hasPartner) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("You already have a partner")),
                );
              } else {
                showDialog(
                  context: context,
                  barrierDismissible: true,
                  builder: (BuildContext context) {
                    return const AddPartnerPopup();
                  },
                );
              }
            },
          )
        : null,
  ),
)

                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 12.0),
              child: const Text(
                'Your Daily Tasks',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
