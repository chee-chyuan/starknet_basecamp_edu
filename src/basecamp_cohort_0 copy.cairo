%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.starknet.common.syscalls import get_caller_address
from starkware.cairo.common.uint256 import Uint256, uint256_eq
from src.IERC20 import IERC20

const BRIDGE_MESSAGING_ERC20 = 794476629470482898616577431597553571361942706809174013646454877410188598265
const CAIRO_101_ERC20 = 3279287344264625568783811699777407692264141572989100183321070717866681257859

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
    let (messaging_balance) = IERC20.balanceOf(contract_address=BRIDGE_MESSAGING_ERC20, account=address)
    let (required_point_messaging) = required_points.read(BRIDGE_MESSAGING_ERC20)
    let (is_equal_messaging) = uint256_eq(messaging_balance, required_point_messaging)

    let (cairo_101_balance) = IERC20.balanceOf(contract_address=CAIRO_101_ERC20, account=address)
    let (required_point_cairo_101) = required_points.read(CAIRO_101_ERC20)
    let (is_equal_cairo_101) = uint256_eq(cairo_101_balance, required_point_cairo_101)

    if is_equal_messaging + is_equal_cairo_101 != 2:
        return (res = 0)
    end

    return (res=1)
end