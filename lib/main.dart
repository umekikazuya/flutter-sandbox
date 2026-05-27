import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
  Timer? _ticker;
  bool _isSpinning = false;
  double _turns = 0;
  String? _winner;
  String? _liveCandidate;
  static const Duration _spinDuration = Duration(milliseconds: 2400);

  @override
  void dispose() {
    _ticker?.cancel();
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
      if (_liveCandidate != null && !_candidates.contains(_liveCandidate)) {
        _liveCandidate = null;
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
      _liveCandidate = _candidates[winnerIndex];
      _turns += 6 + _random.nextDouble() * 3;
    });

    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(milliseconds: 95), (timer) {
      if (!mounted || !_isSpinning || _candidates.isEmpty) {
        timer.cancel();
        return;
      }
      setState(() {
        _liveCandidate = _candidates[_random.nextInt(_candidates.length)];
      });
      HapticFeedback.selectionClick();
    });

    await Future<void>.delayed(_spinDuration);
    if (!mounted) {
      return;
    }
    _ticker?.cancel();

    setState(() {
      _isSpinning = false;
      _winner = _candidates[winnerIndex];
      _liveCandidate = _winner;
    });
    HapticFeedback.mediumImpact();
  }

  @override
  Widget build(BuildContext context) {
    final canSpin = _candidates.length >= 2 && !_isSpinning;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('ルーレット'),
      ),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE8EEFF), Color(0xFFF7F9FF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
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
                  filled: true,
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
                        size: 44,
                        color: Colors.red.shade500,
                      ),
                    ),
                    AnimatedScale(
                      scale: _isSpinning ? 1.05 : 1,
                      duration: const Duration(milliseconds: 260),
                      curve: Curves.easeOut,
                      child: Container(
                        width: 240,
                        height: 240,
                        margin: const EdgeInsets.only(top: 14),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.indigo.withValues(alpha: 0.2),
                              blurRadius: _isSpinning ? 26 : 12,
                              spreadRadius: _isSpinning ? 4 : 0,
                            ),
                          ],
                        ),
                        child: AnimatedRotation(
                          turns: _turns,
                          duration: _spinDuration,
                          curve: Curves.easeOutCubic,
                          child: CustomPaint(
                            painter: _RouletteWheelPainter(
                              candidates: _candidates,
                              colorScheme: Theme.of(context).colorScheme,
                            ),
                            child: Center(
                              child: Container(
                                width: 92,
                                height: 92,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withValues(alpha: 0.92),
                                ),
                                child: Center(
                                  child: Text(
                                    _isSpinning ? 'SPIN!' : 'READY',
                                    style: Theme.of(context).textTheme.titleLarge,
                                  ),
                                ),
                              ),
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
                          return Card(
                            child: ListTile(
                              title: Text(_candidates[index]),
                              trailing: IconButton(
                                key: Key('deleteCandidate-$index'),
                                onPressed: _isSpinning
                                    ? null
                                    : () => _removeCandidate(index),
                                icon: const Icon(Icons.close),
                              ),
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
                  _isSpinning
                      ? '抽選中: ${_liveCandidate ?? '...'}'
                      : (_winner == null ? '結果: -' : '当選: $_winner'),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RouletteWheelPainter extends CustomPainter {
  _RouletteWheelPainter({required this.candidates, required this.colorScheme});

  final List<String> candidates;
  final ColorScheme colorScheme;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide / 2;
    final count = candidates.isEmpty ? 6 : candidates.length;
    final sweep = 2 * pi / count;
    final rect = Rect.fromCircle(center: center, radius: radius);

    for (var i = 0; i < count; i++) {
      final paint = Paint()
        ..style = PaintingStyle.fill
        ..color = i.isEven
            ? colorScheme.primaryContainer
            : colorScheme.secondaryContainer;
      canvas.drawArc(rect, -pi / 2 + i * sweep, sweep, true, paint);
    }

    final border = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..color = colorScheme.primary;
    canvas.drawCircle(center, radius - 1.5, border);
  }

  @override
  bool shouldRepaint(covariant _RouletteWheelPainter oldDelegate) {
    return oldDelegate.candidates.length != candidates.length ||
        oldDelegate.colorScheme != colorScheme;
  }
}
