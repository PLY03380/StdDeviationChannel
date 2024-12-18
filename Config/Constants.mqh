//+------------------------------------------------------------------+
//|                                                   Constants.mqh    |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024"
#property link      ""
#property version   "1.00"
#property strict

// Constantes de l'interface utilisateur
#define UI_BUTTON_WIDTH    80
#define UI_BUTTON_HEIGHT   25
#define UI_EDIT_WIDTH      60
#define UI_EDIT_HEIGHT     20
#define UI_PANEL_MARGIN    10

// Constantes de calcul
#define MIN_PERIOD         5
#define MAX_PERIOD         200
#define MIN_DEVIATION      0.1
#define MAX_DEVIATION      10.0

// Constantes de dessin
#define MAX_CHART_OBJECTS  1000
#define DEFAULT_LINE_WIDTH 1

// Messages d'erreur
#define ERR_INVALID_PERIOD    "Période invalide. Doit être entre " + MIN_PERIOD + " et " + MAX_PERIOD
#define ERR_INVALID_DEVIATION "Déviation invalide. Doit être entre " + MIN_DEVIATION + " et " + MAX_DEVIATION