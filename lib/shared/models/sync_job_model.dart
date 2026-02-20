import 'package:cloud_firestore/cloud_firestore.dart';

enum SyncJobType {
  exportSheets,
  exportDrive,
  importSheets,
  importDrive,
}

enum SyncJobStatus {
  pending,
  running,
  completed,
  failed,
}

class SyncJobModel {
  final String id;
  final SyncJobType type;
  final SyncJobStatus status;
  final DateTime startedAt;
  final DateTime? finishedAt;
  final Map<String, dynamic>? resultMeta;
  final String? errorMessage;

  const SyncJobModel({
    required this.id,
    required this.type,
    this.status = SyncJobStatus.pending,
    required this.startedAt,
    this.finishedAt,
    this.resultMeta,
    this.errorMessage,
  });

  factory SyncJobModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SyncJobModel(
      id: doc.id,
      type: SyncJobType.values.firstWhere(
        (e) => e.name == data['type'],
        orElse: () => SyncJobType.exportDrive,
      ),
      status: SyncJobStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => SyncJobStatus.pending,
      ),
      startedAt:
          (data['startedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      finishedAt: (data['finishedAt'] as Timestamp?)?.toDate(),
      resultMeta: data['resultMeta'] as Map<String, dynamic>?,
      errorMessage: data['errorMessage'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'type': type.name,
      'status': status.name,
      'startedAt': Timestamp.fromDate(startedAt),
      'finishedAt':
          finishedAt != null ? Timestamp.fromDate(finishedAt!) : null,
      'resultMeta': resultMeta,
      'errorMessage': errorMessage,
    };
  }
}
