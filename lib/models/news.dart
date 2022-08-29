class News {
  String title;
  String imageUrl;
  String publishTime;
  String author;
  String newsUrl;

  News({
    this.author = '',
    this.imageUrl = '',
    this.publishTime = '',
    this.title = '',
    this.newsUrl = '',
  });

  // 转换后的时间 好家伙 当前时间减发布时间的时间差
  String get getConvertTime {
    final dateTime = DateTime.parse(publishTime);
    final difference = DateTime.now().difference(dateTime);
    // 时间差小于一个小时
    if (difference.inHours == 0) {
      if (difference.inMinutes == 0) {
        return 'now';
      } else {
        return '${difference.inMinutes}m';
      }
    }
    // 大于24小时 单位用d 否则用h
    if (difference.inHours > 24) {
      return '${difference.inDays}d';
    }
    return '${difference.inHours}h';
  }
}

// convertNews from polygon.io , the news about stocks
List<News> convertNews(Map data) {
  // 发回来的json文件列表 进行处理
  final List<News> results = [];
  data['results'].forEach((news) {
    results.add(
      // new an News object
      News(
        author: news['author'],
        imageUrl: news['image_url'],
        title: news['title'],
        publishTime: news['published_utc'],
        //  be redirected to the source’s origin.
        newsUrl: news['article_url'],
      ),
    );
  });
  return results;
}

// convert news from alpha vantage
// 返回的items个数不固定
List<News> convertCryptoNews(Map data) {
  final List<News> results = [];
  data['feed'].forEach((news) {
    String title = news['title'];
    String imageUrl = news['banner_image'];
    String publishTime = news["time_published"]; //  "20220828T114509",
    String author = news["authors"].length > 0
        ? news["authors"][0]
        : "null"; // the response result maybe empty
    String newsUrl = news["url"];

    results.add(News(
        title: title,
        imageUrl: imageUrl,
        publishTime: publishTime,
        author: author,
        newsUrl: newsUrl));
  });
  return results;
}
