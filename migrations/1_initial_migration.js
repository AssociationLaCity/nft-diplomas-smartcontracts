const DiplomasSignatures = artifacts.require("DiplomasSignatures");

module.exports = function (deployer) {
  //deployer.deploy(Migrations);
  deployer.deploy(DiplomasSignatures, 3, [["0x2f4acB6AFd7A119faD3CDba4BF83267EFa001e7e"],
  ["0x2f4acB6AFd7A119faD3CDba4BF83267EFa001e7e"],
  ["0xe29B8C61d9De268e1297B46E8b5B82e0A98eB7b6"]]);
};
