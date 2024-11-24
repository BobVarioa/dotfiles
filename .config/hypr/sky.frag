#version 320 es
#ifdef GL_ES
precision mediump float;
#endif

uniform float time;
uniform vec2 resolution;

float iTime = 0.0;
vec3  iResolution = vec3(0.0);

#define PI 3.1415926535
const int PRIME_X = 501125321;
const int PRIME_Y = 1136930381;

const vec3 clouds_edge_color = vec3( 0.8, 0.8, 0.98 );
const vec3 clouds_top_color = vec3( 1.0, 1.0, 1.00 );
const vec3 clouds_middle_color = vec3( 0.92, 0.92, 0.98 );
const vec3 clouds_bottom_color = vec3( 0.83, 0.83, 0.94 );
const float clouds_speed = 1.5;
const float clouds_direction  = 0.25;
const float clouds_scale = 1.0;
const float clouds_cutoff = 0.3;
const float clouds_fuzziness  = 0.8;
// More weight is simply a darker color, usefull for rain/storm
const float clouds_weight = 0.0;
const float clouds_blur = 0.25;

const vec3 night_top_color = vec3(0.122, 0, 0.239); // vec3( 0.02, 0.0, 0.04 );
const vec3 night_bottom_color = vec3(0.2, 0, 0.388); // vec3( 0.1, 0.0, 0.2 );

float lerp( float a, float b, float t )
{
    return a + t * ( b - a );
}
float cubic_lerp( float a, float b, float c, float d, float t )
{
    float p = d - c - ( a - b );
    return t * t * t * p + t * t * ( a - b - p ) + t * ( c - a ) + b;
}
float ping_pong( float t )
{
    t -= floor( t * 0.5 ) * 2.0;
    return t < 1.0 ? t : 2.0 - t;
}

float val_coord( int seed, int x_primed, int y_primed )
{
    int hash = ( seed ^ x_primed ^ y_primed ) * 0x27d4eb2d;
    hash *= hash;
    hash ^= hash << 19;
    return float( hash ) * ( 1.0 / 2147483648.0 );
}
float single_value_cubic( int seed, float x, float y )
{
    int x1 = int( floor( x ));
    int y1 = int( floor( y ));

    float xs = x - float( x1 );
    float ys = y - float( y1 );

    x1 *= PRIME_X;
    y1 *= PRIME_Y;
    int x0 = x1 - PRIME_X;
    int y0 = y1 - PRIME_Y;
    int x2 = x1 + PRIME_X;
    int y2 = y1 + PRIME_Y;
    int x3 = x1 + ( PRIME_X * 2 );
    int y3 = y1 + ( PRIME_Y * 2 );

    return cubic_lerp(
        cubic_lerp( val_coord( seed, x0, y0 ), val_coord( seed, x1, y0 ), val_coord( seed, x2, y0 ), val_coord( seed, x3, y0 ), xs ),
        cubic_lerp( val_coord( seed, x0, y1 ), val_coord( seed, x1, y1 ), val_coord( seed, x2, y1 ), val_coord( seed, x3, y1 ), xs ),
        cubic_lerp( val_coord( seed, x0, y2 ), val_coord( seed, x1, y2 ), val_coord( seed, x2, y2 ), val_coord( seed, x3, y2 ), xs ),
        cubic_lerp( val_coord( seed, x0, y3 ), val_coord( seed, x1, y3 ), val_coord( seed, x2, y3 ), val_coord( seed, x3, y3 ), xs ),
    ys ) * ( 1.0 / ( 1.5 * 1.5 ));
}
// Params can be change in the same way as in noise settings in Godot
const float FRACTAL_BOUNDING = 1.0 / 1.75;
const int OCTAVES = 5;
const float PING_PONG_STRENGTH = 2.0;
const float WEIGHTED_STRENGTH = 0.0;
const float GAIN = 0.5;
const float LACUNARITY = 2.0;
float gen_fractal_ping_pong( vec2 pos, int seed, float frequency )
{
    float x = pos.x * frequency;
    float y = pos.y * frequency;
    float sum = 0.0;
    float amp = FRACTAL_BOUNDING;
    for( int i = 0; i < OCTAVES; i++ )
    {
        float noise = ping_pong(( single_value_cubic( seed++, x, y ) + 1.0 ) * PING_PONG_STRENGTH );
        sum += ( noise - 0.5 ) * 2.0 * amp;
        amp *= lerp( 1.0, noise, WEIGHTED_STRENGTH );
        x *= LACUNARITY;
        y *= LACUNARITY;
        amp *= GAIN;
    }
    return sum * 0.5 + 0.5;
}


/// two to one random function
float hash(vec2 uv)
{
    return fract(sin(dot(uv, vec2(154.45, 64.548))) * 124134.54)  ;
}

out vec4 fragColor;
in vec4 position;

void main()
{
    iTime = time;
    iResolution = vec3(resolution, 0.0);

    vec2 uv = (2.*gl_FragCoord.xy - iResolution.xy) / iResolution.y;
//
    vec3 colorM = vec3(0.,0.,0.);
    colorM = mix(night_top_color, night_bottom_color, sin((uv.y+1.7)*PI/4.));


    float n = hash(uv);
    float n2 = hash(uv + vec2(0.1, 0.1));
    float stars = pow(n, 250.);
    vec3 night = vec3(uv.y * .7 + .7) * vec3(stars) * (0.9 + ping_pong(iTime * n2 * 2.)) + colorM;

// Clouds UV movement direction
    float _clouds_speed = iTime * clouds_speed * 0.01;
    float _sin_x = sin( clouds_direction * PI * 2.0 );
    float _cos_y = cos( clouds_direction * PI * 2.0 );
    // I using 3 levels of clouds. Top is the lightes and botom the darkest.
    // The speed of movement (and direction a little) is different for the illusion of the changing shape of the clouds.
    vec2 _clouds_movement = vec2( _sin_x, _cos_y ) * _clouds_speed;
    float _noise_top = gen_fractal_ping_pong( ( uv + _clouds_movement ) * clouds_scale, 0, 0.5 );
    _clouds_movement = vec2( _sin_x * 0.97, _cos_y * 1.07 ) * _clouds_speed * 0.89;
    float _noise_middle = gen_fractal_ping_pong( ( uv + _clouds_movement ) * clouds_scale, 1, 0.75 );
    _clouds_movement = vec2( _sin_x * 1.01, _cos_y * 0.89 ) * _clouds_speed * 0.79;
    float _noise_bottom = gen_fractal_ping_pong( ( uv + _clouds_movement ) * clouds_scale, 2, 1.0 );
    // Smoothstep with the addition of a noise value from a lower level gives a nice, deep result
    _noise_bottom = smoothstep( clouds_cutoff, clouds_cutoff + clouds_fuzziness, _noise_bottom );
    _noise_middle = smoothstep( clouds_cutoff, clouds_cutoff + clouds_fuzziness, _noise_middle + _noise_bottom * 0.2 ) * 1.1;
    _noise_top = smoothstep( clouds_cutoff, clouds_cutoff + clouds_fuzziness, _noise_top + _noise_middle * 0.4 ) * 1.2;
    float _clouds_amount = clamp( _noise_top + _noise_middle + _noise_bottom, 0.0, 1.0 );
    // Fading clouds near the horizon
    float _eyedir_y = 0.1;
    _clouds_amount *= clamp( abs( _eyedir_y ) / clouds_blur, 0.0, 1.0 );

    vec3 _clouds_color = mix( vec3( 0.0 ), clouds_top_color, _noise_top );
    _clouds_color = mix( _clouds_color, clouds_middle_color, _noise_middle );
    _clouds_color = mix( _clouds_color, clouds_bottom_color, _noise_bottom );
    // The edge color gives a nice smooth edge, you can try turning this off if you need sharper edges
    _clouds_color = mix( clouds_edge_color, _clouds_color, _noise_top );
    // The sun passing through the clouds effect
    // _clouds_color = mix( _clouds_color, clamp( sun_color, 0.0, 1.0 ), pow( 1.0 - clamp( _sun_distance, 0.0, 1.0 ), 5 ));
    // Color combined with sunset condition
    // _clouds_color = mix( _clouds_color, sunset_bottom_color, _sunset_amount * 0.75 );
    // Color depending on the "progress" of the night.
    float _night_amount = 0.7;
    vec3 _sky_night_color = mix( night_bottom_color, night_top_color, _night_amount );
    _clouds_color = mix( _clouds_color, _sky_night_color, clamp( _night_amount, 0.0, 0.98 ));
    _clouds_color = mix( _clouds_color, vec3( 0.0 ), clouds_weight * 0.9 );

    fragColor = vec4(mix(night,_clouds_color, _clouds_amount), 1.0);
}

