import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.ArrayList;
import java.util.List;

class Block {
    private String data;
    private String hash;
    private String prevHash;

    public Block(String data, String hash, String prevHash) {
        this.data = data;
        this.hash = hash;
        this.prevHash = prevHash;
    }

    public String getData() {
        return data;
    }

    public String getHash() {
        return hash;
    }

    public String getPrevHash() {
        return prevHash;
    }

    // Getters and setters (if needed)

    @Override
    public String toString() {
        return "Block{" +
                "data='" + data + '\'' +
                ", hash='" + hash + '\'' +
                ", prevHash='" + prevHash + '\'' +
                '}';
    }
}

public class Blockchain {
    private List<Block> chain;

    public Blockchain() {
        String hashLast = hashGenerator("gen_last");
        String hashStart = hashGenerator("gen_hash");

        Block genesis = new Block("gen-data", hashStart, hashLast);
        this.chain = new ArrayList<>();
        this.chain.add(genesis);
    }

    public void addBlock(String data) {
        String prevHash = this.chain.get(this.chain.size() - 1).getHash();
        String hash = hashGenerator(data + prevHash);
        Block block = new Block(data, hash, prevHash);
        this.chain.add(block);
    }

    private String hashGenerator(String data) {
        try {
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            byte[] hashBytes = digest.digest(data.getBytes());

            StringBuilder hexString = new StringBuilder();
            for (byte b : hashBytes) {
                String hex = Integer.toHexString(0xff & b);
                if (hex.length() == 1) hexString.append('0');
                hexString.append(hex);
            }
            return hexString.toString();
        } catch (NoSuchAlgorithmException e) {
            throw new RuntimeException(e);
        }
    }

    public List<Block> getChain() {
        return chain;
    }

    public static void main(String[] args) {
        Blockchain bc = new Blockchain();
        bc.addBlock("1");
        bc.addBlock("2");
        bc.addBlock("3");

        for (Block block : bc.getChain()) {
            System.out.println(block);
        }
    }
}
