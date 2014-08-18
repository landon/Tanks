{
 Tankwars - PC
 Landon W. Rabern, 1999
 Uses graphics mode 13h and .vga files for pictures
}

const
  maxb=3;
  btime=450;
type
  Tcell=record
    tp:byte;
    x,y:integer;
  end;
  Tmap=array[1..40,1..25] of Tcell;
  Pmap=^Tmap;
  Tbullet=record
    l:integer;
    x,y,dx,dy:double;
  end;
  tank=object
    xc,yc,speed,bia:integer;
    alive:boolean;
    gfx:Tvga;
    expl:array[1..3] of Tvga;
    angle:integer;
    bullets:array[1..maxb] of Tbullet;
    procedure put;
    procedure explode(op:tank);
    procedure checkbullets;
  end;
var
  red,blue:tank;
  sintab:array[0..15] of double;
  costab:array[0..15] of double;
  rdc,rmc,rbc,bdc,bmc,bbc,i,j,k,l,rs,bs:integer;
  map:Pmap;

procedure fpos;forward;

procedure maketabs;
var
  i:integer;
begin
  for i:=0 to 15 do
    begin
      sintab[i]:=sin(22.5*i*pi/180);
      costab[i]:=cos(22.5*i*pi/180);
    end;
end;
procedure loadmap(var m:Pmap);
var
  i,j:integer;
  f:text;
  DirInfo:SearchRec;
  fn:string;
  found:boolean;
begin
  found:=false;
  while not found do
  begin
    clrscr;
    FindFirst('*.map', Archive, DirInfo);
    while DosError = 0 do
    begin
      Writeln(DirInfo.Name);
      FindNext(DirInfo);
    end;
    writeln;
    write('Which map:  ');
    readln(fn);
    FindFirst(fn, Archive, DirInfo);
    if DosError=0 then
      found:=true
    else
      begin
        writeln('THAT FILE ISN''T THERE.');
        delay(1000);
      end;
  end;
  assign(f,fn);
  reset(f);
  for j:=1 to 25 do
    begin
      for i:=1 to 40 do
        begin
          read(f,m^[i,j].tp);
          m^[i,j].x:=pred(i)*8;
          m^[i,j].y:=pred(j)*8;
        end;
    end;
  close(f);
end;
function strng(v:longint):string;
var ts:string;
begin
     str(v,ts);
     strng := ts;
end;
procedure done;
begin
  settext;
  dispose(virscr);
  dispose(bkgscr);
  dispose(map);
  killvga(red.gfx);
  killvga(blue.gfx);
  offkeys;
  halt;
end;
{procedure putrot(xc,yc,angle:integer;gfx:Tvga);
var
  x,y:integer;
  c:byte;
begin
  for x:=-gfx.xs div 2 to gfx.xs div 2 do
    for y:=-gfx.ys div 2 to gfx.ys div 2 do
      begin
        c:=mem[seg(gfx.data^):ofs(gfx.data^)+x+gfx.xs div 2+(y+gfx.ys div 2)*gfx.xs];
        if c<>0 then
          putpixel(xc+round((x)*costab[angle]-(y)*sintab[angle]),
          yc+round((x)*sintab[angle]+(y)*costab[angle]),c);
      end;
  for x:=xc-gfx.xs to xc+gfx.xs do
    for y:=yc-gfx.ys to yc+gfx.ys do
      if (getpixel(x,y)=6) and (getpixel(x+1,y)=getpixel(x-1,y)) then
        putpixel(x,y,getpixel(x+1,y));
end;
procedure tank.put;
begin
  putrot(xc,yc,angle,gfx);
end;
procedure tank.explode(op:tank);
const
  seq:array[1..19] of byte=(1,2,3,2,1,2,3,2,1,2,3,2,1,2,3,2,1,2,3);
var
  i:integer;
begin
  for i:=1 to 19 do
    begin
      putrot(xc,yc,angle,expl[seq[i]]);
      if op.alive then op.put;
      red.checkbullets;
      blue.checkbullets;
      gwrite(10,10,strng(bs),1);
      gwrite(296,10,strng(rs),4);
      waitretrace;
      flip(virscr,vga);
      flip(bkgscr,virscr);
      waitretrace;waitretrace;waitretrace;waitretrace;waitretrace;
      waitretrace;waitretrace;
    end;
  if (bs=15) or (rs=15) then
    begin
      where:=vga;
      gwrite(124,96,'GAME OVER',7);
      offkeys;
      readkey;
      done;
    end;
end;}
procedure tank.checkbullets;
var
   i,a,k,l:integer;
begin
  for i:=1 to bia do
    inc(bullets[i].l);
  while (bullets[1].l>btime) and (bia>0) do
    begin
      move(bullets[2],bullets[1],sizeof(Tbullet)*(bia-1));
      dec(bia);
    end;
  i:=1;
  while i<=bia do
    begin
      bullets[i].x:=bullets[i].x+bullets[i].dx;
      bullets[i].y:=bullets[i].y+bullets[i].dy;
      if (bullets[i].y<4) or (bullets[i].y>194) then
           begin
             bullets[i].dy:=-bullets[i].dy;
           end;
      if (bullets[i].x>314) or (bullets[i].x<3) then
        begin
          bullets[i].dx:=-bullets[i].dx;
        end;
      for k:=1 to 40 do
        for l:=1 to 25 do
          if map^[k,l].tp=1 then
            begin
              if (bullets[i].x<map^[k,l].x+10) and (bullets[i].x>map^[k,l].x+4) and
                 (bullets[i].y<map^[k,l].y+8) and (bullets[i].y>=map^[k,l].y) then bullets[i].dx:=-bullets[i].dx
              else if (bullets[i].x>map^[k,l].x-2)  and (bullets[i].x<map^[k,l].x+4) and
                 (bullets[i].y<map^[k,l].y+8)  and (bullets[i].y>=map^[k,l].y) then bullets[i].dx:=-bullets[i].dx;
              if (bullets[i].y<map^[k,l].y+10) and (bullets[i].y>map^[k,l].y+4) and
                 (bullets[i].x<map^[k,l].x+8) and (bullets[i].x>=map^[k,l].x) then bullets[i].dy:=-bullets[i].dy
              else if (bullets[i].y>map^[k,l].y-2) and (bullets[i].y<map^[k,l].y+4) and
                 (bullets[i].x>=map^[k,l].x) and (bullets[i].x<map^[k,l].x+8) then bullets[i].dy:=-bullets[i].dy;
            end;
      case red.angle of
        14..15,0..2,6..10:begin
          if (bullets[i].x>=red.xc-6) and (bullets[i].x<=red.xc+6) and
             (bullets[i].y>=red.yc-10) and (bullets[i].y<=red.yc+10) then
             begin
               if red.alive then
                 begin
                   inc(bs);
                   red.alive:=false;
                   red.explode(blue);
                   fpos;
                 end;
             end;

        end;
        11..13,3..5:begin
          if (bullets[i].x>=red.xc-10) and (bullets[i].x<=red.xc+10) and
             (bullets[i].y>=red.yc-6) and (bullets[i].y<=red.yc+6) then
             begin
               if red.alive then
                 begin
                   inc(bs);
                   red.alive:=false;
                   red.explode(blue);
                   fpos;
                 end;
             end;
        end;
      end;
      case blue.angle of
        14..15,0..2,6..10:begin
          if (bullets[i].x>=blue.xc-6) and (bullets[i].x<=blue.xc+6) and
             (bullets[i].y>=blue.yc-10) and (bullets[i].y<=blue.yc+10) then
             begin
               if blue.alive then
                 begin
                   inc(rs);
                   blue.alive:=false;
                   blue.explode(red);
                   fpos;
                 end;
             end;

        end;
        11..13,3..5:begin
          if (bullets[i].x>=blue.xc-10) and (bullets[i].x<=blue.xc+10) and
             (bullets[i].y>=blue.yc-6) and (bullets[i].y<=blue.yc+6) then
             begin
               if blue.alive then
                 begin
                   inc(rs);
                   blue.alive:=false;
                   blue.explode(red);
                   fpos;
                 end;
             end;
        end;
      end;
      inc(i);
    end;
  for i:=1 to bia do
    begin
      putpixel(round(bullets[i].x),round(bullets[i].y),7);
      putpixel(round(bullets[i].x+1),round(bullets[i].y),7);
      putpixel(round(bullets[i].x),round(bullets[i].y+1),7);
      putpixel(round(bullets[i].x+1),round(bullets[i].y+1),7);
    end;
end;

procedure checkkeys;
var
  a:integer;
procedure redm;
begin
  if keys[k_pad_8]=1 then
    begin
      inc(rdc);
      if rdc>15 then
        begin
          with red do
            begin
              if (angle>0) and (angle<8) then
                dec(angle)
              else if (angle<=15) and (angle>=8) then
                inc(angle);
              if angle>15 then angle:=0
              else if angle<0 then angle:=15;
            end;
          rdc:=0;
        end;
    end;
  if keys[k_pad_2]=1 then
    begin
      inc(rdc);
      if rdc>15 then
        begin
          with red do
            begin
              if (angle>=0) and (angle<8) then
                inc(angle)
              else if (angle<=15) and (angle>8) then
                dec(angle);
              if angle>15 then angle:=0
              else if angle<0 then angle:=15;
            end;
          rdc:=0;
        end;
    end;
  if keys[k_pad_4]=1 then
    begin
      inc(rdc);
      if rdc>15 then
        begin
          with red do
            begin
              if (angle<12) and (angle>=4) then
                inc(angle)
              else if ((angle>12) and (angle<=15)) or ((angle>=0) and (angle<4)) then
                dec(angle);
              if angle>15 then angle:=0
              else if angle<0 then angle:=15;
            end;
          rdc:=0;
        end;
    end;
  if keys[k_pad_6]=1 then
    begin
      inc(rdc);
      if rdc>15 then
        begin
          with red do
            begin
              if (angle<12) and (angle>4) then
                dec(angle)
              else if ((angle>=12) and (angle<=15)) or ((angle>=0) and (angle<4)) then
                inc(angle);
              if angle>15 then angle:=0
              else if angle<0 then angle:=15;
            end;
          rdc:=0;
        end;
    end;
  if keys[k_apostrophe]=1 then
    begin
      inc(rmc);
      if rmc>2 then
        begin
          with red do
            begin
              a:=angle+4;
              if a>15 then a:=a-16;
              dec(xc,round(speed*costab[a]));
              dec(yc,round(speed*sintab[a]));
            end;
          rmc:=0;
        end;
    end;
  case red.angle of
    0:begin
      if red.yc<17 then red.yc:=17;
    end;
    1:begin
      if red.yc<16 then red.yc:=16;
      if red.xc>305 then red.xc:=305;
    end;
    2:begin
      if red.yc<14 then red.yc:=14;
      if red.xc>304 then red.xc:=304;
    end;
    3:begin
      if red.yc<13 then red.yc:=13;
      if red.xc>302 then red.xc:=302;
    end;
    4:begin
      if red.xc>301 then red.xc:=301;
    end;
    5:begin
      if red.yc>185 then red.yc:=185;
      if red.xc>302 then red.xc:=302;
    end;
    6:begin
      if red.yc>184 then red.yc:=184;
      if red.xc>304 then red.xc:=304;
    end;
    7:begin
      if red.yc>181 then red.yc:=181;
      if red.xc>305 then red.xc:=305;
    end;
    8:begin
      if red.yc>181 then red.yc:=181;
    end;
    9:begin
      if red.yc>181 then red.yc:=181;
      if red.xc<13 then red.xc:=13;
    end;
    10:begin
      if red.yc>184 then red.yc:=184;
      if red.xc<14 then red.xc:=14;
    end;
    11:begin
      if red.yc>185 then red.yc:=185;
      if red.xc<16 then red.xc:=16;
    end;
    12:begin
      if red.xc<17 then red.xc:=17;
    end;
    13:begin
      if red.yc<13 then red.yc:=13;
      if red.xc<16 then red.xc:=16;
    end;
    14:begin
      if red.yc<14 then red.yc:=14;
      if red.xc<14 then red.xc:=14;
    end;
    15:begin
      if red.yc<16 then red.yc:=16;
      if red.xc<13 then red.xc:=13;
    end;
  end;

  for k:=1 to 40 do
    for l:=1 to 25 do
      if map^[k,l].tp=1 then
        case red.angle of
          0:begin
            if (red.yc-10<map^[k,l].y+11) and (red.yc>map^[k,l].y+4) and
               (((red.xc-6<=map^[k,l].x+8) and (red.xc-6>=map^[k,l].x)) or
               ((red.xc+6>=map^[k,l].x) and (red.xc+6<=map^[k,l].x+8))  or
               ((red.xc>=map^[k,l].x) and (red.xc<=map^[k,l].x+8))) then red.yc:=map^[k,l].y+21;
          end;
          1:begin
            if (red.yc-10<map^[k,l].y+11) and (red.yc>map^[k,l].y+4) and
               (((red.xc-6<=map^[k,l].x+8) and (red.xc-6>=map^[k,l].x)) or
               ((red.xc+6>=map^[k,l].x) and (red.xc+6<=map^[k,l].x+8))  or
               ((red.xc>=map^[k,l].x) and (red.xc<=map^[k,l].x+8))) then red.yc:=map^[k,l].y+21;
            if (red.xc+10>map^[k,l].x-2) and (red.xc+10<map^[k,l].x+4) and
               (((red.yc-6<=map^[k,l].y+8) and (red.yc-6>=map^[k,l].y)) or
               ((red.yc+6>=map^[k,l].y) and (red.yc+6<=map^[k,l].y+8))  or
               ((red.yc>=map^[k,l].y) and (red.yc<=map^[k,l].y+8))) then red.xc:=map^[k,l].x-12;
          end;
          2:begin
            if (red.yc-10<map^[k,l].y+10) and (red.yc>map^[k,l].y+4) and
               (((red.xc-6<=map^[k,l].x+8) and (red.xc-6>=map^[k,l].x)) or
               ((red.xc+6>=map^[k,l].x) and (red.xc+6<=map^[k,l].x+8))  or
               ((red.xc>=map^[k,l].x) and (red.xc<=map^[k,l].x+8))) then red.yc:=map^[k,l].y+20;
            if (red.xc+10>map^[k,l].x-2) and (red.xc+10<map^[k,l].x+4) and
               (((red.yc-6<=map^[k,l].y+8) and (red.yc-6>=map^[k,l].y)) or
               ((red.yc+6>=map^[k,l].y) and (red.yc+6<=map^[k,l].y+8))  or
               ((red.yc>=map^[k,l].y) and (red.yc<=map^[k,l].y+8))) then red.xc:=map^[k,l].x-12;
          end;
          3:begin
            if (red.yc-10<map^[k,l].y+10) and (red.yc>map^[k,l].y+4) and
               (((red.xc-6<=map^[k,l].x+8) and (red.xc-6>=map^[k,l].x)) or
               ((red.xc+6>=map^[k,l].x) and (red.xc+6<=map^[k,l].x+8))  or
               ((red.xc>=map^[k,l].x) and (red.xc<=map^[k,l].x+8))) then red.yc:=map^[k,l].y+20;
            if (red.xc+10>map^[k,l].x-3) and (red.xc+10<map^[k,l].x+4) and
               (((red.yc-6<=map^[k,l].y+8) and (red.yc-6>=map^[k,l].y)) or
               ((red.yc+6>=map^[k,l].y) and (red.yc+6<=map^[k,l].y+8))  or
               ((red.yc>=map^[k,l].y) and (red.yc<=map^[k,l].y+8))) then red.xc:=map^[k,l].x-13;
          end;
          4:begin
            if (red.xc+10>map^[k,l].x-3) and (red.xc+10<map^[k,l].x+4) and
               (((red.yc-6<=map^[k,l].y+8) and (red.yc-6>=map^[k,l].y)) or
               ((red.yc+6>=map^[k,l].y) and (red.yc+6<=map^[k,l].y+8))  or
               ((red.yc>=map^[k,l].y) and (red.yc<=map^[k,l].y+8))) then red.xc:=map^[k,l].x-13;
          end;
          5:begin
            if (red.xc+10>map^[k,l].x-3) and (red.xc+10<map^[k,l].x+4) and
               (((red.yc-6<=map^[k,l].y+8) and (red.yc-6>=map^[k,l].y)) or
               ((red.yc+6>=map^[k,l].y) and (red.yc+6<=map^[k,l].y+8))  or
               ((red.yc>=map^[k,l].y) and (red.yc<=map^[k,l].y+8))) then red.xc:=map^[k,l].x-13;
            if (red.yc+10>map^[k,l].y-2) and (red.yc+10<map^[k,l].y+4) and
               (((red.xc-6<=map^[k,l].x+8) and (red.xc-6>=map^[k,l].x)) or
               ((red.xc+6>=map^[k,l].x) and (red.xc+6<=map^[k,l].x+8))  or
               ((red.xc>=map^[k,l].x) and (red.xc<=map^[k,l].x+8))) then red.yc:=map^[k,l].y-12;
          end;
          6:begin
            if (red.xc+10>map^[k,l].x-2) and (red.xc+10<map^[k,l].x+4) and
               (((red.yc-6<=map^[k,l].y+8) and (red.yc-6>=map^[k,l].y)) or
               ((red.yc+6>=map^[k,l].y) and (red.yc+6<=map^[k,l].y+8))  or
               ((red.yc>=map^[k,l].y) and (red.yc<=map^[k,l].y+8))) then red.xc:=map^[k,l].x-12;
            if (red.yc+10>map^[k,l].y-2) and (red.yc+10<map^[k,l].y+4) and
               (((red.xc-6<=map^[k,l].x+8) and (red.xc-6>=map^[k,l].x)) or
               ((red.xc+6>=map^[k,l].x) and (red.xc+6<=map^[k,l].x+8))  or
               ((red.xc>=map^[k,l].x) and (red.xc<=map^[k,l].x+8))) then red.yc:=map^[k,l].y-12;
          end;
          7:begin
            if (red.xc+10>map^[k,l].x-2) and (red.xc+10<map^[k,l].x+4) and
               (((red.yc-6<=map^[k,l].y+8) and (red.yc-6>=map^[k,l].y)) or
               ((red.yc+6>=map^[k,l].y) and (red.yc+6<=map^[k,l].y+8))  or
               ((red.yc>=map^[k,l].y) and (red.yc<=map^[k,l].y+8))) then red.xc:=map^[k,l].x-12;
            if (red.yc+10>map^[k,l].y-3) and (red.yc+10<map^[k,l].y+4) and
               (((red.xc-6<=map^[k,l].x+8) and (red.xc-6>=map^[k,l].x)) or
               ((red.xc+6>=map^[k,l].x) and (red.xc+6<=map^[k,l].x+8))  or
               ((red.xc>=map^[k,l].x) and (red.xc<=map^[k,l].x+8))) then red.yc:=map^[k,l].y-13;
          end;
          8:begin
            if (red.yc+10>map^[k,l].y-3) and (red.yc+10<map^[k,l].y+4) and
               (((red.xc-6<=map^[k,l].x+8) and (red.xc-6>=map^[k,l].x)) or
               ((red.xc+6>=map^[k,l].x) and (red.xc+6<=map^[k,l].x+8))  or
               ((red.xc>=map^[k,l].x) and (red.xc<=map^[k,l].x+8))) then red.yc:=map^[k,l].y-13;
          end;
          9:begin
            if (red.xc-10<=map^[k,l].x+10) and (red.xc-10>=map^[k,l].x+4) and
               (((red.yc-6<=map^[k,l].y+8) and (red.yc-6>=map^[k,l].y)) or
               ((red.yc+6>=map^[k,l].y) and (red.yc+6<=map^[k,l].y+8))  or
               ((red.yc>=map^[k,l].y) and (red.yc<=map^[k,l].y+8))) then red.xc:=map^[k,l].x+20;
            if (red.yc+10>map^[k,l].y-3) and (red.yc+10<map^[k,l].y+4) and
               (((red.xc-6<=map^[k,l].x+8) and (red.xc-6>=map^[k,l].x)) or
               ((red.xc+6>=map^[k,l].x) and (red.xc+6<=map^[k,l].x+8))  or
               ((red.xc>=map^[k,l].x) and (red.xc<=map^[k,l].x+8))) then red.yc:=map^[k,l].y-13;
          end;
          10:begin
            if (red.xc-10<=map^[k,l].x+10) and (red.xc-10>=map^[k,l].x+4) and
               (((red.yc-6<=map^[k,l].y+8) and (red.yc-6>=map^[k,l].y)) or
               ((red.yc+6>=map^[k,l].y) and (red.yc+6<=map^[k,l].y+8))  or
               ((red.yc>=map^[k,l].y) and (red.yc<=map^[k,l].y+8))) then red.xc:=map^[k,l].x+20;
            if (red.yc+10>map^[k,l].y-2) and (red.yc+10<map^[k,l].y+4) and
               (((red.xc-6<=map^[k,l].x+8) and (red.xc-6>=map^[k,l].x)) or
               ((red.xc+6>=map^[k,l].x) and (red.xc+6<=map^[k,l].x+8))  or
               ((red.xc>=map^[k,l].x) and (red.xc<=map^[k,l].x+8))) then red.yc:=map^[k,l].y-12;
          end;
          11:begin
            if (red.xc-10<=map^[k,l].x+11) and (red.xc-10>=map^[k,l].x+4) and
               (((red.yc-6<=map^[k,l].y+8) and (red.yc-6>=map^[k,l].y)) or
               ((red.yc+6>=map^[k,l].y) and (red.yc+6<=map^[k,l].y+8))  or
               ((red.yc>=map^[k,l].y) and (red.yc<=map^[k,l].y+8))) then red.xc:=map^[k,l].x+21;
            if (red.yc+10>map^[k,l].y-2) and (red.yc+10<map^[k,l].y+4) and
               (((red.xc-6<=map^[k,l].x+8) and (red.xc-6>=map^[k,l].x)) or
               ((red.xc+6>=map^[k,l].x) and (red.xc+6<=map^[k,l].x+8))  or
               ((red.xc>=map^[k,l].x) and (red.xc<=map^[k,l].x+8))) then red.yc:=map^[k,l].y-12;
          end;
          12:begin
            if (red.xc-10<=map^[k,l].x+11) and (red.xc-10>=map^[k,l].x+4) and
               (((red.yc-6<=map^[k,l].y+8) and (red.yc-6>=map^[k,l].y)) or
               ((red.yc+6>=map^[k,l].y) and (red.yc+6<=map^[k,l].y+8))  or
               ((red.yc>=map^[k,l].y) and (red.yc<=map^[k,l].y+8))) then red.xc:=map^[k,l].x+21;
          end;
          13:begin
            if (red.xc-10<=map^[k,l].x+11) and (red.xc-10>=map^[k,l].x+4) and
               (((red.yc-6<=map^[k,l].y+8) and (red.yc-6>=map^[k,l].y)) or
               ((red.yc+6>=map^[k,l].y) and (red.yc+6<=map^[k,l].y+8))  or
               ((red.yc>=map^[k,l].y) and (red.yc<=map^[k,l].y+8))) then red.xc:=map^[k,l].x+21;
            if (red.yc-10<map^[k,l].y+10) and (red.yc>map^[k,l].y+4) and
               (((red.xc-6<=map^[k,l].x+8) and (red.xc-6>=map^[k,l].x)) or
               ((red.xc+6>=map^[k,l].x) and (red.xc+6<=map^[k,l].x+8))  or
               ((red.xc>=map^[k,l].x) and (red.xc<=map^[k,l].x+8))) then red.yc:=map^[k,l].y+20;
          end;
          14:begin
            if (red.xc-10<=map^[k,l].x+10) and (red.xc-10>=map^[k,l].x+4) and
               (((red.yc-6<=map^[k,l].y+8) and (red.yc-6>=map^[k,l].y)) or
               ((red.yc+6>=map^[k,l].y) and (red.yc+6<=map^[k,l].y+8))  or
               ((red.yc>=map^[k,l].y) and (red.yc<=map^[k,l].y+8))) then red.xc:=map^[k,l].x+20;
            if (red.yc-10<map^[k,l].y+10) and (red.yc>map^[k,l].y+4) and
               (((red.xc-6<=map^[k,l].x+8) and (red.xc-6>=map^[k,l].x)) or
               ((red.xc+6>=map^[k,l].x) and (red.xc+6<=map^[k,l].x+8))  or
               ((red.xc>=map^[k,l].x) and (red.xc<=map^[k,l].x+8))) then red.yc:=map^[k,l].y+20;
          end;
          15:begin
            if (red.xc-10<=map^[k,l].x+10) and (red.xc-10>=map^[k,l].x+4) and
               (((red.yc-6<=map^[k,l].y+8) and (red.yc-6>=map^[k,l].y)) or
               ((red.yc+6>=map^[k,l].y) and (red.yc+6<=map^[k,l].y+8))  or
               ((red.yc>=map^[k,l].y) and (red.yc<=map^[k,l].y+8))) then red.xc:=map^[k,l].x+20;
            if (red.yc-10<map^[k,l].y+11) and (red.yc>map^[k,l].y+4) and
               (((red.xc-6<=map^[k,l].x+8) and (red.xc-6>=map^[k,l].x)) or
               ((red.xc+6>=map^[k,l].x) and (red.xc+6<=map^[k,l].x+8))  or
               ((red.xc>=map^[k,l].x) and (red.xc<=map^[k,l].x+8))) then red.yc:=map^[k,l].y+21;
          end;
        end;
  if keys[k_cr]=1 then
    begin
      inc(rbc);
      if rbc>6 then
        begin
          with red do
            begin
              if bia<maxb then
                begin
                  inc(bia);
                  bullets[bia].l:=0;
                  a:=angle+4;
                  if a>15 then a:=a-16;
                  bullets[bia].x:=xc-11*costab[a];
                  bullets[bia].y:=yc-11*sintab[a];
                  bullets[bia].dx:=-1.2*costab[a];
                  bullets[bia].dy:=-1.2*sintab[a];
                end;
            end;
          rbc:=0;
        end;

    end;
end;
procedure bluem;
begin
  if keys[k_e]=1 then
    begin
      inc(bdc);
      if bdc>15 then
        begin
          with blue do
            begin
              if (angle>0) and (angle<8) then
                dec(angle)
              else if (angle<=15) and (angle>=8) then
                inc(angle);
              if angle>15 then angle:=0
              else if angle<0 then angle:=15;
            end;
          bdc:=0;
        end;
    end;
  if keys[k_d]=1 then
    begin
      inc(bdc);
      if bdc>15 then
        begin
          with blue do
            begin
              if (angle>=0) and (angle<8) then
                inc(angle)
              else if (angle<=15) and (angle>8) then
                dec(angle);
              if angle>15 then angle:=0
              else if angle<0 then angle:=15;
            end;
          bdc:=0;
        end;
    end;
  if keys[k_s]=1 then
    begin
      inc(bdc);
      if bdc>15 then
        begin
          with blue do
            begin
              if (angle<12) and (angle>=4) then
                inc(angle)
              else if ((angle>12) and (angle<=15)) or ((angle>=0) and (angle<4)) then
                dec(angle);
              if angle>15 then angle:=0
              else if angle<0 then angle:=15;
            end;
          bdc:=0;
        end;
    end;
  if keys[k_f]=1 then
    begin
      inc(bdc);
      if bdc>15 then
        begin
          with blue do
            begin
              if (angle<12) and (angle>4) then
                dec(angle)
              else if ((angle>=12) and (angle<=15)) or ((angle>=0) and (angle<4)) then
                inc(angle);
              if angle>15 then angle:=0
              else if angle<0 then angle:=15;
            end;
          bdc:=0;
        end;
    end;
  if keys[k_accent]=1 then
    begin
      inc(bmc);
      if bmc>2 then
        begin
          with blue do
            begin
              a:=angle+4;
              if a>15 then a:=a-16;
              dec(xc,round(speed*costab[a]));
              dec(yc,round(speed*sintab[a]));
            end;
          bmc:=0;
        end;
    end;
  case blue.angle of
    0:begin
      if blue.yc<17 then blue.yc:=17;
    end;
    1:begin
      if blue.yc<16 then blue.yc:=16;
      if blue.xc>305 then blue.xc:=305;
    end;
    2:begin
      if blue.yc<14 then blue.yc:=14;
      if blue.xc>304 then blue.xc:=304;
    end;
    3:begin
      if blue.yc<13 then blue.yc:=13;
      if blue.xc>302 then blue.xc:=302;
    end;
    4:begin
      if blue.xc>301 then blue.xc:=301;
    end;
    5:begin
      if blue.yc>185 then blue.yc:=185;
      if blue.xc>302 then blue.xc:=302;
    end;
    6:begin
      if blue.yc>184 then blue.yc:=184;
      if blue.xc>304 then blue.xc:=304;
    end;
    7:begin
      if blue.yc>182 then blue.yc:=182;
      if blue.xc>305 then blue.xc:=305;
    end;
    8:begin
      if blue.yc>181 then blue.yc:=181;
    end;
    9:begin
      if blue.yc>182 then blue.yc:=182;
      if blue.xc<13 then blue.xc:=13;
    end;
    10:begin
      if blue.yc>184 then blue.yc:=184;
      if blue.xc<14 then blue.xc:=14;
    end;
    11:begin
      if blue.yc>185 then blue.yc:=185;
      if blue.xc<16 then blue.xc:=16;
    end;
    12:begin
      if blue.xc<17 then blue.xc:=17;
    end;
    13:begin
      if blue.yc<13 then blue.yc:=13;
      if blue.xc<16 then blue.xc:=16;
    end;
    14:begin
      if blue.yc<14 then blue.yc:=14;
      if blue.xc<14 then blue.xc:=14;
    end;
    15:begin
      if blue.yc<16 then blue.yc:=16;
      if blue.xc<13 then blue.xc:=13;
    end;
  end;
  for k:=1 to 40 do
    for l:=1 to 25 do
      if map^[k,l].tp=1 then
        case blue.angle of
          0:begin
            if (blue.yc-10<map^[k,l].y+11) and (blue.yc>map^[k,l].y+4) and
               (((blue.xc-6<=map^[k,l].x+8) and (blue.xc-6>=map^[k,l].x)) or
               ((blue.xc+6>=map^[k,l].x) and (blue.xc+6<=map^[k,l].x+8))  or
               ((blue.xc>=map^[k,l].x) and (blue.xc<=map^[k,l].x+8))) then blue.yc:=map^[k,l].y+21;
          end;
          1:begin
            if (blue.yc-10<map^[k,l].y+11) and (blue.yc>map^[k,l].y+4) and
               (((blue.xc-6<=map^[k,l].x+8) and (blue.xc-6>=map^[k,l].x)) or
               ((blue.xc+6>=map^[k,l].x) and (blue.xc+6<=map^[k,l].x+8))  or
               ((blue.xc>=map^[k,l].x) and (blue.xc<=map^[k,l].x+8))) then blue.yc:=map^[k,l].y+21;
            if (blue.xc+10>map^[k,l].x-2) and (blue.xc+10<map^[k,l].x+4) and
               (((blue.yc-6<=map^[k,l].y+8) and (blue.yc-6>=map^[k,l].y)) or
               ((blue.yc+6>=map^[k,l].y) and (blue.yc+6<=map^[k,l].y+8))  or
               ((blue.yc>=map^[k,l].y) and (blue.yc<=map^[k,l].y+8))) then blue.xc:=map^[k,l].x-12;
          end;
          2:begin
            if (blue.yc-10<map^[k,l].y+10) and (blue.yc>map^[k,l].y+4) and
               (((blue.xc-6<=map^[k,l].x+8) and (blue.xc-6>=map^[k,l].x)) or
               ((blue.xc+6>=map^[k,l].x) and (blue.xc+6<=map^[k,l].x+8))  or
               ((blue.xc>=map^[k,l].x) and (blue.xc<=map^[k,l].x+8))) then blue.yc:=map^[k,l].y+20;
            if (blue.xc+10>map^[k,l].x-2) and (blue.xc+10<map^[k,l].x+4) and
               (((blue.yc-6<=map^[k,l].y+8) and (blue.yc-6>=map^[k,l].y)) or
               ((blue.yc+6>=map^[k,l].y) and (blue.yc+6<=map^[k,l].y+8))  or
               ((blue.yc>=map^[k,l].y) and (blue.yc<=map^[k,l].y+8))) then blue.xc:=map^[k,l].x-12;
          end;
          3:begin
            if (blue.yc-10<map^[k,l].y+10) and (blue.yc>map^[k,l].y+4) and
               (((blue.xc-6<=map^[k,l].x+8) and (blue.xc-6>=map^[k,l].x)) or
               ((blue.xc+6>=map^[k,l].x) and (blue.xc+6<=map^[k,l].x+8))  or
               ((blue.xc>=map^[k,l].x) and (blue.xc<=map^[k,l].x+8))) then blue.yc:=map^[k,l].y+20;
            if (blue.xc+10>map^[k,l].x-3) and (blue.xc+10<map^[k,l].x+4) and
               (((blue.yc-6<=map^[k,l].y+8) and (blue.yc-6>=map^[k,l].y)) or
               ((blue.yc+6>=map^[k,l].y) and (blue.yc+6<=map^[k,l].y+8))  or
               ((blue.yc>=map^[k,l].y) and (blue.yc<=map^[k,l].y+8))) then blue.xc:=map^[k,l].x-13;
          end;
          4:begin
            if (blue.xc+10>map^[k,l].x-3) and (blue.xc+10<map^[k,l].x+4) and
               (((blue.yc-6<=map^[k,l].y+8) and (blue.yc-6>=map^[k,l].y)) or
               ((blue.yc+6>=map^[k,l].y) and (blue.yc+6<=map^[k,l].y+8))  or
               ((blue.yc>=map^[k,l].y) and (blue.yc<=map^[k,l].y+8))) then blue.xc:=map^[k,l].x-13;
          end;
          5:begin
            if (blue.xc+10>map^[k,l].x-3) and (blue.xc+10<map^[k,l].x+4) and
               (((blue.yc-6<=map^[k,l].y+8) and (blue.yc-6>=map^[k,l].y)) or
               ((blue.yc+6>=map^[k,l].y) and (blue.yc+6<=map^[k,l].y+8))  or
               ((blue.yc>=map^[k,l].y) and (blue.yc<=map^[k,l].y+8))) then blue.xc:=map^[k,l].x-13;
            if (blue.yc+10>map^[k,l].y-2) and (blue.yc+10<map^[k,l].y+4) and
               (((blue.xc-6<=map^[k,l].x+8) and (blue.xc-6>=map^[k,l].x)) or
               ((blue.xc+6>=map^[k,l].x) and (blue.xc+6<=map^[k,l].x+8))  or
               ((blue.xc>=map^[k,l].x) and (blue.xc<=map^[k,l].x+8))) then blue.yc:=map^[k,l].y-12;
          end;
          6:begin
            if (blue.xc+10>map^[k,l].x-2) and (blue.xc+10<map^[k,l].x+4) and
               (((blue.yc-6<=map^[k,l].y+8) and (blue.yc-6>=map^[k,l].y)) or
               ((blue.yc+6>=map^[k,l].y) and (blue.yc+6<=map^[k,l].y+8))  or
               ((blue.yc>=map^[k,l].y) and (blue.yc<=map^[k,l].y+8))) then blue.xc:=map^[k,l].x-12;
            if (blue.yc+10>map^[k,l].y-2) and (blue.yc+10<map^[k,l].y+4) and
               (((blue.xc-6<=map^[k,l].x+8) and (blue.xc-6>=map^[k,l].x)) or
               ((blue.xc+6>=map^[k,l].x) and (blue.xc+6<=map^[k,l].x+8))  or
               ((blue.xc>=map^[k,l].x) and (blue.xc<=map^[k,l].x+8))) then blue.yc:=map^[k,l].y-12;
          end;
          7:begin
            if (blue.xc+10>map^[k,l].x-2) and (blue.xc+10<map^[k,l].x+4) and
               (((blue.yc-6<=map^[k,l].y+8) and (blue.yc-6>=map^[k,l].y)) or
               ((blue.yc+6>=map^[k,l].y) and (blue.yc+6<=map^[k,l].y+8))  or
               ((blue.yc>=map^[k,l].y) and (blue.yc<=map^[k,l].y+8))) then blue.xc:=map^[k,l].x-12;
            if (blue.yc+10>map^[k,l].y-3) and (blue.yc+10<map^[k,l].y+4) and
               (((blue.xc-6<=map^[k,l].x+8) and (blue.xc-6>=map^[k,l].x)) or
               ((blue.xc+6>=map^[k,l].x) and (blue.xc+6<=map^[k,l].x+8))  or
               ((blue.xc>=map^[k,l].x) and (blue.xc<=map^[k,l].x+8))) then blue.yc:=map^[k,l].y-13;
          end;
          8:begin
            if (blue.yc+10>map^[k,l].y-3) and (blue.yc+10<map^[k,l].y+4) and
               (((blue.xc-6<=map^[k,l].x+8) and (blue.xc-6>=map^[k,l].x)) or
               ((blue.xc+6>=map^[k,l].x) and (blue.xc+6<=map^[k,l].x+8))  or
               ((blue.xc>=map^[k,l].x) and (blue.xc<=map^[k,l].x+8))) then blue.yc:=map^[k,l].y-13;
          end;
          9:begin
            if (blue.xc-10<=map^[k,l].x+10) and (blue.xc-10>=map^[k,l].x+4) and
               (((blue.yc-6<=map^[k,l].y+8) and (blue.yc-6>=map^[k,l].y)) or
               ((blue.yc+6>=map^[k,l].y) and (blue.yc+6<=map^[k,l].y+8))  or
               ((blue.yc>=map^[k,l].y) and (blue.yc<=map^[k,l].y+8))) then blue.xc:=map^[k,l].x+20;
            if (blue.yc+10>map^[k,l].y-3) and (blue.yc+10<map^[k,l].y+4) and
               (((blue.xc-6<=map^[k,l].x+8) and (blue.xc-6>=map^[k,l].x)) or
               ((blue.xc+6>=map^[k,l].x) and (blue.xc+6<=map^[k,l].x+8))  or
               ((blue.xc>=map^[k,l].x) and (blue.xc<=map^[k,l].x+8))) then blue.yc:=map^[k,l].y-13;
          end;
          10:begin
            if (blue.xc-10<=map^[k,l].x+10) and (blue.xc-10>=map^[k,l].x+4) and
               (((blue.yc-6<=map^[k,l].y+8) and (blue.yc-6>=map^[k,l].y)) or
               ((blue.yc+6>=map^[k,l].y) and (blue.yc+6<=map^[k,l].y+8))  or
               ((blue.yc>=map^[k,l].y) and (blue.yc<=map^[k,l].y+8))) then blue.xc:=map^[k,l].x+20;
            if (blue.yc+10>map^[k,l].y-2) and (blue.yc+10<map^[k,l].y+4) and
               (((blue.xc-6<=map^[k,l].x+8) and (blue.xc-6>=map^[k,l].x)) or
               ((blue.xc+6>=map^[k,l].x) and (blue.xc+6<=map^[k,l].x+8))  or
               ((blue.xc>=map^[k,l].x) and (blue.xc<=map^[k,l].x+8))) then blue.yc:=map^[k,l].y-12;
          end;
          11:begin
            if (blue.xc-10<=map^[k,l].x+11) and (blue.xc-10>=map^[k,l].x+4) and
               (((blue.yc-6<=map^[k,l].y+8) and (blue.yc-6>=map^[k,l].y)) or
               ((blue.yc+6>=map^[k,l].y) and (blue.yc+6<=map^[k,l].y+8))  or
               ((blue.yc>=map^[k,l].y) and (blue.yc<=map^[k,l].y+8))) then blue.xc:=map^[k,l].x+21;
            if (blue.yc+10>map^[k,l].y-2) and (blue.yc+10<map^[k,l].y+4) and
               (((blue.xc-6<=map^[k,l].x+8) and (blue.xc-6>=map^[k,l].x)) or
               ((blue.xc+6>=map^[k,l].x) and (blue.xc+6<=map^[k,l].x+8))  or
               ((blue.xc>=map^[k,l].x) and (blue.xc<=map^[k,l].x+8))) then blue.yc:=map^[k,l].y-12;
          end;
          12:begin
            if (blue.xc-10<=map^[k,l].x+11) and (blue.xc-10>=map^[k,l].x+4) and
               (((blue.yc-6<=map^[k,l].y+8) and (blue.yc-6>=map^[k,l].y)) or
               ((blue.yc+6>=map^[k,l].y) and (blue.yc+6<=map^[k,l].y+8))  or
               ((blue.yc>=map^[k,l].y) and (blue.yc<=map^[k,l].y+8))) then blue.xc:=map^[k,l].x+21;
          end;
          13:begin
            if (blue.xc-10<=map^[k,l].x+11) and (blue.xc-10>=map^[k,l].x+4) and
               (((blue.yc-6<=map^[k,l].y+8) and (blue.yc-6>=map^[k,l].y)) or
               ((blue.yc+6>=map^[k,l].y) and (blue.yc+6<=map^[k,l].y+8))  or
               ((blue.yc>=map^[k,l].y) and (blue.yc<=map^[k,l].y+8))) then blue.xc:=map^[k,l].x+21;
            if (blue.yc-10<map^[k,l].y+10) and (blue.yc>map^[k,l].y+4) and
               (((blue.xc-6<=map^[k,l].x+8) and (blue.xc-6>=map^[k,l].x)) or
               ((blue.xc+6>=map^[k,l].x) and (blue.xc+6<=map^[k,l].x+8))  or
               ((blue.xc>=map^[k,l].x) and (blue.xc<=map^[k,l].x+8))) then blue.yc:=map^[k,l].y+20;
          end;
          14:begin
            if (blue.xc-10<=map^[k,l].x+10) and (blue.xc-10>=map^[k,l].x+4) and
               (((blue.yc-6<=map^[k,l].y+8) and (blue.yc-6>=map^[k,l].y)) or
               ((blue.yc+6>=map^[k,l].y) and (blue.yc+6<=map^[k,l].y+8))  or
               ((blue.yc>=map^[k,l].y) and (blue.yc<=map^[k,l].y+8))) then blue.xc:=map^[k,l].x+20;
            if (blue.yc-10<map^[k,l].y+10) and (blue.yc>map^[k,l].y+4) and
               (((blue.xc-6<=map^[k,l].x+8) and (blue.xc-6>=map^[k,l].x)) or
               ((blue.xc+6>=map^[k,l].x) and (blue.xc+6<=map^[k,l].x+8))  or
               ((blue.xc>=map^[k,l].x) and (blue.xc<=map^[k,l].x+8))) then blue.yc:=map^[k,l].y+20;
          end;
          15:begin
            if (blue.xc-10<=map^[k,l].x+10) and (blue.xc-10>=map^[k,l].x+4) and
               (((blue.yc-6<=map^[k,l].y+8) and (blue.yc-6>=map^[k,l].y)) or
               ((blue.yc+6>=map^[k,l].y) and (blue.yc+6<=map^[k,l].y+8))  or
               ((blue.yc>=map^[k,l].y) and (blue.yc<=map^[k,l].y+8))) then blue.xc:=map^[k,l].x+20;
            if (blue.yc-10<map^[k,l].y+11) and (blue.yc>map^[k,l].y+4) and
               (((blue.xc-6<=map^[k,l].x+8) and (blue.xc-6>=map^[k,l].x)) or
               ((blue.xc+6>=map^[k,l].x) and (blue.xc+6<=map^[k,l].x+8))  or
               ((blue.xc>=map^[k,l].x) and (blue.xc<=map^[k,l].x+8))) then blue.yc:=map^[k,l].y+21;
          end;
        end;
  if keys[k_1]=1 then
    begin
      inc(bbc);
      if bbc>6 then
        begin
          with blue do
            begin
              if bia<maxb then
                begin
                  inc(bia);
                  bullets[bia].l:=0;
                  a:=angle+4;
                  if a>15 then a:=a-16;
                  bullets[bia].x:=xc-11*costab[a];
                  bullets[bia].y:=yc-11*sintab[a];
                  bullets[bia].dx:=-1.2*costab[a];
                  bullets[bia].dy:=-1.2*sintab[a];
                end;
            end;
          bbc:=0;
        end;
    end;
end;
begin
  redm;
  bluem;
  if keys[k_esc]=1 then done;
end;
procedure fpos;
begin
  red.alive:=true;
  blue.alive:=true;
  red.xc:=270;
  red.yc:=175;
  red.angle:=12;
  red.speed:=2;
  red.bia:=0;
  rbc:=0;
  rdc:=0;
  rmc:=0;
  blue.xc:=60;
  blue.yc:=20;
  blue.angle:=4;
  blue.speed:=2;
  blue.bia:=0;
  bbc:=0;
  bdc:=0;
  bmc:=0;
  where:=virscr;
  repeat
    checkkeys;
    red.checkbullets;
    blue.checkbullets;
    red.put;
    blue.put;
    waitretrace;
    flip(virscr,vga);
    flip(bkgscr,virscr);
  until false;
end;
begin
 { loadvga(red.gfx,'slug.vga');
   loadvga(red.gfx,'bdr.vga'); }
  loadvga(red.gfx,'t1.vga');
  loadvga(blue.gfx,'t2.vga');
  for i:=1 to 3 do
    loadvga(red.expl[i],'rf'+chr(i+48)+'.vga');
  for i:=1 to 3 do
    loadvga(blue.expl[i],'bf'+chr(i+48)+'.vga');
  new(virscr);
  new(bkgscr);
  new(map);
  loadmap(map);
  onkeys;
  maketabs;
  setmcga;
  where:=bkgscr;
  cls(6);
  for i:=0 to 319 do
    for j:=0 to 5 do
      putpixel(i,j,42);
  for i:=0 to 319 do
    for j:=193 to 199 do
      putpixel(i,j,42);
  for i:=0 to 5 do
    for j:=0 to 199 do
      putpixel(i,j,42);
  for i:=313 to 319 do
    for j:=0 to 199 do
      putpixel(i,j,42);
  for j:=1 to 25 do
    for i:=1 to 40 do
      case map^[i,j].tp of
        1:begin
          for k:=1 to 8 do
            for l:=1 to 8 do
              putpixel(map^[i,j].x+k,map^[i,j].y+l,16);
        end;
      end;
  rs:=0;
  bs:=0;
  fpos;
end.
