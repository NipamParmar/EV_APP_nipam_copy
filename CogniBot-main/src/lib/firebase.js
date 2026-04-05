import { initializeApp } from "firebase/app";
import { getAuth } from "firebase/auth";
import { getFirestore } from "firebase/firestore";

// Using inferred configuration from the EV Flutter app.
// Make sure to replace appId with the actual Web App ID from Firebase Console.
const firebaseConfig = {
  apiKey: "AIzaSyD-AsfBSVdeEOcIWwUN4GVWphJ7yLof6nU",
  authDomain: "ev-charging-app-2026.firebaseapp.com",
  projectId: "ev-charging-app-2026",
  storageBucket: "ev-charging-app-2026.firebasestorage.app",
  messagingSenderId: "193668056093",
  appId: "1:193668056093:web:0ab1c2d3e4f5g6h7i8j9" // Placeholder web appId
};

// Initialize Firebase
const app = initializeApp(firebaseConfig);

// Initialize Firebase Authentication and Firestore
export const auth = getAuth(app);
export const db = getFirestore(app);
