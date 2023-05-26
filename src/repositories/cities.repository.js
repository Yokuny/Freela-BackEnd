import db from "../database/db.database.js";

const getCities = async (req, res) => {
  const { rows } = await db.query("SELECT * FROM cities");
  return res.json(rows);
};

const getCitiesDetails = async (req, res) => {
  const { id } = req.params;
  const { rows } = await db.query("SELECT * FROM cities WHERE id = $1", [id]);
  return res.json(rows);
};

export default { getCities, getCitiesDetails };
