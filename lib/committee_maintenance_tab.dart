import 'package:flutter/material.dart';
import 'api_service.dart';
import 'models.dart';
import 'theme.dart';

class CommitteeMaintenanceTab extends StatefulWidget {
  const CommitteeMaintenanceTab({super.key});

  @override
  State<CommitteeMaintenanceTab> createState() =>
      _CommitteeMaintenanceTabState();
}

class _CommitteeMaintenanceTabState extends State<CommitteeMaintenanceTab> {
  List<Maintenance> _records = [];
  List<Maintenance> _filtered = [];
  bool _loading = true;
  String _search = '';
  String _statusFilter = 'All';

  static const _months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final data = await ApiService.getMaintenance();
      if (mounted) {
        setState(() {
          _records = data;
          _applyFilter();
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _applyFilter() {
    _filtered = _records.where((m) {
      final matchSearch = _search.isEmpty ||
          m.houseno.toLowerCase().contains(_search.toLowerCase()) ||
          (m.familyname ?? '').toLowerCase().contains(_search.toLowerCase());
      final matchStatus =
          _statusFilter == 'All' || m.status == _statusFilter;
      return matchSearch && matchStatus;
    }).toList();
  }

  Future<void> _markPaid(Maintenance m) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Mark as Paid'),
        content: Text(
            'Mark ${m.houseno} maintenance for ${m.month} ${m.year} as paid?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Confirm')),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      final now = DateTime.now();
      final date =
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      await ApiService.updateMaintenance(m.id!, {
        'status': 'Paid',
        'paid_date': date,
        'transaction_id': null,
      });
      _load();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Marked as paid!'),
            backgroundColor: AppTheme.success));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed: $e'), backgroundColor: AppTheme.danger));
      }
    }
  }

  void _showAddSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddMaintenanceSheet(
        months: _months,
        onAdded: _load,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pending = _records.where((m) => m.status == 'Pending').length;
    final paid = _records.where((m) => m.status == 'Paid').length;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Column(children: [
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Column(children: [
            Row(children: [
              _SummaryPill(
                  label: 'Pending',
                  count: pending,
                  color: AppTheme.danger,
                  bg: AppTheme.dangerLight),
              const SizedBox(width: 8),
              _SummaryPill(
                  label: 'Paid',
                  count: paid,
                  color: AppTheme.success,
                  bg: AppTheme.successLight),
            ]),
            const SizedBox(height: 10),
            TextField(
              onChanged: (q) => setState(() {
                _search = q;
                _applyFilter();
              }),
              decoration: const InputDecoration(
                hintText: 'Search by house or family...',
                prefixIcon: Icon(Icons.search_rounded,
                    color: AppTheme.textSecondary),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 34,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: 3,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final s = ['All', 'Pending', 'Paid'][i];
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
                      color:
                          sel ? AppTheme.primary : AppTheme.textSecondary,
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
                                Icon(
                                    Icons
                                        .account_balance_wallet_outlined,
                                    size: 72,
                                    color: Colors.grey[300]),
                                const SizedBox(height: 16),
                                const Text('No maintenance records',
                                    style: TextStyle(
                                        color: AppTheme.textSecondary,
                                        fontSize: 15)),
                              ]),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemCount: _filtered.length,
                          itemBuilder: (_, i) {
                            final m = _filtered[i];
                            final isPaid = m.status == 'Paid';
                            return Card(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 12),
                                child: Row(children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: isPaid
                                          ? AppTheme.successLight
                                          : AppTheme.dangerLight,
                                      borderRadius:
                                          BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      isPaid
                                          ? Icons.check_circle_rounded
                                          : Icons.pending_rounded,
                                      color: isPaid
                                          ? AppTheme.success
                                          : AppTheme.danger,
                                      size: 22,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                              '${m.familyname ?? m.houseno} · ${m.houseno}',
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 13,
                                                  color:
                                                      AppTheme.textPrimary)),
                                          Text(
                                              '${m.month} ${m.year} · ₹${m.amount.toStringAsFixed(0)}',
                                              style: const TextStyle(
                                                  fontSize: 12,
                                                  color:
                                                      AppTheme.textSecondary)),
                                          if (isPaid && m.paidDate != null)
                                            Text('Paid on ${m.paidDate}',
                                                style: const TextStyle(
                                                    fontSize: 11,
                                                    color:
                                                        AppTheme.success)),
                                        ]),
                                  ),
                                  if (!isPaid)
                                    TextButton(
                                      onPressed: () => _markPaid(m),
                                      style: TextButton.styleFrom(
                                        foregroundColor: AppTheme.success,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10),
                                      ),
                                      child: const Text('Mark Paid',
                                          style: TextStyle(fontSize: 12)),
                                    )
                                  else
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                          color: AppTheme.successLight,
                                          borderRadius:
                                              BorderRadius.circular(20)),
                                      child: const Text('PAID',
                                          style: TextStyle(
                                              color: AppTheme.success,
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold)),
                                    ),
                                ]),
                              ),
                            );
                          },
                        ),
                ),
        ),
      ]),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddSheet,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Record'),
      ),
    );
  }
}

class _SummaryPill extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  final Color bg;
  const _SummaryPill(
      {required this.label,
      required this.count,
      required this.color,
      required this.bg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Text('$count',
            style: TextStyle(
                color: color, fontWeight: FontWeight.bold, fontSize: 15)),
        const SizedBox(width: 5),
        Text(label, style: TextStyle(color: color, fontSize: 12)),
      ]),
    );
  }
}

class _AddMaintenanceSheet extends StatefulWidget {
  final List<String> months;
  final VoidCallback onAdded;
  const _AddMaintenanceSheet(
      {required this.months, required this.onAdded});

  @override
  State<_AddMaintenanceSheet> createState() => _AddMaintenanceSheetState();
}

class _AddMaintenanceSheetState extends State<_AddMaintenanceSheet> {
  final _houseCtrl = TextEditingController();
  final _amountCtrl = TextEditingController(text: '1500');
  late String _month;
  late String _year;
  bool _saving = false;
  List<MemberWithFamily> _members = [];

  @override
  void initState() {
    super.initState();
    _month = widget.months[DateTime.now().month - 1];
    _year = DateTime.now().year.toString();
    _loadMembers();
  }

  Future<void> _loadMembers() async {
    try {
      final data = await ApiService.getAllDetails();
      if (mounted) setState(() => _members = data);
    } catch (_) {}
  }

  @override
  void dispose() {
    _houseCtrl.dispose();
    _amountCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_houseCtrl.text.trim().isEmpty || _amountCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill all fields')));
      return;
    }
    setState(() => _saving = true);
    try {
      await ApiService.addMaintenance({
        'houseno': _houseCtrl.text.trim().toUpperCase(),
        'month': _month,
        'year': _year,
        'amount': double.tryParse(_amountCtrl.text.trim()) ?? 1500,
      });
      if (!mounted) return;
      Navigator.of(context).pop();
      widget.onAdded();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Record added!'), backgroundColor: AppTheme.success));
    } catch (e) {
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e'), backgroundColor: AppTheme.danger));
    }
  }

  @override
  Widget build(BuildContext context) {
    final years = [
      '${DateTime.now().year - 1}',
      '${DateTime.now().year}',
      '${DateTime.now().year + 1}',
    ];

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
          const Text('Add Maintenance Record',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary)),
          const SizedBox(height: 18),
          Autocomplete<MemberWithFamily>(
            optionsBuilder: (val) {
              if (val.text.isEmpty) return const Iterable.empty();
              return _members.where((m) =>
                  m.houseno.toLowerCase().contains(val.text.toLowerCase()) ||
                  m.familyname
                      .toLowerCase()
                      .contains(val.text.toLowerCase()));
            },
            displayStringForOption: (m) => '${m.houseno} – ${m.familyname}',
            onSelected: (m) => _houseCtrl.text = m.houseno,
            fieldViewBuilder: (_, ctrl, focus, __) => TextField(
              controller: ctrl,
              focusNode: focus,
              textCapitalization: TextCapitalization.characters,
              onChanged: (v) => _houseCtrl.text = v,
              decoration: const InputDecoration(
                labelText: 'House Number',
                prefixIcon:
                    Icon(Icons.home_rounded, color: AppTheme.primary),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(
              child: InputDecorator(
                decoration: const InputDecoration(
                    labelText: 'Month', isDense: true),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _month,
                    isDense: true,
                    items: widget.months
                        .map((m) => DropdownMenuItem(
                            value: m,
                            child: Text(m,
                                style: const TextStyle(fontSize: 13))))
                        .toList(),
                    onChanged: (v) => setState(() => _month = v!),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: InputDecorator(
                decoration: const InputDecoration(
                    labelText: 'Year', isDense: true),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _year,
                    isDense: true,
                    items: years
                        .map((y) =>
                            DropdownMenuItem(value: y, child: Text(y)))
                        .toList(),
                    onChanged: (v) => setState(() => _year = v!),
                  ),
                ),
              ),
            ),
          ]),
          const SizedBox(height: 12),
          TextField(
            controller: _amountCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Amount (₹)',
              prefixIcon: Icon(Icons.currency_rupee_rounded,
                  color: AppTheme.primary),
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
                    : const Text('Add Record'),
              ),
            ),
          ]),
        ]),
      ),
    );
  }
}
