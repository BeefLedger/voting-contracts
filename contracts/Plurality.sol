pragma solidity ^0.6.0;

import "./Ownable.sol";
import "./SafeMath.sol";

struct Proposal {
    string issue;
    address who;
    uint256 expires;
    uint256 accept;
    uint256 reject;
    uint min;
    uint max;
}

contract Plurality is Ownable {
    using SafeMath for uint;

    uint256 private _totalSupply;
    string private _name = "xx";
    string private _symbol = "xx";
    uint8 private _decimals = 0;

    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowed;

    mapping (uint256 => mapping(address => bool)) public votes;
    Proposal[] public proposals;

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    constructor() public {
        _totalSupply = 1000;
        _balances[msg.sender] = 1000;
    }

    function balanceOf(address who) public view returns (uint256) {
        return _balances[who];
    }

    function transfer(address to, uint256 value) public returns (bool) {
        require(msg.sender != address(this), "Contract itself can not send");
        _transfer(msg.sender, to, value);
        return true;
    }

    function _transfer(address from, address to, uint256 value) internal {
        require(to != address(0), "Invalid address");
        require(from != address(0), "Invalid address");
        require(_balances[from] >= value, "Insufficient funds");

        _balances[from] = _balances[from].sub(value);
        _balances[to] = _balances[to].add(value);

        emit Transfer(from, to, value);
    }

    function allowance(address tokenOwner, address spender) public view returns (uint remaining) {
        return _allowed[tokenOwner][spender];
    }

    function transferFrom(address from, address to, uint256 value) public returns (bool success) {
        require(to != address(0), "Invalid address");
        require(from != address(this), "Cannot be contract address");

        _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);
        _transfer(from, to, value);

        emit Approval(from, msg.sender, _allowed[from][msg.sender]);
        return true;
    }

    function approve(address spender, uint256 value) public returns (bool) {
        require(spender != address(0), "Invalid address");

        _allowed[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function grant(address who, uint256 tokens) public onlyOwner() {
        _balances[who] = _balances[who].add(tokens);
    }

    function revoke(address who, uint256 tokens) public onlyOwner() {
        _balances[who] = _balances[who].sub(tokens);
    }

    function inVotingPeriod(uint index) public view returns (bool) {
        return proposals[index].expires > now;
    }

    function addProposal(string memory issue) public returns(uint256) {
        require(balanceOf(msg.sender) >= 1, "Need at least one token");

        _balances[msg.sender] = _balances[msg.sender].sub(1);
        Proposal memory proposal = Proposal(issue, msg.sender, now + 48 hours, 0, 0, 1, 1);
        proposals.push(proposal);

        return proposals.length;
    }

    function _vote(uint256 index, bool accept, uint256 amount) private {
        require(proposals[index].who != msg.sender, "Cannot vote on own proposal");
        require(votes[index][msg.sender] != true, "Cannot vote twice");
        require(balanceOf(msg.sender) >= amount, "Need more tokens");
        require(inVotingPeriod(index), "Proposal closed for voting");
        require(amount >= proposals[index].min && proposals[index].max >= amount, "Amount outside the bounds.");

        votes[index][msg.sender] = true;
        _balances[msg.sender] = _balances[msg.sender].sub(amount);

        if (accept) {
            proposals[index].accept = proposals[index].accept.add(amount);
        } else {
            proposals[index].reject = proposals[index].accept.add(amount);
        }
        
        emit Vote(index);
        emit Transfer(msg.sender, address(0), amount);
    }

    function accept(uint256 index, uint256 amount) public {
        _vote(index, true, amount);
    }

    function reject(uint256 index, uint256 amount) public {
        _vote(index, false, amount);
    }

    event Vote(uint256 index);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}