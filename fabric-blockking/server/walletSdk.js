/*
 * Copyright IBM Corp. All Rights Reserved.
 *
 * SPDX-License-Identifier: Apache-2.0
 */

'use strict';

const { Gateway, Wallets } = require('fabric-network');
const FabricCAServices = require('fabric-ca-client');
const path = require('path');
const { buildCAClient, registerAndEnrollUser, enrollAdmin } = require('./CAUtil.js');
const { buildCCPOrg1, buildCCPOrg2 ,buildCCPOrg3 ,buildCCPOrg4, buildWallet } = require('./AppUtil.js');
const channelName = 'trade';
const chaincodeName = 'wallet';
const org1 = 'Org1MSP';
const org2 = 'Org2MSP';
const org3 = 'Org3MSP';
const org4 = 'Org4MSP';
const Org1UserId = 'appUser1';
const Org2UserId = 'appUser2';
const Org3UserId = 'appUser3';
const Org4UserId = 'appUser4';
const RED = '\x1b[31m\n';
const GREEN = '\x1b[32m\n';
const RESET = '\x1b[0m';
function prettyJSONString(inputString) {
	return JSON.stringify(JSON.parse(inputString), null, 2);
}
async function initGatewayForOrg1() {
	console.log(`${GREEN}--> Fabric client user & Gateway init: Using Org1 identity to Org1 Peer${RESET}`);
	// build an in memory object with the network configuration (also known as a connection profile)
	const ccpOrg1 = buildCCPOrg1();

	// build an instance of the fabric ca services client based on
	// the information in the network configuration
	const caOrg1Client = buildCAClient(FabricCAServices, ccpOrg1, 'ca.org1.14.49.119.248');

	// setup the wallet to cache the credentials of the application user, on the app server locally
	const walletPathOrg1 = path.join(__dirname, 'wallet', 'org1');
	const walletOrg1 = await buildWallet(Wallets, walletPathOrg1);

	// in a real application this would be done on an administrative flow, and only once
	// stores admin identity in local wallet, if needed
	await enrollAdmin(caOrg1Client, walletOrg1, org1);
	// register & enroll application user with CA, which is used as client identify to make chaincode calls
	// and stores app user identity in local wallet
	// In a real application this would be done only when a new user was required to be added
	// and would be part of an administrative flow
	await registerAndEnrollUser(caOrg1Client, walletOrg1, org1, Org1UserId, 'org1.department1');

	try {
		// Create a new gateway for connecting to Org's peer node.
		const gatewayOrg1 = new Gateway();
		//connect using Discovery enabled
		await gatewayOrg1.connect(ccpOrg1,
			{ wallet: walletOrg1, identity: Org1UserId, discovery: { enabled: true, asLocalhost: true } });

		return gatewayOrg1;
	} catch (error) {
		console.error(`Error in connecting to gateway for Org1: ${error}`);
		process.exit(1);
	}
}

async function initGatewayForOrg2() {
	console.log(`${GREEN}--> Fabric client user & Gateway init: Using Org2 identity to Org2 Peer${RESET}`);
	const ccpOrg2 = buildCCPOrg2();
	const caOrg2Client = buildCAClient(FabricCAServices, ccpOrg2, 'ca.org2.14.49.119.248');

	const walletPathOrg2 = path.join(__dirname, 'wallet', 'org2');
	const walletOrg2 = await buildWallet(Wallets, walletPathOrg2);

	await enrollAdmin(caOrg2Client, walletOrg2, org2);
	await registerAndEnrollUser(caOrg2Client, walletOrg2, org2, Org2UserId, 'org2.department1');

	try {
		// Create a new gateway for connecting to Org's peer node.
		const gatewayOrg2 = new Gateway();
		await gatewayOrg2.connect(ccpOrg2,
			{ wallet: walletOrg2, identity: Org2UserId, discovery: { enabled: true, asLocalhost: true } });

		return gatewayOrg2;
	} catch (error) {
		console.error(`Error in connecting to gateway for Org2: ${error}`);
		process.exit(1);
	}
}
async function initGatewayForOrg3() {
	console.log(`${GREEN}--> Fabric client user & Gateway init: Using Org3 identity to Org3 Peer${RESET}`);
	// build an in memory object with the network configuration (also known as a connection profile)
	const ccpOrg3 = buildCCPOrg3();

	// build an instance of the fabric ca services client based on
	// the information in the network configuration
	const caOrg3Client = buildCAClient(FabricCAServices, ccpOrg3, 'ca.org3.14.49.119.248');

	// setup the wallet to cache the credentials of the application user, on the app server locally
	const walletPathOrg3 = path.join(__dirname, 'wallet', 'org3');
	const walletOrg3 = await buildWallet(Wallets, walletPathOrg3);

	// in a real application this would be done on an administrative flow, and only once
	// stores admin identity in local wallet, if needed
	await enrollAdmin(caOrg3Client, walletOrg3, org3);
	// register & enroll application user with CA, which is used as client identify to make chaincode calls
	// and stores app user identity in local wallet
	// In a real application this would be done only when a new user was required to be added
	// and would be part of an administrative flow
	await registerAndEnrollUser(caOrg3Client, walletOrg3, org3, Org3UserId, 'org3.department1');

	try {
		// Create a new gateway for connecting to Org's peer node.
		const gatewayOrg3 = new Gateway();
		//connect using Discovery enabled
		await gatewayOrg3.connect(ccpOrg3,
			{ wallet: walletOrg3, identity: Org3UserId, discovery: { enabled: true, asLocalhost: true } });

		return gatewayOrg3;
	} catch (error) {
		console.error(`Error in connecting to gateway for Org3: ${error}`);
		process.exit(1);
	}
}

async function initGatewayForOrg4() {
	console.log(`${GREEN}--> Fabric client user & Gateway init: Using Org4 identity to Org4 Peer${RESET}`);
	const ccpOrg4 = buildCCPOrg4();
	const caOrg4Client = buildCAClient(FabricCAServices, ccpOrg4, 'ca.org4.14.49.119.248');

	const walletPathOrg4 = path.join(__dirname, 'wallet', 'org4');
	const walletOrg4 = await buildWallet(Wallets, walletPathOrg4);

	await enrollAdmin(caOrg4Client, walletOrg4, org4);
	await registerAndEnrollUser(caOrg4Client, walletOrg4, org4, Org4UserId, 'org4.department1');

	try {
		// Create a new gateway for connecting to Org's peer node.
		const gatewayOrg4 = new Gateway();
		await gatewayOrg4.connect(ccpOrg4,
			{ wallet: walletOrg4, identity: Org4UserId, discovery: { enabled: true, asLocalhost: true } });

		return gatewayOrg4;
	} catch (error) {
		console.error(`Error in connecting to gateway for Org4: ${error}`);
		process.exit(1);
	}
}

async function send1(type, func, args, res) {
	try {
			/** ******* Fabric client init: Using Org1 identity to Org1 Peer ******* */
			const gatewayOrg1 = await initGatewayForOrg1();
			const networkOrg1 = await gatewayOrg1.getNetwork(channelName);
			const contractOrg1 = networkOrg1.getContract(chaincodeName);            
			try {
				if(type == true) { // type true : submit transaction, not only query
					let result = await contractOrg1.submitTransaction(func, ...args);
					const resultJSONString = result.toString();
					res.send(resultJSONString);
					console.log('Submit transaction success');
				} else {
					const result = await contractOrg1.evaluateTransaction(func, ...args);
					console.log('Evaluate transaction success');
					const resultJSONString = prettyJSONString(result.toString());
					console.log(`*** Result: ${resultJSONString}`);
					const resultString = result.toString();
					console.log(`*** Result: ${resultString}`);
					res.send(resultJSONString);
				}
			}
			finally {
			// Disconnect from the gateway when the application is closing
			// This will close all connections to the network
			gatewayOrg1.disconnect();
			}
		} catch (error) {
			console.error(`${error}`);
			res.send(`${error}`)
		}
}
async function send2(type, func, args, res) {
	try {
			/** ******* Fabric client init: Using Org2 identity to Org2 Peer ******* */
			const gatewayOrg2 = await initGatewayForOrg2();
			const networkOrg2 = await gatewayOrg2.getNetwork(channelName);
			const contractOrg2 = networkOrg2.getContract(chaincodeName);            
			try {
				if(type == true) { // type true : submit transaction, not only query
					let result = await contractOrg2.submitTransaction(func, ...args);
					const resultJSONString = result.toString();
					res.send(resultJSONString);
					console.log('Submit transaction success');
				} else {
					const result = await contractOrg2.evaluateTransaction(func, ...args);
					console.log('Evaluate transaction success');
					const resultJSONString = prettyJSONString(result.toString());
					console.log(`*** Result: ${resultJSONString}`);
					const resultString = result.toString();
					console.log(`*** Result: ${resultString}`);
					res.send(resultJSONString);
				}
			}
			finally {
			// Disconnect from the gateway when the application is closing
			// This will close all connections to the network
			gatewayOrg2.disconnect();
			}
		} catch (error) {
			console.error(`${error}`);
			res.send(`${error}`)
		}
}
async function send3(type, func, args, res) {
	try {
			/** ******* Fabric client init: Using Org3 identity to Org3 Peer ******* */
			const gatewayOrg3 = await initGatewayForOrg3();
			const networkOrg3 = await gatewayOrg3.getNetwork(channelName);
			const contractOrg3 = networkOrg3.getContract(chaincodeName);            
			try {
				if(type == true) { // type true : submit transaction, not only query
					let result = await contractOrg3.submitTransaction(func, ...args);
					const resultJSONString = result.toString();
					res.send(resultJSONString);
					console.log('Submit transaction success');
				} else {
					const result = await contractOrg3.evaluateTransaction(func, ...args);
					console.log('Evaluate transaction success');
					const resultJSONString = prettyJSONString(result.toString());
					console.log(`*** Result: ${resultJSONString}`);
					const resultString = result.toString();
					console.log(`*** Result: ${resultString}`);
					res.send(resultJSONString);
				}
			}
			finally {
			// Disconnect from the gateway when the application is closing
			// This will close all connections to the network
			gatewayOrg3.disconnect();
			}
		} catch (error) {
			console.error(`${error}`);
			res.send(error);
		}
}
async function send4(type, func, args, res) {
	try {
			/** ******* Fabric client init: Using Org4 identity to Org4 Peer ******* */
			const gatewayOrg4 = await initGatewayForOrg4();
			const networkOrg4 = await gatewayOrg4.getNetwork(channelName);
			const contractOrg4 = networkOrg4.getContract(chaincodeName);            
			try {
				if(type == true) { // type true : submit transaction, not only query
					let result = await contractOrg4.submitTransaction(func, ...args);
					const resultJSONString = result.toString();
					res.send(resultJSONString);
					console.log('Submit transaction success');
				} else {
					const result = await contractOrg4.evaluateTransaction(func, ...args);
					console.log('Evaluate transaction success');
					const resultJSONString = prettyJSONString(result.toString());
					console.log(`*** Result: ${resultJSONString}`);
					const resultString = result.toString();
					console.log(`*** Result: ${resultString}`);
					res.send(resultJSONString);
				}
			}
			finally {
			// Disconnect from the gateway when the application is closing
			// This will close all connections to the network
			gatewayOrg4.disconnect();
			}
		} catch (error) {
			console.error(`${error}`);
			res.send(error);
		}
}
module.exports = {
    send1:send1,
	send2:send2,
	send3:send3,
	send4:send4,
}