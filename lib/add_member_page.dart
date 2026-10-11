import 'package:flutter/material.dart';
import 'api_service.dart';
import 'theme.dart';

class AddMemberPage extends StatefulWidget {
  const AddMemberPage({super.key});

  @override
  State<AddMemberPage> createState() => _AddMemberPageState();
}

class _AddMemberPageState extends State<AddMemberPage> {
  final _houseCtrl = TextEditingController();
  final _familyCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _saving = false;
  int _step = 0;
  String _houseno = '';
  final List<_FamilyForm> _forms = [];

  @override
  void dispose() {
    _houseCtrl.dispose();
    _familyCtrl.dispose();
    _passCtrl.dispose();
    for (final f in _forms) { f.dispose(); }
    super.dispose();
  }

  Future<void> _submitHouse() async {
    final houseno = _houseCtrl.text.trim().toUpperCase();
    final family = _familyCtrl.text.trim();
    final pass = _passCtrl.text.trim();
    if (houseno.isEmpty || family.isEmpty || pass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill in all fields')));
      return;
    }
    setState(() => _saving = true);
    try {
      await ApiService.addMember({
        'houseno': houseno,
        'familyname': family,
        'totalmembers': 0,
        'password': pass,
      });
      setState(() {
        _houseno = houseno;
        _step = 1;
        _saving = false;
        _forms.add(_FamilyForm());
      });
    } catch (e) {
      setState(() => _saving = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$e'), backgroundColor: AppTheme.danger));
      }
    }
  }

  Future<void> _submitMembers() async {
    setState(() => _saving = true);
    int added = 0;
    for (final f in _forms) {
      if (f.name.text.trim().isEmpty) continue;
      try {
        await ApiService.addFamilyMember({
          'houseno': _houseno,
          'name': f.name.text.trim(),
          'contactno': f.contact.text.trim(),
          'age': f.age.text.trim(),
          'gender': f.gender,
        });
        added++;
      } catch (_) {}
    }
    setState(() => _saving = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(added > 0
            ? 'Family added with $added member${added == 1 ? '' : 's'}!'
            : 'House added. No members added.'),
        backgroundColor: AppTheme.success,
      ));
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_step == 0 ? 'Add New Family' : 'Add Members'),
        flexibleSpace: Container(decoration: headerGradient),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => _step == 1
              ? setState(() => _step = 0)
              : Navigator.of(context).pop(),
        ),
      ),
      body: _step == 0 ? _buildStep0() : _buildStep1(),
    );
  }

  Widget _buildStep0() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(children: [
        _StepBar(current: 0),
        const SizedBox(height: 28),
        TextField(
          controller: _houseCtrl,
          textCapitalization: TextCapitalization.characters,
          decoration: const InputDecoration(
            labelText: 'House Number',
            hintText: 'e.g. A101',
            prefixIcon: Icon(Icons.home_rounded, color: AppTheme.primary),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _familyCtrl,
          decoration: const InputDecoration(
            labelText: 'Family Name',
            hintText: 'e.g. Sharma Family',
            prefixIcon:
                Icon(Icons.family_restroom_rounded, color: AppTheme.primary),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _passCtrl,
          decoration: const InputDecoration(
            labelText: 'Login Password',
            hintText: 'Password for this family to login',
            prefixIcon: Icon(Icons.lock_rounded, color: AppTheme.primary),
          ),
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _saving ? null : _submitHouse,
            child: _saving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child:
                        CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text('Next: Add Members'),
          ),
        ),
      ]),
    );
  }

  Widget _buildStep1() {
    return Column(children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        child: _StepBar(current: 1),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 4),
        child: Row(children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('House: $_houseno',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
              const Text('Add family members (optional)',
                  style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
            ]),
          ),
          TextButton.icon(
            onPressed: () => setState(() => _forms.add(_FamilyForm())),
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text('Add'),
          ),
        ]),
      ),
      Expanded(
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _forms.length,
          itemBuilder: (_, i) => _FamilyFormWidget(
            form: _forms[i],
            index: i + 1,
            onRemove: _forms.length > 1
                ? () => setState(() => _forms.removeAt(i))
                : null,
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(16),
        child: Row(children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Skip'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: _saving ? null : _submitMembers,
              child: _saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : const Text('Save All'),
            ),
          ),
        ]),
      ),
    ]);
  }
}

class _StepBar extends StatelessWidget {
  final int current;
  const _StepBar({required this.current});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      _StepDot(label: '1', text: 'House Info', active: current == 0, done: current > 0),
      Expanded(
        child: Container(
            height: 2,
            color: current > 0 ? AppTheme.primary : Colors.grey[300]),
      ),
      _StepDot(label: '2', text: 'Members', active: current == 1, done: false),
    ]);
  }
}

class _StepDot extends StatelessWidget {
  final String label;
  final String text;
  final bool active;
  final bool done;
  const _StepDot(
      {required this.label,
      required this.text,
      required this.active,
      required this.done});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: active || done ? AppTheme.primary : Colors.grey[200],
          shape: BoxShape.circle,
        ),
        child: Center(
          child: done
              ? const Icon(Icons.check_rounded, color: Colors.white, size: 16)
              : Text(label,
                  style: TextStyle(
                      color: active ? Colors.white : Colors.grey[500],
                      fontWeight: FontWeight.bold,
                      fontSize: 14)),
        ),
      ),
      const SizedBox(height: 4),
      Text(text,
          style: TextStyle(
              fontSize: 11,
              color: active ? AppTheme.primary : AppTheme.textSecondary,
              fontWeight:
                  active ? FontWeight.w600 : FontWeight.normal)),
    ]);
  }
}

class _FamilyForm {
  final name = TextEditingController();
  final contact = TextEditingController();
  final age = TextEditingController();
  String gender = 'Male';

  void dispose() {
    name.dispose();
    contact.dispose();
    age.dispose();
  }
}

class _FamilyFormWidget extends StatefulWidget {
  final _FamilyForm form;
  final int index;
  final VoidCallback? onRemove;
  const _FamilyFormWidget(
      {required this.form, required this.index, this.onRemove});

  @override
  State<_FamilyFormWidget> createState() => _FamilyFormWidgetState();
}

class _FamilyFormWidgetState extends State<_FamilyFormWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)
        ],
      ),
      child: Column(children: [
        Row(children: [
          Text('Member ${widget.index}',
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
          const Spacer(),
          if (widget.onRemove != null)
            GestureDetector(
              onTap: widget.onRemove,
              child: const Icon(Icons.remove_circle_rounded,
                  color: AppTheme.danger, size: 22),
            ),
        ]),
        const SizedBox(height: 12),
        TextField(
          controller: widget.form.name,
          decoration: const InputDecoration(
            labelText: 'Full Name',
            isDense: true,
            prefixIcon:
                Icon(Icons.person_rounded, color: AppTheme.primary, size: 20),
          ),
        ),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(
            child: TextField(
              controller: widget.form.age,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Age',
                isDense: true,
                prefixIcon:
                    Icon(Icons.cake_rounded, color: AppTheme.primary, size: 20),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: InputDecorator(
              decoration: const InputDecoration(
                  labelText: 'Gender', isDense: true),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: widget.form.gender,
                  isDense: true,
                  items: ['Male', 'Female', 'Other']
                      .map((g) => DropdownMenuItem(
                          value: g,
                          child: Text(g,
                              style: const TextStyle(fontSize: 13))))
                      .toList(),
                  onChanged: (v) =>
                      setState(() => widget.form.gender = v!),
                ),
              ),
            ),
          ),
        ]),
        const SizedBox(height: 10),
        TextField(
          controller: widget.form.contact,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(
            labelText: 'Contact Number',
            isDense: true,
            prefixIcon:
                Icon(Icons.phone_rounded, color: AppTheme.primary, size: 20),
          ),
        ),
      ]),
    );
  }
}
