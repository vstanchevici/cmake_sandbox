#include <uv.h>
#include <http_parser.h>
#include <iostream>
#include <map>

#define debug(msg) std::cout << "debug: " << msg << std::endl
#define error(msg) std::cout << "error: " << msg << std::endl

namespace httplibuv{

    typedef struct {
    	uv_write_t req;
    	uv_buf_t buf;
    } write_req_t;

	class Method
	{
		public:
			Method(char* method, char* url) 
			{
				int result, connect = 0;
				http_parser_url uri;
				http_parser_url_init(&uri);
				result = http_parser_parse_url(url, strlen(url), connect, &uri);
				if (result != 0)
				{
					printf("Parse error : %d\n", result);
				}
				else
				{
					printf("Parse ok, result : \n");
					printf("\tfield_set: 0x%x, port: %u\n", uri.field_set, uri.port);
					port = uri.port;
					for (int i = 0; i < UF_MAX; i++)
					{
						if ((uri.field_set & (1 << i)) == 0)
						{
							printf("\tfield_data[%u]: unset\n", i);
							continue;
						}

						printf("\tfield_data[%u]: off: %u, len: %u, part: %.*s\n",
							i,
							uri.field_data[i].off,
							uri.field_data[i].len,
							uri.field_data[i].len,
							url + uri.field_data[i].off);
					}
				}
			}

		public:
			char* host;
			int port;
	};

	class Request
	{
		public:
			Method* method;

			std::string to_string() { return ""; }
			std::map<std::string, std::string> headers;
	};

	class HttpRequestCall
	{
		public:
			HttpRequestCall(int chunk_size=0);
			void send(Request& request);

			virtual void on_body(const char *p, size_t len);
			virtual void on_message_complete(int status);
			virtual void on_message_begin();
            virtual void on_url(const char* url, size_t length);
            virtual void on_header_field(const char* name, size_t length);
            virtual void on_header_value(const char* value, size_t length);
            virtual void on_headers_complete(void);
     			
			int chunk_size;
			std::string response_buffer;
			http_parser* parser;
			http_parser_settings* settings;
			uv_handle_t* handle_to_close;
			char* message_to_send;

	};

	//Static methods from libuv
	void send_request_to_ip4(const struct sockaddr* addr, void* request_data);
	void on_dns_resolved(uv_getaddrinfo_t *resolver, int status, struct addrinfo *res);
	int resolve_dns_and_send_request(std::string host_name, int port, void* request_data);
	void on_connect(uv_connect_t *connection, int status);
	void after_write(uv_write_t* req, int status);
	void receive_response(uv_stream_t* handle, ssize_t nread, const uv_buf_t* buf);
	void on_close(uv_handle_t* peer);
	void alloc_buffer(uv_handle_t* handle, size_t suggested_size, uv_buf_t* buf);
	
	//Parser callbacks
	int _on_message_complete_cb(http_parser*);
	int _on_body_cb(http_parser*, const char*, size_t);
	int _on_header_field_cb(http_parser*, const char*, size_t);
	int _on_header_value_cb(http_parser*, const char*, size_t);
	int _on_headers_complete_cb(http_parser*);
	int _on_message_begin_cb(http_parser*) ;
    int _on_url_cb(http_parser*, const char*, size_t);

}
