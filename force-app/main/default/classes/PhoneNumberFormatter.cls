public class PhoneNumberFormatter {
    public static String extractPhoneNumber(String input) {
        if (input == null || input.trim().length() == 0) {
            return 'INVALID_INPUT = '+input;
        }
        
        String cleaned = input.replaceAll('[^0-9]', '');
        if (cleaned.length() >= 10) {
            return cleaned.substring(cleaned.length() - 10);
        }
        
        return 'INSUFFICIENT_DIGITS = '+input;
    }
}