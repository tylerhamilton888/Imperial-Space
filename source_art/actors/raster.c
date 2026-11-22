/* Orthographic depth buffer used only to bake the authored 2D character art. */
#include <math.h>
#include <stdint.h>
void triangles(const float *xyz, const uint8_t *colors, int count, int width, int height,
               uint8_t *pixels, float *depth) {
    for (int i = 0; i < count; ++i) {
        const float *p = xyz + 9*i;
        float dx1=p[3]-p[0], dx2=p[6]-p[0], dy1=p[4]-p[1], dy2=p[7]-p[1];
        float determinant = dx1*dy2 - dx2*dy1;
        if (fabsf(determinant) < 0.0001f) continue;
        int xmin=fmaxf(0, floorf(fminf(p[0],fminf(p[3],p[6]))));
        int xmax=fminf(width-1, ceilf(fmaxf(p[0],fmaxf(p[3],p[6]))));
        int ymin=fmaxf(0, floorf(fminf(p[1],fminf(p[4],p[7]))));
        int ymax=fminf(height-1, ceilf(fmaxf(p[1],fmaxf(p[4],p[7]))));
        for (int y=ymin; y<=ymax; ++y) for (int x=xmin; x<=xmax; ++x) {
            float xx=x+0.5f-p[0], yy=y+0.5f-p[1];
            float b=(xx*dy2-yy*dx2)/determinant, c=(yy*dx1-xx*dy1)/determinant;
            if (b < 0 || c < 0 || b+c > 1) continue;
            float z=p[2]+b*(p[5]-p[2])+c*(p[8]-p[2]);
            int px=y*width+x;
            if (z < depth[px]) continue;
            depth[px]=z;
            for(int k=0;k<3;++k) pixels[px*4+k]=colors[i*3+k];
            pixels[px*4+3]=255;
        }
    }
}
