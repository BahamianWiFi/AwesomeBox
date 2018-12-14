pragma solidity ^0.4.24;

import './ERC721.sol';
import './SafeMath.sol';

contract CryptoBallers is ERC721 {

    struct Baller {
        string name;
        uint level;
        uint offenseSkill;
        uint defenseSkill;
        uint winCount;
        uint lossCount;
    }

    address owner;
    Baller[] public ballers;
    uint256 seed;
    

    // Mapping for if address has claimed their free baller
    mapping(address => bool) claimedFreeBaller;
    
    //Mapping to keep track of baller exp to level up
    mapping(uint256 => uint256) exp;

    // Fee for buying a baller
    uint ballerFee = 0.10 ether;

    /**
    * @dev Ensures ownership of the specified token ID
    * @param _tokenId uint256 ID of the token to check
    */
    modifier onlyOwnerOf(uint256 _tokenId) {
        require(ownerOf(_tokenId) == msg.sender, "Owner of Taken Only!");
        _;
    }

    /**
    * @dev Ensures ownership of contract
    */
    modifier onlyOwner() {
       require(msg.sender == owner, "Owner of Game Ownly!");
        _;
    }

    /**
    * @dev Ensures baller has level above specified level
    * @param _level uint level that the baller needs to be above
    * @param _ballerId uint ID of the Baller to check
    */
    modifier aboveLevel(uint _level, uint _ballerId) {
      require(ballers[_ballerId].level > _level," Level Too Low.");
    
        _;
    }

    constructor() public {
        owner = msg.sender;
    }

    /**
    * @dev Allows user to claim first free baller, ensure no address can claim more than one
    */
    function claimFreeBaller() public {
        require(!claimedFreeBaller[msg.sender], "Only free baller per person.");
        _createBaller("Baller", 1, 1, 1); //Allows msg.sender to claim a free baller and select the name
        claimedFreeBaller[msg.sender] = true;
    }

    /**
    * @dev Allows user to buy baller with set attributes
    */
    function buyBaller() public payable {
        require (msg.value > ballerFee, "The fee is 0.1 ether."); 
        owner.transfer(msg.value);//Transfer money to contract address
        _createBaller("Bought Baller", 1, 1, 1);
    }

    /**
    * @dev Play a game with your baller and an opponent baller
    * If your baller has more offensive skill than your opponent's defensive skill
    * you win, your level goes up, the opponent loses, and vice versa.
    * If you win and your baller reaches level 5, you are awarded a new baller with a mix of traits
    * from your baller and your opponent's baller.
    * @param _ballerId uint ID of the Baller initiating the game
    * @param _opponentId uint ID that the baller needs to be above
    */
    function playBall(uint _ballerId, uint _opponentId) onlyOwnerOf(_ballerId) public {
        require (msg.sender == ownerOf(_ballerId) || msg.sender == ownerOf(_opponentId));
        uint256 prob = pRNG(ballers[_ballerId].level, ballers[_opponentId].level);
        if (prob % 2 == 0){
            ballers[_ballerId].offenseSkill += 1; //Update Winner Offense
            ballers[_ballerId].winCount += 1;     //Update Winner Wins
            ballers[_opponentId].defenseSkill -= 1; //Update Loser Defense
            ballers[_opponentId].lossCount += 1; //Update Loser Losses 
            exp[_ballerId] += 1; //Winner gains 1 exp
        }
        
        else{
            ballers[_ballerId].defenseSkill -= 1; //Update Loser Defense
            ballers[_opponentId].offenseSkill += 1; //Update Winner Offense
            ballers[_opponentId].winCount += 1;  //Update Winner Wins
            ballers[_ballerId].lossCount += 1; //Update Loser Losses 
            exp[_opponentId] += 1; //Winner gains 1 exp
        }
        
    }

    /**
    * @dev Changes the name of your baller if they are above level two
    * @param _ballerId uint ID of the Baller who's name you want to change
    * @param _newName string new name you want to give to your Baller
    */
    function changeName(uint _ballerId, string _newName) external aboveLevel(2, _ballerId) onlyOwnerOf(_ballerId) {
        ballers[_ballerId].name = _newName;
    }

    /**
   * @dev Creates a baller based on the params given, adds them to the Baller array and mints a token
   * @param _name string name of the Baller
   * @param _level uint level of the Baller
   * @param _offenseSkill offensive skill of the Baller
   * @param _defenseSkill defensive skill of the Baller
   */
    function _createBaller(string memory _name, uint _level, uint _offenseSkill, uint _defenseSkill) internal {
       Baller memory baller; //Creates Baller object
       baller.name = _name; //Sets Baller name
       baller.level = _level; //Sets Baller level
       baller.offenseSkill = _offenseSkill; //Sets Baller offenseSkill
       baller.defenseSkill = _defenseSkill; // Sets Baller defenseSkill
       baller.winCount = 0; //Sets Baller win count
       baller.lossCount = 0; //Sets Ball loss count
       ballers.push(baller); //Adds new Baller to array of ballers
       
       _mint(msg.sender, ballers.length); //Creates NFT associated with baller and msg.sender
    }

    /**
    * @dev Helper function for a new baller which averages the attributes of the level, attack, defense of the ballers
    * @param _baller1 Baller first baller to average
    * @param _baller2 Baller second baller to average
    * @return tuple of level, attack and defense
    */
    function _breedBallers(Baller memory _baller1, Baller memory _baller2) internal pure returns (uint, uint, uint) {
        uint level = _baller1.level.add(_baller2.level).div(2);
        uint attack = _baller1.offenseSkill.add(_baller2.offenseSkill).div(2);
        uint defense = _baller1.defenseSkill.add(_baller2.defenseSkill).div(2);
        return (level, attack, defense);

    }
    
   function pRNG(uint256 _baller1Lvl, uint256 _baller2Lvl) internal returns (uint256) {
       //Linear Congruential Random Number Generator
       //Coming Soon: Weighted Probability based on each ballers attributes
       uint256 aux1 = (seed.mul(1664525));
       uint256 num = 1013904223;
       uint256 aux2 = num.add(aux1);
       uint256 rand = aux2%2**32;
       seed = rand;
       return rand;
   }
   
   function levelUp(uint256 _id) public{
       require(msg.sender == ownerOf(_id), "Owner of Baller Only!");
       require( exp[_id] >= 3, "You need more experience!");
       exp[_id] = exp[_id].sub(3); //Update Exp
       ballers[_id].level += 1; //Levels up baller
   }
    
}
