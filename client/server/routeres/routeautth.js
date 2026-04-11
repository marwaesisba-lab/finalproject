import express, { Router }  from "express" ;
import { login, Logout, register } from "../controller/controller.js";

const authrouter = Router() ; 
authrouter.post("/auth" , register) ;
authrouter.post("/login" , login) ;
authrouter.post("/logout" , Logout) ;
export default authrouter ;