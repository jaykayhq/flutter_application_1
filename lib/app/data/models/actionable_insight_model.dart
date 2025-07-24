// Path: lib/app/data/models/actionable_insight_model.dart
import 'dart:convert';

List<ActionableInsight> actionableInsightFromJson(String str) => List<ActionableInsight>.from(json.decode(str).map((x) => ActionableInsight.fromJson(x)));

String actionableInsightToJson(List<ActionableInsight> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ActionableInsight {
    final int id;
    final String insightText;
    final String sourceAi;
    final DateTime generatedAt;
    final List<int>? basedOnTrendIds;

    ActionableInsight({
        required this.id,
        required this.insightText,
        required this.sourceAi,
        required this.generatedAt,
        this.basedOnTrendIds,
    });

    factory ActionableInsight.fromJson(Map<String, dynamic> json) => ActionableInsight(
        id: json["id"],
        insightText: json["insight_text"],
        sourceAi: json["source_ai"],
        generatedAt: DateTime.parse(json["generated_at"]),
        basedOnTrendIds: json["based_on_trend_ids"] == null ? [] : List<int>.from(json["based_on_trend_ids"]!.map((x) => x)),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "insight_text": insightText,
        "source_ai": sourceAi,
        "generated_at": generatedAt.toIso8601String(),
        "based_on_trend_ids": basedOnTrendIds == null ? [] : List<dynamic>.from(basedOnTrendIds!.map((x) => x)),
    };
}