import 'package:flutter/material.dart';

class NumberPad extends StatelessWidget {
  final Function keyOnPressed;
  final List<List<String>> keys;
  final String size;

  final List<Map<String, dynamic>>? additionalButtons;

  late final double fontSize;
  late final Size containerSize;
  late final Size wholeSize;
  NumberPad({
    required this.keyOnPressed,
    required this.keys,
    this.size = 'big',
    this.additionalButtons,
  }) {
    switch (size) {
      case 'big':
        fontSize = 23;
        containerSize = Size(80, 60);
        wholeSize = Size(360, (containerSize.height + 20) * keys.length + 50);
        break;

      case 'mid':
        fontSize = 18;
        containerSize = Size(65, 50);
        wholeSize = Size(280, (containerSize.height + 20) * keys.length + 50);
        break;

      case 'normal':
        fontSize = 14;
        containerSize = Size(60, 45);

        if (additionalButtons == null) {
          wholeSize = Size(250, (containerSize.height + 20) * keys.length);
        } else {
          wholeSize = Size(350, (containerSize.height + 20) * keys.length);
        }
        break;
      case 'small':
        fontSize = 12;
        containerSize = Size(50, 15);
        wholeSize = Size(250, 250);
        break;
      default:
    }
  }

  Widget numberKey({String keyName = ''}) {
    Widget keyWidget;

    if (keyName == '<-') {
      keyWidget = Icon(Icons.backspace_outlined);
    } else if (keyName == '.') {
      keyWidget = Text(
        keyName,
        style: TextStyle(
            fontSize: fontSize + 1,
            fontWeight: FontWeight.bold,
            color: Colors.black54),
      );
    } else {
      keyWidget = Text(
        keyName,
        style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: Colors.black54),
      );
    }

    if (keyName == ' ') {
      return Padding(
        padding: const EdgeInsets.all(5.0),
        child: Card(
          elevation: 0,
          color: Colors.transparent,
          child: Container(
            alignment: Alignment.center,
            width: containerSize.width,
            height: containerSize.height,
            child: keyWidget,
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Card(
        // shape: ,
        elevation: 3,
        child: InkWell(
          onTap: () {
            keyOnPressed(keyName);
          },
          child: Container(
            alignment: Alignment.center,
            width: containerSize.width,
            height: containerSize.height,
            child: keyWidget,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: wholeSize.width,
          height: wholeSize.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: Colors.grey[200],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                child: Column(
                  children: [
                    for (List<String> row in keys)
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            for (String key in row) numberKey(keyName: key),
                          ],
                        ),
                      )
                  ],
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (additionalButtons != null)
                    for (var keys in additionalButtons!)
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(5),
                          child: Card(
                            elevation: 3,
                            child: InkWell(
                              onTap: () {
                                keys['function']();
                              },
                              child: Container(
                                alignment: Alignment.center,
                                width: containerSize.width,
                                height: containerSize.height,
                                child: Text(
                                  keys['button'],
                                  style: TextStyle(
                                      fontSize: fontSize,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black54),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                ],
              )
            ],
          ),
        ),
      ],
    );
  }
}
