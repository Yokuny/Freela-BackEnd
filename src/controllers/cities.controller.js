import db from "../database/db.database.js";
const getCities = async (req, res) => {
  const query = "SELECT nome, id FROM cidades";
  try {
    const { rows: cities } = await db.query(query);

    return res.status(200).json(cities);
  } catch (error) {
    console.log(error);
    return res.status(500).json(error);
  }
};
export default { getCities };
