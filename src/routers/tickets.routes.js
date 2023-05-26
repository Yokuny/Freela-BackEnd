import { Router } from "express";
import process from "../controllers/tickets.controller.js";
const tickets = Router();

tickets.get("/ticket/:city", process.getTickets);
tickets.get("/ticket/:id", process.getTicketsDetails);

export default tickets;
