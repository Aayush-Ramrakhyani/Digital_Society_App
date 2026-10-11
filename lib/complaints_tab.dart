import 'package:flutter/material.dart';
import 'api_service.dart';
import 'models.dart';
import 'theme.dart';

class ComplaintsTab extends StatefulWidget {
  final String houseno;
  const ComplaintsTab({super.key, required this.houseno});

  @override
  State<ComplaintsTab> createState() => ComplaintsTabState();
}

class ComplaintsTabState extends State<ComplaintsTab> {
  List<Complaint> _complaints = [];
  List<Complaint> _filtered = [];
  bool _loading = true;
  String _search = '';
  String _statusFilter = 'All';

  static const _statuses = ['All', 'Pending', 'In Progress', 'Resolved'];

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    setState(() => _loading = true);
    try {
      final data = await ApiService.getMemberComplaints(widget.houseno);
      if (mounted) {
        setState(() {
          _complaints = data;
          _applyFilter();
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _applyFilter() {
    _filtered = _complaints.where((c) {
      final matchSearch = _search.isEmpty ||
          c.title.toLowerCase().contains(_search.toLowerCase()) ||
          c.description.toLowerCase().contains(_search.toLowerCase());
      final matchStatus =
          _statusFilter == 'All' || c.status == _statusFilter;
      return matchSearch && matchStatus;
    }).toList();
  }

  Color _statusColor(String s) {
    switch (s) {
      case 'Resolved': return AppTheme.success;
      case 'In Progress': return AppTheme.warning;
      default: return AppTheme.danger;
    }
  }

  Color _statusBg(String s) {
    switch (s) {
      case 'Resolved': return AppTheme.successLight;
      case 'In Progress': return AppTheme.warningLight;
      default: return AppTheme.dangerLight;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Container(
        color: Colors.white,
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        child: Column(children: [
          TextField(
            onChanged: (q) => setState(() { _search = q; _applyFilter(); }),
            decoration: const InputDecoration(
              hintText: 'Search complaints...',
              prefixIcon: Icon(Icons.search_rounded, color: AppTheme.textSecondary),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 34,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _statuses.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final s = _statuses[i];
                final sel = _statusFilter == s;
                return FilterChip(
                  label: Text(s),
                  selected: sel,
                  onSelected: (_) => setState(() { _statusFilter = s; _applyFilter(); }),
                  selectedColor: AppTheme.primary.withValues(alpha: 0.15),
                  checkmarkColor: AppTheme.primary,
                  labelStyle: TextStyle(
                    fontSize: 12,
                    color: sel ? AppTheme.primary : AppTheme.textSecondary,
                    fontWeight: sel ? FontWeight.w600 : FontWeight.normal,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 10),
        ]),
      ),
      Expanded(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: load,
                child: _filtered.isEmpty
                    ? _emptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: _filtered.length,
                        itemBuilder: (_, i) => _ComplaintCard(
                          complaint: _filtered[i],
                          statusColor: _statusColor(_filtered[i].status),
                          statusBg: _statusBg(_filtered[i].status),
                        ),
                      ),
              ),
      ),
    ]);
  }

  Widget _emptyState() => ListView(children: [
        SizedBox(
          height: 380,
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.inbox_rounded, size: 72, color: Colors.grey[300]),
            const SizedBox(height: 16),
            const Text('No complaints filed yet',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 15)),
            const SizedBox(height: 6),
            const Text('Tap + below to file one',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
          ]),
        ),
      ]);
}

class _ComplaintCard extends StatelessWidget {
  final Complaint complaint;
  final Color statusColor;
  final Color statusBg;
  const _ComplaintCard(
      {required this.complaint,
      required this.statusColor,
      required this.statusBg});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child:
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(
              child: Text(complaint.title,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: AppTheme.textPrimary)),
            ),
            const SizedBox(width: 8),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(20)),
              child: Text(complaint.status,
                  style: TextStyle(
                      color: statusColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w600)),
            ),
          ]),
          const SizedBox(height: 8),
          Text(complaint.description,
              style: const TextStyle(
                  color: AppTheme.textSecondary, fontSize: 13, height: 1.4),
              maxLines: 3,
              overflow: TextOverflow.ellipsis),
          const SizedBox(height: 10),
          Row(children: [
            const Icon(Icons.calendar_today_rounded,
                size: 13, color: AppTheme.textSecondary),
            const SizedBox(width: 4),
            Text(complaint.date,
                style: const TextStyle(
                    fontSize: 12, color: AppTheme.textSecondary)),
          ]),
          if (complaint.action != null &&
              complaint.action!.isNotEmpty) ...[
            const Divider(height: 18, color: AppTheme.divider),
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Icon(Icons.engineering_rounded,
                  size: 16, color: AppTheme.info),
              const SizedBox(width: 6),
              Expanded(
                child: Text('Action: ${complaint.action}',
                    style: const TextStyle(
                        fontSize: 13, color: AppTheme.info)),
              ),
            ]),
          ],
          if (complaint.feedback != null &&
              complaint.feedback!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Icon(Icons.feedback_rounded,
                  size: 16, color: AppTheme.success),
              const SizedBox(width: 6),
              Expanded(
                child: Text('Feedback: ${complaint.feedback}',
                    style: const TextStyle(
                        fontSize: 13, color: AppTheme.success)),
              ),
            ]),
          ],
        ]),
      ),
    );
  }
}
