<template>
  <div class="casino container">
    <h1>欢迎来到幸运儿~</h1>
    <h2>奖池总金额：{{ contractBalanceOf }}</h2>
    目前获胜方：{{ winner }}
    <el-collapse>
      <el-collapse-item title="游戏规则" name="1">
        <div>1.红蓝绿三方每方发行101张卡片，共303张，每张卡片售卖1ETH.</div>
        <div>2.用户可以购买任意一方的卡片成为其股东，所花费的资金进入奖池。</div>
        <div>3.用户可以销毁持有的卡片，销毁后该方流通数量-1，销毁数量+1.</div>
        <div>4.游戏结束后，如果你持有获胜方的卡片，按份额领取奖金。</div>
      </el-collapse-item>
      <el-collapse-item title="获胜规则" name="2">
        <div>1.如果发行数量最高的一方不到50枚（包含50），则流通数量最高的获胜。</div>
        <div>2.如果发行数量最高的一方超出50枚，，则流通数量最低的获胜。</div>
        <div>3.如果出现某两方的流通数量相等，则幸运儿（LuckyDog）获胜。</div>
      </el-collapse-item>
    </el-collapse>
    <el-table
      :data="tableData"
      style="width: 100%">
      <el-table-column
        label="阵营"
        width="180">
        <template slot-scope="scope">
          <span style="margin-left: 10px">{{ scope.row.date }}</span>
        </template>
      </el-table-column>
      <el-table-column
        label="流通数量"
        width="180">
        <template slot-scope="scope">
          <div slot="reference" class="name-wrapper">
            <el-tag type="warning" size="medium">{{ scope.row.count }}</el-tag>
          </div>
        </template>
      </el-table-column>
      <el-table-column
        label="销毁数量"
        width="180">
        <template slot-scope="scope">
          <div slot="reference" class="name-wrapper">
            <el-tag type="danger" size="medium">{{ scope.row.burnCount }}</el-tag>
          </div>
        </template>
      </el-table-column>
      <el-table-column label="操作">
        <template slot-scope="scope">
          <el-button
            size="mini"
            @click="handleMint(scope.$index, scope.row)">购买</el-button>
        </template>
      </el-table-column>
    </el-table>
    您拥有的卡的数量：{{ balanceCard }}
    想销毁的卡片Id： <input v-model="cardId"><el-button @click="burn()" type="danger" icon="el-icon-delete" circle></el-button>
    <ul>
      <li :is="item.component" :text="item.text" v-for="item in items" :key="item.id"></li>
    </ul>
    <img v-if="pending" id="loader" src="https://loading.io/spinners/double-ring/lg.double-ring-spinner.gif">
    <div class="event" v-if="winEvent">
      <p v-if="winEvent._status" id="has-won"><i aria-hidden="true" class="fa fa-check"></i> Congragulations, you have won {{winEvent._amount}} wei</p>
      <p v-else id="has-lost"><i aria-hidden="true" class="fa fa-times"></i> Sorry you lost, try again.</p>
    </div>
  </div>
</template>

<script src="//unpkg.com/vue/dist/vue.js"></script>
<script src="//unpkg.com/element-ui@2.4.11/lib/index.js"></script>

<script>
import Vue from 'vue'
var RedComponent = Vue.extend({
  props: ['text'],
  template: '<el-tag type="danger">{{ text }}</el-tag>'
})
var BlueComponent = Vue.extend({
  props: ['text'],
  template: '<el-tag type="">{{ text }}</el-tag >'
})
var GreenComponent = Vue.extend({
  props: ['text'],
  template: '<el-tag type="success">{{ text }}</el-tag>'
})
export default {
  name: 'casino',
  components: {
    'red-component': RedComponent,
    'blue-component': BlueComponent,
    'green-component': GreenComponent
  },
  data () {
    return {
      cardId: null,
      pending: false,
      winEvent: null,
      balanceCard: 0,
      contractBalanceOf:'loading',
      winner: 'LuckyDog',
      items: [],
      cardList:[],
      tableData: [{
        date: '红色',
        count: '0',
        burnCount: '0'
      }, {
        date: '蓝色',
        count: '0',
        burnCount: '0'
      }, {
        date: '绿色',
        count: '0',
        burnCount: '0'
      }]
    }
  },
  methods: {
    redAdd(component, text) {
      console.log('redAdd')
      this.items.push({
        'component': component,
        'text': text
      })
    },
    blueAdd(component, text) {
      console.log('blueAdd')
      this.items.push({
        'component': component,
        'text': text
      })
    },
    greenAdd(component, text) {
      console.log('greenAdd')
      this.items.push({
        'component': component,
        'text': text
      })
    },
    mintBlue () {
      console.log('mintBlue')
      this.winEvent = null
      this.pending = true
      this.$store.state.contractInstance().mintBlue({
        gas: 300000,
        value: this.$store.state.web3.web3Instance().toWei(1, 'ether'),
        from: this.$store.state.web3.coinbase
      }, (err) => {
        if (err) {
          console.log(err)
          this.pending = false
        }
      })
    },
    mintRed () {
      console.log('mintRed')
      this.winEvent = null
      this.pending = true
      this.$store.state.contractInstance().mintRed({
        gas: 300000,
        value: this.$store.state.web3.web3Instance().toWei(1, 'ether'),
        from: this.$store.state.web3.coinbase
      }, (err, result) => {
        if (err) {
          console.log(err)
          this.pending = false
        }
      })
    },
    mintGreen () {
      console.log('mintGreen')
      this.winEvent = null
      this.pending = true
      this.$store.state.contractInstance().mintGreen({
        gas: 300000,
        value: this.$store.state.web3.web3Instance().toWei(1, 'ether'),
        from: this.$store.state.web3.coinbase
      }, (err, result) => {
        if (err) {
          console.log(err)
          this.pending = false
        }
      })
    },
    burn () {
      console.log('burn cardId:' + this.cardId)
      this.winEvent = null
      this.pending = true
      this.$store.state.contractInstance().burn(parseInt(this.cardId, 10), {
        gas: 300000,
        from: this.$store.state.web3.coinbase
      }, (err, result) => {
        if (err) {
          console.log(err)
          this.pending = false
        }
      })
    },
    handleMint(index, row) {
      console.log(index, row)
      if(index==0){
        this.mintRed()
      }else if (index==1){
        this.mintBlue()
      }else{
        this.mintGreen()
      }
    },
    balanceOf () {
      var self = this;
      this.$store.state.contractInstance().balanceOf.call(this.$store.state.web3.coinbase, function (error, result) {
        if (error) {
          // error handle
          console.log('could not get event balanceOf()')
        } else {
          self.balanceCard = parseInt(result, 10)
          self.pending = false
        }
      })
    },
    getContractBalanceOf () {
      var self = this;
      this.$store.state.contractInstance().getContractBalanceOf.call(function (error, result) {
        if (error) {
          // error handle
          console.log('could not get event getContractBalanceOf()')
        } else {
          self.contractBalanceOf = self.$store.state.web3.web3Instance().fromWei(parseInt(result, 10), 'ether')
        }
      })
    },
    tokensOfOwner () {
      var self = this;
      this.$store.state.contractInstance().tokensOfOwner.call(function (error, result) {
        if (error) {
          // error handle
          console.log('could not get event tokensOfOwner()')
        } else {
          console.log('11111111111'+result)
          //数组的forEach方法，相对for循环语法更简单
          self.items = []
          result.forEach(card => {
            self.cardList.push({
              'cardId': parseInt(card, 10)
            })
            if(card<102){
              self.redAdd('red-component',parseInt(card, 10))
            } else if (card<203){
              self.blueAdd('blue-component',parseInt(card, 10))
            }else {
              self.greenAdd('green-component',parseInt(card, 10))
            }
          })
        }
      })
    },
    countRed () {
      var self = this;
      this.$store.state.contractInstance().countRed.call(function (error, result) {
        if (error) {
          // error handle
          console.log('could not get event countRed()')
        } else {
          self.tableData[0].count = parseInt(result, 10)
        }
      })
    },
    countBlue () {
      var self = this;
      this.$store.state.contractInstance().countBlue.call(function (error, result) {
        if (error) {
          // error handle
          console.log('could not get event totalBlueBurn()')
        } else {
          self.tableData[1].count = parseInt(result, 10)
        }
      })
    },
    countGreen () {
      var self = this;
      this.$store.state.contractInstance().countGreen.call(function (error, result) {
        if (error) {
          // error handle
          console.log('could not get event totalGreenBurn()')
        } else {
          self.tableData[2].count = parseInt(result, 10)
        }
      })
    },
    totalRedBurn () {
      var self = this;
      this.$store.state.contractInstance().totalRedBurn.call(function (error, result) {
        if (error) {
          // error handle
          console.log('could not get event totalRedBurn()')
        } else {
          self.tableData[0].burnCount = parseInt(result, 10)
        }
      })
    },
    totalBlueBurn () {
      var self = this;
      this.$store.state.contractInstance().totalBlueBurn.call(function (error, result) {
        if (error) {
          // error handle
          console.log('could not get event totalBlueBurn()')
        } else {
          self.tableData[1].burnCount = parseInt(result, 10)
        }
      })
    },
    totalGreenBurn () {
      var self = this;
      this.$store.state.contractInstance().totalGreenBurn.call(function (error, result) {
        if (error) {
          // error handle
          console.log('could not get event totalGreenBurn()')
        } else {
          self.tableData[2].burnCount = parseInt(result, 10)
        }
      })
    },
    checkWinner () {
      var self = this;
      this.$store.state.contractInstance().checkWinner.call(function (error, result) {
        if (error) {
          // error handle
          console.log('could not get event checkWinner()')
        } else {
          self.winner = result
        }
      })
    },
    refresh () {
      this.checkWinner ()
      this.countBlue()
      this.countGreen()
      this.countRed()
      this.totalBlueBurn()
      this.totalGreenBurn()
      this.totalRedBurn()
      this.tokensOfOwner()
      this.balanceOf ()
      this.getContractBalanceOf ()
    },
    test () {
      console.log('11111111111')
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

    setInterval(() => {
      this.refresh()
    }, 3000)

  }
}
</script>

<style scoped>
@import url("//unpkg.com/element-ui@2.4.11/lib/theme-chalk/index.css");
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
.time {
  font-size: 13px;
  color: #999;
}

.bottom {
  margin-top: 13px;
  line-height: 12px;
}

.button {
  padding: 0;
  float: right;
}

.image {
  width: 100%;
  display: block;
}

.clearfix:before,
.clearfix:after {
  display: table;
  content: "";
}

.clearfix:after {
  clear: both
}
</style>
