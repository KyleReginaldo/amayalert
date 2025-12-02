import 'package:amayalert/core/router/app_route.gr.dart';
import 'package:amayalert/core/widgets/text/custom_text.dart';
import 'package:amayalert/dependency.dart';
import 'package:amayalert/feature/messages/enhanced_message_repository.dart';
import 'package:amayalert/feature/messages/message_model.dart';
import 'package:amayalert/feature/profile/profile_repository.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

@RoutePage()
class NewConversationScreen extends StatefulWidget implements AutoRouteWrapper {
  const NewConversationScreen({super.key});

  @override
  State<NewConversationScreen> createState() => _NewConversationScreenState();

  @override
  Widget wrappedRoute(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: sl<EnhancedMessageRepository>()),
        ChangeNotifierProvider.value(value: sl<ProfileRepository>()),
      ],
      child: this,
    );
  }
}

class _NewConversationScreenState extends State<NewConversationScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUsers();
    });
    _searchController.addListener(_filterUsers);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterUsers);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    final currentUser = Supabase.instance.client.auth.currentUser;
    if (currentUser != null && mounted) {
      await context.read<EnhancedMessageRepository>().loadAvailableUsers(
        currentUserId: currentUser.id,
      );
    }
  }

  void _filterUsers() {
    final query = _searchController.text.toLowerCase();

    // Schedule the repository call to avoid setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final repository = context.read<EnhancedMessageRepository>();
        final currentUser = Supabase.instance.client.auth.currentUser;

        if (currentUser != null) {
          repository.loadAvailableUsers(
            currentUserId: currentUser.id,
            searchQuery: query.isEmpty ? null : query,
          );
        }
      }
    });
  }

  void _startConversation(MessageUser user) {
    // Navigate to chat screen using AutoRoute
    context.router.push(
      ChatRoute(
        otherUserId: user.id,
        otherUserName: user.fullName.isNotEmpty ? user.fullName : user.email,
        otherUserPhone: user.phoneNumber,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const CustomText(text: 'New Conversation'),
        centerTitle: true,
      ),
      body: Consumer<EnhancedMessageRepository>(
        builder: (context, repository, child) {
          final users = repository.availableUsers;
          final isLoading = repository.isLoading;
          final errorMessage = repository.errorMessage;

          return Column(
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
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : errorMessage != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 48,
                              color: Colors.red.shade400,
                            ),
                            const SizedBox(height: 16),
                            CustomText(
                              text: 'Error loading users',
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                            const SizedBox(height: 8),
                            CustomText(
                              text: errorMessage,
                              fontSize: 14,
                              color: Colors.grey.shade600,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                repository.clearError();
                                _loadUsers();
                              },
                              child: const CustomText(text: 'Retry'),
                            ),
                          ],
                        ),
                      )
                    : users.isEmpty
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
                        itemCount: users.length,
                        separatorBuilder: (context, index) =>
                            const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final user = users[index];
                          return UserListItem(
                            user: user,
                            onTap: () => _startConversation(user),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class UserListItem extends StatelessWidget {
  final MessageUser user;
  final VoidCallback onTap;

  const UserListItem({super.key, required this.user, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final name = user.fullName.isNotEmpty ? user.fullName : 'Unknown User';
    final email = user.email;

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.blue.withValues(alpha: 0.1),
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
