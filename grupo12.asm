; *********************************************************************
; * IST-UL
; * Entrega Final:   grupo12.asm
; * Descrição:
; 
; * Autores:
;       André Morgado, 92737
;       Nicole Figueiredo, 96899
;       Rafael Ferreira, 97343
; *********************************************************************

; **********************************************************************
; * Constantes
; **********************************************************************

; **************
; * Periféricos 
; **************
DEFINE_LINHA                EQU 600AH   ; endereço do comando para defenir a linha
DEFINE_COLUNA               EQU 600CH   ; endereço do comando para defenir a coluna
DEFINE_PIXEL                EQU 6012H   ;endereço do comando para escrever um pixel
APAGA_AVISO     		    EQU 6040H   ; endereço do comando para apagar o aviso de nenhum cenário selecionado
APAGA_ECRA		            EQU 6002H   ; endereço do comando para apagar todos os pixels já desenhados
PIN                         EQU 0E000H
SELECIONA_CENARIO_FUNDO     EQU 6042H   ; endereço do comando para selecionar uma imagem de fundo
DISPLAYS                    EQU 0A000H  ; endere�o dos displays de 7 segmentos (perif�rico POUT-1)
TEC_LIN                     EQU 0C000H  ; endere�o das linhas do teclado (perif�rico POUT-2)
TEC_COL                     EQU 0E000H  ; endere�o das colunas do teclado (perif�rico PIN)
TOCA_SOM				    EQU 605AH   ; endereço do comando para tocar um som

; **************
; * Teclado
; **************
MASCARA                     EQU 0FH     ; para isolar os 4 bits de menor peso, ao ler as colunas do teclado
TAM_TAB                     EQU 0010H   ; tamanho do teclado
TEC_DIREITA                 EQU 2       ; tecla 0
TEC_DISPARA                 EQU 1       ; tecla 1
TEC_ESQUERDA                EQU 0      ; tecla 2
TEC_INICIA                  EQU 12       ; tecla 5
TEC_PAUSA                   EQU 13       ; tecla 3
TEC_TERMINA                 EQU 14       ; tecla 7

; **************
; * Nave
; **************
LARGURA_NAVE		        EQU	5		; largura da nave 
ALTURA_NAVE                 EQU 4       ; altura da nave 
LINHA_INICIAL_NAVE          EQU 28
COLUNA_INICIAL_NAVE         EQU 31
COR_PIXEL		            EQU	0FFF0H	; cor do pixel nave (amarelo)

; **************
; * Meteoros
; **************
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
LINHA_INICIAL               EQU 0
COLUNA_INICIAL_0            EQU 1
COLUNA_INICIAL_1            EQU 16
COLUNA_INICIAL_2            EQU 32
COLUNA_INICIAL_3            EQU 48         
LIM_FASE_1                  EQU 2
LIM_FASE_2                  EQU 5 
LIM_FASE_3                  EQU 9
LIM_FASE_4                  EQU 14
BOM                         EQU 1
INIMIGO                     EQU -1
COR_PIXEL_INICIO            EQU 0F888H
COR_PIXEL_INIMIGO           EQU 0FF00H  ; cor do pixel de meteoros inimigos (vermelho)
COR_PIXEL_BOM               EQU 0F0F0H
COR_PIXEL_MORTO             EQU 0FFEFH

; **************
; * Missil
; **************
LARGURA_MISSIL              EQU 1
ALTURA_MISSIL               EQU 1
COR_PIXEL_MISSIL            EQU 0F808H

; **************
; * Energia
; **************
TERMINA_ENERGIA             EQU -2
ENERGIA_INICIAL             EQU 100

; **************
; * Outras
; **************
ATRASO			            EQU	3000H	; atraso para limitar a velocidade de movimento do boneco
MIN_COLUNA                  EQU 0       ; coordenada minima de coluna
MAX_COLUNA                  EQU 63      ; coordenada maxima de coluna
MIN_LINHA                   EQU 0       ; coordenada minima de linha
MAX_LINHA                   EQU 31      ; coordenada maxima de linha
N_METEORO                   EQU 4   
ATIVO                       EQU 1
TERMINA_CHOQUE              EQU -1

ECRA_INICIO                 EQU 0
ECRA_JOGO                   EQU 1
ECRA_SEM_ENERGIA            EQU 2
ECRA_EXPLODIU               EQU 3
ECRA_PAUSA                  EQU 4

SOM_DISPARO                 EQU 0


; **********************************************************************
; * Dados 
; **********************************************************************
PLACE       1000H                ; para escrever as variaveis

; **************
; * Stacks
; **************
; Reserva do espaço para as pilhas dos processos
	STACK   100H			    ; espaço reservado para a pilha do processo "Controlo"
SP_inicial_controlo:		    ; este é o endereço com que o SP deste processo deve ser inicializado
							
	STACK   100H			    ; espaço reservado para a pilha do processo "teclado"
SP_inicial_teclado:			    ; este é o endereço com que o SP deste processo deve ser inicializado
							
; SP inicial de cada processo "Meteoro"
	STACK   100H			    ; espaço reservado para a pilha do processo "Meteoro", instância 0
SP_inicial_meteoro_0:		    ; este é o endereço com que o SP deste processo deve ser inicializado 

    STACK   100H	            ; espaço reservado para a pilha do processo "Meteoro", instância 1		
SP_inicial_meteoro_1:           ; este é o endereço com que o SP deste processo deve ser inicializado 

    STACK   100H			    ; espaço reservado para a pilha do processo "Meteoro", instância 2
SP_inicial_meteoro_2:           ; este é o endereço com que o SP deste processo deve ser inicializado 

    STACK   100H	            ; espaço reservado para a pilha do processo "Meteoro", instância 3
SP_inicial_meteoro_3:           ; este é o endereço com que o SP deste processo deve ser inicializado 

    STACK   100H                ; espaço reservado para a pilha do processo "Rover"
SP_inicial_rover:               ; este é o endereço com que o SP deste processo deve ser inicializado 

    STACK   100H                ; espaço reservado para a pilha do processo "Missil"
SP_inicial_missil:              ; este é o endereço com que o SP deste processo deve ser inicializado 

    STACK   100H                ; espaço reservado para a pilha do processo "Energia_Rover"
SP_incial_energia_rover:        ; este é o endereço com que o SP deste processo deve ser inicializado 

; **************
; * Nave
; **************
nave:	                                                ; endereço que define a nave 
    WORD ALTURA_NAVE, LARGURA_NAVE                      ; dimensões da nave                  
    WORD 0, 0, COR_PIXEL, 0, 0
    WORD COR_PIXEL, 0, COR_PIXEL, 0, COR_PIXEL
    WORD COR_PIXEL, COR_PIXEL, COR_PIXEL, COR_PIXEL, COR_PIXEL
    WORD 0, COR_PIXEL, 0, COR_PIXEL, 0
		
coordenadas_nave:                                       ; endereço com as coordenadas da nave	
    WORD LINHA_INICIAL_NAVE, COLUNA_INICIAL_NAVE        ; coordenadas iniciais da nave     

; **************
; * Meteoros
; **************  
meteoro_SP_tab:                     ; tabela com os SP iniciais de cada processo "Meteoro"
    WORD    SP_inicial_meteoro_0
    WORD    SP_inicial_meteoro_1
    WORD    SP_inicial_meteoro_2
    WORD    SP_inicial_meteoro_3

linha_meteoro_tab:                  ; tabela com as linhas do metoro de cada processo "Meteoro"
    WORD    LINHA_INICIAL   
    WORD    LINHA_INICIAL
    WORD    LINHA_INICIAL
    WORD    LINHA_INICIAL

coluna_meteoro_tab:                 ; tabela com as colunas do metoro de cada processo "Meteoro"
    WORD    COLUNA_INICIAL_0
    WORD    COLUNA_INICIAL_1
    WORD    COLUNA_INICIAL_2
    WORD    COLUNA_INICIAL_3

bom_ou_mau_tab:                     ; tabela que diz se o meteoro é bom ou mau de cada processo "Meteoro"
    WORD INIMIGO
    WORD INIMIGO
    WORD BOM
    WORD INIMIGO

nr_meteoros_vivos:                  ; Variável que diz quantos meteoroas ainda estão vivos
    WORD N_METEORO

meteoro_inicio_1:                   ; Tabela que define o inicio 1 dos meteoros
    WORD ALTURA_INICIO_1, LARGURA_INICIO_1
    WORD COR_PIXEL_INICIO

meteoro_inicio_2:                   ; Tabela que define o inicio 2 dos meteoros
    WORD ALTURA_INICIO_2, LARGURA_INICIO_2
    WORD COR_PIXEL_INICIO, COR_PIXEL_INICIO
    WORD COR_PIXEL_INICIO, COR_PIXEL_INICIO

meteoro_bom_1:                      ; Tabela que define o meteoro bom 1 
    WORD ALTURA_METEORO_1, LARGURA_METEORO_1
    WORD 0, COR_PIXEL_BOM, 0
    WORD COR_PIXEL_BOM, COR_PIXEL_BOM, COR_PIXEL_BOM
    WORD 0, COR_PIXEL_BOM, 0

meteoro_bom_2:                      ; Tabela que define o meteoro bom 2
    WORD ALTURA_METEORO_2, LARGURA_METEORO_2
    WORD 0, COR_PIXEL_BOM, COR_PIXEL_BOM, 0
    WORD COR_PIXEL_BOM, COR_PIXEL_BOM, COR_PIXEL_BOM, COR_PIXEL_BOM
    WORD COR_PIXEL_BOM, COR_PIXEL_BOM, COR_PIXEL_BOM, COR_PIXEL_BOM
    WORD 0, COR_PIXEL_BOM, COR_PIXEL_BOM, 0

meteoro_bom_3:                      ; Tabela que define o meteoro bom 3
    WORD ALTURA_METEORO_3, LARGURA_METEORO_3
    WORD 0, COR_PIXEL_BOM, COR_PIXEL_BOM, COR_PIXEL_BOM, 0
    WORD COR_PIXEL_BOM, COR_PIXEL_BOM, COR_PIXEL_BOM, COR_PIXEL_BOM, COR_PIXEL_BOM
    WORD COR_PIXEL_BOM, COR_PIXEL_BOM, COR_PIXEL_BOM, COR_PIXEL_BOM, COR_PIXEL_BOM
    WORD COR_PIXEL_BOM, COR_PIXEL_BOM, COR_PIXEL_BOM, COR_PIXEL_BOM, COR_PIXEL_BOM
    WORD 0, COR_PIXEL_BOM, COR_PIXEL_BOM, COR_PIXEL_BOM, 0

meteoro_inimigo_1:                  ; Tabela que define o meteoro inimigo 1
    WORD ALTURA_METEORO_1, LARGURA_METEORO_1
    WORD COR_PIXEL_INIMIGO, 0, COR_PIXEL_INIMIGO
    WORD 0, COR_PIXEL_INIMIGO, 0
    WORD COR_PIXEL_INIMIGO, 0, COR_PIXEL_INIMIGO

meteoro_inimigo_2:                  ; Tabela que define o meteoro inimigo 2
    WORD ALTURA_METEORO_2, LARGURA_METEORO_2
    WORD COR_PIXEL_INIMIGO, 0, 0, COR_PIXEL_INIMIGO
    WORD COR_PIXEL_INIMIGO, 0, 0, COR_PIXEL_INIMIGO
    WORD 0, COR_PIXEL_INIMIGO, COR_PIXEL_INIMIGO, 0
    WORD COR_PIXEL_INIMIGO, 0, 0, COR_PIXEL_INIMIGO

meteoro_inimigo_3:                  ; Tabela que define o meteoro inimigo 1
    WORD ALTURA_METEORO_3, LARGURA_METEORO_3
    WORD COR_PIXEL_INIMIGO, 0, 0, 0, COR_PIXEL_INIMIGO
    WORD COR_PIXEL_INIMIGO, 0, COR_PIXEL_INIMIGO, 0, COR_PIXEL_INIMIGO
    WORD 0, COR_PIXEL_INIMIGO, COR_PIXEL_INIMIGO, COR_PIXEL_INIMIGO, 0
    WORD COR_PIXEL_INIMIGO, 0, COR_PIXEL_INIMIGO, 0, COR_PIXEL_INIMIGO
    WORD COR_PIXEL_INIMIGO, 0, 0, 0, COR_PIXEL_INIMIGO

meteoro_morto:                      ; Tabela que define o meteoro morto
    WORD ALTURA_METEORO_3, LARGURA_METEORO_3
    WORD 0, COR_PIXEL_MORTO, 0, COR_PIXEL_MORTO, 0
    WORD COR_PIXEL_MORTO, 0, COR_PIXEL_MORTO, 0, COR_PIXEL_MORTO
    WORD 0, COR_PIXEL_MORTO, 0, COR_PIXEL_MORTO, 0
    WORD COR_PIXEL_MORTO, 0, COR_PIXEL_MORTO, 0, COR_PIXEL_MORTO
    WORD 0, COR_PIXEL_MORTO, 0, COR_PIXEL_MORTO, 0

; **************
; * Missil
; **************  
missil:                             ; Tabela que define o missil
    WORD ALTURA_MISSIL, LARGURA_MISSIL
    WORD COR_PIXEL_MISSIL

coordenadas_missil:                 ; Tabela que guarda as coordenadas do missil       
    WORD -1, -1

; **************
; * Energia
; **************  
energia:                            ; endereço para energia da nave
    WORD ENERGIA_INICIAL 

; **************
; * Rotinas de Interupção
; **************  
tab:                                ; Tabela das rotinas de interrupção
	WORD rot_int_0			        ; rotina de atendimento da interrupção 0
    WORD rot_int_1			        ; rotina de atendimento da interrupção 1
    WORD rot_int_2			        ; rotina de atendimento da interrupção 2
    WORD rot_int_3			        ; rotina de atendimento da interrupção 3

; **************
; * Controlo
; **************  
estado_jogo:                        ; endereço para o a variavel de estado do jogo
    WORD ATIVO

; **************
; * Locks
; **************    
lock_inimigo:
    LOCK 0
lock_rover:             
    LOCK 0
lock_teclado:           ; LOCK para o teclado comunicar aos restantes processos que tecla detetou
    LOCK 0
lock_teclado_continuo:  ; LOCK para o teclado comunicar aos restantes processos que tecla detetou continuamente
    LOCK 0
lock_todos_mortos:
    LOCK 0
lock_missil:
    LOCK 0
lock_dispara:
    LOCK 0
lock_energia:
    LOCK 0
lock_controlo:
    LOCK 0
lock_estado:             ; LOCK que diz o estado em que se encontra o jogo (assume -1 se terminou, 1 se continua e 2 se o meteoro for destruido)
    LOCK 0


PLACE 0H
; **********************************************************************
;                           PROCESSO DE CONTROLO
;
;  DESCRIÇÃO:   Processo responsável, por começar, pausar, terminar, 
;               e reiniciar o jogo. Também é chamado no caso de perder
;
;       
;  RESGISTOS USADOS:
;       R0 - Máscara
;       R1 - Endereço do periférico das linhas
;       R2 - Endereço do periférico das colunas 
;       R3 - Tamanho de teclado 
;       R4 - Coordenada da linha do tecladp
;       R5 - Coordenada da coluna do teclado
;       R6 - Valor da tecla pressionada
;       R7 - Valor do incremento (usado no movimento da nave e na alteração de energia)
;       R11 - Valor do atraso 
;
; **********************************************************************
PROCESS SP_inicial_controlo
controlo:
    MOV     SP, SP_inicial_controlo             ; inicia a Stack
    MOV     BTE, tab			                ; inicializa BTE (registo de Base da Tabela de Exceções)
    MOV     [APAGA_AVISO], R1	                ; apaga o aviso de nenhum cenário selecionado (o valor de R1 não é relevante)
    EI0
    EI1
    EI2
    EI3
    EI
    
    CALL    inicia_jogo

    MOV R11, N_METEORO

    loop_meteoros:

        DEC R11
        CALL acao_move_meteoro

        CMP R11, 0
        JNZ loop_meteoros

    CALL    teclado
    CALL    acao_move_nave
    CALL    acao_missil
    CALL    energia_rover
 
    MOV     R0, MASCARA                                     ; para isolar os 4 bits de menor peso, ao ler as colunas do teclado
    MOV     R2, TEC_LIN                                     ; endereço do periférico das linhas
    MOV     R3, TEC_COL                                     ; endereço do periférico das colunas
    MOV     R4, 8

    coloca_fundo_de_espera_c:
        MOV     R1, ECRA_INICIO			                                ; cenário de fundo número 0
        CALL    desenha_fundo
        CALL    inicia_jogo
        CALL    atraso   

    espera_c:                                               ; neste ciclo espera-se a tecla c ser premida (em loop infinito)
        MOVB    [R2], R4                                    ; escrever no periférico de saída a linha do c
        MOVB    R5, [R3]                                    ; ler do periférico de entrada (colunas)
        AND     R5, R0                                      ; elimina bits para além dos bits 0-3
        CMP     R5, 1                                       ; há c premido?
        JNZ     espera_c                                    ; se c não foi premido, repete

        CMP R1, 0
        JNZ coloca_fundo_de_espera_c

    CALL desenha_tudo
        
    espera_pausa:
        MOV R6, [lock_teclado]
        MOV R5, TEC_PAUSA
        CMP R6, R5
        JZ pausa

        MOV R5, TERMINA_CHOQUE
        CMP R6, R5
        JZ termina_jogo_choque

        MOV R5, TERMINA_ENERGIA
        CMP R6, R5
        JZ termina_jogo_energia

        JMP espera_pausa
        
    pausa:
        DI0
        DI1
        DI2
        DI3
        DI
        MOV R1, ECRA_PAUSA
        CALL desenha_fundo
        CALL atraso

        espera_retorna_ou_termina:
            MOVB    [R2], R4                                    
            MOVB    R5, [R3]                                    
            AND     R5, R0                                      
            CMP     R5, 2                                                                           
            JZ      volta_para_o_jogo
            CMP     R5, 4
            JZ      termina_jogo
            JMP espera_retorna_ou_termina
        
        volta_para_o_jogo:
            MOV R1, ECRA_JOGO
            CALL desenha_fundo
            JMP espera_pausa

        termina_jogo_choque:
            MOV R1, ECRA_EXPLODIU
            CALL desenha_fundo
            JMP espera_e

        termina_jogo_energia:
            MOV R1, ECRA_SEM_ENERGIA
            CALL desenha_fundo
            JMP espera_e


        espera_e:
            MOVB    [R2], R4                                    ; escrever no periférico de saída a linha do c
            MOVB    R5, [R3]                                    ; ler do periférico de entrada (colunas)
            AND     R5, R0                                      ; elimina bits para além dos bits 0-3
            CMP     R5, 4                                       ; há e premido?
            JNZ     espera_e                                    ; se e não foi premido, repete
        termina_jogo:
            CALL inicia_jogo
            JMP coloca_fundo_de_espera_c

; **********************************************************************
;                               PROCESSO TECLADO
;
;  TECLADO - Função principal do jogo que lê o teclado, reconhece a
;            tecla premida, converte o valor da tecla num valor de 0 a F,
;            e a partir daí desencadeia a ação
;
;       
;  RESGISTOS AUXILIARES USADOS:
;       R0 - Máscara
;       R1 - Endereço do periférico das linhas
;       R2 - Endereço do periférico das colunas 
;       R3 - Tamanho de teclado 
;       R4 - Coordenada da linha do tecladp
;       R5 - Coordenada da coluna do teclado
;       R6 - Valor da tecla pressionada
;       R11 - Valor do atraso 
; **********************************************************************
PROCESS SP_inicial_teclado
teclado:                                                ; inicializações
    MOV     R0, MASCARA                         ; para isolar os 4 bits de menor peso, ao ler as colunas do teclado
    MOV     R1, TEC_LIN                         ; endereço do periférico das linhas
    MOV     R2, TEC_COL                         ; endereço do periférico das colunas
    MOV     R3, TAM_TAB                         ; registo auxiliar que guarda o limite da tabela
    
    inicio_teclado:
    reiniciar:
        MOV     R4, 1                           ; inicia a verificação na linha 1
    
    ciclo_espera_tecla:                         ; neste ciclo espera-se até uma tecla ser premida (em loop infinito)
        YIELD
        CMP     R4, R3                          ; verfica se excedeu
        JZ      reiniciar                        ; se excedeu voltamos a 1ª linha
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
        MOV R11, 50H
        CALL atraso
        MOV     [lock_teclado_continuo], R6
        MOVB    [R1], R4                        ; escrever no periférico de saída (linhas)
        MOVB    R5, [R2]                        ; ler do periférico de entrada (colunas)
        AND     R5, R0                          ; elimina bits para além dos bits 0-3
        CMP     R5, 0                           ; há tecla premida?
        JZ      reiniciar                        ; repete ciclo
        JMP     ha_tecla                        ; se ainda houver uma tecla premida, espera at� n�o haver

; **********************************************************************
;                   PROCESSO ACAO_MOVE_NAVE  
;
;ACAO_MOVE_NAVE - Recebe o valor de incremento (-1 ou +1 caso seja 
;                   para a esquerda ou para a direita, respetivamente) 
;                   e desloca a nave.
;
;  RESGISTOS AUXILIARES USADOS:
;       R0 - Coordenada da linha
;       R1 - Coordenada da coluna
;       R2 - Endereço da nave
;       R7 - Deslocamento da nave
;       R9 - tecla que o teclado leu
;      
; **********************************************************************
PROCESS SP_inicial_rover
acao_move_nave:
        MOV     R9 , [lock_teclado_continuo]    ; espera o teclado

        MOV     R7, -1                          ; assume que quer ir para a esquerda
        CMP     R9, TEC_ESQUERDA                ; quer mesmo? (tecla pressionada 0)
        JZ      move_nave                       ; se sim, move
                                               
        MOV     R7, 1                           ; se não, assume que quer andar para a direita 
        CMP     R9, TEC_DIREITA                 ; quer mesmo ?
        JZ      move_nave                       ; se sim, move
        JMP     acao_move_nave                  ; se não é porque não é para andar
                
    move_nave:

        MOV     R0, [coordenadas_nave]          ; define coordenada da linha
        MOV     R1, [coordenadas_nave + 2]      ; define a coordenada da coluna
        MOV     R2, nave                        ; define o endereço da nave


        segue:
        
        CALL    testa_limites_nave              ; vê se o movimento é válido
        CMP     R7, 0                           ; é válido?
        JZ      acao_move_nave                  ; se não for não move a nave
        CALL    apaga_boneco                    ; se for, apaga a nave na posiçao antiga
        ADD     R1, R7                          ; atualiza as coordenada da coluna
        MOV     [coordenadas_nave + 2], R1      ; atualiza em memória as coordenada da coluna da nave
        CALL    desenha_objeto                  ; desenha nave na nova posição
        JMP     acao_move_nave

; **********************************************************************
;                          PROCESSO ENERGIA_ROVER
;  
;   ENERGIA_ROVER -Processo que controla a energia do rover
;    
;   RESGISTOS AUXILIARES USADOS:
;       R6 - Energia
;       R9 - Varíavel lock
;
; **********************************************************************

PROCESS SP_incial_energia_rover

energia_rover:
    MOV R9, [lock_energia]

    MOV R6, -5
    CALL converte_em_decimal
 
    JMP energia_rover

; **********************************************************************
;                   PROCESSO ACAO_MOVE_INIMIGO
;
;   ACAO_MOVE_INIMIGO - Processo que controla o meteoro e o seu movimento
;
;   RESGISTOS AUXILIARES USADOS:
;       R11 - Nº de qual processo meteoro
;       R10 - deslocamento a fazer as tabelas sobre os processos meteoros
;       R4 - linha meteoro em memoria
;       R5 - coluna meteoro em memoria
;       R7 - se o meteoro é bom ou mau em memoria
;       R9 - retorno do obtem_nr_random
;       R3 - nr de metoros vivos
;       R2 - endereço do metoro a desenhar
;       R1 - coluna do metoro a desenhar 
;       R0 - linha do metoro a desenhar
;
; **********************************************************************
PROCESS SP_inicial_meteoro_0	
						
acao_move_meteoro:                                          ; inicializa o meteoro 
    MOV R10, R11
    SHL R10, 1
    MOV R9, meteoro_SP_tab
    MOV SP, [R9+R10]
    MOV R5, linha_meteoro_tab
    ADD R5, R10
    MOV R4, coluna_meteoro_tab
    ADD R4, R10
    MOV R7, bom_ou_mau_tab
    ADD R7, R10

    JMP inicia_meteoro

    ciclo_meteoro:
        MOV R3, [nr_meteoros_vivos]
        CMP R3, 0
        JZ foi_o_ultimo 
        JMP espera

        foi_o_ultimo:
            MOV [lock_todos_mortos], R3
            MOV R3, N_METEORO
            MOV [nr_meteoros_vivos], R3
            JMP inicia_meteoro

        espera:
            MOV R3, [lock_todos_mortos]

        inicia_meteoro:

            MOV     R0, 0                                       ; inicializa valor da linha a 0
            CALL    obter_nr_random                             ; obtem um nr aletorio de 0 a 7 (que fica em R9)
            SHL     R9, 3                                       ; multiplica por 8, para obter o valor da coluna
            MOV     R1, R9                                      ; atribui valor da coluna

            MOV [R5], R1

            MOV [R4], R0


        escolhe_se_bom_ou_mau:                                  ; decide se o meteoro a dar spawn é bom ou mau
            CALL obter_nr_random                                ; retorna R9 com um valor de 0 a 7 (se for 0 ou 1 o meteoro é bom)

            MOV R8, bom_ou_mau_tab                              ; endereço da tabela que define se o meteoro e bom ou mau

            MOV R3, 1                                           ; assumimos que é bom
            CMP R9, 0                                           ; é bom ?
            JZ guarda_valor                                     ; se for bom guarda 1                            
            CMP R9, 1
            JZ guarda_valor                
            MOV R3, -1                                          ; se for mau guarda -1

            guarda_valor:                                       ; guarda se o meteoro é bom ou mau
            MOV [R7], R3


        move_inimigo:
            MOV     R3, [lock_inimigo]
            MOV     R1, [R5]
            MOV     R0, [R4]
            CALL    escolhe_formato_aux
            CALL    apaga_boneco                               ; apaga meteoro na posiçao antiga

            MOV     R8, 0
            CALL    testa_choque_missil                        ; chama o testa_choque
            CMP     R8, 1
            JZ      lida_com_colisao_missil

            CALL testa_choque_nave
            CMP R8, 1
            JZ  lida_com_colisao_nave

            INC     R0                                         ; incrementa valor da linha
            MOV     [R4], R0

            CALL    testa_limites_meteoros                     ; vê se o meteoro está nos limites da grelha
            CMP     R0, 0                                      ; se não tiver é pq o meteoro chegou ao fim
            JZ      chegou_ao_fim                              ; reinicia noutro meteoro
            MOV     R1, [R5]
            MOV     R0, [R4]
            CALL    desenha_objeto                             ; desenha o meteoro na nova posição
            JMP     move_inimigo
        chegou_ao_fim:
                MOV R3, [nr_meteoros_vivos]
                DEC R3
                MOV [nr_meteoros_vivos], R3
                JMP ciclo_meteoro

        lida_com_colisao_missil:
            CALL desenha_objeto
            MOV  R3, [lock_inimigo] 
            CALL apaga_boneco

            MOV R3, [nr_meteoros_vivos]
            DEC R3
            MOV [nr_meteoros_vivos], R3

            MOV R8, [R7]
            CMP R8, INIMIGO
            JZ recebe_energia
            JMP ciclo_meteoro

            recebe_energia:
            MOV R6, 10
            CALL converte_em_decimal
            JMP ciclo_meteoro

        lida_com_colisao_nave:
            MOV R3, [nr_meteoros_vivos]
            DEC R3
            MOV [nr_meteoros_vivos], R3
            MOV R8, [R7]
            CMP R8, INIMIGO
            JZ eh_mau
            MOV R6, 10
            CALL converte_em_decimal
            JMP ciclo_meteoro

            eh_mau:
                MOV R1, TERMINA_CHOQUE
                MOV [lock_teclado], R1
                JMP move_inimigo

            JMP ciclo_meteoro


; **********************************************************************
;                   PROCESSO ACAO_MISSIL
;
;   ACAO_MISSIL - Processo que controla o missil 
;
;   RESGISTOS AUXILIARES USADOS:
;       R3 - teccla precionada pelo teclado
;       R2 - endereço do missil 
;       R1 - coluna da nave
;       R0 - linha da nave
;
; **********************************************************************
PROCESS SP_inicial_missil

acao_missil:
    MOV     R3, [lock_teclado]              ; bloqueia o ciclo até ser disparado um missil
    CMP     R3, TEC_DISPARA                 ; a tecla premida foi para disparar?
    JNZ     acao_missil                     ; não, então não dispara
                                            ; sim, dispara
    MOV     R10, SOM_DISPARO
    CALL    toca_som
    
    MOV R6, -5
    CALL converte_em_decimal

    MOV     R0, [coordenadas_nave]          ; vai buscar as coordenadas da nave
    MOV     R1, [coordenadas_nave + 2]      
    MOV     R2, missil                      ; define o missil
    DEC     R0                              ; decrementa a linha (o missil é disparado imediatamente a seguir a nave)
    ADD     R1, 2                           ; e no centro da nave

    MOV     [coordenadas_missil], R0        ; atualiza as coordenadas da linha do missil na memória
    MOV     [coordenadas_missil + 2], R1    ; atauliza as coordenadas da coluna do missil na memória

    move_missil:                            ; ciclo que move o missil
        CALL    desenha_objeto              ; desenha missil
        MOV     R10, [lock_missil]          ; interrupção para que o movimento do missil seja mais lento
        CALL    apaga_boneco
        MOV     R0, [coordenadas_missil]    ; este buscar de valor na memória só é relevante no caso de o missil ter colidido
        DEC     R0                          ; missil sobe uma linha

        MOV     [coordenadas_missil], R0    ; atualiza valor da linha na memória

        CMP     R0, 1                       ; a linha do missil é menor que 1?
        JLT     acao_missil                 ; sim, então chegou ao fim, volta ao inicio do cilo
                                           
        JMP     move_missil                 ; o missil continua a subir

; **********************************************************************
;  INICIA_JOGO - Rotina que iniciliza os jogo com as posições iniciais
;                da nave e a energia a 100
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
    PUSH    R3
    PUSH    R6    
 
    MOV     [APAGA_ECRA], R1

    mostra_nave:                                            ; desenha a nave na posicao inicial
        MOV     R0, LINHA_INICIAL_NAVE                      ; começa por reinicializar a posicao da nave
        MOV     R1, COLUNA_INICIAL_NAVE
        MOV     [coordenadas_nave + 2], R1                  ; reinicializa a coluna

    reinicia_energia:                                       ; rencializa o valor da energia do rover a 100
        MOV     R0, ENERGIA_INICIAL
        MOV     [energia], R0                               ; reinicia o valor em memória       
    
    reinicia_missil:
        MOV     R0, -1
        MOV     [coordenadas_missil], R0
        MOV     [coordenadas_missil+2], R0

    reinicia_meteoros:
        MOV     R0, LINHA_INICIAL
        MOV     [linha_meteoro_tab], R0
        MOV     [linha_meteoro_tab+2], R0
        MOV     [linha_meteoro_tab+4], R0
        MOV     [linha_meteoro_tab+6], R0

        MOV     R0, COLUNA_INICIAL_0
        MOV     [coluna_meteoro_tab], R0
        MOV     R0, COLUNA_INICIAL_1
        MOV     [coluna_meteoro_tab+2], R0
        MOV     R0, COLUNA_INICIAL_2
        MOV     [coluna_meteoro_tab+4], R0
        MOV     R0, COLUNA_INICIAL_3
        MOV     [coluna_meteoro_tab+6], R0


        
        MOV     R0, N_METEORO
        MOV     [nr_meteoros_vivos], R0
        MOV     [lock_todos_mortos], R0
    
    reinicia_estado_do_jogo:
        MOV     R0, ATIVO
        MOV     [estado_jogo], R0

    fim_inicia_jogo:
    POP     R6
    POP     R3
    POP     R2  
    POP     R1
    POP     R0
    RET

; **********************************************************************
;  DESENHA_TUDO - Rotina que iniciliza os jogo com as posições iniciais
;                da nave e a energia a 100
;
;  RESGISTOS AUXILIARES USADOS:
;       R0 - Linha da coordenada da nave/meteoro
;       R1 - Coluna da coordenada da nava/meteoro
;       R2 - Endereço da nave/meteoro
; **********************************************************************  
desenha_tudo:   
    PUSH R0
    PUSH R1
    PUSH R2
    PUSH R6

    MOV R1, 1
    CALL desenha_fundo

    MOV R0, [coordenadas_nave]
    MOV R1, [coordenadas_nave+2]
    MOV R2, nave
    CALL desenha_objeto

    MOV R0, [energia]
    MOV R6, 0
    CALL converte_em_decimal

    POP R6
    POP R2
    POP R1
    POP R0
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
                CMP     R5, 0
                JZ      nao_desenha
                CALL    escreve_pixel           ; desenha o pixel
                nao_desenha:
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
; ROT_INT_0 -
;   ARGUMENTO:
;       R0 - Nr em hexadecimal a passar para decimal
;   ARGUMENTOS AUXILIARES UTILIZADOS:
;       R1 - Fator
;       R3 - Digito
;       R4 - Resultado
;       
; **********************************************************************
converte_em_decimal:
    PUSH R1
    PUSH R3
    PUSH R4
    PUSH R5
    MOV R1, 1000
    MOV R4, 1
    MOV R5, 10

    MOV R0, [energia]           ; busca valor atual de energia
    ADD R0, R6                  ; atualiza valor de energia
    MOV [energia], R0           ; atualiza valor de energia em memória

    loop_converte:              ; converte hex a dec
    MOD R0, R1
    DIV R1, R5
    MOV R3, R0
    DIV R3, R1
    SHL R4, 4
    OR  R4, R3

    CMP R1, R5
    JLT fim_converte1
    JMP loop_converte

    fim_converte1:
    MOV [DISPLAYS], R4
    MOV R5, 1000H
    CMP R4, R5
    JNZ fim_converte2
    MOV R4, TERMINA_ENERGIA
    MOV [lock_teclado], R4

    fim_converte2:
    POP R5
    POP R4
    POP R3
    POP R1
    RET

; **********************************************************************
; TESTA_CHOQUE - Testa se a nave chocou com o meteoro
;                  Primeiro vê se a ultima coluna do meteoro é a mesma
;                  que a primeira coluna da nave. Depois,
;                  vê os dois extremos do meteoro e verifica se eles estão
;                  entre os extremos da nave, e caso um deles esteja significa
;                  que bateram.
;
; ARGUMENTOS:
;       R0 - Linha do meteoro
;       R1 - Coluna do meteoro
;       R2 - Definição do meteoro
;
;REGISTOS AUXILIARES USADOS:
;       R5 - Linha/Coluna da nave
;       R3 - Largura da nave
;       R4 - Altura/Largura do meteoro inimigo
;
; RETORNA 	
;       R8  = -1 signfica que bateu	
; **********************************************************************
testa_choque_nave:
    PUSH    R0
    PUSH    R1
    PUSH    R3
    PUSH    R4
    PUSH    R5

    MOV     R5, [coordenadas_nave]                          ; define linha nave
    MOV     R4, [R2]                                        ; define altura meteoro
    ADD     R0, R4                                          ; soma a linha do meteoro com a altura do meteoro para ver o fundo/base do meteoro
    CMP     R0, R5                                          ; ve se o meteoro e nave estao na mesma linha
    JGE     estao_mesma_linha                               ; se estão na mesma linha há possibilidade de colisão
    JMP     fim_testa_choque_nave                               ; se não estão na mesma linha não vai haver colisão

    estao_mesma_linha:
        MOV     R5, [coordenadas_nave + 2]                  ; define coluna nave
        MOV     R3, [nave + 2]                              ; define largura nave
        MOV     R4, [R2 + 2]                                ; define largura meteoro
        CMP     R1, R5                                      ; compara a coluna da esquerda no meteoro com coluna da esquerda da nave
        JGT     ve_maximo                                   ; se a coluna da esquerda do meteoro for maior, vai verificar se esta entre a nave
        JMP     testa_outro_limite                          ; se não testa coluna do meteoro da direita

    ve_maximo:
        ADD     R5, R3                                      ; adiciona a largura as coordenadas da nave para ver o ponto direito
        DEC     R5
        CMP     R1, R5                                      ; compara a coluna direita/esquerda do meteoro com a coluna direita da nave
        JLE     bateu                                       ; se for menor é porque bateu

    testa_outro_limite:
        MOV     R5, [coordenadas_nave + 2]                  ; define a coluna da nave 
        ADD     R1, R4                                      ; adiciona a largura do meteoro para verificar o ponto direito
        DEC     R1
        CMP     R1, R5                                      ; compara a coluna direta do meteoro com a coluna esquerda da nave 
        JGE     ve_maximo                                   ; se a coluna direita for maior, vai verificar se está entre a nave  
        JMP     fim_testa_choque_nave                            ; se for menor não há colisão
    bateu:
        MOV     R8, 1                                       ; se bateu mete o valor de retorno a 1

    fim_testa_choque_nave:
        POP     R5
        POP     R4
        POP     R3
        POP     R1
        POP     R0
        RET

; **********************************************************************
; TESTA_CHOQUE_MISSIL - Testa se o meteoro chocou com o missil ou com a nave
;
;  ARGUMENTOS:	
;       R0 - Linha em que o meteoro está
;       R1 - Coluna em que o meteoro está
;       R2 - Definição do meteoro
;
;   REGISTOS AUXILIARES USADOS:
;       (R0, R1) - Coordenadas onde o missil está
;       (R3, R4) - Coordenadas do vertice do canto superior esquerdo do meteoro
;       (R6, R7) - Coordenadas do vertice do canto inferior direito do meteoro
;
; RETORNA 	
;       R8 - Serve de flag para saber que colisão houve (tem  o valor de 1 se choca com o missil)
; **********************************************************************
testa_choque_missil:
    PUSH R0
    PUSH R1
    PUSH R3
    PUSH R4
    PUSH R5
    PUSH R6
    PUSH R7
                                                    ; obtemos a coordenada do vertice do canto superior esquerdo do meteoro (R3, R4)
    MOV R3, R0                                      ; linha
    MOV R4, R1                                      ; coluna
                                                    ; obtemos a coordenada do vertice do canto inferior direito (R6, R7)
    MOV R5, [R2]                                    ; vamos buscar a altura do meteoro
    ADD R5, R3                                      ; somamos com a coordenada da linha
    MOV R6, R5                                      ; obtemos valor da coordenada da linha do vertice inferior direito
    MOV R5, [R2 + 2]                                ; vamos buscar a largura
    ADD R5, R4                                      ; somar com a coordenada da coluna
    MOV R7, R5                                      ; obtemos a coordenada da coluna do vertice inferior direito
                                                    ; testa se colidiu com o missil
    MOV R0, [coordenadas_missil]                    ; linha do missil
    MOV R1, [coordenadas_missil +2]                 ; coluna do missil

    testa:
        CMP R1, R4                                  ; a coluna do missil/nave é menor que (está à esquerda) da coluna mais à esquerda do meteoro
        JLT fim_testa_choque                        ; sim, então não há colisão
        CMP R1, R7                                  ; a coluna do missil/nave é maior que (está à direita) da coluna mais à direita do meteoro
        JGE fim_testa_choque                        ; sim, então não há colisão

        CMP R0, R3                                  ; a linha do missil/nave é inferior à linha do canto superior esquerdo?
        JLT fim_testa_choque                        ; sim, não há colisão
        CMP R0, R6                                  ; a linha do missil/nave é superior à linha do canto inferior direito?
        JGT fim_testa_choque                        ; sim, não há colisão

                                                    
    colide:                                         ; houve colisao
        MOV R2, meteoro_morto                       ; vai desenhar o meteoro morto    
        MOV R0, 0                                   ; reinicia o missil
        MOV [coordenadas_missil], R0                
        MOV R8, 1                                  ; flag que indica que houve colisão com o missil

        JMP fim_testa_choque

    fim_testa_choque:
    POP R7
    POP R6
    POP R5
    POP R4
    POP R3
    POP R1
    POP R0
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
;       R0 - Altera este registo para zero se for para reiniciar o meteoro	
; **********************************************************************
testa_limites_meteoros:
    PUSH	R5
    
    testa_limite_baixo:
        MOV	    R5, MAX_LINHA               ; define o a coordenada maxima da linha
        CMP     R0, R5                      ; vê se ainda estamos entre limites 
        JLE	    sai_testa_limites_meteoros	; entre limites. Mantém o valor do R7 (+1)

    reinicia_meteoro:                        ; se exceder o limite, o meteoro volta ao inicio da grelha
        MOV R0, 0                           ; definimos coordenada da linha igual a 0

    sai_testa_limites_meteoros:	
	    POP	R5
	    RET

; **********************************************************************
;  OBTER_NR_RANDOM - Obtem um numero aleatório de 0 a 7
;
;  RETORNO:
;       R9 - Retorna o valor R9 com um numero aletorio 
; **********************************************************************
obter_nr_random:                ; esta rotina vai buscar valores aletórios ao periférico PIN
    PUSH R0
    PUSH R2
    PUSH R3
    PUSH R4

    MOV     R0, MASCARA                                     ; para isolar os 4 bits de menor peso, ao ler as colunas do teclado
    MOV     R2, TEC_LIN                                     ; endereço do periférico das linhas
    MOV     R3, PIN
    MOV     R4, 2

    MOV    [R2], R4            
    MOV     R9, [R3]                       
    SHR     R9, 5                                       
    AND     R9, R0                                    

    POP R4
    POP R3
    POP R2
    POP R0
    RET

; **********************************************************************
;  ESCOLHE_FORMATO - Obtem o formato do meteoro
;
;  ARGUMENTO:
;       R0 - Linha do meteoro
;       R8 - Endereço da tabel
;       R10 - 
;
;  RETORNO:
;       R2 - Endereço da tabela que define o meteoro a desenhar

;
;  REGISTOS AUXILIARES USADOS:
;       R4 - Registo auxiliar utilizado para a testagem dos limites
;       R8 - Valor que unfica o valor de R9 (assume 1 se 
;            for meteoro bom e -1 se for meteoro mau)
; **********************************************************************
escolhe_formato_aux:
    PUSH R0
    PUSH R4
    PUSH R8

    MOV R8, bom_ou_mau_tab                                  
    MOV R8, [R8+R10]                                         
    
    ve_fase:                                            ; vai ver em que fase estamos     
        MOV     R4, LIM_FASE_4                          ; verifica se estamos na fase 3
        CMP     R0, R4                                  ; compara o valor atual da coordenada da linha com o valor definido para quando o meteoro entra na fase 3
        JGE     fase_3                                  ; se o valor da coordenada for maior que esse limite é pq estamos na fase 3
                                                        ; se não vamos ver se está nas outras fases
        MOV     R2, meteoro_inimigo_2                   ; verifica se estamos na fase 2
        MOV     R4, LIM_FASE_3
        CMP     R0, R4
        JGE     fase_2

        MOV     R2, meteoro_inimigo_1                   ; verifica se estamos na fase 1
        MOV     R4, LIM_FASE_2
        CMP     R0, R4
        JGE     fase_1

        MOV     R2, meteoro_inicio_2                    ; verifica se estamos no inicio_2
        MOV     R4, LIM_FASE_1
        CMP     R0, R4
        JGE     fim                                     ; se estiver, como nesta fase não existe destinção entre meteoros bons e maus, podemos logo saltar para o fim

        MOV     R2, meteoro_inicio_1                    ; só nos resta esta fase 
        JMP     fim         

    fase_3:                                             ; apos vista a fase escolhe o formato do meteoro consoante este seja bom ou mau
        MOV     R2, meteoro_inimigo_3                   ; assumimos que é mau
        CMP     R8, -1                                  ; é mesmo mau?
        JZ      fim                                     ; sim, então termina
        MOV     R2, meteoro_bom_3                       ; não, então é bom
        JMP     fim

    fase_2:
        MOV     R2, meteoro_inimigo_2                   ; assumimos que é mau
        CMP     R8, -1                                  ; é mesmo mau?
        JZ      fim                                     ; sim, então termina
        MOV     R2, meteoro_bom_2                       ; não, então é bom
        JMP     fim

    fase_1:
        MOV     R2, meteoro_inimigo_1                   ; assumimos que é mau
        CMP     R8, -1                                  ; é mesmo mau?
        JZ      fim                                     ; sim, então termina
        MOV     R2, meteoro_bom_1                       ; não, então é bom
        JMP     fim

    fim:
    POP R8
    POP R4
    POP R0
    RET

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
    MOV R11, 0FFFFH
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
	MOV  R1, lock_energia
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