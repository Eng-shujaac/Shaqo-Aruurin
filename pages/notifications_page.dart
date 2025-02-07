import 'package:dulimad_diyarid/helpers/database_helper.dart';
import 'package:dulimad_diyarid/models/user.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';


class NotificationsPage extends StatelessWidget {
  final User user;

  const NotificationsPage({super.key, required this.user});

  Future<List<Map<String, dynamic>>> _getNotifications() async {
    final dbHelper = DatabaseHelper();
    final notifications = await dbHelper.getNotifications(user.id);
    return notifications;
  }

  Future<void> _approveTicket(String ticketId) async {
    await DatabaseHelper().updateTicketStatus(ticketId, 'approved');
    // Show success message
    ScaffoldMessenger.of(context as BuildContext).showSnackBar(
      SnackBar(content: Text('Ticket Approved!')),
    );
  }

  Future<void> _rejectTicket(String ticketId) async {
    await DatabaseHelper().updateTicketStatus(ticketId, 'rejected');
    // Show success message
    ScaffoldMessenger.of(context as BuildContext).showSnackBar(
      SnackBar(content: Text('Ticket Rejected!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Notifications',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _getNotifications(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                      child: Text('No notifications available.'));
                }

                final notifications = snapshot.data!;

                return ListView.builder(
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    final notification = notifications[index];

                    // Check if the logged-in user is an admin and if the notification is for ticket approval
                    final isTicketApproval =
                        notification['title'] == 'New Ticket Booking';
                    return _buildNotificationCard(
                      notification['title'],
                      notification['message'],
                      notification['createdAt'],
                      Icons.notifications,
                      isTicketApproval
                          ? () => _showAdminActions(context, notification['id'])
                          : null,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(
    String title,
    String message,
    String time,
    IconData icon,
    VoidCallback? onAdminAction,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue.shade100,
          child: Icon(icon, color: Colors.blue),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(message),
            const SizedBox(height: 4),
            Text(
              time,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
              ),
            ),
          ],
        ),
        isThreeLine: true,
        trailing: user.isAdmin == 1 && onAdminAction != null
            ? IconButton(
                icon: Icon(Icons.more_vert),
                onPressed: onAdminAction,
              )
            : null,
      ),
    );
  }

  void _showAdminActions(BuildContext context, String ticketId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Admin Actions'),
          content: Text('What do you want to do with this ticket?'),
          actions: [
            TextButton(
              onPressed: () {
                _approveTicket(ticketId);
                Navigator.of(context).pop();
              },
              child: Text('Approve'),
            ),
            TextButton(
              onPressed: () {
                _rejectTicket(ticketId);
                Navigator.of(context).pop();
              },
              child: Text('Reject'),
            ),
          ],
        );
      },
    );
  }
}
