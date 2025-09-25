import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TestUsersWidget extends StatelessWidget {
  const TestUsersWidget({super.key});

  Future<void> _createTestUsers() async {
    try {
      final supabase = Supabase.instance.client;

      // Create some test users if they don't exist
      final testUsers = [
        {
          'id': 'test-user-1',
          'full_name': 'John Doe',
          'email': 'john.doe@example.com',
        },
        {
          'id': 'test-user-2',
          'full_name': 'Jane Smith',
          'email': 'jane.smith@example.com',
        },
        {
          'id': 'test-user-3',
          'full_name': 'Bob Johnson',
          'email': 'bob.johnson@example.com',
        },
      ];

      for (final user in testUsers) {
        // Check if user exists
        final existing = await supabase
            .from('users')
            .select('id')
            .eq('id', user['id']!)
            .maybeSingle();

        if (existing == null) {
          // Insert test user
          await supabase.from('users').insert(user);
          print('Created test user: ${user['full_name']}');
        }
      }
    } catch (e) {
      print('Error creating test users: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: _createTestUsers,
      child: const Text('Create Test Users'),
    );
  }
}
