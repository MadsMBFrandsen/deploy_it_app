import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../components/navigation_bar.dart';
import '../components/circle_usage.dart';
import '../components/api_calls_temp.dart';
import '../components/vm_provider.dart';

class StatusPage extends StatefulWidget {
  final String? selectedVmId;

  const StatusPage({super.key, this.selectedVmId});

  @override
  _StatusPageState createState() => _StatusPageState();
}

class _StatusPageState extends State<StatusPage> {
  String? selectedVmId;
  String? selectedVmName;

  double cpuUsage = 0.0;
  double ramUsage = 0.0;
  double storageUsage = 0.0;
  List<double> chartData = [];
  List<String> logs = [];

  bool loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vmList = Provider.of<VMProvider>(context, listen: false).vms;

      if (vmList.isNotEmpty) {
        final defaultVm = widget.selectedVmId != null
            ? vmList.firstWhere((vm) => vm['id'] == widget.selectedVmId, orElse: () => vmList.first)
            : vmList.first;

        setState(() {
          selectedVmId = defaultVm['id'];
          selectedVmName = defaultVm['name'];
          loading = true;
        });

        fetchVMStatus(defaultVm['id']);
      } else {
        setState(() {
          selectedVmId = null;
          selectedVmName = null;
          loading = false;
        });
      }
    });
  }

  Future<void> fetchVMStatus(String vmId) async {
    try {
      final status = await ApiService.getVMStatus(vmId);

      setState(() {
        cpuUsage = _parsePercentage(status['cpu_usage']);
        ramUsage = _parsePercentage(status['ram_usage']);
        storageUsage = _parsePercentage(status['storage_usage']);
        chartData = (status['chart_data'] as List).map((e) => (e as num).toDouble()).toList();
        logs = List<String>.from(status['logs']);
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load VM status.')),
      );
    }
  }

  double _parsePercentage(String percentStr) {
    return double.tryParse(percentStr.replaceAll('%', ''))! / 100.0;
  }

  @override
  Widget build(BuildContext context) {
    final vmList = context.watch<VMProvider>().vms;

    return NavigationBarCustom(
      body: SafeArea(
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : vmList.isEmpty
            ? const Center(
          child: Text(
            "No VMs available.\nCreate your first VM!",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18),
          ),
        )
            : Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 30),
                const Text('Status', style: TextStyle(fontSize: 24)),
                const SizedBox(height: 20),
                _buildVmDropdown(vmList),
                const SizedBox(height: 16),
                if (selectedVmName != null) _buildSelectedVmText(),
                _buildUsageIndicators(),
                const SizedBox(height: 30),
                _buildUsageChart(),
                const SizedBox(height: 30),
                _buildLogsSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVmDropdown(List<Map<String, dynamic>> vmList) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('Select VM: ', style: TextStyle(fontSize: 16)),
        const SizedBox(width: 8),
        DropdownButton<String>(
          value: selectedVmId,
          onChanged: (String? newId) {
            final vm = vmList.firstWhere((vm) => vm['id'] == newId);
            setState(() {
              selectedVmId = newId;
              selectedVmName = vm['name'];
              loading = true;
            });
            fetchVMStatus(newId!);
          },
          items: vmList.map<DropdownMenuItem<String>>((vm) {
            return DropdownMenuItem<String>(
              value: vm['id'],
              child: Text(vm['name']),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSelectedVmText() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Text(
        'Selected VM: $selectedVmName',
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: Colors.blueGrey,
        ),
      ),
    );
  }

  Widget _buildUsageIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        CircleUsage(label: 'CPU', usage: cpuUsage),
        CircleUsage(label: 'RAM', usage: ramUsage),
        CircleUsage(label: 'Storage', usage: storageUsage),
      ],
    );
  }

  Widget _buildUsageChart() {
    return Container(
      height: 200,
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: LineChart(
        LineChartData(
          lineBarsData: [
            LineChartBarData(
              spots: List.generate(
                chartData.length,
                    (i) => FlSpot(i.toDouble(), chartData[i] / 100),
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
                interval: 1,
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
    );
  }

  Widget _buildLogsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Recent Logs',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 10),
        if (logs.isEmpty)
          const Text('No logs available.')
        else
          ...logs.map(
                (log) => ListTile(
              leading: const Icon(Icons.info_outline, color: Colors.orange),
              title: Text(log),
              subtitle: Text(
                'Timestamp: ${DateTime.now()}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
          ),
      ],
    );
  }
}
