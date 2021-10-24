import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';

class SettingsProvider extends ChangeNotifier {
  StatusKey _statusKey = new StatusKey(statusKeys: []);
  Map _globalSettings = {};
  Map _localSettings = {};
  List<CustomStatusType> _workOrderCustomStatusTypes = [];
  List<ParentStatusType> _parentStatusTypes = [];

  Map get globalSettings => _globalSettings;
  Map get localSettings => _localSettings;
  StatusKey get statusKey => _statusKey;
  List<CustomStatusType> get workOrderCustomStatusTypes =>
      _workOrderCustomStatusTypes;
  List<ParentStatusType> get parentStatusTypes => _parentStatusTypes;

  Future subLocalSettings(String handle) async {
    this._localSettings = {};

    DocumentReference ref =
        FirebaseFirestore.instance.collection('$handle').doc('settings');
    DocumentSnapshot doc = await ref.get();

    Map data = doc.data() as Map;

    this._localSettings = data;

    if (this._localSettings['workOrderCustomStatusTypes'] != null) {
      this._localSettings['workOrderCustomStatusTypes'].map((statusType) {
        this
            ._workOrderCustomStatusTypes
            .add(CustomStatusType.fromData(statusType));
      }).toList();
    }

    notifyListeners();
  }

  Future subGlobalSettings() async {
    this._globalSettings = {};

    DocumentReference ref =
        FirebaseFirestore.instance.collection('settings').doc('settings');
    DocumentSnapshot doc = await ref.get();

    Map data = doc.data() as Map;

    this._globalSettings = data;
    this._globalSettings['workOrderStatusTypes'].map((statusType) {
      this._parentStatusTypes.add(ParentStatusType.fromData(statusType));
    }).toList();

    notifyListeners();
  }

  void createStatusKey() {
    this.workOrderCustomStatusTypes.forEach((statusType) {
      ParentStatusType? parent =
          parentStatusTypes.firstWhereOrNull((e) => e.id == statusType.parent);
      if (parent != null) parent.addStatusType(statusType);
    });
  }
}

class StatusKey {
  List<ParentStatusType> statusKeys;
  StatusKey({required this.statusKeys});
}

class ParentStatusType {
  String color;
  String id;
  String name;
  int position;
  List<CustomStatusType> childStatusTypes = [];

  ParentStatusType({
    required this.color,
    required this.id,
    required this.name,
    required this.position,
  });

  void addStatusType(CustomStatusType statusType) {
    this.childStatusTypes.add(statusType);
  }

  factory ParentStatusType.fromData(Map data) {
    return ParentStatusType(
        color: data['color'],
        id: data['id'],
        name: data['name'],
        position: data['position']);
  }
}

class CustomStatusType {
  Color color;
  String id;
  String name;
  String parent;
  int position;

  CustomStatusType(
      {required this.color,
      required this.id,
      required this.name,
      required this.position,
      required this.parent});

  factory CustomStatusType.fromData(Map data) {
    return CustomStatusType(
        color: Color(int.parse('0xFF${data['color']}')),
        id: data['id'],
        name: data['name'],
        parent: data['parent'],
        position: data['position']);
  }
}
