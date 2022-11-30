# Agrop Smart Contract

## Contract Address

https://goerli.etherscan.io/address/0x3b54fA1db2484a697bD3690a274FbDdC00B8edF8

## Revert/Require

### Reverted error codes and their equivalent messages

#### Agrop

1. o1 - Owner: caller must be agrop owner
1. ag1 - Agrop: \_hub.plan must be monthly, quarterly, yearly
1. ag2 - Agrop: msg.value must be equal to \_hub.plan when creating new hub.
1. ag3 - Agrop: Hub not exist
1. ag4 - Agrop: `from` must be greater or equals to `to` for DESC pagination order
1. ag5 - Agrop: page length can't be more than 10 for DESC pagination order
1. ag6 - Agrop: \_plan must be monthly, quarterly, yearly
1. ag7 - Agrop: msg.value must be equal to \_plan when creating new hub.
1. ag8 - Agrop: \_plan must be monthly, quarterly, yearly
1. ag9 - Agrop: subscription fee must be more than zero
1. ag10 - Agrop: \_plan must be monthly, quarterly, yearly
1. ag11 - Agrop: subscription fee duration must be more than zero
1. o2 - Ownable: Agrop owner can't the zero addresss

#### Hub

1. o3 - Agrop: caller must be agrop contract
1. h1 - Agrop: Hub subscription has expired
1. h2 - Agrop: owner is permitted to freeze if not freezed
1. h3 - Agrop: owner is permitted to unfreeze if freezed
1. h4 - Agrop: owner is permitted to verify if not verified
1. h5 - Agrop: owner is permitted to unverify if verified
1. h6 - Agrop: \_crop.family must be pepper, vegetables, fruits, maize, cassava, or cocoa
1. h7 - Agrop: \_crop.name,\_crop.description,\_crop.thumbnails,\_crop.videos,\_crop.soil, \_crop.climate,\_crop.tools,\_crop.season,\_crop.daytime, and \_crop.store are required
1. h8 - Agrop: `from` must be greater or equals to `to` for DESC pagination order
1. h9 - Agrop: page length can't be more than 10 for DESC pagination order
