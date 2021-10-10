#include <stdio.h>
#include <stdlib.h>
#include <uv.h>

int main()
{
    uv_loop_t* loop = (uv_loop_t*)malloc(sizeof(uv_loop_t));
    uv_loop_init(loop);

    printf("Hello world.\n");

    uv_run(loop, UV_RUN_DEFAULT);

    free(loop);
    return 0;
}
