import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';

class CampaignTrackerView extends StatefulWidget {
  const CampaignTrackerView({super.key});

  @override
  State<CampaignTrackerView> createState() => _CampaignTrackerViewState();
}

class _CampaignTrackerViewState extends State<CampaignTrackerView>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  int _selectedTabIndex = 0;

  final List<Map<String, dynamic>> _campaigns = [
    {
      'id': 1,
      'name': 'Back to School Campaign',
      'status': 'active',
      'progress': 0.75,
      'budget': 5000.0,
      'spent': 3750.0,
      'reach': 15000,
      'engagement': 8.5,
      'startDate': DateTime.now().subtract(const Duration(days: 7)),
      'endDate': DateTime.now().add(const Duration(days: 7)),
      'platforms': ['Instagram', 'Facebook', 'Twitter'],
    },
    {
      'id': 2,
      'name': 'Holiday Special',
      'status': 'draft',
      'progress': 0.0,
      'budget': 3000.0,
      'spent': 0.0,
      'reach': 0,
      'engagement': 0.0,
      'startDate': DateTime.now().add(const Duration(days: 14)),
      'endDate': DateTime.now().add(const Duration(days: 30)),
      'platforms': ['Instagram', 'TikTok'],
    },
    {
      'id': 3,
      'name': 'Product Launch',
      'status': 'completed',
      'progress': 1.0,
      'budget': 8000.0,
      'spent': 8000.0,
      'reach': 25000,
      'engagement': 12.3,
      'startDate': DateTime.now().subtract(const Duration(days: 30)),
      'endDate': DateTime.now().subtract(const Duration(days: 5)),
      'platforms': ['Instagram', 'Facebook', 'LinkedIn'],
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
              _buildTabBar(),
              Expanded(
                child: _buildTabContent(),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateCampaignDialog(),
        backgroundColor: const Color(0xFF667eea),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
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
                    const Icon(Icons.campaign, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Campaign Tracker',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Manage and monitor your campaigns',
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
              _buildStatChip('${_campaigns.length}', 'Total Campaigns'),
              const SizedBox(width: 12),
              _buildStatChip(
                '${_campaigns.where((c) => c['status'] == 'active').length}',
                'Active',
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

  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _buildTab('All', 0),
          _buildTab('Active', 1),
          _buildTab('Draft', 2),
          _buildTab('Completed', 3),
        ],
      ),
    );
  }

  Widget _buildTab(String label, int index) {
    final isSelected = _selectedTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTabIndex = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color:
                    isSelected ? const Color(0xFF667eea) : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              color:
                  isSelected ? const Color(0xFF667eea) : Colors.grey.shade600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    List<Map<String, dynamic>> filteredCampaigns = _getFilteredCampaigns();

    if (filteredCampaigns.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.campaign_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No campaigns found',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create your first campaign to get started',
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
      itemCount: filteredCampaigns.length,
      itemBuilder: (context, index) {
        final campaign = filteredCampaigns[index];
        return _buildCampaignCard(campaign);
      },
    );
  }

  List<Map<String, dynamic>> _getFilteredCampaigns() {
    switch (_selectedTabIndex) {
      case 1:
        return _campaigns.where((c) => c['status'] == 'active').toList();
      case 2:
        return _campaigns.where((c) => c['status'] == 'draft').toList();
      case 3:
        return _campaigns.where((c) => c['status'] == 'completed').toList();
      default:
        return _campaigns;
    }
  }

  Widget _buildCampaignCard(Map<String, dynamic> campaign) {
    final status = campaign['status'] as String;
    final progress = campaign['progress'] as double;
    final budget = campaign['budget'] as double;
    final spent = campaign['spent'] as double;

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
          onTap: () => _showCampaignDetails(campaign),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            campaign['name'],
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF2c3e50),
                            ),
                          ),
                          const SizedBox(height: 4),
                          _buildStatusChip(status),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => _showCampaignOptions(campaign),
                      icon: const Icon(Icons.more_vert, color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildProgressSection(progress, budget, spent),
                const SizedBox(height: 16),
                _buildMetricsRow(campaign),
                const SizedBox(height: 16),
                _buildPlatformsRow(campaign['platforms'] as List<String>),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    String label;

    switch (status) {
      case 'active':
        color = const Color(0xFF28a745);
        label = 'Active';
        break;
      case 'draft':
        color = const Color(0xFFffc107);
        label = 'Draft';
        break;
      case 'completed':
        color = const Color(0xFF6c757d);
        label = 'Completed';
        break;
      default:
        color = Colors.grey;
        label = status;
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

  Widget _buildProgressSection(double progress, double budget, double spent) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Progress',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF2c3e50),
              ),
            ),
            Text(
              '${(progress * 100).toInt()}%',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF667eea),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.grey.shade200,
          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF667eea)),
          minHeight: 8,
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Budget: \$${budget.toStringAsFixed(0)}',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
            Text(
              'Spent: \$${spent.toStringAsFixed(0)}',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricsRow(Map<String, dynamic> campaign) {
    return Row(
      children: [
        Expanded(
          child:
              _buildMetric('Reach', '${campaign['reach']}', Icons.visibility),
        ),
        Expanded(
          child: _buildMetric(
              'Engagement', '${campaign['engagement']}%', Icons.trending_up),
        ),
      ],
    );
  }

  Widget _buildMetric(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF667eea)),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
      ],
    );
  }

  Widget _buildPlatformsRow(List<String> platforms) {
    return Wrap(
      spacing: 8,
      children: platforms
          .map((platform) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  platform,
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: Colors.grey.shade700,
                  ),
                ),
              ))
          .toList(),
    );
  }

  void _showCampaignDetails(Map<String, dynamic> campaign) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildCampaignDetailsSheet(campaign),
    );
  }

  Widget _buildCampaignDetailsSheet(Map<String, dynamic> campaign) {
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
                  Text(
                    campaign['name'],
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2c3e50),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildDetailRow('Status', campaign['status'], Icons.info),
                  _buildDetailRow('Budget', '\$${campaign['budget']}',
                      Icons.account_balance_wallet),
                  _buildDetailRow(
                      'Reach', '${campaign['reach']}', Icons.visibility),
                  _buildDetailRow('Engagement', '${campaign['engagement']}%',
                      Icons.trending_up),
                  const SizedBox(height: 24),
                  Text(
                    'Performance Chart',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF2c3e50),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 200,
                    child: LineChart(
                      LineChartData(
                        gridData: const FlGridData(show: false),
                        titlesData: const FlTitlesData(
                          leftTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          bottomTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          rightTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          topTitles: AxisTitles(
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
                            ],
                            isCurved: true,
                            color: const Color(0xFF667eea),
                            barWidth: 3,
                            dotData: const FlDotData(show: true),
                            belowBarData: BarAreaData(
                              show: true,
                              color: const Color(0xFF667eea)
                                  .withValues(alpha: 0.1),
                            ),
                          ),
                        ],
                      ),
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

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF667eea), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF2c3e50),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showCampaignOptions(Map<String, dynamic> campaign) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit, color: Color(0xFF667eea)),
              title: Text('Edit Campaign', style: GoogleFonts.poppins()),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.analytics, color: Color(0xFF28a745)),
              title: Text('View Analytics', style: GoogleFonts.poppins()),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Color(0xFFdc3545)),
              title: Text('Delete Campaign', style: GoogleFonts.poppins()),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateCampaignDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Create New Campaign', style: GoogleFonts.poppins()),
        content: Text('Campaign creation feature coming soon!',
            style: GoogleFonts.poppins()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK', style: GoogleFonts.poppins()),
          ),
        ],
      ),
    );
  }
}
