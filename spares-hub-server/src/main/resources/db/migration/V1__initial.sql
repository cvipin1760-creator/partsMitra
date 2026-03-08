CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    email TEXT UNIQUE NOT NULL,
    password TEXT NOT NULL,
    name TEXT,
    phone TEXT,
    address TEXT,
    role TEXT,
    status TEXT DEFAULT 'PENDING',
    latitude DOUBLE PRECISION,
    longitude DOUBLE PRECISION,
    shop_image_path TEXT
);

CREATE TABLE IF NOT EXISTS products (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    part_number TEXT,
    mrp DOUBLE PRECISION,
    selling_price DOUBLE PRECISION,
    wholesaler_price DOUBLE PRECISION,
    retailer_price DOUBLE PRECISION,
    mechanic_price DOUBLE PRECISION,
    stock INTEGER,
    wholesaler_id INTEGER,
    image_path TEXT
);

CREATE TABLE IF NOT EXISTS orders (
    id SERIAL PRIMARY KEY,
    customer_id INTEGER,
    customer_name TEXT,
    seller_id INTEGER,
    seller_name TEXT,
    total_amount DOUBLE PRECISION,
    status TEXT,
    created_at TEXT,
    latitude DOUBLE PRECISION,
    longitude DOUBLE PRECISION,
    delivered_by TEXT,
    delivered_at TEXT
);

CREATE TABLE IF NOT EXISTS order_items (
    id SERIAL PRIMARY KEY,
    order_id INTEGER REFERENCES orders(id) ON DELETE CASCADE,
    product_id INTEGER,
    product_name TEXT,
    quantity INTEGER,
    price DOUBLE PRECISION
);

CREATE TABLE IF NOT EXISTS notifications (
    id SERIAL PRIMARY KEY,
    title TEXT,
    message TEXT,
    target_role TEXT,
    created_at TEXT
);

CREATE TABLE IF NOT EXISTS voice_corrections (
    id SERIAL PRIMARY KEY,
    recognized_text TEXT,
    corrected_text TEXT
);

CREATE TABLE IF NOT EXISTS order_requests (
    id SERIAL PRIMARY KEY,
    customer_id INTEGER,
    customer_name TEXT,
    text TEXT,
    photo_path TEXT,
    status TEXT,
    created_at TEXT,
    assigned_staff_id INTEGER,
    assigned_staff_name TEXT
);
