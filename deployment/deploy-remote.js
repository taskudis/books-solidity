const etherlime = require('etherlime-lib');
const BookLibrary = require('../build/BookLibrary.json');
const ETHWrapper = require('../build/ETHWrapper.json');


const deploy = async (network, secret, etherscanApiKey) => {

	const deployer = new etherlime.InfuraPrivateKeyDeployer(secret, network, '40c2813049e44ec79cb4d7e0d18de173');
	const result = await deployer.deploy(BookLibrary);
	const ethWrapper = await deployer.deploy(ETHWrapper);

};

module.exports = {
	deploy
};