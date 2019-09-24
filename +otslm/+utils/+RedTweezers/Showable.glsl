// Shader for Showable region, draws texture to the full window
//
// Copyright 2019 Isaac Lenton
// This file is part of OTSLM, see LICENSE.md for information about
// using/distributing this file.

uniform sampler2D pattern;
void main(void)
{
  vec2 xy = gl_TexCoord[0].xy;
  gl_FragColor = texture(pattern, xy);
}
