<template>
  <div class="casino container">
    <h1>Welcome to the Casino</h1>
    <h4>您拥有的卡的数量：{{ balanceCard }}</h4>
    Amount to bet: <input v-model="amount" placeholder="0 Ether">
    <ul>
      <li v-on:click="mintBlue">购买蓝色卡</li>
      <li v-on:click="mintRed">购买红色卡</li>
      <li v-on:click="test">购买绿色卡</li>

    </ul>
    <img v-if="pending" id="loader" src="https://loading.io/spinners/double-ring/lg.double-ring-spinner.gif">
    <div class="event" v-if="winEvent">
      <p v-if="winEvent._status" id="has-won"><i aria-hidden="true" class="fa fa-check"></i> Congragulations, you have won {{winEvent._amount}} wei</p>
      <p v-else id="has-lost"><i aria-hidden="true" class="fa fa-times"></i> Sorry you lost, try again.</p>
    </div>
  </div>
</template>

<script>
import {store} from '../store/'
export default {
  name: 'casino',
  data () {
    return {
      amount: null,
      pending: false,
      winEvent: null,
      balanceCard: 0
    }
  },
  methods: {
    mintBlue (event) {
      console.log('mintBlue', event.target.innerHTML)
      this.winEvent = null
      this.pending = true
      this.$store.state.contractInstance().mintBlue({
        gas: 300000,
        value: this.$store.state.web3.web3Instance().toWei(0.1, 'ether'),
        from: this.$store.state.web3.coinbase
      }, (err, result) => {
        if (err) {
          console.log(err)
          this.pending = false
        } else {
          let balanceOf = this.$store.state.contractInstance().balanceOf(store.state.web3.coinbase, {
            gas: 300000,
            value: this.$store.state.web3.web3Instance().toWei(this.amount, 'ether'),
            from: this.$store.state.web3.coinbase
          })
          balanceOf.watch((err, result) => {
            if (err) {
              console.log('could not get event balanceCard()')
            } else {
              this.balanceCard = result.args
              // this.winEvent._amount = parseInt(result.args._amount, 10)
              this.pending = false
            }
          })
        }
      })
    },
    mintRed (event) {
      console.log('mintRed', event.target.innerHTML)
      this.winEvent = null
      this.pending = true
      this.$store.state.contractInstance().mintRed({
        gas: 300000,
        value: this.$store.state.web3.web3Instance().toWei(0.1, 'ether'),
        from: this.$store.state.web3.coinbase
      }, (err, result) => {
        if (err) {
          console.log(err)
          this.pending = false
        }
      })
    },
    test (event) {
      console.log('test', event.target.innerHTML)
      this.winEvent = null
      this.pending = true
      this.balanceCard = 1111
      let balanceOf = this.$store.state.contractInstance().getContractBalanceOf()

      balanceOf.watch((err, result) => {
        if (err) {
          console.log('could not get event balanceCard()')
        } else {
          this.balanceCard = result.args
          // this.winEvent._amount = parseInt(result.args._amount, 10)
          this.pending = false
        }
      })
    },
    mintGrenn (event) {
      console.log('mintGrenn', event.target.innerHTML)
      this.winEvent = null
      this.pending = true
      this.$store.state.contractInstance().mintGrenn({
        gas: 300000,
        value: this.$store.state.web3.web3Instance().toWei(0.1, 'ether'),
        from: this.$store.state.web3.coinbase
      }, (err, result) => {
        if (err) {
          console.log(err)
          this.pending = false
        }
      })
    },
    clickNumber (event) {
      console.log('BETTING ON NUMBER, AMOUNT', event.target.innerHTML, this.amount)
      this.winEvent = null
      this.pending = true
      this.$store.state.contractInstance().bet(event.target.innerHTML, {
        gas: 300000,
        value: this.$store.state.web3.web3Instance().toWei(this.amount, 'ether'),
        from: this.$store.state.web3.coinbase
      }, (err, result) => {
        if (err) {
          console.log(err)
          this.pending = false
        } else {
          let Won = this.$store.state.contractInstance().Won()
          Won.watch((err, result) => {
            if (err) {
              console.log('could not get event Won()')
            } else {
              this.winEvent = result.args
              this.winEvent._amount = parseInt(result.args._amount, 10)
              this.pending = false
            }
          })
        }
      })
    }
  },
  mounted () {
    console.log('dispatching getContractInstance')
    this.$store.dispatch('getContractInstance')
  }
}
</script>

<style scoped>
.casino {
     margin-top: 50px;
     text-align:center;
}
#loader {
  width:150px;
}
ul {
    margin: 25px;
    list-style-type: none;
    display: grid;
    grid-template-columns: repeat(5, 1fr);
    grid-column-gap:25px;
    grid-row-gap:25px;
}
li{
    padding: 10px;
    margin-right: 5px;
    border-radius: 50%;
    cursor: pointer;
    background-color:#fff;
    border: -2px solid #bf0d9b;
    color: #bf0d9b;
    box-shadow:3px 5px #bf0d9b;
}
li:hover{
    background-color:#bf0d9b;
    color:white;
    box-shadow:0px 0px #bf0d9b;
}
li:active{
    opacity: 0.7;
}
*{
   color: #444444;
}
#has-won {
  color: green;
}
#has-lost {
  color:red;
}
</style>
