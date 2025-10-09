-- Database Migration for Message Seen Functionality
-- Run this SQL command in your Supabase SQL editor to add the seen_at column

-- Add seen_at column to messages table
ALTER TABLE messages ADD COLUMN IF NOT EXISTS seen_at TIMESTAMP WITH TIME ZONE;

-- Optional: Add an index for better performance on seen_at queries
CREATE INDEX IF NOT EXISTS idx_messages_seen_at ON messages(receiver, sender, seen_at);

-- Optional: Update existing messages to be marked as seen (if desired)
-- Uncomment the line below if you want all existing messages to be marked as seen
-- UPDATE messages SET seen_at = created_at WHERE seen_at IS NULL;

-- Verify the column was added
SELECT column_name, data_type, is_nullable 
FROM information_schema.columns 
WHERE table_name = 'messages' 
ORDER BY ordinal_position;