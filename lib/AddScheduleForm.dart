import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';  // For date formatting

class AddScheduleForm extends StatefulWidget {
  @override
  _AddScheduleFormState createState() => _AddScheduleFormState();
}

class _AddScheduleFormState extends State<AddScheduleForm> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String _exerciseType = '';
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _notificationsEnabled = false;

  void _pickDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  void _pickTime() async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime != null) {
      setState(() {
        _selectedTime = pickedTime;
      });
    }
  }

  void _saveSchedule() async {
    if (_formKey.currentState!.validate()) {
      User? user = _auth.currentUser;

      if (user != null && _selectedDate != null && _selectedTime != null) {
        // Save the schedule to Firestore (for the current user)
        await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('schedules')  // Save schedules under the current user's data
            .add({
          'exerciseType': _exerciseType,
          'date': Timestamp.fromDate(_selectedDate!),  // Store the date as a Firestore timestamp
          'time': _selectedTime!.format(context),  // Store the time in a readable format
          'notificationsEnabled': _notificationsEnabled,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Schedule added successfully')),
        );

        Navigator.of(context).pop();  // Close the form after saving
      } else {
        // Show an error if date or time is not selected
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a date and time')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Add Schedule'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Exercise Type Input
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Exercise Type',
                  labelStyle: TextStyle(color: Colors.white),
                ),
                onChanged: (value) {
                  setState(() {
                    _exerciseType = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an exercise type';
                  }
                  return null;
                },
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 16.0),

              // Pick Date
              ListTile(
                title: Text(
                  _selectedDate == null
                      ? 'Pick a Date'
                      : 'Date: ${DateFormat.yMMMd().format(_selectedDate!)}',  // Format the date
                  style: const TextStyle(color: Colors.white),
                ),
                trailing: const Icon(Icons.calendar_today, color: Colors.white),
                onTap: _pickDate,
              ),

              // Pick Time
              ListTile(
                title: Text(
                  _selectedTime == null
                      ? 'Pick a Time'
                      : 'Time: ${_selectedTime!.format(context)}',
                  style: const TextStyle(color: Colors.white),
                ),
                trailing: const Icon(Icons.access_time, color: Colors.white),
                onTap: _pickTime,
              ),

              // Enable Notifications Switch
              SwitchListTile(
                title: const Text('Enable Notifications', style: TextStyle(color: Colors.white)),
                value: _notificationsEnabled,
                onChanged: (value) {
                  setState(() {
                    _notificationsEnabled = value;
                  });
                },
              ),
              const SizedBox(height: 16.0),

              // Save Schedule Button
              ElevatedButton(
                onPressed: _saveSchedule,
                child: const Text('Save Schedule'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
