import process from "../repositories/hosting.repository.js";

const getHosting = async (req, res) => {
  try {
    const hosting = await process.getHosting(req.params.id);

    return res.status(200).json(hosting);
  } catch (error) {
    console.log(error);
    return res.status(500).json(error);
  }
};
const getHostingDetail = async (req, res) => {
  try {
    const hostingDetail = await process.getHostingDetails(req.params.id);

    return res.status(200).json(hostingDetail);
  } catch (error) {
    console.log(error);
    return res.status(500).json(error);
  }
};

export default { getHosting, getHostingDetail };
