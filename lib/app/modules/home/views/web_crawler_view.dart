import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../data/repositories/crawl4ai_repository.dart';

class WebCrawlerView extends StatefulWidget {
  const WebCrawlerView({super.key});

  @override
  State<WebCrawlerView> createState() => _WebCrawlerViewState();
}

class _WebCrawlerViewState extends State<WebCrawlerView> {
  final Crawl4aiRepository _crawlRepository = Crawl4aiRepository();
  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _maxPagesController =
      TextEditingController(text: '1');

  String _selectedCrawlType = 'single_page';
  String _selectedPlatform = 'auto';
  bool _includeMetadata = true;
  bool _createInsightsTask = true;
  bool _antiDetection = true;
  bool _ragContext = true;
  bool _isLoading = false;
  bool _isHealthCheckLoading = false;

  Map<String, dynamic>? _lastCrawlResult;
  List<Map<String, dynamic>> _insights = [];

  @override
  void initState() {
    super.initState();
    _loadInsights();
  }

  @override
  void dispose() {
    _urlController.dispose();
    _maxPagesController.dispose();
    super.dispose();
  }

  Future<void> _loadInsights() async {
    try {
      final insights = await _crawlRepository.getCrawledInsights();
      setState(() {
        _insights = insights;
      });
    } catch (e) {
      setState(() {
        // _errorMessage = 'Failed to load insights: $e'; // This line is removed
      });
    }
  }

  Future<void> _checkHealth() async {
    setState(() {
      _isHealthCheckLoading = true;
      // _errorMessage = null; // This line is removed
    });

    try {
      final health = await _crawlRepository.checkHealth();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Health Check: ${health['status']}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Health Check Failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isHealthCheckLoading = false;
      });
    }
  }

  Future<void> _crawlWebpage() async {
    if (_urlController.text.trim().isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter a URL'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    setState(() {
      _isLoading = true;
      // _errorMessage = null; // This line is removed
      _lastCrawlResult = null;
    });

    try {
      final result = await _crawlRepository.crawlWebpage(
        url: _urlController.text.trim(),
        crawlType: _selectedCrawlType,
        maxPages: int.tryParse(_maxPagesController.text) ?? 1,
        includeMetadata: _includeMetadata,
        createInsightsTask: _createInsightsTask,
        platform: _selectedPlatform,
        antiDetection: _antiDetection,
        ragContext: _ragContext,
      );

      setState(() {
        _lastCrawlResult = result;
      });

      if (_createInsightsTask) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content:
                  Text('Crawl completed! Insights generation task created.'),
              backgroundColor: Colors.green,
            ),
          );
        }
        // Reload insights after a short delay
        Future.delayed(const Duration(seconds: 2), _loadInsights);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Crawl completed successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        // _errorMessage = 'Crawl failed: $e'; // This line is removed
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Crawl failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                IconButton(
                  onPressed: _isHealthCheckLoading ? null : _checkHealth,
                  icon: _isHealthCheckLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.health_and_safety),
                  tooltip: 'Check Service Health',
                ),
                const SizedBox(width: 8),
                Text(
                  'Web Crawler & Insights',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // URL Input Section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Crawl Configuration',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // URL Input
                    TextField(
                      controller: _urlController,
                      decoration: const InputDecoration(
                        labelText: 'Website URL',
                        hintText: 'https://example.com',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.link),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Platform Selection
                    DropdownButtonFormField<String>(
                      value: _selectedPlatform,
                      decoration: const InputDecoration(
                        labelText: 'Platform',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.devices),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'auto',
                          child: Text('Auto Detect'),
                        ),
                        DropdownMenuItem(
                          value: 'twitter',
                          child: Text('Twitter/X'),
                        ),
                        DropdownMenuItem(
                          value: 'instagram',
                          child: Text('Instagram'),
                        ),
                        DropdownMenuItem(
                          value: 'facebook',
                          child: Text('Facebook'),
                        ),
                        DropdownMenuItem(
                          value: 'linkedin',
                          child: Text('LinkedIn'),
                        ),
                        DropdownMenuItem(
                          value: 'tiktok',
                          child: Text('TikTok'),
                        ),
                        DropdownMenuItem(
                          value: 'youtube',
                          child: Text('YouTube'),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedPlatform = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // Crawl Type Selection
                    DropdownButtonFormField<String>(
                      value: _selectedCrawlType,
                      decoration: const InputDecoration(
                        labelText: 'Crawl Type',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'single_page',
                          child: Text('Single Page'),
                        ),
                        DropdownMenuItem(
                          value: 'sitemap',
                          child: Text('Sitemap'),
                        ),
                        DropdownMenuItem(
                          value: 'recursive',
                          child: Text('Recursive'),
                        ),
                        DropdownMenuItem(
                          value: 'social_media',
                          child: Text('Social Media'),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedCrawlType = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // Max Pages Input
                    TextField(
                      controller: _maxPagesController,
                      decoration: const InputDecoration(
                        labelText: 'Max Pages',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.pages),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),

                    // Enhanced Options
                    Row(
                      children: [
                        Expanded(
                          child: CheckboxListTile(
                            title: const Text('Include Metadata'),
                            value: _includeMetadata,
                            onChanged: (value) {
                              setState(() {
                                _includeMetadata = value!;
                              });
                            },
                          ),
                        ),
                        Expanded(
                          child: CheckboxListTile(
                            title: const Text('Generate Insights'),
                            value: _createInsightsTask,
                            onChanged: (value) {
                              setState(() {
                                _createInsightsTask = value!;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: CheckboxListTile(
                            title: const Text('Anti-Detection'),
                            subtitle: const Text('Stealth mode'),
                            value: _antiDetection,
                            onChanged: (value) {
                              setState(() {
                                _antiDetection = value!;
                              });
                            },
                          ),
                        ),
                        Expanded(
                          child: CheckboxListTile(
                            title: const Text('Nigerian RAG'),
                            subtitle: const Text('Local context'),
                            value: _ragContext,
                            onChanged: (value) {
                              setState(() {
                                _ragContext = value!;
                              });
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Crawl Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _crawlWebpage,
                        icon: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.web),
                        label: Text(_isLoading ? 'Crawling...' : 'Start Crawl'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Results Section
            if (_lastCrawlResult != null) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Crawl Results',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (_lastCrawlResult!['success'] == true) ...[
                        const Text('Status: Success'),
                        if (_lastCrawlResult!['data'] != null) ...[
                          const SizedBox(height: 8),
                          Text(
                              'Content Length: ${_lastCrawlResult!['data']['content']?.toString().length ?? 0} characters'),
                          if (_lastCrawlResult!['data']['metadata'] !=
                              null) ...[
                            const SizedBox(height: 8),
                            Text(
                                'Title: ${_lastCrawlResult!['data']['metadata']['title'] ?? 'N/A'}'),
                            Text(
                                'Platform: ${_lastCrawlResult!['data']['metadata']['platform'] ?? 'Unknown'}'),
                          ],
                          if (_lastCrawlResult!['data']['nigerian_context'] !=
                              null) ...[
                            const SizedBox(height: 8),
                            Text(
                                'Nigerian Relevance: ${(_lastCrawlResult!['data']['nigerian_context']['relevance_score'] * 100).toStringAsFixed(1)}%'),
                            if (_lastCrawlResult!['data']['nigerian_context']
                                    ['local_keywords']
                                .isNotEmpty) ...[
                              Text(
                                  'Local Keywords: ${_lastCrawlResult!['data']['nigerian_context']['local_keywords'].join(', ')}'),
                            ],
                          ],
                        ],
                      ] else ...[
                        const Text('Status: Failed'),
                        Text(
                            'Error: ${_lastCrawlResult!['error'] ?? 'Unknown error'}'),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Insights Section
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Generated Insights',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            onPressed: _loadInsights,
                            icon: const Icon(Icons.refresh),
                            tooltip: 'Refresh Insights',
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (_insights.isEmpty)
                        const Center(
                          child: Text(
                            'No insights available yet. Start crawling to generate insights!',
                            style: TextStyle(
                              color: Colors.grey,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        )
                      else
                        Expanded(
                          child: ListView.builder(
                            itemCount: _insights.length,
                            itemBuilder: (context, index) {
                              final insight = _insights[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 8),
                                child: ListTile(
                                  leading: const Icon(Icons.lightbulb_outline),
                                  title: Text(
                                      insight['insight_text'] ?? 'No text'),
                                  subtitle: Text(
                                    'Generated: ${insight['created_at'] ?? 'Unknown'}',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
