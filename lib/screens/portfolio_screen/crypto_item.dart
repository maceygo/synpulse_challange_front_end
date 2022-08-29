import 'package:flutter/material.dart';

import '../../models/cryptocurrency.dart';

class CurrencyItem extends StatelessWidget {
  const CurrencyItem({Key? key, required this.cryptocurrency})
      : super(key: key);
  final Cryptocurrency cryptocurrency;
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3, //shadow
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 8.0,
          vertical: 10,
        ),
        child: Row(children: [
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: Icon(
                Icons.star,
                color: Colors.amber[300],
              ),
            ),
          ),
          CircleAvatar(
            radius: 15.0,
            backgroundImage: AssetImage(
                "assets/coin/${cryptocurrency.symbol.toLowerCase()}.png"), // uri
            // backgroundImage: NetworkImage('${cryptocurrency.logoUrl}'),
            backgroundColor: Colors.transparent,
          ),
          const SizedBox(
            width: 5,
          ),
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                cryptocurrency.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                "\$${cryptocurrency.quote['price']}",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              // 根据改变百分比是正还是负的来选择背景颜色是绿色还是红色
              color: cryptocurrency.quote['change percent']! < 0
                  ? Colors.green[100]
                  : Colors.red[100],
              borderRadius: BorderRadius.circular(
                5,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                // 改变百分比
                '${cryptocurrency.quote['change percent']}%',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: cryptocurrency.quote['change percent']! < 0
                      ? Colors.green
                      : Colors.red,
                ),
              ),
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                "${cryptocurrency.quote['volume']}",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
