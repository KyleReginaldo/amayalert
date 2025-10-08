# Enhanced Messaging System

This document describes the enhanced messaging system implementation for the AmayAlert app. The system provides comprehensive messaging features with real-time updates, advanced search, file attachments, and message status tracking.

## Architecture Overview

The enhanced messaging system consists of three main components:

1. **Enhanced Message Models** (`message_model.dart`) - Comprehensive data models with enums and helper classes
2. **Enhanced Message Provider** (`enhanced_message_provider.dart`) - Low-level data operations and Supabase interactions
3. **Enhanced Message Repository** (`enhanced_message_repository.dart`) - High-level business logic and state management

## Key Features

### 📱 **Core Messaging**
- Send and receive text messages
- Real-time message delivery with WebSocket subscriptions
- Message status tracking (sent, delivered, read, edited, failed)
- Message editing and deletion
- Conversation management with user info

### 📎 **File Attachments**
- Support for multiple attachment types (image, video, audio, document)
- File upload to Supabase Storage
- Automatic file URL generation
- Attachment type detection and validation

### 🔍 **Advanced Search**
- Full-text search across message content
- Search within specific conversations or globally
- Highlight search results with context
- Real-time search suggestions

### 📊 **Enhanced Features**
- Typing indicators
- Online status tracking
- Message pagination with infinite scroll
- Unread message counters
- User presence indicators
- Conversation threads with participant info

### 🔄 **Real-time Updates**
- Live message delivery
- Real-time conversation updates
- Typing indicator synchronization
- User status changes
- Message edit/delete notifications

## Database Schema

### Messages Table
```sql
CREATE TABLE messages (
  id SERIAL PRIMARY KEY,
  sender UUID REFERENCES users(id) ON DELETE CASCADE,
  receiver UUID REFERENCES users(id) ON DELETE CASCADE,
  content TEXT NOT NULL,
  attachment_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

### Indexes for Performance
```sql
CREATE INDEX idx_messages_participants ON messages(sender, receiver);
CREATE INDEX idx_messages_timestamp ON messages(created_at);
CREATE INDEX idx_messages_content_search ON messages USING gin(to_tsvector('english', content));
```

## API Reference

### EnhancedMessageRepository Methods

#### Core Operations
- `sendMessage()` - Send a new message with optional attachment
- `loadConversations()` - Get user's conversation list with participant info
- `loadConversation()` - Load messages for a specific conversation with pagination
- `updateMessage()` - Edit an existing message
- `deleteMessage()` - Delete a message

#### Search & Discovery
- `searchMessages()` - Full-text search across messages
- `loadAvailableUsers()` - Get users available for new conversations

#### Real-time Features
- `subscribeToConversation()` - Listen for real-time updates in a conversation
- `subscribeToUserMessages()` - Listen for new messages for a user
- `addTypingIndicator()` - Show typing indicator
- `markMessagesAsRead()` - Mark messages as read

### Message Models

#### Core Models
```dart
class Message {
  final int id;
  final String sender;
  final String receiver;
  final String content;
  final String? attachmentUrl;
  final MessageStatus status;
  final AttachmentType? attachmentType;
  final DateTime createdAt;
  final DateTime? updatedAt;
}

class ChatConversation {
  final String participantId;
  final String participantName;
  final String? participantEmail;
  final String? profilePicture;
  final Message? lastMessage;
  final DateTime? lastActivity;
  final int unreadCount;
  final bool isOnline;
}
```

#### Enums
```dart
enum MessageStatus { sent, delivered, read, edited, failed }
enum AttachmentType { image, video, audio, document }
enum ConversationType { direct, group }
```

## Usage Examples

### Sending a Message
```dart
final repository = context.read<EnhancedMessageRepository>();
final request = CreateMessageRequest(
  receiver: 'user-id',
  content: 'Hello, world!',
);

final result = await repository.sendMessage(
  senderId: currentUserId,
  request: request,
);
```

### Sending a Message with Attachment
```dart
final imageFile = XFile('path/to/image.jpg');
final request = CreateMessageRequest(
  receiver: 'user-id',
  content: 'Check out this photo!',
);

final result = await repository.sendMessage(
  senderId: currentUserId,
  request: request,
  attachmentFile: imageFile,
);
```

### Real-time Subscription
```dart
repository.subscribeToConversation(
  userId1: currentUserId,
  userId2: otherUserId,
);

// The repository will automatically update the UI when new messages arrive
```

### Search Messages
```dart
await repository.searchMessages(
  userId: currentUserId,
  query: 'hello world',
);

// Access results via repository.searchResults
```

## UI Components

### Message Screen
- Displays conversation list with unread counts
- Pull-to-refresh functionality
- Search bar for finding conversations
- Real-time updates for new messages

### Chat Screen  
- Message bubbles with proper alignment
- Typing indicators
- Message status indicators
- Attachment support
- Infinite scroll with pagination

### New Conversation Screen
- User search and discovery
- Real-time filtering
- User status indicators

## State Management

The enhanced messaging system uses Provider for state management:

```dart
// Access the repository in any widget
final repository = context.read<EnhancedMessageRepository>();

// Listen for changes
Consumer<EnhancedMessageRepository>(
  builder: (context, repository, child) {
    return ListView.builder(
      itemCount: repository.conversations.length,
      itemBuilder: (context, index) {
        final conversation = repository.conversations[index];
        return ConversationTile(conversation: conversation);
      },
    );
  },
)
```

## Error Handling

The system provides comprehensive error handling:

```dart
if (repository.errorMessage != null) {
  // Show error UI
  return ErrorWidget(
    message: repository.errorMessage!,
    onRetry: () {
      repository.clearError();
      repository.loadConversations(userId);
    },
  );
}
```

## Performance Optimizations

### Message Pagination
- Loads messages in chunks of 50
- Implements infinite scroll
- Caches loaded messages for performance

### Real-time Subscriptions
- Selective subscriptions to reduce bandwidth
- Automatic reconnection handling
- Efficient state updates

### Search Optimization
- Debounced search input
- Full-text search with PostgreSQL
- Result caching and pagination

## Security Features

- User authentication required for all operations
- Message sender verification
- File upload security with type validation
- SQL injection prevention with parameterized queries

## Future Enhancements

### Planned Features
- Message reactions (emoji)
- Voice messages
- Video calling integration
- Message encryption
- Group messaging
- Message forwarding
- Draft messages
- Message scheduling

### Technical Improvements
- Offline message queueing
- Message compression
- Advanced file handling
- Push notification integration
- Message analytics

## Troubleshooting

### Common Issues

**Messages not appearing in real-time:**
- Check internet connection
- Verify Supabase WebSocket connection
- Restart the subscription

**File uploads failing:**
- Check file size limits
- Verify file type support
- Check Supabase Storage configuration

**Search not working:**
- Verify database search indexes
- Check search query formatting
- Ensure proper text normalization

## Configuration

### Supabase Setup
1. Enable real-time subscriptions in Supabase dashboard
2. Configure Storage bucket for file uploads
3. Set up Row Level Security (RLS) policies
4. Create database indexes for performance

### App Configuration
```dart
// Initialize enhanced repository
sl.registerLazySingleton(() => EnhancedMessageRepository());
```

## Testing

### Unit Tests
- Repository method testing
- Model serialization/deserialization
- Error handling validation

### Integration Tests  
- Real-time subscription testing
- File upload functionality
- Search performance testing

### UI Tests
- Message bubble rendering
- Conversation list updates
- Search interface validation

---

This enhanced messaging system provides a robust foundation for real-time communication in the AmayAlert app, with room for future expansion and customization.