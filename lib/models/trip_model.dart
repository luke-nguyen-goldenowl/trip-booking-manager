import 'dart:convert';

class MTrip {
  final int? id;
  final int? routeId;
  final int? busId;
  final int? companyId;
  final int? price;
  final DateTime? departureTime;
  final DateTime? arrivalTime;
  final BusTripStatus status;
  final Map<String, dynamic>? seatLayout;

  MTrip({
    this.id,
    this.routeId,
    this.busId,
    this.companyId,
    this.price,
    this.departureTime,
    this.arrivalTime,
    required this.status,
    this.seatLayout,
  });
  MTrip copyWith({
    int? id,
    int? routeId,
    int? busId,
    int? companyId,
    int? price,
    DateTime? departureTime,
    DateTime? arrivalTime,
    BusTripStatus? status,
    Map<String, dynamic>? seatLayout,
  }) {
    return MTrip(
      id: id ?? this.id,
      routeId: routeId ?? this.routeId,
      busId: busId ?? this.busId,
      companyId: companyId ?? this.companyId,
      price: price ?? this.price,
      departureTime: departureTime ?? this.departureTime,
      arrivalTime: arrivalTime ?? this.arrivalTime,
      status: status ?? this.status,
      seatLayout: seatLayout ?? this.seatLayout,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'route_id': routeId,
      'bus_id': busId,
      'company_id': companyId,
      'price': price,
      'departure_time': departureTime?.toIso8601String(),
      'arrival_time': arrivalTime?.toIso8601String(),
      'status': status.value,
      'seat_layout': seatLayout,
    };
  }

  Map<String, dynamic> toMapLocaldb() {
    return <String, dynamic>{
      'id': id,
      'route_id': routeId,
      'bus_id': busId,
      'company_id': companyId,
      'price': price,
      'departure_time': departureTime?.toIso8601String(),
      'arrival_time': arrivalTime?.toIso8601String(),
      'status': status.value,
      'seat_layout': seatLayout,
    };
  }

  factory MTrip.fromMap(Map<String, dynamic> map) {
    return MTrip(
      id: map['id'] != null ? map['id'] as int : null,
      routeId: map['route_id'] != null ? map['route_id'] as int : null,
      busId: map['bus_id'] != null ? map['bus_id'] as int : null,
      companyId: map['company_id'] != null ? map['company_id'] as int : null,
      price: map['price'] != null ? map['price'] as int : null,
      departureTime:
          map['departure_time'] != null
              ? DateTime.parse(map['departure_time'] as String)
              : null,
      arrivalTime:
          map['arrival_time'] != null
              ? DateTime.parse(map['arrival_time'] as String)
              : null,
      status: _parseTripStatus(map['status']),
      seatLayout:
          map['seat_layout'] != null
              ? Map<String, dynamic>.from(map['seat_layout'] as Map)
              : null,
    );
  }

  static BusTripStatus _parseTripStatus(dynamic value) {
    if (value == null) return BusTripStatus.scheduled;

    final statusStr = value.toString().toLowerCase();

    return BusTripStatus.values.firstWhere(
      (e) => e.value == statusStr,
      orElse: () => BusTripStatus.scheduled,
    );
  }

  String toJson() => json.encode(toMap());

  factory MTrip.fromJson(String source) =>
      MTrip.fromMap(json.decode(source) as Map<String, dynamic>);
  @override
  String toString() {
    return 'MTrip(id: $id, routeId: $routeId, busId: $busId, companyId: $companyId, price: $price, departureTime: $departureTime, arrivalTime: $arrivalTime, status: $status, seatLayout: $seatLayout)';
  }

  @override
  bool operator ==(covariant MTrip other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.routeId == routeId &&
        other.busId == busId &&
        other.companyId == companyId &&
        other.price == price &&
        other.departureTime == departureTime &&
        other.arrivalTime == arrivalTime &&
        other.status == status &&
        other.seatLayout == seatLayout;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        routeId.hashCode ^
        busId.hashCode ^
        companyId.hashCode ^
        price.hashCode ^
        departureTime.hashCode ^
        arrivalTime.hashCode ^
        status.hashCode ^
        seatLayout.hashCode;
  }
}

enum BusTripStatus {
  scheduled('scheduled'),
  completed('completed');

  final String value;
  const BusTripStatus(this.value);

  Map<String, dynamic> toMap() => {'value': value};

  factory BusTripStatus.fromMap(Map<String, dynamic> map) {
    final v = map['value'] as String;
    return BusTripStatus.values.firstWhere((e) => e.value == v);
  }
}
