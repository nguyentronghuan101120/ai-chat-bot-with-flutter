import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class LoadingWidget extends StatelessWidget {
  const LoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40,
      height: 20,
      child: const SpinKitThreeBounce(
        color: Colors.black54,
        size: 20,
      ),
    );
  }
}
