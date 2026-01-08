🐾 PawPal: Pet Adoption & Donation ApplicationPawPal is a full-stack mobile solution developed using Flutter, PHP, and MySQL. It connects pet lovers with animals in need through a public listing system, adoption requests, and a comprehensive donation module.
----------------------------------------------------------------------------------------
⚙️ Project Setup

1. Prerequisites
    * Frontend: Flutter SDK (Stable version) and an IDE like VS Code or Android Studio.
    * Backend: A web host with cPanel or a local server like XAMPP.
    * Database: MySQL.
2. Backend InstallationDatabase Import:
    * Create a new database (e.g., pawpal_db).
    * Import the server/pawpal_db.sql file provided in this repository to set up the * necessary tables (tbl_users, tbl_pets, tbl_donations).
    * File Upload:Upload the contents of the server/pawpal/ folder to your server's web root
    * Database Connection:Edit server/pawpal/api/dbconnect.php with your specific server * credentials (hostname, username, password, and database name).
3. Frontend Configuration
    * Update Base URL:Open lib/myconfig.dart and update the baseUrl to match your server's address
    * Install Dependencies:Run flutter pub get to install required packages like http, shared_preferences, and image_picker.
    * Run Application:Use flutter run on a connected device or emulator.
----------------------------------------------------------------------------------------
✨ Core Features

1. Public Pet Listing
Real-time Retrieval: Fetches all available pets from the backend database.
Search & Filter: Includes a search bar for name-based searches and a dropdown to filter pets by type (e.g., Dog, Cat, Rabbit).

2. Pet Details & Adoption
Detailed View: Shows pet images, descriptions, owner info, and location.
Adoption Form: Logged-in users can submit adoption applications, which are processed and stored on the server.

3. Donation Module
Giving Support: Supports food, medical, and monetary donations.
History Tracking: A dedicated "My Donation" screen where users can view their past contributions, filtered specifically for their account.

4. User Profile
Session Management: Uses SharedPreferences to keep users logged in across app restarts.
Edit Profile: Allows users to update their name, phone, and profile picture.
----------------------------------------------------------------------------------------
🔌 API Usage
The application communicates with the server via several PHP endpoints using HTTP GET and POST methods.

1. REST API