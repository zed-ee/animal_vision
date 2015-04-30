/**
 * @author alteredq / http://alteredqualia.com/
 *
 * Based on Nvidia Cg tutorial
 */

THREE.SimpleShader2 = {
	uniforms: {
		"texture1": { type: "t", value: null }

	},
    
	vertexShader: [
    "varying vec2 vUv;",
		"void main() {",
      "vUv = uv *1.0;",
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
