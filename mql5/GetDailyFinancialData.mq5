//+------------------------------------------------------------------+
//|                                        GetDailyFinancialData.mq5 |
//|                                                         Bowen WU |
//|                                     https://github.com/RapDoodle |
//+------------------------------------------------------------------+
#property copyright "Bowen WU"
#property link      "https://github.com/RapDoodle"
#property version   "1.00"

int        days = 4096;
int        bufferYear[];
int        bufferMonth[];
int        bufferDay[];
double     bufferOpen[];
double     bufferHigh[];
double     bufferLow[];
double     bufferClose[];
long       bufferVolume[];
double     bufferReturn[];
double     bufferMA5[];
double     bufferMA14[];
double     bufferMACD514[];
double     bufferRSI[];
datetime   bufferDatetime[];

//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
//---
   if (Bars(NULL, PERIOD_D1) < days)
      Alert("[WARNING] Not enough bars. There are only " + IntegerToString(Bars(NULL, PERIOD_D1)) + " bars.");
      
   int availableDays = Bars(NULL, PERIOD_D1) < days ? Bars(NULL, PERIOD_D1) : days;
   
   // File IO
   string dataFolderName = "DATA";
   string dataFileName = Symbol() + "_DAILY.csv";
   string dataFilePath = dataFolderName + "/" + dataFileName;
   FileDelete(dataFilePath, FILE_COMMON);
   int dataFileHandle = FileOpen(dataFilePath, FILE_COMMON|FILE_READ|FILE_WRITE|FILE_CSV, ',');
   
   string infoFolderName = "INFO";
   string infoFileName = Symbol() + "_INFO.csv";
   string infoFilePath = infoFolderName + "/" + infoFileName;
   FileDelete(infoFilePath, FILE_COMMON);
   int infoFileHandle = FileOpen(infoFilePath, FILE_COMMON|FILE_READ|FILE_WRITE|FILE_CSV, ',');
   
   // Indicator handles
   int ma5Handle = iMA(Symbol(), PERIOD_D1, 5, 0, MODE_SMA, PRICE_CLOSE);
   int ma14Handle = iMA(Symbol(), PERIOD_D1, 14, 0, MODE_SMA, PRICE_CLOSE);
   int rsiHandle = iRSI(Symbol(), PERIOD_D1, 14, PRICE_CLOSE);
   int macdHandle = iMACD(Symbol(), PERIOD_D1, 12, 26, 9, PRICE_CLOSE);
   
   if(ma5Handle == INVALID_HANDLE || ma14Handle == INVALID_HANDLE || rsiHandle == INVALID_HANDLE) {
      Alert("Bad handle. Script died.");
      return;
   }
   
   // Resize arrays
   ArrayResize(bufferDatetime, availableDays);
   ArrayResize(bufferYear, availableDays);
   ArrayResize(bufferMonth, availableDays);
   ArrayResize(bufferDay, availableDays);
   ArrayResize(bufferOpen, availableDays);
   ArrayResize(bufferHigh, availableDays);
   ArrayResize(bufferLow, availableDays);
   ArrayResize(bufferClose, availableDays);
   ArrayResize(bufferVolume, availableDays);
   ArrayResize(bufferReturn, availableDays);
   
   ArraySetAsSeries(bufferMA5, true);
   ArraySetAsSeries(bufferMA14, true);
   ArraySetAsSeries(bufferRSI, true);
   ArraySetAsSeries(bufferMACD514, true);
   ArraySetAsSeries(bufferDatetime, true);
   
   if(CopyBuffer(ma5Handle, 0, 0, availableDays, bufferMA5) != days)
      Alert("[WARNING] Not enough data at position 1.");
   if(CopyBuffer(ma14Handle, 0, 0, availableDays, bufferMA14) != days)
      Alert("[WARNING] Not enough data at position 2.");
   if(CopyBuffer(rsiHandle, 0, 0, availableDays, bufferRSI) != days)
      Alert("[WARNING] Not enough data at position 3.");
   if(CopyBuffer(macdHandle, 0, 0, availableDays, bufferMACD514) != days)
      Alert("[WARNING] Not enough data at position 4.");
   if(CopyTime(NULL, PERIOD_D1, 0, availableDays, bufferDatetime) != availableDays)
      Alert("[WARNING] Not enough data at position 5.");
   
   // Write to file
   // Write market info file
   FileWrite(infoFileHandle, "Digits");
   FileWrite(infoFileHandle, Digits());
   
   // Time series market data
   FileWrite(dataFileHandle, "Year", "Month", "Day", "Open", "High", "Low", "Close", "Volume", "Return", "MA5", "MA14", "MACD", "RSI");
   for(int d=1;d<availableDays;d++) {
      MqlDateTime dt;
      TimeToStruct(bufferDatetime[d], dt);
      bufferYear[d-1] = dt.year;
      bufferMonth[d-1] = dt.mon;
      bufferDay[d-1] = dt.day;
      bufferOpen[d-1] = iOpen(NULL, PERIOD_D1, d);
      bufferHigh[d-1] = iHigh(NULL, PERIOD_D1, d);
      bufferLow[d-1] = iLow(NULL, PERIOD_D1, d);
      bufferClose[d-1] = iClose(NULL, PERIOD_D1, d);
      bufferVolume[d-1] = iVolume(NULL, PERIOD_D1, d);
      bufferReturn[d-1] = 1.0;
      if (bufferYear[d-1] >= 2100)
         break;
   }
   
   for(int i=0; i < availableDays-1; i++) {
      if (bufferClose[i+1] > 0) {
         bufferReturn[i] = bufferClose[i] / bufferClose[i+1];
      } else {
         bufferReturn[i] = 1;
      }
      
      // Non-sense data
      if (bufferYear[i] >= 2100)
         break;
      
      // Write out the QPD data file
      FileWrite(dataFileHandle, 
                bufferYear[i],
                bufferMonth[i],
                bufferDay[i],
                DoubleToString(bufferOpen[i]),
                DoubleToString(bufferHigh[i]),
                DoubleToString(bufferLow[i]),
                DoubleToString(bufferClose[i]),
                bufferVolume[i],
                DoubleToString(bufferReturn[i], 8),
                DoubleToString(bufferMA5[i]),
                DoubleToString(bufferMA14[i]),
                DoubleToString(bufferMACD514[i]),
                DoubleToString(bufferRSI[i]));
   }
   
   // Close the IO stream
   FileClose(infoFileHandle);
   FileClose(dataFileHandle);
   
   Print("All files saved.");
//+------------------------------------------------------------------+  
  }