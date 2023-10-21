importScripts("https://www.gstatic.com/firebasejs/8.10.0/firebase-app.js");
importScripts("https://www.gstatic.com/firebasejs/8.10.0/firebase-messaging.js");

const firebaseConfig = {
    apiKey: "AIzaSyBOf1cSPtdC3XAVIgatCPtMC2GJqJFZxYg",
    authDomain: "project-neighboard.firebaseapp.com",
    projectId: "project-neighboard",
    storageBucket: "project-neighboard.appspot.com",
    messagingSenderId: "56236883198",
    appId: "1:56236883198:web:880aaeee0fcf911c26f9af"
  };

firebase.initializeApp(firebaseConfig);

const messaging = firebase.messaging();

// Optional:
messaging.onBackgroundMessage((message) => {
  console.log("onBackgroundMessage", message);
});