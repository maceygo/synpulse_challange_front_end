import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nofire/screens/portfolio_screen/portfolio_screen.dart';
import '../../models/cryptocurrency.dart';
import '../portfolio_screen/crypto_detail.dart';
import '/models/stock.dart';
import '/models/user.dart';
import '../../api_manager.dart';
import '../../widgets/see_all_widget.dart';
import 'gainer_widget.dart';
import 'watchlist_widget.dart';

List<Ticker> savedTickers = getMatchesSymbolTicker(appUser.savedTickerSymbols);
List<Cryptocurrency> savedCryptos =
    getMatchesSymbolCrypto(appUser.savedCryptoSymbols);

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({
    Key? key,
    required this.setScreen,
    required this.setTicker,
  }) : super(key: key);
  final Function setScreen;
  final Function setTicker;
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    savedTickers = getMatchesSymbolTicker(appUser.savedTickerSymbols);
    savedCryptos = getMatchesSymbolCrypto(appUser.savedCryptoSymbols);

    fetchData();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void fetchData() async {
    if (!loadedQuote) {
      // Gainer and Losers截取股票市场里的前两个股票
      List<Ticker> allTickers = getMatchesSymbolTicker(
          tickers.sublist(0, 2).map((e) => e.symbol).toList());

      for (int i = 0; i < allTickers.length; i++) {
        if (allTickers[i].notGetQuote) {
          final quoteData = await tickerQuoteApi(allTickers[i].symbol);
          allTickers[i].quote = getQuote(quoteData);
        }
      }
      // Your watchlist里的内容
      for (int i = 0; i < savedTickers.length; i++) {
        if (savedTickers[i].notGetQuote) {
          // 根据股票代码获取报价数据
          final quoteData = await tickerQuoteApi(savedTickers[i].symbol);
          savedTickers[i].quote = getQuote(quoteData);

          // 根据股票代码获取detail 这个detail是新闻 也就是一并请求了股票的新闻和股票头像 注意这里只做一次 后面会有if判断
          final detailData = await tickerDetailApi(savedTickers[i].symbol);
          savedTickers[i].logoUrl = detailData['logo'];
          savedTickers[i].url = detailData['url'];
        }
      }

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

      loadedQuote = true; // 用于控制list_item的显示

      for (Cryptocurrency crypto in savedCryptos) {
        if (crypto.notGetQuote) {
          loadedQuote = true;
          break;
        }
      }

      // 避免异步消息（Gainer and Losers list请求api获取股票报价信息）未返回的时候已经切换页面 造成内存泄漏 所以加上if(mounted)
      if (mounted) {
        setState(() {}); // statefulWidget 更新要显示的数据 同前端框架中的数据绑定
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
          // header
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Dashboard',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                ),
              ),
              IconButton(
                onPressed: () {
                  widget.setScreen('stock search');
                },
                icon: const Icon(
                  Icons.search_rounded,
                  size: 30,
                ),
              ),
            ],
          ),
          const Divider(),
          // gainers and losers
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Gainer and Losers',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SeeAllWidget(function: () {}),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          loadedQuote
              ? SingleChildScrollView(
                  // 水平滚动条
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      for (final ticker in tickers.sublist(0, 2))
                        if (ticker.quote.isNotEmpty)
                          InkWell(
                            onTap: () {
                              widget.setScreen('stock detail');
                              widget.setTicker(ticker.symbol);
                            },
                            child: GainerWidget(
                              ticker: ticker,
                            ),
                          ),
                    ],
                  ),
                )
              : const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: CircularProgressIndicator(),
                  ),
                ),

          const SizedBox(
            height: 20,
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Your watchlist',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SeeAllWidget(function: () {}),
            ],
          ),
          // watchlist
          loadedQuote
              ? Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        for (final ticker in savedTickers)
                          // if (!ticker.notGetQuote)
                          InkWell(
                            onTap: () {
                              widget.setScreen('stock detail');
                              widget.setTicker(ticker.symbol);
                            },
                            child: WatchlistWidget(
                              ticker: ticker,
                            ),
                          ),
                        for (final crypto in savedCryptos)
                          // if (!crypto.notGetQuote)
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CryptoDetailScreen(
                                    //在跳转到新页面的时候，能同时传递一些数据
                                    crypto: crypto,
                                  ),
                                ),
                              );
                            },
                            child: WatchlistWidget(
                              ticker: crypto,
                            ),
                          )
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
          if (savedTickers.isEmpty && savedCryptos.isEmpty)
            const SizedBox(
                height: 200,
                width: 200,
                child: Center(
                    child: Text(
                        "Your watchlist is Empty , go and add some stocks to your portfolio."))),
        ]),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        elevation: 0,
        child: SizedBox(
          height: 70,
          child: Row(children: [
            Expanded(
                child: Column(
              children: const [
                Icon(
                  Icons.arrow_upward_sharp,
                  color: Colors.blueAccent,
                  size: 36.0,
                ),
                Text("Dashboard",
                    style: TextStyle(
                        color: Colors.blueAccent, fontWeight: FontWeight.w900))
              ],
            )),
            Expanded(
                child: InkWell(
                    onTap: _openPortfolio,
                    child: Column(
                      children: const [
                        Icon(
                          Icons.add_circle_outline_outlined,
                          color: Colors.grey,
                          size: 36.0,
                        ),
                        Text("Portfolio"),
                      ],
                    ))),
          ]),
        ),
      ),
    );
  }

  void _openPortfolio() {
    Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (BuildContext context) => const PortfolioScreen(),
      ),
    );
  }
}
