import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import '../widgets/bottom_navbar.dart';

class AbsensiPage extends StatefulWidget {
  @override
  _AbsensiPageState createState() => _AbsensiPageState();
}

class _AbsensiPageState extends State<AbsensiPage> {
  DateTime? clockInTime;
  DateTime? clockOutTime;
  Timer? _timer;
  bool isWorking = false;
  int _currentIndex = 0;
  bool isBreak = false;
  DateTime? breakStartTime;
  DateTime selectedDate = DateTime.now();
  Duration totalBreakDuration = Duration.zero;

  List<Map<String, dynamic>> history = [];

  void clockIn() {
    setState(() {
      clockInTime = DateTime.now();
      clockOutTime = null;
      isWorking = true;

      totalBreakDuration = Duration.zero;
      isBreak = false;
      breakStartTime = null;
    });

    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {});
    });
  }

  void clockOut() {
    if (clockInTime == null) return;

    if (isBreak && breakStartTime != null) {
      Duration breakDuration = DateTime.now().difference(breakStartTime!);
      totalBreakDuration += breakDuration;

      isBreak = false;
      breakStartTime = null;
    }

    _timer?.cancel();

    setState(() {
      clockOutTime = DateTime.now();
      isWorking = false;

      Duration total =
          clockOutTime!.difference(clockInTime!) - totalBreakDuration;

      history.insert(0, {
        'date': DateFormat('dd MMMM yyyy').format(clockInTime!),
        'in': DateFormat('HH:mm').format(clockInTime!),
        'out': DateFormat('HH:mm').format(clockOutTime!),
        'total': formatDuration(total),
      });
    });
  }

  void startBreak() {
    setState(() {
      isBreak = true;
      breakStartTime = DateTime.now();
    });
  }

  void endBreak() {
    if (breakStartTime == null) return;

    setState(() {
      isBreak = false;

      Duration breakDuration = DateTime.now().difference(breakStartTime!);
      totalBreakDuration += breakDuration;

      breakStartTime = null;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String formatDuration(Duration d) {
    return "${d.inHours}:${(d.inMinutes % 60).toString().padLeft(2, '0')}:${(d.inSeconds % 60).toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: SafeArea(
        child: Column(
          children: [
            header(),
            SizedBox(height: 10),
            currentStatusCard(),
            SizedBox(height: 10),
            Expanded(child: historyList()),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavbar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        onProfile: () {
          // navigasi ke halaman Profile
          Navigator.pushNamed(context, '/profile');
        },
        onLogout: () {
          // logika logout
          Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
        },
      ),
    );
  }

  Widget header() {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 25, 20, 25),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF2C2C2C), Color(0xFF111111)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // NAME + ICON
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Fahrul Zahir",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                ),
              ),
              CircleAvatar(
                backgroundColor: Color(0xFFC67C4E),
                child: Icon(Icons.person, color: Colors.white),
              ),
            ],
          ),

          SizedBox(height: 15),

          // STATUS + DATE
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: !isWorking
                      ? Color.fromARGB(255, 255, 210, 205)
                      : isBreak
                      ? Color.fromARGB(255, 255, 236, 199)
                      : Color(0xFFE6F4EA),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isWorking
                      ? (isBreak ? "Sedang Break" : "Sedang Bekerja")
                      : "Belum Clock In",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: !isWorking
                        ? Colors.red
                        : isBreak
                        ? Colors.orange
                        : Colors.green,
                  ),
                ),
              ),
              RichText(
                textAlign: TextAlign.right,
                text: TextSpan(
                  style: TextStyle(
                    color: Colors.white70,
                    fontFamily: 'Sora', // biar konsisten
                    fontSize: 14,
                  ),
                  children: [
                    TextSpan(
                      text: DateFormat('d MMMM yyyy\n').format(DateTime.now()),
                    ),
                    TextSpan(
                      text: DateFormat('HH:mm').format(DateTime.now()),
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 20),

          // BUTTON
          isWorking
              ? Row(
                  children: [
                    Expanded(
                      child: AnimatedButton(
                        onTap: isBreak ? endBreak : startBreak,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isBreak
                              ? Colors.green
                              : Color(0xFFF9E5BE),
                          foregroundColor: isBreak
                              ? Colors.white
                              : Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 15),
                        ),
                        child: Text(isBreak ? "End Break" : "Take A Break"),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: AnimatedButton(
                        onTap: clockOut,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF4B352A),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 15),
                        ),
                        child: Text("Clock Out"),
                      ),
                    ),
                  ],
                )
              : SizedBox(
                  width: double.infinity,
                  child: AnimatedButton(
                    onTap: clockIn,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFC67C4E),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 15),
                    ),
                    child: Text("Clock In"),
                  ),
                ),
        ],
      ),
    );
  }

  void pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Widget currentStatusCard() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 15),
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Total Working Hour",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Text(
            (clockInTime != null && isWorking)
                ? formatDuration(
                    (isBreak ? breakStartTime! : DateTime.now()).difference(
                          clockInTime!,
                        ) -
                        totalBreakDuration,
                  )
                : "0:00:00",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("In"),
                  Text(
                    clockInTime != null
                        ? DateFormat('HH:mm').format(clockInTime!)
                        : "--:--",
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Out"),
                  Text(
                    clockOutTime != null
                        ? DateFormat('HH:mm').format(clockOutTime!)
                        : "--:--",
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget historyList() {
    final filtered = history.where((item) {
      return item['date'] == DateFormat('dd MMMM yyyy').format(selectedDate);
    }).toList();

    return Column(
      children: [
        // DATE PICKER BUTTON
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DateFormat('dd MMMM yyyy').format(selectedDate),
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              IconButton(onPressed: pickDate, icon: Icon(Icons.calendar_month)),
            ],
          ),
        ),

        Expanded(
          child: filtered.isEmpty
              ? Center(child: Text("Tidak ada data"))
              : ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final item = filtered[index];

                    return Container(
                      margin: EdgeInsets.all(10),
                      padding: EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Total: ${item['total']}"),
                          SizedBox(height: 5),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("In: ${item['in']}"),
                              Text("Out: ${item['out']}"),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class AnimatedButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  final ButtonStyle style;

  const AnimatedButton({
    required this.child,
    required this.onTap,
    required this.style,
  });

  @override
  State<AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton> {
  double scale = 1.0;

  void _pressDown() => setState(() => scale = 0.96);
  void _pressUp() => setState(() => scale = 1.0);

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => _pressDown(),
      onPointerUp: (_) => _pressUp(),
      child: AnimatedScale(
        scale: scale,
        duration: Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: ElevatedButton(
          onPressed: widget.onTap,
          style: widget.style,
          child: widget.child,
        ),
      ),
    );
  }
}
