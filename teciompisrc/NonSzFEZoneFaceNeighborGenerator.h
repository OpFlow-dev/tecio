 #pragma once
#include "FaceNeighborGeneratorAbstract.h"
namespace tecplot { namespace ___3934 { class NonSzFEZoneFaceNeighborGenerator : public FaceNeighborGeneratorAbstract { public: explicit NonSzFEZoneFaceNeighborGenerator(class ___37& ___36); virtual ___372 gatherUserFaceNeighbors(std::vector<int32_t>& userFaceNeighbors, ___4636 zone) const; }; }}
