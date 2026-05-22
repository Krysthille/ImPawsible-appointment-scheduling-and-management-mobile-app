-- Add last_password_reset field to users table
ALTER TABLE users ADD COLUMN last_password_reset TIMESTAMP WITH TIME ZONE;

-- Create function to check if password reset is allowed (30 days restriction)
CREATE OR REPLACE FUNCTION can_reset_password(user_id UUID)
RETURNS BOOLEAN AS $$
DECLARE
    last_reset TIMESTAMP WITH TIME ZONE;
BEGIN
    -- Get the last password reset time for the user
    SELECT last_password_reset INTO last_reset
    FROM users
    WHERE id = user_id;
    
    -- If no previous reset, allow it
    IF last_reset IS NULL THEN
        RETURN TRUE;
    END IF;
    
    -- Check if 30 days have passed since last reset
    RETURN last_reset < NOW() - INTERVAL '30 days';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create function to update last_password_reset timestamp
CREATE OR REPLACE FUNCTION update_password_reset_timestamp(user_id UUID)
RETURNS VOID AS $$
BEGIN
    UPDATE users 
    SET last_password_reset = NOW()
    WHERE id = user_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;