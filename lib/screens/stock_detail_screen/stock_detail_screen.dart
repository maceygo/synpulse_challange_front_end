import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:share/share.dart';
import '/models/news.dart';
import '/models/stock.dart';
import '/screens/stock_detail_screen/news_widget.dart';
import '/widgets/message_box.dart';
import '/widgets/see_all_widget.dart';

import '../../api_manager.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class StockDetailScreen extends StatefulWidget {
  const StockDetailScreen(
      {Key? key, required this.setScreen, required this.ticker})
      : super(key: key);
  final Function setScreen;
  final Ticker ticker;
  @override
  _StockDetailScreenState createState() => _StockDetailScreenState();
}

class _StockDetailScreenState extends State<StockDetailScreen> {
  late List<Map<dynamic, dynamic>> timeSeriesStatus;
  late bool isLoading;
  @override
  void initState() {
    timeSeriesStatus = [
      {
        'name': '1d',
        'isPressed': false,
        'type': 'daily',
      },
      {
        // firstly show
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
    fetchData();
    isLoading = true;
    super.initState();
  }

  // to obtain which button is pressed.
  String get getType {
    return timeSeriesStatus
        .firstWhere((element) => element['isPressed'])['type'];
  }

  @override
  void dispose() {
    super.dispose();
  }

  void fetchData() async {
    await getStockTimeSeriesData(widget.ticker,
        'weekly'); // when init , '5d' is pressed . so obtain the data to render LineChart
    if (widget.ticker.newsList.isEmpty) {
      final newsResponse = await tickerNewsApi(widget.ticker.symbol);
      widget.ticker.newsList = convertNews(newsResponse);
    }

    if (widget.ticker.logoUrl.isEmpty) {
      // logo图片的超链接？ 通过polygon这个api
      final detailData = await tickerDetailApi(widget.ticker.symbol);
      widget.ticker.logoUrl = detailData['logo'];
      widget.ticker.url = detailData['url'];
    }
    isLoading = false;
    if (mounted) {
      setState(() {});
    }
  }

  void setTimeSeries(String type) async {
    // premium in Alpha Vantage
    if (type == 'daily' || type == 'all') {
      return;
    }

    try {
      isLoading = true;
      getStockTimeSeriesData(widget.ticker, type);
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
      if (kDebugMode) {
        print(e);
      }
      showWarningMsg(context, 'Exceed api calls, please try again later');
    }
  }

  // 根据类型
  Future getStockTimeSeriesData(Ticker ticker, String type) async {
    if (!ticker.prices.containsKey(type)) {
      try {
        final response = await stockTimeSeriesApi(
          {
            'function': "${stockTimeSeriesFunctionNames[type]}",
            "symbol": ticker.symbol,
            'outputSize': type == 'all' ? 'full' : 'compact',
            'type': type,
          },
        );
        //  This is a premium endpoint. You may subscribe to any of the premium plans at https://www.alphavantage.co/premium/ to instantly unlock all premium endpoints, type: daily/all}
        final temp = Ticker.fromJson(response).prices;
        for (final key in ticker.prices.keys) {
          temp.putIfAbsent(key, () => ticker.prices[key]!);
        }
        ticker.prices = temp;
        isLoading = false;
        if (mounted) {
          setState(() {});
        }
      } catch (e) {
        if (kDebugMode) {
          print("getStockTimeSeriesData:$e");
        }
        // showWarningMsg(context, 'The endpoint is unavailable');
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
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () {
                  widget.setScreen('dashboard');
                },
                icon: const Icon(
                  Icons.arrow_back_outlined,
                  size: 30,
                ),
              ),
              IconButton(
                // using the share package ,
                onPressed: () {
                  Share.share(widget.ticker.url, subject: '');
                },
                icon: const Icon(
                  Icons.ios_share,
                  size: 30,
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          // Ticker info
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                // 股票代码
                widget.ticker.symbol,
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
                    widget.ticker.name,
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
                  backgroundImage:
                      AssetImage("assets/logo/${widget.ticker.symbol}.png"),
                  // backgroundImage: NetworkImage(widget.ticker.logoUrl),
                  backgroundColor: Colors.transparent,
                ),
              ],
            ),
          ),
          // Ticker quote
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
                    '\$${widget.ticker.quote['price']}',
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      // 根据改变百分比是正还是负的来选择背景颜色是绿色还是红色
                      color: widget.ticker.quote['change percent']! > 0
                          ? Colors.green[100]
                          : Colors.red[100],
                      borderRadius: BorderRadius.circular(
                        5,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        // 改变百分比
                        '${widget.ticker.quote['change percent']}%',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: widget.ticker.quote['change percent']! > 0
                              ? Colors.green
                              : Colors.red,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  () {
                    final String price =
                        widget.ticker.quote['change'].toString();
                    String res;
                    // 根据改变的数字是正的还是负的 来决定前面是否加负号
                    if (widget.ticker.quote['change']! > 0) {
                      res = '\$$price';
                    } else {
                      res = '-\$${price.substring(1, price.length)}';
                    }
                    return Text(
                      // 返回加完符号后的结果
                      res,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey,
                      ),
                    );
                  }(),
                ],
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          // time serires toggle button

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
          const SizedBox(
            height: 10,
          ),
          // Graph

          isLoading
              ? const SizedBox(
                  height: 250,
                  child: Center(
                    child: SizedBox(
                      height: 40,
                      width: 40,
                      // 圆圈进度条吧这是 加载圈圈？
                      child: CircularProgressIndicator(),
                    ),
                  ),
                )
              : SizedBox(
                  height: 250,
                  child: _buildDefaultLineChart(widget.ticker, getType),
                ),
          const SizedBox(
            height: 10,
          ),
          // Follow button
          InkWell(
            onTap: () async {
              final status = await widget.ticker.toggleFollow();
              if (status == 'full') {
                showWarningMsg(
                  context,
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
                border: widget.ticker.followed
                    ? null
                    : Border.all(color: Colors.grey[300]!),
                color: widget.ticker.followed ? Colors.blueGrey : Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                widget.ticker.followed ? 'Followed' : 'Follow',
                style: TextStyle(
                  fontSize: 22,
                  color:
                      widget.ticker.followed ? Colors.white : Colors.blueGrey,
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
                function: () {
                  widget.setScreen('news');
                },
              ),
            ],
          ),
          const SizedBox(
            height: 5,
          ),
          // News section
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  for (final news in widget.ticker.newsList)
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

Widget _buildDefaultLineChart(Ticker currentTicker, String type) {
  if (currentTicker.prices[type] == null) {
    return Container();
  }

  return SfCartesianChart(
    primaryXAxis: CategoryAxis(
      isVisible: false,
    ), // Initialize category axis.

    series: <LineSeries<Map<String, dynamic>, String>>[
      // Initialize line series.
      LineSeries<Map<String, dynamic>, String>(
        dataSource: [...currentTicker.prices[type]!],
        // x : time point , y : price (open)
        xValueMapper: (Map<String, dynamic> price, _) => price.keys.first,
        yValueMapper: (Map<String, dynamic> price, _) => price.values.first,
      ),
    ],
  );
}

class TimeSeriesButton extends StatelessWidget {
  const TimeSeriesButton({
    Key? key,
    required this.name,
    required this.function,
    required this.isPressed,
  }) : super(key: key);
  final String name;
  final bool isPressed;
  final Function function;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        function();
      },
      child: Container(
        decoration: BoxDecoration(
          color: isPressed ? Colors.blueGrey : Colors.grey[200],
          borderRadius: BorderRadius.circular(
            5,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 8.0,
            horizontal: 16,
          ),
          child: Text(
            name,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: isPressed ? Colors.white : Colors.blueGrey,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }
}
