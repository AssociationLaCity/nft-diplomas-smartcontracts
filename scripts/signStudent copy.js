const { utils, Wallet } = require('ethers');

const privateKey = '0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80';

const signer = new Wallet(privateKey);
console.log(signer.address);

// Get address of student to sign
let message = "0x2f4acB6AFd7A119faD3CDba4BF83267EFa001e7e";

// Compute hash of the address
let messageHash = utils.id(message);
console.log("Message Hash: ", messageHash);

// Sign the hashed address
let messageBytes = utils.arrayify(messageHash);
signer.signMessage(messageBytes).then((signature) => {
    console.log("Signature: ", signature);
})