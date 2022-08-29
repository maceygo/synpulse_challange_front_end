import 'package:flutter/material.dart';

import '../../models/portfolio.dart';

// this widget will be added into the stock tab body of Portfolio screen . 08/28

// returns the historical portfolio rankings from the Alpha Tournament, world's leading portfolio competition and investors community.

// https://www.alphavantage.co/query?function=TOURNAMENT_PORTFOLIO&season=2022-07&apikey=M8EGV7V9H8YDSROH

// {
//     "season": "2022-06",
//     "ranking": [
//         {
//             "rank": "1",
//             "portfolio": [
//                 {
//                     "symbol": "GMVD",
//                     "shares": "100"
//                 }
//             ],
//             "measurement_start": "2022-06-10",
//             "start_value_usd": "34.51",
//             "measurement_end": "2022-06-24",
//             "end_value_usd": "67.0",
//             "percent_gain": "94.14662"
//         },
//         {
//             "rank": "2",
//             "portfolio": [
//                 {
//                     "symbol": "KOLD",
//                     "shares": "1000"
//                 }
//             ],
//             "measurement_start": "2022-06-10",
//             "start_value_usd": "19860.0",
//             "measurement_end": "2022-06-24",
//             "end_value_usd": "34820.0",
//             "percent_gain": "75.32729"
//         },
//     ]
// }

class PortfolioWidget extends StatelessWidget {
  const PortfolioWidget({Key? key, required this.portfolio}) : super(key: key);
  final Portfolio portfolio;
  @override
  Widget build(BuildContext context) {
    return Card(
        child: Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 5.0,
        vertical: 5.0,
      ),
      child: Column(children: [
        Text(
          "rank: ${portfolio.rank}",
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
        Text(
          "from ${portfolio.measurementStart} to ${portfolio.measurementEnd}",
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.grey,
          ),
        ),
        Text(
          "value from \$${portfolio.startValueUsd} to \$${portfolio.endValueUsd}",
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.grey,
          ),
        ),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(
              5,
            ),
            color: double.parse(portfolio.percentGain) > 0
                ? Colors.red[100]
                : Colors.green[100],
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              double.parse(portfolio.percentGain) > 0
                  ? '+${(double.parse(portfolio.percentGain)).toStringAsFixed(2)}%'
                  : '-${(double.parse(portfolio.percentGain)).toStringAsFixed(2)}%',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: double.parse(portfolio.percentGain) > 0
                    ? Colors.red
                    : Colors.green,
              ),
            ),
          ),
        ),
        for (dynamic ticker in portfolio.tickers) // Map<String, String>
          Text(
            "symbol: ${ticker["symbol"]} shares:${ticker["shares"]}",
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.blue,
            ),
          )
      ]),
    ));
  }
}
