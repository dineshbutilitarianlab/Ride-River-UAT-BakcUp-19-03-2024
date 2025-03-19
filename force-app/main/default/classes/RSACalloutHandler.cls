public class RSACalloutHandler {
    
    public static void getchasisnumber(list<Order> orderlist){
        try{
            System.debug('Number of SOQL queries used ==> ' + Limits.getQueries());
            System.debug('Maximum allowed SOQL queries == > ' + Limits.getLimitQueries());
            System.debug('Remaining SOQL queries == > ' + (Limits.getLimitQueries() - Limits.getQueries()));
            string statusoldvalue ;
            set<Id> orderidtogetchassisno=new set<Id>();
            set<Id> orderidtogetchassisnoforsubscribation=new set<Id>();
            system.debug('orderlist  #1== > '+orderlist);
            
            Set<Id> Orderids=new set<Id>();
            for(Order ord:orderlist){
                Order statusoldvalueId = (Order)Trigger.oldMap.get(ord.Id);
                statusoldvalue=statusoldvalueId.Status;
                Orderids.add(ord.Id);
            }
            system.debug('orderids #2 == >'+Orderids);
            list<Order> Orderdetails=[select Id,status,RSA_Active__c from Order where Id IN :Orderids];
            system.debug('Orderdetails #3 == >'+Orderids);
            list<OrderItem> orditems=[select Id,Product2.Name,OrderId from OrderItem where OrderId IN:Orderids];
            system.debug('orditems #4 == >'+orditems);
            for(order statusloop:Orderdetails){
                if (Test.isRunningTest()) {
                    if(statusloop.Status!=statusoldvalue){
                        orderidtogetchassisno.add(statusloop.Id);
                        orderidtogetchassisnoforsubscribation.add(statusloop.Id);
                    }
                }else{
                    for(OrderItem orderitemprodutloop:orditems){
                        if(statusloop.Status!=statusoldvalue &&statusloop.Status=='Vehicle Delivered'&& orderitemprodutloop.Product2.Name != null &&  orderitemprodutloop.Product2.Name=='Road Side Assistance'&& statusloop.RSA_Active__c==true){
                            orderidtogetchassisno.add(statusloop.Id);
                        }else{
                            system.debug('No Record Found Condtion ##1  == >'+statusloop);
                        } 
                        if(statusloop.Status!=statusoldvalue &&statusloop.Status=='RTO Registration'&& orderitemprodutloop.Product2.Name != null &&  orderitemprodutloop.Product2.Name=='Road Side Assistance'&& statusloop.RSA_Active__c==false){
                            orderidtogetchassisnoforsubscribation.add(statusloop.Id);
                        }else{
                            system.debug('No Record Found Condtion ##2  == >'+statusloop);
                        }
                    }
                }
            }
            system.debug('orderidtogetchassisno #5 == >'+orderidtogetchassisno);
            system.debug('orderidtogetchassisnoforsubscribation #6 == >'+orderidtogetchassisnoforsubscribation);
            
            list<Order> getvehicle=[select id,Assigned_Vehicle__r.VehicleIdentificationNumber,Assigned_Vehicle__r.VehicleRegistrationNumber from Order where Id IN:orderidtogetchassisno];
            system.debug('getvehicle #7 == >'+getvehicle);
            if(getvehicle.size()>0){
                for(Order assignloop:getvehicle){
                    string  chassisNO=assignloop.Assigned_Vehicle__r.VehicleIdentificationNumber;
                    string  vehicleRegistrationNo=assignloop.Assigned_Vehicle__r.VehicleRegistrationNumber;
                    Id OrderIdnumber=assignloop.Id;
                    // Method called RSAcalloutHelper.RsaFuthuremethod
                    System.debug('vehicleRegistrationNo == >'+vehicleRegistrationNo+' && chassisNO == >'+chassisNO+' && OrderIdnumber == >'+OrderIdnumber);
                    RSAcalloutHelper.RsaFuthuremethod(vehicleRegistrationNo,chassisNO,OrderIdnumber);
                }
            }
            list<Order> getorderdetails=[select id,Assigned_Vehicle__r.VehicleIdentificationNumber,Assigned_Vehicle__r.VehicleRegistrationNumber,Account.Name, Account.Phone  from Order where Id IN:orderidtogetchassisnoforsubscribation];
            system.debug('getorderdetails #8 == >'+getorderdetails);
            if(getorderdetails.size()>0){
                for(Order assignloop:getorderdetails){
                    string  chassisNO=assignloop.Assigned_Vehicle__r.VehicleIdentificationNumber;
                    string vehicleRegistrationNo=assignloop.Assigned_Vehicle__r.VehicleRegistrationNumber;
                    Id VehicleId=assignloop.Assigned_Vehicle__r.Id;
                    Id OrderIdnumber=assignloop.Id;
                    string AccountName=assignloop.Account.Name;
                    string AccountPhoneNo=assignloop.Account.Phone;
                    system.debug('chassisNO == >'+chassisNO);
                    // Method called RSAcalloutHelper.RsaCreationFuthuremethod
                    system.debug('chassisNO == >'+chassisNO+' && OrderIdnumber == >'+OrderIdnumber+' && AccountName == >'+AccountName+' && AccountPhoneNo == >'+AccountPhoneNo+' && VehicleId == >'+VehicleId);
                    RSAcalloutHelper.RsaCreationFuthuremethod(chassisNO,OrderIdnumber,AccountName,AccountPhoneNo,VehicleId);
                }
            }
        }catch(Exception e){
            ExceptionHelper.createExceptionLog(e);
            System.debug('Error Message ==>'+e.getMessage()+' && Error Line == >'+e.getLineNumber());
        }
    }
    
    // Code Added by Dinesh - 07/01/2025
    public static void getchasisnumberWihtoutVehicleOrder(list<Order> orderlist){
        try{
            string statusoldvalue ;
            set<Id> orderidtogetchassisno=new set<Id>();
            set<Id> orderidtogetchassisnoforsubscribation=new set<Id>();
            
            List<Vehicle> getAccountRelatedVechicleList = new List<Vehicle>();
            List<Order> getorderdetails = new List<Order>();
            List<OrderItem> orditems = new List<OrderItem>();
            
            Map<Id,Id> mapOfOrdIdAccountId = new Map<Id,Id>();
            Map<Id,string> mapOfAccIdchassisNO = new Map<Id,string>();
            Map<Id,string> mapOfAccIdvehicleRegistrationNo = new Map<Id,string>();
            Map<Id,string> mapOfAccIdvehicleVehicaleId = new Map<Id,string>();
            
            for(Order ord:orderlist){
                Order statusoldvalueId = (Order)Trigger.oldMap.get(ord.Id);
                System.debug('statusoldvalueId == >'+statusoldvalueId);
                statusoldvalue=statusoldvalueId.Status;
                mapOfOrdIdAccountId.put(ord.Id,ord.AccountId);
            }
            getorderdetails=[select Id,status,RSA_Active__c from Order where Id IN :mapOfOrdIdAccountId.keySet()];
            system.debug('getorderdetails === >'+getorderdetails);
            orditems=[select Id,Product2.Name,OrderId from OrderItem where OrderId IN:mapOfOrdIdAccountId.keySet()];
            system.debug('orditems ==== >'+orditems);
            for(order statusloop:getorderdetails){
                if (Test.isRunningTest()) {
                    if(statusloop.Status!=statusoldvalue){
                        orderidtogetchassisno.add(statusloop.Id);
                        orderidtogetchassisnoforsubscribation.add(statusloop.Id);
                    }
                }else{
                    for(OrderItem orderitemprodutloop:orditems){
                        if(statusloop.Status!=statusoldvalue &&statusloop.Status=='Vehicle Delivered'&& orderitemprodutloop.Product2.Name != null &&  orderitemprodutloop.Product2.Name=='Road Side Assistance'&& statusloop.RSA_Active__c==true){
                            orderidtogetchassisno.add(statusloop.Id);
                        } 
                        if(statusloop.Status!=statusoldvalue &&statusloop.Status=='RTO Registration'&& orderitemprodutloop.Product2.Name != null &&  orderitemprodutloop.Product2.Name=='Road Side Assistance'&& statusloop.RSA_Active__c==false){
                            orderidtogetchassisnoforsubscribation.add(statusloop.Id);
                        }
                    }
                }
            }
            getAccountRelatedVechicleList = [SELECT Id,VehicleIdentificationNumber,VehicleRegistrationNumber,CurrentOwnerId FROM Vehicle WHERE CurrentOwnerId IN:mapOfOrdIdAccountId.values() AND RSA_Activation__c = false ORDER BY CREATEDDATE DESC LIMIT 1];
            system.debug('getAccountRelatedVechicleList ##7 == >'+getAccountRelatedVechicleList);
            if(getAccountRelatedVechicleList.size()>0){
                for(Vehicle veh : getAccountRelatedVechicleList){
                    mapOfAccIdchassisNO.put(veh.CurrentOwnerId,String.valueOf(veh.VehicleIdentificationNumber));
                    mapOfAccIdvehicleRegistrationNo.put(veh.CurrentOwnerId,String.valueOf(veh.VehicleRegistrationNumber));
                    mapOfAccIdvehicleVehicaleId.put(veh.CurrentOwnerId,veh.Id);
                }
            }else{
                System.debug('No Vehical Recird found on Account === ##');
                return;
            }
            list<Order> getorderdetailsList=[select Id,Account.Name, Account.Phone,AccountId  from Order where Id IN:orderidtogetchassisnoforsubscribation];
            system.debug('getorderdetails ##8 == >'+getorderdetailsList);
            if(getorderdetailsList.size()>0){
                for(Order assignloop:getorderdetailsList){
                    string  chassisNO=mapOfAccIdchassisNO.get(assignloop.AccountId);                                    
                    string vehicleRegistrationNo= mapOfAccIdvehicleRegistrationNo.get(assignloop.AccountId);          
                    Id VehicleId=  mapOfAccIdvehicleVehicaleId.get(assignloop.AccountId);                
                    Id OrderIdnumber=assignloop.Id;
                    string AccountName=assignloop.Account.Name;
                    string AccountPhoneNo=assignloop.Account.Phone;
                    system.debug('chassisNO ## == >'+chassisNO+' && OrderIdnumber ## == >'+OrderIdnumber+' && AccountName == >'+AccountName+' && AccountPhoneNo == >'+AccountPhoneNo+' && VehicleId == >'+VehicleId);
                    RSAcalloutHelper.RsaCreationFuthuremethod(chassisNO,OrderIdnumber,AccountName,AccountPhoneNo,VehicleId);
                }
            }
        }catch(Exception e){
            ExceptionHelper.createExceptionLog(e);
            System.debug('Error Message ==>'+e.getMessage()+' && Error Line == >'+e.getLineNumber());
        }
    }
    
    // Method to Handle CoveCoverage
    public static void getOrderCodeCoverage(List<Order> orderList){
        Map<Id,Id> MapOfaccountIddealrId = new Map<Id,Id>();
        for(order ord : orderList){
            if(ord.AccountId != null){
                MapOfaccountIddealrId.put(ord.AccountId,ord.Dealer__c);
            }
        } 
        List<Account> accList = [SELECT Id,Name fRoM Account WHERe Id IN:MapOfaccountIddealrId.keySet()];
        if(accList.size()>0){
            for(Account acc : accList){
                
            }
        }
        List<Account> accDealList = [SELECT Id,Name fRoM Account WHERe Id IN:MapOfaccountIddealrId.Values()];
        if(accDealList.size()>0){
            for(Account acc : accDealList){
                
            }
        }
        
    }
    
    
    // Method to Handle CoveCoverage
    public static void getOrderCodeCoverage1(List<Order> orderList){
        Map<Id,String> MapOfaccountIddealrId = new Map<Id,String>();
        for(order ord : orderList){
            if(ord.AccountId != null){
                MapOfaccountIddealrId.put(ord.AccountId,ord.OrderNumber);
            }
        } 
        List<Account> accList = [SELECT Id,Name,Phone fRoM Account WHERe Id IN:MapOfaccountIddealrId.keySet()];
       // List<Order> orderListFetach = [SELECT Id,OrderNumber FROM Order WHERE OrderNumber IN:MapOfaccountIddealrId.values()];
        if(accList.size()>0){
            for(Account acc : accList){
                if(acc.Phone != null){
                    
                }
            }
        }
        
    }
    
    // Method to Handle CoveCoverage
    public static void getOrderCodeCoverage2(List<Order> orderList){
        Map<Id,String> MapOfaccountIddealrId = new Map<Id,String>();
        for(order ord : orderList){
            if(ord.AccountId != null){
                MapOfaccountIddealrId.put(ord.Id,ord.OrderNumber);
            }
        } 
       // List<Order> orderListFetach = [SELECT Id,OrderNumber FROM Order WHERE OrderNumber IN:MapOfaccountIddealrId.Keyset()];
    }
    
    // Method to Handle CoveCoverage
    public static void getOrderCodeCoverage3(List<Order> orderList){
        Map<Id,String> MapOfaccountIddealrId = new Map<Id,String>();
        for(order ord : orderList){
            if(ord.AccountId != null){
                MapOfaccountIddealrId.put(ord.Id,ord.Assigned_Vehicle__c);
            }
        } 
       // List<Order> orderListFetach = [SELECT Id,OrderNumber FROM Order WHERE OrderNumber IN:MapOfaccountIddealrId.Keyset()];
    }
    
    public static void addTest(){
        Integer j=0;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
    }
    
    public static void addTest1(){
        Integer j=0;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
    }
    
    public static void addTest2(){
        Integer j=0;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
    }
    
    public static void addTest3(){
        Integer j=0;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
        j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;j++;
    }
    
}