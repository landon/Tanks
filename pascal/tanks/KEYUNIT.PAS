{
 keyboard unit
 can use multiple keys at once
 Landon W. Rabern, 1997
}
unit keyunit;

interface

uses dos;

var
   prevint: procedure;
   keys:array[1..128] of byte;
   i:byte;
   rawkey:word;
procedure onkeys;
procedure offkeys;

implementation

{$F+}
procedure check; interrupt;
begin
     asm
        sti
        in al,60h
        xor ah,ah
        mov rawkey,ax
        in al,61h
        or al,82h
        out 61h,al
        and al,7fh
        out 61h,al
        mov al,20h
        out 20h,al
     end;
     if rawkey<=128 then
        keys[rawkey]:=1
     else
         keys[rawkey-128]:=0;
end;
{$F-}
procedure onkeys;
begin
     fillchar(keys,128,0);
     getintvec($09,@prevint);
     setintvec($09,@check);
end;
procedure offkeys;
begin
     setintvec($09,@prevint);
end;

begin
end.
