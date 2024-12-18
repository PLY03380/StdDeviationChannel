//+------------------------------------------------------------------+
//|                                              PointerUtilities.mqh  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024"
#property link      ""
#property version   "1.00"
#property strict

template<typename T>
void SafeDelete(T*& ptr)
{
    if(ptr != NULL)
    {
        delete ptr;
        ptr = NULL;
    }
}

// Macro pour la vérification des pointeurs
#define CHECK_POINTER(ptr) if(ptr == NULL) return false

// Macro pour la vérification et suppression des pointeurs
#define SAFE_DELETE(ptr) if(ptr != NULL) { delete ptr; ptr = NULL; }