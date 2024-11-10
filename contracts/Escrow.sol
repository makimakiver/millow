//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

interface IERC721 {
    function transferFrom(
        address _from,
        address _to,
        uint256 _id
    ) external;
}
// list of function I need to add
// 1: seller can list the property
// 2: Buyer deposits earnset
// 3: Appraisal 
// 4: Lenders can get invovlve
// 5: Lender funds
// 6: transfer ownership
// 7: seller get paid
contract Escrow {
    // 0: setting state variables

    address public lender;
    address public inspector;
    address public nftAddress;
    
    modifier onlyBuyer(uint _nftID){
        require(msg.sender == buyer[_nftID], "Only buyer can call this method");
        _;
    }
    modifier onlySeller() {
        require(msg.sender == seller, "Only seller can call this method");
        _;
    }
    modifier onlyInspector() {
        require(msg.sender == inspector, "Only inspector can call this method");
        _;
    }
    mapping(uint256 => bool) public isListed;
    mapping(uint256 => uint256) public purchasePrice;
    mapping(uint256 => uint256) public escrowAmount;
    mapping(uint256 => address) public buyer;
    mapping(uint256 => bool) public inspectionPassed;
    mapping(uint256 => mapping(address => bool)) public approval;
    // seller must be payable as seller will receive the ethereum in the web
    address payable public seller;

    constructor(
        address _nftAddress, 
        address payable _seller, 
        address _inspector, 
        address _lender
        ){
            // its like constructing object in python
            nftAddress = _nftAddress;
            seller = _seller;
            inspector = _inspector;
            lender = _lender;
    }

    // 1: list the property
    // take nft ID as an argument
    function list(
        uint256 _nftID,
        address _buyer, 
        uint256 _purchasePrice, 
        uint256 _escrowAmount)
        public payable onlySeller {
            // before the transaction, we nhave to have owner's consent to move tokens out of their wallet

            // Transfer NFT from seller to this contract
            IERC721(nftAddress).transferFrom(msg.sender, address(this), _nftID);
            isListed[_nftID] = true;
            purchasePrice[_nftID] = _purchasePrice;
            escrowAmount[_nftID] = _escrowAmount;
            buyer[_nftID] = _buyer;
    }
    // put under Contract (only buyer can pay or payable on escrow)
    function updateInspectionStatus(uint256 _nftID, bool _passed) public onlyInspector{
    // 2: inspection initially we need to make a mapping for the inspection status
        inspectionPassed[_nftID] = _passed;
    }

    function depositEarnest(uint256 _nftID) public payable onlyBuyer(_nftID) {
        require(msg.value >= escrowAmount[_nftID]);
    }

    receive() external payable {}
    // this refers to the address of current contract
    function getBalance() public view returns (uint256){
        return address(this).balance;
    }

    // 5lender approval
    function approveSale(uint256 _nftID) public {
        approval[_nftID][msg.sender] = true;
    }
    // Finalise the sale
    // require inspection status 
    // require sale to be authorized 
    // require funds to be correct amount
    // transger NFT to buyer
    // transfer NFT to seller
    function finalizeSale(uint256 _nftID) public {
        require(inspectionPassed[_nftID]);
        require(approval[_nftID][buyer[_nftID]]);
        require(approval[_nftID][seller]);
        require(approval[_nftID][lender]);
        require(address(this).balance >= purchasePrice[_nftID]);

        isListed[_nftID] = false;

        (bool success, ) = payable(seller).call{value: address(this).balance}("");
        require(success);

        IERC721(nftAddress).transferFrom(address(this), buyer[_nftID], _nftID);
    }
    
    function cancelSale(uint256 _nftID) public {
        if(!inspectionPassed[_nftID]){
            payable(buyer[_nftID]).transfer(address(this).balance);
        }
        else{
            payable(seller).transfer(address(this).balance);
        }
    }
}
