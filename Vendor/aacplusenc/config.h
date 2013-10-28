#ifndef _CONFIG_H
#define _CONFIG_H

#ifdef __LITTLE_ENDIAN__
#define _EL_ARCH
#elif defined(__BIG_ENDIAN__)
#define _BE_ARCH
#endif

#undef _FFTW3

#endif
