// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract PNKToken is ERC20 {
    constructor() ERC20("PUNKAPE TOKEN", "PNK") {
        _mint(msg.sender, 10000000000000000000000000);
    }

    function mint(address account, uint256 amount) public {
        _mint(account, amount);
    }
}
