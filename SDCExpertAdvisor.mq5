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
    if(g_calculator == NULL || !g_calculator.Update())
    {
        CErrorHandler::LogError("Échec de l'initialisation du calculateur");
        return INIT_FAILED;
    }
    
    // Création et initialisation de l'interface si demandée
    if(InpShowPanel)
    {
        g_interface = new CInterfaceManager();
        if(g_interface == NULL || !g_interface.Initialize())
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
    if(!g_initialized || !g_calculator.Update()) return;
    
    DrawChannel();
}

//+------------------------------------------------------------------+
//| Draw the channel on the chart                                     |
//+------------------------------------------------------------------+
void DrawChannel()
{
    // Suppression des objets précédents
    ObjectsDeleteAll(0, InpName);
    
    // Récupérer les buffers depuis le calculateur
    double upperBuffer[];
    double lowerBuffer[];
    double middleBuffer[];
    
    // Assurez-vous de dimensionner et de copier les buffers correctement
    ArraySetAsSeries(upperBuffer, true);
    ArraySetAsSeries(lowerBuffer, true);
    ArraySetAsSeries(middleBuffer, true);
    
    // Récupérer la taille du buffer
    int bufferSize = g_calculator.GetPeriod() - 1;
    ArrayResize(upperBuffer, bufferSize);
    ArrayResize(lowerBuffer, bufferSize);
    ArrayResize(middleBuffer, bufferSize);
    
    for(int i = 0; i < bufferSize; i++)
    {
        double upper, lower, middle, ma;
        if(!g_calculator.GetBufferValues(i, upper, lower, middle, ma))
            continue;
        
        datetime time1 = iTime(Symbol(), Period(), i);
        datetime time2 = iTime(Symbol(), Period(), i + 1);
        
        // Vérifier que les valeurs sont valides
        if(upper == EMPTY_VALUE || lower == EMPTY_VALUE || middle == EMPTY_VALUE)
            continue;
            
        // Ligne moyenne
        string maName = StringFormat("%s_MA_%d", InpName, i);
        ObjectCreate(0, maName, OBJ_TREND, 0, time1, middle, time2, middle);
        ObjectSetInteger(0, maName, OBJPROP_COLOR, InpColor);
        ObjectSetInteger(0, maName, OBJPROP_STYLE, STYLE_SOLID);
        ObjectSetInteger(0, maName, OBJPROP_WIDTH, 1);
        
        // Bande supérieure
        string upperName = StringFormat("%s_Upper_%d", InpName, i);
        ObjectCreate(0, upperName, OBJ_TREND, 0, time1, upper, time2, upper);
        ObjectSetInteger(0, upperName, OBJPROP_COLOR, InpColor);
        ObjectSetInteger(0, upperName, OBJPROP_STYLE, STYLE_DOT);
        
        // Bande inférieure
        string lowerName = StringFormat("%s_Lower_%d", InpName, i);
        ObjectCreate(0, lowerName, OBJ_TREND, 0, time1, lower, time2, lower);
        ObjectSetInteger(0, lowerName, OBJPROP_COLOR, InpColor);
        ObjectSetInteger(0, lowerName, OBJPROP_STYLE, STYLE_DOT);
    }
}
//+------------------------------------------------------------------+
//| ChartEvent function                                               |
//+------------------------------------------------------------------+
void OnChartEvent(const int id, const long& lparam, const double& dparam, const string& sparam)
{
    if(!g_initialized || g_interface == NULL) return;
    g_interface.HandleChartEvent(id, lparam, dparam, sparam);
}