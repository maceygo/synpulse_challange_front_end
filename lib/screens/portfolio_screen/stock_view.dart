import 'package:flutter/material.dart';

import '../../api_manager.dart';
import '../../models/portfolio.dart';
import '../../models/stock.dart';
import '../../models/user.dart';
import '../../widgets/see_all_widget.dart';
import '../dashboard/dashboard_screen.dart';
import '../dashboard/watchlist_widget.dart';
import 'portfoliolist_widget.dart';

// consist of two part
// 1. the top 5 winning portfolios in latest season (last month), offered by Alpha Vantage api.
// the historical portfolio rankings from the Alpha Tournament, world's leading portfolio competition and investors community
// this part will be displayed as a ScrollView in vertical direction.

// 2. the list of followed stocks (different from the watchlist in dashboard screen which inclued all financial instruments)
// tap the list item , user will be navigated to stock detail screen . (different from the watchlist in dashboard screen which will invoke setScreen('stock detail') function)

class StockView extends StatefulWidget {
  StockView({Key? key}) : super(key: key);
  @override
  State<StockView> createState() => _StockViewState();
}

// invoke fetchData() to obtain portfolios ;
// use loadPortfolios to determine whether show the list or the CircularProgressIndicator

class _StockViewState extends State<StockView> {
  @override
  void initState() {
    savedTickers = getMatchesSymbolTicker(appUser.savedTickerSymbols);

    fetchData();
    super.initState();
  }

  void fetchData() async {
    if (!loadedPortolios) {
      assert(portfolios.isEmpty);
      final portfoliosResponse = await winningPortfoliosApi();
      portfolios = convertPortfolios(portfoliosResponse);
      loadedPortolios = true;
      if (mounted) {
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Top winning portfolios',
            style: TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          SeeAllWidget(function: () {}),
        ],
      ),
      loadedPortolios
          ? SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (Portfolio portfolio in portfolios)
                    PortfolioWidget(portfolio: portfolio)
                ],
              ),
            )
          : const Center(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: CircularProgressIndicator(),
              ),
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
                    for (final ticker in savedTickers)
                      // if (!ticker.notGetQuote)
                      InkWell(
                        // onTap: () {
                        //   widget.setScreen('stock detail');
                        //   widget.setTicker(ticker.symbol);
                        // },
                        child: WatchlistWidget(
                          ticker: ticker,
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
}
