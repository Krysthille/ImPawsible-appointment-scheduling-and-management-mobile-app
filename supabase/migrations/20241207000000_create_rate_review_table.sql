-- Create rate_review table
CREATE TABLE IF NOT EXISTS rate_review (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
    review_text TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE rate_review ENABLE ROW LEVEL SECURITY;

-- Create policies for rate_review table
CREATE POLICY "Users can insert their own reviews" ON rate_review
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can view all reviews" ON rate_review
    FOR SELECT USING (true);

CREATE POLICY "Users can update their own reviews" ON rate_review
    FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own reviews" ON rate_review
    FOR DELETE USING (auth.uid() = user_id);

-- Create index for better performance
CREATE INDEX IF NOT EXISTS idx_rate_review_user_id ON rate_review(user_id);
CREATE INDEX IF NOT EXISTS idx_rate_review_created_at ON rate_review(created_at); 