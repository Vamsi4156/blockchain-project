(function() {
'use strict';

angular.module('core')
.service('AccountsService', AccountsService);

AccountsService.$inject = ['Web3Service', '$rootScope']
function AccountsService(Web3Service, $rootScope) {
  let AccountsService = this;

  let web3 = Web3Service.getWeb3();
  let currentAccount = web3.eth.defaultAccount = '0x29ee050b183f84cf1f5bd7ac25e8bfb263e871c0';

  AccountsService.getCurrentAccount = () => currentAccount;
  AccountsService.setCurrentAccount = (acc) => {
    $rootScope.$broadcast('currentInfo:change', {
      'currentAccount': acc
    });
    return currentAccount = acc;
  };
}

}());
