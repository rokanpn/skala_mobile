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

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  String userName = "";
  String userRole = "";

  // لیستی شاشەکان بە IndexedStack بۆ پاراستنی دۆخ
  final List<Widget> _screens = [
    const FeedPage(),
    const NewComplaintScreen(),
    const MapPage(),
    const ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        userName = prefs.getString("name") ?? "بەکارهێنەر";
        userRole = prefs.getString("role") ?? "CITIZEN";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF1976D2),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'فید',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            activeIcon: Icon(Icons.add_circle),
            label: 'سکاڵا',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map_outlined),
            activeIcon: Icon(Icons.map),
            label: 'نەخشە',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
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
        title: const Text("سکاڵاکان",
            style: TextStyle(
                fontWeight: FontWeight.bold, color: Color(0xFF1976D2))),
        backgroundColor: Colors.white,
        elevation: 0.5,
        actions: [
          IconButton(
              icon: const Icon(Icons.refresh, color: Colors.black),
              onPressed: _loadData),
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
                          builder: (_) => const NotificationScreen()));
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
                        color: Colors.red, shape: BoxShape.circle),
                    constraints:
                        const BoxConstraints(minWidth: 16, minHeight: 16),
                    child: Text('$_unreadCount',
                        style:
                            const TextStyle(color: Colors.white, fontSize: 10),
                        textAlign: TextAlign.center),
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

// ---- لاپەڕەی نەخشە (Map Page) ----
class MapPage extends StatelessWidget {
  const MapPage({super.key});
  @override
  Widget build(BuildContext context) => const MapScreen();
}

// ---- لاپەڕەی پرۆفایل (Profile Page) ----
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String name = "", email = "";

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        name = prefs.getString("name") ?? "";
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
      appBar: AppBar(
        title: const Text("پرۆفایل"),
        backgroundColor: Colors.white,
        elevation: 0.5,
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          const CircleAvatar(
            radius: 50,
            child: Icon(Icons.person, size: 50),
          ),
          const SizedBox(height: 10),
          Text(
            name,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Text(email),
          const SizedBox(height: 20),
          ListTile(
            leading: const Icon(Icons.list_alt, color: Color(0xFF1976D2)),
            title: const Text("سکاڵاکانم"),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MyComplaintsScreen()),
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
              ),
              onPressed: _logout,
              child: const Center(child: Text("دەرچوون")),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
