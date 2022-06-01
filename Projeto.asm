; *********************************************************************
; * IST-UL
; * Modulo:    lab3.asm
; * Descri��o: Exemplifica o acesso a um teclado.
; *            L� uma linha do teclado, verificando se h� alguma tecla
; *            premida nessa linha.
; *
; * Nota: Observe a forma como se acede aos perif�ricos de 8 bits
; *       atrav�s da instru��o MOVB
; *********************************************************************

; **********************************************************************
; * Constantes
; **********************************************************************
; ATEN��O: constantes hexadecimais que comecem por uma letra devem ter 0 antes.
;          Isto n�o altera o valor de 16 bits e permite distinguir n�meros de identificadores
DEFINE_LINHA                EQU 600AH   ; endereço do comando para defenir a linha
DEFINE_COLUNA               EQU 600CH   ; endereço do comando para defenir a coluna
DEFINE_PIXEL                EQU 6012H   ;endereço do comando para escrever um pixel
APAGA_AVISO     		    EQU 6040H   ; endereço do comando para apagar o aviso de nenhum cenário selecionado
APAGA_ECRA		            EQU 6002H   ; endereço do comando para apagar todos os pixels já desenhados
SELECIONA_CENARIO_FUNDO     EQU 6042H   ; endereço do comando para selecionar uma imagem de fundo
DISPLAYS                    EQU 0A000H  ; endere�o dos displays de 7 segmentos (perif�rico POUT-1)
TEC_LIN                     EQU 0C000H  ; endere�o das linhas do teclado (perif�rico POUT-2)
TEC_COL                     EQU 0E000H  ; endere�o das colunas do teclado (perif�rico PIN)
TOCA_SOM				    EQU 605AH      ; endereço do comando para tocar um som
MASCARA                     EQU 0FH     ; para isolar os 4 bits de menor peso, ao ler as colunas do teclado
TAM_TAB                     EQU 0010H   ; 
LARGURA_NAVE		        EQU	5		; largura do boneco
ALTURA_NAVE                 EQU 4
LARGURA_METEORO             EQU 5
ALTURA_METEORO              EQU 5
COR_PIXEL		            EQU	0FFF0H	; cor do pixel nave
COR_PIXEL_INIMIGO           EQU 0FF00H 
TEC_ESQUERDA                EQU 0
TEC_DIREITA                 EQU 2
TEC_BAIXO                   EQU 5
TEC_AUMENTA                 EQU 3
TEC_DIMINUI                 EQU 7
ATRASO			            EQU	3000H		; atraso para limitar a velocidade de movimento do boneco
MIN_COLUNA                  EQU 0
MAX_COLUNA                  EQU 63
MIN_LINHA                   EQU 0
MAX_LINHA                   EQU 31

; **********************************************************************
; * Dados 
; **********************************************************************
PLACE   0500H ; para escrever as variaveis
    STACK   100H

SP_inicial:

energia: WORD 100
nave:	WORD ALTURA_NAVE, LARGURA_NAVE
        WORD 0, 0, COR_PIXEL, 0, 0
        WORD COR_PIXEL, 0, COR_PIXEL, 0, COR_PIXEL
        WORD COR_PIXEL, COR_PIXEL, COR_PIXEL, COR_PIXEL, COR_PIXEL
        WORD 0, COR_PIXEL, 0, COR_PIXEL, 0
		
coordenadas_nave:	WORD 28, 31  ; coordenadas iniciais da nave

meteoro_inimigo:    WORD ALTURA_METEORO, LARGURA_METEORO
                    WORD COR_PIXEL_INIMIGO, 0, 0, 0, COR_PIXEL_INIMIGO
                    WORD COR_PIXEL_INIMIGO, 0, COR_PIXEL_INIMIGO, 0, COR_PIXEL_INIMIGO
                    WORD 0, COR_PIXEL_INIMIGO, COR_PIXEL_INIMIGO, COR_PIXEL_INIMIGO, 0
                    WORD COR_PIXEL_INIMIGO, 0, COR_PIXEL_INIMIGO, 0, COR_PIXEL_INIMIGO
                    WORD COR_PIXEL_INIMIGO, 0, 0, 0, COR_PIXEL_INIMIGO

coordenadas_meteoro_inimigo: WORD 0, 44
                     
                 

; **********************************************************************
; * Código
; **********************************************************************
PLACE   0 ; para escrever o codigo 

inicia_jogo:
    MOV     SP, SP_inicial
    MOV     R11, [energia]
    CALL    atualiza_energia
    MOV     [APAGA_AVISO], R1	; apaga o aviso de nenhum cenário selecionado (o valor de R1 não é relevante)
    MOV     [APAGA_ECRA], R1	; apaga todos os pixels já desenhados (o valor de R1 não é relevante)
	MOV     R1, 0			    ; cenário de fundo número 0
    CALL    desenha_fundo
    mostra_nave:
        MOV     R0, [coordenadas_nave]          ;define coordenada da linha
        MOV     R1, [coordenadas_nave + 2]      ;define a coordenada da coluna
        MOV     R2, nave
        CALL    desenha_objeto
    
    mostra_inimigo:
        MOV     R0, [coordenadas_meteoro_inimigo]          ;define coordenada da linha
        MOV     R1, [coordenadas_meteoro_inimigo + 2]      ;define a coordenada da coluna
        MOV     R2, meteoro_inimigo
        CALL    desenha_objeto
    
    chama_teclado:
        CALL    teclado
    fim_jogo:
        JMP     fim_jogo

; **********************************************************************
;  TECLADO
;  ARGUMENTOS:
;       
;  RESGISTOS AUXILIARES USADO:
;       R0 - Máscara
;       R1 - Endereço do periférico das linhas
;       R2 - Endereço do periférico das colunas 
;       R3 - Tamanho de teclado 
;       R4 - Coordenada da linha do tecladp
;       R5 - Coordenada da coluna do teclado
;       R6 - Valor da tecla pressionada
; **********************************************************************
teclado:
    PUSH    R0
    PUSH    R1
    PUSH    R2
    PUSH    R3
    PUSH    R4
    PUSH    R5
    PUSH    R11
    ; inicializações
    MOV     R0, MASCARA    ; para isolar os 4 bits de menor peso, ao ler as colunas do teclado
    MOV     R1, TEC_LIN    ; endere�o do perif�rico das linhas
    MOV     R2, TEC_COL    ; endere�o do perif�rico das colunas
    MOV     R3, TAM_TAB    ; registo auxiliar que guarda o limite da tabela
    
    inicio_teclado:
        reniciar:
            MOV     R4, 1           ; inicia a verifica��o na linha 1
    
    ciclo_espera_tecla:             ; neste ciclo espera-se at� uma tecla ser premida
        CMP     R4, R3              ; verfica se excedeu
        JZ      reniciar
        MOVB    [R1], R4            ; escrever no perif�rico de sa�da (linhas)
        MOVB    R5, [R2]            ; ler do perif�rico de entrada (colunas)
        AND     R5, R0              ; elimina bits para al�m dos bits 0-3
        SHL     R4, 1               ; passa para a linha seguinte
        CMP     R5, 0               ; h� tecla premida?
        JZ      ciclo_espera_tecla  ; se nenhuma tecla premida, repete
        
    SHR     R4, 1                      ; retoma o valor 
    CALL    calcula_tecla
    ve_qual_acao:
        CMP     R6, TEC_BAIXO
        JZ      chama_move_meteoro
        MOV     R7, 1
        CMP     R6, TEC_DIREITA
        JZ      chama_move_nave
        CMP     R6, TEC_AUMENTA
        JZ      chama_altera_energia
        MOV     R7, -1
        CMP     R6, TEC_DIMINUI
        JZ      chama_altera_energia
        CMP     R6, TEC_ESQUERDA
        JZ      chama_move_nave
    
    chama_move_nave:
        MOV     R11, ATRASO
        CALL    atraso
        CALL    acao_move_nave
        JMP     reniciar
    chama_move_meteoro:
        CALL    acao_move_meteoro_inimigo
        JMP     ha_tecla
    chama_altera_energia:
        CALL    altera_energia
        ha_tecla:                 ; neste ciclo espera-se at� NENHUMA tecla estar premida
        MOVB    [R1], R4      ; escrever no perif�rico de sa�da (linhas)
        MOVB    R5, [R2]      ; ler do perif�rico de entrada (colunas)
        AND     R5, R0        ; elimina bits para al�m dos bits 0-3
        CMP     R5, 0         ; h� tecla premida?
        JZ      reniciar      ; repete ciclo
        JMP     ha_tecla      ; se ainda houver uma tecla premida, espera at� n�o haver

    POP     R11
    POP     R5
    POP     R4
    POP     R3
    POP     R2
    POP     R1
    POP     R0

    RET


; **********************************************************************
;  CALCULA TECLA
;  ARGUMENTOS:
;       R4 - Coordenada da linha do teclado
;       R5 - Coordenada da coluna do teclado
;  RETORNO:
;       R6 - Valor da tecla pressionada
; **********************************************************************
calcula_tecla:
    PUSH    R4
    PUSH    R5
    MOV     R6, -1                  ; indice da linha, come�a em 1 pq vai de 0 a 3

        calcula_linha:              ; ciclo que calcula o indice da linha
            SHR     R4, 1           ; desloca um bit para direita 
            INC     R6              ; soma 1 ao indice da linha 
            CMP     R4, 0           ; registo da linha já chegou a 0?
            JNZ     calcula_linha   ; se não volta ao ciclo até a chegar, de modo a obter o indice

    SHL     R6, 2
    DEC     R6                      ; indice da linha
        calcula_coluna:             ; ciclo que vai calcular o indice da linha
            SHR     R5, 1           ; desloca um bit para a direita
            INC     R6              ; soma 1 ao indice da linha 
            CMP     R5, 0           ; vê se ja chegamos ao fim
            JNZ     calcula_coluna  ; repete o ciclo até chegarmos
            
    POP     R5
    POP     R4
    RET


; **********************************************************************
;  ACAO_MOVE_NAVE
;  ARGUMENTO:
;       R6 - Valor da tecla precionada 
;  retorna
; **********************************************************************
acao_move_nave:
    PUSH    R0
    PUSH    R1
    PUSH    R2
    move_nave:
        MOV     R0, [coordenadas_nave]          ;define coordenada da linha
        MOV     R1, [coordenadas_nave + 2]      ;define a coordenada da coluna
        MOV     R2, nave
        CALL    testa_limites_nave
        CMP     R7, 0
        JZ      fim_acao_move_nave
        CALL    apaga_boneco
        ADD     R1, R7
        CALL    desenha_objeto
        MOV     [coordenadas_nave + 2], R1

    
fim_acao_move_nave:   
    POP     R2
    POP     R1
    POP     R0
    RET

; **********************************************************************
;  ACAO_MOVE_METEORO_INIMIGO
;  ARGUMENTO:
;       R6 - Valor da tecla precionada 
;  retorna
; **********************************************************************
acao_move_meteoro_inimigo:
    PUSH    R0
    PUSH    R1
    PUSH    R2
    PUSH    R10

    move_inimigo:
        MOV     R0, [coordenadas_meteoro_inimigo]          ;define coordenada da linha
        MOV     R1, [coordenadas_meteoro_inimigo + 2]      ;define a coordenada da coluna
        MOV     R2, meteoro_inimigo
        CALL    apaga_boneco
        ADD     R0, 1
        CALL    testa_limites_meteoros
        MOV     R10, 0
        CALL    toca_som
        CALL    desenha_objeto
        MOV     [coordenadas_meteoro_inimigo], R0


fim_move_meteoro_inimigo:
    POP     R10
    POP     R2
    POP     R1
    POP     R0
    RET






; **********************************************************************
;  TOCA_FUNDO
;  ARGUMENTO:
;       R10 - Valor do som a reproduzir
;  retorna
; **********************************************************************
toca_som:
    MOV [TOCA_SOM], R10
    RET

; **********************************************************************
;  DESENHA_FUNDO
;  ARGUMENTO:
;       R1 - Valor do cenário a desenhar 
;  retorna
; **********************************************************************
desenha_fundo:
    MOV     [SELECIONA_CENARIO_FUNDO], R1	; seleciona o cenário de fundo
    RET

; **********************************************************************
;  ATUALIZA_ENERGIA
;  ARGUMENTO:
;       R11 - Valor do cenário a desenhar 
;  retorna
; **********************************************************************
atualiza_energia:
    MOV     [DISPLAYS], R11
    ret

; **********************************************************************
;   DESENHA_BONECO
;   ARGUMENTOS:
;       R0 - coordenada linha
;       R1 - coordenada coluna
;       R2 - endereço da tabela do boneco
;   REGISTOS AUXILIARES USADOS
;       R3 - altura do boneco 
;       R4 - largura do boneco
;       R5 - cores dos pixeis
;       R6 - auxiliar de R4
;       R7 - auxiliar de R1
; ********************************************************************** 

desenha_objeto:
    PUSH    R0
    PUSH    R2
    PUSH    R3
    PUSH    R4
    PUSH    R5
    PUSH    R6
    PUSH    R7
    
    
    MOV     R3, [R2]                        ;obtem a altura do boneco 
    ADD     R2, 2                           ;passa para a proximo elemento da tabela
    MOV     R4, [R2]                        ;obtem a largura do boneco
    ADD     R2, 2                           ;passa para a proximo elemento da tabela
        desenha_linha:                          ; desenha uma linha do bonecoco
            MOV     R6, R4                      ; R6 variavél auxiliar de R4, para não perder o valor de R4
            MOV     R7, R1                      ; R7 variavél auxiliar de R1, para não perder o valor de R1
            
            desenha_pixel:                      ;desenha um pixel  
                MOV     R5, [R2]                ;vai buscar a tabela a cor do pixel
                CALL    escreve_pixel           ;desenha o pixel
                ADD     R2, 2                   ;endereço da cor do proximo pixel
                INC     R7                      ;incrementa a coordenada da coluna
                DEC     R6                      ;menos uma coluna desta linha para tratar 
                JNZ     desenha_pixel           ;enquanto nao escrevemos a linha toda escreve a proxima coluna

            INC R0                              ;passa para a linha segunite
            DEC R3                              ;menos uma linha para tratar
            JNZ desenha_linha                   ;enquanto nao desenhar as linhas todas escreve a proxima linha
    fim:                                        ;fim da rotina 
        POP     R7
        POP     R6
        POP     R5
        POP     R4
        POP     R3
        POP     R2
        POP     R0                                      
        RET                                     ;retorna

; **********************************************************************
;   APAGA_BONECO
;   ARGUMENTOS:
;       R0 - coordenada linha
;       R1 - coordenada coluna
;       R2 - endereço da tabela do boneco
;   REGISTOS AUXILIARES USADOS
;       R3 - altura do boneco 
;       R4 - largura do boneco
;       R5 - cores dos pixeis
;       R6 - auxiliar de R4
;       R7 - auxiliar de R1
; ********************************************************************** 
apaga_boneco:
    PUSH    R0
    PUSH    R2
    PUSH    R3
    PUSH    R4
    PUSH    R5
    PUSH    R6
    PUSH    R7
    MOV     R3, [R2]                        ;obtem a altura do boneco 
    ADD     R2, 2                           ;passa para a proximo elemento da tabela
    MOV     R4, [R2]                        ;obtem a largura do boneco
    MOV     R5, 0                           ;passa para a proximo elemento da tabela
        apaga_linha:                            ; desenha uma linha do bonecoco
            MOV     R6, R4                      ; R6 variavél auxiliar de R4, para não perder o valor de R4
            MOV     R7, R1                      ; R7 variavél auxiliar de R1, para não perder o valor de R1
            
            apaga_pixel:                        ;desenha um pixel  
                CALL    escreve_pixel           ;desenha o pixel
                INC     R7                      ;incrementa a coordenada da coluna
                DEC     R6                      ;menos uma coluna desta linha para tratar 
                JNZ     apaga_pixel             ;enquanto nao escrevemos a linha toda escreve a proxima coluna

            INC R0                              ;passa para a linha segunite
            DEC R3                              ;menos uma linha para tratar
            JNZ apaga_linha                     ;enquanto nao desenhar as linhas todas escreve a proxima linha

    POP     R7
    POP     R6
    POP     R5
    POP     R4
    POP     R3
    POP     R2
    POP     R0
    RET


; **********************************************************************
;   ESCREVE_PIXEL
;   ARGUMENTOS:
;       R0 - coordenada linha
;       R7 - coordenada coluna
;       R5 - cor do pixel
; ********************************************************************** 
escreve_pixel:
    MOV     [DEFINE_LINHA], R0      ;seleciona a linha  
    MOV     [DEFINE_COLUNA], R7     ;seleciona a coluna
    MOV     [DEFINE_PIXEL], R5      ;altera a cor do pixel da linha e da coluna selecionadas
    RET

; **********************************************************************
; ATRASO - Executa um ciclo para implementar um atraso.
; Argumentos:   R11 - valor que define o atraso
;
; **********************************************************************
atraso:
	PUSH	R11
ciclo_atraso:
	SUB	R11, 1
	JNZ	ciclo_atraso
	POP	R11
	RET

; **********************************************************************
; TESTA_LIMITES - Testa se o boneco chegou aos limites do ecrã e nesse caso
;			   impede o movimento (força R7 a 0)
; Argumentos:	
;           R1 - coluna em que o objeto está
;			R2 - endereço da nave
;			R7 - sentido de movimento do boneco (valor a somar à coluna
;				em cada movimento: +1 para a direita, -1 para a esquerda)
;
;REGISTOS AUXILIARES USADOS:
;           R6 - Largura da nave
;
; Retorna: 	R7 - 0 se já tiver chegado ao limite, inalterado caso contrário	
; **********************************************************************
testa_limites_nave:
	PUSH	R5
	PUSH	R6
    MOV     R6, [R2 + 2]
    testa_limite_esquerdo:		; vê se o boneco chegou ao limite esquerdo
    	MOV	R5, MIN_COLUNA
    	CMP	R1, R5
    	JGT	testa_limite_direito
    	CMP	R7, 0			; passa a deslocar-se para a direita
    	JGE	sai_testa_limites_nave
    	JMP	impede_movimento	; entre limites. Mantém o valor do R7
    testa_limite_direito:		; vê se o boneco chegou ao limite direito
    	ADD	R6, R1			; posição a seguir ao extremo direito do boneco
    	MOV	R5, MAX_COLUNA
    	CMP	R6, R5
    	JLE	sai_testa_limites_nave	; entre limites. Mantém o valor do R7
    	CMP	R7, 0			; passa a deslocar-se para a direita
    	JGT	impede_movimento
    	JMP	sai_testa_limites_nave
    impede_movimento:
    	MOV	R7, 0			; impede o movimento, forçando R7 a 0
sai_testa_limites_nave:	
	POP	R6
	POP	R5
	RET

; **********************************************************************
; TESTA_LIMITES - Testa se o boneco chegou aos limites do ecrã e nesse caso
;			   impede o movimento (força R7 a 0)
; Argumentos:	
;           R0 - linha em que o objeto está
;			R2 - endereço do meteoro
;			R7 - 
;
;REGISTOS AUXILIARES USADOS:
;           R6 - Altura do meteoro
;
; Retorna: 	R7 - 0 se já tiver chegado ao limite, inalterado caso contrário	
; **********************************************************************
testa_limites_meteoros:
    PUSH	R5
	PUSH	R6
    MOV     R6, [R2]

    testa_limite_baixo:
        MOV	    R5, MAX_LINHA
        CMP     R0, R5
        JLE	    sai_testa_limites_meteoros	; entre limites. Mantém o valor do R7

    renicia_meteoro:
        MOV R0, 0 

sai_testa_limites_meteoros:	
	POP	R6
	POP	R5
	RET

        
altera_energia:
    PUSH    R11
    MOV     R11, [energia]
    ADD     R11, R7
    MOV     [energia], R11
    CALL    atualiza_energia
    POP     R11
    RET



