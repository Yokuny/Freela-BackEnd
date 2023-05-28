import process from "../repositories/tickets.repository.js";
const getTickets = async (req, res) => {
  try {
    const tickets = await process.getTickets(req.params.id);
    return res.status(200).json(tickets);
  } catch (error) {
    return res.status(500).json(error);
  }
};
const getTicketsDetails = async (req, res) => {
  try {
    const ticket = await process.getTicketInfo(req.params.id);

    return res.status(200).json(ticket);
  } catch (error) {
    return res.status(500).json(error);
  }
};
export default { getTickets, getTicketsDetails };
