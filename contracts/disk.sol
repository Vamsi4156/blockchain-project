pragma solidity ^0.4.0;

contract fsmp {
    
  struct SellOrder{
	uint id;          //Sell Order Id (auto increment)
	address	DSO;      //Data Storage Owner address of the contract
	uint volumeGB;    //Volume of disk space, which DSO is ready to sell.
	uint pricePerGB;  //	Min price in wei DSO ready to get for 1 second (will be 1 day in real case) per 1 GB storage
	string DSOConnectionInfo;  //Specific info to connect to DSO securely
  }

  struct BuyOrder{
    uint id; //	Buy Order Id (auto increment)
    address DO;	//Data Owner address of the contract
    uint volumeGB;	//Volume of disk space, which DO is ready to buy.
    uint pricePerGB;	//Max price in wei DO ready to pay for 1 second (will be 1 day in real case) per 1 GB storage
    uint weiInitialAmount; // Quantity of wei, that is put into SmartContract at
                           // the moment of Buy Order creation.
                           // So it represent real value, that Escrow logic currently manage
                           // (and real DO intention to pay for future Storage Contract)
    string DOConnectionInfo; //Specific info to conect to DO securely
  }

  struct StorageContract{
    uint id; //ContractID (auto increment)
    address DO; //Data owner address of the contract
    address DSO; //Data storage owner address
    string DOConnectionInfo; //Specific info to connect to DO securely
    string DSOConnectionInfo; //Specific info to conect to DSO securely
    uint volumeGB; //Volume of disk space, which can be provided by DSO.
    uint startDate; //Date and time, which, if exists, indicates that the contract has been started
    uint stopDate;	//Date and time, which, if exists, indicates that the contract has been stopped
    uint pricePerGB; //Price in wei to pay for 1 second (will be 1 day in real case) per 1 GB storage
    uint weiLeftToWithdraw;	//Quantity of wei, that can we withdrawed by DSO
    uint withdrawedAtDate; //Last date and time when wei was withdrawed by DSO
  }


  uint sellOrderId; // auto increment unique id
  uint buyOrderId; // auto increment unique id
  uint storageContractId; // auto increment unique id

  SellOrder[] sellOrderArr; // array of sell orders
  BuyOrder[]  buyOrderArr; // array of buy orders
  StorageContract[]  storageContractArr; // array of contracts


  //################## Shared function ################################################

  function deleteBuyOrderFromArray (uint buyOrderIndex) internal {
    //if index not last element in the array
    if(buyOrderIndex != buyOrderArr.length-1){
        buyOrderArr[buyOrderIndex] = buyOrderArr[buyOrderArr.length-1];
    }
    buyOrderArr.length--;
  }

  function deleteSellOrderFromArray (uint sellOrderIndex) internal {
    //if index not last element in the array
    if(sellOrderIndex != sellOrderArr.length-1){
        sellOrderArr[sellOrderIndex] = sellOrderArr[sellOrderArr.length-1];
    }
    sellOrderArr.length--;
  }

  function deleteStorageContractFromArray (uint storageContractIndex) internal {
    //if index not last element in the array
    if(storageContractIndex != storageContractArr.length-1){
        storageContractArr[storageContractIndex] = storageContractArr[storageContractArr.length-1];
    }
    storageContractArr.length--;
  }

  function weiAllowedToWithdraw(uint storageContractIndex) internal constant returns (uint weiAllowedToWithdraw) {
      var c = storageContractArr[storageContractIndex];
      if (c.startDate == 0) return 0;
      uint calcToDate = now;
      if (c.stopDate != 0) calcToDate = c.stopDate;

      weiAllowedToWithdraw = (calcToDate - c.withdrawedAtDate) * c.pricePerGB * c.volumeGB;
      if (weiAllowedToWithdraw >= c.weiLeftToWithdraw) weiAllowedToWithdraw = c.weiLeftToWithdraw;

      return weiAllowedToWithdraw;
  }

  // ################## Trading ###################################################
  // Buy Order

  function createBuyOrder(uint volumeGB, uint pricePerGB, string DOConnectionInfo) payable {
      buyOrderArr.push(BuyOrder(++buyOrderId, msg.sender, volumeGB, pricePerGB, msg.value, DOConnectionInfo));
  }

  function cancelBuyOrder(uint buyOrderIndex, uint buyOrderID){
      //check if user can cancel an order
      if(buyOrderArr[buyOrderIndex].DO == msg.sender && buyOrderArr[buyOrderIndex].id == buyOrderID){
            uint amount = buyOrderArr[buyOrderIndex].weiInitialAmount;

            deleteBuyOrderFromArray(buyOrderIndex);

            if (!msg.sender.send(amount)) throw;
      }else{
          throw;
      }
  }

  function getBuyOrder(uint buyOrderIndex)constant returns(uint id, address DO, uint volume, uint pricePerGB, uint weiInitialAmount, string DOConnectionInfo){
      return (buyOrderArr[buyOrderIndex].id,
              buyOrderArr[buyOrderIndex].DO,
              buyOrderArr[buyOrderIndex].volumeGB,
              buyOrderArr[buyOrderIndex].pricePerGB,
              buyOrderArr[buyOrderIndex].weiInitialAmount,
              buyOrderArr[buyOrderIndex].DOConnectionInfo);
  }

  function buyOrdersLength() constant returns(uint) {
      return buyOrderArr.length;
  }

  // Sell Order

  function createSellOrder(uint volumeGB, uint pricePerGB, string DSOConnectionInfo) {
     sellOrderArr.push(SellOrder(++sellOrderId, msg.sender, volumeGB, pricePerGB, DSOConnectionInfo));
  }

    function getSellOrder(uint sellOrderIndex)constant returns(uint id, address DSO, uint volume, uint pricePerGB, string DSOConnectionInfo) {
      return (sellOrderArr[sellOrderIndex].id,
              sellOrderArr[sellOrderIndex].DSO,
              sellOrderArr[sellOrderIndex].volumeGB,
              sellOrderArr[sellOrderIndex].pricePerGB,
              sellOrderArr[sellOrderIndex].DSOConnectionInfo);
  }

  function sellOrdersLength() constant returns(uint){
    return sellOrderArr.length;
  }

  function cancelSellOrder(uint sellOrderIndex, uint sellOrderID){
      //check if user can cancel an order
      if(sellOrderArr[sellOrderIndex].DSO == msg.sender && sellOrderArr[sellOrderIndex].id == sellOrderID){
            deleteSellOrderFromArray(sellOrderIndex);
          return;
      }else{
          throw;
      }
  }
}