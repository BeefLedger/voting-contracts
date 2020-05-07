pragma solidity ^0.6.0;

import "./Ownable.sol";
import "./SafeMath.sol";

struct Proposal {
    string issue;
    address who;
    uint256 expires;
    uint256 count;
    uint256 required;
    bool open;
}

contract Plurality is Ownable {
    using SafeMath for uint;
    mapping (address => bool) public members;
    uint256 public membersCount;
    
    mapping (uint256 => mapping(address => bool)) public votes;
    Proposal[] public proposals;

    constructor() public {
        membersCount = 1;
    }

    function inVotingPeriod(uint index) public view returns (bool) {
        return proposals[index].expires > now;
    }

    function addProposal(string memory issue) public onlyMembers() returns(uint256) {
        require(membersCount > 2, "Must have at least three members");

        //Less 2, because owner cannot vote on their own.
        uint256 required = membersCount.sub(2);
        Proposal memory proposal = Proposal(issue, msg.sender, now + 48 hours, 0, required, true);
        proposals.push(proposal);

        return proposals.length;
    }

    function vote(uint256 index) public onlyMembers() {
        //require(proposals[index].who == msg.sender, "Cannot approve own proposal");
        require(proposals[index].expires > now, "Proposal has expired");
        require(proposals[index].open == true, "Proposal is closed");

        if (votes[index][msg.sender] != true) {
            votes[index][msg.sender] = true;
            proposals[index].count = proposals[index].count.add(1);
            emit Vote(index);

            if (proposals[index].count >= proposals[index].required) {
                proposals[index].open = false;
            }
        }
    }

    function updateMember(address who, bool isAuthorised) public onlyOwner() {
        require(who != address(0), "Invalid address");

        //change state
        if (members[who] != isAuthorised) {
            if (isAuthorised == true) {
                membersCount = membersCount.add(1);
            } else {
                membersCount = membersCount.sub(1);
            }
        }

        members[who] = isAuthorised;
    }

    modifier onlyMembers() {
        require(members[msg.sender] == true, "Sender is not a member");
        _;
    }

    event Vote(uint256 index); 
}