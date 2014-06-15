#include <my_global.h>
#include <my_sys.h>
#include <mysql.h>
#include <stdio.h>
#include <sys/time.h>
#include <unistd.h>

extern "C" {
    my_bool now_usec_init(UDF_INIT *initid, UDF_ARGS *args, char *messages);
    char *now_usec(
                   UDF_INIT *initid,
                   UDF_ARGS *args,
                   char *result,
                   unsigned long *length, 
                   char *is_null,
                   char *error);
}

my_bool now_use_init(UDF_INIT *initd, UDF_ARGS *args, char *message)
{
    return 0;
}

char *now_usec(UDF_INIT *init_d, UDF_ARGS *args, char *result, unsigned long *length, char *is_null, char *error)
{
    stuct timeval tv;
    sttruct tm* ptm;
    char time_string[20];
    time_t t;

    gettimeofday(&tv, NULL);
    t = (time_t)tv.tv_sec;
    ptm=localtime(&t);

    strftime(time_string, sizeof(time_string), "%Y-%m-%d %H:%M:%S", ptm);

    sprint(usec_time_string, "%s.%06ld\n", time_string, tv.tv_usec);
    *length=26;
    return (usec_time_string);
}
