import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // <-- Added
import '../components/navigation_bar.dart';
import '../components/api_calls_temp.dart';
import '../components/vm_provider.dart';
import '../pages/status_page.dart';


// Helper function
Map<String, dynamic> mapConfig(Map<String, dynamic> config) {
  return {
    ...config,
    'hardware': {
      'cores': config['hardware']['cores'],
      'memory': config['hardware']['memory'],
      'disksize': config['hardware']['disksize'],
    },
  };
}


class DeploymentPage extends StatelessWidget {
  const DeploymentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return NavigationBarCustom(
      body: SafeArea(
        child: Center(
          child: DefaultTabController(
            length: 3,
            child: Scaffold(
              appBar: AppBar(
                title: const Text('Deployment'),
                bottom: const TabBar(
                  tabs: [
                    Tab(text: 'Create'),
                    Tab(text: 'Update'),
                    Tab(text: 'Delete'),
                  ],
                ),
              ),
              body: const TabBarView(
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

// CREATE TAB
class CreateTab extends StatefulWidget {
  const CreateTab({super.key});

  @override
  _CreateTabState createState() => _CreateTabState();
}

class _CreateTabState extends State<CreateTab> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final descController = TextEditingController();
  List<Map<String, dynamic>> vmConfigs = [];
  Map<String, dynamic>? selectedConfig;
  List<Map<String, dynamic>> availablePackages = [];
  List<String> selectedPackageIds = [];
  bool loadingConfigs = true;
  bool loadingPackages = true;

  @override
  void initState() {
    super.initState();
    loadVMConfigs();
    loadPackages();
  }

  void loadVMConfigs() async {
    final configs = await ApiService.fetchAllVMConfigs();
    setState(() {
      vmConfigs = configs.map(mapConfig).toList();
      selectedConfig = vmConfigs.isNotEmpty ? vmConfigs.first : null;
      loadingConfigs = false;
    });
  }

  void loadPackages() async {
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() {
      availablePackages = [
        {'id': 'fake-uuid-nodejs', 'name': 'Node.js'},
        {'id': 'fake-uuid-php', 'name': 'PHP'},
        {'id': 'fake-uuid-python', 'name': 'Python'},
      ];
      loadingPackages = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loadingConfigs || loadingPackages) {
      return const Center(child: CircularProgressIndicator());
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            TextFormField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "VM Name"),
              validator: (val) => val == null || val.isEmpty ? "Enter name" : null,
            ),
            TextFormField(
              controller: descController,
              decoration: const InputDecoration(labelText: "Description"),
              validator: (val) => val == null || val.isEmpty ? "Enter description" : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: selectedConfig?['id'],
              decoration: const InputDecoration(labelText: "Choose Configuration"),
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
            const SizedBox(height: 16),
            if (selectedConfig != null) ...[
              Text("Memory: ${selectedConfig!['hardware']['memory']} GB"),
              Text("Cores: ${selectedConfig!['hardware']['cores']}"),
              Text("Disk: ${selectedConfig!['hardware']['disksize']} GB"),
            ],
            const SizedBox(height: 16),
            const Text("Select Packages"),
            ...availablePackages.map((pkg) {
              return CheckboxListTile(
                title: Text(pkg['name']),
                value: selectedPackageIds.contains(pkg['id']),
                onChanged: (val) {
                  setState(() {
                    if (val == true) {
                      selectedPackageIds.add(pkg['id']);
                    } else {
                      selectedPackageIds.remove(pkg['id']);
                    }
                  });
                },
              );
            }).toList(),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  try {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (_) => const Center(child: CircularProgressIndicator()),
                    );

                    final vmData = {
                      "name": nameController.text,
                      "description": descController.text,
                      "instance_type": "server",
                      "server_configuration": {
                        "id": selectedConfig!['id'],
                        "name": selectedConfig!['name'],
                        "description": selectedConfig!['description'],
                        "cores": selectedConfig!['hardware']['cores'],
                        "memory": selectedConfig!['hardware']['memory'],
                        "disk_space": selectedConfig!['hardware']['disksize'],
                        "proxmox_configuration_id": int.tryParse(selectedConfig!['proxmox_configuration_id'].toString()) ?? 0, // ✅ fixed
                      },
                      "selected_packages": selectedPackageIds,
                    };


                    final res = await ApiService.createVM(vmData);

                    if (!mounted) return;

                    final resData = jsonDecode(res.body);

                    if (res.statusCode == 200 || res.statusCode == 201) {
                      final newVmId = resData['id'] ?? DateTime.now().millisecondsSinceEpoch.toString();

                      Provider.of<VMProvider>(context, listen: false).addVM({
                        'id': newVmId,
                        'name': nameController.text,
                      });

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(resData['message'])),
                      );

                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => StatusPage(selectedVmId: newVmId),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Failed to create VM')),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: ${e.toString()}')),
                      );
                    }
                  } finally {
                    if (mounted) Navigator.of(context, rootNavigator: true).pop();
                  }
                }
              },
              child: const Text("Create VM"),
            ),
          ],
        ),
      ),
    );
  }
}

// UPDATE TAB
class UpdateTab extends StatefulWidget {
  const UpdateTab({super.key});

  @override
  _UpdateTabState createState() => _UpdateTabState();
}

class _UpdateTabState extends State<UpdateTab> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final descController = TextEditingController();
  Map<String, dynamic>? selectedConfig;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loading = false;
  }

  @override
  Widget build(BuildContext context) {
    final configs = context.watch<VMProvider>().vms;

    if (loading) return const Center(child: CircularProgressIndicator());

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            DropdownButtonFormField<String>(
              value: selectedConfig?['id'],
              decoration: const InputDecoration(labelText: "Select VM to Update"),
              items: configs.map<DropdownMenuItem<String>>((c) {
                return DropdownMenuItem<String>(
                  value: c['id'],
                  child: Text(c['name']),
                );
              }).toList(),
              onChanged: (id) {
                final config = configs.firstWhere((c) => c['id'] == id);
                setState(() {
                  selectedConfig = config;
                  nameController.text = config['name'];
                  descController.text = config['desc'] ?? '';
                });
              },
            ),
            if (selectedConfig != null) ...[
              const SizedBox(height: 12),
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "VM Name"),
                validator: (val) => val == null || val.isEmpty ? "Enter name" : null,
              ),
              TextFormField(
                controller: descController,
                decoration: const InputDecoration(labelText: "Description"),
                validator: (val) => val == null || val.isEmpty ? "Enter description" : null,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    try {
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (_) => const Center(child: CircularProgressIndicator()),
                      );

                      final res = await ApiService.updateVM(selectedConfig!['id'], {
                        "name": nameController.text,
                        "desc": descController.text,
                      });

                      if (!mounted) return;
                      final resData = jsonDecode(res.body);

                      if (res.statusCode == 200) {
                        Provider.of<VMProvider>(context, listen: false).updateVM(
                          selectedConfig!['id'],
                          {
                            'id': selectedConfig!['id'],
                            'name': nameController.text,
                          },
                        );

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(resData['message'])),
                        );

                        setState(() {
                          selectedConfig = null;
                          nameController.clear();
                          descController.clear();
                        });
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: ${e.toString()}')),
                        );
                      }
                    } finally {
                      if (mounted) Navigator.of(context, rootNavigator: true).pop();
                    }
                  }
                },
                child: const Text("Update VM"),
              ),
            ]
          ],
        ),
      ),
    );
  }
}

// DELETE TAB
class DeleteTab extends StatefulWidget {
  const DeleteTab({super.key});

  @override
  _DeleteTabState createState() => _DeleteTabState();
}

class _DeleteTabState extends State<DeleteTab> {
  Map<String, dynamic>? selectedConfig;

  @override
  Widget build(BuildContext context) {
    final configs = context.watch<VMProvider>().vms;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
          DropdownButtonFormField<String>(
            value: selectedConfig?['id'],
            decoration: const InputDecoration(labelText: "Select VM to Delete"),
            items: configs.map<DropdownMenuItem<String>>((c) {
              return DropdownMenuItem<String>(
                value: c['id'],
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
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text("Delete VM"),
                    content: const Text("Are you sure you want to delete this VM?"),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Cancel")),
                      ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text("Delete")),
                    ],
                  ),
                );

                if (confirm == true) {
                  try {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (_) => const Center(child: CircularProgressIndicator()),
                    );

                    final res = await ApiService.deleteVM(selectedConfig!['id']);
                    final resData = jsonDecode(res.body);

                    if (res.statusCode == 200) {
                      Provider.of<VMProvider>(context, listen: false).deleteVM(selectedConfig!['id']);

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(resData['message'])),
                      );

                      setState(() {
                        selectedConfig = null;
                      });
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: ${e.toString()}')),
                    );
                  } finally {
                    if (mounted) Navigator.of(context, rootNavigator: true).pop();
                  }
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text("Delete VM"),
            ),
          ]
        ],
      ),
    );
  }
}
