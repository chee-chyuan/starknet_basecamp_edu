%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from tests.utils.IBaseCampCohort0 import IBaseCampCohort0
from starkware.cairo.common.uint256 import Uint256, uint256_eq

const DEPLOYER_ADDRESS = 12345678
const OTHER_ADDRESS = 989692341

const BRIDGE_MESSAGING_ERC20 = 794476629470482898616577431597553571361942706809174013646454877410188598265
const CAIRO_101_ERC20 = 3279287344264625568783811699777407692264141572989100183321070717866681257859

@view
func __setup__():
    %{ 
        context.basecamp_address = deploy_contract("./src/basecamp_cohort_0.cairo", [ids.DEPLOYER_ADDRESS]).contract_address 
    %}
    return ()
end

@view
func test_initial_state{syscall_ptr:felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}():
    tempvar contract_address
    %{ 
        ids.contract_address = context.basecamp_address 
    %}

    let (deployer_is_moderator) = IBaseCampCohort0.is_moderator(
        contract_address=contract_address, address=DEPLOYER_ADDRESS)
    assert deployer_is_moderator = 1

    let (registration_status) =  IBaseCampCohort0.is_allowed_to_register(
        contract_address=contract_address)
    assert registration_status = 0
    
    return ()
end

@view
func test_cannot_call_set_moderator_by_non_moderator{syscall_ptr:felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}():
    tempvar contract_address
    %{ 
        ids.contract_address = context.basecamp_address 
    %}

    %{ stop_prank_callable = start_prank(ids.OTHER_ADDRESS, target_contract_address=ids.contract_address) %}

    %{ expect_revert(error_message="User is not a moderator") %}
    IBaseCampCohort0.set_moderator(contract_address=contract_address,address=OTHER_ADDRESS,is_moderator=1)

    %{ stop_prank_callable() %}

    return ()
end

@view
func test_cannot_call_set_required_point_by_non_moderator{syscall_ptr:felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}():
    tempvar contract_address
    %{ 
        ids.contract_address = context.basecamp_address 
    %}

    %{ stop_prank_callable = start_prank(ids.OTHER_ADDRESS, target_contract_address=ids.contract_address) %}

    %{ expect_revert(error_message="User is not a moderator") %}
    IBaseCampCohort0.set_required_point(contract_address=contract_address,erc20_token_address=0,point=Uint256(1,0))
    %{ stop_prank_callable() %}

    return ()
end

@view
func test_cannot_call_set_allow_register_by_non_moderator{syscall_ptr:felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}():
    tempvar contract_address
    %{ 
        ids.contract_address = context.basecamp_address 
    %}

    %{ stop_prank_callable = start_prank(ids.OTHER_ADDRESS, target_contract_address=ids.contract_address) %}

    %{ expect_revert(error_message="User is not a moderator") %}
    IBaseCampCohort0.set_allow_register(contract_address=contract_address,can_register=1)
    %{ stop_prank_callable() %}

    return ()
end

@view
func test_able_to_call_moderator_function{syscall_ptr:felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}():
    alloc_locals
    local syscall_ptr_temp: felt*
    assert syscall_ptr_temp = syscall_ptr

     tempvar contract_address
    %{ 
        ids.contract_address = context.basecamp_address 
        stop_prank_callable = start_prank(ids.DEPLOYER_ADDRESS, target_contract_address=ids.contract_address) 
    %}

    IBaseCampCohort0.set_moderator(contract_address=contract_address,address=OTHER_ADDRESS,is_moderator=1)
    let (is_moderator) = IBaseCampCohort0.is_moderator(contract_address=contract_address, address=OTHER_ADDRESS)
    assert is_moderator = 1

    tempvar contract_address
    %{ 
        ids.contract_address = context.basecamp_address 
    %}

    let (previous_point) = IBaseCampCohort0.get_required_points(
            contract_address=contract_address, erc20_contract_address=BRIDGE_MESSAGING_ERC20
        )
    let (is_equal_before) = uint256_eq(previous_point, Uint256(0,0))
    assert is_equal_before = 1

    tempvar contract_address
    %{ 
        ids.contract_address = context.basecamp_address 
    %}

    IBaseCampCohort0.set_required_point(contract_address=contract_address,erc20_token_address=BRIDGE_MESSAGING_ERC20,point=Uint256(1,0))
    
    let (after_point) = IBaseCampCohort0.get_required_points(
            contract_address=contract_address, erc20_contract_address=BRIDGE_MESSAGING_ERC20
        )
    let (is_equal_after) = uint256_eq(after_point, Uint256(1,0))
    assert is_equal_after = 1
    
    tempvar contract_address
    %{ 
        ids.contract_address = context.basecamp_address 
    %}
    IBaseCampCohort0.set_allow_register(contract_address=contract_address,can_register=1)
    let (status) = IBaseCampCohort0.is_allowed_to_register(contract_address=contract_address)
    assert status = 1
    %{ stop_prank_callable() %}

    return ()
end