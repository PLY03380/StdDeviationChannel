#include "../Utilities/ErrorHandler.mqh"

class CBaseIndicator
{
protected:
    int       m_period;
    double    m_deviation;
    double    m_buffers[][3];  // Flexible buffer for multiple indicator lines
    
    virtual bool CalculateIndicators() = 0;  // Pure virtual method to force implementation
    
public:
    CBaseIndicator(int period, double deviation = 2.0)
    {
        m_period = period;
        m_deviation = deviation;
    }
    
    virtual bool Initialize()
    {
        if(m_period <= 0)
        {
            CErrorHandler::LogError("Invalid period for indicator initialization");
            return false;
        }
        
        ArrayResize(m_buffers, m_period);
        return true;
    }
    
    virtual bool Update() 
    {
        return CalculateIndicators();
    }
    
    virtual bool DrawIndicator(const string name, const color clr) = 0;  // Abstract drawing method
    
    // Getters
    int GetPeriod() const { return m_period; }
    double GetDeviation() const { return m_deviation; }
    
    // Virtual destructor for proper cleanup
    virtual ~CBaseIndicator() 
    {
        ArrayFree(m_buffers);
    }
};