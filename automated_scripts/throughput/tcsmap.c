#include <stdio.h>
#include <unistd.h>
#include <stdint.h>
#include <stdbool.h>
#include <sys/mman.h>
#include <stdlib.h>
#include <fcntl.h>
#include <errno.h>

struct sgx_arch_tcs_t {
    char t[4096]; 
};
struct thread_map {
    unsigned int tid;
    struct sgx_arch_tcs_t* tcs;
    uint64_t stack;
    bool thread_for_new_process;
    bool used_by_new_process;
    int process_id;
    bool stop_complete;
    char socket_path[30];
};

const char* tcs_fd_path = "/sharedVolume/tcs_map";

const int thread_num = 128;

int main() {
    int tcs_map_fd = open(tcs_fd_path, O_RDONLY | O_CREAT, 0666);
    if (tcs_map_fd < 0) {
        printf("tcs_map_fd failed\n");
    }
    FILE* f = fopen(tcs_fd_path, "r");
    fseek(f, 0, SEEK_END);
    int filelength = ftell(f);
    fclose(f);
    void* ret = mmap(NULL, filelength, PROT_READ, MAP_SHARED, tcs_map_fd, 0);
    if (ret == 0){
        printf("%d\n", errno);
    }
    struct thread_map* g_enclave_thread_map = (struct thread_map*) ret; 

    for (int i = 0; i < thread_num; ++i) {
        struct thread_map* t = g_enclave_thread_map + i;
        printf("\n"); 
        printf("i: %u\n", i); 
        printf("tid: %u\n", t->tid); 
        printf("process_id: %u\n", t->process_id); 
        printf("thread_for_new_process: %d\n", t->thread_for_new_process); 
        printf("used_by_new_process: %d\n", t->used_by_new_process); 
        printf("stop_complete: %d\n", t->stop_complete); 
    }

    return 0;
}
