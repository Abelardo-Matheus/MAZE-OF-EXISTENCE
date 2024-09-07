
function draw_text_outlined(x,y,cor,cor2,string){
var xx,yy;  
xx = x;  
yy = y;  
  
//Outline  
draw_set_color(cor);  
draw_text(xx+1, yy+1, string);  
draw_text(xx-1, yy-1, string);  
draw_text(xx,   yy+1, string);  
draw_text(xx+1,   yy, string);  
draw_text(xx,   yy-1, string);  
draw_text(xx-1,   yy, string);  
draw_text(xx-1, yy+1, string);  
draw_text(xx+1, yy-1, string);  
  
//Text  
draw_set_color(cor2);  
draw_text(xx, yy, string);  
}