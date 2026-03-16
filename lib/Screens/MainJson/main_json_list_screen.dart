import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../../models/main_json_models.dart';

class MainJsonListScreen extends StatefulWidget {
  static const routeName = '/main-json-list';
  const MainJsonListScreen({Key? key}) : super(key: key);

  @override
  State<MainJsonListScreen> createState() => _MainJsonListScreenState();
}

class _MainJsonListScreenState extends State<MainJsonListScreen> {
  late Future<List<LandRecord>> _futureRecords;

  @override
  void initState() {
    super.initState();
    _futureRecords = _loadRecords();
  }

  Future<List<LandRecord>> _loadRecords() async {
    final raw = await rootBundle.loadString('images/main.json');
    final List<dynamic> data = jsonDecode(raw);
    return data.map((e) => LandRecord.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Main JSON Records'),
      ),
      body: FutureBuilder<List<LandRecord>>(
        future: _futureRecords,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final records = snapshot.data ?? [];
          if (records.isEmpty) {
            return const Center(child: Text('No records found'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: records.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final r = records[index];
              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        r.ownerName ?? '-',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: 6),
                      Text('जिला: ${r.district ?? '-'}   तहसील: ${r.tehsil ?? '-'}'),
                      const SizedBox(height: 4),
                      Text('ग्राम: ${r.village ?? '-'}   पटवार हल्का: ${r.patwarCircle ?? '-'}'),
                      const SizedBox(height: 4),
                      Text('खाता: ${r.khataNo ?? '-'}  खसरा: ${r.khasraNo ?? '-'}'),
                      const SizedBox(height: 8),
                      Text('कुल क्षेत्रफल: ${r.area ?? '-'} हेक्टेयर'),
                      const SizedBox(height: 8),
                      if ((r.crops ?? []).isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('फसलें:'),
                            const SizedBox(height: 6),
                            ...r.crops!.map((c) => Text('- ${c.cropHin ?? '-'}  (${c.area ?? '-'})'))
                          ],
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

