import Web3 from 'web3'
import {address, ABI} from './constants/luckydogContract'

let getContract = new Promise(function (resolve, reject) {
  let web3 = new Web3(new Web3.providers.HttpProvider('http://localhost:7545'))
  let luckydogContract = web3.eth.contract(ABI)
  let luckydogContractInstance = luckydogContract.at(address)
  console.log(luckydogContract)
  console.log(luckydogContractInstance)
  resolve(luckydogContractInstance)
})

export default getContract
