### 1.Installation and Running Guide


Please make sure to install the latest stable version of flutter SDK (mine is 3.0.5-stable) from flutter official website (https://flutter.cn/docs/get-started/install), configure environment variables and run `flutter doctor` to ensure the development environment (android or ios) has been set up correctly. Inconsistent versions of flutter may cause some code errors and run failures.


* Run the `git clone https://github.com/maceygo/synpulse_challange_front_end.git` command in the terminal to download the project code.


* `cd synpulse_challange_front_end`


* `flutter pub get ` install project dependencies



* `flutter run ` run the project on the editor (Visual Studio Code or Android Studio )


* Select the device or emulator you want to run .







### 2.Screenshot and Recording



https://user-images.githubusercontent.com/81661992/187106383-1d0caf20-9ee3-4d20-ba5a-338e4ca5d0da.mov

![Simulator Screen Shot - iPhone 11 Pro Max - 2022-08-29 at 04 15 39 中](https://user-images.githubusercontent.com/81661992/187106668-00a82de1-be4d-44e6-8dd5-2aa4321c7574.jpeg) ![Simulator Screen Shot - iPhone 11 Pro Max - 2022-08-29 at 04 16 22 中](https://user-images.githubusercontent.com/81661992/187106783-70110655-a234-4b6d-a4aa-e0e0a307dc54.jpeg) ![Simulator Screen Shot - iPhone 11 Pro Max - 2022-08-29 at 04 15 25 中](https://user-images.githubusercontent.com/81661992/187106788-4f610145-083f-48d0-b7dd-1fb766b360bd.jpeg)


### 3.Development process documentation


I referred to the open source project https://github.com/cyauai/synpulse_challenge for project construction and data model design, and added several functional modules, including adding support for cryptocurrencies (search function, real-time and historical prices, related news overview and sources, manage and store user watchlists, total portfolio gainers or losses), new portfolio panels and portfolio recommendations.



* Use shared preference for user login verification and save preference settings, and store the financial instrument watch list (string list, because symbol can uniquely correspond to financial instruments) that uniquely corresponds to the user id in the form of key-value pairs. *(lib/models/user.dart)*



* Create a new cryptocurrency data model *(lib/models/cryptocurrency.dart)*, use Alpha Vantage and Polygon Api to obtain financial instrument data *(/lib/screens/portfolio_screen/crypto_item.dart, crypto_detail.dart* , two files respectively define the cryptocurrency in the watchlist widget and detail page)



* Use Algolia to manage cryptos data, including creating index library and initiating query requests through API, algolia returning the hit results of this search. Since Alpha Vantage only provides search endpoint services to stocks, which is not sufficient for demand. *(/lib/screens/stock_search_screen/stock_search_screen.dart)*



* Add a bottom navigation bar to the dashboard screen, and jump to the Portfolio screen by routing. The tabBar in top navigation bar of screen controls the switching of different views of the two financial instruments. *(/lib/screens/portfolio_screen/portfolio_screen.dart)*



  *  The upper part of the stock view is the community recommended portfolio (stock symbol and share), including the past investment period, the change in total value, and the return in percentage; *(/lib/screens/portfolio_screen/stock_view.dart)*



  * The upper part of the cryptocurrency view is the total value of all cryptocurrencies in the watch list, including real-time prices and historical prices, and presents price changes in the form of a line graph, which users can choose to take as an interval of days or weeks. Use a single instance of a financial instrument, virtually virtual, to maintain portfolio aggregated data. Calculated only once when the user logs in, get quotes for all cryptocurrencies in the portfolio, and then update with the user's ToggleFollow event to add or subtract an element. *(/lib/screens/portfolio_screen/crypto_view.dart)*

  * The lower part of the view will be a separate watchlist for the current category of financial instruments.

I tested it on ios emulator, android emulator, chrome web and macos desktop through VS Code editor, on macos desktop you may encounter network connection errors that need to be configured in Xcode.
