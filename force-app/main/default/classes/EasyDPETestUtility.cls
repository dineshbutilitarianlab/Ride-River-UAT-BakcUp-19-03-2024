@IsTest
public with sharing class EasyDPETestUtility
{
    public static string buildjson(){
        StaticResource sr = [SELECT Id, Body FROM StaticResource WHERE Name = 'TestDPEJson' LIMIT 1];
        String body = sr.Body.toString();
        return body;
    }
    
    
}