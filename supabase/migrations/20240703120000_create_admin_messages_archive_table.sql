-- Migration: Create admin_messages_archive table
CREATE TABLE IF NOT EXISTS admin_messages_archive (
    id uuid PRIMARY KEY,
    user_id uuid REFERENCES users(id),
    appointment_id uuid REFERENCES grooming_appointments(id),
    message text,
    is_read boolean DEFAULT false,
    created_at timestamp with time zone DEFAULT now(),
    is_from_admin boolean DEFAULT false,
    is_archived boolean DEFAULT true,
    archived_at timestamp with time zone DEFAULT now()
); 

ALTER TABLE admin_messages
ADD COLUMN is_archived boolean DEFAULT false;