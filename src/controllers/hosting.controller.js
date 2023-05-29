const getHosting = async (req, res) => {
  return res.send([{ key: "value", key: "value", key: "value" }]);
};
const getHostingInfo = async (req, res) => {
  return res.send("getHostingInfo");
};
export default { getHosting, getHostingInfo };
