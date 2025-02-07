import 'package:dulimad_diyarid/models/user.dart';
import 'package:dulimad_diyarid/pages/international_flights_page.dart';
import 'package:dulimad_diyarid/pages/local_flights_page.dart';
import 'package:dulimad_diyarid/pages/notifications_page.dart';
import 'package:dulimad_diyarid/pages/profile_page.dart';
import 'package:dulimad_diyarid/pages/settings_page.dart';
import 'package:flutter/material.dart';


class HomePage extends StatefulWidget {
  final User user;

  const HomePage({
    super.key,
    required this.user,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  late TabController _tabController;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    try {
      _tabController = TabController(length: 2, vsync: this);
      _initializePages();
    } catch (e) {
      print('Error initializing home page: $e');
      // Handle initialization error gracefully
      Future.microtask(() {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error loading home page. Please try again.'),
            duration: Duration(seconds: 3),
          ),
        );
      });
    }
  }

  void _initializePages() {
    try {
      _pages = [
        _buildFlightsPage(),
        NotificationsPage(user: widget.user),
        ProfilePage(user: widget.user),
        const SettingsPage(),
      ];
    } catch (e) {
      print('Error initializing pages: $e');
      _pages = [
        const Center(child: Text('Error loading flights')),
        const Center(child: Text('Error loading notifications')),
        const Center(child: Text('Error loading profile')),
        const Center(child: Text('Error loading settings')),
      ];
    }
  }

  Widget _buildFlightsPage() {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Safar Kaab',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'International'),
            Tab(text: 'Local'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          InternationalFlightsPage(user: widget.user),
          LocalFlightsPage(user: widget.user),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.flight),
            label: 'Flights',
          ),
          BottomNavigationBarItem(
            icon: Stack(
              children: [
                const Icon(Icons.notifications),
                if (widget.user.isAdmin)
                  Positioned(
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(1),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 12,
                        minHeight: 12,
                      ),
                      child: const Text(
                        '',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            label: 'Notifications',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
