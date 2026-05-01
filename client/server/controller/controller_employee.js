import db from "../database.js";
import bcrypt from "bcrypt";
import admin from "./databasecontroller/firebase.js";
import jwt from "jsonwebtoken";

const registerForEmployee = async (req, res) => {
  const {
    first_name,
    family_name,
    E_mail,
    pass_word,
    Adress,
    job,
    phone_number
  } = req.body;

  if (!first_name || !family_name || !E_mail || !pass_word || !Adress || !job || !phone_number) {
    return res.status(400).json({ message: "Missing fields" });
  }

  try {
    // hash password
    const hashed = await bcrypt.hash(pass_word, 10);

    // firebase user
    await admin.auth().createUser({
      email: E_mail,
      password: pass_word,
      displayName: `${first_name} ${family_name}`
    });

    // DB insert
    db.query(
      "INSERT INTO employee (first_name, family_name, E_mail, phone_number, Job, Adrres, password) VALUES (?,?,?,?,?,?,?)",
      [first_name, family_name, E_mail, phone_number, job, Adress, hashed],
      (err, result) => {
        if (err) return res.status(500).json({ err });

        const token = jwt.sign(
          { id: result.insertId },
          process.env.JWT_SECRET,
          { expiresIn: "7d" }
        );

        res.cookie("token", token, { httpOnly: true });

        return res.status(201).json({
          message: "Employee created",
          userId: result.insertId
        });
      }
    );

  } catch (err) {
    return res.status(500).json({ error: err.message });
  }
};

export default registerForEmployee;