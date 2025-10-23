import 'dart:convert';

class MRoute {
  final int? id;
  final int? companyId;
  final String? departure;
  final String? destination;
  final int? distance;
  final BusRouteStatus status;
  MRoute({
    this.id,
    this.companyId,
    this.departure,
    this.destination,
    this.distance,
    required this.status,
  });

  MRoute copyWith({
    int? id,
    int? companyId,
    String? departure,
    String? destination,
    int? distance,
    BusRouteStatus? status,
  }) {
    return MRoute(
      id: id ?? this.id,
      companyId: companyId ?? this.companyId,
      departure: departure ?? this.departure,
      destination: destination ?? this.destination,
      distance: distance ?? this.distance,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'company_id': companyId,
      'departure': departure,
      'destination': destination,
      'distance_km': distance,
      'status': status.value,
    };
  }

  static BusRouteStatus _parseBusRouteStatus(dynamic value) {
    if (value == null) return BusRouteStatus.active;

    final statusStr = value.toString().toLowerCase();

    return BusRouteStatus.values.firstWhere(
      (e) => e.value == statusStr,
      orElse: () => BusRouteStatus.active,
    );
  }

  factory MRoute.fromMap(Map<String, dynamic> map) {
    return MRoute(
      id: map['id'] != null ? map['id'] as int : null,
      companyId: map['company_id'] != null ? map['company_id'] as int : null,
      departure: map['departure'] != null ? map['departure'] as String : null,
      destination:
          map['destination'] != null ? map['destination'] as String : null,
      distance: map['distance_km'] != null ? map['distance_km'] as int : null,
      status: _parseBusRouteStatus(map['status']),
    );
  }

  String toJson() => json.encode(toMap());

  factory MRoute.fromJson(String source) =>
      MRoute.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'MRoute(id: $id, companyId: $companyId, departure: $departure, destination: $destination, distance: $distance, status: $status)';
  }

  @override
  bool operator ==(covariant MRoute other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.companyId == companyId &&
        other.departure == departure &&
        other.destination == destination &&
        other.distance == distance &&
        other.status == status;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        companyId.hashCode ^
        departure.hashCode ^
        destination.hashCode ^
        distance.hashCode ^
        status.hashCode;
  }
}

enum BusRouteStatus {
  active('active'),
  inactive('inactive');

  final String value;
  const BusRouteStatus(this.value);

  Map<String, dynamic> toMap() => {'value': value};

  factory BusRouteStatus.fromMap(Map<String, dynamic> map) {
    final v = map['value'] as String;
    return BusRouteStatus.values.firstWhere((e) => e.value == v);
  }
}
