#include <math.h>
#include <omp.h>

#define lowerb(id, p, n) ((id) * (n) / (p))
#define upperb(id, p, n) (lowerb((id) + 1, p, n) - 1)

/*
 * One Jacobi iteration over the sizex x sizey grid u, written into unew.
 * Returns the sum of squared differences, used to test convergence.
 */
double solve(double *u, double *unew, unsigned sizex, unsigned sizey)
{
    double tmp, diff, sum = 0.0;

    #pragma omp parallel private(tmp, diff) reduction(+: sum)
    {
        // Block decomposition by rows: each thread owns consecutive rows.
        int myid = omp_get_thread_num();
        int howmany = omp_get_num_threads();
        int i_start = lowerb(myid, howmany, sizex);
        int i_end = upperb(myid, howmany, sizex);

        for (int i = fmax(1, i_start); i <= fmin(sizex - 2, i_end); i++) {
            for (int j = 1; j < sizey - 1; j++) {
                tmp = 0.25 * (u[i * sizey + (j - 1)] +    // left
                              u[i * sizey + (j + 1)] +    // right
                              u[(i - 1) * sizey + j] +    // top
                              u[(i + 1) * sizey + j]);    // bottom
                diff = tmp - u[i * sizey + j];
                sum += diff * diff;
                unew[i * sizey + j] = tmp;
            }
        }
    }
    return sum;
}
