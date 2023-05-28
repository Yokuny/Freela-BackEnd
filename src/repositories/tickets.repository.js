import db from "../database/db.database.js";

const getTickets = async (id) => {
  const query = `
    SELECT
      v.id,
      cidade_partida.nome AS cidade_partida,
      cidade_destino.nome AS cidade_destino,
      companhia_aerea.nome AS companhia_aerea,
      TO_CHAR(v.hora_partida, 'DD/MM HH24:MI') AS hora_partida_formatada,
      TO_CHAR(v.hora_chegada, 'DD/MM HH24:MI') AS hora_chegada_formatada,
      v.preco
    FROM
      voos v
      JOIN cidades cidade_partida ON v.cidade_partida_id = cidade_partida.id
      JOIN cidades cidade_destino ON v.cidade_destino_id = cidade_destino.id
      JOIN companhias_aereas companhia_aerea ON v.companhia_aerea_id = companhia_aerea.id
    WHERE
      v.cidade_partida_id = $1;
    `;
  try {
    const { rows: tickets } = await db.query(query, [id]);
    if (!tickets) if (!tickets) throw new Error("No tickets found");

    return tickets;
  } catch (error) {
    throw new Error("No tickets found");
  }
};

const getTicketInfo = async (id) => {
  const query = `
  SELECT
    v.id,
    cidade_partida.nome AS origem,
    cidade_destino.nome AS destino,
    companhia_aerea.nome AS companhia,
    TO_CHAR(v.hora_partida, 'DD/MM HH24:MI') AS horaPartida,
    TO_CHAR(v.hora_chegada, 'DD/MM HH24:MI') AS horaChegada,
    v.preco
  FROM
    voos v
    JOIN cidades cidade_partida ON v.cidade_partida_id = cidade_partida.id
    JOIN cidades cidade_destino ON v.cidade_destino_id = cidade_destino.id
    JOIN companhias_aereas companhia_aerea ON v.companhia_aerea_id = companhia_aerea.id
  WHERE
    v.id = $1;
  `;
  try {
    const { rows } = await db.query(query, [id]);
    if (!rows || rows.length === 0) {
      throw new Error("No ticket found");
    }
    return rows[0];
  } catch (error) {
    throw new Error("No ticket found");
  }
};

export default { getTickets, getTicketInfo };

