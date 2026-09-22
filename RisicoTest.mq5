//+------------------------------------------------------------------+
//|                                                   RisicoTest.mq5 |
//|                                                                  |
//| Meet hoeveel procent van de balans een trade ECHT verliest als de |
//| stop geraakt wordt, bij 1% ingesteld risico.                      |
//|                                                                  |
//| De EA doet niets slims: om de paar dagen een trade, afwisselend   |
//| long en short, met een krappe stop zodat de meeste trades die     |
//| stop halen. De lotgrootte komt uit een van vier methodes:         |
//|                                                                  |
//|   0  SYMBOL_TRADE_TICK_VALUE     zoals bijna elke EA het doet     |
//|   1  SYMBOL_TRADE_TICK_VALUE_LOSS                                 |
//|   2  OrderCalcProfit()           de rekenfunctie van MT5 zelf     |
//|   3  RL_Lots()   (RisicoLots.mqh) zelf omrekenen via omrekenpaar  |
//|   4  RL_LotsOCP() (RisicoLots.mqh) via OrderCalcProfit            |
//|                                                                  |
//| Het verlies wordt NIET zelf uitgerekend maar gelezen uit          |
//| DEAL_PROFIT: het bedrag dat MT5 zelf op de rekening boekt. Zo     |
//| meet je de uitkomst, niet een eigen omrekening die zelf ook fout  |
//| kan zijn.                                                         |
//|                                                                  |
//| Bij elke trade worden ook de lots van ALLE vier de methodes       |
//| gelogd, zodat een run per symbool genoeg is om te zien welke      |
//| methode wat zou hebben ingezet.                                   |
//+------------------------------------------------------------------+
#property copyright "Luc / FXminds"
#property version   "1.00"
#property strict

#include <Trade/Trade.mqh>
#include <RisicoLots.mqh>

input int    Methode      = 0;     // 0 TICK_VALUE | 1 TICK_VALUE_LOSS | 2 OrderCalcProfit | 3 RL_Lots | 4 RL_LotsOCP
input double RisicoPct    = 1.0;
input double SL_ATR       = 0.75;  // krap, zodat de meeste trades de stop halen
input int    ElkeNDagen   = 3;
input int    HandelUur    = 10;    // niet 00:00: custom symbolen handelen pas vanaf 00:01
input int    MaxUren      = 120;   // sluit als de stop na zoveel uur nog niet geraakt is
input int    MagicNumber  = 99887766;

CTrade   trade;
datetime g_laatste_dag  = 0;
int      g_dagteller    = 0;
int      g_richting     = 1;
datetime g_open_sinds   = 0;
double   g_balans_bij_instap = 0;
double   g_lots_bij_instap   = 0;
double   g_sl_bij_instap     = 0;
string   g_bestand = "";

//+------------------------------------------------------------------+
double ATR_H1()
  {
   double som = 0;
   for(int k = 1; k <= 14; k++)
     {
      double h = iHigh(_Symbol, PERIOD_H1, k), l = iLow(_Symbol, PERIOD_H1, k);
      double vc = iClose(_Symbol, PERIOD_H1, k + 1);
      som += MathMax(h - l, MathMax(MathAbs(h - vc), MathAbs(l - vc)));
     }
   return(som / 14.0);
  }

double Normaliseer(double lots)
  {
   double stap = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
   double vmin = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   double vmax = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
   if(stap > 0) lots = MathFloor(lots / stap) * stap;
   if(lots < vmin) lots = vmin;
   if(lots > vmax) lots = vmax;
   return(NormalizeDouble(lots, 2));
  }

//--- lots volgens elke methode
double LotsMethode(int m, double sl, double risico_usd)
  {
   double ts = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
   if(ts <= 0 || sl <= 0) return(0);
   if(m == 0 || m == 1)
     {
      double tv = SymbolInfoDouble(_Symbol, m == 0 ? SYMBOL_TRADE_TICK_VALUE
                                                   : SYMBOL_TRADE_TICK_VALUE_LOSS);
      if(tv <= 0) return(0);
      return(Normaliseer(risico_usd / ((sl / ts) * tv)));
     }
   if(m == 2)
     {
      double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
      double winst = 0;
      if(!OrderCalcProfit(ORDER_TYPE_BUY, _Symbol, 1.0, bid, bid - sl, winst)) return(0);
      if(winst >= 0) return(0);
      return(Normaliseer(risico_usd / (-winst)));
     }
   if(m == 4) return(RL_LotsOCP(_Symbol, RisicoPct, sl));
   return(RL_Lots(_Symbol, RisicoPct, sl));
  }

//+------------------------------------------------------------------+
int OnInit()
  {
   trade.SetExpertMagicNumber(MagicNumber);
   trade.SetTypeFillingBySymbol(_Symbol);
   g_bestand = StringFormat("risicotest_%s_m%d.csv", _Symbol, Methode);
   int fh = FileOpen(g_bestand, FILE_WRITE | FILE_TXT | FILE_ANSI | FILE_COMMON);
   if(fh != INVALID_HANDLE)
     {
      FileWrite(fh, "soort,tijd,symbool,bid,sl_afstand,balans,lots_gebruikt,"
                    "lots_m0,lots_m1,lots_m2,lots_m3,tick_value,tick_value_loss,"
                    "rl_waarde_per_prijs,winst,melding");
      FileClose(fh);
     }
   PrintFormat("RisicoTest methode %d op %s, winstvaluta %s, contract %.0f, tick_value %.6f",
               Methode, _Symbol, SymbolInfoString(_Symbol, SYMBOL_CURRENCY_PROFIT),
               SymbolInfoDouble(_Symbol, SYMBOL_TRADE_CONTRACT_SIZE),
               SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE));
   return(INIT_SUCCEEDED);
  }

void Schrijf(string regel)
  {
   int fh = FileOpen(g_bestand, FILE_READ | FILE_WRITE | FILE_TXT | FILE_ANSI | FILE_COMMON);
   if(fh == INVALID_HANDLE) return;
   FileSeek(fh, 0, SEEK_END);
   FileWrite(fh, regel);
   FileClose(fh);
  }

bool HeeftPositie()
  {
   for(int i = PositionsTotal() - 1; i >= 0; i--)
     {
      if(PositionGetTicket(i) == 0) continue;
      if(PositionGetString(POSITION_SYMBOL) == _Symbol &&
         PositionGetInteger(POSITION_MAGIC) == MagicNumber) return(true);
     }
   return(false);
  }

//+------------------------------------------------------------------+
//| Elke gesloten deal: MT5's eigen winst wegschrijven                |
//+------------------------------------------------------------------+
void OnTradeTransaction(const MqlTradeTransaction &trans, const MqlTradeRequest &req,
                        const MqlTradeResult &res)
  {
   if(trans.type != TRADE_TRANSACTION_DEAL_ADD) return;
   if(!HistoryDealSelect(trans.deal)) return;
   if(HistoryDealGetInteger(trans.deal, DEAL_MAGIC) != MagicNumber) return;
   if(HistoryDealGetInteger(trans.deal, DEAL_ENTRY) != DEAL_ENTRY_OUT) return;
   double winst = HistoryDealGetDouble(trans.deal, DEAL_PROFIT)
                + HistoryDealGetDouble(trans.deal, DEAL_SWAP)
                + HistoryDealGetDouble(trans.deal, DEAL_COMMISSION);
   string reden = (HistoryDealGetInteger(trans.deal, DEAL_REASON) == DEAL_REASON_SL) ? "SL" : "tijd";
   Schrijf(StringFormat("uit,%s,%s,%.5f,%.5f,%.2f,%.2f,,,,,,,,%.2f,%s",
                        TimeToString(TimeCurrent(), TIME_DATE | TIME_MINUTES), _Symbol,
                        HistoryDealGetDouble(trans.deal, DEAL_PRICE), g_sl_bij_instap,
                        g_balans_bij_instap, g_lots_bij_instap, winst, reden));
  }

//+------------------------------------------------------------------+
void OnTick()
  {
   if(HeeftPositie())
     {
      if(TimeCurrent() - g_open_sinds > MaxUren * 3600)
         for(int i = PositionsTotal() - 1; i >= 0; i--)
           {
            ulong tik = PositionGetTicket(i);
            if(tik != 0 && PositionGetString(POSITION_SYMBOL) == _Symbol &&
               PositionGetInteger(POSITION_MAGIC) == MagicNumber)
               trade.PositionClose(tik);
           }
      return;
     }

   MqlDateTime dt;
   TimeToStruct(TimeCurrent(), dt);
   if(dt.hour != HandelUur) return;
   datetime dag = iTime(_Symbol, PERIOD_D1, 0);
   if(dag == g_laatste_dag) return;
   g_laatste_dag = dag;
   if(++g_dagteller % ElkeNDagen != 0) return;

   double sl = ATR_H1() * SL_ATR;
   if(sl <= 0) return;
   double balans  = AccountInfoDouble(ACCOUNT_BALANCE);
   double risico_usd = balans * RisicoPct / 100.0;
   double l0 = LotsMethode(0, sl, risico_usd);
   double l1 = LotsMethode(1, sl, risico_usd);
   double l2 = LotsMethode(2, sl, risico_usd);
   double l3 = LotsMethode(3, sl, risico_usd);
   string melding = RL_LaatsteMelding;
   double gebruikt = (Methode == 0) ? l0 : (Methode == 1) ? l1 : (Methode == 2) ? l2 :
                     (Methode == 3) ? l3 : LotsMethode(4, sl, risico_usd);
   if(gebruikt <= 0) return;

   double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   int cijfers = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
   bool ok = (g_richting > 0)
             ? trade.Buy(gebruikt, _Symbol, ask, NormalizeDouble(ask - sl, cijfers), 0, "risicotest")
             : trade.Sell(gebruikt, _Symbol, bid, NormalizeDouble(bid + sl, cijfers), 0, "risicotest");
   if(!ok) return;

   g_richting = -g_richting;
   g_open_sinds = TimeCurrent();
   g_balans_bij_instap = balans;
   g_lots_bij_instap = gebruikt;
   g_sl_bij_instap = sl;
   Schrijf(StringFormat("in,%s,%s,%.5f,%.5f,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%.6f,%.6f,%.4f,,%s",
                        TimeToString(TimeCurrent(), TIME_DATE | TIME_MINUTES), _Symbol, bid, sl,
                        balans, gebruikt, l0, l1, l2, l3,
                        SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE),
                        SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE_LOSS),
                        RL_WaardePerPrijs(_Symbol), melding));
  }
//+------------------------------------------------------------------+
