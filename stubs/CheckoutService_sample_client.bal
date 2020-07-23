public function main (string... args) {

    CheckoutServiceClient ep = new("http://localhost:9090");

}

service CheckoutServiceMessageListener = service {

    resource function onMessage(string message) {
        // Implementation goes here.
    }

    resource function onError(error err) {
        // Implementation goes here.
    }

    resource function onComplete() {
        // Implementation goes here.
    }
};

