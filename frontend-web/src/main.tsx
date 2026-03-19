
import React from 'react'
import ReactDOM from 'react-dom/client'
import { BrowserRouter } from 'react-router-dom'
import App from './App'
import './index.css'
import { CartProvider } from './context/CartContext'
import { AuthProvider } from './context/AuthContext'
import { LanguageProvider } from './context/LanguageContext'
import { initWebPush } from './services/webpush'

(window as any).global = window

// Register Firebase messaging SW for web push
if ('serviceWorker' in navigator) {
  const swUrl = `${import.meta.env.BASE_URL}firebase-messaging-sw.js`
  navigator.serviceWorker
    .register(swUrl)
    .then(() => {
      initWebPush()
    })
    .catch(() => {
      // Fallback attempt from root
      navigator.serviceWorker
        .register('/firebase-messaging-sw.js')
        .then(() => initWebPush())
        .catch(() => initWebPush())
    })
}

ReactDOM.createRoot(document.getElementById('root')!).render(
  <React.StrictMode>
    <BrowserRouter>
      <LanguageProvider>
        <AuthProvider>
          <CartProvider>
            <App />
          </CartProvider>
        </AuthProvider>
      </LanguageProvider>
    </BrowserRouter>
  </React.StrictMode>,
)
