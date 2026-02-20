import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/models/task_model.dart';

class TaskRepository {
  final FirebaseFirestore _firestore;

  TaskRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference _tasksRef(String uid) =>
      _firestore.collection(FirestorePaths.tasks(uid));

  Stream<List<TaskModel>> watchTasks(String uid) {
    return _tasksRef(uid)
        .orderBy('orderIndex')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => TaskModel.fromFirestore(d)).toList());
  }

  Stream<List<TaskModel>> watchPendingTasks(String uid) {
    return _tasksRef(uid)
        .where('isCompleted', isEqualTo: false)
        .orderBy('orderIndex')
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => TaskModel.fromFirestore(d)).toList());
  }

  Stream<List<TaskModel>> watchCompletedTasks(String uid) {
    return _tasksRef(uid)
        .where('isCompleted', isEqualTo: true)
        .orderBy('completedAt', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => TaskModel.fromFirestore(d)).toList());
  }

  Future<TaskModel> addTask(String uid, TaskModel task) async {
    final doc = _tasksRef(uid).doc();
    final newTask = task.copyWith(
      id: doc.id,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    await doc.set(newTask.toFirestore());
    return newTask.copyWith(id: doc.id);
  }

  Future<void> updateTask(String uid, TaskModel task) async {
    await _tasksRef(uid)
        .doc(task.id)
        .update(task.copyWith(updatedAt: DateTime.now()).toFirestore());
  }

  Future<void> toggleComplete(String uid, TaskModel task) async {
    final now = DateTime.now();
    final updated = task.copyWith(
      isCompleted: !task.isCompleted,
      completedAt: !task.isCompleted ? now : null,
      updatedAt: now,
      clearCompletedAt: task.isCompleted,
    );
    await _tasksRef(uid).doc(task.id).update(updated.toFirestore());
  }

  Future<void> deleteTask(String uid, String taskId) async {
    await _tasksRef(uid).doc(taskId).delete();
  }

  Future<List<TaskModel>> getAllTasks(String uid) async {
    final snap = await _tasksRef(uid).get();
    return snap.docs.map((d) => TaskModel.fromFirestore(d)).toList();
  }
}
