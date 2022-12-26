// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract ERC20Airdrop is Ownable {
    uint256 public price_of_token_a; // this variable store token price
    uint256 public price_of_token_b; // this variable store token price
    uint256 public price_of_token_a_without_decimals; // this variable store token decimals
    uint256 public price_of_token_b_without_decimals; // this variable store token decimals
    uint256 public bonus_tokens; // this variable store bonus tokens for initial users
    uint256 public bonus_tokens_without_decimals;
    uint256 public buy_time; // this variable store buy time of token
    uint256 public token_limit; // this variable store hom much tokens can you purchase
    uint256 public early_users; // this variable store initial users for bonus tokens
    uint256 public initial_users; // this variable is for handling early users
    uint256 public buy_limit; // this variable store limit of how many time can I purchase tokens
    uint256 public decimals_of_token_a;
    uint256 public decimals_of_token_b;

    address public check_for_token_b; // this variable store token B address, I need this because of some conditions
    IERC20 public TOKEN_A; // interface of token A
    IERC20 public TOKEN_B; // interface of token B

    mapping(address => uint256) public buyLimit; // this mapping check buy limit of users

    event Constructor(
        address tokenA_address,
        address tokenB_address,
        uint256 decimals_of_token_a,
        uint256 decimals_of_token_b,
        uint256 price_of_token_a,
        uint256 price_of_token_b,
        uint256 limit_of_token,
        uint256 buy_time_of_token,
        uint256 early_users_of_token,
        uint256 token_bonus,
        uint256 buy_limit_of_token
    ); // event for constructor

    event CreateAirdrop(
        uint256 price_of_token_a,
        uint256 price_of_token_b,
        uint256 limit_of_token,
        uint256 buy_time_of_token,
        uint256 early_users_of_token,
        uint256 token_bonus,
        uint256 buy_limit_of_token
    ); // event for Create_Airdrop function

    event Transfer(address from, address to, uint256 amount); // event for transfer

    constructor(
        address _Token_A_Address,
        address _Token_B_Address,
        uint256 _decimals_of_token_a,
        uint256 _decimals_of_token_b,
        uint256 token_a_price,
        uint256 token_b_price,
        uint256 _token_limit,
        uint256 _buy_time,
        uint256 _early_users,
        uint256 _bonus_tokens,
        uint256 _buy_limit
    ) {
        TOKEN_A = IERC20(_Token_A_Address); // address set for token_a
        TOKEN_B = IERC20(_Token_B_Address); // address set for token_b
        check_for_token_b = _Token_B_Address; // store token_b address in check _for_token_b

        decimals_of_token_a = 10 ** _decimals_of_token_a;
        decimals_of_token_b = 10 ** _decimals_of_token_b;

        price_of_token_a = token_a_price * 10 ** _decimals_of_token_a; // set token price
        price_of_token_b = token_b_price * 10 ** _decimals_of_token_b; // set token price
        price_of_token_a_without_decimals = _decimals_of_token_a;
        price_of_token_b_without_decimals = _decimals_of_token_b;

        token_limit = _token_limit; // set limit of tokens
        buy_time = _buy_time; // set buying time of token
        early_users = _early_users; // set early users for tokens

        bonus_tokens = _bonus_tokens * 10 ** _decimals_of_token_b; // set bonus tokens for early users
        bonus_tokens_without_decimals = _bonus_tokens;

        buy_limit = _buy_limit; // set buy limit for users of token

        emit Constructor(
            _Token_A_Address,
            _Token_B_Address,
            _decimals_of_token_a,
            _decimals_of_token_b,
            price_of_token_a,
            price_of_token_b,
            _token_limit,
            _buy_time,
            _early_users,
            _bonus_tokens,
            _buy_limit
        );
    }

    /**
     * @dev Edit_Airdrop is used to set token price, token limit, time, early users, bonus, buy limit.
     * Requirement:
     * - This function can only called by owner of the contract
     * @param _price_of_token_a - price set for token
     * @param _price_of_token_b - price set for token
     * @param _token_limit - set token limit for users
     * @param _buy_time - set buying time of token
     * @param _early_users - set initial users of token
     * @param _bonus_tokens - set bonus tokens for initial users
     * @param _buy_limit - set buy limit of token
     */

    function Edit_Airdrop(
        uint256 _price_of_token_a,
        uint256 _price_of_token_b,
        uint256 _token_limit,
        uint256 _buy_time,
        uint256 _early_users,
        uint256 _bonus_tokens,
        uint256 _buy_limit
    ) public onlyOwner {
        price_of_token_a = _price_of_token_a;
        price_of_token_b = _price_of_token_b;
        token_limit = _token_limit + block.timestamp;
        buy_time = _buy_time;
        early_users = _early_users;
        bonus_tokens = _bonus_tokens;
        buy_limit = _buy_limit;

        emit CreateAirdrop(
            _price_of_token_a,
            _price_of_token_b,
            _token_limit,
            _buy_time,
            _early_users,
            _bonus_tokens,
            _buy_limit
        );
    }

    /**
     * @dev purchase_token is used to buy tokens.
     * Requirement:
     * - contract needs allowance of token a.
     * - contract needs balance of token a.
     * - If token b address is not equal to '0x0000000000000000000000000000' then contract needs allowance of token b.
     * - If token b address is not equal to '0x0000000000000000000000000000' then contract needs balance of token b.
     * - This function can't called by owner.
     * - Token limit is greater than or equal tokens.
     * - Block.timestamp is greater than or equal buy_time.
     * - msg.value is greater than or equal to price*tokens.
     * @param tokens - value of tokens do you want to buy.
     */

    function purchase_free_tokens(uint256 tokens) public {
        require(price_of_token_a == 0, "Tokens has not free");
        require(
            TOKEN_A.allowance(msg.sender, address(this)) >= tokens,
            "!Allowance TOKEN A"
        );
        require(TOKEN_A.balanceOf(address(this)) >= tokens, "!Balance TOKEN A");
        require(msg.sender != owner(), "Owner");
        require(
            token_limit >= tokens,
            "Token quantity has more than token limit"
        );
        require(block.timestamp >= buy_time, "!Time");
        require(buyLimit[msg.sender] <= buy_limit, "!Buy Limit");
        if (early_users >= initial_users + 1) {
            uint256 handle_tokens = tokens + bonus_tokens_without_decimals;
            TOKEN_A.transferFrom(
                owner(),
                msg.sender,
                handle_tokens * 10 ** price_of_token_a_without_decimals
            );
        } else {
            TOKEN_A.transferFrom(
                owner(),
                msg.sender,
                tokens * 10 ** price_of_token_a_without_decimals
            );
        }
        initial_users++;
        buyLimit[msg.sender]++;

        emit Transfer(owner(), msg.sender, tokens);
    }

    function purchase_tokens_from_ether(uint256 tokens) public payable {
        require(
            price_of_token_a > 0,
            "Please call purchase_free_tokens function"
        );
        require(
            decimals_of_token_b == 1e18,
            "Please call purchase_tokens_from_other_tokens function"
        );
        require(
            check_for_token_b == 0x0000000000000000000000000000000000000000,
            "Please call purchase_tokens_from_other_tokens function"
        );
        require(
            TOKEN_A.allowance(msg.sender, address(this)) >= tokens,
            "!Allowance TOKEN A"
        );
        require(TOKEN_A.balanceOf(address(this)) >= tokens, "!Balance TOKEN A");
        require(msg.sender != owner(), "Owner");
        require(
            token_limit >= tokens,
            "Token quantity has more than token limit"
        );
        require(block.timestamp >= buy_time, "!Time");
        require(msg.value >= price_of_token_a * tokens, "!Balance");
        require(buyLimit[msg.sender] <= buy_limit, "!Buy Limit");
        if (early_users >= initial_users + 1) {
            uint256 handle_tokens = tokens + bonus_tokens_without_decimals;
            TOKEN_A.transferFrom(
                owner(),
                msg.sender,
                handle_tokens * 10 ** price_of_token_a_without_decimals
            );
        } else {
            TOKEN_A.transferFrom(
                owner(),
                msg.sender,
                tokens * 10 ** price_of_token_a_without_decimals
            );
        }
        payable(owner()).transfer(msg.value);

        initial_users++;
        buyLimit[msg.sender]++;

        emit Transfer(owner(), msg.sender, tokens);
    }

    function purchase_tokens_from_other_tokens(uint256 tokens) public payable {
        require(
            price_of_token_a > 0,
            "Please call purchase_free_tokens function"
        );
        require(
            decimals_of_token_b != 18,
            "Please call purchase_tokens_from_ether function"
        );
        require(
            check_for_token_b != 0x0000000000000000000000000000000000000000,
            "Please call purchase_tokens_from_ether function"
        );
        require(
            TOKEN_A.allowance(msg.sender, address(this)) >= tokens,
            "!Allowance TOKEN A"
        );
        require(TOKEN_A.balanceOf(address(this)) >= tokens, "!Balance TOKEN A");
        require(TOKEN_B.balanceOf(msg.sender) >= tokens, "!Balance TOKEN B");
        require(msg.sender != owner(), "Owner");
        require(
            token_limit >= tokens,
            "Token quantity has more than token limit"
        );
        require(block.timestamp >= buy_time, "!Time");
        require(buyLimit[msg.sender] <= buy_limit, "!Buy Limit");

        if (early_users >= initial_users + 1) {
            uint256 handle_tokens = tokens + bonus_tokens_without_decimals;
            TOKEN_A.transferFrom(
                owner(),
                msg.sender,
                handle_tokens * 10 ** price_of_token_a_without_decimals
            );
        } else {
            TOKEN_A.transferFrom(
                owner(),
                msg.sender,
                tokens * 10 ** price_of_token_a_without_decimals
            );
        }
        TOKEN_B.transfer(
            owner(),
            tokens * 10 ** price_of_token_b_without_decimals
        );
        initial_users++;
        buyLimit[msg.sender]++;

        emit Transfer(owner(), msg.sender, tokens);
    }
}
