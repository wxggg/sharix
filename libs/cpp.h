#pragma once

#define this m(self)
#define m(pInst) ((pInst)->_method_(pInst))

#define Define_Method(T) T * T##$Method(T *ps){_obj_arg_ = ps;return ps;}
#define Define_Member(T) struct T * (* _method_)(struct T * ps);
#define Declare_Method(T) T * T##$Method(T * ps);
#define Register_Method(pInst,T) pInst->_method_ = T##$Method;
#define MethodOf(T) T * self = (T *)_obj_arg_;

extern void *_obj_arg_;
