-- Create a trigger function that sends status update messages when appointment status changes
CREATE OR REPLACE FUNCTION trigger_status_update_messages()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
  user_record RECORD;
  pet_name TEXT;
  preferred_date DATE;
  preferred_time TIME;
  message_content TEXT;
  formatted_date TEXT;
  formatted_time TEXT;
BEGIN
  -- Only proceed if status has changed
  IF OLD.status IS DISTINCT FROM NEW.status THEN
    -- Get user details
    SELECT id, full_name, email INTO user_record
    FROM users 
    WHERE id = NEW.user_id;
    
    -- Get appointment details
    pet_name := NEW.pet_name;
    preferred_date := NEW.preferred_date;
    preferred_time := NEW.preferred_time;
    
    -- Format date and time
    formatted_date := TO_CHAR(preferred_date, 'Month DD, YYYY');
    formatted_time := TO_CHAR(preferred_time, 'HH:MM AM');
    
    -- Create appropriate message based on new status
    CASE NEW.status
      WHEN 'Approved' THEN
        message_content := 'Your grooming appointment for ' || pet_name || ' on ' || formatted_date || ' at ' || formatted_time || ' has been APPROVED. Please arrive on time to avoid any inconvenience. Thank you!';
      WHEN 'Cancelled' THEN
        message_content := 'Your grooming appointment for ' || pet_name || ' on ' || formatted_date || ' at ' || formatted_time || ' has been CANCELLED. We''re sorry for any inconvenience this may have caused. The time slot is now available for other users to book. If you reconsider, you may be able to book an appointment at a later date. Thank you for understanding!';
      WHEN 'Completed' THEN
        message_content := 'Your grooming appointment for ' || pet_name || ' on ' || formatted_date || ' at ' || formatted_time || ' has been COMPLETED. Thank you for trusting our services! We look forward to seeing you again.';
      ELSE
        -- For other status changes, don't send a message
        RETURN NEW;
    END CASE;
    
    -- Send message to admin_messages table
    INSERT INTO admin_messages (user_id, appointment_id, message, is_from_admin, is_read)
    VALUES (NEW.user_id, NEW.id, message_content, true, false);
    
    -- Send message to user_messages table
    INSERT INTO user_messages (user_id, appointment_id, message, is_from_admin, is_read)
    VALUES (NEW.user_id, NEW.id, message_content, true, false);
    
    RAISE NOTICE 'Status update message sent for appointment %: %', NEW.id, NEW.status;
  END IF;
  
  RETURN NEW;
END;
$$;

-- Create trigger on grooming_appointments table for status changes
CREATE TRIGGER status_update_message_trigger
  AFTER UPDATE ON grooming_appointments
  FOR EACH ROW
  EXECUTE FUNCTION trigger_status_update_messages();

-- Grant execute permission on the function
GRANT EXECUTE ON FUNCTION trigger_status_update_messages() TO authenticated;

