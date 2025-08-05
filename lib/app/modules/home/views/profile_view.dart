import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _notificationsEnabled = true;
  // Removed unused fields: _darkModeEnabled and _selectedLanguage

  final List<Map<String, dynamic>> _menuItems = [
    {
      'title': 'Account Settings',
      'subtitle': 'Manage your account information',
      'icon': Icons.person_outline,
      'color': const Color(0xFF667eea),
    },
    {
      'title': 'Notifications',
      'subtitle': 'Configure notification preferences',
      'icon': Icons.notifications_outlined,
      'color': const Color(0xFF28a745),
    },
    {
      'title': 'Privacy & Security',
      'subtitle': 'Manage your privacy settings',
      'icon': Icons.security,
      'color': const Color(0xFFdc3545),
    },
    {
      'title': 'Help & Support',
      'subtitle': 'Get help and contact support',
      'icon': Icons.help_outline,
      'color': const Color(0xFFffc107),
    },
    {
      'title': 'About',
      'subtitle': 'App version and information',
      'icon': Icons.info_outline,
      'color': const Color(0xFF6c757d),
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
    final user = Supabase.instance.client.auth.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFf8f9fa),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildProfileHeader(user),
              const SizedBox(height: 24),
              _buildStatsSection(),
              const SizedBox(height: 24),
              _buildMenuSection(),
              const SizedBox(height: 24),
              _buildLogoutButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(User? user) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF667eea), Color(0xFF764ba2)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Profile Avatar
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
              border: Border.all(
                  color: Colors.white.withValues(alpha: 0.3), width: 3),
            ),
            child: Center(
              child: Text(
                _getInitials(user?.email ?? 'User'),
                style: GoogleFonts.poppins(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // User Info
          Text(
            user?.email?.split('@').first ?? 'User',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            user?.email ?? 'user@example.com',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 16),

          // Edit Profile Button
          Container(
            width: double.infinity,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _showEditProfileDialog(user),
                borderRadius: BorderRadius.circular(12),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.edit, color: Colors.white, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Edit Profile',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getInitials(String email) {
    if (email.isEmpty) return 'U';
    final parts = email.split('@');
    if (parts.isEmpty) return 'U';
    final name = parts[0];
    if (name.length >= 2) {
      return name.substring(0, 2).toUpperCase();
    }
    return name.toUpperCase();
  }

  Widget _buildStatsSection() {
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
            'Account Statistics',
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
                child: _buildStatItem(
                    'Campaigns', '12', Icons.campaign, const Color(0xFF667eea)),
              ),
              Expanded(
                child: _buildStatItem(
                    'Reports', '8', Icons.assessment, const Color(0xFF28a745)),
              ),
              Expanded(
                child: _buildStatItem(
                    'Insights', '24', Icons.lightbulb, const Color(0xFFffc107)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
      String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF2c3e50),
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuSection() {
    return Container(
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
        children: _menuItems.map((item) => _buildMenuItem(item)).toList(),
      ),
    );
  }

  Widget _buildMenuItem(Map<String, dynamic> item) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _handleMenuItemTap(item['title']),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: (item['color'] as Color).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  item['icon'],
                  color: item['color'],
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['title'],
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF2c3e50),
                      ),
                    ),
                    Text(
                      item['subtitle'],
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        color: const Color(0xFFdc3545).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border:
            Border.all(color: const Color(0xFFdc3545).withValues(alpha: 0.3)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _showLogoutDialog,
          borderRadius: BorderRadius.circular(12),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.logout, color: Color(0xFFdc3545), size: 20),
                const SizedBox(width: 8),
                Text(
                  'Sign Out',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFdc3545),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleMenuItemTap(String title) {
    switch (title) {
      case 'Account Settings':
        _showAccountSettings();
        break;
      case 'Notifications':
        _showNotificationSettings();
        break;
      case 'Privacy & Security':
        _showPrivacySettings();
        break;
      case 'Help & Support':
        _showHelpSupport();
        break;
      case 'About':
        _showAboutDialog();
        break;
    }
  }

  void _showEditProfileDialog(User? user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Profile', style: GoogleFonts.poppins()),
        content: Text('Profile editing feature coming soon!',
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

  void _showAccountSettings() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildSettingsSheet('Account Settings', [
        _buildSettingItem('Change Email', Icons.email, () {}),
        _buildSettingItem('Change Password', Icons.lock, () {}),
        _buildSettingItem('Two-Factor Authentication', Icons.security, () {}),
        _buildSettingItem('Delete Account', Icons.delete_forever, () {},
            isDestructive: true),
      ]),
    );
  }

  void _showNotificationSettings() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildSettingsSheet('Notification Settings', [
        _buildSwitchSettingItem('Push Notifications', _notificationsEnabled,
            (value) {
          setState(() => _notificationsEnabled = value);
        }),
        _buildSettingItem('Email Notifications', Icons.email, () {}),
        _buildSettingItem('Campaign Alerts', Icons.campaign, () {}),
        _buildSettingItem('Trend Updates', Icons.trending_up, () {}),
      ]),
    );
  }

  void _showPrivacySettings() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildSettingsSheet('Privacy & Security', [
        _buildSettingItem('Privacy Policy', Icons.privacy_tip, () {}),
        _buildSettingItem('Terms of Service', Icons.description, () {}),
        _buildSettingItem('Data Usage', Icons.data_usage, () {}),
        _buildSettingItem('Export Data', Icons.download, () {}),
      ]),
    );
  }

  void _showHelpSupport() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildSettingsSheet('Help & Support', [
        _buildSettingItem('FAQ', Icons.help, () {}),
        _buildSettingItem('Contact Support', Icons.support_agent, () {}),
        _buildSettingItem('Report Bug', Icons.bug_report, () {}),
        _buildSettingItem('Feature Request', Icons.lightbulb, () {}),
      ]),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('About', style: GoogleFonts.poppins()),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('SME Social Analytics',
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Version 1.0.0', style: GoogleFonts.poppins()),
            const SizedBox(height: 8),
            Text(
                'A comprehensive social media analytics platform for Nigerian SMEs.',
                style: GoogleFonts.poppins()),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK', style: GoogleFonts.poppins()),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSheet(String title, List<Widget> items) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
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
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2c3e50),
                  ),
                ),
                const SizedBox(height: 20),
                ...items,
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem(String title, IconData icon, VoidCallback onTap,
      {bool isDestructive = false}) {
    return ListTile(
      leading: Icon(
        icon,
        color:
            isDestructive ? const Color(0xFFdc3545) : const Color(0xFF667eea),
      ),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          color:
              isDestructive ? const Color(0xFFdc3545) : const Color(0xFF2c3e50),
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  Widget _buildSwitchSettingItem(
      String title, bool value, ValueChanged<bool> onChanged) {
    return ListTile(
      leading: const Icon(Icons.notifications, color: Color(0xFF667eea)),
      title: Text(title, style: GoogleFonts.poppins()),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: const Color(0xFF667eea),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Sign Out', style: GoogleFonts.poppins()),
        content: Text('Are you sure you want to sign out?',
            style: GoogleFonts.poppins()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.poppins()),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await Supabase.instance.client.auth.signOut();
            },
            child: Text(
              'Sign Out',
              style: GoogleFonts.poppins(color: const Color(0xFFdc3545)),
            ),
          ),
        ],
      ),
    );
  }
}
