import { Router } from "express";
import process from "../controllers/tickets.controller.js";
const tickets = Router();

tickets.get("/passagens", process.getTickets);
tickets.get("/passagens/:id", process.getTicketsDetails);

export default tickets;
