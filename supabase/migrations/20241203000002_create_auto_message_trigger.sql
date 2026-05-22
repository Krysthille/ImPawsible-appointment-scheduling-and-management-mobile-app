-- Create a function to call the auto-message-sender Edge Function
CREATE OR REPLACE FUNCTION call_auto_message_sender()
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  -- This can be triggered manually or via an external cron job hitting an Edge Function
  PERFORM net.http_post(
    url := 'https://your-project-ref.supabase.co/functions/v1/auto-message-sender',
    headers := '{"Content-Type": "application/json", "Authorization": "Bearer ' || current_setting('request.header.apikey') || '"}',
    body := '{}'
  );
END;
$$;

-- Optional: Trigger function for when appointment status changes
CREATE OR REPLACE FUNCTION trigger_auto_message_sender()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
  PERFORM call_auto_message_sender();
  RETURN NEW;
END;
$$;

-- Trigger on grooming_appointments table
CREATE TRIGGER auto_message_sender_trigger
AFTER INSERT OR UPDATE ON grooming_appointments
FOR EACH ROW
EXECUTE FUNCTION trigger_auto_message_sender();
