-- Enable UUID extension if not already enabled
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Create admin_messages table
CREATE TABLE public.admin_messages (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
    appointment_id UUID REFERENCES public.grooming_appointments(id) ON DELETE CASCADE,
    message TEXT NOT NULL,
    is_read BOOLEAN DEFAULT FALSE,
    is_from_admin BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- Index for faster lookups by user and appointment
CREATE INDEX idx_admin_messages_user_id ON public.admin_messages(user_id);
CREATE INDEX idx_admin_messages_appointment_id ON public.admin_messages(appointment_id);

-- Policy: Allow service role to manage all messages
CREATE POLICY "Service role can manage all admin messages"
    ON public.admin_messages
    FOR ALL
    USING (auth.role() = 'service_role'); 


    
-- Allow all users to select for testing (tighten for production)
create policy "Allow select for all" on public.admin_messages
for select using (true);

create policy "Service role can select" on public.admin_messages
for select using (auth.role() = 'service_role');