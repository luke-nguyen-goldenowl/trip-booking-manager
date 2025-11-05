# Trip Booking Management

## Table of contents

- [How to Use](https://github.com/luke-nguyen-goldenowl/trip-booking-manager#how-to-use)
- [Code Conventions](https://github.com/luke-nguyen-goldenowl/trip-booking-manager#code-conventions)
- [Database diagram](https://github.com/luke-nguyen-goldenowl/trip-booking-manager#database-diagram)
- [Dependencies](https://github.com/luke-nguyen-goldenowl/trip-booking-manager#dependencies)
- [Screenshot](https://github.com/luke-nguyen-goldenowl/trip-booking-manager#screenshot)

## Prerequisites

- Flutter >= 3.27.1

## Link

- [Comana](https://goldenowl.comana.vn/t/FUvPq3q2)
- [Firebase console](https://console.firebase.google.com/project/bus-booking-ticket/overview)
- [Source code - Github](https://github.com/luke-nguyen-goldenowl/trip-booking-manager)

# How to Use

- **Step 1:** Download or clone this repo by using the link below:

  ```sh
  https://github.com/luke-nguyen-goldenowl/trip-booking-manager.git
  ```

- **Step 2:** Install Flutter

  - Install the platform-specific SDK [here](https://flutter.dev/docs/get-started/install)

- **Step 3:** Setup flutter and run locally

  - Go to project root and execute the following command in console to get the required dependencies:

    ```sh
    flutter pub get
    ```

  - Connect your physical device or open simulator. then run your app
    ```sh
    flutter run
    ```

- **Step 4:**
  This project uses inject library that works with code generation, execute the following command to generate files (re-run every time you change one of these files)

  - Firstly, If you have not install flutter_gen yet. [Click here](https://pub.dev/packages/flutter_gen#installation)

  - Secondly, generate files for packages that use build_runner (auto_route, freezed...)

    ```sh
    flutter pub run build_runner build --delete-conflicting-outputs
    ```

- **Step 5:** Download the .env file from [here](https://drive.google.com/file/d/1cn67XQQ2kPsEaOpAK8b8s_Beduc2s9g0/view?usp=drive_link) and place it in the root directory following the structure below:

  ```sh
  ├── lib/
  ├── resources/
  ├── test/
  ├── web/
  │
  ├── .env/
  ```

  ### Android:

  1. Change version and build number in `pubspec.yaml`

     ```
     flutter build appbundle
     ```

  2. Or run command line below to build with your build version

     ```
     flutter build appbundle --build-name=1.2.0 --build-number=2
     ```

  3. Access [Play console](https://play.google.com/console/u/0/developers) to create a new release and upload your build

## Code Conventions

- [analysis_options.yaml](analysis_options.yaml)
- [About code analytics flutter](https://medium.com/flutter-community/effective-code-in-your-flutter-app-from-the-beginning-e597444e1273)

  In Flutter, Modularization will be done at a file level. While building widgets, we have to make sure they stay independent and re-usable as maximum. Ideally, widgets should be easily extractable into an independent project.

- Must know
  - Model name start with `M`: MUser, MProduct, MGroup...
  - Common widget start with `X`: XButton, XText, XAppbar... - These widgets under folder `lib/widgets/`
  - App Constants class or service start with `Add`: AppStyles, AppColor, AppRouter, AppCoordinator,.. and UserPrefs

## Database diagram

![Diagram](resources/images/diagram/db_diagram.png)

## Dependencies

- [flutter_bloc](https://pub.dev/packages/flutter_bloc) A dart package that helps implement the BLoC pattern. Learn more at [bloclibrary.dev](https://bloclibrary.dev/#/)!

- [go_route](https://pub.dev/packages/go_route) It's a Flutter navigation package

- [flutter_gen](https://pub.dev/packages/flutter_gen) The Flutter code generator for your assets, fonts, colors, … — Get rid of all String-based APIs.

- [firebase_core](https://pub.dev/packages/firebase_core) The core Flutter SDK for initializing and connecting your app to Firebase services.

- [firebase_auth](https://pub.dev/packages/firebase_auth) Firebase authentication SDK for Flutter that enables email/password, phone, and social auth.

- [supabase_flutter](https://pub.dev/packages/supabase_flutter) A Flutter client for Supabase, enabling real-time database, authentication, and storage support.

- [flutter_dotenv](https://pub.dev/packages/flutter_dotenv) A package that loads environment variables from .env files into your Flutter app at runtime.

- [google_sign_in](https://pub.dev/packages/google_sign_in) A Flutter plugin that enables Google authentication for Android, iOS, and Web apps.

- [curved_navigation_bar](https://pub.dev/packages/curved_navigation_bar) A custom animated curved bottom navigation bar for Flutter applications.

- [image_picker](https://pub.dev/packages/image_picker) A Flutter plugin for iOS and Android for picking images from the image library, and taking new pictures with the camera.

- [redacted](https://pub.dev/packages/redacted) A widget toolkit for displaying skeleton loading placeholders and redacted UI content.

- [fl_chart](https://pub.dev/packages/fl_chart) A Flutter charting library providing customizable bar, line, pie, and radar charts.

- [diacritic](https://pub.dev/packages/diacritic) A package for removing Vietnamese and other language diacritics from strings.

- [mailer](https://pub.dev/packages/mailer) A Dart email sending library supporting SMTP, attachments, and templated messages.

- [qr_flutter](https://pub.dev/packages/qr_flutter) A Flutter widget for generating and displaying QR codes directly in your app.

- [internet_connection_checker_plus](https://pub.dev/packages/internet_connection_checker_plus) A package to detect the actual internet status and network availability in real time.

- [sqflite](https://pub.dev/packages/sqflite) A Flutter plugin that provides a SQLite database engine for local data storage.

## Screenshot

<div style="display: flex; flex-direction: column; gap: 28px;">

<div>
  <h3>Onboarding</h3>
  <div style="display: flex; flex-wrap: wrap; gap: 12px;">
    <img src="./resources/images/onboarding/get_started.png" width="250">
    <img src="./resources/images/onboarding/on_boarding_1.png" width="250">
    <img src="./resources/images/onboarding/on_boarding_2.png" width="250">
    <img src="./resources/images/onboarding/on_boarding_3.png" width="250">
    <img src="./resources/images/onboarding/on_boarding_4.png" width="250">
  </div>
</div>

<div>
  <h4>Authentication</h4>
  <div style="display: flex; flex-wrap: wrap; gap: 12px;">
    <img src="./resources/images/auth/login.png" width="250">
    <img src="./resources/images/auth/sign_up.png" width="250">
    <img src="./resources/images/auth/forget_password.png" width="250">
  </div>
</div>

<div>
  <h4>Admin</h4>
  <div style="display: flex; flex-wrap: wrap; gap: 12px;">
    <img src="./resources/images/admin/dashboard.png" width="250">
    <img src="./resources/images/admin/dashboard_detail.png" width="250">
    <img src="./resources/images/admin/bus_management.png" width="250">
    <img src="./resources/images/admin/bus_detail.png" width="250">
    <img src="./resources/images/admin/route_management.png" width="250">
    <img src="./resources/images/admin/route_detail.png" width="250">
    <img src="./resources/images/admin/trip_management.png" width="250">
    <img src="./resources/images/admin/trip_detail.png" width="250">
    <img src="./resources/images/admin/profile.png" width="250">
  </div>
</div>

<div>
  <h4>User</h4>
  <div style="display: flex; flex-wrap: wrap; gap: 12px;">
    <img src="./resources/images/client/home.png" width="250">
    <img src="./resources/images/client/result_search.png" width="250">
    <img src="./resources/images/client/detail_trip_search.png" width="250">
    <img src="./resources/images/client/seat_selection.png" width="250">
    <img src="./resources/images/client/payment.png" width="250">
    <img src="./resources/images/client/success_payment.png" width="250">
    <img src="./resources/images/client/profile.png" width="250">
    <img src="./resources/images/client/ticket.png" width="250">
    <img src="./resources/images/client/ticket_detail.png" width="250">
  </div>
</div>

</div>
