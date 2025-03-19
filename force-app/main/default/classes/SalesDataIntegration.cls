public class SalesDataIntegration {
    @future (callout=true)
    public static void pushSalesData(Id orderId) {
        // Set API endpoint and credentials
        String tokenEndpoint = 'https://empsuat.heavyindustries.gov.in/api/emps/token';
        String salesDataEndpoint = ' https://empsuat.heavyindustries.gov.in/api/SalesData';
        String username = 'Rive847573';
        String apiKey = 'kENnr0fXbdCiYRuvqRDySvEgt0Y0CFHS';

        // Generate token
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(tokenEndpoint);
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');
        request.setBody(JSON.serialize(new Map<String, String> {'username' => username, 'api_key' => apiKey}));
        HttpResponse response = http.send(request);
        Map<String, String> resultMap = (Map<String, String>) JSON.deserialize(response.getBody(), Map<String, String>.class);
        String token = resultMap.get('token');

        // Prepare sales data
        Order order = [SELECT Id, Assigned_Vehicle__r.ManufacturedDate, Assigned_Vehicle__r.VehicleIdentificationNumber FROM Order WHERE Id = :orderId];
        String model_detail_id = '1';
        String vin_chasis_no = order.Assigned_Vehicle__r.VehicleIdentificationNumber;
        String manufact_dt = String.valueOf(order.Assigned_Vehicle__r.ManufacturedDate);
        List<SalesData> salesDataList = new List<SalesData>();
        salesDataList.add(new SalesData(model_detail_id, vin_chasis_no, manufact_dt, '2024-07-25', '1'));

        // Push sales data
        request = new HttpRequest();
        request.setEndpoint(salesDataEndpoint);
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');
        request.setBody(JSON.serialize(new Map<String, Object> {
            'token' => token,
            'oem_code' => 219,
            'saleData' => salesDataList
        }));
        response = http.send(request);

        // Handle response
        System.debug(response.getBody());
    }

    public class SalesData {
        public String model_detail_id {get; set;}
        public String vin_chasis_no {get; set;}
        public String manufact_dt {get; set;}
        public String invoice_dt {get; set;}
        public String cat_id {get; set;}

        public SalesData(String model_detail_id, String vin_chasis_no, String manufact_dt, String invoice_dt, String cat_id) {
            this.model_detail_id = model_detail_id;
            this.vin_chasis_no = vin_chasis_no;
            this.manufact_dt = manufact_dt;
            this.invoice_dt = invoice_dt;
            this.cat_id = cat_id;
        }
    }
}