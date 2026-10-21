import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(const DiscountApp());

class DiscountApp extends StatelessWidget {
  const DiscountApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculator de reducere',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
      ),
      home: const DiscountPage(),
    );
  }
}

class DiscountPage extends StatefulWidget {
  const DiscountPage({super.key});

  @override
  State<DiscountPage> createState() => _DiscountPageState();
}

class _DiscountPageState extends State<DiscountPage> {
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _percentController = TextEditingController();

  static const List<String> _currencies = ['MDL', 'EUR', 'USD', 'RON'];
  String _currency = _currencies.first;

  String? _error;
  double? _discountValue;
  double? _finalPrice;

  @override
  void dispose() {
    _priceController.dispose();
    _percentController.dispose();
    super.dispose();
  }

  // Acceptă și virgulă ca separator zecimal (ex: 99,90)
  double? _parse(String text) => double.tryParse(text.trim().replaceAll(',', '.'));

  void _calculate() {
    FocusScope.of(context).unfocus();

    final price = _parse(_priceController.text);
    final percent = _parse(_percentController.text);

    if (price == null || percent == null) {
      _showError('Introdu valori numerice în ambele câmpuri.');
      return;
    }
    if (price < 0) {
      _showError('Prețul nu poate fi negativ.');
      return;
    }
    if (percent < 0 || percent > 100) {
      _showError('Procentul reducerii trebuie să fie între 0 și 100.');
      return;
    }

    final discount = price * percent / 100;
    setState(() {
      _error = null;
      _discountValue = discount;
      _finalPrice = price - discount;
    });
  }

  void _showError(String message) {
    setState(() {
      _error = message;
      _discountValue = null;
      _finalPrice = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculator de reducere'),
        centerTitle: true,
        backgroundColor: theme.colorScheme.primaryContainer,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // TextField 1: prețul inițial
              TextField(
                controller: _priceController,
                keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                ],
                decoration: const InputDecoration(
                  labelText: 'Preț inițial',
                  hintText: 'ex: 1200',
                  prefixIcon: Icon(Icons.sell_outlined),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // TextField 2: procentul reducerii
              TextField(
                controller: _percentController,
                keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                ],
                decoration: const InputDecoration(
                  labelText: 'Procentul reducerii',
                  hintText: 'ex: 15',
                  suffixText: '%',
                  prefixIcon: Icon(Icons.percent),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // DropdownButton: moneda
              InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Moneda',
                  prefixIcon: Icon(Icons.payments_outlined),
                  border: OutlineInputBorder(),
                  contentPadding:
                  EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _currency,
                    isExpanded: true,
                    items: _currencies
                        .map((c) => DropdownMenuItem<String>(
                      value: c,
                      child: Text(c),
                    ))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) setState(() => _currency = value);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // ElevatedButton: calculează
              ElevatedButton.icon(
                onPressed: _calculate,
                icon: const Icon(Icons.calculate),
                label: const Text('Calculează'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 18),
                ),
              ),
              const SizedBox(height: 24),

              // Output: mesaj de eroare sau rezultate
              if (_error != null)
                Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: theme.colorScheme.error, fontSize: 16),
                ),
              if (_discountValue != null && _finalPrice != null)
                Card(
                  color: theme.colorScheme.secondaryContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Text(
                          'Valoarea reducerii: '
                              '${_discountValue!.toStringAsFixed(2)} $_currency',
                          style: const TextStyle(fontSize: 18),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Preț final: '
                              '${_finalPrice!.toStringAsFixed(2)} $_currency',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
