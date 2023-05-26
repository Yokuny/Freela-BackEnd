import db from "../database/db.database.js";

const getCities = async () => {
  const query = "SELECT nome, id FROM cidades";
  try {
    const { rows: cities } = await db.query(query);
    if (cities.length === 0) {
      throw new Error("No cities found");
    }
    return cities;
  } catch (error) {
    throw new Error("No cities found");
  }
};

export default { getCities };
