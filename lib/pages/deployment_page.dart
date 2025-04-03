import 'package:flutter/material.dart';

import '../components/navigation_bar.dart';


class DeploymentPage extends StatelessWidget {
  const DeploymentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return NavigationBarCustom(
      body: Center(
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
  final descriptionController = TextEditingController();

  String? selectedConfigId;
  Map<String, int>? selectedHardware;

  final Map<String, dynamic> vmConfigurations = {
    "9000": {
      "name": "default vm config",
      "desc": "A default config",
      "hardware": {"memory": 2, "processers": 1, "cores": 2, "disksize": 30}
    },
    "9100": {
      "name": "Basic VPS",
      "desc": "A starter VPS configuration",
      "hardware": {"memory": 4, "processers": 1, "cores": 2, "disksize": 50}
    },
    "9200": {
      "name": "Standard VPS",
      "desc": "A mid-tier VPS configuration",
      "hardware": {"memory": 8, "processers": 1, "cores": 4, "disksize": 100}
    },
    "9300": {
      "name": "Premium VPS",
      "desc": "A high-performance VPS configuration",
      "hardware": {"memory": 16, "processers": 1, "cores": 8, "disksize": 250}
    },
  };

  Map<String, bool> packages = {
    'Node.js': false,
    'PHP': false,
    'Python': false,
    'Docker': false,
  };

  void applyConfiguration(String configId) {
    final config = vmConfigurations[configId];
    if (config != null) {
      final hw = config['hardware'];

      setState(() {
        nameController.text = config['name'] ?? '';
        descriptionController.text = config['desc'] ?? '';
        selectedHardware = {
          'cores': hw['cores'],
          'ram': hw['memory'],
          'storage': hw['disksize']
        };
      });
    }
  }

  Widget buildHardwareInfo() {
    if (selectedHardware == null) return SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Hardware Info", style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        Text("Cores: ${selectedHardware!['cores']}"),
        Text("RAM: ${selectedHardware!['ram']} GB"),
        Text("Storage: ${selectedHardware!['storage']} GB"),
        SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            DropdownButtonFormField<String>(
              value: vmConfigurations.containsKey(selectedConfigId)
                  ? selectedConfigId
                  : null,
              decoration: InputDecoration(labelText: 'Select a VM Configuration'),
              items: vmConfigurations.entries.map((entry) {
                return DropdownMenuItem(
                  value: entry.key,
                  child: Text(entry.value['name']),
                );
              }).toList(),
              onChanged: (value) {
                selectedConfigId = value;
                applyConfiguration(value!);
              },
            ),
            TextFormField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'VM Name'),
              readOnly: true,
            ),
            TextFormField(
              controller: descriptionController,
              decoration: InputDecoration(labelText: 'VM Description'),
              readOnly: true,
            ),
            SizedBox(height: 16),
            buildHardwareInfo(),
            Text('Select Packages:', style: TextStyle(fontWeight: FontWeight.bold)),
            ...packages.keys.map((pkg) {
              return CheckboxListTile(
                title: Text(pkg),
                value: packages[pkg],
                onChanged: (bool? value) {
                  setState(() {
                    packages[pkg] = value ?? false;
                  });
                },
              );
            }).toList(),
            SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green, // Button background
                foregroundColor: Colors.black, // Text color
              ),
              onPressed: () {
                if (_formKey.currentState!.validate() && selectedHardware != null) {
                  final selectedPackages = packages.entries
                      .where((entry) => entry.value)
                      .map((entry) => entry.key)
                      .toList();

                  print('Creating VM:');
                  print('Name: ${nameController.text}');
                  print('Description: ${descriptionController.text}');
                  print('Cores: ${selectedHardware!['cores']}');
                  print('RAM: ${selectedHardware!['ram']} GB');
                  print('Storage: ${selectedHardware!['storage']} GB');
                  print('Packages: $selectedPackages');

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('VM Created Successfully')),
                  );
                }
              },
              child: Text('Create VM',style: TextStyle(fontSize: 20,color: Colors.white)),
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
  final descriptionController = TextEditingController();

  Map<String, dynamic>? config;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchConfigFromApi();
  }

  // Simulated API fetch
  void fetchConfigFromApi() async {
    await Future.delayed(Duration(seconds: 1)); // fake delay
    // fake data
    final fakeApiResponse = {
      "id": "9200",
      "name": "Standard VPS",
      "desc": "A mid-tier VPS configuration",
      "hardware": {
        "memory": 8,
        "cores": 4,
        "disksize": 100,
        "processers": 1
      }
    };

    setState(() {
      config = fakeApiResponse;
      nameController.text = config!['name'];
      descriptionController.text = config!['desc'];
      isLoading = false;
    });
  }

  Widget buildHardwareInfo() {
    if (config == null) return SizedBox.shrink();
    final hw = config!['hardware'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Hardware Info", style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        Text("Cores: ${hw['cores']}"),
        Text("RAM: ${hw['memory']} GB"),
        Text("Storage: ${hw['disksize']} GB"),
        SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    return Padding(
      padding: EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            TextFormField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'VM Name'),
              validator: (value) => value!.isEmpty ? 'Enter VM Name' : null,
            ),
            TextFormField(
              controller: descriptionController,
              decoration: InputDecoration(labelText: 'VM Description'),
              validator: (value) => value!.isEmpty ? 'Enter Description' : null,
            ),
            SizedBox(height: 16),
            buildHardwareInfo(),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue, // Button background
                foregroundColor: Colors.black, // Text color
              ),
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  final updatedData = {
                    "name": nameController.text,
                    "desc": descriptionController.text,
                    "hardware": config!['hardware'],
                  };

                  print("Updated VM Config:");
                  print(updatedData);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('VM Updated Successfully')),
                  );
                }
              },
              child: Text('Save Changes', style: TextStyle(fontSize: 20,color: Colors.white),),
            ),
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
  Map<String, dynamic>? config;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchConfigFromApi();
  }

  void fetchConfigFromApi() async {
    await Future.delayed(Duration(seconds: 1)); // Simulate API delay
    final fakeApiResponse = {
      "id": "9300",
      "name": "Premium VPS",
      "desc": "A high-performance VPS configuration",
      "hardware": {
        "memory": 16,
        "cores": 8,
        "disksize": 250,
        "processers": 1
      }
    };

    setState(() {
      config = fakeApiResponse;
      isLoading = false;
    });
  }

  void confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Confirm Delete"),
        content: Text("Are you sure you want to delete this VM configuration?"),
        actions: [
          TextButton(
            child: Text("Cancel"),
            onPressed: () => Navigator.pop(context, false),
          ),
          ElevatedButton(
            child: Text("Delete"),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      print("Deleted VM Config ID: ${config!['id']}");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("VM Configuration Deleted")),
      );
      // ⏳ Wait for 1.5 seconds before navigating to Create tab
      await Future.delayed(Duration(seconds: 1, milliseconds: 500));
      DefaultTabController.of(context).animateTo(0);

    } else {
      print("Delete cancelled.");
    }
  }

  Widget buildReadonlyField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        SizedBox(height: 4),
        Text(value),
        SizedBox(height: 12),
      ],
    );
  }

  Widget buildHardwareInfo() {
    if (config == null) return SizedBox.shrink();
    final hw = config!['hardware'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Hardware Info", style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        Text("Cores: ${hw['cores']}"),
        Text("RAM: ${hw['memory']} GB"),
        Text("Storage: ${hw['disksize']} GB"),
        SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return Center(child: CircularProgressIndicator());

    return Padding(
      padding: EdgeInsets.all(16),
      child: ListView(
        children: [
          buildReadonlyField("VM Name", config!['name']),
          buildReadonlyField("Description", config!['desc']),
          buildHardwareInfo(),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: confirmDelete,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text("Delete VM",style: TextStyle(fontSize: 20,color: Colors.white), ),
          )
        ],
      ),
    );
  }
}
