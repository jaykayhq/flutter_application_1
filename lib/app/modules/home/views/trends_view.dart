// Path: lib/app/modules/home/views/insights_view.dart
import 'package:flutter/material.dart';
import '../../../data/models/actionable_insight_model.dart';
import '../../../data/repositories/supabase_repository.dart';

class InsightsView extends StatefulWidget {
  const InsightsView({super.key});

  @override
  State<InsightsView> createState() => _InsightsViewState();
}

class _InsightsViewState extends State<InsightsView> {
  final SupabaseRepository _repository = SupabaseRepository();
  late Future<List<ActionableInsight>> _insightsFuture;

  @override
  void initState() {
    super.initState();
    _insightsFuture = _repository.getActionableInsights();
  }

  void _refreshInsights() {
    setState(() {
      _insightsFuture = _repository.getActionableInsights();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ActionableInsight>>(
      future: _insightsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red)));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No insights generated yet.'));
        }
        final insights = snapshot.data!;
        return RefreshIndicator(
          onRefresh: () async => _refreshInsights(),
          child: ListView.builder(
            itemCount: insights.length,
            itemBuilder: (context, index) {
              final insight = insights[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: const Icon(Icons.lightbulb_outline, color: Colors.green),
                  title: Text(insight.insightText),
                  subtitle: Text('Source: ${insight.sourceAi}'),
                ),
              );
            },
          ),
        );
      },
    );
  }
}