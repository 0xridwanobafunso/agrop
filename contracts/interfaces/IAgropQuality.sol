// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "./IAgrop.sol";

interface IAgropQuality is IAgrop {
    // @dev
    /// validate crop options input
    function calculateQuality(CropOptionsForQuality memory _crop)
        external
        pure
        returns (uint256);
}
