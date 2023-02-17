#pragma once

/*
#include <boost/beast/core.hpp>
#include <boost/beast/http.hpp>
#include <boost/beast/ssl.hpp>
#include <boost/beast/version.hpp>
#include <boost/asio/connect.hpp>
#include <boost/asio/ip/tcp.hpp>
#include <boost/asio/ssl/error.hpp>
#include <boost/asio/ssl/stream.hpp>

#include <boost/url/error.hpp>
#include <boost/url/segments_encoded_ref.hpp>
#include <boost/url/segments_encoded_view.hpp>
#include <boost/url/string_view.hpp>
#include <boost/url/url.hpp>
#include <boost/url/url_view.hpp>
#include <boost/url/static_url.hpp>
*/

/*
namespace beast = boost::beast; // from <boost/beast.hpp>
namespace http = beast::http;   // from <boost/beast/http.hpp>

namespace urls = boost::urls;
using string_view = urls::string_view;
*/

//#include <memory>
#include <functional>
#include <string>


#include <boost/beast.hpp>
#include <boost/beast/ssl.hpp>

namespace beast = boost::beast; 
namespace http = beast::http;
namespace net = boost::asio;    // from <boost/asio.hpp>
namespace ssl = net::ssl;       // from <boost/asio/ssl.hpp>

using tcp = net::ip::tcp;       // from <boost/asio/ip/tcp.hpp>

class HttpClient: public std::enable_shared_from_this<HttpClient>
{
    public:
        constexpr static std::string_view client_version = "Boost.Beast/1.0";

    private:
        std::function<void()> callback_;

        tcp::resolver resolver_;
        beast::ssl_stream<beast::tcp_stream> stream_;
        beast::flat_buffer buffer_;
        http::request<http::empty_body> req_;
        http::response<http::string_body> res_;

    private:
        void run(char const* host, char const* port, char const* target, int version);
        void on_resolve(beast::error_code ec, tcp::resolver::results_type results);
        void on_connect(beast::error_code ec, tcp::resolver::results_type::endpoint_type);
        void on_handshake(beast::error_code ec);
        void on_write(beast::error_code ec, std::size_t bytes_transferred);
        void on_read(beast::error_code ec, std::size_t bytes_transferred);
        void on_shutdown(beast::error_code ec);
        void fail(beast::error_code ec, char const* what);

    public:

        explicit HttpClient(net::any_io_executor ex, ssl::context& ctx) : resolver_(ex), stream_(ex, ctx) {}
        inline ~HttpClient() {}

        void Open(std::string& url);
        void Send();
        void Send(std::string& data);
        void Send(void* data, size_t size);

};