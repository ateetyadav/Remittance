pragma solidity ^0.4.4;

library ConvertLib{
	function convert(uint ethtoken,uint conversionRate) returns (uint equalGBP)
	{
		return ethtoken * conversionRate;
	}
}
