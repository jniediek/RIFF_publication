clear all

disp('Did you Change the Mixer to Preset 5 ?')

%load LigetiIIEx1 % ligeti #2
load LigetiIIEx1       % ligeti #1

%ID = 6;
%playObject = audioplayer(Ligeti2, Fs,16,ID);
%play(playObject,Fs)

card1=pawavplay(Ligeti2(:,[2 1]),44100,0,[1 3]);
PlayWav(card1);

C=1;

while C==1
    C = CheckWav(card1);
    if C==0
        DeleteWav(card1)
        CloseAllWav
    end
end