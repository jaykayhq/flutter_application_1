import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../data/repositories/supabase_repository.dart';
import '../../../data/models/xtrend_model.dart';
import '../../../data/models/actionable_insight_model.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView>
    with TickerProviderStateMixin {
  final SupabaseRepository _repository = SupabaseRepository();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _isLoading = true;
  List<XTrend> _trends = [];
  List<ActionableInsight> _insights = [];
  final Map<String, dynamic> _stats = {
    'totalReach': 0,
    'engagementRate': 0.0,
    'activeCampaigns': 0,
    'topPerformingPost': '',
  };

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _loadData();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      // Load trends stream
      _repository.getXTrendsStream().listen((trends) {
        if (mounted) {
          setState(() {
            _trends = trends.take(10).toList();
            _stats['totalReach'] =
                trends.fold(0, (sum, trend) => sum + (trend.tweetVolume ?? 0));
          });
        }
      });

      // Load insights
      final insights = await _repository.getActionableInsights();
      if (mounted) {
        setState(() {
          _insights = insights.take(5).toList();
          _stats['engagementRate'] = 5.2; // Mock data
          _stats['activeCampaigns'] = 3; // Mock data
          _stats['topPerformingPost'] = 'Back to School Campaign';
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFf8f9fa),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: _loadData,
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 24),
                      _buildStatsGrid(),
                      const SizedBox(height: 24),
                      _buildTrendingTopics(),
                      const SizedBox(height: 24),
                      _buildEngagementChart(),
                      const SizedBox(height: 24),
                      _buildRecentInsights(),
                      const SizedBox(height: 24),
                      _buildQuickActions(),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final user = Supabase.instance.client.auth.currentUser;
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF667eea), Color(0xFF764ba2)],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.analytics, color: Colors.white, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome back!',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2c3e50),
                ),
              ),
              Text(
                user?.email ?? 'User',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () async {
            await Supabase.instance.client.auth.signOut();
          },
          icon: const Icon(Icons.logout, color: Color(0xFF667eea)),
        ),
      ],
    );
  }

  Widget _buildStatsGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard(
          'Total Reach',
          '${_stats['totalReach'].toStringAsFixed(0)}',
          Icons.visibility,
          const Color(0xFF667eea),
        ),
        _buildStatCard(
          'Engagement Rate',
          '${_stats['engagementRate']}%',
          Icons.trending_up,
          const Color(0xFF28a745),
        ),
        _buildStatCard(
          'Active Campaigns',
          '${_stats['activeCampaigns']}',
          Icons.campaign,
          const Color(0xFFffc107),
        ),
        _buildStatCard(
          'Top Post',
          _stats['topPerformingPost'],
          Icons.star,
          const Color(0xFFdc3545),
        ),
      ],
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
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
                child: Icon(icon, color: color, size: 20),
              ),
              const Spacer(),
              Icon(Icons.more_vert, color: Colors.grey.shade400, size: 20),
            ],
          ),
          const Spacer(),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2c3e50),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendingTopics() {
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.trending_up, color: Color(0xFF667eea)),
              const SizedBox(width: 8),
              Text(
                'Trending Topics',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF2c3e50),
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {},
                child: Text(
                  'View All',
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF667eea),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_trends.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text('No trending topics available'),
              ),
            )
          else
            ..._trends.take(5).map((trend) => _buildTrendItem(trend)),
        ],
      ),
    );
  }

  Widget _buildTrendItem(XTrend trend) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Color(0xFF667eea),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  trend.topic,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF2c3e50),
                  ),
                ),
                Text(
                  '${trend.tweetVolume ?? 0} tweets',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey.shade400),
        ],
      ),
    );
  }

  Widget _buildEngagementChart() {
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Engagement Over Time',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF2c3e50),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: GoogleFonts.poppins(fontSize: 10),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const days = [
                          'Mon',
                          'Tue',
                          'Wed',
                          'Thu',
                          'Fri',
                          'Sat',
                          'Sun'
                        ];
                        if (value.toInt() >= 0 && value.toInt() < days.length) {
                          return Text(
                            days[value.toInt()],
                            style: GoogleFonts.poppins(fontSize: 10),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: const [
                      FlSpot(0, 3),
                      FlSpot(1, 5),
                      FlSpot(2, 4),
                      FlSpot(3, 7),
                      FlSpot(4, 6),
                      FlSpot(5, 8),
                      FlSpot(6, 5),
                    ],
                    isCurved: true,
                    color: const Color(0xFF667eea),
                    barWidth: 3,
                    dotData: const FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      color: const Color(0xFF667eea).withValues(alpha: 0.1),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentInsights() {
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.lightbulb_outline, color: Color(0xFF28a745)),
              const SizedBox(width: 8),
              Text(
                'Recent Insights',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF2c3e50),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_insights.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text('No insights available'),
              ),
            )
          else
            ..._insights.take(3).map((insight) => _buildInsightItem(insight)),
        ],
      ),
    );
  }

  Widget _buildInsightItem(ActionableInsight insight) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF28a745).withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const Icon(Icons.lightbulb, color: Color(0xFF28a745), size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                insight.insightText,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: const Color(0xFF2c3e50),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF2c3e50),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                'New Campaign',
                Icons.add_circle_outline,
                const Color(0xFF667eea),
                () {},
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                'View Reports',
                Icons.assessment,
                const Color(0xFF28a745),
                () {},
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton(
      String title, IconData icon, Color color, VoidCallback onPressed) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
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
}
