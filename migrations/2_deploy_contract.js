const CertificadoNacimiento = artifacts.require("CertificadoNacimiento");

module.exports = function (deployer) {
  deployer.deploy(CertificadoNacimiento);
};
