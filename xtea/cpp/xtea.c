//-----------------------------------------------------------------------------
//-- Title      : XTEA C Implementation
//-----------------------------------------------------------------------------
//-- Created    : 2022-11-25
//-- Standard   : C
//-----------------------------------------------------------------------------
//-- Description:
//--    Execution unit of the XTEA block. Below is the algorithm
//--
//--    Split M into two equal parts V0, V1 each of the size of w bits
//--
//--    SUM = 0
//--
//--    for j= 1 to r do
//--       {
//--          W00 = ((V1 << 4) XOR (V1 >> 5)) + V1
//--          W01 = SUM + KEY[SUM mod 4]
//--          T0 = W00 XOR W01
//--          V0' = V0 + T0
//--
//--          SUM' = SUM + DELTA
//--
//--          W10 = ((V0' << 4) XOR (V0' >> 5)) + V0'
//--          W11 = SUM' + KEY[(SUM'>>11) mod 4]
//--          T1 = W10 XOR W11
//--          V1' = V1 + T1
//--
//--          SUM = SUM'
//--          V0 = V0'
//--          V1 = V1'
//--       }
//--
//--    C = V0 || V1
//-----------------------------------------------------------------------------
//-- Revisions:
//-- Date        | Release | Author | Description
//-- 2022-11-25      1.0       AT     Initial Version
//-- 2022-12-05      1.1       AT     C directives for ROUND and DELTA.
//--                                  To make the code more generic,
//--                                  a pointer to the array of keys was passed
//--                                  to the encrypt function as an argument,
//--                                  with the array itself defined in the
//--                                  function main().
//-----------------------------------------------------------------------------

#include <string.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

// Constants
#define ROUND 3;
#define DELTA 0x800A;

// Funtion that enchiper's a message using XTEA algorithm
void encipher(unsigned int test_num, uint16_t v0, uint16_t v1, uint16_t key[4]) {

	int        max_iter = ROUND;                         // Specifies the rounds

	uint16_t   w00, w01, t0, w10, w11, t1, sum = 0x0000; // Intermediate Variables

	uint16_t   cH, cL;  // cH : MSB 16 bits; cL LSB 16 bits

	printf("-----------------------------\n");
	printf(" TestNum  :  %d\n", test_num);
	printf("-----------------------------\n");

	unsigned int j;

	// Encryption Block
	for (j=0; j < max_iter; j++) {
		w00  = ((v1 << 4) ^ (v1 >> 5)) + v1;
		w01  = sum + key[sum & 3];
		t0   = w00 ^ w01;
		v0  += t0;
		sum += DELTA;
		w10  = ((v0 << 4) ^ (v0 >> 5)) + v0;
		w11  = sum + key[(sum>>11) & 3];
		t1   = w10 ^ w11;
		v1  += t1;

		printf("**********\n");
		printf(" Run    %d\n", j);
		printf("**********\n");
		printf("Output w00 : %x\n", w00);
		printf("Output w01 : %x\n", w01);
		printf("Output t0  : %x\n", t0);
		printf("Output v0  : %x\n", v0);
		printf("Output sum : %x\n", sum);
		printf("Output w10 : %x\n", w10);
		printf("Output w11 : %x\n", w11);
		printf("Output t1  : %x\n", t1);
		printf("Output v1  : %x\n", v1);
		printf("   \n");
	}
	cH = v0;
	cL = v1;

	printf("Output cH %x\n", cH);
	printf("Output cL %x\n", cL);
	printf("  \n");

}

// Main
int main() {

	// Keys used for encyption
	uint16_t KEY[4] = {0xABCD, 0xCCCC, 0x6666, 0xFEDC};

	// Pointer to the KEY array
	uint16_t *ptr = KEY;

	test0 : encipher(0, 0xFFFF, 0x0000, ptr);
	test1 : encipher(1, 0x0000, 0xFFFF, ptr);
	test2 : encipher(2, 0xAAAA, 0x0000, ptr);
	test3 : encipher(3, 0x5555, 0x0000, ptr);
	test4 : encipher(4, 0xFFFF, 0xAAAA, ptr);
	test5 : encipher(5, 0xFFFF, 0x5555, ptr);
	test6 : encipher(6, 0x0101, 0x1010, ptr);
	test7 : encipher(7, 0xABCD, 0xEF01, ptr);
	test8 : encipher(8, 0xABCD, 0xDA1A, ptr);
	test9 : encipher(9, 0xDA1A, 0x0001, ptr);

	return 0;

}
