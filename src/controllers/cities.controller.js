import process from "../repositories/cities.repository.js";

const getCities = async (req, res) => {
  try {
    const cities = await process.getCities();
    return res.status(200).json(cities);
  } catch (error) {
    console.log(error);
    return res.status(500).json(error);
  }
};
export default { getCities };
