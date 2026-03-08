import 'package:flutter/material.dart';
import '../services/settings_service.dart';

class AdminSettingsScreen extends StatefulWidget {
  const AdminSettingsScreen({super.key});
  @override
  State<AdminSettingsScreen> createState() => _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends State<AdminSettingsScreen> {
  bool _voice = true;
  bool _ai = true;
  bool _ws = false;
  bool _localOtp = false;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final v = await SettingsService.isVoiceTrainingEnabled();
    final a = await SettingsService.isAiChatbotEnabled();
    final w = await SettingsService.isWebSocketEnabled();
    final o = await SettingsService.isForceLocalOtp();
    if (mounted) {
      setState(() {
        _voice = v;
        _ai = a;
        _ws = w;
        _localOtp = o;
        _loaded = true;
      });
    }
  }

  Future<void> _save() async {
    await SettingsService.setVoiceTrainingEnabled(_voice);
    await SettingsService.setAiChatbotEnabled(_ai);
    await SettingsService.setWebSocketEnabled(_ws);
    await SettingsService.setForceLocalOtp(_localOtp);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Settings saved')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Settings'),
      ),
      body: !_loaded
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                SwitchListTile(
                  title: const Text('Enable Voice Training'),
                  subtitle:
                      const Text('Use corrections to improve voice searches'),
                  value: _voice,
                  onChanged: (v) => setState(() => _voice = v),
                ),
                SwitchListTile(
                  title: const Text('Enable AI Chatbot'),
                  value: _ai,
                  onChanged: (v) => setState(() => _ai = v),
                ),
                SwitchListTile(
                  title: const Text('Enable WebSocket'),
                  value: _ws,
                  onChanged: (v) => setState(() => _ws = v),
                ),
                SwitchListTile(
                  title: const Text('Force Local Email OTP'),
                  value: _localOtp,
                  onChanged: (v) => setState(() => _localOtp = v),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _save,
                  child: const Text('Save'),
                ),
              ],
            ),
    );
  }
}
