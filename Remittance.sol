pragma solidity ^0.4.11   
   
contract owned {
    address owner;
    function owned() { 
        owner = msg.sender; 
    }
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }
}
contract Remittance is owned {
    
    event LogSend(address sender, uint amount);
    event LogRec(address sender, uint amount);
    event LogWithdraw(address receiver, uint amount);
   
    mapping (address => uint) balances;
    address alice;
    address bob;
    address carol;
//Constructor function 
    function Remittance(){
       // var owner=msg.sender;not needed as we already used OWNED
        }
    
    function xfer(address add)  payable returns (bool success) {
       require (add !=0);
       var receiver=add;
       var xferAmt=msg.value;
       
            if(msg.value<=0)revert();
	  
	        if   (msg.value>0){
	            balances[msg.sender]-=msg.value;
	            LogSend(msg.sender,msg.value);
	            balances[receiver]=msg.value;
	            LogRec(receiver,msg.value);
	            return true;
	        }
	        else 
	        {
	            return false;
	        }
    }
    
	
	function withdrawfund(address rec, bytes32 Hpwd, bytes32 pwd1, bytes32 pwd2)  internal returns(bool success) {
	   
        var  unLock=sha3(pwd1,pwd2);
        if(Hpwd==unLock)
        {
            //pwd1=0;//password set to 0 to avoid re-entry??
            //pwd2=0;//password set to 0 to avoid re-entry??
            
            if(msg.value>0){
             rec.transfer(msg.value);
             LogWithdraw(rec,msg.value);
             return true;
            }
        }
    }

	function kill() {
        if (msg.sender == owner) {
            selfdestruct(owner);
        }
    }


//Call fallback function. Log the event,
	function() payable {
	    LogRec(msg.sender,msg.value);
	    //Payable will take ether in fallback function 
	    //Log will be used to check the ether sender
	    
	}
}
