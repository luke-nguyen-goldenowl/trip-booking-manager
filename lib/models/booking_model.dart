import 'dart:convert';

class MBooking {
  final int? id;
  final int? userId;
  final int? tripId;
  final int? totalPrice;
  final String? status;
  final String? paymentStatus;
  final String? paymentMethod;
  final DateTime? createdAt;
  final String? seats;
  final String? bookingCode;
  final bool? isMailSended;
  MBooking({
    this.id,
    this.userId,
    this.tripId,
    this.totalPrice,
    this.status,
    this.paymentStatus,
    this.paymentMethod,
    this.createdAt,
    this.seats,
    this.bookingCode,
    this.isMailSended,
  });

  MBooking copyWith({
    int? id,
    int? userId,
    int? tripId,
    int? totalPrice,
    String? status,
    String? paymentStatus,
    String? paymentMethod,
    DateTime? createdAt,
    String? seats,
    String? bookingCode,
    bool? isMailSended,
  }) {
    return MBooking(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      tripId: tripId ?? this.tripId,
      totalPrice: totalPrice ?? this.totalPrice,
      status: status ?? this.status,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      createdAt: createdAt ?? this.createdAt,
      seats: seats ?? this.seats,
      bookingCode: bookingCode ?? this.bookingCode,
      isMailSended: isMailSended ?? this.isMailSended,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'user_id': userId,
      'trip_id': tripId,
      'total_price': totalPrice,
      'status': status,
      'payment_status': paymentStatus,
      'payment_method': paymentMethod,
      'created_at': createdAt?.toIso8601String(),
      'seats': seats,
      'booking_code': bookingCode,
      'isMailSended': isMailSended,
    };
  }

  Map<String, dynamic> toMapLocaldb() {
    return <String, dynamic>{
      'user_id': userId,
      'trip_id': tripId,
      'total_price': totalPrice,
      'status': status,
      'payment_status': paymentStatus,
      'payment_method': paymentMethod,
      'created_at': createdAt?.toIso8601String(),
      'seats': seats,
      'booking_code': bookingCode,
      'is_mail_sended': (isMailSended ?? false) ? 1 : 0,
    };
  }

  factory MBooking.fromMap(Map<String, dynamic> map) {
    return MBooking(
      id: map['id'] != null ? map['id'] as int : null,
      userId: map['user_id'] != null ? map['user_id'] as int : null,
      tripId: map['trip_id'] != null ? map['trip_id'] as int : null,
      totalPrice: map['total_price'] != null ? map['total_price'] as int : null,
      status: map['status'] != null ? map['status'] as String : null,
      paymentStatus:
          map['payment_status'] != null
              ? map['payment_status'] as String
              : null,
      paymentMethod:
          map['payment_method'] != null
              ? map['payment_method'] as String
              : null,
      createdAt:
          map['created_at'] != null
              ? DateTime.parse(map['created_at'] as String)
              : null,
      seats: map['seats'] != null ? map['seats'] as String : null,
      bookingCode:
          map['booking_code'] != null ? map['booking_code'] as String : null,
      isMailSended:
          map['isMailSended'] != null ? map['isMailSended'] as bool : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory MBooking.fromJson(String source) =>
      MBooking.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'MBooking(id: $id, userId: $userId, tripId: $tripId, totalPrice: $totalPrice, status: $status, paymentStatus: $paymentStatus, paymentMethod: $paymentMethod, createdAt: $createdAt, seats: $seats, bookingCode: $bookingCode, isMailSended: $isMailSended)';
  }

  @override
  bool operator ==(covariant MBooking other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.userId == userId &&
        other.tripId == tripId &&
        other.totalPrice == totalPrice &&
        other.status == status &&
        other.paymentStatus == paymentStatus &&
        other.paymentMethod == paymentMethod &&
        other.createdAt == createdAt &&
        other.seats == seats &&
        other.bookingCode == bookingCode &&
        other.isMailSended == isMailSended;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        userId.hashCode ^
        tripId.hashCode ^
        totalPrice.hashCode ^
        status.hashCode ^
        paymentStatus.hashCode ^
        paymentMethod.hashCode ^
        createdAt.hashCode ^
        seats.hashCode ^
        bookingCode.hashCode ^
        isMailSended.hashCode;
  }
}

enum BookingStatus {
  pending('pending'),
  confirmed('confirmed'),
  cancelled('cancelled'),
  completed('completed');

  final String value;
  const BookingStatus(this.value);

  Map<String, dynamic> toMap() => {'value': value};

  factory BookingStatus.fromMap(Map<String, dynamic> map) {
    final v = map['value'] as String;
    return BookingStatus.values.firstWhere((e) => e.value == v);
  }
}

enum BookingPaymentStatus {
  pending('pending'),
  completed('completed');

  final String value;
  const BookingPaymentStatus(this.value);

  Map<String, dynamic> toMap() => {'value': value};

  factory BookingPaymentStatus.fromMap(Map<String, dynamic> map) {
    final v = map['value'] as String;
    return BookingPaymentStatus.values.firstWhere((e) => e.value == v);
  }
}

enum BookingPaymentMethod {
  cash('cash'),
  momo('momo');

  final String value;
  const BookingPaymentMethod(this.value);

  Map<String, dynamic> toMap() => {'value': value};

  factory BookingPaymentMethod.fromMap(Map<String, dynamic> map) {
    final v = map['value'] as String;
    return BookingPaymentMethod.values.firstWhere((e) => e.value == v);
  }
}
