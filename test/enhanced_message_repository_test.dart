import 'package:amayalert/core/result/result.dart';
import 'package:amayalert/feature/messages/enhanced_message_provider.dart';
import 'package:amayalert/feature/messages/enhanced_message_repository.dart';
import 'package:amayalert/feature/messages/message_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';

class FakeProvider extends EnhancedMessageProvider {
  @override
  Future<Result<Message>> sendMessage({
    required String senderId,
    required CreateMessageRequest request,
    XFile? attachmentFile,
    void Function(double progress)? onUploadProgress,
  }) async {
    // simulate upload progress
    for (var p in [0.1, 0.5, 0.9]) {
      await Future.delayed(Duration(milliseconds: 1));
      onUploadProgress?.call(p);
    }

    // return a fake message from server
    final msg = Message(
      id: DateTime.now().millisecondsSinceEpoch,
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

void main() {
  test('optimistic placeholder lifecycle', () async {
    final repo = EnhancedMessageRepository(
      provider: FakeProvider(),
      currentUserIdGetter: () => 'userA',
    );

    final tempId = repo.createUploadPlaceholder(
      localPath: '/tmp/photo.jpg',
      senderId: 'userA',
      receiverId: 'userB',
    );

    expect(repo.uploadPlaceholders.containsKey(tempId), isTrue);

    final fakeMessage = Message(
      id: 9999,
      sender: 'userA',
      receiver: 'userB',
      content: '',
      attachmentUrl: 'https://example.com/photo.jpg',
      createdAt: DateTime.now(),
      updatedAt: null,
      seenAt: null,
    );

    repo.replacePlaceholderWithReal(tempId: tempId, realMessage: fakeMessage);

    expect(repo.uploadPlaceholders.containsKey(tempId), isFalse);
    expect(repo.currentConversationMessages.any((m) => m.id == 9999), isTrue);

    // simulate failure
    final temp2 = repo.createUploadPlaceholder(
      localPath: '/tmp/photo2.jpg',
      senderId: 'userA',
      receiverId: 'userB',
    );
    repo.markPlaceholderFailed(temp2);
    expect(repo.failedUploads.contains(temp2), isTrue);
  });
}
