%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.starknet.common.syscalls import get_caller_address
from starkware.cairo.common.uint256 import Uint256, uint256_eq, uint256_add
from starkware.cairo.common.bool import TRUE, FALSE
from src.interfaces.Istarknetbasecamp import IStarknetBaseCamp
from src.IERC20 import IERC20

# const BRIDGE_MESSAGING_ERC20 = 794476629470482898616577431597553571361942706809174013646454877410188598265
# const CAIRO_101_ERC20 = 3279287344264625568783811699777407692264141572989100183321070717866681257859

@storage_var
func bridge_messaging_address() -> (address:felt):
end

@storage_var
func cairo_101_address() -> (address:felt):
end

@storage_var
func registered_users(address:felt) -> (is_registered:felt):
end

@storage_var
func registration_status() -> (can_register:felt):
end

@storage_var
func moderators(address:felt) -> (is_moderator:felt):
end

@storage_var
func required_points(erc_address:felt) -> (res:Uint256):
end

@storage_var
func starknet_basecamp_address_() -> (address:felt):
end

@storage_var
func claimed_token_(address: felt) -> (res:felt):
end

@constructor
func constructor{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    moderator:felt
):
    moderators.write(moderator, 1)
    return ()
end

func only_moderator{syscall_ptr:felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}():
    let (caller) = get_caller_address()
    let (is_moderator) = moderators.read(caller)

    with_attr error_message("User is not a moderator"):
        assert is_moderator = 1
    end
    return ()
end

func can_register{syscall_ptr:felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}():
    let (can_register) = registration_status.read()

    with_attr error_message("Registration is now closed"):
        assert can_register = 1
    end
    return ()
end

@external
func set_erc20_addresses{syscall_ptr:felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    bridge_addr:felt, cairo_101_addr: felt
):
    only_moderator()
    bridge_messaging_address.write(bridge_addr)
    cairo_101_address.write(cairo_101_addr)
    return ()
end

@external
func set_moderator{syscall_ptr:felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    address:felt, is_moderator:felt    
):
    only_moderator()
    moderators.write(address, is_moderator)
    return ()
end

@external
func set_required_point{syscall_ptr:felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    erc20_token_address:felt, point: Uint256
):
    only_moderator()
    required_points.write(erc20_token_address, point)
    return ()
end

@external 
func set_allow_register{syscall_ptr:felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    can_register:felt    
):
    only_moderator()
    registration_status.write(can_register)
    return ()
end

@external
func student_register{syscall_ptr:felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
):
    can_register()
    let (student_address) = get_caller_address()
    registered_users.write(student_address, 1)
    return ()
end

@external
func set_starknet_basecamp_address{syscall_ptr:felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(address: felt):
    only_moderator()
    starknet_basecamp_address_.write(address)
    return ()
end

@external
func mint_basecamp_token{syscall_ptr:felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
):
    alloc_locals

    let (student_address) = get_caller_address()

    # Make sure the student finished the course
    let (completed) = is_complete_course(student_address)
    with_attr error_message("Cohort: Student has not completed the course"):
        assert completed = TRUE
    end

    # Make sure the student doesn't have a token yet
    let (token_address) = starknet_basecamp_address_.read()
    let (balance) = IStarknetBaseCamp.balanceOf(token_address, student_address)
    let (is_equal) = uint256_eq(balance, Uint256(0,0))
    with_attr error_message("Cohort: Student already has a token"):
        assert is_equal = TRUE
    end

    # Make sure the student haven't claimed yet
    let (token_claimed) = claimed_token_.read(student_address)
    with_attr error_message("Cohort: Student already claimed"):
        assert token_claimed = FALSE
    end

    # Mint the token to the student
    let (total_supply) = IStarknetBaseCamp.totalSupply(token_address)
    let next_token_id : Uint256 = uint256_add(total_supply, Uint256(1,0))
    IStarknetBaseCamp.mint(
        contract_address=token_address,
        to=student_address,
        token_id=next_token_id,
    )

    # Write claim status to the storage
    claimed_token_.write(student_address, TRUE)
    return ()
end

@view
func starknet_basecamp_address{syscall_ptr:felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (res:felt):
    let (starknet_basecamp_address) = starknet_basecamp_address_.read()
    return (res=starknet_basecamp_address)
end

@view
func claimed_token{syscall_ptr:felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(address: felt) -> (bool:felt):
    let (bool) = claimed_token_.read(address)
    return (bool)
end

@view
func get_bridge_addr{syscall_ptr:felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (res:felt):
    let (addr) = bridge_messaging_address.read()
    return (res=addr)
end

@view
func get_cairo_101_addr{syscall_ptr:felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (res:felt):
    let (addr) = cairo_101_address.read()
    return (res=addr)
end

@view
func is_moderator{syscall_ptr:felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    address:felt
) -> (res:felt):
    let (is_moderator) = moderators.read(address)
    return (res=is_moderator)
end

@view
func has_registered{syscall_ptr:felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    address:felt
) -> (res:felt):
    let (res) = registered_users.read(address)
    return (res=res)
end

@view
func is_allowed_to_register{syscall_ptr:felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
) -> (res: felt):
    let (can_register) = registration_status.read()
    return (res=can_register)
end

@view
func get_required_points{syscall_ptr:felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    erc20_contract_address: felt
) -> (res: Uint256):
    let (point) = required_points.read(erc20_contract_address)
    return (res=point)
end

@view
func is_complete_course{syscall_ptr:felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    address:felt
) -> (res:felt):
    alloc_locals
    local syscall_ptr_temp: felt*
    assert syscall_ptr_temp = syscall_ptr
    let (is_registered) = registered_users.read(address)

    if is_registered == 0:
        return (res = 0)
    end

    # check course completion
    # call balance_of in the two erc20
    let (bridge_addr) = bridge_messaging_address.read()
    let (messaging_balance) = IERC20.balanceOf(contract_address=bridge_addr, account=address)
    let (required_point_messaging) = required_points.read(bridge_addr)
    let (is_equal_messaging) = uint256_eq(messaging_balance, required_point_messaging)

    let (cairo_101_addr) = cairo_101_address.read()
    let (cairo_101_balance) = IERC20.balanceOf(contract_address=cairo_101_addr, account=address)
    let (required_point_cairo_101) = required_points.read(cairo_101_addr)
    let (is_equal_cairo_101) = uint256_eq(cairo_101_balance, required_point_cairo_101)

    if is_equal_messaging + is_equal_cairo_101 != 2:
        return (res = 0)
    end

    return (res=1)
end