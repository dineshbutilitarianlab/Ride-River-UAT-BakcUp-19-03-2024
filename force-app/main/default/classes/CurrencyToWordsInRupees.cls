public class CurrencyToWordsInRupees {
    
    private static final String[] units = new String[]{'', 'One', 'Two', 'Three', 'Four', 'Five', 'Six', 'Seven', 'Eight', 'Nine'};
        
        private static final String[] teens = new String[]{ 'Ten', 'Eleven', 'Twelve', 'Thirteen', 'Fourteen', 'Fifteen', 'Sixteen', 'Seventeen', 'Eighteen', 'Nineteen'};
            
            private static final String[] tens = new String[]{'', 'Ten', 'Twenty', 'Thirty', 'Forty', 'Fifty', 'Sixty', 'Seventy', 'Eighty', 'Ninety'};
                
                public static String convertToWords(Decimal amount) {
                    if (amount == null) return '';
                    
                    Integer rupees = amount.intValue();
                    Integer paise = (Integer)Math.round((amount - rupees) * 100);
                    
                    String rupeesInWords = convert(rupees);
                    String paiseInWords = convert(paise);
                    
                    String result = '₹ ' + rupeesInWords + ' Rupees';
                    
                    if (paise > 0) {
                        result += ' and ' + paiseInWords + ' Paise';
                    }
                    
                    return result+' Only';
                }
    
    
    private static String convert(Integer n) {
        IF(n < 0){
            return 'Zero';
        }else if (n < 10) {
            return units[n];
        } else if (n < 20) {
            return teens[n - 10];
        } else if (n < 100) {
            return tens[n / 10] + (math.mod(n, 10) > 0 ? ' ' + units[math.mod(n, 10)] : '');
        } else if (n < 1000) {
            return units[n / 100] + ' Hundred ' + convert(math.mod(n, 100));
        } else if (n < 100000) { 
            return convert(n / 1000) + ' Thousand ' + convert(math.mod(n, 1000));
        } else if (n < 10000000) { 
            return convert(n / 100000) + ' Lakh ' + convert(math.mod(n, 100000));
        } else {
            return convert(n / 10000000) + ' Crore ' + convert(math.mod(n, 10000000));
        }
    }
}