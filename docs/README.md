
# SpareHub - Spare Parts Inventory & Delivery Management System

A full-stack multi-role inventory and delivery management system designed for a spare parts business.

## Tech Stack
- **Backend**: Java Spring Boot (REST APIs + WebSocket support)
- **Frontend Web**: React.js (Admin + Wholesaler dashboard)
- **Mobile App**: Flutter (Retailer + Mechanic app)
- **Database**: MySQL
- **Authentication**: JWT-based role authentication
- **Real-time**: WebSockets for live tracking and notifications

## Project Structure
- `/backend`: Spring Boot application
- `/frontend-web`: React.js application
- `/spare_parts_app`: Flutter mobile application
- `/sql`: Database schema scripts

## Setup Guide

### 1. Database Setup
- Install MySQL and create a database named `inventory_delivery_db`.
- Execute the SQL script in `/sql/schema.sql` to create tables and seed initial roles.

### 2. Backend Setup
- Navigate to `/backend`.
- Update `src/main/resources/application.properties` with your MySQL credentials.
- Run the application using Maven:
  ```bash
  mvn spring-boot:run
  ```

### 3. Frontend Web Setup (Admin & Wholesaler)
- Navigate to `/frontend-web`.
- Install dependencies:
  ```bash
  npm install
  ```
- Start the development server:
  ```bash
  npm run dev
  ```
- Access the dashboard at `http://localhost:5173`.

### 4. Mobile App Setup (Retailer & Mechanic)
- Navigate to `/spare_parts_app`.
- Install Flutter dependencies:
  ```bash
  flutter pub get
  ```
- Update `lib/utils/constants.dart` with your backend server URL.
- Run the app on an emulator or physical device:
  ```bash
  flutter run
  ```

## API Documentation
The APIs are documented in the Postman collection provided in `/docs/postman_collection.json`.

### Key Endpoints:
- `POST /api/auth/signup`: Register a new user (Admin, Wholesaler, Retailer, Mechanic)
- `POST /api/auth/signin`: Authenticate and receive JWT
- `GET /api/products`: View all available products
- `POST /api/products`: Add a new product (Wholesaler only)
- `POST /api/excel/upload`: Bulk upload products via Excel (Wholesaler only)
- `POST /api/orders`: Place a new order
- `PUT /api/orders/{id}/status`: Update order status (Pending -> Delivered)
- `WS /ws`: WebSocket endpoint for real-time location updates

## Roles & Features
- **Admin**: Dashboard analytics, user approval, view all transactions.
- **Wholesaler**: Product management, bulk upload, inventory tracking, order fulfillment.
- **Retailer**: Purchase stock from wholesalers, manage own inventory, sell to mechanics, generate bills.
- **Mechanic**: Discover nearby retailers, search parts, place orders, real-time delivery tracking.
