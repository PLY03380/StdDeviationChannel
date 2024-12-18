#include "../Utilities/ErrorHandler.mqh"

class CSDCCalculator
{
private:
    int       m_period;
    double    m_deviation;
    double    m_upperBuffer[];
    double    m_lowerBuffer[];
    double    m_middleBuffer[];  // Ajout du buffer intermédiaire
    double    m_maBuffer[];
    
    // Handles des indicateurs
    int       m_handleMA;
    int       m_handleStdDev;
    
    // Initialisation des handles
    bool InitializeHandles()
    {
        if(m_handleMA != INVALID_HANDLE) IndicatorRelease(m_handleMA);
        if(m_handleStdDev != INVALID_HANDLE) IndicatorRelease(m_handleStdDev);
        
        m_handleMA = iMA(NULL, 0, m_period, 0, MODE_SMA, PRICE_CLOSE);
        m_handleStdDev = iStdDev(NULL, 0, m_period, 0, MODE_SMA, PRICE_CLOSE);
        
        if(m_handleMA == INVALID_HANDLE || m_handleStdDev == INVALID_HANDLE)
        {
            Print("Échec de l'initialisation des handles des indicateurs");
            return false;
        }
        return true;
    }
    
    // Calcul des indicateurs avec gestion optimisée de la mémoire
    bool CalculateIndicators()
    {
        if(m_handleMA == INVALID_HANDLE || m_handleStdDev == INVALID_HANDLE)
        {
            if(!InitializeHandles()) return false;
        }
        
        // Buffers temporaires
        double bufferMA[], bufferStdDev[];
        ArraySetAsSeries(bufferMA, true);
        ArraySetAsSeries(bufferStdDev, true);
        
        // Copie des données avec vérification du nombre de barres disponibles
        int copied = CopyBuffer(m_handleMA, 0, 0, m_period, bufferMA);
        if(copied != m_period)
        {
            Print("Échec de la copie des données MA: ", copied);
            return false;
        }
        
        copied = CopyBuffer(m_handleStdDev, 0, 0, m_period, bufferStdDev);
        if(copied != m_period)
        {
            Print("Échec de la copie des données StdDev: ", copied);
            return false;
        }
        
        // Calcul des canaux avec vérification des données
        for(int i = 0; i < m_period; i++)
        {
            if(!MathIsValidNumber(bufferMA[i]) || !MathIsValidNumber(bufferStdDev[i]))
            {
                Print("Données invalides détectées à l'index ", i);
                return false;
            }
            
            m_maBuffer[i] = bufferMA[i];
            m_middleBuffer[i] = bufferMA[i];  // Ajout de la valeur moyenne
            m_upperBuffer[i] = bufferMA[i] + m_deviation * bufferStdDev[i];
            m_lowerBuffer[i] = bufferMA[i] - m_deviation * bufferStdDev[i];
        }
        return true;
    }

public:
    // Constructeur avec initialisation des handles
    CSDCCalculator(int period, double deviation)
        : m_period(period),
          m_deviation(deviation),
          m_handleMA(INVALID_HANDLE),
          m_handleStdDev(INVALID_HANDLE)
    {
        ArrayResize(m_upperBuffer, m_period);
        ArrayResize(m_lowerBuffer, m_period);
        ArrayResize(m_middleBuffer, m_period);  // Redimensionnement du buffer intermédiaire
        ArrayResize(m_maBuffer, m_period);
        ArraySetAsSeries(m_upperBuffer, true);
        ArraySetAsSeries(m_lowerBuffer, true);
        ArraySetAsSeries(m_middleBuffer, true);  // Configuration du buffer intermédiaire
        ArraySetAsSeries(m_maBuffer, true);
    }
    
    // Destructeur pour libérer les ressources
    ~CSDCCalculator()
    {
        if(m_handleMA != INVALID_HANDLE) IndicatorRelease(m_handleMA);
        if(m_handleStdDev != INVALID_HANDLE) IndicatorRelease(m_handleStdDev);
    }
    
    // Mise à jour des calculs
    bool Update()
    {
        return CalculateIndicators();
    }
    
    // Getters pour accéder aux buffers
    double GetUpperValue(int index) const
    {
        return index < m_period ? m_upperBuffer[index] : 0.0;
    }
    
    double GetLowerValue(int index) const
    {
        return index < m_period ? m_lowerBuffer[index] : 0.0;
    }
    
    double GetMAValue(int index) const
    {
        return index < m_period ? m_maBuffer[index] : 0.0;
    }
    
    double GetMiddleValue(int index) const  // Ajout du getter pour le buffer intermédiaire
    {
        return index < m_period ? m_middleBuffer[index] : 0.0;
    }
    
    // Obtenir les valeurs des buffers
    bool GetBufferValues(int index, double &upper, double &lower, double &middle, double &ma)
    {
        if(index >= m_period) return false;
        
        upper = m_upperBuffer[index];
        lower = m_lowerBuffer[index];
        middle = m_middleBuffer[index];  // Ajout de la valeur intermédiaire
        ma = m_maBuffer[index];
        return true;
    }
    
    // Obtenir la période
    int GetPeriod() const { return m_period; }
};