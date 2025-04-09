import 'package:flutter/material.dart';
import 'package:deploy_it_app/components/navigation_bar.dart';
import 'package:deploy_it_app/components/my_button.dart';
import 'package:fl_chart/fl_chart.dart';

import '../components/circle_usage.dart';


class StatusPage extends StatefulWidget {
  const StatusPage({super.key});

  @override
  _StatusPageState createState() => _StatusPageState();
}

class _StatusPageState extends State<StatusPage> {

  String selectedValue = 'Option 1';

  Future<void> edit_VM() async {
    // edit VM logic here
  }

  @override
  Widget build(BuildContext context) {
    return NavigationBarCustom(
      body: Center(
        child: SingleChildScrollView (
          child: Column(
            children: [
          
              const SizedBox(height: 50),
          
              const Text(
                'Status',
                style: TextStyle(fontSize: 24),
              ),
          
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
                      padd: EdgeInsets.all(5),
                      marg: EdgeInsets.symmetric(horizontal: 10),
                    ),
                  ),
          
                  // const SizedBox(width: 10),
          
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
          
              // row with cpu, ram, Storage monitor
              const SizedBox(height: 30),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: const [
                  CircleUsage(label: 'CPU', usage: 0.75),
                  CircleUsage(label: 'RAM', usage: 0.60),
                  CircleUsage(label: 'Storage', usage: 0.85),
                ],
              ),
          
              const SizedBox(height: 30),
          
              //last 12 - 24 H diagram over use of resources
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
                        spots: [
                          FlSpot(0, 0.3),
                          FlSpot(4, 0.5),
                          FlSpot(8, 0.7),
                          FlSpot(12, 0.6),
                          FlSpot(16, 0.85),
                          FlSpot(20, 0.65),
                          FlSpot(24, 0.75),
                        ],
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
          
          
              // Last 5 Errors / Logs
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: List.generate(5, (index) {
                    return ListTile(
                      leading: const Icon(Icons.warning, color: Colors.red),
                      title: Text('Error ${index + 1}: Something happened'),
                      subtitle: Text('Timestamp: ${DateTime.now().subtract(Duration(minutes: index * 10))}'),
                    );
                  }),
                ),
              ),
          
            ],
          ),
        ),
      ),
    );
  }
}
