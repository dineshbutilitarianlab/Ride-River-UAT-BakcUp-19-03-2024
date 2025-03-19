public class DateUtils {
    public static String formatDateInMMDDYYYY(Date inputDate) {
        if (inputDate == null) {
            return null;
        }
        return Datetime.newInstance(inputDate, Time.newInstance(0, 0, 0, 0)).format('MM/dd/yyyy');
    }
}