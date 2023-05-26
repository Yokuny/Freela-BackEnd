import db from "../database/db.database.js";

const getHosting = async (req, res) => {
  const { rows } = await db.query("SELECT * FROM hosting");
  return res.json(rows);
};

const getHostingInfo = async (req, res) => {
  const { id } = req.params;
  const { rows } = await db.query("SELECT * FROM hosting WHERE id = $1", [id]);
  return res.json(rows);
};

export default { getHosting, getHostingInfo };
