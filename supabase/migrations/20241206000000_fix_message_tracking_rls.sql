-- Fix RLS policies for message_tracking table
-- Enable RLS on message_tracking table
ALTER TABLE message_tracking ENABLE ROW LEVEL SECURITY;

-- Create policy to allow authenticated users to insert message tracking records
CREATE POLICY "Allow authenticated users to insert message tracking" ON message_tracking
  FOR INSERT
  TO authenticated
  WITH CHECK (true);

-- Create policy to allow authenticated users to select message tracking records
CREATE POLICY "Allow authenticated users to select message tracking" ON message_tracking
  FOR SELECT
  TO authenticated
  USING (true);

-- Create policy to allow authenticated users to update message tracking records
CREATE POLICY "Allow authenticated users to update message tracking" ON message_tracking
  FOR UPDATE
  TO authenticated
  USING (true)
  WITH CHECK (true);

-- Create policy to allow authenticated users to delete message tracking records
CREATE POLICY "Allow authenticated users to delete message tracking" ON message_tracking
  FOR DELETE
  TO authenticated
  USING (true);

-- Also ensure user_messages table has proper RLS policies
ALTER TABLE user_messages ENABLE ROW LEVEL SECURITY;

-- Create policy to allow authenticated users to insert user messages
CREATE POLICY "Allow authenticated users to insert user messages" ON user_messages
  FOR INSERT
  TO authenticated
  WITH CHECK (true);

-- Create policy to allow authenticated users to select user messages
CREATE POLICY "Allow authenticated users to select user messages" ON user_messages
  FOR SELECT
  TO authenticated
  USING (true);

-- Create policy to allow authenticated users to update user messages
CREATE POLICY "Allow authenticated users to update user messages" ON user_messages
  FOR UPDATE
  TO authenticated
  USING (true)
  WITH CHECK (true);

-- Create policy to allow authenticated users to delete user messages
CREATE POLICY "Allow authenticated users to delete user messages" ON user_messages
  FOR DELETE
  TO authenticated
  USING (true);

-- Also ensure admin_messages table has proper RLS policies for authenticated users
-- Create policy to allow authenticated users to insert admin messages
CREATE POLICY "Allow authenticated users to insert admin messages" ON admin_messages
  FOR INSERT
  TO authenticated
  WITH CHECK (true);

-- Create policy to allow authenticated users to update admin messages
CREATE POLICY "Allow authenticated users to update admin messages" ON admin_messages
  FOR UPDATE
  TO authenticated
  USING (true)
  WITH CHECK (true);

-- Create policy to allow authenticated users to delete admin messages
CREATE POLICY "Allow authenticated users to delete admin messages" ON admin_messages
  FOR DELETE
  TO authenticated
  USING (true); 