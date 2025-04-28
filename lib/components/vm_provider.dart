import 'package:flutter/material.dart';

class VMProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _vms = [];

  List<Map<String, dynamic>> get vms => _vms;

  void setVMs(List<Map<String, dynamic>> vms) {
    _vms = vms;
    notifyListeners();
  }

  void addVM(Map<String, dynamic> vm) {
    _vms.add(vm);
    notifyListeners();
  }

  void updateVM(String id, Map<String, dynamic> updatedVm) {
    final index = _vms.indexWhere((vm) => vm['id'] == id);
    if (index != -1) {
      _vms[index] = updatedVm;
      notifyListeners();
    }
  }

  void deleteVM(String id) {
    _vms.removeWhere((vm) => vm['id'] == id);
    notifyListeners();
  }

  void preloadVMs() {
    _vms = [
      {
        'id': 'vps-001',
        'name': 'Production Server',
      },
      {
        'id': 'vps-002',
        'name': 'Backup Server',
      },
    ];
    notifyListeners();
  }
}
