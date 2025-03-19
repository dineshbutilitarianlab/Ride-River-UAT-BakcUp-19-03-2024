/** 

Created by Prathap KR

OAuth Helper Class

This class will handle obtaining and refreshing the OAuth access token.
*/
public class OAuthHelper {
    private static final String TOKEN_URL = 'https://login.salesforce.com/services/oauth2/token';

    public static String getAccessToken() {
        // Fetch OAuth credentials from custom setting
        OAuth_Credentials__c oauthCredentials = OAuth_Credentials__c.getOrgDefaults();

        if (oauthCredentials == null) {
            throw new OAuthException('OAuth credentials not found');
        }

        if (String.isEmpty(oauthCredentials.Access_Token__c)) {
            refreshToken(oauthCredentials);
        }

        return oauthCredentials.Access_Token__c;
    }

    public static void refreshToken(OAuth_Credentials__c oauthCredentials) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint(TOKEN_URL);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        req.setBody('grant_type=refresh_token' +
                    '&client_id=' + oauthCredentials.Client_Id__c +
                    '&client_secret=' + oauthCredentials.Client_Secret__c +
                    '&refresh_token=' + oauthCredentials.Refresh_Token__c);

        Http http = new Http();
        HttpResponse res;
        try {
            res = http.send(req);
            if (res.getStatusCode() == 200) {
                Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
                String newAccessToken = (String) responseMap.get('access_token');

                // Update custom setting with new access token
                oauthCredentials.Access_Token__c = newAccessToken;
                update oauthCredentials;
            } else {
                throw new OAuthException('Failed to refresh token: ' + res.getBody());
            }
        } catch (Exception e) {
            throw new OAuthException('Exception occurred while refreshing token: ' + e.getMessage());
        }
    }

    public class OAuthException extends Exception {}
}