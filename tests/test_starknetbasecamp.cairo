%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.uint256 import Uint256, uint256_eq
from starkware.cairo.common.bool import TRUE, FALSE
from starkware.cairo.common.alloc import alloc
from starkware.starknet.common.syscalls import get_contract_address, get_caller_address
from src.interfaces.Istarknetbasecamp import IStarknetBaseCamp

#
# Constants
#

const NAME = 'Starknet Basecamp'
const SYMBOL = 'SB'
const ADMIN = 100
const STUDENT = 101
const PROXY_ADMIN = 102
const BASECAMP_COHORT_ADDRESS = 103
const ANYONE = 104

#
# Tests
#

@view
func __setup__():
    %{
        context.basecamp_erc721_address = deploy_contract(
            "./src/tokens/basecamp/starknetbasecamp.cairo",
            [
                ids.NAME,
                ids.SYMBOL,
                ids.ADMIN,
                ids.PROXY_ADMIN,
                ids.BASECAMP_COHORT_ADDRESS,
                3,
                # token_uri: ['https://ipfs.io/ipfs/','foo','bar/']
                152661009894058335206669104024417562691910569980719, 6713199, 1650553391,
            ]
        ).contract_address

    %}
    return ()
end

@view
func test_mint_token_cohort_contract{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}():
    alloc_locals

    tempvar contract_address
    %{ 
        ids.contract_address = context.basecamp_erc721_address
    %}

    # Mint a token and check the tokenURI
    %{ stop_prank_admin = start_prank(ids.BASECAMP_COHORT_ADDRESS, ids.contract_address) %}

    let token_1 : Uint256 = Uint256(1, 0)
    IStarknetBaseCamp.mint(
        contract_address=contract_address,
        to=STUDENT,
        token_id=token_1
    )
    let (tokenURI_len, tokenURI) = IStarknetBaseCamp.tokenURI(contract_address, token_1)
    let (balance) = IStarknetBaseCamp.balanceOf(contract_address, STUDENT)
    let (is_equal) = uint256_eq(balance, Uint256(1, 0))
    assert is_equal = TRUE

    %{ stop_prank_admin %}

    assert tokenURI_len = 4

    assert [tokenURI] = 'https://ipfs.io/ipfs/'
    assert [tokenURI + 1] = 'foo'
    assert [tokenURI + 2] = 'bar/'
    assert [tokenURI + 3] = '1'
    return ()
end

@view
func test_mint_token_not_cohort_contract{
    syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr
}():
    tempvar contract_address
    %{ 
        ids.contract_address = context.basecamp_erc721_address
    %}

    %{ expect_revert("TRANSACTION_FAILED", "StarknetBaseCamp: Only the BaseCamp Cohort contract can call this function") %}
    %{ stop_prank_admin = start_prank(ids.ANYONE, ids.contract_address) %}
    let token_1 : Uint256 = Uint256(1, 0)
    IStarknetBaseCamp.mint(
        contract_address=contract_address,
        to=STUDENT,
        token_id=token_1
    )
    %{ stop_prank_admin %}

    return ()
end
