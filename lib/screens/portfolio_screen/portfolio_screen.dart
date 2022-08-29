import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nofire/models/cryptocurrency.dart';
import '../../api_manager.dart';
import '../../models/stock.dart';
import '../../models/user.dart';
import '../dashboard/dashboard_screen.dart';
import 'crypto_view.dart';
import 'stock_view.dart';

class PortfolioScreen extends StatefulWidget {
  const PortfolioScreen({Key? key}) : super(key: key);
  @override
  State<PortfolioScreen> createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends State<PortfolioScreen>
    with SingleTickerProviderStateMixin {
  void fetchData() async {
    savedTickers = getMatchesSymbolTicker(appUser.savedTickerSymbols);
    savedCryptos = getMatchesSymbolCrypto(appUser.savedCryptoSymbols);
    if (!loadedQuote) {
      for (int i = 0; i < savedCryptos.length; i++) {
        if (savedCryptos[i].notGetQuote) {
          try {
            final quoteData = await cryptoQuoteApi(savedCryptos[i].symbol);
            final prevData = await cryptoPrevApi(savedCryptos[i].symbol);
            double lastClose = getCryptoPrev(prevData);
            savedCryptos[i].quote =
                getcryptoQuote(quoteData, "5min", lastClose);
          } catch (e) {
            if (kDebugMode) {
              print("savedCrypto get quote failed");
            }
          }
        }
      }
      loadedQuote = true;
      for (Cryptocurrency crypto in savedCryptos) {
        if (crypto.notGetQuote) {
          loadedQuote = true;
          break;
        }
      }
      if (mounted) {
        setState(() {});
      }
    }
  }

  @override
  void initState() {
    print("loadedQuote: $loadedQuote");
    fetchData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.grey,
      ),
      home: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            elevation: 1.0, // shadow below appBar
            backgroundColor: Colors.white70,
            bottom: const TabBar(
              labelColor: Colors.black,
              unselectedLabelColor: Colors.white,
              tabs: [
                Tab(
                    child: Text('Stocks',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold))),
                Tab(
                    child: Text('Cryptocurrencies',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold))),
              ],
            ),
            title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(
                        Icons.arrow_back_ios_outlined,
                        size: 28,
                      )),
                  const Text('Portfolio',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ))
                ]),
          ),
          body: TabBarView(
            children: [
              StockView(),
              const CryptoView(),
            ],
          ),
        ),
      ),
    );
  }
}
