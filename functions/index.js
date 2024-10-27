const admin = require('firebase-admin');

// Path to your service account key
const serviceAccount = require('./adminsdk.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

// Function to send notifications
const sendNotification = (token, title, body) => {
  const message = {
    notification: {
      title: title,
      body: body,
    },
    token: token,
  };

  admin.messaging().send(message)
    .then((response) => {
      console.log('Successfully sent message:', response);
    })
    .catch((error) => {
      console.log('Error sending message:', error);
    });
};

// Example usage
const deviceToken = 'eGHi7incRWObZyqjzrTAPP:APA91bHJi6I_0ZYu3MfguAuKm2qd9x1IaT6Nqqp6vdAyqsms4z5NGgLc1mhCuvQ6t64KvPvOoKUw5X0ijm64C7JCuZU8KjMje5Rjv3BdRWRJlzWunQPrCC-36Si7tMvgyUPA5nKxvcwt'; // Replace with the actual device token
sendNotification(deviceToken, 'New Request', 'Someone applied for hostel change. Take Actions');