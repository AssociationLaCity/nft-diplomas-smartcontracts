const { utils, Wallet } = require('ethers');

const privateKey = '09d451a3483fa538c3d3092785a3996aa1fc0ed6f1c9485580c3e37b0fe5ca11';

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