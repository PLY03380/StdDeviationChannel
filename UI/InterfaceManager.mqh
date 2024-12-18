#include "../Utilities/ErrorHandler.mqh"

class CInterfaceManager
{
private:
    string    m_prefix;
    bool      m_visible;
    int       m_x, m_y;
    int       m_width, m_height;
    
    // Composants UI
    string    m_buttons[];
    string    m_labels[];
    string    m_edits[];
    
    // Ajouter un élément à un tableau dynamique
    void AddToArray(string &arr[], string value)
    {
        int size = ArraySize(arr);
        ArrayResize(arr, size + 1);
        arr[size] = value;
    }
    
    bool CreateButton(const string name, const string text, const int x, const int y)
    {
        string objName = m_prefix + name;
        if(!ObjectCreate(0, objName, OBJ_BUTTON, 0, 0, 0))
        {
            Print("Échec de création du bouton ", name);
            return false;
        }
        
        ObjectSetString(0, objName, OBJPROP_TEXT, text);
        ObjectSetInteger(0, objName, OBJPROP_XDISTANCE, x);
        ObjectSetInteger(0, objName, OBJPROP_YDISTANCE, y);
        ObjectSetInteger(0, objName, OBJPROP_XSIZE, 80);
        ObjectSetInteger(0, objName, OBJPROP_YSIZE, 25);
        ObjectSetInteger(0, objName, OBJPROP_CORNER, CORNER_LEFT_UPPER);
        
        AddToArray(m_buttons, objName);
        return true;
    }
    
    bool CreateLabel(const string name, const string text, const int x, const int y)
    {
        string objName = m_prefix + name;
        if(!ObjectCreate(0, objName, OBJ_LABEL, 0, 0, 0))
        {
            Print("Échec de création du label ", name);
            return false;
        }
        
        ObjectSetString(0, objName, OBJPROP_TEXT, text);
        ObjectSetInteger(0, objName, OBJPROP_XDISTANCE, x);
        ObjectSetInteger(0, objName, OBJPROP_YDISTANCE, y);
        ObjectSetInteger(0, objName, OBJPROP_CORNER, CORNER_LEFT_UPPER);
        
        AddToArray(m_labels, objName);
        return true;
    }
    
    bool CreateEdit(const string name, const string text, const int x, const int y)
    {
        string objName = m_prefix + name;
        if(!ObjectCreate(0, objName, OBJ_EDIT, 0, 0, 0))
        {
            Print("Échec de création du champ d'édition ", name);
            return false;
        }
        
        ObjectSetString(0, objName, OBJPROP_TEXT, text);
        ObjectSetInteger(0, objName, OBJPROP_XDISTANCE, x);
        ObjectSetInteger(0, objName, OBJPROP_YDISTANCE, y);
        ObjectSetInteger(0, objName, OBJPROP_XSIZE, 60);
        ObjectSetInteger(0, objName, OBJPROP_YSIZE, 20);
        ObjectSetInteger(0, objName, OBJPROP_CORNER, CORNER_LEFT_UPPER);
        
        AddToArray(m_edits, objName);
        return true;
    }
    
public:
    CInterfaceManager(const string prefix = "SDC_UI_") : 
        m_prefix(prefix),
        m_visible(true),
        m_x(20), m_y(20),
        m_width(200), m_height(150)
    {
    }
    
    bool Initialize()
    {
        // Création des contrôles
        if(!CreateButton("Apply", "Appliquer", m_x + 10, m_y + 90) ||
           !CreateButton("Reset", "Réinitialiser", m_x + 100, m_y + 90) ||
           !CreateButton("Hide", "Masquer", m_x + 10, m_y + 120))
        {
            return false;
        }
        
        if(!CreateLabel("PeriodLbl", "Période:", m_x + 10, m_y + 10) ||
           !CreateLabel("DeviationLbl", "Déviation:", m_x + 10, m_y + 50))
        {
            return false;
        }
        
        if(!CreateEdit("PeriodEdit", "20", m_x + 90, m_y + 10) ||
           !CreateEdit("DeviationEdit", "2.0", m_x + 90, m_y + 50))
        {
            return false;
        }
        
        return true;
    }
    
    void HandleChartEvent(const int id, const long& lparam, const double& dparam, const string& sparam)
    {
        // Utiliser CHARTEVENT_OBJECT_CLICK au lieu de CHART_EVENT_CLICK
        if(id == CHARTEVENT_OBJECT_CLICK)
        {
            if(StringFind(sparam, m_prefix) == 0)
            {
                string buttonName = StringSubstr(sparam, StringLen(m_prefix));
                
                if(buttonName == "Apply")
                    HandleApplyButton();
                else if(buttonName == "Reset")
                    HandleResetButton();
                else if(buttonName == "Hide")
                    ToggleVisibility();
            }
        }
        // Vous pouvez ajouter d'autres types d'événements si nécessaire
    }
    
    void HandleApplyButton()
    {
        // À implémenter selon vos besoins
        Print("Bouton Appliquer cliqué");
    }
    
    void HandleResetButton()
    {
        // À implémenter selon vos besoins
        Print("Bouton Réinitialiser cliqué");
    }
    
    void ToggleVisibility()
    {
        m_visible = !m_visible;
        
        // Mettre à jour la visibilité des boutons
        for(int i = 0; i < ArraySize(m_buttons); i++)
            ObjectSetInteger(0, m_buttons[i], OBJPROP_TIMEFRAMES, m_visible ? OBJ_ALL_PERIODS : OBJ_NO_PERIODS);
            
        // Mettre à jour la visibilité des labels
        for(int i = 0; i < ArraySize(m_labels); i++)
            ObjectSetInteger(0, m_labels[i], OBJPROP_TIMEFRAMES, m_visible ? OBJ_ALL_PERIODS : OBJ_NO_PERIODS);
            
        // Mettre à jour la visibilité des champs d'édition
        for(int i = 0; i < ArraySize(m_edits); i++)
            ObjectSetInteger(0, m_edits[i], OBJPROP_TIMEFRAMES, m_visible ? OBJ_ALL_PERIODS : OBJ_NO_PERIODS);
            
        ChartRedraw();
    }
    
    ~CInterfaceManager()
    {
        // Nettoyage des boutons
        for(int i = 0; i < ArraySize(m_buttons); i++)
            ObjectDelete(0, m_buttons[i]);
            
        // Nettoyage des labels
        for(int i = 0; i < ArraySize(m_labels); i++)
            ObjectDelete(0, m_labels[i]);
            
        // Nettoyage des champs d'édition
        for(int i = 0; i < ArraySize(m_edits); i++)
            ObjectDelete(0, m_edits[i]);
    }
    
    // Méthodes pour obtenir les valeurs des champs
    double GetPeriodValue()
    {
        string text = ObjectGetString(0, m_prefix + "PeriodEdit", OBJPROP_TEXT);
        return StringToDouble(text);
    }
    
    double GetDeviationValue()
    {
        string text = ObjectGetString(0, m_prefix + "DeviationEdit", OBJPROP_TEXT);
        return StringToDouble(text);
    }
};