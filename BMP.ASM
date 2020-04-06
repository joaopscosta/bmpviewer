.MODEL SMALL
.STACK 100h
.DATA
        message         DB "Enter file name: $"
        buffer          DB 13
                        DB ?
                        DB 13 DUP (0)
        fileHandle      DW ?
        header          DB 54 DUP (0)
        palette         DB 256*4 DUP (0)
        scrLine         DB 320 DUP (0)
        errorMsg        DB 10, 13, "Error opening file$"
.CODE
getInput PROC
        MOV AH, 0Ah
        LEA DX, buffer
        INT 21h
        LEA SI, buffer + 1
        MOV CL, [SI]
        MOV CH, 0
        INC CX
        ADD SI, CX
        MOV AL, 0
        MOV [SI], AL
        RET
getInput ENDP
openFile PROC
        MOV AH, 3Dh
        XOR AL, AL
        LEA DX, buffer + 2
        INT 21h
        JC openError
        MOV [fileHandle], AX
        RET
        openError:
                LEA DX, errorMsg
                MOV AH, 09h
                INT 21h
                MOV AX, 4C00h
                INT 21h
openFile ENDP
vgaMode PROC
        MOV AX, 13h
        INT 10h
        RET
vgaMode ENDP
readHead PROC
        MOV AH, 3Fh
        MOV BX, [fileHandle]
        MOV CX, 54
        LEA DX, header
        INT 21h
        RET
readHead ENDP
readPal PROC
        MOV AH, 3Fh
        MOV CX, 400h
        LEA DX, palette
        INT 21h
        RET
readPal ENDP
copyPal PROC
        LEA SI, palette
        MOV CX, 256
        MOV DX, 3C8h
        MOV AL, 0h
        OUT DX, AL
        INC DX
        palLoop:
                MOV AL, [SI+2]
                SHR AL, 2
                OUT DX, AL
                MOV AL, [SI+1]
                SHR AL, 2
                OUT DX, AL
                MOV AL, [SI]
                SHR AL, 2
                OUT DX, AL
                ADD SI, 4
                LOOP palLoop
                RET
copyPal ENDP
copyBMP PROC
        MOV AX, 0A000h
        MOV ES, AX
        MOV CX, 200
        printBMP:
                PUSH CX
                MOV DI, CX
                SHL CX, 6
                SHL DI, 8
                ADD DI, CX
                MOV AH, 3Fh
                MOV CX, 320
                LEA DX, scrLine
                INT 21h
                CLD
                MOV CX, 320
                LEA SI, scrLine
                REP MOVSB
                POP CX
                LOOP printBMP
                RET
copyBMP ENDP

start:
        MOV AX, @DATA
        MOV DS, AX
        MOV AH, 09h
        LEA DX, message
        INT 21h
        CALL getInput
        CALL openFile
        CALL vgaMode
        CALL readHead
        CALL readPal
        CALL copyPal
        CALL copyBMP
        MOV AH, 1
        INT 21h
        MOV AX, 3h
        INT 10h
        MOV AX, 4C00h
        INT 21h
END start
