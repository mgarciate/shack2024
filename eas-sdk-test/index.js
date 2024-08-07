import { ethers, JsonRpcProvider } from "ethers";
import { EAS, SchemaEncoder } from "@ethereum-attestation-service/eas-sdk";
import dotenv from 'dotenv';

// Load environment variables from test.env file
dotenv.config({ path: './test.env' });

// EAS contract address and schema UID
const easContractAddress = "0xC2679fBD37d54388Ce493F1DB75320D236e1815e";
const schemaUID = "0x135e8fe67404c2d25df8a4a31ec12f401d1f6432acc42dcf4bb44b9ce1d04a8b";

// Initialize ethers provider (here we use a JSON-RPC provider, but you can use any other provider)
const provider = new JsonRpcProvider(`https://eth-sepolia.g.alchemy.com/v2/${process.env.ALCHEMY_API_KEY}`);

// Get the private key from environment variables
const privateKey = process.env.PRIVATE_KEY;

if (!privateKey) {
    throw new Error("Private key not found in test.env file");
}

// Initialize ethers signer with the private key
const signer = new ethers.Wallet(privateKey, provider);

// Initialize EAS with the contract address
const eas = new EAS(easContractAddress);

// Connect the signer to EAS
await eas.connect(signer);

// Initialize SchemaEncoder with the schema string
const schemaEncoder = new SchemaEncoder("bool vote");

// Encode the data
const encodedData = schemaEncoder.encodeData([
    { name: "vote", value: true, type: "bool" }
]);

// Create the attestation
const tx = await eas.attest({
    schema: schemaUID,
    data: {
        recipient: "0x0000000000000000000000000000000000000000",
        expirationTime: 0,
        revocable: true, // Be aware that if your schema is not revocable, this MUST be false
        data: encodedData,
    },
});

// Wait for the transaction to be mined and get the new attestation UID
const receipt = await tx.wait();
// Log the receipt to inspect its structure
console.log("Transaction receipt:", receipt);

// Attempt to get the new attestation UID from the receipt
if (receipt.events && receipt.events.length > 0) {
    const newAttestationUID = receipt.events[0].args.attestationUID;
    console.log("New attestation UID:", newAttestationUID);
} else {
    console.error("No events found in transaction receipt.");
}
