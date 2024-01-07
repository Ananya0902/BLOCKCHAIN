const INITIAL_DIFFICULTY = 3; // Replace with your desired initial difficulty
const MINE_RATE = 1000; //1s = 1000ms
const GENESIS_DATA = {
    timestamp: '1',
    prevHash: '0x000',
    hash: '0x123',
    nonce: 0,
    difficulty: INITIAL_DIFFICULTY,
    data: []
};

module.exports = { GENESIS_DATA, MINE_RATE };

