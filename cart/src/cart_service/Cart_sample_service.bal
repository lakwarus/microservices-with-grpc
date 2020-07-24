import ballerina/http;
import ballerina/io;
import ballerina/grpc;

map<Order> interimOrderMap = {};
Order[] OrderArray = [];

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
    
        // Sending response message.
        check caller->respond("Item: " + <@untainted>item.itemNumber + " added to the cart");

    }
    @http:ResourceConfig {
        methods: ["GET"],
        path: "/checkout"
    }
    resource function checkout(http:Caller caller, http:Request request) returns error? {

        grpc:StreamingClient | grpc:Error streamClient;

        io:println("Calling checkout service");
        io:println(interimOrderMap);
        CheckoutServiceClient checkoutEp = new("http://localhost:9091");

        // Initialize call with checkout resource
        streamClient = checkoutEp->Checkout(CheckoutServiceMessageListener);
        if (streamClient is grpc:Error) {
            io:println("Error from Connector: " + streamClient.message() + " - "
                                           + <string>streamClient.detail()["message"]);
            return;
        } else {

            //Start sending messages to the checkout server
            io:println("Sending interim orders to checkout service");

            int sum = 0;
            foreach var i in 1..< OrderArray.length() {
                sum = sum + i;
                Order value = {};
                value = OrderArray.pop();

                grpc:Error? connErr = streamClient->send(value);
                if (connErr is grpc:Error) {
                    io:println("Error from Connector: " + connErr.message() + " - "
                                                + <string>connErr.detail()["message"]);            
                } else {
                    io:println("Sent item: " + value.itemNumber + " Quantity: " + value.totalQuantity.toString() +
                                                " Price: " + value.subTotal.toString());
                }
            }
            grpc:Error? connErr1 = streamClient->complete();
            if (connErr1 is grpc:Error) {
                io:println("Error from Connector: " + connErr1.message() + " - "
                                            + <string>connErr1.detail()["message"]);            
            }
        }

        // Update Stocks implementation goes here

        // send response to the user
        check caller->respond("Checkout Completed");
    }
}

// Message listener for incoming messages
service OderServerMessageListener = service {

    resource function onMessage(Order message) {

        io:println("Received response from Order process");
        Order order = {};
        order.itemNumber = message.itemNumber;
        order.totalQuantity = message.totalQuantity;
        order.subTotal = message.subTotal;
        OrderArray.push(<@untainted>order);
        io:println("Received interim Order");
        
    }

    resource function onError(error err) {
        io:println("Error reported from server: " + err.message() + " - "
                                           + <string>err.detail()["message"]);
    }

    resource function onComplete() {
        io:println("Interim oder completed");
        CheckoutServiceClient checkoutep = new("http://localhost:9091");
    }
};

service CheckoutServiceMessageListener = service {

    resource function onMessage(FinalBill message) {
        io:println("Final Bill Total:" + message.total.toString());
    }

    resource function onError(error err) {
        // Implementation goes here.
    }

    resource function onComplete() {
        // Implementation goes here.
    }
};

