//+------------------------------------------------------------------+
//|                                                  RisicoLots.mqh  |
//|                                                                  |
//| Lotgrootte op basis van een vast percentage van de balans, die    |
//| OOK in backtests op custom symbolen klopt.                        |
//|                                                                  |
//| HET PROBLEEM                                                     |
//| Bijna elke EA rekent zo:                                          |
//|    lots = risico$ / (SL_in_ticks * SYMBOL_TRADE_TICK_VALUE)       |
//| Live klopt dat: de broker rekent TICK_VALUE bij elke tick opnieuw |
//| uit. Op CUSTOM symbolen (zelf geimporteerde tickdata) staat        |
//| TICK_VALUE als vast getal in de symbooldefinitie. Op de gemeten   |
//| _ICMARKETS-symbolen is dat getal in EURO'S opgeslagen, terwijl de |
//| tester in dollars rekent. Gevolg bij 1% ingesteld risico:         |
//|    JPY-paren 1,2-1,8%  |  XXXUSD ~1,15%  |  CHF-paren 0,9-1,2%     |
//|    EURNZD ~0,65%       |  XAUUSD ~10% (tick_value 0,10 i.p.v. 1,00)|
//|                                                                  |
//| DE OPLOSSING                                                     |
//| MT5's eigen OrderCalcProfit() rekent met de koers van dat moment, |
//| ook in de tester. In MT5 getest op 28 symbolen, 2016-2026:        |
//| een stop kost dan 1,00% op elk symbool, in elk jaar.              |
//|                                                                  |
//| GEBRUIK                                                          |
//|    #include <RisicoLots.mqh>                                      |
//|    // lots voor 1% risico, stopafstand in PRIJS (bv. 0.450):      |
//|    double lots = RL_LotsOCP(_Symbol, 1.0, sl_afstand);            |
//|                                                                  |
//|    // of: vervang SymbolInfoDouble(sym, SYMBOL_TRADE_TICK_VALUE)  |
//|    // door RL_TickWaarde(sym)   (waarde per tick)                 |
//|    // of RL_PuntWaarde(sym)     (waarde per punt)                 |
//+------------------------------------------------------------------+


//--- laatste melding, zodat een EA kan loggen waarom iets niet lukte
string RL_LaatsteMelding = "";

//+------------------------------------------------------------------+
//| Achtervoegsel van een symboolnaam: GBPJPY_ICMARKETS -> _ICMARKETS |
//+------------------------------------------------------------------+
string RL_Achtervoegsel(string sym)
  {
   if(StringLen(sym) <= 6) return("");
   return(StringSubstr(sym, 6));
  }

//+------------------------------------------------------------------+
//| Bid van een symbool, of 0 als het niet bestaat of geen koers heeft|
//+------------------------------------------------------------------+
double RL_Bid(string sym)
  {
   if(!SymbolSelect(sym, true)) return(0.0);
   double b = SymbolInfoDouble(sym, SYMBOL_BID);
   return(b > 0 ? b : 0.0);
  }

//+------------------------------------------------------------------+
//| Hoeveel eenheden `naar` is 1 eenheid `van` waard, NU (in de tester|
//| is dat het historische moment van de test).                       |
//| Zoekt eerst met het achtervoegsel van het eigen symbool, dan      |
//| zonder.                                                           |
//+------------------------------------------------------------------+
double RL_Koers(string van, string naar, string achtervoegsel)
  {
   if(van == naar) return(1.0);
   string pogingen[2];
   pogingen[0] = achtervoegsel;
   pogingen[1] = "";
   for(int i = 0; i < 2; i++)
     {
      if(i == 1 && achtervoegsel == "") break;
      double b = RL_Bid(van + naar + pogingen[i]);     // bv. GBPUSD: 1 GBP = b USD
      if(b > 0) return(b);
      b = RL_Bid(naar + van + pogingen[i]);            // bv. USDJPY: 1 USD = b JPY
      if(b > 0) return(1.0 / b);
     }
   return(0.0);
  }

//+------------------------------------------------------------------+
//| Waarde in rekeningvaluta van 1 lot dat 1 prijseenheid beweegt.    |
//| Winst = prijsverschil * lots * RL_WaardePerPrijs().               |
//| Geeft 0 als er geen omrekenkoers te vinden is.                    |
//+------------------------------------------------------------------+
double RL_WaardePerPrijs(string sym)
  {
   double contract  = SymbolInfoDouble(sym, SYMBOL_TRADE_CONTRACT_SIZE);
   string winstval  = SymbolInfoString(sym, SYMBOL_CURRENCY_PROFIT);
   string rekening  = AccountInfoString(ACCOUNT_CURRENCY);
   if(contract <= 0)
     {
      RL_LaatsteMelding = "geen contractgrootte voor " + sym;
      return(0.0);
     }
   if(winstval == rekening) return(contract);

   string suffix = RL_Achtervoegsel(sym);
   double koers  = 0.0;
   // Het eigen symbool is zelf het omrekenpaar als het de rekeningvaluta en de
   // winstvaluta bevat (USDJPY op een USD-rekening). Dan geen tweede symbool nodig.
   string basis = SymbolInfoString(sym, SYMBOL_CURRENCY_BASE);
   if(basis == rekening)
     {
      double b = SymbolInfoDouble(sym, SYMBOL_BID);
      if(b > 0) koers = 1.0 / b;
     }
   if(koers <= 0) koers = RL_Koers(winstval, rekening, suffix);
   if(koers <= 0)
     {
      RL_LaatsteMelding = StringFormat("geen omrekenkoers %s->%s gevonden (achtervoegsel '%s')",
                                       winstval, rekening, suffix);
      return(0.0);
     }
   return(contract * koers);
  }

//+------------------------------------------------------------------+
//| Lots voor een vast risico. sl_afstand is in PRIJS (bv. 0.450 op   |
//| GBPJPY), niet in punten of ticks.                                 |
//| Valt terug op SYMBOL_TRADE_TICK_VALUE als er geen omrekenkoers is,|
//| en meldt dat in RL_LaatsteMelding.                                |
//+------------------------------------------------------------------+
double RL_Lots(string sym, double risico_pct, double sl_afstand)
  {
   RL_LaatsteMelding = "";
   if(sl_afstand <= 0 || risico_pct <= 0) return(0.0);

   double waarde = RL_WaardePerPrijs(sym);
   if(waarde <= 0)
     {
      // noodgreep: de waarde van de terminal, met een waarschuwing
      double tv = SymbolInfoDouble(sym, SYMBOL_TRADE_TICK_VALUE);
      double ts = SymbolInfoDouble(sym, SYMBOL_TRADE_TICK_SIZE);
      if(tv <= 0 || ts <= 0) return(0.0);
      waarde = tv / ts;
      RL_LaatsteMelding += " -- teruggevallen op SYMBOL_TRADE_TICK_VALUE";
     }

   double verlies_per_lot = sl_afstand * waarde;
   if(verlies_per_lot <= 0) return(0.0);
   double lots = (risico_pct / 100.0) * AccountInfoDouble(ACCOUNT_BALANCE) / verlies_per_lot;

   double stap = SymbolInfoDouble(sym, SYMBOL_VOLUME_STEP);
   double vmin = SymbolInfoDouble(sym, SYMBOL_VOLUME_MIN);
   double vmax = SymbolInfoDouble(sym, SYMBOL_VOLUME_MAX);
   if(stap > 0) lots = MathFloor(lots / stap) * stap;
   if(lots < vmin) lots = vmin;
   if(lots > vmax) lots = vmax;
   return(NormalizeDouble(lots, 2));
  }

//+------------------------------------------------------------------+
//| Geldwaarde van 1 lot die 1 prijseenheid beweegt, via              |
//| OrderCalcProfit(). Valt terug op RL_WaardePerPrijs() en daarna op |
//| SYMBOL_TRADE_TICK_VALUE als het niet lukt.                        |
//+------------------------------------------------------------------+
double RL_WaardePerPrijsOCP(string sym)
  {
   double bid = SymbolInfoDouble(sym, SYMBOL_BID);
   double ts  = SymbolInfoDouble(sym, SYMBOL_TRADE_TICK_SIZE);
   if(bid > 0 && ts > 0)
     {
      // afstand van 1000 ticks, maar nooit meer dan de halve koers
      double afstand = MathMin(1000.0 * ts, bid * 0.5);
      double verlies = 0.0;
      if(OrderCalcProfit(ORDER_TYPE_BUY, sym, 1.0, bid, bid - afstand, verlies) && verlies < 0)
         return(-verlies / afstand);
     }
   double w = RL_WaardePerPrijs(sym);
   if(w > 0) return(w);
   double tv = SymbolInfoDouble(sym, SYMBOL_TRADE_TICK_VALUE);
   return(ts > 0 ? tv / ts : 0.0);
  }

//+------------------------------------------------------------------+
//| Vervangers voor SYMBOL_TRADE_TICK_VALUE die ook in de tester op   |
//| custom symbolen kloppen.                                          |
//|   RL_TickWaarde(sym)  = waarde van 1 lot per TICK  (SYMBOL_TRADE_TICK_SIZE) |
//|   RL_PuntWaarde(sym)  = waarde van 1 lot per PUNT  (SYMBOL_POINT)           |
//| Bij valuta en goud zijn tick en punt gelijk; bij sommige indices  |
//| niet. Gebruik de variant die past bij de eenheid van de formule.  |
//+------------------------------------------------------------------+
double RL_TickWaarde(string sym)
  {
   return(RL_WaardePerPrijsOCP(sym) * SymbolInfoDouble(sym, SYMBOL_TRADE_TICK_SIZE));
  }

double RL_PuntWaarde(string sym)
  {
   return(RL_WaardePerPrijsOCP(sym) * SymbolInfoDouble(sym, SYMBOL_POINT));
  }

//+------------------------------------------------------------------+
//| Zelfde doel via OrderCalcProfit(): MT5 rekent het verlies van 1   |
//| lot over de stopafstand uit met de juiste (historische) koers.    |
//| Geen omrekenpaar nodig. In de tester gemeten: klopt elk jaar      |
//| exact met wat MT5 daarna als DEAL_PROFIT boekt.                   |
//+------------------------------------------------------------------+
double RL_LotsOCP(string sym, double risico_pct, double sl_afstand)
  {
   RL_LaatsteMelding = "";
   if(sl_afstand <= 0 || risico_pct <= 0) return(0.0);
   double bid = SymbolInfoDouble(sym, SYMBOL_BID);
   double verlies = 0.0;
   if(bid <= 0 || !OrderCalcProfit(ORDER_TYPE_BUY, sym, 1.0, bid, bid - sl_afstand, verlies)
      || verlies >= 0)
     {
      RL_LaatsteMelding = "OrderCalcProfit mislukt voor " + sym + ", terugval op RL_Lots";
      return(RL_Lots(sym, risico_pct, sl_afstand));
     }
   double lots = (risico_pct / 100.0) * AccountInfoDouble(ACCOUNT_BALANCE) / (-verlies);

   double stap = SymbolInfoDouble(sym, SYMBOL_VOLUME_STEP);
   double vmin = SymbolInfoDouble(sym, SYMBOL_VOLUME_MIN);
   double vmax = SymbolInfoDouble(sym, SYMBOL_VOLUME_MAX);
   if(stap > 0) lots = MathFloor(lots / stap) * stap;
   if(lots < vmin) lots = vmin;
   if(lots > vmax) lots = vmax;
   return(NormalizeDouble(lots, 2));
  }
//+------------------------------------------------------------------+
