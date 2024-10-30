# 🏨 Hostel Allotment Application

This project is a comprehensive Hostel Allotment application that assists users in booking, switching, and tracking their hostel allotments and other associated details effectively. The system provides role-based access control for Users and Admins with separate functionalities for each. Admins can manage hostel layouts, approve/reject hostel change requests, and handle user allocations. Users can register, request hostel changes, and track their booking details in the application. The application supports both online and offline modes, storing information locally using Hive.

## 🚀 Features

### Admin Role
- **Create/Delete Hostels**: Admins have the authority to create or delete hostels.
- **Approve/Reject Hostel Change Requests**: Admins can manage user requests to switch hostels.
- **Allocate/Deallocate Users**: Admins can manage individual user room allocations.
- **Manage Hostel Layouts**: Admins can set the capacity for each wing on a floor.
- **Track Users on Leave**: Admins can view users who are on leave.
  
### User Role
- **Hostel Registration**: Users can register for hostels after login.
- **Hostel Change Request**: Users can apply for a hostel change with floor and wing preferences.
- **Leave Application**: Users can directly apply for leaves with a reason.
- **Dashboard**: Users have access to a dashboard displaying their personal details like name, email, roll number, and current hostel information.
  
### Common Features
- **Role-Based Access Control**: Separate functionalities for Users and Admins.
- **Hostel Layout**: Includes floors, wings.
- **Hostel Change Request Tracking**: Users can track the status of their requests (In Progress/Approved).
- **Offline Support**: Uses Hive for local storage, allowing users to view information offline.
  
### Hostel Change Request Flow
1. **Initiation**: Users select a floor and wing and request a hostel change.
2. **Admin Review**: Admins receive the request and provide approval based on availability.
3. **Status Tracking**: Users can view request statuses (In Progress/Approved).
4. **Automatic Rejection**: If no rooms are available, user cannot the request flow will not get started.
5. **Approval**: Once approved, the user’s hostel information is updated, user gets the notification.

## 🛠️ Tech Stack
- **Frontend**: Flutter
- **Backend**: Firebase (for authentication)
- **Local Storage**: Hive (for offline data)
- **Backend as a Service**: Firebase Firestore (for hostel data and change requests)
  
## 💻 Setup Instructions

### Installation Steps

1. **Clone the repository**:
    ```bash
    git clone https://github.com/sogalabhi/IRIS_2024_ABHIJITH_SOGAL_231CV203.git
    ```
   
2. **Navigate to the project directory**:
    ```bash
    cd IRIS_2024_ABHIJITH_SOGAL_231CV203
    ```
    
3. **Install dependencies**:
    ```bash
    flutter pub get
    ```

4. **Set up Firebase**:
   - Go to [Firebase Console](https://console.firebase.google.com/)
   - Create a new project and set up Firebase Authentication.
   - Download the `google-services.json` (for Android) and `GoogleService-Info.plist` (for iOS) and place them in the appropriate directories (`android/app` and `ios/Runner` respectively).
   
5. **Run the application**:
    ```bash
    flutter run
    ```

### Firebase Setup
- Enable **Email/Password** Authentication in Firebase.
- Enavle Firestore.
  
## 📱 Features Walkthrough

### User Dashboard
- Displays user details such as name, email, roll number, and current hostel information.
- Shows buttons for **Hostel Registration** if no hostel is assigned and **Apply for Hostel Change** if already registered.
- Show the hostel change request status if applied

### Admin Dashboard
- Displays all pending hostel change requests with options to approve or reject.
- Manage hostel layouts, including floors, wings, and room capacities.
- Track and manage user leave status.
- Allocate, Deaalocate, Reallocate users.

### Hostel Change Request
- Users select a floor and wing from the hostel layout.
- Upon submission, the request is sent to admins for approval.
- Users can track their request status (In Progress/Approved).

## ⚙️ Offline Support
The application uses **Hive** for offline data storage, allowing users to access their hostel details and change request status even when the device is offline.

## 🛡️ Role-Based Access Control
- **Users** can register for hostels, request changes, and apply for leave.
- **Admins** can manage hostels, approve/reject change requests, and handle user allocations.

## 🧪 Download and install the apk to test
Link: 
admin login: admin@gmail.com|abhijith
