import 'dart:convert';
import 'package:flutter/services.dart';

class ListProvinceService {
  Future<List<ListProvince>> getProvinces() async {
    try {
      final String jsonString = await rootBundle.loadString(
        'assets/data/province/provinces.json',
      );
      final List<dynamic> jsonData = json.decode(jsonString);
      return jsonData.map((json) => ListProvince.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Không thể tải danh sách tỉnh/thành phố');
    }
  }
}

class ListProvince {
  final int id;
  final String name;
  final double lat;
  final double lon;

  ListProvince({
    required this.id,
    required this.name,
    required this.lat,
    required this.lon,
  });

  factory ListProvince.fromJson(Map<String, dynamic> json) {
    return ListProvince(
      id: json['id'],
      name: json['name'],
      lat: json['lat'],
      lon: json['lon'],
    );
  }
}
