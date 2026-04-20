import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';
import '../models/complaint_model.dart';
import '../services/complaint_service.dart';
import '../widgets/complaint_card.dart';
import 'new_complaint_screen.dart';
import 'map_screen.dart';
import 'notification_screen.dart';
import '../services/notification_service.dart';
import 'my_complaints_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  // لیستی شاشەکان بە IndexedStack بۆ پاراستنی دۆخ
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = const [
      FeedPage(),
      NewComplaintScreen(),
      MapScreen(),
      ProfilePage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'فید',
          ),
          NavigationDestination(
            icon: Icon(Icons.add_circle_outline),
            selectedIcon: Icon(Icons.add_circle),
            label: 'سکاڵا',
          ),
          NavigationDestination(
            icon: Icon(Icons.map_outlined),
            selectedIcon: Icon(Icons.map),
            label: 'نەخشە',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'پرۆفایل',
          ),
        ],
      ),
    );
  }
}

// ---- لاپەڕەی فید (Feed Page) ----
class FeedPage extends StatefulWidget {
  const FeedPage({super.key});

  @override
  State<FeedPage> createState() => _FeedPageState();
}

class _FeedPageState extends State<FeedPage> {
  List<ComplaintModel> complaints = [];
  bool isLoading = true;
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);
    try {
      final results = await Future.wait([
        ComplaintService.getAll(),
        NotificationService.getUnreadCount(),
      ]);
      if (mounted) {
        setState(() {
          complaints = results[0] as List<ComplaintModel>;
          _unreadCount = results[1] as int;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
      }
      debugPrint("Error loading data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text(
          "سکاڵاکان",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF1976D2),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black),
            onPressed: _loadData,
          ),
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined,
                    color: Colors.black),
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const NotificationScreen()),
                  );
                  _loadData();
                },
              ),
              if (_unreadCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints:
                        const BoxConstraints(minWidth: 16, minHeight: 16),
                    child: Text(
                      '$_unreadCount',
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : complaints.isEmpty
              ? const Center(child: Text("هیچ سکاڵایەک نییە"))
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: ListView.builder(
                    itemCount: complaints.length,
                    itemBuilder: (ctx, i) {
                      final c = complaints[i];
                      return ComplaintCard(
                        userName: c.userName,
                        userImage: c.userImage ??
                            "https://ui-avatars.com/api/?name=${Uri.encodeComponent(c.userName)}",
                        timeAgo: c.createdAt.length >= 10
                            ? c.createdAt.substring(0, 10)
                            : c.createdAt,
                        content: "${c.title}\n${c.description}",
                        mediaUrl: c.mediaUrl,
                        supportCount: c.supportCount,
                        onSupport: () async {
                          bool success = await ComplaintService.support(c.id);
                          if (success && mounted) _loadData();
                        },
                      );
                    },
                  ),
                ),
    );
  }
}

// ---- لاپەڕەی پرۆفایل (Profile Page) ----
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String name = "";
  String email = "";

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        name = prefs.getString("name") ?? "بەکارهێنەر";
        email = prefs.getString("email") ?? "";
      });
    }
  }

  Future<void> _logout() async {
    await AuthService.logout();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text("پرۆفایل"),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1976D2),
        elevation: 0.5,
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1976D2).withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const CircleAvatar(
              radius: 50,
              backgroundColor: Color(0xFF1976D2),
              child: Icon(Icons.person, size: 50, color: Colors.white),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            name,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1976D2),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            email,
            style: const TextStyle(color: Colors.grey, fontSize: 14),
          ),
          const SizedBox(height: 24),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: ListTile(
              leading: const Icon(Icons.list_alt, color: Color(0xFF1976D2)),
              title: const Text("سکاڵاکانم"),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MyComplaintsScreen()),
              ),
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(20),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _logout,
              child: const Text(
                "دەرچوون",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
