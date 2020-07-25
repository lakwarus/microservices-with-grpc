# Microservices-with-grpc

Clone microservices-with-grpc git repo and follow the README.md instructions.

$ cd microservices-with-grpc

### running cart microservice
$ cd cart
$ ballerina run cart_service
[ballerina/http] started HTTP/WS listener 0.0.0.0:8080

### running order microservice
$ cd order
$ ballerina run order_service
[ballerina/grpc] started HTTP/WS listener 0.0.0.0:9090

### running checkout microservice
$ cd checkout
$ ballerina run checkout_service
[ballerina/grpc] started HTTP/WS listener 0.0.0.0:9091

### running stock microservice
$ cd stock

### sample payload
$ ./order.sh

Note: Ballerina code sample is implemented by using Swan Lake release

