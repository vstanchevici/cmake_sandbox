#include <stdio.h>
#include <stdlib.h>
#include <uv.h>
#include "sources/http_request_call.h"

int hello_world_libuv()
{
    uv_loop_t* loop = (uv_loop_t*)malloc(sizeof(uv_loop_t));
    uv_loop_init(loop);

    printf("Hello world.\n");

    uv_run(loop, UV_RUN_DEFAULT);

    free(loop);
    return 0;
}

#include <functional>

typedef std::function<void(int)> fn;

class HttpRequest : public httplibuv::HttpRequestCall
{
    public:
        HttpRequest(int chunk_size = 0) : HttpRequestCall(chunk_size), message_complete{} {}
        //You can also override the following methods
        /*
          virtual void on_body(const char *p, size_t len);
          virtual void on_message_begin();
          virtual void on_url(const char* url, size_t length);
          virtual void on_header_field(const char* name, size_t length);
          virtual void on_header_value(const char* value, size_t length);
          virtual void on_headers_complete(void);
        */
        void on_message_complete(int status)
        {
            std::cout << this->response_buffer << std::endl;
        };

        fn message_complete;
        inline void on_message_complete2(fn f)
        {
            message_complete = f;// f(10, "car");
        }
        
        void call()
        {
            message_complete(10);
        }
};

class SomeResource
{
    private:
        int k;

    public:
        void method()
        {
            HttpRequest hr;

            k = 324;
            hr.on_message_complete2([this](int mode)
            {
                printf("mode=%d, k=%d\n", mode, this->k);
            });

            hr.call();
        }
};

int main(int argc, char** argv)
{
    /*
    httplibuv::Request request;
    httplibuv::Method method("GET", "www.ya.ru");
    request.method = &method;
    HttpRequest request_call;
    request_call.send(request);

    //Run libuv loop
    uv_run(uv_default_loop(), UV_RUN_DEFAULT);
    */

    httplibuv::Method method1("GET", "ftp://login:pass@serv.example.com:21/function/reg.php;type=i#st"); 
    httplibuv::Method method2("GET", "https://www.youtube.com:443/watch?v=Zs4tjbqyVaM&ab_channel=RetinalFetishStudios");
    httplibuv::Method method3("GET", "https://127.0.0.1:443");

    SomeResource a;
    a.method();

    getchar();
    return 0;
}
