# SPDX-License-Identifier: MIT

%lang starknet

from starkware.cairo.common.alloc import alloc
from starkware.cairo.common.cairo_builtins import HashBuiltin, SignatureBuiltin
from starkware.cairo.common.uint256 import Uint256

from openzeppelin.token.erc721.library import _exists

from openzeppelin.introspection.ERC165 import ERC165

from src.utils.ShortString import uint256_to_ss
from src.utils.Array import concat_arr

#
# Storage
#

@storage_var
func ERC721_token_uri(index: felt) -> (res: felt):
end

@storage_var
func ERC721_token_uri_len() -> (res: felt):
end

namespace StarknetBaseCampMetadata:
    #
    # Constructor
    #

    func ERC721_Metadata_initializer{
            syscall_ptr : felt*,
            pedersen_ptr : HashBuiltin*,
            range_check_ptr
        }():
        # register IERC721_Metadata
        ERC165.register_interface(0x5b5e139f)
        return ()
    end

    func ERC721_Metadata_tokenURI{
            syscall_ptr: felt*,
            pedersen_ptr: HashBuiltin*,
            range_check_ptr
        }(token_id: Uint256) -> (token_uri_len: felt, token_uri: felt*):
        alloc_locals

        let (exists) = _exists(token_id)
        assert exists = 1

        let (local token_uri) = alloc()
        let (local token_uri_len) = ERC721_token_uri_len.read()

        _ERC721_Metadata_TokenURI(token_uri_len, token_uri)

        let (token_id_ss_len, token_id_ss) = uint256_to_ss(token_id)
        let (token_uri, token_uri_len) = concat_arr(
            token_uri_len,
            token_uri,
            token_id_ss_len,
            token_id_ss,
        )

        return (token_uri_len=token_uri_len, token_uri=token_uri)
    end

    func _ERC721_Metadata_TokenURI{
            syscall_ptr: felt*,
            pedersen_ptr: HashBuiltin*,
            range_check_ptr
        }(token_uri_len: felt, token_uri: felt*):
        if token_uri_len == 0:
            return ()
        end
        let (token_uri_) = ERC721_token_uri.read(token_uri_len)
        assert [token_uri] = token_uri_
        _ERC721_Metadata_TokenURI(token_uri_len=token_uri_len - 1, token_uri=token_uri + 1)
        return ()
    end

    func ERC721_Metadata_setTokenURI{
            syscall_ptr: felt*,
            pedersen_ptr: HashBuiltin*,
            range_check_ptr
        }(token_uri_len: felt, token_uri: felt*):
        _ERC721_Metadata_setTokenURI(token_uri_len, token_uri)
        ERC721_token_uri_len.write(token_uri_len)
        return ()
    end

    func _ERC721_Metadata_setTokenURI{
            syscall_ptr: felt*,
            pedersen_ptr: HashBuiltin*,
            range_check_ptr
        }(token_uri_len: felt, token_uri: felt*):
        if token_uri_len == 0:
            return ()
        end
        ERC721_token_uri.write(index=token_uri_len, value=[token_uri])
        _ERC721_Metadata_setTokenURI(token_uri_len=token_uri_len - 1, token_uri=token_uri + 1)
        return ()
    end
end