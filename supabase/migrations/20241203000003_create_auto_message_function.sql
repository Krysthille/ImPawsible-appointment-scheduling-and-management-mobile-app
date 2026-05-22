-- Create a function to automatically send reminder and apology messages
CREATE OR REPLACE FUNCTION auto_send_messages()
RETURNS TABLE(reminders_sent INTEGER, apologies_sent INTEGER)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  appointment_record RECORD;
  user_record RECORD;
  reminder_count INTEGER := 0;
  apology_count INTEGER := 0;
  reminder_message TEXT;
  apology_message TEXT;
  appointment_datetime TIMESTAMP;
  reminder_time TIMESTAMP;
  now_time TIMESTAMP := NOW();
BEGIN
  -- Loop through all pending appointments
  FOR appointment_record IN 
    SELECT id, user_id, pet_name, preferred_date, preferred_time, status
    FROM grooming_appointments 
    WHERE status = 'Pending'
  LOOP
    -- Get user details
    SELECT id, full_name, email INTO user_record
    FROM users 
    WHERE id = appointment_record.user_id;
    
    -- Calculate appointment datetime
    appointment_datetime := appointment_record.preferred_date::date + appointment_record.preferred_time::time;
    reminder_time := appointment_datetime - INTERVAL '24 hours';
    
    -- Check if reminder should be sent (24 hours before appointment)
    IF now_time >= reminder_time AND now_time < appointment_datetime THEN
      -- Check if reminder already sent
      IF NOT EXISTS (
        SELECT 1 FROM message_tracking 
        WHERE appointment_id = appointment_record.id 
        AND message_type = 'reminder'
      ) THEN
        -- Create reminder message
        reminder_message := 'REMINDER: Appointment approaching - Status still PENDING

Pet: ' || appointment_record.pet_name || '
Date: ' || TO_CHAR(appointment_record.preferred_date::date, 'Month DD, YYYY') || '
Time: ' || appointment_record.preferred_time || '
Owner: ' || COALESCE(user_record.full_name, 'Unknown') || '

Please update the appointment status.';
        
        -- Send reminder message to admin_messages
        INSERT INTO admin_messages (user_id, appointment_id, message, is_from_admin, is_read)
        VALUES (appointment_record.user_id, appointment_record.id, reminder_message, false, false);
        
        -- Send reminder message to user_messages
        INSERT INTO user_messages (user_id, appointment_id, message, is_from_admin, is_read)
        VALUES (appointment_record.user_id, appointment_record.id, reminder_message, false, false);
        
        -- Record reminder sent
        INSERT INTO message_tracking (appointment_id, message_type, message_content)
        VALUES (appointment_record.id, 'reminder', reminder_message);
        
        reminder_count := reminder_count + 1;
      END IF;
    END IF;
    
    -- Check if apology should be sent (appointment time has passed)
    IF now_time > appointment_datetime THEN
      -- Check if apology already sent
      IF NOT EXISTS (
        SELECT 1 FROM message_tracking 
        WHERE appointment_id = appointment_record.id 
        AND message_type = 'apology'
      ) THEN
        -- Create apology message
        apology_message := 'We''re sorry! Your grooming appointment status was not updated before the scheduled time. We sincerely apologize for the inconvenience this may have caused. Please feel free to reach out to us or rebook your appointment at your convenience. Thank you for your understanding!';
        
        -- Send apology message to admin_messages
        INSERT INTO admin_messages (user_id, appointment_id, message, is_from_admin, is_read)
        VALUES (appointment_record.user_id, appointment_record.id, apology_message, true, false);
        
        -- Send apology message to user_messages
        INSERT INTO user_messages (user_id, appointment_id, message, is_from_admin, is_read)
        VALUES (appointment_record.user_id, appointment_record.id, apology_message, true, false);
        
        -- Update appointment status to Cancelled
        UPDATE grooming_appointments 
        SET status = 'Cancelled' 
        WHERE id = appointment_record.id;
        
        -- Record apology sent
        INSERT INTO message_tracking (appointment_id, message_type, message_content)
        VALUES (appointment_record.id, 'apology', apology_message);
        
        apology_count := apology_count + 1;
      END IF;
    END IF;
  END LOOP;
  
  RETURN QUERY SELECT reminder_count, apology_count;
END;
$$;

-- Grant execute permission to authenticated users
GRANT EXECUTE ON FUNCTION auto_send_messages() TO authenticated; 