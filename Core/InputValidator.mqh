//+------------------------------------------------------------------+
//|                    Classe CInputValidator                        |
//+------------------------------------------------------------------+
class CInputValidator
{
public:
    // Méthode pour valider les paramètres d'entrée
    static bool ValidateInputs(const int period, const double deviation)
    {
        return (period >= 1 && period <= 1000) && 
               (deviation >= 0.1 && deviation <= 10.0);
    }

    // Méthode pour obtenir des paramètres optimaux en fonction du timeframe
    static void GetOptimalParameters(int& period, double& deviation)
    {
        ENUM_TIMEFRAMES tf = Period();
        
        switch(tf)
        {
            case PERIOD_M1:  period = 10; deviation = 2.0; break;
            case PERIOD_M5:  period = 14; deviation = 2.5; break;
            case PERIOD_M15: period = 20; deviation = 3.0; break;
            case PERIOD_M30: period = 30; deviation = 3.5; break;
            case PERIOD_H1:  period = 50; deviation = 4.0; break;
            case PERIOD_H4:  period = 100; deviation = 4.5; break;
            case PERIOD_D1:  period = 200; deviation = 5.0; break;
            case PERIOD_W1:  period = 500; deviation = 6.0; break;
            case PERIOD_MN1: period = 1000; deviation = 7.0; break;
            default:         period = 14; deviation = 2.0; // Valeurs par défaut
        }
    }
};
