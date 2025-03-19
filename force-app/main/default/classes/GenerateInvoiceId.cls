public class GenerateInvoiceId {
    
    public static String generateInvoiceId(String company, String centre, String product, String invoiceNumber) {
        
        Date currentDate = Date.today();
        Integer year = currentDate.year(); 
        Integer month = currentDate.month();
        
        String formattedYear = String.valueOf(year).substring(2, 4);
        String formattedMonth = String.valueOf(month).leftPad(2, '0');
        
        // You can replace the number generation logic as per your requirements
        //String invoiceNumber = '000001';
        invoiceNumber = invoiceNumber.leftPad(6, '0');
        if (invoiceNumber.length() > 6) {
            invoiceNumber = invoiceNumber.substring(invoiceNumber.length() - 6);
        }
        
        // Concatenate all parts to form the final Invoice ID
        // Commented the below invoice id format based on Finance team request (Biswa) Modified :14/10/2024 Developer : Prathap
        //String invoiceId = company + centre + formattedYear + formattedMonth + product + invoiceNumber;
        String invoiceId = company + centre + '25' + invoiceNumber;
        
        return invoiceId;
    }
    
}