// features/agent/dashboard/agent_dashboard.dart
import 'package:flutter/material.dart';

class AgentDashboard extends StatefulWidget {
  const AgentDashboard({super.key});

  @override
  _AgentDashboardState createState() => _AgentDashboardState();
}

class _AgentDashboardState extends State<AgentDashboard> {
  int _currentIndex = 0;

  // Define all the screens here
  final List<Widget> _screens = [
    DashboardHome(),
    BookingsScreen(),
    VehiclesScreen(),
    BranchesScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text("Mo_Rental Agent", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: Icon(Icons.notifications), 
            onPressed: () {
              // Handle notifications
            },
          ),
        ],
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: (index) => setState(() => _currentIndex = index),
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.book_online), label: 'Bookings'),
          BottomNavigationBarItem(icon: Icon(Icons.directions_car), label: 'Vehicles'),
          BottomNavigationBarItem(icon: Icon(Icons.business), label: 'Branches'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

// Dashboard Home Screen
class DashboardHome extends StatelessWidget {
  const DashboardHome({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Today's Overview", 
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue[800])),
          SizedBox(height: 16),
          
          // Stats Grid
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            childAspectRatio: 1.5,
            children: [
              _buildStatCard("Pickups Today", "12", Icons.arrow_circle_up, Colors.green),
              _buildStatCard("Returns Today", "8", Icons.arrow_circle_down, Colors.orange),
              _buildStatCard("Active Rentals", "24", Icons.directions_car, Colors.blue),
              _buildStatCard("Available Cars", "15", Icons.local_parking, Colors.purple),
            ],
          ),
          
          SizedBox(height: 24),
          Text("Quick Actions", 
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue[800])),
          SizedBox(height: 16),
          
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildActionButton("New Booking", Icons.add, Colors.blue, () {
                // Navigate to create booking
              }),
              _buildActionButton("Check-in", Icons.login, Colors.green, () {
                // Navigate to check-in
              }),
              _buildActionButton("Check-out", Icons.logout, Colors.orange, () {
                // Navigate to check-out
              }),
              _buildActionButton("Manage Fleet", Icons.directions_car, Colors.purple, () {
                // Navigate to fleet management
              }),
            ],
          ),

          SizedBox(height: 24),
          Text("Recent Activity", 
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue[800])),
          SizedBox(height: 16),
          _buildRecentActivity(),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 30),
            SizedBox(height: 8),
            Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text(title, style: TextStyle(color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(String text, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 100,
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 30),
            SizedBox(height: 8),
            Text(text, textAlign: TextAlign.center, style: TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity() {
    final activities = [
      {'time': '10:30 AM', 'action': 'Vehicle checked out', 'details': 'Toyota Corolla - John Doe'},
      {'time': '09:15 AM', 'action': 'New booking', 'details': 'Honda CR-V - Jane Smith'},
      {'time': '08:45 AM', 'action': 'Vehicle returned', 'details': 'Nissan X-Trail - Mike Johnson'},
    ];

    return Column(
      children: activities.map((activity) => Card(
        margin: EdgeInsets.only(bottom: 8),
        child: ListTile(
          leading: Icon(Icons.history, color: Colors.blue),
          title: Text(activity['action']!),
          subtitle: Text(activity['details']!),
          trailing: Text(activity['time']!, style: TextStyle(color: Colors.grey)),
        ),
      )).toList(),
    );
  }
}

// Bookings Screen
class BookingsScreen extends StatelessWidget {
  const BookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            _buildSearchBar(),
            SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: 5, // Mock data
                itemBuilder: (context, index) => _buildBookingItem(index),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Create new booking
        },
        backgroundColor: Colors.blue,
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Search bookings...',
        prefixIcon: Icon(Icons.search, color: Colors.blue),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _buildBookingItem(int index) {
    final bookings = [
      {'id': 'BK001', 'customer': 'John Doe', 'vehicle': 'Toyota Corolla', 'status': 'Active'},
      {'id': 'BK002', 'customer': 'Jane Smith', 'vehicle': 'Honda CR-V', 'status': 'Upcoming'},
      {'id': 'BK003', 'customer': 'Mike Johnson', 'vehicle': 'Nissan X-Trail', 'status': 'Completed'},
      {'id': 'BK004', 'customer': 'Sarah Wilson', 'vehicle': 'Mazda CX-5', 'status': 'Active'},
      {'id': 'BK005', 'customer': 'David Brown', 'vehicle': 'Toyota RAV4', 'status': 'Cancelled'},
    ];

    final booking = bookings[index];
    Color statusColor = _getStatusColor(booking['status']!);

    return Card(
      margin: EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(Icons.book_online, color: Colors.blue),
        title: Text('Booking ${booking['id']}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Customer: ${booking['customer']}'),
            Text('Vehicle: ${booking['vehicle']}'),
          ],
        ),
        trailing: Container(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: statusColor),
          ),
          child: Text(
            booking['status']!,
            style: TextStyle(color: statusColor, fontSize: 12),
          ),
        ),
        onTap: () {
          // Navigate to booking details
        },
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active': return Colors.green;
      case 'upcoming': return Colors.orange;
      case 'completed': return Colors.blue;
      case 'cancelled': return Colors.red;
      default: return Colors.grey;
    }
  }
}

// Vehicles Screen
class VehiclesScreen extends StatelessWidget {
  const VehiclesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            _buildVehicleFilters(),
            SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: 6, // Mock data
                itemBuilder: (context, index) => _buildVehicleItem(index),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVehicleFilters() {
    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<String>(
            value: 'All',
            items: ['All', 'Available', 'Rented', 'Maintenance'].map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (value) {},
            decoration: InputDecoration(
              labelText: 'Filter by Status',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        SizedBox(width: 8),
        Expanded(
          child: DropdownButtonFormField<String>(
            value: 'All Branches',
            items: ['All Branches', 'Harare', 'Bulawayo', 'Mutare', 'Bindura'].map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (value) {},
            decoration: InputDecoration(
              labelText: 'Filter by Branch',
              border: OutlineInputBorder(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVehicleItem(int index) {
    final vehicles = [
      {'make': 'Toyota', 'model': 'Corolla', 'plate': 'ABC123', 'status': 'Available', 'branch': 'Harare'},
      {'make': 'Honda', 'model': 'CR-V', 'plate': 'DEF456', 'status': 'Rented', 'branch': 'Bulawayo'},
      {'make': 'Nissan', 'model': 'X-Trail', 'plate': 'GHI789', 'status': 'Available', 'branch': 'Mutare'},
      {'make': 'Mazda', 'model': 'CX-5', 'plate': 'JKL012', 'status': 'Maintenance', 'branch': 'Harare'},
      {'make': 'Toyota', 'model': 'RAV4', 'plate': 'MNO345', 'status': 'Available', 'branch': 'Bindura'},
      {'make': 'Honda', 'model': 'Civic', 'plate': 'PQR678', 'status': 'Rented', 'branch': 'Harare'},
    ];

    final vehicle = vehicles[index];
    Color statusColor = _getVehicleStatusColor(vehicle['status']!);

    return Card(
      margin: EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(Icons.directions_car, color: Colors.blue, size: 40),
        title: Text('${vehicle['make']} ${vehicle['model']}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Plate: ${vehicle['plate']}'),
            Text('Branch: ${vehicle['branch']}'),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: statusColor),
              ),
              child: Text(
                vehicle['status']!,
                style: TextStyle(color: statusColor, fontSize: 12),
              ),
            ),
          ],
        ),
        onTap: () {
          // Navigate to vehicle details
        },
      ),
    );
  }

  Color _getVehicleStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'available': return Colors.green;
      case 'rented': return Colors.orange;
      case 'maintenance': return Colors.red;
      default: return Colors.grey;
    }
  }
}

// Branches Screen
class BranchesScreen extends StatelessWidget {
  const BranchesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            _buildBranchStats(),
            SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: 4, // Mock data for Zimbabwe branches
                itemBuilder: (context, index) => _buildBranchItem(index),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBranchStats() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem('4', 'Total Branches'),
            _buildStatItem('32', 'Total Vehicles'),
            _buildStatItem('24', 'Active Rentals'),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue)),
        Text(label, style: TextStyle(color: Colors.grey)),
      ],
    );
  }

  Widget _buildBranchItem(int index) {
    final branches = [
      {
        'name': 'Harare Central',
        'location': '123 First Street, Harare',
        'vehicles': '12 vehicles',
        'contact': '+263 77 123 4567'
      },
      {
        'name': 'Bulawayo Main',
        'location': '456 Main Street, Bulawayo',
        'vehicles': '8 vehicles',
        'contact': '+263 71 234 5678'
      },
      {
        'name': 'Mutare Branch',
        'location': '789 Third Avenue, Mutare',
        'vehicles': '6 vehicles',
        'contact': '+263 73 345 6789'
      },
      {
        'name': 'Bindura Office',
        'location': '321 Central Road, Bindura',
        'vehicles': '6 vehicles',
        'contact': '+263 78 456 7890'
      },
    ];

    final branch = branches[index];

    return Card(
      margin: EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(Icons.business, color: Colors.blue, size: 40),
        title: Text(branch['name']!, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(branch['location']!),
            Text(branch['vehicles']!),
            Text('Contact: ${branch['contact']}'),
          ],
        ),
        trailing: Icon(Icons.arrow_forward_ios, color: Colors.blue),
        onTap: () {
          // Navigate to branch details
        },
      ),
    );
  }
}

// Profile Screen
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            _buildProfileHeader(),
            SizedBox(height: 24),
            _buildMenuItems(),
            SizedBox(height: 24),
            _buildLogoutButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: Colors.blue,
              child: Icon(Icons.person, color: Colors.white, size: 40),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('John Doe', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  Text('Senior Rental Agent', style: TextStyle(color: Colors.grey)),
                  SizedBox(height: 4),
                  Text('Harare Central Branch', style: TextStyle(color: Colors.blue)),
                  Text('john.doe@morental.co.zw', style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItems() {
    final menuItems = [
      {'icon': Icons.edit, 'title': 'Edit Profile', 'color': Colors.blue},
      {'icon': Icons.settings, 'title': 'Settings', 'color': Colors.green},
      {'icon': Icons.history, 'title': 'Activity Log', 'color': Colors.orange},
      {'icon': Icons.help, 'title': 'Help & Support', 'color': Colors.purple},
      {'icon': Icons.security, 'title': 'Privacy Policy', 'color': Colors.red},
    ];

    return Column(
      children: menuItems.map((item) => Card(
        margin: EdgeInsets.only(bottom: 8),
        child: ListTile(
          leading: Icon(item['icon'] as IconData, color: item['color'] as Color),
          title: Text(item['title'] as String),
          trailing: Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            // Handle menu item tap
          },
        ),
      )).toList(),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          _showLogoutConfirmation(context);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 12),
        ),
        child: Text('Logout'),
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Logout'),
          content: Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Implement logout logic
                Navigator.pushReplacementNamed(context, '/agent-auth');
              },
              child: Text('Logout', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}