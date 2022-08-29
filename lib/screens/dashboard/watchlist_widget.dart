import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class WatchlistWidget extends StatelessWidget {
  WatchlistWidget({Key? key, required this.ticker}) : super(key: key);
  final dynamic ticker;
  late bool isLoading;
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 8.0,
          vertical: 10,
        ),
        child: Row(
          children: [
            Expanded(
              child: Align(
                // alignment: Alignment.centerLeft,
                child: Icon(
                  Icons.star,
                  color: Colors.amber[300],
                ),
              ),
            ),
            CircleAvatar(
              radius: 15.0,
              backgroundImage:
                  AssetImage("${ticker.logoPath}${ticker.symbol}.png"), // uri
              // backgroundImage: NetworkImage('${ticker.logoUrl}'),
              backgroundColor: Colors.transparent,
            ),
            const SizedBox(
              width: 5,
            ),
            Column(
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    ticker.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                () {
                  final String price =
                      ticker.quote['change percent'].toString();
                  print(price);
                  String res;
                  if (ticker.quote['change percent']! > 0) {
                    res = '+\$$price';
                  } else {
                    res = '-\$${price.substring(1, price.length)}';
                  }
                  return FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      res,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: ticker.quote['change percent']! > 0
                            ? Colors.green
                            : Colors.red,
                      ),
                    ),
                  );
                }(),
              ],
            ),

            // quote
            Expanded(
              flex: 3,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  '\$${ticker.quote['price']}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
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

Widget _buildDefaultLineChart(dynamic currentTicker, String type) {
  if (currentTicker.prices[type] == null) {
    return Container();
  }
  // 这是个外部包
  return SfCartesianChart(
    primaryXAxis: CategoryAxis(
      isVisible: false,
    ), // Initialize category axis.

    series: <LineSeries<Map<String, dynamic>, String>>[
      // Initialize line series.
      LineSeries<Map<String, dynamic>, String>(
        dataSource: [...currentTicker.prices[type]!],
        xValueMapper: (Map<String, dynamic> price, _) => price.keys.first,
        yValueMapper: (Map<String, dynamic> price, _) => price.values.first,
      ),
    ],
  );
}
