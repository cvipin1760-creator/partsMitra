/* eslint-disable no-undef */
importScripts('https://www.gstatic.com/firebasejs/10.8.0/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.8.0/firebase-messaging-compat.js');

const firebaseConfig = {
  apiKey: self.env?.VITE_FIREBASE_API_KEY || '',
  authDomain: self.env?.VITE_FIREBASE_AUTH_DOMAIN || '',
  projectId: self.env?.VITE_FIREBASE_PROJECT_ID || '',
  storageBucket: self.env?.VITE_FIREBASE_STORAGE_BUCKET || '',
  messagingSenderId: self.env?.VITE_FIREBASE_MESSAGING_SENDER_ID || '',
  appId: self.env?.VITE_FIREBASE_APP_ID || '',
};

firebase.initializeApp(firebaseConfig);
const messaging = firebase.messaging();

messaging.onBackgroundMessage((payload) => {
  const title = payload.notification?.title || payload.data?.title || 'New Notification';
  const body = payload.notification?.body || payload.data?.message || '';
  const image = payload.data?.imageUrl;
  const route = payload.data?.route || 'offers';
  const offerType = payload.data?.offerType;
  const role = payload.data?.role;

  const options = {
    body,
    icon: '/favicon.ico',
    image,
    data: { route, offerType, role, title, message: body, imageUrl: image },
  };
  self.registration.showNotification(title, options);
});

self.addEventListener('notificationclick', (event) => {
  event.notification.close();
  const data = event.notification.data || {};
  event.waitUntil(
    clients.matchAll({ type: 'window', includeUncontrolled: true }).then((clientList) => {
      for (const client of clientList) {
        if ('focus' in client) {
          client.postMessage({ type: 'webpush', detail: data });
          return client.focus();
        }
      }
      return clients.openWindow('/');
    })
  );
});
