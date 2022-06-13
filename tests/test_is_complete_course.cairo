%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.uint256 import Uint256, uint256_eq
from tests.utils.IBaseCampCohort0 import IBaseCampCohort0

const DEPLOYER_ADDRESS = 12345678
const STUDENT_ADDRESS = 3434321423

# const BRIDGE_MESSAGING_ERC20 = 794476629470482898616577431597553571361942706809174013646454877410188598265
# const CAIRO_101_ERC20 = 3279287344264625568783811699777407692264141572989100183321070717866681257859

@view
func __setup__{syscall_ptr:felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}():

    tempvar contract_address
    tempvar cairo_101_address
    tempvar bridge_messaging_address
    %{ 
        context.cairo_101_address = deploy_contract("./tests/utils/MockErc20.cairo").contract_address
        ids.cairo_101_address = context.cairo_101_address
        context.bridge_messaging_address = deploy_contract("./tests/utils/MockErc20.cairo").contract_address
        ids.bridge_messaging_address = context.bridge_messaging_address

        context.basecamp_address = deploy_contract("./src/basecamp_cohort_0.cairo", [ids.DEPLOYER_ADDRESS]).contract_address 
        ids.contract_address = context.basecamp_address 
        stop_prank_callable = start_prank(ids.DEPLOYER_ADDRESS, target_contract_address=ids.contract_address)
    %}

    # setup our contract state
    IBaseCampCohort0.set_erc20_addresses(
        contract_address=contract_address,bridge_addr=bridge_messaging_address, cairo_101_addr=cairo_101_address
        )
    IBaseCampCohort0.set_allow_register(contract_address=contract_address,can_register=1)
    IBaseCampCohort0.set_required_point(
        contract_address=contract_address,erc20_token_address=bridge_messaging_address,point=Uint256(1,0)
        )
    IBaseCampCohort0.set_required_point(
        contract_address=contract_address,erc20_token_address=cairo_101_address,point=Uint256(1,0)
        )
    
    %{ stop_prank_callable() %}
    return ()
end

# test not complete when not registered
@view
func test_when_not_registered{syscall_ptr:felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}():
    tempvar contract_address
    tempvar cairo_101_address
    tempvar bridge_messaging_address
    %{ 
        ids.contract_address = context.basecamp_address 
        ids.cairo_101_address = context.cairo_101_address
        ids.bridge_messaging_address = context.bridge_messaging_address
    %}
    
    let (is_registered) = IBaseCampCohort0.has_registered(contract_address=contract_address, address=STUDENT_ADDRESS)
    assert is_registered = 0

    %{
        mock_call(ids.bridge_messaging_address, "balanceOf", [1,0]) 
        mock_call(ids.cairo_101_address, "balanceOf", [1,0]) 
    %}

    let (is_completed) = IBaseCampCohort0.is_complete_course(contract_address=contract_address, address=STUDENT_ADDRESS)
    assert is_completed = 0

    %{
        clear_mock_call(ids.bridge_messaging_address, "balanceOf")
        clear_mock_call(ids.cairo_101_address, "balanceOf")
    %}
    return()
end

# test not complete when each one of the balance is not the max
@view
func test_when_cairo_101_point_not_enough{syscall_ptr:felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}():
    tempvar contract_address
    tempvar bridge_messaging_address
    %{ 
        ids.contract_address = context.basecamp_address
        ids.bridge_messaging_address = context.bridge_messaging_address
        stop_prank_callable = start_prank(ids.STUDENT_ADDRESS, target_contract_address=ids.contract_address)
    %}

    IBaseCampCohort0.student_register(contract_address=contract_address)

    %{ stop_prank_callable() %}

    let (is_registered) = IBaseCampCohort0.has_registered(contract_address=contract_address, address=STUDENT_ADDRESS)
    assert is_registered = 1

    %{
        mock_call(ids.bridge_messaging_address, "balanceOf", [1,0])
    %}

    let (is_completed) = IBaseCampCohort0.is_complete_course(contract_address=contract_address, address=STUDENT_ADDRESS)
    assert is_completed = 0

    %{
        clear_mock_call(ids.bridge_messaging_address, "balanceOf")
    %}
    return()
end

@view
func test_when_messaging_bridge_point_not_enough{syscall_ptr:felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}():
    tempvar contract_address
    tempvar cairo_101_address
    %{ 
        ids.contract_address = context.basecamp_address 
        ids.cairo_101_address = context.cairo_101_address
        stop_prank_callable = start_prank(ids.STUDENT_ADDRESS, target_contract_address=ids.contract_address)
    %}

    IBaseCampCohort0.student_register(contract_address=contract_address)

    %{ stop_prank_callable() %}

    let (is_registered) = IBaseCampCohort0.has_registered(contract_address=contract_address, address=STUDENT_ADDRESS)
    assert is_registered = 1

    %{
        mock_call(ids.cairo_101_address, "balanceOf", [1,0]) 
    %}

    let (is_completed) = IBaseCampCohort0.is_complete_course(contract_address=contract_address, address=STUDENT_ADDRESS)
    assert is_completed = 0

    %{
        clear_mock_call(ids.cairo_101_address, "balanceOf")
    %}
    return()
end

# test completed everything
@view
func test_all_conditions_satisfied{syscall_ptr:felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}():
    tempvar contract_address
    tempvar cairo_101_address
    tempvar bridge_messaging_address
    %{ 
        ids.contract_address = context.basecamp_address 
        ids.bridge_messaging_address = context.bridge_messaging_address
        ids.cairo_101_address = context.cairo_101_address
        stop_prank_callable = start_prank(ids.STUDENT_ADDRESS, target_contract_address=ids.contract_address)
    %}

    IBaseCampCohort0.student_register(contract_address=contract_address)

    %{ stop_prank_callable() %}

    let (is_registered) = IBaseCampCohort0.has_registered(contract_address=contract_address, address=STUDENT_ADDRESS)
    assert is_registered = 1

    %{
        mock_call(ids.bridge_messaging_address, "balanceOf", [1,0]) 
        mock_call(ids.cairo_101_address, "balanceOf", [1,0]) 
    %}

    let (is_completed) = IBaseCampCohort0.is_complete_course(contract_address=contract_address, address=STUDENT_ADDRESS)
    assert is_completed = 1
    %{
        clear_mock_call(ids.bridge_messaging_address, "balanceOf")
        clear_mock_call(ids.cairo_101_address, "balanceOf")
    %}
    return()
end