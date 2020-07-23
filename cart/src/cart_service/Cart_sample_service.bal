import ballerina/http;

map<Bill> interimBillMap = {};

listener http:Listener httpListener = new(8080);

@http:ServiceConfig {
    basePath: "/"
}
service cart on httpListener {
    
    @http:ResourceConfig {
        methods: ["POST"],
        path: "/cart"
    }
    resource function addToCart(http:Caller caller, http:Request request) {
        
        var cartReq = request.getJsonPayload();
        Item item = {};
        Bill interimBill = {};
        item.itemNumber="";
        item.quantity=1;

        BillServiceBlockingClient blockingEp = new("http://localhost:9090");
        interimBill = blockingEp->UpdateBill(item);
            


    }
}