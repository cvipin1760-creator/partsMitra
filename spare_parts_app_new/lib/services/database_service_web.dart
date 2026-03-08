class DatabaseService {
  Future<dynamic> get database async {
    throw UnsupportedError('Local database not available on web');
  }
}
