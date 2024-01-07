//Pub/Sub (or Publish/Subscribe) is an architectural design pattern used in distributed systems for asynchronous communication between different components or services. Although Publish/Subscribe is based on earlier design patterns like message queuing and event brokers, it is more flexible and scalable. The key to this is the fact that Pub/Sub enables the movement of messages between different components of the system without the components being aware of each other’s identity (they are decoupled). 


// Import the Redis library
const redis = require("redis");

// Define constant channels for PubSub
const CHANNELS = {
  TEST: "TEST",
  BLOCKCHAIN: "BLOCKCHAIN",
};

// PubSub class definition
class PubSub {
  /**
   * Constructor for PubSub class.
   * @param {object} options - Options for initializing the PubSub instance.
   * @param {object} options.blockchain - Blockchain instance to be used.
   */
  constructor({ blockchain }) {
    // Store the blockchain instance
    this.blockchain = blockchain;

    // Create Redis clients for publishing and subscribing
    this.publisher = redis.createClient();
    this.subscriber = redis.createClient();

    // Subscribe to the specified channels
    this.subscriber.subscribe(CHANNELS.TEST);
    this.subscriber.subscribe(CHANNELS.BLOCKCHAIN);

    // Set up event listener for incoming messages
    this.subscriber.on("message", (channel, message) =>
      this.handleMessage(channel, message)
    );
  }

  /**
   * Handle incoming messages from subscribed channels.
   * @param {string} channel - The channel the message was received on.
   * @param {string} message - The message received from the channel.
   */
  handleMessage(channel, message) {
    console.log(`Message received. Channel: ${channel} Message: ${message}`);

    // Parse the incoming JSON message
    const parseMessage = JSON.parse(message);

    // If the message is from the BLOCKCHAIN channel, update the blockchain
    if (channel === CHANNELS.BLOCKCHAIN) {
      this.blockchain.replaceChain(parseMessage);
    }
  }

  /**
   * Publish a message to a specified channel.
   * @param {object} options - Options for publishing a message.
   * @param {string} options.channel - The channel to publish the message on.
   * @param {string} options.message - The message to be published.
   */
  publish({ channel, message }) {
    this.publisher.publish(channel, message);
  }

  /**
   * Broadcast the current blockchain to all subscribers.
   */
  broadcastChain() {
    // Publish the blockchain on the BLOCKCHAIN channel
    this.publish({
      channel: CHANNELS.BLOCKCHAIN,
      message: JSON.stringify(this.blockchain.chain),
    });
  }
}


// const checkPubSub = new PubSub();
// setTimeout(
//   () => checkPubSub.publisher.publish(CHANNELS.TEST, "Hellloooo"),
//   1000
// );




// Export the PubSub class for use in other modules
module.exports = PubSub;
