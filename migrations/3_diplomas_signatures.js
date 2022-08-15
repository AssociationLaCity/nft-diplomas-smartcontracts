const EpitaDegreeSigner = artifacts.require("EpitaDegreeSigner");
const EpitaDegree = artifacts.require("EpitaDegree");

module.exports = function (_deployer) {
  _deployer
    .deploy(EpitaDegreeSigner, 3, [
      ["0x2f4acB6AFd7A119faD3CDba4BF83267EFa001e7e"],
      ["0x2f4acB6AFd7A119faD3CDba4BF83267EFa001e7e"],
      ["0x2f4acB6AFd7A119faD3CDba4BF83267EFa001e7e"],
    ])
    .then(function () {
      return _deployer.deploy(
        EpitaDegree,
        EpitaDegreeSigner.address,
        "EPITA",
        "2024"
      );
    });
};
