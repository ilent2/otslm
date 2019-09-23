// This is the shader from the labview VI supplied with RedTweezers
// See the RedTweezers paper for more information.

const vec4 white = vec4(1,1,1,1);
uniform int n;                     //number of spots
uniform float totalA;         //total of the "intensity" parameters (used for intensity shaping)

// This uniform is either of the following (depending on if n > 50)
// (1) sampler2D spots
// (2) vec4 spots[200]

uniform %%spotsdecl%%; //spot parameters- each spot corresponds to 4 vec4, first one is x,y,z,l, second one is amplitude, -,-,-
                                            //element 0 x  y  z  l    (x,y,z in um and l is an integer)
                                            //element 1 intensity (I) phase -  -
                                            //element 2 na.x na.y na.r -  (the x, y position, and radius, of the spot on the SLM- useful for Shack-Hartmann holograms)
                                            //element 3 line trapping x y z and phase gradient.  xyz define the size and angle of the line, phase gradient (between +/-1) is the
                                            //scattering force component along the line.  Zero is usually a good choice for in-plane line traps
uniform vec2 centre;        //=vec2(0.5,0.5);//centre of the hologram as a fraction of its size (usually 0.5,0.5)
uniform vec2 size;            //=vec2(7000,7000);//size of the hologram in microns
uniform float f;                 //=1600; //focal length in microns
uniform float k;                //=9.36; //wavevector in 1/microns
uniform float blazing[32]; //blazing function
uniform float zernikeCoefficients[12]; //zernike coefficients, matching the modes defined below
uniform vec3 zernx;        //=vec3(0.0,0.0,0.0);
uniform vec3 zerny;        //=vec3(0.0,0.0,0.0);
uniform vec3 zernz;        //=vec3(0.0,0.0,0.0);

//
// Standarf cuntion definitions (separate VI, added by substitution)
//

const float pi = 3.1415;

float zernikeCombination(float zc[12]){
  //takes a 12-element array of coefficients, and returns a weighted sum
  //of Zernike modes.  This should now be THE way of generating aberration
  //corrections from Zernikes...
  float x = 2.0*gl_TexCoord[0].x - 1.0;
  float y = 2.0*gl_TexCoord[0].y - 1.0;
  float r2 = x*x+y*y;
  float a = 0.0;
  a += zc[0] * (2.0*x*y);                                                //(2,-2)
  a += zc[1] * (2.0*r2-1.0);                                           //(2,0)
  a += zc[2] * (x*x-y*y);                                               //(2,2)
  a += zc[3] * (3.0*x*x*y-y*y*y);                                 //(3,-3)
  a += zc[4] * ((3.0*r2-2.0)*y);                                    //(3,-1)
  a += zc[5] * ((3.0*r2-2.0)*x);                                    //(3,1)
  a += zc[6] * (x*x*x-3.0*x*y*y);                                 //(3,3)
  a += zc[7] * (4.0*x*y*(x*x-y*y));                              //(4,-4)
  a += zc[8] * ((4.0*r2-3.0)*2.0*x*y);                          //(4,-2)
  a += zc[9] * (6.0*r2*r2-6*r2+1);                               //(4,0)
  a += zc[10] * ((4.0*r2-3.0)*(x*x-y*y));                      //(4,2)
  a += zc[11] * (x*x*x*x-6.0*x*x*y*y+y*y*y*y);          //(4,4)
  return a;
}


float zernikeAberration(){
//this function is exactly the same as zernikeCombination, except that it uses a uniform
//called zernikeCoefficients as its argument.  This avoids copying the array = more efficient.
  //takes a 12-element array of coefficients, and returns a weighted sum
  //of Zernike modes.  This should now be THE way of generating aberration
  //corrections from Zernikes...
  float x = 2.0*gl_TexCoord[0].x - 1.0;
  float y = 2.0*gl_TexCoord[0].y - 1.0;
  float r2 = x*x+y*y;
  float a = 0.0;
  a += zernikeCoefficients[0] * (2.0*x*y);                                                //(2,-2)
  a += zernikeCoefficients[1] * (2.0*r2-1.0);                                           //(2,0)
  a += zernikeCoefficients[2] * (x*x-y*y);                                               //(2,2)
  a += zernikeCoefficients[3] * (3.0*x*x*y-y*y*y);                                 //(3,-3)
  a += zernikeCoefficients[4] * ((3.0*r2-2.0)*y);                                    //(3,-1)
  a += zernikeCoefficients[5] * ((3.0*r2-2.0)*x);                                    //(3,1)
  a += zernikeCoefficients[6] * (x*x*x-3.0*x*y*y);                                 //(3,3)
  a += zernikeCoefficients[7] * (4.0*x*y*(x*x-y*y));                              //(4,-4)
  a += zernikeCoefficients[8] * ((4.0*r2-3.0)*2.0*x*y);                          //(4,-2)
  a += zernikeCoefficients[9] * (6.0*r2*r2-6*r2+1);                               //(4,0)
  a += zernikeCoefficients[10] * ((4.0*r2-3.0)*(x*x-y*y));                      //(4,2)
  a += zernikeCoefficients[11] * (x*x*x*x-6.0*x*x*y*y+y*y*y*y);          //(4,4)
  return a;
}

float wrap2pi(float phase){
  return mod(phase + pi, 2*pi) -pi;
}

float phase_to_gray(float phase){
  return phase/2.0/pi +0.5;
}

vec2 unitvector(float angle){
  return vec2(cos(angle), sin(angle));
}

float apply_LUT(float phase){
  int phint = int(floor((phase/2.0/pi +0.5)*30.9999999)); //blazing table element just before our point
  float alpha = fract((phase/2.0/pi +0.5)*30.9999999); //remainder
  return mix(blazing[phint], blazing[phint+1], alpha); //this uses the blazing table with linear interpolation
}

vec4 gray_to_16bit(float gray){
  return vec4(fract(gray * 255.9999), floor(gray * 255.9999)/255.0, 0.0, 1.0);
}

//
// End standard functions
//

// The following is either of the following:
// (1) texture(spots, vec2( (float(j) +0.5) / 4.0, ( float(i) + 0.5) / float(n) ))*500.0 -250.0
// (2) spots[4*i +j]

vec4 spot(int i, int j){
  return %%spotsret%%;
}

void main(void)
{
   float phase;                                                       //phase of current pixel, due to the spot (in loop) or of the resultant hologram (after loop)
   float amplitude;                                               //ditto for amplitude
   vec2 xy=(gl_TexCoord[0].xy-centre)*size;    //current xy position in the hologram, in microns
   float phi=atan(xy.x,xy.y);		                              //angle of the line joining our point to the centre of the pattern
   float length;                                                     //length of a line
   vec4 pos=vec4(xy/f,1.0-dot(xy,xy)/2.0/f/f,phi/k);
   vec4 na;                                                           //to be used later, inside the loop
	 float sx;

                                                     //this loop goes through the spots and calculates the contribution from each one, summing
                                                                            //real and imaginary parts as we go.
   vec2 total = vec2(0.0,0.0);                             //real and imaginary parts of the complex hologram for this pixel
   for(int i=0; i<n; i++){
      amplitude=spot(i,1)[0];                             //amplitude of current spot
      phase=k*dot(spot(i,0),pos)+spot(i,1)[1]; 
                                                                            //this is the basic gratings and lenses algorithm; phase=kx*x+ky*y+kz*(x^2+y^2)+l*theta

      na = spot(i,2);                                           //restrict the spot to a region of the back aperture which is na[2] in radius, centred on na.xy
      if(dot(na.xy-xy/size,na.xy-xy/size) > na[2]*na[2]){
        amplitude = 0.0;
      }
//creates an xyz line trap, needs amplitude shaping.
      vec4 line = spot(i,3);
      length=sqrt(dot(line.xyz,line.xyz));
      if(length>0.0){
		      sx=k*dot(vec4(pos.xyz,1.0*length),line);
		      if(sx!=0.0) amplitude*=sin(sx)/sx;
      }

      total += amplitude * unitvector(phase); //finally, convert from amplitude+phase to real+imaginary for the summation
   }
   amplitude = dot(total, total);
   phase=atan(total.y,total.x);
   phase += zernikeAberration(); //apply aberration correction
   if(amplitude==0.0) phase=0.0;                                      //don't focus zero order
   if(totalA>0.0){ //do amplitude-shaping (dumps light into zero order when not needed)
     phase *= clamp(amplitude/totalA,0.0,1.0);
   }
   phase = wrap2pi(phase);
//   gl_FragColor = gray_to_16bit( apply_LUT(phase)); //16-bit output with LUT, for 16 bit BNS modulators
   gl_FragColor = vec4(1,1,1,1) * apply_LUT(phase);  //8-bit output with LUT, best for Hamamatsu/Holoeye (works for BNS too)
//   gl_FragColor = vec4(1,1,1,1) * phase_to_gray(phase);          //8-bit output, linear LUT, mostly here for debug purposes
//   gl_FragColor = clamp(vec4(.866*cos(phase) -.5*sin(phase), -.866*cos(phase)-.5*sin(phase),sin(phase),1.0)/1.5+0.6667,0.0,1.0); //phase rainbow output
//   gl_FragColor = vec4(%%randcol%%);

}
