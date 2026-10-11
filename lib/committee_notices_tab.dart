import 'package:flutter/material.dart';
import 'api_service.dart';
import 'models.dart';
import 'theme.dart';
import 'add_notice_page.dart';

class CommitteeNoticesTab extends StatefulWidget {
  final MemberCredential member;
  const CommitteeNoticesTab({super.key, required this.member});

  @override
  State<CommitteeNoticesTab> createState() => _CommitteeNoticesTabState();
}

class _CommitteeNoticesTabState extends State<CommitteeNoticesTab> {
  List<Notice> _notices = [];
  List<Notice> _filtered = [];
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
      final data = await ApiService.getNotices();
      if (mounted) {
        setState(() {
          _notices = data;
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
    _filtered = _notices
        .where((n) =>
            n.head.toLowerCase().contains(q.toLowerCase()) ||
            n.content.toLowerCase().contains(q.toLowerCase()))
        .toList();
  }

  Future<void> _delete(Notice n) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Notice'),
        content: Text('Delete "${n.head}"? This cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppTheme.danger),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      try {
        await ApiService.deleteNotice(n.id!);
        _load();
      } catch (_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Failed to delete'),
              backgroundColor: AppTheme.danger));
        }
      }
    }
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
              hintText: 'Search notices...',
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
                                Icon(Icons.campaign_outlined,
                                    size: 72, color: Colors.grey[300]),
                                const SizedBox(height: 16),
                                const Text('No notices issued yet',
                                    style: TextStyle(
                                        color: AppTheme.textSecondary,
                                        fontSize: 15)),
                              ]),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemCount: _filtered.length,
                          itemBuilder: (_, i) {
                            final n = _filtered[i];
                            return Card(
                              child: Padding(
                                padding: const EdgeInsets.all(14),
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                              color: AppTheme.infoLight,
                                              borderRadius:
                                                  BorderRadius.circular(10)),
                                          child: const Icon(
                                              Icons.campaign_rounded,
                                              color: AppTheme.info,
                                              size: 18),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(n.head,
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                  color:
                                                      AppTheme.textPrimary)),
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                              Icons.delete_rounded,
                                              color: AppTheme.danger,
                                              size: 20),
                                          onPressed: () => _delete(n),
                                          tooltip: 'Delete',
                                        ),
                                      ]),
                                      const SizedBox(height: 8),
                                      Text(n.content,
                                          style: const TextStyle(
                                              color: AppTheme.textSecondary,
                                              fontSize: 13,
                                              height: 1.4)),
                                      const SizedBox(height: 10),
                                      Row(children: [
                                        const Icon(
                                            Icons.calendar_today_rounded,
                                            size: 12,
                                            color: AppTheme.textSecondary),
                                        const SizedBox(width: 4),
                                        Text(n.date,
                                            style: const TextStyle(
                                                fontSize: 11,
                                                color:
                                                    AppTheme.textSecondary)),
                                        const Spacer(),
                                        const Icon(Icons.person_rounded,
                                            size: 12,
                                            color: AppTheme.textSecondary),
                                        const SizedBox(width: 4),
                                        Text(n.issueBy,
                                            style: const TextStyle(
                                                fontSize: 11,
                                                color:
                                                    AppTheme.textSecondary)),
                                      ]),
                                    ]),
                              ),
                            );
                          },
                        ),
                ),
        ),
      ]),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final added = await Navigator.of(context).push<bool>(
            MaterialPageRoute(
              builder: (_) =>
                  AddNoticePage(issuedBy: widget.member.familyname),
            ),
          );
          if (added == true) _load();
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Notice'),
      ),
    );
  }
}
