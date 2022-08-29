import 'package:flutter/material.dart';

import '../../models/stock.dart';

class GainerWidget extends StatelessWidget {
  const GainerWidget({Key? key, required this.ticker}) : super(key: key);
  final Ticker ticker;
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 20.0,
          vertical: 30.0,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 30.0,
              backgroundImage:
                  AssetImage("assets/logo/${ticker.symbol}.png"), // uri
              // backgroundImage: NetworkImage('${ticker.logoUrl}'),
              backgroundColor: Colors.transparent,
            ),
            Text(
              ticker.name,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Text(
              '\$${ticker.quote['price']}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(
                      5,
                    ),
                    color: ticker.quote['change']! > 0
                        ? Colors.red[100]
                        : Colors.green[100],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      ticker.quote['change percent']! > 0
                          ? '+\$${ticker.quote['price']}'
                          : '-\$${ticker.quote['price']}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: ticker.quote['change']! > 0
                            ? Colors.red
                            : Colors.green,
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 5,
                ),
                () {
                  final String price = ticker.quote['change'].toString();
                  String res;
                  if (ticker.quote['change']! > 0) {
                    res = '+\$$price';
                  } else {
                    res = '-\$${price.substring(1, price.length)}';
                  }
                  return Text(
                    res,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey,
                    ),
                  );
                }(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
