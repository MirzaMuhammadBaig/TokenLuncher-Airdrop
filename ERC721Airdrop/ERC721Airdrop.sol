// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.8.0/contracts/token/ERC721/IERC721.sol";

interface Token {
    function balanceOf(address owner) external view returns (uint256);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
}

contract support_contract {
    address public owner;

    event Transfer(
        address indexed from,
        address indexed to,
        uint256 indexed tokenId
    );

    constructor() {
        owner = msg.sender;
    }

    mapping(uint256 => address) private _owners;
    mapping(address => uint256) private _balances;

    function _ownerOf(uint256 tokenId) internal view virtual returns (address) {
        return _owners[tokenId];
    }

    function _exists(uint256 tokenId) internal view virtual returns (bool) {
        return _ownerOf(tokenId) != address(0);
    }

    function balanceOf(address _owner) public view virtual returns (uint256) {
        require(
            _owner != address(0),
            "ERC721: address zero is not a valid owner"
        );
        return _balances[owner];
    }
}

contract ERC721Airdrop is support_contract {
    uint256 public time_of_airdrop;
    uint256 public early_investors;
    uint256 public price_of_token;
    uint256 public initial_users;
    uint256 public discount;
    uint256 public buy_limit;

    address internal address_of_token;
    Token public _Token;
    IERC721 public ERC721Token;

    mapping(address => uint256) public buyLimit;

    error G0_on_buyTokenFromEther_function();

    constructor(
        address address_of_erc721,
        address address_of_erc20,
        uint256 _time_of_airdrop,
        uint256 _early_investors,
        uint256 _price_of_token,
        uint256 _discount,
        uint256 _buy_limit
    ) {
        _Token = Token(address_of_erc20);
        ERC721Token = IERC721(address_of_erc721);
        address_of_token = address_of_erc20;

        time_of_airdrop = _time_of_airdrop + block.timestamp;
        early_investors = _early_investors;
        price_of_token = _price_of_token;
        discount = _discount;
        buy_limit = _buy_limit;
    }

    function purchase_free_tokens(uint256 tokenId) public {
        require(
            address_of_token == 0x0000000000000000000000000000000000000000 &&
                price_of_token == 0,
            "Go on other function because its not for you"
        );
        require(ERC721Token.balanceOf(address(this)) > 0, "NFT not exists");
        require(msg.sender != owner, "Owner");
        require(block.timestamp <= time_of_airdrop, "!Time");
        require(buyLimit[msg.sender] <= buy_limit, "!Buy Limit");
        require(
            ERC721Token.isApprovedForAll(msg.sender, address(this)) != false,
            "!Approve"
        );

        ERC721Token.safeTransferFrom(owner, msg.sender, tokenId, "0x00");

        initial_users++;
        buyLimit[msg.sender]++;

        emit Transfer(owner, msg.sender, tokenId);
    }

    function buyTokenFromEther(uint256 tokenId) public payable {
        require(
            address_of_token == 0x0000000000000000000000000000000000000000 &&
                price_of_token != 0,
            "Go on other function because its not for you"
        );
        require(ERC721Token.balanceOf(address(this)) > 0, "NFT not exists");
        require(msg.sender != owner, "Owner");
        require(block.timestamp <= time_of_airdrop, "!Time");
        require(buyLimit[msg.sender] <= buy_limit, "!Buy Limit");

        if (early_investors >= initial_users + 1) {
            require(msg.value >= price_of_token - discount, "!Balance");
        } else {
            require(msg.value >= price_of_token, "!Balance");
        }

        require(
            ERC721Token.isApprovedForAll(msg.sender, address(this)) != false,
            "!Approve"
        );

        ERC721Token.safeTransferFrom(owner, msg.sender, tokenId, "0x00");

        if (early_investors <= initial_users + 1) {
            payable(owner).transfer(msg.value - discount);
        } else {
            payable(owner).transfer(msg.value);
        }

        initial_users++;
        buyLimit[msg.sender]++;

        emit Transfer(owner, msg.sender, tokenId);
    }

    function purchase_tokens_from_other_tokens(uint256 tokenId) public {
        require(
            address_of_token != 0x0000000000000000000000000000000000000000 &&
                price_of_token != 0,
            "Go on other function because its not for you"
        );
        require(ERC721Token.balanceOf(address(this)) > 0, "NFT not exists");
        require(msg.sender != owner, "Owner");
        require(block.timestamp <= time_of_airdrop, "!Time");
        require(buyLimit[msg.sender] <= buy_limit, "!Buy Limit");
        require(
            ERC721Token.isApprovedForAll(msg.sender, address(this)) != false,
            "!Approve"
        );

        ERC721Token.safeTransferFrom(owner, msg.sender, tokenId, "0x00");

        if (early_investors <= initial_users + 1) {
            _Token.transferFrom(msg.sender, owner, price_of_token - discount);
        } else {
            _Token.transferFrom(msg.sender, owner, price_of_token);
        }

        initial_users++;
        buyLimit[msg.sender]++;

        emit Transfer(owner, msg.sender, tokenId);
    }
}
