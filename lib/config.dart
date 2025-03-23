
import 'package:flutter/material.dart';
import 'package:workouttimer/timer.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ConfigurationPage extends StatefulWidget {
  const ConfigurationPage({Key? key}) : super(key: key);

  @override
  State<ConfigurationPage> createState() => _ConfigurationPageState();
}

class _ConfigurationPageState extends State<ConfigurationPage> {
  int _sets = 1;
  int _workouts = 1;
  int _workoutTime = 30;
  int _restTime = 30;
  int _restBetweenSets = 30;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _sets = prefs.getInt('sets') ?? 1;
      _workouts = prefs.getInt('workouts') ?? 1;
      _workoutTime = (prefs.getInt('workoutTime') ?? 30).clamp(30, 120);
      _restTime = (prefs.getInt('restTime') ?? 30).clamp(30, 120);
      _restBetweenSets = (prefs.getInt('restBetweenSets') ?? 30).clamp(30, 360);
    });
  }


  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('sets', _sets);
    await prefs.setInt('workouts', _workouts);
    await prefs.setInt('workoutTime', _workoutTime);
    await prefs.setInt('restTime', _restTime);
    await prefs.setInt('restBetweenSets', _restBetweenSets);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Timer Configuration',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildNumberPickerRow(
              label: 'Sets',
              value: _sets,
              minValue: 1,
              maxValue: 10,
              onChanged: (value) => setState(() => _sets = value),
            ),
            _buildNumberPickerRow(
              label: 'Workouts per Set',
              value: _workouts,
              minValue: 1,
              maxValue: 20,
              onChanged: (value) => setState(() => _workouts = value),
            ),
            _buildNumberPickerRow(
              label: 'Workout Time (seconds)',
              value: _workoutTime,
              minValue: 30, // ⬅ minimum 30
              maxValue: 120,
              onChanged: (value) => setState(() => _workoutTime = value),
            ),
            _buildNumberPickerRow(
              label: 'Rest Time (seconds)',
              value: _restTime,
              minValue: 30, // ⬅ minimum 30
              maxValue: 120,
              onChanged: (value) => setState(() => _restTime = value),
            ),
            _buildNumberPickerRow(
              label: 'Rest Between Sets (seconds)',
              value: _restBetweenSets,
              minValue: 30, // ⬅ minimum 30
              maxValue: 360,
              onChanged: (value) => setState(() => _restBetweenSets = value),
            ),
            _buildGradientButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildNumberPickerRow({
    required String label,
    required int value,
    required int minValue,
    required int maxValue,
    required ValueChanged<int> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              )),
          const SizedBox(height: 12),
          Center(
            child: NumberPicker(
              minValue: minValue,
              maxValue: maxValue,
              value: value,
              itemHeight: 50,
              itemWidth: 70,
              axis: Axis.horizontal,
              onChanged: onChanged,
              textStyle: const TextStyle(color: Colors.black54, fontSize: 18),
              selectedTextStyle: const TextStyle(
                color: Colors.blue,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.blue.shade200),
                  bottom: BorderSide(color: Colors.blue.shade200),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildGradientButton(BuildContext context) {
    return Center(
      child: InkWell(
        onTap: () {
          _saveSettings();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TimerPage(
                sets: _sets,
                workouts: _workouts,
                workoutTime: _workoutTime,
                restTime: _restTime,
                restBetweenSets: _restBetweenSets,
              ),
            ),
          );
        },
        child: Container(
          width: 300,
          padding: const EdgeInsets.symmetric(vertical: 15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: const LinearGradient(
              colors: [Color(0xFF4FC3F7), Color(0xFF29B6F6)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 2,
                blurRadius: 7,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: const Center(
            child: Text(
              'Start Workout',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
