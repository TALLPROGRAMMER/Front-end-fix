// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract PNKToken is ERC20 {
    constructor(address pnkAirdropContract) ERC20("PUNKAPE TOKEN", "PNK") {
        _mint(pnkAirdropContract, 10_000_000 * 10**18);
    }

    function mint(address account, uint256 amount) public {
        _mint(account, amount);
    }
}
