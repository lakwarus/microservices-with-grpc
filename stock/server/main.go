package main

import (
	"context"
	"flag"
	"fmt"
	"log"
	"net"

	"github.com/golang/glog"
	"google.golang.org/grpc"

	"github.com/microservices-with-gRPC/stock/gen"
)

var (
	grpcServerEndpoint = flag.String("grpc-server-endpoint", "localhost:9090", "gRPC server endpoint")
)

type server struct {
}

func (*server) UpdateStock(ctx context.Context, request *gen.UpdateStockRequest) (*gen.Stock, error) {

	// mock bussiness logic
	println("Stock Updating...")
	response := &gen.Stock{
		// return mock value
		ItemNumber: "item1",
		Quantity:   40,
	}
	return response, nil
}

func main() {
	flag.Parse()
	defer glog.Flush()

	address := "0.0.0.0:9090"
	lis, err := net.Listen("tcp", address)
	if err != nil {
		log.Fatalf("Error %v", err)
	}
	fmt.Printf("Server is listening on %v ...", address)

	s := grpc.NewServer()
	gen.RegisterStockServiceServer(s, &server{})

	s.Serve(lis)
}
