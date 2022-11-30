// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "./Hub.sol";
import "./interfaces/IAgrop.sol";
import "./interfaces/IHub.sol";

contract Agrop is IAgrop, IHub {
    // agrop owner
    address public owner;

    // hubs and hub counter
    mapping(uint256 => address) public hubs;
    uint256 public counter;

    // subscription fees
    mapping(string => mapping(string => uint256)) public fees;

    // farmers
    mapping(address => address[]) public farmers;

    modifier onlyOwner() {
        require(owner == msg.sender, "o1");
        _;
    }

    /// @dev
    constructor(
        uint256 _monthlyFee,
        uint256 _quarterlyFee,
        uint256 _yearlyFee
    ) {
        // set owner(deployer) to msg.sender and counter to 0
        owner = msg.sender;
        counter = 0;

        // set subscription fee
        // monthly
        fees["monthly"]["fee"] = _monthlyFee;
        fees["monthly"]["duration"] = 30 days;
        // quarterly
        fees["quarterly"]["fee"] = _quarterlyFee;
        fees["quarterly"]["duration"] = 90 days;
        // yearly
        fees["yearly"]["fee"] = _yearlyFee;
        fees["yearly"]["duration"] = 365 days;
    }

    /// @dev
    /// create new hub for farmer.
    function createHub(HubOptions memory _hub)
        external
        payable
        returns (address)
    {
        // when _hub.plan = 'mon' or anything then the fee will equal to 0 leading to paying zero fee for creating hub
        // since this is a dapp, anybody can call createHub with _hub.plan = 'mon' or anything, we can prevent the
        // creation of hub when _hub.plan is not monthly, quarterly, yearly.
        bool plan = keccak256(bytes(_hub.plan)) ==
            keccak256(bytes("monthly")) ||
            keccak256(bytes(_hub.plan)) == keccak256(bytes("quarterly")) ||
            keccak256(bytes(_hub.plan)) == keccak256(bytes("yearly"));

        // _hub.plan must be monthly, quarterly, yearly
        require(plan, "ag1");

        // get plan fee
        uint256 _fee = fees[_hub.plan]["fee"];

        // ensure msg.value is greater than zero to pay subscription fee
        require(msg.value == _fee, "ag2");

        // create new hub
        Hub hub = new Hub(_hub, msg.sender, fees[_hub.plan]["duration"]);

        // increment counter
        counter++;

        hubs[counter] = address(hub);

        // push address
        farmers[msg.sender].push(address(hub));

        // emit log event
        emit Log("HubCreated");

        // return hub address
        return address(hub);
    }

    /// @dev
    /// view farmer hubs in agrop
    function viewHubs(address _farmerAddress)
        public
        view
        returns (address[] memory)
    {
        return farmers[_farmerAddress];
    }

    /// @dev
    /// view single farmer hub in agrop
    function viewHub(address _hubAddress)
        public
        view
        returns (
            address,
            string memory,
            string memory,
            string memory,
            string memory,
            string[] memory,
            string[] memory,
            string memory,
            uint256,
            uint256,
            bool,
            bool
        )
    {
        Hub _hub = Hub(_hubAddress);

        // is hub exist?
        require(_hub.agrop() != address(0), "ag3");

        // return details
        return _hub.details();
    }

    /// @dev
    /// add crop to farmers' hub
    function addCropToHub(address _hubAddress, AgropCropOptions memory _crop)
        external
        returns (bool)
    {
        Hub _hub = Hub(_hubAddress);

        // is hub exist?
        require(_hub.agrop() != address(0), "ag3");

        // emit log event
        emit Log("CropAdded");

        // add crop to hub
        return _hub.addCrop(_crop);
    }

    /// @dev
    /// view all crop in hub
    function paginateCropsInHub(
        address _hubAddress,
        uint256 _from,
        uint256 _to
    ) public view returns (HubCropOptions[] memory) {
        Hub _hub = Hub(_hubAddress);

        // is hub exist?
        require(_hub.agrop() != address(0), "ag3");

        // add crop to hub
        return _hub.paginateCrops(_from, _to);
    }

    /// @dev
    /// paginate all farmers' hub in agrop
    function paginateHubs(uint256 _from, uint256 _to)
        public
        view
        returns (HubInfo[] memory)
    {
        require(_from >= _to, "ag4");

        require((_from - _to) <= 10, "ag5");

        HubInfo[] memory _hubs = new HubInfo[]((_from - _to) + 1);
        uint256 k = 0;

        for (uint256 i = _from; i >= _to; i--) {
            // get hub details
            (
                address _contract,
                string memory _name,
                string memory _description,
                string memory _digit,
                string memory _location,
                string[] memory _thumbnails,
                string[] memory _documents,
                string memory _plan,
                uint256 _subscriptionExpiresAt,
                uint256 _cropCounter,
                bool _verified,
                bool _freezed
            ) = viewHub(hubs[i]);

            // assign to array
            _hubs[k]._contract = _contract;
            _hubs[k]._name = _name;
            _hubs[k]._description = _description;
            _hubs[k]._digit = _digit;
            _hubs[k]._location = _location;
            _hubs[k]._thumbnails = _thumbnails;
            _hubs[k]._documents = _documents;
            _hubs[k]._plan = _plan;
            _hubs[k]._subscriptionExpiresAt = _subscriptionExpiresAt;
            _hubs[k]._cropCounter = _cropCounter;
            _hubs[k]._verified = _verified;
            _hubs[k]._freezed = _freezed;

            k++;
        }

        // return result
        return _hubs;
    }

    /// @dev
    /// renew farmers' hub subscription
    function renewHubSubscription(address _hubAddress, string memory _plan)
        external
        payable
    {
        Hub _hub = Hub(_hubAddress);

        // is hub exist?
        require(_hub.agrop() != address(0), "ag3");

        // when _plan = 'mon' or anything then the fee will equal to 0 leading to paying zero fee for creating hub
        // since this is a dapp, anybody can call createHub with _plan = 'mon' or anything, we can prevent the
        // creation of hub when _plan is not monthly, quarterly, yearly.
        bool plan = keccak256(bytes(_plan)) == keccak256(bytes("monthly")) ||
            keccak256(bytes(_plan)) == keccak256(bytes("quarterly")) ||
            keccak256(bytes(_plan)) == keccak256(bytes("yearly"));

        // _plan must be monthly, quarterly, yearly
        require(plan, "ag6");

        // get plan fee
        uint256 _fee = fees[_plan]["fee"];

        // ensure msg.value is greater than zero to pay subscription fee
        require(msg.value == _fee, "ag7");

        // renew subscription
        _hub.renewSubscription(_plan, fees[_plan]["duration"]);

        // emit log event
        emit Log("SubscriptionRenewed");
    }

    /// @dev
    /// freeze hub
    function freezeHub(address _hubAddress) external onlyOwner {
        Hub _hub = Hub(_hubAddress);

        // is hub exist?
        require(_hub.agrop() != address(0), "ag3");

        // freeze hub
        _hub.freeze();

        // emit log event
        emit Log("HubFreezed");
    }

    /// @dev
    /// freeze hub
    function unfreezeHub(address _hubAddress) external onlyOwner {
        Hub _hub = Hub(_hubAddress);

        // is hub exist?
        require(_hub.agrop() != address(0), "ag3");

        // unfreeze hub
        _hub.unfreeze();

        // emit log event
        emit Log("HubUnfreezed");
    }

    /// @dev
    /// verify hub
    function verifyHub(address _hubAddress) external onlyOwner {
        Hub _hub = Hub(_hubAddress);

        // is hub exist?
        require(_hub.agrop() != address(0), "ag3");

        // verify hub
        _hub.verify();

        // emit log event
        emit Log("HubVerified");
    }

    /// @dev
    /// unverify hub
    function unverifyHub(address _hubAddress) external onlyOwner {
        Hub _hub = Hub(_hubAddress);

        // is hub exist?
        require(_hub.agrop() != address(0), "ag3");

        // unverify hub
        _hub.unverify();

        // emit log event
        emit Log("HubUnverified");
    }

    /// @dev
    function changeSubscriptionFee(string memory _plan, uint256 _amount)
        external
        onlyOwner
    {
        // _plan must monthly, quarterly, yearly
        bool plan = keccak256(bytes(_plan)) == keccak256(bytes("monthly")) ||
            keccak256(bytes(_plan)) == keccak256(bytes("quarterly")) ||
            keccak256(bytes(_plan)) == keccak256(bytes("yearly"));

        // _plan must be monthly, quarterly, yearly
        require(plan, "ag8");

        require(_amount > 0, "ag9");

        fees[_plan]["fee"] = _amount;

        // emit log event
        emit Log("SubscriptionFeeChanged");
    }

    /// @dev
    function changeSubscriptionDuration(string memory _plan, uint256 _days)
        external
        onlyOwner
    {
        // _plan must monthly, quarterly, yearly
        bool plan = keccak256(bytes(_plan)) == keccak256(bytes("monthly")) ||
            keccak256(bytes(_plan)) == keccak256(bytes("quarterly")) ||
            keccak256(bytes(_plan)) == keccak256(bytes("yearly"));

        // _plan must be monthly, quarterly, yearly
        require(plan, "ag10");

        require(_days > 0, "ag11");

        fees[_plan]["duration"] = _days * 1 days;

        // emit log event
        emit Log("SubscriptionDurationChanged");
    }

    /// @dev
    /// withdraw amount of funds to owner (deployer) address
    function withdraw(uint256 _amount) external onlyOwner {
        require(_amount > 0, "ag12");

        payable(owner).transfer(_amount);

        // emit log event
        emit Log("FundWithdrawn");
    }

    /// @dev
    /// set new Agrop contract ownership
    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "o2");

        owner = newOwner;

        // emit log event
        emit Log("OwnerChanged");
    }

    /// @dev
    /// renounce Agrop contract and set ownership to zero address
    function renounceOwnership() external onlyOwner {
        owner = address(0);

        // emit log event
        emit Log("OwnerRenounced");
    }

    /// @dev
    /// return ETH to sender if blindly sent to Agrop contract.
    receive() external payable {
        payable(msg.sender).transfer(msg.value);
    }
}
