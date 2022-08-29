bool loadedPortolios = false;

List<Portfolio> portfolios = [];

class Portfolio {
  String rank,
      measurementStart,
      startValueUsd,
      measurementEnd,
      endValueUsd,
      percentGain;
  List<dynamic> tickers = [];
  Portfolio(
      {this.rank = "",
      this.measurementStart = "",
      this.startValueUsd = "",
      this.measurementEnd = "",
      this.endValueUsd = "",
      this.percentGain = "",
      this.tickers = const []});
}

List<Portfolio> convertPortfolios(Map data) {
  final List<Portfolio> results = [];
  data['ranking'].forEach((portfolio) {
    results.add(
      Portfolio(
        rank: portfolio["rank"],
        measurementStart: portfolio["measurement_start"],
        startValueUsd: portfolio["start_value_usd"],
        measurementEnd: portfolio["measurement_end"],
        endValueUsd: portfolio["end_value_usd"],
        percentGain: portfolio["percent_gain"],
        tickers: portfolio["portfolio"],
      ),
    );
  });
  return results;
}
