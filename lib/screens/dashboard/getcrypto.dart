import 'dart:convert';
import 'package:http/http.dart' as http;

const APIKEY_VANTAGE = 'M8EGV7V9H8YDSROH';
const APIKEY_TICKERINFO = '619e608d52ef38.00454342';
const APIKEY_NEWS = 'TrEM5GsiNc6rohKg5ooPWnjKC5wMUmv5';

//08.24
const cryptoTimeSeriesFunctionNames = {
  'intraDay': 'CRYPTO_INTRADAY',
  'daily': 'DIGITAL_CURRENCY_DAILY',
  'weekly': 'DIGITAL_CURRENCY_WEEKLY',
  'monthly': 'DIGITAL_CURRENCY_MONTHLY',
};

// function, symbol, market, interval
Future<dynamic> cryptoTimeSeriesApi(Map inputData) async {
  var url = Uri.parse(
      'https://www.alphavantage.co/query?function=${inputData['function']}&symbol=${inputData['symbol']}&market=${inputData['markret']}&interval=${inputData['interval']}&apikey=$APIKEY_VANTAGE');
  final response = await http.get(url);
  final res = json.decode(response.body);
  res['type'] = inputData['type'];
  return res;
}

class object {
  void getCrypto() async {
    Map inputData = {
      "function": "DIGITAL_CURRENCY_DAILY",
      "symbol": "BTC",
      "market": "CNY",
      "type": "daily",
    };
    var url = Uri.parse(
        'https://www.alphavantage.co/query?function=${inputData['function']}&symbol=${inputData['symbol']}&market=${inputData['market']}&apikey=$APIKEY_VANTAGE');
    final response = await http.get(url);

    final res = json.decode(response.body);
    res['type'] = inputData['type'];
    print(response);

    print(res);
  }
}

void main() {
  print("hello");
  object obj = object();
  obj.getCrypto();
}
