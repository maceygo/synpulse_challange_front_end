import 'dart:convert';

import 'package:http/http.dart' as http;

const APIKEY_VANTAGE = 'M8EGV7V9H8YDSROH';
const APIKEY_TICKERINFO = '619e608d52ef38.00454342';
const APIKEY_NEWS = 'TrEM5GsiNc6rohKg5ooPWnjKC5wMUmv5';
const stockTimeSeriesFunctionNames = {
  'intraDay': 'TIME_SERIES_INTRADAY',
  'daily': 'TIME_SERIES_DAILY_ADJUSTED',
  'monthly': 'TIME_SERIES_MONTHLY_ADJUSTED',
  'weekly': 'TIME_SERIES_WEEKLY_ADJUSTED',
  'all': 'TIME_SERIES_DAILY_ADJUSTED',
};

// 08.26

const String MARKET_NAME = 'USD';

const cryptocurrencyTimeSeriesFunctionName = {
  'intraDay': 'CRYPTO_INTRADAY',
  'daily': 'DIGITAL_CURRENCY_DAILY',
  'weekly': 'DIGITAL_CURRENCY_WEEKLY',
  'monthly': 'DIGITAL_CURRENCY_MONTHLY',
};

const cryptoInterval = {
  'daily': 'Digital Currency Daily',
  'weekly': 'Digital Currency Weekly',
  'monthly': 'Digital Currency Monthly'
};

Future<dynamic> cryptoQuoteApi(String symbol) async {
  final url = Uri.parse(
      'https://www.alphavantage.co/query?function=CRYPTO_INTRADAY&symbol=$symbol&market=$MARKET_NAME&interval=5min&apikey=$APIKEY_VANTAGE');
  final response = await http.get(url);
  return json.decode(response.body);
}

Future<dynamic> cryptoTimeSeriesApi(Map inputData) async {
  var url = Uri.parse(
      'https://www.alphavantage.co/query?function=${inputData['function']}&symbol=${inputData['symbol']}&market=$MARKET_NAME&apikey=$APIKEY_VANTAGE');
  final response = await http.get(url);
  final res = json.decode(response.body);
  res['type'] = inputData['type'];
  return res;
}

// 获取指定加密货币对的前一天的开盘、高、低和收盘（OHLC）
Future<dynamic> cryptoPrevApi(String symbol) async {
  String pair = symbol.toUpperCase() + MARKET_NAME.toUpperCase();
  final url = Uri.parse(
      'https://api.polygon.io/v2/aggs/ticker/X:$pair/prev?adjusted=true&apiKey=d9XCBGqOtwVly9Vdnd8flxVP7OfO95xW');
  final response = await http.get(url);
  return json.decode(response.body);

// {
//  "ticker": "X:BTCUSD",
//  "queryCount": 1,
//  "resultsCount": 1,
//  "adjusted": true,
//  "results": [
//   {
//    "T": "X:BTCUSD",
//    "v": 22171.58143214728,
//    "vw": 21612.4661,
//    "o": 21367.13,
//    "c": 21561.86,
//    "h": 21818.32,
//    "l": 21307.32,
//    "t": 1661471999999,
//    "n": 727957
//   }
//  ],
//  "status": "OK",
//  "request_id": "4e18409b8a98e576b6c348f05bd850ac",
//  "count": 1
// }
}

Future<dynamic> stockTimeSeriesApi(Map inputData) async {
  var url;

  if (inputData['type'] == 'intraday') {
    url = Uri.parse(
        'https://www.alphavantage.co/query?function=${inputData['function']}&symbol=${inputData['symbol']}&interval=${inputData['interval']}&apikey=$APIKEY_VANTAGE');
  } else if (inputData['type'] == 'all') {
    url = Uri.parse(
        'https://www.alphavantage.co/query?function=${inputData['function']}&symbol=${inputData['symbol']}&outputsize=${inputData['outputSize']}&apikey=$APIKEY_VANTAGE');
  } else {
    url = Uri.parse(
        'https://www.alphavantage.co/query?function=${inputData['function']}&symbol=${inputData['symbol']}&apikey=$APIKEY_VANTAGE');
  }
  final response = await http.get(url);
  final res = json.decode(response.body);
  res['type'] = inputData['type'];
  return res;
}

Future<dynamic> tickerDetailApi(String symbol) async {
  final url = Uri.parse(
      'https://api.polygon.io/v1/meta/symbols/$symbol/company?apiKey=$APIKEY_NEWS');
  final response = await http.get(url);
  return json.decode(response.body);
}

Future<dynamic> tickerQuoteApi(String symbol) async {
  final url = Uri.parse(
      'https://www.alphavantage.co/query?function=GLOBAL_QUOTE&symbol=$symbol&apikey=$APIKEY_VANTAGE');
  final response = await http.get(url);
  return json.decode(response.body);
}

Future<dynamic> tickerListApi() async {
  var url = Uri.parse(
      'https://eodhistoricaldata.com/api/exchanges-list/?api_token=$APIKEY_TICKERINFO&fmt=json');
  final response = await http.get(url);
  return json.decode(response.body);
}

// 获取股票列表
// https://eodhistoricaldata.com/api/exchanges-list/?api_token=619e608d52ef38.00454342&fmt=json

// https://api.polygon.io/v2/reference/news?ticker=APPL&apiKey=TrEM5GsiNc6rohKg5ooPWnjKC5wMUmv5
Future<dynamic> tickerNewsApi(String symbol) async {
  var url = Uri.parse(
      'https://api.polygon.io/v2/reference/news?ticker=$symbol&apiKey=$APIKEY_NEWS');
  final response = await http.get(url);
  return json.decode(response.body);
}

Future<dynamic> searchTickerApi(String keyword) async {
  var url = Uri.parse(
      'https://www.alphavantage.co/query?function=SYMBOL_SEARCH&keywords=$keyword&apikey=$APIKEY_VANTAGE');
  final response = await http.get(url);
  return json.decode(response.body);
}

Future<dynamic> cryptoNewsApi(String symbol) async {
  symbol = symbol.toUpperCase();
  var url = Uri.parse(
      'https://www.alphavantage.co/query?function=NEWS_SENTIMENT&tickers=CRYPTO:$symbol&apikey=$APIKEY_VANTAGE');
  final response = await http.get(url);
  return json.decode(response.body);
}

Future<dynamic> winningPortfoliosApi() async {
  String season = "2022-07"; // it should be the last month
  var url = Uri.parse(
      "https://www.alphavantage.co/query?function=TOURNAMENT_PORTFOLIO&season=$season&apikey==$APIKEY_VANTAGE");
  final response = await http.get(url);
  return json.decode(response.body);
}


// 获取与加密货币有关的新闻

// https://www.alphavantage.co/query?function=NEWS_SENTIMENT&tickers=CRYPTO:BTC&apikey=M8EGV7V9H8YDSROH

// {
//     "items": "200",
//     "sentiment_score_definition": "x <= -0.35: Bearish; -0.35 < x <= -0.15: Somewhat-Bearish; -0.15 < x < 0.15: Neutral; 0.15 <= x < 0.35: Somewhat_Bullish; x >= 0.35: Bullish",
//     "relevance_score_definition": "0 < x <= 1, with a higher score indicating higher relevance.",
//     "feed": [
//         {
//             "title": "The Sheriff of Cryptoville Draws His Pistol",
//             "url": "https://decrypt.co/108303/sheriff-gary-gensler-mark-cuban-coinbase-react",
//             "time_published": "20220827T151534",
//             "authors": [
//                 "Decrypt / Daniel Roberts"
//             ],
//             "summary": "The SEC chief has gone from rhetoric to enforcement, targeting token projects from the present and past. Crypto companies are shook.",
//             "banner_image": "https://cdn.decrypt.co/resize/1536/wp-content/uploads/2022/06/Screenshot-2022-07-04-at-12.54.25.png.webp",
//             "source": "Decrypt.co",
//             "category_within_source": "n/a",
//             "source_domain": "decrypt.co",
//             "topics": [
//                 {
//                     "topic": "Finance",
//                     "relevance_score": "1.0"
//                 },
//                 {
//                     "topic": "Financial Markets",
//                     "relevance_score": "0.875462"
//                 },
//                 {
//                     "topic": "Blockchain",
//                     "relevance_score": "0.576289"
//                 }
//             ],
//             "overall_sentiment_score": 0.016888,
//             "overall_sentiment_label": "Neutral",
//             "ticker_sentiment": [
//                 {
//                     "ticker": "COIN",
//                     "relevance_score": "0.170878",
//                     "ticker_sentiment_score": "-0.016101",
//                     "ticker_sentiment_label": "Neutral"
//                 },
//                 {
//                     "ticker": "OPNDF",
//                     "relevance_score": "0.057352",
//                     "ticker_sentiment_score": "0.020001",
//                     "ticker_sentiment_label": "Neutral"
//                 },
//                 {
//                     "ticker": "CRYPTO:BTC",
//                     "relevance_score": "0.226477",
//                     "ticker_sentiment_score": "0.021487",
//                     "ticker_sentiment_label": "Neutral"
//                 },
//                 {
//                     "ticker": "CRYPTO:DRGN",
//                     "relevance_score": "0.057352",
//                     "ticker_sentiment_score": "0.030114",
//                     "ticker_sentiment_label": "Neutral"
//                 },
//                 {
//                     "ticker": "CRYPTO:ETH",
//                     "relevance_score": "0.057352",
//                     "ticker_sentiment_score": "0.030114",
//                     "ticker_sentiment_label": "Neutral"
//                 }
//             ]
//         },

//     ]
// }