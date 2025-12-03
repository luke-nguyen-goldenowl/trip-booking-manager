import 'package:supabase_flutter/supabase_flutter.dart';
import 'result_model.dart';

abstract class BaseCollection<T> {
  final SupabaseClient supabase;
  final String tableName;

  T fromMap(Map<String, dynamic> map);
  Map<String, dynamic> toMap(T item);
  int getId(T item);
  T setId(T item, int id);

  BaseCollection({required this.supabase, required this.tableName});

  Future<MResult<T>> get(int id) async {
    try {
      final response =
          await supabase.from(tableName).select().eq('id', id).single();

      return MResult.success(fromMap(response));
    } catch (e) {
      return MResult.exception(e);
    }
  }

  Future<MResult<List<T>>> getAll({
    String? column,
    dynamic value,
    String? orderBy,
    bool ascending = true,
    int? limit,
  }) async {
    try {
      dynamic queryBuilder = supabase.from(tableName).select();

      if (column != null && value != null) {
        queryBuilder = queryBuilder.eq(column, value);
      }

      if (orderBy != null) {
        queryBuilder = queryBuilder.order(orderBy, ascending: ascending);
      }

      if (limit != null) {
        queryBuilder = queryBuilder.limit(limit);
      }

      final response = await queryBuilder;

      final items = (response as List).map((item) => fromMap(item)).toList();

      return MResult.success(items);
    } catch (e) {
      return MResult.exception(e);
    }
  }

  Future<MResult<T>> insert(T item) async {
    try {
      final data = toMap(item);
      data.remove('id');

      final response =
          await supabase.from(tableName).insert(data).select().single();

      return MResult.success(fromMap(response));
    } catch (e) {
      return MResult.exception(e);
    }
  }

  Future<MResult<T>> update(T item) async {
    try {
      final id = getId(item);
      final data = toMap(item);

      final response =
          await supabase
              .from(tableName)
              .update(data)
              .eq('id', id)
              .select()
              .single();

      return MResult.success(fromMap(response));
    } catch (e) {
      return MResult.exception(e);
    }
  }

  Future<MResult<void>> delete(int id) async {
    try {
      await supabase.from(tableName).delete().eq('id', id);

      return MResult.success(null);
    } catch (e) {
      return MResult.exception(e);
    }
  }
}
