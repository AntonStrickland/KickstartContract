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

        // Contributors cannot contribute more than once from the same address
        //require(!approvers[msg.sender]);

        // All contributors must send at least the minimum amount
        require(msg.value >= minimumContribution);

        // If this is a new approver, increment the count
        if (!approvers[msg.sender])
          approversCount++;

        approvers[msg.sender] = true;
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

        // Require that the campaign actually has enough money to send
        require(address(this).balance >= request.value);

        // Send the money to the receipient and mark request as complete
        request.recipient.transfer(request.value);
        request.complete = true;
    }

    function getSummary() public view returns(
      uint, uint, uint, uint, address
      ) {

      return (
          minimumContribution,
          address(this).balance,
          requests.length,
          approversCount,
          manager
        );

    }

    function getRequestsCount() public view returns (uint) {
      return requests.length;
    }


}
