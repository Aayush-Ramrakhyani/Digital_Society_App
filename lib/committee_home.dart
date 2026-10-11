import 'package:flutter/material.dart';
import 'models.dart';
import 'theme.dart';
import 'committee_dashboard_tab.dart';
import 'committee_members_tab.dart';
import 'committee_complaints_tab.dart';
import 'committee_notices_tab.dart';
import 'committee_maintenance_tab.dart';
import 'login_page.dart';

class CommitteeHome extends StatefulWidget {
  final MemberCredential member;
  const CommitteeHome({super.key, required this.member});

  @override
  State<CommitteeHome> createState() => _CommitteeHomeState();
}

class _CommitteeHomeState extends State<CommitteeHome> {
  int _idx = 0;

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
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  widget.member.role.toUpperCase(),
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.8),
                ),
              ),
            ),
          ),
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
          CommitteeDashboardTab(member: widget.member),
          const CommitteeMembersTab(),
          const CommitteeComplaintsTab(),
          CommitteeNoticesTab(member: widget.member),
          const CommitteeMaintenanceTab(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _idx,
        onDestinationSelected: (i) => setState(() => _idx = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard_rounded),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline_rounded),
            selectedIcon: Icon(Icons.people_rounded),
            label: 'Members',
          ),
          NavigationDestination(
            icon: Icon(Icons.report_problem_outlined),
            selectedIcon: Icon(Icons.report_problem_rounded),
            label: 'Complaints',
          ),
          NavigationDestination(
            icon: Icon(Icons.campaign_outlined),
            selectedIcon: Icon(Icons.campaign_rounded),
            label: 'Notices',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_balance_wallet_outlined),
            selectedIcon: Icon(Icons.account_balance_wallet_rounded),
            label: 'Fees',
          ),
        ],
      ),
    );
  }
}
