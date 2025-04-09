import 'package:flutter/material.dart';
import 'package:deploy_it_app/components/navigation_bar.dart';
import 'package:deploy_it_app/components/my_button.dart';
import 'package:deploy_it_app/components/api_calls_temp.dart';
import 'package:fl_chart/fl_chart.dart';
import '../components/circle_usage.dart';

class StatusPage extends StatefulWidget {
  const StatusPage({super.key});

  @override
  _StatusPageState createState() => _StatusPageState();
}

class _StatusPageState extends State<StatusPage> {
  String selectedValue = 'Option 1';

  double cpu = 0.0;
  double ram = 0.0;
  double storage = 0.0;
  List<double> chartData = [];
  List<String> logs = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchStatus();
  }

  Future<void> fetchStatus() async {
    try {
      final data = await ApiService.getStatusData();
      setState(() {
        cpu = data['cpuUsage'];
        ram = data['ramUsage'];
        storage = data['storageUsage'];
        chartData = List<double>.from(data['chartData']);
        logs = List<String>.from(data['logs']);
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to fetch status data")),
      );
    }
  }

  Future<void> edit_VM() async {
    // navigation to deployment
  }

  @override
  Widget build(BuildContext context) {
    return NavigationBarCustom(
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 50),
              const Text('Status', style: TextStyle(fontSize: 24)),
              const SizedBox(height: 25),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: MyButton(
                      onTap: () => edit_VM(),
                      text: 'Edit VM',
                      backgroundColor: Colors.blue,
                      textColor: Colors.white,
                      padd: const EdgeInsets.all(5),
                      marg: const EdgeInsets.symmetric(horizontal: 10),
                    ),
                  ),
                  DropdownButton<String>(
                    value: selectedValue,
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedValue = newValue!;
                      });
                    },
                    items: <String>['Option 1', 'Option 2', 'Option 3']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  CircleUsage(label: 'CPU', usage: cpu),
                  CircleUsage(label: 'RAM', usage: ram),
                  CircleUsage(label: 'Storage', usage: storage),
                ],
              ),
              const SizedBox(height: 30),
              Container(
                height: 200,
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: LineChart(
                  LineChartData(
                    lineBarsData: [
                      LineChartBarData(
                        spots: List.generate(
                          chartData.length,
                              (index) => FlSpot(index * 4, chartData[index]),
                        ),
                        isCurved: true,
                        color: Colors.blue,
                        barWidth: 3,
                        belowBarData: BarAreaData(show: false),
                      ),
                    ],
                    minY: 0,
                    maxY: 1,
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 22,
                          interval: 4,
                          getTitlesWidget: (value, meta) => Text('${value.toInt()}h'),
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: 0.25,
                          getTitlesWidget: (value, meta) => Text('${(value * 100).toInt()}%'),
                        ),
                      ),
                    ),
                    gridData: FlGridData(show: true),
                    borderData: FlBorderData(show: false),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: logs.map((log) {
                    return ListTile(
                      leading: const Icon(Icons.warning, color: Colors.red),
                      title: Text(log),
                      subtitle: Text('Timestamp: ${DateTime.now()}'),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
