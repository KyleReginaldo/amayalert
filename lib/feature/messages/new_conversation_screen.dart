import 'package:amayalert/core/router/app_route.gr.dart';
import 'package:amayalert/core/widgets/text/custom_text.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

@RoutePage()
class NewConversationScreen extends StatefulWidget {
  const NewConversationScreen({super.key});

  @override
  State<NewConversationScreen> createState() => _NewConversationScreenState();
}

class _NewConversationScreenState extends State<NewConversationScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _users = [];
  List<Map<String, dynamic>> _filteredUsers = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUsers();
    _searchController.addListener(_filterUsers);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterUsers);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final currentUser = Supabase.instance.client.auth.currentUser;
      if (currentUser == null) return;

      // Get all users except current user
      final response = await Supabase.instance.client
          .from('users')
          .select('id, full_name, email')
          .neq('id', currentUser.id)
          .limit(50);

      setState(() {
        _users = List<Map<String, dynamic>>.from(response);
        _filteredUsers = _users;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading users: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filterUsers() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredUsers = _users.where((user) {
        final name = user['full_name']?.toString().toLowerCase() ?? '';
        final email = user['email']?.toString().toLowerCase() ?? '';
        return name.contains(query) || email.contains(query);
      }).toList();
    });
  }

  void _startConversation(Map<String, dynamic> user) {
    final userId = user['id'] as String;
    final userName = user['full_name'] as String? ?? user['email'] as String;

    // Navigate to chat screen using AutoRoute
    context.router.push(
      ChatRoute(otherUserId: userId, otherUserName: userName),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const CustomText(text: 'New Conversation'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search users...',
                prefixIcon: const Icon(LucideIcons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredUsers.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          LucideIcons.users,
                          size: 48,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        CustomText(
                          text: _searchController.text.isNotEmpty
                              ? 'No users found'
                              : 'No users available',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        const SizedBox(height: 8),
                        CustomText(
                          text: _searchController.text.isNotEmpty
                              ? 'Try a different search term'
                              : 'Check back later for users to message',
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    itemCount: _filteredUsers.length,
                    separatorBuilder: (context, index) =>
                        const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final user = _filteredUsers[index];
                      return UserListItem(
                        user: user,
                        onTap: () => _startConversation(user),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class UserListItem extends StatelessWidget {
  final Map<String, dynamic> user;
  final VoidCallback onTap;

  const UserListItem({super.key, required this.user, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final name = user['full_name'] as String? ?? 'Unknown User';
    final email = user['email'] as String? ?? '';

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.blue.withOpacity(0.1),
        child: Icon(LucideIcons.user, color: Colors.blue, size: 20),
      ),
      title: CustomText(text: name, fontWeight: FontWeight.w600, fontSize: 16),
      subtitle: email.isNotEmpty
          ? CustomText(text: email, fontSize: 14, color: Colors.grey.shade600)
          : null,
      trailing: Icon(LucideIcons.messageCircle, color: Colors.blue, size: 20),
      onTap: onTap,
    );
  }
}
