// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

interface IAgrop {
    struct HubOptions {
        string name;
        string description;
        string digit;
        string location;
        string[] thumbnails;
        string[] documents;
        string plan;
    }

    struct AgropCropOptions {
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
    }

    struct CropOptionsForQuality {
        string family;
        string soil;
        uint256[] climate;
        string[] tools;
        string season;
        string daytime;
        string store;
    }

    event Log(string eventName);
}
