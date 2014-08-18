{
 mode 13h graphics unit
 very fast assembler routines
 Landon W. Rabern, 1997
}
unit mcga;

interface

uses crt;

const
     vga=ptr($a000,0);

type
    virtptr=^virtual;
    virtual=array [1..64000] of byte;

var
   scr_ofs:array[0..199] of word;
   virscr,bkgscr,where:virtptr;

procedure setmcga;
procedure settext;
procedure cls(col:byte);
procedure pal(colorno:byte;r,g,b:byte);
procedure getpal(colorno:byte;var r,g,b:byte);
procedure putpixel(x,y:integer;col:byte);
procedure cputpixel(x,y:integer;col:byte);
function  getpixel(x,y:integer):byte;
procedure line(x1,y1,x2,y2:integer;color:byte);
procedure circle(oX,oy,rad:integer;col:byte);
procedure hline(x1,x2,y:integer;col:byte);
procedure drawpoly(x1,y1,x2,y2,x3,y3,x4,y4:integer;color:byte);
procedure flip(src,dst:pointer);
procedure blitchar(xc,yc:integer;c:char;col:byte);
procedure gwrite(x,y:integer;s:string;col:byte);
procedure waitretrace;

implementation

procedure setmcga;assembler;
asm
   mov        ax,013h
   int        10h
end;

procedure settext;assembler;
asm
   mov        ax,0003h
   int        10h
end;

procedure cls(col:byte);assembler;
asm
   mov     cx,32000
   les     di,where
   mov     al,col
   mov     ah,al
   rep     stosw
end;

procedure getpal(colorno:byte;var r,g,b:byte);
begin
   port[$3c7]:=colorno;
   r:=port[$3c9];
   g:=port[$3c9];
   b:=port[$3c9];
end;

procedure pal(colorno:byte;r,g,b:byte);
begin
   port[$3c8]:=colorno;
   port[$3c9]:=r;
   port[$3c9]:=g;
   port[$3c9]:=b;
end;

procedure putpixel(x,y:integer;col:byte);assembler;
asm
  mov  bx, y
  shl  bx, 1
  les  di, where
  mov  bx, word ptr [scr_ofs+bx]
  mov  cx, x
  add  bx, cx
  mov  al, col
  mov  byte ptr es:bx, al
end;

procedure cputpixel(x,y:integer;col:byte);
begin
     if (x<320) and (x>=0) and (y<200) and (y>=0) then
     asm
        mov  bx, y
        shl  bx, 1
        les  di,where
        mov  bx, word ptr [scr_ofs+bx]
        mov  cx, x
        add  bx, cx
        mov  al, col
        mov  byte ptr es:bx, al
     end;
end;

function getpixel(x,y:integer):byte;assembler;
asm
   les  di,where
   mov  bx,y
   shl  bx,1
   mov  di,word ptr [scr_ofs+bx]
   add  di,x
   mov  al,byte ptr es:di
end;

procedure line(x1,y1,x2,y2:integer;color:byte);
var i,deltax,deltay,numpixels,
    d,dinc1,dinc2,
    x,xinc1,xinc2,
    y,yinc1,yinc2 : integer;
begin
  deltax:=abs(x2-x1);
  deltay:=abs(y2-y1);
  xinc2:=1;
  yinc2:=1;
  numpixels:=1;
  dinc2:=(deltay-deltax) shl 1;
  if deltax>=deltay then
    begin
      inc(numpixels,deltax);
      dinc1:=deltay shl 1;
      d:=dinc1-deltax;
      xinc1:=1;
      yinc1:=0;
    end
  else
    begin
      inc(numpixels,deltay);
      dinc1:=deltax shl 1;
      d:=dinc1-deltay;
      dinc2:=-dinc2;
      xinc1:=0;
      yinc1:=1;
    end;
  if x1>x2 then
    begin
      xinc1:=-xinc1;
      xinc2:=-1;
    end;
  if y1>y2 then
    begin
      yinc1:=-yinc1;
      yinc2:=-1;
    end;
  x:=x1;
  y:=y1;
  for i:=1 to numpixels do
    begin
      cputpixel(x,y,color);
      if d<0 then
        begin
          inc(d,dinc1);
          inc(x,xinc1);
          inc(y,yinc1);
        end
      else
        begin
          inc(d,dinc2);
          inc(x,xinc2);
          inc(y,yinc2);
        end;
    end;
end;
procedure circle(ox,oy,rad:integer;col:byte);
var
   deg:real;
   x,y:integer;
begin
     deg:=0;
     repeat
           x:=round(rad*cos (deg));
           y:=round(rad*sin (deg));
           cputpixel (ox+x,oy+y,col);
           cputpixel (ox+x,oy-y,col);
           cputpixel (ox-x,oy+y,col);
           cputpixel (ox-x,oy-y,col);
           cputpixel (ox+y,oy+x,col);
           cputpixel (ox+y,oy-x,col);
           cputpixel (ox-y,oy+x,col);
           cputpixel (ox-y,oy-x,col);
           deg:=deg+0.007;
     until (deg>0.785);
end;

procedure hline2(x1,x2,y:integer;col:byte);
var
   f:integer;
   tx:integer;
begin
     if x1>x2 then begin
        tx:=x1;
        x1:=x2;
        x2:=tx;
     end;
     for f:=x1 to x2 do
         cputpixel(f,y,col);
end;
procedure hline(x1,x2,y:integer;col:byte);
label da;
var
   tx,l,off:integer;
begin
     if x1>x2 then begin
        tx:=x1;
        x1:=x2;
        x2:=tx;
     end;
     if x1<0 then x1:=0
     else if x1>319 then x1:=319;
     if x2>319 then x2:=319
     else if x2<0 then x2:=0;
     l:=x2-x1+1;
     off:=x1+scr_ofs[y];
     asm
        les di,where
        add di,off
        mov cx,l
        shr cx,1
        mov al,col
        mov ah,al
        rep stosw
        test l,1
        jz da
        stosb
       da:
     end;
end;

procedure drawpoly(x1,y1,x2,y2,x3,y3,x4,y4:integer;color:byte);
var
  x:integer;
  mny,mxy:integer;
  mnx,mxx,yc:integer;
  mul1,div1,
  mul2,div2,
  mul3,div3,
  mul4,div4:integer;

begin
  mny:=y1; mxy:=y1;
  if y2<mny then mny:=y2;
  if y2>mxy then mxy:=y2;
  if y3<mny then mny:=y3;
  if y3>mxy then mxy:=y3;    { choose the min y mny and max y mxy }
  if y4<mny then mny:=y4;
  if y4>mxy then mxy:=y4;

  if mny<0 then mny:=0;
  if mxy>199 then mxy:=199;
  if mny>199 then exit;
  if mxy<0 then exit;        { verticle range checking }

  mul1:=x1-x4; div1:=y1-y4;
  mul2:=x2-x1; div2:=y2-y1;
  mul3:=x3-x2; div3:=y3-y2;
  mul4:=x4-x3; div4:=y4-y3;  { constansts needed for intersection calc }

  for yc:=mny to mxy do
    begin
      mnx:=320;
      mxx:=-1;
      if (y4>=yc) or (y1>=yc) then
        if (y4<=yc) or (y1<=yc) then   { check that yc is between y1 and y4 }
          if not(y4=y1) then
            begin
              x:=(yc-y4)*mul1 div div1+x4; { point of intersection on x axis }
              if x<mnx then
                mnx:=x;
              if x>mxx then
                mxx:=x;       { set point as start or end of horiz line }
            end;
      if (y1>=yc) or (y2>=yc) then
        if (y1<=yc) or (y2<=yc) then   { check that yc is between y1 and y2 }
          if not(y1=y2) then
            begin
              x:=(yc-y1)*mul2 div div2+x1; { point of intersection on x axis }
              if x<mnx then
                mnx:=x;
              if x>mxx then
                mxx:=x;       { set point as start or end of horiz line }
            end;
      if (y2>=yc) or (y3>=yc) then
        if (y2<=yc) or (y3<=yc) then   { check that yc is between y2 and y3 }
          if not(y2=y3) then
            begin
              x:=(yc-y2)*mul3 div div3+x2; { point of intersection on x axis }
              if x<mnx then
                mnx:=x;
              if x>mxx then
                mxx:=x;       { set point as start or end of horiz line }
            end;
      if (y3>=yc) or (y4>=yc) then
        if (y3<=yc) or (y4<=yc) then   { check that yc is between y3 and y4 }
          if not(y3=y4) then
            begin
              x:=(yc-y3)*mul4 div div4+x3; { point of intersection on x axis }
              if x<mnx then
                mnx:=x;
              if x>mxx then
                mxx:=x;       { set point as start or end of horiz line }
            end;
      if mnx<0 then
        mnx:=0;
      if mxx>319 then
        mxx:=319;          { range checking on horizontal line }
      if mnx<=mxx then
        hline(mnx,mxx,yc,color);   { draw the horizontal line }
    end;
end;

procedure flip(src,dst:pointer); assembler;
asm
  push    ds
  les     di,dst
  lds     si,src
  mov     cx, 16000
  db      66h
  rep     movsw
  pop     ds
end;

procedure blitchar(xc,yc:integer;c:char;col:byte);
var
   j,off,x,y:integer;
   bmask:word;
begin
     j:=0;
     off:=(yc shl 8)+(yc shl 6) +xc;
     for y:=0 to 7 do begin
         bmask:=$80;
         for x:=0 to 7 do begin
             if (mem[$f000:$fa6e+ord(c) shl 3+j] and bmask)<>0 then
                mem[seg(where^):ofs(where^)+off+x]:=col;
             bmask:=bmask shr 1;
         end;
         inc(off,320);
         inc(j);
     end;
end;

procedure gwrite(x,y:integer;s:string;col:byte);
var
   i:word;
begin
     for i:=0 to length(s)-1 do
         blitchar(x+i shl 3,y,s[i+1],col);
end;

procedure waitretrace; assembler;
label
  l1, l2;
asm
    mov dx,3dah
l1:
    in al,dx
    and al,08h
    jnz l1
l2:
    in al,dx
    and al,08h
    jz  l2
end;

var i:byte;

begin
  for i:=0 to 199 do
    scr_ofs[i]:=i shl 6+i shl 8;
  where:=vga;
end.

