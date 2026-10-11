import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'api_service.dart';
import 'theme.dart';

class AddNoticePage extends StatefulWidget {
  final String issuedBy;
  const AddNoticePage({super.key, required this.issuedBy});

  @override
  State<AddNoticePage> createState() => _AddNoticePageState();
}

class _AddNoticePageState extends State<AddNoticePage> {
  final _headCtrl = TextEditingController();
  final _contentCtrl = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _headCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final head = _headCtrl.text.trim();
    final content = _contentCtrl.text.trim();
    if (head.isEmpty || content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill in all fields')));
      return;
    }
    setState(() => _loading = true);
    try {
      await ApiService.addNotice({
        'head': head,
        'content': content,
        'date': DateFormat('yyyy-MM-dd').format(DateTime.now()),
        'issue_by': widget.issuedBy,
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Notice issued successfully!'),
        backgroundColor: AppTheme.success,
      ));
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e'), backgroundColor: AppTheme.danger));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Issue Notice'),
        flexibleSpace: Container(decoration: headerGradient),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: AppTheme.infoLight,
                borderRadius: BorderRadius.circular(14)),
            child: Row(children: [
              const Icon(Icons.campaign_rounded,
                  color: AppTheme.info, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Issuing as',
                          style: TextStyle(
                              fontSize: 11, color: AppTheme.textSecondary)),
                      Text(widget.issuedBy,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.info,
                              fontSize: 15)),
                    ]),
              ),
            ]),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _headCtrl,
            decoration: const InputDecoration(
              labelText: 'Notice Heading',
              hintText: 'e.g. Water supply shutdown notice',
              prefixIcon:
                  Icon(Icons.title_rounded, color: AppTheme.primary),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _contentCtrl,
            maxLines: 7,
            decoration: const InputDecoration(
              labelText: 'Content',
              hintText: 'Write the full notice here...',
              alignLabelWithHint: true,
              prefixIcon: Padding(
                padding: EdgeInsets.only(bottom: 116),
                child: Icon(Icons.article_rounded, color: AppTheme.primary),
              ),
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: _loading ? null : _submit,
              icon: _loading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : const Icon(Icons.send_rounded),
              label: const Text('Issue Notice'),
            ),
          ),
        ]),
      ),
    );
  }
}
