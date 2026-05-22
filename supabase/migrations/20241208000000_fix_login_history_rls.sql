-- Fix RLS policies for login_history table
-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Users can view their own login history" ON public.login_history;
DROP POLICY IF EXISTS "Users can insert their own login history" ON public.login_history;

-- Enable RLS
ALTER TABLE public.login_history ENABLE ROW LEVEL SECURITY;

-- Create proper RLS policies for login_history
CREATE POLICY "Users can view their own login history" ON public.login_history
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own login history" ON public.login_history
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Also allow admins to view all login history (for admin dashboard)
CREATE POLICY "Admins can view all login history" ON public.login_history
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM public.users 
      WHERE users.id = auth.uid() 
      AND (users.role = 'admin' OR users.email LIKE '%@admin%')
    )
  ); 