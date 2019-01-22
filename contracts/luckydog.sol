pragma solidity 0.5.1;

import "https://github.com/0xcert/ethereum-erc721/src/contracts/ownership/ownable.sol";
import "https://github.com/0xcert/ethereum-erc721/src/contracts/tokens/nf-token-metadata.sol";
//import "./ownership/ownable.sol";
//import "./tokens/nf-token-metadata.sol";



/**
 * @dev This is an example contract implementation of NFToken with metadata extension.
 */
contract Luckydog is
NFTokenMetadata,
Ownable
{

  uint8 private constant decimals = 18;

  uint256 private constant LIMIT  = 10 ** uint256(decimals);
  // 锻造上限
  uint8 private constant PRIVATE_SALE_AMOUNT = 101;
  // 所有锻造RED总数
  uint public totalRedSalesReleased = 0;
  // 所有销毁RED总数
  uint public totalRedBurn;

  // 所有锻造BLUE总数
  uint public totalBlueSalesReleased = 101;
  // 所有销毁BLUE总数
  uint public totalBlueBurn;

  // 所有锻造GREEN总数
  uint public totalGreenSalesReleased = 202;
  // 所有销毁GREEN总数
  uint public totalGreenBurn;

  // 合约创建的时间戳
  uint256 public contractStartTime;

  // 一周时间的时间戳增量常数
  uint256 private constant TIMESTAMP_INCREMENT_OF_WEEK  = 604800;
  // Owner 的钱包地址
  address payable private ownerWallet;

  uint private totalTokens;

  address public lastUser;




  /**
   * @dev Contract constructor. Sets metadata extension `name` and `symbol`.
   */
  constructor()
  public
  {
    nftName = "luckydog";
    nftSymbol = "LD";
    contractStartTime = block.timestamp;
    ownerWallet = msg.sender;
  }

  /**
   * @dev Mints a new NFT.
   */
  function mintRed()
  external payable

  {
    // 计算折扣后实际 token 数量
    uint256 limitValue = 1 * LIMIT;
    require(msg.value == limitValue, " The payment amount is wrong.");
    require(!isPrivateSaleFinished(), "The game has ended");

    // 检查发行上限
    totalRedSalesReleased = totalRedSalesReleased.add(1);
    require(totalRedSalesReleased <= PRIVATE_SALE_AMOUNT, "Mint exceeded limitation.");

    _mint(msg.sender, totalRedSalesReleased);
    _setTokenUri(totalRedSalesReleased, "RED");
    totalTokens = totalTokens.add(1);
    //address(this).send(msg.value);
    lastUser = msg.sender;


  }

  /**
   * @dev Mints a new NFT.
   */
  function mintBlue()
  external payable

  {
    // 计算折扣后实际 token 数量
    uint256 limitValue = 1 * LIMIT;
    require(msg.value == limitValue, " The payment amount is wrong.");
    require(!isPrivateSaleFinished(), "The game has ended");

    // 检查发行上限
    totalBlueSalesReleased = totalBlueSalesReleased.add(1);
    require(totalBlueSalesReleased <= 2 * PRIVATE_SALE_AMOUNT, "Mint exceeded limitation.");

    _mint(msg.sender, totalBlueSalesReleased);
    _setTokenUri(totalBlueSalesReleased, "BLUE");
    totalTokens = totalTokens.add(1);
    lastUser = msg.sender;


  }

  /**
  * @dev Mints a new NFT.
  */
  function mintGreen()
  external payable

  {
    // 计算折扣后实际 token 数量
    uint256 limitValue = 1 * LIMIT;
    require(msg.value == limitValue, " The payment amount is wrong.");
    require(!isPrivateSaleFinished(), "The game has ended");

    // 检查发行上限
    totalGreenSalesReleased = totalGreenSalesReleased.add(1);
    require(totalGreenSalesReleased <= 3 * PRIVATE_SALE_AMOUNT, "Mint exceeded limitation.");

    _mint(msg.sender, totalGreenSalesReleased);
    _setTokenUri(totalGreenSalesReleased, "GREEN");
    totalTokens = totalTokens.add(1);
    lastUser = msg.sender;


  }

  /**
   * @dev Removes a NFT from owner.
   * @param _tokenId Which NFT we want to remove.
   */
  function burn(
    uint256 _tokenId
  )
  external
  canOperate(_tokenId)
  {

    require(!isPrivateSaleFinished(), "The game has ended");

    _burn(_tokenId);



    if( _tokenId<=PRIVATE_SALE_AMOUNT){
      totalRedBurn=totalRedBurn.add(1);
    }else if(_tokenId<=PRIVATE_SALE_AMOUNT*2){
      totalBlueBurn=totalBlueBurn.add(1);
    }else {
      totalGreenBurn=totalGreenBurn.add(1);
    }
    lastUser = msg.sender;
  }

  /**
   * @dev 返回red票数
   */
  function countRed(
  )
  public
  view
  returns (uint256)
  {

    return totalRedSalesReleased - totalRedBurn;
  }

  /**
   * @dev 返回blue票数
   */
  function countBlue(
  )
  public
  view
  returns (uint256)
  {

    return totalBlueSalesReleased - totalBlueBurn -101;
  }

  /**
   * @dev 返回green票数
   */
  function countGreen(
  )
  public
  view
  returns (uint256)
  {

    return totalGreenSalesReleased - totalGreenBurn - 202;
  }

  // 返回_owner拥有的所有card的id数组
  function tokensOfAddress(address _owner) public view returns(uint256[] memory) {
    // 获得_owner拥有的数量
    require(_owner != address(0));
    uint256 tokenCount = _getOwnerNFTCount(_owner);

    // 判断数量是否为0
    if (tokenCount == 0) {
      // 如果该_owner没有，返回空数组
      return new uint256[](0);
    } else {
      // 如果该_owner有
      // 声明并初始化一个返回值result，长度为tokenCount
      uint256[] memory result = new uint256[](tokenCount);
      // 当前所有的卡数量
      uint256 totalCard = 3 * PRIVATE_SALE_AMOUNT;
      // 循环的初始值
      uint256 resultIndex = 0;

      // 所有的卡card都有ID从1增加到totalCards
      uint256 cardId;

      // 从1开始循环遍历所有的totalCats
      for (cardId = 1; cardId <= totalCard; cardId++) {
        // 判断当前catId的拥有者是否为_owner
        if (idToOwner[cardId] == _owner) {
          // 如果是，将catId放入result数组resultIndex位置
          result[resultIndex] = cardId;
          // resultIndex加1
          resultIndex++;
        }
      }

      // 返回result
      return result;
    }
  }

  // 返回sender拥有的所有card的id数组
  function tokensOfOwner() external view returns(uint256[] memory) {
    // 获得sender拥有的数量
    return tokensOfAddress(msg.sender);

  }

  /**
   * @dev 检查私募是否已经结束
   */
  function isPrivateSaleFinished() public view returns (bool) {
    bool b1 = block.timestamp > contractStartTime + TIMESTAMP_INCREMENT_OF_WEEK;

    bool b2 = 3*PRIVATE_SALE_AMOUNT == totalTokens;

    return b1 || b2;

  }

  /**
   * @dev 查看合约余额
   */
  function getContractBalanceOf() public view returns (uint) {
    return address(this).balance;
  }

  /**
   * @dev 查看领先者
   */
  function checkWinner() public view returns (string memory) {

    uint countR = countRed();
    uint countB = countBlue();
    uint countG = countGreen();

    string memory res;


    // 有一方票数过半触发少数派原则
    if(countR>50||countB>50||countG>50){
      if(countR<countB&&countR<countG){
        res= "RED";
      } else if(countB<countR&&countB<countG){
        res= "BLUE";
      } else if(countG<countR&&countG<countB){
        res= "GREEN";
      } else{
        res= "LuckyDog";
      }
    }else{
      //多数派原则

      if(countR>countB&&countR>countG){
        res= "RED";
      } else if(countB>countR&&countB>countG){
        res= "BLUE";
      } else if(countG>countR&&countG>countB){
        res= "GREEN";
      } else{
        res= "LuckyDog";
      }

    }



    return res;
  }


  /**
  * @dev 资金分红
  */
  function investmentDividend() public payable onlyOwner {


    require(isPrivateSaleFinished(), "The game is not over yet.");

    uint countR = countRed();
    uint countB = countBlue();
    uint countG = countGreen();

    uint dividend = getContractBalanceOf();
    uint dividendUnits;


    if(countR>50||countB>50||countG>50){
      if(countR<countB&&countR<countG){
        //RED win
        dividendUnits=dividend/countR;
        uint tokenId;
        // 从1开始循环遍历所有
        for (tokenId = 1; tokenId <= PRIVATE_SALE_AMOUNT; tokenId++) {

          address payable owner = address(uint160(idToOwner[tokenId]));
          // 判断当前tokenId拥有者是否为_owner
          if (address(0) != owner) {
            //address(this).tra
            //super.transfer(owner,1000);
            owner.transfer(dividendUnits);

          }
        }

      } else if(countB<countR&&countB<countG){
        //BLUE win
        dividendUnits=dividend/countB;
        uint tokenId;
        // 从1开始循环遍历所有
        for (tokenId = PRIVATE_SALE_AMOUNT+1; tokenId <= PRIVATE_SALE_AMOUNT*2; tokenId++) {

          address payable owner = address(uint160(idToOwner[tokenId]));
          // 判断当前tokenId拥有者是否为_owner
          if (address(0) != owner) {
            //address(this).tra
            //super.transfer(owner,1000);
            owner.transfer(dividendUnits);

          }
        }

      } else if(countG<countR&&countG<countB){
        //GREEN win
        dividendUnits=dividend/countG;
        uint tokenId;
        // 从1开始循环遍历所有
        for (tokenId = 2*PRIVATE_SALE_AMOUNT+1; tokenId <= PRIVATE_SALE_AMOUNT*3; tokenId++) {

          address payable owner = address(uint160(idToOwner[tokenId]));
          // 判断当前tokenId拥有者是否为_owner
          if (address(0) != owner) {
            //address(this).tra
            //super.transfer(owner,1000);
            owner.transfer(dividendUnits);

          }
        }

      } else{
        address payable winner = address(uint160(lastUser));
        winner.transfer(address(this).balance);

      }
    }else{
      //多数派原则

      if(countR>countB&&countR>countG){
        //RED win
        dividendUnits=dividend/countR;
        uint tokenId;
        // 从1开始循环遍历所有
        for (tokenId = 1; tokenId <= PRIVATE_SALE_AMOUNT; tokenId++) {

          address payable owner = address(uint160(idToOwner[tokenId]));
          // 判断当前tokenId拥有者是否为_owner
          if (address(0) != owner) {
            //address(this).tra
            //super.transfer(owner,1000);
            owner.transfer(dividendUnits);

          }
        }

      } else if(countB>countR&&countB>countG){
        //BLUE win
        dividendUnits=dividend/countB;
        uint tokenId;
        // 从1开始循环遍历所有
        for (tokenId = PRIVATE_SALE_AMOUNT+1; tokenId <= PRIVATE_SALE_AMOUNT*2; tokenId++) {

          address payable owner = address(uint160(idToOwner[tokenId]));
          // 判断当前tokenId拥有者是否为_owner
          if (address(0) != owner) {
            //address(this).tra
            //super.transfer(owner,1000);
            owner.transfer(dividendUnits);

          }
        }

      } else if(countG>countR&&countG>countB){
        //GREEN win
        dividendUnits=dividend/countG;
        uint tokenId;
        // 从1开始循环遍历所有
        for (tokenId = 2*PRIVATE_SALE_AMOUNT+1; tokenId <= PRIVATE_SALE_AMOUNT*3; tokenId++) {

          address payable owner = address(uint160(idToOwner[tokenId]));
          // 判断当前tokenId拥有者是否为_owner
          if (address(0) != owner) {
            //address(this).tra
            //super.transfer(owner,1000);
            owner.transfer(dividendUnits);

          }
        }

      } else{

        address payable winner = address(uint160(lastUser));
        winner.transfer(address(this).balance);

      }

    }


  }

}
