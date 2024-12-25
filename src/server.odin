package http;

import "core:net"
import "core:fmt"
import "core:strings"

Server :: struct {
    config : Server_config,
}


init_server :: proc(s : ^Server, config : Server_config = defualt_server_config) {

    s.config = config;
    
}

start_server :: proc(s : ^Server) {

    fmt.printf("Starting server.........")

    listen_socket, listen_err := net.listen_tcp(net.Endpoint{
        address = net.parse_address(s.config.url),
        port = s.config.port,
    })

    if listen_err != nil {
        fmt.panicf("listen error: %s", listen_err)
    }

    fmt.printf("Server is running on port %d\n", s.config.port)

    for {
        // Accept a client connection
        client_socket, _, accept_err := net.accept_tcp(listen_socket)
        if accept_err != nil {
            fmt.panicf("accept error: %s", accept_err)
        }

        fmt.println("Client connected!")

        for {

            data_in_bytes : [8]byte;
            _, err := net.recv_tcp(client_socket, data_in_bytes[:])
            if err != nil {
                fmt.panicf("error while receiving data: %s", err)
            }

            exit_code := [8]byte{101, 120, 105, 116, 13, 10, 0, 0}
            if compare_arrays(data_in_bytes, exit_code) {
                fmt.println("Connection ended")
                break
            }

            // Convert byte data to string
            data, e := strings.clone_from_bytes(data_in_bytes[:])
            if e != nil {
                fmt.panicf("string conversion error: %s", e)
            }

            fmt.println("Client said:", data)
        }

        net.close(client_socket)
    }
}

destroy_server :: proc(s : ^Server) {


}

compare_arrays :: proc(a: [8]byte, b: [8]byte) -> bool {
    for i in 0..<len(a) {
        if a[i] != b[i] {
            return false
        }
    }
    return true
}
