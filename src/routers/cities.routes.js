import { Router } from "express";
import process from "../controllers/cities.controller.js";

const cities = Router();

cities.get("/", process.getCities);

export default cities;
