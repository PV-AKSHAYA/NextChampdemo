import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class PerformanceChart extends StatelessWidget {
  final List<FlSpot> performancePoints;

  const PerformanceChart({Key? key, required this.performancePoints}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 250,
      child: LineChart(
        LineChartData(
          lineBarsData: [
            LineChartBarData(
              spots: performancePoints,
              isCurved: true,
              barWidth: 4,
              color: Colors.deepPurple,  // singular 'color'
              dotData: FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                color: Colors.deepPurple.withOpacity(0.3),  // singular 'color'
              ),
            ),
          ],
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: true, reservedSize: 30, getTitlesWidget: _bottomTitleWidgets),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: true, reservedSize: 40, getTitlesWidget: _leftTitleWidgets),
            ),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(show: true),
          borderData: FlBorderData(show: true),
          minY: 0,
        ),
      ),
    );
  }

Widget _bottomTitleWidgets(double value, TitleMeta meta) {
  const style = TextStyle(
    color: Colors.grey,
    fontWeight: FontWeight.bold,
    fontSize: 12,
  );

  String text;
  switch (value.toInt()) {
    case 0:
      text = 'Test 1';
      break;
    case 1:
      text = 'Test 2';
      break;
    case 2:
      text = 'Test 3';
      break;
    case 3:
      text = 'Test 4';
      break;
    case 4:
      text = 'Test 5';
      break;
    default:
      return Container();
  }

  return SideTitleWidget(
    meta: meta, // pass meta object here as named parameter
    space: 6,
    child: Text(text, style: style),
  );
}

Widget _leftTitleWidgets(double value, TitleMeta meta) {
  const style = TextStyle(
    color: Colors.grey,
    fontWeight: FontWeight.bold,
    fontSize: 12,
  );

  if (value % 10 == 0) {
    return SideTitleWidget(
      meta: meta, // pass meta object here too
      child: Text(value.toInt().toString(), style: style),
    );
  }
  return Container();
}

}
