const hexToBinary =require("hex-to-binary");
const {GENESIS_DATA, MINE_RATE}= require('./config');
const cryptoHash= require('./cryptoHash');
class Block{
    constructor({timestamp,prevHash,hash,data,nonce,difficulty}){
        this.timestamp=timestamp;
        this.prevHash=prevHash;
        this.hash=hash;
        this.data=data;
        this.nonce=nonce;
        this.difficulty=difficulty;
    }

    // we are creating this genesis function as static as we don't want that whenver we create an object we get this genesis block also
    static genesis(){
        return new this(GENESIS_DATA);
    }


    //mining function
    static mineBlock({prevBlock,data}){
        //const timestamp= Date.now();
        let hash, timestamp;
        const prevHash= prevBlock.hash;
        let { difficulty }= prevBlock;

         let nonce=0;
         do{
            nonce++;
            timestamp= Date.now();
            difficulty = Block.adjustDifficulty({
                originalBlock: prevBlock,
                timestamp,
              });
            hash=cryptoHash(timestamp,prevHash,data,nonce,difficulty);
            
         }while(hexToBinary(hash).substring(0,difficulty)!=='0'.repeat(difficulty));

        return new this({timestamp,prevHash,data,nonce,difficulty,hash});
    }

    static adjustDifficulty({ originalBlock, timestamp }) {
        const { difficulty } = originalBlock;
        if (difficulty < 1) return 1;
        const difference = timestamp - originalBlock.timestamp;
        if (difference > MINE_RATE) return difficulty - 1;
        return difficulty + 1;
      }

}
const block1=new Block({timestamp:"31/12/2023",hash:'0xbaac',prevHash:'0xghf',data:'hello'});


// const genesisBlock = Block.genesis();
// console.log(genesisBlock);


// const result = Block.mineBlock({prevBlock:block1,data:"block2"});
// console.log(result);

//console.log(block1);

module.exports= Block;