import { initializeApp } from 'firebase/app';
import { getMessaging, onMessage, getToken, isSupported } from 'firebase/messaging';

const firebaseConfig = {
  apiKey: import.meta.env.VITE_FIREBASE_API_KEY || '',
  authDomain: import.meta.env.VITE_FIREBASE_AUTH_DOMAIN || '',
  projectId: import.meta.env.VITE_FIREBASE_PROJECT_ID || '',
  storageBucket: import.meta.env.VITE_FIREBASE_STORAGE_BUCKET || '',
  messagingSenderId: import.meta.env.VITE_FIREBASE_MESSAGING_SENDER_ID || '',
  appId: import.meta.env.VITE_FIREBASE_APP_ID || '',
};

export async function initWebPush() {
  try {
    const supported = await isSupported();
    if (!supported) return;
    const app = initializeApp(firebaseConfig);
    const messaging = getMessaging(app);

    if (Notification.permission !== 'granted') {
      await Notification.requestPermission();
    }

    // Optional: retrieve FCM web token (useful if you want to persist per user)
    try {
      const vapidKey = import.meta.env.VITE_FIREBASE_VAPID_KEY || undefined;
      await getToken(messaging, vapidKey ? { vapidKey } : undefined);
    } catch {}

    onMessage(messaging, (payload) => {
      const data = {
        route: payload.data?.route ?? 'offers',
        offerType: payload.data?.offerType ?? undefined,
        role: payload.data?.role ?? undefined,
        title: payload.notification?.title ?? payload.data?.title ?? 'New Notification',
        message: payload.notification?.body ?? payload.data?.message ?? '',
        imageUrl: payload.data?.imageUrl ?? undefined,
      };
      window.dispatchEvent(new CustomEvent('webpush', { detail: data }));
    });
  } catch (e) {
    console.warn('WebPush init failed:', e);
  }
}
