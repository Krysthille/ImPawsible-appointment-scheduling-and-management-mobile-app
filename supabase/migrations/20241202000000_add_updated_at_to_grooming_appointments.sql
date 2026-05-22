-- Add updated_at column to grooming_appointments table
ALTER TABLE grooming_appointments 
ADD COLUMN updated_at TIMESTAMP WITH TIME ZONE DEFAULT now();

-- Create a trigger to automatically update the updated_at column
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create trigger for grooming_appointments table
CREATE TRIGGER update_grooming_appointments_updated_at 
    BEFORE UPDATE ON grooming_appointments 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

-- Add comment to explain the column purpose
COMMENT ON COLUMN grooming_appointments.updated_at IS 'Timestamp when the appointment was last updated'; 