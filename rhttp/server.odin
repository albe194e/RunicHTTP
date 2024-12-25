package rhttp;

import "core:net"
import "core:fmt"
import "core:strings"
import "core:bytes"

Server :: struct {
    config : Server_config,
    router : Router
}

init_server :: proc(s : ^Server, config : Server_config = defualt_server_config) {

    fmt.printfln("Initializing Server....")
    
    router : Router;
    init_router(&router);

    s.config = config;
    s.router = router;
    
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

    client_loop : for {
        // Accept a client connection
        client_socket, _, accept_err := net.accept_tcp(listen_socket)
        if accept_err != nil {
            fmt.panicf("accept error: %s", accept_err)
        } else {
            fmt.println("Client connected!")
            //send data back to client
            response_data := handle_request(s.router, {path = "/index"});
            defer delete(response_data)

            sent, send_err := net.send_tcp(client_socket, response_data)
            if send_err != nil {
                fmt.panicf("Error sending data: %#v", send_err)
            }

            fmt.printf("Sent: %i", sent)
        }
        
        net.close(client_socket)
    }
}


destroy_server :: proc(s : ^Server) {

    fmt.printfln("Destoying server....")
    destroy_router(&s.router)

}

//TODO delete
compare_arrays :: proc(a: [8]byte, b: [8]byte) -> bool {
    for i in 0..<len(a) {
        if a[i] != b[i] {
            return false
        }
    }
    return true
}
