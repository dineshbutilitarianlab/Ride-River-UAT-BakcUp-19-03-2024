public without sharing class UploadTransactionWrapper {
    public UploadTransactionWrapper() {
    }
    
    public String TransactionNumber;       // Example: "120111177892"
    public Integer SequenceNumber;         // Example: 1
    public String AllowedPaymentMode;      // Example: "1" (1 for CARD, 10 for UPI)
    public String MerchantStorePosCode;   // Example: 1221258
    public String ClientID;                // Example: "1002187"
    public Decimal Amount;                 // Example: 10000 (in Paisa)
    public String UserID;                  // Optional: Example: "RAVI"
    public String MerchantID;              // Example: "29610"
    public String StoreID;                 // Example: "1221258"
    public String CustomerMobileNumber;    // Example: "7678255079"
    public String SecurityToken;           // Example: "a4c9741b-2889-47b8-be2f-ba42081a246e"
    public String IMEI;                    // Example: "a4c9741b-2889-47b8-be2f-ba42081a246e"
    public Integer AutoCancelDurationInMinutes; // Example: 3 (recommended)
    
}