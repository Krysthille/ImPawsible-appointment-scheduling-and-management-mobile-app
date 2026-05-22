CREATE TABLE grooming_appointments (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE, -- Assuming a relation to the auth.users table

  -- Pet Information
  pet_name TEXT NOT NULL,
  pet_type TEXT NOT NULL,
  pet_type_other TEXT,
  breed TEXT,
  pet_size TEXT,
  age INT,
  gender TEXT,
  allergies_medical_conditions TEXT,

  -- Grooming Services Details
  service_bath BOOLEAN DEFAULT FALSE,
  service_haircut BOOLEAN DEFAULT FALSE,
  service_nail_trim BOOLEAN DEFAULT FALSE,
  service_ear_cleaning BOOLEAN DEFAULT FALSE,
  special_requests_notes TEXT,
  estimated_duration INT, -- Total duration in minutes

  -- Appointment Details
  preferred_date DATE,
  preferred_time TIME,
  status TEXT DEFAULT 'Pending', -- Add status field with default value 'Pending'

  -- Payment Information
  estimated_cost DECIMAL(10, 2),
  payment_method TEXT,

  -- Consent
  consent_photos BOOLEAN DEFAULT FALSE,

  -- New: Reschedule details
  rescheduled_from_date DATE,
  rescheduled_from_time TIME
); 

ALTER TABLE grooming_appointments
ADD COLUMN haircut_extra_option TEXT;