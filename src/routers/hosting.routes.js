import { Router } from "express";
import process from "../controllers/hosting.controller.js";

const hosting = Router();

hosting.get("/hospedagens/:id", process.getHosting);
hosting.get("/hospedagens/details/:id", process.getHostingInfo);

export default hosting;
