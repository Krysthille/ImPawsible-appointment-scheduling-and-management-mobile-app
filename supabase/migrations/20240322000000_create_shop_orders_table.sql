-- Enable UUID extension if not already enabled
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Create shop_orders table
CREATE TABLE public.shop_orders (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    full_name TEXT NOT NULL,
    contact_number TEXT NOT NULL,
    total_amount NUMERIC(10,2) NOT NULL,
    payment_method TEXT NOT NULL CHECK (payment_method IN ('cash', 'gcash')),
    message_to_admin TEXT,
    status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'processing', 'completed', 'cancelled')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- Create shop_order_items table
CREATE TABLE public.shop_order_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_id UUID REFERENCES public.shop_orders(id) ON DELETE CASCADE,
    product_id UUID REFERENCES public.shop_products(id) ON DELETE CASCADE,
    product_name TEXT NOT NULL,
    price NUMERIC(10,2) NOT NULL,
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- Create indexes for better query performance
CREATE INDEX idx_shop_orders_user_id ON public.shop_orders(user_id);
CREATE INDEX idx_shop_order_items_order_id ON public.shop_order_items(order_id);
CREATE INDEX idx_shop_order_items_product_id ON public.shop_order_items(product_id);

-- Create a function to update the updated_at timestamp
CREATE OR REPLACE FUNCTION update_shop_orders_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = TIMEZONE('utc'::text, NOW());
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create a trigger to automatically update the updated_at column
CREATE TRIGGER update_shop_orders_updated_at
    BEFORE UPDATE ON public.shop_orders
    FOR EACH ROW
    EXECUTE FUNCTION update_shop_orders_updated_at();

-- Add RLS (Row Level Security) policies
ALTER TABLE public.shop_orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.shop_order_items ENABLE ROW LEVEL SECURITY;

-- Policy to allow users to view their own orders
CREATE POLICY "Users can view their own orders"
    ON public.shop_orders
    FOR SELECT
    USING (auth.uid() = user_id);

-- Policy to allow users to insert their own orders
CREATE POLICY "Users can insert their own orders"
    ON public.shop_orders
    FOR INSERT
    WITH CHECK (auth.uid() = user_id);

-- Policy to allow users to view their own order items
CREATE POLICY "Users can view their own order items"
    ON public.shop_order_items
    FOR SELECT
    USING (EXISTS (
        SELECT 1 FROM public.shop_orders
        WHERE id = shop_order_items.order_id
        AND user_id = auth.uid()
    ));

-- Policy to allow users to insert their own order items
CREATE POLICY "Users can insert their own order items"
    ON public.shop_order_items
    FOR INSERT
    WITH CHECK (EXISTS (
        SELECT 1 FROM public.shop_orders
        WHERE id = shop_order_items.order_id
        AND user_id = auth.uid()
    ));

-- Policy to allow service_role to manage all orders
CREATE POLICY "Service role can manage all orders"
    ON public.shop_orders
    FOR ALL
    USING (auth.role() = 'service_role');

-- Policy to allow service_role to manage all order items
CREATE POLICY "Service role can manage all order items"
    ON public.shop_order_items
    FOR ALL
    USING (auth.role() = 'service_role'); 

ALTER TABLE shop_orders ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Admins can update any order"
  ON shop_orders
  FOR UPDATE
  USING (
    auth.role() = 'service_role'
    -- OR (auth.uid() IN (SELECT id FROM users WHERE is_admin = true))
  );