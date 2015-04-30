/**
 * @author alteredq / http://alteredqualia.com/
 *
 * Based on Nvidia Cg tutorial
 */

THREE.SphereShader = {

	uniforms: {

		"refractionIndex": { type: "f", value: 0.5 },
		"radius": { type: "f", value: 15 },
		"centerX": { type: "f", value: 0 },
		"centerY": { type: "f", value: 0 },
		"texture1": { type: "t", value: null }

	},
  
	vertexShader: [
		"uniform float refractionIndex;",
		"uniform float radius;",
		"uniform float centerX;",
		"uniform float centerY;",
    
    "varying vec2 vUv;",
    "varying float x;",
    "varying float y;",
    "varying float origX;",
    "varying float origY;",
    "varying float distX;",
    "varying float distY;",
    "varying float radius2;",
    "varying float ya;",
    "varying float xa;",
    "varying float yb;",
    "varying float xb;",
    "varying float z;",
    "varying float z2;",
    "varying float r2;",
    
		"void main() {",
      "x = position[0];",
      "y = position[1];",
      "origX = x;",
      "origY =y;",
      "  distX = x - centerX;",
      "  distY = y - centerY;",
      "  r2 = distX * distX + distY * distY;",
      "radius2 = radius * radius;",
      "  if ( r2 > 0.0 && r2 < radius2) {",
        
      " /*     // distance                                                                    "      ,
      "     z2 = radius2 - r2;                                                             "      ,
      "     z = sqrt(z2);                                                             "           ,
      "                                                                                    "      ,
      "     // refraction                                                                   "      ,
      "     xa = asin( distX / sqrt( distX * distX + z2 ) );                     "                ,
      "     xb = xa - xa * refractionIndex;                                                "      ,
      "     ya = asin( distY / sqrt( distY * distY + z2 ) );                     "                ,
      "     yb = ya - ya * refractionIndex;                                                "      ,
      "                                                                                    "      ,
      "     //displacement                                                                  "      ,
      "     origX = origX - z * tan( xb );                                            "           ,
      "     origY = origY - z * tan( yb ); */ ",
      "     vUv = uv; "                                                           ,
      "  } else {"                                                   ,
      "     vUv = uv; "                                                           ,
      "  }",
      "gl_Position =  projectionMatrix * modelViewMatrix * vec4(position,1.0);",
		"}"

	].join("\n"),

	fragmentShader: [

		"uniform sampler2D texture1;",

		"varying vec2 vUv;",

		"void main() {",

			"gl_FragColor = texture2D(texture1, vUv);",

		"}"

	].join("\n")

};
