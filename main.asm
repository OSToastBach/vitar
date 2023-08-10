/*

    VIC-20 KEYTAR

    A PROJECT FOR CHAOS COMMUNICATION CAMP
    BY TÔBACH/SLP^RIFT^TUHB^FURRY-TRASH-GROUP

    USB POWER HOOKUP:
    USB 5V - PSU DIN PIN 4
    USB GND - PSU DIN PIN 2
    (somehow seems to run on 1.5A fine)
    ((at least that's what i think it's doing anyways...))

    AUDIO HOOKUP:
    3.5MM JACK L & R - VIDEO DIN PIN 3
    3.5MM JACK GND - VIDEO DIN GND
    (i was going to do it off the vic but it needs an amp and i cba building one)

    do not ask me what the code does where, because i probably won't know several weeks after release

    code quality is poor as i'd been doing armv2 for the past few months
    and then switched over to 6502 for this and realised
    how much it kinda sucks :-)

    GREETZ TO SLIPSTREAM, RIFT, FURRY TRASH GROUP, TUHB, K2, TITAN, QUADTRIP, SVATG,
    POO-BRAIN, AYCE, TORMENT, LOGICOMA, HOOY-PROGRAM, PWP, ORB, RBBS AND YOU !! :) <3

*/

    .const cmpval = $80
    .const tnidx1 = $81
    .const keyval = $82

    /* this is fucked don't do this */
    .const t2 = $83
    .const t3 = $84
    .const t4 = $85
    .const t5 = $86
    .const t6 = $87

    .const seqind = $88
    /* a byte as a one bit flag yes its bad but i don't care */
    /* i've got ~5KB RAM i'm going to use it */
    .const kickflag = $89
    .const bgflag = $8A
    .const bassval = $8B
    .const octflg = $8C
    .const arpval = $8D
    .const tempoval = $8E
    .const bgval = $8F
    .const arpnote = $90

    .const portb = $9120
    .const porta = $9121
    .const ddrb = $9122
    .const ddra = $9123

    //VIC addresses
    .const horzscreen   = $9000
    .const vertscreen   = $9001
    .const screencols   = $9002
    .const screenrows   = $9003
    .const rasterline   = $9004
    .const charvideomem = $9005
    .const horzlightpen = $9006
    .const vertlightpen = $9007
    .const horzpaddle   = $9008
    .const vertpaddle   = $9009
    .const soundosc1    = $900A
    .const soundosc2    = $900B
    .const soundosc3    = $900C
    .const soundosc4    = $900D
    .const soundvols    = $900E
    .const screenborder = $900F

    /*

    SHIT TO DO:

    ADD ARPS USING SECOND KEY??
    (ALSO WORK OUT HOW MULTIPLE SIMULTANEOUS KEY PRESSES WORK)
    ((MATRIX BUG WORKAROUND NEEDED))

    0,4,7   MAJ
    0,3,7   MIN
    0,5,9   IDK?
    0,12,7  OCT+5TH

    BACKGROUND ACCOMPANIMENT PRESETS
    
    TEMPO WILL HAVE TO BE WITH CMPVAL
    AS TIMERS A PAIN IN THE ARSE TO SET UP

    BASS KEYBOARD LAYER

    POSSIBLE VIBRATO KEY??

    */


    * = $1001

    .byte $0b, $10, $0a, $00, $9e, $34, $31, $30, $39, $00, $00, $00

start:

    lda #%00001111  //volume
    sta $900E

    /* sequencer speed */
    /* would've used via timer for variable tempo but i cba :-) */
    lda #5
    sta cmpval
    lda #1
    sta bgflag
    lda #0
    sta tnidx1
    sta t2
    sta t3
    sta t4
    sta t5
    sta $a2
    sta kickflag
    sta bassval
    sta octflg
    sta arpval

clrlp:
    sta $1e00,x
    sta $9600,x
    inx
    cpx #22
    bne clrlp
    ldx #0
    lda #$60
clrlp2:
    sta $1e00+22,x
    sta $9600+22,x
    sta $1e00+22+256,x
    sta $9600+22+256,x
    inx
    bne clrlp2

    ldx #0
textlp:
    lda screentext,x
    sta $1e84-66,x
    lda screentext+256,x
    sta $1e84-66+256,x
    inx
    bne textlp
textend:

    lda #$46
    sta $1f57

    /* the start of an interrupt driven sequencer that never was :'-) */
/*
    lda #>irqlp
    sta $0314
    lda #<irqlp
    sta $0315
    VIA_HZ = 1000000
    SAMP_HZ = 50
    RHZ = VIA_HZ / SAMP_HZ
*/

mainloop:

    lda soundosc1
    sta $1e0b
    lda soundosc2
    sta $1e0c
    lda soundosc3
    sta $1e0d
    lda soundosc4
    sta $1e0e

    //portb - col
    //porta - row

    /* this is also quite fucked but it works :-) */

    lda #$ff
    sta ddrb
    lda #$00
    sta ddra

    /* bottom keyboard bass */
    /* so that you can trigger the bass and lead at roughly the same time */

    lda #%11101111
    sta portb
    lda porta
    cmp #%11111101
    bne skipkey_z
    lda #0
    sta bassval
    jmp basskeyend
skipkey_z:
    cmp #%11111011
    bne skipkey_c
    lda #4
    sta bassval
    jmp basskeyend
skipkey_c:
    cmp #%11110111
    bne skipkey_b
    lda #7
    sta bassval
    jmp basskeyend
skipkey_b:
    cmp #%11101111
    bne skipkey_m
    lda #11
    sta bassval
    jmp basskeyend
skipkey_m:

    lda #%11110111
    sta portb
    lda porta
    cmp #%11111011
    bne skipkey_x
    lda #2
    sta bassval
    jmp basskeyend
skipkey_x:
    cmp #%11110111
    bne skipkey_v
    lda #5
    sta bassval
    jmp basskeyend
skipkey_v:
    cmp #%11101111
    bne skipkey_n
    lda #9
    sta bassval
    jmp basskeyend
skipkey_n:
    cmp #%11011111
    bne skipkey_comma
    lda #12
    sta bassval
    jmp basskeyend
skipkey_comma:
    lda #%11011111
    sta portb
    lda porta
    cmp #%11111101
    bne skipkey_s
    lda #1
    sta bassval
    jmp basskeyend
skipkey_s:
    cmp #%11110111
    bne skipkey_h
    lda #8
    sta bassval
    jmp basskeyend
skipkey_h:

    lda #%11111011
    sta portb
    lda porta
    cmp #%11111011
    bne skipkey_d
    lda #3
    sta bassval
    jmp basskeyend
skipkey_d:
    cmp #%11110111
    bne skipkey_g
    lda #6
    sta bassval
    jmp basskeyend
skipkey_g:
    cmp #%11101111
    bne skipkey_j
    lda #10
    sta bassval
    jmp basskeyend
skipkey_j:

    lda #%11111110
    sta portb
    lda porta
    cmp #%11011111
    bne skipkey_plus
    lda #1
    sta octflg
    jmp basskeyend
skipkey_plus:
    lda #%01111111
    sta portb
    lda porta
    cmp #%11011111
    bne skipkey_minus
    lda #0
    sta octflg
    jmp basskeyend
skipkey_minus:

    /* column */
    lda #%10111111
    sta portb
    lda porta
    //sta $1e03
    /* row */
    cmp #%11111110
    bne skipkey_q
    ldx #0
    jmp skipend
skipkey_q:
    cmp #%11111101
    bne skipkey_e
    ldx #4
    jmp skipend
skipkey_e:
    cmp #%11111011
    bne skipkey_t
    ldx #7
    jmp skipend
skipkey_t:
    cmp #%11110111
    bne skipkey_u
    ldx #11
    jmp skipend
skipkey_u:
    cmp #%11101111
    bne skipkey_o
    ldx #14
    jmp skipend
skipkey_o:

    /* column */
    lda #%11111101
    sta portb
    lda porta
    //sta $1e03
    /* row */
    cmp #%11111101
    bne skipkey_w
    ldx #2
    jmp skipend
skipkey_w:
    cmp #%11111011
    bne skipkey_r
    ldx #5
    jmp skipend
skipkey_r:
    cmp #%11110111
    bne skipkey_y
    ldx #9
    jmp skipend
skipkey_y:
    cmp #%11101111
    bne skipkey_i
    ldx #12
    jmp skipend
skipkey_i:
    cmp #%11011111
    bne skipkey_p
    ldx #16
    jmp skipend
skipkey_p:

    /* column */
    lda #%01111111
    sta portb
    lda porta
    //sta $1e03
    /* row */
    cmp #%11111110
    bne skipkey_2
    ldx #1
    jmp skipend
skipkey_2:
    cmp #%11111011
    bne skipkey_6
    ldx #8
    jmp skipend
skipkey_6:
    cmp #%11101111
    bne skipkey_0
    ldx #15
    jmp skipend
skipkey_0:

    /* column */
    lda #%11111110
    sta portb
    lda porta
    //sta $1e03
    /* row */
    cmp #%11111101
    bne skipkey_3
    ldx #3
    jmp skipend
skipkey_3:
    cmp #%11111011
    bne skipkey_5
    ldx #6
    jmp skipend
skipkey_5:
    cmp #%11110111
    bne skipkey_7
    ldx #10
    jmp skipend
skipkey_7:
    cmp #%11101111
    bne skipkey_9
    ldx #13
    jmp skipend
skipkey_9:

    /* cheap bug fix to stop giving me random noise */
    /* on keys that were assigned on column 0 */
    /* bloody keyboard matrices */

    lda #%11111111
    sta portb

    cmp #$ff
    bne skipend
    jmp skipcheck
skipend:

    /* chord key checking */

    lda #%11011111
    sta portb
    lda porta
    //sta $1e03
    cmp #%11011111
    bne skipkey_cln
    lda #1
    sta arpval
    jmp skiparpend
skipkey_cln:
    lda #%11111011
    sta portb
    lda porta
    //sta $1e03
    cmp #%10111111
    bne skipkey_smcln
    lda #2
    sta arpval
    jmp skiparpend
skipkey_smcln:
    lda #%11011111
    sta portb
    lda porta
    //sta $1e03
    cmp #%10111111
    bne skipkey_eqls
    lda #3
    sta arpval
    jmp skiparpend
skipkey_eqls:
    lda #0
    sta arpval

skiparpend:
    /* octave fuckery */

    lda octflg
    bne skipldoct
    jmp octcheckend
skipldoct:
    txa
    clc
    adc #12
    tax
octcheckend:

    /* 0=none 1=maj 2=min 3=oct */
    lda arpval
    cmp #1
    bne skipmaj
    lda arpmaj,y
    sta arpnote
    jmp skipoct
skipmaj:
    cmp #2
    bne skipmin
    lda arpmin,y
    sta arpnote
    jmp skipoct
skipmin:
    cmp #3
    bne skipoct
    lda arpoct,y
    sta arpnote
    jmp skipoct
skipoct:


    lda arpval
    beq skiparp
    txa
    clc
    adc arpnote
    tax
skiparp:

    lda freqtab,x
    sta keyval

    /* column */
    lda #%11101111
    sta portb
    lda porta
    cmp #%11111110
    bne skipkey_spc
    lda keyval
    clc
    adc vibtab,y
    sta keyval
skipkey_spc:

    lda keyval
    sta $1e04
    sta soundosc3
    jmp jiffyloop
skipcheck:
    //lda #%00001111
    //sta $900e
    lda #0
    sta soundosc3
    sta $1e04

    /* bg enable/disable */
    lda #%01111111
    sta portb
    lda porta
    cmp #%01111111
    bne skipbgdisable
    lda #1
    sta bgflag
skipbgdisable:

    /* bg enable/disable */
    /* for some reason if you hold down f1 you get assfuck techno */
    /* no clue why or how but its the best unintentional bug one could ask for */

    /* ^^^ this no longer happens bc i reset timers for the other bgs :-( */

    lda #%11101111
    sta portb
    lda porta
    cmp #%01111111
    bne skipbg1enable

    lda #0
    sta bgflag
    sta t4
    sta t3
    sta t2
    lda #1
    sta bgval
    lda #5
    sta cmpval
    jmp skipbg3enable

skipbg1enable:
    lda #%11011111
    sta portb
    lda porta
    cmp #%01111111
    bne skipbg2enable

    lda #0
    sta bgflag
    sta t4
    sta t3
    sta t2
    lda #2
    sta bgval
    lda #3
    sta cmpval
    jmp skipbg3enable

skipbg2enable:
    lda #%10111111
    sta portb
    lda porta
    cmp #%01111111
    bne skipbg3enable

    lda #0
    sta bgflag
    sta t4
    sta t3
    sta t2
    lda #3
    sta bgval
    lda #7
    sta cmpval
skipbg3enable:

    lda bassval
    sta $1e09

    lda bgval
    sta $1e0a

basskeyend:

    /* 2,3,6,7,10,11,14,15 */

    lda bgval
    cmp #1
    bne skipbgbass1

    lda bassval
    clc
    adc #12
    sta seqtab1+2
    sta seqtab1+6
    sta seqtab1+10
    sta seqtab1+14
    jmp skipbgbasscheck
skipbgbass1:
    cmp #2
    bne skipbgbass2

    /* 64,255,0,255,12,255,24,255,64,255,0,255,12,255,24,255 */
    
    lda #0
    clc
    adc bassval
    sta seqtab2+2
    lda #12
    adc bassval
    sta seqtab2+4
    lda #0
    adc bassval
    sta seqtab2+6
    lda #0
    adc bassval
    sta seqtab2+10
    lda #12
    adc bassval
    sta seqtab2+12
    lda #0
    adc bassval
    sta seqtab2+14
    
    jmp skipbgbasscheck

skipbgbass2:
    cmp #3
    bne skipbgbass3

    /* 64,12,0,12,64,0,10,12,64,12,0,12,64,0,10,12 */

    lda #12
    clc
    adc bassval
    sta seqtab3+1
    lda #0
    adc bassval
    sta seqtab3+2
    lda #12
    adc bassval
    sta seqtab3+3
    lda #0
    adc bassval
    sta seqtab3+5
    lda #10
    adc bassval
    sta seqtab3+6
    lda #12
    adc bassval
    sta seqtab3+7

    lda #12
    adc bassval
    sta seqtab3+9
    lda #0
    adc bassval
    sta seqtab3+10
    lda #12
    adc bassval
    sta seqtab3+11
    lda #0
    adc bassval
    sta seqtab3+13
    lda #10
    adc bassval
    sta seqtab3+14
    lda #12
    adc bassval
    sta seqtab3+15

    jmp skipbgbasscheck

skipbgbass3:

skipbgbasscheck:

jiffyloop:
    lda $a2
    sta $1e00
    cmp #1
    beq skipendloop
    jmp endloop
skipendloop:

    /* jank */
    inc t5
    lda t5
    cmp #1
    bne skipt5rst
    lda #0
    sta t5
    inc t6

    lda bgflag
    bne skipkickpitch

    lda kickflag
    beq skipkickpitch
    lda soundosc1
    clc
    sbc #5
    sta soundosc1

skipkickpitch:

skipt5rst:

    /* can't even remember what all this shit does */
    lda t5
    sta $1e07
    lda t6
    sta $1e08
    inc $1e01
    lda #0
    sta $a2
    inc t2
    inc t3
    lda t3
    and #$1f
    tay
    sta $1e02
    lda t2
    cmp cmpval
    bne skipt2rst
    lda #0
    sta t2
    inc $1e03
    lda $1e03
    sta t4
skipt2rst:

    /* sequencer */
    /* all sorts of buggery going on here... */

    lda bgflag
    beq skipbg
    lda #0
    sta soundosc1
    sta soundosc4
    jmp endloop
skipbg:

    lda t4
    /* length of pattern goes here */
    and #$0f
    sta seqind
    sta $1e05
    ldx seqind

    lda bgval
    cmp #1
    bne skipbg1play
    lda seqtab1n,x
    sta soundosc4
    lda seqtab1,x
    sta $1e06
    jmp skipbgplayend
skipbg1play:

    lda bgval
    cmp #2
    bne skipbg2play
    lda seqtab2n,x
    sta soundosc4
    lda seqtab2,x
    sta $1e06
    jmp skipbgplayend
skipbg2play:

    lda bgval
    cmp #3
    bne skipbg3play
    lda seqtab3n,x
    sta soundosc4
    lda seqtab3,x
    sta $1e06
    jmp skipbgplayend
skipbg3play:

skipbgplayend:
    cmp #64
    bcs skipnote
    tax
    lda freqtab,x
    sta soundosc1
    lda #0
    sta kickflag
    jmp endloop
skipnote:

    cmp #64
    bne skipkickrst
    lda kickflag
    bne skipkickrst
    lda #1
    sta kickflag
    lda #242
    sta soundosc1
    jmp endloop
skipkickrst:
/*
    cmp #26
    bne skippitchdown
    lda #0
    sta kickflag
    jmp endloop
skippitchdown:
*/
    cmp #255
    bne skip1rst
    lda #0
    sta soundosc1
    lda #0
    sta kickflag
skip1rst:

endloop:
    jmp mainloop

    /* the most normal part of the code, and its not even code */

freqtab:
    .byte 130,137,144,150,156,161,167,172,176,181,185,189 
    .byte 193,196,199,202,205,208,211,213,216,218,220,222 
    .byte 224,226,227,229,230,232,233,234,235,236,237,238 
    .byte 239,240,241,242

vibtab:
    .byte 0,1,1,0,-1,-1,0,1,1,0,-1,-1,-1,0,1,1,0,-1,-1,0,1,1,0,-1,-1,0,1,1,0,-1,-1,0

/*

    ACCOMP SEQUENCES
    LOW AND NOISE CHANNELS USED

    0-24 = NOTES
    64 = KICK
    255 = OFF

    noise is just same as normal bc i cba implementing more shit

    (not yet implemented)
    26 = PITCH DOWN
    27 = PITCH UP
    64 = NOISE CANCEL
    31-63 = NOISE

    don't like the ones i've made? make your own!! :-)
    just change 'cmpval' for speed where each bg in enagled

*/

seqtab1:
    .byte 64,64,0,255,64,64,0,255,64,64,0,255,64,64,0,255
seqtab1n:
    .byte 140,0,254,0,140,0,254,0,140,0,254,0,140,0,254,0

seqtab2:
    .byte 64,255,0,255,12,255,24,255,64,255,0,255,12,255,24,255
seqtab2n:
    .byte 0,0,0,0,254,254,0,0,0,0,0,0,254,254,0,0

seqtab3:
    .byte 64,12,0,12,64,0,10,12,64,12,0,12,64,0,10,12
seqtab3n:
    .byte 254,0,254,0,239,239,0,0,254,0,254,0,239,239,0,0

    /* 32 in length bc using y reg already modulo'd */

arpmaj:
    .byte 0,4,7,0,4,7,0,4,7,0,4,7,0,4,7,0,0,4,7,0,4,7,0,4,7,0,4,7,0,4,7,0
arpmin:
    .byte 0,3,7,0,3,7,0,3,7,0,3,7,0,3,7,0,0,3,7,0,3,7,0,3,7,0,3,7,0,3,7,0
arpoct:
    .byte 0,12,7,0,12,7,0,12,7,0,12,7,0,12,7,0,0,12,7,0,12,7,0,12,7,0,12,7,0,12,7,0

screentext:
    .text petscreen "      greetz to:      "
    .text petscreen "                      "
    .text petscreen "slipstream, rift, tuhb"
    .text petscreen "furry trash group, k2,"
    .text petscreen "titan, quadtrip, svatg"
    .text petscreen "poo-brain, ayce, pwp, "
    .text petscreen "torment, logicoma, orb"
    .text petscreen "rbbs, desire, trepaan,"
    .text petscreen "bitshifters,truck,rc55"
    .text petscreen "alia, lex <3, field-fx"
    .text petscreen "ons, dss, asd, and you"
    .text petscreen "                      "
    .text petscreen "                      "
    .text petscreen "    code by tobach    "
    .text petscreen "                      "
    .text petscreen "                      "
    .text petscreen " made for cccamp 2023 "
    .text petscreen "                      "
    .text petscreen "  on track demoparty  "
    .text petscreen "                      "