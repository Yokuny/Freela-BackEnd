import { Router } from "express";
import cities from "./cities.routes.js";
import tickets from "./tickets.routes.js";
import hosting from "./hosting.routes.js";

const router = Router();

router.use(cities);
router.use(tickets);
router.use(hosting);

export default router;
