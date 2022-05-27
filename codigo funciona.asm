;        ______________________________________________
;       |   |GRUPO 35|                                 |
;       |                                              |
;       |    NICOLE FIGUEIREDO                         |
;       | 	NR 96899						     |
;       |______________________________________________|


SCREEN		EQU	8000H	      ; endereço da memória do ecrã

N_LINHAS        EQU  32        ; número de linhas do ecrã (altura)
N_COLUNAS       EQU  64        ; número de colunas do ecrã (largura)
TEC_LIN         EQU  0C000H    ; endereço das linhas do teclado (periférico POUT-2)
TEC_COL         EQU  0E000H    ; endereço das colunas do teclado (periférico PIN)
LINHA           EQU  16
SOM             EQU  605AH
DEFINE_PIXEL    EQU 601AH      ; endereço para obter o estado de um pixel, ligado ou desligado
DEFINE_COR  	EQU 6014H
DEFINE_LINHA    EQU 600AH      ; especifica a linha
DEFINE_COLUNA   EQU 600CH      ; especifica a coluna
NR_FUNDOS       EQU 6042H

APAGA_PIXELS    EQU 6000H

ESTADO_JOGAR    EQU 0
ESTADO_PAUSA 	EQU 1
ESTADO_TERMINAR EQU 2
ESTADO_INICIAL  EQU 3


;PLACE 2000H
;INTERRUPCAO_OVNIS: STRING 0

PLACE 1000H
pilha:      TABLE 100H      
                            
SP_inicial:  

;BTE_Table:
	;WORD interrupcao_ovnis
	;WORD 0000H
	;WORD 0000H
	;WORD 0000H               

nave:	WORD 0FFF0H
		
        BYTE 5,5            ; comprimento x largura da nave
        BYTE 0,0,1,0,0
        BYTE 0,1,1,1,0          ; desenho da nave por tabela
        BYTE 1,1,1,1,1       ; 1 ligado, 0 desligado
		BYTE 0,0,1,0,0
		BYTE 0,1,0,1,0, 0
		
coordenadas_nave:	STRING 27, 29   ; coordenadas iniciais da nave

;ovni_primeira_fase:		WORD 0F000H
						
;						STRING 1,1
;						STRING 1
						
						
;ovni_segunda_fase: 		WORD 0F000H
						
;						STRING 2,2
;						STRING 1,1
;						STRING 1,1
	
	
;asteroide_primeira:		WORD 0F0F0H
						
;						STRING 3,3
;						STRING 0,1,0
;						STRING 1,1,1
;						STRING 0,1,0


;asteroide_segunda:		WORD 0F0F0H
						
;						STRING 4,4
;						STRING 0,1,1,0
;						STRING 1,1,1,1
;						STRING 1,1,1,1
;						STRING 0,1,1,0
	
	
;asteroide:   	   WORD 0F0F0H 		; Cor
				   
;				   STRING 5,5       ; comprimento x largura
;				   STRING 0,1,1,1,0     
;			       STRING 1,1,1,1,1     ; pulsar com todos os pixeis ligados
;			       STRING 1,1,1,1,1
;				   STRING 1,1,1,1,1
;				   STRING 0,1,1,1,0


;nave_inimiga_primeira:		WORD 0FF00H
							
;							STRING 3,3
;							STRING 1,0,1
;							STRING 0,1,0
;							STRING 1,1,1
							
							
;nave_inimiga_segunda:		WORD 0FF00H
							
;							STRING 4,4
;							STRING 1,0,0,1
;							STRING 0,1,1,0
;							STRING 0,1,1,0
;							STRING 1,0,0,1


;nave_inimiga:	   WORD 0FF00H 		; COr
				   
;				   STRING 5,5       ; comprimento x largura
 ;                  STRING 1,0,0,0,1
	;			   STRING 0,1,0,1,0     ; 1 pixel ligado, 0 pixel desligado
	;			   STRING 0,0,1,0,0
;				   STRING 0,1,0,1,0
;				   STRING 1,0,0,0,1
				   
teclas_tab:		   
				   STRING 04H       ; Nave para a esquerda 
				   STRING 06H       ; Nave para a direita 
				   STRING 0DH		; Pausa

ESTADO_PROGRAMA: STRING ESTADO_INICIAL
TECLA_ATUAL: STRING 0FFH
TECLA_ANTERIOR: STRING 0FFH



; *********************************************************************************
; * Código
; *********************************************************************************


PLACE   0                   ; o código tem de começar em 0000H
 
	MOV  SP, SP_inicial     ; inicializa SP para a palavra a seguir
	;MOV  BTE, BTE_Table
	;EI
	;EI0

	MOV R0, APAGA_PIXELS
	MOV R1, 0
	MOV [R0], R1


;inicializa_estado_jogar:


;inicializa_estado_terminado:


;inicializar_estado_pausa:
                            
							
coloca_fundo:  
	MOV R0, 0               ; escolhe a primeira imagem colocada no pixel screen (design)
	MOV R1, NR_FUNDOS  			; fundo de inicio
	MOV [R1], R0            ; escreve na memoria do endereço do fundo (R1) o numero da imagem selecionada

inicio_jogo:
	CALL teclado            ; chama a rotina teclado para identificar uma tecla premida
	MOV  R2, 0CH            ; coloca num registo qual o valor da tecla
	CMP  R5, R2    			; compara com R5
	JZ  coloca_fundo2   	; se cmp R5, R2 for zero, ou seja, tecla C premida começa o jogo
	JMP  inicio_jogo   		; se não continua a espera
	
coloca_fundo2:
	MOV R0, ESTADO_PROGRAMA
	MOV R1, ESTADO_JOGAR
	MOVB [R0], R1
	MOV R0, 1               ; escolhe a segunda imagem colocada no pixel screen (design)
	MOV R1, NR_FUNDOS  			; fundo do jogo
	MOV [R1], R0            ; escreve na memoria do endereço do fundo (R1) o numero da imagem selecionada

CALL som_inicio             ; ao começar o jogo, chama a rotina para o som da tecla C (tecla para iniciar jogo)        







; ***********************************************
; ciclo de calls para chamar as rotinas a seguir
; ***********************************************

ciclo_call:
	CALL valores_nave
nao_repete_nave:	;CALL valores_asteroide    ; nao repete nave --> colocado apos o call de valores_nave para nao estar sempre a desenhar a nave na posiçao inicial
	 				;CALL valores_nave_inimiga
					;CALL valores_ovni_primeira_fase
					;CALL valores_ovni_segunda_fase
					CALL teclado
					CALL tecla_funcoes
					JMP  nao_repete_nave
	
;*************************************************** FIM DO CICLO DE CALLS. FICA EM LOOP DENTRO DESTE CICLO
;***************************************************

som_inicio:                 ; rotina para tocar o som inicial
	PUSH R3
	PUSH R4
	
	MOV R3, 0               ; escolhe o primeiro som colocado no pixel screen (design) 
	MOV R4, SOM             ; endereço do som colocado num registo
	MOV [R4], R3            ; escreve na memoria do endereço do som (R4) o numero do som selecionado
	
	POP R4
	POP R3
	RET
	
valores_nave:
	PUSH R3
	PUSH R4
	PUSH R7
	PUSH R8
	
    MOV  R7, 27          	; define linha
    MOV  R8, 29             ; define coluna
	MOV  R3, 1              ; R3 a 1 para desenhar
    MOV R4, nave           
	CALL desenha_objeto
	
	POP R8
	POP R7
	POP R4
	POP R3
	RET
	
;valores_asteroide:    ; pulsar canto superior esquerdo
;	PUSH R3
;	PUSH R4
;	PUSH R7
;	PUSH R8
	
;	MOV R7, 7               ; primeira coordenada
;	MOV R8, 20               ; segunda coordenada          
;	MOV R3,  1              ; R3 a 1 para desenhar asteroide
;	MOV R4, asteroide 
;	CALL desenha_objeto
	
;	POP R8
;	POP R7
;	POP R4
;	POP R3
;	RET
	
;valores_nave_inimiga:     ; pulsar canto inferior esquerdo
;	PUSH R3
;	PUSH R4
;	PUSH R7
;	PUSH R8
	
;	MOV R7, 7              ; primeira coordenada
;	MOV R8, 35               ; segunda coordenada               
;	MOV R3, 1               ; R3 a 1 para desenhar nave
;	MOV R4, nave_inimiga
;	CALL desenha_objeto
	
;	POP R8
;	POP R7
;	POP R4
;	POP R3
;	RET
	
;valores_ovni_primeira_fase:
;	PUSH R3
;	PUSH R4
;	PUSH R7
;	PUSH R8
	
;	MOV R7, 0               ; primeira coordenada
;	MOV R8, 32               ; segunda coordenada          
;	MOV R3,  1              ; R3 a 1 para desenhar ovni
;	MOV R4, ovni_primeira_fase 
;	CALL desenha_objeto
	
;	POP R8
;	POP R7
;	POP R4
;	POP R3
;	RET
	
;valores_ovni_segunda_fase:
;	PUSH R3
;	PUSH R4
;	PUSH R7
;	PUSH R8
	
;	MOV R7, 3               ; primeira coordenada
;	MOV R8, 30               ; segunda coordenada          
;	MOV R3,  1              ; R3 a 1 para desenhar ovni
;	MOV R4, ovni_segunda_fase 
;	CALL desenha_objeto
	
;	POP R8
;	POP R7
;	POP R4
;	POP R3
;	RET

; **********************************************************************
; Rotina desenha_objeto para desenhar nave e pulsares
; **********************************************************************


desenha_objeto:	
		PUSH R0
		PUSH R4
		PUSH R5
		PUSH R6
		PUSH R7
		PUSH R8
		PUSH R9
		PUSH R10
		
		MOV R0, DEFINE_COR      ; define a cor dos objetos
		MOV R10, [R4]   
		MOV [R0], R10 	   
		
		
		ADD R4, 2             ; le o proximo valor. neste caso passa para a tabela abaixo
		
		MOVB R5, [R4]         ; define as linhas
		ADD R4, 1             ; proximo pixel
		MOVB R6, [R4]         ; define as colunas
		MOV R0, R5            ; volta para a linha inicial
	    MOV R9, R8            ; coordenada da primeira coluna
    
	ciclo:
	    ADD R4, 1         
		MOVB R10, [R4]    
		CMP R10, 0 
		JZ  nao_escreve       ; se for 0 nao desenha o pixel
		CALL escreve_pixel 
		
	nao_escreve:
		ADD R9, 1
		SUB R5, 1
		CMP R5, 0             ; proxima linha
		JNZ continua
		SUB R6, 1
		CMP R6, 0             
		JZ fim_desenha        ; acabaram as colunas? fim da rotina
		MOV R5, R0
		ADD R7, 1
		MOV R9, R8
	
	continua:	
		JMP ciclo			  ; se nao for zero repete o ciclo
		
	fim_desenha:
		POP R10
		POP R9
		POP R8
		POP R7
		POP R6
		POP R5
		POP R4
		POP R0
		RET

; ***********************************************************************
; escreve_pixel - Rotina que escreve um pixel na linha e coluna indicadas.
; ***********************************************************************

escreve_pixel:
    PUSH  R0
    
    MOV  R0, DEFINE_LINHA
    MOV  [R0], R7           ; seleciona a linha
    
    MOV  R0, DEFINE_COLUNA
    MOV  [R0], R9          ; seleciona a coluna

    MOV  R0, DEFINE_PIXEL
    MOV  [R0], R3           ; liga ou desliga o pixel na linha e coluna selecionadas
    
    POP  R0
    RET
	
; **********************************************************************
; teclado - rotina para leitura de todo o teclado
; **********************************************************************

teclado:
     PUSH R0
     PUSH R1
     PUSH R2
     PUSH R3
	 PUSH R4
	 PUSH R11
     
	 MOV R4, 0
	 MOV R5, 0FFH                ; tecla nula. nao ha tecla premida
	 
	 MOV  R2, TEC_LIN            ; endereço do periférico das linhas
     MOV  R3, TEC_COL            ; endereço do periférico das colunas
	 MOV  R1, LINHA              ; testar a linha 
	
	espera_tecla:                ; neste ciclo espera-se até uma tecla ser premida
		SHR  R1, 1
		CMP  R1, 0
		JZ   fim_teclado
		MOV R11, 000FH
		AND R1, R11
		MOVB [R2], R1            ; escrever no periférico de saída (linhas)
		MOVB R0, [R3]            ; ler do periférico de entrada (colunas)
		MOV R11, 000FH
		AND R0, R11
		CMP  R0, 0               ; há tecla premida?
		JZ   espera_tecla        ; se nenhuma tecla premida, repete
	 
	 MOV R5, 0                   ; se houver tecla passa a ser zero para as contas
	
	conversao_linhas:            ; converter as linhas para 0 a 3
		SHR  R1, 1
		CMP  R1, 0
		JZ  conversao_colunas    ; se nao existirem mais linhas, ir para colunas 
		ADD  R5, 1
		JMP  conversao_linhas    ; se ainda existir alguma linha, voltar ao inicio da rotina
		
	conversao_colunas:           ; converter as colunas para 0 a 3
		SHR  R0, 1
		CMP  R0, 0
		JZ   contas              ; se nao existirem mais colunas, fim da rotina. passar para contas
		ADD  R4, 1               ; proxima coluna
		JMP  conversao_colunas   ; volta ao inicio da rotina
		
	contas:
		SHL R5, 2                ; multiplica linha por 4
		ADD R5, R4               ; soma com a coluna

		
	
	fim_teclado:

		MOV R0, TECLA_ATUAL
		MOVB [R0], R5
		
		POP R11
		POP  R4
		POP  R3
		POP  R2
		POP  R1
		POP  R0
		RET                      ; só retorna após detetar tecla
	
	
	tecla_funcoes:
		PUSH R0
		PUSH R1
		PUSH R2
		PUSH R4
		PUSH R7
		PUSH R8
		
		MOV R0, TECLA_ATUAL
		MOVB R5, [R0]
		MOV R0, 0FFH            
		CMP R0, R5               ; se nao houver tecla premida sai da rotina

		JZ  fim_tecla_funcoes
		
		MOV R1, teclas_tab       ; ler os valores da tabela das teclas
		
		MOVB R2, [R1]            ; repete o processo mas com a tecla 04H
		CMP R2, R5
		JZ  move_esquerda        ; se a tecla premida for 04H move a nave para a esquerda
		ADD R1, 1                ; proximo valor da tabela
		MOVB R2, [R1]            ; repete o processo mas com a tecla 06H
		CMP R2, R5
		JZ  move_direita         ; se a tecla premida for 06H move a nave para a direita
		ADD R1, 1
		MOVB R2, [R1] 			; comparar com pausa 0DH
		CMP R2, R5
		JZ pausa
		JMP fim_tecla_funcoes
		
atualiza_nave:
	MOV R3, 1                    ; volta a colocar o R3 a 1 para desenhar a nave (que estava apagada)
	CALL desenha_objeto          ; volta a desenhar 
	MOV  R0, coordenadas_nave    ; coordenadas iniciais
	MOVB [R0], R7                ; coloca na memoria a primeira coordenada
	ADD R0, 1                    ; proximo valor da tabela
	MOVB [R0], R8                ; coloca na memoria a segunda coordenada
		
fim_tecla_funcoes:
	MOV R0, TECLA_ANTERIOR
	MOVB [R0], R5

	POP R8
	POP R7
	POP R4
	POP R2
	POP R1
	POP R0
	RET

pausa:
	MOV R0, TECLA_ANTERIOR
	MOVB R1, [R0]

	MOV R0, 0FFH
	CMP R1, R0
	JNE fim_tecla_funcoes

	MOV R0, ESTADO_PROGRAMA
	MOVB R1, [R0]

	CMP R1, ESTADO_JOGAR
	JNE pausa_nao_jogar
	MOV R1, ESTADO_PAUSA
	MOVB [R0], R1
	DI
	MOV R0, NR_FUNDOS
	MOV R1, 2
	MOV [R0], R1
	JMP fim_tecla_funcoes

	pausa_nao_jogar:
	CMP R1, ESTADO_PAUSA
	JNE fim_tecla_funcoes
	MOV R1, ESTADO_JOGAR
	MOVB [R0], R1
	EI
	MOV R0, NR_FUNDOS
	MOV R1, 1
	MOV [R0], R1
	JMP fim_tecla_funcoes		
	

	
; *************************************************************************
; Rotinas para mover a nave
; *************************************************************************



	
move_esquerda:
	MOV R0, ESTADO_PROGRAMA
	MOVB R1 , [R0]
	CMP R1, ESTADO_JOGAR
	JNE fim_tecla_funcoes

	MOV R0, coordenadas_nave 
	MOVB R7, [R0]            ; coloca no r7 o valor das linhas
	ADD R0, 1                ; proximo valor
	MOVB R8, [R0]            ; coloca no r8 o valor das colunas
	MOV R3, 0                ; r3 a zero para apagar pixeis
	MOV R4, nave             ; coloca nave apagada num registo
	CALL desenha_objeto      ; como o r3 esta a zero, entao o desenha objeto apaga a nave

	SUB R8, 1                    ; para a esquerda, subtrai uma unidade as colunas
	JMP atualiza_nave

move_direita:
	MOV R0, ESTADO_PROGRAMA
	MOVB R1 , [R0]
	CMP R1, ESTADO_JOGAR
	JNE fim_tecla_funcoes

	MOV R0, coordenadas_nave 
	MOVB R7, [R0]            ; coloca no r7 o valor das linhas
	ADD R0, 1                ; proximo valor
	MOVB R8, [R0]            ; coloca no r8 o valor das colunas
	MOV R3, 0                ; r3 a zero para apagar pixeis
	MOV R4, nave             ; coloca nave apagada num registo
	CALL desenha_objeto      ; como o r3 esta a zero, entao o desenha objeto apaga a nave

	ADD R8, 1                    ; para a direita, soma uma unidade as colunas
	JMP atualiza_nave


	
; ************fim do movimento da nave******************************


;interrupcao_ovnis:
;	PUSH R0
;	PUSH R1

;	MOV R0, INTERRUPCAO_OVNIS
;	MOV R1, 1
;	MOVB [R0], R1

;	POP R1
;	POP R0

;	RFE
	
;********************displays**************************************



















