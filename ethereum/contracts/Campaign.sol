pragma solidity ^0.4.17;

contract CampaignFactory {

    address[] public deployedCampaigns;

    function createCampaign(uint minimum) public {
        address newCampaign = new Campaign(minimum, msg.sender);
        deployedCampaigns.push(newCampaign);
    }

    function getDeployedCampaigns() public view returns (address[]) {
        return deployedCampaigns;
    }
}

contract Campaign {

    struct Request {
        string description;
        uint value;
        address recipient;
        bool complete;
        uint approvalCount;
        mapping(address => bool) approvals;
    }

    address public manager;
    uint public minimumContribution;

    mapping(address => bool) public approvers;
    uint public approversCount;

    Request[] public requests;

    modifier onlyManager() {
        require(msg.sender == manager);
        _;
    }

    constructor(uint minimum, address creator) public {
        manager = creator;
        minimumContribution = minimum;
    }

    function contribute() public payable {

        // All contributors must send at least the minimum amount
        require(msg.value >= minimumContribution);

        approvers[msg.sender] = true;
        approversCount++;
    }

    function createRequest(string description, uint value, address recipient) public onlyManager {
        Request memory newRequest = Request({
           description: description,
           value: value,
           recipient: recipient,
           complete: false,
           approvalCount: 0
        });

        requests.push(newRequest);
    }

    function approveRequest(uint index) public {

        Request storage request = requests[index];

        // Require that the sender is a contributer
        require(approvers[msg.sender]);

        // Require that the sender has not voted on this before
        require(!request.approvals[msg.sender]);

        // Register the approval
        request.approvals[msg.sender] = true;
        request.approvalCount++;

    }

    function finalizeRequest(uint index) public onlyManager {

        Request storage request = requests[index];

        // Require that more than 50% of contributers approve this request
        require(request.approvalCount > (approversCount / 2));

        // Require that this request is not already complete
        require(!request.complete);

        // Send the money to the receipient and mark request as complete
        request.recipient.transfer(request.value);
        request.complete = true;
    }


}
