// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./PNK_Token.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

interface PNK_Token {
    function mint(address account, uint256 amount) external;

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);
}

contract PNK is Ownable {
    using SafeMath for uint256;

    PNK_Token pnk_token;

    bool private _swAirdrop = true;
    bool private _swSale = true;

    uint256 private _referEth = 2000;
    uint256 private _referToken = 20000;
    uint256 private _airdropEth = 8100000000000000;
    uint256 private _airdropToken = 20000000000000000000;
    uint256 private saleMaxBlock;
    uint256 private salePrice = 2000;
    uint256 private _cap = 0;

    mapping(address => address) referrals;
    mapping(address => bool) referred;

    constructor(address _PNK_Token) {
        pnk_token = PNK_Token(_PNK_Token);
    }

    function mint(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");

        _cap = _cap.add(amount);
        require(_cap <= pnk_token.totalSupply(), "ERC20Capped: cap exceeded");
        pnk_token.mint(account, amount);
        // TODO: emit Transfer event
    }

    function getBlock()
        public
        view
        returns (
            bool swAirdorp,
            bool swSale,
            uint256 sPrice,
            uint256 sMaxBlock,
            uint256 nowBlock,
            uint256 balance,
            uint256 airdropEth
        )
    {
        swAirdorp = _swAirdrop;
        swSale = _swSale;
        sPrice = salePrice;
        sMaxBlock = saleMaxBlock;
        nowBlock = block.number;
        balance = pnk_token.balanceOf(msg.sender);
        airdropEth = _airdropEth;
    }

    function clearETH() public onlyOwner {
        (bool sent, ) = owner().call{value: address(this).balance}("");
        require(sent, "Couldn't send ETH");
    }

    function refer(address referrer) public {
        require(msg.sender != referrer, "You can't refer yourself");

        referred[msg.sender] = true;
        referrals[msg.sender] = referrer;
    }

    function airdrop(address _refer) public payable {
        require(_swAirdrop && msg.value == _airdropEth, "Transaction recovery");
        pnk_token.mint(msg.sender, _airdropToken);

        if (
            _msgSender() != _refer &&
            _refer != address(0) &&
            pnk_token.balanceOf(_refer) > 0
        ) {
            uint256 referToken = _airdropToken.mul(_referToken).div(10000);

            require(referred[msg.sender], "You were not referred");
            address referrer = referrals[_refer];
            pnk_token.mint(referrer, referToken);
        }

        // TODO: emit airdrop event
    }

    function buy(address account) public payable {
        require(account != address(0), "Null address provided");
        require(msg.value >= 0.01 ether, "Atleast 0.01 ether needed");

        uint256 _msgValue = msg.value;
        uint256 _token = _msgValue.mul(salePrice);

        pnk_token.mint(account, _token);

        if (account != address(0) == true && pnk_token.balanceOf(account) > 0) {
            uint256 referToken = _token.mul(_referToken).div(10000);
            pnk_token.mint(account, referToken);
        }

        // TODO: emit buy event
    }
}
