const etherlime = require('etherlime-lib');
const BookLibrary = require('../build/BookLibrary.json');
const ETHWrapper = require('../build/ETHWrapper.json');


const deploy = async (network, secret, etherscanApiKey) => {

	const deployer = new etherlime.EtherlimeGanacheDeployer();
	await deployer.deploy(BookLibrary);
	await deployer.deploy(ETHWrapper);
};

module.exports = {
	deploy
};