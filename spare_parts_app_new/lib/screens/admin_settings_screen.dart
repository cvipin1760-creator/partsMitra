import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../services/settings_service.dart';
import '../widgets/section_header.dart';

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
  bool _notifInApp = true;
  bool _notifWhatsApp = false;
  bool _loaded = false;
  late ThemeProvider _themeProvider;
  final List<Color> _colorChoices = const [
    Color(0xFF2E7D32), // Emerald
    Color(0xFF1565C0), // Royal Blue
    Color(0xFFFFB300), // Amber
    Color(0xFF7E57C2), // Purple
    Color(0xFFD32F2F), // Red
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    // Theme is managed by ThemeProvider; no need to read here
    final v = await SettingsService.isVoiceTrainingEnabled();
    final a = await SettingsService.isAiChatbotEnabled();
    final w = await SettingsService.isWebSocketEnabled();
    final o = await SettingsService.isForceLocalOtp();
    final remote = await SettingsService.getRemoteSettings();
    if (mounted) {
      setState(() {
        _voice = v;
        _ai = a;
        _ws = w;
        _localOtp = o;
        _notifInApp = remote['NOTIF_IN_APP_ENABLED'] == 'true';
        _notifWhatsApp = remote['NOTIF_WHATSAPP_ENABLED'] == 'true';
        _loaded = true;
      });
    }
  }

  Future<void> _save() async {
    await SettingsService.setVoiceTrainingEnabled(_voice);
    await SettingsService.setAiChatbotEnabled(_ai);
    await SettingsService.setWebSocketEnabled(_ws);
    await SettingsService.setForceLocalOtp(_localOtp);
    await SettingsService.saveRemoteSetting(
        'NOTIF_IN_APP_ENABLED', _notifInApp ? 'true' : 'false');
    await SettingsService.saveRemoteSetting(
        'NOTIF_WHATSAPP_ENABLED', _notifWhatsApp ? 'true' : 'false');
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Settings saved')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    _themeProvider = Provider.of<ThemeProvider>(context);
    final currentTheme = _themeProvider.themeMode;
    final currentSeed = _themeProvider.seedColor;
    final textScale = _themeProvider.textScale;
    final animationSpeed = _themeProvider.animationSpeed;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Settings'),
      ),
      body: !_loaded
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const SectionHeader(
                    title: 'Appearance',
                    subtitle: 'Customize app look and feel'),
                const SizedBox(height: 8),
                SegmentedButton<ThemeMode>(
                  segments: const [
                    ButtonSegment(
                        value: ThemeMode.system,
                        icon: Icon(Icons.brightness_auto),
                        label: Text('System')),
                    ButtonSegment(
                        value: ThemeMode.light,
                        icon: Icon(Icons.light_mode),
                        label: Text('Light')),
                    ButtonSegment(
                        value: ThemeMode.dark,
                        icon: Icon(Icons.dark_mode),
                        label: Text('Dark')),
                  ],
                  selected: {currentTheme},
                  onSelectionChanged: (sel) {
                    final mode = sel.first;
                    _themeProvider.setThemeMode(mode);
                  },
                  style: ButtonStyle(
                    visualDensity: VisualDensity.compact,
                  ),
                ),
                const SizedBox(height: 12),
                Text('Primary Color',
                    style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: _colorChoices.map((c) {
                    final selected = c.value == currentSeed.value;
                    return GestureDetector(
                      onTap: () => _themeProvider.setSeedColor(c),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: c,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: selected ? Colors.black : Colors.black12,
                            width: selected ? 2 : 1,
                          ),
                        ),
                        child: selected
                            ? const Icon(Icons.check,
                                color: Colors.white, size: 20)
                            : null,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
                Text('Text Size',
                    style: Theme.of(context).textTheme.labelLarge),
                Slider(
                  value: textScale,
                  min: 0.8,
                  max: 1.4,
                  divisions: 6,
                  label: '${textScale.toStringAsFixed(2)}x',
                  onChanged: (v) => _themeProvider.setTextScale(v),
                ),
                const SizedBox(height: 8),
                Text('Animation Speed',
                    style: Theme.of(context).textTheme.labelLarge),
                Slider(
                  value: animationSpeed,
                  min: 0.5,
                  max: 2.0,
                  divisions: 6,
                  label: '${animationSpeed.toStringAsFixed(2)}x',
                  onChanged: (v) => _themeProvider.setAnimationSpeed(v),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.analytics_outlined),
                  title: const Text('AI Training Report'),
                  subtitle:
                      const Text('Review samples and export CSV for analysis'),
                  onTap: () =>
                      Navigator.of(context).pushNamed('/admin/ai-training'),
                ),
                const Divider(),
                const SectionHeader(
                    title: 'Local App Settings',
                    subtitle: 'These apply to this device only'),
                SwitchListTile(
                  title: const Text('Enable Voice Training'),
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
                const Divider(),
                const SectionHeader(
                    title: 'Global Notification Settings',
                    subtitle: 'Affects all users'),
                SwitchListTile(
                  title: const Text('In-App Notifications'),
                  subtitle: const Text('Notify users when new products launch'),
                  value: _notifInApp,
                  onChanged: (v) => setState(() => _notifInApp = v),
                ),
                SwitchListTile(
                  title: const Text('WhatsApp Notifications'),
                  subtitle: const Text('Send WhatsApp alerts for new products'),
                  value: _notifWhatsApp,
                  onChanged: (v) => setState(() => _notifWhatsApp = v),
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
