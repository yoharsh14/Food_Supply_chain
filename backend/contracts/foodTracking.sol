//SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

contract trackFood {
    event OrderCreated(
        string indexed productName,
        uint indexed productCost,
        address manufacturer,
        address reciever
    );
    enum STATE {
        ordered,
        payed,
        shipped,
        delivered
    }
    struct Food {
        string productName;
        STATE state;
        string timeOfDispatch;
        string currentLocation;
        string expectedDelivery;
        string recieverLocation;
        address manufacturerAddress;
        address recieverAddress;
        uint productCost;
        bool exist;
    }
    struct Owe {
        address reciever;
        uint amount;
    }
    struct Order {
        uint amount;
        string productCatogery;
        string productName;
        bool payed;
    }
    mapping(string => mapping(string => Food)) public foods;
    mapping(address => mapping(string => Owe)) public costOwned;
    mapping(address => Owe[]) owes;
    mapping(address => Order) orderDetails;
    address private immutable owner;
    address[] private creators;

    constructor() {
        owner = msg.sender;
        creators.push(msg.sender);
    }

    modifier isOwner() {
        require(msg.sender == owner, "You are not the owner");
        _;
    }
    modifier isCreator() {
        bool isACreator = false;
        for (uint i = 0; i < creators.length; i++) {
            if (creators[i] == msg.sender) isACreator = true;
        }
        require(isACreator, "You are not a creator of the shipment");
        _;
    }
    modifier productExist(
        string memory _productCatogery,
        string memory _productName
    ) {
        require(
            foods[_productCatogery][_productName].exist,
            "This product does not exist"
        );
        _;
    }

    function balance() public view isOwner returns (uint256) {
        return payable(address(this)).balance;
    }

    function addCreator(address creator) public isOwner {
        creators.push(creator);
    }

    function Initiation(
        string memory _productName,
        string memory _productCatogery,
        string memory _timeOfDispatch,
        string memory _currentLocation,
        string memory _expectedDelivery,
        string memory _recieverLocation,
        address _manufacturerAddress,
        address _recieverAddress,
        uint _productCost
    ) public isCreator {
        Food memory food = Food(
            _productName,
            STATE.ordered,
            _timeOfDispatch,
            _currentLocation,
            _expectedDelivery,
            _recieverLocation,
            _manufacturerAddress,
            _recieverAddress,
            _productCost,
            true
        );
        foods[_productCatogery][_productName] = food;
        Owe memory productCost = Owe(_manufacturerAddress, _productCost);
        costOwned[_manufacturerAddress][_productName] = productCost;
        emit OrderCreated(
            _productName,
            _productCost,
            _manufacturerAddress,
            _recieverAddress
        );
    }

    function order(
        string memory _productName,
        string memory _productCategory
    ) public payable {
        uint cost = foods[_productCategory][_productName].productCost;
        if (msg.value < cost) {
            delete foods[_productCategory][_productName];
            require(msg.value >= cost, "You need to spend more");
        } else {
            foods[_productCategory][_productName].state = STATE.payed;
            orderDetails[msg.sender] = Order(
                cost,
                _productCategory,
                _productName,
                true
            );
        }
    }

    function Shipped(
        string memory _productCatogery,
        string memory _productName,
        address recieverAddress
    ) public productExist(_productCatogery, _productName) {
        //state of Food changed
        require(
            foods[_productCatogery][_productName].state == STATE.payed &&
                orderDetails[recieverAddress].payed,
            "Product not exit or Eth is not payed"
        );
        foods[_productCatogery][_productName].state = STATE.shipped;
    }

    function approveDelivery(
        string memory _productCatogery,
        string memory _productName
    ) public productExist(_productCatogery, _productName) {
        require(
            msg.sender ==
                foods[_productCatogery][_productName].recieverAddress &&
                foods[_productCatogery][_productName].state == STATE.shipped,
            "You are not the reciever of this item"
        );
        foods[_productCatogery][_productName].state = STATE.delivered;
        delivered(_productCatogery, _productName);
    }

    function delivered(
        string memory _productCatogery,
        string memory _productName
    ) private productExist(_productCatogery, _productName) {
        address payable to = payable(
            foods[_productCatogery][_productName].manufacturerAddress
        );
        uint amount = foods[_productCatogery][_productName].productCost;
        delete foods[_productCatogery][_productName];
        (bool sent, ) = to.call{value: amount}("");
        require(sent, "failed to send Ether");
    }
}

// contract outline
//  1. Features
//       a.) Food Item by catogery
//       b.) Time of dipatch, expected delivery.
//       c.) Current location.
//       d.) Quality check at every step.
//  2. Ownership
//       a.) Dispatcher.
//       b.) Movers.
//       c.) Reciever.
//       d.) owner.

// workflow of the product
// food manufactured -> packeged -> moved -> delivered

// money flow
// money is stored in the COA -> after the delivery of the product portion of payment is sent to mover and manufacturer
