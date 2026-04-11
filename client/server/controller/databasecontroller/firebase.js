import admin from "firebase-admin";
import serviceAccount from "./serviceAccountKey.json" assert { type: "json" };
// intial firebase admin 
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

export default admin;
