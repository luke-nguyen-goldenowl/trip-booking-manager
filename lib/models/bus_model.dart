import 'dart:convert';

class MBus {
  final int? id;
  final int? companyId;
  final String? busNumber;
  final BusType type;
  final int? seatCount;
  final BusStatus status;
  MBus({
    this.id,
    this.companyId,
    this.busNumber,
    required this.type,
    this.seatCount,
    required this.status,
  });
  MBus copyWith({
    int? id,
    int? companyId,
    String? busNumber,
    BusType? type,
    int? seatCount,
    BusStatus? status,
  }) {
    return MBus(
      id: id ?? this.id,
      companyId: companyId ?? this.companyId,
      busNumber: busNumber ?? this.busNumber,
      type: type ?? this.type,
      seatCount: seatCount ?? this.seatCount,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'company_id': companyId,
      'bus_number': busNumber,
      'type': type.value,
      'seat_count': seatCount,
      'status': status.value,
    };
  }

  factory MBus.fromMap(Map<String, dynamic> map) {
    return MBus(
      id: map['id'] != null ? map['id'] as int : null,
      companyId: map['company_id'] != null ? map['company_id'] as int : null,
      busNumber: map['bus_number'] != null ? map['bus_number'] as String : null,
      type: _parseBusType(map['type']),
      seatCount: map['seat_count'] != null ? map['seat_count'] as int : null,
      status: _parseBusStatus(map['status']),
    );
  }
  static BusType _parseBusType(dynamic value) {
    if (value == null) return BusType.seater;

    final typeStr = value.toString().toLowerCase();

    return BusType.values.firstWhere(
      (e) => e.value == typeStr,
      orElse: () => BusType.seater,
    );
  }

  static BusStatus _parseBusStatus(dynamic value) {
    if (value == null) return BusStatus.active;

    final statusStr = value.toString().toLowerCase();

    return BusStatus.values.firstWhere(
      (e) => e.value == statusStr,
      orElse: () => BusStatus.active,
    );
  }

  String toJson() => json.encode(toMap());

  factory MBus.fromJson(String source) =>
      MBus.fromMap(json.decode(source) as Map<String, dynamic>);
  @override
  String toString() {
    return 'Bus(id: $id, companyId: $companyId, busNumber: $busNumber, type: $type, seatCount: $seatCount, status: $status)';
  }

  @override
  bool operator ==(covariant MBus other) {
    if (identical(this, other)) return true;
    return other.id == id &&
        other.companyId == companyId &&
        other.busNumber == busNumber &&
        other.type == type &&
        other.seatCount == seatCount &&
        other.status == status;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        companyId.hashCode ^
        busNumber.hashCode ^
        type.hashCode ^
        seatCount.hashCode ^
        status.hashCode;
  }
}

enum BusStatus {
  active('active'),
  maintenance('maintenance'),
  inactive('inactive');

  final String value;
  const BusStatus(this.value);

  Map<String, dynamic> toMap() => {'value': value};

  factory BusStatus.fromMap(Map<String, dynamic> map) {
    final v = map['value'] as String;
    return BusStatus.values.firstWhere((e) => e.value == v);
  }
}

enum BusType {
  sleeper('sleeper'),
  seater('seater'),
  limousine('limousine');

  final String value;
  const BusType(this.value);

  Map<String, dynamic> toMap() => {'value': value};

  factory BusType.fromMap(Map<String, dynamic> map) {
    final v = map['value'] as String;
    return BusType.values.firstWhere((e) => e.value == v);
  }
}
