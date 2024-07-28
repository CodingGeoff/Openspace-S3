// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "forge-std/console.sol";
contract RNT is ERC20("RNTcoin", "RNT"){
    // address public account;
    address public owner;

    constructor(){
        owner = msg.sender;
        _mint(owner, 1000000 * 10**18);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "caller is not the owner");
        _;
    }

    function setOwner(address newOwner) public onlyOwner {
        owner = newOwner;
    }
    function transfer(address to, uint256 amount) public override virtual returns (bool) {
        require(amount <= balanceOf(msg.sender), "Not enough RNT tokens");
        return super.transfer(to, amount);
    }
}
contract RNTIDO {
    address public owner;
    uint256 public constant RNT_PRICE = 0.0001 ether;
    uint256 public constant RNT_SUPPLY = 1000000 * 10**18;
    uint256 public constant MIN_CONTRIBUTION = 0.01 ether;
    uint256 public constant MAX_CONTRIBUTION = 0.1 ether;
    uint256 public constant FUNDING_GOAL = 0.5 ether;
    uint256 public constant FUNDING_CAP = 1 ether;
    uint256 public totalbalance;
    // uint256 public constant FUNDING_GOAL = 100 ether;
    // uint256 public constant FUNDING_CAP = 200 ether;
    uint256 public endTime;
    bool public isFinalized = false;
    RNT public rnt;




    mapping(address => uint256) public contributions;

    event Contribution(address indexed contributor, uint256 amount);
    event Refund(address indexed contributor, uint256 amount);
    event TokensIssued(address indexed contributor, uint256 amount);
    event FundingSuccess(uint256 currentFund, uint256 fundingGoal, uint256 fundingCap);
    event FundingFailed(uint256 currentFund, uint256 fundingGoal, uint256 fundingCap);


    constructor(uint256 _duration) {
        owner = msg.sender;
        endTime = block.timestamp + _duration;
        rnt = new RNT();
        rnt.transfer(address(this), RNT_SUPPLY);
        // rnt.mint(RNT_SUPPLY);
        // TODO: transfer RNT to this contract?
    }

    modifier onlyOwner() {
        console.log(msg.sender);
        require(msg.sender == owner, "Not the owner");
        _;
    }


    modifier onlyBeforeEnd() {
        require(block.timestamp < endTime, "IDO has ended");
        _;
    }

    // modifier onlyAfterEnd() {
    //     require(block.timestamp >= endTime, "IDO is still ongoing");
    //     _;
    // }

    modifier onlySuccess() {
        console.log("address(this).balance: ", address(this).balance);
        require(address(this).balance >= FUNDING_GOAL, "Funding goal not reached");
        _;
    }

    modifier onFailed() {
        require(address(this).balance < FUNDING_GOAL, "Funding goal reached");
        _;
    }



    function contribute() external payable onlyBeforeEnd {
        require(msg.value >= MIN_CONTRIBUTION, "Contribution too low");
        require(msg.value <= MAX_CONTRIBUTION, "Contribution too high");
        require(address(this).balance + msg.value <= FUNDING_CAP, "Funding cap reached");
        // todo: how does user transfer eth ?
        // payable(address(this)).transfer(msg.value);
        contributions[msg.sender] += msg.value;
        totalbalance += msg.value;
        // address(this).balance += msg.value;
        emit Contribution(msg.sender, msg.value);

        if (address(this).balance >= FUNDING_CAP) {
            finalize();
        }
    }

    function admin_contribute() external payable onlyOwner(){
        // This function is for testing only, do not deploy it
    }


    function finalize() public {
        require(!isFinalized, "Already finalized");
        // console.log("address(this).balance: ", address(this).balance);
        // console.log("address(this): ", address(this));
        if (address(this).balance >= FUNDING_GOAL && address(this).balance <= FUNDING_CAP) {
            emit FundingSuccess(address(this).balance, FUNDING_GOAL, FUNDING_CAP);
            console.log("Funding Success");
            isFinalized = true;
        } else {
            emit FundingFailed(address(this).balance, FUNDING_GOAL, FUNDING_CAP);
            console.log("Funding Failed");
            isFinalized = false;
        }
    }

    function claim() external onlySuccess {
        uint256 contribution = contributions[msg.sender];
        require(contribution > 0, "No contribution to claim");

        uint256 tokenAmount = (RNT_SUPPLY * contribution) / address(this).balance;
        contributions[msg.sender] = 0;
        // contributions[msg.sender] = contribution;

        // Issue tokens to contributor
        emit TokensIssued(msg.sender, tokenAmount);
        // could be an issue...
        // rnt.mint(tokenAmount);
        rnt.transfer(msg.sender, tokenAmount);
    }

    function refund() external onFailed {
        uint256 contribution = contributions[msg.sender];
        require(contribution > 0, "No contribution to refund");
        contributions[msg.sender] = 0;
        // payable(msg.sender).transfer(contribution);
        emit Refund(msg.sender, contribution);
    }

    // function withdrawFunds(uint256 amount) external onlyOwner onlySuccess {
        // require(amount <= address(this).balance / 10 , "Insufficient balance");
    function withdrawFunds() external onlyOwner onlySuccess {
        payable(owner).transfer(totalbalance);
        totalbalance = 0;
    }
}


