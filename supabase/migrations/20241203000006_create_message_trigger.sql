-- Create a trigger function that calls auto_send_messages when appointments are modified
CREATE OR REPLACE FUNCTION trigger_auto_messages()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
  -- Call the auto message function when appointments are created or updated
  PERFORM auto_send_messages();
  RETURN NEW;
END;
$$;

-- Create trigger on grooming_appointments table
CREATE TRIGGER auto_message_trigger
  AFTER INSERT OR UPDATE ON grooming_appointments
  FOR EACH ROW
  EXECUTE FUNCTION trigger_auto_messages(); 