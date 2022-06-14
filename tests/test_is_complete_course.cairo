%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.uint256 import Uint256, uint256_eq
from starkware.cairo.common.bool import TRUE, FALSE
from tests.utils.IBaseCampCohort0 import IBaseCampCohort0
from src.interfaces.Istarknetbasecamp import IStarknetBaseCamp

const DEPLOYER_ADDRESS = 12345678
const STUDENT_ADDRESS = 3434321423
const NAME = 'Starknet Basecamp'
const SYMBOL = 'SB'
const PROXY_ADMIN = 102

# const BRIDGE_MESSAGING_ERC20 = 794476629470482898616577431597553571361942706809174013646454877410188598265
# const CAIRO_101_ERC20 = 3279287344264625568783811699777407692264141572989100183321070717866681257859

@view
func __setup__{syscall_ptr:felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}():

    tempvar contract_address
    tempvar cairo_101_address
    tempvar bridge_messaging_address
    tempvar basecamp_erc721_address
    %{ 
        context.cairo_101_address = deploy_contract("./tests/utils/MockErc20.cairo").contract_address
        ids.cairo_101_address = context.cairo_101_address
        context.bridge_messaging_address = deploy_contract("./tests/utils/MockErc20.cairo").contract_address
        ids.bridge_messaging_address = context.bridge_messaging_address

        context.basecamp_address = deploy_contract("./src/basecamp_cohort_0.cairo", [ids.DEPLOYER_ADDRESS]).contract_address 
        ids.contract_address = context.basecamp_address
        context.basecamp_erc721_address = deploy_contract(
                    "./src/tokens/basecamp/starknetbasecamp.cairo",
                    [
                        ids.NAME,
                        ids.SYMBOL,
                        ids.DEPLOYER_ADDRESS,
                        ids.PROXY_ADMIN,
                        ids.DEPLOYER_ADDRESS,
                        3,
                        # token_uri: ['https://ipfs.io/ipfs/','foo','bar/']
                        152661009894058335206669104024417562691910569980719, 6713199, 1650553391,
                    ]
                ).contract_address
        ids.basecamp_erc721_address = context.basecamp_erc721_address
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
    IBaseCampCohort0.set_starknet_basecamp_address(
        contract_address=contract_address,
        address=basecamp_erc721_address
        )
    %{ stop_prank_callable() %}

    # Set the basecamp cohort contract address in the ERC721 contract
    %{
        start_prank_deployer = start_prank(ids.DEPLOYER_ADDRESS, target_contract_address=ids.basecamp_erc721_address)
    %}
    IStarknetBaseCamp.setBaseCampCohortAddress(
        contract_address=basecamp_erc721_address,
        address=contract_address
    )
    %{ start_prank_deployer() %}
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

@view
func test_mint_when_not_completed{syscall_ptr:felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}():
    tempvar contract_address
    tempvar cairo_101_address
    tempvar basecamp_erc721_address

    %{ 
        ids.contract_address = context.basecamp_address 
        ids.cairo_101_address = context.cairo_101_address
        ids.basecamp_erc721_address = context.basecamp_erc721_address
        stop_prank_callable = start_prank(ids.STUDENT_ADDRESS, target_contract_address=ids.contract_address)
    %}

    IBaseCampCohort0.student_register(contract_address=contract_address)

    let (is_registered) = IBaseCampCohort0.has_registered(contract_address=contract_address, address=STUDENT_ADDRESS)
    assert is_registered = 1

    %{
        mock_call(ids.cairo_101_address, "balanceOf", [1,0]) 
    %}

    let (is_completed) = IBaseCampCohort0.is_complete_course(contract_address=contract_address, address=STUDENT_ADDRESS)
    assert is_completed = 0

    %{ expect_revert("TRANSACTION_FAILED","Cohort: Student has not completed the course") %}
    IBaseCampCohort0.mint_basecamp_token(contract_address)

    %{ stop_prank_callable() %}
    %{
        clear_mock_call(ids.cairo_101_address, "balanceOf")
    %}
    return()
end

# test completed everything
@view
func test_all_conditions_satisfied{syscall_ptr:felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}():
    alloc_locals

    tempvar contract_address
    tempvar cairo_101_address
    tempvar bridge_messaging_address
    tempvar basecamp_erc721_address
    %{ 
        ids.contract_address = context.basecamp_address 
        ids.bridge_messaging_address = context.bridge_messaging_address
        ids.cairo_101_address = context.cairo_101_address
        ids.basecamp_erc721_address = context.basecamp_erc721_address
        stop_prank_callable = start_prank(ids.STUDENT_ADDRESS, target_contract_address=ids.contract_address)
    %}

    IBaseCampCohort0.student_register(contract_address=contract_address)

    let (is_registered) = IBaseCampCohort0.has_registered(contract_address=contract_address, address=STUDENT_ADDRESS)
    assert is_registered = 1

    %{
        mock_call(ids.bridge_messaging_address, "balanceOf", [1,0]) 
        mock_call(ids.cairo_101_address, "balanceOf", [1,0]) 
    %}

    let (is_completed) = IBaseCampCohort0.is_complete_course(contract_address=contract_address, address=STUDENT_ADDRESS)
    assert is_completed = 1

    # Mint graduation token
    IBaseCampCohort0.mint_basecamp_token(contract_address)
    let (token_claimed) = IBaseCampCohort0.claimed_token(contract_address=contract_address, address=STUDENT_ADDRESS)
    assert token_claimed = TRUE

    %{
        clear_mock_call(ids.bridge_messaging_address, "balanceOf")
        clear_mock_call(ids.cairo_101_address, "balanceOf")
    %}

    %{ stop_prank_callable() %}

    # Check balance and claimed_token status
    let (balance) = IStarknetBaseCamp.balanceOf(basecamp_erc721_address, STUDENT_ADDRESS)
    let (is_equal) = uint256_eq(balance, Uint256(1,0))
    assert is_equal = TRUE

    return()
end