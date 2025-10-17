import 'package:flutter/material.dart';

void main() => runApp(MaterialApp(home:  MinimalStateless()));

class MinimalStateless extends StatelessWidget {
  const MinimalStateless({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Hello, World!'),
    );
  }
}
