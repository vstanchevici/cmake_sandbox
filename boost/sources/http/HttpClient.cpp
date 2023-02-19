#include "HttpClient.h"

#include <boost/url/parse.hpp>
#include <iostream>

void HttpClient::Open(const std::string& url)
{
    auto res = boost::urls::parse_uri(url);

    if (res.has_value())
    {
        boost::urls::url_view uv = res.value();

        std::cout << uv.scheme() << std::endl;
        std::cout << uv.host_name() << std::endl;
        std::cout << uv.port_number() << std::endl;
        std::cout << uv.encoded_path() << std::endl;
        std::cout << uv.encoded_fragment() << std::endl;

        /*
        for (auto& param : uv.params())
            std::cout << param.key << " : " << param.value << std::endl;
        */
    }
}

void HttpClient::Send()
{

}

void HttpClient::Send(std::string& data)
{

}

void HttpClient::Send(void* data, size_t size)
{

}

// Start the asynchronous operation
void HttpClient::run(char const* host, char const* port, char const* target, int version)
{
    // Set SNI Hostname (many hosts need this to handshake successfully)
    if (!SSL_set_tlsext_host_name(stream_.native_handle(), host))
    {
        beast::error_code ec{ static_cast<int>(::ERR_get_error()), net::error::get_ssl_category() };
        std::cerr << ec.message() << "\n";
        return;
    }

    // Set up an HTTP GET request message
    req_.version(version);
    req_.method(http::verb::get);
    req_.target(target);
    req_.set(http::field::host, host);
    //req_.set(http::field::user_agent, BOOST_BEAST_VERSION_STRING);
    req_.set(http::field::user_agent, client_version);

    // Look up the domain name
    resolver_.async_resolve(
        host,
        port,
        beast::bind_front_handler(
            &HttpClient::on_resolve,
            shared_from_this()));
}

void HttpClient::on_resolve(beast::error_code ec, tcp::resolver::results_type results)
{
    if (ec)
        return fail(ec, "resolve");

    // Set a timeout on the operation
    beast::get_lowest_layer(stream_).expires_after(std::chrono::seconds(30));

    // Make the connection on the IP address we get from a lookup
    beast::get_lowest_layer(stream_).async_connect(
        results,
        beast::bind_front_handler(
            &HttpClient::on_connect,
            shared_from_this()));
}

void HttpClient::on_connect(beast::error_code ec, tcp::resolver::results_type::endpoint_type)
{
    if (ec)
        return fail(ec, "connect");

    // Perform the SSL handshake
    stream_.async_handshake(
        ssl::stream_base::client,
        beast::bind_front_handler(
            &HttpClient::on_handshake,
            shared_from_this()));
}

void HttpClient::on_handshake(beast::error_code ec)
{
    if (ec)
        return fail(ec, "handshake");

    // Set a timeout on the operation
    beast::get_lowest_layer(stream_).expires_after(std::chrono::seconds(60));

    // Send the HTTP request to the remote host
    http::async_write(stream_, req_,
        beast::bind_front_handler(
            &HttpClient::on_write,
            shared_from_this()));
}

void HttpClient::on_write(beast::error_code ec, std::size_t bytes_transferred)
{
    boost::ignore_unused(bytes_transferred);

    if (ec)
        return fail(ec, "write");

    // Receive the HTTP response
    http::async_read(stream_, buffer_, res_,
        beast::bind_front_handler(
            &HttpClient::on_read,
            shared_from_this()));
}

void HttpClient::on_read(beast::error_code ec, std::size_t bytes_transferred)
{
    boost::ignore_unused(bytes_transferred);

    if (ec)
        return fail(ec, "read");

    // Write the message to standard out
    std::cout << res_ << std::endl;

    // Set a timeout on the operation
    beast::get_lowest_layer(stream_).expires_after(std::chrono::seconds(10));

    // Gracefully close the stream
    stream_.async_shutdown(
        beast::bind_front_handler(
            &HttpClient::on_shutdown,
            shared_from_this()));
}

void HttpClient::on_shutdown(beast::error_code ec)
{
    if (ec == net::error::eof)
    {
        // Rationale:
        // http://stackoverflow.com/questions/25587403/boost-asio-ssl-async-shutdown-always-finishes-with-an-error
        ec = {};
    }
    if (ec)
        return fail(ec, "shutdown");

    // If we get here then the connection is closed gracefully
}

void HttpClient::fail(beast::error_code ec, char const* what)
{
    std::cerr << what << ": " << ec.message() << "\n";
}
