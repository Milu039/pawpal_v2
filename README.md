# pawpal_v2

PawPal v2 - Pet Submission Module
This is Version 2 of the PawPal Flutter mobile application. This update introduces the Pet Submission Module, allowing users to upload details about pets including multiple images and geolocation data. It also features a Main Page to view all submitted pets.

For the Version 1, it having some issues due cant be use to proceed the assignment. So i have created this new version and copy the code from the version 1.

# 🚀 Key Features
1. Pet Submission Form: Text inputs, dropdowns, and validation.
2. Multi-Image Upload: Supports selecting and uploading up to 3 images.
3. Geolocation: Automatically captures the device's Latitude and Longitude.
4. Backend Integration: Uses PHP and MySQL with manual file handling (file_put_contents)

# Setup for this project:
1. This project is run in dart code, the flutter extendion is required to install(if using vsCode), installation link: https://docs.flutter.dev/install/with-vs-code
2. This project using sql server(Xampp) to stored the data, make sure to install Xampp
3. create the folder in the Xampp htdocs, 
    C:\xampp\htdocs\pawpal\api <- place all the php.file inside this project api folder into your xampp htdocs with the path
    C:\xampp\htdocs\pawpal\assets\pets <- this folder is used to store the images
4. import the pawpal_db.sql into the sql server
5. Find your PC's local IP address, open lib/myconfig.dart, and update the baseUrl with your local IP address

# 📡 API Explanation
1. add_pet.php
   Method: POST

   Description: Receives pet details and a JSON string of Base64 encoded images. It saves the text data to the database and converts Base64 strings into .png files stored in the server's asset folder.

Parameters:
1. user_id: (int) ID of the user submitting the pet.
2. pet_name: (String) Name of the pet.
3. pet_type: (String) e.g., Dog, Cat.
4. category: (String) e.g., Adoption, Rescue.
5. description: (String) Details about the pet.
6. lat: (double) Latitude.
7. lng: (double) Longitude.
8. image_paths: (String) JSON Encoded string containing a list of Base64 images.

2. load_pets.php
   Method: GET

   Description: Fetches the list of pets from the database to display on the Main Screen.

   Parameters: Optional user_id to filter by user.

# 📄 JSON Response Samples
1. Success Response (add_pet.php)
   When the form is successfully submitted:
   {"status": "success","message": "Pet submitted successfully"}

2. Error Response
   If required fields are missing or database insertion fails:
   {
       "status": "failed",
       "message": "Submit failed: Field 'image_paths' doesn't have a default value"
   }

3. Data Fetch Response (load_pets.php)
   Used to populate the ListView on the Main Page:
   {
       "status": "success",
       "data": [
           {
               "pet_id": "1",
               "user_id": "15",
               "pet_name": "Oyen",
               "pet_type": "Cat",
               "category": "Adoption",
               "description": "Orange cat found near park.",
               "image_paths": "pet_1_0.png,pet_1_1.png",
               "lat": "6.4432",
               "lng": "100.4321",
               "created_at": "2025-12-06 10:00:00"
           }
       ]
   }