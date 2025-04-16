import 'dart:convert';
import 'package:flutter/material.dart';
import '../components/navigation_bar.dart';
import '../components/api_calls_temp.dart';

class DeploymentPage extends StatelessWidget {
  const DeploymentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return NavigationBarCustom(
      body: SafeArea(
        child: Center(
          child: DefaultTabController(
            length: 3, // Number of tabs
            child: Scaffold(
              appBar: AppBar(
                title: Text('Deployment'),
                bottom: TabBar(
                  tabs: [
                    Tab(text: 'Create'),
                    Tab(text: 'Update'),
                    Tab(text: 'Delete'),
                  ],
                ),
              ),
              body: TabBarView(
                children: [
                  CreateTab(),
                  UpdateTab(),
                  DeleteTab(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Widgets for each tab content

class CreateTab extends StatefulWidget {
  @override
  _CreateTabState createState() => _CreateTabState();
}

class _CreateTabState extends State<CreateTab> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final descController = TextEditingController();

  List<Map<String, dynamic>> vmConfigs = [];
  Map<String, dynamic>? selectedConfig;
  List<String> packages = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadVMConfigs();
  }

  void loadVMConfigs() async {
    final configs = await ApiService.fetchAllVMConfigs();
    setState(() {
      vmConfigs = configs;
      selectedConfig = configs.isNotEmpty ? configs.first : null;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return Center(child: CircularProgressIndicator());

    return Padding(
      padding: EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            TextFormField(
              controller: nameController,
              decoration: InputDecoration(labelText: "VM Name"),
              validator: (val) => val!.isEmpty ? "Enter name" : null,
            ),
            TextFormField(
              controller: descController,
              decoration: InputDecoration(labelText: "Description"),
              validator: (val) => val!.isEmpty ? "Enter description" : null,
            ),
            SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: selectedConfig?['id'],
              decoration: InputDecoration(labelText: "Choose Configuration"),
              items: vmConfigs.map((config) {
                return DropdownMenuItem<String>(
                  value: config['id'],
                  child: Text(config['name']),
                );
              }).toList(),
              onChanged: (id) {
                final config = vmConfigs.firstWhere((c) => c['id'] == id);
                setState(() => selectedConfig = config);
              },
            ),
            SizedBox(height: 16),
            if (selectedConfig != null) ...[
              Text("Memory: ${selectedConfig!['hardware']['memory']} GB"),
              Text("Cores: ${selectedConfig!['hardware']['cores']}"),
              Text("Disk: ${selectedConfig!['hardware']['disksize']} GB"),
            ],
            SizedBox(height: 16),
            Text("Select Packages"),
            ...["Node.js", "PHP", "Python"].map((pkg) {
              return CheckboxListTile(
                title: Text(pkg),
                value: packages.contains(pkg),
                onChanged: (val) {
                  setState(() {
                    if (val == true) {
                      packages.add(pkg);
                    } else {
                      packages.remove(pkg);
                    }
                  });
                },
              );
            }).toList(),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  final vmData = {
                    "name": nameController.text,
                    "desc": descController.text,
                    "hardware": selectedConfig!['hardware'],
                    "packages": packages
                  };
                  final res = await ApiService.createVM(vmData);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(jsonDecode(res.body)['message'])),
                  );
                }
              },
              child: Text("Create VM"),
            ),
          ],
        ),
      ),
    );
  }
}


class UpdateTab extends StatefulWidget {
  @override
  _UpdateTabState createState() => _UpdateTabState();
}

class _UpdateTabState extends State<UpdateTab> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final descController = TextEditingController();

  List<Map<String, dynamic>> configs = [];
  Map<String, dynamic>? selectedConfig;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadConfigs();
  }

  void loadConfigs() async {
    final newConfigs = await ApiService.vmconfig();

    setState(() {
      configs = newConfigs;
      loading = false;

      if (selectedConfig != null) {
        final matched = newConfigs.where((c) => c['id'] == selectedConfig!['id']).toList();
        selectedConfig = matched.isNotEmpty ? matched.first : null;
      }
    });
  }



  void onSelect(String? id) {
    final config = configs.firstWhere((c) => c['id'] == id);
    setState(() {
      selectedConfig = config;
      nameController.text = config['name'];
      descController.text = config['desc'];
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return Center(child: CircularProgressIndicator());

    return Padding(
      padding: EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            DropdownButtonFormField<String>(
              value: selectedConfig?['id'],
              decoration: InputDecoration(labelText: "Select VM to Update"),
              items: configs.map<DropdownMenuItem<String>>((c) {
                return DropdownMenuItem<String>(
                  value: c['id'] as String,
                  child: Text(c['name']),
                );
              }).toList(),
              onChanged: onSelect,
            ),
            if (selectedConfig != null) ...[
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(labelText: "VM Name"),
                validator: (val) => val!.isEmpty ? "Enter name" : null,
              ),
              TextFormField(
                controller: descController,
                decoration: InputDecoration(labelText: "Description"),
                validator: (val) => val!.isEmpty ? "Enter description" : null,
              ),
              SizedBox(height: 16),
              Text("Cores: ${selectedConfig!['hardware']['cores']}"),
              Text("RAM: ${selectedConfig!['hardware']['memory']} GB"),
              Text("Storage: ${selectedConfig!['hardware']['disksize']} GB"),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final res = await ApiService.updateVM(selectedConfig!['id'], {
                      "name": nameController.text,
                      "desc": descController.text,
                      "hardware": selectedConfig!['hardware'],
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(jsonDecode(res.body)['message'])),
                    );

                    // Refresh the VM list and selection
                    loadConfigs(); // Refresh list
                    setState(() {
                      selectedConfig = null;
                      nameController.clear();
                      descController.clear();
                    });
                  }
                },
                child: Text("Update VM"),
              ),
            ]
          ],
        ),
      ),
    );
  }
}


class DeleteTab extends StatefulWidget {
  @override
  _DeleteTabState createState() => _DeleteTabState();
}

class _DeleteTabState extends State<DeleteTab> {
  List<Map<String, dynamic>> configs = [];
  Map<String, dynamic>? selectedConfig;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadConfigs();
  }

  void loadConfigs() async {
    final newConfigs = await ApiService.vmconfig();

    setState(() {
      configs = newConfigs;
      loading = false;

      if (selectedConfig != null) {
        final matched = newConfigs.where((c) => c['id'] == selectedConfig!['id']).toList();
        selectedConfig = matched.isNotEmpty ? matched.first : null;
      }
    });
  }


  void confirmDelete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Delete VM"),
        content: Text("Are you sure you want to delete this VM?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text("Cancel")),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: Text("Delete")),
        ],
      ),
    );

    if (confirm == true) {
      final res = await ApiService.deleteVM(selectedConfig!['id']);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(jsonDecode(res.body)['message'])),
      );

      // Clear selection and reload list
      setState(() {
        selectedConfig = null;
        loading = true;
      });
      loadConfigs(); // Reload updated list
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return Center(child: CircularProgressIndicator());

    return Padding(
      padding: EdgeInsets.all(16),
      child: ListView(
        children: [
          DropdownButtonFormField<String>(
            value: selectedConfig?['id'],
            decoration: InputDecoration(labelText: "Select VM to Delete"),
            items: configs.map<DropdownMenuItem<String>>((c) {
              return DropdownMenuItem<String>(
                value: c['id'] as String,
                child: Text(c['name']),
              );
            }).toList(),
            onChanged: (id) {
              setState(() {
                selectedConfig = configs.firstWhere((c) => c['id'] == id);
              });
            },
          ),
          if (selectedConfig != null) ...[
            SizedBox(height: 12),
            Text("Name: ${selectedConfig!['name']}"),
            Text("Desc: ${selectedConfig!['desc']}"),
            Text("Cores: ${selectedConfig!['hardware']['cores']}"),
            Text("RAM: ${selectedConfig!['hardware']['memory']} GB"),
            Text("Storage: ${selectedConfig!['hardware']['disksize']} GB"),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: confirmDelete,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text("Delete VM"),
            ),
          ]
        ],
      ),
    );
  }
}
