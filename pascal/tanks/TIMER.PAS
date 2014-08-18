{
 timer unit
 Landon W. Rabern, 1996
}
unit timer;
interface
uses dos;
var
   shour,smin,ssec,shsec : word;
   nhour,nmin,nsec,nhsec : word;
   hour,min,sec,hsec : longint;

procedure starttimer;
procedure checktimer;
procedure wait(hs:word);

implementation

procedure starttimer;
begin
gettime(shour,smin,ssec,shsec);
end;

procedure checktimer;
begin
gettime(nhour,nmin,nsec,nhsec);
hour := longint(nhour) - longint(shour);
min := longint(nmin) - longint(smin);
sec := longint(nsec) - longint(ssec);
hsec := longint(nhsec) - longint(shsec);
if hsec<0 then
  begin
    inc(hsec,100);
    dec(sec);
  end;
if sec<0 then
  begin
    inc(sec,60);
    dec(min);
  end;
if min<0 then
  begin
    inc(min,60);
    dec(hour);
  end;
end;
procedure wait(hs:word);
begin
  starttimer;
  while hsec<hs do
    checktimer;
end;
end.
