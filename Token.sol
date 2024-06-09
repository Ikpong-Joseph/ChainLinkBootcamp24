// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "@openzeppelin/contracts@4.6.0/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts@4.6.0/access/AccessControl.sol";

contract Token is ERC20, AccessControl {
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    constructor() ERC20("Chainlink Bootcamp 2024 Token", "JOT") {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(MINTER_ROLE, msg.sender);
    }

    function mint(address to, uint256 amount) public onlyRole(MINTER_ROLE) {
        _mint(to, amount);
    }

    function decimals() public pure override returns (uint8) {
        return 2;
    }    
}

// ********CONTRACT ADDRESS***********
// SEPOLIA
// 0xe7E04b359aFd12907640B0522079F7814131DA33
// AVALANCHE FUJI
// 0x7f1586e04F13b03cC7bC48157FcCdE18278ACE71
// POLYGON MATIC
// 0x7FCF7b8ae82dAF9AFA34ED37f579e3655AD52200