import 'package:amayalert/core/theme/theme.dart';
import 'package:amayalert/core/widgets/text/custom_text.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

@RoutePage()
class CreatePostsScreen extends StatefulWidget {
  const CreatePostsScreen({super.key});

  @override
  State<CreatePostsScreen> createState() => _CreatePostsScreenState();
}

class _CreatePostsScreenState extends State<CreatePostsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: CustomText(text: 'Create Posts'),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () {},
            style: ButtonStyle().copyWith(
              foregroundColor: const WidgetStatePropertyAll(AppColors.primary),
            ),
            child: CustomText(text: 'Post', color: AppColors.primary),
          ),
        ],
      ),
      body: Column(
        children: [
          TextField(
            // controller: _controller,
            keyboardType: TextInputType.multiline,
            maxLines: null, // Allows the text field to expand vertically
            minLines: 3, // Sets an initial minimum height
            decoration: const InputDecoration(
              labelText: 'What\'s on your mind?',
              hintText: 'Type your detailed message here...',
              border: InputBorder.none,
              errorBorder: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              focusedErrorBorder: InputBorder.none,
            ),
            onChanged: (text) {
              // Handle text changes if needed
              print('Current text: $text');
            },
          ),
        ],
      ),
    );
  }
}
