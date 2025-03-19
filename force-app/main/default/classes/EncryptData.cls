public class EncryptData {
    public static String encryptData(Map<String, Object> requestData) {
        Blob apiKey = Blob.valueOf('kENnr0fXbdCiYRuvqRDySvEgt0Y0CFHS');
        String cipher = 'AES-256';
        Blob iv = Blob.valueOf('062e2803735b415c');
        String jsonRequest = JSON.serialize(requestData);
        Blob data = Blob.valueOf(jsonRequest);
        Blob encrypted = Crypto.encrypt(cipher, apiKey, iv, data);
        return EncodingUtil.base64Encode(encrypted);
    }
}