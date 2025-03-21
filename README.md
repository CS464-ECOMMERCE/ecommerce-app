# Ecommerce-app
An Ecommerce Application.

# Quick Start
To start, simply clone this project along with its submodules with:
```bash
git clone --recurse-submodules git@github.com:CS464-ECOMMERCE/ecommerce-app.git

git submodule foreach "git checkout main && git pull"
## do this to git pull for each submodule 
```

# ER Diagram
```mermaid
erDiagram
        USER ||--o{ ORDER : places
        USER {
            int id PK "anon session uuid"
            string email
            string password_hash
            string role
        }

        %% MERCHANT ||--o{ PRODUCT : sells
        MERCHANT |o--|| USER : linked_to
        MERCHANT {
            int user_id PK, FK  
            string business_name
            string tax_id
            boolean verified
        }

        %% PRODUCT ||--o{ REVIEW : reviewed_by
        ORDER ||--|{ ORDERITEM : contains
        PRODUCT {
            int id PK
            %% int merchant_id FK
            %% int category_id FK
            string name
            float price
            int inventory
            string description
            string images "; object location delimited"
            string stripe_price_id
            string stripe_product_id
        }
        
        ORDER {
            int id PK
            int user_id FK
            float total
            string status
            string transaction
        }

        ORDERITEM }o--|| PRODUCT: contains
        ORDERITEM {
            int order_id PK, FK
            int product_id PK, FK
            int quantity
        }

        PAYMENT ||--|| ORDER : associated_with
        PAYMENT {
            int order_id PK, FK
            string transaction_id
            string status
            string gateway
        }
```