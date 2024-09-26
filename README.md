# CinemaNow

This repository contains the code for a cinema app developed as part of the Software Development II course at the Faculty of Information Technologies. The app is currently in development and is being implemented using .NET for the backend and Flutter for the frontend.

## Overview

- **Backend**: Developed using .NET, providing a robust API for managing cinema-related data.
- **Frontend**: Built with Flutter, with separate interfaces for desktop (admin) and mobile (user) applications.

## Getting Started

To get the app up and running, follow these steps:

1. Clone the repository:

    ```bash
    git clone https://github.com/NedzmijaMuminovic/CinemaNow
    ```

2. Set up the database:
   - Navigate to the Database folder (CinemaNow/CinemaNow/Database).
   - Execute the SQL file inside this folder to set up the database.

3. Run the backend:
   - Open the CinemaNow.sln file in Visual Studio (CinemaNow/CinemaNow).
   - Build and run the backend project.

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
       
       ```bash
       flutter run
       ```
    
## License

This project is licensed under the MIT License - see the LICENSE file for details.
