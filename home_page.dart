import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'safety_tips_page.dart';
import 'profile_page.dart';
import 'login_screen.dart';
import 'live_location_tracking.dart';
import 'emergency_contacts.dart';
import 'nearby_police_stations.dart';
import 'sos_emergency_page.dart';
import 'ai_chat_assistant.dart';  // OLD AI

// ✅ NEW IMPORTS (ADDED ONLY)
import 'map.dart';
import 'ai_chat.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    if (context.mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  final List<Widget> _pages = [
    const _HomeBody(),
    const ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE3F2FD),
      appBar: AppBar(
        title: const Text(
          'AMAR PROTIKKHA',
          style: TextStyle(
            fontFamily: 'Georgia',
            fontSize: 24,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.6,
            color: Colors.white,
            shadows: [
              Shadow(
                offset: Offset(0, 1.4),
                blurRadius: 2,
                color: Colors.black26,
              ),
            ],
          ),
        ),
        backgroundColor: const Color(0xFF1E88E5),
        elevation: 5,
        actions: [
          IconButton(
            onPressed: _signOut,
            icon: const Icon(Icons.logout, color: Colors.white),
          )
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF1976D2),
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}

class _HomeBody extends StatelessWidget {
  const _HomeBody();

  void _showComingSoon(BuildContext context, String featureName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$featureName feature coming soon!'),
        backgroundColor: const Color(0xFF1976D2),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget buildFeatureBox(BuildContext context, String title, String subtitle,
      IconData icon, {Widget? page, bool comingSoon = false}) {
    return InkWell(
      onTap: () {
        if (comingSoon) {
          _showComingSoon(context, title);
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => page!),
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black12.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(10),
        height: 120,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 35, color: const Color(0xFF1976D2)),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF2196F3), Color(0xFFE3F2FD)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .doc(FirebaseAuth.instance.currentUser!.uid)
                  .get(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Text(
                    "Hi, User 👋",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  );
                }

                final data = snapshot.data!.data() as Map<String, dynamic>?;
                final name = data?['name'] ?? 'User';

                return Text(
                  "Hi, $name 👋",
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                );
              },
            ),

            const SizedBox(height: 25),

            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [

                // 🔵 EXISTING FEATURES (UNCHANGED)
                buildFeatureBox(
                  context,
                  "SOS Emergency ",
                  "Send instant alerts with your location.",
                  Icons.warning_amber_rounded,
                  page: SOSEmergencyPage(emergencyContacts: []),
                ),

                buildFeatureBox(
                  context,
                  "Live Location Tracking",
                  "Share your real-time location.",
                  Icons.location_on,
                  page: const LiveLocationTrackingPage(),
                ),

                buildFeatureBox(
                  context,
                  "Nearby Help Services",
                  "Find and contact your nearest help point.",
                  Icons.local_police,
                  page: const NearbyPoliceStationsPage(),
                ),

                buildFeatureBox(
                  context,
                  "AI Chat Assistant",
                  "Chat with a friendly bot for calm & support.",
                  Icons.chat_bubble_outline,
                  page: AIChatPage(),
                ),

                buildFeatureBox(
                  context,
                  "Emergency Contacts",
                  "Manage your trusted contacts easily.",
                  Icons.contact_phone,
                  page: const EmergencyContactsPage(),
                ),

                buildFeatureBox(
                  context,
                  "Safety Tips & Awareness",
                  "Learn self-defense and safety tips.",
                  Icons.menu_book,
                  page: const SafetyTipsPage(),
                ),

                // 🆕 NEW FEATURE 1 → MAP
                buildFeatureBox(
                  context,
                  "Safety Map",
                  "Explore safe routes & report areas.",
                  Icons.map,
                  page: const MapScreen(),
                ),

                // 🆕 NEW FEATURE 2 → NEW AI SYSTEM
                buildFeatureBox(
                  context,
                  "AI Safety Assistant",
                  "Advanced AI for safety insights & routes.",
                  Icons.smart_toy,
                  page: const AiChatScreen(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}