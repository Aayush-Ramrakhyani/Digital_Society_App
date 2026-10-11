import 'package:flutter/material.dart';
import 'api_service.dart';
import 'models.dart';
import 'theme.dart';

class NoticesTab extends StatefulWidget {
  const NoticesTab({super.key});

  @override
  State<NoticesTab> createState() => _NoticesTabState();
}

class _NoticesTabState extends State<NoticesTab> {
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

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Container(
        color: Colors.white,
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: TextField(
          onChanged: (q) => setState(() => _applySearch(q)),
          decoration: InputDecoration(
            hintText: 'Search notices...',
            prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.textSecondary),
            suffixIcon: _search.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear_rounded),
                    onPressed: () => setState(() { _applySearch(''); }),
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
                    ? _emptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: _filtered.length,
                        itemBuilder: (_, i) => _NoticeCard(notice: _filtered[i]),
                      ),
              ),
      ),
    ]);
  }

  Widget _emptyState() => ListView(children: [
        SizedBox(
          height: 400,
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.notifications_off_rounded, size: 72, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              _search.isNotEmpty ? 'No notices match your search' : 'No notices yet',
              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 15),
            ),
          ]),
        ),
      ]);
}

class _NoticeCard extends StatelessWidget {
  final Notice notice;
  const _NoticeCard({required this.notice});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                  color: AppTheme.infoLight, borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.campaign_rounded, color: AppTheme.info, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                notice.head,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.textPrimary),
              ),
            ),
          ]),
          const SizedBox(height: 12),
          Text(notice.content,
              style: const TextStyle(
                  color: AppTheme.textSecondary, fontSize: 14, height: 1.45)),
          const SizedBox(height: 12),
          const Divider(height: 1, color: AppTheme.divider),
          const SizedBox(height: 10),
          Row(children: [
            const Icon(Icons.calendar_today_rounded, size: 13, color: AppTheme.textSecondary),
            const SizedBox(width: 4),
            Text(notice.date,
                style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
            const Spacer(),
            const Icon(Icons.person_rounded, size: 13, color: AppTheme.textSecondary),
            const SizedBox(width: 4),
            Text(notice.issueBy,
                style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
          ]),
        ]),
      ),
    );
  }
}
