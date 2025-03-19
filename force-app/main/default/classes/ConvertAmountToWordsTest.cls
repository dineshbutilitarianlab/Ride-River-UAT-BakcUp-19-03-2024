@IsTest
public class ConvertAmountToWordsTest {
    
    @IsTest
    public static void testNumberToEnglish() {
        Test.startTest();
        
        System.debug(ConvertAmountToWords.numberToEnglish(0));
        System.debug(ConvertAmountToWords.numberToEnglish(5));
        System.debug(ConvertAmountToWords.numberToEnglish(15));
        System.debug(ConvertAmountToWords.numberToEnglish(42));
        System.debug(ConvertAmountToWords.numberToEnglish(123));
        System.debug(ConvertAmountToWords.numberToEnglish(1000));
        Test.stopTest();
    }
    

}