import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'api_service.dart';
import 'models.dart';
import 'theme.dart';

class CommitteeComplaintsTab extends StatefulWidget {
  const CommitteeComplaintsTab({super.key});

  @override
  State<CommitteeComplaintsTab> createState() =>
      _CommitteeComplaintsTabState();
}

class _CommitteeComplaintsTabState extends State<CommitteeComplaintsTab> {
  List<Complaint> _complaints = [];
  List<Complaint> _filtered = [];
  bool _loading = true;
  String _search = '';
  String _statusFilter = 'All';

  static const _statuses = ['All', 'Pending', 'In Progress', 'Resolved'];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final data = await ApiService.getComplaints();
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
          c.houseno.toLowerCase().contains(_search.toLowerCase());
      final matchStatus =
          _statusFilter == 'All' || c.status == _statusFilter;
      return matchSearch && matchStatus;
    }).toList();
  }

  Color _statusColor(String s) {
    switch (s) {
      case 'Resolved':
        return AppTheme.success;
      case 'In Progress':
        return AppTheme.warning;
      default:
        return AppTheme.danger;
    }
  }

  Color _statusBg(String s) {
    switch (s) {
      case 'Resolved':
        return AppTheme.successLight;
      case 'In Progress':
        return AppTheme.warningLight;
      default:
        return AppTheme.dangerLight;
    }
  }

  void _openUpdate(Complaint c) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _UpdateSheet(complaint: c, onSaved: _load),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Container(
        color: Colors.white,
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        child: Column(children: [
          TextField(
            onChanged: (q) =>
                setState(() {
                  _search = q;
                  _applyFilter();
                }),
            decoration: const InputDecoration(
              hintText: 'Search complaint or house no...',
              prefixIcon:
                  Icon(Icons.search_rounded, color: AppTheme.textSecondary),
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
                  onSelected: (_) => setState(() {
                    _statusFilter = s;
                    _applyFilter();
                  }),
                  selectedColor: AppTheme.primary.withValues(alpha: 0.15),
                  checkmarkColor: AppTheme.primary,
                  labelStyle: TextStyle(
                    fontSize: 12,
                    color: sel ? AppTheme.primary : AppTheme.textSecondary,
                    fontWeight:
                        sel ? FontWeight.w600 : FontWeight.normal,
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
                onRefresh: _load,
                child: _filtered.isEmpty
                    ? Center(
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.inbox_rounded,
                                  size: 72, color: Colors.grey[300]),
                              const SizedBox(height: 16),
                              const Text('No complaints found',
                                  style: TextStyle(
                                      color: AppTheme.textSecondary,
                                      fontSize: 15)),
                            ]),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: _filtered.length,
                        itemBuilder: (_, i) {
                          final c = _filtered[i];
                          return Card(
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () => _openUpdate(c),
                              child: Padding(
                                padding: const EdgeInsets.all(14),
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: AppTheme.primary
                                                .withValues(alpha: 0.1),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Text('House ${c.houseno}',
                                              style: const TextStyle(
                                                  color: AppTheme.primary,
                                                  fontSize: 11,
                                                  fontWeight:
                                                      FontWeight.w600)),
                                        ),
                                        const Spacer(),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                              color: _statusBg(c.status),
                                              borderRadius:
                                                  BorderRadius.circular(20)),
                                          child: Text(c.status,
                                              style: TextStyle(
                                                  color:
                                                      _statusColor(c.status),
                                                  fontSize: 11,
                                                  fontWeight:
                                                      FontWeight.w600)),
                                        ),
                                      ]),
                                      const SizedBox(height: 8),
                                      Text(c.title,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                              color: AppTheme.textPrimary)),
                                      const SizedBox(height: 4),
                                      Text(c.description,
                                          style: const TextStyle(
                                              color: AppTheme.textSecondary,
                                              fontSize: 13,
                                              height: 1.3),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis),
                                      const SizedBox(height: 8),
                                      Row(children: [
                                        const Icon(
                                            Icons.calendar_today_rounded,
                                            size: 12,
                                            color: AppTheme.textSecondary),
                                        const SizedBox(width: 4),
                                        Text(c.date,
                                            style: const TextStyle(
                                                fontSize: 11,
                                                color:
                                                    AppTheme.textSecondary)),
                                        const Spacer(),
                                        const Text('Tap to update',
                                            style: TextStyle(
                                                fontSize: 11,
                                                color: AppTheme.primary)),
                                        const Icon(
                                            Icons.chevron_right_rounded,
                                            size: 14,
                                            color: AppTheme.primary),
                                      ]),
                                    ]),
                              ),
                            ),
                          );
                        },
                      ),
              ),
      ),
    ]);
  }
}

class _UpdateSheet extends StatefulWidget {
  final Complaint complaint;
  final VoidCallback onSaved;
  const _UpdateSheet({required this.complaint, required this.onSaved});

  @override
  State<_UpdateSheet> createState() => _UpdateSheetState();
}

class _UpdateSheetState extends State<_UpdateSheet> {
  late String _status;
  final _actionCtrl = TextEditingController();
  final _feedbackCtrl = TextEditingController();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _status = widget.complaint.status;
    _actionCtrl.text = widget.complaint.action ?? '';
    _feedbackCtrl.text = widget.complaint.feedback ?? '';
  }

  @override
  void dispose() {
    _actionCtrl.dispose();
    _feedbackCtrl.dispose();
    super.dispose();
  }

  Color _chipColor(String s) {
    switch (s) {
      case 'Resolved': return AppTheme.successLight;
      case 'In Progress': return AppTheme.warningLight;
      default: return AppTheme.dangerLight;
    }
  }

  Color _chipTextColor(String s) {
    switch (s) {
      case 'Resolved': return AppTheme.success;
      case 'In Progress': return AppTheme.warning;
      default: return AppTheme.danger;
    }
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      final finishDate = _status == 'Resolved'
          ? DateFormat('yyyy-MM-dd').format(DateTime.now())
          : null;
      await ApiService.updateComplaint(widget.complaint.id!, {
        'status': _status,
        'action': _actionCtrl.text.trim().isEmpty
            ? null
            : _actionCtrl.text.trim(),
        'feedback': _feedbackCtrl.text.trim().isEmpty
            ? null
            : _feedbackCtrl.text.trim(),
        'finish_date': finishDate,
      });
      if (!mounted) return;
      Navigator.of(context).pop();
      widget.onSaved();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Complaint updated successfully!'),
        backgroundColor: AppTheme.success,
      ));
    } catch (e) {
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e'), backgroundColor: AppTheme.danger));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
          20, 16, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      child: SingleChildScrollView(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 18),
          const Text('Update Complaint',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary)),
          const SizedBox(height: 2),
          Text(widget.complaint.title,
              style: const TextStyle(
                  color: AppTheme.textSecondary, fontSize: 13)),
          const SizedBox(height: 18),
          const Text('Status',
              style: TextStyle(
                  fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: ['Pending', 'In Progress', 'Resolved'].map((s) {
              final sel = _status == s;
              return ChoiceChip(
                label: Text(s),
                selected: sel,
                onSelected: (_) => setState(() => _status = s),
                selectedColor: _chipColor(s),
                labelStyle: TextStyle(
                  color: sel ? _chipTextColor(s) : AppTheme.textSecondary,
                  fontWeight:
                      sel ? FontWeight.w600 : FontWeight.normal,
                  fontSize: 12,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _actionCtrl,
            maxLines: 2,
            decoration: const InputDecoration(
              labelText: 'Action Taken',
              hintText: 'What action was taken to resolve this?',
              prefixIcon:
                  Icon(Icons.engineering_rounded, color: AppTheme.primary),
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _feedbackCtrl,
            maxLines: 2,
            decoration: const InputDecoration(
              labelText: 'Feedback / Remarks',
              hintText: 'Any message for the resident...',
              prefixIcon:
                  Icon(Icons.feedback_rounded, color: AppTheme.primary),
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 22),
          Row(children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Cancel'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : const Text('Save Changes'),
              ),
            ),
          ]),
        ]),
      ),
    );
  }
}
