package main

import "core:fmt"
import "core:net"
import "core:strings"
//import utils "shared:furbs/utils"
import "core:mem"

import "rhttp"

run :: proc() {
    
    //Initiate the server
    s : rhttp.Server;
    sc := rhttp.load_config_from_file("server_config.json", .SERVER).(rhttp.Server_config);

    rhttp.init_server(&s, sc);
    defer rhttp.destroy_server(&s)

    //Add routes
    rhttp.add_route(
        &s.router,
        rhttp.Route{
            path = "/index",
            action = my_get_action
        }
    )

    rhttp.add_route(
        &s.router,
        rhttp.Route{
            path = "/json",
            action = send_json
        }
    )

    rhttp.add_route(
        &s.router,
        rhttp.Route{
            path = "/xml",
            action = send_xml
        }
    )

    rhttp.add_route(
        &s.router,
        rhttp.Route{
            path = "/csv",
            action = send_csv
        }
    )

    rhttp.add_route(
        &s.router,
        rhttp.Route{
            path = "/yaml",
            action = send_yaml
        }
    )

    rhttp.add_route(
        &s.router,
        rhttp.Route{
            path = "/text",
            action = send_txt
        }
    )

    //Start the server
    rhttp.start_server(&s)
}

//JSON
send_json :: proc () -> (r : rhttp.Response, err: rhttp.RhttpError) {

    rhttp.init_response(&r)
    r.body.content = "{\"message\": \"Sending JSON from RunicHttp\"}"
    r.status_line.status.code = .OK
    r.settings.content_type = .JSON

    return r, err
}

//XML
send_xml :: proc () -> (r : rhttp.Response, err: rhttp.RhttpError) {

    rhttp.init_response(&r)
    r.body.content = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<response>\n    <message>Sending JSON from RunicHttp</message>\n</response>"
    r.status_line.status.code = .OK

    return r, err
}

//CSV
send_csv :: proc () -> (r : rhttp.Response, err: rhttp.RhttpError) {

    rhttp.init_response(&r)
    r.body.content = strings.concatenate({
        "id,name,age,email\n",
        "1,John Doe,28,john.doe@example.com\n",
        "2,Jane Smith,34,jane.smith@example.com\n",
        "3,Michael Johnson,25,michael.johnson@example.com\n",
        "4,Emily Davis,40,emily.davis@example.com\n",
        "5,Chris Brown,22,chris.brown@example.com"
    })
    r.status_line.status.code = .OK

    return r, err
}

//YAML
send_yaml :: proc () -> (r : rhttp.Response, err: rhttp.RhttpError) {

    rhttp.init_response(&r)
    r.body.content = strings.concatenate({
        "users:\n",
        "  - id: 1\n",
        "    name: John Doe\n",
        "    age: 28\n",
        "    email: john.doe@example.com\n",
        "  - id: 2\n",
        "    name: Jane Smith\n",
        "    age: 34\n",
        "    email: jane.smith@example.com\n",
        "  - id: 3\n",
        "    name: Michael Johnson\n",
        "    age: 25\n",
        "    email: michael.johnson@example.com\n"
    })
    r.status_line.status.code = .OK

    return r, err
}

//Text
send_txt :: proc () -> (r : rhttp.Response, err: rhttp.RhttpError) {

    rhttp.init_response(&r)
    r.body.content = "Hello, Sending data as Text from RunicHttp server"
    r.status_line.status.code = .OK

    return r, err
}




//Create actions for routes
my_get_action :: proc() -> (r : rhttp.Response, err: rhttp.RhttpError) {

    Mini_struct :: struct {
        str : string,
        integer : int,
        boolean : bool,
        float : f32,
    }

    test_struct :: struct {

        str : string,
        integer : int,
        boolean : bool,
        float : f32,
        array : [2]string,
        object : Mini_struct
    }

    ts : test_struct = {
        str = "Hello",
        integer = 1,
        boolean = true,
        float = 5.24,
        array = {"Hello", "There"},
        object = {
            str = "Hello",
            integer = 1,
            boolean = true,
            float = 5.24,
        }
    }

    rhttp.init_response(&r)
    r.body.content = ""
    r.status_line.status.code = .Created

    r.headers.kv["Accept"] = "application/json"
    

    return r, err;
}

my_login_action :: proc() -> (r : rhttp.Response, err: rhttp.RhttpError) {

    body := ""
    r.body.content = body
    r.status_line.status.code = .OK
    return r, err;
}

//
main :: proc () {
    /*
    context.assertion_failure_proc = utils.init_stack_trace();
    defer utils.destroy_stack_trace();
    
    context.logger = utils.create_console_logger(.Info);
    defer utils.destroy_console_logger(context.logger);
    
    utils.init_tracking_allocators();
    */
    
    {
        //tracker : ^mem.Tracking_Allocator;
        //context.allocator = utils.make_tracking_allocator(tracker_res = &tracker); //This will use the backing allocator,
        
        run();
        
        //free_all(context.temp_allocator);
    }

    /*
    
    utils.print_tracking_memory_results();
    utils.destroy_tracking_allocators();

    */
}
