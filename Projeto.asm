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
APAGA_ECRÃ	 		        EQU 6002H   ; endereço do comando para apagar todos os pixels já desenhados
SELECIONA_CENARIO_FUNDO     EQU 6042H   ; endereço do comando para selecionar uma imagem de fundo
DISPLAYS                    EQU 0A000H  ; endere�o dos displays de 7 segmentos (perif�rico POUT-1)
TEC_LIN                     EQU 0C000H  ; endere�o das linhas do teclado (perif�rico POUT-2)
TEC_COL                     EQU 0E000H  ; endere�o das colunas do teclado (perif�rico PIN)
MASCARA                     EQU 0FH     ; para isolar os 4 bits de menor peso, ao ler as colunas do teclado
TAM_TAB                     EQU 0010H   ; 
LARGURA		                EQU	5		; largura do boneco
ALTURA                      EQU 4
COR_PIXEL		            EQU	0FF00H	; cor do pixel
TEC_ESQUERDA                EQU 0
TEC_DIREIRA                 EQU 2

; **********************************************************************
; * Dados 
; **********************************************************************
PLACE   0500H ; para escrever as variaveis
    STACK   100H

SP_inicial:

nave:	WORD ALTURA, LARGURA
        WORD 0, 0, COR_PIXEL, 0, 0
        WORD COR_PIXEL, 0, COR_PIXEL, 0, COR_PIXEL
        WORD COR_PIXEL, COR_PIXEL, COR_PIXEL, COR_PIXEL, COR_PIXEL
        WORD 0, COR_PIXEL, 0, COR_PIXEL, 0
		
coordenadas_nave:	WORD 28, 31  ; coordenadas iniciais da nave

; **********************************************************************
; * Código
; **********************************************************************
PLACE   0 ; para escrever o codigo 

inicia_jogo:
    MOV     SP, SP_inicial
    MOV     [APAGA_AVISO], R1	; apaga o aviso de nenhum cenário selecionado (o valor de R1 não é relevante)
    MOV     [APAGA_ECRÃ], R1	; apaga todos os pixels já desenhados (o valor de R1 não é relevante)
	MOV     R1, 0			    ; cenário de fundo número 0
    CALL    desenha_fundo
    mostra_nave:
        MOV     R0, [coordenadas_nave]          ;define coordenada da linha
        MOV     R1, [coordenadas_nave + 2]      ;define a coordenada da coluna
        MOV     R2, nave
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
;       R11 - Endereço do display
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
    MOV     R11, DISPLAYS  ; endere�o do perif�rico dos displays
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
        
    SHR  R4, 1                      ; retoma o valor 
    CALL calcula_tecla
    MOV [R11], R6
    CALL acoes
    ha_tecla:                 ; neste ciclo espera-se at� NENHUMA tecla estar premida
        MOVB    [R1], R4      ; escrever no perif�rico de sa�da (linhas)
        MOVB    R5, [R2]      ; ler do perif�rico de entrada (colunas)
        AND     R5, R0        ; elimina bits para al�m dos bits 0-3
        CMP     R5, 0         ; h� tecla premida?
        JNZ     ha_tecla      ; se ainda houver uma tecla premida, espera at� n�o haver
        JMP     reniciar      ; repete ciclo

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
;  ACOES
;  ARGUMENTO:
;       R6 - Valor da tecla precionada 
;  retorna
; **********************************************************************
acoes:
    PUSH    R0
    PUSH    R1
    PUSH    R2
    ciclo_acoes:
        CMP     R6, 0
        JZ      move_esquerda
    
    move_esquerda:
        MOV     R0, [coordenadas_nave]          ;define coordenada da linha
        MOV     R1, [coordenadas_nave + 2]      ;define a coordenada da coluna
        MOV     R2, nave
        CALL    apaga_boneco
        DEC     R1
        CALL desenha_objeto
        MOV [coordenadas_nave + 2], R1
    
    POP     R2
    POP     R1
    POP     R0
    RET


desenha_fundo:
    MOV     [SELECIONA_CENARIO_FUNDO], R1	; seleciona o cenário de fundo
    RET

; **********************************************************************
;   DESENHA_BONECO
;   ARGUMENTOS:
;       R0 - coordenada linha
;       R1 - coordenada coluna
;       R2 - endereço da tabela do boneco
;   REGISTOS AUXILIARES USADOS
;   R3 - altura do boneco 
;   R4 - largura do boneco
;   R5 - cores dos pixeis
;   R6 - auxiliar de R4
;   R7 - auxiliar de R1
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




