import 'package:dulimad_diyarid/helpers/database_helper.dart';
import 'package:dulimad_diyarid/models/flight.dart';
import 'package:dulimad_diyarid/models/user.dart';
import 'package:flutter/material.dart';


class PaymentPage extends StatefulWidget {
  final Flight flight;
  final User user;

  const PaymentPage({
    Key? key,
    required this.flight,
    required this.user,
  }) : super(key: key);

  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  final _referenceController = TextEditingController();
  bool _isProcessing = false;

  Future<void> _submitPayment() async {
    setState(() {
      _isProcessing = true;
    });

    final reference = _referenceController.text.trim();
    if (reference.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter reference number')),
      );
      setState(() {
        _isProcessing = false;
      });
      return;
    }

    final ticket = {
      'flightId': widget.flight.id,
      'userId': widget.user.id,
      'reference': reference,
      'status': 'pending',
      'createdAt': DateTime.now().toIso8601String(),
    };

    try {
      await DatabaseHelper().createTicket(ticket);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment submitted successfully!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Payment',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 255, 208, 0),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Flight Details',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const Divider(),
                    Text(
                      '${widget.flight.fromCity} (${widget.flight.fromCode}) → ${widget.flight.toCity} (${widget.flight.toCode})',
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Date: ${widget.flight.date}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    Text(
                      'Time: ${widget.flight.time}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Amount to Pay: \$${widget.flight.price.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _referenceController,
              decoration: const InputDecoration(
                labelText: 'Payment Reference Number',
                hintText: 'Enter the reference number from your payment',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isProcessing ? null : _submitPayment,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isProcessing
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      'Submit Payment',
                      style: TextStyle(fontSize: 18),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
