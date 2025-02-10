class Flight {
  final String? id;
  final String type;
  final String fromCity;
  final String fromCode;
  final String toCity;
  final String toCode;
  final String airline;
  final String date;
  final String time;
  final double price;
  final int seats;
  final DateTime? createdAt;

  Flight({
    this.id,
    required this.type,
    required this.fromCity,
    required this.fromCode,
    required this.toCity,
    required this.toCode,
    required this.airline,
    required this.date,
    required this.time,
    required this.price,
    required this.seats,
    this.createdAt,
  });

  factory Flight.fromMap(Map<String, dynamic> map) {
    return Flight(
      id: map['id']?.toString(),
      type: map['type'] ?? '',
      fromCity: map['fromCity'] ?? '',
      fromCode: map['fromCode'] ?? '',
      toCity: map['toCity'] ?? '',
      toCode: map['toCode'] ?? '',
      airline: map['airline'] ?? '',
      date: map['date'] ?? '',
      time: map['time'] ?? '',
      price: (map['price'] is int) ? (map['price'] as int).toDouble() : (map['price'] as num).toDouble(),
      seats: map['seats'] as int? ?? 0,
      createdAt: map['createdAt'] != null ? DateTime.parse(map['createdAt']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'type': type,
      'fromCity': fromCity,
      'fromCode': fromCode,
      'toCity': toCity,
      'toCode': toCode,
      'airline': airline,
      'date': date,
      'time': time,
      'price': price,
      'seats': seats,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
    };
  }

  Flight copyWith({
    String? id,
    String? type,
    String? fromCity,
    String? fromCode,
    String? toCity,
    String? toCode,
    String? airline,
    String? date,
    String? time,
    double? price,
    int? seats,
    DateTime? createdAt,
  }) {
    return Flight(
      id: id ?? this.id,
      type: type ?? this.type,
      fromCity: fromCity ?? this.fromCity,
      fromCode: fromCode ?? this.fromCode,
      toCity: toCity ?? this.toCity,
      toCode: toCode ?? this.toCode,
      airline: airline ?? this.airline,
      date: date ?? this.date,
      time: time ?? this.time,
      price: price ?? this.price,
      seats: seats ?? this.seats,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
