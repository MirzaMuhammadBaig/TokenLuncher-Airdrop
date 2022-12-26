// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.8.0/contracts/token/ERC1155/IERC1155.sol";

interface Token {
    function balanceOf(address owner) external view returns (uint256);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
}

contract support_contract {
    mapping(uint256 => mapping(address => uint256)) internal _balances;
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    function balanceOf(
        address account,
        uint256 id
    ) public view virtual returns (uint256) {
        require(
            account != address(0),
            "ERC1155: address zero is not a valid owner"
        );
        return _balances[id][account];
    }

    function isApprovedForAll(
        address account,
        address operator
    ) public view virtual returns (bool) {
        return _operatorApprovals[account][operator];
    }
}

contract ERC721Airdrop is support_contract {
    uint256 public time_of_airdrop;
    uint256 public early_investors;
    uint256 public price_of_token;
    uint256 public initial_users;
    uint256 public discount;
    uint256 public token_amount;
    uint256 public buy_limit;
    address public owner;

    address internal address_of_token;
    Token public _Token;
    IERC1155 public ERC1155Token;

    mapping(address => uint256) public buyLimit;

    error G0_on_buyTokenFromEther_function();

    constructor(
        address address_of_erc1155,
        address address_of_erc20,
        uint256 _time_of_airdrop,
        uint256 _early_investors,
        uint256 _price_of_token,
        uint256 _discount,
        uint256 _token_amount,
        uint256 _buy_limit
    ) {
        owner = msg.sender;
        _Token = Token(address_of_erc20);
        ERC1155Token = IERC1155(address_of_erc1155);
        address_of_token = address_of_erc20;

        time_of_airdrop = _time_of_airdrop + block.timestamp;
        early_investors = _early_investors;
        price_of_token = _price_of_token;
        discount = _discount;
        token_amount = _token_amount;
        buy_limit = _buy_limit;
    }

    function purchase_free_tokens(
        uint256[] memory tokenIds,
        uint256[] memory amounts,
        bytes memory data
    ) public {
        require(
            address_of_token == 0x0000000000000000000000000000000000000000 &&
                price_of_token == 0,
            "Go on other function because its not for you"
        );

        for (uint256 i = 0; i < tokenIds.length; ++i) {
            uint256 id = tokenIds[i];
            uint256 amount = amounts[i];

            uint256 fromBalance = _balances[id][address(this)];
            require(
                fromBalance >= amount,
                "ERC1155: insufficient balance for transfer"
            );
        }

        require(msg.sender != owner, "Owner");
        require(block.timestamp <= time_of_airdrop, "!Time");
        require(buyLimit[msg.sender] <= buy_limit, "!Buy Limit");
        require(token_amount >= amounts.length, "More enough amount");
        require(
            tokenIds.length == amounts.length,
            "TokenIds and amounts length mismatch"
        );

        require(
            ERC1155Token.isApprovedForAll(msg.sender, address(this)) != false,
            "!Approve"
        );

        ERC1155Token.safeBatchTransferFrom(
            owner,
            msg.sender,
            tokenIds,
            amounts,
            data
        );

        initial_users++;
        buyLimit[msg.sender]++;
    }

    function buyTokenFromEther(
        uint256[] memory tokenIds,
        uint256[] memory amounts,
        bytes memory data
    ) public payable {
        require(
            address_of_token == 0x0000000000000000000000000000000000000000 &&
                price_of_token != 0,
            "Go on other function because its not for you"
        );
        require(msg.sender != owner, "Owner");
        require(block.timestamp <= time_of_airdrop, "!Time");
        require(buyLimit[msg.sender] <= buy_limit, "!Buy Limit");

        if (early_investors >= initial_users + 1) {
            require(msg.value >= price_of_token - discount, "!Balance");
        } else {
            require(msg.value >= price_of_token, "!Balance");
        }

        require(
            tokenIds.length == amounts.length,
            "TokenIds and amounts length mismatch"
        );
        require(token_amount >= amounts.length, "More enough amount");

        for (uint256 i = 0; i < tokenIds.length; ++i) {
            uint256 id = tokenIds[i];
            uint256 amount = amounts[i];

            uint256 fromBalance = _balances[id][address(this)];
            require(
                fromBalance >= amount,
                "ERC1155: insufficient balance for transfer"
            );
        }

        require(
            ERC1155Token.isApprovedForAll(msg.sender, address(this)) != false,
            "!Approve"
        );

        ERC1155Token.safeBatchTransferFrom(
            owner,
            msg.sender,
            tokenIds,
            amounts,
            data
        );

        if (early_investors <= initial_users + 1) {
            payable(owner).transfer(msg.value - discount);
        } else {
            payable(owner).transfer(msg.value);
        }

        initial_users++;
        buyLimit[msg.sender]++;
    }

    function purchase_tokens_from_other_tokens(
        uint256[] memory tokenIds,
        uint256[] memory amounts,
        bytes memory data
    ) public {
        require(
            address_of_token == 0x0000000000000000000000000000000000000000 &&
                price_of_token != 0,
            "Go on other function because its not for you"
        );
        require(msg.sender != owner, "Owner");
        require(block.timestamp <= time_of_airdrop, "!Time");
        require(buyLimit[msg.sender] <= buy_limit, "!Buy Limit");
        require(
            tokenIds.length == amounts.length,
            "TokenIds and amounts length mismatch"
        );
        require(token_amount >= amounts.length, "More enough amount");

        if (early_investors >= initial_users + 1) {
            require(
                _Token.balanceOf(msg.sender) > price_of_token - discount,
                "You have not enough balance for purchasing"
            );
        } else {
            require(
                _Token.balanceOf(msg.sender) > price_of_token,
                "You have not enough balance for purchasing"
            );
        }

        for (uint256 i = 0; i < tokenIds.length; ++i) {
            uint256 id = tokenIds[i];
            uint256 amount = amounts[i];

            uint256 fromBalance = _balances[id][address(this)];
            require(
                fromBalance >= amount,
                "ERC1155: insufficient balance for transfer"
            );
        }

        require(
            ERC1155Token.isApprovedForAll(msg.sender, address(this)) != false,
            "!Approve"
        );

        ERC1155Token.safeBatchTransferFrom(
            owner,
            msg.sender,
            tokenIds,
            amounts,
            data
        );

        if (early_investors <= initial_users + 1) {
            _Token.transferFrom(
                msg.sender,
                owner,
                (price_of_token - discount) * amounts.length
            );
        } else {
            _Token.transferFrom(
                msg.sender,
                owner,
                price_of_token * amounts.length
            );
        }

        initial_users++;
        buyLimit[msg.sender]++;
    }
}
