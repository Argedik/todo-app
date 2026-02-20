abstract class NotesSyncAdapter {
  Future<void> exportNotes(List<Map<String, dynamic>> notes);
  Future<List<Map<String, dynamic>>> importNotes();
  String get adapterName;
}

class GoogleDriveNotesAdapter implements NotesSyncAdapter {
  @override
  String get adapterName => 'Google Drive';

  @override
  Future<void> exportNotes(List<Map<String, dynamic>> notes) async {
    // TODO: googleapis ile Drive'a export yap
    // 1. "Notlarim_Backups" klasörü bul veya oluştur
    // 2. JSON dosyası olarak yükle
    throw UnimplementedError('Google Drive export henüz kurulmadı');
  }

  @override
  Future<List<Map<String, dynamic>>> importNotes() async {
    // TODO: googleapis ile Drive'dan import yap
    throw UnimplementedError('Google Drive import henüz kurulmadı');
  }
}

class GoogleKeepNotesAdapter implements NotesSyncAdapter {
  static const bool isEnabled = false;

  @override
  String get adapterName => 'Google Keep';

  @override
  Future<void> exportNotes(List<Map<String, dynamic>> notes) async {
    if (!isEnabled) {
      throw UnsupportedError(
        'Google Keep entegrasyonu henüz aktif değil. '
        'Google Drive kullanılacak.',
      );
    }
  }

  @override
  Future<List<Map<String, dynamic>>> importNotes() async {
    if (!isEnabled) {
      throw UnsupportedError(
        'Google Keep entegrasyonu henüz aktif değil. '
        'Google Drive kullanılacak.',
      );
    }
    return [];
  }
}

class NotesSyncService {
  NotesSyncAdapter _adapter;

  NotesSyncService({NotesSyncAdapter? adapter})
      : _adapter = adapter ?? GoogleDriveNotesAdapter();

  NotesSyncAdapter get currentAdapter => _adapter;

  void setAdapter(NotesSyncAdapter adapter) {
    _adapter = adapter;
  }

  Future<void> exportNotes(List<Map<String, dynamic>> notes) async {
    try {
      await _adapter.exportNotes(notes);
    } on UnsupportedError {
      _adapter = GoogleDriveNotesAdapter();
      await _adapter.exportNotes(notes);
    }
  }

  Future<List<Map<String, dynamic>>> importNotes() async {
    try {
      return await _adapter.importNotes();
    } on UnsupportedError {
      _adapter = GoogleDriveNotesAdapter();
      return await _adapter.importNotes();
    }
  }
}
