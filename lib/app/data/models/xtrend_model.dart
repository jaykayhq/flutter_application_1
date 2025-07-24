// Path: lib/app/data/models/xtrend_model.dart
import 'dart:convert';

List<XTrend> xTrendFromJson(String str) => List<XTrend>.from(json.decode(str).map((x) => XTrend.fromJson(x)));

String xTrendToJson(List<XTrend> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class XTrend {
    final int id;
    final String topic;
    final int? tweetVolume;
    final String countryCode;
    final String locationName;
    final DateTime retrievedAt;
    final int? xWoeid;

    XTrend({
        required this.id,
        required this.topic,
        this.tweetVolume,
        required this.countryCode,
        required this.locationName,
        required this.retrievedAt,
        this.xWoeid,
    });

    factory XTrend.fromJson(Map<String, dynamic> json) => XTrend(
        id: json["id"],
        topic: json["topic"],
        tweetVolume: json["tweet_volume"],
        countryCode: json["country_code"],
        locationName: json["location_name"],
        retrievedAt: DateTime.parse(json["retrieved_at"]),
        xWoeid: json["x_woeid"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "topic": topic,
        "tweet_volume": tweetVolume,
        "country_code": countryCode,
        "location_name": locationName,
        "retrieved_at": retrievedAt.toIso8601String(),
        "x_woeid": xWoeid,
    };
}