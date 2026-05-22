-- Enable UUID extension if not already enabled
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Create orders table
CREATE TABLE orders (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    full_name TEXT NOT NULL,
    contact_number TEXT NOT NULL,
    product_id UUID REFERENCES shop_products(id) ON DELETE CASCADE,
    product_name TEXT NOT NULL,
    product_price NUMERIC(10,2) NOT NULL,
    quantity INT NOT NULL CHECK (quantity > 0),
    total_price NUMERIC(10,2) NOT NULL,
    payment_method TEXT NOT NULL CHECK (payment_method IN ('cash', 'gcash')),
    message_to_admin TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- Index for faster lookups by user
CREATE INDEX idx_orders_user_id ON orders(user_id);
-- Index for faster lookups by product
CREATE INDEX idx_orders_product_id ON orders(product_id); 