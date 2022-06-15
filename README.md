 [![Test](https://github.com/chee-chyuan/starknet_basecamp_edu/actions/workflows/tests.yml/badge.svg)](https://github.com/chee-chyuan/starknet_basecamp_edu/actions/workflows/tests.yml)
 
 # Toy Example to Get Graduation Eligibility from Basecamp Cohort 0

## Moderator's role
1. Deployer of the contract will be the `moderator`
2. `moderator` will need to set the `bridge_messaging_address` and `cairo_101_address` address by calling `set_erc20_addresses`
3. `moderator` will need to set the required points for each the two Erc20 token to graduate by calling `set_required_point`
4. `moderator` will need to start the registration status to allow student to register by calling `set_allow_register`
5. `moderator` can end the registration period
6. In order to reward students with an NFT upon graduation, a moderator will need to deploy `starknetbasecamp.cairo` and provide the relevant details in the constructor. (including the `basecamp_cohort_0.cairo` address)
7. The `moderator` will then need to call `set_starknet_basecamp_address` in `basecamp_cohort_0.cairo` to set the NFT address

## Student's role
1. Register themselves by calling `student_register`
2. Complete assigment at [Starknet Cairo 101](https://github.com/starknet-edu/starknet-cairo-101) and [Starknet Messaging Bridge](https://github.com/starknet-edu/starknet-messaging-bridge) to obtain enough points to graduate
3. Students upon completion can call `mint_basecamp_token` to obtain a graduation NFT
