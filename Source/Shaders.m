#include "Shader.h"

Control *cPtr = NULL;

void setControlPointer(Control *ptr) { cPtr = ptr; }

void setPColor(int index, int value) { cPtr->pColor[index % MAX_ITERATIONS] = (unsigned char)(value & 255); }
int  getPColor(int index) { return (int)(cPtr->pColor[index % MAX_ITERATIONS]); }

void pColorClear(void) { for(int i=0;i<MAX_ITERATIONS;++i) cPtr->pColor[i] = 0; }

// moving color lookup tables from Swift to 'C' greatly speeds up compile time

static const vector_float3 colorMap1[] = {
    { 0,0,0}, { 0.000,0.000,0.531 }, { 0.000,0.000,0.547 }, { 0.000,0.000,0.563},
    { 0.000,0.000,0.578 }, { 0.000,0.000,0.594 }, { 0.000,0.000,0.609 }, { 0.000,0.000,0.625},
    { 0.000,0.000,0.641 }, { 0.000,0.000,0.656 }, { 0.000,0.000,0.672 }, { 0.000,0.000,0.688},
    { 0.000,0.000,0.703 }, { 0.000,0.000,0.719 }, { 0.000,0.000,0.734 }, { 0.000,0.000,0.750},
    { 0.000,0.000,0.766 }, { 0.000,0.000,0.781 }, { 0.000,0.000,0.797 }, { 0.000,0.000,0.813},
    { 0.000,0.000,0.828 }, { 0.000,0.000,0.844 }, { 0.000,0.000,0.859 }, { 0.000,0.000,0.875},
    { 0.000,0.000,0.891 }, { 0.000,0.000,0.906 }, { 0.000,0.000,0.922 }, { 0.000,0.000,0.938},
    { 0.000,0.000,0.953 }, { 0.000,0.000,0.969 }, { 0.000,0.000,0.984 }, { 0.000,0.000,1.000},
    { 0.000,0.016,1.000 }, { 0.000,0.031,1.000 }, { 0.000,0.047,1.000 }, { 0.000,0.063,1.000},
    { 0.000,0.078,1.000 }, { 0.000,0.094,1.000 }, { 0.000,0.109,1.000 }, { 0.000,0.125,1.000},
    { 0.000,0.141,1.000 }, { 0.000,0.156,1.000 }, { 0.000,0.172,1.000 }, { 0.000,0.188,1.000},
    { 0.000,0.203,1.000 }, { 0.000,0.219,1.000 }, { 0.000,0.234,1.000 }, { 0.000,0.250,1.000},
    { 0.000,0.266,1.000 }, { 0.000,0.281,1.000 }, { 0.000,0.297,1.000 }, { 0.000,0.313,1.000},
    { 0.000,0.328,1.000 }, { 0.000,0.344,1.000 }, { 0.000,0.359,1.000 }, { 0.000,0.375,1.000},
    { 0.000,0.391,1.000 }, { 0.000,0.406,1.000 }, { 0.000,0.422,1.000 }, { 0.000,0.438,1.000},
    { 0.000,0.453,1.000 }, { 0.000,0.469,1.000 }, { 0.000,0.484,1.000 }, { 0.000,0.500,1.000},
    { 0.000,0.516,1.000 }, { 0.000,0.531,1.000 }, { 0.000,0.547,1.000 }, { 0.000,0.563,1.000},
    { 0.000,0.578,1.000 }, { 0.000,0.594,1.000 }, { 0.000,0.609,1.000 }, { 0.000,0.625,1.000},
    { 0.000,0.641,1.000 }, { 0.000,0.656,1.000 }, { 0.000,0.672,1.000 }, { 0.000,0.688,1.000},
    { 0.000,0.703,1.000 }, { 0.000,0.719,1.000 }, { 0.000,0.734,1.000 }, { 0.000,0.750,1.000},
    { 0.000,0.766,1.000 }, { 0.000,0.781,1.000 }, { 0.000,0.797,1.000 }, { 0.000,0.813,1.000},
    { 0.000,0.828,1.000 }, { 0.000,0.844,1.000 }, { 0.000,0.859,1.000 }, { 0.000,0.875,1.000},
    { 0.000,0.891,1.000 }, { 0.000,0.906,1.000 }, { 0.000,0.922,1.000 }, { 0.000,0.938,1.000},
    { 0.000,0.953,1.000 }, { 0.000,0.969,1.000 }, { 0.000,0.984,1.000 }, { 0.000,1.000,1.000},
    { 0.016,1.000,0.984 }, { 0.031,1.000,0.969 }, { 0.047,1.000,0.953 }, { 0.063,1.000,0.938},
    { 0.078,1.000,0.922 }, { 0.094,1.000,0.906 }, { 0.109,1.000,0.891 }, { 0.125,1.000,0.875},
    { 0.141,1.000,0.859 }, { 0.156,1.000,0.844 }, { 0.172,1.000,0.828 }, { 0.188,1.000,0.813},
    { 0.203,1.000,0.797 }, { 0.219,1.000,0.781 }, { 0.234,1.000,0.766 }, { 0.250,1.000,0.750},
    { 0.266,1.000,0.734 }, { 0.281,1.000,0.719 }, { 0.297,1.000,0.703 }, { 0.313,1.000,0.688},
    { 0.328,1.000,0.672 }, { 0.344,1.000,0.656 }, { 0.359,1.000,0.641 }, { 0.375,1.000,0.625},
    { 0.391,1.000,0.609 }, { 0.406,1.000,0.594 }, { 0.422,1.000,0.578 }, { 0.438,1.000,0.563},
    { 0.453,1.000,0.547 }, { 0.469,1.000,0.531 }, { 0.484,1.000,0.516 }, { 0.500,1.000,0.500},
    { 0.516,1.000,0.484 }, { 0.531,1.000,0.469 }, { 0.547,1.000,0.453 }, { 0.563,1.000,0.438},
    { 0.578,1.000,0.422 }, { 0.594,1.000,0.406 }, { 0.609,1.000,0.391 }, { 0.625,1.000,0.375},
    { 0.641,1.000,0.359 }, { 0.656,1.000,0.344 }, { 0.672,1.000,0.328 }, { 0.688,1.000,0.313},
    { 0.703,1.000,0.297 }, { 0.719,1.000,0.281 }, { 0.734,1.000,0.266 }, { 0.750,1.000,0.250},
    { 0.766,1.000,0.234 }, { 0.781,1.000,0.219 }, { 0.797,1.000,0.203 }, { 0.813,1.000,0.188},
    { 0.828,1.000,0.172 }, { 0.844,1.000,0.156 }, { 0.859,1.000,0.141 }, { 0.875,1.000,0.125},
    { 0.891,1.000,0.109 }, { 0.906,1.000,0.094 }, { 0.922,1.000,0.078 }, { 0.938,1.000,0.063},
    { 0.953,1.000,0.047 }, { 0.969,1.000,0.031 }, { 0.984,1.000,0.016 }, { 1.000,1.000,0.000},
    { 1.000,0.984,0.000 }, { 1.000,0.969,0.000 }, { 1.000,0.953,0.000 }, { 1.000,0.938,0.000},
    { 1.000,0.922,0.000 }, { 1.000,0.906,0.000 }, { 1.000,0.891,0.000 }, { 1.000,0.875,0.000},
    { 1.000,0.859,0.000 }, { 1.000,0.844,0.000 }, { 1.000,0.828,0.000 }, { 1.000,0.813,0.000},
    { 1.000,0.797,0.000 }, { 1.000,0.781,0.000 }, { 1.000,0.766,0.000 }, { 1.000,0.750,0.000},
    { 1.000,0.734,0.000 }, { 1.000,0.719,0.000 }, { 1.000,0.703,0.000 }, { 1.000,0.688,0.000},
    { 1.000,0.672,0.000 }, { 1.000,0.656,0.000 }, { 1.000,0.641,0.000 }, { 1.000,0.625,0.000},
    { 1.000,0.609,0.000 }, { 1.000,0.594,0.000 }, { 1.000,0.578,0.000 }, { 1.000,0.563,0.000},
    { 1.000,0.547,0.000 }, { 1.000,0.531,0.000 }, { 1.000,0.516,0.000 }, { 1.000,0.500,0.000},
    { 1.000,0.484,0.000 }, { 1.000,0.469,0.000 }, { 1.000,0.453,0.000 }, { 1.000,0.438,0.000},
    { 1.000,0.422,0.000 }, { 1.000,0.406,0.000 }, { 1.000,0.391,0.000 }, { 1.000,0.375,0.000},
    { 1.000,0.359,0.000 }, { 1.000,0.344,0.000 }, { 1.000,0.328,0.000 }, { 1.000,0.313,0.000},
    { 1.000,0.297,0.000 }, { 1.000,0.281,0.000 }, { 1.000,0.266,0.000 }, { 1.000,0.250,0.000},
    { 1.000,0.234,0.000 }, { 1.000,0.219,0.000 }, { 1.000,0.203,0.000 }, { 1.000,0.188,0.000},
    { 1.000,0.172,0.000 }, { 1.000,0.156,0.000 }, { 1.000,0.141,0.000 }, { 1.000,0.125,0.000},
    { 1.000,0.109,0.000 }, { 1.000,0.094,0.000 }, { 1.000,0.078,0.000 }, { 1.000,0.063,0.000},
    { 1.000,0.047,0.000 }, { 1.000,0.031,0.000 }, { 1.000,0.016,0.000 }, { 1.000,0.000,0.000},
    { 0.984,0.000,0.000 }, { 0.969,0.000,0.000 }, { 0.953,0.000,0.000 }, { 0.938,0.000,0.000},
    { 0.922,0.000,0.000 }, { 0.906,0.000,0.000 }, { 0.891,0.000,0.000 }, { 0.875,0.000,0.000},
    { 0.859,0.000,0.000 }, { 0.844,0.000,0.000 }, { 0.828,0.000,0.000 }, { 0.813,0.000,0.000},
    { 0.797,0.000,0.000 }, { 0.781,0.000,0.000 }, { 0.766,0.000,0.000 }, { 0.750,0.000,0.000},
    { 0.734,0.000,0.000 }, { 0.719,0.000,0.000 }, { 0.703,0.000,0.000 }, { 0.688,0.000,0.000},
    { 0.672,0.000,0.000 }, { 0.656,0.000,0.000 }, { 0.641,0.000,0.000 }, { 0.625,0.000,0.000},
    { 0.609,0.000,0.000 }, { 0.594,0.000,0.000 }, { 0.578,0.000,0.000 }, { 0.563,0.000,0.000},
    { 0.547,0.000,0.000 }, { 0.531,0.000,0.000 }, { 0.516,0.000,0.000 }, { 0.500,0.000,0.000 }};

static const vector_float3 colorMap2[] = {
    { 0,0,0 }, { 0.504821, 0.785329, 0.507190 }, { 0.511603, 0.782422, 0.516340 }, { 0.518385, 0.779516, 0.525490},
    { 0.525167, 0.776609, 0.534641 }, { 0.531949, 0.773702, 0.543791 }, { 0.538731, 0.770796, 0.552941 }, { 0.545513, 0.767889, 0.562092},
    { 0.552295, 0.764983, 0.571242 }, { 0.559077, 0.762076, 0.580392 }, { 0.565859, 0.759170, 0.589542 }, { 0.572641, 0.756263, 0.598693},
    { 0.579423, 0.753356, 0.607843 }, { 0.586205, 0.750450, 0.616993 }, { 0.592987, 0.747543, 0.626144 }, { 0.599769, 0.744637, 0.635294},
    { 0.606551, 0.741730, 0.644444 }, { 0.613333, 0.738824, 0.653595 }, { 0.620115, 0.735917, 0.662745 }, { 0.626897, 0.733010, 0.671895},
    { 0.633679, 0.730104, 0.681046 }, { 0.640461, 0.727197, 0.690196 }, { 0.647243, 0.724291, 0.699346 }, { 0.654025, 0.721384, 0.708497},
    { 0.660807, 0.718478, 0.717647 }, { 0.667589, 0.715571, 0.726797 }, { 0.674371, 0.712664, 0.735948 }, { 0.681153, 0.709758, 0.745098},
    { 0.687935, 0.706851, 0.754248 }, { 0.694717, 0.703945, 0.763399 }, { 0.701499, 0.701038, 0.772549 }, { 0.708281, 0.698132, 0.781699},
    { 0.715063, 0.695225, 0.790850 }, { 0.721845, 0.692318, 0.800000 }, { 0.728627, 0.689412, 0.809150 }, { 0.735409, 0.686505, 0.818301},
    { 0.742191, 0.683599, 0.827451 }, { 0.748973, 0.683460, 0.826574 }, { 0.755755, 0.685398, 0.818178 }, { 0.762537, 0.687336, 0.809781},
    { 0.769320, 0.689273, 0.801384 }, { 0.776102, 0.691211, 0.792987 }, { 0.782884, 0.693149, 0.784591 }, { 0.789666, 0.695087, 0.776194},
    { 0.796448, 0.697024, 0.767797 }, { 0.803230, 0.698962, 0.759400 }, { 0.810012, 0.700900, 0.751003 }, { 0.816794, 0.702837, 0.742607},
    { 0.823576, 0.704775, 0.734210 }, { 0.830358, 0.706713, 0.725813 }, { 0.837140, 0.708651, 0.717416 }, { 0.843922, 0.710588, 0.709020},
    { 0.850704, 0.712526, 0.700623 }, { 0.857486, 0.714464, 0.692226 }, { 0.864268, 0.716401, 0.683829 }, { 0.871050, 0.718339, 0.675433},
    { 0.877832, 0.720277, 0.667036 }, { 0.884614, 0.722215, 0.658639 }, { 0.891396, 0.724152, 0.650242 }, { 0.898178, 0.726090, 0.641845},
    { 0.904960, 0.728028, 0.633449 }, { 0.911742, 0.729965, 0.625052 }, { 0.918524, 0.731903, 0.616655 }, { 0.925306, 0.733841, 0.608258},
    { 0.932088, 0.735779, 0.599862 }, { 0.938870, 0.737716, 0.591465 }, { 0.945652, 0.739654, 0.583068 }, { 0.952434, 0.741592, 0.574671},
    { 0.959216, 0.743529, 0.566275 }, { 0.965998, 0.745467, 0.557878 }, { 0.972780, 0.747405, 0.549481 }, { 0.979562, 0.749343, 0.541084},
    { 0.986344, 0.751280, 0.532687 }, { 0.992188, 0.753910, 0.525782 }, { 0.992403, 0.760692, 0.527828 }, { 0.992618, 0.767474, 0.529873},
    { 0.992834, 0.774256, 0.531919 }, { 0.993049, 0.781038, 0.533964 }, { 0.993264, 0.787820, 0.536009 }, { 0.993479, 0.794602, 0.538055},
    { 0.993695, 0.801384, 0.540100 }, { 0.993910, 0.808166, 0.542145 }, { 0.994125, 0.814948, 0.544191 }, { 0.994341, 0.821730, 0.546236},
    { 0.994556, 0.828512, 0.548281 }, { 0.994771, 0.835294, 0.550327 }, { 0.994987, 0.842076, 0.552372 }, { 0.995202, 0.848858, 0.554418},
    { 0.995417, 0.855640, 0.556463 }, { 0.995632, 0.862422, 0.558508 }, { 0.995848, 0.869204, 0.560554 }, { 0.996063, 0.875986, 0.562599},
    { 0.996278, 0.882768, 0.564644 }, { 0.996494, 0.889550, 0.566690 }, { 0.996709, 0.896332, 0.568735 }, { 0.996924, 0.903114, 0.570780},
    { 0.997140, 0.909896, 0.572826 }, { 0.997355, 0.916678, 0.574871 }, { 0.997570, 0.923460, 0.576917 }, { 0.997785, 0.930242, 0.578962},
    { 0.998001, 0.937024, 0.581007 }, { 0.998216, 0.943806, 0.583053 }, { 0.998431, 0.950588, 0.585098 }, { 0.998647, 0.957370, 0.587143},
    { 0.998862, 0.964152, 0.589189 }, { 0.999077, 0.970934, 0.591234 }, { 0.999293, 0.977716, 0.593280 }, { 0.999508, 0.984498, 0.595325},
    { 0.999723, 0.991280, 0.597370 }, { 0.999938, 0.998062, 0.599416 }, { 0.984698, 0.988697, 0.601769 }, { 0.963276, 0.972872, 0.604245},
    { 0.941853, 0.957047, 0.606721 }, { 0.920431, 0.941223, 0.609196 }, { 0.899008, 0.925398, 0.611672 }, { 0.877586, 0.909573, 0.614148},
    { 0.856163, 0.893749, 0.616624 }, { 0.834740, 0.877924, 0.619100 }, { 0.813318, 0.862099, 0.621576 }, { 0.791895, 0.846275, 0.624052},
    { 0.770473, 0.830450, 0.626528 }, { 0.749050, 0.814625, 0.629004 }, { 0.727628, 0.798800, 0.631480 }, { 0.706205, 0.782976, 0.633956},
    { 0.684783, 0.767151, 0.636432 }, { 0.663360, 0.751326, 0.638908 }, { 0.641938, 0.735502, 0.641384 }, { 0.620515, 0.719677, 0.643860},
    { 0.599093, 0.703852, 0.646336 }, { 0.577670, 0.688028, 0.648812 }, { 0.556248, 0.672203, 0.651288 }, { 0.534825, 0.656378, 0.653764},
    { 0.513403, 0.640554, 0.656240 }, { 0.491980, 0.624729, 0.658716 }, { 0.470557, 0.608904, 0.661192 }, { 0.449135, 0.593080, 0.663668},
    { 0.427712, 0.577255, 0.666144 }, { 0.406290, 0.561430, 0.668620 }, { 0.384867, 0.545606, 0.671096 }, { 0.363445, 0.529781, 0.673572},
    { 0.342022, 0.513956, 0.676048 }, { 0.320600, 0.498131, 0.678524 }, { 0.299177, 0.482307, 0.681000 }, { 0.277755, 0.466482, 0.683476},
    { 0.256332, 0.450657, 0.685952 }, { 0.234910, 0.434833, 0.688428 }, { 0.225267, 0.420269, 0.688689 }, { 0.245075, 0.408858, 0.683414},
    { 0.264883, 0.397447, 0.678139 }, { 0.284691, 0.386036, 0.672864 }, { 0.304498, 0.374625, 0.667589 }, { 0.324306, 0.363214, 0.662315},
    { 0.344114, 0.351803, 0.657040 }, { 0.363922, 0.340392, 0.651765 }, { 0.383729, 0.328981, 0.646490 }, { 0.403537, 0.317570, 0.641215},
    { 0.423345, 0.306159, 0.635940 }, { 0.443153, 0.294748, 0.630665 }, { 0.462960, 0.283337, 0.625390 }, { 0.482768, 0.271926, 0.620115},
    { 0.502576, 0.260515, 0.614840 }, { 0.522384, 0.249104, 0.609566 }, { 0.542191, 0.237693, 0.604291 }, { 0.561999, 0.226282, 0.599016},
    { 0.581807, 0.214871, 0.593741 }, { 0.601615, 0.203460, 0.588466 }, { 0.621423, 0.192049, 0.583191 }, { 0.641230, 0.180638, 0.577916},
    { 0.661038, 0.169227, 0.572641 }, { 0.680846, 0.157816, 0.567366 }, { 0.700654, 0.146405, 0.562092 }, { 0.720461, 0.134994, 0.556817},
    { 0.740269, 0.123583, 0.551542 }, { 0.760077, 0.112172, 0.546267 }, { 0.779885, 0.100761, 0.540992 }, { 0.799692, 0.089350, 0.535717},
    { 0.819500, 0.077939, 0.530442 }, { 0.839308, 0.066528, 0.525167 }, { 0.859116, 0.055117, 0.519892 }, { 0.878923, 0.043706, 0.514617},
    { 0.898731, 0.032295, 0.509343 }, { 0.918539, 0.020884, 0.504068 }, { 0.938347, 0.009473, 0.498793 }, { 0.936655, 0.016055, 0.488443},
    { 0.931380, 0.025636, 0.477247 }, { 0.926105, 0.035217, 0.466052 }, { 0.920830, 0.044798, 0.454856 }, { 0.915556, 0.054379, 0.443660},
    { 0.910281, 0.063960, 0.432464 }, { 0.905006, 0.073541, 0.421269 }, { 0.899731, 0.083122, 0.410073 }, { 0.894456, 0.092703, 0.398877},
    { 0.889181, 0.102284, 0.387682 }, { 0.883906, 0.111865, 0.376486 }, { 0.878631, 0.121446, 0.365290 }, { 0.873356, 0.131027, 0.354095},
    { 0.868082, 0.140607, 0.342899 }, { 0.862807, 0.150188, 0.331703 }, { 0.857532, 0.159769, 0.320507 }, { 0.852257, 0.169350, 0.309312},
    { 0.846982, 0.178931, 0.298116 }, { 0.841707, 0.188512, 0.286920 }, { 0.836432, 0.198093, 0.275725 }, { 0.831157, 0.207674, 0.264529},
    { 0.825882, 0.217255, 0.253333 }, { 0.820607, 0.226836, 0.242138 }, { 0.815333, 0.236417, 0.230942 }, { 0.810058, 0.245998, 0.219746},
    { 0.804783, 0.255579, 0.208551 }, { 0.799508, 0.265160, 0.197355 }, { 0.794233, 0.274740, 0.186159 }, { 0.788958, 0.284321, 0.174963},
    { 0.783683, 0.293902, 0.163768 }, { 0.778408, 0.303483, 0.152572 }, { 0.773133, 0.313064, 0.141376 }, { 0.767859, 0.322645, 0.130181},
    { 0.762584, 0.332226, 0.118985 }, { 0.757309, 0.341807, 0.107789 }, { 0.752034, 0.351388, 0.096594 }, { 0.744914, 0.357370, 0.093841},
    { 0.735333, 0.358554, 0.102345 }, { 0.725752, 0.359739, 0.110850 }, { 0.716171, 0.360923, 0.119354 }, { 0.706590, 0.362107, 0.127859},
    { 0.697009, 0.363291, 0.136363 }, { 0.687428, 0.364475, 0.144867 }, { 0.677847, 0.365659, 0.153372 }, { 0.668266, 0.366844, 0.161876},
    { 0.658685, 0.368028, 0.170381 }, { 0.649104, 0.369212, 0.178885 }, { 0.639523, 0.370396, 0.187389 }, { 0.629942, 0.371580, 0.195894},
    { 0.620361, 0.372764, 0.204398 }, { 0.610780, 0.373948, 0.212903 }, { 0.601200, 0.375133, 0.221407 }, { 0.591619, 0.376317, 0.229912},
    { 0.582038, 0.377501, 0.238416 }, { 0.572457, 0.378685, 0.246920 }, { 0.562876, 0.379869, 0.255425 }, { 0.553295, 0.381053, 0.263929},
    { 0.543714, 0.382238, 0.272434 }, { 0.534133, 0.383422, 0.280938 }, { 0.524552, 0.384606, 0.289443 }, { 0.514971, 0.385790, 0.297947},
    { 0.505390, 0.386974, 0.306451 }, { 0.495809, 0.388158, 0.314956 }, { 0.486228, 0.389343, 0.323460 }, { 0.476647, 0.390527, 0.331965},
    { 0.467067, 0.391711, 0.340469 }, { 0.457486, 0.392895, 0.348973 }, { 0.447905, 0.394079, 0.357478 }, { 0.438324, 0.395263, 0.365982},
    { 0.428743, 0.396448, 0.374487 }, { 0.419162, 0.397632, 0.382991 }, { 0.409581, 0.398816, 0.391496 }, { 0.400000, 0.400000, 0.400000 }};

static const vector_float3 colorMap3[] = {
    { 0,0,0 }, { 0.051895, 0.000000, 0.000000 }, { 0.062190, 0.000000, 0.000000 }, { 0.072485, 0.000000, 0.000000},
    { 0.082779, 0.000000, 0.000000 }, { 0.093074, 0.000000, 0.000000 }, { 0.103369, 0.000000, 0.000000 }, { 0.113664, 0.000000, 0.000000},
    { 0.123959, 0.000000, 0.000000 }, { 0.134254, 0.000000, 0.000000 }, { 0.144548, 0.000000, 0.000000 }, { 0.154843, 0.000000, 0.000000},
    { 0.165138, 0.000000, 0.000000 }, { 0.175433, 0.000000, 0.000000 }, { 0.185728, 0.000000, 0.000000 }, { 0.196023, 0.000000, 0.000000},
    { 0.206318, 0.000000, 0.000000 }, { 0.216612, 0.000000, 0.000000 }, { 0.226907, 0.000000, 0.000000 }, { 0.237202, 0.000000, 0.000000},
    { 0.247497, 0.000000, 0.000000 }, { 0.257792, 0.000000, 0.000000 }, { 0.268087, 0.000000, 0.000000 }, { 0.278381, 0.000000, 0.000000},
    { 0.288676, 0.000000, 0.000000 }, { 0.298971, 0.000000, 0.000000 }, { 0.309266, 0.000000, 0.000000 }, { 0.319561, 0.000000, 0.000000},
    { 0.329856, 0.000000, 0.000000 }, { 0.340150, 0.000000, 0.000000 }, { 0.350445, 0.000000, 0.000000 }, { 0.360740, 0.000000, 0.000000},
    { 0.371035, 0.000000, 0.000000 }, { 0.381330, 0.000000, 0.000000 }, { 0.391625, 0.000000, 0.000000 }, { 0.401920, 0.000000, 0.000000},
    { 0.412214, 0.000000, 0.000000 }, { 0.422509, 0.000000, 0.000000 }, { 0.432804, 0.000000, 0.000000 }, { 0.443099, 0.000000, 0.000000},
    { 0.453394, 0.000000, 0.000000 }, { 0.463689, 0.000000, 0.000000 }, { 0.473983, 0.000000, 0.000000 }, { 0.484278, 0.000000, 0.000000},
    { 0.494573, 0.000000, 0.000000 }, { 0.504868, 0.000000, 0.000000 }, { 0.515163, 0.000000, 0.000000 }, { 0.525458, 0.000000, 0.000000},
    { 0.535753, 0.000000, 0.000000 }, { 0.546047, 0.000000, 0.000000 }, { 0.556342, 0.000000, 0.000000 }, { 0.566637, 0.000000, 0.000000},
    { 0.576932, 0.000000, 0.000000 }, { 0.587227, 0.000000, 0.000000 }, { 0.597522, 0.000000, 0.000000 }, { 0.607816, 0.000000, 0.000000},
    { 0.618111, 0.000000, 0.000000 }, { 0.628406, 0.000000, 0.000000 }, { 0.638701, 0.000000, 0.000000 }, { 0.648996, 0.000000, 0.000000},
    { 0.659291, 0.000000, 0.000000 }, { 0.669585, 0.000000, 0.000000 }, { 0.679880, 0.000000, 0.000000 }, { 0.690175, 0.000000, 0.000000},
    { 0.700470, 0.000000, 0.000000 }, { 0.710765, 0.000000, 0.000000 }, { 0.721060, 0.000000, 0.000000 }, { 0.731355, 0.000000, 0.000000},
    { 0.741649, 0.000000, 0.000000 }, { 0.751944, 0.000000, 0.000000 }, { 0.762239, 0.000000, 0.000000 }, { 0.772534, 0.000000, 0.000000},
    { 0.782829, 0.000000, 0.000000 }, { 0.793124, 0.000000, 0.000000 }, { 0.803418, 0.000000, 0.000000 }, { 0.813713, 0.000000, 0.000000},
    { 0.824008, 0.000000, 0.000000 }, { 0.834303, 0.000000, 0.000000 }, { 0.844598, 0.000000, 0.000000 }, { 0.854893, 0.000000, 0.000000},
    { 0.865188, 0.000000, 0.000000 }, { 0.875482, 0.000000, 0.000000 }, { 0.885777, 0.000000, 0.000000 }, { 0.896072, 0.000000, 0.000000},
    { 0.906367, 0.000000, 0.000000 }, { 0.916662, 0.000000, 0.000000 }, { 0.926957, 0.000000, 0.000000 }, { 0.937251, 0.000000, 0.000000},
    { 0.947546, 0.000000, 0.000000 }, { 0.957841, 0.000000, 0.000000 }, { 0.968136, 0.000000, 0.000000 }, { 0.978431, 0.000000, 0.000000},
    { 0.988726, 0.000000, 0.000000 }, { 0.999020, 0.000000, 0.000000 }, { 1.000000, 0.009315, 0.000000 }, { 1.000000, 0.019609, 0.000000},
    { 1.000000, 0.029903, 0.000000 }, { 1.000000, 0.040197, 0.000000 }, { 1.000000, 0.050491, 0.000000 }, { 1.000000, 0.060785, 0.000000},
    { 1.000000, 0.071079, 0.000000 }, { 1.000000, 0.081373, 0.000000 }, { 1.000000, 0.091667, 0.000000 }, { 1.000000, 0.101962, 0.000000},
    { 1.000000, 0.112256, 0.000000 }, { 1.000000, 0.122550, 0.000000 }, { 1.000000, 0.132844, 0.000000 }, { 1.000000, 0.143138, 0.000000},
    { 1.000000, 0.153432, 0.000000 }, { 1.000000, 0.163726, 0.000000 }, { 1.000000, 0.174020, 0.000000 }, { 1.000000, 0.184314, 0.000000},
    { 1.000000, 0.194608, 0.000000 }, { 1.000000, 0.204903, 0.000000 }, { 1.000000, 0.215197, 0.000000 }, { 1.000000, 0.225491, 0.000000},
    { 1.000000, 0.235785, 0.000000 }, { 1.000000, 0.246079, 0.000000 }, { 1.000000, 0.256373, 0.000000 }, { 1.000000, 0.266667, 0.000000},
    { 1.000000, 0.276961, 0.000000 }, { 1.000000, 0.287255, 0.000000 }, { 1.000000, 0.297549, 0.000000 }, { 1.000000, 0.307844, 0.000000},
    { 1.000000, 0.318138, 0.000000 }, { 1.000000, 0.328432, 0.000000 }, { 1.000000, 0.338726, 0.000000 }, { 1.000000, 0.349020, 0.000000},
    { 1.000000, 0.359314, 0.000000 }, { 1.000000, 0.369608, 0.000000 }, { 1.000000, 0.379902, 0.000000 }, { 1.000000, 0.390196, 0.000000},
    { 1.000000, 0.400491, 0.000000 }, { 1.000000, 0.410785, 0.000000 }, { 1.000000, 0.421079, 0.000000 }, { 1.000000, 0.431373, 0.000000},
    { 1.000000, 0.441667, 0.000000 }, { 1.000000, 0.451961, 0.000000 }, { 1.000000, 0.462255, 0.000000 }, { 1.000000, 0.472549, 0.000000},
    { 1.000000, 0.482843, 0.000000 }, { 1.000000, 0.493137, 0.000000 }, { 1.000000, 0.503432, 0.000000 }, { 1.000000, 0.513726, 0.000000},
    { 1.000000, 0.524020, 0.000000 }, { 1.000000, 0.534314, 0.000000 }, { 1.000000, 0.544608, 0.000000 }, { 1.000000, 0.554902, 0.000000},
    { 1.000000, 0.565196, 0.000000 }, { 1.000000, 0.575490, 0.000000 }, { 1.000000, 0.585784, 0.000000 }, { 1.000000, 0.596078, 0.000000},
    { 1.000000, 0.606373, 0.000000 }, { 1.000000, 0.616667, 0.000000 }, { 1.000000, 0.626961, 0.000000 }, { 1.000000, 0.637255, 0.000000},
    { 1.000000, 0.647549, 0.000000 }, { 1.000000, 0.657843, 0.000000 }, { 1.000000, 0.668137, 0.000000 }, { 1.000000, 0.678431, 0.000000},
    { 1.000000, 0.688725, 0.000000 }, { 1.000000, 0.699019, 0.000000 }, { 1.000000, 0.709314, 0.000000 }, { 1.000000, 0.719608, 0.000000},
    { 1.000000, 0.729902, 0.000000 }, { 1.000000, 0.740196, 0.000000 }, { 1.000000, 0.750490, 0.000000 }, { 1.000000, 0.760784, 0.000000},
    { 1.000000, 0.771078, 0.000000 }, { 1.000000, 0.781372, 0.000000 }, { 1.000000, 0.791666, 0.000000 }, { 1.000000, 0.801960, 0.000000},
    { 1.000000, 0.812255, 0.000000 }, { 1.000000, 0.822549, 0.000000 }, { 1.000000, 0.832843, 0.000000 }, { 1.000000, 0.843137, 0.000000},
    { 1.000000, 0.853431, 0.000000 }, { 1.000000, 0.863725, 0.000000 }, { 1.000000, 0.874019, 0.000000 }, { 1.000000, 0.884313, 0.000000},
    { 1.000000, 0.894607, 0.000000 }, { 1.000000, 0.904901, 0.000000 }, { 1.000000, 0.915196, 0.000000 }, { 1.000000, 0.925490, 0.000000},
    { 1.000000, 0.935784, 0.000000 }, { 1.000000, 0.946078, 0.000000 }, { 1.000000, 0.956372, 0.000000 }, { 1.000000, 0.966666, 0.000000},
    { 1.000000, 0.976960, 0.000000 }, { 1.000000, 0.987254, 0.000000 }, { 1.000000, 0.997548, 0.000000 }, { 1.000000, 1.000000, 0.011764},
    { 1.000000, 1.000000, 0.027205 }, { 1.000000, 1.000000, 0.042646 }, { 1.000000, 1.000000, 0.058087 }, { 1.000000, 1.000000, 0.073528},
    { 1.000000, 1.000000, 0.088970 }, { 1.000000, 1.000000, 0.104411 }, { 1.000000, 1.000000, 0.119852 }, { 1.000000, 1.000000, 0.135293},
    { 1.000000, 1.000000, 0.150734 }, { 1.000000, 1.000000, 0.166176 }, { 1.000000, 1.000000, 0.181617 }, { 1.000000, 1.000000, 0.197058},
    { 1.000000, 1.000000, 0.212499 }, { 1.000000, 1.000000, 0.227940 }, { 1.000000, 1.000000, 0.243382 }, { 1.000000, 1.000000, 0.258823},
    { 1.000000, 1.000000, 0.274264 }, { 1.000000, 1.000000, 0.289705 }, { 1.000000, 1.000000, 0.305146 }, { 1.000000, 1.000000, 0.320588},
    { 1.000000, 1.000000, 0.336029 }, { 1.000000, 1.000000, 0.351470 }, { 1.000000, 1.000000, 0.366911 }, { 1.000000, 1.000000, 0.382352},
    { 1.000000, 1.000000, 0.397794 }, { 1.000000, 1.000000, 0.413235 }, { 1.000000, 1.000000, 0.428676 }, { 1.000000, 1.000000, 0.444117},
    { 1.000000, 1.000000, 0.459558 }, { 1.000000, 1.000000, 0.474999 }, { 1.000000, 1.000000, 0.490441 }, { 1.000000, 1.000000, 0.505882},
    { 1.000000, 1.000000, 0.521323 }, { 1.000000, 1.000000, 0.536764 }, { 1.000000, 1.000000, 0.552205 }, { 1.000000, 1.000000, 0.567647},
    { 1.000000, 1.000000, 0.583088 }, { 1.000000, 1.000000, 0.598529 }, { 1.000000, 1.000000, 0.613970 }, { 1.000000, 1.000000, 0.629411},
    { 1.000000, 1.000000, 0.644853 }, { 1.000000, 1.000000, 0.660294 }, { 1.000000, 1.000000, 0.675735 }, { 1.000000, 1.000000, 0.691176},
    { 1.000000, 1.000000, 0.706617 }, { 1.000000, 1.000000, 0.722059 }, { 1.000000, 1.000000, 0.737500 }, { 1.000000, 1.000000, 0.752941},
    { 1.000000, 1.000000, 0.768382 }, { 1.000000, 1.000000, 0.783823 }, { 1.000000, 1.000000, 0.799265 }, { 1.000000, 1.000000, 0.814706},
    { 1.000000, 1.000000, 0.830147 }, { 1.000000, 1.000000, 0.845588 }, { 1.000000, 1.000000, 0.861029 }, { 1.000000, 1.000000, 0.876470},
    { 1.000000, 1.000000, 0.891912 }, { 1.000000, 1.000000, 0.907353 }, { 1.000000, 1.000000, 0.922794 }, { 1.000000, 1.000000, 0.938235},
    { 1.000000, 1.000000, 0.953676 }, { 1.000000, 1.000000, 0.969118 }, { 1.000000, 1.000000, 0.984559 }, { 1.000000, 1.000000, 1.000000 }};

static const vector_float3 colorMap4[] = {
    { 0,0,0 }, { 0.000000, 0.000000, 0.168366 }, { 0.000000, 0.000000, 0.221176 }, { 0.000000, 0.000000, 0.261961},
    { 0.000000, 0.000000, 0.305098 }, { 0.000000, 0.000000, 0.346405 }, { 0.000000, 0.000000, 0.389020 }, { 0.000000, 0.000000, 0.432941},
    { 0.000000, 0.005490, 0.454902 }, { 0.001569, 0.016471, 0.454902 }, { 0.005229, 0.026144, 0.454902 }, { 0.007843, 0.034510, 0.454902},
    { 0.008627, 0.044706, 0.455686 }, { 0.012288, 0.052549, 0.458824 }, { 0.015948, 0.063268, 0.458824 }, { 0.019608, 0.070588, 0.458824},
    { 0.019608, 0.081569, 0.458824 }, { 0.023007, 0.089150, 0.458824 }, { 0.026667, 0.099608, 0.461961 }, { 0.030327, 0.107712, 0.462745},
    { 0.031373, 0.117647, 0.462745 }, { 0.033725, 0.126275, 0.462745 }, { 0.037386, 0.135686, 0.462745 }, { 0.041046, 0.144837, 0.464575},
    { 0.043137, 0.153725, 0.466667 }, { 0.044444, 0.163399, 0.466667 }, { 0.048105, 0.170719, 0.466667 }, { 0.051765, 0.178824, 0.466667},
    { 0.055425, 0.189281, 0.467190 }, { 0.058824, 0.196601, 0.470588 }, { 0.058824, 0.203922, 0.470588 }, { 0.062484, 0.214902, 0.470588},
    { 0.066144, 0.222484, 0.470588 }, { 0.069804, 0.229804, 0.470588 }, { 0.070588, 0.237124, 0.473464 }, { 0.073203, 0.247059, 0.474510},
    { 0.076863, 0.255686, 0.474510 }, { 0.080523, 0.263007, 0.474510 }, { 0.084183, 0.270327, 0.474510 }, { 0.086275, 0.277647, 0.476078},
    { 0.087582, 0.284967, 0.478431 }, { 0.091242, 0.293333, 0.478431 }, { 0.094902, 0.303529, 0.478431 }, { 0.098562, 0.310850, 0.478431},
    { 0.101961, 0.318170, 0.478693 }, { 0.101961, 0.325490, 0.482353 }, { 0.105621, 0.332810, 0.482353 }, { 0.109281, 0.340131, 0.482353},
    { 0.112941, 0.347451, 0.482353 }, { 0.116601, 0.354771, 0.482353 }, { 0.120261, 0.362092, 0.484967 }, { 0.121569, 0.369412, 0.486275},
    { 0.123660, 0.376732, 0.486275 }, { 0.127320, 0.384052, 0.486275 }, { 0.130980, 0.389804, 0.486275 }, { 0.134641, 0.394771, 0.487582},
    { 0.138301, 0.402092, 0.490196 }, { 0.141176, 0.409412, 0.490196 }, { 0.141699, 0.416732, 0.490196 }, { 0.145359, 0.423791, 0.490196},
    { 0.149020, 0.427451, 0.490196 }, { 0.152680, 0.434771, 0.493856 }, { 0.156340, 0.442092, 0.494118 }, { 0.160000, 0.449412, 0.494118},
    { 0.160784, 0.453856, 0.494118 }, { 0.163399, 0.460131, 0.494118 }, { 0.167059, 0.467451, 0.496471 }, { 0.170719, 0.472680, 0.498039},
    { 0.174379, 0.478170, 0.498039 }, { 0.178039, 0.485490, 0.498039 }, { 0.181699, 0.491503, 0.498039 }, { 0.185359, 0.496209, 0.499085},
    { 0.188235, 0.501961, 0.500392 }, { 0.188235, 0.502484, 0.493595 }, { 0.188497, 0.505882, 0.489935 }, { 0.192157, 0.505882, 0.486275},
    { 0.192157, 0.509543, 0.482614 }, { 0.195556, 0.513203, 0.478954 }, { 0.196078, 0.513726, 0.472157 }, { 0.198954, 0.516601, 0.467712},
    { 0.200000, 0.520261, 0.464052 }, { 0.202353, 0.521569, 0.460392 }, { 0.203922, 0.523660, 0.454641 }, { 0.205752, 0.525490, 0.449150},
    { 0.207843, 0.527059, 0.445490 }, { 0.209150, 0.530719, 0.440523 }, { 0.211765, 0.533333, 0.434248 }, { 0.212549, 0.534118, 0.430588},
    { 0.215686, 0.537778, 0.426928 }, { 0.215948, 0.541176, 0.423007 }, { 0.219608, 0.541176, 0.415686 }, { 0.219608, 0.544837, 0.412026},
    { 0.223007, 0.548497, 0.408366 }, { 0.223529, 0.549020, 0.401569 }, { 0.226405, 0.551895, 0.397124 }, { 0.227451, 0.552941, 0.393464},
    { 0.229804, 0.555294, 0.387451 }, { 0.231373, 0.558954, 0.382222 }, { 0.233203, 0.560784, 0.378562 }, { 0.236863, 0.562353, 0.373333},
    { 0.239216, 0.566013, 0.367320 }, { 0.240261, 0.568627, 0.363660 }, { 0.243137, 0.569412, 0.359216 }, { 0.243660, 0.572549, 0.352418},
    { 0.247059, 0.572810, 0.348758 }, { 0.247059, 0.576471, 0.345098 }, { 0.250719, 0.580131, 0.337778 }, { 0.250980, 0.580392, 0.333856},
    { 0.254118, 0.583529, 0.330196 }, { 0.254902, 0.587190, 0.323660 }, { 0.257516, 0.588235, 0.318954 }, { 0.261176, 0.590588, 0.315294},
    { 0.262745, 0.592157, 0.309543 }, { 0.264575, 0.593987, 0.304052 }, { 0.266667, 0.597647, 0.300392 }, { 0.267974, 0.600000, 0.295425},
    { 0.270588, 0.601046, 0.289150 }, { 0.271373, 0.604706, 0.284706 }, { 0.275033, 0.607843, 0.277909 }, { 0.278954, 0.608105, 0.274771},
    { 0.286275, 0.611765, 0.278431 }, { 0.297255, 0.611765, 0.282092 }, { 0.304837, 0.615163, 0.282353 }, { 0.315294, 0.618824, 0.285490},
    { 0.323399, 0.619608, 0.286275 }, { 0.333333, 0.622222, 0.288889 }, { 0.341961, 0.625882, 0.292549 }, { 0.351373, 0.627451, 0.294118},
    { 0.362353, 0.629281, 0.295948 }, { 0.371765, 0.631373, 0.298039 }, { 0.380392, 0.632680, 0.299346 }, { 0.390327, 0.636340, 0.301961},
    { 0.398431, 0.639216, 0.302745 }, { 0.408889, 0.639739, 0.306405 }, { 0.416471, 0.643399, 0.309804 }, { 0.427451, 0.647059, 0.309804},
    { 0.434771, 0.647059, 0.313464 }, { 0.445490, 0.650458, 0.313726 }, { 0.456471, 0.650980, 0.316863 }, { 0.464575, 0.653856, 0.320523},
    { 0.471895, 0.657516, 0.321569 }, { 0.476863, 0.658824, 0.321569 }, { 0.482614, 0.658824, 0.323660 }, { 0.489935, 0.660654, 0.325490},
    { 0.497255, 0.662745, 0.325490 }, { 0.503268, 0.664052, 0.326797 }, { 0.507974, 0.666667, 0.329412 }, { 0.515294, 0.667451, 0.329412},
    { 0.522614, 0.670588, 0.329935 }, { 0.529673, 0.670850, 0.333333 }, { 0.533333, 0.674510, 0.333333 }, { 0.540654, 0.674510, 0.333333},
    { 0.547974, 0.674510, 0.336732 }, { 0.552157, 0.677647, 0.337255 }, { 0.558693, 0.678431, 0.337255 }, { 0.566013, 0.681046, 0.339869},
    { 0.573333, 0.682353, 0.341176 }, { 0.580654, 0.684444, 0.341176 }, { 0.586144, 0.686275, 0.343007 }, { 0.591373, 0.686275, 0.345098},
    { 0.598693, 0.687582, 0.345098 }, { 0.606013, 0.690196, 0.346144 }, { 0.612549, 0.690980, 0.349020 }, { 0.616732, 0.694118, 0.349020},
    { 0.624052, 0.694379, 0.349281 }, { 0.631373, 0.698039, 0.352941 }, { 0.638693, 0.698039, 0.352941 }, { 0.646013, 0.701438, 0.352941},
    { 0.650196, 0.701961, 0.356078 }, { 0.656732, 0.701961, 0.356863 }, { 0.664052, 0.704575, 0.356863 }, { 0.671373, 0.705882, 0.359216},
    { 0.678693, 0.707974, 0.360784 }, { 0.684183, 0.709804, 0.360784 }, { 0.689412, 0.711373, 0.362353 }, { 0.696732, 0.713726, 0.364706},
    { 0.704052, 0.714771, 0.364706 }, { 0.711373, 0.717647, 0.365490 }, { 0.717647, 0.717124, 0.368627 }, { 0.717909, 0.713464, 0.368627},
    { 0.721569, 0.709804, 0.368627 }, { 0.721569, 0.709804, 0.372288 }, { 0.724967, 0.706405, 0.372549 }, { 0.725490, 0.702745, 0.372549},
    { 0.728366, 0.699085, 0.375425 }, { 0.729412, 0.695425, 0.376471 }, { 0.731765, 0.691765, 0.378824 }, { 0.733333, 0.688105, 0.380392},
    { 0.733333, 0.684444, 0.380392 }, { 0.734902, 0.680784, 0.381961 }, { 0.737255, 0.677124, 0.384314 }, { 0.738301, 0.673464, 0.384314},
    { 0.741176, 0.669804, 0.385098 }, { 0.741699, 0.666144, 0.388235 }, { 0.745098, 0.662484, 0.388235 }, { 0.745098, 0.658824, 0.388235},
    { 0.745098, 0.655163, 0.391895 }, { 0.748497, 0.651503, 0.392157 }, { 0.749020, 0.647843, 0.392157 }, { 0.751895, 0.644183, 0.395033},
    { 0.752941, 0.640523, 0.396078 }, { 0.755294, 0.639216, 0.403137 }, { 0.761046, 0.641307, 0.412026 }, { 0.766536, 0.643137, 0.419346},
    { 0.770196, 0.644706, 0.428235 }, { 0.773856, 0.647059, 0.437909 }, { 0.777516, 0.648105, 0.446275 }, { 0.781961, 0.651765, 0.456471},
    { 0.788758, 0.654902, 0.464314 }, { 0.792418, 0.655163, 0.475033 }, { 0.796078, 0.658824, 0.482353 }, { 0.799739, 0.662484, 0.493333},
    { 0.803399, 0.666144, 0.504314 }, { 0.810196, 0.669804, 0.512157 }, { 0.814641, 0.673464, 0.522353 }, { 0.818301, 0.677124, 0.533333},
    { 0.821961, 0.680784, 0.541961 }, { 0.825621, 0.684444, 0.551373 }, { 0.831111, 0.688105, 0.562353 }, { 0.836863, 0.691765, 0.573333},
    { 0.840523, 0.695425, 0.583007 }, { 0.844183, 0.699085, 0.591373 }, { 0.847843, 0.703529, 0.602353 }, { 0.852026, 0.710327, 0.613333},
    { 0.859085, 0.714248, 0.624314 }, { 0.862745, 0.721569, 0.635294 }, { 0.866405, 0.725229, 0.646275 }, { 0.870065, 0.732288, 0.657255},
    { 0.873726, 0.736471, 0.665098 }, { 0.880261, 0.743007, 0.675294 }, { 0.884967, 0.750327, 0.686275 }, { 0.888627, 0.757647, 0.697255},
    { 0.892288, 0.764967, 0.708235 }, { 0.895948, 0.772288, 0.719216 }, { 0.901176, 0.779608, 0.731765 }, { 0.907190, 0.786928, 0.745098},
    { 0.910850, 0.794248, 0.756078 }, { 0.914510, 0.801569, 0.767059 }, { 0.918170, 0.808889, 0.778039 }, { 0.922092, 0.816471, 0.789020},
    { 0.929412, 0.827451, 0.800000 }, { 0.933072, 0.834771, 0.810980 }, { 0.936732, 0.842092, 0.825359 }, { 0.940392, 0.852549, 0.836863},
    { 0.944052, 0.863529, 0.847843 }, { 0.950327, 0.871895, 0.858824 }, { 0.955294, 0.881569, 0.872157 }, { 0.958954, 0.892549, 0.884706},
    { 0.962614, 0.903529, 0.895686 }, { 0.966275, 0.914510, 0.908235 }, { 0.971242, 0.925490, 0.921569 }, { 0.977516, 0.936471, 0.933595},
    { 0.981176, 0.947451, 0.947451 }, { 0.984837, 0.958954, 0.958954 }, { 0.988497, 0.973333, 0.973333 }, { 0.992157, 0.984314, 0.984314 }};

const vector_float3 colorLookup1(int index) { return colorMap1[index]; }
const vector_float3 colorLookup2(int index) { return colorMap2[index]; }
const vector_float3 colorLookup3(int index) { return colorMap3[index]; }
const vector_float3 colorLookup4(int index) { return colorMap4[index]; }

const vector_float3 *colorLookupPtr1(void) { return colorMap1; }
const vector_float3 *colorLookupPtr2(void) { return colorMap2; }
const vector_float3 *colorLookupPtr3(void) { return colorMap3; }
const vector_float3 *colorLookupPtr4(void) { return colorMap4; }


