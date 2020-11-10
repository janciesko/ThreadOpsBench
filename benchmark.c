
#define _GNU_SOURCE

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/time.h>
#include <unistd.h>
#include <stdarg.h>

static void init(int num_threads);
static void finalize(void);
static void kernel(int num_threads, int num_yields);

static double get_time_sec()
{
    struct timeval tv;
    gettimeofday(&tv, 0);
    return tv.tv_sec + (double)tv.tv_usec * 1e-6;
}

#if defined(USE_QTHREADS)

#include <qthread.h>
#define THREAD_TYPE "QTH"

static aligned_t yield_f(void *arg)
{
    size_t num_yields = (size_t)((intptr_t)arg);
    for (int i = 0; i < num_yields; i++) {
        qthread_yield();
    }
    return 0;
}

aligned_t *g_rets;

static void init(int num_threads)
{
    qthread_initialize();
    g_rets = (aligned_t *)calloc(num_threads, sizeof(aligned_t));
}

static void finalize(void)
{
    free(g_rets);
    qthread_finalize();
}

static void kernel(int num_threads, int num_yields)
{
    for (int i = 0; i < num_threads; i++) {
        qthread_fork(yield_f, (void *)((intptr_t)num_yields), &g_rets[i]);
    }
    for (int i = 0; i < num_threads; i++) {
        qthread_readFF(NULL, &g_rets[i]);
    }
}

#elif defined(USE_ARGOBOTS)

#include <abt.h>
#define THREAD_TYPE "ABT"

static void yield_f(void *arg)
{
    size_t num_yields = (size_t)((intptr_t)arg);
    for (int i = 0; i < num_yields; i++) {
        ABT_thread_yield();
    }
}

ABT_thread *g_threads;
ABT_pool g_pool;

static void init(int num_threads)
{
    ABT_init(0, NULL);
    g_threads = (ABT_thread *)calloc(num_threads, sizeof(ABT_thread));
    ABT_xstream self_xstream;
    ABT_xstream_self(&self_xstream);
#if 0
    ABT_xstream_get_main_pools(self_xstream, 1, &g_pool);
#else
    ABT_sched sched;
    ABT_pool_create_basic(ABT_POOL_FIFO, ABT_POOL_ACCESS_MPMC, ABT_TRUE,
                          &g_pool);
    ABT_sched_create_basic(ABT_SCHED_DEFAULT, 1, &g_pool, ABT_SCHED_CONFIG_NULL,
                           &sched);
    ABT_xstream_set_main_sched(self_xstream, sched);
#endif
}

static void finalize(void)
{
    free(g_threads);
    ABT_finalize();
}

static void kernel(int num_threads, int num_yields)
{
    for (int i = 0; i < num_threads; i++) {
        ABT_thread_create(g_pool, yield_f, (void *)((intptr_t)num_yields),
                          ABT_THREAD_ATTR_NULL, &g_threads[i]);
    }
    for (int i = 0; i < num_threads; i++) {
        ABT_thread_free(&g_threads[i]);
    }
}

#else /* Pthreads. */

#include <pthread.h>
#define THREAD_TYPE "PTH"

static void *yield_f(void *arg)
{
    size_t num_yields = (size_t)((intptr_t)arg);
    for (int i = 0; i < num_yields; i++) {
        pthread_yield();
    }
    return NULL;
}

pthread_t *g_threads;

static void init(int num_threads)
{
    g_threads = (pthread_t *)calloc(num_threads, sizeof(pthread_t));
}

static void finalize(void)
{
    free(g_threads);
}

static void kernel(int num_threads, int num_yields)
{
    for (int i = 0; i < num_threads; i++) {
        pthread_create(&g_threads[i], NULL, yield_f,
                       (void *)((intptr_t)num_yields));
    }
    for (int i = 0; i < num_threads; i++) {
        pthread_join(g_threads[i], NULL);
    }
}

#endif /* Pthreads */

typedef struct benchmark_param_t {
    int num_yields;
    int num_threads;
} benchmark_param_t;

int main(int argc, char *const *argv)
{

    int num_repeats = 8;
    int num_warmups = 4;
    int num_threads = 16;
    int num_yields = 128;
    int print_csv = 0;
    char *prefix = strdup("");

    while (1) {
        int opt = getopt(argc, argv, "hHcr:w:t:y:p:");
        if (opt == -1)
            break;
        switch (opt) {
            case 'c':
                print_csv = 1;
                break;
            case 'r':
                num_repeats = atoi(optarg);
                break;
            case 'w':
                num_warmups = atoi(optarg);
                break;
            case 't':
                num_threads = atoi(optarg);
                break;
            case 'y':
                num_yields = atoi(optarg);
                break;
            case 'p':
                free(prefix);
                prefix = strdup(optarg);
                break;
            case 'H':
                printf("thread_type, benchmark, nrepeats, nthreads, nyields, "
                       "nwarmups, t_per_thread_ns\n");
                return 0;
            case 'h':
            default:
                printf("Usage: ./benchmark [-r NUM_REPEATS] [-w NUM_WARMUPS] "
                       "[-t NUM_THREADS] [-y NUM_YIELDS] [-p PREFIX]\n");
                printf("       -c: print CSV\n");
                printf("       -H: print CSV header and return.\n");
                printf("       -h: show this help.\n");
                printf("ex:    ./benchmark -r 10 -w 5 -t 128 -y 16 -c -p "
                       "nworkers_16_O3\n");
                return -1;
        }
    }

    /* Initialize the threading library */
    init(num_threads);

    /* Measure the overheads */
    benchmark_param_t benchmark_params[2] = { { 0, num_threads },
                                              { num_yields, 1 } };
    double fork_join_overhead_per_thread_ns, yield_overhead_per_thread_ns;
    for (int benchmark_i = 0;
         benchmark_i < sizeof(benchmark_params) / sizeof(benchmark_param_t);
         benchmark_i++) {
        const int num_yields_local = benchmark_params[benchmark_i].num_yields;
        const int num_threads_local = benchmark_params[benchmark_i].num_threads;
        double start_time = 0;
        for (int step = -num_warmups; step < num_repeats; step++) {
            if (start_time == 0)
                start_time = get_time_sec();
            kernel(num_threads_local, num_yields_local);
        }

        double elapsed_time = get_time_sec() - start_time;
        double overhead_per_thread_ns =
            elapsed_time / num_repeats / num_threads_local * 1.0e9;
        if (benchmark_i == 0) {
            fork_join_overhead_per_thread_ns = overhead_per_thread_ns;
        } else if (benchmark_i == 1) {
            yield_overhead_per_thread_ns =
                (overhead_per_thread_ns - fork_join_overhead_per_thread_ns) /
                num_yields_local;
        }
    }

    /* Print data. */
    if (print_csv) {
        printf("%s%s, %s, %d, %d, %d, %d, %f\n", prefix, THREAD_TYPE,
               "FORKJOIN", num_repeats, num_threads, num_yields, num_warmups,
               fork_join_overhead_per_thread_ns);
        printf("%s%s, %s, %d, %d, %d, %d, %f\n", prefix, THREAD_TYPE, "YIELD",
               num_repeats, num_threads, num_yields, num_warmups,
               yield_overhead_per_thread_ns);
    } else {
        printf("[%s%s] #reps = %d, #threads = %d, #yields = %d, #warmups = "
               "%d\n",
               prefix, THREAD_TYPE, num_repeats, num_threads, num_yields,
               num_warmups);
        printf("Fork-join overhead per thread: %f[ns]\n",
               fork_join_overhead_per_thread_ns);
        printf("Yield overhead per thread: %f[ns]\n",
               yield_overhead_per_thread_ns);
    }

    /* Initialize the threading library */
    finalize();
    free(prefix);
    return 0;
}
