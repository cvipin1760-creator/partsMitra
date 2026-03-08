
import './db_universal.dart';
import './remote_client.dart';
import '../utils/constants.dart';

class VoiceCorrectionService {
  final DatabaseService _dbService = DatabaseService();
  final RemoteClient _remote = RemoteClient();

  Future<void> addCorrection(String recognizedText, String correctedText) async {
    if (Constants.useRemote) {
      await _remote.postJson('/voice-corrections', {
        'recognizedText': recognizedText,
        'correctedText': correctedText,
      });
    } else {
      final db = await _dbService.database;
      await db.insert('voice_corrections', {
        'recognized_text': recognizedText,
        'corrected_text': correctedText,
      });
    }
  }

  Future<String?> getCorrection(String recognizedText) async {
    if (Constants.useRemote) {
      final res = await _remote.postJson('/voice-corrections/find', {'recognizedText': recognizedText});
      return res['correctedText'] as String?;
    } else {
      final db = await _dbService.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'voice_corrections',
        where: 'recognized_text = ?',
        whereArgs: [recognizedText],
      );
      if (maps.isNotEmpty) {
        return maps.first['corrected_text'] as String?;
      }
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> listCorrections() async {
    if (Constants.useRemote) {
      final list = await _remote.getList('/voice-corrections');
      return list.cast<Map<String, dynamic>>();
    } else {
      final db = await _dbService.database;
      return db.query('voice_corrections', orderBy: 'id DESC');
    }
  }

  Future<void> deleteCorrection(int id) async {
    if (Constants.useRemote) {
      await _remote.postJson('/voice-corrections/delete', {'id': id});
    } else {
      final db = await _dbService.database;
      await db.delete('voice_corrections', where: 'id = ?', whereArgs: [id]);
    }
  }
}
