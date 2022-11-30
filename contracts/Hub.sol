// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "./interfaces/IHub.sol";
import "./interfaces/IAgrop.sol";
import "./interfaces/IAgropQuality.sol";

contract Hub is IHub, IAgrop {
    // agrop contract address
    address public agrop;

    // farmer
    address public owner;

    // hub details
    string public name;
    string public description;
    string public digit;
    string public location;
    string[] public thumbnails;
    string[] public documents;
    string public plan;

    // subscriptionExpiresAt - hub subscription ends at
    uint256 public subscriptionExpiresAt;

    // verified - for toggling hub verification.
    // freezed - for toggling hub freezing.
    bool public verified;
    bool public freezed;

    // crops and crop counter
    mapping(uint256 => HubCropOptions) public crops;
    uint256 public counter;

    // caller must be agrop contract
    modifier onlyAgrop() {
        require(agrop == msg.sender, "o3");
        _;
    }

    // is hub subscription active
    modifier isSubscriptionActive() {
        require(subscriptionExpiresAt >= block.timestamp, "h1");
        _;
    }

    // modifiers for freezed
    modifier ifNotFreezed() {
        require(freezed == false, "h2");
        _;
    }
    modifier ifFreezed() {
        require(freezed == true, "h3");
        _;
    }

    // modifiers for verified
    modifier ifNotVerified() {
        require(verified == false, "h4");
        _;
    }
    modifier ifVerified() {
        require(verified == true, "h5");
        _;
    }

    /// @dev
    /// constructor
    constructor(
        HubOptions memory _hub,
        address _owner,
        uint256 _duration
    ) {
        // set deployer to agrop
        // set owner to farmer address
        agrop = msg.sender;
        owner = _owner;

        // hub
        name = _hub.name;
        description = _hub.description;
        digit = _hub.digit;
        location = _hub.location;
        thumbnails = _hub.thumbnails;
        documents = _hub.documents;
        plan = _hub.plan;
        subscriptionExpiresAt = block.timestamp + _duration;
        counter = 0;

        // verified | freezed
        verified = false;
        freezed = false;
    }

    /// @dev
    /// get hub details
    function details()
        public
        view
        onlyAgrop
        isSubscriptionActive
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
        return (
            address(this),
            name,
            description,
            digit,
            location,
            thumbnails,
            documents,
            plan,
            subscriptionExpiresAt,
            counter,
            verified,
            freezed
        );
    }

    /// @dev
    /// add crop to hub
    function addCrop(AgropCropOptions memory _crop)
        external
        onlyAgrop
        ifNotFreezed
        isSubscriptionActive
        returns (bool)
    {
        // _crop.family must be pepper, vegetables, fruits, maize, cassava, or cocoa
        bool crop = keccak256(bytes(_crop.family)) ==
            keccak256(bytes("pepper")) ||
            keccak256(bytes(_crop.family)) == keccak256(bytes("vegetables")) ||
            keccak256(bytes(_crop.family)) == keccak256(bytes("fruits")) ||
            keccak256(bytes(_crop.family)) == keccak256(bytes("maize")) ||
            keccak256(bytes(_crop.family)) == keccak256(bytes("cassava")) ||
            keccak256(bytes(_crop.family)) == keccak256(bytes("cocoa"));

        //
        require(crop, "h6");

        // deployed IAgropQuality smart contract
        IAgropQuality _contract = IAgropQuality(
            0xf0F5A120A22f16309360466d0bF7844D3b5c7E4A
        );

        // calculate the quality
        uint256 quality = _contract.calculateQuality(
            CropOptionsForQuality(
                _crop.family,
                _crop.soil,
                _crop.climate,
                _crop.tools,
                _crop.season,
                _crop.daytime,
                _crop.store
            )
        );

        // add crop with the calculated percent
        // increment counter
        counter++;

        crops[counter] = HubCropOptions(
            _crop.name,
            _crop.family,
            _crop.description,
            _crop.price,
            _crop.thumbnails,
            _crop.videos,
            _crop.soil,
            _crop.climate,
            _crop.tools,
            _crop.season,
            _crop.daytime,
            _crop.store,
            // quality percent
            quality
        );

        // return true
        return true;
    }

    /// @dev
    /// paginate all crops in farmers' hub
    function paginateCrops(uint256 _from, uint256 _to)
        public
        view
        onlyAgrop
        ifNotFreezed
        isSubscriptionActive
        returns (HubCropOptions[] memory)
    {
        require(_from >= _to, "h8");

        require((_from - _to) <= 10, "h9");

        HubCropOptions[] memory _crop = new HubCropOptions[]((_from - _to) + 1);
        uint256 k = 0;

        for (uint256 i = _from; i >= _to; i--) {
            // assign to array
            _crop[k].name = crops[i].name;
            _crop[k].family = crops[i].family;
            _crop[k].description = crops[i].description;
            _crop[k].price = crops[i].price;
            _crop[k].thumbnails = crops[i].thumbnails;
            _crop[k].videos = crops[i].videos;
            _crop[k].soil = crops[i].soil;
            _crop[k].climate = crops[i].climate;
            _crop[k].tools = crops[i].tools;
            _crop[k].season = crops[i].season;
            _crop[k].daytime = crops[i].daytime;
            _crop[k].store = crops[i].store;
            _crop[k].quality = crops[i].quality;

            k++;
        }

        // return result
        return _crop;
    }

    /// @dev
    /// renew subscription
    function renewSubscription(string memory _plan, uint256 _duration)
        external
        onlyAgrop
        ifNotFreezed
    {
        // set plan and subscriptionExpiresAt
        plan = _plan;
        subscriptionExpiresAt = block.timestamp + _duration;
    }

    // @dev
    /// freeze hub
    function freeze() external onlyAgrop ifNotFreezed {
        // freezed hub
        freezed = true;
    }

    // @dev
    /// unfreeze hub
    function unfreeze() external onlyAgrop ifFreezed {
        // unfreezed hub
        freezed = false;
    }

    // @dev
    /// verify hub
    function verify() external onlyAgrop ifNotVerified {
        // verified hub
        verified = true;
    }

    // @dev
    /// unverify hub
    function unverify() external onlyAgrop ifVerified {
        // unverified hub
        verified = false;
    }
}
