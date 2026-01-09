 #pragma once
#include "MASTER.h"
#include "GLOBAL.h"
#include "CodeContract.h"
inline double clampToDataTypeRange(double ___4299, FieldDataType_e ___1361) { switch (___1361) { case FieldDataType_Float: return ___648(___4299); case FieldDataType_Double: return ___487(___4299); case FieldDataType_Int32: return ___650(___4299); case FieldDataType_Int16: return ___649(___4299); case FieldDataType_Byte: return CONVERT_DOUBLE_TO_UINT8(___4299); case ___1363: return (___4299 < 1.0 ? 0.0 : 1.0); default: ___476(___1303); return ___2178; } }
