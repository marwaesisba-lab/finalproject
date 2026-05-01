/* import express from "express"  ;
import cors from "cors" ;
import "dotenv/config" ;
import cookieParser  from "cookie-parser";
import db from "./controller/databasecontroller/database.js" 
import authrouter from "./routeres/routeautth.js";
import { Server } from "socket.io";


let onlineUsers = {};
app.get("/employeechat", (req, res) => {
  res.send(`
  <html>
  <head>
  <title>Employee Chat</title>
  </head>

  <body>

  <h2>Employee Chat</h2>

  <input id="userid" placeholder="employee id" value="2"/>
  <input id="target" placeholder="user id" value="1"/>
  <br><br>

  <input id="message" placeholder="message"/>
  <button onclick="send()">Send</button>

  <ul id="messages"></ul>

  <script src="/socket.io/socket.io.js"></script>

  <script>

  const socket = io();

  let employeeId = 2;

  socket.on("connect", () => {
    console.log("connected");

    employeeId = document.getElementById("userid").value;

    socket.emit("join", { userId: employeeId });
  });

  function send(){

    const msg = document.getElementById("message").value;
    const target = document.getElementById("target").value;

    socket.emit("send_message", {
      fromId: employeeId,
      toId: target,
      text: msg
    });

  }

  socket.on("receive_message", (data) => {

    const li = document.createElement("li");
    li.innerText = data.text;

    document.getElementById("messages").appendChild(li);

  });

  </script>

  </body>
  </html>
  `);
});


io.on("connection", (socket) => {

  console.log("A user connected:", socket.id);

  socket.on("join", (data) => {
    onlineUsers[data.userId] = socket.id;
    console.log(data.userId + " connected");
  });

  socket.on("send_message", (data) => {

    const { fromId, toId, text } = data;

    db.query(
      "INSERT INTO messages (sender_id, receiver_id, message) VALUES (?, ?, ?)",
      [fromId, toId, text],
      (err) => {

        if(err) throw err;

        const targetSocketId = onlineUsers[toId];

        if(targetSocketId){

          io.to(targetSocketId).emit("receive_message", {
            fromId,
            toId,
            text
          });

        }

      }
    );

  });

  socket.on("disconnect", () => {

    for(const userId in onlineUsers){

      if(onlineUsers[userId] === socket.id){
        delete onlineUsers[userId];
        break;
      }

    }

  });

});



function getUserNamesForComments(comments) {
  return new Promise((resolve, reject) => {
    if (comments.length === 0) return resolve(comments);

    const userIds = comments.map(c => `'${c.user_id}'`).join(",");
    const sql = `SELECT id, CONCAT(first_name, ' ', family_name) AS full_name FROM person WHERE id IN (${userIds})`;

    db.query(sql, (err, results) => {
      if (err) return reject(err);

      const userMap = {};
      results.forEach(u => {
        userMap[u.id.toString()] = u.full_name; // 👈 حوّل int إلى string
      });

      const commentsWithNames = comments.map(c => ({
        ...c,
        user_name: userMap[c.user_id] || "Unknown" // 👈 fallback
      }));

      resolve(commentsWithNames);
    });
  });
}
const port = process.env.PORT || 5500 ;
const app = express() ;
app.use(express.json()) ;
app.use(cookieParser()) ;
app.use(cors({
  origin: "*", 
  methods: ["GET","POST","PUT","DELETE"],
  credentials: true,
}));
const server = http.createServer(app);

const io = new Server(server, {
  cors: { origin: "*" }
});

app.get("/" , (request , response ) => {
    response.send("API is working") ;
});
app.use("/api/usersmagni" , authrouter) ;
app.use(express.json()) ;

app.get("/users", (req, res) => {
  db.query("SELECT * FROM person", (err, results) => {
    if (err) {
      res.status(500).send("DB error");
      return;
    }
    res.json(results);
  });
});
app.get("/api/users/workers", (req, res) => {
  db.query("SELECT * FROM employee", (err, result) => {
    if (err) {
      return res.status(500).json({ error: "Database error" });
    } else {
      res.json(result); 
    }
  });
});
const  sqlinstrution = "INSERT INTO comments (user_id , post_id , content) Values (? , ? , ? )" ;
app.use(express.json()); // مهم قبل أي route

 app.post("/comments", (req, res) => {
  const { user_id, post_id, content } = req.body ; 

  const sqlinstrution = "INSERT INTO comments(user_id, post_id, content) VALUES(?, ?, ?)";

  db.query(sqlinstrution, [user_id, post_id, content], (err, result) => {
    if (err) {
      return res.status(500).json({ error: err }); 
    } else {
      res.json({
        message: "Comment added successfully",
      });
    }
  });
}); 
app.get("/comments/:postId", (req, res) => {
  const postId = req.params.postId;
  const sql = `
    SELECT content, created_at, user_name
    FROM comments
    WHERE post_id = ?
    ORDER BY created_at DESC
  `;
  db.query(sql, [postId], (err, results) => {
    if (err) return res.status(500).json({ error: err });
    res.json({ comments: results });
  });
});


app.get("/comments_with_names/:postId", async (req, res) => {
  const postId = req.params.postId;
  const sqlComments = "SELECT content, created_at, user_id FROM comments WHERE post_id = ? ORDER BY created_at DESC";

  db.query(sqlComments, [postId], async (err, comments) => {
    if (err) return res.status(500).json({ error: err });

    try {
      const commentsWithNames = await getUserNamesForComments(comments);
      res.json({ comments: commentsWithNames });
    } catch (e) {
      res.status(500).json({ error: e.message });
    }
  });
});
app.post("/showusers" , (req , res ) => {
  const {first_name,family_name,date , timer, 	appointemet , workerSelect} = req.body ;
  const sqlinstrution = "Insert Into evenements (first_name,family_name,date,timer,appointemet , workerSelect) Values(?,?,?,?,? ,?)";
  db.query(sqlinstrution , [first_name , family_name , date , timer , appointemet, workerSelect], (err ,result)=>{
    if (err) {
      return res.status(500).json({ error: err });
    } else {
      res.json({
        message: "add user succesuffly ",
      });
    }

  })

}) ;
/* app.get("/getusers", (req, res) => {
  const instr = "SELECT * FROM evenements";

  db.query(instr, (err, result) => {   // 
    if (err) {
      console.error(err);
      return res.status(500).json({ error: "Database error" });
    } else {
      res.json(result);
    }
  });
}); */
  /* app.get("/getusers/:worker", (req, res) => {
  const worker = req.params.worker;

  const instr = "SELECT * FROM evenements WHERE workerSelect = ?";

  db.query(instr, [worker], (err, result) => {
    if (err) {
      console.error(err);
      return res.status(500).json({ error: "Database error" });
    } else {
      res.json(result);
    }
  });
});
// add payment and reting in data base 
app.post("/addpayementandrate" , (req , res ) => {
  const {first_name , family_name , payment ,RateStarts} = req.body ;
  const sqlinstrution = "Insert into  paymentandrate (first_name,family_name,payment,RateStars) Values(?,?,?,?)" ;
  db.query(sqlinstrution , [first_name , family_name , payment , RateStarts ] , (err,result)=>{
    if (err) {
      return res.status(500).json({ error: err });
    } else {
      res.json({
        message: "add information succesuffuly  ",
      });
    }

  }) 
})
server.listen(5500, "0.0.0.0", () => console.log("Server running on all interfaces")); */
  
/* 
import express from "express";
import http from "http";
import cors from "cors";
import "dotenv/config";
import cookieParser from "cookie-parser";
import db from "./database.js";
import authrouter from "./routeres/routeautth.js";
import { Server } from "socket.io";

const app = express();
const port = process.env.PORT || 5500;

// إعدادات Middleware
app.use(express.json());
app.use(cookieParser());
app.use(cors({
    origin: "*",
    methods: ["GET", "POST", "PUT", "DELETE"],
    credentials: true,
}));

// إنشاء السيرفر
const server = http.createServer(app);
const io = new Server(server, {
    cors: { origin: "*" }
});

let onlineUsers = {};

// --- نظام الدردشة (Socket.io) ---
io.on("connection", (socket) => {
    console.log("🟢 A user connected:", socket.id);

    socket.on("join", (data) => {
        if (data.userId) {
            onlineUsers[data.userId.toString()] = socket.id;
            console.log(`👤 User ${data.userId} connected`);
        }
    });

    socket.on("send_message", (data) => {
        const { fromId, toId, text } = data;
        if (!fromId || !toId || !text) return;

        const sql = "INSERT INTO messages (sender_id, receiver_id, message) VALUES (?, ?, ?)";
        db.query(sql, [fromId, toId, text], (err) => {
            if (err) {
                console.error("❌ DB Error:", err);
                return;
            }
            const targetSocketId = onlineUsers[toId.toString()];
            if (targetSocketId) {
                io.to(targetSocketId).emit("receive_message", { fromId, toId, text });
            }
        });
    });

    // جلب تاريخ المحادثة (يجب أن يكون داخل الاتصال)
    socket.on("get_history", (data) => {
        const { user1Id, user2Id } = data;
        const sql = "SELECT * FROM messages WHERE (sender_id = ? AND receiver_id = ?) OR (sender_id = ? AND receiver_id = ?) ORDER BY id ASC";
        db.query(sql, [user1Id, user2Id, user2Id, user1Id], (err, results) => {
            if (!err) socket.emit("history", { messages: results });
        });
    });

    socket.on("disconnect", () => {
        for (const userId in onlineUsers) {
            if (onlineUsers[userId] === socket.id) {
                delete onlineUsers[userId];
                console.log(`🔴 User ${userId} disconnected`);
                break;
            }
        }
    });
});

// --- الروابط (Routes) ---

app.get("/", (req, res) => res.send("API is working"));

// راوتر المصادقة
app.use("/api/usersmagni", authrouter);

// جلب المستخدمين والموظفين (Workers)
app.get("/users", (req, res) => {
    db.query("SELECT * FROM person", (err, results) => {
        if (err) return res.status(500).send("DB error");
        res.json(results);
    });
});

app.get("/api/users/workers", (req, res) => {
    db.query("SELECT * FROM employee", (err, result) => {
        if (err) {
            console.error("❌ Workers Error:", err);
            return res.status(500).json({ error: "Database error" });
        }
        res.json(result);
    });
});

// جلب صندوق الوارد
app.get("/api/chat/inbox/:workerId", (req, res) => {
    const workerId = req.params.workerId;
    const sql = `
        SELECT m.sender_id, m.receiver_id, m.message, m.created_at, 
        p.first_name, p.family_name 
        FROM messages m
        JOIN person p ON (p.id = m.sender_id OR p.id = m.receiver_id)
        WHERE (m.sender_id = ? OR m.receiver_id = ?) AND p.id != ?
        GROUP BY p.id
        ORDER BY m.created_at DESC`;

    db.query(sql, [workerId, workerId, workerId], (err, results) => {
        if (err) return res.status(500).json({ error: err.message });
        res.json(results);
    });
});

// المواعيد والتعليقات والوظائف الأخرى تبقى كما هي
app.post("/comments", (req, res) => {
    const { user_id, post_id, content } = req.body;
    const sql = "INSERT INTO comments(user_id, post_id, content) VALUES(?, ?, ?)";
    db.query(sql, [user_id, post_id, content], (err, result) => {
        if (err) return res.status(500).json({ error: err });
        res.json({ message: "Comment added successfully" });
    });
});

app.post("/showusers", (req, res) => {
    const { first_name, family_name, date, timer, appointemet, workerSelect } = req.body;
    const sql = "INSERT INTO evenements (first_name, family_name, date, timer, appointemet, workerSelect) VALUES(?,?,?,?,?,?)";
    db.query(sql, [first_name, family_name, date, timer, appointemet, workerSelect], (err, result) => {
        if (err) return res.status(500).json({ error: err });
        res.json({ message: "Appointment added successfully" });
    });
});
// جلب المواعيد الخاصة بعامل معين بناءً على اسمه
app.get("/getusers/:workerName", (req, res) => {
    const workerName = req.params.workerName;
    console.log("🔍 Searching for worker:", workerName);
    
    // استعلام لجلب المواعيد من جدول evenements
    const sql = "SELECT * FROM evenements WHERE workerSelect = ? ORDER BY date DESC, timer DESC";
    
    db.query(sql, [workerName], (err, results) => {
        if (err) {
            console.error("❌ Error fetching appointments:", err);
            return res.status(500).json({ error: "Database error" });
        }
        res.json(results);
    });
});

// تشغيل السيرفر
server.listen(port, "0.0.0.0", () => {
    console.log(`🚀 Server running on http://localhost:${port}`);
}); */
/* import express from "express";
import http from "http";
import cors from "cors";
import cookieParser from "cookie-parser";
import "dotenv/config";

import db from "./database.js";
import authrouter from "./routeres/routeautth.js";
import { Server } from "socket.io";

const app = express();
const server = http.createServer(app);

const io = new Server(server, {
  cors: { origin: "*" }
});

app.use(express.json());
app.use(cookieParser());
app.use(cors({ origin: "*", methods: ["GET","POST","PUT","DELETE"] }));

// ================= ROUTES =================

app.use("/api/usersmagni", authrouter);

app.get("/", (req, res) => {
  res.send("API is working");
});

// USERS
app.get("/users", (req, res) => {
  db.query("SELECT * FROM person", (err, result) => {
    if (err) return res.status(500).send(err);
    res.json(result);
  });
});

// WORKERS
app.get("/api/users/workers", (req, res) => {
  db.query("SELECT * FROM employee", (err, result) => {
    if (err) return res.status(500).json(err);
    res.json(result);
  });
});

// ================= SOCKET =================

let onlineUsers = {};

io.on("connection", (socket) => {
  socket.on("join", ({ userId }) => {
    onlineUsers[userId] = socket.id;
  });

  socket.on("send_message", (data) => {
    const { fromId, toId, text } = data;

    db.query(
      "INSERT INTO messages (sender_id, receiver_id, message) VALUES (?,?,?)",
      [fromId, toId, text]
    );

    const target = onlineUsers[toId];
    if (target) {
      io.to(target).emit("receive_message", data);
    }
  });

  socket.on("disconnect", () => {
    for (let id in onlineUsers) {
      if (onlineUsers[id] === socket.id) {
        delete onlineUsers[id];
      }
    }
  });

});

// ================= START =================

server.listen(5500, () => {
  console.log("Server running on http://127.0.0.1:5500");
}); 
/*/
/* claude ai */ 
/* 
 */



// second part ai // 
/* 

*/
// serv 1 ;


 import express from "express";
import cors from "cors";
import "dotenv/config";
import cookieParser from "cookie-parser";
import http from "http";
import { Server } from "socket.io";
import db from "./controller/databasecontroller/database.js";
import authrouter from "./routeres/routeautth.js";
import { error } from "console";
import admin from "firebase-admin";
import { json } from "stream/consumers";

const messaging = admin.messaging();

const app = express();
const server = http.createServer(app);
const io = new Server(server, {
  cors: { origin: "*" },
});

app.use(express.json());
app.use(cookieParser());
app.use(cors({
  origin: "*",
  methods: ["GET", "POST", "PUT", "DELETE"],
  credentials: true,
}));

app.get("/", (req, res) => {
  res.send("API is working");
});

app.use("/api/usersmagni", authrouter);

app.get("/users", (req, res) => {
  db.query("SELECT * FROM person", (err, results) => {
    if (err) return res.status(500).send("DB error");
    res.json(results);
  });
});

app.get("/api/users/workers", (req, res) => {
  db.query("SELECT * FROM employee order by rating DESC", (err, result) => {
    if (err) return res.status(500).json({ error: "Database error" });
    res.json(result);
  });
});

app.post("/comments", (req, res) => {
  const { user_id, post_id, content } = req.body;
  const sql = "INSERT INTO comments(user_id, post_id, content) VALUES(?, ?, ?)";
  db.query(sql, [user_id, post_id, content], (err) => {
    if (err) return res.status(500).json({ error: err });
    res.json({ message: "Comment added successfully" });
  });
});

app.get("/comments/:postId", (req, res) => {
  const postId = req.params.postId;
  const sql = `
    SELECT content, created_at, user_name
    FROM comments
    WHERE post_id = ?
    ORDER BY created_at DESC
  `;
  db.query(sql, [postId], (err, results) => {
    if (err) return res.status(500).json({ error: err });
    res.json({ comments: results });
  });
});

app.get("/comments_with_names/:postId", async (req, res) => {
  const postId = req.params.postId;
  const sql = "SELECT content, created_at, user_id FROM comments WHERE post_id = ? ORDER BY created_at DESC";

  db.query(sql, [postId], async (err, comments) => {
    if (err) return res.status(500).json({ error: err });
    try {
      const commentsWithNames = await getUserNamesForComments(comments);
      res.json({ comments: commentsWithNames });
    } catch (e) {
      res.status(500).json({ error: e.message });
    }
  });
});

// ✅ FIX: زدنا user_id
app.post("/showusers", (req, res) => {
  const { first_name, family_name, date, timer, appointemet, workerSelect, user_id } = req.body;
  const sql = "INSERT INTO evenements (first_name, family_name, date, timer, appointemet, workerSelect, user_id) VALUES(?, ?, ?, ?, ?, ?, ?)";
  db.query(sql, [first_name, family_name, date, timer, appointemet, workerSelect, user_id], (err) => {
    if (err) {
      console.error("showusers error:", err);
      return res.status(500).json({ error: err });
    }
    res.json({ message: "add user successfully" });
  });
});
// payment method correct forma
app.post("/payment", (req, res) => {
  const { first_name, family_name, idofuser, paymentvalue } = req.body;
  const inst = "INSERT INTO paymentandrate (first_name, family_name, payement, employee_selected) VALUES (?, ?, ?, ?)";
  
  db.query(inst, [first_name, family_name, paymentvalue, idofuser], (err) => {
    if (err) {
      return res.status(500).json({ error: err });
    }
    res.json({ message: "payment success" });
  });

}); 
// get valu of payment for payed person 
app.get("/seevalueofpayed/:employeeId", (req, res) => {
  const employeeId = req.params.employeeId;

  // "payement" مش "payment" ← كيما في الـ database
  const sqlsta = "SELECT * FROM paymentandrate WHERE employee_selected = ? AND payement > 0 AND payement IS NOT NULL";

  db.query(sqlsta, [employeeId], (err, results) => {
    if (err) {
      return res.status(500).json({ error: err });
    }
    res.status(200).json(results);
  });
});
// save uid 
app.post("/api/employee/saveuid", (req, res) => {
  const { email, firebase_uid } = req.body;
  db.query(
    "UPDATE employee SET firebase_uid = ? WHERE E_mail = ?",
    [firebase_uid, email],
    (err) => {
      if (err) return res.status(500).json({ error: err });
      res.json({ message: "ok" });
    }
  );
});


app.get("/getusers/:worker", (req, res) => {
  const worker = req.params.worker;
  const sql = "SELECT * FROM evenements WHERE workerSelect = ?";
  db.query(sql, [worker], (err, result) => {
    if (err) return res.status(500).json({ error: "Database error" });
    res.json(result);
  });
});

//  for notifications employee with client 
app.post("/notificationssend", (req, res) => {
  const { content, user_id, employee_id } = req.body;
  const sql = "INSERT INTO notifications(content, user_id, employee_id) VALUES (?, ?, ?)";
  
  db.query(sql, [content, user_id, employee_id], (err) => {
    if (err) {
      return res.json({ error: err });
    } else {
      return res.json({ message: "Notification sent successfully" });
    }
  });
});
// get notifications 
app.get("/getnotificationsfromemployee", (req, res) => {
  const { user_id } = req.query; // get user_id 
  const sql = "SELECT * FROM notifications WHERE user_id = ?";
  
  db.query(sql, [user_id], (err, results) => {
    if (err) {
      return res.json({ error: err });
    } else {
      return res.json(results); // 
    }
  });
});

// for problem of id  ; 
app.get("/api/usersmagni/getid", (req, res) => {
  const { email } = req.query;
  db.query(
    "SELECT ID FROM person WHERE E_mail = ?", 
    [email],
    (err, results) => {
      if (err) return res.status(500).json({ error: err });
      if (results.length === 0) return res.status(404).json({ error: "not found" });
      res.json({ id: results[0].ID });
    }
  );
});
app.get("/api/employee/getid", (req, res) => {
  const { email } = req.query;
  db.query(
    "SELECT id FROM employee WHERE E_mail = ?",
    [email],
    (err, results) => {
      if (err) return res.status(500).json({ error: err });
      if (results.length === 0) return res.status(404).json({ error: "not found" });
      res.json({ id: results[0].id });
    }
  );
});
// في index.js — تأكد إن اسم العمود صح
// جرب هذا الـ route مؤقتاً لترى البيانات
app.get("/api/employee/debug", (req, res) => {
  db.query("SELECT id, E_mail FROM employee LIMIT 5", (err, results) => {
    if (err) return res.status(500).json({ error: err });
    res.json(results);
  });
});
// rating  part 
app.post("/submitratting", (req, res) => {
  const { RateStars, employee_id } = req.body;

  // ✅ أولاً جيب الـ id الحقيقي من جدول employee
  const getIdSql = `SELECT id FROM employee LIMIT 1`;

  db.query(getIdSql, (err, idResult) => {
    if (err) return res.status(500).json({ error: err.message });

    const realEmployeeId = idResult[0].id; // ✅ الـ id الحقيقي
    console.log("🔍 realEmployeeId:", realEmployeeId);

    const insertSql = "INSERT INTO ratingsofemployee (RateStars, employee_selected) VALUES (?, ?)";

    db.query(insertSql, [RateStars, realEmployeeId], (err) => {
      if (err) return res.status(500).json({ error: err.message });

      const avgSql = `SELECT AVG(RateStars) as avg_rating FROM ratingsofemployee WHERE employee_selected = ?`;

      db.query(avgSql, [realEmployeeId], (err, avgResult) => {
        if (err) return res.status(500).json({ error: err.message });

        const avgRating = avgResult[0].avg_rating;
        console.log("⭐ avgRating:", avgRating);

        const updateSql = `UPDATE employee SET rating = ? WHERE id = ?`;

        db.query(updateSql, [avgRating, realEmployeeId], (err, updateResult) => {
          if (err) return res.status(500).json({ error: err.message });
          console.log("✅ affectedRows:", updateResult.affectedRows);
          return res.status(200).json({ message: "Rate added successfully" });
        });
      });
    });
  });
});
// ─── Socket.IO ────────────────────────────────────────────────────────────────
let onlineUsers = {};

io.on("connection", (socket) => {
  console.log("A user connected:", socket.id);

  socket.on("join", (data) => {
    if (data.userId) {
      onlineUsers[data.userId.toString()] = socket.id;
      console.log(data.userId + " connected");
    }
  });

  socket.on("get_history", (data) => {
  const { user1Id, user2Id } = data;
  const sql = `
    SELECT sender_id, receiver_id, message, created_at
    FROM messages
    WHERE (sender_id = ? AND receiver_id = ?)
       OR (sender_id = ? AND receiver_id = ?)
    ORDER BY created_at ASC
  `;
  db.query(sql, [user1Id, user2Id, user2Id, user1Id], (err, results) => {
    if (err) return;
    socket.emit("history", { messages: results });
  });

  });

  // ✅ ADD: get_all_messages
  socket.on("get_all_messages", (data) => {
    const { userId } = data;
    const sql = `
      SELECT sender_id, receiver_id, message, created_at
      FROM messages
      WHERE sender_id = ? OR receiver_id = ?
      ORDER BY created_at DESC
    `;
    db.query(sql, [userId, userId], (err, results) => {
      if (err) {
        console.error("get_all_messages error:", err);
        return;
      }
      socket.emit("all_messages", { messages: results });
    });
  });

 socket.on("send_message", (data) => {
  const { fromId, toId, text } = data;
  if (!fromId || !toId || !text) return;
  db.query(
    "INSERT INTO messages (sender_id, receiver_id, message) VALUES (?, ?, ?)",
    [fromId, toId, text],
    (err) => {
      if (err) return;
      const targetSocketId = onlineUsers[toId];
      if (targetSocketId) {
        io.to(targetSocketId).emit("receive_message", { fromId, toId, text });
      }
    }
  );
});
  // helps for chat page 
  app.get("/api/usersmagni/getid", (req, res) => {
  const { email } = req.query;
  db.query(
    "SELECT ID FROM person WHERE email = ?",
    [email],
    (err, results) => {
      if (err) return res.status(500).json({ error: err });
      if (results.length === 0) return res.status(404).json({ error: "not found" });
      res.json({ id: results[0].id });
    }
  );
});
  socket.on("disconnect", () => {
    for (const userId in onlineUsers) {
      if (onlineUsers[userId] === socket.id) {
        delete onlineUsers[userId];
        console.log(userId + " disconnected");
        break;
      }
    }
  });
});

// ─── Helper Functions ─────────────────────────────────────────────────────────
function getUserNamesForComments(comments) {
  return new Promise((resolve, reject) => {
    if (comments.length === 0) return resolve(comments);

    const userIds = comments.map(c => `'${c.user_id}'`).join(",");
    const sql = `SELECT id, CONCAT(first_name, ' ', family_name) AS full_name FROM person WHERE id IN (${userIds})`;

    db.query(sql, (err, results) => {
      if (err) return reject(err);

      const userMap = {};
      results.forEach(u => {
        userMap[u.id.toString()] = u.full_name;
      });

      const commentsWithNames = comments.map(c => ({
        ...c,
        user_name: userMap[c.user_id] || "Unknown",
      }));

      resolve(commentsWithNames);
    });
  });
}

const port = process.env.PORT || 5500;
server.listen(port, "0.0.0.0", () => console.log(`Server running on port ${port}`)); 


// serv 2 

