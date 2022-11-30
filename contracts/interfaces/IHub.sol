// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "./IAgrop.sol";

interface IHub {
    struct HubInfo {
        address _contract;
        string _name;
        string _description;
        string _digit;
        string _location;
        string[] _thumbnails;
        string[] _documents;
        string _plan;
        uint256 _subscriptionExpiresAt;
        uint256 _cropCounter;
        bool _verified;
        bool _freezed;
    }

    struct HubCropOptions {
        string name;
        string family;
        string description;
        uint256 price;
        string[] thumbnails;
        string[] videos;
        string soil;
        uint256[] climate;
        string[] tools;
        string season;
        string daytime;
        string store;
        // quality percent
        uint256 quality;
    }
}
