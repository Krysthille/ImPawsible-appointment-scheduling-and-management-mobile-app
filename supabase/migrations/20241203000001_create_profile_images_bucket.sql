-- Create profile-images storage bucket
INSERT INTO storage.buckets (id, name, public) 
VALUES ('profile-images', 'profile-images', true)
ON CONFLICT (id) DO NOTHING;

-- Set up storage policies for profile-images bucket
CREATE POLICY "Public Access" ON storage.objects FOR SELECT USING (bucket_id = 'profile-images');
CREATE POLICY "Authenticated users can upload profile images" ON storage.objects FOR INSERT WITH CHECK (bucket_id = 'profile-images' AND auth.role() = 'authenticated');
CREATE POLICY "Users can update their own profile images" ON storage.objects FOR UPDATE USING (bucket_id = 'profile-images' AND auth.uid()::text = (storage.foldername(name))[1]);
CREATE POLICY "Users can delete their own profile images" ON storage.objects FOR DELETE USING (bucket_id = 'profile-images' AND auth.uid()::text = (storage.foldername(name))[1]); 