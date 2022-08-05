#include <Trade/Trade.mqh>

#define BtnClose "ButtonClose"
#define BtnSell "ButtonSell"
#define BtnBuy "ButtonBuy"
#define BtnCalculate "BtnCalculate"
#define EdiLots "EdiLots"
#define EdiSlPips "EdiSlPips"
#define EdiRiskToReward "EdiRiskToReward"
#define EdiPercentRisk "EdiPercentRisk"

#define LlbLots "LlbLots"
#define LblSl "LblSl"
#define LblRiskToReward "LblRiskToReward"
#define LblPercentRisk "LblPercentRisk"

double ask;
double bid;

double tpBuy;
double tpSell;

double slPips; // Stoploss in pips
double RiskToReward; // RRR
double slSell;
double slBuy;
double posLots;

string text = "No text added";   

int OnInit()
  {      
   int formX = 5;
   int formY = 20;
   int formElHeight = 30;   
   int formElOffset = 1;
   
   createButton(BtnClose, "Close All", formX,formY,formElHeight,200,clrWhite,clrNavy);
   
   createButton(BtnSell, "SELL", formX,formY+formElHeight+formElOffset,formElHeight,100,clrWhite,clrTomato);
   createButton(BtnBuy, "BUY", formX + 100 + formElOffset, formY+formElHeight+formElOffset,formElHeight,100,clrWhite,clrForestGreen);
   
   createButton(BtnCalculate, "Calculate %", formX, formY+2*formElHeight+formElOffset,formElHeight,200,clrWhite,clrDodgerBlue);
   
   createLabel(LlbLots, "Lots", formX,formY+3*formElHeight+formElOffset,15,50,clrWhite,clrBlack);
   createLabel(LblSl, "SL P", formX+50+formElOffset,formY+3*formElHeight+formElOffset,15,50,clrWhite,clrBlack);
   createLabel(LblRiskToReward, "RRR", formX+2*50+2*formElOffset,formY+3*formElHeight+formElOffset,15,50,clrWhite,clrBlack);
   createLabel(LblPercentRisk, "%R", formX+3*50+3*formElOffset,formY+3*formElHeight+formElOffset,15,50,clrWhite,clrBlack);
   
   createEdit(EdiLots, formX,formY+4*formElHeight+formElOffset,formElHeight,50,clrWhite,clrBlack);
   createEdit(EdiSlPips, formX+50+formElOffset,formY+4*formElHeight+formElOffset,formElHeight,50,clrWhite,clrBlack);
   createEdit(EdiRiskToReward, formX+2*50+2*formElOffset,formY+4*formElHeight+formElOffset,formElHeight,50,clrWhite,clrBlack);
   createEdit(EdiPercentRisk, formX+3*50+3*formElOffset,formY+4*formElHeight+formElOffset,formElHeight,50,clrWhite,clrBlack);
         
   ChartRedraw();
   return(INIT_SUCCEEDED);
  }

void OnDeinit(const int reason)
  {
   ObjectDelete(0,BtnClose);
   ObjectDelete(0,BtnSell);
   ObjectDelete(0,BtnBuy);
   
   ObjectDelete(0,EdiLots);
   ObjectDelete(0,EdiSlPips);
   ObjectDelete(0,EdiRiskToReward);
   ObjectDelete(0,EdiPercentRisk);
   
   ObjectDelete(0,BtnCalculate);
   
   ObjectDelete(0,LlbLots);
   ObjectDelete(0,LblSl);
   ObjectDelete(0,LblRiskToReward);
   ObjectDelete(0,LblPercentRisk);
      
  }

void OnTick()
  {     
   // Saving edit values into variables     
   posLots = NormalizeDouble(StringToDouble(ObjectGetString(0,EdiLots,OBJPROP_TEXT)),2);        
   slPips = NormalizeDouble(StringToDouble(ObjectGetString(0,EdiSlPips,OBJPROP_TEXT)),2);
   RiskToReward = NormalizeDouble(StringToDouble(ObjectGetString(0,EdiRiskToReward,OBJPROP_TEXT)),2);        
   
   ask = SymbolInfoDouble(_Symbol,SYMBOL_ASK);
   bid = SymbolInfoDouble(_Symbol,SYMBOL_BID);   
     
   slSell = NormalizeDouble(bid + slPips*_Point*10,4);
   slBuy = NormalizeDouble(ask - slPips*_Point*10,4);
     
   tpSell = NormalizeDouble(bid - RiskToReward * (slSell - bid),4);
   tpBuy = NormalizeDouble(ask + RiskToReward * (ask - slBuy),4);
          
   
//   text = "";
//   text += "-----------------------------------------\n";
//   text += "AR Universal Trading Pannel\n";
//   
//   text += "Tick => " + _Symbol + "\n";
//   text += "ask => " + DoubleToString(ask,2) + "\n";
//   text += "bid => " + DoubleToString(bid,2) + "\n";   
//   text += "slSell => " +  DoubleToString(slSell,2) + "\n";
//   text += "slBuy => " +  DoubleToString(slBuy,2) + "\n";
//   text += "tpBuy => " +  DoubleToString(tpBuy,2) + "\n";
//   text += "tpSell => " +  DoubleToString(tpSell,2) + "\n";   
//        
//   Comment(text);

  }
  
void  OnChartEvent(
   const int       id,       // event ID  
   const long&     lparam,   // long type event parameter 
   const double&   dparam,   // double type event parameter 
   const string&   sparam    // string type event parameter 
   )
   {         
                 
      if(id == CHARTEVENT_OBJECT_CLICK)
        {                                    
         // BtnClose action
         if(sparam == BtnClose)         
           {                                              
           for(int i = PositionsTotal() - 1; i>=0;i--)
             {
              CTrade trade;
              ulong posTicket = PositionGetTicket(i);
                 if(trade.PositionClose(posTicket))
                   {
                    Print(i," Position #",posTicket," Was closed...");
                   }                                      
            } // end of for loop
               ObjectSetInteger(0,BtnClose,OBJPROP_STATE,false);
               ChartRedraw();
           } // end of if(sparam == BtnClose)
           
           
         // BtnSell action
         if(sparam == BtnSell)
           {
            CTrade trade;          
               if(trade.Sell(posLots,_Symbol,bid,slSell,tpSell,"This is a SELL trade"))
               {
                Print("Sold ",posLots," Lots of ",_Symbol," @ ",bid," SL = ",slSell, " TP = ",tpSell);
               }         
                             
               ObjectSetInteger(0,BtnSell,OBJPROP_STATE,false);
               ChartRedraw();               
           } // end of if(sparam == BtnSell)


         // BtnBuy action
         if(sparam == BtnBuy)
           {
            CTrade trade;          
               if(trade.Buy(posLots,_Symbol,ask,slBuy,tpBuy,"This is a SELL trade"))
               {
                Print("Bought ",posLots," Lots of ",_Symbol," @ ",ask," SL = ",slBuy, " TP = ",tpBuy);
               }         
                             
               ObjectSetInteger(0,BtnBuy,OBJPROP_STATE,false);
               ChartRedraw();               
           } // end of if(sparam == BtnBuy)                                                                               
                      
           // Calculate risk action                      
           
         if(sparam == BtnCalculate)
           {           
            double percentRisk = NormalizeDouble(StringToDouble(ObjectGetString(0,EdiPercentRisk,OBJPROP_TEXT)),2);             
            double AccountBalance = NormalizeDouble(AccountInfoDouble(ACCOUNT_BALANCE),2);          
            double AmountToRisk = NormalizeDouble(AccountBalance*percentRisk/100,2);          
            double ValuePp = SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_VALUE);
            double LotsCalculated = NormalizeDouble(AmountToRisk/(slPips*10)/ValuePp,2);                                       
            string LotsCalculatedStr = DoubleToString(LotsCalculated,2);                                                             
            ObjectSetString(0,EdiLots,OBJPROP_TEXT,LotsCalculatedStr);                  
            ObjectSetInteger(0,BtnCalculate,OBJPROP_STATE,false);
            ChartRedraw();
                
           } // end of if(sparam == BtnCalculate)    
                                                       
        } // end of if(id == CHARTEVENT_OBJECT_CLICK)
                                                          
   } // end of OnchartEvent

// Creating Buttons
bool createButton(string objName, string text, int x, int y, int height, int width, color clrTxt, color clrBg)
   {  
   ResetLastError(); 
   if(!ObjectCreate(0,objName,OBJ_BUTTON,0,0,0)) 
     { 
      Print(__FUNCTION__, 
            ": failed to create the button! Error code = ",GetLastError()); 
      return(false); 
     } 
   ObjectSetInteger(0,objName,OBJPROP_XDISTANCE,x); 
   ObjectSetInteger(0,objName,OBJPROP_YDISTANCE,y); 
   ObjectSetInteger(0,objName,OBJPROP_XSIZE,width); 
   ObjectSetInteger(0,objName,OBJPROP_YSIZE,height); 
   ObjectSetInteger(0,objName,OBJPROP_CORNER,CORNER_LEFT_UPPER); 
   ObjectSetString(0,objName,OBJPROP_TEXT,text);    
   ObjectSetInteger(0,objName,OBJPROP_FONTSIZE,12); 
   ObjectSetInteger(0,objName,OBJPROP_COLOR,clrTxt); 
   ObjectSetInteger(0,objName,OBJPROP_BGCOLOR,clrBg); 
   ObjectSetInteger(0,objName,OBJPROP_BACK,false); 
   ObjectSetInteger(0,objName,OBJPROP_STATE,false); 
   ObjectSetInteger(0,objName,OBJPROP_SELECTABLE,false); 
   ObjectSetInteger(0,objName,OBJPROP_SELECTED,false); 
   ObjectSetInteger(0,objName,OBJPROP_HIDDEN,true); 
   
   return(true); 
   } // end of create button
   
 // Creating Edit Fields
    bool createEdit(string objName, int x, int y, int height, int width, color clrTxt, color clrBg)
       {
        ResetLastError(); 

         if(!ObjectCreate(0,objName,OBJ_EDIT,0,0,0)) 
           { 
            Print(__FUNCTION__, 
                  ": failed to create \"Edit\" object! Error code = ",GetLastError()); 
            return(false); 
           } 
         ObjectSetInteger(0,objName,OBJPROP_XDISTANCE,x); 
         ObjectSetInteger(0,objName,OBJPROP_YDISTANCE,y);       
         ObjectSetInteger(0,objName,OBJPROP_XSIZE,width); 
         ObjectSetInteger(0,objName,OBJPROP_YSIZE,height);                        
         ObjectSetInteger(0,objName,OBJPROP_FONTSIZE,10);       
         ObjectSetInteger(0,objName,OBJPROP_ALIGN,ALIGN_CENTER);       
         ObjectSetInteger(0,objName,OBJPROP_READONLY,false); 
         ObjectSetInteger(0,objName,OBJPROP_COLOR,clrTxt);       
         ObjectSetInteger(0,objName,OBJPROP_BGCOLOR,clrBg); 
    
         return(true); 
  
    }
    
    
    
    // Creating Labels
    bool createLabel(string objName, string text, int x, int y, int height, int width, color clrTxt, color clrBg)
       {
        ResetLastError(); 

         if(!ObjectCreate(0,objName,OBJ_LABEL,0,0,0)) 
           { 
            Print(__FUNCTION__, 
                  ": failed to create \"Edit\" object! Error code = ",GetLastError()); 
            return(false); 
           } 
         ObjectSetInteger(0,objName,OBJPROP_XDISTANCE,x); 
         ObjectSetInteger(0,objName,OBJPROP_YDISTANCE,y);       
         ObjectSetInteger(0,objName,OBJPROP_XSIZE,width); 
         ObjectSetInteger(0,objName,OBJPROP_YSIZE,height);      
         ObjectSetString(0,objName,OBJPROP_TEXT,text);             
         ObjectSetInteger(0,objName,OBJPROP_FONTSIZE,10);       
         ObjectSetInteger(0,objName,OBJPROP_ALIGN,ALIGN_CENTER);       
         ObjectSetInteger(0,objName,OBJPROP_READONLY,false);
         ObjectSetInteger(0,objName,OBJPROP_COLOR,clrTxt);       
            
         return(true);   
    }
