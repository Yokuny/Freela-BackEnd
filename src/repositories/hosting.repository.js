import db from "../database/db.database.js";

const getHosting = async (id) => {
  const query = `
    SELECT h.*, cidades.nome AS nome_cidade
    FROM hoteis h
    JOIN cidades ON h.cidade_id = cidades.id
    WHERE h.cidade_id = <id_da_cidade>;`;
  try {
    const { rows: hosting } = await db.query(query, [id]);
    if (!hosting) throw new Error("No hosting found");

    return hosting;
  } catch (error) {
    throw new Error("No hosting found");
  }
};

const getHostingDetails = async (req, res) => {
  const { id } = req.params;
  const { rows } = await db.query("SELECT * FROM hoteis WHERE id = $1", [id]);
  return res.json(rows);
};

export default { getHosting, getHostingDetails };
