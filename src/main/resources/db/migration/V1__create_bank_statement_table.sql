CREATE TABLE bank_statement (
    id BIGSERIAL PRIMARY KEY,
    customer_id VARCHAR(255) NOT NULL,
    transaction_id VARCHAR(255) NOT NULL,
    transaction_type VARCHAR(255) NOT NULL,
    transaction_value NUMERIC(19, 2) NOT NULL,
    transaction_date TIMESTAMP NOT NULL,
    description VARCHAR(255) NOT NULL
);
