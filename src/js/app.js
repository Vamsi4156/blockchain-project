App={
  web3provider:null,
  contracts:{},
  account:'0x0',
  init:function()
  {
    console.log("init");
    return App.initweb3();
  },
  initweb3: function()
  {
    if(typeof web3!=='undefined')
    {
      console.log("initweb3:Metamask");

      App.web3provider=web3.currentProvider;
      web3=new Web3(App.web3provider);
    }
    else
    {
      console.log("initweb3:Ganache");

      App.web3provider=new Web3.providers.HttpProvider('http://localhost:7545');
      web3=new Web3(App.web3provider);
    }
    return App.initContract();
  },
  initContract: function()
  {
    $.getJSON("Insurance.json",function(insurance)
    {
      App.contracts.Insurance=TruffleContract(insurance);
      App.contracts.Insurance.setProvider(App.web3provider);
      console.log("initContract");
      return App.render();
    });
  },
}