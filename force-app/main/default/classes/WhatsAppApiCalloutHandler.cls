public class WhatsAppApiCalloutHandler {
    @future(callout=true)
    public static void leadcreationmsg(string MobileNo,string templatename){
        WhatsAppApiCallout.sendWhatsAppMessage(MobileNo,templatename);
        
        
    }
    
}