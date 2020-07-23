import ballerina/http;
import ballerina/io;

map<Order> interimOrderMap = {};

listener http:Listener httpListener = new(8080);

@http:ServiceConfig {
    basePath: "/"
}
service cart on httpListener {
    
    @http:ResourceConfig {
        methods: ["POST"],
        path: "/cart",
        body: "itemReq"
    }
    resource function addToCart(http:Caller caller, http:Request request, json itemReq) returns error? {
        
     
        Item item = {};
        item.itemNumber = <string>itemReq.itemNumber;
        item.quantity = <int>itemReq.quantity;

        OrderServiceClient orderEp = new("http://localhost:9090");
        var result = orderEp->UpdateOrder(item,OderServerMessageListener);
    
        //string subtotal = interimOrderMap.get(item.itemNumber)["subTotal"].toString();

        string subtotal = "0";
        // Sending response message.
        check caller->respond("Item: " + <@untainted>item.itemNumber + 
                                " added to the cart. Subtotal: " + <@untainted>subtotal);

    }
    @http:ResourceConfig {
        methods: ["GET"],
        path: "/checkout"
    }
    resource function checkout(http:Caller caller, http:Request request) {
        io:println(" checkout");
        io:println(interimOrderMap);

    }

}

// Message listener for incoming messages
service OderServerMessageListener = service {

    resource function onMessage(Order message) {

        io:println("Received response from Order process");
        Order order = {};
        io:println(message);
        order.itemNumber = message.itemNumber;
        order.totalQuantity = message.totalQuantity;
        order.subTotal = message.subTotal;
        interimOrderMap[order.itemNumber] = <@untainted>order;
        io:println("Received interim Order");
        
    }

    resource function onError(error err) {
        io:println("Error reported from server: " + err.message() + " - "
                                           + <string>err.detail()["message"]);
    }

    resource function onComplete() {
        io:println("Interim oder completed");

    }
};