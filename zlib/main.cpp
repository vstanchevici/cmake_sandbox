#include <iostream>
#include "sources/gvrzip.h"
/*
* minzip:
* https://github.com/madler/zlib/tree/master/contrib/minizip
* 
* example:
* https://github.com/madler/zlib/blob/master/examples/zpipe.c
* 
* example:
* https://www.geeksforgeeks.org/c-program-to-read-and-print-all-files-from-a-zip-file/
*/


int wait_for_enter()
{
    do
    {
        std::cout << '\n' << "Press the Enter key to continue.";
    } while (std::cin.get() != '\n');

    return 0;
}

int main(int argc, char** argv)
{
    gvrzip::GVRZip gvrzip;
    gvrzip.Decompress("D:\\projects\\main_menu.zip");

    return wait_for_enter();
}
