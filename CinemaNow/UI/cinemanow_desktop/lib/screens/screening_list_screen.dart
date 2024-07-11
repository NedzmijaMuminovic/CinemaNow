import 'package:flutter/material.dart';

class ScreeningListScreen extends StatelessWidget {
  const ScreeningListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search and Date Row
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 50,
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    decoration: BoxDecoration(
                      color: Colors.grey[850],
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: // Inside the Row widget of the search bar container
                        Row(
                      children: [
                        Icon(Icons.search, color: Colors.grey[500]),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Search',
                            style: TextStyle(color: Colors.grey[500]),
                            overflow: TextOverflow
                                .ellipsis, // Add this line to handle overflow
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Container(
                  height: 50,
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  decoration: BoxDecoration(
                    color: Colors.grey[850],
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today, color: Colors.grey[500]),
                      SizedBox(width: 8),
                      Text(
                        '1/4/2024',
                        style: TextStyle(color: Colors.grey[500]),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[850],
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    minimumSize: Size(0, 55),
                  ),
                  child: Text(
                    'Add a new screening',
                    style: TextStyle(color: Colors.grey[500]),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            // Screenings Grid
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  int crossAxisCount;
                  if (constraints.maxWidth > 1200) {
                    crossAxisCount = 4;
                  } else if (constraints.maxWidth > 900) {
                    crossAxisCount = 3;
                  } else if (constraints.maxWidth > 600) {
                    crossAxisCount = 2;
                  } else {
                    crossAxisCount = 1;
                  }
                  return GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 16.0,
                      mainAxisSpacing: 16.0,
                      childAspectRatio: 1.0,
                    ),
                    itemCount: 4,
                    itemBuilder: (context, index) {
                      return ScreeningCard(
                        imageUrl: index % 2 == 0
                            ? 'assets/images/oppenheimer.jpg'
                            : 'assets/images/barbie.jpg',
                        title: index % 2 == 0 ? 'Oppenheimer' : 'Barbie',
                        date: '1/4/2024',
                        time: index % 2 == 0
                            ? (index == 0 ? '16:00' : '21:00')
                            : (index == 1 ? '20:00' : '17:00'),
                        hall: index % 2 == 0 ? 'Hall 4' : 'Hall 3',
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ScreeningCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String date;
  final String time;
  final String hall;

  const ScreeningCard({
    Key? key,
    required this.imageUrl,
    required this.title,
    required this.date,
    required this.time,
    required this.hall,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints:
          BoxConstraints(minHeight: 180), // Adjust the minimum height as needed
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Stack(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.asset(
                    imageUrl,
                    fit: BoxFit.cover,
                    height: MediaQuery.of(context).size.height * 0.3,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 4),
                      InfoRow(icon: Icons.calendar_today, text: date),
                      InfoRow(icon: Icons.access_time, text: time),
                      InfoRow(icon: Icons.theaters, text: hall),
                    ],
                  ),
                ),
              ],
            ),
            Positioned(
              bottom: 8,
              left: 8,
              child: ElevatedButton.icon(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(
                    vertical: 16.0,
                    horizontal: 24.0,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                icon: Icon(Icons.edit, color: Colors.white),
                label: Text('Edit', style: TextStyle(color: Colors.white)),
              ),
            ),
            Positioned(
              bottom: 8,
              right: 8,
              child: ElevatedButton.icon(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(
                    vertical: 16.0,
                    horizontal: 24.0,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                icon: Icon(Icons.delete, color: Colors.white),
                label: Text('Delete', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const InfoRow({
    Key? key,
    required this.icon,
    required this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[500], size: 16),
          SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(color: Colors.grey[500], fontSize: 20),
          ),
        ],
      ),
    );
  }
}
