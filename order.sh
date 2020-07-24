# adding item1 to the cart
echo "adding item1 to the cart\n"
curl -X POST -d '{ "itemNumber": "item1", "quantity" : 2 }' "http://localhost:8080/cart" -H "Content-Type:application/json"
echo "\n"
# adding item2 to the cart
echo "adding item2 to the cart\n"
curl -X POST -d '{ "itemNumber": "item2", "quantity" : 3 }' "http://localhost:8080/cart" -H "Content-Type:application/json"
echo "\n"
# adding item3 to the cart
echo "adding item3 to the cart\n"
curl -X POST -d '{ "itemNumber": "item3", "quantity" : 7 }' "http://localhost:8080/cart" -H "Content-Type:application/json"
echo "\n"
# calling checkout
echo "calling checkout....\n"
curl http://localhost:8080/checkout
