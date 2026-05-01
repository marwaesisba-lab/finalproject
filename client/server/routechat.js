import express from "express";
import db from "../controller/database.js";

const router = express.Router();

// إرسال رسالة وتخزينها
router.post("/", (req, res) => {
  const { sender_id, receiver_id, message } = req.body;
  db.query(
    "INSERT INTO messages(sender_id, receiver_id, message) VALUES (?, ?, ?)",
    [sender_id, receiver_id, message],
    (err, result) => {
      if (err) return res.status(500).json({ error: "Database error" });
      res.json({ status: "message saved" });
    }
  );
});


router.get("/:userId/:employeeId", (req, res) => {
  const { userId, employeeId } = req.params;
  db.query(
    "SELECT * FROM messages WHERE (sender_id = ? AND receiver_id = ?) OR (sender_id = ? AND receiver_id = ?) ORDER BY created_at ASC",
    [userId, employeeId, employeeId, userId],
    (err, result) => {
      if (err) return res.status(500).json({ error: "Database error" });
      res.json(result);
    }
  );
});

export default router;