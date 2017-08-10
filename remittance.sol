pragma solidity ^0.4.11;
//Alice want to send some ether to BOB. 
//however Bob does't have wallet and can receive 
//only GBP equal amount.
//agent add //"0x04" 
import "./ConvertLib.sol";
contract Remittance{
	
	address owner;
	address xferAgent;
	bytes32 withdrawCode;
	mapping (address => uint) balances;
	mapping (address => uint) GBPbalances;
	
	event Transfer(address sender,address receiver,uint256 _value);
	event GBPTransfer(address sender,uint256 _value);
	event withdraw(address receiver,uint256 value);

	function Remittance() {
		owner=msg.sender;
	}
        function sendEther(address agent,address receiver,bytes32 passcode) payable returns(bool sufficient) {
	    require(passcode!=0);
	    require(agent!=0);
	    require(receiver!=0);
	    require(msg.value>0);
	    if(balances[msg.sender] < msg.value) revert();
		
		withdrawCode=sha3(passcode);	
		balances[msg.sender] -= msg.value;
		balances[agent] += msg.value;
		Transfer(msg.sender, agent, msg.value);
                uint eth_GBP;
		eth_GBP=ConvertLib.convert(msg.value,2);// assume 1Eth=2GBP
		GBPbalances[receiver] += eth_GBP;       
		GBPTransfer(receiver,GBPbalances[receiver]);
		
		return true;
	}
        function withdrawal(uint pwd1,uint pwd2,uint amt) payable returns (bool success){
	    require(pwd1!=0);
	    require(pwd2!=0);
	    require(amt>0);
	    if(GBPbalances[msg.sender] < amt) revert();
	    if(sha3(pwd1,pwd2) != withdrawCode) revert();//sha3(12,34)!=sha3(1234)
            if(sha3(pwd2,pwd1) == withdrawCode) revert();
            //uint amt=GBPbalances[msg.sender];
            GBPbalances[msg.sender]-=amt; // Do not allow multiple withdrawal for same requenst.
            if (amt <= GBPbalances[msg.sender]){
			msg.sender.transfer(amt);
			
			return true;
			withdraw(msg.sender,amt);
	    }
	}
	function kill() {
        	if (msg.sender == owner) {
            	selfdestruct(owner);
		}
        }
	function() {
	    //log the details using event
  	}
}

