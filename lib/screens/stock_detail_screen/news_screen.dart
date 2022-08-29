import 'package:flutter/material.dart';
import '/models/stock.dart';
import '/screens/stock_detail_screen/news_widget.dart';

// by cliking 'see all' button
// display the list of news.

class NewsScreen extends StatelessWidget {
  const NewsScreen({
    Key? key,
    required this.setScreen,
    required this.ticker,
  }) : super(key: key);
  final Function setScreen;
  final Ticker ticker;
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8),
      child: Column(
        children: [
          Row(
            children: [
              InkWell(
                onTap: () {
                  setScreen('stock detail');
                },
                child: const Icon(
                  Icons.arrow_back,
                  size: 30,
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              const Text(
                'News',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  for (final news in ticker.newsList)
                    TickerNews(
                      news: news,
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
