pragma solidity ^0.5.0;

import "./ERC20.sol";
import "./ERC20Detailed.sol";
import "./Ownable.sol";

library BokkyPooBahsDateTimeLibrary {

    uint constant SECONDS_PER_DAY = 24 * 60 * 60;
    uint constant SECONDS_PER_HOUR = 60 * 60;
    uint constant SECONDS_PER_MINUTE = 60;
    int constant OFFSET19700101 = 2440588;

    uint constant DOW_MON = 1;
    uint constant DOW_TUE = 2;
    uint constant DOW_WED = 3;
    uint constant DOW_THU = 4;
    uint constant DOW_FRI = 5;
    uint constant DOW_SAT = 6;
    uint constant DOW_SUN = 7;


    function _daysFromDate(uint year, uint month, uint day) internal pure returns (uint _days) {
        require(year >= 1970);
        int _year = int(year);
        int _month = int(month);
        int _day = int(day);

        int __days = _day
          - 32075
          + 1461 * (_year + 4800 + (_month - 14) / 12) / 4
          + 367 * (_month - 2 - (_month - 14) / 12 * 12) / 12
          - 3 * ((_year + 4900 + (_month - 14) / 12) / 100) / 4
          - OFFSET19700101;

        _days = uint(__days);
    }


    function _daysToDate(uint _days) internal pure returns (uint year, uint month, uint day) {
        int __days = int(_days);

        int L = __days + 68569 + OFFSET19700101;
        int N = 4 * L / 146097;
        L = L - (146097 * N + 3) / 4;
        int _year = 4000 * (L + 1) / 1461001;
        L = L - 1461 * _year / 4 + 31;
        int _month = 80 * L / 2447;
        int _day = L - 2447 * _month / 80;
        L = _month / 11;
        _month = _month + 2 - 12 * L;
        _year = 100 * (N - 49) + _year + L;

        year = uint(_year);
        month = uint(_month);
        day = uint(_day);
    }

    function timestampFromDate(uint year, uint month, uint day) internal pure returns (uint timestamp) {
        timestamp = _daysFromDate(year, month, day) * SECONDS_PER_DAY;
    }
    function timestampFromDateTime(uint year, uint month, uint day, uint hour, uint minute, uint second) internal pure returns (uint timestamp) {
        timestamp = _daysFromDate(year, month, day) * SECONDS_PER_DAY + hour * SECONDS_PER_HOUR + minute * SECONDS_PER_MINUTE + second;
    }
    function timestampToDate(uint timestamp) internal pure returns (uint year, uint month, uint day) {
        (year, month, day) = _daysToDate(timestamp / SECONDS_PER_DAY);
    }
    function timestampToDateTime(uint timestamp) internal pure returns (uint year, uint month, uint day, uint hour, uint minute, uint second) {
        (year, month, day) = _daysToDate(timestamp / SECONDS_PER_DAY);
        uint secs = timestamp % SECONDS_PER_DAY;
        hour = secs / SECONDS_PER_HOUR;
        secs = secs % SECONDS_PER_HOUR;
        minute = secs / SECONDS_PER_MINUTE;
        second = secs % SECONDS_PER_MINUTE;
    }

    function isValidDate(uint year, uint month, uint day) internal pure returns (bool valid) {
        if (year >= 1970 && month > 0 && month <= 12) {
            uint daysInMonth = _getDaysInMonth(year, month);
            if (day > 0 && day <= daysInMonth) {
                valid = true;
            }
        }
    }
    function isValidDateTime(uint year, uint month, uint day, uint hour, uint minute, uint second) internal pure returns (bool valid) {
        if (isValidDate(year, month, day)) {
            if (hour < 24 && minute < 60 && second < 60) {
                valid = true;
            }
        }
    }
    function isLeapYear(uint timestamp) internal pure returns (bool leapYear) {
        (uint year,,) = _daysToDate(timestamp / SECONDS_PER_DAY);
        leapYear = _isLeapYear(year);
    }
    function _isLeapYear(uint year) internal pure returns (bool leapYear) {
        leapYear = ((year % 4 == 0) && (year % 100 != 0)) || (year % 400 == 0);
    }

    function isWeekDay(uint timestamp) internal pure returns (bool weekDay) {
        weekDay = getDayOfWeek(timestamp) <= DOW_FRI;
    }
    function isWeekEnd(uint timestamp) internal pure returns (bool weekEnd) {
        weekEnd = getDayOfWeek(timestamp) >= DOW_SAT;
    }

    function getDaysInMonth(uint timestamp) internal pure returns (uint daysInMonth) {
        (uint year, uint month,) = _daysToDate(timestamp / SECONDS_PER_DAY);
        daysInMonth = _getDaysInMonth(year, month);
    }

    function _getDaysInMonth(uint year, uint month) internal pure returns (uint daysInMonth) {
        if (month == 1 || month == 3 || month == 5 || month == 7 || month == 8 || month == 10 || month == 12) {
            daysInMonth = 31;
        } else if (month != 2) {
            daysInMonth = 30;
        } else {
            daysInMonth = _isLeapYear(year) ? 29 : 28;
        }
    }
    // 1 = Monday, 7 = Sunday
    function getDayOfWeek(uint timestamp) internal pure returns (uint dayOfWeek) {
        uint _days = timestamp / SECONDS_PER_DAY;
        dayOfWeek = (_days + 3) % 7 + 1;
    }

    function getYear(uint timestamp) internal pure returns (uint year) {
        (year,,) = _daysToDate(timestamp / SECONDS_PER_DAY);
    }
    function getMonth(uint timestamp) internal pure returns (uint month) {
        (,month,) = _daysToDate(timestamp / SECONDS_PER_DAY);
    }
    function getDay(uint timestamp) internal pure returns (uint day) {
        (,,day) = _daysToDate(timestamp / SECONDS_PER_DAY);
    }
    function getHour(uint timestamp) internal pure returns (uint hour) {
        uint secs = timestamp % SECONDS_PER_DAY;
        hour = secs / SECONDS_PER_HOUR;
    }
    function getMinute(uint timestamp) internal pure returns (uint minute) {
        uint secs = timestamp % SECONDS_PER_HOUR;
        minute = secs / SECONDS_PER_MINUTE;
    }
    function getSecond(uint timestamp) internal pure returns (uint second) {
        second = timestamp % SECONDS_PER_MINUTE;
    }

    function addYears(uint timestamp, uint _years) internal pure returns (uint newTimestamp) {
        (uint year, uint month, uint day) = _daysToDate(timestamp / SECONDS_PER_DAY);
        year += _years;
        uint daysInMonth = _getDaysInMonth(year, month);
        if (day > daysInMonth) {
            day = daysInMonth;
        }
        newTimestamp = _daysFromDate(year, month, day) * SECONDS_PER_DAY + timestamp % SECONDS_PER_DAY;
        require(newTimestamp >= timestamp);
    }
    function addMonths(uint timestamp, uint _months) internal pure returns (uint newTimestamp) {
        (uint year, uint month, uint day) = _daysToDate(timestamp / SECONDS_PER_DAY);
        month += _months;
        year += (month - 1) / 12;
        month = (month - 1) % 12 + 1;
        uint daysInMonth = _getDaysInMonth(year, month);
        if (day > daysInMonth) {
            day = daysInMonth;
        }
        newTimestamp = _daysFromDate(year, month, day) * SECONDS_PER_DAY + timestamp % SECONDS_PER_DAY;
        require(newTimestamp >= timestamp);
    }
    function addDays(uint timestamp, uint _days) internal pure returns (uint newTimestamp) {
        newTimestamp = timestamp + _days * SECONDS_PER_DAY;
        require(newTimestamp >= timestamp);
    }
    function addHours(uint timestamp, uint _hours) internal pure returns (uint newTimestamp) {
        newTimestamp = timestamp + _hours * SECONDS_PER_HOUR;
        require(newTimestamp >= timestamp);
    }
    function addMinutes(uint timestamp, uint _minutes) internal pure returns (uint newTimestamp) {
        newTimestamp = timestamp + _minutes * SECONDS_PER_MINUTE;
        require(newTimestamp >= timestamp);
    }
    function addSeconds(uint timestamp, uint _seconds) internal pure returns (uint newTimestamp) {
        newTimestamp = timestamp + _seconds;
        require(newTimestamp >= timestamp);
    }

    function subYears(uint timestamp, uint _years) internal pure returns (uint newTimestamp) {
        (uint year, uint month, uint day) = _daysToDate(timestamp / SECONDS_PER_DAY);
        year -= _years;
        uint daysInMonth = _getDaysInMonth(year, month);
        if (day > daysInMonth) {
            day = daysInMonth;
        }
        newTimestamp = _daysFromDate(year, month, day) * SECONDS_PER_DAY + timestamp % SECONDS_PER_DAY;
        require(newTimestamp <= timestamp);
    }
    function subMonths(uint timestamp, uint _months) internal pure returns (uint newTimestamp) {
        (uint year, uint month, uint day) = _daysToDate(timestamp / SECONDS_PER_DAY);
        uint yearMonth = year * 12 + (month - 1) - _months;
        year = yearMonth / 12;
        month = yearMonth % 12 + 1;
        uint daysInMonth = _getDaysInMonth(year, month);
        if (day > daysInMonth) {
            day = daysInMonth;
        }
        newTimestamp = _daysFromDate(year, month, day) * SECONDS_PER_DAY + timestamp % SECONDS_PER_DAY;
        require(newTimestamp <= timestamp);
    }
    function subDays(uint timestamp, uint _days) internal pure returns (uint newTimestamp) {
        newTimestamp = timestamp - _days * SECONDS_PER_DAY;
        require(newTimestamp <= timestamp);
    }
    function subHours(uint timestamp, uint _hours) internal pure returns (uint newTimestamp) {
        newTimestamp = timestamp - _hours * SECONDS_PER_HOUR;
        require(newTimestamp <= timestamp);
    }
    function subMinutes(uint timestamp, uint _minutes) internal pure returns (uint newTimestamp) {
        newTimestamp = timestamp - _minutes * SECONDS_PER_MINUTE;
        require(newTimestamp <= timestamp);
    }
    function subSeconds(uint timestamp, uint _seconds) internal pure returns (uint newTimestamp) {
        newTimestamp = timestamp - _seconds;
        require(newTimestamp <= timestamp);
    }

    function diffYears(uint fromTimestamp, uint toTimestamp) internal pure returns (uint _years) {
        require(fromTimestamp <= toTimestamp);
        (uint fromYear,,) = _daysToDate(fromTimestamp / SECONDS_PER_DAY);
        (uint toYear,,) = _daysToDate(toTimestamp / SECONDS_PER_DAY);
        _years = toYear - fromYear;
    }
    function diffMonths(uint fromTimestamp, uint toTimestamp) internal pure returns (uint _months) {
        require(fromTimestamp <= toTimestamp);
        (uint fromYear, uint fromMonth,) = _daysToDate(fromTimestamp / SECONDS_PER_DAY);
        (uint toYear, uint toMonth,) = _daysToDate(toTimestamp / SECONDS_PER_DAY);
        _months = toYear * 12 + toMonth - fromYear * 12 - fromMonth;
    }
    function diffDays(uint fromTimestamp, uint toTimestamp) internal pure returns (uint _days) {
        require(fromTimestamp <= toTimestamp);
        _days = (toTimestamp - fromTimestamp) / SECONDS_PER_DAY;
    }
    function diffHours(uint fromTimestamp, uint toTimestamp) internal pure returns (uint _hours) {
        require(fromTimestamp <= toTimestamp);
        _hours = (toTimestamp - fromTimestamp) / SECONDS_PER_HOUR;
    }
    function diffMinutes(uint fromTimestamp, uint toTimestamp) internal pure returns (uint _minutes) {
        require(fromTimestamp <= toTimestamp);
        _minutes = (toTimestamp - fromTimestamp) / SECONDS_PER_MINUTE;
    }
    function diffSeconds(uint fromTimestamp, uint toTimestamp) internal pure returns (uint _seconds) {
        require(fromTimestamp <= toTimestamp);
        _seconds = toTimestamp - fromTimestamp;
    }
}

contract NovaxCoin is ERC20, ERC20Detailed ,Ownable {

    mapping(address => uint) public Locked;
    mapping(address => uint) public MonthlyEarning;
    mapping(address => bool) public HasLocked;
    mapping(address => uint) public StartDate;
    mapping(address => uint) public LastWithdrawDate;
    mapping(address => uint) public Withdrawed;
    mapping(address => uint) public Earned;
    mapping(address => uint) public EarningPercent;
    mapping(address => string) public SuperLockNote;
    uint public MonthlyEarningPercent  = 600;
    uint public AirdropPercent         = 1000;
    uint public TotalLockedAmount      = 0;
    uint public TotalLockedSenders     = 0;
    uint public TotalSuperLockRewrds   = 0;
    uint public TotalUnLocked          = 0;
    uint public TotalAirdropRewards    = 0;
    uint256 public lastBlock;

    constructor() public ERC20Detailed("Novax Coin","NVX",18) {
        _mint(msg.sender, 3000000 * (10 ** uint256(decimals())));
    }

    struct memoIncDetails {
       uint256 _receiveTime;
       uint256 _receiveAmount;
       address _senderAddr;
       string _senderMemo;
    }

    mapping(string => memoIncDetails[]) textPurchases;

    function sendtokenwithmemo(uint256 _amount, address _to, string memory _memo)  public returns(uint256) {
      textPurchases[nMixForeignAddrandBlock(_to)].push(memoIncDetails(now, _amount, msg.sender, _memo));
      _transfer(msg.sender, _to, _amount);
      return 200;
    }

    function uintToString(uint256 v) internal pure returns(string memory str) {
        uint maxlength = 100;
        bytes memory reversed = new bytes(maxlength);
        uint i = 0;
        while (v != 0) {
            uint remainder = v % 10;
            v = v / 10;
            reversed[i++] = byte(uint8(48 + remainder));
        }
        bytes memory s = new bytes(i + 1);
        for (uint j = 0; j <= i; j++) {
            s[j] = reversed[i - j];
        }
        str = string(s);
    }

    function append(string memory a, string memory b) internal pure returns (string memory) {
        return string(abi.encodePacked(a,"-",b));
    }

    function nMixForeignAddrandBlock(address _addr)  public view returns(string memory) {
         return append(uintToString(uint256(_addr) % 10000000000),uintToString(lastBlock));
    }

    function checkmemopurchases(address _addr, uint256 _index) view public returns(uint256,
       uint256,
       string memory,
       address) {

           uint256 rTime = textPurchases[nMixForeignAddrandBlock(_addr)][_index]._receiveTime;
           uint256 rAmount = textPurchases[nMixForeignAddrandBlock(_addr)][_index]._receiveAmount;
           string memory sMemo = textPurchases[nMixForeignAddrandBlock(_addr)][_index]._senderMemo;
           address sAddr = textPurchases[nMixForeignAddrandBlock(_addr)][_index]._senderAddr;
           if(textPurchases[nMixForeignAddrandBlock(_addr)][_index]._receiveTime == 0){
                return (0, 0,"0", _addr);
           }else {
                return (rTime, rAmount,sMemo, sAddr);
           }
    }

     function createSuperLock(uint _amount,string memory _note,address airdrop) public
    {
        /*
         * check stake availability
         */
        address sender = msg.sender;
        uint256 balanceSender = balanceOf(sender);
        //amount must be highr from 10
        require(_amount > 50, "SuperLock amount must be higher from 50 NVX!");
        // amount cannot be higher from your balance
        require(_amount <=  balanceSender, "SuperLock amount can't be higher from your balance!");
        // sender must be don't have active
        require(!HasLocked[sender], "Your wallet address is already active in SuperLock!");

        // set has lock
        HasLocked[sender]         =  true;
        // set Earning Percent
        EarningPercent[sender]    =  MonthlyEarningPercent;
        // set locked amount
        Locked[sender]            =  _amount;
        // set monthly earning
        uint monthlyEarning       =  monthlyEarningCalulate(_amount,sender);
        MonthlyEarning[sender]    =  monthlyEarning;
         // set date locking
        StartDate[sender]         =  now;
        // set total earined
        uint earined              =  monthlyEarning * 12;
        Earned[sender]            =  earined;
        // set Withdrawed to zero
        Withdrawed[sender]        =  0;
        // burn amount from balance of sender
        _burn(sender, _amount);
        // add note to sender
        SuperLockNote[sender]     = _note;
        // add to Total Locked
        TotalLockedAmount         = TotalLockedAmount + _amount;
        // add to Total Locked Senders
        TotalLockedSenders        = TotalLockedSenders + 1;
        // get airdrop rewards
        uint airdropRewards       = airdropCalulate(_amount);
        TotalAirdropRewards       = TotalAirdropRewards + airdropRewards;
        // send rewards to referral wallet
        _mint(airdrop, airdropRewards);
    }

    function airdropCalulate (uint256 _amount) public view returns(uint) {
        return _amount * AirdropPercent / 10000;
    }

    function lockedStatus() public view returns(
        bool HasLockedStatus,
        uint LockedTotal,
        uint MonthlyEarningAmount,
        uint StartDateValue,
        uint LastWithdrawDateValue,
        uint WithdrawedTotal,
        uint earinedTotal,
        uint EarningPercentAmount,
        string memory Note
        ) {
         address sender = msg.sender;
         // check sender have a stake
         require(HasLocked[sender], "Your wallet address is inactive in SuperLock!");
         HasLockedStatus             = HasLocked[sender];
         LockedTotal                 = Locked[sender];
         MonthlyEarningAmount        = MonthlyEarning[sender];
         StartDateValue              = StartDate[sender];
         WithdrawedTotal             = Withdrawed[sender];
         LastWithdrawDateValue       = LastWithdrawDate[sender];
         earinedTotal                = Earned[sender];
         EarningPercentAmount        = EarningPercent[sender];
         Note                        = SuperLockNote[sender];
    }

    function monthlyEarningCalulate(uint256 _amount,address sender) public view returns(uint) {
        // month earning
        return _amount * EarningPercent[sender] / 10000;
    }

    function withdrawMonthlyEarning() public {
         address sender = msg.sender;
         require(HasLocked[sender], "Your wallet address is inactive in SuperLock!");

         if (LastWithdrawDate[sender] != 0) {
             // diff Months From Start Date To Last Withdraw Date
             uint dw  = BokkyPooBahsDateTimeLibrary.diffMonths(StartDate[sender],LastWithdrawDate[sender]);
             // if dw highr from 12 month cann't get earning
             require(dw < 13, " Your SuperLock duration has finished!");
         }

         // date now
         uint dateNow = now;

         // date last withdraw
         uint date = LastWithdrawDate[sender];
         if (LastWithdrawDate[sender] == 0) {  date = StartDate[sender]; }

         // get diffrent Months
         uint diffMonths     = BokkyPooBahsDateTimeLibrary.diffMonths(date,dateNow);
         if (diffMonths > 12) { diffMonths = 12; }

         // check if diffrent Months > 0
         require(diffMonths > 0, "You can send withdraw request on the next month");

         // withdraw amount
         uint256 WithdrawAmount = diffMonths * MonthlyEarning[sender];

         // send monthly earnings to sender
         _mint(sender, WithdrawAmount);

         // set last withdraw date
         LastWithdrawDate[sender]  = BokkyPooBahsDateTimeLibrary.addMonths(date,diffMonths);

         // set withdrawed total
         Withdrawed[sender]  = Withdrawed[sender] + WithdrawAmount ;

         // Add to Total SuperLock Rewrds
         TotalSuperLockRewrds = TotalSuperLockRewrds + WithdrawAmount;
    }

    function unlockSuperLock() public {
         address sender = msg.sender;
         // sender must have a active superLock
         require(HasLocked[sender], "Your wallet address is inactive in SuperLock!");

         // sender must have Withdrawed amount
         require(LastWithdrawDate[sender] == 0, "You have to withdraw SuperLock rewards before call unlock function");

         // diff days From Start Date To Last Withdraw Date
         uint deff  = BokkyPooBahsDateTimeLibrary.diffDays(StartDate[sender],now);

         // if rerequest before 1 year from start lock
         require(deff > 365, "Your SuperLock period (1 year) has not expired.");

         // earnings amount must be Withdrawed
         require(Withdrawed[sender] == Earned[sender], "You have to withdraw SuperLock rewards before call unlock function");

         // send
         _mint(sender, Locked[sender]);

         // * reset superLock Data For sender * //

        // Remove From Total Locked Amount
        TotalLockedAmount         = TotalLockedAmount - Locked[sender];
        // Add To Total Unclock
        TotalUnLocked             = TotalUnLocked + Locked[sender];
        // set has lock
        HasLocked[sender]         =  false;
        // set locked amount
        Locked[sender]            =  0;
        // set monthly earning
        MonthlyEarning[sender]    =  0;
         // set date locking
        StartDate[sender]         =  0;
        // set total earined
        Earned[sender]            =  0;
        // set Withdrawed to zero
        Withdrawed[sender]        =  0;
        // set Earning Percent
        EarningPercent[sender]    = 0;
    }

    function updateMonthlyEarningPercent (uint _percent) public onlyOwner {
        MonthlyEarningPercent = _percent;
    }


    function updateAirdropPercent (uint _percent) public onlyOwner {
        AirdropPercent = _percent;
    }

    function transferRewards(uint _amount,address recipient)  public onlyOwner {
        _mint(recipient, _amount);
    }

}
