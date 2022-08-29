import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../models/cryptocurrency.dart';
import '../../models/stock.dart';
import '../../models/user.dart';
import '../dashboard/dashboard_screen.dart';
import '../stock_detail_screen/stock_detail_screen.dart';
import 'crypto_detail.dart';
import 'crypto_item.dart';

// consist of two part
// 1. the total value of all cryptocurrencies with the same holdings in watchlist , will be show in the format of Line Chart.
// 2. the watchlist

class CryptoView extends StatefulWidget {
  const CryptoView({Key? key}) : super(key: key);

  @override
  State<CryptoView> createState() => _CryptoViewState();
}

class _CryptoViewState extends State<CryptoView> {
  late double totalnum;
  late double change;
  late double changePercent;
  String type = "weekly";
  late List<Map<dynamic, dynamic>> timeSeriesStatus;
  @override
  void initState() {
    savedCryptos = getMatchesSymbolCrypto(appUser.savedCryptoSymbols);
    getTotalNum(type);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      const Padding(
        padding: EdgeInsets.symmetric(horizontal: 10.0),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            // 股票代码
            'Total',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.grey,
            ),
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 8.0,
          vertical: 5,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                // 股票名字
                'Portfolio value',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 8.0,
          vertical: 5,
        ),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Row(
            children: [
              Text(
                // 价格
                '\$$totalnum',
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              Container(
                decoration: BoxDecoration(
                  // to determine backgroung color is red or green
                  color:
                      changePercent < 0 ? Colors.green[100] : Colors.red[100],
                  borderRadius: BorderRadius.circular(
                    5,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    '$changePercent%',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: changePercent < 0 ? Colors.green : Colors.red,
                    ),
                  ),
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              () {
                final String price = change.toString();
                String res;

                if (change > 0) {
                  res = '\$$price';
                } else {
                  res = '-\$${price.substring(1, price.length)}';
                }
                return Text(
                  res,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey,
                  ),
                );
              }(),
            ],
          ),
        ),
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          TimeSeriesButton(
            isPressed: type == "daily" ? true : false,
            function: () {
              type = "daily";
              getTotalNum(type);
              setState(() {});
            },
            name: '24h',
          ),
          TimeSeriesButton(
            function: () {
              type = "weekly";
              getTotalNum(type);
              setState(() {});
            },
            isPressed: type == "weekly" ? true : false,
            name: '7d',
          ),
        ],
      ),
      SizedBox(
        height: 250,
        child: _buildDefaultLineChart(totalwatch, type),
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: const [
          Text(
            'Your watchlist',
            style: TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
      const SizedBox(
        height: 10,
      ),
      loadedQuote
          ? Flexible(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    for (final cryptocurrency in savedCryptos)
                      if (!cryptocurrency.notGetQuote)
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CryptoDetailScreen(
                                  // deliver data when transfering page
                                  crypto: cryptocurrency,
                                ),
                              ),
                            );
                          },
                          child: CurrencyItem(
                            cryptocurrency: cryptocurrency,
                          ),
                        ),
                  ],
                ),
              ),
            )
          : const Center(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: CircularProgressIndicator(),
              ),
            ),
    ]);
  }

  void getTotalNum(String type) {
    double lastnum = 0.0;
    if (totalwatch.prices[type]?.length == 0) {
      totalnum = 0.0;
      change = 0.0;
      changePercent = 0.0;
    } else {
      for (double n in totalwatch.prices[type]![0].values) {
        // latest interval
        totalnum = double.parse(n.toStringAsFixed(3));
      }

      for (double n in totalwatch.prices[type]![1].values) {
        // last interval
        lastnum = n;
      }
      change = double.parse((totalnum - lastnum).toStringAsFixed(3));
      changePercent = double.parse((change / lastnum).toStringAsFixed(3));
    }

    // check the total value of user's watchlist is accrate

    // print("本时间间隔开盘$totalnum上一时间间隔开盘$lastnum变化$change占上一时间间隔开盘的$changePercent%");

    if (mounted) {
      setState(() {});
    }
    return;
  }
}

Widget _buildDefaultLineChart(dynamic currentTicker, String type) {
  return SfCartesianChart(
    primaryXAxis: CategoryAxis(
      isVisible: false,
    ), // Initialize category axis.
    series: <LineSeries<Map<String, dynamic>, String>>[
      LineSeries<Map<String, dynamic>, String>(
        dataSource: [...currentTicker.prices[type]!],
        xValueMapper: (Map<String, dynamic> price, _) => price.keys.first,
        yValueMapper: (Map<String, dynamic> price, _) => price.values.first,
      ),
    ],
  );
}
