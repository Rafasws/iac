; *********************************************************************
; * IST-UL
; * Modulo:    lab3.asm
; * Descrição: Exemplifica o acesso a um teclado.
; *            Lê uma linha do teclado, verificando se há alguma tecla
; *            premida nessa linha.
; *
; * Nota: Observe a forma como se acede aos periféricos de 8 bits
; *       através da instrução MOVB
; *********************************************************************

; **********************************************************************
; * Constantes
; **********************************************************************
; ATENÇÃO: constantes hexadecimais que comecem por uma letra devem ter 0 antes.
;          Isto não altera o valor de 16 bits e permite distinguir números de identificadores
DISPLAYS   EQU 0A000H  ; endereço dos displays de 7 segmentos (periférico POUT-1)
TEC_LIN    EQU 0C000H  ; endereço das linhas do teclado (periférico POUT-2)
TEC_COL    EQU 0E000H  ; endereço das colunas do teclado (periférico PIN)
MASCARA    EQU 0FH     ; para isolar os 4 bits de menor peso, ao ler as colunas do teclado
TAM_TAB    EQU 0010H   ; 


; **********************************************************************
; * Código
; **********************************************************************
PLACE      0
inicio:		
; inicializações
    MOV  R2, TEC_LIN   ; endereço do periférico das linhas
    MOV  R3, TEC_COL   ; endereço do periférico das colunas
    MOV  R4, DISPLAYS  ; endereço do periférico dos displays
    MOV  R5, MASCARA   ; para isolar os 4 bits de menor peso, ao ler as colunas do teclado

; corpo principal do programa
MOV  R7, TAM_TAB                ; registo auxiliar para o CMP da linha 40

reniciar:
    MOV R6, 1              ; inicia a verificação na linha 1
    
    espera_tecla:          ; neste ciclo espera-se até uma tecla ser premida
        CMP  R6, R7        ; verfica se excedeu
        JZ   reniciar
        MOV  R1, R6        ; testar a linha i 
        MOVB [R2], R1      ; escrever no periférico de saída (linhas)
        MOVB R0, [R3]      ; ler do periférico de entrada (colunas)
        AND  R0, R5        ; elimina bits para além dos bits 0-3
        SHL  R6, 1         ; passa para a linha seguinte
        CMP  R0, 0         ; há tecla premida?
        JZ   espera_tecla  ; se nenhuma tecla premida, repete
                           ; vai mostrar a linha e a coluna da tecla
        SHL  R1, 4         ; coloca linha no nibble high
        OR   R1, R0        ; junta coluna (nibble low)
        MOVB [R4], R1      ; escreve linha e coluna nos displays
        SHR R6, 1          ; como passamos para a linha seguinte, volta para a linha anterior
                           ; vai obter o valor da tecla
        
        MOV R8, R6         ; registo R8 guarda a linha
        MOV R9, -1         ; indice da linha, começa em 1 pq vai de 0 a 3
        calcula_linha:     ; ciclo que calcula o indice da linha
            SHR R8, 1      ; desloca um bit para direita 
            ADD R9, 1      ; soma 1 ao indice da linha 
            CMP R8, 0      ; registo da linha já chegou a 0?
            JNZ calcula_linha ; se não volta ao ciclo até a chegar, de modo a obter o indice
         
        MOV R8, R0         ; registo R8 guarda a coluna
        MOV R10, -1        ; indice da linha
        calcula_coluna:    ; ciclo que vai calcular o indice da linha
            SHR R8, 1      ; desloca um bit para a direita
            ADD R10, 1     ; soma 1 ao indice da linha 
            CMP R8, 0      ; vê se ja chegamos ao fim
            JNZ calcula_coluna  ; repete o ciclo até chegarmos
            
        SHL R9, 2          ; multiplcamos o indice da linha por 4
        ADD R9, R10        ; somamos ao indice da coluna
                           
        
        
ha_tecla:              ; neste ciclo espera-se até NENHUMA tecla estar premida
    MOV  R1, R6         ; testar a linha 4  (R1 tinha sido alterado)
    MOVB [R2], R1      ; escrever no periférico de saída (linhas)
    MOVB R0, [R3]      ; ler do periférico de entrada (colunas)
    AND  R0, R5        ; elimina bits para além dos bits 0-3
    CMP  R0, 0         ; há tecla premida?
    JNZ  ha_tecla      ; se ainda houver uma tecla premida, espera até não haver
    JMP  reniciar        ; repete ciclo



