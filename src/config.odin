package http;

import "core:net"

@(private)
defualt_server_config : Server_config = {
    port = 8080,
    url = net.IP4_Address{127, 0, 0, 1}
}
