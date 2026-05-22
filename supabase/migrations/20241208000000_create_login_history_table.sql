-- Create login_history table to track admin login activity
CREATE TABLE IF NOT EXISTS public.login_history (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    admin_name TEXT NOT NULL,
    login_date DATE NOT NULL,
    login_time TIME NOT NULL,
    timestamp TIMESTAMPTZ DEFAULT NOW(),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE public.login_history ENABLE ROW LEVEL SECURITY;

-- Create RLS policies
CREATE POLICY "Users can view their own login history" ON public.login_history
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own login history" ON public.login_history
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Create index for better performance
CREATE INDEX IF NOT EXISTS idx_login_history_user_id ON public.login_history(user_id);
CREATE INDEX IF NOT EXISTS idx_login_history_timestamp ON public.login_history(timestamp);

-- Create function to automatically log admin logins
CREATE OR REPLACE FUNCTION log_admin_login()
RETURNS TRIGGER AS $$
BEGIN
    -- Only log if user has admin role or is in users table
    IF EXISTS (
        SELECT 1 FROM public.users 
        WHERE id = NEW.id 
        AND (role = 'admin' OR email LIKE '%@admin%')
    ) THEN
        INSERT INTO public.login_history (user_id, admin_name, login_date, login_time)
        SELECT 
            NEW.id,
            COALESCE(u.full_name, 'Admin User'),
            CURRENT_DATE,
            CURRENT_TIME
        FROM public.users u
        WHERE u.id = NEW.id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create trigger to automatically log logins
DROP TRIGGER IF EXISTS trigger_log_admin_login ON auth.users;
CREATE TRIGGER trigger_log_admin_login
    AFTER INSERT ON auth.users
    FOR EACH ROW
    EXECUTE FUNCTION log_admin_login(); 