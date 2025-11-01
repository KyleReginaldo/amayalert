import 'dart:io';

import 'package:amayalert/core/result/result.dart';
import 'package:amayalert/dependency.dart';
import 'package:amayalert/feature/messages/chat_screen.dart';
import 'package:amayalert/feature/messages/enhanced_message_provider.dart';
import 'package:amayalert/feature/messages/enhanced_message_repository.dart';
import 'package:amayalert/feature/messages/message_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

class FakeProvider extends EnhancedMessageProvider {
  @override
  Future<Result<Message>> sendMessage({
    required String senderId,
    required CreateMessageRequest request,
    XFile? attachmentFile,
    void Function(double progress)? onUploadProgress,
  }) async {
    // simulate progress
    for (var p in [0.1, 0.5, 0.9]) {
      await Future.delayed(const Duration(milliseconds: 10));
      onUploadProgress?.call(p);
    }

    // Simulate server-created message
    final msg = Message(
      id: 9999,
      sender: senderId,
      receiver: request.receiver,
      content: request.content,
      attachmentUrl: attachmentFile != null
          ? 'https://example.com/${attachmentFile.name}'
          : null,
      createdAt: DateTime.now(),
      updatedAt: null,
      seenAt: null,
    );

    return Result.success(msg);
  }
}

class FakeImagePicker extends ImagePicker {
  final XFile file;
  FakeImagePicker(this.file);

  @override
  Future<XFile?> pickImage({
    required ImageSource source,
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
    CameraDevice preferredCameraDevice = CameraDevice.rear,
    bool requestFullMetadata = false,
  }) async {
    return file;
  }
}

void main() {
  testWidgets('upload image optimistic placeholder -> real message', (
    tester,
  ) async {
    // prepare a temp file as fake image
    final tmp = File('${Directory.systemTemp.path}/test_photo.jpg');
    await tmp.writeAsBytes(List<int>.generate(100, (i) => i % 256));

    final fakePicker = FakeImagePicker(XFile(tmp.path));
    final fakeProvider = FakeProvider();
    final repo = EnhancedMessageRepository(
      provider: fakeProvider,
      currentUserIdGetter: () => 'userA',
    );

    // register in service locator (use lazy singleton to allow overriding in test)
    if (sl.isRegistered<EnhancedMessageRepository>()) {
      sl.unregister<EnhancedMessageRepository>();
    }
    sl.registerLazySingleton<EnhancedMessageRepository>(() => repo);

    // Pump only the MessageInput inside a scaffold to avoid ChatScreen init (network/subscriptions)
    final controller = TextEditingController();
    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider.value(
          value: repo,
          child: Scaffold(
            body: MessageInput(
              controller: controller,
              isComposing: false,
              onSend: () {},
              receiverId: 'userB',
              imagePicker: fakePicker,
            ),
          ),
        ),
      ),
    );

    // Let the build settle
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // tap the image button
    final imageButton = find.byIcon(LucideIcons.image);
    expect(imageButton, findsOneWidget);

    // Instead of interacting with modal, call the state's helper to send the file directly
    final state = tester.state(find.byType(MessageInput)) as dynamic;
    await state.pickAndSendFile(XFile(tmp.path));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // progress and server response may take a moment — pump in short intervals and check state
    var attempts = 0;
    while (attempts < 50 &&
        !repo.currentConversationMessages.any((m) => m.id == 9999)) {
      await tester.pump(const Duration(milliseconds: 50));
      attempts++;
    }

    // After send completes, repo should have no placeholders and should contain the real message
    expect(repo.currentConversationMessages.any((m) => m.id == 9999), isTrue);
    expect(repo.uploadPlaceholders.isEmpty, isTrue);

    // cleanup
    await tmp.delete();
  });
}
