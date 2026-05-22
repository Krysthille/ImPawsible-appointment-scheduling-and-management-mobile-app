-- Create message tracking table to prevent duplicate system messages
CREATE TABLE message_tracking (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  appointment_id UUID REFERENCES grooming_appointments(id) ON DELETE CASCADE,
  message_type TEXT NOT NULL, -- 'reminder' or 'apology'
  sent_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  message_content TEXT NOT NULL
);

-- Create index for efficient lookups
CREATE INDEX idx_message_tracking_appointment_type ON message_tracking(appointment_id, message_type);

-- Add comment to explain the table purpose
COMMENT ON TABLE message_tracking IS 'Tracks system messages (reminders and apologies) to prevent duplicates';
COMMENT ON COLUMN message_tracking.message_type IS 'Type of system message: reminder or apology'; 