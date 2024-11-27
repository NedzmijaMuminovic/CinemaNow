import 'dart:convert';

import 'package:cinemanow_desktop/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:cinemanow_desktop/models/user.dart';
import 'package:cinemanow_desktop/providers/user_provider.dart';

class AdministratorsScreen extends StatefulWidget {
  const AdministratorsScreen({Key? key}) : super(key: key);

  @override
  State<AdministratorsScreen> createState() => _AdministratorsScreenState();
}

class _AdministratorsScreenState extends State<AdministratorsScreen> {
  final UserProvider _userProvider = UserProvider();
  late Future<List<User>> _adminsFuture;

  @override
  void initState() {
    super.initState();
    _fetchAdmins();
  }

  void _fetchAdmins() {
    _adminsFuture = _userProvider.getUsers(filter: {'RoleName': 'Admin'}).then(
      (result) {
        result.result.sort((a, b) {
          if (a.id == AuthProvider.userId) return -1;
          if (b.id == AuthProvider.userId) return 1;
          return 0;
        });
        return result.result;
      },
    );
  }

  Future<void> _refreshAdmins() async {
    setState(() {
      _fetchAdmins();
    });
  }

  void _deleteAdmin(int userId) async {
    try {
      await _userProvider.deleteUser(userId);
      _refreshAdmins();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('You have successfully deleted the admin!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete admin.')),
      );
    }
  }

  void _addAdmin() {
    print('Add Admin');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<List<User>>(
          future: _adminsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Failed to load administrators: ${snapshot.error}',
                  style: const TextStyle(color: Colors.red),
                ),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.sentiment_dissatisfied,
                      color: Colors.white70,
                      size: 80,
                    ),
                    SizedBox(height: 24),
                    Text(
                      'No administrators available',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 24,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              );
            }

            final admins = snapshot.data!;
            return RefreshIndicator(
              onRefresh: _refreshAdmins,
              child: ListView.builder(
                itemCount: admins.length,
                itemBuilder: (context, index) {
                  final admin = admins[index];
                  bool isCurrentAdmin = admin.id == AuthProvider.userId;
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    color: Colors.grey[850],
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: isCurrentAdmin
                          ? BorderSide(color: Colors.red, width: 1)
                          : BorderSide.none,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: ListTile(
                        leading: CircleAvatar(
                          radius: 28,
                          backgroundColor: Colors.grey[700],
                          backgroundImage: admin.imageBase64 != null &&
                                  admin.imageBase64!.isNotEmpty
                              ? MemoryImage(base64Decode(admin.imageBase64!))
                              : null,
                          child: admin.imageBase64 == null ||
                                  admin.imageBase64!.isEmpty
                              ? const Icon(
                                  Icons.person,
                                  color: Colors.white,
                                  size: 28,
                                )
                              : null,
                        ),
                        title: Text(
                          '${admin.name} ${admin.surname}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              admin.email!,
                              style: const TextStyle(fontSize: 16),
                            ),
                            Text(
                              '@${admin.username}',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        trailing: AuthProvider.userId != admin.id
                            ? IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                iconSize: 28,
                                onPressed: () async {
                                  final confirmed = await showDialog<bool>(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: const Text(
                                          'Confirm Deletion',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        content: const Text(
                                          'Are you sure you want to delete this admin?',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        backgroundColor: Colors.grey[900],
                                        actions: <Widget>[
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.of(context)
                                                    .pop(false),
                                            child: const Text(
                                              'No',
                                              style:
                                                  TextStyle(color: Colors.red),
                                            ),
                                          ),
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.of(context).pop(true),
                                            child: const Text(
                                              'Yes',
                                              style:
                                                  TextStyle(color: Colors.red),
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  );

                                  if (confirmed == true) {
                                    _deleteAdmin(admin.id!);
                                  }
                                },
                              )
                            : null,
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addAdmin,
        backgroundColor: Colors.grey[850],
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}