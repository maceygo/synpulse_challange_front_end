import '../api_manager.dart';
import 'news.dart';
import 'stock.dart';
import 'user.dart';

List<Cryptocurrency> cryptocurrencies = [
  Cryptocurrency(
    name: 'Bitcoin',
    symbol: 'btc',
  ),
  Cryptocurrency(
    name: 'WAVES',
    symbol: 'waves',
  ),
  Cryptocurrency(
    name: 'Ethereum',
    symbol: 'eth',
  ),
  Cryptocurrency(
    name: ' Cosmos',
    symbol: 'atom',
  ),
  Cryptocurrency(
    name: ' Binance-Coin',
    symbol: 'bnb',
  ),
  Cryptocurrency(
    name: ' DigiByte',
    symbol: 'dgb',
  ),
  Cryptocurrency(
    name: ' Enjin-Coin',
    symbol: 'enj',
  ),
  Cryptocurrency(
    name: ' EOS',
    symbol: 'eos',
  ),
  Cryptocurrency(
    name: ' Gnosis-Token',
    symbol: 'gno',
  ),
  Cryptocurrency(
    name: ' IOStoken',
    symbol: 'iost',
  ),
  Cryptocurrency(
    name: ' IoTeX',
    symbol: 'iotx',
  ),
  Cryptocurrency(
    name: ' Lisk',
    symbol: 'lsk',
  ),
  Cryptocurrency(
    name: ' Litecoin',
    symbol: 'ltc',
  ),
  Cryptocurrency(
    name: ' Ontology',
    symbol: 'ont',
  ),
  Cryptocurrency(
    name: ' Qtum',
    symbol: 'qtum',
  ),
  Cryptocurrency(
    name: ' Storj',
    symbol: 'storj',
  ),
  Cryptocurrency(
    name: ' Theta-Token',
    symbol: 'theta',
  ),
  Cryptocurrency(
    name: ' Tronix',
    symbol: 'trx',
  ),
  Cryptocurrency(
    name: ' NEM',
    symbol: 'xem',
  ),
  Cryptocurrency(
    name: ' Verge',
    symbol: 'xvg',
  ),
  Cryptocurrency(
    name: ' ZCoin',
    symbol: 'xzc',
  ),
];

Cryptocurrency totalwatch = Cryptocurrency(
  name: "all crypto in watchlist",
  symbol: "all",
  followed: false,
  logoPath: '',
);

List<Map<String, dynamic>> buildAllCryptos(
    Cryptocurrency crypto, String action, String type) {
  List<Map<String, dynamic>> total = totalwatch.prices[type]!; // 原本的
  List<Map<String, dynamic>> t = []; // 临时的
  List<Map<String, dynamic>>? update = crypto.prices[type]; // 有follow操作的
  for (int i = 0; i < update!.length; i++) {
    String date = "";
    for (String d in update[i].keys) {
      // 从新到旧遍历日期
      // actually only one element in keys.
      // {2022-08-26: 21516.7}
      //(2022-08-26)
      date = d;
    }
    t.add({date: 0.0}); // 暂存第i天的值
    double before = 0.0;
    if (total.isNotEmpty) {
      for (double n in total[i].values) {
        // actually only one element in keys.
        before = n; // 未更新前的值
      }
    }
    double modify = 0;
    for (double n in update[i].values) {
      // actually only one element in keys.
      modify = n; // 要更新的值
    }

    if (action == 'add') {
      t[i][date] = before + modify;
    } else {
      assert(action == 'delete');
      t[i][date] = before - modify;
    }
  }
  return t;
}

void UpdateAllCryptos(Cryptocurrency crypto, String action) async {
  for (String type in ['weekly', 'daily']) {
    if (type == 'weekly'
        ? crypto.notGetPricesWeekly
        : crypto.notGetPricesDaily) {
      // get TimeSeries in certain interval , api provide with 'Intraday, Daily, Weekly, Monthly'
      final response = await cryptoTimeSeriesApi(
        {
          'function': cryptocurrencyTimeSeriesFunctionName[type],
          "symbol": crypto.symbol,
          'type': type,
        },
      );
      String? interval = cryptoInterval[type];
      final temp = Cryptocurrency.fromJson(response, interval!).prices;
      for (final key in crypto.prices.keys) {
        temp.putIfAbsent(key, () => crypto.prices[key]!);
      }
      crypto.prices = temp;
    }
  }

  // daily 和 type
  List<Map<String, dynamic>> daily = buildAllCryptos(crypto, action, "daily");
  List<Map<String, dynamic>> weekly = buildAllCryptos(crypto, action, "weekly");

  // totalwatch.prices['weekly'] = total; // Cannot modify unmodifiable map
  totalwatch.prices = {'daily': daily, 'weekly': weekly};
  return;
}

List<Cryptocurrency> getMatchesSymbolCrypto(List<String> symbols) {
  List<Cryptocurrency> result = [];
  cryptocurrencies.forEach((element) {
    // traverse all tickers
    if (symbols.contains(element.symbol.toLowerCase())) {
      // contains specified element
      result.add(element);
    }
  });
  return [...result];
}

double getCryptoPrev(Map data) {
  // last day open value of crypto
  double lastClose = double.parse(data["results"][0]["c"].toString());
  return lastClose;
}

// obtain Intraday quote (real time)
Map<String, num> getcryptoQuote(Map data, String interval, double lastClose) {
  try {
    String time = data['Meta Data']['6. Last Refreshed'];

    double price = double.parse(
        data['Time Series Crypto ($interval)'][time]["1. open"].toString());
    double change = double.parse(
        (price - lastClose).toStringAsFixed(4)); // 实时价格减去前一天的收盘价格 保留4位小数
    double changePercent =
        double.parse((change / lastClose).toStringAsFixed(4)); // 变化百分比

    // to check the change value is accurate .
    // print("现在$price, 前一天收盘价$lastClose, 改变了$change, 占前一天收盘价的$changePercent");

    return {
      // latest open和volume
      'price': double.parse(
          data['Time Series Crypto ($interval)'][time]["1. open"].toString()),
      'volume': data['Time Series Crypto ($interval)'][time]["5. volume"],
      'change': change,
      'change percent': changePercent,
    };
  } catch (e) {
    print(e);
    return {};
  }
}

List<Cryptocurrency> get getFollowedCryptos {
  return cryptocurrencies.where((element) => element.followed).toList();
}

class Cryptocurrency {
  final String name;
  final String symbol;
  bool followed;
  String logoPath;
  Map<String, List<Map<String, dynamic>>>
      prices; // prices['daily'] = List<Map<String, dynamic>>
  Map<String, num> quote;
  List<News> newsList;

  bool get notGetQuote {
    return quote['change'] == 0 &&
        quote['change percent'] == 0 &&
        quote['open'] == 0 &&
        quote['volume'] == 0;
  }

  bool get notGetPricesWeekly {
    return prices['weekly']!.isEmpty;
  }

  bool get notGetPricesDaily {
    return prices['daily']!.isEmpty;
  }

  Cryptocurrency({
    this.name = '',
    this.symbol = '',
    this.logoPath = 'assets/coin/',
    this.quote = const {
      'open': 0.0,
      'volume': 0.0,
      'change': 0.0,
      'change percent': 0.0,
    },
    this.prices = const {
      'daily': [],
      'weekly': [],
    },
    this.newsList = const [],
    this.followed = false,
  });

  Future<String> toggleFollow() async {
    followed = !followed;

    if (getFollowedCryptos.length > 5) {
      followed = !followed;
      return 'full';
    }
    // map tickers into symbols , turn ticker to symbols  (String), so that storage the string list in shared preference
    appUser.savedCryptoSymbols =
        getFollowedCryptos.map((e) => e.symbol).toList();
    //togglefollow 更新watchlist
    loadedQuote = false;
    await appUser.setData('crypto');

    if (followed == true) {
      String action = "add";
      UpdateAllCryptos(this, action);
    } else {
      String action = "delete";
      UpdateAllCryptos(this, action);
    }

    return 'success';
  }

  static Cryptocurrency fromJson(Map data, String interval) {
    final name = data['Meta Data']['3. Digital Currency Name'];
    final symbol =
        data['Meta Data']['2. Digital Currency Code'].toString().toLowerCase();
    final List<Map<String, dynamic>> prices =
        []; // 多种类型 daily, weekly, monthly, all

    // key取遍所有的时间节点 如"2022-08-25 12:00:00"
    // prices取遍所有时间节点对应的开盘价 如  "1. open": "1710.11000" 里的"1710.11000"
    // prices[type]
    // [
    //   {
    //     key :"2022-08-25 12:00:00",
    //     value: "1710.11000",
    //   }
    // ]

    // interval = "Digital Currency Daily"
    data['Time Series ($interval)'].forEach((time, detail) {
      prices.add({time: double.parse(detail['1b. open (USD)'])});
    });
    // price is like {'2022-08-25 12:00:00': "1710.11000", }
    // prices is like [price, price, price  ...]

    // print({data['type']: prices});

    // {daily: [{2022-08-26: 21559.04}, {2022-08-25: 21368.05}, {2022-08-24: 21529.11}, {2022-08-23: 21400.75}, {2022-08-22: 21516.7}, {2022-08-21: 21140.07}, {2022-08-20: 20834.39}

    return Cryptocurrency(
        name: name, symbol: symbol, prices: {data['type']: prices});
  }
}

// 返回json格式示例

// CRYPTO_INTRADAY 日内、实时

// https://www.alphavantage.co/query?function=CRYPTO_INTRADAY&symbol=BTC&market=USD&interval=5min&apikey=M8EGV7V9H8YDSROH

// {
//     "Meta Data": {
//         "1. Information": "Crypto Intraday (5min) Time Series",
//         "2. Digital Currency Code": "BTC",
//         "3. Digital Currency Name": "Bitcoin",
//         "4. Market Code": "USD",
//         "5. Market Name": "United States Dollar",
//         "6. Last Refreshed": "2022-08-25 13:50:00",
//         "7. Interval": "5min",
//         "8. Output Size": "Compact",
//         "9. Time Zone": "UTC"
//     },
//     "Time Series Crypto (5min)": {
//         "2022-08-25 13:50:00": {
//             "1. open": "21635.51000",
//             "2. high": "21643.70000",
//             "3. low": "21609.10000",
//             "4. close": "21640.56000",
//             "5. volume": 443
//         },
//     },
// }

// function=DIGITAL_CURRENCY_DAILY

// https://www.alphavantage.co/query?function=DIGITAL_CURRENCY_DAILY&symbol=BTC&market=USD&apikey=M8EGV7V9H8YDSROH

// {
//     "Meta Data": {
//         "1. Information": "Daily Prices and Volumes for Digital Currency",
//         "2. Digital Currency Code": "BTC",
//         "3. Digital Currency Name": "Bitcoin",
//         "4. Market Code": "USD",
//         "5. Market Name": "United States Dollar",
//         "6. Last Refreshed": "2022-08-25 00:00:00",
//         "7. Time Zone": "UTC"
//     },
//     "Time Series (Digital Currency Daily)": {
//         "2022-08-25": {
//             "1a. open (USD)": "21368.05000000",
//             "1b. open (USD)": "21368.05000000",
//             "2a. high (USD)": "21444.97000000",
//             "2b. high (USD)": "21444.97000000",
//             "3a. low (USD)": "21310.15000000",
//             "3b. low (USD)": "21310.15000000",
//             "4a. close (USD)": "21430.50000000",
//             "4b. close (USD)": "21430.50000000",
//             "5. volume": "4856.60138000",
//             "6. market cap (USD)": "4856.60138000"
//         },
//         "2022-08-24": {
//             "1a. open (USD)": "21529.11000000",
//             "1b. open (USD)": "21529.11000000",
//             "2a. high (USD)": "21900.00000000",
//             "2b. high (USD)": "21900.00000000",
//             "3a. low (USD)": "21145.00000000",
//             "3b. low (USD)": "21145.00000000",
//             "4a. close (USD)": "21368.08000000",
//             "4b. close (USD)": "21368.08000000",
//             "5. volume": "174383.22046000",
//             "6. market cap (USD)": "174383.22046000"
//         },
//     }
// }
