jmp main

; 0    branco						0000 0000
; 256  marrom						0001 0000
; 512  verde						0010 0000
; 768  oliva						0011 0000
; 1024 azul marinho                 0100 0000
; 1280 roxo							0101 0000
; 1536 teal							0110 0000
; 1792 prata						0111 0000
; 2048 cinza						1000 0000
; 2304 vermelho	                    0001 0000
; 2560 lima							1010 0000
; 2816 amarelo					    1011 0000
; 3072 azul							1100 0000
; 3328 rosa							1101 0000
; 3584 aqua							1110 0000
; 3840 branco						1111 0000

scrOver   : string "                GAMEOVER                "
scrLine0  : string "                 PORTAL                 "
scrLine1  : string "----------------------------------------"
scrLine2  : string "                 ------                 "
scrLine3  : string "                   \\/                   "
scrLine4  : string "                               *        "
scrLine5  : string "                                        "
scrLine6  : string "     *                                  "
scrLine7  : string "               *                        "
scrLine8  : string "                                        "
scrLine9  : string "                                        "
scrLine10 : string "        *                 *             "
scrLine11 : string "                                        "
scrLine12 : string "                                        "
scrLine13 : string "|            *                         |"
scrLine14 : string "|\\                                    /|"
scrLine15 : string "|/                                    \\|"
scrLine16 : string "|                                      |"
scrLine17 : string "                  *                     "
scrLine18 : string "   *                                    "
scrLine19 : string "                                        "
scrLine20 : string "               *                 *      "
scrLine21 : string "                                        "
scrLine22 : string "                         *              "
scrLine23 : string "                                        "
scrLine24 : string "    *                                   "
scrLine25 : string "                                        "
scrLine26 : string "           *                            "
scrLine27 : string "                             *          "
scrLine28 : string "                   /\\                   "
scrLine29 : string "                 ------                 "

gameOver: var #1            ; Game over son.

shipPosA: var #1            ; "Old" ship position
shipPosB: var #1            ; "New" ship position
shipDir:  var #1            ; Current ship direction
shipLen:  var #1            ; Current ship length
shipVec:  var #40           ; Ship positions vector
shipSpd:  var #1            ; Ship draw delay interval

foodPos: var #1             ; Current food position
foodCur: var #1             ; Current rand in list
foodRls: var #1             ; Food rands list size
foodEtn: var #1             ; Amount of food eaten
foodExs: var #1             ; Current food state

foodRand: var #10
static foodRand + #0, #105
static foodRand + #1, #83
static foodRand + #2, #470
static foodRand + #3, #558
static foodRand + #4, #641
static foodRand + #5, #1020
static foodRand + #6, #1142
static foodRand + #7, #870
static foodRand + #8, #921
static foodRand + #9, #97

main:

    ; Initialize player
    loadn r0, #0
    store shipPosA, r0
    loadn r0, #615
    store shipPosB, r0
    loadn r0, #'w'
    store shipDir, r0
    loadn r0, #5
    store shipSpd, r0

    ; Initialize scenario
    loadn r0, #0
    loadn r1, #scrLine0
    loadn r2, #0
    call printScreen

    ; Initialize artifacts
    loadn r0, #10
    store foodRls, r0
    loadn r0, #875
    store foodPos, r0
    loadn r0, #0
    store foodCur, r0
    store foodExs, r0
    store foodEtn, r0
    store gameOver, r0

    mainLoop:

        load r1, shipSpd
        mod r1, r0, r1
        jnz step
            call ctlShip
            call clrShip
            call drwShip
            call setShip
            call drwFood
            call setFood
        step:

        load r1, gameOver
        loadn r2, #0
        cmp r1, r2
        jne mainDone

        call Delay
        inc r0
        jmp mainLoop

    mainDone:
    loadn r0, #0
    loadn r1, #scrOver
    loadn r2, #2304
    call printString

    ;@@@_HAXORZ_@@@
    load r0, foodEtn
    loadn r1, #37
    dec r0
    call printNumber

    halt

ctlShip:
    push r0
    push r1
    push r2

    inchar r0
    loadn r1, #255

    cmp r0, r1
    jeq ctlShipEnd
    store shipDir, r0

    ctlShipEnd:
    pop r2
    pop r1
    pop r0
    rts

clrShip:
    push r0
    push r1
    push r2

    load r0, shipPosA
    load r1, shipPosB
    cmp r1, r0
    jeq clrShipEnd

    loadn r2, #40       ; Load the divider number
    div r2, r0, r2      ; Find position in line
    add r2, r2, r0      ; Find line in the map
    loadn r1, #scrLine0 ; Load the tracker
    add r1, r1, r2      ; Place the tracker

    ; WHY THE FUCK DOES THIS WORK???
    loadi r1, r1
    outchar r1, r0

    clrShipEnd:
    pop r2
    pop r1
    pop r0
    rts

drwShip:
    push r0
    push r1
    push r2

    load r0, shipPosA
    load r1, shipPosB
    cmp r1, r0
    jeq drwShipEnd

    loadn r0, #'X'
    loadn r2, #2560
    add r0, r0, r2
    outchar r0, r1
    store shipPosA, r1

    drwShipEnd:
    pop r2
    pop r1
    pop r0
    rts

setShip:
    push r0
    push r1
    push r2

    load r1, shipDir
    load r0, shipPosA

    loadn r2, #'w'
    cmp r2, r1
    jeq setShipPortalW

    loadn r2, #'a'
    cmp r2, r1
    jeq setShipPortalA

    loadn r2, #'s'
    cmp r2, r1
    jeq setShipPortalS

    loadn r2, #'d'
    cmp r2, r1
    jeq setShipPortalD

    setShipEnd:
    store shipPosB, r0
    pop r2
    pop r1
    pop r0
    rts

    ; Move ship into portal
    setShipPortalW:
        loadn r1, #137
        cmp r0, r1
        jle setShipMoveW
        loadn r1, #142
        cmp r0, r1
        jgr setShipMoveW
        loadn r1, #1000
        add r0, r0, r1
        jmp setShipEnd

    setShipPortalA:
        loadn r1, #40
        mod r1, r0, r1
        loadn r2, #1
        cmp r1, r2
        jne setShipMoveA
        loadn r1, #521
        cmp r0, r1
        jle setShipMoveA
        loadn r1, #641
        cmp r0, r1
        jgr setShipMoveA
        loadn r1, #37
        add r0, r0, r1
        jmp setShipEnd

    setShipPortalS:
        loadn r1, #1137
        cmp r0, r1
        jle setShipMoveS
        loadn r1, #1142
        cmp r0, r1
        jgr setShipMoveS
        loadn r1, #1000
        sub r0, r0, r1
        jmp setShipEnd

    setShipPortalD:
        loadn r1, #40
        mod r1, r0, r1
        loadn r2, #38
        cmp r1, r2
        jne setShipMoveD
        loadn r1, #558
        cmp r0, r1
        jle setShipMoveD
        loadn r1, #678
        cmp r0, r1
        jgr setShipMoveD
        loadn r1, #37
        sub r0, r0, r1
        jmp setShipEnd

    ; Just move ship normally
    setShipMoveW:
        loadn r1, #120
        cmp r0, r1
        jle setExplode
        loadn r1, #40
        sub r0, r0, r1
        jmp setShipEnd

    setShipMoveA:
        loadn r1, #40
        mod r1, r0, r1
        loadn r2, #0
        cmp r1, r2
        jeq setExplode
        dec r0
        jmp setShipEnd

    setShipMoveS:
        loadn r1, #1159
        cmp r0, r1
        jgr setExplode
        loadn r1, #40
        add r0, r0, r1
        jmp setShipEnd

    setShipMoveD:
        loadn r1, #40
        mod r1, r0, r1
        loadn r2, #39
        cmp r1, r2
        jeq setExplode
        inc r0
        jmp setShipEnd

    setExplode:
        loadn r1, #1
        store gameOver, r1
        jmp setShipEnd

drwFood:
    push r0
    push r1
    push r2

    load r0, foodExs
    loadn r1, #1
    cmp r0, r1
    jeq drwFoodEnd

    loadn r0, #1
    store foodExs, r0
    loadn r0, #'O'
    loadn r2, #2304
    add r0, r0, r2
    load r1, foodPos
    outchar r0, r1

    load r0, foodEtn
    loadn r1, #37
    call printNumber
    inc r0
    store foodEtn, r0
    load r0, shipSpd
    loadn r1, #1
    cmp r0, r1
    jeq drwFoodEnd
    dec r0
    store shipSpd, r0

    drwFoodEnd:
    pop r2
    pop r1
    pop r0
    rts

setFood:
    push r0
    push r1
    push r2

    load r0, shipPosA   ; Load ship position
    load r1, foodPos    ; Load food position
    cmp r0, r1          ; The ship eat the food?
    load r0, foodCur    ; Just load food tracker
    jne setFoodEnd      ; End routine, if not
    loadn r1, #0        ; Otherwise load value
    store foodExs, r1   ; And set to food flag

    loadn r1, #foodRand ; Load food rand list
    add r1, r1, r0      ; Position list index
    loadi r2, r1        ; Prime value at index
    store foodPos, r2   ; Store new position
    inc r0              ; Increment tracker
    load r1, foodRls    ; Load rand list size
    cmp r0, r1          ; Compare with tracker
    jle setFoodEnd      ; Continue if not maxed
    loadn r0, #0        ; Reset tracker otherwise

    setFoodEnd:
    store foodCur, r0   ; Re-store food tracker
    pop r2
    pop r1
    pop r0
    rts

printScreen:
    ; r0 = Initial printing position
    ; r1 = Initial strubg address
    ; r2 = Printing colour
    push r0
    push r1
    push r2
    push r3
    push r4
    push r5

    loadn r3, #40       ; Print position increment
    loadn r4, #41       ; Print address increment
    loadn r5, #1200     ; Screen edge

    printScreenLoop:
        call printString
        add r0, r0, r3
        add r1, r1, r4
        cmp r0, r5
        jne printScreenLoop

    pop r5
    pop r4
    pop r3
    pop r2
    pop r1
    pop r0
    rts

printString:
    ; r0 = Initial printing position
    ; r1 = Initial strubg address
    ; r2 = Printing colour
    push r0
    push r1
    push r2
    push r3
    push r4

    loadn r3, #'\0'

    printStringLoop:
        loadi r4, r1
        cmp r4, r3
        jeq printStringEnd

        add r4, r2, r4
        outchar r4, r0
        inc r0
        inc r1
        jmp printStringLoop

    printStringEnd:
    pop r4
    pop r3
    pop r2
    pop r1
    pop r0
    rts

Delay:
    push r0
    push r1
    loadn r0, #640

    loop1:
        loadn r1, #640

        loop2:
            dec r1
            jnz loop2
            dec r0
            jnz loop1

    pop r1
    pop r0
    rts

printNumber:
    ; Parametors: r0 - numero; r1 - posicao na tela
	push r0
	push r1
	push r2
	push r3
	push r4
	push r5
	push r6

	loadn r3, #9
	loadn r2, #48
	cmp r0, r3
	jgr PrintnrDezena
	add r0, r0, r2
	outchar r0, r1
	jmp PrintnrRts

PrintnrDezena:
	loadn r3, #99
	cmp r0, r3
	jgr PrintnrCentena
	loadn r6, #10
	div r4, r0, r6
	loadn r2, #48
	add r5, r4, r2
	outchar r5, r1
	mul r4, r4, r6
	sub r0, r0, r4
	add r0, r0, r2
	inc r1
	outchar r0, r1
	jmp PrintnrRts

PrintnrCentena:
	loadn r3, #999
	cmp r0, r3
	jgr PrintnrMilhar
	loadn r6, #100
	div r4, r0, r6
	loadn r2, #48
	add r5, r4, r2
	outchar r5, r1
	mul r4, r4, r6
	sub r4, r0, r4
	loadn r6, #10
	div r0, r4, r6
	loadn r2, #48
	add r5, r0, r2
	inc r1
	outchar r5, r1
	mul r0, r0, r6
	sub r0, r4, r0
	add r0, r0, r2
	inc r1
	outchar r0, r1
	jmp PrintnrRts

PrintnrMilhar:
	loadn r0, #'?'
	outchar r0, r1
	inc r1
	outchar r0, r1
	inc r1
	outchar r0, r1
	inc r1
	outchar r0, r1

PrintnrRts:	; Fim da subrotina
	pop r6
	pop r5
	pop r4
	pop r3
	pop r2
	pop r1
	pop r0
	rts
