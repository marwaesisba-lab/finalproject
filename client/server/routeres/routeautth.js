import express, { Router }  from "express" ;
import { login, Logout, register } from "../controller/controller.js";
import registerForEmployee from "../controller/controller_employee.js"

const authrouter = Router() ; 
authrouter.post("/auth" , register) ;
authrouter.post("/login" , login) ;
authrouter.post("/logout" , Logout) ;
authrouter.post("/register-employee", registerForEmployee);

export default authrouter ;