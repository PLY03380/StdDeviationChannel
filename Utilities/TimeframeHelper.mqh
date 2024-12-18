class CTimeframeHelper
{
public:
    static string TimeframeToString(ENUM_TIMEFRAMES timeframe)
    {
        switch(timeframe)
        {
            case PERIOD_M1:  return "M1";
            case PERIOD_M5:  return "M5";
            case PERIOD_M15: return "M15";
            case PERIOD_H1:  return "H1";
            case PERIOD_H4:  return "H4";
            case PERIOD_D1:  return "D1";
            case PERIOD_W1:  return "W1";
            case PERIOD_MN1: return "MN";
            default:         return "Custom";
        }
    }
    
    static int GetOptimalPeriod(ENUM_TIMEFRAMES timeframe)
    {
        switch(timeframe)
        {
            case PERIOD_M1:  return 10;
            case PERIOD_M5:  return 15;
            case PERIOD_M15: return 20;
            case PERIOD_H1:  return 24;
            case PERIOD_H4:  return 30;
            case PERIOD_D1:  return 40;
            default:         return 20;
        }
    }
    
    static double GetOptimalDeviation(ENUM_TIMEFRAMES timeframe)
    {
        // On peut personnaliser selon le timeframe si nécessaire
        return 2.0;
    }
};