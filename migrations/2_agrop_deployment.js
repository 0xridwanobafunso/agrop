const Agrop = artifacts.require('Agrop')

module.exports = function (deployer) {
  deployer.deploy(
    Agrop,
    // monthly
    '5000000000000000',
    // quarterly
    '14250000000000000',
    // yearly
    '58200000000000000'
  )
}
