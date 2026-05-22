-- Enable UUID extension if not already enabled
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Create shop_cart table
CREATE TABLE public.shop_cart (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    product_id UUID REFERENCES public.shop_products(id) ON DELETE CASCADE,
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    is_selected BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
    UNIQUE(user_id, product_id)
);

-- Create indexes for better query performance
CREATE INDEX idx_shop_cart_user_id ON public.shop_cart(user_id);
CREATE INDEX idx_shop_cart_product_id ON public.shop_cart(product_id);

-- Create a function to update the updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = TIMEZONE('utc'::text, NOW());
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create a trigger to automatically update the updated_at column
CREATE TRIGGER update_shop_cart_updated_at
    BEFORE UPDATE ON public.shop_cart
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Add RLS (Row Level Security) policies
ALTER TABLE public.shop_cart ENABLE ROW LEVEL SECURITY;

-- Policy to allow users to view their own cart items
CREATE POLICY "Users can view their own cart items"
    ON public.shop_cart
    FOR SELECT
    USING (auth.uid() = user_id);

-- Policy to allow users to insert their own cart items
CREATE POLICY "Users can insert their own cart items"
    ON public.shop_cart
    FOR INSERT
    WITH CHECK (auth.uid() = user_id);

-- Policy to allow users to update their own cart items
CREATE POLICY "Users can update their own cart items"
    ON public.shop_cart
    FOR UPDATE
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

-- Policy to allow users to delete their own cart items
CREATE POLICY "Users can delete their own cart items"
    ON public.shop_cart
    FOR DELETE
    USING (auth.uid() = user_id); 



