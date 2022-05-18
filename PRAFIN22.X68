
*-----------------------------------------------------------
* Title      : PRAFIN22
* Written by : <nombres completos de los autores>
* Date       : 30/05/2022
* Description: Emulador de la JARVIS
*-----------------------------------------------------------
    ORG $1000
EMEM:   DC.W $2800,$2A03,$50E0,$0B60,$5114,$0C70,$1430,$0E40,$7140,$3001,$32FF,$90D0
        DC.W $8020,$C000,$0002,$0003,$0001,$0003,$0002,$0004,$0000,$0000,$0000
EIR:    DC.W 0 ;eregistro de instruccion
EPC:    DC.W 0 ;econtador de programa
EB0:    DC.W 0 ;eregistro B0
EB1:    DC.W 0 ;eregistro B1
ER2:    DC.W 0 ;eregistro R2
ER3:    DC.W 0 ;eregistro R3
ER4:    DC.W 0 ;eregistro R4
ER5:    DC.W 0 ;eregistro R5
ET6:    DC.W 0 ;eregistro T6
ET7:    DC.W 0 ;eregistro T7
ESR:    DC.W 0 ;eregistro de estado (00000000 00000ZCN)

START:
    CLR.W EPC

FETCH:
    ;--- IFETCH: INICIO FETCH
        ;*** En esta seccion debeis introducir el codigo necesario para cargar
        ;*** en el EIR la siguiente instruccion a ejecutar, indicada por el EPC,
	    ;*** y dejar listo el EPC para que apunte a la siguiente instruccion
	
	    ; ESCRIBID VUESTRO CODIGO AQUI

	MOVE.W	EPC,D7
	MULS.W	#2,D7
	MOVE.W	D7,A0
	MOVE.W	EMEM(A0),EIR
	ADD.W	#1,EPC
        
    ;--- FFETCH: FIN FETCH
    
    
    ;--- IBRDECOD: INICIO SALTO A DECOD
        ;*** En esta seccion debeis preparar la pila para llamar a la subrutina
        ;*** DECOD, llamar a la subrutina, y vaciar la pila correctamente,
        ;*** almacenando el resultado de la decodificacion en D1

    	; ESCRIBID VUESTRO CODIGO AQUI
	SUBQ.W	#2,-(A7)
	MOVE.W EIR,-(A7) ;0(A7) [error] revisar memoria
 	
        
    ;--- FBRDECOD: FIN SALTO A DECOD
  	JSR DECOD  

	MOVE.W	(A7)+,EIR
	MOVE.W	(A7)+,D1
    
    ;--- IBREXEC: INICIO SALTO A FASE DE EJECUCION
        ;*** Esta seccion se usa para saltar a la fase de ejecucion
        ;*** NO HACE FALTA MODIFICARLA
    MULU #6,D1
    MOVEA.L D1,A1
    JMP JMPLIST(A1)
JMPLIST:
    JMP ETRA
    JMP EADD
    JMP ESUB
    JMP ENAN
    JMP ESTC
    JMP EINC
    JMP ELOA
    JMP ELOAX
    JMP ESTO
    JMP ESTOX
    JMP EBRI
    JMP EBRZ
    JMP EBRN
    JMP ESTP
    ;--- FBREXEC: FIN SALTO A FASE DE EJECUCION
    
    
    ;--- IEXEC: INICIO EJECUCION
        ;*** En esta seccion debeis implementar la ejecucion de cada einstr.
	
	; ESCRIBID EN CADA ETIQUETA LA FASE DE EJECUCION DE CADA INSTRUCCION
ETRA:
	
	JMP FETCH
EADD:
	MOVE.W 	EIR,D3
    AND.W 	#%0000000001110000,D3  ;OBTENEMOS A 
    LSR.L 	#4,D3  ; lo he cambiado a 4

    JSR 	CREG
    
    MOVE.W 	D3,D2                ;METEMOS EL OPERANDO A A D2                     
    
    MOVE.W 	EIR,D3
    AND.W 	#%0000011100000000,D3 ;OBTENEMOS B
    LSR.L	#8,D3 ; esto es nuevo
    JSR CREG
    
    ;AHORA TEEMOS EL OPERANDO A EN D2 Y B EN D3 Y ADEMAS 
    ;TENEMOS LA DIRECCION DEL REGISTRO DE B EN A3
    ADD.W D2,D3
    
    MOVE.W SR,D4 ;ACTUALIZAMOS LOS FLAGS
    JSR FLAGS
    
    
    MOVE.W D3, (A3)
	JMP FETCH
ESUB:
	MOVE.W EIR,D3
    AND.W #%0000000001110000,D3  ;OBTENEMOS A 
    LSR.L #4,D3  

    JSR CREG
    
    MOVE.W D3,D2                ;METEMOS EL OPERANDO A A D2                     
    
    MOVE.W EIR,D3
    AND.W #%0000011100000000,D3 ;OBTENEMOS B
    LSR.L #8,D3
    JSR CREG
    ;AHORA TENEMOS EL OPERANDO A EN D2 Y B EN D3 Y 
    ;ADEMAS TENEMOS LA DIRECCION DEL REGISTRO DE B EN A3
    
    NOT D3
    ADD.W #1,D3  ; ESTO esta mal 100
    ADD.W D2,D3
    
    
    ;Y LOS MOVEMOS AL ESR A NUESTROS EFLAGS
    
    MOVE.W SR,D4 ;ACTUALIZAMOS LOS FLAGS
    JSR FLAGS

    MOVE.W D3, (A3)
	JMP FETCH
ENAN:
	
	JMP FETCH
ESTC:
	
	JMP FETCH
EINC:
	
	JMP FETCH
ELOA:
	
	JMP FETCH
ELOAX:
	
	JMP FETCH
ESTO:
	
	JMP FETCH
ESTOX:
	
	JMP FETCH
EBRI:
	MOVE.W EIR,D5
    AND.W #$0FF0,D5 ;D5 TENEMOS LA M y LA DESPLAZAMOS A LOS BITS MENOS SIGN 
    LSR.L  #4,D5 
                    ;ESTE SALTO ES INCONDICIONAL POR TANTO PONEMOS
                    ;LA DIRECCION DE MEMORIA AL EPC Y VOLVEMOS A FETCH
    MOVE.W D5,EPC
	JMP FETCH
EBRZ:
	MOVE.W EIR,D5
    AND.W #$0FF0,D5  ;D5 TENEMOS LA M, 
    LSR.L  #4,D5     ;MOVEMOS LOS 8 BITS 4 POSUICIONES  A LA DERECHA,
                     ;PARA TENER LAS MS EN EL BYTE MENOS SIGN


    AND.W #%0000000000000100,ESR    ;MASCARA DEL BIT 0 
    BEQ FETCH                     ;SI ES 0 A FETCH SI ES UNO MOVEMOS LA 
                                  ;DIRECCION DE MEMORIA  EPC Y VOLVEMOS A FETCH
    MOVE.W D5,EPC
    

	
	JMP FETCH
EBRN:
	MOVE.W EIR,D5
    AND.W #$0FF0,D5     ;D5 TENEMOS LA M,
    LSR.L  #4,D5        ;MOVEMOS LOS 8 BITS 4 POSUICIONES  A LA 
                        ;DERECHA, PARA TENER LAS MS EN EL BYTE MENOS SIGN


    AND.W #%0000000000000001,ESR   ;MASCARA DEL BIT 2      
    BEQ FETCH   
                       ;SI ES 0 A FETCH SI ES UNO MOVEMOS LA DIRECCION DE 
                       ;MEMORIA A EPC Y VOLVEMOS A FETCH
    MOVE.W D5,EPC
    
    JMP FETCH

	
ESTP:
	
	SIMHALT
    ;--- FEXEC: FIN EJECUCION
    

    ;--- ISUBR: INICIO SUBRUTINAS
        ;*** Aqui debeis incluir las subrutinas que necesite vuestra solucion
        ;*** SALVO DECOD, que va en la siguiente seccion



FLAGS:        ;(00000000 000XNZVC)--(00000000 00000ZCN) 
   ;FLAG N
    MOVE.W D4,D5
    AND.W #%0000000000001000,D5  ;HACEMOS UNA MASCARA DEL BIT 3 
    BEQ N0 
    JMP N1

N0:         ;SI EL BIT 3 DE SR ES 0 CAMBIAMOS EL VALOR DE EL BIT 2 DE ESR A 0
    AND.W #%1111111111111110,ESR
    JMP FLAGC
    
N1:         ;SI EL BIT 3 DE SR ES 1 CAMBIAMOS EL VALOR DE EL BIT 2 DE ESR A 1
    OR.W #%0000000000000001,ESR
    
FLAGC:     
    ;FLAG C     ;(00000000 000XNZVC)--(00000000 00000ZCN)  
    MOVE.W D4,D5 
    AND.W #%0000000000000001,D5 ;HACEMOS UNA MASCARA DEL BIT 0 
    BEQ C0
    JMP C1

C0:         ;SI EL BIT 0 DE SR ES 0 CAMBIAMOS EL VALOR DE EL BIT 1 DE ESR A 0
    AND.W #%1111111111111101,ESR
    JMP FLAGZ
    
C1:          ;SI EL BIT 0 DE SR ES 1 CAMBIAMOS EL VALOR DE EL BIT 1 DE ESR A 1
    OR.W #%0000000000000010,ESR
  
  
FLAGZ:  ;(00000000 000XNZVC)--(00000000 00000ZCN)  
    ;FLAG Z
    MOVE.W D4,D5
    AND.W #%0000000000000100,D5 ;HACEMOS UNA MASCARA DEL BIT 2 
    BEQ FN0
    JMP FN1

FN0:          ;SI EL BIT 2 DE SR ES 0 CAMBIAMOS EL VALOR DE EL BIT 0 DE ESR A 0
    AND.W #%1111111111111011,ESR
    RTS
    
FN1:          ;SI EL BIT 2 DE SR ES 1 CAMBIAMOS EL VALOR DE EL BIT 0 DE ESR A 1
    OR.W #%0000000000000100,ESR
    RTS


;///////////////////////////////////////////////////////////////////////////
CREG:
    BTST.L #2,D3
    BEQ REG0
    JMP REG1
REG1:
    BTST.L #1,D3
    BEQ REG10
    JMP REG11 

REG0:
    BTST.L #1,D3
    BEQ REG00
    JMP REG01
REG01:
    BTST.L #0,D3
    BEQ R2
    JMP R3

REG10:
    BTST.L #0,D3
    BEQ R4
    JMP R5
REG11:
    BTST.L #0,D3
    BEQ T6
    JMP T7

REG00:
    BTST.L #0,D3
    BEQ B0
    JMP B1


B0:
    MOVE.W EB0,D3 ;SABEMOS QUE ES B0
    LEA EB0, A3
    RTS
B1:
    MOVE.W EB1,D3 ;SABEMOS QUE ES B1
    LEA EB1, A3
    RTS
R2:
    MOVE.W ER2,D3 ;SABEMOS QUE ES R2
    LEA ER2, A3
    RTS 
R3:
    MOVE.W ER3,D3 ;SABEMOS QUE ES R3
    LEA ER3, A3
    RTS
R4:
    MOVE.W ER4,D3 ;SABEMOS QUE ES R4
    LEA ER4, A3
    RTS
R5:
    MOVE.W ER5,D3 ;SABEMOS QUE ES R5 
    LEA ER5, A3
    RTS
T6:
    MOVE.W ET6,D3 ;SABEMOS QUE ES T6 
    LEA ET6, A3    
    RTS
T7:
    MOVE.W ET7,D3 ;SABEMOS QUE ES T7
    LEA ET7, A3
    RTS

	    ; ESCRIBID VUESTRO CODIGO AQUI
        
    ;--- FSUBR: FIN SUBRUTINAS
    

    ;--- IDECOD: INICIO DECOD
        ;*** Tras la etiqueta DECOD, debeis implementar la subrutina de 
        ;*** decodificacion, que debera ser de libreria, siguiendo la interfaz
        ;*** especificada en el enunciado
DECOD:
	    ; ESCRIBID VUESTRO CODIGO AQUI
	MOVE.W D0,-(A7) ;GUARDAMOS LOS VALORES DE ESTOS REGISTROS PORQUE LOS 
                    ;USAMOS EN DECOD Y ASI NO LOS MODIFICAMOS
    MOVE.W D6,-(A7)
    MOVE.W 8(A7),D0 ;METEMOS EL EIR DE LA PILA EN D0


	; ESCRIBID VUESTRO CODIGO AQUI
    BTST.L #15,D0
    BEQ O ;SALTAMOS SI EL BIT QUE COMPROBAMOS ES 0 , EN CASO NEGATIVO
               
    JMP I ;LEEMOS LA SIGUIENTE INSTRUCCION JMP YA TENIENDO EN CUENTA QUE ES 1
I: 
    BTST.L #14,D0
    BEQ IO
    JMP II  
 
O:  ;
    BTST.L #14,D0
    BEQ OO
    JMP OI

OO:            
    	BTST.L #13,D0 ;AL SABER QUE INSTRUCCION ES METEMOS SU VALOR
     	BEQ OOO
    	JMP OOI            ; NUMERICO ASIGNADO EN ESTA PRACTICA 
                ; Y LO METEMOS EN D6 
OOO:
	BTST.L #12,D0
	BEQ	OOOO
	JMP OOOI
		
OOI:    
 	BTST.L #12,D0
	BEQ	OOIO
	JMP OOII

OOOO:
	BTST.L #11,D0
	BEQ	ERROR ;ERROR
	JMP OOOOI

OOOI:
	BTST.L #11,D0
	BEQ	OOOIO
	JMP OOOII

OOOOI:;TRA
	MOVE.W #0,D6
	JMP VEC
OOOIO: ;ADD
	MOVE.W #1,D6
	JMP VEC
OOOII: ; SUB
	MOVE.W #2,D6
	JMP VEC
OOII:
	BTST.L #11,D0
	BEQ	OOIIO
	JMP ERROR ; ERROR

OOIO:
	BTST.L #11,D0
	BEQ	OOIOO
	JMP OOIOI
OOIOO: ; NAN
	MOVE.W #3,D6
	JMP VEC
OOIOI: ; STC
	MOVE.W #4,D6
	JMP VEC
OOIIO: ; INC
	MOVE.W #5,D6
	JMP VEC




   
OI:
    BTST.L #13,D0
    BEQ OIO
    JMP OII    

OIO:
	BTST.L #12,D0
    BEQ OIOO
    JMP OIOI
OII:
	BTST.L #12,D0
    BEQ OIIO
    JMP OIII
OIOO: ;LOA	M	
	MOVE.W #6,D6
	JMP VEC		
OIOI: ;LOAX	M(Bi),Tj
	MOVE.W #7,D6
	JMP VEC
OIIO: ;STO	M
	MOVE.W #8,D6
	JMP VEC
OIII: ;STOX Tj,M(Bi)
	MOVE.W #9,D6
	JMP VEC	
II:   ; STP
    
    
	MOVE.W #13,D6
	JMP VEC
    

IO:
    BTST.L #13,D0
    BEQ IOO
    JMP IOI
IOO:
    BTST.L #12,D0
    BEQ IOOO
    JMP IOOI
    
IOOI: ;BRZ M
	MOVE.W #11,D6
	JMP VEC
IOOO: ;BRI M
    MOVE.W #10,D6
	JMP VEC      
IOI:
    BTST.L #12 ,D0
    BEQ IOIO
    JMP ERROR ; error

    
IOIO: ;BRN M
    MOVE.W #12,D6
	JMP VEC
    



    
ERROR: 
	SIMHALT	   
VEC:
    MOVE.W D6,10(A7) ;AQUI ES DONDE PONEMOS EL ID AL FINAL DE LA PILA 
    CLR D6           
    JMP FINAL 
       
FINAL:
    MOVE.W (A7)+,D6  ;RECUPERAMOS LOS VALORES DE LOS REGISTROS
                     ;PARA DEJARLOS COMO ESTABAN ANTES
    MOVE.W (A7)+,D0  ;RTS TENEMOS LA DIRECCION PC Y LUEGO CUANDO 
                     ;VOLVEMOS AL PROG PRINCIPAL RECUPERAMOS EIR E ID
    RTS


    ;--- FDECOD: FIN DECOD
    END    START







*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
