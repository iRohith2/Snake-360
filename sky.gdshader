shader_type sky;

uniform vec3 color : source_color = vec3(0, 0, 0);

void sky() {
	//if (AT_CUBEMAP_PASS) {
        // Sets the radiance cubemap to a nice shade of blue instead of doing
        // expensive sky calculations
        COLOR = color.rgb;
    //} else {
        // Do expensive sky calculations for background sky only
        //COLOR = get_sky_color(EYEDIR);
    //}
}
