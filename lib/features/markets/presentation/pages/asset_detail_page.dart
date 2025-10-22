import 'package:flutter/material.dart';

class AssetDetailPage extends StatelessWidget {
  const AssetDetailPage({required this.symbol, super.key});

  final String symbol;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(symbol)),
      body: Center(
        child: Text('Detalle de $symbol (gráficos, volumen, trading).'),
      ),
    );
  }
}
