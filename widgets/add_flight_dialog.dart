import 'package:flutter/material.dart';
import 'package:safar_kaab/models/flight.dart';

class AddFlightDialog extends StatefulWidget {
  final String flightType;

  const AddFlightDialog({
    super.key,
    required this.flightType,
  });

  @override
  State<AddFlightDialog> createState() => _AddFlightDialogState();
}

class _AddFlightDialogState extends State<AddFlightDialog> {
  final _formKey = GlobalKey<FormState>();
  final _fromCityController = TextEditingController();
  final _fromCodeController = TextEditingController();
  final _toCityController = TextEditingController();
  final _toCodeController = TextEditingController();
  final _airlineController = TextEditingController();
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();
  final _priceController = TextEditingController();
  final _seatsController = TextEditingController();

  @override
  void dispose() {
    _fromCityController.dispose();
    _fromCodeController.dispose();
    _toCityController.dispose();
    _toCodeController.dispose();
    _airlineController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    _priceController.dispose();
    _seatsController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _dateController.text =
            "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _timeController.text =
            "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add ${widget.flightType} Flight'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // From City
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _fromCityController,
                      decoration: const InputDecoration(
                        labelText: 'From City',
                        hintText: 'e.g. London',
                      ),
                      validator: (value) => value?.isEmpty ?? true
                          ? 'Please enter departure city'
                          : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _fromCodeController,
                      decoration: const InputDecoration(
                        labelText: 'Code',
                        hintText: 'e.g. LHR',
                      ),
                      validator: (value) => value?.isEmpty ?? true
                          ? 'Please enter city code'
                          : null,
                      textCapitalization: TextCapitalization.characters,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // To City
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _toCityController,
                      decoration: const InputDecoration(
                        labelText: 'To City',
                        hintText: 'e.g. Dubai',
                      ),
                      validator: (value) => value?.isEmpty ?? true
                          ? 'Please enter arrival city'
                          : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _toCodeController,
                      decoration: const InputDecoration(
                        labelText: 'Code',
                        hintText: 'e.g. DXB',
                      ),
                      validator: (value) => value?.isEmpty ?? true
                          ? 'Please enter city code'
                          : null,
                      textCapitalization: TextCapitalization.characters,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Airline
              TextFormField(
                controller: _airlineController,
                decoration: const InputDecoration(
                  labelText: 'Airline',
                  hintText: 'e.g. Emirates',
                ),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Please enter airline' : null,
              ),
              const SizedBox(height: 16),
              // Date and Time
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _dateController,
                      decoration: const InputDecoration(
                        labelText: 'Date',
                        hintText: 'YYYY-MM-DD',
                      ),
                      readOnly: true,
                      onTap: () => _selectDate(context),
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'Please select date' : null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _timeController,
                      decoration: const InputDecoration(
                        labelText: 'Time',
                        hintText: 'HH:MM',
                      ),
                      readOnly: true,
                      onTap: () => _selectTime(context),
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'Please select time' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Price and Seats
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _priceController,
                      decoration: const InputDecoration(
                        labelText: 'Price',
                        prefixText: '\$',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value?.isEmpty ?? true) return 'Please enter price';
                        if (double.tryParse(value!) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _seatsController,
                      decoration: const InputDecoration(
                        labelText: 'Seats',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value?.isEmpty ?? true) return 'Please enter seats';
                        if (int.tryParse(value!) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState?.validate() ?? false) {
              final flight = Flight(
                type: widget.flightType,
                fromCity: _fromCityController.text,
                fromCode: _fromCodeController.text.toUpperCase(),
                toCity: _toCityController.text,
                toCode: _toCodeController.text.toUpperCase(),
                airline: _airlineController.text,
                date: _dateController.text,
                time: _timeController.text,
                price: double.parse(_priceController.text),
                seats: int.parse(_seatsController.text),
              );
              Navigator.pop(context, flight);
            }
          },
          child: const Text('Add Flight'),
        ),
      ],
    );
  }
}
