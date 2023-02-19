#include <iostream>
#include "http/HttpClient.h"

//https://www.boost.org/doc/libs/1_81_0/libs/beast/doc/html/beast/examples.html#beast.examples.servers_advanced

int main(int argc, char** argv)
{
    net::io_context ioc;
    ssl::context ctx{ssl::context::tlsv12_client};
    HttpClient client(net::make_strand(ioc), ctx);

    client.Open("https://user:pass@subdomain.example.com:443/path/to/my%2dfile.txt?id=42&name=John%20Doe+Jingleheimer%2DSchmidt#page%20anchor");
    
    //std::cout << "sizeof(std::function<void()>) = " << sizeof(client) << std::endl;
    return 0;
}
