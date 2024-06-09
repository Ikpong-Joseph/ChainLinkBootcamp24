// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

// Deploy this contract on Fuji
// Fuji is the source blockchain
// Since we're transferring USDC from Fuji to Sepolia

import {IRouterClient} from "@chainlink/contracts-ccip/src/v0.8/ccip/interfaces/IRouterClient.sol";
import {Client} from "@chainlink/contracts-ccip/src/v0.8/ccip/libraries/Client.sol";
import {IERC20} from "@chainlink/contracts-ccip/src/v0.8/vendor/openzeppelin-solidity/v4.8.0/token/ERC20/IERC20.sol";
import {SafeERC20} from "@chainlink/contracts-ccip/src/v0.8/vendor/openzeppelin-solidity/v4.8.0/token/ERC20/utils/SafeERC20.sol";

/**
 * THIS IS AN EXAMPLE CONTRACT THAT USES HARDCODED VALUES FOR CLARITY.
 * THIS IS AN EXAMPLE CONTRACT THAT USES UN-AUDITED CODE.
 * DO NOT USE THIS CODE IN PRODUCTION.
 */
contract TransferUSDCBasic {
    using SafeERC20 for IERC20;

    error NotEnoughBalanceForFees(uint256 currentBalance, uint256 calculatedFees);
    error NotEnoughBalanceUsdcForTransfer(uint256 currentBalance);
    error NothingToWithdraw();

    address public owner;
    IRouterClient private immutable ccipRouter;
    IERC20 private immutable linkToken;
    IERC20 private immutable usdcToken;

    // https://docs.chain.link/ccip/supported-networks/v1_2_0/testnet#avalanche-fuji
    address ccipRouterAddress = 0xF694E193200268f9a4868e4Aa017A0118C9a8177; // For the source blockchain

    // https://docs.chain.link/resources/link-token-contracts#fuji-testnet
    address linkAddress = 0x0b9d5D9136855f6FEc3c0993feE6E9CE8a297846;

    // https://developers.circle.com/stablecoins/docs/usdc-on-test-networks
    address usdcAddress = 0x5425890298aed601595a70AB815c96711a31Bc65; // Sepolia

    // https://docs.chain.link/ccip/supported-networks/v1_2_0/testnet#ethereum-sepolia
    // Sepolia is the destination bockchain
    // Since it will receive USDC sent from source blockchain -- Fuji
    uint64 destinationChainSelector = 16015286601757825753;

    event UsdcTransferred(
        bytes32 messageId,
        uint64 destinationChainSelector,
        address receiver,
        uint256 amount,
        uint256 ccipFee
    );

    constructor() {
        owner = msg.sender;
        ccipRouter = IRouterClient(ccipRouterAddress);
        linkToken = IERC20(linkAddress);
        usdcToken = IERC20(usdcAddress);
    }

    function transferUsdcToSepolia(
        address _receiver,
        uint256 _amount
    )
        external
        returns (bytes32 messageId)
    {
        Client.EVMTokenAmount[]
            memory tokenAmounts = new Client.EVMTokenAmount[](1); // A fixed[] containing only 1 token to be sent-- USDC
        Client.EVMTokenAmount memory tokenAmount = Client.EVMTokenAmount({
            token: address(usdcToken),
            amount: _amount
        });
        tokenAmounts[0] = tokenAmount;

        Client.EVM2AnyMessage memory message = Client.EVM2AnyMessage({
            receiver: abi.encode(_receiver),
            data: "",
            tokenAmounts: tokenAmounts,
            extraArgs: Client._argsToBytes(
                Client.EVMExtraArgsV1({gasLimit: 0})
            ),
            feeToken: address(linkToken)
        });

        uint256 ccipFee = ccipRouter.getFee(
            destinationChainSelector,
            message
        );

        if (ccipFee > linkToken.balanceOf(address(this)))
            revert NotEnoughBalanceForFees(linkToken.balanceOf(address(this)), ccipFee);
        linkToken.approve(address(ccipRouter), ccipFee); // Aproving the Router to spend our LINK tokens

        if (_amount > usdcToken.balanceOf(msg.sender))
            revert NotEnoughBalanceUsdcForTransfer(usdcToken.balanceOf(msg.sender));
        usdcToken.safeTransferFrom(msg.sender, address(this), _amount); // Transfers USDC from msg.sender account to this contract
        usdcToken.approve(address(ccipRouter), _amount); // Approving the router to spend our USDC tokens 

        // Send CCIP Message
        messageId = ccipRouter.ccipSend(destinationChainSelector, message);

        emit UsdcTransferred(
            messageId,
            destinationChainSelector,
            _receiver,
            _amount,
            ccipFee
        );
    }

    function allowanceUsdc() public view returns (uint256 usdcAmount) {
        usdcAmount = usdcToken.allowance(msg.sender, address(this));
    }

    function balancesOf(address account) public view returns (uint256 linkBalance, uint256 usdcBalance) {
        linkBalance =  linkToken.balanceOf(account);
        usdcBalance = IERC20(usdcToken).balanceOf(account);
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function withdrawToken(
        address _beneficiary,
        address _token
    ) public onlyOwner {
        uint256 amount = IERC20(_token).balanceOf(address(this));
        if (amount == 0) revert NothingToWithdraw();
        IERC20(_token).transfer(_beneficiary, amount);
    }
}

//****** Contract Address ******/
// 0x7FCF7b8ae82dAF9AFA34ED37f579e3655AD52200

// Approve this contract to spend 0.1 (100000) USDC from my metamask
// HOW?
// In 'CONTRACT' select IERC20. Then populate 'At Address' with the USDC token address on Fuji. 
// Then select approve()
// Use this contract address as spender

// Send LINK to this contract address
// Send USDC to metamask (Fuji to Sepolia)// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

// Deploy this contract on Fuji
// Fuji is the source blockchain
// Since we're transferring USDC from Fuji to Sepolia

import {IRouterClient} from "@chainlink/contracts-ccip/src/v0.8/ccip/interfaces/IRouterClient.sol";
import {Client} from "@chainlink/contracts-ccip/src/v0.8/ccip/libraries/Client.sol";
import {IERC20} from "@chainlink/contracts-ccip/src/v0.8/vendor/openzeppelin-solidity/v4.8.0/token/ERC20/IERC20.sol";
import {SafeERC20} from "@chainlink/contracts-ccip/src/v0.8/vendor/openzeppelin-solidity/v4.8.0/token/ERC20/utils/SafeERC20.sol";

/**
 * THIS IS AN EXAMPLE CONTRACT THAT USES HARDCODED VALUES FOR CLARITY.
 * THIS IS AN EXAMPLE CONTRACT THAT USES UN-AUDITED CODE.
 * DO NOT USE THIS CODE IN PRODUCTION.
 */
contract TransferUSDCBasic {
    using SafeERC20 for IERC20;

    error NotEnoughBalanceForFees(uint256 currentBalance, uint256 calculatedFees);
    error NotEnoughBalanceUsdcForTransfer(uint256 currentBalance);
    error NothingToWithdraw();

    address public owner;
    IRouterClient private immutable ccipRouter;
    IERC20 private immutable linkToken;
    IERC20 private immutable usdcToken;

    // https://docs.chain.link/ccip/supported-networks/v1_2_0/testnet#avalanche-fuji
    address ccipRouterAddress = 0xF694E193200268f9a4868e4Aa017A0118C9a8177; // For the source blockchain

    // https://docs.chain.link/resources/link-token-contracts#fuji-testnet
    address linkAddress = 0x0b9d5D9136855f6FEc3c0993feE6E9CE8a297846;

    // https://developers.circle.com/stablecoins/docs/usdc-on-test-networks
    address usdcAddress = 0x5425890298aed601595a70AB815c96711a31Bc65; // Sepolia

    // https://docs.chain.link/ccip/supported-networks/v1_2_0/testnet#ethereum-sepolia
    // Sepolia is the destination bockchain
    // Since it will receive USDC sent from source blockchain -- Fuji
    uint64 destinationChainSelector = 16015286601757825753;

    event UsdcTransferred(
        bytes32 messageId,
        uint64 destinationChainSelector,
        address receiver,
        uint256 amount,
        uint256 ccipFee
    );

    constructor() {
        owner = msg.sender;
        ccipRouter = IRouterClient(ccipRouterAddress);
        linkToken = IERC20(linkAddress);
        usdcToken = IERC20(usdcAddress);
    }

    function transferUsdcToSepolia(
        address _receiver,
        uint256 _amount
    )
        external
        returns (bytes32 messageId)
    {
        Client.EVMTokenAmount[]
            memory tokenAmounts = new Client.EVMTokenAmount[](1); // A fixed[] containing only 1 token to be sent-- USDC
        Client.EVMTokenAmount memory tokenAmount = Client.EVMTokenAmount({
            token: address(usdcToken),
            amount: _amount
        });
        tokenAmounts[0] = tokenAmount;

        Client.EVM2AnyMessage memory message = Client.EVM2AnyMessage({
            receiver: abi.encode(_receiver),
            data: "",
            tokenAmounts: tokenAmounts,
            extraArgs: Client._argsToBytes(
                Client.EVMExtraArgsV1({gasLimit: 0})
            ),
            feeToken: address(linkToken)
        });

        uint256 ccipFee = ccipRouter.getFee(
            destinationChainSelector,
            message
        );

        if (ccipFee > linkToken.balanceOf(address(this)))
            revert NotEnoughBalanceForFees(linkToken.balanceOf(address(this)), ccipFee);
        linkToken.approve(address(ccipRouter), ccipFee); // Aproving the Router to spend our LINK tokens

        if (_amount > usdcToken.balanceOf(msg.sender))
            revert NotEnoughBalanceUsdcForTransfer(usdcToken.balanceOf(msg.sender));
        usdcToken.safeTransferFrom(msg.sender, address(this), _amount); // Transfers USDC from msg.sender account to this contract
        usdcToken.approve(address(ccipRouter), _amount); // Approving the router to spend our USDC tokens 

        // Send CCIP Message
        messageId = ccipRouter.ccipSend(destinationChainSelector, message);

        emit UsdcTransferred(
            messageId,
            destinationChainSelector,
            _receiver,
            _amount,
            ccipFee
        );
    }

    function allowanceUsdc() public view returns (uint256 usdcAmount) {
        usdcAmount = usdcToken.allowance(msg.sender, address(this));
    }

    function balancesOf(address account) public view returns (uint256 linkBalance, uint256 usdcBalance) {
        linkBalance =  linkToken.balanceOf(account);
        usdcBalance = IERC20(usdcToken).balanceOf(account);
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function withdrawToken(
        address _beneficiary,
        address _token
    ) public onlyOwner {
        uint256 amount = IERC20(_token).balanceOf(address(this));
        if (amount == 0) revert NothingToWithdraw();
        IERC20(_token).transfer(_beneficiary, amount);
    }
}

//****** Contract Address ******/
// 0x7FCF7b8ae82dAF9AFA34ED37f579e3655AD52200

// Approve this contract to spend 0.1 (100000) USDC from my metamask
// HOW?
// In 'CONTRACT' select IERC20. Then populate 'At Address' with the USDC token address on Fuji. 
// Then select approve()
// Use this contract address as spender

// Send LINK to this contract address
// Send USDC to metamask (Fuji to Sepolia)