-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Create users table
CREATE TABLE users (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    full_name TEXT NOT NULL,
    email TEXT UNIQUE NOT NULL,
    contact_number TEXT NOT NULL,
    role TEXT NOT NULL DEFAULT 'user',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- Create index on email for faster lookups
CREATE INDEX users_email_idx ON users(email);

-- Enable Row Level Security
ALTER TABLE users ENABLE ROW LEVEL SECURITY;

-- Create a function to check if a user exists in auth.users
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.users (id, full_name, email, contact_number, role)
    VALUES (
        NEW.id,
        NEW.raw_user_meta_data->>'full_name',
        NEW.email,
        NEW.raw_user_meta_data->>'contact_number',
        COALESCE(NEW.raw_user_meta_data->>'role', 'user')
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create a trigger to automatically create user profile
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_new_user();

-- Policy: Allow users to view their own data
CREATE POLICY "Users can view own data" ON users
    FOR SELECT
    USING (auth.uid() = id);

-- Policy: Allow users to update their own data
CREATE POLICY "Users can update own data" ON users
    FOR UPDATE
    USING (auth.uid() = id);

-- Policy: Allow inserts during signup
CREATE POLICY "Enable insert for new users" ON users
    FOR INSERT
    WITH CHECK (auth.uid() = id);

-- Policy: Allow service_role to manage all data
CREATE POLICY "Service role can manage all users" ON users
    FOR ALL
    USING (auth.role() = 'service_role');

-- Function to automatically update `updated_at` timestamp
CREATE OR REPLACE FUNCTION handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = TIMEZONE('utc'::text, NOW());
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to call handle_updated_at before each update
DROP TRIGGER IF EXISTS set_updated_at ON users;
CREATE TRIGGER set_updated_at
    BEFORE UPDATE ON users
    FOR EACH ROW
    EXECUTE FUNCTION handle_updated_at();

-- Create function to handle user deletion
CREATE OR REPLACE FUNCTION handle_user_deletion()
RETURNS TRIGGER AS $$
BEGIN
    -- Delete user's profile
    DELETE FROM users WHERE id = OLD.id;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

-- Drop existing trigger if it exists
DROP TRIGGER IF EXISTS on_auth_user_deleted ON auth.users;

-- Create trigger for user deletion
CREATE TRIGGER on_auth_user_deleted
    AFTER DELETE ON auth.users
    FOR EACH ROW
    EXECUTE FUNCTION handle_user_deletion();

-- Update user role to admin
UPDATE users SET role = 'admin' WHERE email = 'krysthilleannetambis@gmail.com';


ALTER TABLE users ENABLE ROW LEVEL SECURITY;

-- Allow authenticated users to insert their own row
CREATE POLICY "Allow self insert" ON users
FOR INSERT
WITH CHECK (auth.uid() = id);

-- Add profile_image_url column
ALTER TABLE users ADD COLUMN profile_image_url TEXT;

DROP POLICY IF EXISTS "Allow self insert" ON users;

CREATE POLICY "Public can insert new users" ON users
FOR INSERT
TO public
WITH CHECK (true);