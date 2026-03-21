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

  // New Global Settings
  bool _wsGlobal = true;
  bool _localOtpGlobal = false;
  final TextEditingController _logoUrlController = TextEditingController();
  final TextEditingController _serverHostController = TextEditingController();
  final TextEditingController _googleClientIdController =
      TextEditingController();
  final TextEditingController _resetPasswordPathController =
      TextEditingController();
  final TextEditingController _altResetPasswordPathController =
      TextEditingController();
  final TextEditingController _changePasswordPathController =
      TextEditingController();
  final TextEditingController _otpLoginPathController = TextEditingController();
  final TextEditingController _locationIdPathController =
      TextEditingController();
  final TextEditingController _locationBodyPathController =
      TextEditingController();
  final TextEditingController _loyaltyPercentController =
      TextEditingController();
  final TextEditingController _minRedeemPointsController =
      TextEditingController();

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

  @override
  void dispose() {
    _logoUrlController.dispose();
    _serverHostController.dispose();
    _googleClientIdController.dispose();
    _resetPasswordPathController.dispose();
    _altResetPasswordPathController.dispose();
    _changePasswordPathController.dispose();
    _otpLoginPathController.dispose();
    _locationIdPathController.dispose();
    _locationBodyPathController.dispose();
    _loyaltyPercentController.dispose();
    _minRedeemPointsController.dispose();
    super.dispose();
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

        // Load Global Settings
        _wsGlobal = (remote['WS_ENABLED'] ?? 'true') == 'true';
        _localOtpGlobal = (remote['FORCE_LOCAL_OTP'] ?? 'false') == 'true';
        _logoUrlController.text = remote['LOGO_URL'] ?? '';
        _serverHostController.text =
            remote['SERVER_HOST'] ?? 'sparehub-0t47.onrender.com';
        _googleClientIdController.text = remote['GOOGLE_CLIENT_ID'] ?? '';
        _resetPasswordPathController.text =
            remote['RESET_PASSWORD_PATH'] ?? '/auth/reset-password';
        _altResetPasswordPathController.text =
            remote['ALT_RESET_PASSWORD_PATH'] ?? '/auth/password/reset';
        _changePasswordPathController.text =
            remote['CHANGE_PASSWORD_PATH'] ?? '/auth/change-password';
        _otpLoginPathController.text =
            remote['OTP_LOGIN_PATH'] ?? '/auth/otp-login';
        _locationIdPathController.text =
            remote['LOCATION_ID_PATH'] ?? '/admin/users/{id}/location';
        _locationBodyPathController.text =
            remote['LOCATION_BODY_PATH'] ?? '/admin/users/update-location';
        _loyaltyPercentController.text = remote['LOYALTY_PERCENT'] ?? '1';
        _minRedeemPointsController.text = remote['MIN_REDEEM_POINTS'] ?? '0';

        _loaded = true;
      });
    }
  }

  Future<void> _save() async {
    await SettingsService.setVoiceTrainingEnabled(_voice);
    await SettingsService.setAiChatbotEnabled(_ai);
    await SettingsService.setWebSocketEnabled(_ws);
    await SettingsService.setForceLocalOtp(_localOtp);

    // Save Remote Settings
    final remoteMap = {
      'NOTIF_IN_APP_ENABLED': _notifInApp ? 'true' : 'false',
      'NOTIF_WHATSAPP_ENABLED': _notifWhatsApp ? 'true' : 'false',
      'WS_ENABLED': _wsGlobal ? 'true' : 'false',
      'FORCE_LOCAL_OTP': _localOtpGlobal ? 'true' : 'false',
      'LOGO_URL': _logoUrlController.text,
      'SERVER_HOST': _serverHostController.text,
      'GOOGLE_CLIENT_ID': _googleClientIdController.text,
      'RESET_PASSWORD_PATH': _resetPasswordPathController.text,
      'ALT_RESET_PASSWORD_PATH': _altResetPasswordPathController.text,
      'CHANGE_PASSWORD_PATH': _changePasswordPathController.text,
      'OTP_LOGIN_PATH': _otpLoginPathController.text,
      'LOCATION_ID_PATH': _locationIdPathController.text,
      'LOCATION_BODY_PATH': _locationBodyPathController.text,
      'LOYALTY_PERCENT': _loyaltyPercentController.text,
      'MIN_REDEEM_POINTS': _minRedeemPointsController.text,
    };

    for (var entry in remoteMap.entries) {
      await SettingsService.saveRemoteSetting(entry.key, entry.value);
    }

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
                    title: 'Global System Settings',
                    subtitle: 'Affects all devices (Stored on Server)'),
                SwitchListTile(
                  title: const Text('Global WebSocket'),
                  subtitle: const Text('Enable/Disable WS for all clients'),
                  value: _wsGlobal,
                  onChanged: (v) => setState(() => _wsGlobal = v),
                ),
                SwitchListTile(
                  title: const Text('Global Force Local OTP'),
                  subtitle: const Text('Force local OTP for all clients'),
                  value: _localOtpGlobal,
                  onChanged: (v) => setState(() => _localOtpGlobal = v),
                ),
                _buildTextField(
                    'Logo URL', _logoUrlController, 'URL for the app logo'),
                _buildTextField('Server Host', _serverHostController,
                    'Backend API host (e.g. example.com)'),
                _buildTextField('Google Client ID', _googleClientIdController,
                    'Google OAuth Client ID'),
                const Divider(),
                const SectionHeader(
                    title: 'Loyalty & Points',
                    subtitle: 'Manage reward system'),
                _buildTextField('Loyalty Percent', _loyaltyPercentController,
                    'Percentage of order amount given as points',
                    keyboardType: TextInputType.number),
                _buildTextField('Min Redeem Points', _minRedeemPointsController,
                    'Minimum points required to redeem',
                    keyboardType: TextInputType.number),
                const Divider(),
                const SectionHeader(
                    title: 'API Path Configuration',
                    subtitle: 'Advanced path overrides'),
                _buildTextField(
                    'Reset Password Path',
                    _resetPasswordPathController,
                    'Default: /auth/reset-password'),
                _buildTextField(
                    'Alt Reset Password Path',
                    _altResetPasswordPathController,
                    'Default: /auth/password/reset'),
                _buildTextField(
                    'Change Password Path',
                    _changePasswordPathController,
                    'Default: /auth/change-password'),
                _buildTextField('OTP Login Path', _otpLoginPathController,
                    'Default: /auth/otp-login'),
                _buildTextField('Location ID Path', _locationIdPathController,
                    'Default: /admin/users/{id}/location'),
                _buildTextField(
                    'Location Body Path',
                    _locationBodyPathController,
                    'Default: /admin/users/update-location'),
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
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                  ),
                  child: const Text('Save All Settings'),
                ),
                const SizedBox(height: 32),
              ],
            ),
    );
  }

  Widget _buildTextField(
      String label, TextEditingController controller, String hint,
      {TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: const OutlineInputBorder(),
          isDense: true,
        ),
        keyboardType: keyboardType,
      ),
    );
  }
}
