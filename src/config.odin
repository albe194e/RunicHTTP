package http;

import "core:net"
import "core:os"
import "core:fmt"
import "core:encoding/json"
import "core:reflect"

Server_config :: struct {
    port: int,
    url: string,
}

Test_config :: struct {
    integer: int,
    text: string,
    point: f32
}

Config_type_e :: enum {
    TEST,
    SERVER,
}

Config_type_u :: union {
    Server_config,
    Test_config,
}

// Loads a custom json file for a configuration (e.g Server_config). 
load_config_from_file :: proc(path : string, type : Config_type_e) -> (config : Config_type_u) {

    //Find type & initialize with defualt configurations
    #partial switch type {
        case .SERVER:
            config = defualt_server_config;
            break;
        case .TEST:
            config = Test_config{};
            break;
        case:
            panic("That config type does not exist")
        }
            
    //Load saved JSON data
    data, ok_file := os.read_entire_file_from_filename(path);
    defer delete(data);

	if ok_file {

        json_data, json_err := json.parse(data);
        defer json.destroy_value(json_data);
        
        if (json_err != nil) {
            //TODO: remove panic
            fmt.panicf("Json parse err: %#v\n", json_err)
        }
        
        //Check if json field corrosponds with config type struct field
        struct_fields := reflect.struct_field_names(reflect.union_variant_typeid(config))
        //TODO: Implement showing all non existing fields in err instead of just 1 at a time.
        for json_field in json_data.(json.Object) {
            field_exists : bool
            for sf in struct_fields {
                if json_field == sf {
                    field_exists = true;
                    break;
                }
            }
            if !field_exists {
                //TODO: remove panic
                fmt.panicf("Json field: %#v does does not exist in config type: %#v\n", json_field, type)
            }
        }
        
        err : json.Unmarshal_Error;
        #partial switch type {
            case .SERVER:
                config, err = load_server_config(data);
                break;
            case .TEST:
                config, err = load_test_config(data)
                break;
            case:
                panic("That config type does not exist")
            }

		if err != nil {
            fmt.printfln("Err: %#v", err)
            panic("Failed to load config")
		} else {
            fmt.printf("\nSuccesfully loaded config file: %#v\n", config)
		}

	} else {
        fmt.panicf("Failed to load configuration file: %#v", path)
    }

    return config
}

//At the moment, json.unmarshal does not work with unions as i inteded to,
//unfortunatly defualting to the first union variant when used. 
//These methods just specifies what union variant json.marshal should be working with.
@(private="file")
load_server_config :: proc(data : []byte) -> (config : Server_config, err : json.Unmarshal_Error) {
    err = json.unmarshal(data, &config);
    return config, err;
}
@(private="file")
load_test_config :: proc(data : []byte) -> (config : Test_config, err : json.Unmarshal_Error) {
    err = json.unmarshal(data, &config);
    return config, err;
}
