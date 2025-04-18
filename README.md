# Ecommerce-app

An Ecommerce Application.

# Production

- To see the production version of the app, visit [this website](https://cartshop.live) or enter the link `https://cartshop.live`.
- Read about our production deployment in [Architecture Diagram](#architecture-diagram).

# Quick Start

To start, simply clone this project along with its submodules with:

```bash
git clone --recurse-submodules git@github.com:CS464-ECOMMERCE/ecommerce-app.git

git submodule foreach "git checkout main && git pull"
## do this to git pull for each submodule
```

## 🛠️ How to Run the Project Locally

### Option 1: Run with Docker Compose

#### ✅ Requirements

- Install [Docker](https://www.docker.com/).
- (Optional) Get your own [Google Maps API key](https://developers.google.com/maps/documentation/javascript/get-api-key) to use the map feature when checking out.
- (Optional) Get your own [Stripe API keys](https://dashboard.stripe.com/apikeys) to create new products.

#### 🔑 Add Stripe and Google Maps Keys

An environment variable file is created named `testing.env` in the project root folder. Add/Change the following variables:

```env
STRIPE_SECRET_KEY=''
STRIPE_API_KEY=''
GOOGLE_MAPS_API_KEY=''
```

> ⚠️ You can skip this if you just want to test without checkout and adding new products — some products are already added using:
>
> - **Email:** `test@test.com`
> - **Password:** `testing`

#### ▶️ Start the Project

```bash
make run
```

#### ⏹️ Stop the Project

Press `Ctrl + C`, then run:

```bash
make stop
```

---

### Option 2: Run with Kubernetes (K8s)

#### ✅ Requirements

- For M1/M2 MacBooks:
  - Install [OrbStack](https://orbstack.dev/) with:
    ```bash
    brew install --cask orbstack
    ```
  - Or install [Minikube](https://minikube.sigs.k8s.io/docs/)
- Install [Tilt](https://docs.tilt.dev/)

#### ▶️ Start the Project

```bash
tilt up
```

#### ⏹️ Stop the Project

```bash
tilt down
```

---

# Architecture Diagram

![Architecture Diagram](architecture.png "Architecture of Ecommerce App")

# Architecture Overview

## Frontend

- The frontend is built using **Next.js** and hosted on **Vercel**.
- It communicates with the backend through a **GCP Load Balancer**, which routes API requests to **Traefik**.
- Traefik acts as a reverse proxy that forwards the requests to the appropriate backend services.

---

## Backend

### Stateless Components

The backend's stateless services run on **Kubernetes** with a **Horizontal Pod Autoscaler** configured to scale based on **CPU and memory utilization**. These services include:

1. **Backend (API) Server**

   - Exposes REST API endpoints for client interactions.
   - Translates REST calls to gRPC requests to communicate with internal services.
   - Handles **authentication** for merchant users.

2. **Cart Service**

   - Exposes a gRPC server.
   - Manages customer carts, storing session-based cart data in **Redis**.

3. **Product Service**

   - Exposes a gRPC server.
   - Manages product information and inventory.
   - Handles order creation by communicating with the Cart Service to retrieve cart contents.

4. **Order Service**
   - Exposes a gRPC server.
   - Handles **Stripe payment logic** and order finalization.

---

### Stateful Components

Stateful backend services are deployed using **Kubernetes StatefulSets** to ensure stable network identities and persistent storage. These services use **Persistent Volumes** to retain data across pod restarts.

1. **PostgreSQL**

   - Stores structured data across several tables: `users`, `merchants`, `products`, `orders` and `order_items`.

2. **Redis**
   - Stores session-based cart data using the session ID as a hash key.
   - Ensures low-latency access for cart operations.

---

## Infrastructure

- The entire infrastructure is hosted on **Google Cloud Platform (GCP)**.
- Backend services are deployed on **Google Kubernetes Engine (GKE)**, while the frontend is hosted on **Vercel**.
- **Cloudflare** is used as a Content Delivery Network (CDN), handles SSL/TLS certificates, and acts as a reverse proxy for the origin server.
- The entire infrastructure is provisioned and managed using **Terraform**.

---

# ER Diagram

```mermaid
erDiagram
    users ||--o{ orders : "places"
    users ||--o| merchants : "operates"
    merchants ||--o{ products : "sells"
    orders ||--|{ order_items : "contains"
    products ||--o{ order_items : "included_in"

    users {
        int id PK
        string email UK "Unique and non-null"
        text password_hash
        enum role "ENUM('admin', 'merchant', 'client')"
    }

    merchants {
        int user_id PK,FK
        string business_name
        string tax_id
        boolean verified
    }

    products {
        int id PK
        int merchant_id FK "References merchants(user_id)"
        string name
        float price
        int inventory
        text description
        text[] images
        string stripe_price_id
        string stripe_product_id
        boolean is_deleted "Defaults to FALSE"
    }

    orders {
        int id PK
        int user_id FK "References users(id)"
        float total
        enum status "ENUM('processing', 'cancelled', 'completed')"
        string transaction_id
        string checkout_session_id
        enum payment_status "ENUM('pending', 'completed', 'cancelled')"
        string address
        timestamp created_at "Defaults to CURRENT_TIMESTAMP"
        timestamp updated_at "Defaults to CURRENT_TIMESTAMP"
    }

    order_items {
        int order_id PK,FK "References orders(id)"
        int product_id PK,FK "References products(id)"
        int quantity
        float price
        timestamp created_at "Defaults to CURRENT_TIMESTAMP"
        timestamp updated_at "Defaults to CURRENT_TIMESTAMP"
    }
```
