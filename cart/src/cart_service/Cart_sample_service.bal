import ballerina/http;
import ballerina/io;
import ballerina/grpc;

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

        OrderServiceBlockingClient blockingEp = new("http://localhost:9092");
        var UpdateOrderResp = blockingEp->UpdateOrder(item);
        if (UpdateOrderResp is grpc:Error) {
            io:println("Error from Connector: " + UpdateOrderResp.message());
        } else {
            Order result;
            grpc:Headers resHeaders;
            [result, resHeaders] = UpdateOrderResp;
            float subtotal = result["subTotal"];

            // push to OrderArray
            OrderArray.push(<@untainted>result);

            // Sending response message.
            check caller->respond("Item: " + <@untainted>item.itemNumber + 
                                " added to the cart. Subtotal = " + subtotal.toString());
        }
    }

    @http:ResourceConfig {
        methods: ["GET"],
        path: "/checkout"
    }
    resource function checkout(http:Caller caller, http:Request request) returns error? {

        grpc:StreamingClient | grpc:Error streamClient;

        io:println("Calling checkout service....");
        CheckoutServiceClient checkoutEp = new("http://localhost:9091");

        // Initialize call with checkout resource
        streamClient = checkoutEp->Checkout(CheckoutServiceMessageListener);
        if (streamClient is grpc:Error) {
            io:println("Error from Connector: " + streamClient.message() + " - "
                                           + <string>streamClient.detail()["message"]);
            return;
        } else {

            //Start sending messages to the checkout server
            io:println("Sending interim orders to checkout service:");

            int sum = 0;
            foreach var i in 0..< OrderArray.length() {
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

        // send response to the user
        check caller->respond("Checkout Completed");

        // Update Stocks implementation goes here
        UpdateStockRequest stockUpdate ={};
        StockServiceBlockingClient blockingStockEp = new("http://localhost:9090");
        var stockUpdateResult = blockingStockEp->UpdateStock(stockUpdate);
        if (stockUpdateResult is grpc:Error) {
            io:println("Error from Connector: " + stockUpdateResult.message());
        } else {
            io:println("Stock Updated!");
        }

    }
}

service CheckoutServiceMessageListener = service {

    resource function onMessage(FinalBill message) {
        io:println("=======================================");
        io:println("Final Bill: " + message.total.toString());
    }

    resource function onError(error err) {
        // Implementation goes here.
    }

    resource function onComplete() {
        // Implementation goes here.
    }
};

