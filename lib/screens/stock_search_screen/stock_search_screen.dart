import 'package:algolia/algolia.dart';
import 'package:flutter/material.dart';
import 'package:nofire/models/cryptocurrency.dart';
import '../portfolio_screen/crypto_detail.dart';
import '/api_manager.dart';
import '/models/stock.dart';

// alphago vantage offer the search endpoint for searching specific symbols
// it work well in searching stocks but not in searching cryptocurrency
// Use Algolia , upload the cryptons.json file to index("cryptos")

// create the search hit class

class SearchHit {
  final String name;
  final String symbol;

  SearchHit(this.name, this.symbol);

  static SearchHit fromJson(Map<String, dynamic> json) {
    return SearchHit(json['name'], json['symbol']);
  }
}

class StockSearchScreen extends StatefulWidget {
  const StockSearchScreen({
    Key? key,
    required this.setTicker,
    required this.setScreen,
  }) : super(key: key);
  final Function setScreen;
  final Function setTicker;
  @override
  _StockSearchScreenState createState() => _StockSearchScreenState();
}

class _StockSearchScreenState extends State<StockSearchScreen> {
  late List<Ticker> filteredTicker;
  late List<Cryptocurrency> filteredCrypto;
  late TextEditingController searchController;

  // init Algolia object
  final Algolia _algoliaClient = const Algolia.init(
      applicationId: "Q6DNYROL44", apiKey: "f556cfcc4c5c05b548cdf1379132fd5b");
  // List<SearchHit> _hitsList = [];

  // invoke Algolia API and update the _hitsList
  Future<void> _getSearchResult(String query) async {
    AlgoliaQuery algoliaQuery =
        _algoliaClient.instance.index("cryptos").query(query);
    AlgoliaQuerySnapshot snapshot = await algoliaQuery.getObjects();
    final rawHits = snapshot.toMap()['hits'] as List;
    final hits =
        List<SearchHit>.from(rawHits.map((hit) => SearchHit.fromJson(hit)));
    setState(() {
      // _hitsList = hits;
      List<String> symbols = [];
      for (SearchHit hit in hits) {
        symbols.add(hit.symbol);
      }
      filteredCrypto = getMatchesSymbolCrypto(symbols);
    });
  }

  void setFilteredTicker(String text) async {
    if (text.isEmpty) {
      filteredTicker = [...tickers];
      _getSearchResult(''); // init empty search

    } else {
      // use search endpoint provided by AlphaVantage
      // return a list of matching symbol
      final result = await searchTickerApi(text);
      // a list of symbol (symbol exsit in stock.dart ,that is mocked data)
      final symbols = getMatchesSymbol(result);
      filteredTicker = getMatchesSymbolTicker(symbols);
      // filteredCrypto = getMatchesSymbolCrypto([text]);  // if not use algolia , this method could only matches with certain symbols .
    }

    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    filteredTicker = tickers;
    filteredCrypto = cryptocurrencies;
    searchController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // header
          Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Welcome!',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      widget.setScreen('dashboard');
                    },
                    icon: const Icon(
                      Icons.clear_outlined,
                      color: Colors.black,
                      size: 30,
                    ),
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.only(left: 3.0),
                child: Text(
                  'Choose your interests to follow and trade on your terms.',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey,
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              TextField(
                  decoration: const InputDecoration(
                    prefixIcon: Icon(
                      Icons.search_rounded,
                    ),
                    border: OutlineInputBorder(),
                    hintText: 'Search interests to folow',
                  ),
                  controller: searchController,
                  onSubmitted: (value) {
                    setFilteredTicker(value);
                    _getSearchResult(value); // get filtered cryptos
                  }),
            ],
          ),
          const SizedBox(
            height: 20,
          ),
          Expanded(
            child: GridView(
              padding: EdgeInsets.zero,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, childAspectRatio: 1.0),
              children: <Widget>[
                for (Ticker ticker in filteredTicker)
                  InkWell(
                    onTap: () {
                      widget.setScreen('stock detail');
                      widget.setTicker(ticker.symbol);
                    },
                    child: TickerWidget(
                      ticker: ticker,
                    ),
                  ),
                for (Cryptocurrency crypto in filteredCrypto)
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
                    child: TickerWidget(
                      ticker: crypto,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class TickerWidget extends StatefulWidget {
  const TickerWidget({
    Key? key,
    required this.ticker,
  }) : super(key: key);
  final dynamic ticker; // ticker or crypto
  @override
  _TickerWidgetState createState() => _TickerWidgetState();
}

class _TickerWidgetState extends State<TickerWidget> {
  Widget get _getFollowButton {
    if (widget.ticker.followed == false) {
      return Container(
        alignment: Alignment.center,
        width: 150,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(
            40,
          ),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Text(
          widget.ticker.followed == false ? 'Follow' : 'Followed',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.blueGrey,
          ),
        ),
      );
    } else {
      return Container(
        alignment: Alignment.center,
        width: 150,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.blueGrey,
          borderRadius: BorderRadius.circular(
            40,
          ),
        ),
        child: const Text(
          'Followed',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 30.0,
            backgroundImage: AssetImage(
                "${widget.ticker.logoPath}${widget.ticker.symbol}.png"),
            // backgroundImage: NetworkImage('${widget.ticker.logoUrl}'),
            backgroundColor: Colors.transparent,
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              widget.ticker.name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          InkWell(
            onTap: () async {
              final status = await widget.ticker.toggleFollow();
              // if (status == 'full') {
              //   showWarningMsg(
              //     context,
              //     'Because of the API limit\nYou can only choose 5 stock to follow',
              //   );
              // }
              if (mounted) {
                setState(() {});
              }
            },
            child: _getFollowButton,
          ),
        ],
      ),
    );
  }
}
