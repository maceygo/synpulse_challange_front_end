import 'package:flutter/material.dart';
import 'api_manager.dart';
import 'models/stock.dart';
import 'models/user.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/login_screen/signin_screen.dart';
import 'screens/login_screen/signup_screen.dart';
import 'screens/stock_detail_screen/news_screen.dart';
import 'screens/stock_detail_screen/stock_detail_screen.dart';
import 'screens/stock_search_screen/stock_search_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized(); // Add this
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Synpulse Challenge',
      theme: ThemeData(
        primarySwatch: Colors.grey,
      ),
      home: const MainScreen(),
      // home: const PortfolioScreen(),
    );
  }
}

// Screen to manage all the screen
class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late String currentScreen;
  late Ticker selectedTicker;

  void login() async {
    setScreen('dashboard');
  }

  void testFunction() async {
    appUser = AppUser(id: testId);
    setState(() {});
  }

  void setScreen(String screen) {
    currentScreen = screen;
    setState(() {});
  }

  void setTicker(String symbol) async {
    selectedTicker = tickers.firstWhere((element) => element.symbol == symbol);
    if (selectedTicker.notGetQuote) {
      final quoteData = await tickerQuoteApi(selectedTicker.symbol);
      selectedTicker.quote = getQuote(quoteData);
    }
  }

  @override
  void initState() {
    appUser = AppUser(id: '');
    // testFunction();
    super.initState();
    currentScreen = 'signup';
  }

  Widget get _getScreen {
    switch (currentScreen) {
      case 'signup':
        return RegisterScreen(setScreen: setScreen);
      case 'login':
        return LoginScreen(setScreen: setScreen);
      case 'dashboard':
        return SafeArea(
          child: DashboardScreen(
            setScreen: setScreen,
            setTicker: setTicker,
          ),
        );
      case 'stock detail':
        return SafeArea(
          child: StockDetailScreen(
            setScreen: setScreen,
            ticker: selectedTicker,
          ),
        );

      case 'stock search':
        return SafeArea(
          child: StockSearchScreen(
            setScreen: setScreen,
            setTicker: setTicker,
          ),
        );
      case 'news':
        return SafeArea(
          child: NewsScreen(
            ticker: selectedTicker,
            setScreen: setScreen,
          ),
        );
      default:
    }
    return Container();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Container(
          child: _getScreen,
        ),
      ),
    );
  }
}
