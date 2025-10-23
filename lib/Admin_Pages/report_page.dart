// analytics_screen.dart
import 'dart:async';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  String selectedRange = 'Weekly'; // Daily, Weekly, Monthly
  bool loading = false;

  // Summary metrics
  int totalOrders = 0;
  double totalRevenue = 0.0;
  double percentageChange = 0.0;
  bool isIncrease = true;

  // Collections
  List<Map<String, dynamic>> bestProducts = [];
  List<Map<String, dynamic>> topCustomers = [];

  // Chart data
  Map<String, int> paymentMethodCounts = {};
  List<BarChartGroupData> salesPerDayBars = [];
  List<FlSpot> revenueLineSpots = [];
  List<FlSpot> ordersLineSpots = [];
  List<String> lineXAxisLabels = [];

  // Raw current and previous orders (docs)
  List<QueryDocumentSnapshot> currentOrders = [];
  List<QueryDocumentSnapshot> previousOrders = [];

  final firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _fetchAndCompute();
  }

  Future<void> _fetchAndCompute() async {
    setState(() => loading = true);

    try {
      final now = DateTime.now();
      DateTime startCurrent, startPrev, endPrev;

      if (selectedRange == 'Daily') {
        startCurrent = DateTime(now.year, now.month, now.day);
        startPrev = startCurrent.subtract(const Duration(days: 1));
        endPrev = startCurrent.subtract(const Duration(seconds: 1));
      } else if (selectedRange == 'Weekly') {
        final monday = now.subtract(Duration(days: now.weekday - 1));
        startCurrent = DateTime(monday.year, monday.month, monday.day);
        startPrev = startCurrent.subtract(const Duration(days: 7));
        endPrev = startCurrent.subtract(const Duration(seconds: 1));
      } else {
        startCurrent = DateTime(now.year, now.month, 1);
        startPrev = DateTime(startCurrent.year, startCurrent.month - 1, 1);
        endPrev = startCurrent.subtract(const Duration(seconds: 1));
      }

      final usersSnap = await firestore.collection('users').get();
      List<QueryDocumentSnapshot> allOrders = [];

      for (final userDoc in usersSnap.docs) {
        final ordersSnap = await userDoc.reference.collection('orders').get();
        allOrders.addAll(ordersSnap.docs);
      }

      currentOrders =
          allOrders.where((d) {
            final ts = d['orderDate'];
            if (ts is Timestamp) {
              final date = ts.toDate();
              return !date.isBefore(startCurrent);
            }
            return false;
          }).toList();

      previousOrders =
          allOrders.where((d) {
            final ts = d['orderDate'];
            if (ts is Timestamp) {
              final date = ts.toDate();
              return date.isAfter(startPrev) && date.isBefore(endPrev);
            }
            return false;
          }).toList();

      // compute totals
      totalOrders = currentOrders.length;
      totalRevenue = currentOrders.fold(
        0.0,
        (s, d) => s + ((d['total'] ?? 0) as num).toDouble(),
      );

      final prevRevenue = previousOrders.fold(
        0.0,
        (s, d) => s + ((d['total'] ?? 0) as num).toDouble(),
      );

      if (prevRevenue == 0) {
        percentageChange = prevRevenue == totalRevenue ? 0.0 : 100.0;
      } else {
        percentageChange = ((totalRevenue - prevRevenue) / prevRevenue) * 100.0;
      }
      isIncrease = percentageChange >= 0;

      // best products
      final Map<String, Map<String, dynamic>> productStats = {};
      for (final order in currentOrders) {
        final items = List.from(order['items'] ?? []);
        for (final raw in items) {
          final id = raw['productId'] ?? raw['id'];
          if (id == null) continue;
          final qty = (raw['quantity'] ?? 0) as int;
          if (!productStats.containsKey(id)) {
            productStats[id] = {
              'productId': id,
              'name': raw['name'] ?? 'Unknown',
              'image': raw['image'] ?? '',
              'sold': qty,
            };
          } else {
            productStats[id]!['sold'] =
                (productStats[id]!['sold'] as int) + qty;
          }
        }
      }

      bestProducts =
          productStats.values.toList()
            ..sort((a, b) => (b['sold'] as int).compareTo(a['sold'] as int));
      if (bestProducts.length > 5) bestProducts = bestProducts.sublist(0, 5);

      // top customers
      final Map<String, Map<String, dynamic>> customerStats = {};
      for (final order in currentOrders) {
        final name = order['customer'] ?? 'Unknown';
        final phone = order['phone'] ?? '';
        final city = order['city'] ?? '';
        final userId = order['userId'] ?? '';
        final total = ((order['total'] ?? 0) as num).toDouble();

        final key = userId != '' ? userId : '$name|$phone';

        if (!customerStats.containsKey(key)) {
          customerStats[key] = {
            'name': name,
            'phone': phone,
            'city': city,
            'orders': 1,
            'spent': total,
          };
        } else {
          customerStats[key]!['orders'] =
              (customerStats[key]!['orders'] as int) + 1;
          customerStats[key]!['spent'] =
              (customerStats[key]!['spent'] as double) + total;
        }
      }

      topCustomers =
          customerStats.values.toList()..sort(
            (a, b) => (b['orders'] as int).compareTo(a['orders'] as int),
          );
      if (topCustomers.length > 3) topCustomers = topCustomers.sublist(0, 3);

      // payment methods
      paymentMethodCounts = {};
      for (final order in currentOrders) {
        final method = (order['paymentMethod'] ?? 'Unknown').toString();
        paymentMethodCounts[method] = (paymentMethodCounts[method] ?? 0) + 1;
      }

      // sales per day & line charts
      List<DateTime> dayBuckets = [];
      if (selectedRange == 'Daily') {
        dayBuckets = [
          DateTime(startCurrent.year, startCurrent.month, startCurrent.day),
        ];
      } else if (selectedRange == 'Weekly') {
        for (int i = 0; i < 7; i++) {
          dayBuckets.add(
            DateTime(
              startCurrent.year,
              startCurrent.month,
              startCurrent.day,
            ).add(Duration(days: i)),
          );
        }
      } else {
        final daysInMonth =
            DateTime(startCurrent.year, startCurrent.month + 1, 0).day;
        for (int i = 0; i < daysInMonth; i++) {
          dayBuckets.add(
            DateTime(
              startCurrent.year,
              startCurrent.month,
              1,
            ).add(Duration(days: i)),
          );
        }
      }

      final Map<String, int> dayCounts = {};
      final Map<String, double> dayRevenue = {};
      for (final d in dayBuckets) {
        final key = DateFormat('yyyy-MM-dd').format(d);
        dayCounts[key] = 0;
        dayRevenue[key] = 0.0;
      }

      for (final order in currentOrders) {
        final ts = order['orderDate'];
        if (ts is Timestamp) {
          final d = ts.toDate();
          final key = DateFormat('yyyy-MM-dd').format(d);
          if (!dayCounts.containsKey(key)) continue;
          dayCounts[key] = (dayCounts[key] ?? 0) + 1;
          dayRevenue[key] =
              (dayRevenue[key] ?? 0) +
              ((order['total'] ?? 0) as num).toDouble();
        }
      }

      salesPerDayBars = [];
      revenueLineSpots = [];
      ordersLineSpots = [];
      lineXAxisLabels = [];

      int idx = 0;
      for (final d in dayBuckets) {
        final key = DateFormat('yyyy-MM-dd').format(d);
        final ordersOnDay = dayCounts[key] ?? 0;
        final revenueOnDay = dayRevenue[key] ?? 0.0;

        salesPerDayBars.add(
          BarChartGroupData(
            x: idx,
            barRods: [BarChartRodData(toY: ordersOnDay.toDouble(), width: 12)],
          ),
        );

        ordersLineSpots.add(FlSpot(idx.toDouble(), ordersOnDay.toDouble()));
        revenueLineSpots.add(FlSpot(idx.toDouble(), revenueOnDay));

        final label =
            selectedRange == 'Weekly'
                ? DateFormat('E').format(d)
                : (selectedRange == 'Daily'
                    ? DateFormat('HH:mm').format(d)
                    : DateFormat('d').format(d));
        lineXAxisLabels.add(label);

        idx++;
      }
    } catch (e, st) {
      debugPrint('Error computing analytics: $e\n$st');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to load analytics: $e')));
    } finally {
      setState(() => loading = false);
    }
  }

  // PDF
  Future<void> _exportPdf() async {
    final doc = pw.Document();
    final dateStr = DateFormat.yMd().add_Hm().format(DateTime.now());

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return [
            pw.Header(level: 0, child: pw.Text('Sales Report - $dateStr')),
            pw.Paragraph(text: 'Range: $selectedRange'),
            pw.SizedBox(height: 8),
            pw.Text('Total Orders: $totalOrders'),
            pw.Text('Total Revenue: ₪${totalRevenue.toStringAsFixed(2)}'),
            pw.Text(
              'Change vs previous: ${isIncrease ? "+" : ""}${percentageChange.toStringAsFixed(1)}%',
            ),
          ];
        },
      ),
    );

    final bytes = await doc.save();
    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => bytes);
  }

  Widget _buildTimeRangeButtons() {
    return Row(
      children:
          ['Daily', 'Weekly', 'Monthly'].map((range) {
            final sel = selectedRange == range;
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    selectedRange = range;
                  });
                  _fetchAndCompute();
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  height: 40,
                  decoration: BoxDecoration(
                    color: sel ? Colors.white : const Color(0xFFE7EDF4),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow:
                        sel
                            ? [BoxShadow(color: Colors.black12, blurRadius: 4)]
                            : [],
                  ),
                  child: Center(
                    child: Text(
                      range,
                      style: TextStyle(
                        color:
                            sel
                                ? const Color(0xFF0D141C)
                                : const Color(0xFF49709C),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
    );
  }

  // Pie chart
  Widget _buildPaymentPie(double size) {
    if (paymentMethodCounts.isEmpty) {
      return SizedBox(
        height: size,
        child: const Center(child: Text('No payments yet')),
      );
    }

    final entries = paymentMethodCounts.entries.toList();
    final total = entries.fold<int>(0, (s, e) => s + e.value);

    return SizedBox(
      height: size,
      child: Column(
        children: [
          Expanded(
            child: PieChart(
              PieChartData(
                sections: List.generate(entries.length, (i) {
                  final val = entries[i].value;
                  final percent = total == 0 ? 0.0 : (val / total) * 100;
                  final color = _colorForIndex(i);
                  return PieChartSectionData(
                    value: val.toDouble(),
                    title: '${entries[i].key}\n${percent.toStringAsFixed(0)}%',
                    color: color,
                    radius: size * 0.15,
                    titleStyle: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  );
                }),
                sectionsSpace: 2,
                centerSpaceRadius: size * 0.08,
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  // Bar chart
  Widget _buildBarChart(double height) {
    if (salesPerDayBars.isEmpty) {
      return SizedBox(
        height: height,
        child: const Center(child: Text('No sales data')),
      );
    }
    return SizedBox(
      height: height,
      child: BarChart(
        BarChartData(
          barGroups: salesPerDayBars,
          gridData: FlGridData(show: true),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40, // increase from default 28
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toInt().toString(),
                    style: const TextStyle(fontSize: 10),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final idx = value.toInt();
                  final label =
                      (idx >= 0 && idx < lineXAxisLabels.length)
                          ? lineXAxisLabels[idx]
                          : '';
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    child: Text(label, style: const TextStyle(fontSize: 10)),
                  );
                },
                reservedSize: 28,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Line chart
  Widget _buildLineChart(double height) {
    if (ordersLineSpots.isEmpty || revenueLineSpots.isEmpty) {
      return SizedBox(
        height: height,
        child: const Center(child: Text('No data for chart')),
      );
    }

    final maxOrders = ordersLineSpots
        .map((s) => s.y)
        .fold<double>(0.0, (a, b) => a > b ? a : b);
    final maxRevenue = revenueLineSpots
        .map((s) => s.y)
        .fold<double>(0.0, (a, b) => a > b ? a : b);
    final revenueScale =
        (maxRevenue == 0)
            ? 1.0
            : (maxOrders == 0 ? 1.0 : maxOrders / maxRevenue);
    final scaledRevenue =
        revenueLineSpots.map((s) => FlSpot(s.x, s.y * revenueScale)).toList();

    return SizedBox(
      height: 200,
      child: LineChart(
        LineChartData(
          lineBarsData: [
            LineChartBarData(
              spots: ordersLineSpots,
              isCurved: true,
              dotData: FlDotData(show: true),
              barWidth: 2,
              color: Colors.blue,
            ),
            LineChartBarData(
              spots: scaledRevenue,
              isCurved: true,
              dotData: FlDotData(show: false),
              barWidth: 2,
              color: Colors.green,
            ),
          ],
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40, // increase reserved size
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toInt().toString(),
                    style: const TextStyle(fontSize: 10),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (val, meta) {
                  final idx = val.toInt();
                  final label =
                      (idx >= 0 && idx < lineXAxisLabels.length)
                          ? lineXAxisLabels[idx]
                          : '';
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    child: Text(label, style: const TextStyle(fontSize: 10)),
                  );
                },
                reservedSize: 28,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _colorForIndex(int i) {
    const palette = [
      Color(0xFF0D78F2),
      Color(0xFF07883B),
      Color(0xFFF59E0B),
      Color(0xFFEF4444),
      Color(0xFF7C3AED),
      Color(0xFF06B6D4),
    ];
    return palette[i % palette.length];
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF1F5F9),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Sales Overview',
          style: TextStyle(
            color: Color(0xFF0D141C),
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.file_copy_outlined,
              color: Color(0xFF0D141C),
            ),
            onPressed: _exportPdf,
            tooltip: 'Export PDF',
          ),
        ],
      ),
      body:
          loading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                onRefresh: _fetchAndCompute,
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildTimeRangeButtons(),
                    const SizedBox(height: 16),
                    Card(
                      margin: EdgeInsets.zero,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Revenue',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '₪${totalRevenue.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Text('vs last $selectedRange'),
                                const SizedBox(width: 8),
                                Text(
                                  '${isIncrease ? '+' : ''}${percentageChange.toStringAsFixed(1)}%',
                                  style: TextStyle(
                                    color:
                                        isIncrease ? Colors.green : Colors.red,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            _buildLineChart(size.height * 0.25),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'Best-Selling Products',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: size.height * 0.4,
                      child:
                          bestProducts.isEmpty
                              ? const Center(child: Text('No data'))
                              : ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: bestProducts.length,
                                itemBuilder: (context, i) {
                                  final p = bestProducts[i];
                                  return Container(
                                    width: size.width * 0.4,
                                    margin: const EdgeInsets.only(right: 12),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        AspectRatio(
                                          aspectRatio: 1,
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            child:
                                                p['image'] != null &&
                                                        (p['image'] as String)
                                                            .isNotEmpty
                                                    ? Image.network(
                                                      p['image'],
                                                      fit: BoxFit.cover,
                                                      errorBuilder:
                                                          (
                                                            _,
                                                            __,
                                                            ___,
                                                          ) => Container(
                                                            color:
                                                                Colors
                                                                    .grey
                                                                    .shade200,
                                                          ),
                                                    )
                                                    : Container(
                                                      color:
                                                          Colors.grey.shade200,
                                                    ),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          p['name'] ?? 'Unknown',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                          ),
                                          maxLines: 2, // limit to 2 lines
                                          overflow:
                                              TextOverflow
                                                  .ellipsis, // show "..." if overflow
                                        ),
                                        Text(
                                          '${p['sold']} units',
                                          style: const TextStyle(
                                            color: Color(0xFF49709C),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                    ),

                    const SizedBox(height: 18),
                    const Text(
                      'Top Customers',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...topCustomers.map((c) {
                      return Card(
                        child: ListTile(
                          leading: const CircleAvatar(
                            backgroundColor: Color(0xFFE7EDF4),
                            child: Icon(Icons.person, color: Color(0xFF0D141C)),
                          ),
                          title: Text(c['name'] ?? 'Unknown'),
                          subtitle: Text(
                            '${c['city'] ?? ''} • ${c['phone'] ?? ''}',
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('${c['orders']}'),
                              const Text(
                                'orders',
                                style: TextStyle(fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                    const SizedBox(height: 18),
                    const Text(
                      'Payment Methods',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildPaymentPie(size.height * 0.2),
                    const SizedBox(height: 18),
                    const Text(
                      'Sales per Day',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildBarChart(size.height * 0.25),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _exportPdf,
                      icon: const Icon(Icons.file_download),
                      label: const Text('Export Report (PDF)'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(size.width, 48),
                      ),
                    ),
                  ],
                ),
              ),
    );
  }
}
