import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RecommendationsView extends StatefulWidget {
  const RecommendationsView({super.key});

  @override
  State<RecommendationsView> createState() => _RecommendationsViewState();
}

class _RecommendationsViewState extends State<RecommendationsView>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  int _selectedCategoryIndex = 0;

  final List<String> _categories = [
    'All',
    'Content',
    'Timing',
    'Platform',
    'Audience'
  ];

  final List<Map<String, dynamic>> _recommendations = [
    {
      'id': 1,
      'title': 'Post during peak hours',
      'description':
          'Your audience is most active between 7-9 PM. Schedule posts during this time for maximum engagement.',
      'category': 'Timing',
      'priority': 'high',
      'impact': 'High',
      'effort': 'Low',
      'icon': Icons.schedule,
      'color': const Color(0xFF667eea),
    },
    {
      'id': 2,
      'title': 'Use more video content',
      'description':
          'Videos receive 2.5x more engagement than static posts. Consider creating short-form videos.',
      'category': 'Content',
      'priority': 'high',
      'impact': 'High',
      'effort': 'Medium',
      'icon': Icons.video_library,
      'color': const Color(0xFF28a745),
    },
    {
      'id': 3,
      'title': 'Engage with followers',
      'description':
          'Respond to comments within 2 hours to increase engagement rates by 40%.',
      'category': 'Audience',
      'priority': 'medium',
      'impact': 'Medium',
      'effort': 'Low',
      'icon': Icons.chat_bubble,
      'color': const Color(0xFFffc107),
    },
    {
      'id': 4,
      'title': 'Try TikTok marketing',
      'description':
          'Your target demographic is highly active on TikTok. Consider expanding to this platform.',
      'category': 'Platform',
      'priority': 'medium',
      'impact': 'High',
      'effort': 'High',
      'icon': Icons.trending_up,
      'color': const Color(0xFFdc3545),
    },
    {
      'id': 5,
      'title': 'Use trending hashtags',
      'description':
          'Incorporate trending hashtags in your posts to increase discoverability by 30%.',
      'category': 'Content',
      'priority': 'low',
      'impact': 'Medium',
      'effort': 'Low',
      'icon': Icons.tag,
      'color': const Color(0xFF6f42c1),
    },
    {
      'id': 6,
      'title': 'Collaborate with influencers',
      'description':
          'Partner with local influencers to reach new audiences and increase brand awareness.',
      'category': 'Audience',
      'priority': 'high',
      'impact': 'High',
      'effort': 'High',
      'icon': Icons.people,
      'color': const Color(0xFFfd7e14),
    },
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFf8f9fa),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildCategoryTabs(),
              Expanded(
                child: _buildRecommendationsList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF6f42c1), Color(0xFFfd7e14)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child:
                    const Icon(Icons.recommend, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI Recommendations',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Personalized suggestions for your business',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildStatChip(
                  '${_recommendations.length}', 'Total Recommendations'),
              const SizedBox(width: 12),
              _buildStatChip(
                '${_recommendations.where((r) => r['priority'] == 'high').length}',
                'High Priority',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTabs() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SizedBox(
        height: 40,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: _categories.length,
          itemBuilder: (context, index) {
            final category = _categories[index];
            final isSelected = _selectedCategoryIndex == index;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(
                  category,
                  style: GoogleFonts.poppins(
                    color: isSelected ? Colors.white : const Color(0xFF6f42c1),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    _selectedCategoryIndex = index;
                  });
                },
                backgroundColor: Colors.grey.shade100,
                selectedColor: const Color(0xFF6f42c1),
                checkmarkColor: Colors.white,
                side: BorderSide(
                  color: isSelected
                      ? const Color(0xFF6f42c1)
                      : Colors.grey.shade300,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildRecommendationsList() {
    List<Map<String, dynamic>> filteredRecommendations =
        _getFilteredRecommendations();

    if (filteredRecommendations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.recommend_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No recommendations found',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try selecting a different category',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredRecommendations.length,
      itemBuilder: (context, index) {
        final recommendation = filteredRecommendations[index];
        return _buildRecommendationCard(recommendation);
      },
    );
  }

  List<Map<String, dynamic>> _getFilteredRecommendations() {
    if (_selectedCategoryIndex == 0) {
      return _recommendations;
    }
    final selectedCategory = _categories[_selectedCategoryIndex];
    return _recommendations
        .where((r) => r['category'] == selectedCategory)
        .toList();
  }

  Widget _buildRecommendationCard(Map<String, dynamic> recommendation) {
    final priority = recommendation['priority'] as String;
    final impact = recommendation['impact'] as String;
    final effort = recommendation['effort'] as String;
    final color = recommendation['color'] as Color;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showRecommendationDetails(recommendation),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        recommendation['icon'] as IconData,
                        color: color,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            recommendation['title'],
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF2c3e50),
                            ),
                          ),
                          const SizedBox(height: 4),
                          _buildPriorityChip(priority),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () =>
                          _showRecommendationOptions(recommendation),
                      icon: const Icon(Icons.more_vert, color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  recommendation['description'],
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildMetricChip('Impact', impact, _getImpactColor(impact)),
                    const SizedBox(width: 8),
                    _buildMetricChip('Effort', effort, _getEffortColor(effort)),
                    const Spacer(),
                    TextButton(
                      onPressed: () =>
                          _showRecommendationDetails(recommendation),
                      child: Text(
                        'View Details',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: color,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPriorityChip(String priority) {
    Color color;
    String label;

    switch (priority.toLowerCase()) {
      case 'high':
        color = const Color(0xFFdc3545);
        label = 'High Priority';
        break;
      case 'medium':
        color = const Color(0xFFffc107);
        label = 'Medium Priority';
        break;
      case 'low':
        color = const Color(0xFF28a745);
        label = 'Low Priority';
        break;
      default:
        color = Colors.grey;
        label = priority;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildMetricChip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 10,
              color: color,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Color _getImpactColor(String impact) {
    switch (impact.toLowerCase()) {
      case 'high':
        return const Color(0xFF28a745);
      case 'medium':
        return const Color(0xFFffc107);
      case 'low':
        return const Color(0xFF6c757d);
      default:
        return Colors.grey;
    }
  }

  Color _getEffortColor(String effort) {
    switch (effort.toLowerCase()) {
      case 'high':
        return const Color(0xFFdc3545);
      case 'medium':
        return const Color(0xFFffc107);
      case 'low':
        return const Color(0xFF28a745);
      default:
        return Colors.grey;
    }
  }

  void _showRecommendationDetails(Map<String, dynamic> recommendation) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildRecommendationDetailsSheet(recommendation),
    );
  }

  Widget _buildRecommendationDetailsSheet(Map<String, dynamic> recommendation) {
    final color = recommendation['color'] as Color;

    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          recommendation['icon'] as IconData,
                          color: color,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              recommendation['title'],
                              style: GoogleFonts.poppins(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF2c3e50),
                              ),
                            ),
                            Text(
                              recommendation['category'],
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: color,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Description',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF2c3e50),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: color.withValues(alpha: 0.2)),
                    ),
                    child: Text(
                      recommendation['description'],
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: const Color(0xFF2c3e50),
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: _buildDetailCard('Priority',
                            recommendation['priority'], Icons.priority_high),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildDetailCard('Impact',
                            recommendation['impact'], Icons.trending_up),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildDetailCard(
                            'Effort', recommendation['effort'], Icons.work),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),
                  Text(
                    'Actions',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF2c3e50),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildActionButton(
                          'Implement',
                          Icons.check_circle_outline,
                          color,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildActionButton(
                          'Save for Later',
                          Icons.bookmark_border,
                          Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFF6f42c1), size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF2c3e50),
            ),
          ),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 10,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon, Color color) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showRecommendationOptions(Map<String, dynamic> recommendation) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.check_circle_outline,
                  color: Color(0xFF28a745)),
              title: Text('Mark as Implemented', style: GoogleFonts.poppins()),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading:
                  const Icon(Icons.bookmark_border, color: Color(0xFF667eea)),
              title: Text('Save for Later', style: GoogleFonts.poppins()),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.share, color: Color(0xFFffc107)),
              title: Text('Share with Team', style: GoogleFonts.poppins()),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}
