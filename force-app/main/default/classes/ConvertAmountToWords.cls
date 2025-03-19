public with sharing class ConvertAmountToWords {
    public String wordText { get; set; }
    public Decimal numberVal { get; set; }
    
    public void convert() {
        wordText = numberToEnglish(numberVal);
    }

    static String[] firstTwenty = new String[] { 'Zero','One','Two','Three','Four','Five','Six','Seven','Eight','Nine',
            'Ten','Eleven','Twelve','Thirteen','Fourteen','Fifteen','Sixteen','Seventeen','Eighteen','Nineteen' };
    static String[] tens = new String[] { '','Twenty','Thirty','Forty','Fifty','Sixty','Seventy','Eighty','Ninety' };
    static String[] powers = new String[] { 'Crore','Lakh','Thousand','Hundred' };
    static Integer[] thresholds = new Integer[] { 100000000, 100000, 1000, 100 };

  public  static String[] convert(Integer value) {
        String[] result = new String[0];
        Boolean less20 = value < 20, less100 = value < 100;
        if(less20) {
            result.add(firstTwenty[value]);
        } else if(less100) {
            Integer tenValue = value / 10, oneValue = Math.mod(value, 10);
            result.add(tens[tenValue - 1]);
            if(oneValue > 0) {
                result.add(firstTwenty[oneValue]);
            }
        }
        if(less100) {
            return result;
        }
        if(value > 0) {
            for(Integer index = 0; index < thresholds.size(); index++) {
                if(thresholds[index] <= value) {
                    result.addAll(convert(value / thresholds[index]));
                    result.add(powers[index]);
                    value = Math.mod(value, thresholds[index]);
                }
            }
            if(value > 0) {
                result.addAll(convert(value));
            }
        }
        return result;
    }

    static String convertDecimalPart(Decimal value) {
        Integer decimalPart = (Integer) ((value - Math.floor(value)) * 100);
        return decimalPart > 0 ? firstTwenty[decimalPart] + ' ' : '';
    }

    public static String numberToEnglish(Decimal value) {
        if(value == null || value < 0) {
            return '';
        }
        
        // Split the number into integer and decimal parts
        Integer integerPart = value.intValue();
        String integerPartInWords = String.join(convert(integerPart), ' ');
        
        // Handle the decimal part
        String decimalPartInWords = convertDecimalPart(value);
        
        // Combine integer and decimal parts
        return decimalPartInWords != '' 
            ? integerPartInWords + ' and ' + decimalPartInWords 
            : integerPartInWords;
    }
}