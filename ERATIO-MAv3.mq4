#property strict
#property indicator_chart_window
#property indicator_buffers 1
#property indicator_color1 clrBlue



input int sampleSize = 30000;
sinput string Info_1=""; // MA INDICATOR INPUTS
input int period = 200;
sinput string Info_2=""; // RISK MANAGEMENT INPUTS
input int T = 4;
input int S = 24;
input double Spread = 1.0;


// Drawing Buffers
double dataBuffer[];

bool newLoad = false;

// Main Buffers Printed to CSV
double avgMAEs[30000];
double avgMFEs[30000];
double avgOutcome[30000];
double eRatios[30000];
double POP[30000];
double POT[30000];
double POS[30000];
double salMAEs[30000];
double salMFEs[30000];
double sawMAEs[30000];
double sawMFEs[30000];

// Inner Buffers Used to Calculate Data for Main Buffers
int TradeStartTime[30000];
int TradeEndTime[30000];
int TradeOutcomeInPips[30000];
int TradeMAE[30000];
int TradeMFE[30000];
int TradeMAEl[30000];
int TradeMFEl[30000];
int TradeMAEw[30000];
int TradeMFEw[30000];

string objprefix = IntegerToString(Period()) + Symbol();
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   IndicatorBuffers(1);
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0, dataBuffer);
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator de-initialization function                      |
//+------------------------------------------------------------------+
void OnDeinit(const int reason){DeleteObjects(objprefix);}

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---
  if(newLoad) return(0);
  if(Volume[0]>1) {newLoad = false;}
  //--------------
  // Time Loop - Cyles Through Data using each individual time exit
  //--------------
  int x = 1;
  while(x<=1000)
   {
   //-----------------------------
   //--------------
    // Single Data Loop - Cyles Through Data using x time exit.
   // Gathers Average eRatio & Stores It
   //--------------
   int i = sampleSize;
   double startingLevel = 0;
   int startTime = 0;
   int MAE = 0;
   int MFE = 0;
   int maxMAE = 0;
   int maxMFE = 0;
   bool longOp = false;
   bool shortOp = false;
   bool tradeOp = false;
   int TradeCount = 0;
   int wins = 0;
   int thit = 0;
   int shit = 0;
   
   int slopeOne = 0;

   while(i>0)
    {
    //--------------
    // Indicators to Slice Market
    //--------------
    dataBuffer[i] = iMA(NULL,0,period,0,MODE_SMA,PRICE_CLOSE,i);
    
    if(dataBuffer[i] > dataBuffer[i+1]) {slopeOne = 1;}
    if(dataBuffer[i] > dataBuffer[i+1]) {slopeOne = -1;}

    //--------------
    // LONG OPP OPEN
    //--------------
    if(!longOp && !shortOp)// Confirm No Trades are Open
       {
       if(slopeOne == -1 && Close[i] > Close[i+1]) // Long Oppurtunity Started
          {
          startTime = i;
          startingLevel = Close[i];
          longOp = true;
          i--;
          }
       }
       
    
    //--------------
    // LONG UPDATE MAE/MFE PLACEHOLDERS
    //--------------
    if(longOp) // Check For Open Trade
       {
       int MAEdistance = int((startingLevel-Low[i])/CalculateNormalizedDigits()); // Draw Down Distance
       int MFEdistance = int((High[i]-startingLevel)/CalculateNormalizedDigits()); // Run Up Distance
       
       // Compare Distances to Current Place Holders
       if(MAEdistance>MAE) {MAE = MAEdistance;}
       if(MAE>maxMAE) {maxMAE = MAE;}
       
       if(MFEdistance>MFE) {MFE = MFEdistance;}
       if(MFE>maxMFE) {maxMFE = MFE;}
       
       if(!tradeOp)
         {
         if(MAE >= S && MFE < T) {shit++; tradeOp = true; TradeMAEl[TradeCount] = -MAE; TradeMFEl[TradeCount] = MFE;}
         if(MFE >= T && MAE < S) {thit++; tradeOp = true; TradeMAEw[TradeCount] = -MAE; TradeMFEw[TradeCount] = MFE;}
         }
       }
   
          
    //--------------
    // LONG OPP CLOSE
    //--------------
    if(longOp) // Check For Open Trade
       {
       if(startTime-i >= x || i == 0) // Long Opp is Closed
          {
          // Log Trade Data
          TradeStartTime[TradeCount] = startTime;
          TradeEndTime[TradeCount] = i;
          if(startingLevel>Close[i]) 
             {
             TradeOutcomeInPips[TradeCount] = -int((startingLevel-Close[i])/CalculateNormalizedDigits());
             }
          else
             {
             TradeOutcomeInPips[TradeCount] = int((Close[i]-startingLevel)/CalculateNormalizedDigits());
             wins++;
             }
          TradeMAE[TradeCount] = -MAE;
          TradeMFE[TradeCount] = MFE;
          if(!tradeOp)
            {
            if(MAE >= S && MFE < T) {shit++; tradeOp = true; TradeMAEl[TradeCount] = -MAE; TradeMFEl[TradeCount] = MFE;}
            if(MFE >= T && MAE < S) {thit++; tradeOp = true; TradeMAEw[TradeCount] = -MAE; TradeMFEw[TradeCount] = MFE;}
            }
          TradeCount++;
         
          // Reset Counters
          MAE = 0;
          MFE = 0;
          longOp = false;
          tradeOp = false;
          }
       }
      
    //--------------
    // SHORT OPP OPEN
    //--------------
    if(!shortOp && !longOp) // Confirm No Trades are Open
       {
       if(slopeOne == 1 && Close[i] < Close[i+1])
          {
          startTime = i;
          startingLevel = Close[i];
          shortOp = true;
          i--;
          }
       }
      
    //--------------
    // SHORT UPDATE MAE/MFE PLACEHOLDERS
    //--------------
    if(shortOp) // Check For Open Trade
       {
       int MAEdistance = int((High[i]-startingLevel)/CalculateNormalizedDigits()); // Draw Down Distance
       int MFEdistance = int((startingLevel-Low[i])/CalculateNormalizedDigits()); // Run Up Distance
       
       // Compare Distances to Current Place Holders
       if(MAEdistance>MAE) {MAE = MAEdistance;}
       if(MAE>maxMAE) {maxMAE = MAE;}
      
       if(MFEdistance>MFE) {MFE = MFEdistance;}
       if(MFE>maxMFE) {maxMFE = MFE;}
       
       if(!tradeOp)
         {
         if(MAE >= S && MFE < T) {shit++; tradeOp = true; TradeMAEl[TradeCount] = -MAE; TradeMFEl[TradeCount] = MFE;}
         if(MFE >= T && MAE < S) {thit++; tradeOp = true; TradeMAEw[TradeCount] = -MAE; TradeMFEw[TradeCount] = MFE;}
         }
       }
   
    //--------------
    // SHORT OPP CLOSE
    //--------------
    if(shortOp) // Check For Open Trade
       {
       if(startTime-i >= x || i == 0) // Short Opp is Closed
          {
          // Log Trade Data
          TradeStartTime[TradeCount] = startTime;
          TradeEndTime[TradeCount] = i;
          if(startingLevel<Close[i]) 
             {
             TradeOutcomeInPips[TradeCount] = -int((Close[i]-startingLevel)/CalculateNormalizedDigits());
             }
          else
             {
             TradeOutcomeInPips[TradeCount] = int((startingLevel-Close[i])/CalculateNormalizedDigits());
             wins++;
             }
          TradeMAE[TradeCount] = -MAE;
          TradeMFE[TradeCount] = MFE;
          if(!tradeOp)
            {
            if(MAE >= S && MFE < T) {shit++; tradeOp = true; TradeMAEl[TradeCount] = -MAE; TradeMFEl[TradeCount] = MFE;}
            if(MFE >= T && MAE < S) {thit++; tradeOp = true; TradeMAEw[TradeCount] = -MAE; TradeMFEw[TradeCount] = MFE;}
            }
          TradeCount++;
         
          // Reset Counters
          MAE = 0;
          MFE = 0;
          shortOp = false;
          tradeOp = false;
          }
       }
   
    i--;
    }
   
   //--------------
   // Find & Record Avg MFE/MAE
   // Calculate & Store eRatio for x exit
   //--------------
   // Find Average MFE & MAE
   int k = 0;
   double MFEsum = 0;
   double MAEsum = 0;
   double MFEsuml = 0;
   double MAEsuml = 0;
   double MFEsumw = 0;
   double MAEsumw = 0;
   double outcomeSum = 0;
   while(k<TradeCount)
      {
      MAEsum += TradeMAE[k] * (-1);
      MFEsum += TradeMFE[k];
      outcomeSum += TradeOutcomeInPips[k];
      
      MAEsuml += TradeMAEl[k] * (-1);
      MFEsuml += TradeMFEl[k];
      
      MAEsumw += TradeMAEw[k] * (-1);
      MFEsumw += TradeMFEw[k];

      k++;
      }
   avgMAEs[x] = MAEsum/k;
   avgMFEs[x] = MFEsum/k;
   avgOutcome[x] = outcomeSum/double(TradeCount);
   eRatios[x] = avgMFEs[x]/avgMAEs[x];
   POP[x] = (double(wins)/double(TradeCount))*100;
   POT[x] = (double(thit)/double(TradeCount))*100;
   POS[x] = (double(shit)/double(TradeCount))*100;
   salMAEs[x] = MAEsuml/k;
   salMFEs[x] = MFEsuml/k; 
   sawMAEs[x] = MAEsumw/k;
   sawMFEs[x] = MFEsumw/k;
   
  
   
   //-----------------------------
   x++;
   }
   
   WriteFile();
   
   newLoad = true;
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//+--------------
//|DELETE OBJECTS                                                 
//+--------------  
void DeleteObjects(string prefix)
  {
   string strObj;
   int ObjTotal=ObjectsTotal();
   for(int i=ObjTotal-1;i>=0;i--)
     {
      strObj=ObjectName(i);
      if(StringFind(strObj,prefix,0)>-1)
        {
         ObjectDelete(strObj);
        }
     }
  }
//+----------------
//|Normalize Digits                                                  
//+---------------- 
double CalculateNormalizedDigits()
  {
//If there are 3 or less digits (JPY for example) then return 0.01 which is the pip value
   if(Digits<=3)
     {
      return(0.01);
     }
//If there are 4 or more digits then return 0.0001 which is the pip value
   else if(Digits>=4)
     {
      return(0.0001);
     }
//In all other cases (there shouldn't be any) return 0
   else return(0);
  }
//+--------------------------
//|WRITE STATISTICS INTO FILE                                        
//+--------------------------
bool WriteFile()
  {
   int file_handle=FileOpen("Statistics"+"//"+"ERATIO-MA.txt",FILE_READ|FILE_WRITE|FILE_CSV|FILE_ANSI);
   if(file_handle!=INVALID_HANDLE)
     {
      PrintFormat("%s file is available for writing","ERATIO-MA.txt");
      PrintFormat("File path: %s\\Files\\",TerminalInfoString(TERMINAL_DATA_PATH));

      string strData="";

      // High Distance Data
      strData = strData + "TIME EXIT,AVG MFE,AVG MAE,AVG OUTCOME,ERATIO,POP,POT,POS,L AVG MFE,L AVG MAE,W AVG MFE,W AVG MAE," + IntegerToString(S) + "," + IntegerToString(T) + "," + DoubleToStr(Spread,2) + "\n";
      int x = 1;
      while(x<1000)
         {
         strData = strData + IntegerToString(x) + "," + DoubleToStr(avgMFEs[x],2) + "," + DoubleToStr(avgMAEs[x],2) + "," + DoubleToStr(avgOutcome[x],2) + "," + DoubleToStr(eRatios[x],2) + "," + DoubleToStr(POP[x],2) + "," + DoubleToStr(POT[x],2) + "," + DoubleToStr(POS[x],2) + "," + DoubleToStr(salMFEs[x],2) + "," + DoubleToStr(salMAEs[x],2) + "," + DoubleToStr(sawMFEs[x],2) + "," + DoubleToStr(sawMAEs[x],2) + "\n";

         x++;
         }
      
      FileWriteString(file_handle,strData);

      //--- close the file
      FileClose(file_handle);
      PrintFormat("Data is written, %s file is closed","ERATIO-MA.txt");
      
      return(true);
     }
   else
     {
      PrintFormat("Failed to open %s file, Error code = %d","ERATIO-MA.txt",GetLastError());
      return(false);
     }
  }
  
  