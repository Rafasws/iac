; *********************************************************************
; * IST-UL
; * Entrega Intremédia:   grupo12.asm
; * Descrição: O objetivo deste projeto consiste em concretizar algumas
;           funcionalidades de um jogo, entre as quais:
;               -Mover a nave para a esquerda: tecla 0
;               -Mover a nave para a direita: tecla 2
;               -Mover meteoro enimigo para baixo: tecla 5
;               -Incrementar o display da energia: tecla 3
;               -Decrementar o display da energia: tecla 7
;           Foi implementado um sistema de limites do ecrã, que faz com
;           que a nave não sai do mesmo, e que o meteoro inimigo reapareça
;           na posição inicial.
;           Ainda foi desenvolvido um sistema de anti-colisão entre a nave
;           e o meteoro inimigo.
; *
; * Autores:
;       André Morgado, 92737
;       Nicole Figueiredo, 96899
;       Rafael Ferreira, 97343
; *********************************************************************
;
; **********************************************************************
; * Constantes
; **********************************************************************
DEFINE_LINHA                EQU 600AH   ; endereço do comando para defenir a linha
DEFINE_COLUNA               EQU 600CH   ; endereço do comando para defenir a coluna
DEFINE_PIXEL                EQU 6012H   ;endereço do comando para escrever um pixel
APAGA_AVISO     		    EQU 6040H   ; endereço do comando para apagar o aviso de nenhum cenário selecionado
APAGA_ECRA		            EQU 6002H   ; endereço do comando para apagar todos os pixels já desenhados
SELECIONA_CENARIO_FUNDO     EQU 6042H   ; endereço do comando para selecionar uma imagem de fundo
DISPLAYS                    EQU 0A000H  ; endere�o dos displays de 7 segmentos (perif�rico POUT-1)
TEC_LIN                     EQU 0C000H  ; endere�o das linhas do teclado (perif�rico POUT-2)
TEC_COL                     EQU 0E000H  ; endere�o das colunas do teclado (perif�rico PIN)
TOCA_SOM				    EQU 605AH   ; endereço do comando para tocar um som
MASCARA                     EQU 0FH     ; para isolar os 4 bits de menor peso, ao ler as colunas do teclado
TAM_TAB                     EQU 0010H   ; tamanho do teclado
LARGURA_NAVE		        EQU	5		; largura da nave 
ALTURA_NAVE                 EQU 4       ; altura da nave 
LARGURA_INICIO_1            EQU 1
ALTURA_INICIO_1             EQU 1
LARGURA_INICIO_2            EQU 2
ALTURA_INICIO_2             EQU 2
LARGURA_METEORO_1           EQU 3       ; largura dos meteoros
ALTURA_METEORO_1            EQU 3       ; altura dos meteoros 
LARGURA_METEORO_2           EQU 4       ; largura dos meteoros
ALTURA_METEORO_2            EQU 4      ; altura dos meteoros 
LARGURA_METEORO_3           EQU 5       ; largura dos meteoros
ALTURA_METEORO_3            EQU 5       ; altura dos meteoros

LIM_FASE_1                  EQU 2
LIM_FASE_2                  EQU 5 
LIM_FASE_3                  EQU 9
LIM_FASE_4                  EQU 14
COR_PIXEL		            EQU	0FFF0H	; cor do pixel nave (amarelo)
COR_PIXEL_INIMIGO           EQU 0FF00H  ; cor do pixel de meteoros inimigos (vermelho)
COR_PIXEL_BOM               EQU 0F0F0H
COR_PIXEL_INICIO            EQU 0F888H
COR_PIXEL_MORTO             EQU 0FFEFH
COR_PIXEL_MISSIL            EQU 0F808H
TEC_0                       EQU 0       ; tecla 0
TEC_1                       EQU 1       ; tecla 1
TEC_2                       EQU 2       ; tecla 2
TEC_C                       EQU 12       ; tecla 5
TEC_D                       EQU 13       ; tecla 3
TEC_E                       EQU 14       ; tecla 7
ATRASO			            EQU	3000H	; atraso para limitar a velocidade de movimento do boneco
MIN_COLUNA                  EQU 0       ; coordenada minima de coluna
MAX_COLUNA                  EQU 63      ; coordenada maxima de coluna
MIN_LINHA                   EQU 0       ; coordenada minima de linha
MAX_LINHA                   EQU 31      ; coordenada maxima de linha

; **********************************************************************
; * Dados 
; **********************************************************************
PLACE       1000H                                                     ; para escrever as variaveis

; Reserva do espaço para as pilhas dos processos
	STACK 100H			; espaço reservado para a pilha do processo "programa principal"
SP_inicial_prog_princ:		; este é o endereço com que o SP deste processo deve ser inicializado
							
	STACK 100H			; espaço reservado para a pilha do processo "teclado"
SP_inicial_teclado:			; este é o endereço com que o SP deste processo deve ser inicializado
							
; SP inicial de cada processo "boneco"
	STACK 100H			; espaço reservado para a pilha do processo "boneco", instância 0
SP_inicial_inimigo:		; este é o endereço com que o SP deste processo deve ser inicializado      

    STACK 100H
SP_inicial_rover:

    STACK 100H

SP_inicial_missil:

energia: WORD 100                                                     ; endereço para energia da nave

nave:	WORD ALTURA_NAVE, LARGURA_NAVE                                ; endereço que define a nave  
        WORD 0, 0, COR_PIXEL, 0, 0
        WORD COR_PIXEL, 0, COR_PIXEL, 0, COR_PIXEL
        WORD COR_PIXEL, COR_PIXEL, COR_PIXEL, COR_PIXEL, COR_PIXEL
        WORD 0, COR_PIXEL, 0, COR_PIXEL, 0
		
coordenadas_nave:	WORD 28, 31  ; coordenadas iniciais da nave       ; endereço com as coordenadas da nave

meteoro_inicio_1: WORD ALTURA_INICIO_1, LARGURA_INICIO_1
                    WORD COR_PIXEL_INICIO
meteoro_inicio_2: WORD ALTURA_INICIO_2, LARGURA_INICIO_2
                    WORD COR_PIXEL_INICIO, COR_PIXEL_INICIO
                    WORD COR_PIXEL_INICIO, COR_PIXEL_INICIO
meteoro_bom_1:  WORD ALTURA_METEORO_1, LARGURA_METEORO_1
                    WORD 0, COR_PIXEL_BOM, 0
                    WORD COR_PIXEL_BOM, COR_PIXEL_BOM, COR_PIXEL_BOM
                    WORD 0, COR_PIXEL_BOM, 0
meteoro_bom_2:  WORD ALTURA_METEORO_2, LARGURA_METEORO_2
                    WORD 0, COR_PIXEL_BOM, COR_PIXEL_BOM, 0
                    WORD COR_PIXEL_BOM, COR_PIXEL_BOM, COR_PIXEL_BOM, COR_PIXEL_BOM
                    WORD COR_PIXEL_BOM, COR_PIXEL_BOM, COR_PIXEL_BOM, COR_PIXEL_BOM
                    WORD 0, COR_PIXEL_BOM, COR_PIXEL_BOM, 0
meteoro_bom_3:    WORD ALTURA_METEORO_3, LARGURA_METEORO_3
                    WORD 0, COR_PIXEL_BOM, COR_PIXEL_BOM, COR_PIXEL_BOM, 0
                    WORD COR_PIXEL_BOM, COR_PIXEL_BOM, COR_PIXEL_BOM, COR_PIXEL_BOM, COR_PIXEL_BOM
                    WORD COR_PIXEL_BOM, COR_PIXEL_BOM, COR_PIXEL_BOM, COR_PIXEL_BOM, COR_PIXEL_BOM
                    WORD COR_PIXEL_BOM, COR_PIXEL_BOM, COR_PIXEL_BOM, COR_PIXEL_BOM, COR_PIXEL_BOM
                    WORD 0, COR_PIXEL_BOM, COR_PIXEL_BOM, COR_PIXEL_BOM, 0
meteoro_inimigo_1:  WORD ALTURA_METEORO_1, LARGURA_METEORO_1
                    WORD COR_PIXEL_INIMIGO, 0, COR_PIXEL_INIMIGO
                    WORD 0, COR_PIXEL_INIMIGO, 0
                    WORD COR_PIXEL_INIMIGO, 0, COR_PIXEL_INIMIGO
meteoro_inimigo_2:  WORD ALTURA_METEORO_2, LARGURA_METEORO_2
                    WORD COR_PIXEL_INIMIGO, 0, 0, COR_PIXEL_INIMIGO
                    WORD COR_PIXEL_INIMIGO, 0, 0, COR_PIXEL_INIMIGO
                    WORD 0, COR_PIXEL_INIMIGO, COR_PIXEL_INIMIGO, 0
                    WORD COR_PIXEL_INIMIGO, 0, 0, COR_PIXEL_INIMIGO
meteoro_inimigo_3:  WORD ALTURA_METEORO_3, LARGURA_METEORO_3
                    WORD COR_PIXEL_INIMIGO, 0, 0, 0, COR_PIXEL_INIMIGO
                    WORD COR_PIXEL_INIMIGO, 0, COR_PIXEL_INIMIGO, 0, COR_PIXEL_INIMIGO
                    WORD 0, COR_PIXEL_INIMIGO, COR_PIXEL_INIMIGO, COR_PIXEL_INIMIGO, 0
                    WORD COR_PIXEL_INIMIGO, 0, COR_PIXEL_INIMIGO, 0, COR_PIXEL_INIMIGO
                    WORD COR_PIXEL_INIMIGO, 0, 0, 0, COR_PIXEL_INIMIGO

meteoro_morto: WORD ALTURA_METEORO_3, LARGURA_METEORO_3
                    WORD 0, COR_PIXEL_MORTO, 0, COR_PIXEL_MORTO, 0
                    WORD COR_PIXEL_MORTO, 0, COR_PIXEL_MORTO, 0, COR_PIXEL_MORTO
                    WORD 0, COR_PIXEL_MORTO, 0, COR_PIXEL_MORTO, 0
                    WORD COR_PIXEL_MORTO, 0, COR_PIXEL_MORTO, 0, COR_PIXEL_MORTO
                    WORD 0, COR_PIXEL_MORTO, 0, COR_PIXEL_MORTO, 0

missil: WORD ALTURA_INICIO_1, LARGURA_INICIO_1
            WORD COR_PIXEL_MISSIL
coordenadas_meteoro_inimigo: WORD 0, 44                               ; endereço com as coordenadas do inimigo

tab:
	WORD rot_int_0			; rotina de atendimento da interrupção 0
    WORD rot_int_1			; rotina de atendimento da interrupção 0
    WORD rot_int_2			; rotina de atendimento da interrupção 0
    WORD rot_int_3			; rotina de atendimento da interrupção 0
    
lock_inimigo:
    LOCK 0

lock_rover:
    LOCK 0

lock_teclado:           ; LOCK para o teclado comunicar aos restantes processos que tecla detetou
    LOCK 0
lock_teclado_continuo:
    LOCK 0
lock_missil:
    LOCK 0

lock_dispara:
    LOCK 0

; **********************************************************************
; * Código
; **********************************************************************
PLACE   0                       ; para escrever o codigo 

inicio:
    MOV     SP, SP_inicial_prog_princ                       ; inicia a Stack
    MOV     BTE, tab			                            ; inicializa BTE (registo de Base da Tabela de Exceções)
                          
    MOV     [APAGA_AVISO], R1	                            ; apaga o aviso de nenhum cenário selecionado (o valor de R1 não é relevante)
    MOV     [APAGA_ECRA], R1	                            ; apaga todos os pixels já desenhados (o valor de R1 não é relevante)
	MOV     R1, 0			                                ; cenário de fundo número 0
    CALL    desenha_fundo           
    MOV     R0, MASCARA                                     ; para isolar os 4 bits de menor peso, ao ler as colunas do teclado
    MOV     R1, TEC_LIN                                     ; endereço do periférico das linhas
    MOV     R2, TEC_COL                                     ; endereço do periférico das colunas
    MOV     R4, 8
    
    espera_c:                                               ; neste ciclo espera-se a tecla c ser premida (em loop infinito)
        MOVB    [R1], R4                                    ; escrever no periférico de saída a linha do c
        MOVB    R5, [R2]                                    ; ler do periférico de entrada (colunas)
        AND     R5, R0                                      ; elimina bits para além dos bits 0-3
        CMP     R5, 1                                       ; há c premido?
        JNZ     espera_c                                    ; se c não foi premido, repete
    CALL    inicia_jogo

    EI0
    EI1
    EI3
    EI

    chama_inimigo:
        CALL    teclado
        CALL    acao_move_nave
        CALL    acao_move_inimigo
        
    fim_jogo: 
    YIELD                                              ; termina o jogo
        JMP     fim_jogo


; **********************************************************************
;  TECLADO - Função principal do jogo que lê o teclado, reconhece a
;            tecla premida, converte o valor da tecla num valor de 0 a F,
;            e a partir daí desencadeia a ação
;  ARGUMENTOS:
;       
;  RESGISTOS AUXILIARES USADOS:
;       R0 - Máscara
;       R1 - Endereço do periférico das linhas
;       R2 - Endereço do periférico das colunas 
;       R3 - Tamanho de teclado 
;       R4 - Coordenada da linha do tecladp
;       R5 - Coordenada da coluna do teclado
;       R6 - Valor da tecla pressionada
;       R7 - Valor do incremento (usado no movimento da nave e na alteração de energia)
;       R11 - Valor do atraso 
; **********************************************************************
PROCESS SP_inicial_teclado
teclado:                                                ; inicializações
    MOV     R0, MASCARA                         ; para isolar os 4 bits de menor peso, ao ler as colunas do teclado
    MOV     R1, TEC_LIN                         ; endereço do periférico das linhas
    MOV     R2, TEC_COL                         ; endereço do periférico das colunas
    MOV     R3, TAM_TAB                         ; registo auxiliar que guarda o limite da tabela
    
    inicio_teclado:
    reniciar:
        MOV     R4, 1                           ; inicia a verificação na linha 1
    
    ciclo_espera_tecla:                         ; neste ciclo espera-se até uma tecla ser premida (em loop infinito)
        YIELD
        CMP     R4, R3                          ; verfica se excedeu
        JZ      reniciar                        ; se excedeu voltamos a 1ª linha
        MOVB    [R1], R4                        ; escrever no periférico de saída (linhas)
        MOVB    R5, [R2]                        ; ler do periférico de entrada (colunas)
        AND     R5, R0                          ; elimina bits para além dos bits 0-3
        SHL     R4, 1                           ; passa para a linha seguinte
        CMP     R5, 0                           ; há tecla premida?
        JZ      ciclo_espera_tecla              ; se nenhuma tecla premida, repete
        
    SHR     R4, 1                               ; retoma o valor, pois multiplicamos o valor de R4 uma ultima vez antes de sair do ciclo de cima
    CALL    calcula_tecla                       ; calcula o valor da tecla para um valor de 0 a F
    MOV    [lock_teclado], R6 
        
    ha_tecla:                                   ; neste ciclo espera-se até NENHUMA tecla estar premida
        YIELD
        MOV     [lock_teclado_continuo], R6
        MOVB    [R1], R4                        ; escrever no periférico de saída (linhas)
        MOVB    R5, [R2]                        ; ler do periférico de entrada (colunas)
        AND     R5, R0                          ; elimina bits para além dos bits 0-3
        CMP     R5, 0                           ; há tecla premida?
        JZ      reniciar                        ; repete ciclo
        JMP     ha_tecla                        ; se ainda houver uma tecla premida, espera at� n�o haver

    
; **********************************************************************
;  ACAO_MOVE_NAVE - Recebe o valor de incremento (-1 ou +1 caso seja 
;                   para a esquerda ou para a direita, respetivamente) 
;                   e desloca a nave.
;  ARGUMENTO:
;       R7 - Valor do deslocamento 
;
;  RESGISTOS AUXILIARES USADOS:
;       R0 - Coordenada da linha
;       R1 - Coordenada da coluna
;       R2 - Endereço da nave
; **********************************************************************

PROCESS SP_inicial_rover
acao_move_nave:
        MOV     R9 , [lock_teclado]
        CMP     R9, TEC_1
        JZ      dispara
        move_nave_continua:

        MOV     R9 , [lock_teclado_continuo]
        CMP     R9, TEC_1
        JZ      dispara
        MOV     R0, [coordenadas_nave]          ; define coordenada da linha
        MOV     R1, [coordenadas_nave + 2]      ; define a coordenada da coluna
        MOV     R2, nave                        ; define o endereço da nave

        MOV     R7, -1
        CMP     R9, TEC_0
        JZ      move_nave

        MOV     R7, 1
        CMP     R9, TEC_2
        JZ      move_nave
        JMP     acao_move_nave


        ;CMP     R9, TEC_1
        ;JZ      dispara
        ;JMP     acao_move_nave

    dispara:
        CALL acao_missil
        JMP acao_move_nave
    move_nave:
        ;MOV     R8, 0                           ; define o deslocamento do meteoro enimigo a 0
        ;CALL    testa_choque                    ; chama o testa_choque
        ;CMP     R0, 0                           ; ve se choquou ou não
        ;JNZ     segue                           ; se não chocou segue
        ;MOV     R7, R0                          ; se chocou força o delocamento da nave a 0
        segue:
        MOV     R10, [lock_rover]
        CALL    testa_limites_nave              ; vê se o movimento é válido
        CMP     R7, 0                           ; é válido?
        JZ      acao_move_nave                  ; se não for não move a nave
        CALL    apaga_boneco                    ; se for, apaga a nave na posiçao antiga
        ADD     R1, R7                          ; atualiza as coordenada da coluna
        MOV     [coordenadas_nave + 2], R1      ; atualiza em memória as coordenada da coluna da nave
        CALL    desenha_objeto                  ; desenha nave na nova posição
        JMP     move_nave_continua




; **********************************************************************
; Processo
;
; BONECO - Processo que desenha um boneco e o move horizontalmente, com
;		 temporização marcada por uma interrupção.
;		 Este processo está preparado para ter várias instâncias (vários
;		 processos serem criados com o mesmo código), com o argumento (R11)
;		 a indicar o número de cada instância. Esse número é usado para
;		 indexar tabelas com informação para cada uma das instâncias,
;		 nomeadamente o valor inicial do SP (que tem de ser único para cada instaância)
;		 e o LOCK que lê à espera que a interrupção respetiva ocorra
;
; Argumentos:   R11 - número da instância do processo (cada instância fica
;				  com uma cópia independente dos registos, com os valores
;				  que os registos tinham na altura da criação do processo.
;				  O valor de R11 deve ser mantido ao longo de toda a vida do processo
;
; **********************************************************************

PROCESS SP_inicial_missil

acao_missil:
    MOV     R2, missil
    MOV     R0, [coordenadas_nave]          ; define coordenada da linha
    MOV     R1, [coordenadas_nave + 2]      ; define a coordenada da coluna
    DEC     R0
    ADD     R1, 2
    move_missil:
        CALL    desenha_objeto
        MOV     R10, [lock_missil]
        CALL    apaga_boneco
        SUB     R0, 1
        CMP     R0, 1
        JGE move_missil

    fim_acao_missil:
        YIELD
        JMP     fim_acao_missil
        

; **********************************************************************
;  INICIA_JOGO - Função que desenha as primeiras instancias dos bonecos
;  ARGUMENTOS:
;       
;  RESGISTOS AUXILIARES USADOS:
;       R0 - Linha da coordenada da nave/meteoro
;       R1 - Coluna da coordenada da nava/meteoro
;       R2 - Endereço da nave/meteoro
; **********************************************************************                                                          
inicia_jogo: 
    PUSH    R0
    PUSH    R1
    PUSH    R2    
    MOV     R1, 1
    CALL    desenha_fundo    
    mostra_nave:                                            ; desenha a nave na posicao inicial
        MOV     R0, [coordenadas_nave]                      ; define coordenada da linha
        MOV     R1, [coordenadas_nave + 2]                  ; define a coordenada da coluna
        MOV     R2, nave                                    ; vai buscar a definição da nave
        CALL    desenha_objeto                              ; desenha-a
    POP     R2
    POP     R1
    POP     R0
    RET

; **********************************************************************
; Processo
;
; BONECO - Processo que desenha um boneco e o move horizontalmente, com
;		 temporização marcada por uma interrupção.
;		 Este processo está preparado para ter várias instâncias (vários
;		 processos serem criados com o mesmo código), com o argumento (R11)
;		 a indicar o número de cada instância. Esse número é usado para
;		 indexar tabelas com informação para cada uma das instâncias,
;		 nomeadamente o valor inicial do SP (que tem de ser único para cada instaância)
;		 e o LOCK que lê à espera que a interrupção respetiva ocorra
;
; Argumentos:   R11 - número da instância do processo (cada instância fica
;				  com uma cópia independente dos registos, com os valores
;				  que os registos tinham na altura da criação do processo.
;				  O valor de R11 deve ser mantido ao longo de toda a vida do processo
;
; **********************************************************************

PROCESS SP_inicial_inimigo	; indicação de que a rotina que se segue é um processo,
						; com indicação do valor para inicializar o SP
						; NOTA - Como cada processo tem de ter uma pilha única,
						;	    mal comece a executar tem de reinicializar
						; 	    o SP com o valor correto, obtido de uma tabela
						;	    indexada por R11 (número da instância)
						
acao_move_inimigo:
        MOV     R0, [coordenadas_meteoro_inimigo]          ; define coordenada da linha
        MOV     R1, [coordenadas_meteoro_inimigo + 2]      ; define a coordenada da coluna
        
        MOV     R2, meteoro_inimigo_3
        MOV     R4, LIM_FASE_4
        CMP     R0, R4
        JGE     move_inimigo

        MOV     R2, meteoro_inimigo_2
        MOV     R4, LIM_FASE_3
        CMP     R0, R4
        JGE     move_inimigo

        MOV     R2, meteoro_inimigo_1
        MOV     R4, LIM_FASE_2
        CMP     R0, R4
        JGE     move_inimigo

        MOV     R2, meteoro_inicio_2
        MOV     R4, LIM_FASE_1
        CMP     R0, R4
        JGE     move_inimigo

        MOV     R2, meteoro_inicio_1

    move_inimigo:
       
        CALL    desenha_objeto                             ; desenha o meteoro na nova posição 
        MOV     R10, 0                                     ; toca quando move som
        CALL    toca_som 
        MOV     R3, [lock_inimigo]
        CALL    apaga_boneco                               ; apaga meteoro na posiçao antiga
        ;CALL    testa_choque                               ; chama o testa_choque
        CALL    testa_limites_meteoros                     ; vê se o meteoro está nos limites da grelha
        
        MOV     R7, 0                                      ; força o deslocamento da nave a 0
        MOV     R8, 1                                      ; define o delocaamento do meteoro
        ADD     R0, R8                                     ; incrementa a linha                           
        MOV     [coordenadas_meteoro_inimigo], R0          ; atualiza em memória o valor da coordenada da linha do meteoro
        JMP     acao_move_inimigo






; **********************************************************************
;  TOCA_SOM - Reproduz som.
;  ARGUMENTO:
;       R10 - Valor do som a reproduzir
; **********************************************************************
toca_som:
    MOV [TOCA_SOM], R10                    ; seleciona o som a reproduzir
    RET


; **********************************************************************
;  DESENHA_FUNDO - Desenha fundo no jogo
;  ARGUMENTO:
;       R1 - Valor do cenário a desenhar 
; **********************************************************************
desenha_fundo:
    MOV     [SELECIONA_CENARIO_FUNDO], R1	; seleciona o cenário de fundo
    RET

; **********************************************************************
;  CALCULA_TECLA - Recebe as coordenadas da linha e da coluna do teclado
;                  da tecla pressionada e devolve um valor de 0 a F.
;  ARGUMENTOS:
;       R4 - Coordenada da linha do teclado
;       R5 - Coordenada da coluna do teclado
;  RETORNO:
;       R6 - Valor da tecla pressionada
; **********************************************************************
calcula_tecla:
    PUSH    R4
    PUSH    R5
    MOV     R6, -1                  ; indice da linha, começa em -1 porque vai de 0 a 3

        calcula_linha:              ; ciclo que calcula o indice da linha
            SHR     R4, 1           ; desloca um bit para direita 
            INC     R6              ; soma 1 ao indice da linha 
            CMP     R4, 0           ; registo da linha já chegou a 0?
            JNZ     calcula_linha   ; se não volta ao ciclo até a chegar, de modo a obter o indice

    SHL     R6, 2                   ; multiplica o valor obtido por 4
    DEC     R6                      ; decrementa 1 porque o indice da coluna começa em 0
    
        calcula_coluna:             ; ciclo que vai calcular o indice da linha
            SHR     R5, 1           ; desloca um bit para a direita
            INC     R6              ; soma 1 ao indice da linha 
            CMP     R5, 0           ; vê se ja chegamos ao fim
            JNZ     calcula_coluna  ; repete o ciclo até chegarmos ao resultado
            
fim_calcula_tecla:
    POP     R5
    POP     R4
    RET

; **********************************************************************
;   DESENHA_BONECO - Rotina que recebes as coordenadas da posição do
;                    primeiro pixel a desenhar, e o endereço que define
;                    o boneco a desenha e desenha-o.
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
    
    MOV     R3, [R2]                            ; obtem a altura do boneco 
    ADD     R2, 2                               ; passa para a proximo elemento da tabela
    MOV     R4, [R2]                            ; obtem a largura do boneco
    ADD     R2, 2                               ; passa para a proximo elemento da tabela
        desenha_linha:                          ; desenha uma linha do bonecoco
            MOV     R6, R4                      ; R6 variavél auxiliar de R4, para não perder o valor de R4
            MOV     R7, R1                      ; R7 variavél auxiliar de R1, para não perder o valor de R1
            
            desenha_pixel:                      ; desenha um pixel  
                MOV     R5, [R2]                ; vai buscar a tabela a cor do pixel
                CALL    escreve_pixel           ; desenha o pixel
                ADD     R2, 2                   ; endereço da cor do proximo pixel
                INC     R7                      ; incrementa a coordenada da coluna
                DEC     R6                      ; menos uma coluna desta linha para tratar 
                JNZ     desenha_pixel           ; enquanto nao escrevemos a linha toda vai escrever a proxima coluna dessa linha
                
            INC R0                              ; passa para a linha segunite
            DEC R3                              ; menos uma linha para tratar
            JNZ desenha_linha                   ; enquanto nao desenhar as linhas todas escreve a proxima linha
    
fim_desenha_objeto:                                        
    POP     R7
    POP     R6
    POP     R5
    POP     R4
    POP     R3
    POP     R2
    POP     R0                                      
    RET                                     

; **********************************************************************
;   APAGA_BONECO - Rotina que recebes as coordenadas da posição do
;                  primeiro pixel a apagar, e o endereço que define
;                  o boneco a apagar e apaga-o.
;   ARGUMENTOS:
;       R0 - coordenada linha
;       R1 - coordenada coluna
;       R2 - endereço da tabela do boneco
;   REGISTOS AUXILIARES USADOS
;       R3 - altura do boneco 
;       R4 - largura do boneco
;       R5 - cores do pixel  (neste caso é sempre 0)
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
    
    MOV     R3, [R2]                            ; obtem a altura do boneco 
    ADD     R2, 2                               ; passa para a proximo elemento da tabela
    MOV     R4, [R2]                            ; obtem a largura do boneco
    MOV     R5, 0                               ; passa para a proximo elemento da tabela
        apaga_linha:                            ; desenha uma linha do bonecoco
            MOV     R6, R4                      ; R6 variavél auxiliar de R4, para não perder o valor de R4
            MOV     R7, R1                      ; R7 variavél auxiliar de R1, para não perder o valor de R1
            
            apaga_pixel:                        ; apaga um pixel  
                CALL    escreve_pixel           ; apaga o pixel
                INC     R7                      ; incrementa a coordenada da coluna
                DEC     R6                      ; menos uma coluna desta linha para tratar 
                JNZ     apaga_pixel             ; enquanto nao apagarmos a linha toda, apaga a proxima coluna dessa linha

            INC R0                              ; passa para a linha segunite
            DEC R3                              ; menos uma linha para tratar
            JNZ apaga_linha                     ; enquanto nao apagar as linhas todas apaga a proxima linha

fim_apaga_boneco:
    POP     R7
    POP     R6
    POP     R5
    POP     R4
    POP     R3
    POP     R2
    POP     R0
    RET


; **********************************************************************
;   ESCREVE_PIXEL - Recebe as coordenadas do pixel e a cor e escreve-o 
;                    na grelha de jogo
;   ARGUMENTOS:
;       R0 - coordenada linha
;       R7 - coordenada coluna
;       R5 - cor do pixel
; ********************************************************************** 
escreve_pixel:
    MOV     [DEFINE_LINHA], R0      ; seleciona a linha  
    MOV     [DEFINE_COLUNA], R7     ; seleciona a coluna
    MOV     [DEFINE_PIXEL], R5      ; altera a cor do pixel da linha e da coluna selecionadas
    RET

; **********************************************************************
; TESTA_LIMITES_METEORO - Testa se o boneco chegou aos limites do ecrã 
;                         e nesse caso impede o movimento (força R7 a 0)
; ARGUMENTOS:	
;       R0 - Linha em que o objeto está
;
;REGISTOS AUXILIARES USADOS:
;       R5 - Coordenada máxima da grelha
;
; RETORNA 	
;       R0 - Altera este registo para zero se for para reniciar o meteoro	
; **********************************************************************
testa_limites_meteoros:
    PUSH	R5
    
    testa_limite_baixo:
        MOV	    R5, MAX_LINHA               ; define o a coordenada maxima da linha
        CMP     R0, R5                      ; vê se ainda estamos entre limites 
        JLE	    sai_testa_limites_meteoros	; entre limites. Mantém o valor do R7 (+1)

    renicia_meteoro:                        ; se exceder o limite, o meteoro volta ao inicio da grelha
        MOV R0, 0                           ; definimos coordenada da linha igual a 0

sai_testa_limites_meteoros:	
	POP	R5
	RET

; **********************************************************************
; TESTA_LIMITES_NAVE - Testa se o boneco chegou aos limites do ecrã e 
;                      nesse caso impede o movimento (força R7 a 0)
; ARGUMENTO:	
;       R1 - Coluna em que o objeto está
;	    R2 - Endereço da nave
;		R7 - Sentido de movimento do boneco (valor a somar à coluna
;				em cada movimento: +1 para a direita, -1 para a esquerda)
;
; REGISTOS AUXILIARES USADOS:
;       R5 - Coordenada minima ou máxima da coluna
;       R6 - Largura da nave
;
; RETORNA: 	
;       R7 - 0 se já tiver chegado ao limite, inalterado caso contrário	
; **********************************************************************
testa_limites_nave:
	PUSH	R5
	PUSH	R6
    
    MOV     R6, [R2 + 2]               ; define a largura da nave
    
    testa_limite_esquerdo:		       ; vê se o boneco chegou ao limite esquerdo
    	MOV	R5, MIN_COLUNA             ; define a coordenada minima da coluna
    	CMP	R1, R5                     ; vê se a coordenada coluna já atingiu o minimo
    	JGT	testa_limite_direito       ; se a coordenada for maior, poderá estar no máximo, então verifica
    	CMP	R7, 0			           ; se chegou aqui é porque a coordenada está no minimo. o movimento é para a esquerda?
    	JGE	sai_testa_limites_nave     ; não, então pode mover-se
    	JMP	impede_movimento	       ; se sim, impede o movimento
        
    testa_limite_direito:		       ; vê se o boneco chegou ao limite direito
    	ADD	R6, R1			           ; posição a seguir ao extremo direito do boneco
    	MOV	R5, MAX_COLUNA             ; define a coordenada maxima da coluna
    	CMP	R6, R5                     ; vê se a coordenada coluna já atingiu o máximo
    	JLE	sai_testa_limites_nave	   ; está entre limites, move-se
    	CMP	R7, 0			           ; não está entre limites, então está no limite direito. Quer mover-se para a direita?
    	JGT	impede_movimento           ; se sim, impede movimento
    	JMP	sai_testa_limites_nave     ; se não, pode mover-se
        
    impede_movimento:
    	MOV	R7, 0			           ; impede o movimento, forçando R7 a 0
        
sai_testa_limites_nave:	
	POP	R6
	POP	R5
	RET

; **********************************************************************
; ATRASO - Executa um ciclo para implementar um atraso.
; Argumentos:   R11 - valor que define o atraso
;
; **********************************************************************
atraso:
	PUSH	R11
    
    ciclo_atraso:                           ; atrasa a execucao do programa
        SUB	R11, 1                          ; subtrai R11 até 0
        JNZ	ciclo_atraso

fim_atraso:
    POP	R11
    RET


; **********************************************************************
; ROT_INT_0 - 	Rotina de atendimento da interrupção 0
;			Faz simplesmente uma escrita no LOCK que o processo boneco lê.
;			Como basta indicar que a interrupção ocorreu (não há mais
;			informação a transmitir), basta a escrita em si, pelo que
;			o registo usado, bem como o seu valor, é irrelevante
; **********************************************************************
rot_int_0:
	PUSH	R1
	MOV  R1, lock_inimigo
	MOV	[R1], R0	; desbloqueia processo boneco (qualquer registo serve) 
	POP	R1
	RFE

; **********************************************************************
; ROT_INT_1 - 	Rotina de atendimento da interrupção 0
;			Faz simplesmente uma escrita no LOCK que o processo boneco lê.
;			Como basta indicar que a interrupção ocorreu (não há mais
;			informação a transmitir), basta a escrita em si, pelo que
;			o registo usado, bem como o seu valor, é irrelevante
; **********************************************************************
rot_int_1:
	PUSH	R1
	MOV  R1, lock_missil
	MOV	[R1], R0	; desbloqueia processo boneco (qualquer registo serve) 
	POP	R1
	RFE
; **********************************************************************
; ROT_INT_0 - 	Rotina de atendimento da interrupção 0
;			Faz simplesmente uma escrita no LOCK que o processo boneco lê.
;			Como basta indicar que a interrupção ocorreu (não há mais
;			informação a transmitir), basta a escrita em si, pelo que
;			o registo usado, bem como o seu valor, é irrelevante
; **********************************************************************
rot_int_2:
	PUSH	R1
	MOV  R1, lock_inimigo
	MOV	[R1], R0	; desbloqueia processo boneco (qualquer registo serve) 
	POP	R1
	RFE

; **********************************************************************
; ROT_INT_3 - 	Rotina de atendimento da interrupção 0
;			Faz simplesmente uma escrita no LOCK que o processo boneco lê.
;			Como basta indicar que a interrupção ocorreu (não há mais
;			informação a transmitir), basta a escrita em si, pelo que
;			o registo usado, bem como o seu valor, é irrelevante
; **********************************************************************
rot_int_3:
	PUSH	R1
	MOV  R1, lock_rover
	MOV	[R1], R0	; desbloqueia processo boneco (qualquer registo serve) 
	POP	R1
	RFE