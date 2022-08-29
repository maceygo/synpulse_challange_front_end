import 'package:flutter/material.dart';

class SeeAllWidget extends StatelessWidget {
  final Function function;
  const SeeAllWidget({
    Key? key,
    required this.function,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        function();
      },
      child: Row(
        children: const [
          Text(
            'See all',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.blue,
            ),
          ),
          Icon(
            Icons.arrow_forward,
            color: Colors.blue,
            size: 18,
          ),
        ],
      ),
    );
  }
}
