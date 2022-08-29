import 'package:flutter/material.dart';

class _LoadingWidget extends StatelessWidget {
  const _LoadingWidget({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // ignore: sized_box_for_whitespace
    return Container(
      width: 100,
      height: 100,
      child: Center(
        child: SizedBox(
          height: 40.0,
          width: 40.0,
          child: CircularProgressIndicator(
            color: Colors.blue[400],
          ),
        ),
      ),
    );
  }
}

void showLoadingBoxTransparent(final BuildContext context) {
  showDialog(
    barrierColor: Colors.white.withOpacity(0),
    barrierDismissible: false,
    context: context,
    builder: (context) {
      return const _LoadingWidget();
    },
  );
}

void showLoadingBoxDark(final BuildContext context) {
  showDialog(
    barrierColor: Colors.white.withOpacity(0),
    barrierDismissible: false,
    context: context,
    builder: (context) {
      return const _LoadingWidget();
    },
  );
}
