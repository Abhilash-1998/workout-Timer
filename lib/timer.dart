import 'dart:math' as Math;
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:confetti/confetti.dart';
import 'package:audioplayers/audioplayers.dart';

class TimerPage extends StatefulWidget {
  final int sets;
  final int workouts;
  final int workoutTime;
  final int restTime;
  final int restBetweenSets;

  const TimerPage({
    Key? key,
    required this.sets,
    required this.workouts,
    required this.workoutTime,
    required this.restTime,
    required this.restBetweenSets,
  }) : super(key: key);

  @override
  State<TimerPage> createState() => _TimerPageState();
}

class _TimerPageState extends State<TimerPage> {
  int _currentSet = 1;
  int _currentWorkout = 1;
  int _remainingTime = 0;
  bool _isWorkout = true;
  bool _isRunning = false;
  bool _countdownPlayed = false;
  bool _isGetReady = true;
  int _getReadyTime = 5;

  Timer? _timer;
  Timer? _getReadyTimer;
  final AudioPlayer _audioPlayer = AudioPlayer();
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 5));
    _startGetReadyCountdown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _getReadyTimer?.cancel();
    _confettiController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _startGetReadyCountdown() {
    setState(() {
      _isGetReady = true;
      _getReadyTime = 10; // or any duration
    });

    _getReadyTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_getReadyTime > 1) {
        if (_getReadyTime == 6) {
          _playSound('beep.mp3');
        }
        setState(() {
          _getReadyTime--;
        });
      } else {
        _playSound('beep.mp3'); // Final beep at 1
        timer.cancel();
        setState(() {
          _isGetReady = false;
        });
        _startWorkout();
      }
    });
  }





  void _startWorkout() {
    _currentSet = 1;
    _currentWorkout = 1;
    _isWorkout = true;
    _remainingTime = widget.workoutTime;
    _isRunning = true;
    _countdownPlayed = false;
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isRunning) {
        timer.cancel();
        return;
      }

      setState(() {
        // ✅ Countdown sound logic
        if (_remainingTime == 6 && !_countdownPlayed) {
          bool isFinalRest = !_isWorkout &&
              _currentWorkout == widget.workouts &&
              _currentSet == widget.sets;

          _playSound(isFinalRest ? 'timer.mp3' : 'beep.mp3');
          _countdownPlayed = true;
        }


        if (_remainingTime > 0) {
          _remainingTime--;
        } else {
          _countdownPlayed = false;
          _nextInterval();
        }
      });
    });
  }



  void _nextInterval() {
    _timer?.cancel();

    if (_isWorkout) {
      _isWorkout = false;
      _remainingTime = widget.restTime;
    } else {
      if (_currentWorkout < widget.workouts) {
        _currentWorkout++;
        _isWorkout = true;
        _remainingTime = widget.workoutTime;
      } else if (_currentSet < widget.sets) {
        _currentSet++;
        _currentWorkout = 1;
        _isWorkout = false;
        _remainingTime = widget.restBetweenSets;
      } else {
        _stopTimer();
        _showWorkoutCompleteDialog();
        return;
      }
    }

    if (_isRunning) {
      _startTimer(); // ✅ Start fresh timer
    }
  }


  void _stopTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
    });
  }

  void _pauseResumeTimer() {
    setState(() {
      _isRunning = !_isRunning;
    });

    if (_isRunning) {
      _startTimer();
    } else {
      _timer?.cancel();
    }
  }

  void _resetTimer() {
    _stopTimer();
    _startWorkout();
  }

  void _cancelWorkout() {
    _stopTimer();
    Navigator.pop(context, true);
  }

  void _showWorkoutCompleteDialog() {
    _confettiController.play();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 10,
          backgroundColor: Colors.white,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle, size: 60, color: Colors.green),
                const SizedBox(height: 16),
                const Text("Workout Complete!", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black)),
                const SizedBox(height: 12),
                const Text("Congratulations, you've finished your workout.", textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: Colors.black87)),
                const SizedBox(height: 24),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  },
                  child: const Text("OK", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _playSound(String fileName) async {
    try {
      await _audioPlayer.play(AssetSource('sounds/$fileName'));
    } catch (e) {
      debugPrint('Error playing sound: $e');
    }
  }

  String _formatTime(int seconds) {
    int minutes = (seconds ~/ 60);
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Workout Timer'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      backgroundColor: Colors.white,
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          Center(
            child: _isGetReady
                ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Get Ready', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                Text('$_getReadyTime', style: const TextStyle(fontSize: 80, fontWeight: FontWeight.bold)),
              ],
            )
                : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _isWorkout ? 'Workout' : 'Rest',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: _isWorkout ? Colors.green : Colors.red,
                  ),
                ),
                Text(_formatTime(_remainingTime), style: const TextStyle(fontSize: 60, fontWeight: FontWeight.bold)),
                Text('Set: $_currentSet / ${widget.sets}', style: const TextStyle(fontSize: 18)),
                Text('Workout: $_currentWorkout / ${widget.workouts}', style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildGradientButton(onPressed: _pauseResumeTimer, text: _isRunning ? 'Pause' : 'Resume', gradientColors: const [Color(0xFF4CAF50), Color(0xFF66BB6A)]),
                    const SizedBox(width: 10),
                    _buildGradientButton(onPressed: _resetTimer, text: 'Reset', gradientColors: const [Color(0xFFFF9800), Color(0xFFFBC02D)]),
                    const SizedBox(width: 10),
                    _buildGradientButton(onPressed: _cancelWorkout, text: 'Cancel', gradientColors: const [Color(0xFFF44336), Color(0xFFE57373)]),
                  ],
                ),
              ],
            ),
          ),
          ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            emissionFrequency: 0.05,
            numberOfParticles: 30,
            gravity: 0.2,
            maxBlastForce: 30,
            minBlastForce: 10,
            particleDrag: 0.05,
            colors: const [Colors.green, Colors.blue, Colors.pink, Colors.orange, Colors.purple, Colors.yellow, Colors.cyan],
            createParticlePath: drawStar,
          ),
        ],
      ),
    );
  }

  Widget _buildGradientButton({required VoidCallback onPressed, required String text, required List<Color> gradientColors}) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          gradient: LinearGradient(colors: gradientColors, begin: Alignment.topLeft, end: Alignment.bottomRight),
          boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.2), spreadRadius: 1, blurRadius: 4, offset: const Offset(0, 2))],
        ),
        child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
      ),
    );
  }

  Path drawStar(Size size) {
    double degToRad(double deg) => deg * (3.1415926535897932 / 180.0);
    const numberOfPoints = 5;
    final halfWidth = size.width / 2;
    final externalRadius = halfWidth;
    final internalRadius = halfWidth / 2.5;
    final path = Path();
    final angle = 360 / numberOfPoints;

    for (int i = 0; i < numberOfPoints; i++) {
      final x1 = halfWidth + externalRadius * Math.cos(degToRad(i * angle));
      final y1 = halfWidth + externalRadius * Math.sin(degToRad(i * angle));
      final x2 = halfWidth + internalRadius * Math.cos(degToRad(i * angle + angle / 2));
      final y2 = halfWidth + internalRadius * Math.sin(degToRad(i * angle + angle / 2));
      if (i == 0) {
        path.moveTo(x1, y1);
      } else {
        path.lineTo(x1, y1);
      }
      path.lineTo(x2, y2);
    }
    path.close();
    return path;
  }
}
