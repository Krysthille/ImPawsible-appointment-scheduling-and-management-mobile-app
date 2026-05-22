CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE TABLE public.shop_products (
    id uuid NOT NULL DEFAULT uuid_generate_v4(),
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    name text NULL,
    picture text NULL,
    description text NULL,
    price numeric NULL,
    local_picture_path text NULL,
    product_type text NULL,
    CONSTRAINT shop_products_pkey PRIMARY KEY (id)
);

ALTER TABLE shop_products
ADD COLUMN stock INT DEFAULT 0 CHECK (stock >= 0);

DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_policies 
        WHERE tablename = 'objects' 
        AND policyname = 'Allow authenticated uploads'
    ) THEN
        CREATE POLICY "Allow authenticated uploads"
        ON storage.objects
        FOR INSERT
        TO authenticated
        WITH CHECK (
            bucket_id = 'product-images' AND
            auth.role() = 'authenticated'
        );
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM pg_policies 
        WHERE tablename = 'objects' 
        AND policyname = 'Allow public downloads'
    ) THEN
        CREATE POLICY "Allow public downloads"
        ON storage.objects
        FOR SELECT
        TO public
        USING (bucket_id = 'product-images');
    END IF;

    IF NOT EXISTS (
        SELECT 1 FROM pg_policies 
        WHERE tablename = 'objects' 
        AND policyname = 'Allow authenticated deletes'
    ) THEN
        CREATE POLICY "Allow authenticated deletes"
        ON storage.objects
        FOR DELETE
        TO authenticated
        USING (
            bucket_id = 'product-images' AND
            auth.role() = 'authenticated'
        );
    END IF;
END $$; 

CREATE TABLE public.shop_cart (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    product_id UUID REFERENCES public.shop_products(id) ON DELETE CASCADE,
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    price NUMERIC(10,2) NOT NULL,
    is_selected BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
    UNIQUE(user_id, product_id)
); 