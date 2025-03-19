@isTest
public class CurrencyToWordsInRupeesTest {
   @IsTest 
    Public static void checkCurrencyToWords(){
        string rupeesInWords = CurrencyToWordsInRupees.convertToWords(198900);
        system.AssertEquals(rupeesInWords, '₹ One Lakh Ninety Eight Thousand Nine Hundred  Rupees Only','Rupees coming wrong');
    }

}