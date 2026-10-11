import 'package:flutter/material.dart';
import 'api_service.dart';
import 'models.dart';
import 'theme.dart';
import 'add_member_page.dart';

class CommitteeMembersTab extends StatefulWidget {
  const CommitteeMembersTab({super.key});

  @override
  State<CommitteeMembersTab> createState() => _CommitteeMembersTabState();
}

class _CommitteeMembersTabState extends State<CommitteeMembersTab> {
  List<MemberWithFamily> _members = [];
  List<MemberWithFamily> _filtered = [];
  bool _loading = true;
  String _search = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final data = await ApiService.getAllDetails();
      if (mounted) {
        setState(() {
          _members = data;
          _applySearch(_search);
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _applySearch(String q) {
    _search = q;
    _filtered = _members
        .where((m) =>
            m.houseno.toLowerCase().contains(q.toLowerCase()) ||
            m.familyname.toLowerCase().contains(q.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Column(children: [
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: TextField(
            onChanged: (q) => setState(() => _applySearch(q)),
            decoration: InputDecoration(
              hintText: 'Search by house no or family name...',
              prefixIcon: const Icon(Icons.search_rounded,
                  color: AppTheme.textSecondary),
              suffixIcon: _search.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded),
                      onPressed: () => setState(() => _applySearch('')),
                    )
                  : null,
            ),
          ),
        ),
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: _load,
                  child: _filtered.isEmpty
                      ? Center(
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.people_outline_rounded,
                                    size: 72, color: Colors.grey[300]),
                                const SizedBox(height: 16),
                                const Text('No members found',
                                    style: TextStyle(
                                        color: AppTheme.textSecondary,
                                        fontSize: 15)),
                              ]),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemCount: _filtered.length,
                          itemBuilder: (_, i) =>
                              _MemberTile(member: _filtered[i]),
                        ),
                ),
        ),
      ]),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final added = await Navigator.of(context).push<bool>(
            MaterialPageRoute(builder: (_) => const AddMemberPage()),
          );
          if (added == true) _load();
        },
        icon: const Icon(Icons.person_add_rounded),
        label: const Text('Add Family'),
      ),
    );
  }
}

class _MemberTile extends StatelessWidget {
  final MemberWithFamily member;
  const _MemberTile({required this.member});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.home_rounded, color: AppTheme.primary),
          ),
          title: Text(member.familyname,
              style: const TextStyle(
                  fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
          subtitle: Text(
              'House ${member.houseno} · ${member.family.length} member${member.family.length == 1 ? '' : 's'}',
              style: const TextStyle(
                  fontSize: 12, color: AppTheme.textSecondary)),
          childrenPadding: const EdgeInsets.only(bottom: 8),
          children: member.family.isEmpty
              ? [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Text('No family members added.',
                        style: TextStyle(
                            fontSize: 13, color: AppTheme.textSecondary)),
                  )
                ]
              : member.family
                  .map((f) => ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 0),
                        dense: true,
                        leading: CircleAvatar(
                          radius: 18,
                          backgroundColor:
                              AppTheme.accent.withValues(alpha: 0.15),
                          child: Icon(
                            f.gender.toLowerCase() == 'female'
                                ? Icons.face_3_rounded
                                : Icons.face_rounded,
                            color: AppTheme.accent,
                            size: 20,
                          ),
                        ),
                        title: Text(f.name,
                            style: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w500)),
                        subtitle: Text('${f.age} yrs · ${f.gender}',
                            style: const TextStyle(
                                fontSize: 12,
                                color: AppTheme.textSecondary)),
                        trailing: Text(f.contactno,
                            style: const TextStyle(
                                fontSize: 12,
                                color: AppTheme.textSecondary)),
                      ))
                  .toList(),
        ),
      ),
    );
  }
}
