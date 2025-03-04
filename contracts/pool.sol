//SPDX-License-Indentifier: MTI
pragma solidity ^0.8.7;
import "./store.sol";
import "./console.sol";
contract storeFactory{
    address[] private storeList;
    //搜索引擎
    mapping(address=>mapping(address=>address))public storesSearch;

    event storeCreateEvent(address indexed token0,address indexed token1,address storeAddress,uint location);

    function createStore(address token0,address token1)external returns(address store){
      require(token0 !=  token1,"Equal token address error");
      require(token0!=address(0)&&token1!=address(0),"invaild zero address");
      require(storesSearch[token0][token1]==address(0),"store exists");
      bytes memory bytecode = type(Store).creationCode;
      bytes32 salt = keccak256(abi.encodePacked(token0,token1));
      assembly{
          store:=create2(0,add(bytecode,32),mload(bytecode),salt)
      }
      Store(store).initialize(token0,token1);
      storesSearch[token0][token1]=store;
      storesSearch[token1][token0]=store;
      storeList.push(store);
      emit storeCreateEvent(token0,token1,store,storeList.length);
    }
    function searchAMM(address token0,address token1)external view returns(address store){
         store =storesSearch[token0][token1];
        require(store!=address(0),"cant find the change store");
    }
}