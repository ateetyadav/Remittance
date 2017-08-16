pragma solidity ^0.4.11;
contract Remittance{
    address owner;
    uint deadLine;        
    uint finaldeadLine;
    
    mapping (bytes32 => remittance) remittances;
    
    event LogreClaim(address receiver, uint amount);
    event LogSender(address sender, uint amount);
    event LogWithdraw(address receiver, uint amount);
    event LogClosed(bool closeflag);
    
    function Remittance(uint endTime) {
		owner=msg.sender;
		deadLine=endTime;
    }
	struct remittance{
	    bytes32 pwd;
	    uint startBalance;    //actual deposited  amount.
	    uint outstandBalance; //current balance, after withdrawal.
	    bool active;          //after final dedline and reclaim, contract will become  inactive.
    }
     function sendEther(bytes32 passCode, uint timeLine, uint closeTime) payable  {
	    
	    if(msg.sender!=owner) revert();
	    if(msg.value <= 0) revert();
	    require(passCode!=0);
	    require(timeLine!=0);
	    remittances[sha3(msg.sender)].pwd=sha3(passCode);
            remittances[sha3(msg.sender)].startBalance=msg.value;
            remittances[sha3(msg.sender)].outstandBalance=msg.value;
            remittances[sha3(msg.sender)].active=true;
            deadLine=now+timeLine;
            finaldeadLine=deadLine+closeTime;
            LogSender(msg.sender,msg.value);
    }
	 
    function withdrawal(uint pwd1,uint pwd2) payable returns (bool success){
	    require (remittances[sha3(msg.sender)].active!=false);//active contract.
	    require(pwd1!=0);
	    require(pwd2!=0);
	    require(msg.value>0);
	    bytes32 storePwd=remittances[sha3(pwd1,pwd2)].pwd;
	    if(storePwd!=sha3(pwd1,pwd2)) revert();
	    
	    if(deadLine >=now && remittances[sha3(pwd1,pwd2)].outstandBalance >= msg.value){
	        remittances[sha3(pwd1,pwd2)].outstandBalance -= msg.value;
	        msg.sender.transfer(msg.value);
	        LogWithdraw(msg.sender,msg.value);
	    }else{
	        throw ;
	    }
    }
	 
    function reClaim() returns(uint remainEther){
	    if (remittances[sha3(msg.sender)].active=false) revert();
	    if(msg.sender != owner) revert();  
	    if(now <deadLine ) revert();       //reclain allowed only after deadline.
	    if(now >finaldeadLine) revert();   //after close times no reclaim allowed.
	    if(remittances[sha3(msg.sender)].outstandBalance<=0) revert();
	    
	       uint reclaimfund=remittances[sha3(msg.sender)].outstandBalance;
	       remittances[sha3(msg.sender)].outstandBalance=0;
	       msg.sender.transfer(reclaimfund);
	       LogreClaim(msg.sender, reclaimfund);
	       reclaimfund=0;
	            
	    if (now>=finaldeadLine){
	        remittances[sha3(msg.sender)].active=false;
	        LogClosed(remittances[sha3(msg.sender)].active);
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
