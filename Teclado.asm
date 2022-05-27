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
DISPLAYS   EQU 0A000H  ; endere�o dos displays de 7 segmentos (perif�rico POUT-1)
TEC_LIN    EQU 0C000H  ; endere�o das linhas do teclado (perif�rico POUT-2)
TEC_COL    EQU 0E000H  ; endere�o das colunas do teclado (perif�rico PIN)
MASCARA    EQU 0FH     ; para isolar os 4 bits de menor peso, ao ler as colunas do teclado
TAM_TAB    EQU 0010H   ; 
LARGURA		                EQU	5			; largura do boneco
COR_PIXEL		            EQU	0FF00H		; cor do pixel

; **********************************************************************
; * Dados 
; **********************************************************************
PLACE 2000H ; para escrever as variaveis
    STACK 100H

SP_inicial:

nave:	WORD LARGURA, LARGURA
        WORD 0, 0, COR_PIXEL, 0, 0
        WORD 0, COR_PIXEL, COR_PIXEL, COR_PIXEL, 0
        WORD COR_PIXEL, COR_PIXEL, COR_PIXEL, COR_PIXEL, COR_PIXEL
        WORD 0, 0, COR_PIXEL, 0, 0
        WORD 0, COR_PIXEL, 0, COR_PIXEL, 0
		
coordenadas_nave:	STRING 27, 29   ; coordenadas iniciais da nave

; **********************************************************************
; * Código
; **********************************************************************
PLACE 0 ; para escrever o codigo 

inicia_jogo:
    MOV  SP, SP_inicial
    MOV  [APAGA_AVISO], R1	; apaga o aviso de nenhum cenário selecionado (o valor de R1 não é relevante)
    MOV  [APAGA_ECRÃ], R1	; apaga todos os pixels já desenhados (o valor de R1 não é relevante)
	MOV     R1, 0			; cenário de fundo número 0
    CALL desenha_fundo
    CALL teclado
inicio:		
; inicializações
    MOV  R2, TEC_LIN   ; endere�o do perif�rico das linhas
    MOV  R3, TEC_COL   ; endere�o do perif�rico das colunas
    MOV  R4, DISPLAYS  ; endere�o do perif�rico dos displays
    MOV  R5, MASCARA   ; para isolar os 4 bits de menor peso, ao ler as colunas do teclado

; corpo principal do programa
MOV  R7, TAM_TAB                ; registo auxiliar para o CMP da linha 40

reniciar:
    MOV R6, 1              ; inicia a verifica��o na linha 1
    
    espera_tecla:          ; neste ciclo espera-se at� uma tecla ser premida
        CMP  R6, R7        ; verfica se excedeu
        JZ   reniciar
        MOV  R1, R6        ; testar a linha i 
        MOVB [R2], R1      ; escrever no perif�rico de sa�da (linhas)
        MOVB R0, [R3]      ; ler do perif�rico de entrada (colunas)
        AND  R0, R5        ; elimina bits para al�m dos bits 0-3
        SHL  R6, 1         ; passa para a linha seguinte
        CMP  R0, 0         ; h� tecla premida?
        JZ   espera_tecla  ; se nenhuma tecla premida, repete
                           ; vai mostrar a linha e a coluna da tecla
        SHL  R1, 4         ; coloca linha no nibble high
        OR   R1, R0        ; junta coluna (nibble low)
        MOVB [R4], R1      ; escreve linha e coluna nos displays
        SHR R6, 1          ; como passamos para a linha seguinte, volta para a linha anterior
                           ; vai obter o valor da tecla
        
        MOV R8, R6         ; registo R8 guarda a linha
        MOV R9, -1         ; indice da linha, come�a em 1 pq vai de 0 a 3
        calcula_linha:     ; ciclo que calcula o indice da linha
            SHR R8, 1      ; desloca um bit para direita 
            ADD R9, 1      ; soma 1 ao indice da linha 
            CMP R8, 0      ; registo da linha j� chegou a 0?
            JNZ calcula_linha ; se n�o volta ao ciclo at� a chegar, de modo a obter o indice
         
        MOV R8, R0         ; registo R8 guarda a coluna
        MOV R10, -1        ; indice da linha
        calcula_coluna:    ; ciclo que vai calcular o indice da linha
            SHR R8, 1      ; desloca um bit para a direita
            ADD R10, 1     ; soma 1 ao indice da linha 
            CMP R8, 0      ; v� se ja chegamos ao fim
            JNZ calcula_coluna  ; repete o ciclo at� chegarmos
            
        SHL R9, 2          ; multiplcamos o indice da linha por 4
        ADD R9, R10        ; somamos ao indice da coluna
                           
        
        
ha_tecla:              ; neste ciclo espera-se at� NENHUMA tecla estar premida
    MOV  R1, R6         ; testar a linha 4  (R1 tinha sido alterado)
    MOVB [R2], R1      ; escrever no perif�rico de sa�da (linhas)
    MOVB R0, [R3]      ; ler do perif�rico de entrada (colunas)
    AND  R0, R5        ; elimina bits para al�m dos bits 0-3
    CMP  R0, 0         ; h� tecla premida?
    JNZ  ha_tecla      ; se ainda houver uma tecla premida, espera at� n�o haver
    JMP  reniciar        ; repete ciclo



