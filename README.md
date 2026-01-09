PawPal - Pet Adoption & Donation System
PawPal is a mobile application developed with Flutter designed to streamline pet adoption and manage animal welfare donations. The system features a secure PHP-based backend integrated with a payment gateway to handle financial contributions safely.
-----------------------------------------------------------------------------------------------------
🚀 Features
* Pet Adoption Management: Allows users to view and apply for pet adoptions through a digital form.

* Donation System: Integrated payment gateway for secure credit and donation transactions.

* Real-time Payment Verification: Uses secure hashing (X-Signature) to verify transaction integrity before updating records.

* Role-Based Dashboard: Management system for tracking donations and pet statuses.
-----------------------------------------------------------------------------------------------------
🛠 Project Setup
Prerequisites
* Frontend: Flutter SDK installed on your local machine.

* Backend: PHP 7.4+ and MySQL (accessible via cPanel or similar).

* Payment Gateway: A registered account with a payment provider (e.g., Billplz).

Installation Steps
1. Backend Deployment:

    * Upload the PHP scripts to your web host's directory (e.g., /api/).

    * Import the database schema into phpMyAdmin.

    * Configure dbconnect.php with your database credentials.

2. Payment Configuration:

    * Open payment.php and insert your unique API Key and Collection ID.

    * Open payment_update.php and replace the placeholder with your X-Signature Key.

3. Frontend Configuration:

    * Update the base URL in your Flutter project to point to your backend API directory.

    * Run flutter pub get to install necessary dependencies.
-----------------------------------------------------------------------------------------------------
📂 API Usage
The system utilizes two primary scripts to manage the payment lifecycle:

1. Initiate Payment (payment.php)
This endpoint is called by the Flutter app to start a transaction.

Method: GET

Required Parameters: userid, email, phone, name, credits, petid, category.

Action: It generates a bill via the payment gateway and redirects the user to the secure payment page.

2. Payment Update & Verification (payment_update.php)
This endpoint acts as the callback and redirect URL.

Method: GET (via gateway redirect)

Action: * Receives transaction data and verifies the security signature.

If successful, it inserts a record into the donations table.

Displays a mobile-responsive receipt to the user.
-----------------------------------------------------------------------------------------------------
🔧 Security Best Practices
Data Protection: The system uses prepared statements for SQL queries to prevent injection attacks.

Encrypted Connections: Always ensure your API is hosted over HTTPS to protect user data during transit.

Environment Safety: Never commit your actual API keys or database passwords to public version control systems.