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
	// command-line options:
	// gRPC server endpoint
	grpcServerEndpoint = flag.String("grpc-server-endpoint", "localhost:9090", "gRPC server endpoint")
)

type server struct {
}

func (*server) UpdateStock(ctx context.Context, request *gen.UpdateStockRequest) (*gen.Stock, error) {
	//itemNo := request.GetItemNumber
	//quantity := request.GetQuantity
	response := &gen.Stock{}
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
