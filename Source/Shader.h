#pragma once

#ifdef __METAL_VERSION__
#define NS_ENUM(_type, _name) enum _name : _type _name; enum _name : _type
#define NSInteger metal::int32_t
#else
#import <Foundation/Foundation.h>
#endif

#include <simd/simd.h>

#define MAX_ITERATIONS 40
#define VMAX int((255000000 / sizeof(TVertex)) - 10000)
#define WIDTH 200

enum { BULB_1,BULB_2,BULB_3,BULB_4,BULB_5,JULIA,BOX,QJULIA,IFS,APOLLONIAN };

typedef struct {
    unsigned char data[WIDTH][WIDTH][WIDTH];
} Map3D;

typedef struct {
    int version;
    int xSize,ySize;
    
    float basex;
    float basey;
    float basez;
    float scale;
    float power;
    float re1;
    float im1;
    float mult1;
    float zoom1;
    float re2;
    float im2;
    float mult2;
    float zoom2;
    
    int formula;
    int hop;
    int center;
    int spread;
    int offset;
    int range;
    int ifsIndex;
    int param;
    
    unsigned char pColor[MAX_ITERATIONS];
} Control;

typedef struct {
    int count;
} Counter;

typedef struct {
    int count[256];
} Histogram;

typedef struct {
    matrix_float4x4 projectionMatrix;
    matrix_float4x4 modelViewMatrix;
    matrix_float4x4 mvp;
    vector_float3 light;
    float pointSize;
} Uniforms;

typedef struct {
    vector_float3 pos;
    vector_float4 color;
} TVertex;

#ifndef __METAL_VERSION__

void setControlPointer(Control *ptr);
void setPColor(int index, int value);
int  getPColor(int index);
void pColorClear(void);

// moving color lookup tables from Swift to 'C'  greatly speeds up compile time
const vector_float3 colorLookup1(int index);
const vector_float3 colorLookup2(int index);
const vector_float3 colorLookup3(int index);
const vector_float3 colorLookup4(int index);
const vector_float3 *colorLookupPtr1(void);
const vector_float3 *colorLookupPtr2(void);
const vector_float3 *colorLookupPtr3(void);
const vector_float3 *colorLookupPtr4(void);

#endif

