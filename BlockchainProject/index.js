// Import necessary libraries and modules
const bodyParser = require("body-parser");
const express = require("express");
const request = require("request");
const Blockchain = require("./blockchain");
const PubSub = require("./publishsubscribe");

// Create an instance of Express application
const app = express();

// Create an instance of the Blockchain class
const blockchain = new Blockchain();

// Create an instance of the PubSub class with the blockchain instance
const pubsub = new PubSub({ blockchain });

// Set default port for the application
const DEFAULT_PORT = 3000;

// Define the root node address for communication
const ROOT_NODE_ADDRESS = `http://localhost:${DEFAULT_PORT}`;

// Broadcast the blockchain after a delay to synchronize with other nodes
setTimeout(() => pubsub.broadcastChain(), 1000);

// Use body-parser middleware to parse incoming JSON requests
app.use(bodyParser.json());

// Endpoint to get the entire blockchain
app.get("/api/blocks", (req, res) => {
  res.json(blockchain.chain);
});

// Endpoint to mine a new block
app.post("/api/mine", (req, res) => {
  const { data } = req.body;

  // Add a new block to the blockchain with the provided data
  blockchain.addBlock({ data });

  // Broadcast the updated blockchain to all nodes
  pubsub.broadcastChain();

  // Redirect to the endpoint that returns the entire blockchain
  res.redirect("/api/blocks");
});

// Function to synchronize chains with the root node
const syncChains = () => {
  // Request the blockchain from the root node
  request(
    { url: `${ROOT_NODE_ADDRESS}/api/blocks` },
    (error, response, body) => {
      if (!error && response.statusCode === 200) {
        // Parse the response body into a JSON object
        const rootChain = JSON.parse(body);

        // Log and replace the local chain with the received chain
        console.log("Replace chain on sync with", rootChain);
        blockchain.replaceChain(rootChain);
      }
    }
  );
};

// Define the peer port, either using a random port or the default port
let PEER_PORT;

if (process.env.GENERATE_PEER_PORT === "true") {
  PEER_PORT = DEFAULT_PORT + Math.ceil(Math.random() * 1000);
}

// Set the actual port for the Express app
const PORT = PEER_PORT || DEFAULT_PORT;

// Start the Express app on the specified port
app.listen(PORT, () => {
  console.log(`Listening to PORT: ${PORT}`);

  // Synchronize the chain with the root node upon starting the server
  syncChains();
});
