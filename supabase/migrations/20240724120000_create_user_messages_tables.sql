-- Create user_messages table with the same schema as admin_messages
CREATE TABLE IF NOT EXISTS user_messages (LIKE admin_messages INCLUDING ALL);

-- Copy all data from admin_messages to user_messages
INSERT INTO user_messages SELECT * FROM admin_messages;

-- Create user_messages_archive table with the same schema as admin_messages_archive
CREATE TABLE IF NOT EXISTS user_messages_archive (LIKE admin_messages_archive INCLUDING ALL);

-- Copy all data from admin_messages_archive to user_messages_archive
INSERT INTO user_messages_archive SELECT * FROM admin_messages_archive;

-- Create a view for user_messages
CREATE OR REPLACE VIEW user_messages_view AS SELECT * FROM user_messages;

-- Create a view for user_messages_archive
CREATE OR REPLACE VIEW user_messages_archive_view AS SELECT * FROM user_messages_archive; 


DROP VIEW IF EXISTS user_messages_archive_view;