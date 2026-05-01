import 'package:appweb/workers/modelworkers.dart';

class SelectedWorkerService {
  static final SelectedWorkerService instance =
      SelectedWorkerService._internal();

  SelectedWorkerService._internal();

  Worker? _worker;

  Worker? get worker => _worker;

  String get name => _worker?.fullname ?? 'Unknown';
  String get phone => _worker?.phoneNumber ?? '';
  int get id => _worker?.id ?? 0;
  String get job => _worker?.job ?? '';
  String get address => _worker?.address ?? '';
  String get firebaseUid =>
      _worker?.firebaseUid ?? _worker?.id.toString() ?? '';

  void select(Worker w) {
    _worker = w;
  }

  void clear() {
    _worker = null;
  }
}
