import express from "express"  ;
import cors from "cors" ;
import "dotenv/config" ;
import cookieParser  from "cookie-parser";
import db from "./controller/databasecontroller/database.js" 
import authrouter from "./routeres/routeautth.js";


const port = process.env.PORT || 5500 ;
const app = express() ;
app.use(express.json()) ;
app.use(cookieParser()) ;
app.use(cors({
  origin: "*", 
  methods: ["GET","POST","PUT","DELETE"],
  credentials: true,
}));

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

app.listen(5500, "0.0.0.0", () => console.log("Server running on all interfaces"));
