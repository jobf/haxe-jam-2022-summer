package samples;

class ColorFilterFormulas {
	public static var White = '
	vec4 solidColor = vec4(0.03);
	vec4 compose(){
		return solidColor;
	}
	';
	
	public static var Hues = '
	vec4 compose(){
		// time varying pixel color
		vec3 col = 0.5 + 0.5*cos(uTime+vTexCoord.xyx+vec3(0,2,4));
		return vec4(col * 0.5, 0.5);
	}
	';

	public static var Gradient = '
	vec4 compose(){
		// y varying pixel alpha
		float fmin = 0.3;
		float fmod = mod(vTexCoord.y, 2.0);
		float fstep = fmin + (1.0 - fmin) * fmod;
		return vec4(1.0, 1.0, 1.0, fstep);
	}
	';
}

class FrameBufferFormulas {
	public static var PassThroughFilter = '
	vec4 globalCompose( int textureID ){
		return getTextureColor(textureID, vTexCoord);
	}';

	// needs work, see https://www.shadertoy.com/view/XdScD1
	public static var TwistingRings = '
	#define TWO_PI 6.2831

	vec2 rotate (vec2 coord, float angle, vec2 iResolution){
		float sin_factor = sin(angle);
		float cos_factor = cos(angle);
		vec2 c = vec2((coord.x - 0.5) * (iResolution.x / iResolution.y), coord.y - 0.5) * mat2(cos_factor, sin_factor, -sin_factor, cos_factor);
		c += 0.5;
    	return c;
	}

	vec4 globalCompose( int textureID ){
		vec2 res = getTextureResolution(textureID);
		vec2 uv = vTexCoord ;
		vec2 tc = uv / res;
		tc = vTexCoord;
		
		float rings = 30.0;
		float d = 1.0 - floor(distance(vec2(0.5 * (res.x/res.y), 0.5),vec2(tc.x * (res.x/res.y), tc.y))*rings)/rings;
		
		return getTextureColor(textureID, tc + rotate(tc, uTime, res)*d);
	}
	';


	// inspired by https://www.shadertoy.com/view/4sBBDK
	public static var DotScreen = '
	float greyScale(in vec3 col) {
		return dot(col, vec3(0.2126, 0.7152, 0.0722));
	}

	mat2 rotate2d(float angle){
		return mat2(cos(angle), -sin(angle), sin(angle),cos(angle));
	}

	float dotScreen(in vec2 uv, in float angle, in float scale, vec2 res) {
		float s = sin( angle ), c = cos( angle );
		vec2 p = (uv - vec2(0.5)) * res.xy;
		vec2 q = rotate2d(angle) * p * scale; 
		return ( sin( q.x ) * sin( q.y ) ) * 4.0;
	}

	vec4 globalCompose( int textureID ){
		vec2 uv = vTexCoord;
		vec3 col = getTextureColor(textureID, vTexCoord).rgb; 
		float grey = greyScale(col); 
		float angle = 0.4;
		float scale = 1.0 + 0.8 * sin(uTime); 
		vec2 res = getTextureResolution(textureID);
		col = vec3( grey * 10.0 - 5.0 + dotScreen(uv, angle, scale, res ) );
		vec3 tex = getTextureColor(textureID, vTexCoord).rgb;
		return vec4( mix(col, tex, 0.9), 1.0 );
	}
	';
}



