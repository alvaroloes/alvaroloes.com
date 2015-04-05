/**
 * @author alteredq / http://alteredqualia.com/
 *
 * Blend two textures
 */

THREE.AdditiveShader = {

	uniforms: {

		"tDiffuse": { type: "t", value: null },
		"tAdd": { type: "t", value: null },
		"mixRatio":  { type: "f", value: 1 }

	},

	vertexShader: [

		"varying vec2 vUv;",

		"void main() {",

			"vUv = uv;",
			"gl_Position = projectionMatrix * modelViewMatrix * vec4( position, 1.0 );",

		"}"

	].join("\n"),

	fragmentShader: [

		"uniform float mixRatio;",

		"uniform sampler2D tDiffuse;",
		"uniform sampler2D tAdd;",

		"varying vec2 vUv;",

		"void main() {",

			"vec4 texel1 = texture2D( tDiffuse, vUv );",
			"vec4 texel2 = texture2D( tAdd, vUv );",
			"gl_FragColor = texel1 + texel2 * mixRatio;",

		"}"

	].join("\n")

};
