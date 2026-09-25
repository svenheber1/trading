// Candle stick Goud

#property copyright "Built with Profectus.AI. The user owns all intellectual property. Profectus.AI is not responsible for any trading results."
#property link "https://app.profectus.ai/Qt6Kxt3hOR9HNGaWRNIdWX4l9r368DO6?utm_source=share"
#property version "1.0"
#property description "This trading bot was built on Profectus.AI — the no-code drag-and-drop builder for MetaTrader 5."
#property description ""
#property description "This project was shared on 25/09/2026 13:24."
#property description ""
#property description ""
#property description ""

input int MagicNumber = 11110000;
#define EXPERT_MAGIC MagicNumber
#define PROFECTUS_LABEL "Profectus.AI"

#include <Generic/HashMap.mqh>


#define DEBUG false
#define DEBUG_TYPED false
#define INFO false
#define WARN false
#define ERROR true
#define SLCT_CNTXT_DEBUG true
#define SLCT_CNTXT_TYPE "SLCT_CNTXT_TYPE"
#define CHK_PROF_LOSS_DEBUG true
#define CHK_PROF_LOSS_TYPE "CHK_PROF_LOSS_TYPE"
#define ONC_PR_TRD_DEBUG true
#define ONC_PR_TRD_TYPE "ONC_PR_TRD_TYPE"
#define CLS_TRD_DEBUG true
#define CLS_TRD_TYPE "CLS_TRD_TYPE"
#define MDF_SL_TP_DEBUG true
#define MDF_SL_TP_TYPE "MDF_SL_TP_TYPE"
#define DLT_PND_ORDR_DEBUG true
#define DLT_PND_ORDR_TYPE "DLT_PND_ORDR_TYPE"
#define ONC_A_DAY_DEBUG true
#define ONC_A_DAY_TYPE "ONC_A_DAY_TYPE"
#define TRD_INF_DEBUG true
#define TRD_INF_TYPE "TRD_INF_TYPE"
#define EXP_PRCSSR_DEBUG true
#define EXP_PRCSSR_TYPE "EXP_PRCSSR_TYPE"
#define ONC_PR_BR_DEBUG true
#define ONC_PR_BR_TYPE "ONC_PR_BR_TYPE"

//@PAI_BLOCK_BEGIN -1 __globals__
#define MAX_ASK_BID_HISTORY_COUNT 100
#define OCO_PREFIX "[OCO<"
#define OCO_POSTFIX ">]"
#define ALLOWED_ACCOUNT 0

// User variables and constants class
class UserItem
{
   public:
      string value;
      bool isTracked;

   UserItem(string value, bool isTracked) {
      this.value = value;
      this.isTracked = isTracked;
   }

};

// Inputs (Global constants)
input double SL = 1;		// 
input double RR_Ratio = 100;		// 
input double Risk = 1;		// 
input double MA_confo = 100;		// 
input string Project_link = "https://app.profectus.ai/Qt6Kxt3hOR9HNGaWRNIdWX4l9r368DO6?utm_source=share";		// Project_link

// Variables (Global Variables)
class Variables
{
    public:


    Variables() {

    }
};
Variables* vars = new Variables();

CHashMap<string, UserItem*> variablesMap;
CHashMap<string, UserItem*> inputsMap;
CHashMap<double, double> customPointMap;

class AskBidHistory {
public:
   double historyAsk[MAX_ASK_BID_HISTORY_COUNT];
   double historyBid[MAX_ASK_BID_HISTORY_COUNT];
   int nextDataId;

   AskBidHistory() {
      nextDataId = 0;
   }

};

CHashMap<string, AskBidHistory*> askBidHistoryMap;
CHashMap<long, long> orders;    // <pending order, oco order>
CHashMap<long, datetime> ticketExpirations;    // <ticket, expiration datetime>

enum SELECT_ORDER_TYPE {
    PENDING_ORDERS, OPEN_TRADES, CLOSE_TRADES
};
enum SELECT_TRADE_DIRECTION_TYPE {
    BUYS_ONLY, SELLS_ONLY, BUYS_AND_SELLS
};
class SelectOrdersContext {
   public:
      SELECT_ORDER_TYPE type;
      long tickets[];
};
CHashMap<int, SelectOrdersContext*> selectContextMap; // <context creator index, selected data>
class TradeOrderMarkers {
   public:
      SELECT_ORDER_TYPE type;
      long tickets[];
};
CHashMap<int, TradeOrderMarkers*> tradeOrderMarkers; // <marker block index, marked tickets>
//@PAI_BLOCK_END -1

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{

	hoistTheColours();


	customPointMap.Add(0.001, 0.01);
	customPointMap.Add(0.00001, 0.0001);
	customPointMap.Add(0.000001, 0.0001);

	inputsMap.Add("SL", new UserItem(SL, false));
	inputsMap.Add("RR_Ratio", new UserItem(RR_Ratio, false));
	inputsMap.Add("Risk", new UserItem(Risk, false));
	inputsMap.Add("MA_confo", new UserItem(MA_confo, false));
	inputsMap.Add("Project_link", new UserItem(Project_link, false));



//@PAI_BLOCK_BEGIN 0 OncePerTickDto_a6d8b666-a293-43ba-ae8c-dd06e0edd99c
OncePerTickBlockParams params0;
params0.nextBlocks = "13";
params0.index = 0;
b[0] = new OncePerTickBlock(params0);
//@PAI_BLOCK_END 0

//@PAI_BLOCK_BEGIN 1 OncePerTickDto_a6d8b666-a293-43ba-ae8c-dd06e0edd99c_copied_7
OncePerTickBlockParams params1;
params1.nextBlocks = "8";
params1.index = 1;
b[1] = new OncePerTickBlock(params1);
//@PAI_BLOCK_END 1

//@PAI_BLOCK_BEGIN 2 9ed4aa0a-c54a-4f11-865d-af483f553b24_copied_7
ConditionBlockParams<Candle, Candle> params2;
params2.left_operand = new Candle("Body", Value<int>(2.0), Value<ENUM_TIMEFRAMES>(PERIOD_CURRENT));
params2.right_operand = new Candle("Body", Value<int>(1.0), Value<ENUM_TIMEFRAMES>(PERIOD_CURRENT));
params2.compare_operator = "<";
params2.left_adjust_operation = '+';
params2.left_adjust_value =  Value<double>(0);
params2.right_adjust_operation = '+';
params2.right_adjust_value = Value<double>(0);
params2.nextBlocks = "10";
params2.falseBlocks = "-1";
params2.index = 2;
params2.contextCreatorIndex = -1;
b[2] = new ConditionBlock<Candle, Candle>(params2);
//@PAI_BLOCK_END 2

//@PAI_BLOCK_BEGIN 3 9ed4aa0a-c54a-4f11-865d-af483f553b24
ConditionBlockParams<Candle, Candle> params3;
params3.left_operand = new Candle("Body", Value<int>(2.0), Value<ENUM_TIMEFRAMES>(PERIOD_CURRENT));
params3.right_operand = new Candle("Body", Value<int>(1.0), Value<ENUM_TIMEFRAMES>(PERIOD_CURRENT));
params3.compare_operator = "<";
params3.left_adjust_operation = '+';
params3.left_adjust_value =  Value<double>(0);
params3.right_adjust_operation = '+';
params3.right_adjust_value = Value<double>(0);
params3.nextBlocks = "11";
params3.falseBlocks = "-1";
params3.index = 3;
params3.contextCreatorIndex = -1;
b[3] = new ConditionBlock<Candle, Candle>(params3);
//@PAI_BLOCK_END 3

//@PAI_BLOCK_BEGIN 4 7b7a43cd-d646-4b3e-b5c8-9fcda049c178_copied_7
ConditionBlockParams<MarketPropertiesAskBidMid, IndicatorBlock_iMA> params4;
params4.left_operand = new MarketPropertiesAskBidMid("ASK", Value<int>(0));
params4.right_operand = new IndicatorBlock_iMA(Symbol(), Value<ENUM_TIMEFRAMES>(PERIOD_CURRENT), 0, Value<int>(1.0), Value<int>("input", "MA_confo"), Value<int>(0.0), MODE_SMA, PRICE_CLOSE);
params4.compare_operator = "<";
params4.left_adjust_operation = '+';
params4.left_adjust_value =  Value<double>(0);
params4.right_adjust_operation = '+';
params4.right_adjust_value = Value<double>(0.0);
params4.nextBlocks = "7";
params4.falseBlocks = "-1";
params4.index = 4;
params4.contextCreatorIndex = -1;
b[4] = new ConditionBlock<MarketPropertiesAskBidMid, IndicatorBlock_iMA>(params4);
//@PAI_BLOCK_END 4

//@PAI_BLOCK_BEGIN 5 df671671-ea17-4bb3-9e7c-35240a46aadd
ConditionBlockParams<Candle, Candle> params5;
params5.left_operand = new Candle("Close", Value<int>(1.0), Value<ENUM_TIMEFRAMES>(PERIOD_CURRENT));
params5.right_operand = new Candle("High", Value<int>(3.0), Value<ENUM_TIMEFRAMES>(PERIOD_CURRENT));
params5.compare_operator = ">";
params5.left_adjust_operation = '+';
params5.left_adjust_value =  Value<double>(0);
params5.right_adjust_operation = '+';
params5.right_adjust_value = Value<double>(0);
params5.nextBlocks = "3";
params5.falseBlocks = "-1";
params5.index = 5;
params5.contextCreatorIndex = -1;
b[5] = new ConditionBlock<Candle, Candle>(params5);
//@PAI_BLOCK_END 5

//@PAI_BLOCK_BEGIN 6 BuyNowDto_34240988-b2fa-4f8a-99fd-d033e5abb798
BuyNowBlockParams<Value<double>> params6;
params6.groupId = 0;
params6.volume_size = Value<double>("input", "Risk");
params6.volume_mode = "balanceRisk";
params6.lookup_trades = RUNNING;
params6.multiply_loss = Value<double>(1);
params6.multiply_profit =  Value<double>(1);
params6.add_loss = Value<double>(0);
params6.add_profit = Value<double>(0);
params6.reset_loss = Value<int>(1);
params6.reset_profit = Value<int>(1);
params6.loss_coef_string = "";
params6.profit_coef_string = "";
params6.stop_loss = new PercentPriceStopLoss(Value<double>("input", "SL"), ActionType::BUY);
params6.take_profit = new SLPercentTakeProfit(Value<double>("input", "RR_Ratio"), ActionType::BUY);
params6.nextBlocks = "-1";
params6.index = 6;
params6.expiration = new ExpirationNone();
params6.slippage = Value<int>(0);
params6.symbol = Symbol();
b[6] = new BuyNowBlock<Value<double>>(params6);
//@PAI_BLOCK_END 6

//@PAI_BLOCK_BEGIN 7 df671671-ea17-4bb3-9e7c-35240a46aadd_copied_7
ConditionBlockParams<Candle, Candle> params7;
params7.left_operand = new Candle("Close", Value<int>(1.0), Value<ENUM_TIMEFRAMES>(PERIOD_CURRENT));
params7.right_operand = new Candle("Low", Value<int>(3.0), Value<ENUM_TIMEFRAMES>(PERIOD_CURRENT));
params7.compare_operator = "<";
params7.left_adjust_operation = '+';
params7.left_adjust_value =  Value<double>(0);
params7.right_adjust_operation = '+';
params7.right_adjust_value = Value<double>(0);
params7.nextBlocks = "2";
params7.falseBlocks = "-1";
params7.index = 7;
params7.contextCreatorIndex = -1;
b[7] = new ConditionBlock<Candle, Candle>(params7);
//@PAI_BLOCK_END 7

//@PAI_BLOCK_BEGIN 8 4114294e-a880-4106-83a9-acf22521fd0c_copied_7
ConditionBlockParams<IndicatorBlock_iMA, IndicatorBlock_iMA> params8;
params8.left_operand = new IndicatorBlock_iMA(Symbol(), Value<ENUM_TIMEFRAMES>(PERIOD_CURRENT), 0, Value<int>(1.0), Value<int>(5.0), Value<int>(0.0), MODE_SMA, PRICE_CLOSE);
params8.right_operand = new IndicatorBlock_iMA(Symbol(), Value<ENUM_TIMEFRAMES>(PERIOD_CURRENT), 0, Value<int>(1.0), Value<int>(20.0), Value<int>(0.0), MODE_SMA, PRICE_CLOSE);
params8.compare_operator = "<";
params8.left_adjust_operation = '+';
params8.left_adjust_value =  Value<double>(0.0);
params8.right_adjust_operation = '+';
params8.right_adjust_value = Value<double>(0.0);
params8.nextBlocks = "4";
params8.falseBlocks = "-1";
params8.index = 8;
params8.contextCreatorIndex = -1;
b[8] = new ConditionBlock<IndicatorBlock_iMA, IndicatorBlock_iMA>(params8);
//@PAI_BLOCK_END 8

//@PAI_BLOCK_BEGIN 9 SellNowDto_daad9121-3454-499c-88a9-b85686836a51
SellNowBlockParams<Value<double>> params9;
params9.groupId = 0;
params9.volume_size = Value<double>("input", "Risk");
params9.volume_mode = "balanceRisk";
params9.lookup_trades = RUNNING;
params9.multiply_loss = Value<double>(1);
params9.multiply_profit = Value<double>(1);
params9.add_loss = Value<double>(0);
params9.add_profit = Value<double>(0);
params9.reset_loss = Value<int>(1);
params9.reset_profit = Value<int>(1);
params9.loss_coef_string = "";
params9.profit_coef_string = "";
params9.stop_loss = new PercentPriceStopLoss(Value<double>("input", "SL"), ActionType::SELL);
params9.take_profit = new SLPercentTakeProfit(Value<double>("input", "RR_Ratio"), ActionType::SELL);
params9.nextBlocks = "-1";
params9.index = 9;
params9.expiration = new ExpirationNone();
params9.slippage = Value<int>(0);
params9.symbol = Symbol();
b[9] = new SellNowBlock<Value<double>>(params9);
//@PAI_BLOCK_END 9

//@PAI_BLOCK_BEGIN 10 TradeOrderCountDto_80eb74d5-7f1f-4285-88cf-d50af85f28b4_copied_7
CheckTradeAndOrderCountBlockParams checkTradeAndOrderCountBlockParams10;
checkTradeAndOrderCountBlockParams10.tradeOperator = "==";
checkTradeAndOrderCountBlockParams10.orderOperator = "==";
checkTradeAndOrderCountBlockParams10.tradeCount = Value<int>(0.0);
checkTradeAndOrderCountBlockParams10.orderCount = Value<int>(0.0);
checkTradeAndOrderCountBlockParams10.nextBlocks = "9";
checkTradeAndOrderCountBlockParams10.falseBlocks = "-1";
checkTradeAndOrderCountBlockParams10.index = 10;
checkTradeAndOrderCountBlockParams10.symbolsStr = "";
checkTradeAndOrderCountBlockParams10.groupIdsStr = "";
checkTradeAndOrderCountBlockParams10.tradeDirection = SELLS_ONLY;
b[10] = new CheckTradeAndOrderCountBlock(checkTradeAndOrderCountBlockParams10);
//@PAI_BLOCK_END 10

//@PAI_BLOCK_BEGIN 11 TradeOrderCountDto_80eb74d5-7f1f-4285-88cf-d50af85f28b4
CheckTradeAndOrderCountBlockParams checkTradeAndOrderCountBlockParams11;
checkTradeAndOrderCountBlockParams11.tradeOperator = "==";
checkTradeAndOrderCountBlockParams11.orderOperator = "==";
checkTradeAndOrderCountBlockParams11.tradeCount = Value<int>(0.0);
checkTradeAndOrderCountBlockParams11.orderCount = Value<int>(0.0);
checkTradeAndOrderCountBlockParams11.nextBlocks = "6";
checkTradeAndOrderCountBlockParams11.falseBlocks = "-1";
checkTradeAndOrderCountBlockParams11.index = 11;
checkTradeAndOrderCountBlockParams11.symbolsStr = "";
checkTradeAndOrderCountBlockParams11.groupIdsStr = "";
checkTradeAndOrderCountBlockParams11.tradeDirection = BUYS_ONLY;
b[11] = new CheckTradeAndOrderCountBlock(checkTradeAndOrderCountBlockParams11);
//@PAI_BLOCK_END 11

//@PAI_BLOCK_BEGIN 12 7b7a43cd-d646-4b3e-b5c8-9fcda049c178
ConditionBlockParams<MarketPropertiesAskBidMid, IndicatorBlock_iMA> params12;
params12.left_operand = new MarketPropertiesAskBidMid("ASK", Value<int>(0));
params12.right_operand = new IndicatorBlock_iMA(Symbol(), Value<ENUM_TIMEFRAMES>(PERIOD_CURRENT), 0, Value<int>(1.0), Value<int>("input", "MA_confo"), Value<int>(0.0), MODE_SMA, PRICE_CLOSE);
params12.compare_operator = ">";
params12.left_adjust_operation = '+';
params12.left_adjust_value =  Value<double>(0);
params12.right_adjust_operation = '+';
params12.right_adjust_value = Value<double>(0.0);
params12.nextBlocks = "5";
params12.falseBlocks = "-1";
params12.index = 12;
params12.contextCreatorIndex = -1;
b[12] = new ConditionBlock<MarketPropertiesAskBidMid, IndicatorBlock_iMA>(params12);
//@PAI_BLOCK_END 12

//@PAI_BLOCK_BEGIN 13 4114294e-a880-4106-83a9-acf22521fd0c
ConditionBlockParams<IndicatorBlock_iMA, IndicatorBlock_iMA> params13;
params13.left_operand = new IndicatorBlock_iMA(Symbol(), Value<ENUM_TIMEFRAMES>(PERIOD_CURRENT), 0, Value<int>(1.0), Value<int>(5.0), Value<int>(0.0), MODE_SMA, PRICE_CLOSE);
params13.right_operand = new IndicatorBlock_iMA(Symbol(), Value<ENUM_TIMEFRAMES>(PERIOD_CURRENT), 0, Value<int>(1.0), Value<int>(20.0), Value<int>(0.0), MODE_SMA, PRICE_CLOSE);
params13.compare_operator = ">";
params13.left_adjust_operation = '+';
params13.left_adjust_value =  Value<double>(0.0);
params13.right_adjust_operation = '+';
params13.right_adjust_value = Value<double>(0.0);
params13.nextBlocks = "12";
params13.falseBlocks = "-1";
params13.index = 13;
params13.contextCreatorIndex = -1;
b[13] = new ConditionBlock<IndicatorBlock_iMA, IndicatorBlock_iMA>(params13);
//@PAI_BLOCK_END 13





   long current_account = AccountInfoInteger(ACCOUNT_LOGIN);
   if(ALLOWED_ACCOUNT != 0 && current_account != ALLOWED_ACCOUNT)
   {
      Print("Unauthorized account: ", current_account);
      Alert("This EA is licensed only for account ", ALLOWED_ACCOUNT);
      return(INIT_FAILED);
   }

   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+



//+------------------------------------------------------------------+
//| Every incomng tick function                                      |
//+------------------------------------------------------------------+
void OnTick()
{



    updateAskBidHistory();

    int c[2] = {0, 1};
    CallGraph* graph = new CallGraph(b, c);
    graph.run();
    delete graph;

    ExpirationProcessor();
    OCOProcessor();
    CommentProcessor();

    return;
}
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//| On trade events - open, close, modify                            |
//+------------------------------------------------------------------+
void OnTrade()
{



}
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//| On a period basis                                                |
//+------------------------------------------------------------------+
void OnTimer()
{



}
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//| Chart events                                                     |
//+------------------------------------------------------------------+
void OnChartEvent(
	const int id,         // Event ID
	const long& lparam,   // Parameter of type long event
	const double& dparam, // Parameter of type double event
	const string& sparam  // Parameter of type string events
)
{



}
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   //TBD

}
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Common classes                                                   |
//+------------------------------------------------------------------+
template <typename T>
class Value {
private:
   T value;
   string type;
   string name;
public:
   Value() {}

   Value(T value) {
      this.value = value;
   }
   Value(string type, string name) {
      this.type = type;
      this.name = name;
   }
   Value(Value<T>& inputValue) {
      this.value = inputValue.getValue();
      this.type = inputValue.getType();
      this.name = inputValue.getName();
   }

   T getValue() {
      return this.value;
   }

   string getType() {
      return type;
   }

   string getName() {
      return name;
   }

    T execute() {
        UserItem* userItem;
        if (type == "variable") {
            variablesMap.TryGetValue(this.name, userItem);
        } else if (type == "input") {
            inputsMap.TryGetValue(this.name, userItem);
        } else {
            if (isDateTimeFormat(this.value)) {
                return prepareDateTime(this.value);
            } else if (isTimeFormat(this.value)) {
                return prepareDateTimeFromTimeStr(this.value);
            } else {
                return this.value;
            }
        }
        string val = userItem.value;

        if (val == "true" || val == "false") {
            this.value = (bool) (val == "true");
        } else if (isDateTimeFormat(val)) {
            this.value = prepareDateTime((datetime) (val));
        } else if (isTimeFormat(val)) {
            this.value = prepareDateTimeFromTimeStr(val);
        } else {
            this.value = (double) val;
        }
        return this.value;
    }

    datetime prepareDateTime(datetime val) {
        MqlDateTime dateTimeStruct;
        TimeToStruct((datetime) (val), dateTimeStruct);
        MqlDateTime currentDateStruct;
        TimeToStruct(TimeCurrent(), currentDateStruct);

        dateTimeStruct.day = currentDateStruct.day;
        dateTimeStruct.mon = currentDateStruct.mon;
        dateTimeStruct.year = currentDateStruct.year;

        return StructToTime(dateTimeStruct);
    }

    datetime prepareDateTimeFromTimeStr(string val) {
        string currentDate = TimeToString(TimeCurrent(), TIME_DATE);
        string dateTimeStr = currentDate + " " + val;
        return StringToTime(dateTimeStr);
    }

};

class Empty {
public:
   double execute() {
      return NULL;
    }
};

class SharedData {
public:
   long ticket;

public:
   SharedData(long ticket) {
      this.ticket = ticket;
   }
   SharedData() {
      this.ticket = -1;
   }
};
//+------------------------------------------------------------------+

void debug(string msg) {
  if (DEBUG) {
    Print("[DEBUG] ", msg);
  }
}

void debug(string msg, string type) {
  if (DEBUG_TYPED) {
   if ((type == CHK_PROF_LOSS_TYPE && CHK_PROF_LOSS_DEBUG) ||
      (type == SLCT_CNTXT_TYPE && SLCT_CNTXT_DEBUG) ||
      (type == CLS_TRD_TYPE && CLS_TRD_DEBUG) ||
      (type == MDF_SL_TP_TYPE && MDF_SL_TP_DEBUG) ||
      (type == DLT_PND_ORDR_TYPE && DLT_PND_ORDR_DEBUG) ||
      (type == ONC_A_DAY_TYPE && ONC_A_DAY_DEBUG) ||
      (type == TRD_INF_TYPE && TRD_INF_DEBUG) ||
      (type == EXP_PRCSSR_TYPE && EXP_PRCSSR_DEBUG) ||
      (type == ONC_PR_BR_TYPE && ONC_PR_BR_DEBUG) ||
      (type == ONC_PR_TRD_TYPE && ONC_PR_TRD_DEBUG)) {
      Print("[", type, "] ", msg);
   }
  }
}

void info(string msg) {
  if (INFO) {
    Print("[INFO] ", msg);
  }
}

void warn(string msg) {
  if (WARN) {
    Print("[WARNING] ", msg);
  }
}

void error(string msg) {
  if (ERROR) {
    Print("[ERROR] ", msg);
  }
}

//+------------------------------------------------------------------+
//| Common block classes                                             |
//+------------------------------------------------------------------+
struct BlockParameters {
    string id;
    int index;
    string nextBlocks;
    SharedData *sharedData;
};

class Block {
public:
   virtual void execute(int& nextBlocks[]) = NULL;
   int nextBlocks[];
   int index;
   string id;
   SharedData *sharedData;
};

Block *b[14];

class CallGraph {
private:
   Block* blocks[];
   int blocks_to_execute[];

public:
   CallGraph(Block* &blocks[], int& blocks_to_execute[]) {
      CopyObjects(this.blocks, blocks);
      CopyObjects(this.blocks_to_execute, blocks_to_execute);
   }

   void run() {
      for (int i = 0; i < ArraySize(blocks_to_execute); ++i) {
         int current_index = blocks_to_execute[i];
         processBlock(current_index);
      }
   }

   void processBlock(int index) {
      int inner_blocks[];
      blocks[index].execute(inner_blocks);
      if (ArraySize(inner_blocks) == 1 && inner_blocks[0] == -1) {
         return;
      } else {
         for (int i = 0; i < ArraySize(inner_blocks); ++i) {
            processBlock(inner_blocks[i]);
         }
      }
   }
};

struct CheckResult {
   bool success;
   double result;

   CheckResult(bool success, double result) {
      this.success = success;
      this.result = result;
   }
   CheckResult(CheckResult& checkResult) {
      this.success = checkResult.success;
      this.result = checkResult.result;
   }
};

//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//| Condition block classes                                          |
//+------------------------------------------------------------------+
template <typename T1, typename T2>
struct ConditionBlockParams: BlockParameters {
    T1 left_operand;
    T2 right_operand;
    string compare_operator;
    char left_adjust_operation;
    Value<double> left_adjust_value;
    char right_adjust_operation;
    Value<double> right_adjust_value;
    string falseBlocks;
    int contextCreatorIndex;
};
template <typename T1, typename T2>
class ConditionBlock: public Block {
private:
   T1 left_operand;
   T2 right_operand;
   string compare_operator;
   int left_next_block[];
   int right_next_block[];
   int contextCreatorIndex;
   char left_adjust_operation;
   Value<double> left_adjust_value;
   char right_adjust_operation;
   Value<double> right_adjust_value;
public:
   ConditionBlock(const ConditionBlockParams<T1, T2>& params) {
      //TODO think about moving comparing operators to separate entities
      this.left_operand = params.left_operand;
      this.right_operand = params.right_operand;
      this.compare_operator = params.compare_operator;
      ParseStringToIntArray(this.left_next_block, params.nextBlocks);
      ParseStringToIntArray(this.right_next_block, params.falseBlocks);
      this.left_adjust_operation = params.left_adjust_operation;
      this.left_adjust_value = params.left_adjust_value;
      this.right_adjust_operation = params.right_adjust_operation;
      this.right_adjust_value = params.right_adjust_value;
      this.index = params.index;
      this.contextCreatorIndex = params.contextCreatorIndex;
   }

   void execute(int& nextBlocks[]) {
      debug("Executing ConditionBlock");
      if (compare(left_operand, right_operand, compare_operator)) {
         CopyObjects(nextBlocks, left_next_block);
      } else {
         CopyObjects(nextBlocks, right_next_block);
      }
   }

private:
   bool compare(T1& left, T2& right, string compare_operator) {
      return CompareValues(left, right, compare_operator, left_adjust_operation, left_adjust_value.execute(), right_adjust_operation, right_adjust_value.execute());
   }
};
//+------------------------------------------------------------------+


enum ActionType {
    BUY, SELL, UNDEFINED
};

enum LOOKUP_TRADES {
    RUNNING, RUNNING_HISTORY, HISTORY
};

struct StopLossFractions {
    double stopLossPips;
    double stopLossLevel;

    StopLossFractions() {}
    StopLossFractions(double slp, double sll) : stopLossPips(slp), stopLossLevel(sll) {}
    StopLossFractions(const StopLossFractions& another) : stopLossPips(another.stopLossPips), stopLossLevel(another.stopLossLevel) {}
};

struct TakeProfitFractions {
    double takeProfitPips;
    double takeProfitLevel;

    TakeProfitFractions() {}
    TakeProfitFractions(double tpp, double tpl) : takeProfitPips(tpp), takeProfitLevel(tpl) {}
    TakeProfitFractions(const TakeProfitFractions& another) : takeProfitPips(another.takeProfitPips), takeProfitLevel(another.takeProfitLevel) {}
};

//+------------------------------------------------------------------+
//| Stop Loss classes                                            |
//+------------------------------------------------------------------+
class StopLoss {
public:
    StopLoss(ActionType type) : type(type) {
        referencePrice = -1;
    }

    void setType(ActionType type) {
        this.type = type;
    }

    double referencePrice;
    virtual StopLossFractions calculate() = 0;

protected:
    double pipsToLimit(double pips) {
        string symbol = Symbol();

        if (type == ActionType::BUY) {
            double ask = (referencePrice != -1) ? referencePrice : SymbolInfoDouble(symbol, SYMBOL_ASK);
            return ask - pipsToPrice(pips, symbol);
        } else {
            double bid = (referencePrice != -1) ? referencePrice : SymbolInfoDouble(symbol, SYMBOL_BID);
            return bid + pipsToPrice(pips, symbol);
        }
    }

    double limitToPips(double limit) {
        string symbol = Symbol();

        if (type == ActionType::BUY) {
            double ask = (referencePrice != -1) ? referencePrice : SymbolInfoDouble(symbol, SYMBOL_ASK);
            return priceToPips(ask - limit, symbol);
        } else {
            double bid = (referencePrice != -1) ? referencePrice : SymbolInfoDouble(symbol, SYMBOL_BID);
            return priceToPips(limit - bid, symbol);
        }
    }

    ActionType type;
};

class NoneStopLoss : public StopLoss {
public:
    NoneStopLoss() : StopLoss(ActionType::BUY) {}

    StopLossFractions calculate() override {
        return StopLossFractions(0, 0);
    }
};

class FixedStopLoss : public StopLoss {
public:
    FixedStopLoss(Value<double>& pips, ActionType type) : StopLoss(type), pips(pips) {}

    StopLossFractions calculate() override {
        return StopLossFractions(pips.execute(), pipsToLimit(pips.execute()));
    }
private:
    Value<double> pips;
};

class PercentPriceStopLoss : public StopLoss {
public:
    PercentPriceStopLoss(Value<double>& percentPrice, ActionType type) : StopLoss(type), percentPrice(percentPrice) {}

    StopLossFractions calculate() override {
        string symbol = Symbol();
        if (type == ActionType::BUY) {
            double ask = (referencePrice != -1) ? referencePrice : SymbolInfoDouble(symbol, SYMBOL_ASK);
            double limit = ask - ask * percentPrice.execute() / 100;
            return StopLossFractions(limitToPips(limit), limit);
        } else {
            double bid = (referencePrice != -1) ? referencePrice : SymbolInfoDouble(symbol, SYMBOL_BID);
            double limit = bid + bid * percentPrice.execute() / 100;
            return StopLossFractions(limitToPips(limit), limit);
        }
    }
private:
    Value<double> percentPrice;
};

template <typename Dynamic>
class DynamicPipsStopLoss : public StopLoss {
public:
    DynamicPipsStopLoss(Dynamic& dynamicPips, ActionType type) : StopLoss(type) {
        this.dynamicPips = dynamicPips;
    }

    StopLossFractions calculate() override {
        double pips = dynamicPips.execute();
        return StopLossFractions(pips, pipsToLimit(pips));
    }
private:
    Dynamic dynamicPips;
};

template <typename Dynamic>
class PriceLevelStopLoss : public StopLoss {
public:
    PriceLevelStopLoss(Dynamic& dynamicLevel, ActionType type) : StopLoss(type) {
        this.dynamicLevel = dynamicLevel;
    }

    StopLossFractions calculate() override {
        double limit = dynamicLevel.execute();
        return StopLossFractions(limitToPips(limit), limit);
    }
private:
    Dynamic dynamicLevel;
};

template <typename Dynamic>
class PriceFractionStopLoss : public StopLoss {
public:
    PriceFractionStopLoss(Dynamic& dynamicDigits, ActionType type) : StopLoss(type) {
        this.dynamicDigits = dynamicDigits;
    }

    StopLossFractions calculate() override {
        string symbol = Symbol();
        double distance = dynamicDigits.execute();

        if (distance <= 0) {
            error("PriceDistanceStopLoss distance is zero or negative!");
            return StopLossFractions(0, 0);
        }

        if (type == ActionType::BUY) {
            double ask = (referencePrice != -1) ? referencePrice : SymbolInfoDouble(symbol, SYMBOL_ASK);
            double limit = ask - distance;
            return StopLossFractions(limitToPips(limit), limit);
        } else {
            double bid = (referencePrice != -1) ? referencePrice : SymbolInfoDouble(symbol, SYMBOL_BID);
            double limit = bid + distance;
            return StopLossFractions(limitToPips(limit), limit);
        }
    }

private:
    Dynamic dynamicDigits;
};

class TPPercentStopLoss : public StopLoss {
public:
    TPPercentStopLoss(Value<double>& percent, ActionType type) : StopLoss(type), percent(percent) {}

    void setTakeProfitInfo(TakeProfitFractions& tp) {
        takeProfit = tp;
    }

    StopLossFractions calculate() override {
        double slPips = takeProfit.takeProfitPips * percent.execute() / 100;
        return StopLossFractions(slPips, pipsToLimit(slPips));
    }
private:
    Value<double> percent;
    TakeProfitFractions takeProfit;
};

class SLPercentStopLoss : public StopLoss {
public:
    SLPercentStopLoss(Value<double>& percent, ActionType type) : StopLoss(type), percent(percent) {}

    void setCurrentStopLoss(double sl) {
        curStopLoss = sl;
    }

    StopLossFractions calculate() override {
        double slPips = limitToPips(curStopLoss) * percent.execute() / 100;
        return StopLossFractions(slPips, pipsToLimit(slPips));
    }
private:
    Value<double> percent;
    double curStopLoss;
};

class AdjustedStopLoss : public StopLoss {
public:
    AdjustedStopLoss(StopLoss* inner, Value<double>& adjustValue, string adjustOp)
        : StopLoss(inner.type), inner(inner), adjustValue(adjustValue), adjustOp(adjustOp) {}

    StopLossFractions calculate() override {
        inner.referencePrice = referencePrice;
        StopLossFractions result = inner.calculate();
        double base = result.stopLossPips;
        double adj = adjustValue.execute();
        double adjusted;
        if (adjustOp == "+") adjusted = base + adj;
        else if (adjustOp == "-") adjusted = base - adj;
        else if (adjustOp == "*") adjusted = base * adj;
        else if (adjustOp == "/" && adj != 0) adjusted = base / adj;
        else adjusted = base;
        if (adjusted < 0) adjusted = 0;
        return StopLossFractions(adjusted, pipsToLimit(adjusted));
    }

    StopLoss* inner;
private:
    Value<double> adjustValue;
    string adjustOp;
};
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Take Profit classes                                            |
//+------------------------------------------------------------------+
class TakeProfit {
public:
    TakeProfit(ActionType type) : type(type) {
        referencePrice = -1;
    }

    void setType(ActionType type) {
        this.type = type;
    }

    double referencePrice;
    virtual TakeProfitFractions calculate() = 0;
protected:
    double pipsToLimit(double pips) {
        string symbol = Symbol();

        if (type == ActionType::BUY) {
            double ask = (referencePrice != -1) ? referencePrice : SymbolInfoDouble(symbol, SYMBOL_ASK);
            return ask + pipsToPrice(pips, symbol);
        } else {
            double bid = (referencePrice != -1) ? referencePrice : SymbolInfoDouble(symbol, SYMBOL_BID);
            return bid - pipsToPrice(pips, symbol);
        }
    }

    double limitToPips(double limit) {
        string symbol = Symbol();

        if (type == ActionType::BUY) {
            double ask = (referencePrice != -1) ? referencePrice : SymbolInfoDouble(symbol, SYMBOL_ASK);
            return priceToPips(limit - ask, symbol);
        } else {
            double bid = (referencePrice != -1) ? referencePrice : SymbolInfoDouble(symbol, SYMBOL_BID);
            return priceToPips(bid - limit, symbol);
        }
    }

    ActionType type;
};

class NoneTakeProfit : public TakeProfit {
public:
    NoneTakeProfit() : TakeProfit(ActionType::BUY) {}

    TakeProfitFractions calculate() override {
        return TakeProfitFractions(0, 0);
    }
};

class FixedTakeProfit : public TakeProfit {
public:
    FixedTakeProfit(Value<double>& pips, ActionType type) : TakeProfit(type), pips(pips) {}

    TakeProfitFractions calculate() override {
        return TakeProfitFractions(pips.execute(), pipsToLimit(pips.execute()));
    }
private:
    Value<double> pips;
};

class PercentPriceTakeProfit : public TakeProfit {
public:
    PercentPriceTakeProfit(Value<double>& percentPrice, ActionType type) : TakeProfit(type), percentPrice(percentPrice) {}

    TakeProfitFractions calculate() override {
        string symbol = Symbol();
        if (type == ActionType::BUY) {
            double ask = (referencePrice != -1) ? referencePrice : SymbolInfoDouble(symbol, SYMBOL_ASK);
            double limit = ask + ask * percentPrice.execute() / 100;
            return TakeProfitFractions(limitToPips(limit), limit);
        } else {
            double bid = (referencePrice != -1) ? referencePrice : SymbolInfoDouble(symbol, SYMBOL_BID);
            double limit = bid - bid * percentPrice.execute() / 100;
            return TakeProfitFractions(limitToPips(limit), limit);
        }
    }
private:
    Value<double> percentPrice;
};

template <typename Dynamic>
class DynamicPipsTakeProfit : public TakeProfit {
public:
    DynamicPipsTakeProfit(Dynamic& dynamicPips, ActionType type) : TakeProfit(type) {
        this.dynamicPips = dynamicPips;
    }

    TakeProfitFractions calculate() override {
        double pips = dynamicPips.execute();
        return TakeProfitFractions(pips, pipsToLimit(pips));
    }
private:
    Dynamic dynamicPips;
};

template <typename Dynamic>
class PriceLevelTakeProfit : public TakeProfit {
public:
    PriceLevelTakeProfit(Dynamic& dynamicLevel, ActionType type) : TakeProfit(type) {
        this.dynamicLevel = dynamicLevel;
    }

    TakeProfitFractions calculate() override {
        double limit = dynamicLevel.execute();
        return TakeProfitFractions(limitToPips(limit), limit);
    }
private:
    Dynamic dynamicLevel;
};

template <typename Dynamic>
class PriceFractionTakeProfit : public TakeProfit {
public:
    PriceFractionTakeProfit(Dynamic& dynamicDigits, ActionType type) : TakeProfit(type) {
        this.dynamicDigits = dynamicDigits;
    }

    TakeProfitFractions calculate() override {
        string symbol = Symbol();
        double fractionPrice = dynamicDigits.execute();

        if (type == ActionType::BUY) {
            double ask = (referencePrice != -1) ? referencePrice : SymbolInfoDouble(symbol, SYMBOL_ASK);
            double limit = ask + ask * fractionPrice;
            return TakeProfitFractions(limitToPips(limit), limit);
        } else {
            double bid = (referencePrice != -1) ? referencePrice : SymbolInfoDouble(symbol, SYMBOL_BID);
            double limit = bid - bid * fractionPrice;
            return TakeProfitFractions(limitToPips(limit), limit);
        }
    }

private:
    Dynamic dynamicDigits;
};

class SLPercentTakeProfit : public TakeProfit {
public:
    SLPercentTakeProfit(Value<double>& percent, ActionType type) : TakeProfit(type), percent(percent) {}

    void setStopLossInfo(StopLossFractions& sl) {
        stopLoss = sl;
    }

    TakeProfitFractions calculate() override {
        double tpPips = stopLoss.stopLossPips * percent.execute() / 100;
        return TakeProfitFractions(tpPips, pipsToLimit(tpPips));
    }
private:
    Value<double> percent;
    StopLossFractions stopLoss;
};

class TPPercentTakeProfit : public TakeProfit {
public:
    TPPercentTakeProfit(Value<double>& percent, ActionType type) : TakeProfit(type), percent(percent) {}

    void setCurrentTakeProfit(double tp) {
        curTakeProfit = tp;
    }

    TakeProfitFractions calculate() override {
        double tpPips = limitToPips(curTakeProfit) * percent.execute() / 100;
        return TakeProfitFractions(tpPips, pipsToLimit(tpPips));
    }
private:
    Value<double> percent;
    double curTakeProfit;
};

class AdjustedTakeProfit : public TakeProfit {
public:
    AdjustedTakeProfit(TakeProfit* inner, Value<double>& adjustValue, string adjustOp)
        : TakeProfit(inner.type), inner(inner), adjustValue(adjustValue), adjustOp(adjustOp) {}

    TakeProfitFractions calculate() override {
        inner.referencePrice = referencePrice;
        TakeProfitFractions result = inner.calculate();
        double base = result.takeProfitPips;
        double adj = adjustValue.execute();
        double adjusted;
        if (adjustOp == "+") adjusted = base + adj;
        else if (adjustOp == "-") adjusted = base - adj;
        else if (adjustOp == "*") adjusted = base * adj;
        else if (adjustOp == "/" && adj != 0) adjusted = base / adj;
        else adjusted = base;
        if (adjusted < 0) adjusted = 0;
        return TakeProfitFractions(adjusted, pipsToLimit(adjusted));
    }

    TakeProfit* inner;
private:
    Value<double> adjustValue;
    string adjustOp;
};
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Stop Loss and Take Profit calculations                           |
//+------------------------------------------------------------------+

struct ResultSLTPFractions {
   StopLossFractions stopLoss;
   TakeProfitFractions takeProfit;

   ResultSLTPFractions(StopLossFractions& stopLoss, TakeProfitFractions& takeProfit) {
      this.stopLoss = stopLoss;
      this.takeProfit = takeProfit;
   }
   ResultSLTPFractions(ResultSLTPFractions& resultSLTPFractions) {
      this.stopLoss = resultSLTPFractions.stopLoss;
      this.takeProfit = resultSLTPFractions.takeProfit;
   }
};

ResultSLTPFractions calculateSLTPFractions(StopLoss *stop_loss, TakeProfit *take_profit) {
   return calculateSLTPFractions(stop_loss, take_profit, 0, 0);
}

ResultSLTPFractions calculateSLTPFractions(StopLoss *stop_loss, TakeProfit *take_profit, double oldStopLoss, double oldTakeProfit) {
    StopLossFractions stopLoss;
    TakeProfitFractions takeProfit;

    // Unwrap AdjustedStopLoss/AdjustedTakeProfit to get the real inner type for checks
    StopLoss* rawSL = IsInstance<StopLoss, AdjustedStopLoss>(stop_loss)
        ? dynamic_cast<AdjustedStopLoss*>(stop_loss).inner
        : stop_loss;
    TakeProfit* rawTP = IsInstance<TakeProfit, AdjustedTakeProfit>(take_profit)
        ? dynamic_cast<AdjustedTakeProfit*>(take_profit).inner
        : take_profit;

    bool isStopLossPercentOfTP = IsInstance<StopLoss, TPPercentStopLoss>(rawSL);
    bool isTakeProfitPercentOfSL = IsInstance<TakeProfit, SLPercentTakeProfit>(rawTP);
    bool isStopLossPercentOfSL = IsInstance<StopLoss, SLPercentStopLoss>(rawSL);
    bool isTakeProfitPercentOfTP = IsInstance<TakeProfit, TPPercentTakeProfit>(rawTP);

    if (isStopLossPercentOfSL) {
         SLPercentStopLoss* percent_stop_loss = dynamic_cast<SLPercentStopLoss*>(rawSL);
         percent_stop_loss.setCurrentStopLoss(oldStopLoss);
    }
    if (isTakeProfitPercentOfTP) {
         TPPercentTakeProfit* percent_take_profit = dynamic_cast<TPPercentTakeProfit*>(rawTP);
         percent_take_profit.setCurrentTakeProfit(oldTakeProfit);
    }

    if (isStopLossPercentOfTP && isTakeProfitPercentOfSL) {
        stopLoss = StopLossFractions(0, 0);
        takeProfit = TakeProfitFractions(0, 0);
        warn("'% of Stop-Loss' and '% of Take-Profit' are not compatible, both SL and TP are not set");
    } else if (isStopLossPercentOfTP) {
        takeProfit = take_profit.calculate();
        TPPercentStopLoss* percent_stop_loss = dynamic_cast<TPPercentStopLoss*>(rawSL);

        percent_stop_loss.setTakeProfitInfo(takeProfit);
        stopLoss = stop_loss.calculate();
    } else if (isTakeProfitPercentOfSL) {
        stopLoss = stop_loss.calculate();
        SLPercentTakeProfit* percent_take_profit = dynamic_cast<SLPercentTakeProfit*>(rawTP);

        percent_take_profit.setStopLossInfo(stopLoss);
        takeProfit = take_profit.calculate();
    } else {
        stopLoss = stop_loss.calculate();
        takeProfit = take_profit.calculate();
    }

    return ResultSLTPFractions(stopLoss, takeProfit);

}
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Expiration classes                                               |
//+------------------------------------------------------------------+
class Expiration {
public:
    Expiration() { }

    virtual datetime calculateExpiration() = 0;

};

class ExpirationNone : public Expiration {
public:
    ExpirationNone() : Expiration() {}

    datetime calculateExpiration() override {
        debug("None expiration, current date time: " + TimeCurrent());
        return (datetime)0;
    }
};

class ExpirationFixed : public Expiration {
private:
    Value<datetime> expiration;

public:
    ExpirationFixed(Value<datetime>& expiration): Expiration() {
        this.expiration = expiration;
    }

    datetime calculateExpiration() override {
        datetime currentDateTime = TimeCurrent();

        MqlDateTime expirationResult;
        TimeToStruct(currentDateTime, expirationResult);
        MqlDateTime expirationHHmm;
        TimeToStruct(expiration.execute(), expirationHHmm);

        expirationResult.hour = expirationHHmm.hour;
        expirationResult.min = expirationHHmm.min;
        expirationResult.sec = expirationHHmm.sec;

        if (StructToTime(expirationResult) < currentDateTime) {
            expirationResult.day = expirationResult.day + 1;
        }

        datetime expirationDateTime = StructToTime(expirationResult);

        debug("Calculated fixed expiration: " + expirationDateTime + ", current date time: " + currentDateTime);
        return expirationDateTime;
    }
};

class ExpirationRelative : public Expiration {
private:
    Value<double> days;
    Value<double> hours;
    Value<double> minutes;
    Value<double> seconds;
public:
    ExpirationRelative(Value<double>& days, Value<double>& hours, Value<double>& minutes, Value<double>& seconds) : Expiration() {
        this.days = days;
        this.hours = hours;
        this.minutes = minutes;
        this.seconds = seconds;
    }

    datetime calculateExpiration() override {
        datetime currentDateTime = TimeCurrent();

        int daysInSec = ((int)days.execute()) * 24 * 3600;
        int hoursInSec = ((int)hours.execute()) * 3600;
        int minutesInSec = ((int)minutes.execute()) * 60;

        datetime expirationDateTime = currentDateTime + daysInSec + hoursInSec + minutesInSec + ((int)seconds.execute());

        debug("Calculated relative expiration: " + expirationDateTime + ", current date time: " + currentDateTime);
        return expirationDateTime;
    }
};
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Buy now block classes                                            |
//+------------------------------------------------------------------+
template <typename T>
struct BuyNowBlockParams: BlockParameters {
    int groupId;
    T volume_size;
    string volume_mode;
    LOOKUP_TRADES lookup_trades;
    Value<double> multiply_loss;
    Value<double> multiply_profit;
    Value<double> add_loss;
    Value<double> add_profit;
    Value<int> reset_loss;
    Value<int> reset_profit;
    string loss_coef_string;
    string profit_coef_string;
    StopLoss *stop_loss;
    TakeProfit *take_profit;
    Expiration *expiration;
    Value<int> slippage;
    string symbol;
};
template<typename T>
class BuyNowBlock: public Block {
private:
   int groupId;
   T volume_size;
   string volume_mode;
   LOOKUP_TRADES lookup_trades;
   Value<double> multiply_loss;
   Value<double> multiply_profit;
   Value<double> add_loss;
   Value<double> add_profit;
   Value<int> reset_loss;
   Value<int> reset_profit;
   string loss_coef_string;
   string profit_coef_string;
   StopLoss *stop_loss;
   TakeProfit *take_profit;
   Expiration *expiration;
   Value<int> slippage;
   string symbol;

public:
   BuyNowBlock(const BuyNowBlockParams<T>& params) {
      this.groupId = params.groupId;
      this.volume_size = params.volume_size;
      this.volume_mode = params.volume_mode;
      this.lookup_trades = params.lookup_trades;
      this.multiply_loss = params.multiply_loss;
      this.multiply_profit = params.multiply_profit;
      this.add_loss = params.add_loss;
      this.add_profit = params.add_profit;
      this.reset_loss = params.reset_loss;
      this.reset_profit = params.reset_profit;
      this.loss_coef_string = params.loss_coef_string;
      this.profit_coef_string = params.profit_coef_string;
      this.stop_loss = params.stop_loss;
      this.take_profit = params.take_profit;
      this.expiration = params.expiration;
      this.slippage = params.slippage;
      this.index = params.index;
      this.symbol = params.symbol;
      ParseStringToIntArray(this.nextBlocks, params.nextBlocks);
   }

    void execute(int& nextBlocks[]) {
        debug("Executing BuyBlock");
        double lots = 0;

        ResultSLTPFractions resultSLTPFractions = calculateSLTPFractions(stop_loss, take_profit);
        StopLossFractions stopLoss = resultSLTPFractions.stopLoss;
        TakeProfitFractions takeProfit = resultSLTPFractions.takeProfit;

		lots = processVolumeMode(this.symbol, volume_mode, volume_size.execute(), stopLoss.stopLossPips, lookup_trades, multiply_loss.execute(), multiply_profit.execute(), add_loss.execute(), add_profit.execute(), reset_loss.execute(), reset_profit.execute(), loss_coef_string, profit_coef_string);
		debug("BuyNow lots : " + (string)lots);

		long ticket = createBuyNowOrder(this.symbol, lots, stopLoss.stopLossLevel, takeProfit.takeProfitLevel, EXPERT_MAGIC + groupId, expiration.calculateExpiration(), slippage.execute());
		if (ticket == -1) {
            error("Couldn't create Buy Now order!");
            return;
		}
		debug("BuyNow ticket : " + (string)ticket);

        CopyObjects(nextBlocks, this.nextBlocks);
   }

};

//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Buy now block functions                                          |
//+------------------------------------------------------------------+

long createBuyNowOrder(
	string symbol,
	double lots,
	double stopLoss,
	double takeProfit,
	int magicNumber,
	datetime expiration,
	int slippage
	)
{
	return createOrder(
		symbol,
		ORDER_TYPE_BUY,
		lots,
		SYMBOL_ASK,
		stopLoss,
		takeProfit,
		"Buy now comment",
		magicNumber,
		expiration,
		slippage
	);
}

//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Buy later block classes                                            |
//+------------------------------------------------------------------+
template<typename T, typename T1>
struct BuyPendingBlockParams: BlockParameters {
    int groupId;
    T volume_size;
    string volume_mode;
    LOOKUP_TRADES lookup_trades;
    Value<double> multiply_loss;
    Value<double> multiply_profit;
    Value<double> add_loss;
    Value<double> add_profit;
    Value<int> reset_loss;
    Value<int> reset_profit;
    string loss_coef_string;
    string profit_coef_string;
    StopLoss* stop_loss;
    TakeProfit* take_profit;
    Expiration *expiration;
    Value<int> slippage;
    T1 pendingPrice;
    string priceType;
    Value<double> priceOffset;
    bool isOcoEnabled;
    string symbol;
};
template<typename T, typename T1>
class BuyPendingBlock: public Block {
private:
   int groupId;
   T volume_size;
   string volume_mode;
   LOOKUP_TRADES lookup_trades;
   Value<double> multiply_loss;
   Value<double> multiply_profit;
   Value<double> add_loss;
   Value<double> add_profit;
   Value<int> reset_loss;
   Value<int> reset_profit;
   string loss_coef_string;
   string profit_coef_string;
   StopLoss *stop_loss;
   TakeProfit *take_profit;
   Expiration *expiration;
   Value<int> slippage;
   T1 pendingPrice;
   string priceType;
   Value<double> priceOffset;
   bool isOcoEnabled;
   string symbol;

public:
   BuyPendingBlock(const BuyPendingBlockParams<T, T1>& params) {
      this.groupId = params.groupId;
      this.volume_size = params.volume_size;
      this.volume_mode = params.volume_mode;
      this.lookup_trades = params.lookup_trades;
      this.multiply_loss = params.multiply_loss;
      this.multiply_profit = params.multiply_profit;
      this.add_loss = params.add_loss;
      this.add_profit = params.add_profit;
      this.reset_loss = params.reset_loss;
      this.reset_profit = params.reset_profit;
      this.loss_coef_string = params.loss_coef_string;
      this.profit_coef_string = params.profit_coef_string;
      this.stop_loss = params.stop_loss;
      this.take_profit = params.take_profit;
      this.expiration = params.expiration;
      this.slippage = params.slippage;
      this.pendingPrice = params.pendingPrice;
      this.priceType = params.priceType;
      this.priceOffset = params.priceOffset;
      this.isOcoEnabled = params.isOcoEnabled;
      this.index = params.index;
      this.symbol = params.symbol;
      ParseStringToIntArray(this.nextBlocks, params.nextBlocks);
   }

    void execute(int& nextBlocks[]) {
        debug("Executing BuyPendingBlock");
        double lots = 0;

        double price = 0;
        if (priceType == "ask") {
            price = SymbolInfoDouble(this.symbol, SYMBOL_ASK);
        } else if (priceType == "bid") {
            price = SymbolInfoDouble(this.symbol, SYMBOL_BID);
        } else if (priceType == "mid") {
            price = (SymbolInfoDouble(this.symbol, SYMBOL_ASK) + SymbolInfoDouble(this.symbol, SYMBOL_BID)) / 2;
        } else if (priceType == "custom") {
            price = pendingPrice.execute();
        } else {
            error("Unknown price type: " + priceType);
            return;
        }
        price = price + pipsToPrice(priceOffset.execute(), this.symbol);

        stop_loss.referencePrice = price;
        take_profit.referencePrice = price;

        ResultSLTPFractions resultSLTPFractions = calculateSLTPFractions(stop_loss, take_profit);
        StopLossFractions stopLoss = resultSLTPFractions.stopLoss;
        TakeProfitFractions takeProfit = resultSLTPFractions.takeProfit;

		lots = processVolumeMode(this.symbol, volume_mode, volume_size.execute(), stopLoss.stopLossPips, lookup_trades, multiply_loss.execute(), multiply_profit.execute(), add_loss.execute(), add_profit.execute(), reset_loss.execute(), reset_profit.execute(), loss_coef_string, profit_coef_string);
		debug("BuyPending lots : " + (string)lots);

		long ticket = createBuyPendingOrder(this.symbol, lots, stopLoss.stopLossLevel, takeProfit.takeProfitLevel, price, isOcoEnabled, EXPERT_MAGIC + groupId, expiration.calculateExpiration(), slippage.execute());
		if (ticket == -1) {
            error("Couldn't create Buy Pending order!");
            return;
		}
		debug("BuyPending ticket : " + (string)ticket);

        CopyObjects(nextBlocks, this.nextBlocks);
   }

};

//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Buy later block functions                                          |
//+------------------------------------------------------------------+

long createBuyPendingOrder(
	string symbol,
	double lots,
	double stopLoss,
	double takeProfit,
	double price,
	bool isOcoEnabled,
	int magicNumber,
	datetime expiration,
	int slippage
	)
{
	double ask = SymbolInfoDouble(symbol,SYMBOL_ASK);
	ENUM_ORDER_TYPE type = 0;

   if (price == ask) {type = ORDER_TYPE_BUY;}
	else if (price < ask)  {type = ORDER_TYPE_BUY_LIMIT;}
	else if (price > ask)  {type = ORDER_TYPE_BUY_STOP;}

	return createOrder(
		symbol,
		type,
		lots,
		SYMBOL_ASK,
		stopLoss,
		takeProfit,
		"Buy later comment",
		magicNumber,
		expiration,
		slippage,
		price,
		isOcoEnabled
	);
}

//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Sell now block classes                                           |
//+------------------------------------------------------------------+
template <typename T>
struct SellNowBlockParams: BlockParameters {
    int groupId;
    T volume_size;
    string volume_mode;
    LOOKUP_TRADES lookup_trades;
    Value<double> multiply_loss;
    Value<double> multiply_profit;
    Value<double> add_loss;
    Value<double> add_profit;
    Value<int> reset_loss;
    Value<int> reset_profit;
    string loss_coef_string;
    string profit_coef_string;
    StopLoss* stop_loss;
    TakeProfit* take_profit;
    Expiration *expiration;
    Value<int> slippage;
    string symbol;
};
template<typename T>
class SellNowBlock: public Block {
private:
   int groupId;
   T volume_size;
   string volume_mode;
   LOOKUP_TRADES lookup_trades;
   Value<double> multiply_loss;
   Value<double> multiply_profit;
   Value<double> add_loss;
   Value<double> add_profit;
   Value<int> reset_loss;
   Value<int> reset_profit;
   string loss_coef_string;
   string profit_coef_string;
   StopLoss* stop_loss;
   TakeProfit* take_profit;
   Expiration *expiration;
   Value<int> slippage;
   string symbol;

public:
   SellNowBlock(const SellNowBlockParams<T>& params) {
      this.groupId = params.groupId;
      this.volume_size = params.volume_size;
      this.volume_mode = params.volume_mode;
      this.lookup_trades = params.lookup_trades;
      this.multiply_loss = params.multiply_loss;
      this.multiply_profit = params.multiply_profit;
      this.add_loss = params.add_loss;
      this.add_profit = params.add_profit;
      this.reset_loss = params.reset_loss;
      this.reset_profit = params.reset_profit;
      this.loss_coef_string = params.loss_coef_string;
      this.profit_coef_string = params.profit_coef_string;
      this.stop_loss = params.stop_loss;
      this.take_profit = params.take_profit;
      this.expiration = params.expiration;
      this.slippage = params.slippage;
      this.index = params.index;
      this.symbol = params.symbol;
      ParseStringToIntArray(this.nextBlocks, params.nextBlocks);
   }

    void execute(int& nextBlocks[]) {
        debug("Executing SellNowBlock");
        double lots = 0;

        ResultSLTPFractions resultSLTPFractions = calculateSLTPFractions(stop_loss, take_profit);
        StopLossFractions stopLoss = resultSLTPFractions.stopLoss;
        TakeProfitFractions takeProfit = resultSLTPFractions.takeProfit;

		lots = processVolumeMode(this.symbol, volume_mode, volume_size.execute(), stopLoss.stopLossPips, lookup_trades, multiply_loss.execute(), multiply_profit.execute(), add_loss.execute(), add_profit.execute(), reset_loss.execute(), reset_profit.execute(), loss_coef_string, profit_coef_string);
		debug("SellNow lots : " + (string)lots);

		long ticket = createSellNowOrder(this.symbol, lots, stopLoss.stopLossLevel, takeProfit.takeProfitLevel, EXPERT_MAGIC + groupId, expiration.calculateExpiration(), slippage.execute());
		if (ticket == -1) {
            error("Couldn't create Sell Now order!");
            return;
		}
		debug("SellNow ticket : " + (string)ticket);

        CopyObjects(nextBlocks, this.nextBlocks);
   }

};

//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Sell now block functions                                         |
//+------------------------------------------------------------------+

long createSellNowOrder(
	string symbol,
	double lots,
	double stopLoss,
	double takeProfit,
	int magicNumber,
	datetime expiration,
	int slippage
	)
{
	return createOrder(
		symbol,
		ORDER_TYPE_SELL,
		lots,
		SYMBOL_BID,
		stopLoss,
		takeProfit,
		"Sell now comment",
		magicNumber,
		expiration,
		slippage
	);
}

//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Sell later block classes                                           |
//+------------------------------------------------------------------+
template<typename T1, typename T2>
struct SellPendingBlockParams: BlockParameters {
    int groupId;
    T1 volume_size;
    string volume_mode;
    LOOKUP_TRADES lookup_trades;
    Value<double> multiply_loss;
    Value<double> multiply_profit;
    Value<double> add_loss;
    Value<double> add_profit;
    Value<int> reset_loss;
    Value<int> reset_profit;
    string loss_coef_string;
    string profit_coef_string;
    StopLoss* stop_loss;
    TakeProfit* take_profit;
    Expiration *expiration;
    Value<int> slippage;
    T2 pendingPrice;
    string priceType;
    Value<double> priceOffset;
    bool isOcoEnabled;
    string symbol;
};
template<typename T, typename T1>
class SellPendingBlock: public Block {
private:
   int groupId;
   T volume_size;
   string volume_mode;
   LOOKUP_TRADES lookup_trades;
   Value<double> multiply_loss;
   Value<double> multiply_profit;
   Value<double> add_loss;
   Value<double> add_profit;
   Value<int> reset_loss;
   Value<int> reset_profit;
   string loss_coef_string;
   string profit_coef_string;
   StopLoss* stop_loss;
   TakeProfit* take_profit;
   Expiration *expiration;
   Value<int> slippage;
   T1 pendingPrice;
   string priceType;
   Value<double> priceOffset;
   bool isOcoEnabled;
   string symbol;

public:
   SellPendingBlock(SellPendingBlockParams<T, T1>& params) {
      this.groupId = params.groupId;
      this.volume_size = params.volume_size;
      this.volume_mode = params.volume_mode;
      this.lookup_trades = params.lookup_trades;
      this.multiply_loss = params.multiply_loss;
      this.multiply_profit = params.multiply_profit;
      this.add_loss = params.add_loss;
      this.add_profit = params.add_profit;
      this.reset_loss = params.reset_loss;
      this.reset_profit = params.reset_profit;
      this.loss_coef_string = params.loss_coef_string;
      this.profit_coef_string = params.profit_coef_string;
      this.stop_loss = params.stop_loss;
      this.take_profit = params.take_profit;
      this.expiration = params.expiration;
      this.slippage = params.slippage;
      this.pendingPrice = params.pendingPrice;
      this.priceType = params.priceType;
      this.priceOffset = params.priceOffset;
      this.isOcoEnabled = params.isOcoEnabled;
      this.index = params.index;
      this.symbol = params.symbol;
      ParseStringToIntArray(nextBlocks, params.nextBlocks);
   }

    void execute(int& nextBlocks[]) {
        debug("Executing SellPendingBlock");
        double lots = 0;

        double price = 0;
        if (priceType == "ask") {
            price = SymbolInfoDouble(this.symbol, SYMBOL_ASK);
        } else if (priceType == "bid") {
            price = SymbolInfoDouble(this.symbol, SYMBOL_BID);
        } else if (priceType == "mid") {
            price = (SymbolInfoDouble(this.symbol, SYMBOL_ASK) + SymbolInfoDouble(this.symbol, SYMBOL_BID)) / 2;
        } else if (priceType == "custom") {
            price = pendingPrice.execute();
        } else {
            error("Unknown price type: " + priceType);
            return;
        }
        price = price - pipsToPrice(priceOffset.execute(), this.symbol);

        stop_loss.referencePrice = price;
        take_profit.referencePrice = price;

        ResultSLTPFractions resultSLTPFractions = calculateSLTPFractions(stop_loss, take_profit);
        StopLossFractions stopLoss = resultSLTPFractions.stopLoss;
        TakeProfitFractions takeProfit = resultSLTPFractions.takeProfit;

		lots = processVolumeMode(this.symbol, volume_mode, volume_size.execute(), stopLoss.stopLossPips, lookup_trades, multiply_loss.execute(), multiply_profit.execute(), add_loss.execute(), add_profit.execute(), reset_loss.execute(), reset_profit.execute(), loss_coef_string, profit_coef_string);
		debug("SellPending lots : " + (string)lots);

		long ticket = createSellPendingOrder(this.symbol, lots, stopLoss.stopLossLevel, takeProfit.takeProfitLevel, price, isOcoEnabled, EXPERT_MAGIC + groupId, expiration.calculateExpiration(), slippage.execute());
		if (ticket == -1) {
            error("Couldn't create Sell Pending order!");
            return;
		}
		debug("SellPending ticket : " + (string)ticket);

        CopyObjects(nextBlocks, this.nextBlocks);
   }

};

//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Sell later block functions                                         |
//+------------------------------------------------------------------+

long createSellPendingOrder(
	string symbol,
	double lots,
	double stopLoss,
	double takeProfit,
	double price,
	bool isOcoEnabled,
	int magicNumber,
	datetime expiration,
	int slippage
	)
{
   double bid = SymbolInfoDouble(symbol,SYMBOL_BID);
	ENUM_ORDER_TYPE type = 0;

	     if (price == bid) {type = ORDER_TYPE_SELL;}
	else if (price < bid)  {type = ORDER_TYPE_SELL_STOP;}
	else if (price > bid)  {type = ORDER_TYPE_SELL_LIMIT;}

	return createOrder(
		symbol,
		type,
		lots,
		SYMBOL_BID,
		stopLoss,
		takeProfit,
		"Sell later comment",
		magicNumber,
		expiration,
		slippage,
		price,
		isOcoEnabled
	);
}

//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Once per tick block classes                                      |
//+------------------------------------------------------------------+
struct OncePerTickBlockParams: BlockParameters {
};
class OncePerTickBlock: public Block {
private:
   datetime prevDatetime;
   double prevAsk;
   double prevBid;

public:
   OncePerTickBlock(const OncePerTickBlockParams& params) {
      this.index = params.index;
      ParseStringToIntArray(this.nextBlocks, params.nextBlocks);
   }

   void execute(int& nextBlocks[]) {
      debug("Executing OncePerTickBlock");
      string symbol = Symbol();
      datetime curDatetime = (datetime)SymbolInfoInteger(symbol, SYMBOL_TIME);
      double curAsk = SymbolInfoDouble(symbol, SYMBOL_ASK);
		double curBid = SymbolInfoDouble(symbol, SYMBOL_BID);


      if (
         curDatetime != prevDatetime ||
         curAsk != prevAsk ||
         curBid != prevBid
      ) {
			prevDatetime = curDatetime;
			prevAsk = curAsk;
			prevBid = curBid;

			CopyObjects(nextBlocks, this.nextBlocks);
		} else {
		    int res[] = { -1 };
		    CopyObjects(nextBlocks, res);
		}
   }

};

//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Once per bar block classes                                       |
//+------------------------------------------------------------------+

class SymbolBarContext {
private:
    string symbol;
    datetime time;
    int passes;
    int maxPasses;
public:
    string getSymbol() {
        return symbol;
    }

    SymbolBarContext(string symbol, int maxPasses) : symbol(symbol), time(0), passes(0), maxPasses(maxPasses) {
        if (maxPasses <= 0) {
            //TODO verify 0 max passes
            warn("OncePerBar maximum passes field has to be more than 0");
            ExpertRemove();
        }
    }

    bool update(ENUM_TIMEFRAMES period) {
        datetime freshTime = iTime(symbol, period, 1);
        if (freshTime == 0) {
            warn("Once per bar: failed to fetch the opening time of the bar for symbol: " + symbol);
            error("Once per bar: last error: " + GetLastError());
            return false;
        }

        if (freshTime > time) {
            passes++;
            if (passes == maxPasses) {
                time = freshTime;
                passes = 0;
            }
            return true;
        }

        return false;
    }
};


struct OncePerBarBlockParams: BlockParameters {
    Value<ENUM_TIMEFRAMES> period;
    Value<int> maxPasses;
    string symbol;
};
class OncePerBarBlock : public Block {
private:
    CHashMap<string, SymbolBarContext *> symbolContexts;
    Value<int> maxPasses;
    Value<ENUM_TIMEFRAMES> period;
    string symbol;
public:
    OncePerBarBlock(const OncePerBarBlockParams& params) {
        this.maxPasses = params.maxPasses;
        this.period = params.period;
        this.index = params.index;
        this.symbol = params.symbol;
        ParseStringToIntArray(this.nextBlocks, params.nextBlocks);
    }

    void execute(int& nextBlocks[]) {
        debug("Executing OncePerBar Block", ONC_PR_BR_TYPE);
        string symbol = Symbol();
        SymbolBarContext* context;

        if (!symbolContexts.TryGetValue(this.symbol, context)) {
            context = new SymbolBarContext(this.symbol, maxPasses.execute());
            symbolContexts.Add(this.symbol, context);
        }

        if (context.update(period.execute())) {
            CopyObjects(nextBlocks, this.nextBlocks);
        } else {
            int res[] = { -1 };
            CopyObjects(nextBlocks, res);
        }
    }
};

//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Spread filter block classes                                      |
//+------------------------------------------------------------------+
struct SpreadFilterBlockParams: BlockParameters {
	string compareOperator;
	string spreadMode;
	Value<double> maxSpreadValue;
	Value<int> spreadPeriodSeconds;
	Value<double> spreadAdjust;
	string falseBlocks;
};

class SpreadFilterBlock: public Block {
private:
	string compareOperator;
	string spreadMode;
	Value<double> maxSpreadValue;
	Value<int> spreadPeriodSeconds;
	Value<double> spreadAdjust;
	int left_next_block[];
	int right_next_block[];

	datetime datetimeData[];
	double spreadValuesData[];
	int currentPosition;
	int maxDepth;

public:

   SpreadFilterBlock(const SpreadFilterBlockParams& params) {
      this.compareOperator = params.compareOperator;
      this.spreadMode = params.spreadMode;
      this.maxSpreadValue = params.maxSpreadValue;
      this.spreadPeriodSeconds = params.spreadPeriodSeconds;
      this.spreadAdjust = params.spreadAdjust;
      ParseStringToIntArray(this.left_next_block, params.nextBlocks);
      ParseStringToIntArray(this.right_next_block, params.falseBlocks);

      this.currentPosition = -1;
      this.maxDepth = 50;
   }

   void execute(int& nextBlocks[]) {
      string symbol = Symbol();
      double curAsk = SymbolInfoDouble(symbol, SYMBOL_ASK);
		double curBid = SymbolInfoDouble(symbol, SYMBOL_BID);
		double currentSpread = curAsk - curBid;
		double spreadValueToCompare = 0;

		if (spreadMode == "fixed") {
		   spreadValueToCompare = getDigits(maxSpreadValue.execute(), symbol);
		} else if (spreadMode == "average") {
			datetime timeCurrent = TimeCurrent();
			int newArraySize = ArraySize(datetimeData);

			if (newArraySize < maxDepth * 2) {
				int cleanPos = newArraySize;
				newArraySize = maxDepth * 2;

				ArrayResize(datetimeData, newArraySize);
				ArrayResize(spreadValuesData, newArraySize);
				ArrayFill(datetimeData, cleanPos, newArraySize-cleanPos, 0);
				ArrayFill(spreadValuesData, cleanPos, newArraySize-cleanPos, 0);
			}

			currentPosition++;
			if (currentPosition >= newArraySize) {
				currentPosition = 0;
			}

			datetimeData[currentPosition] = timeCurrent;
			spreadValuesData[currentPosition] = customNormalizeDouble(currentSpread);

			double averageSpreadCalculated = 0;
			int spreadCountCalculated = 0;
			int cycleItemPosition = currentPosition + 1;

			while(!IsStopped())
			{
				cycleItemPosition--;
				if (cycleItemPosition < 0) {
					cycleItemPosition = newArraySize - 1;
				}

				int oldestPos = currentPosition + 1;
				if (oldestPos >= newArraySize) {
					oldestPos = newArraySize - 1;
				}

				if (datetimeData[cycleItemPosition] == 0) {
					if (cycleItemPosition == oldestPos) {
						break;
					} else {
						continue;
					}
				}

				if (datetimeData[cycleItemPosition] < timeCurrent - spreadPeriodSeconds.execute()) {
					break;
				}

				spreadCountCalculated++;
				averageSpreadCalculated += spreadValuesData[cycleItemPosition];

				if (cycleItemPosition == oldestPos) {
					datetime oldestAvailableTime = timeCurrent - datetimeData[cycleItemPosition];
					if (oldestAvailableTime == 0) {
						break;
					}
					spreadCountCalculated = spreadCountCalculated * (int)(spreadPeriodSeconds.execute() / oldestAvailableTime);
					break;
				}
			}

			if (spreadCountCalculated > maxDepth) {
				maxDepth = spreadCountCalculated;
			}

			spreadValueToCompare = calculateComparingSpreadValue(averageSpreadCalculated, spreadCountCalculated, currentSpread, symbol);
		} else {
            error("Unknown spread mode: " + spreadMode);
            return;
		}

		if (CompareValues(
			customNormalizeDouble(currentSpread),
			customNormalizeDouble(spreadValueToCompare),
			compareOperator)
		) {
			CopyObjects(nextBlocks, left_next_block);
		} else {
			CopyObjects(nextBlocks, right_next_block);
		}
   }

private:
    double calculateComparingSpreadValue(double averageSpreadCalculated, int spreadCountCalculated, double currentSpread, string symbol) {
        averageSpreadCalculated = (spreadCountCalculated > 0) ? averageSpreadCalculated / spreadCountCalculated : currentSpread;
        double averageSpreadCalculatedNormilized = customNormalizeDouble(averageSpreadCalculated);
        return averageSpreadCalculatedNormilized + getDigits(spreadAdjust.execute(), symbol);
    }

};

//+------------------------------------------------------------------+
//| Check News block classes                                         |
//| Injected once per EA via the NEWS_FILTER_CLASS placeholder below  |
//| (NewsFilter core + CheckNewsBlock). Absent when the strategy has  |
//| no Check News block, so the generated EA never references an      |
//| undefined symbol and always compiles.                             |
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+

struct FlagBlockParams: BlockParameters {
    Value<bool> flagVal;
};
class FlagBlock: public Block {
private:
    Value<bool> flagVal;
public:
    FlagBlock(const FlagBlockParams& params) {
        this.flagVal = params.flagVal;
        ParseStringToIntArray(this.nextBlocks, params.nextBlocks);
    }

    void execute(int& nextBlocks[]) {
        debug("Executing flagBlock");
        if (flagVal.execute() == true) {
	        CopyObjects(nextBlocks, this.nextBlocks);
	    }
   }
};

//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Time filter block classes                                        |
//+------------------------------------------------------------------+
struct TimeFilterBlockParams: BlockParameters {
   string sourceTime;
   Value<datetime> timeStart;
   Value<datetime> timeEnd;
   string selectedMonthsStr;
   string selectedWeekdaysStr;
   string selectedDaysStr;
   string falseBlocks;
};

class TimeFilterBlock: public Block {
private:
   string sourceTime;
   Value<datetime> timeStart;
   Value<datetime> timeEnd;
   int selectedMonths[];
   int selectedWeekdays[];
   int selectedDays[];
   int left_next_block[];
   int right_next_block[];

   datetime lastExecutedDateTime;

public:

   TimeFilterBlock(const TimeFilterBlockParams& params) {
      this.sourceTime = params.sourceTime;
      this.timeStart = params.timeStart;
      this.timeEnd = params.timeEnd;
      ParseStringToIntArray(this.selectedMonths, params.selectedMonthsStr);
      ParseStringToIntArray(this.selectedWeekdays, params.selectedWeekdaysStr);
      ParseStringToIntArray(this.selectedDays, params.selectedDaysStr);
      ParseStringToIntArray(this.left_next_block, params.nextBlocks);
      ParseStringToIntArray(this.right_next_block, params.falseBlocks);
      this.index = params.index;
      this.lastExecutedDateTime = 0;
   }

   void execute(int& nextBlocks[]) {
   	datetime currentDateTime = 0;

      if (sourceTime == "server") {
         currentDateTime = TimeCurrent();
      } else if (sourceTime == "local") {
         currentDateTime = TimeLocal();
      } else if (sourceTime == "utc") {
         currentDateTime = TimeGMT();
      } else {
         error("Unexpected source time: " + sourceTime);
         return;
      }

      if (checkIsInInterval(currentDateTime)) {
         lastExecutedDateTime = currentDateTime;
         CopyObjects(nextBlocks, left_next_block);
      } else {
         CopyObjects(nextBlocks, right_next_block);
      }
   }

private:

   bool checkIsInInterval(datetime currentDateTime) {
      MqlDateTime currentDateTimeStruct;
      TimeToStruct(currentDateTime, currentDateTimeStruct);

      if (ArraySize(selectedMonths) != 0) {
         if (contains(selectedMonths, currentDateTimeStruct.mon) == -1) {
            return false;
         }
      }

      if (ArraySize(selectedWeekdays) != 0) {
         if (contains(selectedWeekdays, currentDateTimeStruct.day_of_week) == -1) {
            return false;
         }
      }

      if (ArraySize(selectedDays) != 0) {
         if (contains(selectedDays, currentDateTimeStruct.day) == -1) {
            return false;
         }
      }

      datetime startDateTime = StringToTime(
         currentDateTimeStruct.year + "." + currentDateTimeStruct.mon + "." + currentDateTimeStruct.day + " " + timeStart.execute()
      );
      datetime endDateTime = StringToTime(
         currentDateTimeStruct.year + "." + currentDateTimeStruct.mon + "." + currentDateTimeStruct.day + " " + timeEnd.execute()
      );

      if (startDateTime >= endDateTime) {
         return currentDateTime <= endDateTime || currentDateTime >= startDateTime;
      }

      return currentDateTime >= startDateTime && currentDateTime <= endDateTime;
   }

};

class TimeFilterBlockCached: public Block {
private:
   string sourceTime;
   Value<datetime> timeStart;
   Value<datetime> timeEnd;
   int selectedMonths[];
   int selectedWeekdays[];
   int selectedDays[];
   int left_next_block[];
   int right_next_block[];

   datetime lastExecutedDateTime;
   int      cacheDayKey;
   datetime cachedStart;
   datetime cachedEnd;

public:

   TimeFilterBlockCached(const TimeFilterBlockParams& params) {
      this.sourceTime = params.sourceTime;
      this.timeStart = params.timeStart;
      this.timeEnd = params.timeEnd;
      ParseStringToIntArray(this.selectedMonths, params.selectedMonthsStr);
      ParseStringToIntArray(this.selectedWeekdays, params.selectedWeekdaysStr);
      ParseStringToIntArray(this.selectedDays, params.selectedDaysStr);
      ParseStringToIntArray(this.left_next_block, params.nextBlocks);
      ParseStringToIntArray(this.right_next_block, params.falseBlocks);
      this.index = params.index;
      this.lastExecutedDateTime = 0;
      this.cacheDayKey = -1;
   }

   void execute(int& nextBlocks[]) {
      datetime currentDateTime = 0;

      if (sourceTime == "server") {
         currentDateTime = TimeCurrent();
      } else if (sourceTime == "local") {
         currentDateTime = TimeLocal();
      } else if (sourceTime == "utc") {
         currentDateTime = TimeGMT();
      } else {
         error("Unexpected source time: " + sourceTime);
         return;
      }

      if (checkIsInInterval(currentDateTime)) {
         lastExecutedDateTime = currentDateTime;
         CopyObjects(nextBlocks, left_next_block);
      } else {
         CopyObjects(nextBlocks, right_next_block);
      }
   }

private:

   bool checkIsInInterval(datetime currentDateTime) {
      MqlDateTime currentDateTimeStruct;
      TimeToStruct(currentDateTime, currentDateTimeStruct);

      if (ArraySize(selectedMonths) != 0) {
         if (contains(selectedMonths, currentDateTimeStruct.mon) == -1) {
            return false;
         }
      }

      if (ArraySize(selectedWeekdays) != 0) {
         if (contains(selectedWeekdays, currentDateTimeStruct.day_of_week) == -1) {
            return false;
         }
      }

      if (ArraySize(selectedDays) != 0) {
         if (contains(selectedDays, currentDateTimeStruct.day) == -1) {
            return false;
         }
      }

      int dayKey = currentDateTimeStruct.year * 10000 + currentDateTimeStruct.mon * 100 + currentDateTimeStruct.day;
      if (dayKey != cacheDayKey) {
         cachedStart = StringToTime(
            currentDateTimeStruct.year + "." + currentDateTimeStruct.mon + "." + currentDateTimeStruct.day + " " + timeStart.execute()
         );
         cachedEnd = StringToTime(
            currentDateTimeStruct.year + "." + currentDateTimeStruct.mon + "." + currentDateTimeStruct.day + " " + timeEnd.execute()
         );
         cacheDayKey = dayKey;
      }
      datetime startDateTime = cachedStart;
      datetime endDateTime = cachedEnd;

      if (startDateTime >= endDateTime) {
         return currentDateTime <= endDateTime || currentDateTime >= startDateTime;
      }

      return currentDateTime >= startDateTime && currentDateTime <= endDateTime;
   }

};
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Check trade and order count block classes                        |
//+------------------------------------------------------------------+
struct CheckTradeAndOrderCountBlockParams: BlockParameters {
   string tradeOperator;
   string orderOperator;
   Value<int> tradeCount;
   Value<int> orderCount;
   string falseBlocks;
   string symbolsStr;
   string groupIdsStr;
   SELECT_TRADE_DIRECTION_TYPE tradeDirection;
};

class CheckTradeAndOrderCountBlock: public Block {
private:
   string tradeOperator;
   string orderOperator;
   Value<int> tradeCount;
   Value<int> orderCount;
   int left_next_block[];
   int right_next_block[];
   string symbols[];
   int groupIds[];
   SELECT_TRADE_DIRECTION_TYPE tradeDirection;

public:

   CheckTradeAndOrderCountBlock(const CheckTradeAndOrderCountBlockParams& params) {
      this.tradeOperator = params.tradeOperator;
      this.orderOperator = params.orderOperator;
      this.tradeCount = params.tradeCount;
      this.orderCount = params.orderCount;
      this.tradeDirection = params.tradeDirection;
      ParseStringToIntArray(this.left_next_block, params.nextBlocks);
      ParseStringToIntArray(this.right_next_block, params.falseBlocks);
      ParseStringToStringArray(this.symbols, params.symbolsStr);
      ParseStringToIntArray(this.groupIds, params.groupIdsStr);
      this.index = params.index;
   }

   void execute(int& nextBlocks[]) {
      debug("Executing CheckTradeAndOrderCountBlock");
      bool checkTradeResult = checkTradeCount();
      bool checkOrderResult = checkOrderCount();

      if (checkTradeResult && checkOrderResult) {
         CopyObjects(nextBlocks, left_next_block);
      } else {
         CopyObjects(nextBlocks, right_next_block);
      }
   }

private:

   bool checkTradeCount() {
      int count = 0;

      for (int index = 0; index < PositionsTotal(); index++) {
         ulong ticket = PositionGetTicket(index);
         if (ticket == 0) {
            warn("Could not get position ticket by index: " + index + " when checking trade count");
            continue;
         }
         bool success = PositionSelectByTicket(ticket);
         if (!success) {
            warn("Position is unavailable by ticket: " + ticket + " when checking trade count");
            checkError("Check trade count");
            continue;
         }

         if (ArraySize(this.symbols) > 0) {
            string ticketSymbol = PositionGetString(POSITION_SYMBOL);
            if (checkTicketSymbol(ticketSymbol) == false) {
               continue;
            }
         }

         int ticketMagicNumber = PositionGetInteger(POSITION_MAGIC);
         if (checkTicketGroup(ticketMagicNumber) == false) {
            continue;
         }

         ENUM_DEAL_TYPE positionType = PositionGetInteger(POSITION_TYPE);
         SELECT_TRADE_DIRECTION_TYPE ticketTradeDirection = -1;
         if (positionType == POSITION_TYPE_BUY) {
            ticketTradeDirection = BUYS_ONLY;
         } else if (positionType == POSITION_TYPE_SELL) {
            ticketTradeDirection = SELLS_ONLY;
         }
         if (checkTicketDirection(ticketTradeDirection) == false) {
            continue;
         }

         count++;
      }
      debug("Check trade count got " + count + " trades");
      return CompareValues(count, tradeCount.execute(), tradeOperator);
   }

   bool checkOrderCount() {
      int count = 0;

      for (int index = 0; index < OrdersTotal(); index++) {
         ulong ticket = OrderGetTicket(index);
         if (ticket == 0) {
            warn("Could not get order ticket by index: " + index + " when checking order count");
            continue;
         }
         bool success = OrderSelect(ticket);
         if (!success) {
            warn("Order is unavailable by ticket: " + ticket + " when checking order count");
            checkError("Check order count");
            continue;
         }

         if (ArraySize(this.symbols) > 0) {
            string ticketSymbol = OrderGetString(ORDER_SYMBOL);
            if (checkTicketSymbol(ticketSymbol) == false) {
               continue;
            }
         }

         int ticketMagicNumber = OrderGetInteger(ORDER_MAGIC);
         if (checkTicketGroup(ticketMagicNumber) == false) {
            continue;
         }

         ENUM_DEAL_TYPE orderType = OrderGetInteger(ORDER_TYPE);
         SELECT_TRADE_DIRECTION_TYPE ticketTradeDirection = -1;
         if (orderType == ORDER_TYPE_BUY || orderType == ORDER_TYPE_BUY_LIMIT || orderType == ORDER_TYPE_BUY_STOP) {
            ticketTradeDirection = BUYS_ONLY;
         } else if (orderType == ORDER_TYPE_SELL || orderType == ORDER_TYPE_SELL_LIMIT || orderType == ORDER_TYPE_SELL_STOP) {
            ticketTradeDirection = SELLS_ONLY;
         }
         if (checkTicketDirection(ticketTradeDirection) == false) {
            continue;
         }

         count++;
      }
      debug("Check order count got " + count + " orders");
      return CompareValues(count, orderCount.execute(), orderOperator);
   }

   bool checkTicketSymbol(string ticketSymbol) {
      if (contains(this.symbols, ticketSymbol) == -1) {
         debug("Not suitable symbol in check trade/order count, ticket got " + ticketSymbol + ", expected " + stringArrayToString(this.symbols));
         return false;
      }
      return true;
   }

   bool checkTicketGroup(int ticketMagicNumber) {
      if (ArraySize(this.groupIds) > 0) {
         if (contains(this.groupIds, ticketMagicNumber - EXPERT_MAGIC) == -1) {
            debug("Not suitable group in check trade/order count, ticket got " + (ticketMagicNumber - EXPERT_MAGIC) + ", expected " + intArrayToString(this.groupIds));
            return false;
         }
         return true;
      } else {
         if (ticketMagicNumber != EXPERT_MAGIC) {
            debug("Not suitable magic number in check trade/order count, ticket got " + ticketMagicNumber + ", expected " + EXPERT_MAGIC);
            return false;
         }
         return true;
      }
   }

   bool checkTicketDirection(SELECT_TRADE_DIRECTION_TYPE ticketTradeDirection) {
      if (ticketTradeDirection == -1 ||
      (ticketTradeDirection != this.tradeDirection && this.tradeDirection != BUYS_AND_SELLS)) {
         debug("Not suitable trade direction in check trade/order count, ticket got " + ticketTradeDirection + ", expected " + this.tradeDirection);
         return false;
      }
      return true;
   }

};
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Common functions                                                 |
//+------------------------------------------------------------------+
template <typename T>
void CopyObjects(T& arr1[], T& arr2[])
{
   ArrayResize(arr1, ArraySize(arr2));
   for (int i = 0; i < ArraySize(arr2); i++) {
      arr1[i] = arr2[i];
   }
}

void ParseStringToIntArray(int& arr[], string str)
{
   string strs[];
   StringSplit(str, ',', strs);
   ArrayResize(arr, ArraySize(strs));
   for (int i = 0; i < ArraySize(strs); i++) {
      arr[i] = StringToInteger(strs[i]);
   }
   ArrayFree(strs);
}

void ParseStringToStringArray(string& arr[], string str)
{
   string strs[];
   StringSplit(str, ',', strs);
   ArrayResize(arr, ArraySize(strs));
   for (int i = 0; i < ArraySize(strs); i++) {
      arr[i] = strs[i];
   }
   ArrayFree(strs);
}

string longArrayToString(long& array[]) {
   string str;
   for (int i = 0; i < ArraySize(array); i++) {
      if (i != 0) {
         str = str + ",";
      }
      str = str + array[i];
   }
   return str;
}

string intArrayToString(int& array[]) {
   string str;
   for (int i = 0; i < ArraySize(array); i++) {
      str = str + array[i];
   }
   return str;
}

string stringArrayToString(string& array[]) {
   string str;
   for (int i = 0; i < ArraySize(array); i++) {
      str = str + array[i];
   }
   return str;
}

template<typename T1, typename T2>
bool CompareValues(T1& left, T2& right, string compare_operator, char left_adjust_operation, double left_adjust_value, char right_adjust_operation, double right_adjust_value)
{
   if (compare_operator == "x>" || compare_operator == "x<") {
      return processCrossoverOperator(left, right, compare_operator, left_adjust_operation, left_adjust_value, right_adjust_operation, right_adjust_value);
   } else {
      double left_value = adjustValue(left.execute(), left_adjust_operation, left_adjust_value);
	  double right_value = adjustValue(right.execute(), right_adjust_operation, right_adjust_value);
	  if (DEBUG) {
	    PrintFormat("Comparing values [%s=%.6f] %s [%s=%.6f]", typename(left), left_value, compare_operator, typename(right), right_value);
	  }
      return CompareValues(left_value, right_value, compare_operator);
   }

   error("Unknown compare operator: " + compare_operator);
   return false;
}

bool CompareValues(double left, double right, string compare_operator)
{
   if (compare_operator == ">")        return(left > right);
   else if (compare_operator == "<")   return(left < right);
   else if (compare_operator == ">=")  return(left >= right);
   else if (compare_operator == "<=")  return(left <= right);
   else if (compare_operator == "==")  return(left == right);
   else if (compare_operator == "!=")  return(left != right);

   error("Unknown compare operator: " + compare_operator);
	return false;
}

template<typename T1, typename T2>
bool processCrossoverOperator(T1& left, T2& right, string compare_operator, char left_adjust_operation, double left_adjust_value, char right_adjust_operation, double right_adjust_value) {
    debug("processCrossoverOperator");
    double leftBuffer[2];
    double rightBuffer[2];
    ArraySetAsSeries(leftBuffer, true);
    ArraySetAsSeries(rightBuffer, true);

    int elementCount = getBuffer(left, leftBuffer);
    if (elementCount != 2) {
        error("Not enough data for left indicator");
        return false;
    }

    elementCount = getBuffer(right, rightBuffer);
    if (elementCount != 2) {
        error("Not enough data for right indicator");
        return false;
    }

    bool adjustResultFirst;
    bool adjustResultSecond;
    bool adjustResult;
    if (compare_operator == "x>") {
      adjustResultFirst = adjustValue(leftBuffer[0], left_adjust_operation, left_adjust_value) <= adjustValue(rightBuffer[0], right_adjust_operation, right_adjust_value);
      adjustResultSecond = adjustValue(leftBuffer[1], left_adjust_operation, left_adjust_value) >  adjustValue(rightBuffer[1], right_adjust_operation, right_adjust_value);
      adjustResult = (adjustResultFirst && adjustResultSecond);
    } else if (compare_operator == "x<") {
      adjustResultFirst = adjustValue(leftBuffer[0], left_adjust_operation, left_adjust_value) >  adjustValue(rightBuffer[0], right_adjust_operation, right_adjust_value);
      adjustResultSecond = adjustValue(leftBuffer[1], left_adjust_operation, left_adjust_value) <= adjustValue(rightBuffer[1], right_adjust_operation, right_adjust_value);
      adjustResult = (adjustResultFirst && adjustResultSecond);
    } else {
        error("Not defined crossover operator: " + compare_operator);
        adjustResult = false;
    }

    ArrayFree(leftBuffer);
    ArrayFree(rightBuffer);
    return adjustResult;
}

template<typename T>
int getBuffer(T& item, double &buffer[]) {
   if (CheckPointer(dynamic_cast<IndicatorBlock_Base*>(&item)) != POINTER_INVALID) {
      IndicatorBlock_Base* indicator = dynamic_cast<IndicatorBlock_Base*>(&item);
      indicator.createHandle();
      int elementCount = CopyBuffer(indicator.handle, 0, 0, 2, buffer);
      if (elementCount == -1 && BarsCalculated(indicator.handle) < 0) {
         warn("Indicator not calculated in history yet");
         buffer[0] = 0;
         buffer[1] = 0;
         return 2;
      }
      return elementCount;
   } else if (CheckPointer(dynamic_cast<Candle*>(&item)) != POINTER_INVALID) {
      Candle* candle = dynamic_cast<Candle*>(&item);
      return candle.executeBuffered(2, buffer);
   } else if (CheckPointer(dynamic_cast<MarketPropertiesAskBidMid*>(&item)) != POINTER_INVALID) {
      MarketPropertiesAskBidMid* marketProperty = dynamic_cast<MarketPropertiesAskBidMid*>(&item);
      buffer[0] = marketProperty.execute();
      buffer[1] = marketProperty.execute(1);
      if (buffer[0] == 0) {
         return 0;
      }
      if (buffer[1] == 0) {
         return 1;
      }
      return 2;
   } else {
      warn("Not suitable crossover operator!");
      double value = item.execute();
      buffer[0] = value;
      buffer[1] = value;
      return 2;
   }
}

double adjustValue(double value, char adjust_operation, double adjust_value) {
   switch (adjust_operation) {
      case '+': value += adjust_value; break;
      case '-': value -= adjust_value; break;
      case '*': value *= adjust_value; break;
      case '/': value /= adjust_value; break;
   }
   return value;
}

template <typename Base, typename Derived>
bool IsInstance(Base *obj) {
    return CheckPointer(dynamic_cast<Derived*>(obj)) != POINTER_INVALID;
}

template<typename T> int contains(const T& arr[], T searchValue){
   for (int i = 0; i < ArraySize(arr); i++) {
      if (arr[i] == searchValue) {
         return i;
      }
   }
   return -1;
}

long createOrder(
	string   symbol                        = "",
	int      type                          = ORDER_TYPE_BUY,
	double   lots                          = 0,
	ENUM_SYMBOL_INFO_DOUBLE priceInfoType  = SYMBOL_ASK,
	double   stopLoss                      = 0,
	double   takeProfit                    = 0,
	string   comment                       = NULL,
	int      magicNumber                   = 0,
	datetime expiration                    = 0,
	int      slippage                      = 0,
	double   price                         = 0,   //For pending orders only
	bool     isOcoEnabled                  = false   //For pending orders only
) {
    debug("createOrder");
    clearError();
    MqlTradeRequest request;
	MqlTradeResult result;
	MqlTradeCheckResult check_result;
	ZeroMemory(request);
	ZeroMemory(result);
	ZeroMemory(check_result);

    double resultPrice = price;
    if (resultPrice == 0) {
       resultPrice = customNormalizeDouble(SymbolInfoDouble(symbol, priceInfoType));
    }
    ENUM_TRADE_REQUEST_ACTIONS action = (type > ORDER_TYPE_SELL) ? TRADE_ACTION_PENDING : TRADE_ACTION_DEAL;

	request.action       = action;
	request.symbol       = symbol;
	request.type         = type;
	request.volume       = calculateLots(symbol, lots);
	request.price        = resultPrice;
	request.sl           = customNormalizeDouble(stopLoss);
	request.tp           = customNormalizeDouble(takeProfit);
	request.comment      = comment;
	request.magic        = magicNumber;
	request.type_filling = calculateFillingType(symbol);
	request.type_time    = calculateOrderTypeTime(expiration);
	request.expiration   = expiration;

	if (!OrderCheck(request, check_result))
	{
		error("OrderCheck() failed for operation: " + type + " - " + (string)check_result.comment + " (" + (string)check_result.retcode + ")");
		printOrderRequestInfo(request);
		printOrderCheckInfo(check_result);
		checkError("Check order for creation");
		return -1;
	}

	printOrderRequestInfo(request);
	bool success = OrderSend(request, result);

	if (success) {
	   info("OrderSend() succeed, order id: " + result.order + " - " + (string)result.comment + " (" + (string)result.retcode + ")");
	   printOrderResultInfo(result);
	} else {
	   error("OrderSend() failed for operation: " + type + " - " + (string)result.comment + " (" + (string)result.retcode + ")");
	   printOrderResultInfo(result);
	   checkError("Send order for creation");
	   return -1;
	}

    if (isOcoEnabled) {

        stopLoss = (stopLoss > 0) ? customNormalizeDouble(MathAbs(resultPrice-stopLoss)) : 0;
        takeProfit = (takeProfit > 0) ? customNormalizeDouble(MathAbs(resultPrice-takeProfit)) : 0;

        double ask = SymbolInfoDouble(symbol, SYMBOL_ASK);
        double bid = SymbolInfoDouble(symbol, SYMBOL_BID);

        int typeOco;
        if (type == ORDER_TYPE_BUY_STOP) {
            typeOco = ORDER_TYPE_SELL_STOP;
            resultPrice = bid - MathAbs(resultPrice - ask);
        } else if (type == ORDER_TYPE_BUY_LIMIT) {
            typeOco = ORDER_TYPE_SELL_LIMIT;
            resultPrice = bid + MathAbs(resultPrice - ask);
        } else if (type== ORDER_TYPE_SELL_STOP) {
            typeOco = ORDER_TYPE_BUY_STOP;
            resultPrice = ask + MathAbs(resultPrice - bid);
        } else if (type == ORDER_TYPE_SELL_LIMIT) {
            typeOco = ORDER_TYPE_BUY_LIMIT;
            resultPrice = ask - MathAbs(resultPrice - bid);
        } else {
            typeOco = type;
        }

        if (typeOco == ORDER_TYPE_BUY_STOP || typeOco == ORDER_TYPE_BUY_LIMIT) {
            stopLoss = (stopLoss > 0) ? resultPrice - stopLoss : 0;
            takeProfit = (takeProfit > 0) ? resultPrice + takeProfit : 0;
        } else {
            stopLoss = (stopLoss > 0) ? resultPrice + stopLoss : 0;
            takeProfit = (takeProfit > 0) ? resultPrice - takeProfit : 0;
        }

        ENUM_SYMBOL_INFO_DOUBLE priceInfoTypeOco;
		if (type == ORDER_TYPE_SELL || type == ORDER_TYPE_SELL_STOP || type == ORDER_TYPE_SELL_LIMIT) {
			priceInfoTypeOco = SYMBOL_BID;
		} else if (type == ORDER_TYPE_BUY || type == ORDER_TYPE_BUY_STOP || type == ORDER_TYPE_BUY_LIMIT) {
			priceInfoTypeOco = SYMBOL_ASK;
		}

        string comment = OCO_PREFIX + (string)result.order + OCO_POSTFIX;

        createOrder(
            symbol,
            typeOco,
            lots,
            priceInfoTypeOco,
            stopLoss,
            takeProfit,
            comment,
            magicNumber,
            expiration,
            slippage,
            resultPrice,
            false
        );
    }

    if (action == TRADE_ACTION_DEAL && expiration != 0) {
        ticketExpirations.TrySetValue(result.order, expiration);
    }

    checkError("Create order");
	return result.order;
}

double processVolumeMode(
   string symbol,
   string volumeMode,
   double volumeSize,
   double stopLossPips,
   LOOKUP_TRADES lookupTrades = RUNNING,
   double multiplyLoss = 0.0,
   double multiplyProfit = 0.0,
   double addLoss = 0.0,
   double addProfit = 0.0,
   int resetLoss = 0,
   int resetProfit = 0,
   string lossCoefString = "",
   string profitCoefString = ""
) {
   double resultSize=0;
   debug("processVolumeMode");
   debug(volumeMode);
   double tickValue=SymbolInfoDouble(symbol,SYMBOL_TRADE_TICK_VALUE);
   if (volumeMode == "fixed") {
      // Fixed no. of lots
      // volumeSize = no. of lots to buy
      resultSize = volumeSize;
   } else if (volumeMode == "balanceRisk") {
      // Risk % of balance
      // volumeSize = % of balance to risk (in %)
      resultSize = ( (volumeSize/100) * getAccountBalance() ) / ( stopLossPips * getPipValue(symbol) * tickValue);
   } else if (volumeMode == "equityRisk") {
      // Risk % of equity
      // volumeSize = % of equity to risk (in %)
      resultSize = ( (volumeSize/100) * getAccountEquity() ) / ( stopLossPips * getPipValue(symbol) * tickValue );
   }
   else if (volumeMode == "fixedRisk") {
      // Risk fixed amount of money
      // volumeSize = money to risk (in base account currency)
      resultSize = volumeSize / ( stopLossPips * getPipValue(symbol) * tickValue );
   } else if (volumeMode == "martingale") {
      resultSize = processMartingale(symbol, volumeSize, lookupTrades, multiplyLoss, multiplyProfit, addLoss, addProfit, resetLoss, resetProfit);
   } else if (volumeMode == "sequence") {
      resultSize = processCustomSequence(symbol, volumeSize, lookupTrades, lossCoefString, profitCoefString);
   }
   debug("processVolumeMode(), volumeMode: " + volumeMode + ", volumeSize: " + volumeSize + ", stopLossPips: " + stopLossPips + ", resultSize: " + resultSize);
   return resultSize;
}

double processMartingale(
    string symbol,
    double volumeSize,
    LOOKUP_TRADES lookupTrades,
    double multiplyLoss,
    double multiplyProfit,
    double addLoss,
    double addProfit,
    int resetLoss,
    int resetProfit
) {
   debug("processMartingale");
   double lots = 0.0;

   bool isHistory = lookupTrades == HISTORY;
   int total = 0;
   int seqLen = 0;
   double profit = 0.0;

   if (!isHistory) {
      total = PositionsTotal();
      if (total > 0) {
         ulong ticket = PositionGetTicket(total-1);
         PositionSelectByTicket(ticket);
         lots = PositionGetDouble(POSITION_VOLUME);

         profit = getPositionClosePrice(ticket) - getPositionOpenPrice(ticket);
         seqLen = getSameSignRunningSequenceLenght(symbol, ticket, total, false);
      } else if (lookupTrades == RUNNING_HISTORY) {
         isHistory = true;
      }
   }
   if (isHistory) {
      HistorySelect(0,TimeCurrent());
      total = HistoryDealsTotal();
      if (total > 0) {
         ulong ticket = HistoryDealGetTicket(total-1);
         lots = HistoryDealGetDouble(ticket, DEAL_VOLUME);

         profit = getHistoryOrderClosePrice(ticket) - getHistoryOrderOpenPrice(ticket);
         seqLen = getSameSignHistorySequenceLenght(symbol, profit > 0.0, true);
      }
   }

   if (lots == 0.0) {
	   lots = volumeSize;
   } else {
		if (profit > 0.0) {
			if (resetProfit > 0 && seqLen >= resetProfit) {
				lots = volumeSize;
			}
			else {
				lots = (lots * multiplyProfit) + addProfit;
			}
		}
		else {
			if (resetLoss > 0 && seqLen >= resetLoss) {
				lots = volumeSize;
			} else {
				lots = (lots * multiplyLoss) + addLoss;
			}
		}
   }

   return lots;
}

int profPosition = 0;
int lossPosition = 0;

double processCustomSequence(string symbol, double volumeSize, LOOKUP_TRADES lookupTrades, string lossCoefString, string profitCoefString) {
    debug("processCustomSequence");
   double lots = 0.0;

   double lossCoefSeq[];
   double profitCoefSeq[];

   if (lossCoefString == "") {
      lossCoefString = "1";
   }
   if (profitCoefString == "") {
      profitCoefString = "1";
   }

   string lossCoefs[];
   lossCoefString.Split(',', lossCoefs);
   for (uint i = 0; i < lossCoefs.Size(); i++) {
      lossCoefs[i].TrimLeft();
      lossCoefs[i].TrimRight();
      string c = lossCoefs[i];
      lossCoefSeq.Push(StringToDouble(lossCoefs[i]));
   }

   string profitCoefs[];
   profitCoefString.Split(',', profitCoefs);
   for (uint i = 0; i < profitCoefs.Size(); i++) {
      profitCoefs[i].TrimLeft();
      profitCoefs[i].TrimRight();
      profitCoefSeq.Push(StringToDouble(profitCoefs[i]));
   }


   bool isHistory = lookupTrades == HISTORY;
   int total = 0;
   double profit = 0.0;


   if (!isHistory) {
      total = PositionsTotal();
      if (total != 0) {
         ulong ticket = PositionGetTicket(total);
         PositionSelectByTicket(ticket);

         profit = getPositionClosePrice(ticket) - getPositionOpenPrice(ticket);
   		if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL) {
   			profit = -1 * profit;
   		}
		}
		if (lookupTrades == RUNNING_HISTORY && profit == 0.0) {
		   isHistory = true;
		}
   }

   if (isHistory) {
      HistorySelect(0,TimeCurrent());
      total = HistoryDealsTotal();

      for (int i = 1; i <= total; i++) {
         ulong ticket = HistoryDealGetTicket(total-i);

         profit = getHistoryOrderClosePrice(ticket) - getHistoryOrderOpenPrice(ticket);
         if (HistoryDealGetInteger(ticket, DEAL_TYPE) == ORDER_TYPE_SELL) {
   			profit = -1 * profit;
   		}

		   if (profit != 0.0) {break;}
		}

   }

    if (profit == 0.0) {
	   lots = volumeSize;
	} else {
	    if (profit > 0.0) {
	        int profitPosition = profPosition;
           	profPosition++;
           	lossPosition = 0;
           	double profMult = profitCoefSeq[profitCoefSeq.Size()-1];
           	if (profitPosition < profitCoefSeq.Size()) {
           		profMult = profitCoefSeq[profitPosition];
           	}
           	lots = volumeSize * profMult;
        } else {
            int lossPosition = lossPosition;
           	lossPosition++;
           	profPosition = 0;
           	double lossMult = lossCoefSeq[lossCoefSeq.Size()-1];
           	if (lossPosition < lossCoefSeq.Size()) {
           		lossMult = lossCoefSeq[lossPosition];
           	}
           	lots = volumeSize * lossMult;
        }
	}

   ArrayFree(lossCoefSeq);
   ArrayFree(profitCoefSeq);
   ArrayFree(lossCoefs);
   return lots;
}

ENUM_ORDER_TYPE_FILLING calculateFillingType(string symbol) {
   int filling=(int)SymbolInfoInteger(symbol,SYMBOL_FILLING_MODE);

   if       (checkIsFillingTypeAllowed(symbol, SYMBOL_FILLING_FOK))  { return ORDER_FILLING_FOK; }
   else if  (checkIsFillingTypeAllowed(symbol, SYMBOL_FILLING_IOC))  { return ORDER_FILLING_IOC; }
   else                                                              { return ORDER_FILLING_RETURN; }
}

double calculateLots(string symbol, double lots) {
   double resultLots;
   double minLots = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MIN);
   double volumeStep = SymbolInfoDouble(symbol, SYMBOL_VOLUME_STEP);
   checkError("Lots calculating");

   double roundedLots = MathRound(lots / volumeStep) * volumeStep;
   debug("Calculate lots: " + lots + " has been rounded to " + roundedLots);
   if (roundedLots < minLots) {
      resultLots = minLots;
      warn("Calculate lots: " + roundedLots + " is less than minimal allowed volume for this pair, reset to " + minLots);
   } else {
      resultLots = roundedLots;
   }

   //Maybe there are some more calculations later
   return resultLots;
}

ENUM_ORDER_TYPE_TIME calculateOrderTypeTime(datetime expiration) {
   if (expiration == 0) {
      return ORDER_TIME_GTC;
   } else {
      return ORDER_TIME_SPECIFIED;
   }
}

double getAccountBalance() {
    // TODO: use customNormalizeDouble instead
	return NormalizeDouble(AccountInfoDouble(ACCOUNT_BALANCE), 2);
}

double getAccountEquity() {
	return AccountInfoDouble(ACCOUNT_EQUITY);
}

double getAccountFreeMargin() {
	return AccountInfoDouble(ACCOUNT_MARGIN_FREE);
}

double getTickValue(string symbol) {
   return SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_VALUE);
}

double getPipSize(string symbol) {
    return (getPipValue(symbol) * SymbolInfoDouble(symbol, SYMBOL_POINT));
}

double pipsToPrice(double pips, string symbol) {
    return pips * getPipSize(symbol);
}

double priceToPips(double price, string symbol) {
    return price / getPipSize(symbol);
}

double getPipValue(string symbol) {
   double symbolPoint = SymbolInfoDouble(symbol, SYMBOL_POINT);
   double customPoint = 0;
   if (customPointMap.ContainsKey(symbolPoint)) {
      customPointMap.TryGetValue(symbolPoint, customPoint);
   } else {
      warn("Couldn't find custom symbol point!");
      customPoint = symbolPoint;
   }
   return customPoint / symbolPoint;
}

double getDigits(double pips, string symbol)
{
	int digits = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);
	double point = SymbolInfoDouble(symbol, SYMBOL_POINT);

	return NormalizeDouble(pips * getPipValue(symbol) * point, digits);
}

double getPips(double digits, string symbol)
{
    return digits / (getPipValue(symbol) * SymbolInfoDouble(symbol, SYMBOL_POINT));
}

void checkError(string name) {
    int errorCode = GetLastError();
    if (errorCode > 0) {
        error("Got error code " + errorCode + " in " + name);
        ResetLastError();
    }
}

void clearError() {
    ResetLastError();
}

template<typename K, typename V>
void deleteOldMapValue(CHashMap<K, V*>& map, K key) {
   V* oldValue;
   if (map.TryGetValue(key, oldValue)) {
      delete oldValue;
      map.Remove(key);
   }
}

//+------------------------------------------------------------------+
//| Checks if the specified filling mode is allowed                  |
//+------------------------------------------------------------------+
bool checkIsFillingTypeAllowed(string symbol,int fill_type) {
//--- Obtain the value of the property that describes allowed filling modes
   int filling = (int) SymbolInfoInteger(symbol, SYMBOL_FILLING_MODE);
//--- Return true, if mode fill_type is allowed
   return ((filling & fill_type) == fill_type);
}

//+------------------------------------------------------------------+
//| According to discussions on forums - there are some problems     |
//| with original NormalizeDouble function                           |
//+------------------------------------------------------------------+
double customNormalizeDouble(const double value) {
   double tickSize = SymbolInfoDouble(Symbol(), SYMBOL_TRADE_TICK_SIZE);
   return (MathRound(value / tickSize) * tickSize );
}

int getSameSignRunningSequenceLenght(string symbol, ulong ticket, int total, bool lookupHistory) {
      debug("getSameSignRunningSequenceLenght");
      bool isProfit = true;
      int seqLen = 0;
      bool isStart = true;

      for (int pos = 0; pos < total; pos++) {
			ticket = PositionGetTicket(total - 1 - pos);
         PositionSelectByTicket(ticket);

         double profit = getPositionClosePrice(ticket) - getHistoryOrderOpenPrice(ticket);

			if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL) {
				profit = -1 * profit;
			}

			if (isStart) {
		      isProfit = profit > 0.0;
		      isStart = false;
		   }

			if ((isProfit && profit < 0.0) || (!isProfit && profit > 0.0)) {
				break;
			}
         seqLen++;

		}

   	if (lookupHistory) {
		 seqLen += getSameSignHistorySequenceLenght(symbol, isProfit, false);
	}

   return seqLen;
}

int getSameSignHistorySequenceLenght(string symbol, bool isProfit, bool isStart) {

   int seqLen = 0;

   HistorySelect(0,TimeCurrent());
   int total = HistoryDealsTotal();

   for (int i = 0; i < total; i++) {
      ulong ticket = HistoryDealGetTicket(total - 1 - i);

		//only out deals with sell/buy type
		ENUM_DEAL_ENTRY dealEntry = (ENUM_DEAL_ENTRY)HistoryDealGetInteger(ticket, DEAL_ENTRY);
		ENUM_DEAL_TYPE dealType = (ENUM_DEAL_TYPE)HistoryDealGetInteger(ticket, DEAL_TYPE);

		if (dealEntry != DEAL_ENTRY_OUT || (dealType != DEAL_TYPE_BUY && dealType != DEAL_TYPE_SELL)) {
		   continue;
		}

      double profit = getHistoryOrderClosePrice(ticket) - getHistoryOrderOpenPrice(ticket);

      if (HistoryDealGetInteger(ticket, DEAL_TYPE) == ORDER_TYPE_SELL) {
				profit = -1 * profit;
			}

		if (isStart) {
		   isProfit = profit > 0.0;
		   isStart = false;
		}

		if ((isProfit && profit < 0.0) || (!isProfit && profit > 0.0)) {
			break;
		}
      seqLen++;
   }
   return seqLen;
}

double getPositionClosePrice(ulong ticket) {
    debug("getPositionClosePrice");
   long tradeType = PositionGetInteger(POSITION_TYPE);

   if (tradeType == POSITION_TYPE_BUY) {
		return SymbolInfoDouble(PositionGetString(POSITION_SYMBOL), SYMBOL_BID);
	} else {
		return SymbolInfoDouble(PositionGetString(POSITION_SYMBOL), SYMBOL_ASK);
	}
}

double getPositionOpenPrice(ulong ticket) {
    debug("getPositionOpenPrice");
	return PositionGetDouble(POSITION_PRICE_OPEN);
}

double getHistoryOrderClosePrice(ulong ticket) {
      debug("getHistoryOrderClosePrice");
      HistorySelect(0,TimeCurrent());
		ENUM_DEAL_ENTRY dealEntry = (ENUM_DEAL_ENTRY)HistoryDealGetInteger(ticket, DEAL_ENTRY);
		long positionId = HistoryDealGetInteger(ticket, DEAL_POSITION_ID);
		double price = 0.0;

		HistorySelectByPosition(positionId);

		int total = HistoryDealsTotal();

		for (int i = 0; i < total; i++) {
			ulong inDealTicket = HistoryDealGetTicket(i);

			if (HistoryDealGetInteger(inDealTicket, DEAL_ENTRY) == DEAL_ENTRY_OUT) {
				price = HistoryDealGetDouble(inDealTicket, DEAL_PRICE);
			}
		}

		return price;
}

double getHistoryOrderOpenPrice(ulong ticket) {
    debug("getHistoryOrderOpenPrice");
   HistorySelect(0,TimeCurrent());
	ulong positionId = HistoryDealGetInteger(ticket, DEAL_POSITION_ID);
	HistorySelectByPosition(positionId);
	ulong firstTicket = HistoryDealGetTicket(0);

	return HistoryDealGetDouble(firstTicket, DEAL_PRICE);
}


void printOrderRequestInfo(MqlTradeRequest &request) {
	debug("OrderSend() request: " +
         "action: " +       request.action +
         ", magic: " +        request.magic +
         ", order: " +        request.order +
         ", symbol: " +       request.symbol +
         ", volume: " +       request.volume +
         ", price: " +        request.price +
         ", stoplimit: " +    request.stoplimit +
         ", sl: " +           request.sl +
         ", tp: " +           request.tp +
         ", deviation: " +    request.deviation +
         ", type: " +         request.type +
         ", type_filling: " + request.type_filling +
         ", type_time: " +    request.type_time +
         ", expiration: " +   request.expiration +
         ", comment: " +      request.comment +
         ", position: " +     request.position +
         ", position_by: " +  request.position_by +
      ")");
}

void printOrderCheckInfo(MqlTradeCheckResult &check_result) {
   debug("OrderCheck() check_result: " +
      "retcode: " +      check_result.retcode +
      ", balance: " +      check_result.balance +
      ", equity: " +       check_result.equity +
      ", profit: " +       check_result.profit +
      ", margin: " +       check_result.margin +
      ", margin_free: " +  check_result.margin_free +
      ", margin_level: " + check_result.margin_level +
      ", comment: " +      check_result.comment +
   ")");
}

void printOrderResultInfo(MqlTradeResult &result) {
   debug("OrderSend() result: " +
      "retcode: " +              result.retcode +
      ", deal: " +               result.deal +
      ", order: " +              result.order +
      ", volume: " +             result.volume +
      ", price: " +              result.price +
      ", bid: " +                result.bid +
      ", ask: " +                result.ask +
      ", comment: " +            result.comment +
      ", request_id: " +         result.request_id +
      ", retcode_external: " +   result.retcode_external +
   ")");
}

bool closeTrade(ulong ticket, string commentMessage) {

    clearError();

    double tradeVolumeFull;
    double tradeVolumeCurCycle;

    do {

        if (!PositionSelectByTicket(ticket)) {
            error("Couldn't select trade by ticket " + ticket + " while closing trade");
            return false;
        }

        string tradeSymbol = PositionGetString(POSITION_SYMBOL);
        long tradeMagicNumber = PositionGetInteger(POSITION_MAGIC);
        int tradeType = PositionGetInteger(POSITION_TYPE);
        double tradeVolumeMax = SymbolInfoDouble(tradeSymbol, SYMBOL_VOLUME_MAX);

        tradeVolumeFull = PositionGetDouble(POSITION_VOLUME);
        tradeVolumeCurCycle = (tradeVolumeFull > tradeVolumeMax) ? tradeVolumeMax : tradeVolumeFull;

        int type;
        double resultPrice;
        if (tradeType == POSITION_TYPE_BUY) {
            type = ORDER_TYPE_SELL;
            resultPrice = SymbolInfoDouble(tradeSymbol, SYMBOL_BID);
        } else if (tradeType == POSITION_TYPE_SELL) {
            type  = ORDER_TYPE_BUY;
            resultPrice = SymbolInfoDouble(tradeSymbol, SYMBOL_ASK);
        } else {
            error("Unexpected position type " + tradeType + " when closing trade with ticket " + ticket);
            return false;
        }

        checkError("Close trade");
        clearError();
        MqlTradeRequest request;
        MqlTradeResult result;
        MqlTradeCheckResult check_result;
        ZeroMemory(request);
        ZeroMemory(result);
        ZeroMemory(check_result);

        request.action       = TRADE_ACTION_DEAL;
        request.symbol       = tradeSymbol;
        request.type         = type;
        request.volume       = tradeVolumeCurCycle;
        request.price        = resultPrice;
        request.comment      = commentMessage;
        request.magic        = tradeMagicNumber;
        request.type_filling = calculateFillingType(tradeSymbol);
        request.position     = ticket;

        bool success = OrderSend(request, result);

        if (success) {
            info("OrderSend() in close trade succeed, order id: " + result.order + " - " + (string)result.comment + " (" + (string)result.retcode + ")" + " amount " + tradeVolumeCurCycle);
            printOrderResultInfo(result);
        } else {
            error("OrderSend() in close trade failed for operation: " + type + " - " + (string)result.comment + " (" + (string)result.retcode + ")" + " amount " + tradeVolumeCurCycle);
            printOrderResultInfo(result);
            checkError("Close trade sending");
            return false;
        }

    } while (tradeVolumeFull != tradeVolumeCurCycle);

    checkError("Close trade");
    return true;
}

bool closeTradePartial(ulong ticket, double partialPercent, string commentMessage) {

    clearError();
    if (partialPercent <= 0 || partialPercent > 100.0) {
        error("Percent value of partial close trade should be between 0 (excl) and 100 (incl)");
        return false;
    }

    double tradeVolumePartialFull = EMPTY_VALUE;
    double tradeVolumeCurCycle;
    double volumeFull;

    do {

        if (!PositionSelectByTicket(ticket)) {
            error("Couldn't select trade by ticket " + ticket + " while closing trade");
            return false;
        }

        string tradeSymbol = PositionGetString(POSITION_SYMBOL);
        long tradeMagicNumber = PositionGetInteger(POSITION_MAGIC);
        int tradeType = PositionGetInteger(POSITION_TYPE);
        double tradeVolumeMax = SymbolInfoDouble(tradeSymbol, SYMBOL_VOLUME_MAX);
        double tradeVolumeMin = SymbolInfoDouble(tradeSymbol, SYMBOL_VOLUME_MIN);
        double minVolumeStep = SymbolInfoDouble(tradeSymbol, SYMBOL_VOLUME_STEP);
        double prevVolume = PositionGetDouble(POSITION_VOLUME);

        if (tradeVolumePartialFull == EMPTY_VALUE) {
            volumeFull = PositionGetDouble(POSITION_VOLUME);
            tradeVolumePartialFull = volumeFull * partialPercent / 100;
            tradeVolumePartialFull = MathRound(tradeVolumePartialFull / minVolumeStep) * minVolumeStep;
            debug("Partially closing ticket " + ticket + " with value " + tradeVolumePartialFull);
        }

        tradeVolumeCurCycle = (tradeVolumePartialFull > tradeVolumeMax) ? tradeVolumeMax : (tradeVolumePartialFull < tradeVolumeMin) ? tradeVolumeMin : tradeVolumePartialFull;
        tradeVolumePartialFull -= tradeVolumeCurCycle;
        debug("Partially closing ticket " + ticket + ", closing cycle value is " + tradeVolumeCurCycle);

        int type;
        double resultPrice;
        if (tradeType == POSITION_TYPE_BUY) {
            type = ORDER_TYPE_SELL;
            resultPrice = SymbolInfoDouble(tradeSymbol, SYMBOL_BID);
        } else if (tradeType == POSITION_TYPE_SELL) {
            type  = ORDER_TYPE_BUY;
            resultPrice = SymbolInfoDouble(tradeSymbol, SYMBOL_ASK);
        } else {
            error("Unexpected position type " + tradeType + " when closing trade with ticket " + ticket);
            return false;
        }

        checkError("Close partial trade");
        clearError();
        MqlTradeRequest request;
        MqlTradeResult result;
        MqlTradeCheckResult check_result;
        ZeroMemory(request);
        ZeroMemory(result);
        ZeroMemory(check_result);

        request.action       = TRADE_ACTION_DEAL;
        request.symbol       = tradeSymbol;
        request.type         = type;
        request.volume       = tradeVolumeCurCycle;
        request.price        = resultPrice;
        request.comment      = commentMessage;
        request.magic        = tradeMagicNumber;
        request.type_filling = calculateFillingType(tradeSymbol);
        request.position     = ticket;

        bool success = OrderSend(request, result);

        if (success) {
            info("OrderSend() in close trade succeed, order id: " + result.order + " - " + (string)result.comment + " (" + (string)result.retcode + ")" + " amount " + tradeVolumeCurCycle);
            printOrderResultInfo(result);
        } else {
            error("OrderSend() in close trade failed for operation: " + type + " - " + (string)result.comment + " (" + (string)result.retcode + ")" + " amount " + tradeVolumeCurCycle);
            printOrderResultInfo(result);
            checkError("Close partial trade sending");
            return false;
        }

        if (tradeVolumeCurCycle != prevVolume) {
            if (!HistoryDealSelect(result.deal)) {
                error("Couldn't select deal history for deal " + result.deal);
                checkError("Close partial trade history");
            } else {
                long positionID = HistoryDealGetInteger(result.deal, DEAL_POSITION_ID);
                long positionNewTicket = 0;

                for (int i = 0; i < PositionsTotal(); i++) {
                    if (PositionGetTicket(i) > 0) {
                        if (PositionGetInteger(POSITION_IDENTIFIER) == positionID) {
                            positionNewTicket = PositionGetInteger(POSITION_TICKET);
                            if (ticket != positionNewTicket) {
                                error("Ticket of trade have been changed while partial closing!");
                                checkError("Close partial trade not found");
                                return false;
                            }
                        }
                    }
                }
            }
        }

    } while (tradeVolumePartialFull > 0);

    checkError("Close partial trade");
    return true;
}

bool changeStopLossTakeProfit(
	long ticket,
	ActionType actionType,
	SELECT_ORDER_TYPE contextType,
	double stopLoss,
	double takeProfit
) {
	// Check input parameters
   if (stopLoss < 0 || takeProfit < 0) {
      error("Got incorrect input stop loss and take profit values on changeStopLossTakeProfit: stopLoss = " + stopLoss + " takeProfit = " + takeProfit);
      return false;
   }

   if (!selectTicket(ticket, contextType)) {
      error("Couldn't select ticket " + ticket + " of type " + contextType + " while preparing modify SL TP request");
      return false;
   }

   double openPrice = getOpenPrice(contextType, -1);
   if (openPrice < 0 || openPrice >= EMPTY_VALUE) {
      error("Got incorrect open price of ticket on changeStopLossTakeProfit");
      return false;
   }

   string symbol = Symbol();

   // Allign Stop Loss and Take Profit
   double resultStopLoss = alignStopLoss(symbol, actionType, contextType, openPrice, getStopLoss(contextType, -1), stopLoss);
   if (resultStopLoss < 0) {
      error("Got negative result StopLoss: " + resultStopLoss);
      return false;
   }
   double resultTakeProfit = alignTakeProfit(symbol, actionType, contextType, openPrice, getTakeProfit(contextType, -1), takeProfit);
   if (resultTakeProfit < 0) {
      error("Got negative result TakeProfit: " + resultTakeProfit);
      return false;
   }
   debug("Got aligned stop loss and take profit values: SL = " + resultStopLoss + ", TP = " + resultTakeProfit);

   // Create request
   clearError();
   MqlTradeRequest request;
   MqlTradeResult result;
   MqlTradeCheckResult check_result;
   ZeroMemory(request);
   ZeroMemory(result);
   ZeroMemory(check_result);

   if (contextType == OPEN_TRADES) {
      if (
         resultStopLoss == customNormalizeDouble(PositionGetDouble(POSITION_SL)) &&
         resultTakeProfit == customNormalizeDouble(PositionGetDouble(POSITION_TP))
      ) {
         debug("No need to change SL TP for position " + ticket + " new stop loss and take profit values are equals to current");
         return true;
      }

      request.action       = TRADE_ACTION_SLTP;
      request.position     = ticket;
      request.symbol       = PositionGetString(POSITION_SYMBOL);
      request.magic        = PositionGetInteger(POSITION_MAGIC);
      request.sl           = resultStopLoss;
      request.tp           = resultTakeProfit;
   } else if (contextType == PENDING_ORDERS) {
      if (
         resultStopLoss == customNormalizeDouble(OrderGetDouble(ORDER_SL)) &&
         resultTakeProfit == customNormalizeDouble(OrderGetDouble(ORDER_TP))
      ) {
         debug("No need to change SL TP for order " + ticket + " new stop loss and take profit values are equals to current");
         return true;
      }

      request.action       = TRADE_ACTION_MODIFY;
      request.order        = ticket;
      request.symbol       = OrderGetString(ORDER_SYMBOL);
      request.magic        = OrderGetInteger(ORDER_MAGIC);
      request.price        = openPrice;
      request.sl           = resultStopLoss;
      request.tp           = resultTakeProfit;
   } else {
      error("Got unexpected type for modifying stop loss take profit: " + contextType);
      return false;
   }

   if (!OrderCheck(request,check_result)) {
      error("OrderCheck() failed while changing SL TP: " + (string)check_result.comment + " (" + (string)check_result.retcode + ")");
      checkError("Change SL TP request check");
      return false;
   }

   clearError();
   bool success = OrderSend(request, result);
   if (success) {
      info("OrderSend() in modify stop loss take profit succeed, order id: " + result.order + " - " + (string)result.comment + " (" + (string)result.retcode + ")");
      printOrderResultInfo(result);
   } else {
      error("OrderSend() in modify stop loss take profit failed for context type: " + contextType + " and action type: " + actionType + " - " + (string)result.comment + " (" + (string)result.retcode + ")");
      printOrderResultInfo(result);
      checkError("Change SL TP request send");
      return false;
   }

   if (result.retcode != TRADE_RETCODE_DONE) {
      error("Got unexpected code on ticket " + ticket + " modifying stop loss take profit, error code: " + result.retcode);
      return false;
   }

    checkError("Change SL TP request");
	return true;
}

double alignStopLoss(
	string symbol,
	ActionType actionType,
	SELECT_ORDER_TYPE contextType,
	double price,
	double curStopLoss,
	double newStopLoss
) {
	if (newStopLoss == 0.0) {
		return 0.0;
	} else if (newStopLoss < 0.0) {
	   return -1;
	}

	if (newStopLoss == curStopLoss) {
	   return curStopLoss;
	}

	double resultStopLoss = newStopLoss;
	double point = SymbolInfoDouble(symbol, SYMBOL_POINT);
	int digits = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);
	double stopLevel = (double)SymbolInfoInteger(symbol, SYMBOL_TRADE_STOPS_LEVEL);
	double minstops = NormalizeDouble(stopLevel * point, digits);

	if (contextType == OPEN_TRADES) {
      double ask = SymbolInfoDouble(symbol, SYMBOL_ASK);
      double bid = SymbolInfoDouble(symbol, SYMBOL_BID);

	   if (actionType == BUY) {
	      double limit = bid - minstops;
         if (resultStopLoss > ask) {
            error("Wrong value of stop loss requested, result SL (" + resultStopLoss + ") is more than ask price (ask=" + ask + ", bid=" + bid + ")");
            return -1;
         } else if (resultStopLoss > limit) {
            warn("Too short value of stop loss requested, result SL (" + resultStopLoss + ") is more than limit value (" + limit + "), limit value will be taken");
            resultStopLoss = limit;
            return resultStopLoss;
         }
	   } else if (actionType == SELL) {
	      double limit = ask + minstops;
         if (resultStopLoss < bid) {
            error("Wrong value of stop loss requested, result SL (" + resultStopLoss + ") is less than bid price (ask=" + ask + ", bid=" + bid + ")");
            return -1;
         } else if (resultStopLoss < limit) {
            warn("Too short value of stop loss requested, result SL (" + resultStopLoss + ") is less than limit value (" + limit + "), limit value will be taken");
            resultStopLoss = limit;
            return resultStopLoss;
         }
	   } else {
	      error("Unexpected action in aligning stop loss of open trades!");
	      return -1;
	   }
	} else if (contextType == PENDING_ORDERS) {
      if (actionType == BUY) {
         double limit = price - minstops;
         if (resultStopLoss > price) {
            error("Wrong value of stop loss requested, result SL (" + resultStopLoss + ") is more than price (price=" + price + ")");
            return -1;
         } else if (resultStopLoss > limit) {
            warn("Too short value of stop loss requested, result SL (" + resultStopLoss + ") is more than limit value (" + limit + "), limit value will be taken");
            resultStopLoss = limit;
            return resultStopLoss;
         }
	   } else if (actionType == SELL) {
	      double limit = price + minstops;
         if (resultStopLoss < price) {
            error("Wrong value of stop loss requested, result SL (" + resultStopLoss + ") is less than price (price=" + price + ")");
            return -1;
         } else if (resultStopLoss < limit) {
            warn("Too short value of stop loss requested, result SL (" + resultStopLoss + ") is less than limit value (" + limit + "), limit value will be taken");
            resultStopLoss = limit;
            return resultStopLoss;
         }
	   } else {
         error("Unexpected action in aligning stop loss of open trades!");
	      return -1;
	   }
	} else {
      error("Unexpected context type in aligning stop loss!");
      return -1;
	}

	return customNormalizeDouble(resultStopLoss);
}

double alignTakeProfit(
	string symbol,
	ActionType actionType,
	SELECT_ORDER_TYPE contextType,
	double price,
	double curTakeProfit,
	double newTakeProfit
) {
   if (newTakeProfit == 0.0) {
		return 0.0;
	} else if (newTakeProfit < 0.0) {
	   return -1;
	}

	if (newTakeProfit == curTakeProfit) {
	   return curTakeProfit;
	}

   double resultTakeProfit = newTakeProfit;
	double point = SymbolInfoDouble(symbol, SYMBOL_POINT);
	int digits = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);
	double stopLevel = (double)SymbolInfoInteger(symbol, SYMBOL_TRADE_STOPS_LEVEL);
	double minstops = NormalizeDouble(stopLevel * point, digits);

	if (contextType == OPEN_TRADES) {
      double ask = SymbolInfoDouble(symbol, SYMBOL_ASK);
      double bid = SymbolInfoDouble(symbol, SYMBOL_BID);

	   if (actionType == BUY) {
	      double limit = bid + minstops;
         if (resultTakeProfit < bid) {
            error("Wrong value of take profit requested, result TP (" + resultTakeProfit + ") is less than bid price (ask=" + ask + ", bid=" + bid + ")");
            return -1;
         } else if (resultTakeProfit < limit) {
            warn("Too short value of take profit requested, result TP (" + resultTakeProfit + ") is less than limit value (" + limit + "), limit value will be taken");
            resultTakeProfit = limit;
            return resultTakeProfit;
         }
	   } else if (actionType == SELL) {
	      double limit = ask - minstops;
         if (resultTakeProfit > ask) {
            error("Wrong value of take profit requested, result TP (" + resultTakeProfit + ") is more than ask price (ask=" + ask + ", bid=" + bid + ")");
            return -1;
         } else if (resultTakeProfit > limit) {
            warn("Too short value of take profit requested, result TP (" + resultTakeProfit + ") is more than limit value (" + limit + "), limit value will be taken");
            resultTakeProfit = limit;
            return resultTakeProfit;
         }
	   } else {
	      error("Unexpected action in aligning stop loss of open trades!");
	      return -1;
	   }
	} else if (contextType == PENDING_ORDERS) {
      if (actionType == BUY) {
         double limit = price + minstops;
         if (resultTakeProfit < price) {
            error("Wrong value of take profit requested, result TP (" + resultTakeProfit + ") is less than price (price=" + price + ")");
            return -1;
         } else if (resultTakeProfit < limit) {
            warn("Too short value of take profit requested, result TP (" + resultTakeProfit + ") is less than limit value (" + limit + "), limit value will be taken");
            resultTakeProfit = limit;
            return resultTakeProfit;
         }
	   } else if (actionType == SELL) {
	      double limit = price - minstops;
         if (resultTakeProfit > price) {
            error("Wrong value of take profit requested, result TP (" + resultTakeProfit + ") is more than price (price=" + price + ")");
            return -1;
         } else if (resultTakeProfit > limit) {
            warn("Too short value of take profit requested, result TP (" + resultTakeProfit + ") is more than limit value (" + limit + "), limit value will be taken");
            resultTakeProfit = limit;
            return resultTakeProfit;
         }
	   } else {
         error("Unexpected action in aligning stop loss of open trades!");
	      return -1;
	   }
	} else {
      error("Unexpected context type in aligning stop loss!");
      return -1;
	}

	return customNormalizeDouble(resultTakeProfit);
}

double getOpenPrice(SELECT_ORDER_TYPE type, int historyTicket) {
   double price  = 0.0;

   switch(type) {
      case PENDING_ORDERS: {
         price = OrderGetDouble(ORDER_PRICE_OPEN);
         break;
      }
      case OPEN_TRADES: {
         price = PositionGetDouble(POSITION_PRICE_OPEN);
         break;
      }
      case CLOSE_TRADES: {
         if (historyTicket == -1) {
            error("Could not get open price for closed trade - passed ticket is " + historyTicket);
            return -1;
         }

         int dealPositionId = HistoryDealGetInteger(historyTicket, DEAL_POSITION_ID);
         for (int i = 0; i < HistoryDealsTotal(); i++) {
            int ticket = HistoryDealGetTicket(i);
            if (ticket == 0) {
               error("Could not get history deal by index = " + i + "while calculating open price for closed trades");
               checkError("Open price calculation");
               return 0.0;
            }
            int ticketDealPositionId = HistoryDealGetInteger(ticket, DEAL_POSITION_ID);
            ENUM_DEAL_ENTRY ticketDealEntry = (ENUM_DEAL_ENTRY)HistoryDealGetInteger(ticket, DEAL_ENTRY);
            if (dealPositionId == ticketDealPositionId && ticketDealEntry == DEAL_ENTRY_IN) {
               price = HistoryDealGetDouble(ticket, DEAL_PRICE);
               break;
            }

         }
         break;
      }
   }
   return customNormalizeDouble(price);
}

double getClosePrice(SELECT_ORDER_TYPE type, int historyTicket) {
   double price  = 0.0;

   switch(type) {
      case PENDING_ORDERS: {
         price = OrderGetDouble(ORDER_PRICE_CURRENT);
         break;
      }
      case OPEN_TRADES: {
         int positionType = PositionGetInteger(POSITION_TYPE);
         if (positionType == POSITION_TYPE_BUY) {
            price = SymbolInfoDouble(PositionGetString(POSITION_SYMBOL), SYMBOL_BID);
         } else if (positionType == POSITION_TYPE_SELL) {
            price = SymbolInfoDouble(PositionGetString(POSITION_SYMBOL), SYMBOL_ASK);
         } else {
            error("Unexpected open trade position type while getting close price: " + positionType);
         }
         break;
      }
      case CLOSE_TRADES: {
         if (historyTicket == -1) {
            error("Could not get close price for closed trade - passed ticket is " + historyTicket);
            return -1;
         }

         int dealPositionId = HistoryDealGetInteger(historyTicket, DEAL_POSITION_ID);
         for (int i = HistoryDealsTotal()-1; i >= 0; i--) {
            int ticket = HistoryDealGetTicket(i);
            if (ticket == 0) {
               error("Could not get history deal by index = " + i + "while calculating close price for closed trades");
               checkError("Close price calculation");
               return 0.0;
            }
            int ticketDealPositionId = HistoryDealGetInteger(ticket, DEAL_POSITION_ID);
            ENUM_DEAL_ENTRY ticketDealEntry = (ENUM_DEAL_ENTRY)HistoryDealGetInteger(ticket, DEAL_ENTRY);
            if (dealPositionId == ticketDealPositionId && ticketDealEntry == DEAL_ENTRY_OUT) {
               price = HistoryDealGetDouble(ticket, DEAL_PRICE);
               break;
            }

         }
         break;
      }
   }
   return customNormalizeDouble(price);
}

double getVolumeSize(SELECT_ORDER_TYPE type, int historyTicket) {
   double price  = 0.0;

   switch(type) {
      case PENDING_ORDERS: {
         price = OrderGetDouble(ORDER_VOLUME_INITIAL);
         break;
      }
      case OPEN_TRADES: {
         price = PositionGetDouble(POSITION_VOLUME);
         break;
      }
      case CLOSE_TRADES: {
         if (historyTicket == -1) {
            error("Could not get volume size for closed trade - passed ticket is " + historyTicket);
            return -1;
         }
         price = HistoryDealGetDouble(historyTicket, DEAL_VOLUME);
         break;
      }
   }
   return customNormalizeDouble(price);
}

double getStopLoss(SELECT_ORDER_TYPE type, int historyTicket) {
   double stopLoss  = 0.0;

   switch(type) {
      case PENDING_ORDERS: {
         stopLoss = OrderGetDouble(ORDER_SL);
         break;
      }
      case OPEN_TRADES: {
         stopLoss = PositionGetDouble(POSITION_SL);
         break;
      }
      case CLOSE_TRADES: {
         if (historyTicket == -1) {
            error("Could not get sl for closed trade - passed ticket is " + historyTicket);
            return -1;
         }
         stopLoss = HistoryDealGetDouble(historyTicket, DEAL_SL);
         break;
      }
   }
   return customNormalizeDouble(stopLoss);
}

double getTakeProfit(SELECT_ORDER_TYPE type, int historyTicket) {
   double takeProfit  = 0.0;

   switch(type) {
      case PENDING_ORDERS: {
         takeProfit = OrderGetDouble(ORDER_TP);
         break;
      }
      case OPEN_TRADES: {
         takeProfit = PositionGetDouble(POSITION_TP);
         break;
      }
      case CLOSE_TRADES: {
         if (historyTicket == -1) {
            error("Could not get tp for closed trade - passed ticket is " + historyTicket);
            return -1;
         }
         takeProfit = HistoryDealGetDouble(historyTicket, DEAL_TP);
         break;
      }
   }
   return customNormalizeDouble(takeProfit);
}

bool selectTicket(long ticket, SELECT_ORDER_TYPE type) {
  switch(type) {
     case PENDING_ORDERS: {
        bool result = OrderSelect(ticket);
        checkError("Select ticket " + ticket + " of type " + type);
        return result;
     }
     case OPEN_TRADES: {
        bool result = PositionSelectByTicket(ticket);
        checkError("Select ticket " + ticket + " of type " + type);
        return result;
     }
     case CLOSE_TRADES: {
        bool result = HistoryDealSelect(ticket);
        checkError("Select ticket " + ticket + " of type " + type);
        return result;
     }
  }
  return false;
}

ActionType defineActionType(SELECT_ORDER_TYPE type) {
  switch(type) {
     case PENDING_ORDERS: {
        int orderType = OrderGetInteger(ORDER_TYPE);
        if (orderType == ORDER_TYPE_BUY_LIMIT || orderType == ORDER_TYPE_BUY_STOP) {
           return BUY;
        } else if (orderType == ORDER_TYPE_BUY_LIMIT || orderType == ORDER_TYPE_BUY_STOP) {
           return SELL;
        } else {
           error("Unexpected pending order order type while modifying SL TP: " + orderType);
           return UNDEFINED;
        }
     }
     case OPEN_TRADES: {
        int positionType = PositionGetInteger(POSITION_TYPE);
        if (positionType == POSITION_TYPE_BUY) {
           return BUY;
        } else if (positionType == POSITION_TYPE_SELL) {
           return SELL;
        } else {
           error("Unexpected open trade position type while modifying SL TP: " + positionType);
           return UNDEFINED;
        }
     }
     case CLOSE_TRADES: {
        error("Got wrong context type for ticket (closed)");
        return UNDEFINED;
     }
  }
  return UNDEFINED;
}

CheckResult getCurrentProfit(SELECT_ORDER_TYPE type, long ticket) {
   double profitValue = 0.0;

   switch(type) {
      case PENDING_ORDERS: {
         //Pending orders has no profit
         return CheckResult(false, 0.0);
      }
      case OPEN_TRADES: {
         if (PositionSelectByTicket(ticket)) {
            double profit = PositionGetDouble(POSITION_PROFIT);
            double swap = PositionGetDouble(POSITION_SWAP);
            double comission = PositionGetDouble(POSITION_COMMISSION);
            profitValue = profit + swap + comission;
            debug("Calculated profit for ticket " + ticket + " position: " + profitValue , CHK_PROF_LOSS_TYPE);
            checkError("Getting current profit");
         } else {
            error("Couldn't select position with ticket " + ticket);
            checkError("Getting current profit");
            return CheckResult(false, 0.0);
         }
         break;
      }
      case CLOSE_TRADES: {
         if (HistoryDealSelect(ticket)) {
            double profit = HistoryDealGetDouble(ticket, DEAL_PROFIT);
            double swap = HistoryDealGetDouble(ticket, DEAL_SWAP);
            double comission = HistoryDealGetDouble(ticket, DEAL_COMMISSION);
            profitValue = profit + swap + comission;
            debug("Calculated profit for ticket " + ticket + " history deal: " + profitValue , CHK_PROF_LOSS_TYPE);
            checkError("Getting current profit");
         } else {
            error("Couldn't select closed position with ticket " + ticket);
            checkError("Getting current profit");
            return CheckResult(false, 0.0);
         }
         break;
      }
   }

   return CheckResult(true, profitValue);
}

uint RGB(uchar r, uchar g, uchar b)
{
   return ((uint)r) | (((uint)g) << 8) | (((uint)b) << 16);
}

void hoistTheColours() {
   long chart_id = ChartID();
   ChartSetInteger(chart_id, CHART_COLOR_BACKGROUND, RGB(29, 29, 29));
   ChartSetInteger(chart_id, CHART_COLOR_FOREGROUND, clrWhite);
   ChartSetInteger(chart_id, CHART_COLOR_GRID, clrLightSlateGray);
   ChartSetInteger(chart_id, CHART_COLOR_CHART_UP, RGB(0, 182, 153));
   ChartSetInteger(chart_id, CHART_COLOR_CHART_DOWN, RGB(217, 42, 15));
   ChartSetInteger(chart_id, CHART_COLOR_CANDLE_BULL, RGB(0, 182, 153));
   ChartSetInteger(chart_id, CHART_COLOR_CANDLE_BEAR, RGB(217, 42, 15));
   ChartSetInteger(chart_id, CHART_COLOR_CHART_LINE, RGB(75, 56, 240));
   ChartSetInteger(chart_id, CHART_COLOR_VOLUME, RGB(75, 56, 240));
   ChartSetInteger(chart_id, CHART_COLOR_BID, clrLightSlateGray);
   ChartSetInteger(chart_id, CHART_COLOR_ASK, clrRed);
   ChartSetInteger(chart_id, CHART_COLOR_LAST, RGB(75, 56, 240));
   ChartSetInteger(chart_id, CHART_COLOR_STOP_LEVEL, clrRed);
   ChartSetInteger(chart_id, CHART_SHOW_GRID, 0, false);
   ChartRedraw();
}

//+------------------------------------------------------------------+
class IndicatorBlock_Base {
   public:
    int handle;

    virtual void createHandle() = NULL;
};

//+------------------------------------------------------------------+
//| Indicators block classes                                            |
//+------------------------------------------------------------------+
class IndicatorBlock_iMA: public IndicatorBlock_Base {

private:
    string symbol;
    Value<ENUM_TIMEFRAMES> period;
    int mode;
    Value<int> candleIdShift;
    Value<int> maPeriod;
    Value<int> maShift;
    ENUM_MA_METHOD maMethod;
    ENUM_APPLIED_PRICE appliedPrice;


public:
    IndicatorBlock_iMA() {}

    IndicatorBlock_iMA(string symbol, Value<ENUM_TIMEFRAMES>& period, int mode, Value<int>& candleIdShift , Value<int>& maPeriod, Value<int>& maShift, ENUM_MA_METHOD maMethod, ENUM_APPLIED_PRICE appliedPrice) {
        this.symbol = symbol;
        this.period = period;
        this.mode = mode;
        this.candleIdShift = candleIdShift;
        this.maPeriod = maPeriod;
        this.maShift = maShift;
        this.maMethod = maMethod;
        this.appliedPrice = appliedPrice;


    }

    void createHandle() {
        this.handle = iMA(this.symbol, this.period.execute(), this.maPeriod.execute(), this.maShift.execute(), this.maMethod, this.appliedPrice);
    }

    double execute() {
        createHandle();
        //TODO improve with try attempts
        while (BarsCalculated(handle) < 0) {
            Sleep(10);
        }

        if (handle == INVALID_HANDLE) {
            error("Indicator handler hasn't yet been created!");
            return 0;
        }

        double buffer[1];
        int elementCount = CopyBuffer(handle, mode, this.candleIdShift.execute(), 1, buffer);
        if (elementCount == -1) {
            error("Can't get iMA indicator value!");
            return 0;
        }
        debug("Indicator iMA value ", buffer[0]);
        return NormalizeDouble(buffer[0], 10);
    }
};

//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//| Candles block classes                                            |
//+------------------------------------------------------------------+
class Candle {

private:
    string symbol;
    string candleMode;
    Value<int> candleId;
    Value<ENUM_TIMEFRAMES> timeFrame;

public:
    Candle() {}

    Candle(string candleMode, Value<int>& candleId, Value<ENUM_TIMEFRAMES>& timeFrame) {
        this.symbol = Symbol();
        this.candleMode = candleMode;
        this.candleId = candleId;
        this.timeFrame = timeFrame;
    }

   double execute() {
      double result;
      double resultBuffer[];
      executeBuffered(1, resultBuffer);
      result = resultBuffer[0];
      ArrayFree(resultBuffer);
      return result;
   }

   int executeBuffered(int size, double &result[]) {
      debug("Getting candle");
      double tmpArrayOpen[];
      double tmpArrayClose[];
      double tmpArrayHigh[];
      double tmpArrayLow[];
      ArrayResize(result, size);

      ENUM_TIMEFRAMES timeFrame = this.timeFrame.execute();
      int candleId = this.candleId.execute();

    	if (candleMode == "Open") {
			if (CopyOpen(symbol, timeFrame, candleId, size, tmpArrayOpen) > -1) {
			   for (int i = 0; i < size; i++) {
			      result[i] = tmpArrayOpen[i];
			   }
			}
		} else if (candleMode == "Close") {
			if (CopyClose(symbol, timeFrame, candleId, size, tmpArrayClose) > -1) {
			   for (int i = 0; i < size; i++) {
			      result[i] = tmpArrayClose[i];
			   }
		   }
		} else if (candleMode == "High") {
			if (CopyHigh(symbol, timeFrame, candleId, size, tmpArrayHigh) > -1) {
			   for (int i = 0; i < size; i++) {
			      result[i] = tmpArrayHigh[i];
			   }
			}
		} else if (candleMode == "Low") {
			if (CopyLow(symbol, timeFrame, candleId, size, tmpArrayLow) > -1) {
			   for (int i = 0; i < size; i++) {
			      result[i] = tmpArrayLow[i];
			   }
		   }
		} else if (candleMode == "Median") {
			if (
			      (CopyLow(symbol, timeFrame, candleId, size, tmpArrayLow) > -1) &&
			      (CopyHigh(symbol, timeFrame, candleId, size, tmpArrayHigh) > -1)
		   ) {
		      for (int i = 0; i < size; i++) {
		         result[i] = ((tmpArrayLow[i] + tmpArrayHigh[i]) / 2);
		      }
			}
		} else if (candleMode=="Total") {
			if (
				   (CopyHigh(symbol, timeFrame, candleId, size, tmpArrayHigh) > -1) &&
				   (CopyLow(symbol, timeFrame, candleId, size, tmpArrayLow) > -1)
		   ) {
		      for (int i = 0; i < size; i++) {
				   result[i] = priceToPips(MathAbs(tmpArrayHigh[i] - tmpArrayLow[i]), symbol);
				}
			}
		} else if (candleMode == "Body") {
			if (
				   (CopyOpen(symbol, timeFrame, candleId, size, tmpArrayOpen) > -1) &&
				   (CopyClose(symbol, timeFrame, candleId, size, tmpArrayClose) > -1)
			) {
			   for (int i = 0; i < size; i++) {
				   result[i] = priceToPips(MathAbs(tmpArrayClose[i] - tmpArrayOpen[i]), symbol);
				}
			}
		} else if (candleMode == "UpperWick") {
			if (
				   (CopyHigh(symbol, timeFrame, candleId, size, tmpArrayHigh) > -1) &&
				   (CopyOpen(symbol, timeFrame, candleId, size, tmpArrayOpen) > -1) &&
				   (CopyClose(symbol, timeFrame, candleId, size, tmpArrayClose) > -1)
			) {
			   for (int i = 0; i < size; i++) {
				   result[i] = (tmpArrayClose[i] > tmpArrayOpen[i]) ?
   				   priceToPips(MathAbs(tmpArrayHigh[i] - tmpArrayClose[i]), symbol) :
				      priceToPips(MathAbs(tmpArrayHigh[i] - tmpArrayOpen[i]), symbol);
            }
			}
		} else if (candleMode == "BottomWick") {
			if (
				   (CopyOpen(symbol, timeFrame, candleId, size, tmpArrayOpen) > -1) &&
				   (CopyClose(symbol, timeFrame, candleId, size, tmpArrayClose) > -1) &&
				   (CopyLow(symbol, timeFrame, candleId, size, tmpArrayLow) > -1)
			) {
			   for (int i = 0; i < size; i++) {
				   result[i] = (tmpArrayClose[i] > tmpArrayOpen[i]) ?
   				   priceToPips(MathAbs(tmpArrayOpen[i] - tmpArrayLow[i]), symbol) :
				      priceToPips(MathAbs(tmpArrayClose[i] - tmpArrayLow[i]), symbol);
            }
			}
		} else {
		   error("Not defined candle mode: " + candleMode);
		}

      ArrayFree(tmpArrayOpen);
      ArrayFree(tmpArrayClose);
      ArrayFree(tmpArrayHigh);
      ArrayFree(tmpArrayLow);
      for (int i = 0; i < size; i++) {
         result[i] = customNormalizeDouble(result[i]);
      }
      return ArraySize(result);
   }
};
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Market properties operands                                       |
//+------------------------------------------------------------------+
class MarketPropertiesAskBidMid {
private:
   string symbol;
   string priceType;
   Value<int> shift;

public:
   MarketPropertiesAskBidMid() {}
   MarketPropertiesAskBidMid(string priceType, Value<int>& shift) {
      this.symbol = Symbol();
      this.priceType = priceType;
      this.shift = shift;
   }

   double execute(int additionalShift = 0) {
      debug("Executing MarketPropertiesAskBidMid");
      double resultData = 0;
      if (priceType == "ASK") {
         resultData = getAskBidData(symbol, SYMBOL_ASK, shift.execute() + additionalShift);
      } else if (priceType == "BID") {
         resultData = getAskBidData(symbol, SYMBOL_BID, shift.execute() + additionalShift);
      } else if (priceType == "MID") {
         int shiftResult = shift.execute() + additionalShift;
         resultData = (getAskBidData(symbol, SYMBOL_ASK, shiftResult) + getAskBidData(symbol, SYMBOL_BID, shiftResult)) / 2;
      } else if (priceType == "BIDHIGH") {
         resultData = SymbolInfoDouble(symbol, SYMBOL_BIDHIGH);
      } else if (priceType == "BIDLOW") {
         resultData = SymbolInfoDouble(symbol, SYMBOL_BIDLOW);
      } else if (priceType == "ASKHIGH") {
         resultData = SymbolInfoDouble(symbol, SYMBOL_ASKHIGH);
      } else if (priceType == "ASKLOW") {
         resultData = SymbolInfoDouble(symbol, SYMBOL_ASKLOW);
      } else if (priceType == "LAST") {
         resultData = SymbolInfoDouble(symbol, SYMBOL_LAST);
      } else if (priceType == "LASTHIGH") {
         resultData = SymbolInfoDouble(symbol, SYMBOL_LASTHIGH);
      } else if (priceType == "LASTLOW") {
         resultData = SymbolInfoDouble(symbol, SYMBOL_LASTLOW);
      } else {
         error("Unexpected price type value in MarketPropertiesAskBidMid: " + priceType);
      }

      return customNormalizeDouble(resultData);
   }
};

class MarketPropertiesHighestCandles {
private:
   string symbol;
   Value<int> startCandleId;
   Value<int> endCandleId;
   string valueName;
   Value<ENUM_TIMEFRAMES> period;

   public:
      MarketPropertiesHighestCandles() {}
      MarketPropertiesHighestCandles(Value<int>& startCandleId, Value<int>& endCandleId, string valueName, Value<ENUM_TIMEFRAMES>& period) {
         this.symbol = Symbol();
         this.startCandleId = startCandleId;
         this.endCandleId = endCandleId;
         this.valueName = valueName;
         this.period = period;
      }

      double execute() {
         debug("Executing MarketPropertiesHighestCandles");
         return getHighestCandles(symbol, period.execute(), startCandleId.execute(), endCandleId.execute(), valueName);
      }

};

class MarketPropertiesLowestCandles {
private:
   string symbol;
   Value<int> startCandleId;
   Value<int> endCandleId;
   string valueName;
   Value<ENUM_TIMEFRAMES> period;

public:
   MarketPropertiesLowestCandles() {}
   MarketPropertiesLowestCandles(Value<int>& startCandleId, Value<int>& endCandleId, string valueName, Value<ENUM_TIMEFRAMES>& period) {
         this.symbol = Symbol();
         this.startCandleId = startCandleId;
         this.endCandleId = endCandleId;
         this.valueName = valueName;
         this.period = period;
   }

   double execute() {
      debug("Executing MarketPropertiesLowestCandles");
      return getLowestCandles(symbol, period.execute(), startCandleId.execute(), endCandleId.execute(), valueName);
   }

};

class MarketPropertiesHighestTime {
private:
   string symbol;
   string sourceTime;
   Value<datetime> startTime;
   Value<datetime> endTime;
   Value<int> dayOffset;
   string valueName;
   Value<ENUM_TIMEFRAMES> period;

public:
   MarketPropertiesHighestTime() {}
   MarketPropertiesHighestTime(string sourceTime, Value<datetime>& startTime, Value<datetime>& endTime, Value<int>& dayOffset, string valueName, Value<ENUM_TIMEFRAMES>& period) {
      this.symbol = Symbol();
      this.sourceTime = sourceTime;
      this.startTime = startTime;
      this.endTime = endTime;
      this.dayOffset = dayOffset;
      this.valueName = valueName;
      this.period = period;
   }

   double execute() {
      debug("Executing MarketPropertiesHighestTime");
      return getHighestTime(symbol, period.execute(), startTime.execute(), endTime.execute(), valueName, sourceTime, dayOffset.execute());
   }

};

class MarketPropertiesLowestTime {
private:
   string symbol;
   string sourceTime;
   Value<datetime> startTime;
   Value<datetime> endTime;
   Value<int> dayOffset;
   string valueName;
   Value<ENUM_TIMEFRAMES> period;

public:
   MarketPropertiesLowestTime() {}
   MarketPropertiesLowestTime(string sourceTime, Value<datetime>& startTime, Value<datetime>& endTime, Value<int>& dayOffset, string valueName, Value<ENUM_TIMEFRAMES>& period) {
      this.symbol = Symbol();
      this.sourceTime = sourceTime;
      this.startTime = startTime;
      this.endTime = endTime;
      this.dayOffset = dayOffset;
      this.valueName = valueName;
      this.period = period;
   }

   double execute() {
      debug("Executing MarketPropertiesLowestTime");
      return getLowestTime(symbol, period.execute(), startTime.execute(), endTime.execute(), valueName, sourceTime, dayOffset.execute());
   }

};

void updateAskBidHistory() {
   string symbol = Symbol();
   bool isNewValue = false;
   AskBidHistory* askBidHistory;
   if (askBidHistoryMap.ContainsKey(symbol)) {
      if (!askBidHistoryMap.TryGetValue(symbol, askBidHistory)) {
         error("Could not get ask bid history by key " + symbol);
         return;
      }
   } else {
      askBidHistory = new AskBidHistory();
      isNewValue = true;
   }

   double ask = SymbolInfoDouble(symbol, SYMBOL_ASK);
   double bid = SymbolInfoDouble(symbol, SYMBOL_BID);

   int nextId = askBidHistory.nextDataId;
   if (ask != askBidHistory.historyAsk[nextId] || bid != askBidHistory.historyBid[nextId]) {
      askBidHistory.historyAsk[nextId] = ask;
      askBidHistory.historyBid[nextId] = bid;
      nextId++;
      if (nextId >= MAX_ASK_BID_HISTORY_COUNT) {
         nextId = 0;
      }
      askBidHistory.nextDataId = nextId;

      if (isNewValue) {
         deleteOldMapValue(askBidHistoryMap, symbol);
      }
      askBidHistoryMap.TrySetValue(symbol, askBidHistory);
   }
}

double getAskBidData(string symbol, int type, int shift) {
   debug("getAskBidData, symbol = " + symbol + ", type = " + type + ", shift = " + shift);
   double result = 0;

   if (shift > MAX_ASK_BID_HISTORY_COUNT) {
      error("Too big shift for market property: " + shift);
      return result;
   }

   if (shift > 0) {
      AskBidHistory* askBidHistory;
      if (!askBidHistoryMap.TryGetValue(symbol, askBidHistory)) {
         error("Could not get ask bid history by key " + symbol + " while calculating market property");
      } else {
         int requiredId = askBidHistory.nextDataId - shift - 1;
         if (requiredId < 0) {
            requiredId = requiredId + MAX_ASK_BID_HISTORY_COUNT;
         }

         if (type == SYMBOL_ASK) {
            result = askBidHistory.historyAsk[requiredId];
         } else if (type == SYMBOL_BID) {
            result = askBidHistory.historyBid[requiredId];
         } else {
            error("Not supported type while getting ASK/BID history data: " + type);
         }
      }
   }

   if (result == 0) {
      result = getAskBidData(symbol, type);
   }

   return result;
}

double getAskBidData(string symbol, int type) {
   debug("getAskBidData, symbol = " + symbol + ", type = " + type);
   if (type == SYMBOL_ASK) {
      return SymbolInfoDouble(symbol, SYMBOL_ASK);
   } else if (type == SYMBOL_BID) {
      return SymbolInfoDouble(symbol, SYMBOL_BID);
   } else {
      error("Not supported type while getting ASK/BID data: " + type);
      return 0;
   }
}

double getHighestCandles(string symbol, ENUM_TIMEFRAMES timeframe, int startCandleId, int endCandleId, string valueName) {
   debug("getHighestCandles, symbol = " + symbol + ", timeframe = " + timeframe + ", startCandleId = " + startCandleId + ", endCandleId = " + endCandleId + ", valueName = " + valueName);
   double result = 0.0;

	int barShift = 0;
	if (startCandleId == endCandleId) {
		barShift = (int)startCandleId;
	} else {
		int barCount = iBars(symbol, timeframe);

		if (endCandleId > barCount-1 || endCandleId == 0) {
			endCandleId = barCount-1;
		}
		barShift = iHighest(symbol, timeframe, MODE_HIGH, (int)(endCandleId - startCandleId) + 1, (int)startCandleId);
	}

	if (valueName == "priceValue") {
	   result = iHigh(symbol, timeframe, barShift);
	} else if (valueName == "candleId") {
	   result = barShift;
	} else if (valueName == "timeValue") {
	   result = (double)iTime(symbol, timeframe, barShift);
	} else {
	   error("Unexpected value name in Highest Candles Market Property: " + valueName);
	}

	return customNormalizeDouble(result);
}

double getLowestCandles(string symbol, ENUM_TIMEFRAMES timeframe, datetime startCandleId, datetime endCandleId, string valueName) {
   debug("getLowestCandles, symbol = " + symbol + ", timeframe = " + timeframe + ", startCandleId = " + startCandleId + ", endCandleId = " + endCandleId + ", valueName = " + valueName);
   double result = 0.0;

	int barShift = 0;
	if (startCandleId == endCandleId) {
		barShift = (int)startCandleId;
	} else {
		int barCount = iBars(symbol, timeframe);

		if (endCandleId > barCount-1 || endCandleId == 0) {
			endCandleId = barCount-1;
		}
		barShift = iLowest(symbol, timeframe, MODE_LOW, (int)(endCandleId - startCandleId) + 1, (int)startCandleId);
	}

	if (valueName == "priceValue") {
	   result = iLow(symbol, timeframe, barShift);
	} else if (valueName == "candleId") {
	   result = barShift;
	} else if (valueName == "timeValue") {
	   result = (double)iTime(symbol, timeframe, barShift);
	} else {
	   error("Unexpected value name in Lowest Candles Market Property: " + valueName);
	}

   return customNormalizeDouble(result);
}

double getHighestTime(string symbol, ENUM_TIMEFRAMES timeframe, datetime startTime, datetime endTime, string valueName, string sourceTime, int dayOffset) {
   debug("getHighestTime, symbol = " + symbol + ", timeframe = " + timeframe + ", startTime = " + startTime + ", endTime = " + endTime + ", valueName = " + valueName + ", sourceTime = " + sourceTime + ", dayOffset = " + dayOffset);
   double result = 0.0;

   int secondsOffset = 3600 * 24 * dayOffset;
   int offset = calculateOffset(sourceTime);
   datetime startTimeResult = startTime - offset - secondsOffset;
   datetime endTimeResult = endTime - offset - secondsOffset;

   int barShiftStart = iBarShift(symbol, timeframe, startTimeResult, false);
   int barShiftEnd = iBarShift(symbol, timeframe, endTimeResult, false);

   if (barShiftStart < barShiftEnd) {
      barShiftStart = iBarShift(symbol, timeframe, (startTimeResult - 3600 * 24), false);
   }

   if (barShiftStart < 0 || barShiftEnd < 0) {
      error("Got negative bar shifts on calculating Highest Time: barShiftStart: " + barShiftStart + ", barShiftEnd: " + barShiftEnd);
      return -1;
   }

   double resultVal = 0;
   datetime resultTime = 0;
   double resultId = 0;
   for (int i = barShiftEnd; i <= barShiftStart; i++) {
      double currentVal = iHigh(symbol, timeframe, i);
      if (currentVal > resultVal) {
         resultVal = currentVal;
         resultTime = iTime(symbol, timeframe, i);
         resultId = i;
      }
   }

   if (valueName == "priceValue") {
	   result = resultVal;
	} else if (valueName == "candleId") {
	   result = resultId;
	} else if (valueName == "timeValue") {
	   result = resultTime;
	} else {
	   error("Unexpected value name in Highest Time Market Property: " + valueName);
	}

   return customNormalizeDouble(result);
}

double getLowestTime(string symbol, ENUM_TIMEFRAMES timeframe, datetime startTime, datetime endTime, string valueName, string sourceTime, int dayOffset) {
   debug("getLowestTime, symbol = " + symbol + ", timeframe = " + timeframe + ", startTime = " + startTime + ", endTime = " + endTime + ", valueName = " + valueName + ", sourceTime = " + sourceTime + ", dayOffset = " + dayOffset);
   double result = 0.0;

   int secondsOffset = 3600 * 24 * dayOffset;
   int offset = calculateOffset(sourceTime);
   datetime startTimeResult = startTime - offset - secondsOffset;
   datetime endTimeResult = endTime - offset - secondsOffset;

   int barShiftStart = iBarShift(symbol, timeframe, startTimeResult, false);
   int barShiftEnd = iBarShift(symbol, timeframe, endTimeResult, false);

   if (barShiftStart < barShiftEnd) {
      barShiftStart = iBarShift(symbol, timeframe, (startTimeResult - 3600 * 24), false);
   }

   if (barShiftStart < 0 || barShiftEnd < 0) {
      error("Got negative bar shifts on calculating Lowest Time: barShiftStart: " + barShiftStart + ", barShiftEnd: " + barShiftEnd);
      return -1;
   }

   double resultVal = 0;
   datetime resultTime = 0;
   double resultId = 0;
   for (int i = barShiftEnd; i <= barShiftStart; i++) {
      double currentVal = iLow(symbol, timeframe, i);
      if (currentVal < resultVal || resultVal == 0) {
         resultVal = currentVal;
         resultTime = iTime(symbol, timeframe, i);
         resultId = i;
      }
   }

   if (valueName == "priceValue") {
	   result = resultVal;
	} else if (valueName == "candleId") {
	   result = resultId;
	} else if (valueName == "timeValue") {
	   result = resultTime;
	} else {
	   error("Unexpected value name in Lowest Time Market Property: " + valueName);
	}

   return customNormalizeDouble(result);
}

int calculateOffset(string sourceTime) {
	int offset = 0;

	if (sourceTime == "server") {
	   offset = 0;
   } else if (sourceTime == "local") {
      offset = (int)(TimeLocal() - TimeCurrent());
   } else if (sourceTime == "utc") {
      offset = (int)(TimeGMT() - TimeCurrent());
   } else {
      error("Unexpected source time while calculating offset: " + sourceTime);
   }

   return offset;
}

bool isDateTimeFormat(string val) {
    if (val.Length() == 19) {
        return StringSubstr(val, 4, 1) == "." && StringSubstr(val, 7, 1) == "." && StringSubstr(val, 13, 1) == ":" && StringSubstr(val, 16, 1) == ":";
    }
    return false;
}

bool isTimeFormat(string val) {
    if (val.Length() == 5) {
        return StringSubstr(val, 2, 1) == ":";
    }
    return false;
}
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Account info block classes                                       |
//+------------------------------------------------------------------+
class AccountOperand {

private:
    string mode;

public:
    AccountOperand() {}

    AccountOperand(string mode) {
        this.mode = mode;
    }

    double execute() {
      debug("Getting account operand info");
      double result = 0;

      if (mode == "BALANCE") {
         result = getAccountBalance();
      } else if (mode == "EQUITY") {
         result = getAccountEquity();
      } else if (mode == "FREE_MARGIN") {
         result = getAccountFreeMargin();
      } else {
         error("Unexpected mode in account operand: " + mode);
      }

      return customNormalizeDouble(result);
   }
};
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Trade info block classes                                         |
//+------------------------------------------------------------------+
enum TRADE_INFO_VALUE {
    TI_OPEN_PRICE, TI_CLOSE_PRICE, TI_VOLUME_SIZE, TI_PROFIT, TI_STOP_LOSS
};
enum TRADE_INFO_MODE {
    TI_TOTAL, TI_LAST, TI_CORRESPONDING
};
enum TRADE_INFO_PROFIT_MODE {
    TI_FIXED_PIPS, TI_FIXED_AMOUNT, TI_EQUITY_RISK, TI_BALANCE_RISK
};
class TradeInfoOperand {

private:
   TRADE_INFO_VALUE value;
   TRADE_INFO_MODE mode;
   TRADE_INFO_PROFIT_MODE profitMode;
   int contextCreatorIndex;
   SharedData *sharedData;

public:
    TradeInfoOperand() {}

    TradeInfoOperand(TRADE_INFO_VALUE value, TRADE_INFO_MODE mode, TRADE_INFO_PROFIT_MODE profitMode, int contextCreatorIndex, SharedData *sharedData) {
        this.value = value;
        this.mode = mode;
        this.profitMode = profitMode;
        this.contextCreatorIndex = contextCreatorIndex;
        this.sharedData = sharedData;
    }

    double execute() {
      debug("Getting trade info operand");
      double result = 0;
      long tickets[];
      clearError();

      SelectOrdersContext* context;
      if (this.contextCreatorIndex == -1) {
         error("Context creator block not defined for trade info operator with data: value = " + this.value + ", mode = " + this.mode + ", profitMode = " + this.profitMode);
         return result;
      }

      if (!selectContextMap.TryGetValue(this.contextCreatorIndex, context)) {
         error("Context data for context creator block " + this.contextCreatorIndex + " not found!");
         return result;
      }
      debug("Got input context of type " + context.type + " with " + ArraySize(context.tickets) + " tickets", TRD_INF_TYPE);

      if (validateParameters(context.type) == false) {
         error("Validation error in Trade Info!");
         return result;
      }

      if (this.mode == TI_CORRESPONDING) {
         ArrayResize(tickets, 1);
         tickets[0] = sharedData.ticket;
         debug("Selected corresponding ticket " + sharedData.ticket, TRD_INF_TYPE);
      } else {
         CopyObjects(tickets, context.tickets);
         debug("Selected tickets from context", TRD_INF_TYPE);
      }

      CheckResult operationResult = CheckResult(true, 0);
      if (this.value == TI_OPEN_PRICE) {
         operationResult = processOpenPrice(context.type, tickets);
      } else if (this.value == TI_CLOSE_PRICE) {
         operationResult = processClosePrice(context.type, tickets);
      } else if (this.value == TI_VOLUME_SIZE) {
         operationResult = processVolumeSize(context.type, tickets);
      } else if (this.value == TI_PROFIT) {
         operationResult = processProfit(context.type, tickets);
      } else if (this.value == TI_STOP_LOSS) {
         operationResult = processStopLoss(context.type, tickets);
      } else {
         error("Unexpected value for TradeInfoOperand: " + this.value);
         operationResult = CheckResult(false, 0);
      }

      if (operationResult.success) {
         result = operationResult.result;
      }

      ArrayFree(tickets);
      return result;
   }

private:

   CheckResult processOpenPrice(SELECT_ORDER_TYPE type, long& tickets[]) {
      debug("Processing open price with type " + type + " and tickets " + longArrayToString(tickets) + ", mode: " + this.mode, TRD_INF_TYPE);
      double result = 0;

      switch(this.mode) {
         case TI_TOTAL: {
            if (type == CLOSE_TRADES) {
               filterClosedTickets(tickets);
            }
            for (int i = 0; i < ArraySize(tickets); i++) {
               if (selectTicketForProcessing(tickets[i], type) != true) {
                  return CheckResult(false, 0);
               }
               result += getOpenPrice(type, tickets[i]);
            }
            break;
         }
         case TI_LAST: {
            int lastIndex = ArraySize(tickets) - 1;
            if (selectTicketForProcessing(tickets[lastIndex], type) != true) {
               return CheckResult(false, 0);
            }
            result = getOpenPrice(type, tickets[lastIndex]);
            break;
         }
         case TI_CORRESPONDING: {
            if (selectTicketForProcessing(tickets[0], type) != true) {
               return CheckResult(false, 0);
            }
            result = getOpenPrice(type, tickets[0]);
            break;
         }
         default: {
            error("Unexpected mode with tickets " + longArrayToString(tickets) + " of type " + type + " while processing open price");
            return CheckResult(false, 0);
         }
      }

      debug("Got result of open price: " + result, TRD_INF_TYPE);
      return CheckResult(true, result);
   }

   CheckResult processClosePrice(SELECT_ORDER_TYPE type, long& tickets[]) {
      debug("Processing close price with type " + type + " and tickets " + longArrayToString(tickets) + ", mode: " + this.mode, TRD_INF_TYPE);
      double result = 0;

      switch(this.mode) {
         case TI_TOTAL: {
            if (type == CLOSE_TRADES) {
               filterClosedTickets(tickets);
            }
            for (int i = 0; i < ArraySize(tickets); i++) {
               if (selectTicketForProcessing(tickets[i], type) != true) {
                  return CheckResult(false, 0);
               }
               result += getClosePrice(type, tickets[i]);
            }
            break;
         }
         case TI_LAST: {
            int lastIndex = ArraySize(tickets) - 1;
            if (selectTicketForProcessing(tickets[lastIndex], type) != true) {
               return CheckResult(false, 0);
            }
            result = getClosePrice(type, tickets[lastIndex]);
            break;
         }
         case TI_CORRESPONDING: {
            if (selectTicketForProcessing(tickets[0], type) != true) {
               return CheckResult(false, 0);
            }
            result = getClosePrice(type, tickets[0]);
            break;
         }
         default: {
            error("Unexpected mode with tickets " + longArrayToString(tickets) + " of type " + type + " while processing close price");
            return CheckResult(false, 0);
         }
      }

      debug("Got result of close price: " + result, TRD_INF_TYPE);
      return CheckResult(true, result);
   }

   CheckResult processVolumeSize(SELECT_ORDER_TYPE type, long& tickets[]) {
      debug("Processing volume size with type " + type + " and tickets " + longArrayToString(tickets) + ", mode: " + this.mode, TRD_INF_TYPE);
      double result = 0;

      switch(this.mode) {
         case TI_TOTAL: {
            for (int i = 0; i < ArraySize(tickets); i++) {
               if (selectTicketForProcessing(tickets[i], type) != true) {
                  return CheckResult(false, 0);
               }
               result += getVolumeSize(type, tickets[i]);
            }
            break;
         }
         case TI_LAST: {
            int lastIndex = ArraySize(tickets) - 1;
            if (selectTicketForProcessing(tickets[lastIndex], type) != true) {
               return CheckResult(false, 0);
            }
            result = getVolumeSize(type, tickets[lastIndex]);
            break;
         }
         case TI_CORRESPONDING: {
            if (selectTicketForProcessing(tickets[0], type) != true) {
               return CheckResult(false, 0);
            }
            result = getVolumeSize(type, tickets[0]);
            break;
         }
         default: {
            error("Unexpected mode with tickets " + longArrayToString(tickets) + " of type " + type + " while processing volume size");
            return CheckResult(false, 0);
         }
      }

      debug("Got result of volume size: " + result, TRD_INF_TYPE);
      return CheckResult(true, result);
   }

   CheckResult processProfit(SELECT_ORDER_TYPE type, long& tickets[]) {
      debug("Processing profit with type " + type + " and tickets " + longArrayToString(tickets) + ", mode: " + this.mode + ", profit mode: " + this.profitMode, TRD_INF_TYPE);
      double result = 0;

      switch(this.mode) {
         case TI_TOTAL: {
            for (int i = 0; i < ArraySize(tickets); i++) {
               if (selectTicketForProcessing(tickets[i], type) != true) {
                  return CheckResult(false, 0);
               }

               CheckResult profitResult = getCurrentProfit(type, tickets[i]);
               if (!profitResult.success) {
                  error("Got error on current profit calculation, while processing profit");
                  return CheckResult(false, 0);
               }
               double profit = customNormalizeDouble(profitResult.result);
               result += profit;
            }
            break;
         }
         case TI_LAST: {
            int lastIndex = ArraySize(tickets) - 1;
            if (selectTicketForProcessing(tickets[lastIndex], type) != true) {
               return CheckResult(false, 0);
            }

            CheckResult profitResult = getCurrentProfit(type, tickets[lastIndex]);
            if (!profitResult.success) {
               error("Got error on current profit calculation, while processing profit");
               return CheckResult(false, 0);
            }
            double profit = customNormalizeDouble(profitResult.result);
            result = profit;
            break;
         }
         case TI_CORRESPONDING: {
            if (selectTicketForProcessing(tickets[0], type) != true) {
               return CheckResult(false, 0);
            }

            CheckResult profitResult = getCurrentProfit(type, tickets[0]);
            if (!profitResult.success) {
               error("Got error on current profit calculation, while processing profit");
               return CheckResult(false, 0);
            }
            double profit = customNormalizeDouble(profitResult.result);
            result = profit;
            break;
         }
         default: {
            error("Unexpected mode with tickets " + longArrayToString(tickets) + " of type " + type + " while processing profit");
            return CheckResult(false, 0);
         }
      }

      CheckResult calculatedProfitOption = calculateProfitOption(result);
      if (!calculatedProfitOption.success) {
         return CheckResult(false, 0);
      }

      debug("Got result of profit: " + calculatedProfitOption.result, TRD_INF_TYPE);
      return calculatedProfitOption;
   }

   CheckResult processStopLoss(SELECT_ORDER_TYPE type, long& tickets[]) {
      debug("Processing stop loss with type " + type + " and tickets " + longArrayToString(tickets) + ", mode: " + this.mode, TRD_INF_TYPE);
      double result = 0;

      switch(this.mode) {
         case TI_TOTAL: {
            for (int i = 0; i < ArraySize(tickets); i++) {
               if (selectTicketForProcessing(tickets[i], type) != true) {
                  return CheckResult(false, 0);
               }
               result += getStopLoss(type, tickets[i]);
            }
            break;
         }
         case TI_LAST: {
            int lastIndex = ArraySize(tickets) - 1;
            if (selectTicketForProcessing(tickets[lastIndex], type) != true) {
               return CheckResult(false, 0);
            }
            result = getStopLoss(type, tickets[lastIndex]);
            break;
         }
         case TI_CORRESPONDING: {
            if (selectTicketForProcessing(tickets[0], type) != true) {
               return CheckResult(false, 0);
            }
            result = getStopLoss(type, tickets[0]);
            break;
         }
         default: {
            error("Unexpected mode with tickets " + longArrayToString(tickets) + " of type " + type + " while processing stop loss");
            return CheckResult(false, 0);
         }
      }

      debug("Got result of stop loss: " + result, TRD_INF_TYPE);
      return CheckResult(true, result);
   }

   CheckResult calculateProfitOption(double profit) {
      debug("Calculating profit option for profit: " + profit + ", profit mode: " + this.profitMode, TRD_INF_TYPE);
      double result = 0;

      if (this.profitMode == TI_FIXED_PIPS) {
         result = priceToPips(profit, Symbol());
      } else if (this.profitMode == TI_FIXED_AMOUNT) {
         result = profit;
      } else if (this.profitMode == TI_EQUITY_RISK) {
         double accountEquity = AccountInfoDouble(ACCOUNT_EQUITY);
         result = profit * 100 / accountEquity;
      } else if (this.profitMode == TI_BALANCE_RISK) {
         double accountBalance = AccountInfoDouble(ACCOUNT_BALANCE);
         result = profit * 100 / accountBalance;
      } else {
         error("Unexpected profit option: " + this.profitMode);
         return CheckResult(false, 0);
      }

      result = customNormalizeDouble(result);
      debug("Got result of profit option " + result, TRD_INF_TYPE);
      return CheckResult(true, result);
   }

   bool selectTicketForProcessing(long ticket, SELECT_ORDER_TYPE type) {
      if (selectTicket(ticket, type) != true) {
         error("Couldn't select ticket " + ticket + " of type " + type + " while processing " + this.value + " with mode " + this.mode);
         return false;;
      }
      return true;
   }

   bool validateParameters(SELECT_ORDER_TYPE type) {
      if (this.mode == TI_TOTAL || this.mode == TI_LAST) {
         if (sharedData.ticket != -1) {
            error("Shared ticket id, but mode is not corresponding in Trade Info operand");
            return false;
         }
      }
      if (this.mode == TI_CORRESPONDING) {
         if (sharedData.ticket == -1) {
            error("Not shared ticket id for corresponding mode in Trade Info operand");
            return false;
         }
      }

      if (this.value == TI_CLOSE_PRICE) {
         if (type != CLOSE_TRADES) {
            error("Unexpected trades type (" + type + ") for Close Price mode in Trade Info (Close Trades available only)");
            return false;
         }
      }
      if (this.value == TI_PROFIT) {
         if (type != OPEN_TRADES && type != CLOSE_TRADES) {
            error("Unexpected trades type (" + type + ") for Profit mode in Trade Info (Open Trades and Close Trades available only)");
            return false;
         }
      }

      return true;
   }

   void filterClosedTickets(long &tickets[]) {
      int count = ArraySize(tickets);
      long positionIds[];
      int positionIdsCounter = 0;
      ArrayResize(positionIds, count);

      int writeIndex = 0;

      for (int i = 0; i < count; i++) {
         long ticket = tickets[i];
         long positionId = (long)HistoryDealGetInteger(ticket, DEAL_POSITION_ID);

         bool isExists = false;
         for (int j = 0; j < positionIdsCounter; j++) {
            if (positionIds[j] == positionId) {
               isExists = true;
               break;
            }
         }
         if (isExists) {
            continue;
         }

         tickets[writeIndex++] = ticket;
         positionIds[positionIdsCounter++] = positionId;
      }

      ArrayResize(tickets, writeIndex);
   }

};
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Formula blocks classes                                           |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| OCO Processor block                                              |
//+------------------------------------------------------------------+
void OCOProcessor() {
	int ordersTotal = OrdersTotal();

	for (int orderIndex = ordersTotal - 1; orderIndex >= 0; orderIndex--) {
	  long ticket = OrderGetTicket(orderIndex);
      if (selectOrder(ticket) && isOrderTypeValid(ticket)) {

			if (orders.ContainsKey(ticket)) {
			   break;
			}

			string comment = OrderGetString(ORDER_COMMENT);
			int ocoPrefixLength = StringLen(OCO_PREFIX);
			if (StringSubstr(comment, 0, ocoPrefixLength) == OCO_PREFIX)
			{
			   int ocoPostfixLength = StringLen(OCO_POSTFIX);
			   string ocoTicketStr = StringSubstr(comment, ocoPrefixLength, StringLen(comment) - ocoPostfixLength);
			   long ocoTicket = StringToInteger(ocoTicketStr);

			   if (!orders.ContainsValue(ocoTicket)) {
                  orders.TrySetValue(ticket, ocoTicket);
			   }
			}
		}
	}

   long keys[];
   long values[];
   orders.CopyTo(keys, values);
   for (int i=0; i<orders.Count(); i++) {
      long ticket = keys[i];
      long ocoTicket = values[i];

      if (!selectOrder(ticket) || !isOrderTypeValid(ticket)) {
         if (selectOrder(ocoTicket) && isOrderTypeValid(ocoTicket)) {
				if (deleteOrder(ocoTicket))
				{
				   orders.Remove(ticket);
				}
			}
      }

      if (!selectOrder(ocoTicket) || !isOrderTypeValid(ocoTicket)) {
         if (selectOrder(ticket) && isOrderTypeValid(ticket)) {
				if (deleteOrder(ticket))
				{
				   orders.Remove(ticket);
				}
			}
      }

   }

   ArrayFree(keys);
   ArrayFree(values);
}

bool selectOrder(long ticket) {
   if (OrderSelect(ticket)) {
      return true;
   } else {
      error("Could not select order ticket: " + ticket);
   }
   return false;
}

bool isOrderTypeValid(long ticket) {
   ENUM_ORDER_TYPE type = (ENUM_ORDER_TYPE)OrderGetInteger(ORDER_TYPE);
   if (type == ORDER_TYPE_BUY_LIMIT || type == ORDER_TYPE_SELL_LIMIT ||
      type == ORDER_TYPE_BUY_STOP || type == ORDER_TYPE_SELL_STOP) {
      return true;
   } else {
      debug("Not valid type for OCO of ticket " + ticket + ": " + type);
   }
   return false;
}

bool deleteOrder(long ticket) {
   debug("deleteOrder");
   clearError();
   MqlTradeRequest request;
   MqlTradeResult result;
   MqlTradeCheckResult checkResult;
   ZeroMemory(request);
   ZeroMemory(result);
   ZeroMemory(checkResult);

   request.order=ticket;
   request.action=TRADE_ACTION_REMOVE;
   request.comment="Cancel pending order: " + ticket;

   if (!OrderCheck(request, checkResult)) {
		error("OrderCheck() failed for delete order operation: ticket: " + ticket + ", " + (string)checkResult.comment + " (" + (string)checkResult.retcode + ")");
		printOrderRequestInfo(request);
		printOrderCheckInfo(checkResult);
		checkError("Check order for deletion");
		return false;
	}

   bool success = OrderSend(request, result);
   if (success) {
	   info("OrderSend() succeed while removing, order id: " + result.order + " - " + (string)result.comment + " (" + (string)result.retcode + ")");
	   printOrderResultInfo(result);
	} else {
	   error("OrderSend() failed while removing, order id: " + result.order + " - " + (string)result.comment + " (" + (string)result.retcode + ")");
	   printOrderResultInfo(result);
	   checkError("Send order for deletion");
	   return false;
	}

   if (result.retcode != TRADE_RETCODE_DONE) {
      error("Got unexpected code on order " + ticket + " delete, error code: " + result.retcode);
      checkError("Unexpected code in order deletion");
      return false;
   }

   if (selectOrder(ticket)) {
      error("Deleting went wrong, order " + ticket + " not deleted");
      checkError("Select order for deletion");
      return false;
   }

   checkError("Delete order");
   return true;
}

//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Expiration Processor block                                       |
//+------------------------------------------------------------------+
void ExpirationProcessor() {
    // PERF + LEAK FIX. Original cost: every tick this did CopyTo (heap-allocating
    // keys[]/values[]) and scanned the WHOLE map, even when nothing was due. The
    // map also LEAKED: entries are added on every order open but only removed on
    // expiration-close or CloseTrade-block close, so positions exited via SL/TP
    // left stale entries forever -> the map grew unboundedly -> the processor
    // dominated runtime. Fixes: (1) early-out when empty; (2) iterate the
    // SNAPSHOT deterministically (n = ArraySize(keys)) instead of re-reading the
    // shrinking Count() mid-loop; (3) drop the entry when its position no longer
    // exists (a gone position is never closed either way, so no trade action
    // changes - it just stops the leak). Validated trade-identical on the ORB EA.
    if (ticketExpirations.Count() == 0) {
        return;
    }

    debug("ExpirationProcessor (got " + ticketExpirations.Count() + " tickets)", EXP_PRCSSR_TYPE);

    long keys[];
    long values[];
    ticketExpirations.CopyTo(keys, values);
    datetime currentDateTime = TimeCurrent();
    int n = ArraySize(keys);

    for (int i = 0; i < n; i++) {
        long ticket = keys[i];
        datetime ticketExpiration = values[i];

        if (currentDateTime >= ticketExpiration) {
            if (PositionSelectByTicket(ticket)) {
                if (closeTrade(ticket, "Expiration for ticket " + ticket)) {
                    info("Ticket " + ticket + " has been closed because of expiration");
                    ticketExpirations.Remove(ticket);
                } else {
                    warn("Couldn't close ticket " + ticket + " because of expiration: " + GetLastError());
                }
            } else {
                warn("Couldn't select index by ticket" + ticket + ": " + GetLastError());
                ticketExpirations.Remove(ticket);
            }
        }
    }
    ArrayFree(keys);
    ArrayFree(values);
}
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Comment Processor block                                              |
//+------------------------------------------------------------------+
void CommentProcessor() {
   // Display-only: the on-chart comment is invisible during a non-visual
   // backtest, so skip the per-tick string building + map copies + Comment()
   // there. Live trading and visual-mode backtests run it exactly as before.
   // No trade state is read or written here, so skipping changes nothing the
   // engine sees -> trade lists are unaffected.
   if (MQLInfoInteger(MQL_TESTER) && !MQLInfoInteger(MQL_VISUAL_MODE)) {
      return;
   }

   string result = PROFECTUS_LABEL + "\n\n";

   string inputsKeys[];
   UserItem* inputsValues[];
   inputsMap.CopyTo(inputsKeys, inputsValues);

   for (int i = 0; i < inputsMap.Count(); i++) {
      UserItem* value = inputsValues[i];
      if (value.isTracked == true) {
         result = result + inputsKeys[i] + "=" + value.value + "\n";
      }
   }

   string variablesKeys[];
   UserItem* variablesValues[];
   variablesMap.CopyTo(variablesKeys, variablesValues);

   for (int i = 0; i < variablesMap.Count(); i++) {
      UserItem* value = variablesValues[i];
      if (value.isTracked == true) {
         result = result + variablesKeys[i] + "=" + value.value + "\n";
      }
   }

   Comment(result);

}
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Select context block functions                                   |
//+------------------------------------------------------------------+
enum SELECT_TRADE_SOURCE_TYPE {
    MANUAL_TRADES_ONLY, AUTOMATIC_TRADES_ONLY, MANUAL_AND_AUTOMATIC_TRADES
};


struct SelectContextBlockParams: BlockParameters {
   SELECT_ORDER_TYPE type;
   string groups;
   string symbols;
   SELECT_TRADE_DIRECTION_TYPE tradeDirection;
   SELECT_TRADE_SOURCE_TYPE tradeSource;
};
class SelectContextBlock: public Block {
private:
   SELECT_ORDER_TYPE type;
   int groups[];
   string symbols[];
   SELECT_TRADE_DIRECTION_TYPE tradeDirection;
   SELECT_TRADE_SOURCE_TYPE tradeSource;

public:
   SelectContextBlock(const SelectContextBlockParams& params) {
      this.type = params.type;
      ParseStringToIntArray(this.groups, params.groups);
      ParseStringToStringArray(this.symbols, params.symbols);
      this.tradeDirection = params.tradeDirection;
      this.tradeSource = params.tradeSource;
      this.index = params.index;
      ParseStringToIntArray(this.nextBlocks, params.nextBlocks);
   }

    void execute(int& nextBlocks[]) {
      debug("Executing SelectContextBlock");
      clearError();
      long tickets[];

      switch(this.type) {
         case PENDING_ORDERS: {
            int totalOrders = OrdersTotal();
            debug("Got " + totalOrders + " pending orders", SLCT_CNTXT_TYPE);

            for (int i = 0; i < totalOrders; i++) {
               debug("Processing index " + i + " of orders", SLCT_CNTXT_TYPE);
               ulong ticket  = OrderGetTicket(i);
               if (ticket == 0) {
                  error("Could not get order by index = " + i);
                  checkError("Select context block");
                  continue;
               }
               debug("Got ticket = " + ticket + " by index " + i, SLCT_CNTXT_TYPE);

               int ticketMagicNumber = OrderGetInteger(ORDER_MAGIC);
               string ticketSymbol = OrderGetString(ORDER_SYMBOL);
               ENUM_DEAL_TYPE orderType = OrderGetInteger(ORDER_TYPE);
               SELECT_TRADE_DIRECTION_TYPE ticketTradeDirection = -1;
               if (orderType == ORDER_TYPE_BUY || orderType == ORDER_TYPE_BUY_LIMIT || orderType == ORDER_TYPE_BUY_STOP) {
                  ticketTradeDirection = BUYS_ONLY;
               } else if (orderType == ORDER_TYPE_SELL || orderType == ORDER_TYPE_SELL_LIMIT || orderType == ORDER_TYPE_SELL_STOP) {
                  ticketTradeDirection = SELLS_ONLY;
               }
               SELECT_TRADE_SOURCE_TYPE ticketTradeSource = -1;
               if (ticketMagicNumber == 0) {
                  ticketTradeSource = MANUAL_TRADES_ONLY;
               } else {
                  ticketTradeSource =AUTOMATIC_TRADES_ONLY;
               }

               debug("Collected ticket " + ticket + " info: ticketMagicNumber=" + ticketMagicNumber + ", ticketSymbol=" + ticketSymbol + ", ticketTradeDirection=" + ticketTradeDirection + ", ticketTradeSource=" + ticketTradeSource, SLCT_CNTXT_TYPE);
               checkError("Select context block");
               if (checkTicket(ticketMagicNumber, ticketSymbol, ticketTradeDirection, ticketTradeSource)) {
                  int size = ArraySize(tickets);
                  ArrayResize(tickets, size + 1);
					   tickets[size] = ticket;
               }

            }
            break;
         }
         case OPEN_TRADES: {
            int totalPositons = PositionsTotal();
            debug("Got " + totalPositons + " positions", SLCT_CNTXT_TYPE);

            for (int i = 0; i < totalPositons; i++) {
               debug("Processing index " + i + " of positions", SLCT_CNTXT_TYPE);
               ulong ticket  = PositionGetTicket(i);
               if (ticket == 0) {
                  error("Could not get position by index = " + i);
                  checkError("Select context block");
                  continue;
               }
               debug("Got ticket = " + ticket + " by index " + i, SLCT_CNTXT_TYPE);

               int ticketMagicNumber = PositionGetInteger(POSITION_MAGIC);
               string ticketSymbol = PositionGetString(POSITION_SYMBOL);
               ENUM_DEAL_TYPE positionType = PositionGetInteger(POSITION_TYPE);
               SELECT_TRADE_DIRECTION_TYPE ticketTradeDirection = -1;
               if (positionType == POSITION_TYPE_BUY) {
                  ticketTradeDirection = BUYS_ONLY;
               } else if (positionType == POSITION_TYPE_SELL) {
                  ticketTradeDirection = SELLS_ONLY;
               }
               SELECT_TRADE_SOURCE_TYPE ticketTradeSource = -1;
               if (ticketMagicNumber == 0) {
                  ticketTradeSource = MANUAL_TRADES_ONLY;
               } else {
                  ticketTradeSource = AUTOMATIC_TRADES_ONLY;
               }

               debug("Collected ticket " + ticket + " info: ticketMagicNumber=" + ticketMagicNumber + ", ticketSymbol=" + ticketSymbol + ", ticketTradeDirection=" + ticketTradeDirection + ", ticketTradeSource=" + ticketTradeSource, SLCT_CNTXT_TYPE);
               checkError("Select context block");
               if (checkTicket(ticketMagicNumber, ticketSymbol, ticketTradeDirection, ticketTradeSource)) {
                  int size = ArraySize(tickets);
                  ArrayResize(tickets, size + 1);
					   tickets[size] = ticket;
               }

            }
            break;
         }
         case CLOSE_TRADES: {
	         bool historySelected = HistorySelect(0, TimeCurrent() + 1);
	         if (!historySelected) {
	            error("Couldn't select history in block " + this.index);
	         }

            int totalDeals = HistoryDealsTotal();
            debug("Got " + totalDeals + " history deals", SLCT_CNTXT_TYPE);

            for (int i = 0; i < totalDeals; i++) {
               debug("Processing index " + i + " of history deals", SLCT_CNTXT_TYPE);
               ulong ticket  = HistoryDealGetTicket(i);
               if (ticket == 0) {
                  error("Could not get history deal by index = " + i);
                  checkError("Select context block");
                  continue;
               }

               ENUM_DEAL_TYPE dealType = (ENUM_DEAL_TYPE)HistoryDealGetInteger(ticket, DEAL_TYPE);
               if (dealType != DEAL_TYPE_BUY && dealType != DEAL_TYPE_SELL) {
                  continue;
               }

               if (!checkIsTradeClosed(ticket)) {
                  continue;
               }

               debug("Got ticket = " + ticket + " by index " + i, SLCT_CNTXT_TYPE);

               int ticketMagicNumber = HistoryDealGetInteger(ticket, DEAL_MAGIC);
               string ticketSymbol = HistoryDealGetString(ticket, DEAL_SYMBOL);
               SELECT_TRADE_DIRECTION_TYPE ticketTradeDirection = -1;
               if (dealType == DEAL_TYPE_BUY) {
                  ticketTradeDirection = BUYS_ONLY;
               } else if (dealType == DEAL_TYPE_SELL) {
                  ticketTradeDirection = SELLS_ONLY;
               }
               SELECT_TRADE_SOURCE_TYPE ticketTradeSource = -1;
               if (ticketMagicNumber == 0) {
                  ticketTradeSource = MANUAL_TRADES_ONLY;
               } else {
                  ticketTradeSource = AUTOMATIC_TRADES_ONLY;
               }

               debug("Collected ticket " + ticket + " info: ticketMagicNumber=" + ticketMagicNumber + ", ticketSymbol=" + ticketSymbol + ", ticketTradeDirection=" + ticketTradeDirection + ", ticketTradeSource=" + ticketTradeSource, SLCT_CNTXT_TYPE);
               checkError("Select context block");
               if (checkTicket(ticketMagicNumber, ticketSymbol, ticketTradeDirection, ticketTradeSource)) {
                  int size = ArraySize(tickets);
                  ArrayResize(tickets, size + 1);
					   tickets[size] = ticket;
               }

            }
            break;
         }
      }

      SelectOrdersContext* context = new SelectOrdersContext();
      context.type = this.type;
      CopyObjects(context.tickets, tickets);

      deleteOldMapValue(selectContextMap, this.index);
      selectContextMap.TrySetValue(this.index, context);
      debug("Created new context on " + this.index + " index with " + ArraySize(tickets) + " tickets");

      if (ArraySize(tickets) > 0) {
         CopyObjects(nextBlocks, this.nextBlocks);
      }

      ArrayFree(tickets);
   }

private:

   bool checkTicket(int ticketMagicNumber, string ticketSymbol, SELECT_TRADE_DIRECTION_TYPE ticketTradeDirection, SELECT_TRADE_SOURCE_TYPE ticketTradeSource) {
      if (ArraySize(this.groups) > 0) {
         if (contains(this.groups, ticketMagicNumber - EXPERT_MAGIC) == -1) {
            debug("Not suitable group, ticket got " + (ticketMagicNumber - EXPERT_MAGIC) + ", expected " + intArrayToString(this.groups), SLCT_CNTXT_TYPE);
            return false;
         }
      } else {
         if (ticketMagicNumber != EXPERT_MAGIC) {
            debug("Not suitable magic number, ticket got " + ticketMagicNumber + ", expected " + EXPERT_MAGIC, SLCT_CNTXT_TYPE);
            return false;
         }
      }
      if (ArraySize(this.symbols) > 0) {
         if (contains(this.symbols, ticketSymbol) == -1) {
            debug("Not suitable symbol, ticket got " + ticketSymbol + ", expected " + stringArrayToString(this.symbols), SLCT_CNTXT_TYPE);
            return false;
         }
      }
      if (ticketTradeDirection == -1 ||
         (ticketTradeDirection != this.tradeDirection && this.tradeDirection != BUYS_AND_SELLS)) {
            debug("Not suitable trade direction, ticket got " + ticketTradeDirection + ", expected " + this.tradeDirection, SLCT_CNTXT_TYPE);
            return false;
      }
      if (ticketTradeSource != this.tradeSource && this.tradeSource != MANUAL_AND_AUTOMATIC_TRADES) {
         debug("Not suitable trade source, ticket got " + ticketTradeSource + ", expected " + this.tradeSource, SLCT_CNTXT_TYPE);
         return false;
      }
      return true;
   }

   bool checkIsTradeClosed(long ticketCheck) {
      int positionId = HistoryDealGetInteger(ticketCheck, DEAL_POSITION_ID);
      if ((ENUM_DEAL_ENTRY)HistoryDealGetInteger(ticketCheck, DEAL_ENTRY) == DEAL_ENTRY_OUT) {
         return true;
      }

      for (int i = 0; i < HistoryDealsTotal(); i++) {
         int ticket = HistoryDealGetTicket(i);
         int ticketDealPositionId = HistoryDealGetInteger(ticket, DEAL_POSITION_ID);
         ENUM_DEAL_ENTRY ticketDealEntry = (ENUM_DEAL_ENTRY)HistoryDealGetInteger(ticket, DEAL_ENTRY);
         if (positionId == ticketDealPositionId && ticketDealEntry == DEAL_ENTRY_OUT) {
            return true;
         }
      }
      return false;
   }

};

class SelectContextBlockCached: public Block {
private:
   SELECT_ORDER_TYPE type;
   int groups[];
   string symbols[];
   SELECT_TRADE_DIRECTION_TYPE tradeDirection;
   SELECT_TRADE_SOURCE_TYPE tradeSource;

public:
   SelectContextBlockCached(const SelectContextBlockParams& params) {
      this.type = params.type;
      ParseStringToIntArray(this.groups, params.groups);
      ParseStringToStringArray(this.symbols, params.symbols);
      this.tradeDirection = params.tradeDirection;
      this.tradeSource = params.tradeSource;
      this.index = params.index;
      ParseStringToIntArray(this.nextBlocks, params.nextBlocks);
   }

    void execute(int& nextBlocks[]) {
      debug("Executing SelectContextBlock");
      clearError();
      long tickets[];

      switch(this.type) {
         case PENDING_ORDERS: {
            int totalOrders = OrdersTotal();
            debug("Got " + totalOrders + " pending orders", SLCT_CNTXT_TYPE);

            for (int i = 0; i < totalOrders; i++) {
               debug("Processing index " + i + " of orders", SLCT_CNTXT_TYPE);
               ulong ticket  = OrderGetTicket(i);
               if (ticket == 0) {
                  error("Could not get order by index = " + i);
                  checkError("Select context block");
                  continue;
               }
               debug("Got ticket = " + ticket + " by index " + i, SLCT_CNTXT_TYPE);

               int ticketMagicNumber = OrderGetInteger(ORDER_MAGIC);
               string ticketSymbol = OrderGetString(ORDER_SYMBOL);
               ENUM_DEAL_TYPE orderType = OrderGetInteger(ORDER_TYPE);
               SELECT_TRADE_DIRECTION_TYPE ticketTradeDirection = -1;
               if (orderType == ORDER_TYPE_BUY || orderType == ORDER_TYPE_BUY_LIMIT || orderType == ORDER_TYPE_BUY_STOP) {
                  ticketTradeDirection = BUYS_ONLY;
               } else if (orderType == ORDER_TYPE_SELL || orderType == ORDER_TYPE_SELL_LIMIT || orderType == ORDER_TYPE_SELL_STOP) {
                  ticketTradeDirection = SELLS_ONLY;
               }
               SELECT_TRADE_SOURCE_TYPE ticketTradeSource = -1;
               if (ticketMagicNumber == 0) {
                  ticketTradeSource = MANUAL_TRADES_ONLY;
               } else {
                  ticketTradeSource =AUTOMATIC_TRADES_ONLY;
               }

               debug("Collected ticket " + ticket + " info: ticketMagicNumber=" + ticketMagicNumber + ", ticketSymbol=" + ticketSymbol + ", ticketTradeDirection=" + ticketTradeDirection + ", ticketTradeSource=" + ticketTradeSource, SLCT_CNTXT_TYPE);
               checkError("Select context block");
               if (checkTicket(ticketMagicNumber, ticketSymbol, ticketTradeDirection, ticketTradeSource)) {
                  int size = ArraySize(tickets);
                  ArrayResize(tickets, size + 1);
					   tickets[size] = ticket;
               }

            }
            break;
         }
         case OPEN_TRADES: {
            int totalPositons = PositionsTotal();
            debug("Got " + totalPositons + " positions", SLCT_CNTXT_TYPE);

            for (int i = 0; i < totalPositons; i++) {
               debug("Processing index " + i + " of positions", SLCT_CNTXT_TYPE);
               ulong ticket  = PositionGetTicket(i);
               if (ticket == 0) {
                  error("Could not get position by index = " + i);
                  checkError("Select context block");
                  continue;
               }
               debug("Got ticket = " + ticket + " by index " + i, SLCT_CNTXT_TYPE);

               int ticketMagicNumber = PositionGetInteger(POSITION_MAGIC);
               string ticketSymbol = PositionGetString(POSITION_SYMBOL);
               ENUM_DEAL_TYPE positionType = PositionGetInteger(POSITION_TYPE);
               SELECT_TRADE_DIRECTION_TYPE ticketTradeDirection = -1;
               if (positionType == POSITION_TYPE_BUY) {
                  ticketTradeDirection = BUYS_ONLY;
               } else if (positionType == POSITION_TYPE_SELL) {
                  ticketTradeDirection = SELLS_ONLY;
               }
               SELECT_TRADE_SOURCE_TYPE ticketTradeSource = -1;
               if (ticketMagicNumber == 0) {
                  ticketTradeSource = MANUAL_TRADES_ONLY;
               } else {
                  ticketTradeSource = AUTOMATIC_TRADES_ONLY;
               }

               debug("Collected ticket " + ticket + " info: ticketMagicNumber=" + ticketMagicNumber + ", ticketSymbol=" + ticketSymbol + ", ticketTradeDirection=" + ticketTradeDirection + ", ticketTradeSource=" + ticketTradeSource, SLCT_CNTXT_TYPE);
               checkError("Select context block");
               if (checkTicket(ticketMagicNumber, ticketSymbol, ticketTradeDirection, ticketTradeSource)) {
                  int size = ArraySize(tickets);
                  ArrayResize(tickets, size + 1);
					   tickets[size] = ticket;
               }

            }
            break;
         }
         case CLOSE_TRADES: {
	         bool historySelected = HistorySelect(0, TimeCurrent() + 1);
	         if (!historySelected) {
	            error("Couldn't select history in block " + this.index);
	         }

            int totalDeals = HistoryDealsTotal();
            debug("Got " + totalDeals + " history deals", SLCT_CNTXT_TYPE);

            for (int i = 0; i < totalDeals; i++) {
               debug("Processing index " + i + " of history deals", SLCT_CNTXT_TYPE);
               ulong ticket  = HistoryDealGetTicket(i);
               if (ticket == 0) {
                  error("Could not get history deal by index = " + i);
                  checkError("Select context block");
                  continue;
               }

               ENUM_DEAL_TYPE dealType = (ENUM_DEAL_TYPE)HistoryDealGetInteger(ticket, DEAL_TYPE);
               if (dealType != DEAL_TYPE_BUY && dealType != DEAL_TYPE_SELL) {
                  continue;
               }

               if (!checkIsTradeClosed(ticket)) {
                  continue;
               }

               debug("Got ticket = " + ticket + " by index " + i, SLCT_CNTXT_TYPE);

               int ticketMagicNumber = HistoryDealGetInteger(ticket, DEAL_MAGIC);
               string ticketSymbol = HistoryDealGetString(ticket, DEAL_SYMBOL);
               SELECT_TRADE_DIRECTION_TYPE ticketTradeDirection = -1;
               if (dealType == DEAL_TYPE_BUY) {
                  ticketTradeDirection = BUYS_ONLY;
               } else if (dealType == DEAL_TYPE_SELL) {
                  ticketTradeDirection = SELLS_ONLY;
               }
               SELECT_TRADE_SOURCE_TYPE ticketTradeSource = -1;
               if (ticketMagicNumber == 0) {
                  ticketTradeSource = MANUAL_TRADES_ONLY;
               } else {
                  ticketTradeSource = AUTOMATIC_TRADES_ONLY;
               }

               debug("Collected ticket " + ticket + " info: ticketMagicNumber=" + ticketMagicNumber + ", ticketSymbol=" + ticketSymbol + ", ticketTradeDirection=" + ticketTradeDirection + ", ticketTradeSource=" + ticketTradeSource, SLCT_CNTXT_TYPE);
               checkError("Select context block");
               if (checkTicket(ticketMagicNumber, ticketSymbol, ticketTradeDirection, ticketTradeSource)) {
                  int size = ArraySize(tickets);
                  ArrayResize(tickets, size + 1);
					   tickets[size] = ticket;
               }

            }
            break;
         }
      }

      // PERF: rebuild the published context only when the selected ticket set
      // actually changed. Positions/orders change on trade events, not per
      // tick, so on the vast majority of ticks this skips a heap new+delete,
      // an array copy, a map remove and a map write whose result would be
      // identical to what is already published. When the set HAS changed, the
      // code below runs byte-identically to the original. Downstream readers
      // fetch from selectContextMap on every use, so they observe the same data.
      SelectOrdersContext* oldContext = NULL;
      bool contextUnchanged = false;
      if (selectContextMap.TryGetValue(this.index, oldContext) && CheckPointer(oldContext) != POINTER_INVALID) {
         if (oldContext.type == this.type && ArraySize(oldContext.tickets) == ArraySize(tickets)) {
            contextUnchanged = true;
            for (int t = 0; t < ArraySize(tickets); t++) {
               if (oldContext.tickets[t] != tickets[t]) {
                  contextUnchanged = false;
                  break;
               }
            }
         }
      }

      if (!contextUnchanged) {
         SelectOrdersContext* context = new SelectOrdersContext();
         context.type = this.type;
         CopyObjects(context.tickets, tickets);

         deleteOldMapValue(selectContextMap, this.index);
         selectContextMap.TrySetValue(this.index, context);
         debug("Created new context on " + this.index + " index with " + ArraySize(tickets) + " tickets");
      }

      if (ArraySize(tickets) > 0) {
         CopyObjects(nextBlocks, this.nextBlocks);
      }

      ArrayFree(tickets);
   }

private:

   bool checkTicket(int ticketMagicNumber, string ticketSymbol, SELECT_TRADE_DIRECTION_TYPE ticketTradeDirection, SELECT_TRADE_SOURCE_TYPE ticketTradeSource) {
      if (ArraySize(this.groups) > 0) {
         if (contains(this.groups, ticketMagicNumber - EXPERT_MAGIC) == -1) {
            debug("Not suitable group, ticket got " + (ticketMagicNumber - EXPERT_MAGIC) + ", expected " + intArrayToString(this.groups), SLCT_CNTXT_TYPE);
            return false;
         }
      } else {
         if (ticketMagicNumber != EXPERT_MAGIC) {
            debug("Not suitable magic number, ticket got " + ticketMagicNumber + ", expected " + EXPERT_MAGIC, SLCT_CNTXT_TYPE);
            return false;
         }
      }
      if (ArraySize(this.symbols) > 0) {
         if (contains(this.symbols, ticketSymbol) == -1) {
            debug("Not suitable symbol, ticket got " + ticketSymbol + ", expected " + stringArrayToString(this.symbols), SLCT_CNTXT_TYPE);
            return false;
         }
      }
      if (ticketTradeDirection == -1 ||
         (ticketTradeDirection != this.tradeDirection && this.tradeDirection != BUYS_AND_SELLS)) {
            debug("Not suitable trade direction, ticket got " + ticketTradeDirection + ", expected " + this.tradeDirection, SLCT_CNTXT_TYPE);
            return false;
      }
      if (ticketTradeSource != this.tradeSource && this.tradeSource != MANUAL_AND_AUTOMATIC_TRADES) {
         debug("Not suitable trade source, ticket got " + ticketTradeSource + ", expected " + this.tradeSource, SLCT_CNTXT_TYPE);
         return false;
      }
      return true;
   }

   bool checkIsTradeClosed(long ticketCheck) {
      int positionId = HistoryDealGetInteger(ticketCheck, DEAL_POSITION_ID);
      if ((ENUM_DEAL_ENTRY)HistoryDealGetInteger(ticketCheck, DEAL_ENTRY) == DEAL_ENTRY_OUT) {
         return true;
      }

      for (int i = 0; i < HistoryDealsTotal(); i++) {
         int ticket = HistoryDealGetTicket(i);
         int ticketDealPositionId = HistoryDealGetInteger(ticket, DEAL_POSITION_ID);
         ENUM_DEAL_ENTRY ticketDealEntry = (ENUM_DEAL_ENTRY)HistoryDealGetInteger(ticket, DEAL_ENTRY);
         if (positionId == ticketDealPositionId && ticketDealEntry == DEAL_ENTRY_OUT) {
            return true;
         }
      }
      return false;
   }

};
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Check profit loss block functions                                |
//+------------------------------------------------------------------+
enum CHECK_PROFIT_LOSS_MODE {
    DEPOSIT, PERCENT_OF_ACCOUNT, PERCENT_OF_EQUITY, PERCENT_OF_BALANCE, PIPS
};
enum CHECK_PROFIT_LOSS_TYPE {
    PROFIT, LOSS
};

template <typename T>
struct CheckProfitLossBlockParams: BlockParameters {
   CHECK_PROFIT_LOSS_MODE checkMode;
   CHECK_PROFIT_LOSS_TYPE checkType;
   Value<T> amountValue;
   string compareOperator;
   int contextCreatorIndex;
};
template <typename T>
class CheckProfitLossBlock: public Block {
private:
   CHECK_PROFIT_LOSS_MODE checkMode;
   CHECK_PROFIT_LOSS_TYPE checkType;
   Value<T> amountValue;
   string compareOperator;
   int contextCreatorIndex;

public:
   CheckProfitLossBlock(const CheckProfitLossBlockParams<T>& params) {
      this.checkMode = params.checkMode;
      this.checkType = params.checkType;
      this.amountValue = params.amountValue;
      this.compareOperator = params.compareOperator;
      this.contextCreatorIndex = params.contextCreatorIndex;
      this.index = params.index;
      ParseStringToIntArray(this.nextBlocks, params.nextBlocks);
   }

    void execute(int& nextBlocks[]) {
      debug("Executing CheckProfitLossBlock");
      clearError();

      SelectOrdersContext* context;
      long filteredTickets[];

      if (this.contextCreatorIndex == -1) {
         error("Context creator block not defined for block with index " + this.index + "!");
         return;
      }

      if (!selectContextMap.TryGetValue(this.contextCreatorIndex, context)) {
         error("Context data for context creator block " + this.contextCreatorIndex + " not found!");
         return;
      }
      debug("Got input context of type " + context.type + " with " + ArraySize(context.tickets) + " tickets", CHK_PROF_LOSS_TYPE);

      if (context.type == PENDING_ORDERS) {
         error("Check profit/loss is not available for pending orders! Block index " + this.index);
      } else {
         for (int i = 0; i < ArraySize(context.tickets); i++) {
            long ticket = context.tickets[i];
            debug("Processing ticket " + ticket, CHK_PROF_LOSS_TYPE);
            if (checkTicket(context.type, ticket)) {
               debug("Adding ticket " + ticket, CHK_PROF_LOSS_TYPE);
               int size = ArraySize(filteredTickets);
               ArrayResize(filteredTickets, size + 1);
               filteredTickets[size] = ticket;
            } else {
               debug("Filtering out ticket " + ticket, CHK_PROF_LOSS_TYPE);
            }
         }
      }

      SelectOrdersContext* filteredContext = new SelectOrdersContext();
      filteredContext.type = context.type;
      CopyObjects(filteredContext.tickets, filteredTickets);

      deleteOldMapValue(selectContextMap, this.index);
      selectContextMap.TrySetValue(this.index, filteredContext);
      debug("Created new check profit loss context on " + this.index + " index with " + ArraySize(filteredTickets) + " tickets");

      if (ArraySize(filteredTickets) > 0) {
         CopyObjects(nextBlocks, this.nextBlocks);
      }

      ArrayFree(filteredTickets);
   }

private:

   bool checkTicket(SELECT_ORDER_TYPE type, long ticket) {
      CheckResult profitCalcResult = getCurrentProfit(type, ticket);
      if (!profitCalcResult.success) {
         error("Got error on current profit calculation, block with index " + this.index);
         return false;
      }
      double profit = customNormalizeDouble(profitCalcResult.result);

      CheckResult amountCalcResult = calculateAmount();
      if (!amountCalcResult.success) {
         error("Got error on amount calculation, block with index " + this.index);
         return false;
      }
      double amount = amountCalcResult.result;

      debug("Comparing profit " + profit + " with amount " + amount + " using operator " + compareOperator + " and type " + this.checkType, CHK_PROF_LOSS_TYPE);
      switch(this.checkType) {
         case PROFIT: {
            return CompareValues(profit, amount, compareOperator);
         }
         case LOSS: {
            double loss = (profit < 0.0 ? -profit : 0.0);
            return CompareValues(loss, amount, compareOperator);
         }
      }
      error("Unexpected check profit/loss check type: " + this.checkType);
      return false;
   }

   CheckResult calculateAmount() {
      double amount = 0;

      switch(this.checkMode) {
         case DEPOSIT: {
            amount = this.amountValue.execute();
            break;
         }
         case PERCENT_OF_ACCOUNT: {
            amount = AccountInfoDouble(ACCOUNT_PROFIT) * this.amountValue.execute() / 100;
            break;
         }
         case PERCENT_OF_EQUITY: {
            amount = AccountInfoDouble(ACCOUNT_EQUITY) * this.amountValue.execute() / 100;
            break;
         }
         case PERCENT_OF_BALANCE: {
            amount = customNormalizeDouble(AccountInfoDouble(ACCOUNT_BALANCE)) * this.amountValue.execute() / 100;
            break;
         }
         case PIPS: {
            amount = pipsToProfit(this.amountValue.execute());
            break;
         }
         default: {
            error("Unexpected check mode: " + this.checkMode);
            return CheckResult(false, 0.0);
         }
      }

      debug("Calculated amount for mode " + this.checkMode + " and value " + this.amountValue.execute() + ": " + amount, CHK_PROF_LOSS_TYPE);
      checkError("Check profit loss block");
      return CheckResult(true, amount);
   }

   double pipsToProfit(double pips) {
      double pipsInPrice = pipsToPrice(pips, Symbol());
      double lots = PositionGetDouble(POSITION_VOLUME);
      double tickValue = SymbolInfoDouble(Symbol(), SYMBOL_TRADE_TICK_VALUE);
      double tickSize = SymbolInfoDouble(Symbol(), SYMBOL_TRADE_TICK_SIZE);
      double moneyChangeValue = (pipsInPrice / tickSize) * tickValue;
      return moneyChangeValue * lots;
   }

};
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Once per trade/order block functions                             |
//+------------------------------------------------------------------+
struct OncePerTradeOrderBlockParams: BlockParameters {
   int contextCreatorIndex;
};
class OncePerTradeOrderBlock: public Block {
private:
   int contextCreatorIndex;

public:
   OncePerTradeOrderBlock(const OncePerTradeOrderBlockParams& params) {
      this.contextCreatorIndex = params.contextCreatorIndex;
      this.index = params.index;
      ParseStringToIntArray(this.nextBlocks, params.nextBlocks);
   }

    void execute(int& nextBlocks[]) {
      debug("Executing OncePerTradeOrderBlock");
      clearError();

      SelectOrdersContext* context;
      TradeOrderMarkers* markers;

      long filteredTickets[];
      long markedTickets[];

      if (this.contextCreatorIndex == -1) {
         error("Context creator block not defined for block with index " + this.index + "!");
         return;
      }

      if (!selectContextMap.TryGetValue(this.contextCreatorIndex, context)) {
         error("Context data for context creator block " + this.contextCreatorIndex + " not found!");
         return;
      }
      debug("Got input context of type " + context.type + " with " + ArraySize(context.tickets) + " tickets", ONC_PR_TRD_TYPE);

      if (tradeOrderMarkers.TryGetValue(this.index, markers)) {
         CopyObjects(markedTickets, markers.tickets);
      }

      for (int i = 0; i < ArraySize(context.tickets); i++) {
         long ticket = context.tickets[i];
         debug("Processing ticket " + ticket, ONC_PR_TRD_TYPE);
         if (checkTicket(ticket, markedTickets)) {
            int size = ArraySize(filteredTickets);
            ArrayResize(filteredTickets, size + 1);
            filteredTickets[size] = ticket;

            int markersSize = ArraySize(markedTickets);
            ArrayResize(markedTickets, markersSize + 1);
            markedTickets[markersSize] = ticket;
         }
      }

      SelectOrdersContext* filteredContext = new SelectOrdersContext();
      filteredContext.type = context.type;
      CopyObjects(filteredContext.tickets, filteredTickets);
      deleteOldMapValue(selectContextMap, this.index);
      selectContextMap.TrySetValue(this.index, filteredContext);
      debug("Created new filtered context on " + this.index + " index with " + ArraySize(filteredTickets) + " tickets");

      TradeOrderMarkers* updatedTradeOrderMarkers = new TradeOrderMarkers();
      updatedTradeOrderMarkers.type = context.type;
      CopyObjects(updatedTradeOrderMarkers.tickets, markedTickets);
      deleteOldMapValue(tradeOrderMarkers, this.index);
      tradeOrderMarkers.TrySetValue(this.index, updatedTradeOrderMarkers);
      debug("Updated markers on " + this.index + " index with " + ArraySize(markedTickets) + " tickets");

      if (ArraySize(filteredTickets) > 0) {
         CopyObjects(nextBlocks, this.nextBlocks);
      }

      ArrayFree(filteredTickets);
      ArrayFree(markedTickets);
   }

private:

   bool checkTicket(long ticket, long& markedTickets[]) {
      if (contains(markedTickets, ticket) != -1) {
         debug("Ticket " + ticket + " has already been marked by block with " + this.index + " index", ONC_PR_TRD_TYPE);
         return false;
      }
      return true;
   }

};
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Close trade block functions                                      |
//+------------------------------------------------------------------+
struct CloseTradeBlockParams: BlockParameters {
   int contextCreatorIndex;
   Value<double> closePartially;
};
class CloseTradeBlock: public Block {
private:
   int contextCreatorIndex;
   Value<double> closePartially;

public:
   CloseTradeBlock(const CloseTradeBlockParams& params) {
      this.contextCreatorIndex = params.contextCreatorIndex;
      this.closePartially = params.closePartially;
      this.index = params.index;
      ParseStringToIntArray(this.nextBlocks, params.nextBlocks);
   }

   void execute(int& nextBlocks[]) {
      debug("Executing CloseTradeBlock");
      clearError();

      SelectOrdersContext* context;

      if (this.contextCreatorIndex == -1) {
         error("Context creator block not defined for block with index " + this.index + "!");
         return;
      }

      if (!selectContextMap.TryGetValue(this.contextCreatorIndex, context)) {
         error("Context data for context creator block " + this.contextCreatorIndex + " not found!");
         return;
      }
      debug("Got input context of type " + context.type + " with " + ArraySize(context.tickets) + " tickets", CLS_TRD_TYPE);

      if (context.type != OPEN_TRADES) {
         error("Wrong context type (" + context.type + ") got, while processing close trade in block " + this.index + ", only " + OPEN_TRADES + " is available");
         return;
      }

      for (int i = 0; i < ArraySize(context.tickets); i++) {
         long ticket = context.tickets[i];
         double closePercent = this.closePartially.execute();
         debug("Processing ticket " + ticket + " partially percent value is " + closePercent, CLS_TRD_TYPE);

         if (closeTradePartial(ticket, closePercent, "Closing partially - " + closePercent)) {

            if (!PositionSelectByTicket(ticket)) {
               debug("Ticket " + ticket + " has been fully closed", CLS_TRD_TYPE);
               ticketExpirations.Remove(ticket);
            }

            debug("Ticket " + ticket + " partially closed", CLS_TRD_TYPE);
         } else {
            error("Failed to close trade " + ticket);
            return;
         }
      }

      CopyObjects(nextBlocks, this.nextBlocks);
   }

};
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Modify stop loss take profit block functions                     |
//+------------------------------------------------------------------+
template <typename T>
struct ModifySLTPBlockParams: BlockParameters {
   int contextCreatorIndex;
   string priceMode;
   StopLoss* stopLoss;
   TakeProfit* takeProfit;
   T customPrice;
   bool updateSL;
   bool updateTP;
   SharedData *sharedData;
};
template <typename T>
class ModifySLTPBlock: public Block {
private:
   int contextCreatorIndex;
   string priceMode;
   StopLoss* stopLoss;
   TakeProfit* takeProfit;
   T customPrice;
   bool updateSL;
   bool updateTP;
   SharedData *sharedData;

public:
   ModifySLTPBlock(const ModifySLTPBlockParams<T>& params) {
      this.contextCreatorIndex = params.contextCreatorIndex;
      this.index = params.index;
      this.priceMode = params.priceMode;
      this.stopLoss = params.stopLoss;
      this.takeProfit = params.takeProfit;
      this.customPrice = params.customPrice;
      this.updateSL = params.updateSL;
      this.updateTP = params.updateTP;
      this.sharedData = params.sharedData;
      ParseStringToIntArray(this.nextBlocks, params.nextBlocks);
   }

   void execute(int& nextBlocks[]) {
      debug("Executing ModifySLTPBlock");
      clearError();

      SelectOrdersContext* context;

      if (this.contextCreatorIndex == -1) {
         error("Context creator block not defined for block with index " + this.index + "!");
         return;
      }

      if (!selectContextMap.TryGetValue(this.contextCreatorIndex, context)) {
         error("Context data for context creator block " + this.contextCreatorIndex + " not found!");
         return;
      }
      debug("Got input context of type " + context.type + " with " + ArraySize(context.tickets) + " tickets", MDF_SL_TP_TYPE);

      if (context.type != OPEN_TRADES && context.type != PENDING_ORDERS) {
         error("Wrong context type (" + context.type + ") got, while processing modify stop loss take profit in block " + this.index);
         return;
      }

      for (int i = 0; i < ArraySize(context.tickets); i++) {
         long ticket = context.tickets[i];
         debug("Processing ticket " + ticket, MDF_SL_TP_TYPE);
         this.sharedData.ticket = ticket;
         if (!modifyStopLossTakeProfit(ticket, context.type)) {
            error("Got error while processing modify SL TP for ticket " + ticket + " of type " + context.type);
            return;
         }
         debug("Modifying SL TP of ticket " + ticket + " has been successfully processed", MDF_SL_TP_TYPE);
      }

      CopyObjects(nextBlocks, this.nextBlocks);
   }

   bool modifyStopLossTakeProfit(long ticket, SELECT_ORDER_TYPE type) {

		string symbol = Symbol();
		int digits = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);

		if (!selectTicket(ticket, type)) {
		   error("Couldn't select ticket " + ticket + " of type " + type + " while modifying SL TP");
		   return false;
		}
		ActionType actionType = defineActionType(type);
		if (actionType == UNDEFINED) {
		   error("Couldn't define action type for ticket " + ticket + " of type " + type + " while modifying SL TP");
		   return false;
		}
		debug("Got action type " + actionType, MDF_SL_TP_TYPE);

        // Calculating reference price
		double price;
		if (this.priceMode == "PRICE_OPEN") {
		   debug("Processing with open price reference", MDF_SL_TP_TYPE);
		   price = getOpenPrice(type, -1);
		} else if (this.priceMode == "PRICE_CUSTOM") {
		   debug("Processing with custom price reference", MDF_SL_TP_TYPE);
		   price = customPrice.execute();
		} else {
		   error("Got unexpected priceMode " + priceMode + " while processing modify SL TP for ticket " + ticket + " of type " + type);
		   return false;
		}
		debug("Got price " + price + " for price mode " + this.priceMode, MDF_SL_TP_TYPE);

		// Calculating new SL and TP
		double oldStopLoss = customNormalizeDouble(getStopLoss(type, -1));
		double oldTakeProfit = customNormalizeDouble(getTakeProfit(type, -1));

		this.stopLoss.setType(actionType);
		this.takeProfit.setType(actionType);
		this.stopLoss.referencePrice = price;
		this.takeProfit.referencePrice = price;

		ResultSLTPFractions resultSLTPFractions = calculateSLTPFractions(this.stopLoss, this.takeProfit, oldStopLoss, oldTakeProfit);
		StopLossFractions stopLossFractions = resultSLTPFractions.stopLoss;
		TakeProfitFractions takeProfitFractions = resultSLTPFractions.takeProfit;

		double stopLoss = (this.updateSL == true) ? stopLossFractions.stopLossLevel : oldStopLoss;
		double takeProfit = (this.updateTP == true) ? takeProfitFractions.takeProfitLevel : oldTakeProfit;
		debug("Got oldStopLoss = " + oldStopLoss + ", oldTakeProfit = " + oldTakeProfit, MDF_SL_TP_TYPE);
		debug("Got stopLoss = " + stopLoss + ", takeProfit = " + takeProfit, MDF_SL_TP_TYPE);

		bool success;
		if (stopLoss != oldStopLoss || takeProfit != oldTakeProfit) {
		   success = changeStopLossTakeProfit(ticket, actionType, type, stopLoss, takeProfit);
		   checkError("Sent modify order ticket");
		}

		return true;
   }

};
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Delete pending orders block functions                            |
//+------------------------------------------------------------------+
struct DeletePendingOrdersBlockParams: BlockParameters {
   int contextCreatorIndex;
};
class DeletePendingOrdersBlock: public Block {
private:
   int contextCreatorIndex;

public:
   DeletePendingOrdersBlock(const DeletePendingOrdersBlockParams& params) {
      this.contextCreatorIndex = params.contextCreatorIndex;
      this.index = params.index;
      ParseStringToIntArray(this.nextBlocks, params.nextBlocks);
   }

   void execute(int& nextBlocks[]) {
      debug("Executing DeletePendingOrdersBlock");
      clearError();

      SelectOrdersContext* context;

      if (this.contextCreatorIndex == -1) {
         error("Context creator block not defined for block with index " + this.index + "!");
         return;
      }

      if (!selectContextMap.TryGetValue(this.contextCreatorIndex, context)) {
         error("Context data for context creator block " + this.contextCreatorIndex + " not found!");
         return;
      }
      debug("Got input context of type " + context.type + " with " + ArraySize(context.tickets) + " tickets", DLT_PND_ORDR_TYPE);

      if (context.type != PENDING_ORDERS) {
         error("Wrong context type (" + context.type + ") got, while processing delete pending orders in block " + this.index + ", only " + PENDING_ORDERS + " is available");
         return;
      }

      for (int i = 0; i < ArraySize(context.tickets); i++) {
         long ticket = context.tickets[i];
         debug("Processing ticket " + ticket, DLT_PND_ORDR_TYPE);

         if (deleteOrder(ticket)) {
            if (!OrderSelect(ticket)) {
               debug("Ticket " + ticket + " has been deleted", DLT_PND_ORDR_TYPE);
               orders.Remove(ticket);
            }
            debug("Ticket " + ticket + " delete finished", DLT_PND_ORDR_TYPE);
         } else {
            error("Failed to delete pending order " + ticket);
            return;
         }
      }

      CopyObjects(nextBlocks, this.nextBlocks);
   }

};
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Once a time block classes                                        |
//+------------------------------------------------------------------+
struct OnceATimeBlockParams: BlockParameters {
   string sourceTime;
   Value<datetime> startTime;
};

class OnceATimeBlock: public Block {
private:
   string sourceTime;
   Value<datetime> startTime;

   datetime lastExecutedDateTime;

public:

   OnceATimeBlock(const OnceATimeBlockParams& params) {
      this.sourceTime = params.sourceTime;
      this.startTime = params.startTime;
      ParseStringToIntArray(this.nextBlocks, params.nextBlocks);
      this.index = params.index;
      this.lastExecutedDateTime = 0;
   }

   void execute(int& nextBlocks[]) {
      debug("Executing OnceATimeBlock");
      datetime currentDateTime = 0;

      if (sourceTime == "server") {
         currentDateTime = TimeCurrent();
      } else if (sourceTime == "local") {
         currentDateTime = TimeLocal();
      } else if (sourceTime == "utc") {
         currentDateTime = TimeGMT();
      } else {
         error("Unexpected source time: " + sourceTime );
         return;
      }

      if (checkIsExecutionTime(currentDateTime)) {
         debug("Execution time for OnceATimeBlock block at index: " + this.index, ONC_A_DAY_TYPE);
         lastExecutedDateTime = currentDateTime;
         CopyObjects(nextBlocks, this.nextBlocks);
      } else {
         int res[] = { -1 };
         CopyObjects(nextBlocks, res);
      }
   }

private:

   bool checkIsExecutionTime(datetime currentDateTime) {
      MqlDateTime currentDateTimeStruct;
      TimeToStruct(currentDateTime, currentDateTimeStruct);

      if (lastExecutedDateTime != 0) {
         MqlDateTime lastExecutedDateTimeStruct;
         TimeToStruct(lastExecutedDateTime, lastExecutedDateTimeStruct);

         if (
            lastExecutedDateTimeStruct.year == currentDateTimeStruct.year &&
            lastExecutedDateTimeStruct.mon == currentDateTimeStruct.mon &&
            lastExecutedDateTimeStruct.day == currentDateTimeStruct.day
         ) {
            return false;
         }
      }

      datetime startDateTime = StringToTime(
         currentDateTimeStruct.year + "." + currentDateTimeStruct.mon + "." + currentDateTimeStruct.day + " " + startTime.execute()
      );
      datetime endDateTime = startDateTime + 59;
      debug("currentDateTime: " + currentDateTime + ", startDateTime: " + startDateTime + ", endDateTime: " + endDateTime, ONC_A_DAY_TYPE);

      if (startDateTime >= endDateTime) {
         error("Not valid start and end times: " + startDateTime + " " + endDateTime);
         return false;
      }

      return currentDateTime >= startDateTime && currentDateTime <= endDateTime;
   }

};

class OnceATimeBlockCached: public Block {
private:
   string sourceTime;
   Value<datetime> startTime;

   datetime lastExecutedDateTime;
   int      cacheDayKey;
   datetime cachedStartDateTime;

public:

   OnceATimeBlockCached(const OnceATimeBlockParams& params) {
      this.sourceTime = params.sourceTime;
      this.startTime = params.startTime;
      ParseStringToIntArray(this.nextBlocks, params.nextBlocks);
      this.index = params.index;
      this.lastExecutedDateTime = 0;
      this.cacheDayKey = -1;
   }

   void execute(int& nextBlocks[]) {
      datetime currentDateTime = 0;

      if (sourceTime == "server") {
         currentDateTime = TimeCurrent();
      } else if (sourceTime == "local") {
         currentDateTime = TimeLocal();
      } else if (sourceTime == "utc") {
         currentDateTime = TimeGMT();
      } else {
         error("Unexpected source time: " + sourceTime );
         return;
      }

      if (checkIsExecutionTime(currentDateTime)) {
         lastExecutedDateTime = currentDateTime;
         CopyObjects(nextBlocks, this.nextBlocks);
      } else {
         int res[] = { -1 };
         CopyObjects(nextBlocks, res);
      }
   }

private:

   bool checkIsExecutionTime(datetime currentDateTime) {
      MqlDateTime currentDateTimeStruct;
      TimeToStruct(currentDateTime, currentDateTimeStruct);

      if (lastExecutedDateTime != 0) {
         MqlDateTime lastExecutedDateTimeStruct;
         TimeToStruct(lastExecutedDateTime, lastExecutedDateTimeStruct);

         if (
            lastExecutedDateTimeStruct.year == currentDateTimeStruct.year &&
            lastExecutedDateTimeStruct.mon == currentDateTimeStruct.mon &&
            lastExecutedDateTimeStruct.day == currentDateTimeStruct.day
         ) {
            return false;
         }
      }

      int dayKey = currentDateTimeStruct.year * 10000 + currentDateTimeStruct.mon * 100 + currentDateTimeStruct.day;
      if (dayKey != cacheDayKey) {
         cachedStartDateTime = StringToTime(
            currentDateTimeStruct.year + "." + currentDateTimeStruct.mon + "." + currentDateTimeStruct.day + " " + startTime.execute()
         );
         cacheDayKey = dayKey;
      }
      datetime startDateTime = cachedStartDateTime;
      datetime endDateTime = startDateTime + 59;

      if (startDateTime >= endDateTime) {
         error("Not valid start and end times: " + startDateTime + " " + endDateTime);
         return false;
      }

      return currentDateTime >= startDateTime && currentDateTime <= endDateTime;
   }

};
//+------------------------------------------------------------------+
struct DeleteChartObjectsBlockParams: BlockParameters {
};
class DeleteChartObjectsBlock: public Block {
public:
  DeleteChartObjectsBlock(DeleteChartObjectsBlockParams& params) {
    ParseStringToIntArray(this.nextBlocks, params.nextBlocks);
    this.index = params.index;
  }
  void execute(int& nextBlocks[]) {
     debug("Executing DeleteChartObjectsBlock");
     clearError();
     ObjectsDeleteAll(0, "");
     CopyObjects(nextBlocks, this.nextBlocks);
  }
};

//+------------------------------------------------------------------+

class DrawOnChartBlockParams {
public:
   string name;
   int myColor;
   ENUM_OBJECT objectType;
   string nextBlocks;
   int index;

   Value<double> level;
   Value<int> candleId;

   DrawOnChartBlockParams() {}

   DrawOnChartBlockParams(DrawOnChartBlockParams& old) {
      this.name = old.name;
      this.candleId = old.candleId;
      this.index = old.index;
      this.nextBlocks = old.nextBlocks;
      this.level = old.level;
      this.objectType = old.objectType;
      this.myColor = old.myColor;
   }
};
class DrawOnChartBlock: public Block {
private:
   DrawOnChartBlockParams params[];

public:
   DrawOnChartBlock(DrawOnChartBlockParams& params[], int index, string nextBlocks) {
      ArrayResize(this.params, ArraySize(params));
      for (int i = 0; i < ArraySize(params); i++) {
         this.params[i] = new DrawOnChartBlockParams(params[i]);
      }
      this.index = index;
      ParseStringToIntArray(this.nextBlocks, nextBlocks);
   }

   void execute(int& nextBlocks[]) {
      debug("Executing DrawOnChartBlock, going to draw " + ArraySize(this.params) + " objects.");
      clearError();
      static const int ARROW_MARGIN_PIPS = 30;
      static const int ARROW_WIDTH = 5;
      static const int MIN_ARROW_MARGIN_RATIO = 0.3;

      for (int i = 0; i < ArraySize(this.params); i++) {
         DrawOnChartBlockParams objectParams = this.params[i];
         double level = objectParams.level.execute();
         int myColor = objectParams.myColor;
         int objectType = objectParams.objectType;

         if (objectType == OBJ_HLINE) {
            string name = objectParams.name;
            debug("Drawing " + name + " with level=" + DoubleToString(level) + ", color=" + IntegerToString(myColor));

            if (ObjectFind(0, name) >= 0) {
               continue;
            }

            bool created = ObjectCreate(0, name, OBJ_HLINE, 0, TimeCurrent(), level);
            if (!created) {
               warn("Object " + name + " wasn't created!");
            }
            ObjectSetInteger(0, name, OBJPROP_COLOR, myColor);
            ObjectSetDouble(0, name, OBJPROP_PRICE, level);
         } else if (objectParams.objectType == OBJ_ARROW_DOWN) {
            string name = objectParams.name + "_" + (long)TimeCurrent();
            int candleId = objectParams.candleId.execute();
            double low = iLow(NULL, PERIOD_CURRENT, candleId);
            double high = iHigh(NULL, PERIOD_CURRENT, candleId);
            double candleHeight = high - low;
            double minOffset = ARROW_MARGIN_PIPS * Point();
            double offset = MathMax(candleHeight * MIN_ARROW_MARGIN_RATIO, minOffset);
            datetime time = iTime(NULL, PERIOD_CURRENT, candleId);

            debug("Drawing " + name + " with candleId=" + IntegerToString(candleId) + ", color=" + IntegerToString(myColor) + ", highPrice=" + DoubleToString(high) + ", time=" + TimeToString(time));
            bool created = ObjectCreate(0, name, OBJ_ARROW_DOWN, 0, time, high + offset);
            if (!created) {
               warn("Object " + name + " wasn't created!");
            }
            ObjectSetInteger(0, name, OBJPROP_COLOR, myColor);
            ObjectSetInteger(0, name, OBJPROP_WIDTH, ARROW_WIDTH);
            ObjectSetInteger(0 ,name, OBJPROP_ANCHOR, (int)ANCHOR_BOTTOM);
         } else {
            error("Object type of object " + objectParams.name + " isn't supported!");
         }
      }

      CopyObjects(nextBlocks, this.nextBlocks);
   }
};

//+------------------------------------------------------------------+

//<ProjectData>eyJub2RlcyI6W3siaWQiOiJPbmNlUGVyVGlja0R0b19hNmQ4YjY2Ni1hMjkzLTQzYmEtYWU4Yy1kZDA2ZTBlZGQ5OWMiLCJkYXRhIjp7ImlzUHJlbWl1bSI6ZmFsc2UsImxhYmVsIjoiUnVuIHBlciB0aWNrIiwiZGVzY3JpcHRpb24iOiJSdW5zIGNvbm5lY3RlZCBibG9ja3Mgb25seSBvbmNlIGVhY2ggdGltZSB0aGUgcHJpY2UgY2hhbmdlcy4iLCJibG9ja1R5cGUiOiJPbmNlUGVyVGlja0R0byIsImludmFsaWQiOmZhbHNlfSwidHlwZSI6ImlucHV0IiwicG9zaXRpb24iOnsieCI6MjQwLCJ5IjoyNTV9LCJtZWFzdXJlZCI6eyJ3aWR0aCI6MTQ4LCJoZWlnaHQiOjQ1fSwic2VsZWN0ZWQiOmZhbHNlfSx7ImlkIjoiNDExNDI5NGUtYTg4MC00MTA2LTgzYTktYWNmMjI1MjFmZDBjIiwidHlwZSI6InR3b091dHB1dHMiLCJkYXRhIjp7ImlzUHJlbWl1bSI6ZmFsc2UsImxhYmVsIjoiTUEgNSA+IE1BIDIwIiwiZGVzY3JpcHRpb24iOiJDaGVja3MgaWYgdHdvIHZhbHVlcyBvciBleHByZXNzaW9ucyBtZWV0IGEgY2hvc2VuIGNvbXBhcmlzb24gKGUuZy4sID4sIDwsID0pIiwiYmxvY2tUeXBlIjoiSWZCbG9ja0R0byIsImxlZnQiOnsiaWQiOiJmYzU5ZWMwOS1iNzEzLTRjMmEtYmRkMi01NTZhZWFhYjNlMjkiLCJ0eXBlIjoiSW5kaWNhdG9yIiwiZGF0YSI6eyJuYW1lIjoiTW92aW5nQXZlcmFnZUluZGljYXRvciIsIm1hUGVyaW9kIjp7ImRhdGFUeXBlIjoiRE9VQkxFIiwidmFsdWUiOjV9LCJtYVNoaWZ0Ijp7ImRhdGFUeXBlIjoiRE9VQkxFIiwidmFsdWUiOjB9LCJtYU1ldGhvZCI6Ik1PREVfU01BIiwiYXBwbGllZFByaWNlIjoiUFJJQ0VfQ0xPU0UifSwibWF0aE9wZXJhdG9yIjoiKyIsIm1hdGhWYWx1ZSI6eyJkYXRhVHlwZSI6IkRPVUJMRSIsInZhbHVlIjowfSwiY2FuZGxlSWQiOnsiZGF0YVR5cGUiOiJET1VCTEUiLCJ2YWx1ZSI6MX0sInRpbWVGcmFtZSI6eyJkYXRhVHlwZSI6IlRJTUVGUkFNRSIsInZhbHVlIjoiUEVSSU9EX0NVUlJFTlQifX0sIm9wZXJhdG9yIjoiPiIsInJpZ2h0Ijp7ImlkIjoiZDM0YmRkOWMtNTVkMC00MzFlLTgwMjAtZGMwN2IxMDgxODY4IiwidHlwZSI6IkluZGljYXRvciIsImRhdGEiOnsibmFtZSI6Ik1vdmluZ0F2ZXJhZ2VJbmRpY2F0b3IiLCJtYVBlcmlvZCI6eyJkYXRhVHlwZSI6IkRPVUJMRSIsInZhbHVlIjoyMH0sIm1hU2hpZnQiOnsiZGF0YVR5cGUiOiJET1VCTEUiLCJ2YWx1ZSI6MH0sIm1hTWV0aG9kIjoiTU9ERV9TTUEiLCJhcHBsaWVkUHJpY2UiOiJQUklDRV9DTE9TRSJ9LCJtYXRoT3BlcmF0b3IiOiIrIiwibWF0aFZhbHVlIjp7ImRhdGFUeXBlIjoiRE9VQkxFIiwidmFsdWUiOjB9LCJjYW5kbGVJZCI6eyJkYXRhVHlwZSI6IkRPVUJMRSIsInZhbHVlIjoxfSwidGltZUZyYW1lIjp7ImRhdGFUeXBlIjoiVElNRUZSQU1FIiwidmFsdWUiOiJQRVJJT0RfQ1VSUkVOVCJ9fSwiaW52YWxpZCI6ZmFsc2V9LCJwb3NpdGlvbiI6eyJ4IjoyMzQuNzM5ODEzNTA1MjA0NzgsInkiOjMzOS42ODc3NDc3MDUwODZ9LCJzZWxlY3RlZCI6ZmFsc2UsIm1lYXN1cmVkIjp7IndpZHRoIjoxNjIsImhlaWdodCI6NDV9LCJkcmFnZ2luZyI6ZmFsc2V9LHsiaWQiOiI3YjdhNDNjZC1kNjQ2LTRiM2UtYjVjOC05ZmNkYTA0OWMxNzgiLCJ0eXBlIjoidHdvT3V0cHV0cyIsImRhdGEiOnsiaXNQcmVtaXVtIjpmYWxzZSwibGFiZWwiOiJQcmljZSA+IE1BQ09ORk8iLCJkZXNjcmlwdGlvbiI6IkNoZWNrcyBpZiB0d28gdmFsdWVzIG9yIGV4cHJlc3Npb25zIG1lZXQgYSBjaG9zZW4gY29tcGFyaXNvbiAoZS5nLiwgPiwgPCwgPSkiLCJibG9ja1R5cGUiOiJJZkJsb2NrRHRvIiwibGVmdCI6eyJpZCI6ImJlZmJmMmE4LTNmODMtNGI5ZS04ODkyLWUzMmYxZTBkZmQ1ZCIsInR5cGUiOiJNYXJrZXRQcm9wZXJ0eSIsImRhdGEiOnsibmFtZSI6IkFza0JpZE1pZCIsInByaWNlIjoiQVNLIn19LCJvcGVyYXRvciI6Ij4iLCJyaWdodCI6eyJpZCI6ImQzNGJkZDljLTU1ZDAtNDMxZS04MDIwLWRjMDdiMTA4MTg2OCIsInR5cGUiOiJJbmRpY2F0b3IiLCJkYXRhIjp7Im5hbWUiOiJNb3ZpbmdBdmVyYWdlSW5kaWNhdG9yIiwibWFQZXJpb2QiOnsiZGF0YVR5cGUiOiJJTlBVVCIsInZhbHVlIjoiTUFfY29uZm8ifSwibWFTaGlmdCI6eyJkYXRhVHlwZSI6IkRPVUJMRSIsInZhbHVlIjowfSwibWFNZXRob2QiOiJNT0RFX1NNQSIsImFwcGxpZWRQcmljZSI6IlBSSUNFX0NMT1NFIn0sIm1hdGhPcGVyYXRvciI6IisiLCJtYXRoVmFsdWUiOnsiZGF0YVR5cGUiOiJET1VCTEUiLCJ2YWx1ZSI6MH0sImNhbmRsZUlkIjp7ImRhdGFUeXBlIjoiRE9VQkxFIiwidmFsdWUiOjF9LCJ0aW1lRnJhbWUiOnsiZGF0YVR5cGUiOiJUSU1FRlJBTUUiLCJ2YWx1ZSI6IlBFUklPRF9DVVJSRU5UIn19LCJpbnZhbGlkIjpmYWxzZX0sInBvc2l0aW9uIjp7IngiOjIzMi41NjUwODIyNTAxNDgwNywieSI6NDI1LjE4OTU4NjgzOTk3NjI0fSwic2VsZWN0ZWQiOmZhbHNlLCJtZWFzdXJlZCI6eyJ3aWR0aCI6MTg4LCJoZWlnaHQiOjQ1fSwiZHJhZ2dpbmciOmZhbHNlfSx7ImlkIjoiZGY2NzE2NzEtZWExNy00YmIzLTllN2MtMzUyNDBhNDZhYWRkIiwidHlwZSI6InR3b091dHB1dHMiLCJkYXRhIjp7ImlzUHJlbWl1bSI6ZmFsc2UsImxhYmVsIjoiQnVsbGlzaCBFbmd1bGZpbmciLCJkZXNjcmlwdGlvbiI6IkNoZWNrcyBpZiB0d28gdmFsdWVzIG9yIGV4cHJlc3Npb25zIG1lZXQgYSBjaG9zZW4gY29tcGFyaXNvbiAoZS5nLiwgPiwgPCwgPSkiLCJibG9ja1R5cGUiOiJJZkJsb2NrRHRvIiwibGVmdCI6eyJpZCI6Ijk1YTU1Nzg3LWY2NTMtNGQ4Yy1hZmIxLTllN2NhN2ZkMTYwZiIsInR5cGUiOiJDYW5kbGUiLCJwYXJhbWV0ZXIiOiJDTE9TRSIsImNhbmRsZUlkIjp7ImRhdGFUeXBlIjoiRE9VQkxFIiwidmFsdWUiOjF9LCJ0aW1lRnJhbWUiOnsidmFsdWUiOiJQRVJJT0RfQ1VSUkVOVCIsImRhdGFUeXBlIjoiVElNRUZSQU1FIn19LCJvcGVyYXRvciI6Ij4iLCJyaWdodCI6eyJpZCI6ImFkOGQyYjAxLWUzMTYtNDBjYS05MDRlLTlmNjY4NzJiN2RiZiIsInR5cGUiOiJDYW5kbGUiLCJwYXJhbWV0ZXIiOiJISUdIIiwiY2FuZGxlSWQiOnsiZGF0YVR5cGUiOiJET1VCTEUiLCJ2YWx1ZSI6M30sInRpbWVGcmFtZSI6eyJ2YWx1ZSI6IlBFUklPRF9DVVJSRU5UIiwiZGF0YVR5cGUiOiJUSU1FRlJBTUUifX0sImludmFsaWQiOmZhbHNlfSwicG9zaXRpb24iOnsieCI6MjMzLjcxMzc4MDYwNTE0NTIsInkiOjUyOC4xOTMyNjUxMDk3NTY3fSwic2VsZWN0ZWQiOmZhbHNlLCJtZWFzdXJlZCI6eyJ3aWR0aCI6MTgwLCJoZWlnaHQiOjQ1fSwiZHJhZ2dpbmciOmZhbHNlfSx7ImlkIjoiOWVkNGFhMGEtYzU0YS00ZjExLTg2NWQtYWY0ODNmNTUzYjI0IiwidHlwZSI6InR3b091dHB1dHMiLCJkYXRhIjp7ImlzUHJlbWl1bSI6ZmFsc2UsImxhYmVsIjoiTGFyZ2VyIENhbmRsZSBCb2R5IiwiZGVzY3JpcHRpb24iOiJDaGVja3MgaWYgdHdvIHZhbHVlcyBvciBleHByZXNzaW9ucyBtZWV0IGEgY2hvc2VuIGNvbXBhcmlzb24gKGUuZy4sID4sIDwsID0pIiwiYmxvY2tUeXBlIjoiSWZCbG9ja0R0byIsImxlZnQiOnsiaWQiOiJmOTViNDA3Mi0wZTRjLTQxNDItOGU2Mi05NmJhNDI4ZTAxNWIiLCJ0eXBlIjoiQ2FuZGxlIiwicGFyYW1ldGVyIjoiQk9EWSIsImNhbmRsZUlkIjp7ImRhdGFUeXBlIjoiRE9VQkxFIiwidmFsdWUiOjJ9LCJ0aW1lRnJhbWUiOnsidmFsdWUiOiJQRVJJT0RfQ1VSUkVOVCIsImRhdGFUeXBlIjoiVElNRUZSQU1FIn19LCJvcGVyYXRvciI6IjwiLCJyaWdodCI6eyJpZCI6IjljMTc4ZTQyLWVhODAtNDk5NS1iYjk1LTlhMDc2MTc0YTRhYSIsInR5cGUiOiJDYW5kbGUiLCJwYXJhbWV0ZXIiOiJCT0RZIiwiY2FuZGxlSWQiOnsiZGF0YVR5cGUiOiJET1VCTEUiLCJ2YWx1ZSI6MX0sInRpbWVGcmFtZSI6eyJ2YWx1ZSI6IlBFUklPRF9DVVJSRU5UIiwiZGF0YVR5cGUiOiJUSU1FRlJBTUUifX0sImludmFsaWQiOmZhbHNlfSwicG9zaXRpb24iOnsieCI6MjMxLjA3ODA5ODcwMDE3Nzg2LCJ5Ijo2MzQuOTU1MjkwNzM5NDQyNn0sInNlbGVjdGVkIjpmYWxzZSwibWVhc3VyZWQiOnsid2lkdGgiOjE5NywiaGVpZ2h0Ijo0NX0sImRyYWdnaW5nIjpmYWxzZX0seyJpZCI6IlRyYWRlT3JkZXJDb3VudER0b184MGViNzRkNS03ZjFmLTQyODUtODhjZi1kNTBhZjg1ZjI4YjQiLCJkYXRhIjp7ImlzUHJlbWl1bSI6ZmFsc2UsImxhYmVsIjoiQ291bnQgdHJhZGVzIiwiZGVzY3JpcHRpb24iOiJDb3VudHMgaG93IG1hbnkgb3BlbiBvciBwZW5kaW5nIHRyYWRlcyBtYXRjaCB5b3VyIGNyaXRlcmlhLiIsImJsb2NrVHlwZSI6IlRyYWRlT3JkZXJDb3VudER0byIsInRyYWRlT3BlcmF0b3IiOiI9PSIsInRyYWRlVmFsdWUiOnsiZGF0YVR5cGUiOiJET1VCTEUiLCJ2YWx1ZSI6MH0sIm9yZGVyT3BlcmF0b3IiOiI9PSIsIm9yZGVyVmFsdWUiOnsiZGF0YVR5cGUiOiJET1VCTEUiLCJ2YWx1ZSI6MH0sInR5cGUiOiJCVVlTX09OTFkiLCJncm91cE51bWJlciI6W10sInN5bWJvbCI6W10sImludmFsaWQiOmZhbHNlfSwidHlwZSI6InR3b091dHB1dHMiLCJwb3NpdGlvbiI6eyJ4IjoyNDMuMzc5MTczNjc5OTUyNSwieSI6NzQxLjk1OTExMTUxNTAyMDd9LCJtZWFzdXJlZCI6eyJ3aWR0aCI6MTU0LCJoZWlnaHQiOjQ1fSwic2VsZWN0ZWQiOmZhbHNlLCJkcmFnZ2luZyI6ZmFsc2V9LHsiaWQiOiJCdXlOb3dEdG9fMzQyNDA5ODgtYjJmYS00ZjhhLTk5ZmQtZDAzM2U1YWJiNzk4IiwiZGF0YSI6eyJpc1ByZW1pdW0iOmZhbHNlLCJsYWJlbCI6IkJ1eSBub3ciLCJkZXNjcmlwdGlvbiI6Ik9wZW5zIGEgYnV5IHBvc2l0aW9uIGF0IHRoZSBjdXJyZW50IG1hcmtldCBwcmljZS4iLCJibG9ja1R5cGUiOiJCdXlOb3dEdG8iLCJ2b2x1bWVNb2RlIjoiYmFsYW5jZVJpc2siLCJhbW91bnQiOnsiZGF0YVR5cGUiOiJJTlBVVCIsInZhbHVlIjoiUmlzayJ9LCJzdG9wTG9zcyI6eyJzdG9wTG9zc01vZGUiOiJQRVJDRU5UX1BSSUNFIiwic3RvcExvc3NBbW91bnQiOnsiZGF0YVR5cGUiOiJJTlBVVCIsInZhbHVlIjoiU0wifX0sInRha2VQcm9maXQiOnsidGFrZVByb2ZpdE1vZGUiOiJQRVJDRU5UX1NMIiwidGFrZVByb2ZpdEFtb3VudCI6eyJkYXRhVHlwZSI6IklOUFVUIiwidmFsdWUiOiJSUl9SYXRpbyJ9fSwiYXV0b0Nsb3NlVHJhZGUiOnsibW9kZSI6Ik5PTkUiLCJmaXhlZFRpbWUiOnsiZGF0YVR5cGUiOiJEQVRFVElNRSIsInZhbHVlIjoiMDE6MDAifX0sImdyb3VwTnVtYmVyIjoiIiwic3ltYm9sIjoiIiwiaW52YWxpZCI6ZmFsc2V9LCJ0eXBlIjoidHdvT3V0cHV0cyIsInBvc2l0aW9uIjp7IngiOjI0NS42NzY1NzAzODk5NDY2MiwieSI6ODUxLjU1MzkwNDkzNTAwODl9LCJtZWFzdXJlZCI6eyJ3aWR0aCI6MTI2LCJoZWlnaHQiOjQ1fSwic2VsZWN0ZWQiOmZhbHNlLCJkcmFnZ2luZyI6ZmFsc2V9LHsiaWQiOiJPbmNlUGVyVGlja0R0b19hNmQ4YjY2Ni1hMjkzLTQzYmEtYWU4Yy1kZDA2ZTBlZGQ5OWNfY29waWVkXzciLCJkYXRhIjp7ImlzUHJlbWl1bSI6ZmFsc2UsImxhYmVsIjoiUnVuIHBlciB0aWNrIiwiZGVzY3JpcHRpb24iOiJSdW5zIGNvbm5lY3RlZCBibG9ja3Mgb25seSBvbmNlIGVhY2ggdGltZSB0aGUgcHJpY2UgY2hhbmdlcy4iLCJibG9ja1R5cGUiOiJPbmNlUGVyVGlja0R0byIsImludmFsaWQiOmZhbHNlfSwidHlwZSI6ImlucHV0IiwicG9zaXRpb24iOnsieCI6NTk5LCJ5IjoyNTh9LCJtZWFzdXJlZCI6eyJ3aWR0aCI6MTQ4LCJoZWlnaHQiOjQ1fSwic2VsZWN0ZWQiOmZhbHNlLCJkcmFnZ2luZyI6ZmFsc2V9LHsiaWQiOiI0MTE0Mjk0ZS1hODgwLTQxMDYtODNhOS1hY2YyMjUyMWZkMGNfY29waWVkXzciLCJ0eXBlIjoidHdvT3V0cHV0cyIsImRhdGEiOnsiaXNQcmVtaXVtIjpmYWxzZSwibGFiZWwiOiJNQSA1IDwgTUEgMjAiLCJkZXNjcmlwdGlvbiI6IkNoZWNrcyBpZiB0d28gdmFsdWVzIG9yIGV4cHJlc3Npb25zIG1lZXQgYSBjaG9zZW4gY29tcGFyaXNvbiAoZS5nLiwgPiwgPCwgPSkiLCJibG9ja1R5cGUiOiJJZkJsb2NrRHRvIiwibGVmdCI6eyJpZCI6ImZjNTllYzA5LWI3MTMtNGMyYS1iZGQyLTU1NmFlYWFiM2UyOSIsInR5cGUiOiJJbmRpY2F0b3IiLCJkYXRhIjp7Im5hbWUiOiJNb3ZpbmdBdmVyYWdlSW5kaWNhdG9yIiwibWFQZXJpb2QiOnsiZGF0YVR5cGUiOiJET1VCTEUiLCJ2YWx1ZSI6NX0sIm1hU2hpZnQiOnsiZGF0YVR5cGUiOiJET1VCTEUiLCJ2YWx1ZSI6MH0sIm1hTWV0aG9kIjoiTU9ERV9TTUEiLCJhcHBsaWVkUHJpY2UiOiJQUklDRV9DTE9TRSJ9LCJtYXRoT3BlcmF0b3IiOiIrIiwibWF0aFZhbHVlIjp7ImRhdGFUeXBlIjoiRE9VQkxFIiwidmFsdWUiOjB9LCJjYW5kbGVJZCI6eyJkYXRhVHlwZSI6IkRPVUJMRSIsInZhbHVlIjoxfSwidGltZUZyYW1lIjp7ImRhdGFUeXBlIjoiVElNRUZSQU1FIiwidmFsdWUiOiJQRVJJT0RfQ1VSUkVOVCJ9fSwib3BlcmF0b3IiOiI8IiwicmlnaHQiOnsiaWQiOiJkMzRiZGQ5Yy01NWQwLTQzMWUtODAyMC1kYzA3YjEwODE4NjgiLCJ0eXBlIjoiSW5kaWNhdG9yIiwiZGF0YSI6eyJuYW1lIjoiTW92aW5nQXZlcmFnZUluZGljYXRvciIsIm1hUGVyaW9kIjp7ImRhdGFUeXBlIjoiRE9VQkxFIiwidmFsdWUiOjIwfSwibWFTaGlmdCI6eyJkYXRhVHlwZSI6IkRPVUJMRSIsInZhbHVlIjowfSwibWFNZXRob2QiOiJNT0RFX1NNQSIsImFwcGxpZWRQcmljZSI6IlBSSUNFX0NMT1NFIn0sIm1hdGhPcGVyYXRvciI6IisiLCJtYXRoVmFsdWUiOnsiZGF0YVR5cGUiOiJET1VCTEUiLCJ2YWx1ZSI6MH0sImNhbmRsZUlkIjp7ImRhdGFUeXBlIjoiRE9VQkxFIiwidmFsdWUiOjF9LCJ0aW1lRnJhbWUiOnsiZGF0YVR5cGUiOiJUSU1FRlJBTUUiLCJ2YWx1ZSI6IlBFUklPRF9DVVJSRU5UIn19LCJpbnZhbGlkIjpmYWxzZX0sInBvc2l0aW9uIjp7IngiOjU5MC43Mzk4MTM1MDUyMDQ4LCJ5IjozNDEuNjg3NzQ3NzA1MDg1OTR9LCJzZWxlY3RlZCI6ZmFsc2UsIm1lYXN1cmVkIjp7IndpZHRoIjoxNjIsImhlaWdodCI6NDV9LCJkcmFnZ2luZyI6ZmFsc2V9LHsiaWQiOiI3YjdhNDNjZC1kNjQ2LTRiM2UtYjVjOC05ZmNkYTA0OWMxNzhfY29waWVkXzciLCJ0eXBlIjoidHdvT3V0cHV0cyIsImRhdGEiOnsiaXNQcmVtaXVtIjpmYWxzZSwibGFiZWwiOiJQcmljZSA8IE1BQ09ORk8iLCJkZXNjcmlwdGlvbiI6IkNoZWNrcyBpZiB0d28gdmFsdWVzIG9yIGV4cHJlc3Npb25zIG1lZXQgYSBjaG9zZW4gY29tcGFyaXNvbiAoZS5nLiwgPiwgPCwgPSkiLCJibG9ja1R5cGUiOiJJZkJsb2NrRHRvIiwibGVmdCI6eyJpZCI6ImJlZmJmMmE4LTNmODMtNGI5ZS04ODkyLWUzMmYxZTBkZmQ1ZCIsInR5cGUiOiJNYXJrZXRQcm9wZXJ0eSIsImRhdGEiOnsibmFtZSI6IkFza0JpZE1pZCIsInByaWNlIjoiQVNLIn19LCJvcGVyYXRvciI6IjwiLCJyaWdodCI6eyJpZCI6ImQzNGJkZDljLTU1ZDAtNDMxZS04MDIwLWRjMDdiMTA4MTg2OCIsInR5cGUiOiJJbmRpY2F0b3IiLCJkYXRhIjp7Im5hbWUiOiJNb3ZpbmdBdmVyYWdlSW5kaWNhdG9yIiwibWFQZXJpb2QiOnsiZGF0YVR5cGUiOiJJTlBVVCIsInZhbHVlIjoiTUFfY29uZm8ifSwibWFTaGlmdCI6eyJkYXRhVHlwZSI6IkRPVUJMRSIsInZhbHVlIjowfSwibWFNZXRob2QiOiJNT0RFX1NNQSIsImFwcGxpZWRQcmljZSI6IlBSSUNFX0NMT1NFIn0sIm1hdGhPcGVyYXRvciI6IisiLCJtYXRoVmFsdWUiOnsiZGF0YVR5cGUiOiJET1VCTEUiLCJ2YWx1ZSI6MH0sImNhbmRsZUlkIjp7ImRhdGFUeXBlIjoiRE9VQkxFIiwidmFsdWUiOjF9LCJ0aW1lRnJhbWUiOnsiZGF0YVR5cGUiOiJUSU1FRlJBTUUiLCJ2YWx1ZSI6IlBFUklPRF9DVVJSRU5UIn19LCJpbnZhbGlkIjpmYWxzZX0sInBvc2l0aW9uIjp7IngiOjU4NC41NjUwODIyNTAxNDgyLCJ5Ijo0MzEuMTg5NTg2ODM5OTc2M30sInNlbGVjdGVkIjpmYWxzZSwibWVhc3VyZWQiOnsid2lkdGgiOjE4OCwiaGVpZ2h0Ijo0NX0sImRyYWdnaW5nIjpmYWxzZX0seyJpZCI6ImRmNjcxNjcxLWVhMTctNGJiMy05ZTdjLTM1MjQwYTQ2YWFkZF9jb3BpZWRfNyIsInR5cGUiOiJ0d29PdXRwdXRzIiwiZGF0YSI6eyJpc1ByZW1pdW0iOmZhbHNlLCJsYWJlbCI6IkJlYXJpc2ggRW5ndWxmaW5nIiwiZGVzY3JpcHRpb24iOiJDaGVja3MgaWYgdHdvIHZhbHVlcyBvciBleHByZXNzaW9ucyBtZWV0IGEgY2hvc2VuIGNvbXBhcmlzb24gKGUuZy4sID4sIDwsID0pIiwiYmxvY2tUeXBlIjoiSWZCbG9ja0R0byIsImxlZnQiOnsiaWQiOiI5NWE1NTc4Ny1mNjUzLTRkOGMtYWZiMS05ZTdjYTdmZDE2MGYiLCJ0eXBlIjoiQ2FuZGxlIiwicGFyYW1ldGVyIjoiQ0xPU0UiLCJjYW5kbGVJZCI6eyJkYXRhVHlwZSI6IkRPVUJMRSIsInZhbHVlIjoxfSwidGltZUZyYW1lIjp7InZhbHVlIjoiUEVSSU9EX0NVUlJFTlQiLCJkYXRhVHlwZSI6IlRJTUVGUkFNRSJ9fSwib3BlcmF0b3IiOiI8IiwicmlnaHQiOnsiaWQiOiJhZDhkMmIwMS1lMzE2LTQwY2EtOTA0ZS05ZjY2ODcyYjdkYmYiLCJ0eXBlIjoiQ2FuZGxlIiwicGFyYW1ldGVyIjoiTE9XIiwiY2FuZGxlSWQiOnsiZGF0YVR5cGUiOiJET1VCTEUiLCJ2YWx1ZSI6M30sInRpbWVGcmFtZSI6eyJ2YWx1ZSI6IlBFUklPRF9DVVJSRU5UIiwiZGF0YVR5cGUiOiJUSU1FRlJBTUUifX0sImludmFsaWQiOmZhbHNlfSwicG9zaXRpb24iOnsieCI6NTg0LjcxMzc4MDYwNTE0NTIsInkiOjUyNy4xOTMyNjUxMDk3NTY3fSwic2VsZWN0ZWQiOmZhbHNlLCJtZWFzdXJlZCI6eyJ3aWR0aCI6MTg1LCJoZWlnaHQiOjQ1fSwiZHJhZ2dpbmciOmZhbHNlfSx7ImlkIjoiOWVkNGFhMGEtYzU0YS00ZjExLTg2NWQtYWY0ODNmNTUzYjI0X2NvcGllZF83IiwidHlwZSI6InR3b091dHB1dHMiLCJkYXRhIjp7ImlzUHJlbWl1bSI6ZmFsc2UsImxhYmVsIjoiTGFyZ2VyIENhbmRsZSBCb2R5IiwiZGVzY3JpcHRpb24iOiJDaGVja3MgaWYgdHdvIHZhbHVlcyBvciBleHByZXNzaW9ucyBtZWV0IGEgY2hvc2VuIGNvbXBhcmlzb24gKGUuZy4sID4sIDwsID0pIiwiYmxvY2tUeXBlIjoiSWZCbG9ja0R0byIsImxlZnQiOnsiaWQiOiJmOTViNDA3Mi0wZTRjLTQxNDItOGU2Mi05NmJhNDI4ZTAxNWIiLCJ0eXBlIjoiQ2FuZGxlIiwicGFyYW1ldGVyIjoiQk9EWSIsImNhbmRsZUlkIjp7ImRhdGFUeXBlIjoiRE9VQkxFIiwidmFsdWUiOjJ9LCJ0aW1lRnJhbWUiOnsidmFsdWUiOiJQRVJJT0RfQ1VSUkVOVCIsImRhdGFUeXBlIjoiVElNRUZSQU1FIn19LCJvcGVyYXRvciI6IjwiLCJyaWdodCI6eyJpZCI6IjljMTc4ZTQyLWVhODAtNDk5NS1iYjk1LTlhMDc2MTc0YTRhYSIsInR5cGUiOiJDYW5kbGUiLCJwYXJhbWV0ZXIiOiJCT0RZIiwiY2FuZGxlSWQiOnsiZGF0YVR5cGUiOiJET1VCTEUiLCJ2YWx1ZSI6MX0sInRpbWVGcmFtZSI6eyJ2YWx1ZSI6IlBFUklPRF9DVVJSRU5UIiwiZGF0YVR5cGUiOiJUSU1FRlJBTUUifX0sImludmFsaWQiOmZhbHNlfSwicG9zaXRpb24iOnsieCI6NTgzLjA3ODA5ODcwMDE3NzksInkiOjYzNS45NTUyOTA3Mzk0NDI2fSwic2VsZWN0ZWQiOmZhbHNlLCJtZWFzdXJlZCI6eyJ3aWR0aCI6MTk3LCJoZWlnaHQiOjQ1fSwiZHJhZ2dpbmciOmZhbHNlfSx7ImlkIjoiVHJhZGVPcmRlckNvdW50RHRvXzgwZWI3NGQ1LTdmMWYtNDI4NS04OGNmLWQ1MGFmODVmMjhiNF9jb3BpZWRfNyIsImRhdGEiOnsiaXNQcmVtaXVtIjpmYWxzZSwibGFiZWwiOiJDb3VudCB0cmFkZXMiLCJkZXNjcmlwdGlvbiI6IkNvdW50cyBob3cgbWFueSBvcGVuIG9yIHBlbmRpbmcgdHJhZGVzIG1hdGNoIHlvdXIgY3JpdGVyaWEuIiwiYmxvY2tUeXBlIjoiVHJhZGVPcmRlckNvdW50RHRvIiwidHJhZGVPcGVyYXRvciI6Ij09IiwidHJhZGVWYWx1ZSI6eyJkYXRhVHlwZSI6IkRPVUJMRSIsInZhbHVlIjowfSwib3JkZXJPcGVyYXRvciI6Ij09Iiwib3JkZXJWYWx1ZSI6eyJkYXRhVHlwZSI6IkRPVUJMRSIsInZhbHVlIjowfSwidHlwZSI6IlNFTExTX09OTFkiLCJncm91cE51bWJlciI6W10sInN5bWJvbCI6W10sImludmFsaWQiOmZhbHNlfSwidHlwZSI6InR3b091dHB1dHMiLCJwb3NpdGlvbiI6eyJ4Ijo1ODYuMDgxNzc2OTY5OTU4NSwieSI6NzQxLjk1OTExMTUxNTAyMDd9LCJtZWFzdXJlZCI6eyJ3aWR0aCI6MTU0LCJoZWlnaHQiOjQ1fSwic2VsZWN0ZWQiOmZhbHNlLCJkcmFnZ2luZyI6ZmFsc2V9LHsiaWQiOiJTZWxsTm93RHRvX2RhYWQ5MTIxLTM0NTQtNDk5Yy04OGE5LWI4NTY4NjgzNmE1MSIsImRhdGEiOnsiaXNQcmVtaXVtIjpmYWxzZSwibGFiZWwiOiJTZWxsIG5vdyIsImRlc2NyaXB0aW9uIjoiT3BlbnMgYSBzZWxsIHBvc2l0aW9uIGF0IHRoZSBjdXJyZW50IG1hcmtldCBwcmljZS4iLCJibG9ja1R5cGUiOiJTZWxsTm93RHRvIiwidm9sdW1lTW9kZSI6ImJhbGFuY2VSaXNrIiwiYW1vdW50Ijp7ImRhdGFUeXBlIjoiSU5QVVQiLCJ2YWx1ZSI6IlJpc2sifSwic3RvcExvc3MiOnsic3RvcExvc3NNb2RlIjoiUEVSQ0VOVF9QUklDRSIsInN0b3BMb3NzQW1vdW50Ijp7ImRhdGFUeXBlIjoiSU5QVVQiLCJ2YWx1ZSI6IlNMIn19LCJ0YWtlUHJvZml0Ijp7InRha2VQcm9maXRNb2RlIjoiUEVSQ0VOVF9TTCIsInRha2VQcm9maXRBbW91bnQiOnsiZGF0YVR5cGUiOiJJTlBVVCIsInZhbHVlIjoiUlJfUmF0aW8ifX0sImF1dG9DbG9zZVRyYWRlIjp7Im1vZGUiOiJOT05FIiwiZml4ZWRUaW1lIjp7ImRhdGFUeXBlIjoiREFURVRJTUUiLCJ2YWx1ZSI6IjAxOjAwIn19LCJncm91cE51bWJlciI6IiIsInN5bWJvbCI6IiIsImludmFsaWQiOmZhbHNlfSwidHlwZSI6InR3b091dHB1dHMiLCJwb3NpdGlvbiI6eyJ4Ijo1ODksInkiOjg1NX0sIm1lYXN1cmVkIjp7IndpZHRoIjoxMjYsImhlaWdodCI6NDV9LCJzZWxlY3RlZCI6ZmFsc2UsImRyYWdnaW5nIjpmYWxzZX1dLCJlZGdlcyI6W3sic291cmNlIjoiT25jZVBlclRpY2tEdG9fYTZkOGI2NjYtYTI5My00M2JhLWFlOGMtZGQwNmUwZWRkOTljIiwidGFyZ2V0IjoiNDExNDI5NGUtYTg4MC00MTA2LTgzYTktYWNmMjI1MjFmZDBjIiwiaWQiOiJ4eS1lZGdlX19PbmNlUGVyVGlja0R0b19hNmQ4YjY2Ni1hMjkzLTQzYmEtYWU4Yy1kZDA2ZTBlZGQ5OWMtNDExNDI5NGUtYTg4MC00MTA2LTgzYTktYWNmMjI1MjFmZDBjIiwibWFya2VyRW5kIjp7InR5cGUiOiJhcnJvdyIsInN0cm9rZVdpZHRoIjoyLCJ3aWR0aCI6OCwiaGVpZ2h0Ijo4LCJjb2xvciI6IiM3NTc1NzUifSwic3R5bGUiOnsic3Ryb2tlV2lkdGgiOjJ9LCJkYXRhIjp7InNlY29uZFNjZW5hcmlvIjpmYWxzZX0sInNlbGVjdGVkIjpmYWxzZX0seyJzb3VyY2UiOiI0MTE0Mjk0ZS1hODgwLTQxMDYtODNhOS1hY2YyMjUyMWZkMGMiLCJzb3VyY2VIYW5kbGUiOiJjb25kaXRpb25GaXJzdFNvdXJjZSIsInRhcmdldCI6IjdiN2E0M2NkLWQ2NDYtNGIzZS1iNWM4LTlmY2RhMDQ5YzE3OCIsImlkIjoieHktZWRnZV9fNDExNDI5NGUtYTg4MC00MTA2LTgzYTktYWNmMjI1MjFmZDBjY29uZGl0aW9uRmlyc3RTb3VyY2UtN2I3YTQzY2QtZDY0Ni00YjNlLWI1YzgtOWZjZGEwNDljMTc4IiwibWFya2VyRW5kIjp7InR5cGUiOiJhcnJvdyIsInN0cm9rZVdpZHRoIjoyLCJ3aWR0aCI6OCwiaGVpZ2h0Ijo4LCJjb2xvciI6IiM3NTc1NzUifSwic3R5bGUiOnsic3Ryb2tlV2lkdGgiOjJ9LCJkYXRhIjp7InNlY29uZFNjZW5hcmlvIjpmYWxzZX0sInNlbGVjdGVkIjpmYWxzZX0seyJzb3VyY2UiOiI3YjdhNDNjZC1kNjQ2LTRiM2UtYjVjOC05ZmNkYTA0OWMxNzgiLCJzb3VyY2VIYW5kbGUiOiJjb25kaXRpb25GaXJzdFNvdXJjZSIsInRhcmdldCI6ImRmNjcxNjcxLWVhMTctNGJiMy05ZTdjLTM1MjQwYTQ2YWFkZCIsImlkIjoieHktZWRnZV9fN2I3YTQzY2QtZDY0Ni00YjNlLWI1YzgtOWZjZGEwNDljMTc4Y29uZGl0aW9uRmlyc3RTb3VyY2UtZGY2NzE2NzEtZWExNy00YmIzLTllN2MtMzUyNDBhNDZhYWRkIiwibWFya2VyRW5kIjp7InR5cGUiOiJhcnJvdyIsInN0cm9rZVdpZHRoIjoyLCJ3aWR0aCI6OCwiaGVpZ2h0Ijo4LCJjb2xvciI6IiM3NTc1NzUifSwic3R5bGUiOnsic3Ryb2tlV2lkdGgiOjJ9LCJkYXRhIjp7InNlY29uZFNjZW5hcmlvIjpmYWxzZX0sInNlbGVjdGVkIjpmYWxzZX0seyJzb3VyY2UiOiJkZjY3MTY3MS1lYTE3LTRiYjMtOWU3Yy0zNTI0MGE0NmFhZGQiLCJzb3VyY2VIYW5kbGUiOiJjb25kaXRpb25GaXJzdFNvdXJjZSIsInRhcmdldCI6IjllZDRhYTBhLWM1NGEtNGYxMS04NjVkLWFmNDgzZjU1M2IyNCIsImlkIjoieHktZWRnZV9fZGY2NzE2NzEtZWExNy00YmIzLTllN2MtMzUyNDBhNDZhYWRkY29uZGl0aW9uRmlyc3RTb3VyY2UtOWVkNGFhMGEtYzU0YS00ZjExLTg2NWQtYWY0ODNmNTUzYjI0IiwibWFya2VyRW5kIjp7InR5cGUiOiJhcnJvdyIsInN0cm9rZVdpZHRoIjoyLCJ3aWR0aCI6OCwiaGVpZ2h0Ijo4LCJjb2xvciI6IiM3NTc1NzUifSwic3R5bGUiOnsic3Ryb2tlV2lkdGgiOjJ9LCJkYXRhIjp7InNlY29uZFNjZW5hcmlvIjpmYWxzZX0sInNlbGVjdGVkIjpmYWxzZX0seyJzb3VyY2UiOiI5ZWQ0YWEwYS1jNTRhLTRmMTEtODY1ZC1hZjQ4M2Y1NTNiMjQiLCJzb3VyY2VIYW5kbGUiOiJjb25kaXRpb25GaXJzdFNvdXJjZSIsInRhcmdldCI6IlRyYWRlT3JkZXJDb3VudER0b184MGViNzRkNS03ZjFmLTQyODUtODhjZi1kNTBhZjg1ZjI4YjQiLCJpZCI6Inh5LWVkZ2VfXzllZDRhYTBhLWM1NGEtNGYxMS04NjVkLWFmNDgzZjU1M2IyNGNvbmRpdGlvbkZpcnN0U291cmNlLVRyYWRlT3JkZXJDb3VudER0b184MGViNzRkNS03ZjFmLTQyODUtODhjZi1kNTBhZjg1ZjI4YjQiLCJtYXJrZXJFbmQiOnsidHlwZSI6ImFycm93Iiwic3Ryb2tlV2lkdGgiOjIsIndpZHRoIjo4LCJoZWlnaHQiOjgsImNvbG9yIjoiIzc1NzU3NSJ9LCJzdHlsZSI6eyJzdHJva2VXaWR0aCI6Mn0sImRhdGEiOnsic2Vjb25kU2NlbmFyaW8iOmZhbHNlfSwic2VsZWN0ZWQiOmZhbHNlfSx7InNvdXJjZSI6IlRyYWRlT3JkZXJDb3VudER0b184MGViNzRkNS03ZjFmLTQyODUtODhjZi1kNTBhZjg1ZjI4YjQiLCJzb3VyY2VIYW5kbGUiOiJjb25kaXRpb25GaXJzdFNvdXJjZSIsInRhcmdldCI6IkJ1eU5vd0R0b18zNDI0MDk4OC1iMmZhLTRmOGEtOTlmZC1kMDMzZTVhYmI3OTgiLCJpZCI6Inh5LWVkZ2VfX1RyYWRlT3JkZXJDb3VudER0b184MGViNzRkNS03ZjFmLTQyODUtODhjZi1kNTBhZjg1ZjI4YjRjb25kaXRpb25GaXJzdFNvdXJjZS1CdXlOb3dEdG9fMzQyNDA5ODgtYjJmYS00ZjhhLTk5ZmQtZDAzM2U1YWJiNzk4IiwibWFya2VyRW5kIjp7InR5cGUiOiJhcnJvdyIsInN0cm9rZVdpZHRoIjoyLCJ3aWR0aCI6OCwiaGVpZ2h0Ijo4LCJjb2xvciI6IiM3NTc1NzUifSwic3R5bGUiOnsic3Ryb2tlV2lkdGgiOjJ9LCJkYXRhIjp7InNlY29uZFNjZW5hcmlvIjpmYWxzZX0sInNlbGVjdGVkIjpmYWxzZX0seyJzb3VyY2UiOiJPbmNlUGVyVGlja0R0b19hNmQ4YjY2Ni1hMjkzLTQzYmEtYWU4Yy1kZDA2ZTBlZGQ5OWNfY29waWVkXzciLCJ0YXJnZXQiOiI0MTE0Mjk0ZS1hODgwLTQxMDYtODNhOS1hY2YyMjUyMWZkMGNfY29waWVkXzciLCJpZCI6Inh5LWVkZ2VfX09uY2VQZXJUaWNrRHRvX2E2ZDhiNjY2LWEyOTMtNDNiYS1hZThjLWRkMDZlMGVkZDk5Yy00MTE0Mjk0ZS1hODgwLTQxMDYtODNhOS1hY2YyMjUyMWZkMGNfY29waWVkXzYiLCJtYXJrZXJFbmQiOnsidHlwZSI6ImFycm93Iiwic3Ryb2tlV2lkdGgiOjIsIndpZHRoIjo4LCJoZWlnaHQiOjgsImNvbG9yIjoiIzc1NzU3NSJ9LCJzdHlsZSI6eyJzdHJva2VXaWR0aCI6Mn0sImRhdGEiOnsic2Vjb25kU2NlbmFyaW8iOmZhbHNlfSwic2VsZWN0ZWQiOmZhbHNlfSx7InNvdXJjZSI6IjQxMTQyOTRlLWE4ODAtNDEwNi04M2E5LWFjZjIyNTIxZmQwY19jb3BpZWRfNyIsInNvdXJjZUhhbmRsZSI6ImNvbmRpdGlvbkZpcnN0U291cmNlIiwidGFyZ2V0IjoiN2I3YTQzY2QtZDY0Ni00YjNlLWI1YzgtOWZjZGEwNDljMTc4X2NvcGllZF83IiwiaWQiOiJ4eS1lZGdlX180MTE0Mjk0ZS1hODgwLTQxMDYtODNhOS1hY2YyMjUyMWZkMGNjb25kaXRpb25GaXJzdFNvdXJjZS03YjdhNDNjZC1kNjQ2LTRiM2UtYjVjOC05ZmNkYTA0OWMxNzhfY29waWVkXzYiLCJtYXJrZXJFbmQiOnsidHlwZSI6ImFycm93Iiwic3Ryb2tlV2lkdGgiOjIsIndpZHRoIjo4LCJoZWlnaHQiOjgsImNvbG9yIjoiIzc1NzU3NSJ9LCJzdHlsZSI6eyJzdHJva2VXaWR0aCI6Mn0sImRhdGEiOnsic2Vjb25kU2NlbmFyaW8iOmZhbHNlfSwic2VsZWN0ZWQiOmZhbHNlfSx7InNvdXJjZSI6IjdiN2E0M2NkLWQ2NDYtNGIzZS1iNWM4LTlmY2RhMDQ5YzE3OF9jb3BpZWRfNyIsInNvdXJjZUhhbmRsZSI6ImNvbmRpdGlvbkZpcnN0U291cmNlIiwidGFyZ2V0IjoiZGY2NzE2NzEtZWExNy00YmIzLTllN2MtMzUyNDBhNDZhYWRkX2NvcGllZF83IiwiaWQiOiJ4eS1lZGdlX183YjdhNDNjZC1kNjQ2LTRiM2UtYjVjOC05ZmNkYTA0OWMxNzhjb25kaXRpb25GaXJzdFNvdXJjZS1kZjY3MTY3MS1lYTE3LTRiYjMtOWU3Yy0zNTI0MGE0NmFhZGRfY29waWVkXzYiLCJtYXJrZXJFbmQiOnsidHlwZSI6ImFycm93Iiwic3Ryb2tlV2lkdGgiOjIsIndpZHRoIjo4LCJoZWlnaHQiOjgsImNvbG9yIjoiIzc1NzU3NSJ9LCJzdHlsZSI6eyJzdHJva2VXaWR0aCI6Mn0sImRhdGEiOnsic2Vjb25kU2NlbmFyaW8iOmZhbHNlfSwic2VsZWN0ZWQiOmZhbHNlfSx7InNvdXJjZSI6ImRmNjcxNjcxLWVhMTctNGJiMy05ZTdjLTM1MjQwYTQ2YWFkZF9jb3BpZWRfNyIsInNvdXJjZUhhbmRsZSI6ImNvbmRpdGlvbkZpcnN0U291cmNlIiwidGFyZ2V0IjoiOWVkNGFhMGEtYzU0YS00ZjExLTg2NWQtYWY0ODNmNTUzYjI0X2NvcGllZF83IiwiaWQiOiJ4eS1lZGdlX19kZjY3MTY3MS1lYTE3LTRiYjMtOWU3Yy0zNTI0MGE0NmFhZGRjb25kaXRpb25GaXJzdFNvdXJjZS05ZWQ0YWEwYS1jNTRhLTRmMTEtODY1ZC1hZjQ4M2Y1NTNiMjRfY29waWVkXzYiLCJtYXJrZXJFbmQiOnsidHlwZSI6ImFycm93Iiwic3Ryb2tlV2lkdGgiOjIsIndpZHRoIjo4LCJoZWlnaHQiOjgsImNvbG9yIjoiIzc1NzU3NSJ9LCJzdHlsZSI6eyJzdHJva2VXaWR0aCI6Mn0sImRhdGEiOnsic2Vjb25kU2NlbmFyaW8iOmZhbHNlfSwic2VsZWN0ZWQiOmZhbHNlfSx7InNvdXJjZSI6IjllZDRhYTBhLWM1NGEtNGYxMS04NjVkLWFmNDgzZjU1M2IyNF9jb3BpZWRfNyIsInNvdXJjZUhhbmRsZSI6ImNvbmRpdGlvbkZpcnN0U291cmNlIiwidGFyZ2V0IjoiVHJhZGVPcmRlckNvdW50RHRvXzgwZWI3NGQ1LTdmMWYtNDI4NS04OGNmLWQ1MGFmODVmMjhiNF9jb3BpZWRfNyIsImlkIjoieHktZWRnZV9fOWVkNGFhMGEtYzU0YS00ZjExLTg2NWQtYWY0ODNmNTUzYjI0Y29uZGl0aW9uRmlyc3RTb3VyY2UtVHJhZGVPcmRlckNvdW50RHRvXzgwZWI3NGQ1LTdmMWYtNDI4NS04OGNmLWQ1MGFmODVmMjhiNF9jb3BpZWRfNiIsIm1hcmtlckVuZCI6eyJ0eXBlIjoiYXJyb3ciLCJzdHJva2VXaWR0aCI6Miwid2lkdGgiOjgsImhlaWdodCI6OCwiY29sb3IiOiIjNzU3NTc1In0sInN0eWxlIjp7InN0cm9rZVdpZHRoIjoyfSwiZGF0YSI6eyJzZWNvbmRTY2VuYXJpbyI6ZmFsc2V9LCJzZWxlY3RlZCI6ZmFsc2V9LHsic291cmNlIjoiVHJhZGVPcmRlckNvdW50RHRvXzgwZWI3NGQ1LTdmMWYtNDI4NS04OGNmLWQ1MGFmODVmMjhiNF9jb3BpZWRfNyIsInNvdXJjZUhhbmRsZSI6ImNvbmRpdGlvbkZpcnN0U291cmNlIiwidGFyZ2V0IjoiU2VsbE5vd0R0b19kYWFkOTEyMS0zNDU0LTQ5OWMtODhhOS1iODU2ODY4MzZhNTEiLCJpZCI6Inh5LWVkZ2VfX1RyYWRlT3JkZXJDb3VudER0b184MGViNzRkNS03ZjFmLTQyODUtODhjZi1kNTBhZjg1ZjI4YjRfY29waWVkXzdjb25kaXRpb25GaXJzdFNvdXJjZS1TZWxsTm93RHRvX2RhYWQ5MTIxLTM0NTQtNDk5Yy04OGE5LWI4NTY4NjgzNmE1MSIsIm1hcmtlckVuZCI6eyJ0eXBlIjoiYXJyb3ciLCJzdHJva2VXaWR0aCI6Miwid2lkdGgiOjgsImhlaWdodCI6OCwiY29sb3IiOiIjNzU3NTc1In0sInN0eWxlIjp7InN0cm9rZVdpZHRoIjoyfSwiZGF0YSI6eyJzZWNvbmRTY2VuYXJpbyI6ZmFsc2V9fV0sImdsb2JhbCI6eyJ2YXJpYWJsZXMiOltdLCJpbnB1dHMiOlt7ImRhdGFUeXBlIjoiRE9VQkxFIiwidHlwZSI6IklOUFVUIiwiaW5wdXROYW1lIjoiU0wiLCJpbnB1dFZhbHVlIjoiMSIsImRlc2NyaXB0aW9uIjoiIiwia2V5IjoiY2ZjMWJjNTgtODhlOC00ZTllLThiNmMtMzkwZGEzNDFmMGIzIiwidHJhY2tPblNjcmVlbiI6ZmFsc2V9LHsiZGF0YVR5cGUiOiJET1VCTEUiLCJ0eXBlIjoiSU5QVVQiLCJpbnB1dE5hbWUiOiJSUl9SYXRpbyIsImlucHV0VmFsdWUiOiIxMDAiLCJkZXNjcmlwdGlvbiI6IiIsImtleSI6IjJjNDg0MGM1LWVjYTEtNGM5ZS1iODZjLTZlNjQ4OGIyNDg4YSIsInRyYWNrT25TY3JlZW4iOmZhbHNlfSx7ImRhdGFUeXBlIjoiRE9VQkxFIiwidHlwZSI6IklOUFVUIiwiaW5wdXROYW1lIjoiUmlzayIsImlucHV0VmFsdWUiOiIxIiwiZGVzY3JpcHRpb24iOiIiLCJrZXkiOiI4MmY1OWI2Yi1hYWM4LTRlMTMtYjM2ZC0yN2U3NGMzNWYxOWQiLCJ0cmFja09uU2NyZWVuIjpmYWxzZX0seyJkYXRhVHlwZSI6IkRPVUJMRSIsInR5cGUiOiJJTlBVVCIsImlucHV0TmFtZSI6Ik1BX2NvbmZvIiwiaW5wdXRWYWx1ZSI6IjEwMCIsImRlc2NyaXB0aW9uIjoiIiwia2V5IjoiYWNlMmY4MDgtNDc0Zi00NjQ4LWFiM2MtN2QxMGRmOGNmODNhIiwidHJhY2tPblNjcmVlbiI6ZmFsc2V9XSwicHJvamVjdFByb3BlcnRpZXMiOnsiaWQiOiI5MjMxMzMzZi1lNmI0LTRmMmQtOGFkNS1iYjRmMjM1NTZiMjkiLCJ0aXRsZSI6IkNhbmRsZSBzdGljayBHb3VkIiwiY29weXJpZ2h0IjoiQnVpbHQgd2l0aCBQcm9mZWN0dXMuQUkuIFRoZSB1c2VyIG93bnMgYWxsIGludGVsbGVjdHVhbCBwcm9wZXJ0eS4gUHJvZmVjdHVzLkFJIGlzIG5vdCByZXNwb25zaWJsZSBmb3IgYW55IHRyYWRpbmcgcmVzdWx0cy4iLCJ3ZWJzaXRlTGluayI6Imh0dHBzOi8vYXBwLnByb2ZlY3R1cy5haS9RdDZLeHQzaE9SOUhOR2FXUk5JZFdYNGw5cjM2OERPNj91dG1fc291cmNlPXNoYXJlIiwidmVyc2lvbiI6IjEuMCIsIm1hZ2ljTnVtYmVyIjoxMTExLCJkZXNjcmlwdGlvbiI6IlRoaXMgdHJhZGluZyBib3Qgd2FzIGJ1aWx0IG9uIFByb2ZlY3R1cy5BSSDigJQgdGhlIG5vLWNvZGUgZHJhZy1hbmQtZHJvcCBidWlsZGVyIGZvciBNZXRhVHJhZGVyIDUuXG5cblRoaXMgcHJvamVjdCB3YXMgc2hhcmVkIG9uIDI1LzA5LzIwMjYgMTM6MjQuIiwiY3JlYXRlZCI6IjIwMjYtMDktMjVUMDg6MDY6MDUuNTQxWiIsInVwZGF0ZWQiOiIyMDI2LTA5LTI1VDA4OjA2OjA1LjU0MVoiLCJkYXRhIjp7InRpdGxlIjoiQ2FuZGxlIHN0aWNrIEdvdWQifSwiYnJva2VyTmFtZSI6InNvbWVCcm9rZXJOYW1lIiwiYWNjb3VudE51bWJlciI6IjAiLCJwcm9qZWN0U2hhcmVMaW5rIjoiaHR0cHM6Ly9hcHAucHJvZmVjdHVzLmFpL1F0Nkt4dDNoT1I5SE5HYVdSTklkV1g0bDlyMzY4RE82P3V0bV9zb3VyY2U9c2hhcmUifSwicHJvamVjdFByb2JsZW1zIjpbXX19</ProjectData>