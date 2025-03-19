@IsTest
public class DateUtilsTest {
    
    @IsTest
    public static void testFormatDateInMMDDYYYY() {
        Test.startTest();
        
        Date testDate = Date.newInstance(2025, 3, 6);
        System.debug(DateUtils.formatDateInMMDDYYYY(testDate));
        
        System.debug(DateUtils.formatDateInMMDDYYYY(null));
        
        Test.stopTest();
    }
}