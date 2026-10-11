import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'api_service.dart';
import 'models.dart';
import 'theme.dart';

class ProfileTab extends StatefulWidget {
  final MemberCredential member;
  const ProfileTab({super.key, required this.member});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  List<FamilyMember> _family = [];
  List<Maintenance> _maintenance = [];
  bool _loadingFamily = true;
  bool _loadingMaint = true;

  @override
  void initState() {
    super.initState();
    _loadFamily();
    _loadMaintenance();
  }

  Future<void> _loadFamily() async {
    try {
      final all = await ApiService.getAllDetails();
      final mine =
          all.where((m) => m.houseno == widget.member.houseno).toList();
      if (mounted) {
        setState(() {
          _family = mine.isNotEmpty ? mine.first.family : [];
          _loadingFamily = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loadingFamily = false);
    }
  }

  Future<void> _loadMaintenance() async {
    try {
      final data =
          await ApiService.getMemberMaintenance(widget.member.houseno);
      if (mounted) setState(() { _maintenance = data; _loadingMaint = false; });
    } catch (_) {
      if (mounted) setState(() => _loadingMaint = false);
    }
  }

  Future<void> _reload() async {
    setState(() { _loadingFamily = true; _loadingMaint = true; });
    await Future.wait([_loadFamily(), _loadMaintenance()]);
  }

  Future<void> _payUPI(Maintenance m) async {
    // Replace societyupi@okaxis with the actual society UPI ID
    const upiId = 'societyupi@okaxis';
    final amount = m.amount.toStringAsFixed(0);
    final note = Uri.encodeComponent('Maintenance ${m.month} ${m.year}');
    final uri = Uri.parse(
        'upi://pay?pa=$upiId&pn=Digital+Society&am=$amount&cu=INR&tn=$note');

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (!mounted) return;
      _showPaymentDetails(m);
    }
  }

  void _showPaymentDetails(Maintenance m) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(
                color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(height: 20),
          const Icon(Icons.account_balance_rounded, color: AppTheme.primary, size: 48),
          const SizedBox(height: 12),
          const Text('Society Bank Details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
          const SizedBox(height: 16),
          _InfoRow(label: 'Amount', value: '₹ ${m.amount.toStringAsFixed(0)}'),
          _InfoRow(label: 'For', value: '${m.month} ${m.year}'),
          _InfoRow(label: 'UPI ID', value: 'societyupi@okaxis'),
          const _InfoRow(label: 'Account Name', value: 'Griha Society'),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.warningLight, borderRadius: BorderRadius.circular(12)),
            child: const Row(children: [
              Icon(Icons.info_rounded, color: AppTheme.warning, size: 18),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                    'After paying, please inform the secretary with your transaction ID.',
                    style: TextStyle(fontSize: 12, color: AppTheme.warning, height: 1.4)),
              ),
            ]),
          ),
          const SizedBox(height: 16),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _reload,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Profile hero card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.primaryDark, AppTheme.primaryLight],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primary.withValues(alpha: 0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.home_rounded, color: Colors.white, size: 36),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(widget.member.familyname,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('House No: ${widget.member.houseno}',
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontSize: 14)),
                  const SizedBox(height: 2),
                  Text('${_family.length} family member${_family.length == 1 ? '' : 's'}',
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 12)),
                ]),
              ),
            ]),
          ),
          const SizedBox(height: 24),

          // Family members section
          _SectionHeader(title: 'Family Members', icon: Icons.family_restroom_rounded),
          const SizedBox(height: 10),
          if (_loadingFamily)
            const Center(
                child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()))
          else if (_family.isEmpty)
            _EmptyCard(message: 'No family members added yet.')
          else
            ..._family.map((f) => _FamilyCard(member: f)),

          const SizedBox(height: 24),

          // Maintenance section
          _SectionHeader(
              title: 'Maintenance Dues',
              icon: Icons.account_balance_wallet_rounded),
          const SizedBox(height: 10),
          if (_loadingMaint)
            const Center(
                child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()))
          else if (_maintenance.isEmpty)
            _EmptyCard(message: 'No maintenance records yet. Contact the committee.')
          else
            ..._maintenance.map((m) => _MaintenanceCard(
                  m: m,
                  onPay: m.status == 'Pending' ? () => _payUPI(m) : null,
                )),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  const _SectionHeader({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) => Row(children: [
        Icon(icon, color: AppTheme.primary, size: 20),
        const SizedBox(width: 8),
        Text(title,
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary)),
      ]);
}

class _EmptyCard extends StatelessWidget {
  final String message;
  const _EmptyCard({required this.message});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.divider),
        ),
        child: Text(message,
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
      );
}

class _FamilyCard extends StatelessWidget {
  final FamilyMember member;
  const _FamilyCard({required this.member});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Row(children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: AppTheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            member.gender.toLowerCase() == 'female'
                ? Icons.face_3_rounded
                : Icons.face_rounded,
            color: AppTheme.primary,
            size: 26,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(member.name,
                style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: AppTheme.textPrimary)),
            const SizedBox(height: 2),
            Text('${member.age} yrs · ${member.gender}',
                style: const TextStyle(
                    fontSize: 12, color: AppTheme.textSecondary)),
          ]),
        ),
        if (member.contactno.isNotEmpty)
          Text(member.contactno,
              style: const TextStyle(
                  fontSize: 12, color: AppTheme.textSecondary)),
      ]),
    );
  }
}

class _MaintenanceCard extends StatelessWidget {
  final Maintenance m;
  final VoidCallback? onPay;
  const _MaintenanceCard({required this.m, this.onPay});

  @override
  Widget build(BuildContext context) {
    final isPaid = m.status == 'Paid';
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: isPaid ? AppTheme.successLight : AppTheme.dangerLight,
            width: 1.5),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(9),
          decoration: BoxDecoration(
            color: isPaid ? AppTheme.successLight : AppTheme.dangerLight,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            isPaid ? Icons.check_circle_rounded : Icons.pending_rounded,
            color: isPaid ? AppTheme.success : AppTheme.danger,
            size: 22,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('${m.month} ${m.year}',
                style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: AppTheme.textPrimary)),
            Text('₹ ${m.amount.toStringAsFixed(0)}',
                style: const TextStyle(
                    fontSize: 13, color: AppTheme.textSecondary)),
          ]),
        ),
        if (!isPaid && onPay != null)
          ElevatedButton.icon(
            onPressed: onPay,
            icon: const Icon(Icons.payment_rounded, size: 15),
            label: const Text('Pay', style: TextStyle(fontSize: 12)),
            style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                minimumSize: Size.zero),
          )
        else if (isPaid)
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                  color: AppTheme.successLight,
                  borderRadius: BorderRadius.circular(20)),
              child: const Text('PAID',
                  style: TextStyle(
                      color: AppTheme.success,
                      fontSize: 11,
                      fontWeight: FontWeight.bold)),
            ),
            if (m.paidDate != null)
              Text(m.paidDate!,
                  style: const TextStyle(
                      fontSize: 10, color: AppTheme.textSecondary)),
          ]),
      ]),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(children: [
          Text(label,
              style: const TextStyle(
                  color: AppTheme.textSecondary, fontSize: 13)),
          const Spacer(),
          Text(value,
              style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                  fontSize: 13)),
        ]),
      );
}
