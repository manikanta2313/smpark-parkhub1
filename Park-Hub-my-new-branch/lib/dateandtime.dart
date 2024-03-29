import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smartparkin1/MapsPage.dart';
import 'package:smartparkin1/vehicle_details_page.dart';

class DateAndTime extends StatefulWidget {
  final String lotName;
  final String lotId;
  const DateAndTime({super.key, required this.lotName, required this.lotId});

  @override
  State<DateAndTime> createState() => DateAndTimeState();
}

class CountController extends StatelessWidget {
  final int count;
  final ValueSetter<int> onChanged;

  const CountController({
    super.key,
    required this.count,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        FloatingActionButton(
          heroTag: 'Decrement',
          onPressed: () => onChanged(count > 0 ? count - 1 : count),
          backgroundColor: Colors.black,
          child: const Icon(Icons.remove, color: Colors.white),
        ),
        const SizedBox(width: 16),
        Text(
          '$count',
          style: const TextStyle(fontSize: 20),
        ),
        const SizedBox(width: 16),
        FloatingActionButton(
          heroTag: 'Increment',
          onPressed: () => onChanged(count + 1),
          backgroundColor: Colors.black,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ],
    );
  }
}

class DateAndTimeState extends State<DateAndTime> {
  DateTime _selectedDateTime = DateTime.now();
  int _selectedHours = 0;

  @override
  void initState() {
    super.initState();
    _selectedDateTime = DateTime.now(); // Initialize with current date and time
  }

  void _updateSelectedDateTime(DateTime newDateTime) {
    setState(() {
      _selectedDateTime = newDateTime;
    });
  }

  void _selectDateTime(BuildContext context) async {
    DateTime now = DateTime.now();
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      // ignore: use_build_context_synchronously
      TimeOfDay? pickedTime = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.fromDateTime(now));


      if (pickedTime != null) {
        _updateSelectedDateTime(DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        ));
      }
    }
  }

  String _formatDateTime(DateTime dateTime) {
    String formattedDateTime =
    DateFormat('MMMM d,  h:mm a').format(dateTime);
    return formattedDateTime;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MapsPage()),
        );
        // Return true to allow back navigation, return false to prevent it
        return true;
      },
      child: Scaffold(
        body: Column(
          children: [
            _buildBackgroundContainer(),
            _buildBottomContainer(context),
          ],
        ),
      ),
    );
  }

  Widget _buildBackgroundContainer() {
    return Container(
      color: Colors.black,
      height: MediaQuery.of(context).size.height / 2,
      child: Image.asset(
        'assets/images/clock2.avif',
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildBottomContainer(BuildContext context) {
    return Container(
      color: Colors.white,
      height: MediaQuery.of(context).size.height / 2,
      child: Column(
        children: [
          _buildSelectDateTimeButton(),
          GestureDetector(
            onTap: () => _selectDateTime(context),
            child: Text(
              _formatDateTime(_selectedDateTime),
              style: const TextStyle(
                  fontSize: 24,
                  color: Colors.blue,
                  fontWeight: FontWeight.bold),
            ),
          ),
          _buildTimeSelectionContainer(),
          _buildButtons(),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSelectDateTimeButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 30.0, left: 30.0, right: 30.0),
      child: ElevatedButton(
        onPressed: () => _selectDateTime(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          textStyle: const TextStyle(fontSize: 20),
        ),
        child: const Text(
          'Select date and time of arrival',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildTimeSelectionContainer() {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Select Time (Hours)',
              style: TextStyle(fontSize: 22),
            ),
            CountController(
              count: _selectedHours,
              onChanged: (newCount) {
                setState(() {
                  _selectedHours = newCount;
                });
              },
            ),
            const SizedBox(height: 10),
            Text(
              'Total Amount: ₹${_selectedHours * 30}',
              style: const TextStyle(fontSize: 20),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        ElevatedButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const MapsPage()),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
          ),
          child: const Text('Back'),
        ),
        ElevatedButton(
          onPressed: () {
            if(_selectedHours != 0){
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => VehicleDetailsPage(
                    amountToPass: _selectedHours * 30,
                    lotName: widget.lotName,
                    reserved: _selectedDateTime,
                    hours: _selectedHours,
                    lotId: widget.lotId,
                  ),
                ),
              );
            } else {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Please Select Hours.'),
                    actions: [
                      const SizedBox(height: 50,),
                      Center(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.purple,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                          ),
                          child: const Text('OK',style: TextStyle(fontWeight: FontWeight.bold),),
                        ),
                      )
                    ],
                  );
                },
              );
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
          ),
          child: const Text('Next'),
        ),
      ],
    );
  }
}