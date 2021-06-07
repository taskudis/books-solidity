const etherlime = require('etherlime-lib');
const BookLibrary = require('../build/BookLibrary.json');
const LIBWrapper = require('../build/LIBWrapper.json');
const LIBToken = require('../build/LibToken.json');


const deploy = async (network, secret, etherscanApiKey) => {
	const deployer = new etherlime.EtherlimeGanacheDeployer();
	const libWrapper = await deployer.deploy(LIBWrapper);
	const libTokenAddress = await libWrapper.LIBToken();
	await deployer.deploy(BookLibrary, false, libTokenAddress, libWrapper.contractAddress);
};

module.exports = {
	deploy
};