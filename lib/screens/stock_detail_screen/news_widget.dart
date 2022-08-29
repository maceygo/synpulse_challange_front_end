import 'package:flutter/material.dart';
import '/models/news.dart';
import 'package:url_launcher/url_launcher.dart';

class TickerNews extends StatelessWidget {
  const TickerNews({Key? key, required this.news}) : super(key: key);
  final News news;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        await launch(
          news.newsUrl,
          forceSafariVC: false,
          forceWebView: false,
        );
      },
      child: Card(
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              if (news.imageUrl.contains("financialexpress.com/") ==
                  false) //  HTTP request failed, statusCode: 403,
                CircleAvatar(
                  radius: 30.0,
                  backgroundImage: NetworkImage(news.imageUrl),
                  backgroundColor: Colors.transparent,
                ),
              const SizedBox(
                width: 20,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      news.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.left,
                    ),
                    Text(
                      '${news.author} | ${news.getConvertTime}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey,
                      ),
                      maxLines: 2,
                      textAlign: TextAlign.left,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
