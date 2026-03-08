import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const _voiceTrainingKey = 'voice_training_enabled';
  static const _aiChatbotKey = 'ai_chatbot_enabled';
  static const _websocketKey = 'websocket_enabled';
  static const _forceLocalOtpKey = 'force_local_otp';

  static Future<SharedPreferences> _prefs() async =>
      await SharedPreferences.getInstance();

  static Future<bool> isVoiceTrainingEnabled() async {
    final p = await _prefs();
    return p.getBool(_voiceTrainingKey) ?? true;
    }

  static Future<void> setVoiceTrainingEnabled(bool v) async {
    final p = await _prefs();
    await p.setBool(_voiceTrainingKey, v);
  }

  static Future<bool> isAiChatbotEnabled() async {
    final p = await _prefs();
    return p.getBool(_aiChatbotKey) ?? true;
  }

  static Future<void> setAiChatbotEnabled(bool v) async {
    final p = await _prefs();
    await p.setBool(_aiChatbotKey, v);
  }

  static Future<bool> isWebSocketEnabled() async {
    final p = await _prefs();
    return p.getBool(_websocketKey) ?? false;
  }

  static Future<void> setWebSocketEnabled(bool v) async {
    final p = await _prefs();
    await p.setBool(_websocketKey, v);
  }

  static Future<bool> isForceLocalOtp() async {
    final p = await _prefs();
    return p.getBool(_forceLocalOtpKey) ?? false;
  }

  static Future<void> setForceLocalOtp(bool v) async {
    final p = await _prefs();
    await p.setBool(_forceLocalOtpKey, v);
  }
}
