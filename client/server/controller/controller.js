import bcrypt from "bcrypt";
import  db from "./databasecontroller/database.js";
import jwt from "jsonwebtoken";
import dotenv from "dotenv/config" ;


// ================= REGISTER =================
import admin from "./databasecontroller/firebase.js";
import { transporter } from "./mailer.js";

export const register = async (req, res) => {
  const { firstname, familyname, adress, phonenumber, email, password } = req.body;

  if (!firstname || !familyname || !adress || !phonenumber || !email || !password) {
    return res.status(400).json({
      success: false,
      message: "you are missing detail informations",
    });
  }

  try {

    //  bycrypt pass word 
    const hashcode = await bcrypt.hash(password, 10);

    // 🔹 create user in fire base 
    const firebaseUser = await admin.auth().createUser({
      email,
      password,
      displayName: `${firstname} ${familyname}`,
    });

    // insert users in my sql 

    db.query(
      "INSERT INTO person (first_name, family_name, phone_number, E_mail, Adress, password) VALUES (?, ?, ?, ?, ?, ?)",
      [firstname, familyname, phonenumber, email, adress, hashcode],
      async (err, result) => {
        if (err) {
          console.log("INSERT ERROR:", err);
          return res.status(500).json({ message: "insert failed" });
        }

        const userId = result.insertId;

        // gnerate the link of veificaion email 
        try {
          const verificationLink = await admin.auth().generateEmailVerificationLink(email);

          // 🔹 إرسال الإيميل
          await transporter.sendMail({
            from: '"MyApp" <your_email@gmail.com>',
            to: email,
            subject: "Email Verification",
            html: `<p>Hi ${firstname},</p>
                   <p>Click below to verify your email:</p>
                   <a href="${verificationLink}">Verify Email</a>`,
          });

          console.log("Verification email sent to", email);

          //  genarate token 
          const token = jwt.sign(
            { id: userId },
            process.env.JWT_SECRET,
            { expiresIn: "7d" }
          );

          res.cookie("token", token, {
            httpOnly: true,
            sameSite: "strict",
            secure: false,
          });

        } catch (mailError) {
          console.error("Error sending verification email:", mailError);
        }

        return res.status(201).json({
          success: true,
          message: "User created successfully, verification email sent",
          userId,
        });
      }
    );

  } catch (error) {
    console.log("REGISTER ERROR:", error);
    return res.status(500).json({ message: "server error" });
  }
};

// ================= LOGIN =================
export const login = (req, res) => {
  const { email, password } = req.body;

  if (!email || !password) {
    return res.status(400).json({
      success: false,
      message: "email and password are required",
    });
  }

  db.query(
    "SELECT * FROM person WHERE E_mail = ?",
    [email],
    async (err, results) => {
      if (err) {
        console.log("LOGIN SELECT ERROR:", err);
        return res.status(500).json({ message: "DB error" });
      }

      if (!results || results.length === 0) {
        return res.status(400).json({ message: "user does not exist" });
      }

      try {
        const user = results[0];

        // حماية إضافية
        if (!user.password) {
          return res.status(500).json({ message: "password field missing" });
        }

        // 1️⃣ تحقق من كلمة السر
        const isMatch = await bcrypt.compare(password, user.password);
        if (!isMatch) {
          return res.status(400).json({ message: "password invalid" });
        }

        // 2️⃣ إنشاء JWT
        if (!process.env.JWT_SECRET) {
          console.error("JWT_SECRET is missing");
          return res.status(500).json({ message: "server config error" });
        }

        const token = jwt.sign(
          { id: user.ID },
          process.env.JWT_SECRET,
          { expiresIn: "7d" }
        );

        // 3️⃣ تخزينه في cookie
        res.cookie("token", token, {
          httpOnly: true,
          sameSite: "strict",
          secure: false,
        });

        return res.json({
          success: true,
          message: "login successful",
          userId: user.ID,
        });

      } catch (error) {
        console.error("LOGIN ERROR:", error);
        return res.status(500).json({ message: "login failed" });
      }
    }
  );
};


// ================= LOGOUT =================
export const Logout = (req, res) => {
  try {
    res.clearCookie("token");
    return res.json({
      success: true,
      message: "user logged out successfully",
    });
  } catch (error) {
    return res.json({
      success: false,
      message: error.message,
    });
  }
};
// tester for vlidte email 