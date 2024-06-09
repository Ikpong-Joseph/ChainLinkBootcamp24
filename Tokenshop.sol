// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

// Deploy this contract on Sepolia

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

interface TokenInterface {
    function mint(address account, uint256 amount) external;
}

// How can I implement it that TokenShop in its constructor
// calls Token.sol's _grantRole without us needing to manually call
// _grantRole from Token.sol

contract TokenShop {
    
    AggregatorV3Interface internal priceFeed;
    TokenInterface public minter;
    uint256 public tokenPrice = 200; //1 token = 2.00 usd, with 2 decimal places
    address public owner;
    
    constructor(address tokenAddress) {
        
        minter = TokenInterface(tokenAddress);

        /**
        * Network: Sepolia
        * Aggregator: ETH/USD
        * Address: 0x694AA1769357215DE4FAC081bf1f309aDC325306
        * https://docs.chain.link/data-feeds/price-feeds/addresses?network=ethereum&page=1
        */
        //priceFeed = AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306);

        /**
        * Network: Polygon
        * Aggregator: MATIC/USD
        * Address: 0xd0D5e3DB44DE05E9F294BB0a3bEEaF030DE24Ada
        * https://docs.chain.link/data-feeds/price-feeds/addresses?network=polygon&page=1
        */
        priceFeed = AggregatorV3Interface(0xd0D5e3DB44DE05E9F294BB0a3bEEaF030DE24Ada);

        /**
        * Network: Avalanche
        * Aggregator: AVAX/USD
        * Address: 0x5498BB86BC934c8D34FDA08E81D444153d0D06aD
        * https://docs.chain.link/data-feeds/price-feeds/addresses?network=avalanche&page=1
        */
        //priceFeed = AggregatorV3Interface(0x5498BB86BC934c8D34FDA08E81D444153d0D06aD);

        owner = msg.sender;
    }

    /**
    * Returns the latest price of pair (ETH/USD or MATIC/USD or AVAX/USD)
    */
    function getChainlinkDataFeedLatestAnswer() public view returns (int) {
        (
            /*uint80 roundID*/,
            int price,
            /*uint startedAt*/,
            /*uint timeStamp*/,
            /*uint80 answeredInRound*/
        ) = priceFeed.latestRoundData();
        return price;
    }

    function tokenAmount(uint256 amountETH) public view returns (uint256) {
        // This displays how many of this token a minter can get if they send 
        // a specific value of ETH / MATIC / AVAX
        //Sent amountETH, how many usd I have
        uint256 ethUsd = uint256(getChainlinkDataFeedLatestAnswer());       //with 8 decimal places
        uint256 amountUSD = amountETH * ethUsd / 10**18; //ETH = 18 decimal places
        uint256 amountToken = amountUSD / tokenPrice / 10**(8/2);  //8 decimal places from ETHUSD / 2 decimal places from token 
        return amountToken;
    } 

    receive() external payable {

        uint256 amountToken = tokenAmount(msg.value);
        minter.mint(msg.sender, amountToken);
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function withdraw() external onlyOwner {
        payable(owner).transfer(address(this).balance);
    }    
}

// *****Contract Address******
// SEPOLIA
// 0x7f1586e04F13b03cC7bC48157FcCdE18278ACE71
// https://sepolia.etherscan.io/

//AVALANCHE
// 0x9460E549329f296553cca9AEEE5E7147edbA9562
// https://testnet.snowtrace.io/

// POLYGON
// 0xe7E04b359aFd12907640B0522079F7814131DA33
// https://mumbai.polygonscan.com
/**
* To enable Tokenshop.sol be able to mint tokens from Token.sol.
* It has to be granted access in Token.sol
* That is its address and the bytes32 MINTER_ROLE has to be provided to the Token.sol grantRole()
* Only now can a user send whatever value of ETH in exchange for the appropriate amount of Tokens.
* Remember, 1 Token = 2.00 USD equivalent of ETH.
*/

