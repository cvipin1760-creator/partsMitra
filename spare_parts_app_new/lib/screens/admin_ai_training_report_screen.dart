import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import '../services/remote_client.dart';
import '../utils/constants.dart';
import 'dart:io';

class AdminAITrainingReportScreen extends StatefulWidget {
  const AdminAITrainingReportScreen({super.key});

  @override
  State<AdminAITrainingReportScreen> createState() => _AdminAITrainingReportScreenState();
}

class _AdminAITrainingReportScreenState extends State<AdminAITrainingReportScreen> {
  final RemoteClient _remote = RemoteClient();
  List<dynamic> _samples = [];
  String? _role;
  DateTime? _from;
  DateTime? _to;
  bool _loading = false;

  Future<void> _pickFrom() async {
    final now = DateTime.now();
    final res = await showDatePicker(
      context: context,
      initialDate: _from ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 1),
    );
    if (res != null) setState(() => _from = res);
  }

  Future<void> _pickTo() async {
    final now = DateTime.now();
    final res = await showDatePicker(
      context: context,
      initialDate: _to ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 1),
    );
    if (res != null) setState(() => _to = res);
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final qp = <String, String>{'page': '0', 'size': '200'};
      if (_role != null && _role!.isNotEmpty) qp['role'] = _role!;
      if (_from != null) qp['from'] = DateFormat("yyyy-MM-dd'T'00:00:00").format(_from!);
      if (_to != null) qp['to'] = DateFormat("yyyy-MM-dd'T'23:59:59").format(_to!);
      final query = qp.entries.map((e) => '${e.key}=${Uri.encodeComponent(e.value)}').join('&');
      final res = await _remote.getJson('/admin/ai/voice/samples?$query');
      setState(() {
        _samples = (res['content'] as List?) ?? [];
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load samples: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _exportCsvClient() async {
    final buf = StringBuffer();
    buf.writeln('id,createdAt,userId,role,query,productId,productName,price');
    for (final s in _samples) {
      buf.writeln([
        s['id'] ?? '',
        s['createdAt'] ?? '',
        s['userId'] ?? '',
        s['role'] ?? '',
        (s['query'] ?? '').toString().replaceAll(',', ' '),
        s['productId'] ?? '',
        (s['productName'] ?? '').toString().replaceAll(',', ' '),
        s['price'] ?? ''
      ].join(','));
    }
    final dir = await getTemporaryDirectory();
    final f = File('${dir.path}/voice_training_samples.csv');
    await f.writeAsString(buf.toString());
    await OpenFile.open(f.path);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Training Report'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _load,
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _exportCsvClient,
            tooltip: 'Export CSV',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _role,
                    items: const [
                      DropdownMenuItem(value: null, child: Text('All Roles')),
                      DropdownMenuItem(value: 'ROLE_MECHANIC', child: Text('Mechanic')),
                      DropdownMenuItem(value: 'ROLE_RETAILER', child: Text('Retailer')),
                      DropdownMenuItem(value: 'ROLE_WHOLESALER', child: Text('Wholesaler')),
                      DropdownMenuItem(value: 'ROLE_STAFF', child: Text('Staff')),
                    ],
                    onChanged: (v) => setState(() => _role = v),
                    decoration: const InputDecoration(labelText: 'Role'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickFrom,
                    icon: const Icon(Icons.date_range),
                    label: Text(_from == null ? 'From' : DateFormat('yyyy-MM-dd').format(_from!)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickTo,
                    icon: const Icon(Icons.date_range),
                    label: Text(_to == null ? 'To' : DateFormat('yyyy-MM-dd').format(_to!)),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _load,
                  child: const Text('Filter'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_loading) const LinearProgressIndicator(),
            Expanded(
              child: _samples.isEmpty
                  ? const Center(child: Text('No samples'))
                  : ListView.separated(
                      itemCount: _samples.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (ctx, i) {
                        final s = _samples[i] as Map<String, dynamic>;
                        return ListTile(
                          title: Text(s['query'] ?? ''),
                          subtitle: Text(
                              '${s['productName'] ?? ''}  •  ${s['role'] ?? ''}  •  ${s['createdAt'] ?? ''}'),
                          trailing: Text('${s['price'] ?? ''}'),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
