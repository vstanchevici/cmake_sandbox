#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "gvrzip.h"

#include <assert.h>
#include <memory.h>

namespace gvrzip
{
    void GVRZip::Compress()
    {

    }

    int GVRZip::Decompress(std::string fileName)
    {

        // if the file provided can't
        // be opened/read, program
        // ends
        if (!fopen(fileName.c_str(), "r"))
            return -2;

        // stores error codes for libzip functions
        int errorp = 0;

        // initializes a pointer to a zip archive
        zip_t* arch = NULL;

        // sets that pointer to the
        // zip file from argv[1]
        arch = zip_open(fileName.c_str(), 0, &errorp);

        // the zip_stat structure
        // contains information such as
        // file name, size, comp size

        struct zip_stat* finfo = NULL;

        // must be allocated enough space
        // (not exact space here)
        finfo = (struct zip_stat*)calloc(256, sizeof(int));

        // "initializes" the structure
        // according to documentation

        zip_stat_init(finfo);

        // initialize file descriptor for
        // zip files inside archive
        zip_file_t* fd = NULL;

        // initialize string pointer for
        // reading from fd
        char* txt = NULL;

        // count = index of file archive   0 =
        // first file

        int count = 0;

        // we open the file at the count'th index inside the
        // archive we loop and print every file and its
        // contents, stopping when zip_stat_index did not return
        // 0, which means the count index is more than # of
        // files
        while ((zip_stat_index(arch, count, 0, finfo)) == 0) {

            // allocate room for the entire file contents
            txt = (char*)calloc(finfo->size + 1, sizeof(char));

            fd = zip_fopen_index(
                arch, count, 0); // opens file at count index
                                 // reads from fd finfo->size
                                 // bytes into txt buffer
            zip_fread(fd, txt, finfo->size);

            printf("file #%i: %s\n\n", count + 1,
                finfo->name); // prints filename

            /*
            printf("%s\n\n",
                txt); // prints entire file contents
            */

         // frees allocated buffer, will
         // reallocate on next iteration of loop
            free(txt);

            // increase index by 1 and the loop will
            // stop when files are not found
            count++;
        }
    }

}
