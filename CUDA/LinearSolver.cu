#include "LinearSolver.cuh"


__device__ int matrixToArray(int row, int col, int n)
{
	return (row * n + col);
}

__device__ void matrixVectorProduct(complex_t *M, complex_t *v, complex_t *y, int n)
{
	for (int i = 0; i < n; i++)
	{
		*(y + i) = 0;
		for (int j = 0; j < n; j++)
		{
			*(y + i) += *(M + matrixToArray(i, j, n)) * *(v + j);
		}
	}
}

__device__ void matrixMatrixProduct(complex_t *A, complex_t *B, complex_t *C, int n)
{
	for (int i = 0; i < n; i++)
	{
		for (int j = 0; j < n; j++)
		{
			complex_t currentSum = complex_t(0, 0);
			for (int k = 0; k < n; k++)
			{
				currentSum += *(A + matrixToArray(i, k, n)) * *(B + matrixToArray(k, j, n));
			}
			*(C + matrixToArray(i, j, n)) = currentSum;
		}
	}
}


// Decomposes Matrix A into an Upper (stored in U) and a Lower (stored in L) triangular matrix using
// doolittle factorization.
//
// n is the number of rows/columns of A, A is a row-major matrix.
//
// Code implemented from pesudocode found in Cheney/Kincade, "Numerical Mathematics", pg 300.
__device__ void LUDecomp(complex_t *A, complex_t *L, complex_t *U, int n)
{

	//printf("A(device) = \n");
	for (int row = 0; row < n; row++)
	{
		for (int col = 0; col < n; col++)
		{
			//printf("%0.2f ", *(A + matrixToArray(row, col, n)));
			*(L + matrixToArray(row, col, n)) = complex_t(0, 0);
			*(U + matrixToArray(row, col, n)) = complex_t(0, 0);
		}
		//printf("\n");
	}

	for (int k = 0; k < n; k++)
	{
		// L_kk = 1 (set 1 along the diagonal of L)
		*(L + matrixToArray(k, k, n)) = 1;

		for (int j = k; j < n; j++)
		{
			complex_t currentSum = 0;
			for (int s = 0; s < k; s++)
			{
				complex_t L_Val = *(L + matrixToArray(k, s, n));
				complex_t U_Val = *(U + matrixToArray(s, j, n));;
				currentSum += L_Val * U_Val;
			}

			// U_kj = A_kj - currentSum
			*(U + matrixToArray(k, j, n)) = *(A + matrixToArray(k, j, n)) - currentSum;
		}

		for (int i = k + 1; i < n; i++)
		{
			complex_t currentSum = 0;
			for (int s = 0; s < k; s++)
			{
				complex_t L_Val = *(L + matrixToArray(i, s, n));
				complex_t U_Val = *(U + matrixToArray(s, k, n));;
				currentSum += L_Val * U_Val;
			}

			// L_ik = (A_ik - currentSum)/U_kk
			*(L + matrixToArray(i, k, n)) = (*(A + matrixToArray(i, k, n)) - currentSum) / *(U + matrixToArray(k, k, n));
		}

	}
}


__device__ void matrixVectorProduct(double *M, double *v, double *y, int n)
{
	for (int i = 0; i < n; i++)
	{
		*(y + i) = 0;
		for (int j = 0; j < n; j++)
		{
			*(y + i) += *(M + matrixToArray(i, j, n)) * *(v + j);
		}
	}
}

// Solves Ax = b for x, where A has been decomposed into upper (U) and lower (L) triangular matrices.
//
//	LUx = b -> first, let Ux = z => Lz = b, solve for z.
// 
//	Second, solve Ux = z for x.
// Code written from pseudocode in Cheney/Kincaid, pg 301.
__device__ void linSolve(complex_t *A, complex_t *L, complex_t *U, complex_t *b, int n)
{
	complex_t *x = &A[0];
	complex_t *z = &A[n];

	for (int i = 0; i < n; i++)
	{
		*(z + i) = 0;
	}
	// *******************
	// Solve Lz = b for z.
	// *******************

	// z_0 = b_0.
	*(z) = *(b);

	// finding the rest of z 
	for (int i = 1; i < n; i++)
	{
		complex_t currentSum = 0;
		for (int j = 0; j < i; j++)
		{
			complex_t lVal = *(L + matrixToArray(i, j, n));
			complex_t zVal = *(z + j);
			currentSum += lVal * zVal;
		}

		*(z + i) = *(b + i) - currentSum;
	}

	// *******************
	// Solve Ux = z for x.
	// *******************

	//x_n = z_n/U_nn
	*(x + (n - 1)) = *(z + (n - 1)) / *(U + matrixToArray(n - 1, n - 1, n));

	// finding the rest of x
	for (int i = (n - 2); i >= 0; i--)
	{
		complex_t currentSum = 0;
		for (int j = i + 1; j < n; j++)
		{
			complex_t uVal = *(U + matrixToArray(i, j, n));
			complex_t xVal = *(x + j);
			currentSum += uVal * xVal;
		}

		*(x + i) = (*(z + i) - currentSum) / *(U + matrixToArray(i, i, n));
	}

}

__device__ void LUDecomp_PartialPivot(complex_t *A, complex_t *L, complex_t *U, complex_t *P, int n)
{

	//printf("A(device) = \n");
	for (int row = 0; row < n; row++)
	{
		for (int col = 0; col < n; col++)
		{
			//printf("%0.2f ", *(A + matrixToArray(row, col, n)));
			*(L + matrixToArray(row, col, n)) = complex_t(0, 0);
			*(U + matrixToArray(row, col, n)) = complex_t(0, 0);
			*(P + matrixToArray(row, col, n)) = complex_t(0, 0);
		}
	}

	for (int k = 0; k < n; k++)
	{
		*(P + matrixToArray(k, k, n)) = complex_t(1, 0);
	}

	int pivotRow;
	complex_t pivotVal;
	complex_t pivotCandidate;

	complex_t tempP;
	complex_t tempA;
	for (int k = 0; k < n; k++)
	{
		// L_kk = 1 (set 1 along the diagonal of L)
		*(L + matrixToArray(k, k, n)) = complex_t(1, 0);

		// Pivoting
		pivotRow = k;
		pivotVal = *(A + matrixToArray(k, k, n));
		double pivotNorm = pivotVal.real() * pivotVal.real() + pivotVal.imag() * pivotVal.imag();
		for (int i = k + 1; i < n; i++)
		{
			pivotCandidate = *(A + matrixToArray(i, k, n));
			double candidateNorm = pivotCandidate.real() * pivotCandidate.real() + pivotCandidate.imag() * pivotCandidate.imag();
			if (candidateNorm > pivotNorm)
			{
				pivotVal = pivotCandidate;
				pivotRow = i;
				pivotNorm = candidateNorm;
			}
		}

		// Swapping rows if necessary.
		if (pivotRow != k)
		{
			for (int j = 0; j < n; j++)
			{
				// swap rows pivotRow and k of P
				tempP = *(P + matrixToArray(pivotRow, j, n));
				*(P + matrixToArray(pivotRow, j, n)) = *(P + matrixToArray(k, j, n));
				*(P + matrixToArray(k, j, n)) = tempP;

				// swap rows pivotRow and k of A
				tempA = *(A + matrixToArray(pivotRow, j, n));
				*(A + matrixToArray(pivotRow, j, n)) = *(A + matrixToArray(k, j, n));
				*(A + matrixToArray(k, j, n)) = tempA;
			}

			if (k >= 1)
			{
				// interchange rows pivotRow and k in cols 1:k-1 of L
				for (int j = 0; j < k; j++)
				{
					tempA = *(L + matrixToArray(pivotRow, j, n));
					*(L + matrixToArray(pivotRow, j, n)) = *(L + matrixToArray(k, j, n));
					*(L + matrixToArray(k, j, n)) = tempA;
				}

			}
		}

		// Peforming gaussian elimination
		for (int i = k + 1; i < n; i++)
		{
			// L[i][k] = A[i][k] / A[k][k]
			*(L + matrixToArray(i, k, n)) = *(A + matrixToArray(i, k, n)) / *(A + matrixToArray(k, k, n));

			for (int j = k + 1; j < n; j++)
			{
				// A[i][j] = A[i][j] - L[i][k] * A[k][j]
				*(A + matrixToArray(i, j, n)) -= *(L + matrixToArray(i, k, n)) * *(A + matrixToArray(k, j, n));
			}
		}

		for (int j = k; j < n; j++)
		{
			//U[k][j] = A[k][j];
			*(U + matrixToArray(k, j, n)) = *(A + matrixToArray(k, j, n));
		}
	}
}


// Solves the linear system Ax = b.
// Stores the value of x in A from 0:n
__device__ void solveLinearSystem(complex_t *A, complex_t *L, complex_t *U, complex_t *P, complex_t *b, int n, double t)
{

	LUDecomp_PartialPivot(A, L, U, P, n);
	//if (threadIdx.x == 0 && t == 1.0)
	//{
	//	printf("A = \n");
	//	for (int i = 0; i < n; i++)
	//	{
	//		for (int j = 0; j < n; j++)
	//		{
	//			complex_t currentVal = *(A + (i * n) + j);
	//			printf("(%0.5f,  %0.5f) ", currentVal.real(), currentVal.imag());
	//		}
	//		printf("\n");
	//	}
	//	printf("\n\n");

	//	printf("L = \n");
	//	for (int i = 0; i < n; i++)
	//	{
	//		for (int j = 0; j < n; j++)
	//		{
	//			printf("%f ", *(L + (i * n) + j));
	//		}
	//		printf("\n");
	//	}
	//	printf("\n\n");
	//}

	// Permutating b vec by the permutation matrix P
	matrixVectorProduct(P, b, &A[0], n);

	for (int i = 0; i < n; i++)
	{
		*(b + i) = *(A + i);
	}

	linSolve(A, L, U, b, n);
	// A from 0:n holds the value of x



}