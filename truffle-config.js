module.exports = {

  compilers: {
    solc: {
      version: '0.4.0', // A version or constraint - Ex. "^0.5.0"
                         // Can also be set to "native" to use a native solc
      
  networks:{
    development: {
      host: "127.0.0.1",
      port: 7545,
      network_id: "*" // Match any network id
},
    develop: {
      port: 8545
    }
  }
}
  }
};
