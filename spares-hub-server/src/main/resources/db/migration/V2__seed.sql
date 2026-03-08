INSERT INTO users (email, password, name, phone, address, role, status)
VALUES
  ('admin@example.com', 'password123', 'System Admin', '9999999999', 'Admin Office', 'ROLE_ADMIN', 'ACTIVE')
ON CONFLICT (email) DO NOTHING;

INSERT INTO users (email, password, name, phone, address, role, status)
VALUES
  ('staff@example.com', 'password123', 'Delivery Staff', '8888888888', 'Staff Hub', 'ROLE_STAFF', 'ACTIVE')
ON CONFLICT (email) DO NOTHING;

INSERT INTO users (email, password, name, phone, address, role, status)
VALUES
  ('super.manager@example.com', 'supermanager', 'Super Manager', '7777777777', 'HQ', 'ROLE_SUPER_MANAGER', 'ACTIVE')
ON CONFLICT (email) DO NOTHING;

INSERT INTO products (name, part_number, mrp, selling_price, wholesaler_price, retailer_price, mechanic_price, stock, wholesaler_id)
VALUES
  ('Brake Pad Set', 'BP-001', 1200.0, 1000.0, 800.0, 900.0, 950.0, 50, 1),
  ('Oil Filter', 'OF-002', 450.0, 350.0, 250.0, 300.0, 320.0, 0, 1)
ON CONFLICT DO NOTHING;
