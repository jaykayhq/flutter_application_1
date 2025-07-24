// Path: lib/app/data/repositories/supabase_repository.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/xtrend_model.dart';
import '../models/actionable_insight_model.dart';

class SupabaseRepository {
  final SupabaseClient _client = Supabase.instance.client;

  Stream<List<XTrend>> getXTrendsStream() {
    return _client
        .from('x_trends')
        .stream(primaryKey: ['id'])
        .order('retrieved_at', ascending: false)
        .limit(20)
        .map((listOfMaps) => listOfMaps.map((map) => XTrend.fromJson(map)).toList());
  }

  Future<List<ActionableInsight>> getActionableInsights() async {
    final response = await _client
        .from('actionable_insights')
        .select()
        .order('generated_at', ascending: false)
        .limit(30);
    
    final insights = response.map((map) => ActionableInsight.fromJson(map)).toList();
    return insights;
  }
}