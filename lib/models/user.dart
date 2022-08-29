import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'cryptocurrency.dart';
import 'stock.dart';

late AppUser appUser;

String testId =
    'AJOnW4QP2jbCvZmY5eOJYUjutiYMSixKCT7OOWzW-Nc9ikENQRyZxkbZtUTS1OBrpNqKI2N2roGMR9bvLLu28DDxE7-ViH0or0KolPv-K50_ssRoN8azooUBnSZozB_nL5_xPohUp5rTGgJIXYBR3YOhFTP2hvrp9UlZ9AmopvP6-wbUSG3EGMd3UvCdWI1ojODmcbLhUNjGPQeE0gNWFPCCYAvqNH0log';

class AppUser {
  String id;
  List<String> savedTickerSymbols;
  List<String> savedCryptoSymbols;
  late SharedPreferences sharedPreferences;

  // 实例化的时候需要传入的属性
  AppUser({
    required this.id,
    this.savedTickerSymbols = const [],
    this.savedCryptoSymbols = const [],
  });

  // 每次toggleFollow()更改watchlist的时候调用setData 保存更新后的watchlist
  Future<void> setData(String type) async {
    sharedPreferences = await SharedPreferences.getInstance(); // 实例化
    // 设置string list类型的数组

    if (type == 'ticker') {
      await sharedPreferences.setStringList(
          "${id}_tickers", savedTickerSymbols);
    } else if (type == 'crypto') {
      await sharedPreferences.setStringList(
          "${id}_cryptos", savedCryptoSymbols);
    } else {
      assert(type == 'all'); // 只在注册成功时执行
      await sharedPreferences.setStringList(
          "${id}_tickers", savedTickerSymbols);
      await sharedPreferences.setStringList(
          "${id}_cryptos", savedCryptoSymbols);
    }

    if (kDebugMode) {
      print("update portfolio information for user $id");
      print(savedTickerSymbols);
      print(savedCryptoSymbols);
    }
  }

  // 每次登录的时候查Data 导入用户id对应的watchlist
  Future<void> getData() async {
    // SharedPreferences Instance
    sharedPreferences = await SharedPreferences.getInstance();
    savedTickerSymbols = sharedPreferences.getStringList("${id}_tickers")!;
    savedCryptoSymbols = sharedPreferences.getStringList("${id}_cryptos")!;

    List<Ticker> savedTickers = getMatchesSymbolTicker(savedTickerSymbols);

    List<Cryptocurrency> savedCryptos =
        getMatchesSymbolCrypto(savedCryptoSymbols);

    for (Ticker ticker in tickers) {
      if (savedTickers.contains(ticker)) {
        ticker.followed = true;
      }
    }
    for (Cryptocurrency crypto in cryptocurrencies) {
      if (savedCryptos.contains(crypto)) {
        crypto.followed = true;
        String action = "add";
        UpdateAllCryptos(crypto, action);
      }
    }
    if (kDebugMode) {
      // A constant that is true if the application was compiled in debug mode.
      print("recover portfolio information for user $id");
      print(savedTickerSymbols);
      print(savedCryptoSymbols);
    }
  }
}
