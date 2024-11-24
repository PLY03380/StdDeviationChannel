//+------------------------------------------------------------------+
//|                                            SDCExpertAdvisor.mq5    |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024"
#property version   "1.00"
#property strict

#include "Core/SDCCalculator.mqh"
#include "Core/InputValidator.mqh"
#include "UI/InterfaceManager.mqh"
#include "UI/ChartObjects.mqh"
#include "Utilities/ErrorHandler.mqh"
#include "Utilities/PointerUtilities.mqh"

// Paramètres d'entrée
input string   InpName = "StdDevChannel";    // Nom du canal
input int      InpPeriod = 20;               // Période
input double   InpDeviation = 2.0;           // Déviation
input color    InpColor = clrRed;            // Couleur
input bool     InpShowPanel = true;          // Afficher le panneau

// Variables globales
CSDCCalculator*    g_calculator = NULL;
CInterfaceManager* g_interface = NULL;
bool               g_initialized = false;

//+------------------------------------------------------------------+
//| Expert initialization function                                     |
//+------------------------------------------------------------------+
int OnInit()
{
    // Initialisation du gestionnaire d'erreurs
    CErrorHandler::Initialize("SDC_ErrorLog.txt");
    
    // Validation des entrées
    if(!CInputValidator::ValidateInputs(InpPeriod, InpDeviation))
        return INIT_PARAMETERS_INCORRECT;
    
    // Création et initialisation du calculateur
    g_calculator = new CSDCCalculator(InpPeriod, InpDeviation);
    if(!g_calculator || !g_calculator->Update())
    {
        CErrorHandler::LogError("Échec de l'initialisation du calculateur");
        return INIT_FAILED;
    }
    
    // Création et initialisation de l'interface si demandée
    if(InpShowPanel)
    {
        g_interface = new CInterfaceManager();
        if(!g_interface || !g_interface->Initialize())
        {
            CErrorHandler::LogError("Échec de l'initialisation de l'interface");
            return INIT_FAILED;
        }
    }
    
    g_initialized = true;
    return INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                   |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
    SafeDelete(g_calculator);
    SafeDelete(g_interface);
    CChartObjects::CleanupObjects(InpName);
}

//+------------------------------------------------------------------+
//| Expert tick function                                              |
//+------------------------------------------------------------------+
void OnTick()
{
    if(!g_initialized || !g_calculator->Update()) return;
    
    DrawChannel();
}

//+------------------------------------------------------------------+
//| Draw the channel on the chart                                     |
//+------------------------------------------------------------------+
void DrawChannel()
{
    ObjectsDeleteAll(0, InpName);
    
    for(int i = 0; i < g_calculator->GetPeriod() - 1; i++)
    {
        double upper1, lower1, ma1, upper2, lower2, ma2;
        datetime time1 = iTime(NULL, 0, i + 1);
        datetime time2 = iTime(NULL, 0, i);
        
        if(!g_calculator->GetBufferValues(i + 1, upper1, lower1, ma1) || 
           !g_calculator->GetBufferValues(i, upper2, lower2, ma2))
            continue;
            
        // Ligne moyenne
        string maName = StringFormat("%s_MA_%d", InpName, i);
        CChartObjects::CreateTrendLine(maName, time1, ma1, time2, ma2, 
                                     InpColor, STYLE_SOLID, 1);
        
        // Bande supérieure
        string upperName = StringFormat("%s_Upper_%d", InpName, i);
        CChartObjects::CreateTrendLine(upperName, time1, upper1, time2, upper2,
                                     InpColor, STYLE_DOT);
        
        // Bande inférieure
        string lowerName = StringFormat("%s_Lower_%d", InpName, i);
        CChartObjects::CreateTrendLine(lowerName, time1, lower1, time2, lower2,
                                     InpColor, STYLE_DOT);
    }
}

//+------------------------------------------------------------------+
//| ChartEvent function                                               |
//+------------------------------------------------------------------+
void OnChartEvent(const int id, const long& lparam, const double& dparam, const string& sparam)
{
    if(!g_initialized || g_interface == NULL) return;
    g_interface->HandleChartEvent(id, lparam, dparam, sparam);
}