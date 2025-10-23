import 'dart:convert';

class Province {
  final int code;
  final String name;
  final String divisionType;
  final String codename;
  final int phoneCode;

  Province({
    required this.code,
    required this.name,
    required this.divisionType,
    required this.codename,
    required this.phoneCode,
  });

  Province copyWith({
    int? code,
    String? name,
    String? divisionType,
    String? codename,
    int? phoneCode,
  }) {
    return Province(
      code: code ?? this.code,
      name: name ?? this.name,
      divisionType: divisionType ?? this.divisionType,
      codename: codename ?? this.codename,
      phoneCode: phoneCode ?? this.phoneCode,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'code': code,
      'name': name,
      'division_type': divisionType,
      'codename': codename,
      'phone_code': phoneCode,
    };
  }

  factory Province.fromMap(Map<String, dynamic> map) {
    return Province(
      code: map['code'] as int,
      name: map['name'] as String,
      divisionType: map['division_type'] as String? ?? '',
      codename: map['codename'] as String,
      phoneCode: map['phone_code'] as int? ?? 0,
    );
  }
  String toJson() => json.encode(toMap());

  factory Province.fromJson(String source) =>
      Province.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Province(code: $code, name: $name, divisionType: $divisionType, codename: $codename, phoneCode: $phoneCode)';
  }

  @override
  bool operator ==(covariant Province other) {
    if (identical(this, other)) return true;

    return other.code == code &&
        other.name == name &&
        other.divisionType == divisionType &&
        other.codename == codename &&
        other.phoneCode == phoneCode;
  }

  @override
  int get hashCode {
    return code.hashCode ^
        name.hashCode ^
        divisionType.hashCode ^
        codename.hashCode ^
        phoneCode.hashCode;
  }
}
