import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Roulette App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
      ),
      home: const RoulettePage(),
    );
  }
}

class RoulettePage extends StatefulWidget {
  const RoulettePage({super.key});

  @override
  State<RoulettePage> createState() => _RoulettePageState();
}

class _RoulettePageState extends State<RoulettePage> {
  final TextEditingController _candidateController = TextEditingController();
  final List<String> _candidates = [];
  final Random _random = Random();
  bool _isSpinning = false;
  double _turns = 0;
  String? _winner;

  @override
  void dispose() {
    _candidateController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _addCandidate() {
    final value = _candidateController.text.trim();
    if (value.isEmpty) {
      _showSnackBar('候補を入力してください');
      return;
    }
    setState(() {
      _candidates.add(value);
      _candidateController.clear();
    });
  }

  void _removeCandidate(int index) {
    setState(() {
      _candidates.removeAt(index);
      if (_winner != null && !_candidates.contains(_winner)) {
        _winner = null;
      }
    });
  }

  Future<void> _spinRoulette() async {
    if (_candidates.length < 2) {
      _showSnackBar('候補を2件以上追加してください');
      return;
    }

    final winnerIndex = _random.nextInt(_candidates.length);

    setState(() {
      _isSpinning = true;
      _winner = null;
      _turns += 4 + _random.nextDouble() * 2;
    });

    await Future<void>.delayed(const Duration(milliseconds: 2200));
    if (!mounted) {
      return;
    }

    setState(() {
      _isSpinning = false;
      _winner = _candidates[winnerIndex];
    });
  }

  @override
  Widget build(BuildContext context) {
    final canSpin = _candidates.length >= 2 && !_isSpinning;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('ルーレット'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              key: const Key('candidateInput'),
              controller: _candidateController,
              enabled: !_isSpinning,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: '候補',
                hintText: '候補名を入力',
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    key: const Key('addCandidateButton'),
                    onPressed: _isSpinning ? null : _addCandidate,
                    icon: const Icon(Icons.add),
                    label: const Text('追加'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton.icon(
                    key: const Key('spinButton'),
                    onPressed: canSpin ? _spinRoulette : null,
                    icon: const Icon(Icons.casino),
                    label: Text(_isSpinning ? '回転中...' : '回す'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    top: 0,
                    child: Icon(
                      Icons.arrow_drop_down,
                      size: 40,
                      color: Colors.red.shade400,
                    ),
                  ),
                  Container(
                    width: 220,
                    height: 220,
                    margin: const EdgeInsets.only(top: 14),
                    child: AnimatedRotation(
                      turns: _turns,
                      duration: const Duration(milliseconds: 2200),
                      curve: Curves.easeOutCubic,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              Theme.of(context).colorScheme.primaryContainer,
                              Theme.of(context).colorScheme.secondaryContainer,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          border: Border.all(
                            color: Theme.of(context).colorScheme.primary,
                            width: 3,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            _isSpinning ? 'SPIN' : 'READY',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text('候補: ${_candidates.length}件'),
            const SizedBox(height: 8),
            Expanded(
              child: _candidates.isEmpty
                  ? const Center(child: Text('候補がありません'))
                  : ListView.builder(
                      itemCount: _candidates.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(_candidates[index]),
                          trailing: IconButton(
                            key: Key('deleteCandidate-$index'),
                            onPressed:
                                _isSpinning ? null : () => _removeCandidate(index),
                            icon: const Icon(Icons.close),
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _winner == null ? '結果: -' : '当選: $_winner',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
