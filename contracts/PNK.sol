// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract PNK is Ownable {
    using SafeMath for uint256;

    IERC20 public pnk_token;

    bool private _swAirdrop = true;
    bool private _swSale = true;

    uint256 private _referEth = 2000;
    uint256 private _referToken = 20000;
    uint256 private _airdropEth = 8100000000000000; // = 0.0081 ether
    uint256 private _airdropToken = 20000000000000000000;
    uint256 private saleMaxBlock;
    uint256 private salePrice = 2000;
    uint256 private _cap = 0;

    mapping(address => address) public referrals;
    mapping(address => bool) public referred;

    event referral(address indexed refer, address indexed referred);
    event airdropped(
        address indexed caller,
        address indexed referrer,
        uint256 airdropAmount,
        uint256 referralBonus
    );
    event bought(address indexed buyer, uint256 amount, uint256 bonus);
    event updatePnk_TokenAddress(address pnkTokenAddress);

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

        emit referral(referrer, msg.sender);
    }

    function airdrop(address _refer) public payable {
        require(_swAirdrop && msg.value == _airdropEth, "Transaction recovery");
        pnk_token.transfer(address(msg.sender), _airdropToken);

        uint256 referBonus = 0;

        if (
            _msgSender() != _refer &&
            _refer != address(0) &&
            pnk_token.balanceOf(_refer) > 0
        ) {
            uint256 referToken = _airdropToken.mul(_referToken).div(10000);
            referBonus = _referToken;
            require(referred[msg.sender], "You were not referred");
            require(
                referrals[msg.sender] == _refer,
                "You were not referred by this address"
            );
            pnk_token.transfer(_refer, referToken);
        }

        emit airdropped(msg.sender, _refer, _airdropToken, referBonus);
    }

    function buy(address account) public payable {
        require(account != address(0), "Null address provided");
        require(msg.value >= 0.01 ether, "Atleast 0.01 ether needed");

        uint256 _msgValue = msg.value;
        uint256 _token = _msgValue.mul(salePrice);
        uint256 bonus = 0;

        pnk_token.transfer(account, _token);

        if (account != address(0) == true && pnk_token.balanceOf(account) > 0) {
            uint256 referToken = _token.mul(_referToken).div(10000);
            bonus = referToken;
            pnk_token.transfer(account, referToken);
        }

        emit bought(msg.sender, _token, bonus);
    }

    function updatePnkTokenAddress(address pnkTokenAddress) public onlyOwner {
        pnk_token = IERC20(pnkTokenAddress);

        emit updatePnk_TokenAddress(pnkTokenAddress);
    }
}
