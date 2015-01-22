/*
  narray.h
  NArray with big memory support
    (C) Copyright 1999-2011 by Masahiro TANAKA
    (C) Copyright 2013-2015 by Seiya NISHIZAWA

  This program is free software.
  You can distribute/modify this program
  under the same terms as Ruby itself.
  NO WARRANTY.
*/
#ifndef NARRAY_H
#define NARRAY_H

#include <math.h>

#include "narray_config.h"

#ifdef HAVE_STDINT_H
# include <stdint.h>
#endif

#ifdef HAVE_SYS_TYPES_H
# include <sys/types.h>
#endif

#define NARRAY_VERSION "0.6.0.8"
#define NARRAY_VERSION_CODE 608

#define NARRAYBIGMEM_VERSION "0.0.0"
#define NARRAYBIGMEM_VERSION_CODE 000

/* big memory support */
#define NARRAY_BIGMEM 1

/*
  Data types used in NArray :
  Please modify these types if your system has any different type.
*/


/* NA_BYTE : unsigned 8-bit integer */
#ifndef HAVE_U_INT8_T
# ifdef HAVE_UINT8_T
typedef uint8_t			u_int8_t;
# else
typedef unsigned char		u_int8_t;
# endif
#endif

#ifndef HAVE_INT16_T
# if SIZEOF_SHORT == 2
typedef short                  int16_t;  /* NA_SINT */
# else
---->> Please define int16_t manually because sizeof(short) != 2. <<----
# endif
#endif /* HAVE_INT16_T */

#ifndef HAVE_INT32_T
# if SIZEOF_LONG == 4
typedef long                   int32_t;  /* NA_LINT */
# else
#  if SIZEOF_INT == 4
typedef int                    int32_t;  /* NA_LINT */
#  else
---->> Please define int32_t manually because sizeof(long) != 4. <<----
#  endif
# endif
#endif /* HAVE_INT32_T */

#ifndef HAVE_INT64_T
# if SIZEOF_LONG_LONG == 8
typedef long long                   int64_t;  /* NA_LLINT */
# else
---->> Please define int64_t manually because sizeof(long long) != 8. <<----
# endif
#endif /* HAVE_INT64_T */

/* unsigned 64-bit integer */
#ifndef HAVE_U_INT64_T
# ifdef HAVE_UINT64_T
typedef uint64_t			u_int64_t;
# else
#  if SIZEOF_LONG_LONG == 8
typedef unsigned long long              u_int64_t;
#  else
---->> Please define u_int64_t manually because sizeof(long long) != 8. <<----
#  endif
# endif
#endif /* HAVE_U_INT64_T */

/* shape type */
#if SIZEOF_VOIDP == 4
typedef int32_t na_shape_t;
#elif SIZEOF_VOIDP == 8
typedef int64_t na_shape_t;
#else
  ---->> Please define na_shape_t manually because sizeof(*void) != 4, 8. <<----
#endif
#if SIZEOF_INT == SIZEOF_VOIDP
#define NUM2SHAPE(v) NUM2INT(v)
#define SHAPE2NUM(v) INT2NUM(v)
#elif SIZEOF_LONG == SIZEOF_VOIDP
#define NUM2SHAPE(v) NUM2LONG(v)
#define SHAPE2NUM(v) LONG2NUM(v)
#elif SIZEOF_LONG_LONG == SIZEOF_VOIDP
#define NUM2SHAPE(v) NUM2LL(v)
#define SHAPE2NUM(v) LL2NUM(v)
#else
  ---->> Please define NUM2SHAPE and SHAPE2NUM manually because sizeof(int,long,long long) != sizeof(*void). <<----
#endif


typedef struct { float r,i; }  scomplex;
typedef struct { double r,i; } dcomplex;

enum NArray_Types {
  NA_NONE,
  NA_BYTE,	/* 1 */
  NA_SINT,	/* 2 */
  NA_LINT,	/* 3 */
  NA_LLINT,	/* 4 */
  NA_SFLOAT,	/* 5 */
  NA_DFLOAT,	/* 6 */
  NA_SCOMPLEX,	/* 7 */
  NA_DCOMPLEX,	/* 8 */
  NA_ROBJ,	/* 9 */
  NA_NTYPES	/* 10 */
};

#if SIZEOF_VOIDP == 4
#define NA_SIZE NA_LINT
#elif SIZEOF_VOIDP == 8
#define NA_SIZE NA_LLINT
#else
---->> Please define NA_SIZE manually because sizeof(*void) != 4 or 8. <<----
#endif

/* struct for Numerical Array */
struct NARRAY {
  int    rank;	  /* # of dimension */
  na_shape_t total;  /* # of total element */
  int    type;	  /* data type */
  na_shape_t *shape;
  char  *ptr;	  /* pointer to data */
  VALUE  ref;	  /* NArray object wrapping this structure */
};

#ifndef NARRAY_C
extern VALUE cNArray;

extern const int na_sizeof[NA_NTYPES+1];
#endif

#define NA_MAX_RANK 15

#define GetNArray(obj,var)  Data_Get_Struct(obj, struct NARRAY, var)
#define IsNArray(obj) (rb_obj_is_kind_of(obj,cNArray)==Qtrue)

#define NA_PTR(a,p)    ((a)->ptr+(p)*na_sizeof[(a)->type])
#define NA_STRUCT(val) ((struct NARRAY*)DATA_PTR(val))
#define NA_PTR_TYPE(val,type) (type)(((struct NARRAY*)DATA_PTR(val))->ptr)
#define NA_RANK(val)   (((struct NARRAY*)DATA_PTR(val))->rank)
#define NA_TYPE(val)   (((struct NARRAY*)DATA_PTR(val))->type)
#define NA_TOTAL(val)  (((struct NARRAY*)DATA_PTR(val))->total)
#define NA_SHAPE0(val) (((struct NARRAY*)DATA_PTR(val))->shape[0])
#define NA_SHAPE1(val) (((struct NARRAY*)DATA_PTR(val))->shape[1])

#define NA_IsNArray(obj) \
  (rb_obj_is_kind_of(obj,cNArray)==Qtrue)
#define NA_IsArray(obj) \
  (TYPE(obj)==T_ARRAY || rb_obj_is_kind_of(obj,cNArray)==Qtrue)
#define NA_IsROBJ(d) ((d)->type==NA_ROBJ)
#define NA_IsINTEGER(a) \
  ((a)->type==NA_BYTE || (a)->type==NA_SINT || (a)->type==NA_LINT )
#define NA_IsCOMPLEX(a) \
  ((a)->type==NA_SCOMPLEX || (a)->type==NA_DCOMPLEX)
#define NA_MAX(a,b) (((a)>(b))?(a):(b))
#define NA_MAX3(a,b,c) NA_MAX( (NA_MAX((a),(b))), (c) )


#define NA_SWAP(a,b,tmp) {(tmp)=(a);(a)=(b);(b)=(tmp);}

#define na_class_dim(klass) NUM2INT(rb_const_get(klass, na_id_class_dim))

#define NUM2REAL(v)  NUM2DBL( rb_funcall((v),na_id_real,0) )
#define NUM2IMAG(v)  NUM2DBL( rb_funcall((v),na_id_imag,0) )

#define NA_ALLOC_SLICE(slc,nc,shp,np) \
{ slc = (struct slice*)xmalloc( sizeof(struct slice)*(nc) + \
				sizeof(na_shape_t)*(np) );	    \
  shp = (na_shape_t*)&( (slc)[nc] ); }


/* Function Prototypes */

/* narray.c */
VALUE na_make_object(int type, int rank, na_shape_t *shape, VALUE klass);
VALUE na_make_scalar(VALUE obj, int type);
VALUE na_make_empty(int type, VALUE klass);
int   na_get_typecode(VALUE v);
void  na_clear_data(struct NARRAY *ary);
VALUE na_clone(VALUE self);
VALUE na_fill(VALUE self, volatile VALUE obj);
void  na_copy_nary(struct NARRAY *dst, struct NARRAY *src);

/* na_array.c */
VALUE na_to_array(VALUE obj);
VALUE na_make_inspect(VALUE self);
VALUE na_ary_to_nary(VALUE ary, VALUE klass);
int   na_object_type(VALUE v);

VALUE na_cast_object(VALUE obj, int type);
VALUE na_cast_unless_narray(VALUE obj, int type);
VALUE na_cast_unless_array(VALUE obj, int type);
VALUE na_upcast_object(VALUE obj, int type);
VALUE na_dup_w_type(VALUE obj, int type);
VALUE na_change_type(VALUE obj, int type);
VALUE na_upcast_type(VALUE obj, int type);
VALUE na_to_narray(VALUE obj);

/* na_index.c */
VALUE na_aset(int argc, VALUE *argv, VALUE self);
VALUE na_aref(int argc, VALUE *argv, VALUE self);
VALUE na_slice(int argc, VALUE *argv, VALUE self);
VALUE na_count_true(VALUE self);
VALUE na_count_false(VALUE self);
VALUE na_aref_mask(VALUE self, VALUE mask);
void  na_aset_mask(VALUE self, VALUE mask, VALUE v);

#endif /* ifndef NARRAY_H */
