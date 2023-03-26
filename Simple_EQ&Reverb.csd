<Cabbage> bounds(0, 0, 0, 0)
form caption("Multi Effect") size(530, 550), guiMode("queue") pluginId("mte1") colour(32,44,51)
image bounds(16, 62, 500, 481) channel("wallpaper") file("Simple_EQ&Reverb_v1.png")
label bounds(315, 460, 80, 13) channel("on/off") text("On/Off") fontColour(238, 233, 233, 255)
checkbox  channel("bypass")  colour:0(34, 250, 19, 255) colour:1(11, 12, 11, 255)  fontColour:0(255, 255, 255, 255) fontColour:1(255, 253, 253, 255) corners(7) imgFile("On", "Multi_Effects_BigGoat/off.png") imgFile("Off", "Multi_Effects_BigGoat/off.png") imgFile("Off", "Multi_Effects_BigGoat/on.png") bounds(340, 435, 24, 23) text("On/Off")

rslider bounds(35, 85, 54, 60), channel("lowpass"), range(1000, 20000, 20000, 1, 1), text("Lowpass"), trackerColour(0, 255, 0, 255), outlineColour(0, 0, 0, 50), textColour(233, 233, 233, 255) colour(255, 255, 255, 255)
rslider bounds(85, 149, 54, 60) channel("highpass") range(60, 2000, 60, 1, 1) text("Highpass") textColour(255, 255, 255, 255) trackerColour(0, 255, 0, 255)
rslider bounds(35, 233, 54, 60) channel("gainlowshelf") range(0, 10, 1, 1, 0.1) text("Gain") textColour(255, 255, 255, 255) trackerColour(0, 255, 0, 255)
rslider bounds(85, 279, 54, 60) channel("freqlowshelf") range(80, 2000, 440, 1, 1) text("Freq") textColour(255, 255, 255, 255) trackerColour(0, 255, 0, 255)
rslider bounds(35, 349, 54, 60) channel("gainhighshelf") range(0, 10, 1, 1, 0.1) text("Gain") textColour(255, 255, 255, 255) trackerColour(0, 255, 0, 255)
rslider bounds(88, 402, 54, 60) channel("freqhighshelf") range(2000, 20000, 2500, 1, 1) textColour(255, 255, 255, 255) text("Freq.") trackerColour(0, 255, 0, 255)


rslider bounds(200, 85, 54, 60) channel("gainpeakeq") range(0, 10, 1, 0.45, 0.1) text("Gain") textColour(238, 238, 238, 255) trackerColour(0, 255, 0, 255)
rslider bounds(250, 149, 54, 60) channel("freqpeak") range(80, 20000, 1000, 0.5, 1) text("Freq.") textColour(255, 255, 255, 255) trackerColour(0, 255, 0, 255)
rslider bounds(200, 215, 54, 60) channel("qualitypeak") range(0.1, 5, 1, 0.5, 0.01) text("Q") textColour(255, 255, 255, 255) trackerColour(0, 255, 0, 255)
rslider bounds(205, 320, 100, 100) channel("mixeq") range(0, 1, 1, 1, 0.01) text("Dry/Wet") trackerColour(0, 255, 0, 255) textColour(255, 255, 255, 255)

vslider bounds(366, 148, 50, 200) channel("feedback") range(0.01, 1, 0.5, 1, 0.01) text("Size") textColour(255, 255, 255, 255) trackerColour(255, 0, 255, 255)
vslider bounds(434, 148, 50, 200) channel("reverbcutoff") range(20, 20000, 480, 1, 1) text("Distance") textColour(255, 255, 255, 255) trackerColour(255, 0, 255, 255)
hslider bounds(335, 358, 165, 50) channel("mix") range(0, 1, 0, 1, 0.001) text("Dry/Wet") textColour(255, 255, 255, 255) trackerColour(0, 255, 255, 255)

combobox bounds(30, 25, 100, 25), populate("*.snaps"), channelType("string")
filebutton bounds(285, 25, 60, 25), text("Save"), populate("*.snaps", "test"), mode("named preset")
filebutton bounds(370, 25, 60, 25), text("Remove"), populate("*.snaps", "test"), mode("remove preset")
</Cabbage>
<CsoundSynthesizer>
<CsOptions>
-n -d
</CsOptions>
<CsInstruments>
; Initialize the global variables. 
ksmps = 128
nchnls = 1
0dbfs = 1


instr 1
kBypass cabbageGetValue "bypass"
kPreset cabbageGetValue "preset"

kLowpass cabbageGetValue "lowpass"
kHighpass cabbageGetValue "highpass"
kGainLowShelf cabbageGetValue "gainlowshelf"
kGainHighShelf cabbageGetValue "gainhighshelf"
kLowshelffreq cabbageGetValue "freqlowshelf"
kHighshelffreq cabbageGetValue "freqhighshelf"

kGainPeak cabbageGetValue "gainpeakeq"
kFreqPeak cabbageGetValue "freqpeak"
kQ cabbageGetValue "qualitypeak"

kMixEQ cabbageGetValue "mixeq"

kSize cabbageGetValue "feedback"
kDistance cabbageGetValue "reverbcutoff"
kMix cabbageGetValue "mix"

a1 inch 1

//Preset Code

if (kBypass == 0) then

    //Lowpass and Highpass filtering stage
    afilt tone a1, kLowpass
    afilt atone afilt, kHighpass
    
    
    //Lowshelf and Highshelf filtering stage
    kGainLowShelf = ampdb(kGainLowShelf)
    kGainHighShelf = ampdb(kGainHighShelf)
    afilt pareq afilt, kLowshelffreq, kGainLowShelf, 0.6, 1
    afilt pareq afilt, kHighshelffreq, kGainHighShelf, 0.846, 2
    
    //Peak EQ stage
    kGainPeak = ampdb(kGainPeak)
    afilt pareq afilt, kFreqPeak, kGainPeak, kQ
    
    //Dry/Wet EQ
    aeqout ntrpol a1, afilt, kMixEQ
    
    //Reverb
    averbL, averbR reverbsc aeqout, aeqout, kSize, kDistance
    
    //Dry/Wet Reverb
    aoutL ntrpol aeqout, averbL, kMix
    aoutR ntrpol aeqout, averbR, kMix 
    
    outs aoutL , aoutR 
    
else
    outs a1, a1
endif
endin

</CsInstruments>
<CsScore>
;causes Csound to run for about 7000 years...
f0 z
;starts instrument 1 and runs it for a week
i1 0 [60*60*24*7] 
</CsScore>
</CsoundSynthesizer>
