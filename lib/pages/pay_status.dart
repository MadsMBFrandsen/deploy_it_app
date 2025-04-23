import 'package:flutter/material.dart';
import 'package:deploy_it_app/components/navigation_bar.dart';
import 'package:deploy_it_app/components/api_calls.dart';

class PayStatus extends StatefulWidget {
  const PayStatus({super.key});

  @override
  State<PayStatus> createState() => _PayStatusState();
}

class _PayStatusState extends State<PayStatus> {
  bool loading = true;
  bool hasPaid = false;
  bool isOverdue = false;
  String nextPayment = "";
  int daysRemaining = 0;

  @override
  void initState() {
    super.initState();
    fetchPaymentStatus();
  }

  void fetchPaymentStatus() async {
    try {
      final response = await ApiService.getPaymentStatus();

      final data = response['data'];

      setState(() {
        hasPaid = data['is_paid'] ?? false;
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to fetch payment status")),
      );

    }
  }



  @override
  Widget build(BuildContext context) {
    return NavigationBarCustom(
      body: SafeArea(
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(right: 16.0),
                    child: Text(
                      'Payment Status',
                      style: TextStyle(fontSize: 24),
                    ),
                  ),
                  Icon(
                    hasPaid ? Icons.check_circle : Icons.error,
                    color: hasPaid ? Colors.green : Colors.red,
                    size: 30,
                  )
                ],
              ),
              const SizedBox(height: 20),
              Text(
                hasPaid
                    ? "Your payment is up-to-date."
                    : "You have not paid yet.",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: hasPaid ? Colors.green : Colors.red,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}