import 'package:flutter/material.dart';
import '../widgets/base_scaffold.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  SharedPreferences? prefs;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  void _loadPreferences() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // Show a loading indicator if prefs is not yet loaded
    if (prefs == null) {
      return Center(child: CircularProgressIndicator());
    }

    return BaseScaffold(
      currentIndex: 0,
      child: Column(
        children: [
          Container(
            height: 250,
            decoration: BoxDecoration(
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
                          padding: const EdgeInsets.only(left: 20.0, top: 50.0),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50),
                              color: Colors.white,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Icon(Icons.favorite, size: 20, color: const Color(0xFFa082ad)),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 50.0),
                          child: Row(
                            children: [
                              IconButton(
                                onPressed: () {},
                                icon: Icon(Icons.notifications, color: Color(0xFF603a62)),
                              ),
                              IconButton(
                                onPressed: () {},
                                icon: Icon(Icons.settings, color: Color(0xFF603a62)),
                              ),
                              SizedBox(width: 20),
                            ],
                          ),
                        ),
                      ],
                    ),
                    // Centered name horizontally only, not vertically
                    Align(
                      alignment: Alignment.topCenter,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 55.0), // Adjust the vertical position as needed
                        child: Text(
                          prefs!.getString('name') ?? 'User',
                          style: TextStyle(
                            fontSize: 20,
                            color: Color(0xFF603a62),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Center(
                  child: SizedBox(
                    height: 100,
                    width: 175, // Adjust width as needed for overlap
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Positioned(
                          left: 0,
                          child: CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.white,
                            backgroundImage: prefs!.getString('profile_image_data') != null
                                ? MemoryImage(base64Decode(prefs!.getString('profile_image_data')!))
                                : AssetImage('assets/images/default_profile.png') as ImageProvider,
                          ),
                        ),
                        Positioned(
                          left: 85, // Adjust this value for more or less overlap (should be less than diameter)
                          top: 0,
                          child: CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.white,
                            child: Icon(Icons.person_add_alt_1, color: Color(0xFFd5a4a8), size: 30),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          //Make the text to the left
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 12.0),
              child: Text(
                'Your Daily Tasks',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(height: 20),
          Align(
            alignment: Alignment.centerLeft,
            child: Column(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, '/check_in');
                  },
                  child: Card(
                    margin: EdgeInsets.symmetric(horizontal: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: SizedBox(
                      width: 120,
                      height: 125,
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Image.asset(
                              'assets/checkin_logo.png',
                              height: 80,
                              width: 75,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Text(
                            'Check in',
                            style: TextStyle(
                              fontSize: 18,
                              color: Color(0xFF603a62),
                              fontWeight: FontWeight.bold,
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
        ],
      ),
    );
  }
}