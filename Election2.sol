
// Given the following election contract which uses the hash-commit-reveal scheme,
// implement the logic for the constructor, commitVote() and revealVote() functions.
// Assume that vote hashes are generated using keccak256,
// and votes are submitted in the format: “1-somepassword” (if voting for choice1 )
// or “2-someotherpassword” (if voting for choice2).
// Voters can only submit one vote and reveal one vote.
// All submitted votes must be revealed before announcing a winner.
// Add any state variables or functions you need, and emit the ElectionWinner event to announce the winner.

pragma solidity 0.4.24;

contract CommitRevealElection {
    string public candidate1;
    string public candidate2;
    uint public commitPhaseEndTime;
    bytes32 commit;

    event ElectionWinner(string winner, uint voteCount);

    // Add any other state variables you need

    constructor(uint _commitPhaseDurationInMinutes, string _candidate1, string _candidate2) public {
        candidate1 = _candidate1;
        candidate2 = _candidate2;
        commitPhaseEndTime = now + (_commitPhaseDurationInMinutes * 1 minutes);
    }
    
    
    // _voteHash is computed based on the keccak256 of user's
    // vote and their password of their choice
    // e.g. keccak256('1-votersPassword')
    //function commitVote(string _name) public{
        
    }
    function submitVote(bytes32 _voteHash) public {
        
    }

    // _vote is the msg that was hashed in submitVote (e.g. '1-votersPassword')
    // Add checks to make sure the _vote is in the correct format,
    // otherwise don't count the vote.
    function revealVote(string _vote) public {
    }

    // Only announce winner when everyone who submitted their vote has revealed their vote
    function announceWinner() public {
    }
}
