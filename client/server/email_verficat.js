import admin from "./firebase.js";
import nodemailer from "nodemailer";

// إعداد Nodemailer (يمكنك تغير SMTP حسب البريد تاعك)
const transporter = nodemailer.createTransport({
  host: "smtp.gmail.com",
  port: 587,
  secure: false,
  auth: {
    user: "ma.yahiaoui@esi-sba.dz",
    pass: "12esi#ab",
  },
});

export const sendVerificationEmail = async (userEmail) => {
  try {
    // توليد رابط التحقق من Firebase
    const verificationLink = await admin
      .auth()
      .generateEmailVerificationLink(userEmail);

    // إرسال الإيميل
    await transporter.sendMail({
      from: '"MyApp" <your_email@gmail.com>',
      to: userEmail,
      subject: "Email Verification",
      html: `<p>Click the link below to verify your email:</p>
             <a href="${verificationLink}">Verify Email</a>`,
    });

    console.log("Verification email sent to", userEmail);
  } catch (error) {
    console.error("Error sending verification email:", error);
  }
};
