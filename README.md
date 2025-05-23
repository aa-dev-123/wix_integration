# 🚀 Wix Integration Rails App
This Ruby on Rails application integrates with Wix using custom (legacy) OAuth authentication. It allows users to install the app on their Wix site and import product and order data. It also supports webhooks for real-time updates and offers a basic UI to manage shops, products, and orders.

## ✅ Features
### 🔐 Wix OAuth (Custom Authentication)
  Implements Wix's legacy OAuth flow

  Supports:

    Requesting access token

    Refreshing access token

    Fetching app instance

### 🏪 Shop Management
  Users can install the app on a selected Wix site
  
  Each Wix site is saved as a Shop
  
  Ensures uniqueness of shops during creation

### 📦 Product (Project) Import
  Imports products from the connected Wix site
  
  Stored as Projects in the app
  
  Ensures unique products by SKU
  
  Skips duplicates using service-level checks

### 🧾 Order & Line Item Import
  Imports orders and associated line items from the site
  
  Ensures uniqueness of orders
  
  Includes fulfillment and payment statuses
  
  Displays orders and statuses in the UI

### 🔁 Webhook Support
  Handles the Order Updated webhook from Wix
  
  Implements JWT verification using Wix public key
  
  Self-hosted webhook endpoint: `POST /webhook`
  
  Setup instructions included below

## 🖥️ User Interface
  Basic UI with:
  
    Navigation bar
    
    Pages for shops, projects (products), and orders
    
    Styling applied throughout
  
  All core functionality is integrated into the new UI

## 📦 Setup Instructions
1. **Clone the repository:**

```
git clone https://github.com/your-username/wix-integration-rails.git
cd wix-integration-rails
```

2. Install dependencies:

```
bundle install
yarn install --check-files
```

3. Set up the database:

```
rails db:setup
```

4. Environment Variables:

Configure the following in `.env` or using Rails credentials:
```
WIX_CLIENT_ID

WIX_CLIENT_SECRET

WIX_API_BASE_URL

WIX_REDIRECT_URL

WIX_PUBLIC_KEY
```

5. Start the server:

```
rails server
```

## 🔔 Webhook Setup
To enable real-time updates from Wix:

1. Go to your Wix App Dashboard

2. Navigate to: `Develop → Webhooks → Create Webhook`

3. Add an event for: `Order Updated`

4. Use this endpoint in your app:

`POST /webhook`

5. The webhook will:

Verify JWT using your app's public key

Process and update order status accordingly

## 🛠️ Tech Stack
  Ruby on Rails (API + HTML UI)
  
  Wix REST APIs
  
  SQLite
  
## 🚧 Future Improvements
  Better UI/UX design
  
  Add more Wix events and product updates to webhooks
  
  Admin dashboard for shops
  
  Automatic syncing of data on schedule
