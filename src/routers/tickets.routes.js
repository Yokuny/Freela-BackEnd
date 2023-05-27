import { Router } from "express";
import process from "../controllers/tickets.controller.js";
const tickets = Router();

tickets.get("/ticket/:id", process.getTickets);
tickets.get("/ticket/details/:id", process.getTicketsDetails);

export default tickets;
