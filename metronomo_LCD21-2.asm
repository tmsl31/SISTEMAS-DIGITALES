; ----------------------------------------------
; PIC SELECTION
; ----------------------------------------------

    LIST P=18F4550			; Indica que las instrucciones a utilizar
							; corresponden al PIC18F4550
    #include <P18F4550.inc> ; Archivo que contiene los nombres
							; de los registros del PIC

; ----------------------------------------------
; BIT CONFIGURATIONS
; ----------------------------------------------

; Configuraciones de bit para opciones del PIC
    CONFIG PBADEN = OFF
    CONFIG WDT = OFF	    ; Deshabilita el Watchdog Timer
    CONFIG MCLRE = ON	    ; Habilita el Master Clear
    CONFIG DEBUG = ON	    ; Habilita el Debug del PIC
    CONFIG LVP = OFF	    ; Deshabilita
    CONFIG FOSC = XT_XT	    ; Selecciona el tipo de oscilador
							; XT_XT := Oscilador 4[MHz]

; ----------------------------------------------
; GENERAL PURPOSE REGISTERS DEFINITIONS
; ----------------------------------------------
    #define LCD_RS PORTD,0
    #define LCD_RW PORTD,1
    #define LCD_E PORTD,7

    COUNT_H_a           EQU 0x000
    COUNT_H_g           EQU 0x001
    COUNT_L_a           EQU 0x002
    COUNT_L_g           EQU 0x003
    COUNT_M             EQU 0x004
    COUNT_N_g           EQU 0X005
    COUNT_N_a           EQU 0X006
    COUNT_P             EQU 0x007
    COUNT_O             EQU 0X008
    reg_tiempo_delay    EQU 0X009
    reg_contador_compas EQU 0x00A
    reg_estado_compas   EQU 0x00B
    COUNT_Q             EQU 0X00C
    COUNT_R             EQU 0X00D
    COUNT_S             EQU 0X00E
	Conta1              EQU 0X00F
	Conta2              EQU 0X010
	Conta3              EQU 0X011
    compas_led          EQU 0x012
    bit0_led            EQU 0x013
    bit1_led            EQU 0x014
    bit2_led            EQU 0x015
    hola EQU 0x016
    chao equ 0x017
; ----------------------------------------------
; PROGRAM INSTRUCTIONS
; ----------------------------------------------

    org 0x0000
    call LCD_Inicializa
    bcf  LCD_E
    goto start
;-----------------------------------------------------------------
;Seccion que configura las condiciones iniciales de los registros
;y fija configura los puertos de entrada y salida.
;-----------------------------------------------------------------
config_proc
    movlw d'4'
    movwf reg_estado_compas
    movlw '4'
    movwf compas_led
    movlw '1'
    movwf bit2_led
    movlw '5'
    movwf bit1_led
    movlw '0'
    movwf bit0_led
    movlw d'4'
    movwf reg_contador_compas
    movlw 0x02              ;
    movwf COUNT_H_g	    ;Contador para delay de pulsos
    movlw 0x01              ;
    movwf COUNT_H_a	    ;Contador para delay de pulsos
    movlw d'7'            ;
    movwf COUNT_P	    ;Contador para la variacion del tiempo
                        ;                         entre pulsos
    movlw 0x15              ;
    movwf COUNT_N_g           ;Delta tiempo para ancho de pulso.
    movlw 0x38              ;
    movwf COUNT_N_a           ;Delta tiempo para ancho de pulso.
    movlw d'60'
    movwf reg_tiempo_delay  ;Fija el tiempo inicial de delay en d'20'
    movf reg_tiempo_delay, 0
    movwf COUNT_O
    clrf COUNT_L_g	    ;COUNT_L_g = 0
    clrf COUNT_L_a	    ;COUNT_L_a = 0
    clrf COUNT_M	    ;COUNT_M = 0
    clrf PORTC		    ;
    clrf TRISC      	    ;Define los puertos C como salida
    clrf PORTB
    clrf PORTD
    clrf TRISB
    movlw b'01111100'    ;Registro de trabajo en como un 1 de 7 bits
    movwf TRISD             ;Setea el puerto A como entrada (todos sus pines)
    movlw 0x02
    movwf COUNT_Q
    clrf COUNT_S
    movlw 0xB2
    movwf COUNT_R
    movlw '0'
    movwf hola
    decf hola,1
    movlw '9'
    movwf chao
    incf chao,1
    return

;----
;----
;----

Inicio
   call   LCD_Borrar
   call Delay ;Esperar un tiempo antes de comenzar a escribir
   movlw  b'01100110'
   call   LCD_Caracter
   movlw  b'00111010'
   call   LCD_Caracter
   movf   bit2_led,0
   call   LCD_Caracter
   movf   bit1_led,0
   call   LCD_Caracter
   movf   bit0_led,0
   call   LCD_Caracter
   movlw  ' '
   call   LCD_Caracter
   movlw  ' '
   call   LCD_Caracter
   movf   compas_led,0
   call   LCD_Caracter
   movf   hola,0
   call   LCD_Caracter
   movlw  '4'
   call   LCD_Caracter
   call   Delay
   call   Delay
   return

LCD_Inicializa
   call   Retardo_20ms ;Esperar 20 ms
   movlw  b'00110000' ;Mandar 0x30 -> W
   movwf  PORTB ;Enviar W -> PORTB

   call   Retardo_5ms ;Esperar 5ms
   movlw  b'00110000' ;Enviar 0x30 -> W
   movwf  PORTB

   call   Retardo_50us ;Acumular 100us
   call   Retardo_50us ;Acumular 100us
   movlw  b'00110000'
   movwf  PORTB

   movlw  0x0F
   movwf  PORTB

   bsf    LCD_E
   bcf    LCD_E
   return

LCD_Caracter
   bsf    LCD_RS ;Modo Caracter RS = 1
   movwf  PORTB ;Lo que se cargó previamente en W -> PORTB
   bsf    LCD_E ;Activar Enable
   call   Retardo_50us ;Esperar 50us para enviar información
   bcf    LCD_E ;Transición del Enable a 0
   ;call   Delay ;Esperar a poner la siguiente llamada
   return

LCD_Borrar
   movlw  b'00000001' ;Comando para Borrar
   call   LCD_Comando ;Enviar un comando

LCD_Comando
   bcf    LCD_RS ;Modo Comando RS = 0
   movwf  PORTB ;Envia W -> PORTB
   bsf    LCD_E ;Activa Enable
   call   Retardo_50us ;Espera que se envie la información
   bcf    LCD_E ;Transición del Enable
   return

;Retardo_20ms *********************
Retardo_20ms
    movlw  .247
    movwf  Conta1
    movlw  .26
    movwf  Conta2
Re_20ms
    decfsz Conta1, F  ;Salta cuando Conta1 llega a 0
    bra    Re_20ms    ;Salta a Repeat para Decrementar Conta1
    decfsz Conta2, F  ;Salta cuando Conta2 llega a 0
    bra    Re_20ms    ;Salta a Repeat
    Return

;Retardo_5ms *********************
Retardo_5ms
    movlw  .146
    movwf  Conta1
    movlw  .7
    movwf  Conta2
Re_5ms
    decfsz Conta1, F ;Salta cuando Conta1 llega a 0
    bra    Re_5ms    ;Salta a Repeat para Decrementar Conta1
    decfsz Conta2, F ;Salta cuando Conta2 llega a 0
    bra    Re_5ms    ;Salta a Repeat
    Return

;Retardo_200us *********************
Retardo_200us
    movlw  .65
    movwf  Conta1
Re_200us
    decfsz  Conta1, F ;Salta cuando Conta1 llega a 0
    bra     Re_200us  ;Salta a Repeat para Decrementar Conta1
    Return

;Retardo_2ms *********************
Retardo_2ms
    movlw  .151
    movwf  Conta1
    movlw  .3
    movwf  Conta2
Re_2ms
    decfsz  Conta1, F ;Salta cuando Conta1 llega a 0
    bra     Re_2ms    ;Salta a Repeat para Decrementar Conta1
    decfsz  Conta2, F ;Salta cuando Conta2 llega a 0
    bra     Re_2ms    ;Salta a Repeat
    Return

;Retardo_50us *********************
Retardo_50us
    movlw  .15
    movwf  Conta1
Re_50us
    decfsz Conta1, F ;Salta cuando Conta1 llega a 0
    bra    Re_50us   ;Salta a Repeat para Decrementar Conta1
    Return

Delay
    clrf   Conta1
    clrf   Conta2
    movlw  .3
    movwf  Conta3
Re_Delay
    decfsz Conta1, F ;Salta cuando Conta1 llega a 0
    bra    Re_Delay  ;Salta a Repeat para Decrementar Conta1

    decfsz Conta2, F ;Salta cuando Conta2 llega a 0
    bra    Re_Delay  ;Salta a Repeat

    decfsz Conta3, F
    bra    Re_Delay

    Return
;---
;---
;---

delay2                      ;delay para frecuencia de pulsos (bps) 5ms
			    ;Esto da las pulsaciones del metronomo
    decfsz COUNT_M	    ;Notamos que este delay es mayor en comparacion al
    goto delay2             ;anterior, para tener una meor frecuencia.
    decfsz COUNT_P
    goto delay2
    movlw d'7'
    movwf COUNT_P	    ;Resetea el contador para futuras iteraciones.
    return

delay_fijo              ;255 ms
    decfsz COUNT_Q
    goto delay_fijo
    decfsz COUNT_R
    goto delay_fijo
    movlw 0xA2
    movwf COUNT_R
    decfsz COUNT_S
    goto delay_fijo
    movlw 0x02
    movwf COUNT_S
    return


;--------------------------------------------------------
;Modulo que se varia para aumentar o disminuir frecuencia
;--------------------------------------------------------

controlador_frecuencia
    call delay2
    decfsz COUNT_O
    goto controlador_frecuencia
    movf reg_tiempo_delay,0
    movwf COUNT_O
    return

;--------------------------------------------------------
;Loop para generar el sonido
;--------------------------------------------------------

loopsonido_grave                  ;Loop generador de sonido
    call delay_grave		    ;Llama a delay para generar una onda
    btg PORTC, 0	    ;con frecuencia audible
    decfsz COUNT_N_g	    ;Delta tiempo en que suena el parlante
    goto loopsonido_grave
    movlw 0x10              ;Resetea el contador
    movwf COUNT_N_g
    return

loopsonido_agudo                  ;Loop generador de sonido
    bsf PORTC, 2
    call delay_agudo		    ;Llama a delay para generar una onda
    btg PORTC, 0	    ;con frecuencia audible
    decfsz COUNT_N_a	    ;Delta tiempo en que suena el parlante
    goto loopsonido_agudo
    movlw 0x1D              ;Resetea el contador
    movwf COUNT_N_a
    bcf PORTC,2
    return
;-------------------------------------------------------------------------
;Inicio de delays para dar al sonido una cierta frecuencia.
;-------------------------------------------------------------------------

delay_grave                      ;delay para frecuencia de sonido, esto define el
		           ;Tono del bip, bip, bip
    decfsz COUNT_L_g
    goto delay_grave
    decfsz COUNT_H_g	   ;Se usa decfsz para realizar iteraciones que
    goto delay_grave		   ;gasten tiempo
    movlw d'2'
    movwf COUNT_H_g
    return

delay_agudo                      ;delay para frecuencia de sonido, esto define el
		           ;Tono del bip, bip, bip
    decfsz COUNT_L_a
    goto delay_agudo
    decfsz COUNT_H_a	   ;Se usa decfsz para realizar iteraciones que
    goto delay_agudo		   ;gasten tiempo
    movlw d'1'
    movwf COUNT_H_a
    return

;------------------------------------------------------
;Subrutinas para aumentar o disminuir la frecuencia
;------------------------------------------------------
restar_centena 
    decf bit2_led
    movf chao,0
    movwf bit1_led
    return

sumar_centena
    incf bit2_led
    movf hola,0
    movwf bit1_led
    return

bajar_frecuencia
    movlw '0'
    CPFSGT bit1_led
    call restar_centena
    decf bit1_led
    movlw d'10'
    addwf reg_tiempo_delay,1
    call Inicio
    return

aumentar_frecuencia
    movlw '9'
    CPFSLT bit1_led
    call sumar_centena
    incf bit1_led
    movlw d'10'
    subwf reg_tiempo_delay,1
    call Inicio
    return

resetear
    movlw '4'
    movwf compas_led
    return
;----------------------------------------------------
;subrutina para cambiar el compas 2/4 3/4 4/4
;----------------------------------------------------
cambiar_compas
    decf compas_led
    movlw '1'
    CPFSGT compas_led
    call resetear
    call Inicio
    decf reg_estado_compas,1
    movlw d'1'
    CPFSEQ reg_estado_compas
    return
    movlw d'4'
    movwf reg_estado_compas
    return


;--------------------------------------------------------
;inicio del programa (primera instruccion que se ejecuta).
;--------------------------------------------------------
start
    call config_proc

    call Inicio
;--------------------------------------------------------
;--------------------------------------------------------
;Loop principal
;--------------------------------------------------------
;--------------------------------------------------------
loop                        	;Loop principal
    decf reg_contador_compas
    btg PORTC, 1            	;enciende el led (niega el valor del puerto)
    movlw d'0'
    CPFSEQ reg_contador_compas  ;Verifica si reg_contador_compas es 0, si lo es
                                ;Se salta la siguiente instruccion
    call loopsonido_grave       ;Loop para sonido grave
    movlw d'0'
    CPFSGT reg_contador_compas  ;Verifica si reg_contador_compas mayor a 0, si
                                ;Si es, se salta la siguiente instruccion

    call loopsonido_agudo      	;Loop para sonido agudo.
    btg PORTC, 1            	;apaga el led

;--------------
;Control de frecuencia (botones)
;--------------
    call delay_fijo
    call controlador_frecuencia	;Controlar los bpm
    btfsc PORTD,2,0             ;Si PORTD,2 esta en 0 se salta la siguiente
    call bajar_frecuencia       ;Llama a la subrutina que disminuye frecuencia
    btfsc PORTD,3,0             ;Si PORTD,3 esta en 0 se salta la siguiente
    call aumentar_frecuencia
;----
;Control de boton (compases)
;----
    btfsc PORTD,6,0
    call cambiar_compas
;----

    movlw d'0'
    CPFSEQ reg_contador_compas
    goto loop
    movf reg_estado_compas, w
    movwf reg_contador_compas
    goto loop

    end



