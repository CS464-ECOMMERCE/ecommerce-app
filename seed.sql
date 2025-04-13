CREATE TYPE user_role AS ENUM ('admin', 'merchant', 'client');

CREATE TYPE order_status AS ENUM ('processing', 'cancelled', 'completed');

CREATE TYPE payment_status AS ENUM ('pending', 'completed', 'cancelled', 'error');


CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash TEXT,
    role user_role NOT NULL DEFAULT 'client'
);

CREATE TABLE orders (
    id SERIAL PRIMARY KEY,
    user_id INT NOT NULL,
    total NUMERIC(10,2) NOT NULL,
    status order_status NOT NULL DEFAULT 'processing',
    transaction_id VARCHAR(255) NOT NULL,
    checkout_session_id VARCHAR(255),
    payment_status payment_status NOT NULL DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_user_id FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE TABLE merchants (
    user_id INT PRIMARY KEY,
    business_name VARCHAR(255) NOT NULL,
    tax_id VARCHAR(255),
    verified BOOLEAN DEFAULT FALSE,
    CONSTRAINT fk_merchant_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE TABLE products (
    id SERIAL PRIMARY KEY,
    merchant_id INT NOT NULL,
    name  VARCHAR(100) NOT NULL,
    price NUMERIC(10,2) NOT NULL,
    inventory INTEGER NOT NULL,
    description TEXT,
    images TEXT[],
    stripe_price_id VARCHAR(255),
    stripe_product_id VARCHAR(255),
    is_deleted BOOLEAN DEFAULT FALSE
);

CREATE TABLE order_items (
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    price NUMERIC(10,2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_order_id FOREIGN KEY (order_id) REFERENCES orders(id),
    CONSTRAINT fk_product_id FOREIGN KEY (product_id) REFERENCES products(id),
    CONSTRAINT pk_orderitem PRIMARY KEY (order_id, product_id)
);

INSERT INTO products (
    name,
    merchant_id,
    price,
    inventory,
    description,
    images,
    stripe_price_id,
    stripe_product_id
) VALUES
    ('Book', 1, 1.23, 12, 'This is a book description', '{"https://storage.googleapis.com/cs464-application/book-dbdbc5ce-43c7-4a10-995d-7eee507b5feb.jpeg"}', 'price_1R289X2fahqAQuSF9FLFgWy9', 'prod_Rw09PADMzbrm5i'),
    ('Crayons', 1, 5.5, 2, 'This is a crayon description', '{"https://storage.googleapis.com/cs464-application/crayon-521e8adc-f2a9-4721-9b01-15f61f868e6e.jpeg"}', 'price_1R94HD2fahqAQuSF2dunWWDc', 'prod_S3AczQviRprZfD'),
    ('Table', 1, 200, 1, 'This is a table description', '{"https://storage.googleapis.com/cs464-application/table-5d44e86a-e2e1-450b-bd41-f0b32e5e75f1.jpeg"}', 'price_1R94I72fahqAQuSFLGyIq4tK', 'prod_S3AdGhsGIOcpDt'),
    ('Chair', 1, 99.90, 10, '','{"https://storage.googleapis.com/cs464-application/chair-b69f84a8-06e7-42bf-a788-f0c11bc14432.jpeg"}', 'price_1R94IM2fahqAQuSFNahqJ7r1', 'prod_S3AdgZsfojgML0');

INSERT INTO users (
    email,
    password_hash,
    role
) VALUES
('test@test.com', '$2a$10$6B/J96q.6oztUg9.YCw4UujRaGJxHHk3tvka2/qHnBV3d2yUz6kiW', 'merchant');

INSERT INTO merchants (
    user_id,
    business_name,
    tax_id,
    verified
) VALUES
(1, 'Test Business', '123456789', true);