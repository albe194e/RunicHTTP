package rhttp;

import "core:net"
import "core:fmt"
import "core:strings"
import "core:bytes"

SERVER_TEMP_BUFFER :: 4096;

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

    main_loop : for {
        // Accept a client connection
        client_socket, _, accept_err := net.accept_tcp(listen_socket)
        if accept_err != nil {
            fmt.panicf("accept error: %s", accept_err)
        } else {
            fmt.println("Client connected!")

            //Prepare buffer
            request_buffer := make([dynamic]byte);
            defer delete(request_buffer)

            //Read
            recv_loop : for {
                buff : [SERVER_TEMP_BUFFER]byte;
                bytes_read, err := net.recv_tcp(client_socket, buff[:]);
                if err != nil {
                    fmt.panicf("error while receiving data: %s", err)
                }

                append(&request_buffer, ..buff[:])
                //TODO: Find out when to break the loop
                break recv_loop;
            }
            request := parse_request(request_buffer[:])

            //Handle the request
            response_data := handle_request(s.router, request);
            defer delete(response_data)
            
            //send data back to client
            sent, send_err := net.send_tcp(client_socket, response_data)
            if send_err != nil {
                fmt.panicf("Error sending data: %#v", send_err)
            }
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
