//random fictional example Header, 

#ifndef FORTRAN_ICD_H
#define FORTRAN_ICD_H

/* Status codes returned by ICD functions. */
typedef enum {
    ICD_OK = 0,
    ICD_ERROR = 1
} ICD_Status;

/* Input data exchanged with Fortran. */
typedef struct {
    int id;
    double value;
} ICD_Data;

/* Initializes the ICD interface. */
ICD_Status icd_initialize(void);

/* Processes input data and returns a result. */
ICD_Status icd_process(const ICD_Data *input, ICD_Data *output);

/* Releases interface resources. */
void icd_finalize(void);

#endif /* FORTRAN_ICD_H */