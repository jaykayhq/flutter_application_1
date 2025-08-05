// Path: lib/main.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app/modules/home/views/trends_view.dart' as trends;
import 'app/modules/home/views/insights_view.dart' as insights;
import 'app/modules/home/views/dashboard_view.dart' as dashboard;
import 'app/modules/home/views/campaign_tracker_view.dart' as campaign;
import 'app/modules/home/views/recommendations_view.dart' as recommendations;
import 'app/modules/home/views/profile_view.dart' as profile;
import 'app/modules/home/views/web_crawler_view.dart' as crawler;
import 'app/modules/home/views/auth_gate.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://druyjbsgrfauseoxjeas.supabase.co',
    anonKey: 'sb_publishable_SlmJi5enB74vzJpjuxRx6A_Yie-VriP',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SME Social Analytics',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: const AuthGate(child: MainScreen()),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  static final List<Widget> _widgetOptions = <Widget>[
    const dashboard.DashboardView(),
    const trends.TrendsView(),
    const insights.InsightsView(),
    const campaign.CampaignTrackerView(),
    const recommendations.RecommendationsView(),
    const crawler.WebCrawlerView(),
    const profile.ProfileView(),
  ];

  static final List<String> _titles = [
    'Dashboard',
    'Trends',
    'Insights',
    'Campaigns',
    'Recommendations',
    'Crawler',
    'Profile',
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
      ),
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.trending_up),
            label: 'Trends',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.insights),
            label: 'Insights',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.campaign),
            label: 'Campaigns',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.recommend),
            label: 'Recommendations',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.web),
            label: 'Crawler',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF28a745),
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}
