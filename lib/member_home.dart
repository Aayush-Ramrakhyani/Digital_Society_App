import 'package:flutter/material.dart';
import 'models.dart';
import 'theme.dart';
import 'notices_tab.dart';
import 'complaints_tab.dart';
import 'profile_tab.dart';
import 'add_complaint_page.dart';
import 'login_page.dart';

class MemberHome extends StatefulWidget {
  final MemberCredential member;
  const MemberHome({super.key, required this.member});

  @override
  State<MemberHome> createState() => _MemberHomeState();
}

class _MemberHomeState extends State<MemberHome> {
  int _idx = 0;
  final _complaintsKey = GlobalKey<ComplaintsTabState>();

  void _logout() {
    Navigator.of(context).pushAndRemoveUntil(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const LoginPage(),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 400),
      ),
      (_) => false,
    );
  }

  Future<void> _openAddComplaint() async {
    final added = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => AddComplaintPage(houseno: widget.member.houseno),
      ),
    );
    if (added == true) {
      _complaintsKey.currentState?.load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(decoration: headerGradient),
        title: const Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.apartment_rounded, color: Colors.white, size: 22),
          SizedBox(width: 8),
          Text('Griha'),
        ]),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.white),
            tooltip: 'Logout',
            onPressed: _logout,
          ),
        ],
      ),
      body: IndexedStack(
        index: _idx,
        children: [
          const NoticesTab(),
          ComplaintsTab(key: _complaintsKey, houseno: widget.member.houseno),
          ProfileTab(member: widget.member),
        ],
      ),
      floatingActionButton: _idx == 1
          ? FloatingActionButton(
              onPressed: _openAddComplaint,
              tooltip: 'File a complaint',
              child: const Icon(Icons.add_rounded),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _idx,
        onDestinationSelected: (i) => setState(() => _idx = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.notifications_none_rounded),
            selectedIcon: Icon(Icons.notifications_rounded),
            label: 'Notices',
          ),
          NavigationDestination(
            icon: Icon(Icons.report_problem_outlined),
            selectedIcon: Icon(Icons.report_problem_rounded),
            label: 'Complaints',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
