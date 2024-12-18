#include "../Utilities/ErrorHandler.mqh"

class CChartObjects
{
public:
    static bool CreateChannel(const string name, const double upper1, const double lower1,
                            const double upper2, const double lower2, const color clr,
                            const ENUM_LINE_STYLE style = STYLE_SOLID,
                            const int width = 1,
                            const bool fill = true)
    {
        datetime time1 = TimeCurrent();
        datetime time2 = time1 + PeriodSeconds(PERIOD_CURRENT) * 20;
        
        // Créer le canal supérieur
        if(!ObjectCreate(0, name + "_upper", OBJ_TREND, 0, time1, upper1, time2, upper2))
        {
            Print("Échec de création de la ligne supérieure du canal: ", GetLastError());
            return false;
        }
        
        // Créer le canal inférieur
        if(!ObjectCreate(0, name + "_lower", OBJ_TREND, 0, time1, lower1, time2, lower2))
        {
            Print("Échec de création de la ligne inférieure du canal: ", GetLastError());
            ObjectDelete(0, name + "_upper");
            return false;
        }
        
        // Configurer le canal supérieur
        ObjectSetInteger(0, name + "_upper", OBJPROP_COLOR, clr);
        ObjectSetInteger(0, name + "_upper", OBJPROP_STYLE, style);
        ObjectSetInteger(0, name + "_upper", OBJPROP_WIDTH, width);
        ObjectSetInteger(0, name + "_upper", OBJPROP_BACK, true);
        ObjectSetInteger(0, name + "_upper", OBJPROP_SELECTABLE, false);
        ObjectSetInteger(0, name + "_upper", OBJPROP_HIDDEN, true);
        
        // Configurer le canal inférieur
        ObjectSetInteger(0, name + "_lower", OBJPROP_COLOR, clr);
        ObjectSetInteger(0, name + "_lower", OBJPROP_STYLE, style);
        ObjectSetInteger(0, name + "_lower", OBJPROP_WIDTH, width);
        ObjectSetInteger(0, name + "_lower", OBJPROP_BACK, true);
        ObjectSetInteger(0, name + "_lower", OBJPROP_SELECTABLE, false);
        ObjectSetInteger(0, name + "_lower", OBJPROP_HIDDEN, true);
        
        // Créer la zone de remplissage si demandé
        if(fill)
        {
            if(!ObjectCreate(0, name + "_fill", OBJ_RECTANGLE, 0, time1, upper1, time2, lower2))
            {
                Print("Échec de création du remplissage du canal: ", GetLastError());
                ObjectDelete(0, name + "_upper");
                ObjectDelete(0, name + "_lower");
                return false;
            }
            
            color fillColor = clr;
            ObjectSetInteger(0, name + "_fill", OBJPROP_COLOR, fillColor);
            ObjectSetInteger(0, name + "_fill", OBJPROP_BACK, true);
            ObjectSetInteger(0, name + "_fill", OBJPROP_FILL, true);
            ObjectSetInteger(0, name + "_fill", OBJPROP_SELECTABLE, false);
            ObjectSetInteger(0, name + "_fill", OBJPROP_HIDDEN, true);
        }
        
        ChartRedraw();
        return true;
    }
    
    static bool UpdateChannel(const string name, const double upper1, const double lower1,
                            const double upper2, const double lower2)
    {
        datetime time1 = TimeCurrent();
        datetime time2 = time1 + PeriodSeconds(PERIOD_CURRENT) * 20;
        
        // Mettre à jour la ligne supérieure
        if(!ObjectMove(0, name + "_upper", 0, time1, upper1) ||
           !ObjectMove(0, name + "_upper", 1, time2, upper2))
        {
            Print("Échec de la mise à jour de la ligne supérieure: ", GetLastError());
            return false;
        }
        
        // Mettre à jour la ligne inférieure
        if(!ObjectMove(0, name + "_lower", 0, time1, lower1) ||
           !ObjectMove(0, name + "_lower", 1, time2, lower2))
        {
            Print("Échec de la mise à jour de la ligne inférieure: ", GetLastError());
            return false;
        }
        
        // Mettre à jour le remplissage si présent
        if(ObjectFind(0, name + "_fill") >= 0)
        {
            if(!ObjectMove(0, name + "_fill", 0, time1, upper1) ||
               !ObjectMove(0, name + "_fill", 1, time2, lower2))
            {
                Print("Échec de la mise à jour du remplissage: ", GetLastError());
                return false;
            }
        }
        
        ChartRedraw();
        return true;
    }
    
    static void CleanupObjects(const string prefix = "")
    {
        for(int i = ObjectsTotal(0) - 1; i >= 0; i--)
        {
            string name = ObjectName(0, i);
            if(prefix == "" || StringFind(name, prefix) == 0)
                ObjectDelete(0, name);
        }
        ChartRedraw();
    }
    
    static void DeleteChannel(const string name)
    {
        ObjectDelete(0, name + "_upper");
        ObjectDelete(0, name + "_lower");
        ObjectDelete(0, name + "_fill");
        ChartRedraw();
    }
};