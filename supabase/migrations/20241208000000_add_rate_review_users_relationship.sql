-- Add foreign key relationship between rate_review and users table
-- First, ensure the users table exists and has the correct structure
DO $$ 
BEGIN
    -- Check if users table exists
    IF EXISTS (SELECT FROM information_schema.tables WHERE table_schema = 'public' AND table_name = 'users') THEN
        -- Add foreign key constraint if it doesn't exist
        IF NOT EXISTS (
            SELECT 1 FROM information_schema.table_constraints 
            WHERE constraint_name = 'rate_review_user_id_fkey_public'
        ) THEN
            ALTER TABLE rate_review 
            ADD CONSTRAINT rate_review_user_id_fkey_public 
            FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;
        END IF;
    END IF;
END $$; 