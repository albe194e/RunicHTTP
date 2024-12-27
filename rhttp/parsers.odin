package rhttp;

import "core:fmt"
import "core:strings"
import "core:bytes"

@(private)
parse_request :: proc(data : []byte) -> (r : Request) {

    //Get headers
    header_byte_seperator := transmute([]byte)HEADER_SEPERATOR_S;
    data_split := bytes.split_after(data, header_byte_seperator);

    headers := data_split[0][:]
    //Get necessary data from headers
    method_path := bytes.split(headers, {BACKSLASH});
    method := method_path[0][:]
    path := bytes.split(method_path[1][:], {SPACE})[0][:];
    
    r.method = string_to_request_method(strings.clone_from_bytes(method));
    r.path = fmt.aprintf("/%v",strings.clone_from_bytes(path));

    fmt.printfln("Showing: %#v", strings.clone_from_bytes(data_split[0][:]))
    return r;
}

@(private)
parse_response :: proc(r : Response) -> (bytes : []byte) {

    //Here the response should be formmated into appropiete string and converted to bytes
    return transmute([]byte)r.body;

}


//Helpers 
@(private="file")
string_to_request_method :: proc(s : string) -> Request_method {

    switch (s) {
        case "GET":
            return .GET
        case :
            return nil
    }
}


//Strings
@(private="file")
HEADER_SEPERATOR_S : string : "\r\n\r\n";

//Chars in bytes
@(private="file")
BACKSLASH : byte : 47;
@(private="file")
SPACE : byte : 32;
