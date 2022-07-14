const DiplomasSignatures = artifacts.require("DiplomasSignatures");
const DiplomasNFT = artifacts.require("DiplomasNFT");

module.exports = function (_deployer) {
  _deployer
    .deploy(DiplomasSignatures, 3, [
      ["0x2f4acB6AFd7A119faD3CDba4BF83267EFa001e7e"],
      ["0x2f4acB6AFd7A119faD3CDba4BF83267EFa001e7e"],
      ["0xe29B8C61d9De268e1297B46E8b5B82e0A98eB7b6"],
    ])
    .then(function () {
      return _deployer.deploy(
        DiplomasNFT,
        DiplomasSignatures.address,
        "EPITA",
        "2024"
      );
    });
};
