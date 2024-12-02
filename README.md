# CinemaNow

This repository contains the code for a cinema app developed as part of the Software Development II course at the Faculty of Information Technologies.

## Overview

- **Backend**: Developed using .NET, providing a comprehensive API for managing cinema-related data.
- **Frontend**: Built with Flutter, with separate interfaces for desktop (admin) and mobile (user) applications.

## Getting Started

To get the app up and running, follow these steps:

1. Clone the repository:

    ```bash
    git clone https://github.com/NedzmijaMuminovic/CinemaNow
    ```

2. Configure Environment Variables:

   - Set up your Stripe Secret key and email app password in your environment with one of these commands:

       ```bash
       # Command Prompt
       set STRIPE_SECRET_KEY=YourSecretKey
       set EMAIL_PASSWORD=YourEmailAppPassword

       # PowerShell
       $env:STRIPE_SECRET_KEY = "YourSecretKey"
       $env:EMAIL_PASSWORD = "YourEmailAppPassword"
       ```

    - Alternatively, use .env files:
        - For the backend, place the .env file in CinemaNow/CinemaNow.
        - For the frontend (mobile app), place it in CinemaNow/CinemaNow/UI/cinemanow_mobile/assets.

3. Run the backend and services using Docker:

    - In the project's root directory (CinemaNow/CinemaNow), use the following command:
      
       ```bash
       docker-compose up --build
       ```

4. Run the frontend:

   - **For Desktop:**
     - Open the Flutter project in Visual Studio Code (CinemaNow/CinemaNow/UI/cinemanow_desktop).
     - Install the necessary dependencies:
       
       ```bash
       dart pub get
       ```
     
     - Run the Flutter app for Windows:
       
       ```bash
       flutter run -d windows
       ```

   - **For Mobile:**
     - Open the Flutter project in Visual Studio Code (CinemaNow/CinemaNow/UI/cinemanow_mobile).
     - Install the necessary dependencies:
       
       ```bash
       dart pub get
       ```
     
     - Connect a physical device or start an emulator.
     - Run the Flutter app for mobile:
       
       - **For an emulator** (if you have an `.env` file configured):
         
         ```bash
         flutter run
         ```
       - **For a physical device** (replacing 192.168.x.x with your device's IP address):
      
         ```bash
         flutter run --dart-define=API_HOST=192.168.x.x
         ```
       - Or, if you prefer to specify your Stripe Publishable Key directly, use:
         
         ```bash
         flutter run --dart-define=STRIPE_PUBLISHABLE_KEY=YourPublishableKey
         ```

## Login Credentials

- **Admin (Desktop app):**
  - Username: desktop
  - Password: test
        
- **User (Mobile app):**
  - Username: mobile
  - Password: test

## Payment Information (for Stripe Testing)
Use the following information for testing Stripe payments:

- **Card Number:** 4242 4242 4242 4242
- **Expiration Date:** Any future date
- **CVC:** Any three-digit number
- **ZIP Code:** Any five-digit number

## Additional Notes
- **Email Notifications:** The app uses RabbitMQ to send an email after successful user registration.
- **Recommender System:** A content-based recommender system is implemented on the movie details screen to display similar movies based on the selected title's attributes.
- **Seed Data:** The seed data includes only 2 sample images to speed up the `docker-compose up` process.

## Screenshots

<details>
  <summary>Desktop Screenshots</summary>

  <img src="screenshots/desktop/1.png" alt="Screenshot 1" width="300px">
  <img src="screenshots/desktop/2.png" alt="Screenshot 2" width="300px">
  <img src="screenshots/desktop/3.png" alt="Screenshot 3" width="300px">
  <img src="screenshots/desktop/4.png" alt="Screenshot 4" width="300px">
  <img src="screenshots/desktop/5.png" alt="Screenshot 5" width="300px">
  <img src="screenshots/desktop/6.png" alt="Screenshot 6" width="300px">
  <img src="screenshots/desktop/7.png" alt="Screenshot 7" width="300px">
  <img src="screenshots/desktop/8.png" alt="Screenshot 8" width="300px">
  <img src="screenshots/desktop/9.png" alt="Screenshot 9" width="300px">
  <img src="screenshots/desktop/10.png" alt="Screenshot 10" width="300px">
  <img src="screenshots/desktop/11.png" alt="Screenshot 11" width="300px">
  <img src="screenshots/desktop/12.png" alt="Screenshot 12" width="300px">
  <img src="screenshots/desktop/13.png" alt="Screenshot 13" width="300px">
  <img src="screenshots/desktop/14.png" alt="Screenshot 14" width="300px">
  <img src="screenshots/desktop/15.png" alt="Screenshot 15" width="300px">

</details>

<details>
  <summary>Mobile Screenshots</summary>

  <img src="screenshots/mobile/1.jpg" alt="Screenshot 1" width="200px">
  <img src="screenshots/mobile/2.jpg" alt="Screenshot 2" width="200px">
  <img src="screenshots/mobile/3.jpg" alt="Screenshot 3" width="200px">
  <img src="screenshots/mobile/4.jpg" alt="Screenshot 4" width="200px">
  <img src="screenshots/mobile/5.jpg" alt="Screenshot 5" width="200px">
  <img src="screenshots/mobile/6.jpg" alt="Screenshot 6" width="200px">
  <img src="screenshots/mobile/7.jpg" alt="Screenshot 7" width="200px">
  <img src="screenshots/mobile/8.jpg" alt="Screenshot 8" width="200px">
  <img src="screenshots/mobile/9.jpg" alt="Screenshot 9" width="200px">
  <img src="screenshots/mobile/10.jpg" alt="Screenshot 10" width="200px">
  <img src="screenshots/mobile/11.jpg" alt="Screenshot 11" width="200px">
  <img src="screenshots/mobile/12.jpg" alt="Screenshot 12" width="200px">
  <img src="screenshots/mobile/13.jpg" alt="Screenshot 13" width="200px">
  <img src="screenshots/mobile/14.jpg" alt="Screenshot 14" width="200px">

</details>
    
## License

This project is licensed under the MIT License - see the LICENSE file for details.
