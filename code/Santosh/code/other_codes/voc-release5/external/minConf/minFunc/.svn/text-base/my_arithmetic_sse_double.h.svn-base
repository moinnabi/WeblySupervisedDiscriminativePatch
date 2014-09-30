/*
 *      SSE2 implementation of vector oprations (64bit double).
 *
 * Copyright (c) 2007-2010 Naoaki Okazaki
 * All rights reserved.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

/* $Id$ */

#include <stdlib.h>
#include <malloc.h>
#include <memory.h>

/* Using compiler intrinsics (for SSE >=2) can have a huge speedup effect: 
 *    8x for float and 3.5x for double on Intel Core2.
 *       You have to compile with the right CPU setting, e.g. gcc -march=k8 or -march=nocona */
#ifdef __SSE2__
#include <emmintrin.h> 
#endif

#define fsigndiff(x, y) \
    ((_mm_movemask_pd(_mm_set_pd(*(x), *(y))) + 1) & 0x002)

#define vecset(x, c, n) \
{ \
    int i; \
    __m128d XMM0 = _mm_set1_pd(c); \
    for (i = 0;i < (n);i += 8) { \
        _mm_store_pd((x)+i  , XMM0); \
        _mm_store_pd((x)+i+2, XMM0); \
        _mm_store_pd((x)+i+4, XMM0); \
        _mm_store_pd((x)+i+6, XMM0); \
    } \
}

/*
#define veccpymul_odd_unaligned(arr2, arr1, c, nn) \
{ \
    int i; \
    __m128d XMM7 = _mm_set1_pd(c); \
    for (i = 0;i < ((nn/8)*8);i += 8) { \
        __m128d XMM0 = _mm_loadu_pd((arr1)+i  ); \
        __m128d XMM1 = _mm_loadu_pd((arr1)+i+2); \
        __m128d XMM2 = _mm_loadu_pd((arr1)+i+4); \
        __m128d XMM3 = _mm_loadu_pd((arr1)+i+6); \
        _mm_storeu_pd((arr2)+i  , XMM0); \
        _mm_storeu_pd((arr2)+i+2, XMM1); \
        _mm_storeu_pd((arr2)+i+4, XMM2); \
        _mm_storeu_pd((arr2)+i+6, XMM3); \
    } \
    for ( ;i < (nn); i++) { \
        __m128d XMM0 = _mm_load_sd((arr1)+i  ); \
        _mm_store_sd((arr2)+i  , XMM0); \
    }\
}
*/

#define veccpy_odd_unaligned(arr2, arr1, nn) \
{ \
    int i; \
    for (i = 0;i < ((nn/8)*8);i += 8) { \
        __m128d XMM0 = _mm_loadu_pd((arr1)+i  ); \
        __m128d XMM1 = _mm_loadu_pd((arr1)+i+2); \
        __m128d XMM2 = _mm_loadu_pd((arr1)+i+4); \
        __m128d XMM3 = _mm_loadu_pd((arr1)+i+6); \
        _mm_storeu_pd((arr2)+i  , XMM0); \
        _mm_storeu_pd((arr2)+i+2, XMM1); \
        _mm_storeu_pd((arr2)+i+4, XMM2); \
        _mm_storeu_pd((arr2)+i+6, XMM3); \
    } \
    for ( ;i < (nn); i++) { \
        __m128d XMM0 = _mm_load_sd((arr1)+i  ); \
        _mm_store_sd((arr2)+i  , XMM0); \
    }\
}

#define veccpy_odd(arr2, arr1, nn) \
{ \
    int i; \
    for (i = 0;i < ((nn/8)*8);i += 8) { \
        __m128d XMM0 = _mm_load_pd((arr1)+i  ); \
        __m128d XMM1 = _mm_load_pd((arr1)+i+2); \
        __m128d XMM2 = _mm_load_pd((arr1)+i+4); \
        __m128d XMM3 = _mm_load_pd((arr1)+i+6); \
        _mm_store_pd((arr2)+i  , XMM0); \
        _mm_store_pd((arr2)+i+2, XMM1); \
        _mm_store_pd((arr2)+i+4, XMM2); \
        _mm_store_pd((arr2)+i+6, XMM3); \
    } \
    for ( ;i < (nn); i++) { \
        __m128d XMM0 = _mm_load_sd((arr1)+i  ); \
        _mm_store_sd((arr2)+i  , XMM0); \
    }\
}

#define veccpy(arr2, arr1, nn) \
{ \
    int i; \
    for (i = 0;i < (nn);i += 8) { \
        __m128d XMM0 = _mm_load_pd((arr1)+i  ); \
        __m128d XMM1 = _mm_load_pd((arr1)+i+2); \
        __m128d XMM2 = _mm_load_pd((arr1)+i+4); \
        __m128d XMM3 = _mm_load_pd((arr1)+i+6); \
        _mm_store_pd((arr2)+i  , XMM0); \
        _mm_store_pd((arr2)+i+2, XMM1); \
        _mm_store_pd((arr2)+i+4, XMM2); \
        _mm_store_pd((arr2)+i+6, XMM3); \
    } \
}

#define vecncpy(y, x, n) \
{ \
    int i; \
    for (i = 0;i < (n);i += 8) { \
        __m128d XMM0 = _mm_setzero_pd(); \
        __m128d XMM1 = _mm_setzero_pd(); \
        __m128d XMM2 = _mm_setzero_pd(); \
        __m128d XMM3 = _mm_setzero_pd(); \
        __m128d XMM4 = _mm_load_pd((x)+i  ); \
        __m128d XMM5 = _mm_load_pd((x)+i+2); \
        __m128d XMM6 = _mm_load_pd((x)+i+4); \
        __m128d XMM7 = _mm_load_pd((x)+i+6); \
        XMM0 = _mm_sub_pd(XMM0, XMM4); \
        XMM1 = _mm_sub_pd(XMM1, XMM5); \
        XMM2 = _mm_sub_pd(XMM2, XMM6); \
        XMM3 = _mm_sub_pd(XMM3, XMM7); \
        _mm_store_pd((y)+i  , XMM0); \
        _mm_store_pd((y)+i+2, XMM1); \
        _mm_store_pd((y)+i+4, XMM2); \
        _mm_store_pd((y)+i+6, XMM3); \
    } \
}

#define vecadd(y, x, c, n) \
{ \
    int i; \
    __m128d XMM7 = _mm_set1_pd(c); \
    for (i = 0;i < (n);i += 4) { \
        __m128d XMM0 = _mm_load_pd((x)+i  ); \
        __m128d XMM1 = _mm_load_pd((x)+i+2); \
        __m128d XMM2 = _mm_load_pd((y)+i  ); \
        __m128d XMM3 = _mm_load_pd((y)+i+2); \
        XMM0 = _mm_mul_pd(XMM0, XMM7); \
        XMM1 = _mm_mul_pd(XMM1, XMM7); \
        XMM2 = _mm_add_pd(XMM2, XMM0); \
        XMM3 = _mm_add_pd(XMM3, XMM1); \
        _mm_store_pd((y)+i  , XMM2); \
        _mm_store_pd((y)+i+2, XMM3); \
    } \
}

#define vec3add_odd_unaligned(arr3, arr2, arr1, mul1, nn) \
{ \
    int i; \
    __m128d XMM7 = _mm_set1_pd(mul1); \
    for (i = 0;i < ((nn/4)*4);i += 4) { \
        __m128d XMM0 = _mm_loadu_pd((arr1)+i  ); \
        __m128d XMM1 = _mm_loadu_pd((arr1)+i+2); \
        __m128d XMM2 = _mm_loadu_pd((arr2)+i  ); \
        __m128d XMM3 = _mm_loadu_pd((arr2)+i+2); \
        XMM0 = _mm_mul_pd(XMM0, XMM7); \
        XMM1 = _mm_mul_pd(XMM1, XMM7); \
        XMM2 = _mm_add_pd(XMM2, XMM0); \
        XMM3 = _mm_add_pd(XMM3, XMM1); \
        _mm_storeu_pd((arr3)+i  , XMM2); \
        _mm_storeu_pd((arr3)+i+2, XMM3); \
    } \
    for ( ;i < (nn); i++) { \
        __m128d XMM0 = _mm_load_sd((arr1)+i  ); \
        __m128d XMM2 = _mm_load_sd((arr2)+i  ); \
        XMM0 = _mm_mul_sd(XMM0, XMM7); \
        XMM2 = _mm_add_sd(XMM2, XMM0); \
        _mm_store_sd((arr3)+i  , XMM2); \
    }\
}

#define vec3add_odd(arr3, arr2, arr1, mul1, nn) \
{ \
    int i; \
    __m128d XMM7 = _mm_set1_pd(mul1); \
    for (i = 0;i < ((nn/4)*4);i += 4) { \
        __m128d XMM0 = _mm_load_pd((arr1)+i  ); \
        __m128d XMM1 = _mm_load_pd((arr1)+i+2); \
        __m128d XMM2 = _mm_load_pd((arr2)+i  ); \
        __m128d XMM3 = _mm_load_pd((arr2)+i+2); \
        XMM0 = _mm_mul_pd(XMM0, XMM7); \
        XMM1 = _mm_mul_pd(XMM1, XMM7); \
        XMM2 = _mm_add_pd(XMM2, XMM0); \
        XMM3 = _mm_add_pd(XMM3, XMM1); \
        _mm_store_pd((arr3)+i  , XMM2); \
        _mm_store_pd((arr3)+i+2, XMM3); \
    } \
    for ( ;i < (nn); i++) { \
        __m128d XMM0 = _mm_load_sd((arr1)+i  ); \
        __m128d XMM2 = _mm_load_sd((arr2)+i  ); \
        XMM0 = _mm_mul_sd(XMM0, XMM7); \
        XMM2 = _mm_add_sd(XMM2, XMM0); \
        _mm_store_sd((arr3)+i  , XMM2); \
    }\
}

#define vec3add(arr3, arr2, arr1, mul1, nn) \
{ \
    int i; \
    __m128d XMM7 = _mm_set1_pd(mul1); \
    for (i = 0;i < (nn);i += 4) { \
        __m128d XMM0 = _mm_load_pd((arr1)+i  ); \
        __m128d XMM1 = _mm_load_pd((arr1)+i+2); \
        __m128d XMM2 = _mm_load_pd((arr2)+i  ); \
        __m128d XMM3 = _mm_load_pd((arr2)+i+2); \
        XMM0 = _mm_mul_pd(XMM0, XMM7); \
        XMM1 = _mm_mul_pd(XMM1, XMM7); \
        XMM2 = _mm_add_pd(XMM2, XMM0); \
        XMM3 = _mm_add_pd(XMM3, XMM1); \
        _mm_store_pd((arr3)+i  , XMM2); \
        _mm_store_pd((arr3)+i+2, XMM3); \
    } \
}

#define vecdiff(z, x, y, n) \
{ \
    int i; \
    for (i = 0;i < (n);i += 8) { \
        __m128d XMM0 = _mm_load_pd((x)+i  ); \
        __m128d XMM1 = _mm_load_pd((x)+i+2); \
        __m128d XMM2 = _mm_load_pd((x)+i+4); \
        __m128d XMM3 = _mm_load_pd((x)+i+6); \
        __m128d XMM4 = _mm_load_pd((y)+i  ); \
        __m128d XMM5 = _mm_load_pd((y)+i+2); \
        __m128d XMM6 = _mm_load_pd((y)+i+4); \
        __m128d XMM7 = _mm_load_pd((y)+i+6); \
        XMM0 = _mm_sub_pd(XMM0, XMM4); \
        XMM1 = _mm_sub_pd(XMM1, XMM5); \
        XMM2 = _mm_sub_pd(XMM2, XMM6); \
        XMM3 = _mm_sub_pd(XMM3, XMM7); \
        _mm_store_pd((z)+i  , XMM0); \
        _mm_store_pd((z)+i+2, XMM1); \
        _mm_store_pd((z)+i+4, XMM2); \
        _mm_store_pd((z)+i+6, XMM3); \
    } \
}

#define vecscale_odd_unaligned(arr1, mul1, nn) \
{ \
    int i; \
    __m128d XMM7 = _mm_set1_pd(mul1); \
    for (i = 0;i < ((nn/4)*4);i += 4) { \
        __m128d XMM0 = _mm_loadu_pd((arr1)+i  ); \
        __m128d XMM1 = _mm_loadu_pd((arr1)+i+2); \
        XMM0 = _mm_mul_pd(XMM0, XMM7); \
        XMM1 = _mm_mul_pd(XMM1, XMM7); \
        _mm_storeu_pd((arr1)+i  , XMM0); \
        _mm_storeu_pd((arr1)+i+2, XMM1); \
    } \
    for ( ;i < (nn); i++) { \
        __m128d XMM0 = _mm_load_sd((arr1)+i  ); \
        XMM0 = _mm_mul_sd(XMM0, XMM7); \
        _mm_store_sd((arr1)+i  , XMM0); \
    }\
}

#define vecscale(y, c, n) \
{ \
    int i; \
    __m128d XMM7 = _mm_set1_pd(c); \
    for (i = 0;i < (n);i += 4) { \
        __m128d XMM0 = _mm_load_pd((y)+i  ); \
        __m128d XMM1 = _mm_load_pd((y)+i+2); \
        XMM0 = _mm_mul_pd(XMM0, XMM7); \
        XMM1 = _mm_mul_pd(XMM1, XMM7); \
        _mm_store_pd((y)+i  , XMM0); \
        _mm_store_pd((y)+i+2, XMM1); \
    } \
}


#define vec3mul_odd_unaligned(arr3, arr1, arr2, nn) \
{ \
    int i; \
    for (i = 0;i < ((nn/8)*8);i += 8) { \
        __m128d XMM0 = _mm_loadu_pd((arr1)+i  ); \
        __m128d XMM1 = _mm_loadu_pd((arr1)+i+2); \
        __m128d XMM2 = _mm_loadu_pd((arr1)+i+4); \
        __m128d XMM3 = _mm_loadu_pd((arr1)+i+6); \
        __m128d XMM4 = _mm_loadu_pd((arr2)+i  ); \
        __m128d XMM5 = _mm_loadu_pd((arr2)+i+2); \
        __m128d XMM6 = _mm_loadu_pd((arr2)+i+4); \
        __m128d XMM7 = _mm_loadu_pd((arr2)+i+6); \
        XMM4 = _mm_mul_pd(XMM4, XMM0); \
        XMM5 = _mm_mul_pd(XMM5, XMM1); \
        XMM6 = _mm_mul_pd(XMM6, XMM2); \
        XMM7 = _mm_mul_pd(XMM7, XMM3); \
        _mm_storeu_pd((arr3)+i  , XMM4); \
        _mm_storeu_pd((arr3)+i+2, XMM5); \
        _mm_storeu_pd((arr3)+i+4, XMM6); \
        _mm_storeu_pd((arr3)+i+6, XMM7); \
    } \
    for ( ;i < (nn); i++) { \
        __m128d XMM0 = _mm_load_sd((arr1)+i  ); \
        __m128d XMM4 = _mm_load_sd((arr2)+i  ); \
        XMM0 = _mm_mul_sd(XMM0, XMM4); \
        _mm_store_sd((arr3)+i  , XMM0); \
    }\
}

#define vecmul(y, x, n) \
{ \
    int i; \
    for (i = 0;i < (n);i += 8) { \
        __m128d XMM0 = _mm_load_pd((x)+i  ); \
        __m128d XMM1 = _mm_load_pd((x)+i+2); \
        __m128d XMM2 = _mm_load_pd((x)+i+4); \
        __m128d XMM3 = _mm_load_pd((x)+i+6); \
        __m128d XMM4 = _mm_load_pd((y)+i  ); \
        __m128d XMM5 = _mm_load_pd((y)+i+2); \
        __m128d XMM6 = _mm_load_pd((y)+i+4); \
        __m128d XMM7 = _mm_load_pd((y)+i+6); \
        XMM4 = _mm_mul_pd(XMM4, XMM0); \
        XMM5 = _mm_mul_pd(XMM5, XMM1); \
        XMM6 = _mm_mul_pd(XMM6, XMM2); \
        XMM7 = _mm_mul_pd(XMM7, XMM3); \
        _mm_store_pd((y)+i  , XMM4); \
        _mm_store_pd((y)+i+2, XMM5); \
        _mm_store_pd((y)+i+4, XMM6); \
        _mm_store_pd((y)+i+6, XMM7); \
    } \
}



#if     3 <= __SSE__ || defined(__SSE3__)
/*
    Horizontal add with haddps SSE3 instruction. The work register (rw)
    is unused.
 */
#define __horizontal_sum(r, rw) \
    r = _mm_hadd_ps(r, r); \
    r = _mm_hadd_ps(r, r);

#else
/*
    Horizontal add with SSE instruction. The work register (rw) is used.
 */
#define __horizontal_sum(r, rw) \
    rw = r; \
    r = _mm_shuffle_ps(r, rw, _MM_SHUFFLE(1, 0, 3, 2)); \
    r = _mm_add_ps(r, rw); \
    rw = r; \
    r = _mm_shuffle_ps(r, rw, _MM_SHUFFLE(2, 3, 0, 1)); \
    r = _mm_add_ps(r, rw);

#endif


#define vecdot_odd_unaligned(scal1, arr1, arr2, nn) \
{ \
    int i; \
    __m128d XMM0 = _mm_setzero_pd(); \
    __m128d XMM1 = _mm_setzero_pd(); \
    __m128d XMM2, XMM3, XMM4, XMM5; \
    for (i = 0;i < ((nn/4)*4);i += 4) { \
        XMM2 = _mm_loadu_pd((arr1)+i  ); \
        XMM3 = _mm_loadu_pd((arr1)+i+2); \
        XMM4 = _mm_loadu_pd((arr2)+i  ); \
        XMM5 = _mm_loadu_pd((arr2)+i+2); \
        XMM2 = _mm_mul_pd(XMM2, XMM4); \
        XMM3 = _mm_mul_pd(XMM3, XMM5); \
        XMM0 = _mm_add_pd(XMM0, XMM2); \
        XMM1 = _mm_add_pd(XMM1, XMM3); \
    } \
    for ( ;i < (nn); i++) { \
        XMM2 = _mm_load_sd((arr1)+i  ); \
        XMM4 = _mm_load_sd((arr2)+i  ); \
        XMM2 = _mm_mul_sd(XMM2, XMM4); \
        XMM0 = _mm_add_sd(XMM0, XMM2); \
    }\
    XMM0 = _mm_add_pd(XMM0, XMM1); \
    XMM1 = _mm_shuffle_pd(XMM0, XMM0, _MM_SHUFFLE2(1, 1)); \
    XMM0 = _mm_add_pd(XMM0, XMM1); \
    _mm_store_sd((scal1), XMM0); \
}

#define vecdot_odd(scal1, arr1, arr2, nn) \
{ \
    int i; \
    __m128d XMM0 = _mm_setzero_pd(); \
    __m128d XMM1 = _mm_setzero_pd(); \
    __m128d XMM2, XMM3, XMM4, XMM5; \
    for (i = 0;i < ((nn/4)*4);i += 4) { \
        XMM2 = _mm_load_pd((arr1)+i  ); \
        XMM3 = _mm_load_pd((arr1)+i+2); \
        XMM4 = _mm_load_pd((arr2)+i  ); \
        XMM5 = _mm_load_pd((arr2)+i+2); \
        XMM2 = _mm_mul_pd(XMM2, XMM4); \
        XMM3 = _mm_mul_pd(XMM3, XMM5); \
        XMM0 = _mm_add_pd(XMM0, XMM2); \
        XMM1 = _mm_add_pd(XMM1, XMM3); \
    } \
    for ( ;i < (nn); i++) { \
        XMM2 = _mm_load_sd((arr1)+i  ); \
        XMM4 = _mm_load_sd((arr2)+i  ); \
        XMM2 = _mm_mul_sd(XMM2, XMM4); \
        XMM0 = _mm_add_sd(XMM0, XMM2); \
    }\
    XMM0 = _mm_add_pd(XMM0, XMM1); \
    XMM1 = _mm_shuffle_pd(XMM0, XMM0, _MM_SHUFFLE2(1, 1)); \
    XMM0 = _mm_add_pd(XMM0, XMM1); \
    _mm_store_sd((scal1), XMM0); \
}

#define vecdot(scal1, arr1, arr2, nn) \
{ \
    int i; \
    __m128d XMM0 = _mm_setzero_pd(); \
    __m128d XMM1 = _mm_setzero_pd(); \
    __m128d XMM2, XMM3, XMM4, XMM5; \
    for (i = 0;i < (nn);i += 4) { \
        XMM2 = _mm_load_pd((arr1)+i  ); \
        XMM3 = _mm_load_pd((arr1)+i+2); \
        XMM4 = _mm_load_pd((arr2)+i  ); \
        XMM5 = _mm_load_pd((arr2)+i+2); \
        XMM2 = _mm_mul_pd(XMM2, XMM4); \
        XMM3 = _mm_mul_pd(XMM3, XMM5); \
        XMM0 = _mm_add_pd(XMM0, XMM2); \
        XMM1 = _mm_add_pd(XMM1, XMM3); \
    } \
    XMM0 = _mm_add_pd(XMM0, XMM1); \
    XMM1 = _mm_shuffle_pd(XMM0, XMM0, _MM_SHUFFLE2(1, 1)); \
    XMM0 = _mm_add_pd(XMM0, XMM1); \
    _mm_store_sd((scal1), XMM0); \
}

#define vec2norm(s, x, n) \
{ \
    int i; \
    __m128d XMM0 = _mm_setzero_pd(); \
    __m128d XMM1 = _mm_setzero_pd(); \
    __m128d XMM2, XMM3, XMM4, XMM5; \
    for (i = 0;i < (n);i += 4) { \
        XMM2 = _mm_load_pd((x)+i  ); \
        XMM3 = _mm_load_pd((x)+i+2); \
        XMM4 = XMM2; \
        XMM5 = XMM3; \
        XMM2 = _mm_mul_pd(XMM2, XMM4); \
        XMM3 = _mm_mul_pd(XMM3, XMM5); \
        XMM0 = _mm_add_pd(XMM0, XMM2); \
        XMM1 = _mm_add_pd(XMM1, XMM3); \
    } \
    XMM0 = _mm_add_pd(XMM0, XMM1); \
    XMM1 = _mm_shuffle_pd(XMM0, XMM0, _MM_SHUFFLE2(1, 1)); \
    XMM0 = _mm_add_pd(XMM0, XMM1); \
    XMM0 = _mm_sqrt_pd(XMM0); \
    _mm_store_sd((s), XMM0); \
}


#define vec2norminv(s, x, n) \
{ \
    int i; \
    __m128d XMM0 = _mm_setzero_pd(); \
    __m128d XMM1 = _mm_setzero_pd(); \
    __m128d XMM2, XMM3, XMM4, XMM5; \
    for (i = 0;i < (n);i += 4) { \
        XMM2 = _mm_load_pd((x)+i  ); \
        XMM3 = _mm_load_pd((x)+i+2); \
        XMM4 = XMM2; \
        XMM5 = XMM3; \
        XMM2 = _mm_mul_pd(XMM2, XMM4); \
        XMM3 = _mm_mul_pd(XMM3, XMM5); \
        XMM0 = _mm_add_pd(XMM0, XMM2); \
        XMM1 = _mm_add_pd(XMM1, XMM3); \
    } \
    XMM2 = _mm_set1_pd(1.0); \
    XMM0 = _mm_add_pd(XMM0, XMM1); \
    XMM1 = _mm_shuffle_pd(XMM0, XMM0, _MM_SHUFFLE2(1, 1)); \
    XMM0 = _mm_add_pd(XMM0, XMM1); \
    XMM0 = _mm_sqrt_pd(XMM0); \
    XMM2 = _mm_div_pd(XMM2, XMM0); \
    _mm_store_sd((s), XMM2); \
}
