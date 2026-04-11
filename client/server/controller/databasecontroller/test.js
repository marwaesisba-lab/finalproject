import admin from "./firebase"; 
import "dotenv/config";

async function test() {
  try {
    const link = await admin.auth().generateEmailVerificationLink("your_email@example.com"); // ضع إيميلك
    console.log("Verification link:", link);
  } catch (err) {
    console.error("ERROR:", err);
  }
}

test();
