import 'package:flutter/material.dart';
import 'package:officialapp/services/auth_service.dart';

class CustomBottomAppBar extends StatefulWidget {
  final int currentIndex;

  const CustomBottomAppBar({
    required this.currentIndex,
    Key? key,
  }) : super(key: key);

  @override
  State<CustomBottomAppBar> createState() => CustomBottomAppBarState();
}

class CustomBottomAppBarState extends State<CustomBottomAppBar> {
  late Future<ImageProvider> _userImageFuture;

  @override
  void initState() {
    super.initState();
    _userImageFuture = AuthService().getProfilePictureBytes();
  }

  void refreshProfileImage() {
    setState(() {
      _userImageFuture = AuthService().getProfilePictureBytes();
    });
  }

  void _onTap(BuildContext context, int index) {
    final routes = ['/', '/friends', '/add', '/statistics', '/profile'];
    if (index < routes.length && ModalRoute.of(context)?.settings.name != routes[index]) {
      Navigator.pushReplacementNamed(context, routes[index]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
      child: BottomAppBar(
        color: Colors.black87,
        // Remove notch shape since no longer using FAB
        child: SizedBox(
          height: 70,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(context, Icons.home, "Home", 0),
              _buildNavItem(context, Icons.group, "Friends", 1),
              _buildAddButton(context, 2),
              _buildNavItem(context, Icons.send, "Stats", 3),
              _buildProfileItem(context, 4),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, IconData icon, String label, int index) {
    final isSelected = widget.currentIndex == index;
    return GestureDetector(
      onTap: () => _onTap(context, index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: isSelected ? Colors.white : Colors.grey),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton(BuildContext context, int index) {
    final isSelected = widget.currentIndex == index;
    return IconButton(
      onPressed: () => _onTap(context, index),
      icon: Icon(Icons.add_circle, size: 32, color: isSelected ? Colors.white : Colors.grey),
      tooltip: "Add",
    );
  }

  Widget _buildProfileItem(BuildContext context, int index) {
    final isSelected = widget.currentIndex == index;
    return GestureDetector(
      onTap: () => _onTap(context, index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FutureBuilder<ImageProvider>(
            future: _userImageFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircleAvatar(
                  radius: 12,
                  backgroundColor: Colors.grey,
                  child: SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 2)),
                );
              } else if (snapshot.hasError || !snapshot.hasData) {
                return const CircleAvatar(
                  radius: 12,
                  backgroundColor: Colors.red,
                  child: Icon(Icons.error, size: 14),
                );
              } else {
                return CircleAvatar(
                  radius: 12,
                  backgroundImage: snapshot.data!,
                );
              }
            },
          ),
          const SizedBox(height: 2),
          Text(
            "Profile",
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}