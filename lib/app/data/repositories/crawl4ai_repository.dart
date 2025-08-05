import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

class Crawl4aiRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Base URL for the crawl4ai MCP bridge function
  String get _baseUrl =>
      'https://druyjbsgrfauseoxjeas.supabase.co/functions/v1/crawl4ai-mcp-bridge';

  /// Crawl a single webpage and optionally create insights task
  Future<Map<String, dynamic>> crawlWebpage({
    required String url,
    String crawlType = 'single_page',
    int maxPages = 1,
    bool includeMetadata = true,
    bool createInsightsTask = false,
    String platform = 'auto',
    bool antiDetection = true,
    bool ragContext = true,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization':
              'Bearer sb_publishable_SlmJi5enB74vzJpjuxRx6A_Yie-VriP',
        },
        body: jsonEncode({
          'url': url,
          'crawl_type': crawlType,
          'max_pages': maxPages,
          'include_metadata': includeMetadata,
          'create_insights_task': createInsightsTask,
          'platform': platform,
          'anti_detection': antiDetection,
          'rag_context': ragContext,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception(
            'Failed to crawl webpage: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Error crawling webpage: $e');
    }
  }

  /// Crawl multiple pages from a sitemap
  Future<Map<String, dynamic>> crawlSitemap({
    required String url,
    int maxPages = 10,
    bool includeMetadata = true,
    bool createInsightsTask = false,
  }) async {
    return crawlWebpage(
      url: url,
      crawlType: 'sitemap',
      maxPages: maxPages,
      includeMetadata: includeMetadata,
      createInsightsTask: createInsightsTask,
    );
  }

  /// Recursively crawl a website
  Future<Map<String, dynamic>> crawlRecursive({
    required String url,
    int maxPages = 20,
    bool includeMetadata = true,
    bool createInsightsTask = false,
  }) async {
    return crawlWebpage(
      url: url,
      crawlType: 'recursive',
      maxPages: maxPages,
      includeMetadata: includeMetadata,
      createInsightsTask: createInsightsTask,
    );
  }

  /// Check the health status of the crawl4ai MCP bridge
  Future<Map<String, dynamic>> checkHealth() async {
    try {
      final response = await http.get(
        Uri.parse(_baseUrl),
        headers: {
          'Authorization':
              'Bearer sb_publishable_SlmJi5enB74vzJpjuxRx6A_Yie-VriP',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Health check failed: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error checking health: $e');
    }
  }

  /// Get crawled content with insights for a specific URL
  Future<List<Map<String, dynamic>>> getCrawledInsights({String? url}) async {
    try {
      var query = _supabase
          .from('actionable_insights')
          .select('*')
          .order('created_at', ascending: false);

      if (url != null) {
        // If you have a way to track which URL an insight came from
        // query = query.eq('source_url', url);
      }

      final response = await query.limit(50);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Error fetching insights: $e');
    }
  }
}
