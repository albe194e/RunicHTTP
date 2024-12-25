package tests;

import "core:log"
import "core:testing"

import http "../src"


@(test)
load_config_from_file_test_positive :: proc(t: ^testing.T) {

    expected_cf : http.Server_config = {
        url = "127.0.0.1",
        port = 80
    }
    cf := http.load_config_from_file("tests/assets/server_config.json", .SERVER).(http.Server_config);

    //Assert
    testing.expectf(t, cf.port == expected_cf.port, "%v is not: %v", cf.port, expected_cf.port)
    testing.expectf(t, cf.url == expected_cf.url, "%v is not: %v", cf.url, expected_cf.url)
}

@(test)
load_config_from_file_test_negative :: proc(t: ^testing.T) {

    
}
