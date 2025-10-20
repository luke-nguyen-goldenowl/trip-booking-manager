import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:bus_ticket_app/models/MProvince.dart';
import 'package:bus_ticket_app/constants/api_province.dart';

class ProvinceService {
  static final ProvinceService _instance = ProvinceService._internal();
  factory ProvinceService() => _instance;
  ProvinceService._internal();

  List<Province>? _cachedProvinces;

  Future<List<Province>> getProvinces() async {
    if (_cachedProvinces != null) {
      return _cachedProvinces!;
    }

    try {
      final response = await http.get(Uri.parse(API_PROVINCE_PATH));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        _cachedProvinces =
            data.map((json) {
              json['name'] =
                  json['name']
                      .toString()
                      .replaceAll(RegExp(r'^(Tỉnh|Thành phố)\s*'), '')
                      .trim();

              return Province.fromMap(json);
            }).toList();
        return _cachedProvinces!;
      } else {
        throw Exception('Failed to load provinces: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching provinces: $e');
    }
  }

  void clearCache() {
    _cachedProvinces = null;
  }
}
