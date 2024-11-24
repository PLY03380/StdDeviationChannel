class CErrorHandler
{
public:
    static void LogError(const string message, const int error_code = 0)
    {
        string error_text = StringFormat("❌ %s", message);
        if(error_code != 0)
            error_text += StringFormat(" (Code: %d)", error_code);
            
        Print(error_text);
        
        // Optionnel : Enregistrement dans un fichier log
        string filename = "SDC_ErrorLog.txt";
        int handle = FileOpen(filename, FILE_WRITE|FILE_READ|FILE_TXT);
        
        if(handle != INVALID_HANDLE)
        {
            FileSeek(handle, 0, SEEK_END);
            FileWriteString(handle, TimeToString(TimeCurrent()) + ": " + error_text + "\n");
            FileClose(handle);
        }
    }
    
    static void LogWarning(const string message)
    {
        Print("⚠️ " + message);
    }
    
    static void LogInfo(const string message)
    {
        Print("ℹ️ " + message);
    }
    
    static void LogSuccess(const string message)
    {
        Print("✅ " + message);
    }
};