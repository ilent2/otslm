/* vis_rsmethod.cpp - Rayleigh-Sommerfeld integral for visualisation.
 * 
 * Implementation of C++ MEX function for calculating the
 * Rayleigh-Sommerfeld integral for a plane some distance away.
 *
 * Uout = vis_rsmethod(Uin, dx, distance, scale) calculates
 * a plane Uout parallel to Uin with distance separation.  dx is the
 * width of pixels in the input image (or a 2 element vector for
 * x and y pixel widths).  scale (integer) is the size of pixels in
 * the output image compared to pixels in the input.  All distances
 * are in units of wavelength.
 *
 * Copyright (C) 2017 Isaac Lenton (aka ilent2)
 */

#include "mex.h"
#include "matrix.h"
#include <cmath>
#include <complex>

#define U_IN          prhs[0]
#define DX_IN         prhs[1]
#define DISTANCE_IN   prhs[2]
#define SCALE_IN      prhs[3]
#define U_OUT         plhs[0]

#if !defined(MAX)
#define MAX(A, B) ((A) > (B) ? (A) : (B))
#endif

#if !defined(MIN)
#define MIN(A, B) ((A) < (B) ? (A) : (B))
#endif

class Point
{
public:
  /** Create a new point representation. */
  Point(double _x, double _y, double _z) : x(_x), y(_y), z(_z) {}

  /** Calculate length of vector. */
  double length(void) const
  {
    return sqrt(x*x + y*y + z*z);
  }

  double x, y, z;
};

/** Subtraction of two point vectors. */
Point operator- (const Point& a, const Point& b)
{
  return Point(a.x - b.x, a.y - b.y, a.z - b.z);
}

/** Subtraction of two point vectors. */
Point operator+ (const Point& a, const Point& b)
{
  return Point(a.x + b.x, a.y + b.y, a.z + b.z);
}


/** An object to wrap a MEX complex field plane. */
class Field
{
public:

  typedef std::complex<double> complex;

  /** Construct a new field wrapper object. */
  Field(unsigned m, unsigned n, complex* _data, double _dx, double _dy)
    : rows(m), cols(n), data(_data), dx(_dx), dy(_dy)
  {
    // Nothing to do
  }

  /** Propagate a field some distance, storing result in output. */
  void propogate(double distance, Field& output) const
  {
    for (unsigned i = 0; i < output.cols; ++i) {
      for (unsigned j = 0; j < output.rows; ++j) {
        output.at(j, i) = calculate(
            output.point(j, i) + Point(0, 0, distance));
      }
    }
  }

  /** Calculate the field value at some target point. */
  complex calculate(const Point& target) const
  {
    complex output = 0.0;

    for (unsigned i = 0; i < cols; ++i) {
      for (unsigned j = 0; j < rows; ++j) {
        double dist = (target - point(j, i)).length();
        output += at(j, i) * exp(complex(0, 1)*2.0*M_PI*dist)/dist;
      }
    }

    return output/complex(0, 1)*dx*dy;
  }

private:

  /** Calculate the coordinates for a point. */
  Point point(unsigned row, unsigned col) const
  {
    double x = ((col + 0.5) - 0.5*cols)*dx;
    double y = ((row + 0.5) - 0.5*rows)*dy;
    return Point(x, y, 0.0);
  }

  /** Get a location in the field. */
  complex at(unsigned row, unsigned col) const
  {
    if (row >= rows || col >= cols) {
      mexErrMsgIdAndTxt("otslm:tools:visRsmethod:internalerr",
          "Attempt to access value outside range");
    }

    return data[row + col*rows];
  }

  /** Set a location in the field. */
  complex& at(unsigned row, unsigned col)
  {
    if (row >= rows || col >= cols) {
      mexErrMsgIdAndTxt("otslm:tools:visRsmethod:internalerr",
          "Attempt to access value outside range");
    }

    return data[row + col*rows];
  }

private:
  unsigned rows;      //< Size of the data (number of rows)
  unsigned cols;      //< Size of the data (number of columns)
  complex* data;      //< Plane of the field
  double dx;          //< Pixel size (x direction)
  double dy;          //< Pixel size (y direction)
};

/* The gateway function. */
void mexFunction(int nlhs, mxArray* plhs[],
    int nrhs, const mxArray* prhs[]) {

  // Check number of inputs/outputs
  if (nrhs != 4) {
    mexErrMsgIdAndTxt("otslm:tools:visRsmethod:nargin",
        "vis_rsmethod returnes 4 inputs");
  }
  if (nlhs != 1) {
    mexErrMsgIdAndTxt("otslm:tools:visRsmethod:nargout",
        "vis_rsmethod returns one output argument");
  }

  // Check type of U_IN
  if (mxIsSparse(U_IN) || !mxIsDouble(U_IN)) {
    mexErrMsgIdAndTxt("otslm:tools:visRsmethod:invalidU",
        "U must be non-sparse matrix");
  }

  // Check dimensions of DX_IN
  size_t mDx = mxGetM(DX_IN);
  size_t nDx = mxGetN(DX_IN);
  if (MAX(mDx, nDx) > 2 || MIN(mDx, nDx) != 1 ||
      !mxIsDouble(DX_IN) || mxIsSparse(DX_IN) || mxIsComplex(DX_IN)) {
    mexErrMsgIdAndTxt("otslm:tools:visRsmethod:invalidDx",
        "dx must be scalar or 2 x 1 vector describing pixel size");
  }

  // Check DISTANCE_IN
  if (!mxIsDouble(DISTANCE_IN) || mxIsComplex(DISTANCE_IN) ||
      !mxIsScalar(DISTANCE_IN)) {
    mexErrMsgIdAndTxt("otslm:tools:visRsmethod:invalidDistance",
        "distance must be a scalar");
  }

  // Check SCALE_IN
  if (!mxIsDouble(SCALE_IN) || mxIsComplex(SCALE_IN) ||
      !mxIsScalar(SCALE_IN)) {
    mexErrMsgIdAndTxt("otslm:tools:visRsmethod:invalidScale",
        "scale must be a scalar");
  }

  size_t mUin = mxGetM(U_IN);
  size_t nUin = mxGetN(U_IN);

  double scale = *mxGetPr(SCALE_IN);

  // Calculate size of output
  size_t mUout = round(mUin * scale);
  size_t nUout = round(nUin * scale);

  // Create a matrix for return argument
  U_OUT = mxCreateDoubleMatrix((mwSize)mUout, (mwSize)nUout, mxCOMPLEX);

  // Get dx, dy
  double* dxdy = mxGetPr(DX_IN);
  double dx = dxdy[0], dy = dxdy[0];
  if (MAX(mDx, nDx) == 2) dy = dxdy[1];

  // Wrap field objects
  Field input(mUin, nUin,
      (Field::complex*) mxGetComplexDoubles(U_IN), dx, dy);
  Field output(mUout, nUout,
      (Field::complex*) mxGetComplexDoubles(U_OUT), dx*scale, dy*scale);

  double distance = *mxGetPr(DISTANCE_IN);

  // Propagate the field
  input.propogate(distance, output);
}
