package main;

import "core:fmt"
import "core:net"
import "core:strings"

main :: proc() {

    fmt.print("Hello")
    listen_socket, listen_err := net.listen_tcp(net.Endpoint{
        port = 8000,
        address = net.IP4_Loopback
    })
    if listen_err != nil {
        fmt.panicf("listen error : %s", listen_err)
    }


    // setting up socket for the client to connect to
    client_socket, client_endpoint, accept_err := net.accept_tcp(listen_socket)

    if accept_err != nil {
        fmt.panicf("%s",accept_err)
    }

    for {

        data_in_bytes : [8]byte;
        _ ,err := net.recv_tcp(client_socket, data_in_bytes[:])

        if err != nil {
            fmt.panicf("error while recieving data %s", err)
        }

        exit_code := [8]byte{101, 120, 105, 116, 13, 10, 0, 0}
        if data_in_bytes == exit_code{
            fmt.println("connection ended")
            break
        }

        // converting bytes data to string
        data, e := strings.clone_from_bytes(data_in_bytes[:], context.allocator)
        fmt.println("client said :",data)
    }

    net.close(client_socket)

 }
 