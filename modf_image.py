from PIL import Image

in_f = Image.open("frog.png","r")

out_f = Image.new("RGBA",in_f.size)

w,h = in_f.size

for i in range(w):
    for j in range(h):
        a = 1 - sum(in_f.getpixel((i,j)))/3/255
        if a < 0.05:
            a = 0
        if a > 0.5:
            a = 1
        out_f.putpixel((i,j),(0,0,0,int(a*255)))

out_f.save("frog_alpha.png")