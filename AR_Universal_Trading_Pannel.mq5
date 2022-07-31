#include <Trade/Trade.mqh>

#define BtnClose "ButtonClose"
#define BtnSell "ButtonSell"
#define BtnBuy "ButtonBuy"

double ask;
double bid;

double ask_tp;
double bid_tp;

input double lots = 0.01; // Lots to trade
input double slPips = 100; // Stoploss in pips
input double RiskToReward = 2; // RRR
double slSell;
double slBuy;

string text = "No text added";

int OnInit()
  {
   string BtnSellLbl = "Sell " + lots + " Lots of " + _Symbol;
   string BtnBuyLbl = "Buy " + lots + " Lots of " + _Symbol;
   createButton(BtnClose, "Close All", 50,150,30,200,clrWhite,clrNavy);
   createButton(BtnSell, BtnSellLbl, 50,181,30,200,clrWhite,clrLightCoral);
   createButton(BtnBuy, BtnBuyLbl, 50,211,30,200,clrWhite,clrLightGreen);   
   ChartRedraw();
   return(INIT_SUCCEEDED);
  }

void OnDeinit(const int reason)
  {
   ObjectDelete(0,BtnClose);
   ObjectDelete(0,BtnSell);
   ObjectDelete(0,BtnBuy);
  }

void OnTick()
  {
   text = "-----------------------------------------\n";
   text += "AR Universal Trading Pannel\n";   
   
   ask = SymbolInfoDouble(_Symbol,SYMBOL_ASK);
   bid = SymbolInfoDouble(_Symbol,SYMBOL_BID);   
   
   slSell = NormalizeDouble(ask + (1+slPips*_Point),4);
   slBuy = NormalizeDouble(bid - (1+slPips*_Point),4);
      
   ask_tp = NormalizeDouble(ask + RiskToReward * (ask - slBuy),4);
   bid_tp = NormalizeDouble(bid - RiskToReward * (slSell - bid),4);
   
   text += "Tick => " + _Symbol + "\n";
   text += "ask => " + ask + "\n";
   text += "bid => " + bid + "\n";   
   text += "slSell => " +  slSell + "\n";
   text += "slBuy => " +  slBuy + "\n";
   text += "ask_tp => " +  ask_tp + "\n";
   text += "bid_tp => " +  bid_tp + "\n";   
   
   Comment(text);
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
               if(trade.Sell(lots,_Symbol,bid,slSell,bid_tp,"This is a SELL trade"))
               {
                Print("Sold ",lots," Lots of ",_Symbol," @ ",bid," SL = ",slSell, " TP = ",bid_tp);
               }         
                             
               ObjectSetInteger(0,BtnSell,OBJPROP_STATE,false);
               ChartRedraw();               
           } // end of if(sparam == BtnSell)


         // BtnBuy action
         if(sparam == BtnBuy)
           {
            CTrade trade;          
               if(trade.Buy(lots,_Symbol,ask,slBuy,ask_tp,"This is a SELL trade"))
               {
                Print("Bought ",lots," Lots of ",_Symbol," @ ",ask," SL = ",slBuy, " TP = ",ask_tp);
               }         
                             
               ObjectSetInteger(0,BtnBuy,OBJPROP_STATE,false);
               ChartRedraw();               
           } // end of if(sparam == BtnBuy)                                                       

           
        } // end of if(id == CHARTEVENT_OBJECT_CLICK)      
   } // end of OnchartEvent





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
