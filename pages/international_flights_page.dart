import 'package:dulimad_diyarid/helpers/database_helper.dart';
import 'package:dulimad_diyarid/models/flight.dart';
import 'package:dulimad_diyarid/models/user.dart';
import 'package:dulimad_diyarid/pages/payments_page.dart';
import 'package:dulimad_diyarid/widgets/add_flight_dialog.dart';
import 'package:dulimad_diyarid/widgets/flight_card.dart';
import 'package:dulimad_diyarid/widgets/logout_button.dart';
import 'package:flutter/material.dart';


class InternationalFlightsPage extends StatefulWidget {
  final User user;

  const InternationalFlightsPage({
    super.key,
    required this.user,
  });

  @override
  State<InternationalFlightsPage> createState() =>
      _InternationalFlightsPageState();
}

class _InternationalFlightsPageState extends State<InternationalFlightsPage> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  List<Flight> _flights = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFlights();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadFlights(); // Reload flights when dependencies change
  }

  Future<void> _loadFlights() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final flights = await _databaseHelper.getFlights('international');
      if (mounted) {
        setState(() {
          _flights =
              flights.map((flightData) => Flight.fromMap(flightData)).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading flights: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading flights: $e')),
        );
      }
    }
  }

  Future<void> _bookFlight(Flight flight) async {
    if (flight.seats <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No seats available')),
      );
      return;
    }

    // Navigate to the PaymentPage when booking a flight
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentPage(
          flight: flight,
          user: widget.user,
        ),
      ),
    );
  }

  Future<void> _addFlight() async {
    if (!widget.user.isAdmin) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Only admins can add flights')),
      );
      return;
    }

    final Flight? newFlight = await showDialog<Flight>(
      context: context,
      builder: (context) => const AddFlightDialog(flightType: 'international'),
    );

    if (newFlight != null) {
      try {
        print('Attempting to add flight: ${newFlight.toMap()}');
        await _databaseHelper.insertFlight(newFlight.toMap());
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Flight added successfully')),
          );
        }
        _loadFlights(); // Reload the flights list
      } catch (e) {
        print('Error adding flight: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Failed to add flight: ${e.toString().replaceAll('Exception: ', '')}'),
              duration: const Duration(seconds: 5),
            ),
          );
        }
      }
    } else {
      print('No flight was returned from the dialog');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'International Flights',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: const [
          LogoutButton(),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _flights.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.airplanemode_inactive,
                        size: 64,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No flights available',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadFlights,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: _flights.length,
                    itemBuilder: (context, index) {
                      final flight = _flights[index];
                      return FlightCard(
                        flight: flight,
                        isAdmin: widget.user.isAdmin == 1,
                        onBook: () => _bookFlight(flight),
                      );
                    },
                  ),
                ),
      floatingActionButton: widget.user.isAdmin
          ? FloatingActionButton(
              onPressed: _addFlight,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
