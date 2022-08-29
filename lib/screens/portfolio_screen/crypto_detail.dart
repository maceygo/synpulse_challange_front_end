import 'package:flutter/material.dart';
import 'package:nofire/models/cryptocurrency.dart';
import 'package:share/share.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../api_manager.dart';
import '../../models/news.dart';
import '../../widgets/message_box.dart';
import '../../widgets/see_all_widget.dart';
import '../stock_detail_screen/news_widget.dart';
import '../stock_detail_screen/stock_detail_screen.dart';

class CryptoDetailScreen extends StatefulWidget {
  const CryptoDetailScreen({Key? key, required this.crypto}) : super(key: key);
  final Cryptocurrency crypto;

  @override
  State<CryptoDetailScreen> createState() => _CryptoDetailScreenState();
}

class _CryptoDetailScreenState extends State<CryptoDetailScreen> {
  late List<Map<dynamic, dynamic>> timeSeriesStatus;
  late bool isLoading;

  @override
  // 初始化状态
  void initState() {
    timeSeriesStatus = [
      {
        'name': '1d',
        'isPressed': false,
        'type': 'daily',
      },
      {
        'name': '5d',
        'isPressed': true,
        'type': 'weekly',
      },
      {
        'name': '30d',
        'isPressed': false,
        'type': 'monthly',
      },
      {
        'name': '90d',
        'isPressed': false,
        'type': 'all',
      },
      {
        'name': '6m',
        'isPressed': false,
        'type': 'all',
      },
      {
        'name': 'All',
        'isPressed': false,
        'type': 'all',
      },
    ];
    isLoading = true;
    fetchData();
    super.initState();
  }

  // 获取timeSeries的类型 哪个按钮被压着
  String get getType {
    return timeSeriesStatus
        // 这函数怎么写的 淦 看不懂map
        // 其实就是map的iterator 迭代器吧
        .firstWhere((element) => element['isPressed'])['type'];
  }

  void fetchData() async {
    await getCryptoTimeSeriesData('weekly');

    if (widget.crypto.newsList.isEmpty) {
      // 如果新闻列表是空的 就加载新闻 通过api获取新闻 避免重复请求导致 只请求一次就返回多条新闻 所以是newsList
      final newsResponse = await cryptoNewsApi(widget.crypto.symbol);
      // 转化为需要的格式
      widget.crypto.newsList = convertCryptoNews(newsResponse);
    }

    isLoading = false;
    if (mounted) {
      setState(() {});
    }
  }

  void setTimeSeries(String type) async {
    try {
      isLoading = true;
      getCryptoTimeSeriesData(type);
      timeSeriesStatus = timeSeriesStatus.map((e) {
        if (e['type'] != type) {
          e['isPressed'] = false;
        } else {
          e['isPressed'] = true;
        }
        return e;
      }).toList();
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      showWarningMsg(context, 'Exceed api calls, please try again later');
    }
  }

  Future getCryptoTimeSeriesData(String type) async {
    // 获取 Intraday quote
    if (widget.crypto.notGetQuote) {
      try {
        final quoteData = await cryptoQuoteApi(widget.crypto.symbol);
        final prevData = await cryptoPrevApi(widget.crypto.symbol);
        double lastClose = getCryptoPrev(prevData);
        widget.crypto.quote = getcryptoQuote(quoteData, "5min", lastClose);
      } catch (e) {
        print(e);
      }
    }
    // 获取 Timeseries
    if (!widget.crypto.prices.containsKey(type) || type == 'weekly') {
      try {
        final response = await cryptoTimeSeriesApi(
          {
            'function': "${cryptocurrencyTimeSeriesFunctionName[type]}",
            "symbol": widget.crypto.symbol,
            'type': type,
          },
        );
        String? interval = cryptoInterval[type];
        final temp = Cryptocurrency.fromJson(response, interval!)
            .prices; // 淦 返回的temp是个新的Currency实例 然后取了这个实例的prices 所以是个prices {'':[],'':[]};
        for (final key in widget.crypto.prices.keys) {
          // 如果有就填充进temp
          temp.putIfAbsent(key, () => widget.crypto.prices[key]!);
        }
        widget.crypto.prices = temp;

        // print(widget.crypto.prices['weekly']);
//{2022-08-26: 21516.7}, {2022-08-21: 24305.25}, {2022-08-14: 23174.39}, {2022-08-07: 23296.36}, {2022-07-31: 22577.13}, {2022-07-24: 20799.58}, {2022-07-17: 20861.11}, {2022-07-10: 19315.83}, {2022-07-03: 21038.08}, {2022-06-26: 20574.0}, {2022-06-19: 26574.53}, {2022-06-12: 29919.2}, {2022-06-05: 29468.1}, {2022-05-29: 30293.93}, {2022-05-22: 31328.89}, {2022-05-15: 34038.39}, {2022-05-08: 38468.35}, {2022-05-01: 39450.12}, {2022-04-24: 39678.11}, {2022-04-17: 42158.85}, {2022-04-10: 46407.36}, {2022-04-03: 46827.76}, {2022-03-27: 41262.11}, {2022-03-20: 37777.35}, {2022-03-13: 38420.8}, {2022-03-06: 37699.08}, {2022-02-27: 38386.89}, {2022-02-20: 42053.65}, {2022-02-13: 42380.87}, {2022-02-06: 37881.75}, {2022-01-30: 36244.55}, {2022-01-23: 43071.66}, {2022-01-16: 41864.62}, {2022-01-09: 47286.18}, {2022-01-02: 50775.48}, {2021-12-26: 46681.24}, {2021-12-19: 50053.9}, {2021-12-12: 49396.32}, {2021-12-05: 57274.89}, {2021-11-28: 58617.7}, {2021-11-21: 65519.11}, {2021-11-14: 63273.58}
        isLoading = false;
        if (mounted) {
          setState(() {});
        }
      } catch (e) {
        showWarningMsg(context, 'The endpoint is unavailable');
      }
    } else {
      isLoading = false;
      if (mounted) {
        setState(() {});
      }
    }
    return;
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            IconButton(
              onPressed: () {
                // Navigator.pop(context);
                // Share.share(widget.crypto.url, subject: '');
              },
              icon: const Icon(
                Icons.ios_share,
                size: 30,
              ),
            ),
          ],
        ),
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
        ),
        child: Column(children: [
          const SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                widget.crypto.symbol,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 8.0,
              vertical: 5,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    // 股票名字
                    widget.crypto.name,
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                ),
                CircleAvatar(
                  // 股票logo
                  radius: 20.0,
                  backgroundImage: AssetImage(
                      "assets/coin/${widget.crypto.symbol.toLowerCase()}.png"),
                  // backgroundImage: NetworkImage(widget.crypto.logoUrl),
                  backgroundColor: Colors.transparent,
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              for (final timeSeries in timeSeriesStatus)
                TimeSeriesButton(
                  // 按钮
                  function: () {
                    setTimeSeries('${timeSeries['type']}');
                  },
                  name: timeSeries['name'],
                  isPressed: timeSeries['isPressed'],
                ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 8.0,
              vertical: 5,
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  Text(
                    // 价格
                    '\$${widget.crypto.quote['price']}',
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      // 根据改变百分比是正还是负的来选择背景颜色是绿色还是红色
                      color: widget.crypto.quote['change percent']! > 0
                          ? Colors.green[100]
                          : Colors.red[100],
                      borderRadius: BorderRadius.circular(
                        5,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        '${widget.crypto.quote['change percent']}%',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: widget.crypto.quote['change percent']! > 0
                              ? Colors.green
                              : Colors.red,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Text(
                    // volume
                    '${widget.crypto.quote['volume']}',
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          isLoading
              ? const SizedBox(
                  height: 250,
                  child: Center(
                    child: SizedBox(
                      height: 40,
                      width: 40,
                      child: CircularProgressIndicator(),
                    ),
                  ),
                )
              : SizedBox(
                  height: 250,
                  child: _buildDefaultLineChart(widget.crypto, getType),
                ),
          InkWell(
            onTap: () async {
              final status = await widget.crypto.toggleFollow();
              if (status == 'full') {
                showSnackbar(
                  'Because of the API limit\nYou can only choose 5 stock to follow',
                );
              }
              if (mounted) {
                setState(() {});
              }
            },
            child: Container(
              alignment: Alignment.center,
              width: screenSize.width * 0.9,
              height: 50,
              decoration: BoxDecoration(
                border: widget.crypto.followed
                    ? null
                    : Border.all(color: Colors.grey[300]!),
                color: widget.crypto.followed ? Colors.blueGrey : Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                widget.crypto.followed ? 'Followed' : 'Follow',
                style: TextStyle(
                  fontSize: 22,
                  color:
                      widget.crypto.followed ? Colors.white : Colors.blueGrey,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'News',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SeeAllWidget(
                function: () {},
              ),
            ],
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  for (final news in widget.crypto.newsList)
                    if (news.imageUrl.isNotEmpty &&
                        news.imageUrl.contains("financialexpress.com/") ==
                            false)
                      TickerNews(
                        news: news,
                      ),
                ],
              ),
            ),
          ),
        ]),
      ),
    );
  }

  void showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }
}

Widget _buildDefaultLineChart(Cryptocurrency currentTicker, String type) {
  if (currentTicker.prices[type] == null) {
    return Container();
  }
  return SfCartesianChart(
    primaryXAxis: CategoryAxis(
      isVisible: false,
    ), // Initialize category axis.
    series: <LineSeries<Map<String, dynamic>, String>>[
      LineSeries<Map<String, dynamic>, String>(
        dataSource: [...currentTicker.prices[type]!],
        xValueMapper: (Map<String, dynamic> price, _) => price.keys.first,
        yValueMapper: (Map<String, dynamic> price, _) => price.values.first,
      ),
    ],
  );
}
