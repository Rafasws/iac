; *********************************************************************
; * IST-UL
; * Entrega Final:   grupo12.asm
; * Descrição: O objetivo deste projeto é desenvolver o jogo jogo chuva
;         de meteoros, usando assembly do prcessador educacional, PEPE-16.
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
TEC_DIREITA                 EQU 2       ; tecla que move rover para a direita
TEC_DISPARA                 EQU 1       ; tecla que dispara
TEC_ESQUERDA                EQU 0       ; tecla que move rover para esquerda
TEC_INICIA                  EQU 12      ; tecla que incia o jogo (tecla C)
TEC_PAUSA                   EQU 13      ; tecla que pausa o jogo (tecla D)
TEC_TERMINA                 EQU 14      ; tecla que termian o jogo (tecla E)

; **************
; * Nave
; **************
LARGURA_NAVE		        EQU	5		; largura da nave 
ALTURA_NAVE                 EQU 4       ; altura da nave 
LINHA_INICIAL_NAVE          EQU 28      ; coordenada da linha inicial da nave
COLUNA_INICIAL_NAVE         EQU 31      ; coordenada da coluna inicial da nave 
COR_PIXEL		            EQU	0FFF0H	; cor do pixel nave (amarelo)

; **************
; * Meteoros
; **************
LARGURA_INICIO_1            EQU 1       ; largura inicial dos meteoros
ALTURA_INICIO_1             EQU 1       ; altura incial dos meteoros
LARGURA_INICIO_2            EQU 2       ; largura do estagio inicial 2 dos meteoros
ALTURA_INICIO_2             EQU 2       ; altura do estagio incial 2 dos meteoros
LARGURA_METEORO_1           EQU 3       ; largura dos meteoros na fase 1
ALTURA_METEORO_1            EQU 3       ; altura dos meteoros na fase 1
LARGURA_METEORO_2           EQU 4       ; largura dos meteoros na fase 2
ALTURA_METEORO_2            EQU 4       ; altura dos meteoros na fase 2
LARGURA_METEORO_3           EQU 5       ; largura dos meteoros na fase 3
ALTURA_METEORO_3            EQU 5       ; altura dos meteoros na fase 3
LINHA_INICIAL               EQU 0       ; linha inicial dos meteoros
COLUNA_INICIAL_0            EQU 1       ; coluna inicial do meteoro 1
COLUNA_INICIAL_1            EQU 16      ; coluna inicial do meteoro 2 
COLUNA_INICIAL_2            EQU 32      ; coluna inicial do meteoro 3
COLUNA_INICIAL_3            EQU 48      ; coluna inicial do meteoro 4   
LIM_FASE_1                  EQU 2       ; linha que limita a fase 1 dos meteoros
LIM_FASE_2                  EQU 5       ; linha que limita a fase 2 dos meteoros
LIM_FASE_3                  EQU 9       ; linha que limita a fase 3 dos meteoros
LIM_FASE_4                  EQU 14      ; linha que limita a fase 4 dos meteoros
BOM                         EQU 1       ; valor que define que o meteoro é bom
INIMIGO                     EQU -1      ; valor que define que o meteoro é mau
COR_PIXEL_INICIO            EQU 0F888H  ; cor do pixel dos meteoros no estagio inicial (cizento)
COR_PIXEL_INIMIGO           EQU 0FF00H  ; cor do pixel de meteoros inimigos (vermelho)
COR_PIXEL_BOM               EQU 0F0F0H  ; cor do pixel dos meteoros bons (verde)
COR_PIXEL_MORTO             EQU 0FFEFH  ; cor do pixel dos meteoros quando explodem (branco)

; **************
; * Missil
; **************
LARGURA_MISSIL              EQU 1       ; largura do missil
ALTURA_MISSIL               EQU 1       ; altura do missil
COR_PIXEL_MISSIL            EQU 0F808H  ; cor do missil (roxo)
ALCANCE                     EQU 12      ; alcance em pixeis do missil
COORDENADA_INICIAL_MISSIL   EQU -1      ; coordenada inicial do missil (-1 para ele não aparecer no jogo)

; **************
; * Energia
; **************
TERMINA_ENERGIA              EQU -2      ; valor de flag para quando o jogo termina por falta de energia
ENERGIA_INICIAL              EQU 100     ; valor de energia incial
ZERO_ENERGIA                 EQU 1000H   ; valor a imprimir no display de energia, quando esta atinge o zero
DECREMENTO_ENERGIA           EQU -5      ; decremento cosntante de energia por ciclo
BONUS_ENERGIA_ACERTOU_MISSIL EQU 10      ; aumento de energia por ter acertado missil
BONUS_ENERGIA_METEORO        EQU 10      ; aumento de energia por colisao com meteoro bom 
GASTO_AO_DISPARAR            EQU -5       ; gasto de energia ao disparar missil 

; **************
; * Outras
; **************
ATRASO			            EQU	3000H	; atraso para limitar a velocidade de movimento do boneco
MIN_COLUNA                  EQU 0       ; coordenada minima de coluna
MAX_COLUNA                  EQU 63      ; coordenada maxima de coluna
MIN_LINHA                   EQU 0       ; coordenada minima de linha
MAX_LINHA                   EQU 31      ; coordenada maxima de linha
N_METEORO                   EQU 4       ; nr de meteoros em jogo (inicialmente e por spawn)
TERMINA_CHOQUE              EQU -1      ; valor de flag para quando o jogo termina por choque com meteoro inimigo

; **************
; * Ecrãs
; **************
ECRA_INICIO                 EQU 0       ; ecra incial do jogo (prima c para continuar)  
ECRA_JOGO                   EQU 1       ; ecra de fundo do jogo
ECRA_SEM_ENERGIA            EQU 2       ; ecra quando a energia acaba
ECRA_EXPLODIU               EQU 3       ; ecra de quando a nave choca com um meteoro inimigo
ECRA_PAUSA                  EQU 4       ; ecra de pausa do jogo

; **************
; * Sons
; **************
SOM_DISPARO                 EQU 0       ; som de disparo do missil
SOM_EXPLODE_METEORO         EQU 1       ; som de quando explode meteoro
SOM_BRUH                    EQU 2       ; som quando renicia jogo em pausa
SOM_ESPETACLEEEE            EQU 3       ; som quando come meteoro bom
SOM_MILK                    EQU 4       ; som quando nave embate com meteoro mau
SOM_WINDOWS                 EQU 5       ; som quando nave fica sem energia
SOM_NICE_SHOT               EQU 6       ; som quando o missil atinge meteoro mau
SOM_FUNDO                   EQU 7       ; som de fundo no jogo

; **************
; * Flags
; **************
FLAG_INATIVA                EQU 0       ; valor da flag choque missil quando não há choque 
FLAG_ATIVA                  EQU 1       ; valor da flag choque missil quando há choque


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

meteoro_inimigo_3:                  ; Tabela que define o meteoro inimigo 3
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
    WORD COORDENADA_INICIAL_MISSIL, COORDENADA_INICIAL_MISSIL

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

; **************
; * Locks
; **************    
lock_inimigo:
    LOCK 0
lock_teclado:           ; LOCK para o teclado comunicar aos restantes processos que tecla detetou
    LOCK 0
lock_teclado_continuo:  ; LOCK para o teclado comunicar aos restantes processos que tecla detetou continuamente
    LOCK 0
lock_todos_mortos:
    LOCK 0
lock_missil:
    LOCK 0
lock_energia:
    LOCK 0




PLACE 0H
; **********************************************************************
;                           PROCESSO DE CONTROLO
;
;  DESCRIÇÃO:   Processo responsável, por começar, pausar, terminar, 
;               e reiniciar o jogo. Também é chamado no caso de perder.
;               Inicializa todos os outros processos do jogo
;       
;  RESGISTOS USADOS:
;       R0 - Máscara
;       R1 - Endereço utilizado para selecionar os ecrãs a imprimir
;       R2 - Endereço do periférico das linhas
;       R3 - Endereço do periférico das colunas
;       R4 - Linha 8 do tecla (linha que é varrida nos ciclos espera tecla)
;       R5 - Contem o valor da tecla pressionada nos ciclos espera_tecla 
;       R6 - Contem o valor da tecla pressionada no ciclo espera_pausa
;       R11 - Nr do meteoro a incializar o processo
;
; **********************************************************************
PROCESS SP_inicial_controlo
controlo:
    MOV     SP, SP_inicial_controlo             ; inicia a Stack
    MOV     BTE, tab			                ; inicializa BTE (registo de Base da Tabela de Exceções)
    MOV     [APAGA_AVISO], R1	                ; apaga o aviso de nenhum cenário selecionado (o valor de R1 não é relevante)
    EI0                                         ; ativa as rotinas de interrupção 0, 1 e 2
    EI1                 
    EI2
    EI
    
    MOV R11, N_METEORO                          ; nr de meteoros em jogo guardado em R11

    loop_meteoros:                              ; loop que inicializa os 4 processos dos meteoros
        DEC R11                                 ; menos um processo a inicializar
       
        CALL acao_move_meteoro                  ; inicializa um processo

        CMP R11, 0                              ; já inicializou todos?
        JNZ loop_meteoros                       ; não, então vai incializar
                                                ; sim, inicializa os outro processos
    CALL    teclado                             ; inicializa processo do teclado
    CALL    acao_move_nave                      ; inicializa processo que move o rover
    CALL    acao_missil                         ; inicializa o processo que controla o missil quando disparada
    CALL    energia_rover                       ; inicializa o processo que controla a energia do rover
 
    MOV     R0, MASCARA                         ; para isolar os 4 bits de menor peso, ao ler as colunas do teclado
    MOV     R2, TEC_LIN                         ; endereço do periférico das linhas
    MOV     R3, TEC_COL                         ; endereço do periférico das colunas
    MOV     R4, 8                               ; vai ler na linha 4 do teclado

    coloca_fundo_de_espera_c:
        MOV     R1, ECRA_INICIO			        ; cenário de fundo espera c
        CALL    desenha_fundo                   ; desenha o cenario de fundo
        CALL    inicia_jogo                     ; repõe as variáveis iniciais do jogo
        DI0                                     ; desativa as interrupções 0, 1, 2
        DI1
        DI2
        DI                             

    espera_c:                                   ; neste ciclo espera-se a tecla c ser premida (em loop infinito)
        MOVB    [R2], R4                        ; escrever no periférico de saída a linha do c
        MOVB    R5, [R3]                        ; ler do periférico de entrada (colunas)
        AND     R5, R0                          ; elimina bits para além dos bits 0-3
        CMP     R5, 1                           ; há c premido?
        JNZ     espera_c                        ; se c não foi premido, repete

    MOV R1, ECRA_JOGO                           ; escolhe o ecra de fundo
    CALL desenha_tudo                           ; desenha o ecrã de fundo
        
    espera_pausa:                               ; ciclo base do processo que espera que seja pressionada a tecla de pausa e que verifica o estado do jogo
        MOV R6, [lock_teclado]                  ; bloqueia o processo até ser pressionada uma tecla
                                                ; foi pressionada um tecla
        MOV R5, TEC_PAUSA                       ; vai ver se foi a tecla de pausa
        CMP R6, R5                              ; foi a tecla de pausa?
        JZ pausa                                ; sim então vai para o ciclo que trata da pausa
                                                ; vai verifica o estado do jogo
        MOV R5, TERMINA_CHOQUE                  
        CMP R6, R5                              ; terminou porque chocou?
        JZ termina_jogo_choque                  ; sim,  então vai lidar com esse acontecimento
                                                ; não, então vai verificar se não terminou por falta de energia
        MOV R5, TERMINA_ENERGIA                 
        CMP R6, R5                              ; terminou porque faltou a energia?
        JZ termina_jogo_energia                 ; sim, vai lidar com isso
                                                ; se chegou aqui é porque não pausou o jogo e este continua
        JMP espera_pausa                        ; volta o inicio do ciclo, bloqueando o processo
        
    pausa:                                      ; é pedido para pausar o jogo                 
        MOV R1, ECRA_PAUSA                      ; seleciona o ecrã da pausa
        CALL desenha_fundo                      ; desenha-se o ecrã da pausa
        CALL atraso                             ; este atraso serve para o jogador poder carregar na tecla D (caso contrario o toque teria de ser muito rapido)
       
        DI0                                     ; desativam-se as interrupções
        DI1
        DI2
        DI

        espera_retorna_ou_termina:              ; na pausa so existem duas opções ou espera-se retornar a jogar ou termina-se o jogo
            MOVB    [R2], R4                    ; tal como no ciclo espera_c faz o varrimento da ultima linha do teclado à espera que seja pressionada a tecla de retornar ou de terminar            
            MOVB    R5, [R3]                                    
            AND     R5, R0                           
            CMP     R5, 2                       ; foi pressionada a tecla de retornar?                                                  
            JZ      volta_para_o_jogo           ; sim, então volta ao jogo
            CMP     R5, 4                       ; foi pressionada a tecla de terminar?
            JZ      toca_som_terminar           ; sim, vai tocar o som de terminar e termina o jogo
            JMP espera_retorna_ou_termina       ; não foi pressionada nenhuma destas teclas, então o jogo mantem-se neste ciclo infinitamente (está em pausa)
        
        toca_som_terminar:                      ; toca o som e termina o jogo
            MOV R10, SOM_BRUH                   ; seleciona o som a tocar
            CALL toca_som                       ; toca-o 
            JMP termina_jogo                    ; termina o jogo
        
        volta_para_o_jogo:                      ; vai retornar o jogo
            MOV R1, ECRA_JOGO                   ; repõe o ecrã de fundo do jogo
            CALL desenha_fundo
            JMP espera_pausa                    ; retorna ao ciclo principal deste processo

        termina_jogo_choque:                    ; o jogo termina porque o rover chocou com o meteoro inimigo
            MOV R10, SOM_MILK                   ; toca o som de choque com meteoro inimigo
            CALL toca_som
            MOV R1, ECRA_EXPLODIU               ; coloca o ecrã de choque do rover com meteoro inimigo
            CALL desenha_fundo
            JMP espera_e                        ; vai para o ciclo que espera que o jogador carregue na tecla e

        termina_jogo_energia:                   ; termina jogo por falta de energia do rover
            MOV R10, SOM_WINDOWS                ; toca o som por falta de energia
            CALL toca_som                       
            MOV R1, ECRA_SEM_ENERGIA            ; coloca o ecrã de falta de energia
            CALL desenha_fundo
            JMP espera_e                        ; espera que o jogador carregue na tecla e


        espera_e:                               ; espera que o jogador carregue na tecla e
            MOVB    [R2], R4                    ; identico ao espera c, mas neste caso espera-se que se prima a tecla e
            MOVB    R5, [R3]                                    
            AND     R5, R0                                     
            CMP     R5, 4                                       
            JNZ     espera_e                                    
        
        termina_jogo:                           ; termina-se o jogo
            CALL inicia_jogo                    ; repõe-se valores (coordenadas, energia, etc.) com os valores iniciais
            JMP coloca_fundo_de_espera_c        ; coloca o fundo de espera que se carregue na tecla c

; **********************************************************************
;                               PROCESSO TECLADO
;
;  TECLADO - Processo que lê o teclado, reconhece a tecla premida, converte 
;            o valor da tecla num valor de 0 a F, e comunica com os outros
;            processos, desbloquando-os de modo a relizarem as ações pretendidas
;
;       
;  RESGISTOS AUXILIARES USADOS:
;       R0 - Máscara
;       R1 - Endereço do periférico das linhas
;       R2 - Endereço do periférico das colunas 
;       R3 - Tamanho de teclado 
;       R4 - Coordenada da linha do teclado
;       R5 - Coordenada da coluna do teclado
;       R6 - Valor da tecla pressionada
; **********************************************************************
PROCESS SP_inicial_teclado
teclado:                                        ; inicializações
    MOV     R0, MASCARA                         ; para isolar os 4 bits de menor peso, ao ler as colunas do teclado
    MOV     R1, TEC_LIN                         ; endereço do periférico das linhas
    MOV     R2, TEC_COL                         ; endereço do periférico das colunas
    MOV     R3, TAM_TAB                         ; registo auxiliar que guarda o limite da tabela
    
    inicio_teclado:
    reiniciar:
        MOV     R4, 1                           ; inicia a verificação na linha 1
    
    ciclo_espera_tecla:                         ; neste ciclo espera-se até uma tecla ser premida (em loop infinito)
        WAIT                                   ; como este é um ciclo potencialmente bloquante, instruimos o processador de que ele pode passar para outro processo se ficar bloqueado aqui
        CMP     R4, R3                          ; verfica se excedeu
        JZ      reiniciar                       ; se excedeu voltamos a 1ª linha
        MOVB    [R1], R4                        ; escrever no periférico de saída (linhas)
        MOVB    R5, [R2]                        ; ler do periférico de entrada (colunas)
        AND     R5, R0                          ; elimina bits para além dos bits 0-3
        SHL     R4, 1                           ; passa para a linha seguinte
        CMP     R5, 0                           ; há tecla premida?
        JZ      ciclo_espera_tecla              ; se nenhuma tecla premida, repete
        
    SHR     R4, 1                               ; retoma o valor, pois multiplicamos o valor de R4 uma ultima vez antes de sair do ciclo de cima
    CALL    calcula_tecla                       ; calcula o valor da tecla para um valor de 0 a F
    MOV    [lock_teclado], R6                   ; escreve esse valor no lock do teclado
        
    ha_tecla:                                   ; neste ciclo espera-se até NENHUMA tecla estar premida
        YIELD
        MOV     [lock_teclado_continuo], R6     ; escreve no lock
        MOVB    [R1], R4                        ; escrever no periférico de saída (linhas)
        MOVB    R5, [R2]                        ; ler do periférico de entrada (colunas)
        AND     R5, R0                          ; elimina bits para além dos bits 0-3
        CMP     R5, 0                           ; há tecla premida?
        JZ      reiniciar                       ; repete ciclo
        JMP     ha_tecla                        ; se ainda houver uma tecla premida, espera até não haver

; **********************************************************************
;                   PROCESSO ACAO_MOVE_NAVE  
;
; ACAO_MOVE_NAVE - Processo responsável pelo movimento do rover, move-o 
;                   para a esquerda e para direita de modo continuo 
;                   (consoante a tecla pressionada)
;
;  RESGISTOS AUXILIARES USADOS:
;       R0 - Coordenada da linha
;       R1 - Coordenada da coluna
;       R2 - Endereço da nave
;       R7 - Deslocamento da nave
;       R9 - tecla que o teclado leu
;       R11 - Define valor de atraso
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
        MOV     R11, 700                            ; define um atraso para o rover de modo a ele se mover de uma forma mais fluida
        ciclo_atraso_rover:                     ; atrasa a execucao do programa
            YIELD                               ; como este ciclo é bloqueante, salta para os outros processos (ficando o jogo mais fluido)
            SUB	    R11, 1                          ; subtrai R11 até 0
            JNZ	    ciclo_atraso_rover              ; enquanto não fizer o atraso não sai do ciclo

        MOV     R0, [coordenadas_nave]          ; define coordenada da linha
        MOV     R1, [coordenadas_nave + 2]      ; define a coordenada da coluna
        MOV     R2, nave                        ; define o endereço da nave


        segue:                                  ; vai mover a nave
        CALL    testa_limites_nave              ; vê se o movimento é válido
        CMP     R7, 0                           ; é válido?
        JZ      acao_move_nave                  ; se não for não move a nave
        CALL    apaga_boneco                    ; se for, apaga a nave na posiçao antiga
        ADD     R1, R7                          ; atualiza as coordenada da coluna
        MOV     [coordenadas_nave + 2], R1      ; atualiza em memória as coordenada da coluna da nave
        CALL    desenha_objeto                  ; desenha nave na nova posição
        JMP     acao_move_nave                  ; volta ao inicio (ficando o processo bloquado a espera que se pressione uma tecla no teclado)

; **********************************************************************
;                          PROCESSO ENERGIA_ROVER
;  
;   ENERGIA_ROVER - Processo que controla a energia do rover
;    
;   RESGISTOS AUXILIARES USADOS:
;       R6 - Valor constante a decrementar de energia por ciclo
;       R9 - Varíavel lock
;
; **********************************************************************
PROCESS SP_incial_energia_rover 

energia_rover:
    MOV     R9, [lock_energia]                      ; bloqueia o processo

    MOV     R6, DECREMENTO_ENERGIA                  ; valor a decrementar da energia 
    CALL    converte_em_decimal                     ; decrementa a energia, e imprime no display
 
    JMP     energia_rover                           ; retorna o ciclo, bloqueando o processo e saltando para o proximo

; **********************************************************************
;                   PROCESSO ACAO_MOVE_INIMIGO
;
;   ACAO_MOVE_INIMIGO - Processo responsável pelos meteoros. 
;                       Define pesudo-aletoriamente a sua posição inicial 
;                       e se são bons ou maus. Move-os em cada ciclo. 
;                       Desenha-os nas varias fases. E verifica as colisões 
;                       com os missil e com o rover.
;
;   RESGISTOS AUXILIARES USADOS:
;       R0 - Linha do meteoro
;       R1 - Coluna do meteoro
;       R3 - Usado para registo de comparação (uso do comando CMP)
;       R4 - Endereço da tabela que contem as coordenadas da coluna dos vários meteoros
;       R5 - Endereço da tabela que contem as coordenadas da linha dos vários meteoros
;       R6 - Usado para registo de comparação
;       R7 - Endereço da tabela que contem a informação de que o meteoro é bom ou mau
;       R8 - Flag que é acionada aquando colisoes com missil ou rover e meteoro
;       R9 - Valor aletorio obtido que serve para calcular a coordenada da coluna do 
;            meteoro e se o mesmo é bom ou mau
;       R10 - Deslocamento a fazer as tabelas sobre os processos meteoros
;       R11 - Nº de qual processo meteoro
;       
;
; **********************************************************************
PROCESS SP_inicial_meteoro_0	
						
acao_move_meteoro:                                          ; inicializa o meteoro 
    MOV     R10, R11                                                                       
    SHL     R10, 1                                          ; multiplica R10 por 2 para poder aceder ao registo correto
    MOV     R9, meteoro_SP_tab
    MOV     SP, [R9+R10]
    MOV     R5, linha_meteoro_tab                           ; guardamos em R5 o registo de memória que contem a coordenada da linha do meteoro
    ADD     R5, R10
    MOV     R4, coluna_meteoro_tab                          ; guardamos em R4 o registo de memória que contem a coordenada da coluna do meteoro
    ADD     R4, R10
    MOV     R7, bom_ou_mau_tab                              ; guardamos em R7 o registo de memória que contem se o meteoro e bom ou mau
    ADD     R7, R10

    JMP     inicia_meteoro                                  ; salta logo para o processo iniciar o meteoro (sem as verificações seguintes)

    ciclo_meteoro:                                          ; ciclo que espera que todos os meteoros morram para reaparecerem ao mesmo tempo
        MOV     R3, [nr_meteoros_vivos]                     ; guarda em R3 quantos meteoros estão vivos
        CMP     R3, 0                                       ; já morreram todos?
        JZ      foi_o_ultimo                                ; sim, então este foi o ultimo
        JMP     espera                                      ; não, então espera que todos morram (ficam presos no lock)

        foi_o_ultimo:                                       ; foi o ultimo 
            MOV     [lock_todos_mortos], R3                 ; escreve no lock, desbloqueando os outros meteoros
            MOV     R3, N_METEORO                           ; repoem o nr de meteoros vivos (= 4)
            MOV     [nr_meteoros_vivos], R3                 ; guarda em memória
            JMP     inicia_meteoro                          ; salta o lock para não ficar preso

        espera:                                             ; bloqueia o processo enquanto houverem meteoros vivos
            MOV     R3, [lock_todos_mortos]                        

        inicia_meteoro:                                     ; inicializa o meteoro a ser desenhado
            MOV     R0, 0                                   ; inicializa valor da linha a 0
                                                            ; vamos agora obter agora o valor da coluna (de modo a reduzir a probabilidade de sobreposição de meteoros, dividimos o ecrã em 4 partes e cada meteoro 0, 1, 2 ou 3 so pode spawnar nessa zona)   
            CALL    obter_nr_random                         ; obtem um nr aletorio de 0 a 7 (que fica em R9)
            SHL     R9, 1                                   ; multiplicamos por 2, ficamos com todos os nrs pares de 0 a 14
            MOV     R10, R11                                ; movemos para R10, o nr de meteoro
            MOV     R6, 15                                   
            MUL     R10, R6                                 ; multiplicamos o nr do meteoro por 15 (de modo a partirmos o ecrã em 4)
            ADD     R10, R9                                 ; soma o valor de R9 com R10 de modo a obter um valor de coluna entre [nr_meteoro*15, nr_meteoro_seguinte*15], no caso de n haver meteoro seguinte é até ao fim do ecrã
            MOV     R1, R10                                 ; guardar este valor em R1 (que define a coordenada da linha)   

            MOV     [R5], R0                                ; guarda em memória a coordenada da linha
            MOV     [R4], R1                                ; guarda em memória a coordenada da coluna


        escolhe_se_bom_ou_mau:                              ; decide se o meteoro a dar spawn é bom ou mau
            CALL    obter_nr_random                         ; retorna R9 com um valor de 0 a 7 (se for 0 ou 1 o meteoro é bom)

            MOV     R3, BOM                                 ; assumimos que é bom
            CMP     R9, 0                                   ; é bom ?
            JZ      guarda_valor                            ; se for bom guarda 1                            
            CMP     R9, 1
            JZ      guarda_valor                
            MOV     R3, INIMIGO                             ; se for mau guarda -1

            guarda_valor:                                   ; guarda se o meteoro é bom ou mau em memória
            MOV     [R7], R3


        move_inimigo:                                       ; ciclo que move inimigo
            MOV     R3, [lock_inimigo]                      ; bloqueia o processo em cada ciclo de relogio da interrupção inimigo
            MOV     R0, [R5]                                ; vai buscar à memória a coordenada da linha do meteoro
            MOV     R1, [R4]                                ; vai buscar à memória a coordenada da colunha do meteoro

            CALL    escolhe_formato_aux                     ; escolhe o formato do meteoro (consoante a posição onde ele se encontra)
            CALL    apaga_boneco                            ; apaga meteoro na posiçao antiga

            MOV     R8, FLAG_INATIVA                        ; flag de choque inicializada a 0
            CALL    testa_choque_missil                     ; chama o testa_choque
            MOV     R10, FLAG_ATIVA                         ; a flag do choque foi ativa?
            CMP     R8, FLAG_ATIVA              
            JZ      lida_com_colisao_missil                 ; sim, então colidiu com missil
                                                            ; não, então vamos ver se houve algum choque com a nave
            CALL    testa_choque_nave
            CMP     R8, R10                                 ; a flag de choque foi ativa?
            JZ      lida_com_colisao_nave                   ; sim, então colidiu com nave
                                                            ; se chegamos aqui é porque não houve colisões com nada
            INC     R0                                      ; incrementa valor da linha
            MOV     [R5], R0                                ; guarda este novo valor em memória

            CALL    testa_limites_meteoros                  ; vê se o meteoro está nos limites da grelha
            MOV     R10, LINHA_INICIAL                      
            CMP     R0, R10                                   ; se não tiver é pq o meteoro chegou ao fim (o valor da linha é renializado a zero)
            JZ      chegou_ao_fim                           ; reinicia noutro meteoro
                                                            ; se for só mover o meteoro chegamos aqui
            MOV     R0, [R5]                                ; vamos buscar a linha do meteoro
            MOV     R1, [R4]                                ; vamos buscar a coluna do meteoro
            CALL    desenha_objeto                          ; desenha o meteoro na nova posição
            JMP     move_inimigo                            ; repete o ciclo
            
        chegou_ao_fim:                                      ; chegou ao fim
                CALL    decrementa_nr_meteoros_vivos        ; 
                JMP     ciclo_meteoro                       ; retorna ao ciclo 

        lida_com_colisao_missil:                            ; houve colisão com o missil
            CALL    desenha_objeto                          ; desenha a explosão do meteoro
            MOV     R3, [lock_inimigo]                      ; metemos o lock aqui para que haja um intervalo entre o meteoro desaparecer e o efeito da explosão
            MOV     R10, SOM_EXPLODE_METEORO                ; seleciona o som quando o meteoro explodir
            CALL    toca_som                                ; toca o som 
            CALL    apaga_boneco                            ; apaga a explosão

            CALL decrementa_nr_meteoros_vivos               ; decrementa o valor de meteoros vivos guardado em memoria

            MOV     R8, [R7]                                ; vai buscar informação à memória se o meteoro era bom ou mau
            CMP     R8, INIMIGO                             ; o meteoro era inimigo?
            JZ      recebe_energia                          ; sim, então recebe energia
            JMP     ciclo_meteoro                           ; se não, e porque era bom, renicia o ciclo

            recebe_energia:                                 ; aumenta a energia caso o missil tenha acertado num meteoro bom
            MOV     R10, SOM_NICE_SHOT                      ; som de que acertou num meteoro bom
            CALL    toca_som                
            MOV     R6, BONUS_ENERGIA_ACERTOU_MISSIL        ; recebe um bonus de energia por ter acertado o missil
            CALL    converte_em_decimal                     ; imprime o novo valor de energia no display
            JMP     ciclo_meteoro                           ; reinicia o meteoro

        lida_com_colisao_nave:                              ; houve uma colisao de um meteoro com o rover
            CALL decrementa_nr_meteoros_vivos               ; decrementa o nr de meteoros vivos guardado em memoria

            MOV     R8, [R7]                                ; vai buscar à memória se o meteoro é bom ou mau
            CMP     R8, INIMIGO                             ; é um meteoro inimigo?
            JZ      eh_mau                                  ; sim, então salta para a label
            MOV     R10, SOM_ESPETACLEEEE                   ; não, então é bom
            CALL    toca_som                                ; toca o som de ser bom
            MOV     R6, BONUS_ENERGIA_METEORO               ; recebe bonus de energia por ter colidido com meteoro bom                                  
            CALL    converte_em_decimal                     ; adiciona o valor de energia e imprime no display 
            JMP     ciclo_meteoro                           ; reinicia o meteoro

            eh_mau:                                         ; se o meteoro que o rover colidiu foi inimigo
                MOV     R9, TERMINA_CHOQUE                  ; vai "avisar" o processo de controlo para terminar o jogo 
                MOV     [lock_teclado], R9                  ; escreve no lock_teclado de modo a desbloquear o processo controlo que estava bloqueado neste lock
                JMP     move_inimigo                        ; retorna ao inicio

; **********************************************************************
;                   PROCESSO ACAO_MISSIL
;
;   ACAO_MISSIL - Processo que controla o missil, desenha-o, e move-o até
;                 que este atinja o seu alcance ou choque com um meteoro
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
    MOV     R3, COORDENADA_INICIAL_MISSIL   ; reiniciliza as coordenadas do missil (de modo a que não acione o choque quando ele desaparece)
    MOV     [coordenadas_missil], R3        ; guarda esse valor em memória
    MOV     R3, [lock_teclado]              ; bloqueia o ciclo até ser disparado um missil
    CMP     R3, TEC_DISPARA                 ; a tecla premida foi para disparar?
    JNZ     acao_missil                     ; não, então não dispara
                                            ; sim, dispara
    MOV     R10, SOM_DISPARO                ; toca o som de disparo
    CALL    toca_som
    
    MOV R6, GASTO_AO_DISPARAR               ; decrementa o valor de energia por ter disparado o missil                             
    CALL converte_em_decimal                ; decrementa energia e imprime este novo valor no display

    MOV     R0, [coordenadas_nave]          ; vai buscar as coordenadas da linha da nave
    MOV     R1, [coordenadas_nave + 2]      ; vai buscar as coordenadas da coluna da nave
    MOV     R2, missil                      ; define o missil
    DEC     R0                              ; decrementa a linha (o missil é disparado imediatamente a seguir a nave)
    ADD     R1, 2                           ; e no centro da nave

    MOV     [coordenadas_missil], R0        ; atualiza as coordenadas da linha do missil na memória
    MOV     [coordenadas_missil + 2], R1    ; atauliza as coordenadas da coluna do missil na memória

    MOV R3, ALCANCE                         ; registo que dita quantas vezes o proximo loop se vai repetir
    move_missil:                            ; ciclo que move o missil
        DEC     R3                          ; menos um movimento
        JZ      acao_missil                 ; já moveu até ao alcance? se sim então renicializa o missil
                                            ; não, então move-se mais um pixel para cima
        CALL    desenha_objeto              ; desenha missil
        MOV     R10, [lock_missil]          ; interrupção para que o movimento do missil seja mais lento
        CALL    apaga_boneco
        MOV     R0, [coordenadas_missil]    ; este buscar de valor na memória só é relevante no caso de o missil ter colidido
        DEC     R0                          ; missil sobe uma linha

        MOV     [coordenadas_missil], R0    ; atualiza valor da linha na memória

        CMP     R0, 0                       ; a linha do missil é menor que 1?
        JLT     acao_missil                 ; sim, então chegou ao fim, volta ao inicio do cilo (esta condição serve para parar o movimento do missil caso tenha havido colisão com o meteoro, e a coordenada do missil tenha sido atualizada para -1)
                                           
        JMP     move_missil                 ; o missil continua a subir

; **********************************************************************
; DECREMENTA_NR_METEOROS_VIVOS - Rotina que drecementa 1 o nr de meteoros vivos
;                                  guardado na memória
;
;  RESGISTOS AUXILIARES USADOS:
;       R3 - Nr de meteoros vivos em jogo
; **********************************************************************   
decrementa_nr_meteoros_vivos:
    PUSH    R3

    MOV     R3, [nr_meteoros_vivos]             ; vai buscar a memoria quantos meteoros estão vivos naquele momento
    DEC     R3                                  ; decrementa esse valor
    MOV     [nr_meteoros_vivos], R3             ; guarda o novo valor na memória

    POP     R3
    RET

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
    PUSH    R10   

    MOV     R10, SOM_FUNDO                                  ; toca a musica de fundo do jogo
    CALL    toca_som
    MOV     [APAGA_ECRA], R1

    mostra_nave:                                            ; desenha a nave na posicao inicial
        MOV     R0, LINHA_INICIAL_NAVE                      ; começa por reinicializar a posicao da nave
        MOV     R1, COLUNA_INICIAL_NAVE
        MOV     [coordenadas_nave + 2], R1                  ; reinicializa a coluna

    reinicia_energia:                                       ; rencializa o valor da energia do rover a 100
        MOV     R0, ENERGIA_INICIAL
        MOV     [energia], R0                               ; reinicia o valor em memória       
    
    reinicia_missil:
        MOV     R0, COORDENADA_INICIAL_MISSIL                                                                            
        MOV     [coordenadas_missil], R0                    ; rencializa o valor da linha do missil
        MOV     [coordenadas_missil+2], R0                  ; rencializa o valor da coluna do missil

    reinicia_meteoros:
        MOV     R0, LINHA_INICIAL
        MOV     [linha_meteoro_tab], R0                     ; rencializa o valor da linha do meteoro 0
        MOV     [linha_meteoro_tab+2], R0                   ; rencializa o valor da linha do meteoro 1
        MOV     [linha_meteoro_tab+4], R0                   ; rencializa o valor da linha do meteoro 2
        MOV     [linha_meteoro_tab+6], R0                   ; rencializa o valor da linha do meteoro 3

        MOV     R0, COLUNA_INICIAL_0
        MOV     [coluna_meteoro_tab], R0                    ; rencializa o valor da coluna do meteoro 0
        MOV     R0, COLUNA_INICIAL_1
        MOV     [coluna_meteoro_tab+2], R0                  ; rencializa o valor da coluna do meteoro 1
        MOV     R0, COLUNA_INICIAL_2
        MOV     [coluna_meteoro_tab+4], R0                  ; rencializa o valor da coluna do meteoro 2
        MOV     R0, COLUNA_INICIAL_3
        MOV     [coluna_meteoro_tab+6], R0                  ; rencializa o valor da coluna do meteoro 3


        
        MOV     R0, N_METEORO
        MOV     [nr_meteoros_vivos], R0                     ; rencializa o valor de meteoros vivos
        MOV     [lock_todos_mortos], R0                     ; escreve no lock para desbloquear os processos dos meteoros
    

    fim_inicia_jogo:
    POP     R10
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
;       R6 - Valor de incremento da energia
; **********************************************************************  
desenha_tudo:
    PUSH R0
    PUSH R1
    PUSH R2
    PUSH R6

    MOV R1, ECRA_JOGO               ; seleciona o ecra de jogo
    CALL desenha_fundo

    MOV R0, [coordenadas_nave]      ; define a linha da nave
    MOV R1, [coordenadas_nave+2]    ; define a coluna da nave
    MOV R2, nave                    ; define a nave
    CALL desenha_objeto

    MOV R0, [energia]               ; le a energia em memoria
    MOV R6, 0                       ; argumento do converte_em_decimal
    CALL converte_em_decimal

    POP R6
    POP R2
    POP R1
    POP R0
    RET

; **********************************************************************
;   DESENHA_OBJETO - Rotina que recebes as coordenadas da posição do
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
; CONVERTE_EM_DECIMAL - Recebe um numero em hexa e imprime no display 
;                           em decimal e atualiza a energia em memoria
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
    MOV [DISPLAYS], R4        ; imprime o novo valor de energia no display
    MOV R5, ZERO_ENERGIA      ; este novo valor é zero ?
    CMP R4, R5                  
    JNZ fim_converte2         ; se não é, termina a rotina  

    MOV R4, TERMINA_ENERGIA   ; se for 0, vai "avisar" o processo de controlo de o jogo termina por falta de energia
    MOV [lock_teclado], R4    ; para isso escreve no lock_teclado (lock cujo o processo de controlo foi bloqueado por) com o valor correspondente ao termino de jogo por falta de energia  

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
;       R8  - Flag que indica se colidiu ou não
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
    JMP     fim_testa_choque_nave                           ; se não estão na mesma linha não vai haver colisão

    estao_mesma_linha:
        MOV     R5, [coordenadas_nave + 2]                  ; define coluna nave
        MOV     R3, [nave + 2]                              ; define largura nave
        MOV     R4, [R2 + 2]                                ; define largura meteoro
        CMP     R1, R5                                      ; compara a coluna da esquerda no meteoro com coluna da esquerda da nave
        JGT     ve_maximo                                   ; se a coluna da esquerda do meteoro for maior, vai verificar se esta entre a nave
        JMP     testa_outro_limite                          ; se não testa coluna do meteoro da direita

    ve_maximo:
        ADD     R5, R3                                      ; adiciona a largura as coordenadas da nave para ver o ponto direito
        DEC     R5                                          ; decrementa 1 pois ao somarmos a coordenada com a largura obtemos o ponto a direito do pretendido (daí o decremento)
        CMP     R1, R5                                      ; compara a coluna direita/esquerda do meteoro com a coluna direita da nave
        JLE     bateu                                       ; se for menor é porque bateu

    testa_outro_limite:
        MOV     R5, [coordenadas_nave + 2]                  ; define a coluna da nave 
        ADD     R1, R4                                      ; adiciona a largura do meteoro para verificar o ponto direito
        DEC     R1
        CMP     R1, R5                                      ; compara a coluna direta do meteoro com a coluna esquerda da nave 
        JGE     ve_maximo                                   ; se a coluna direita for maior, vai verificar se está entre a nave  
        JMP     fim_testa_choque_nave                       ; se for menor não há colisão
    bateu:
        MOV     R8, FLAG_ATIVA                              ; se bateu mete o valor de retorno a 1

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
        MOV R0, COORDENADA_INICIAL_MISSIL           ; reinicia o missil
        MOV [coordenadas_missil], R0                
        MOV R8, FLAG_ATIVA                          ; flag que indica que houve colisão com o missil

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
;                         e nesse caso renicia o meteoro
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
        JLE	    sai_testa_limites_meteoros	; entre limites, mantém o meteoro

    reinicia_meteoro:                       ; se exceder o limite, o meteoro volta ao inicio da grelha
        MOV R0, LINHA_INICIAL               ; definimos coordenada da linha igual a 0

    sai_testa_limites_meteoros:	
	    POP	R5
	    RET

; **********************************************************************
;  OBTER_NR_RANDOM - Obtem um numero aleatório de 0 a 7
;
;
;  REGISTOS AUXILIARES USADOS:
;       R0 - Máscara
;       R3 - Endereço da coluna do teclado
;
;  RETORNO:
;       R9 - Retorna o valor R9 com um numero aletorio 
;
;  
; **********************************************************************
obter_nr_random:                ; esta rotina vai buscar valores aletórios ao periférico PIN
    PUSH R0
    PUSH R3

    MOV     R0, MASCARA                                     ; para isolar os 4 bits de menor peso, ao ler as colunas do teclado             
    MOV     R3, TEC_COL

         
    MOVB    R9, [R3]                                        ; obter o numero aletorio               
    SHR     R9, 5                                       
    AND     R9, R0                                    

    POP R3
    POP R0
    RET

; **********************************************************************
;  ESCOLHE_FORMATO - Recebe como argumento a linha do meteoro e a
;                    informação de que se ele é bom ou mau e obtem o 
;                    formato do meteoro
;
;  ARGUMENTO:
;       R0 - Linha do meteoro
;       R7 - Endereço da tabela em memória que contem a informação se os meteoros são bons ou maus 
;
;  RETORNO:
;       R2 - Endereço da tabela que define o meteoro a desenhar

;
;  REGISTOS AUXILIARES USADOS:
;       R4 - Registo auxiliar utilizado para a testagem dos limites
;       R8 - Valor do meteoro (se é bom ou mau)
; **********************************************************************
escolhe_formato_aux:
    PUSH R0
    PUSH R4
    PUSH R8
                              
    MOV R8, [R7]                                         
    
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
        CMP     R8, INIMIGO                             ; é mesmo mau?
        JZ      fim                                     ; sim, então termina
        MOV     R2, meteoro_bom_3                       ; não, então é bom
        JMP     fim

    fase_2:
        MOV     R2, meteoro_inimigo_2                   ; assumimos que é mau
        CMP     R8, INIMIGO                             ; é mesmo mau?
        JZ      fim                                     ; sim, então termina
        MOV     R2, meteoro_bom_2                       ; não, então é bom
        JMP     fim

    fase_1:
        MOV     R2, meteoro_inimigo_1                   ; assumimos que é mau
        CMP     R8, INIMIGO                             ; é mesmo mau?
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

