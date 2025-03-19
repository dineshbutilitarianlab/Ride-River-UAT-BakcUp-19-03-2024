@isTest
private class NumberToWords_Test {
    @isTest static void testNull() {
        String check = NumberToWords.convertNumberToText(null);
        System.assertEquals('',check);
    }
    @isTest static void testZero() {
        String check = NumberToWords.convertNumberToText(0.0);
        System.assertEquals('Zero',check);
    }
    @isTest static void testSevenPointEight() {
        String check = NumberToWords.convertNumberToText(7.8);
        System.assertEquals('Seven',check);
    }
    @isTest static void testTwentyFive() {
        String check = NumberToWords.convertNumberToText(25);
        System.assertEquals('Twenty Five',check);
    }
    @isTest static void testTwentyFiveMillion() {
        String check = NumberToWords.convertNumberToText(25000000);
        System.assertEquals('Twenty Five Million',check);
    }
    @isTest static void testTwentyFiveMillionNineHundredTwentyThreeThousandFiveHundredThree() {
        String check = NumberToWords.convertNumberToText(25923503);
        System.assertEquals('Twenty Five Million Nine Hundred Twenty Three Thousand Five Hundred Three',check);
    }
}