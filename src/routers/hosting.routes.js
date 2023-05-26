import { Router } from "express";
import process from "../controllers/hosting.controller.js";

const hosting = Router();

hosting.get("/hospedagens", process.getHosting);
hosting.get("/hospedagens/:id", process.getHostingInfo);

export default hosting;
