@IsTest
public with sharing class debugDPETestUtility
{
    public static string buildjson(){
        StaticResource sr = [SELECT Id, Body FROM StaticResource WHERE Name = 'TestDPEJson' LIMIT 1];
        String body = sr.Body.toString();
        return body;
    }
    public static string buildjsonv1(){
        StaticResource sr = [SELECT Id, Body FROM StaticResource WHERE Name = 'TestDPEJsonv1' LIMIT 1];
        String body = sr.Body.toString();
        return body;
    }
    public static string buildresponsejson(){
        StaticResource sr = [SELECT Id, Body FROM StaticResource WHERE Name = 'TestDPEResponseJson' LIMIT 1];
        String body = sr.Body.toString();
        return body;
    }
    
}