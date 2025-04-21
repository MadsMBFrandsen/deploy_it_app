import 'dart:convert';
import 'package:flutter/material.dart';
import '../components/navigation_bar.dart';
import '../components/api_calls_temp.dart';
import '../pages/status_page.dart'; // <-- Important for navigation after create

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
    if (loading) return const Center(child: CircularProgressIndicator());

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
                  try {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) => const Center(child: CircularProgressIndicator()),
                    );

                    final vmData = {
                      "name": nameController.text,
                      "desc": descController.text,
                      "hardware": selectedConfig!['hardware'],
                      "packages": packages,
                    };

                    final res = await ApiService.createVM(vmData);

                    if (!mounted) return;

                    final resData = jsonDecode(res.body);

                    if (res.statusCode == 200) {
                      final newVmId = resData['id'];

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(resData['message'])),
                      );

                      await Future.delayed(const Duration(milliseconds: 500));
                      if (!mounted) return;

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
                    if (mounted) {
                      Navigator.of(context, rootNavigator: true).pop();
                    }
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
                  value: c['id'] as String,
                  child: Text(c['name']),
                );
              }).toList(),
              onChanged: onSelect,
            ),
            if (selectedConfig != null) ...[
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
              Text("Cores: ${selectedConfig!['hardware']['cores']}"),
              Text("RAM: ${selectedConfig!['hardware']['memory']} GB"),
              Text("Storage: ${selectedConfig!['hardware']['disksize']} GB"),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    try {
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) => const Center(child: CircularProgressIndicator()),
                      );

                      final res = await ApiService.updateVM(selectedConfig!['id'], {
                        "name": nameController.text,
                        "desc": descController.text,
                        "hardware": selectedConfig!['hardware'],
                      });

                      if (!mounted) return;

                      final resData = jsonDecode(res.body);

                      if (res.statusCode == 200) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(resData['message'])),
                        );

                        loadConfigs();
                        setState(() {
                          selectedConfig = null;
                          nameController.clear();
                          descController.clear();
                        });
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Failed to update VM')),
                        );
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: ${e.toString()}')),
                        );
                      }
                    } finally {
                      if (mounted) {
                        Navigator.of(context, rootNavigator: true).pop();
                      }
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
    });
  }

  void confirmDelete() async {
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
          builder: (context) => const Center(child: CircularProgressIndicator()),
        );

        final res = await ApiService.deleteVM(selectedConfig!['id']);

        if (!mounted) return;

        final resData = jsonDecode(res.body);

        if (res.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(resData['message'])),
          );

          setState(() {
            selectedConfig = null;
            loading = true;
          });

          loadConfigs();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to delete VM')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${e.toString()}')),
          );
        }
      } finally {
        if (mounted) {
          Navigator.of(context, rootNavigator: true).pop();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return const Center(child: CircularProgressIndicator());

    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
          DropdownButtonFormField<String>(
            value: selectedConfig?['id'],
            decoration: const InputDecoration(labelText: "Select VM to Delete"),
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
            const SizedBox(height: 12),
            Text("Name: ${selectedConfig!['name']}"),
            Text("Desc: ${selectedConfig!['desc']}"),
            Text("Cores: ${selectedConfig!['hardware']['cores']}"),
            Text("RAM: ${selectedConfig!['hardware']['memory']} GB"),
            Text("Storage: ${selectedConfig!['hardware']['disksize']} GB"),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: confirmDelete,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text("Delete VM"),
            ),
          ]
        ],
      ),
    );
  }
}
