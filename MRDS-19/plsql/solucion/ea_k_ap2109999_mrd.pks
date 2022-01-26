create or replace package ea_k_ap2109999_mrd as
   --
   -- --------------------- VERSION = 1.10 ---------------------
   --
   -- ----------------------------------------------------------
   --  Nota : Inicialmente fue programado por Franklin, luego
   --       : trabajaron otras personas mas. Fec. 29-Ago-2011.
   -- ----------------------------------------------------------
   -- Autor : Manuel Rodriguez                   Version : 1.00
   -- Fecha : 25-Oct-2013
   -- Nota  : Para el manejo de la pantalla de Renovaciones
   --       : Automaticas de Automovil.
   -- Otras : Implemetacion de nuevas Estructuras de procesos,
   --       : Cursores, Query y Tablas. Tambien, creacion de
   --       : tres tareas (MRDEA00015, MRDEA00017, MRDEA00018).
   -- ----------------------------------------------------------
   -- Autor : Manuel Rodriguez                   Version : 1.01
   -- Fecha : 11-Feb-2015                       Sismas : 952524
   -- Modif.: Para filtrar las polizas renovadas en el proceso
   --       : P_RENOVAR_JAVA, porque se quedan enganchadas y
   --       : agregar el nombre del ambiente en uso, en E-Mail.
   -- ----------------------------------------------------------
   -- Autor : Manuel Rodriguez                   Version : 1.03
   -- Fecha : 15-Abr-2015                      Sismas : 1003897
   -- Modif.: Implementar Renovacion por (Control M), solo para
   --       : las polizas que son Autorizadas por Cobros. Que el
   --       : usuario de Luis Garcia (P0308788) pueda renovar.
   --       : Que los ramos (330 y 360) puedan renovar y que los
   --       : errores de las polizas, se vean en JAVA y validar
   --       : que las polizas Rechazas/Autorizadas por Cobros y
   --       : las puestas como NO RENOVAR, no se re-carguen.
   -- ----------------------------------------------------------
   -- Autor : Manuel Rodriguez                   Version : 1.05
   -- Fecha : 29-Sep-2016                      Sismas : 1172394
   -- Modif.: Crear las funsiones (f_verifica_fec_vcto_pol) y
   --       : la (f_buscar_fec_vin_prestamo), para determinar si
   --       : la fec_vcto_pol es mayor a fec_fin_prestamo, para
   --       : que la poliza se renueve con la fec_fin_prestamo.
   -- ----------------------------------------------------------
   -- Autor : Manuel Rodriguez                   Version : 1.09
   -- Fecha : 06-Ene-2017                      Sismas : 1240397
   -- Modif.: Cada vez que se renueve, una poliza, actualize la
   --       : fecha FEC_ACTU=SYSDATE, en la tabla R2000030 y se
   --       : crea el proceso (p_actualiza_fec_r2000030).
   -- ----------------------------------------------------------
   -- Autor : CARRIERHOUSE, RGUERRA               Version : 1.10
   -- Fecha : 18-ago-2021                      Sismas : 
   -- Modif.: Se modifica el procedimiento p_inserta_g2000510
   --       : se agrega el cursor para que automaticamente
   --       : incluya el proceso de exclusion de polizas
   -- Fecha : 24/01/2022
   -- Modif.: Se crea el proceso de validacion de gestor luego
   --         de la pre-renovacion y renovacion
   --         p_valida_gestor
   -- ----------------------------------------------------------   
   --
   /* --------------------------------------------------------
   || Aqui comienza la declaracion de variables GLOBALES
   */ --------------------------------------------------------
   --
   -- Nuevos Procesos:
   PROCEDURE p_carga_polizas_Ctl_M;
   PROCEDURE p_carga_polizas_tarea;
   PROCEDURE p_carga_polizas_tarea_2da;
   PROCEDURE p_carga_inicial_polizas_2da;
   --
   /**
   || Inserta un registro en la tabla
   */
   PROCEDURE p_inserta (p_reg a2109010_mrd%ROWTYPE);
   --
   --
   -- ------------------------------------------------------------
   --
   -- Nuevos Procesos:
   PROCEDURE p_inserta_g2109022(p_reg  g2109022_mrd%ROWTYPE);
   --
   -- ------------------------------------------------------------
   --
   /**
   || p_totaliza_query :
   */
   PROCEDURE p_totaliza_query (
                     p_num_poliza            a2109010_mrd.num_poliza           %TYPE,
                     p_num_poliza_grupo      a2109010_mrd.num_poliza_grupo     %TYPE,
                     p_mes                   a2109010_mrd.mes                  %TYPE,
                     p_anio                  a2109010_mrd.anio                 %TYPE,
                     p_cod_agt               a2009030_mrd.cod_agt              %TYPE,
                     p_cod_nivel3            a2000030.cod_nivel3               %TYPE,
                     p_evolucion             a2109010_mrd.evolucion            %TYPE,
                     p_tip_estatus_riesgo    a2109010_mrd.tip_estatus_riesgo   %TYPE,
                     p_tip_estatus           a2009030_mrd.tip_estatus          %TYPE,
                     p_mca_siniestros        a2109010_mrd.mca_siniestros       %TYPE,
                     p_mca_balance           a2009030_mrd.mca_balance          %TYPE,
                     p_tip_docum             a2109010_mrd.tip_docum            %TYPE,
                     p_cod_docum             a2109010_mrd.cod_docum            %TYPE,
                     p_cod_ramo              a2109010_mrd.cod_ramo             %TYPE,
                     p_tip_coaseguro         a2009030_mrd.tip_coaseguro        %TYPE,
                     p_tip_cuenta            a2009030_mrd.tip_cuenta           %TYPE,
                     p_porc_balance          NUMBER                                 ,
                     p_porc_siniestros       a2009030_mrd.siniestralidad       %TYPE,
                     p_tip_resultado         a2009030_mrd.tip_resultado        %TYPE,
                     p_tip_estatus_cobro     a2009030_mrd.tip_estatus_cobro    %TYPE,
                     p_cod_ejecutivo         a2009030_mrd.cod_ejecutivo        %TYPE,
                     p_num_chasis            a2109010_mrd.num_chasis           %TYPE,
                     p_prima                 a2109010_mrd.prima                %TYPE,
                     p_variacion_d           a2109010_mrd.variacion            %TYPE,
                     p_variacion_h           a2109010_mrd.variacion            %TYPE,
                     p_dnr_ren_d             a2109010_mrd.dnr_ren              %TYPE,
                     p_dnr_ren_h             a2109010_mrd.dnr_ren              %TYPE,
                     p_tip_riesgo            a2109010_mrd.tip_estatus_riesgo   %TYPE,
                     p_cod_mon               a2009030_mrd.cod_mon              %TYPE,
                     p_cod_modalidad_ren     a2109010_mrd.cod_modalidad_ren    %TYPE);
   --
   -- ------------------------------------------------------------
   --
   /**
   || p_query : Lee el registro para consulta/actualizacion
   */
   PROCEDURE p_query(p_num_poliza            a2109010_mrd.num_poliza           %TYPE,
                     p_num_poliza_grupo      a2109010_mrd.num_poliza_grupo     %TYPE,
                     p_mes                   a2109010_mrd.mes                  %TYPE,
                     p_anio                  a2109010_mrd.anio                 %TYPE,
                     p_cod_agt               a2009030_mrd.cod_agt              %TYPE,
                     p_cod_nivel3            a2000030.cod_nivel3               %TYPE,
                     p_evolucion             a2109010_mrd.evolucion            %TYPE,
                     p_tip_estatus_riesgo    a2109010_mrd.tip_estatus_riesgo   %TYPE,
                     p_tip_estatus           a2009030_mrd.tip_estatus          %TYPE,
                     p_mca_siniestros        a2109010_mrd.mca_siniestros       %TYPE,
                     p_mca_balance           a2009030_mrd.mca_balance          %TYPE,
                     p_tip_docum             a2109010_mrd.tip_docum            %TYPE,
                     p_cod_docum             a2109010_mrd.cod_docum            %TYPE,
                     p_cod_ramo              a2109010_mrd.cod_ramo             %TYPE,
                     p_tip_coaseguro         a2009030_mrd.tip_coaseguro        %TYPE,
                     p_tip_cuenta            a2009030_mrd.tip_cuenta           %TYPE,
                     p_porc_balance          NUMBER                                 ,
                     p_porc_siniestros       a2009030_mrd.siniestralidad       %TYPE,
                     p_tip_resultado         a2009030_mrd.tip_resultado        %TYPE,
                     p_tip_estatus_cobro     a2009030_mrd.tip_estatus_cobro    %TYPE,
                     p_cod_ejecutivo         a2009030_mrd.cod_ejecutivo        %TYPE,
                     p_num_chasis            a2109010_mrd.num_chasis           %TYPE,
                     p_prima                 a2109010_mrd.prima                %TYPE,
                     p_cant_riesgos          a2109010_mrd.cant_riesgos         %TYPE,
                     p_variacion_d           a2109010_mrd.variacion            %TYPE,
                     p_variacion_h           a2109010_mrd.variacion            %TYPE,
                     p_dnr_ren_d             a2109010_mrd.dnr_ren              %TYPE,
                     p_dnr_ren_h             a2109010_mrd.dnr_ren              %TYPE,
                     p_tip_riesgo            a2109010_mrd.tip_estatus_riesgo   %TYPE,
                     p_cod_mon               a2009030_mrd.cod_mon              %TYPE,
                     p_cod_modalidad_ren     a2109010_mrd.cod_modalidad_ren    %TYPE);
   --
   -- ------------------------------------------------------------
   --
   /**
   || Devuelve la fila al programa de mantenimiento
   */
   PROCEDURE p_devuelve(
                         p_num_secu_k            IN OUT NUMBER,
                         p_num_poliza            IN OUT a2109010_mrd.num_poliza           %TYPE,
                         p_mes                   IN OUT a2109010_mrd.mes                  %TYPE,
                         p_anio                  IN OUT a2109010_mrd.anio                 %TYPE,
                         p_cod_ramo              IN OUT a2109010_mrd.cod_ramo             %TYPE,
                         p_num_spto              IN OUT a2109010_mrd.num_spto             %TYPE,
                         p_num_apli              IN OUT a2109010_mrd.num_apli             %TYPE,
                         p_num_spto_apli         IN OUT a2109010_mrd.num_spto_apli        %TYPE,
                         p_num_poliza_grupo      IN OUT a2109010_mrd.num_poliza_grupo     %TYPE,
                         p_cod_plan              IN OUT a2109010_mrd.cod_plan             %TYPE,
                         p_nom_plan              IN OUT taaut096_mrd.nom_plan             %TYPE,
                         p_cod_modalidad         IN OUT a2109010_mrd.cod_modalidad        %TYPE,
                         p_cod_modalidad_ren     IN OUT a2109010_mrd.cod_modalidad_ren    %TYPE,
                         p_cant_riesgos          IN OUT a2109010_mrd.cant_riesgos         %TYPE,
                         p_num_riesgo            IN OUT a2109010_mrd.num_riesgo           %TYPE,
                         p_nom_riesgo            IN OUT a2000031.nom_riesgo               %TYPE,
                         p_cod_tip_vehi          IN OUT a2109010_mrd.cod_tip_vehi         %TYPE,
                         p_tip_docum             IN OUT a2109010_mrd.tip_docum            %TYPE,
                         p_cod_docum             IN OUT a2109010_mrd.cod_docum            %TYPE,
                         p_nom_tomador           IN OUT a1001399.nom_tercero              %TYPE,
                         p_cod_marca             IN OUT a2109010_mrd.cod_marca            %TYPE,
                         p_cod_modelo            IN OUT a2109010_mrd.cod_modelo           %TYPE,
                         p_cod_sub_modelo        IN OUT a2109010_mrd.cod_sub_modelo       %TYPE,
                         p_anio_modelo           IN OUT a2109010_mrd.anio_modelo          %TYPE,
                         p_num_chasis            IN OUT a2109010_mrd.num_chasis           %TYPE,
                         p_suma_aseg             IN OUT a2109010_mrd.suma_aseg            %TYPE,
                         p_suma_aseg_ren         IN OUT a2109010_mrd.suma_aseg_ren        %TYPE,
                         p_prima                 IN OUT a2109010_mrd.prima                %TYPE,
                         p_prima_ren             IN OUT a2109010_mrd.prima_ren            %TYPE,
                         p_prima_preren          IN OUT a2109010_mrd.prima_preren         %TYPE,
                         p_nueva_dif_prima_ren   IN OUT a2109010_mrd.nueva_dif_prima_ren  %TYPE,
                         p_nueva_var_prima       IN OUT a2109010_mrd.nueva_var_prima      %TYPE,
                         p_primanetafacturada    IN OUT a2109010_mrd.primanetafacturada   %TYPE,
                         p_tasa                  IN OUT a2109010_mrd.tasa                 %TYPE,
                         p_tasa_ren              IN OUT a2109010_mrd.tasa_ren             %TYPE,
                         p_nueva_tasa            IN OUT a2109010_mrd.nueva_tasa           %TYPE,
                         p_dnr                   IN OUT a2109010_mrd.dnr                  %TYPE,
                         p_dnr_ren               IN OUT a2109010_mrd.dnr_ren              %TYPE,
                         p_variacion_valor       IN OUT a2109010_mrd.variacion_valor      %TYPE,
                         p_variacion_valor_ren   IN OUT a2109010_mrd.variacion_valor_ren  %TYPE,
                         p_diferencia            IN OUT a2109010_mrd.diferencia           %TYPE,
                         p_diferencia_ren        IN OUT a2109010_mrd.diferencia_ren       %TYPE,
                         p_evolucion             IN OUT a2109010_mrd.evolucion            %TYPE,
                         p_evolucion_ren         IN OUT a2109010_mrd.evolucion_ren        %TYPE,
                         p_variacion             IN OUT a2109010_mrd.variacion            %TYPE,
                         p_variacion_ren         IN OUT a2109010_mrd.variacion_ren        %TYPE,
                         p_desc_comercial        IN OUT a2109010_mrd.desc_comercial       %TYPE,
                         p_desc_comercial_ren    IN OUT a2109010_mrd.desc_comercial_ren   %TYPE,
                         p_mca_siniestros        IN OUT a2109010_mrd.mca_siniestros       %TYPE,
                         p_num_siniestros        IN OUT a2109010_mrd.num_siniestros       %TYPE,
                         p_sini_pag              IN OUT a2109010_mrd.sini_pag             %TYPE,
                         p_sini_por_pag          IN OUT a2109010_mrd.sini_por_pag         %TYPE,
                         p_num_sini_menores      IN OUT a2109010_mrd.num_sini_menores     %TYPE,
                         p_num_sini_mayores      IN OUT a2109010_mrd.num_sini_mayores     %TYPE,
                         p_imp_siniestros        IN OUT a2109010_mrd.imp_siniestros       %TYPE,
                         p_mca_sin_mayor_cero    IN OUT a2109010_mrd.mca_sin_mayor_cero   %TYPE,
                         p_factor_recargo        IN OUT a2109010_mrd.factor_recargo       %TYPE,
                         p_factor_ajuste         IN OUT a2109010_mrd.factor_ajuste        %TYPE,
                         p_cod_agt               IN OUT a2009030_mrd.cod_agt              %TYPE,
                         p_nom_intermediario     IN OUT a2009030_mrd.intermediario        %TYPE,
                         p_cod_nivel3            IN OUT a2009030_mrd.cod_nivel3           %TYPE,
                         p_nom_nivel3            IN OUT a2009030_mrd.nom_nivel3           %TYPE,
                         p_fec_efec_riesgo       IN OUT a2109010_mrd.fec_efec_riesgo      %TYPE,
                         p_fec_vcto_riesgo       IN OUT a2109010_mrd.fec_vcto_riesgo      %TYPE,
                         p_tip_coaseguro         IN OUT a2009030_mrd.tip_coaseguro        %TYPE,
                         p_cod_mon               IN OUT a2009030_mrd.cod_mon              %TYPE,
                         p_mca_catastrofico      IN OUT a2009030_mrd.catastrofico         %TYPE,
                         p_direccion             IN OUT a2009030_mrd.direccion            %TYPE,
                         p_mca_balance           IN OUT a2009030_mrd.mca_balance          %TYPE,
                         p_balance               IN OUT a2009030_mrd.balance              %TYPE,
                         p_dias_vig              IN OUT a2009030_mrd.diasvig              %TYPE,
                         p_dias_trans            IN OUT a2009030_mrd.diastrans            %TYPE,
                         p_siniestralidad        IN OUT a2009030_mrd.siniestralidad       %TYPE,
                         p_reaseguro_fac         IN OUT a2009030_mrd.reasegurofac         %TYPE,
                         p_motivo                IN OUT a2009030_mrd.motivo               %TYPE,
                         p_grupo                 IN OUT a2009030_mrd.grupo                %TYPE,
                         p_mca_poliza_automatica IN OUT a2009030_mrd.mca_poliza_automatica%TYPE,
                         p_fec_tratamiento       IN OUT a2109010_mrd.fec_tratamiento      %TYPE,
                         p_tip_situ              IN OUT a2009030_mrd.tip_situ             %TYPE,
                         p_num_orden             IN OUT a2109010_mrd.num_orden            %TYPE,
                         p_tip_estatus           IN OUT a2009030_mrd.tip_estatus          %TYPE,
                         p_tip_cuenta            IN OUT a2009030_mrd.tip_cuenta           %TYPE,
                         p_tip_resultado         IN OUT a2009030_mrd.tip_resultado        %TYPE,
                         p_tip_estatus_cobro     IN OUT a2009030_mrd.tip_estatus_cobro    %TYPE,
                         p_cod_ejecutivo         IN OUT a2009030_mrd.cod_ejecutivo        %TYPE,
                         p_ejecutivo_cobros      IN OUT a2009030_mrd.ejecutivo_cobros     %TYPE,
                         p_cod_cia_coaseguradora IN OUT a2009030_mrd.cod_cia_coaseguradora%TYPE,
                         p_nom_cia_coaseguradora IN OUT a2009030_mrd.nom_cia_coaseguradora%TYPE,
                         p_pct_participacion     IN OUT a2009030_mrd.pct_participacion    %TYPE,
                         p_categoria             IN OUT a2109010_mrd.categoria            %TYPE,
                         p_pct_categoria         IN OUT a2109010_mrd.pct_categoria        %TYPE,
                         p_nom_tip_vehi          IN OUT a2100100.nom_tip_vehi             %TYPE,
                         p_nom_marca             IN OUT a2100400.nom_marca                %TYPE,
                         p_nom_modelo            IN OUT a2100410.nom_modelo               %TYPE,
                         p_nom_sub_modelo        IN OUT a2100420.nom_sub_modelo           %TYPE,
                         p_nom_modalidad         IN OUT g2990004.nom_modalidad            %TYPE,
                         p_nom_modalidad_ren     IN OUT g2990004.nom_modalidad            %TYPE,
                         p_cod_zona_vehi         IN OUT a2109010_mrd.cod_zona_vehi        %TYPE,
                         p_nom_zona_vehi         IN OUT taaut130_mrd.nom_zona_vehi        %TYPE,
                         p_cod_uso_vehi          IN OUT a2109010_mrd.cod_uso_vehi         %TYPE,
                         p_nom_uso_vehi          IN OUT a2100200.nom_uso_vehi             %TYPE,
                         p_num_matricula         IN OUT a2109010_mrd.num_matricula        %TYPE,
                         p_cod_cuadro_com        IN OUT a2109010_mrd.cod_cuadro_com       %TYPE,
                         p_nom_cuadro_com        IN OUT a1001752.nom_cuadro_com           %TYPE,
                         p_cod_oficial           IN OUT a2109010_mrd.cod_oficial          %TYPE,
                         p_nom_oficial           IN OUT v1009733_mrd.nombre               %TYPE,
                         p_tip_benef             IN OUT a2109010_mrd.tip_benef            %TYPE,
                         p_tip_docum_benef       IN OUT a2109010_mrd.tip_docum_benef      %TYPE,
                         p_cod_docum_benef       IN OUT a2109010_mrd.cod_docum_benef      %TYPE,
                         p_nom_benef             IN OUT a1001399.nom_tercero              %TYPE,
                         p_importe_endoso        IN OUT a2109010_mrd.importe_endoso       %TYPE,
                         p_cod_fracc_pago        IN OUT a2109010_mrd.cod_fracc_pago       %TYPE,
                         p_nom_fracc_pago        IN OUT a1001402.nom_fracc_pago           %TYPE,
                         p_pct_desc_com_pol      IN OUT a2109010_mrd.pct_desc_com_pol     %TYPE,
                         p_cod_error_ctrl_tec    IN OUT NUMBER,
                         p_nom_error_ctrl_tec    IN OUT g2000211.nom_error                %TYPE,
                         p_equipo_gas            IN OUT a2109010_mrd.equipo_gas           %TYPE,
                         p_nom_equipo_gas        IN OUT a2109601_mrd.nom_equipo           %TYPE,
                         p_tip_aeroambulancia    IN OUT a2109010_mrd.tip_aeroambulancia   %TYPE,
                         p_nom_aeroambulancia    IN OUT taaut123_mrd.nom_tip_factor_prima %TYPE,
                         p_tip_estatus_riesgo    IN OUT a2109010_mrd.tip_estatus_riesgo   %TYPE,
                         p_ind_sini_acumulado    IN OUT a2109010_mrd.ind_sini_acumulado   %TYPE,
                         p_meses_vig             IN OUT a2109010_mrd.meses_vig            %TYPE,
                         p_estatus_reglas        IN OUT a2009030_mrd.nom_nivel3           %TYPE,
                         p_txt_error_ct          IN OUT a2109010_mrd.txt_error_ct         %TYPE,
                         p_cod_usr               IN OUT a2109010_mrd.cod_usr              %TYPE,
                         p_txt_error_pol         IN OUT a2109010_mrd.txt_error_pol        %TYPE);
   --
   --
   -- ------------------------------------------------------------
   --
   /**
   || Devuelve los campos pk para habilitar/deshabilitar
   */
   FUNCTION f_devuelve_pk RETURN VARCHAR2;
   --
   --
   -- ------------------------------------------------------------
   --
   /**
   || Comprueba si puede crear el registro
   */
   PROCEDURE p_alta(p_cod_pgm VARCHAR2);
   --
   --
   -- ------------------------------------------------------------
   --
   /**
   || Comprueba si puede modificar el registro
   */
   PROCEDURE p_modifica(p_num_secu_k NUMBER  ,
                        p_cod_pgm    VARCHAR2);
   --
    --
    -- ------------------------------------------------------------
   --
   -- -------------------------------------------------------------
   --
   /**
   || Comprueba si puede borrar el registro y lo borra
   */
   PROCEDURE p_borra(p_num_secu_k NUMBER  ,
                     p_cod_pgm    VARCHAR2);
   --
   -- Actualizar Estatus Poliza:
   PROCEDURE p_actualiza_estatus_java ( p_num_poliza            IN  a2109010_mrd.num_poliza           %TYPE,
                                        p_anio                  IN  a2109010_mrd.anio                 %TYPE,
                                        p_mes                   IN  a2109010_mrd.mes                  %TYPE,
                                        p_motivo                IN  a2009030_mrd.motivo               %TYPE,
                                        p_tip_estatus           IN  a2009030_mrd.tip_estatus          %TYPE
                                       );
   --
   -- Actualizar Factor en el riesgo:
   PROCEDURE p_actualiza_riesgo_java ( p_cod_cia               IN  a2109010_mrd.cod_cia              %TYPE,
                                       p_cod_ramo              IN  a2109010_mrd.cod_ramo             %TYPE,
                                       p_num_poliza            IN  a2109010_mrd.num_poliza           %TYPE,
                                       p_num_riesgo            IN  a2109010_mrd.num_riesgo           %TYPE,
                                       p_fec_tratamiento       IN  a2109010_mrd.fec_tratamiento      %TYPE,
                                       p_anio                  IN  a2109010_mrd.anio                 %TYPE,
                                       p_mes                   IN  a2109010_mrd.mes                  %TYPE,
                                       p_num_orden             IN  a2109010_mrd.num_orden            %TYPE,
                                       p_prima_preren          IN  a2109010_mrd.prima_preren         %TYPE,
                                       p_nueva_dif_prima_ren   IN  a2109010_mrd.nueva_dif_prima_ren  %TYPE,
                                       p_nueva_var_prima       IN  a2109010_mrd.nueva_var_prima      %TYPE,
                                       p_diferencia_ren        IN  a2109010_mrd.diferencia_ren       %TYPE,
                                       p_nueva_tasa            IN  a2109010_mrd.nueva_tasa           %TYPE,
                                       p_evolucion_ren         IN  a2109010_mrd.evolucion_ren        %TYPE,
                                       p_tip_estatus           IN  a2009030_mrd.tip_estatus          %TYPE,
                                       p_factor_ajuste         IN  a2109010_mrd.factor_ajuste        %TYPE
                                      );
   --
   -- Fecha: 6-Ene-17, Version: 1.09
   PROCEDURE p_actualiza_fec_r2000030 ( p_cod_cia       IN  a2109010_mrd.num_poliza  %TYPE,
                                        p_num_poliza    IN  a2109010_mrd.num_poliza  %TYPE
                                       );
   --
   /**
   || Graba la informacion de los nuevos registros
   */
   PROCEDURE p_graba;
   --
   -- ------------------------------------------------------------
   --
   /**
   || Controla si hay cambios no grabados
   */
   FUNCTION f_hay_cambios RETURN VARCHAR2;
   --
   -- ------------------------------------------------------------
   --
   /**
   || Valida la columna : num_poliza
   */
   PROCEDURE p_v_num_poliza
            (p_num_poliza            IN     a2109010_mrd.num_poliza           %TYPE);
   --
   -- ------------------------------------------------------------
   --
   /**
   || Valida la columna : cod_ramo
   */
   PROCEDURE p_v_cod_ramo
            (p_cod_ramo              IN     a2109010_mrd.cod_ramo             %TYPE,
             p_nom_ramo              IN OUT a1001800.nom_ramo                 %type );
   --
   -- ------------------------------------------------------------
   --
   PROCEDURE p_v_num_poliza_grupo
            (p_num_poliza_grupo      IN     a2109010_mrd.num_poliza_grupo     %TYPE);
   --
   -- ------------------------------------------------------------
   --
   PROCEDURE p_v_cod_modalidad_ren
            (p_cod_ramo              IN     a2109010_mrd.cod_ramo             %TYPE,
             p_cod_modalidad_ren     IN     a2109010_mrd.cod_modalidad_ren    %TYPE,
             p_nom_modalidad_ren     IN OUT G2990004.nom_modalidad            %TYPE );
   --
   -- ------------------------------------------------------------
   --
   PROCEDURE p_v_cod_mon
            (p_cod_mon               IN     a2009030_mrd.cod_mon       %TYPE);
   --
   -- ------------------------------------------------------------
   --
   /**
   || Para inicializar el package
   */
   PROCEDURE p_inicio;
   --
   -- ------------------------------------------------------------
   --
   /**
   || Para terminar el package
   */
   PROCEDURE p_termina;
   --
   -- ------------------------------------------------------------
   --
   PROCEDURE p_limpia_tablas_r ( p_cod_cia          a2000030.cod_cia           %TYPE,
                                 p_cod_ramo         a2000030.cod_ramo          %TYPE,
                                 p_num_poliza       a2000030.num_poliza        %TYPE,
                                 p_fec_tratamiento  a2000500.fec_tratamiento   %TYPE,
                                 p_num_orden        a2000500.num_orden         %TYPE
                                );
   --
   -- ------------------------------------------------------------
   --
   PROCEDURE p_carga_inicial_polizas;
   --
   -- M.R., Fec. 19-Feb-15, Version : 1.01
   PROCEDURE p_procesar_poliza (p_num_poliza  a2000500.num_poliza%TYPE);
   --
   /**
   || Procedimiento para la carga de las tablas R
   */
   PROCEDURE p_carga_tablas_r ( p_cod_cia          a2000030.cod_cia           %TYPE,
                                p_cod_ramo         a2000030.cod_ramo          %TYPE,
                                p_num_poliza       a2000030.num_poliza        %TYPE,
                                p_fec_tratamiento  a2000500.fec_tratamiento   %TYPE,
                                p_num_orden        a2000500.num_orden         %TYPE
                               );
   --
   -- ------------------------------------------------------------
   --
   /**
   || Procedimiento para la insertar los datos en la tabla
   */
   -- M.R., Fec. 19-Feb-15, Version : 1.01
   PROCEDURE p_inserta_a2109010 (p_num_poliza  a2000030.num_poliza%TYPE);
   --
   -- ------------------------------------------------------------
   --
   /**
   || Procedimiento para el monto de prima factura
   */
   ---
   PROCEDURE p_total_prima_facturada(
             lp_prima                OUT a2109010_mrd.prima               %TYPE,
             lp_prima_ren            OUT a2109010_mrd.prima_ren           %TYPE,
             lp_prima_preren         OUT a2009030_mrd.prima_preren        %TYPE );
   --
   -- ------------------------------------------------------------
   --
   /**
   || Procedimiento para renovar
   */
   --
   PROCEDURE p_renovar_java;
   PROCEDURE p_renovar_pol_Ctl_M_Cobros;   -- Version : 1.03
   PROCEDURE p_renovar_polizas_Tarea;
   PROCEDURE p_renovar_polizas_ramo;
   --
   -- ------------------------------------------------------------
   --
   /**
   || Funci??n que busca el porciento por categoria de vehiculo
   */
   --
   FUNCTION f_pct_x_grupo_vehi (p_Cod_Cia        taaut069_mrd.cod_cia        %TYPE ,
                                p_Cod_Ramo       taaut069_mrd.cod_ramo       %TYPE ,
                                p_Cod_Modalidad  taaut084_mrd.cod_modalidad  %type ,
                                p_Cod_Marca      a2100400.cod_marca          %TYPE ,
                                p_Cod_Modelo     a2100410.cod_modelo         %TYPE ,
                                p_Cod_Sub_Modelo a2100420.cod_sub_modelo     %TYPE ,
                                p_Fec_validez    taaut069_mrd.fec_ini_validez%TYPE )
     RETURN taaut084_mrd.pct_ajuste%TYPE;
   --
   -- ------------------------------------------------------------
   --
   /**
   || Devuelve la fila del manejo radio button
   */
   PROCEDURE p_manejo_radio_button( p_cod_cia       IN     G2109023.cod_cia      %TYPE ,
                                    p_cod_campo     IN     G2109023.cod_campo    %TYPE ,
                                    p_val_campo     IN     G2109023.val_campo    %TYPE ,
                                    p_mca_estado_1  IN OUT G2109023.mca_estado   %TYPE ,
                                    p_mca_estado_2  IN OUT G2109023.mca_estado   %TYPE ,
                                    p_mca_estado_3  IN OUT G2109023.mca_estado   %TYPE ,
                                    p_mca_estado_4  IN OUT G2109023.mca_estado   %TYPE ,
                                    p_mca_estado_5  IN OUT G2109023.mca_estado   %TYPE ,
                                    p_mca_estado_6  IN OUT G2109023.mca_estado   %TYPE ,
                                    p_mca_estado_7  IN OUT G2109023.mca_estado   %TYPE );
   --
   FUNCTION f_campo_variable_a( p_cod_cia      a2000020.cod_cia%TYPE,
                                p_num_poliza   a2000020.num_poliza%TYPE,
                                p_cod_campo    a2000020.cod_campo%TYPE,
                                p_tip_campo    VARCHAR2,  -- V o T
                                p_cod_ramo     a2000020.cod_ramo%TYPE,
                                p_num_riesgo   a2000020.num_riesgo%TYPE
                               ) RETURN VARCHAR2;
   --
   FUNCTION f_campo_variable_r( p_cod_cia      a2000020.cod_cia%TYPE,
                                p_num_poliza   a2000020.num_poliza%TYPE,
                                p_cod_campo    a2000020.cod_campo%TYPE,
                                p_tip_campo    VARCHAR2,  -- V o T
                                p_num_riesgo   a2000020.num_riesgo%TYPE
                               ) RETURN VARCHAR2;
   --
   FUNCTION f_cal_prima_riesgo_a (p_cod_cia      a2000020.cod_cia%TYPE,
                                  p_cod_ramo     a2000020.cod_ramo%TYPE,
                                  p_num_poliza   a2000020.num_poliza%TYPE,
                                  p_num_riesgo   a2000020.num_riesgo%TYPE
                                 ) RETURN NUMBER;
   --
   FUNCTION f_cal_prima_riesgo_n ( p_cod_cia      a2000031.cod_cia%TYPE,
                                   p_cod_ramo     a2000030.cod_ramo%TYPE,
                                   p_num_poliza   a2000031.num_poliza%TYPE,
                                   p_num_riesgo   a2000031.num_riesgo%TYPE
                                 ) RETURN NUMBER;
   --
   FUNCTION f_cal_prima_renovacion(p_cod_cia      a2000020.cod_cia%TYPE,
                                   p_num_poliza   a2000020.num_poliza%TYPE,
                                   p_num_riesgo   a2000020.num_riesgo%TYPE
                                  ) RETURN NUMBER;
   --
   FUNCTION f_cal_siniestro(p_cod_cia          a2000020.cod_cia         %TYPE,
                            p_num_poliza       a2000020.num_poliza      %TYPE,
                            p_num_riesgo       a2000020.num_riesgo      %TYPE,
                            p_fec_efec_riesgo  a2000031.fec_efec_riesgo %TYPE,
                            p_fec_vcto_riesgo  a2000031.fec_vcto_riesgo %TYPE,
                            p_mca_siniestro    IN OUT VARCHAR2,
                            p_num_siniestros   IN OUT NUMBER
                           ) RETURN NUMBER;
   --
   FUNCTION f_cal_ind_sini_acumulado(p_cod_cia            a2000030.cod_cia%TYPE,
                                     p_cod_ramo           a2000030.cod_ramo%TYPE,
                                     p_num_poliza         a2000030.num_poliza%TYPE
                                    ) RETURN NUMBER;
   --
   FUNCTION f_trae_error_CT(p_cod_cia         a2000500.cod_cia%TYPE,
                            p_num_Poliza      a2000500.num_poliza%TYPE,
                            p_num_riesgo      a2109010.num_riesgo%TYPE
                            ) RETURN VARCHAR2;
   --
   -- M.R., Fec. 06-May-15, Version : 1.03
   FUNCTION f_trae_error_POL(p_fec_tratamiento   a2000520.fec_tratamiento %TYPE,
                             p_num_orden         a2000520.num_orden       %TYPE,
                             p_tip_mvto_batch    a2000520.tip_mvto_batch  %TYPE,
                             p_cod_cia           a2000500.cod_cia         %TYPE,
                             p_num_Poliza        a2000500.num_poliza      %TYPE,
                             p_num_riesgo        a2109010.num_riesgo      %TYPE
                             ) RETURN VARCHAR2;
   --
   PROCEDURE p_envia_correo_cargas(p_cod_cia    g1009100.cod_cia%TYPE,
                                   p_nom_forma  g1009100.nom_forma%TYPE,
                                   p_mensage    g1009100.html_message%TYPE );
   --
   FUNCTION f_nom_marca( p_cod_cia      a2000020.cod_cia%TYPE,
                         p_cod_marca    a2100400.cod_marca%TYPE
                       ) RETURN VARCHAR2;
   --
   FUNCTION f_nom_modalidad( p_cod_cia        g2990004.cod_cia%TYPE,      -- Fec. 29-Dic-14
                             p_cod_modalidad  g2990004.cod_modalidad%TYPE
                            ) RETURN VARCHAR2;
   --
   FUNCTION f_cal_desc_tw ( p_dnr_ren          a2109010.dnr_ren%TYPE,
                            p_factor_ajuste    a2109010.factor_ajuste%TYPE
                          ) RETURN NUMBER;
   --
   PROCEDURE p_verifica_spto_poliza;
   --
   PROCEDURE p_siniestro(pcod_cia         a7000900.cod_cia    %TYPE,
                         pnum_poliza      a7000900.num_poliza %TYPE,
                         pnum_riesgo      a7000900.num_riesgo %TYPE,
                         pcod_Ramo        a7000900.cod_ramo   %TYPE,
                         pfec_efec_riesgo a7000900.fec_sini   %TYPE,
                         pfec_vcto_riesgo a7000900.fec_sini   %TYPE,
                         pimp_prima       a2100170.imp_spto   %TYPE,
                         psini_menores    IN OUT NUMBER,
                         psini_mayores    IN OUT NUMBER,
                         pmonto_Sini      IN OUT NUMBER);
   --
   PROCEDURE p_verifica_sini_poliza;
   --
   PROCEDURE p_carga_reglas_periodo ( p_Cod_Cia      a2109013.cod_cia   %TYPE,
                                      p_cod_ramo     a2109013.cod_ramo  %TYPE,
                                      p_num_poliza   a2109013.num_poliza%TYPE,
                                      p_Anio         a2109013.anio      %TYPE,
                                      p_Mes          a2109013.mes       %TYPE );
   --
   PROCEDURE p_aplica_reglas( p_cod_cia                   g2109019_mrd.cod_cia  %TYPE,
                              p_nom_tabla                 g2109019_mrd.nom_tabla%TYPE,
                              p_tip_nivel                 g2000020.tip_nivel    %TYPE,
                              p_cod_ramo                  g2000020.cod_ramo     %TYPE,
                              p_mes                       a2109011_mrd.mes      %TYPE,
                              p_anio                      a2109011_mrd.anio     %TYPE,
                              p_cant_regla_aplicada       IN OUT VARCHAR2,
                              p_owner                     all_tab_columns.owner %TYPE DEFAULT 'TRON2000');
   --
   PROCEDURE p_carga_datos_variables_riesgo( pl_cod_cia    a2000020.cod_cia    %TYPE,
                                             pl_num_poliza a2000020.num_poliza %TYPE,
                                             pl_num_riesgo a2000020.num_riesgo %TYPE,
                                             pl_cod_ramo  a2000020.cod_ramo  %TYPE );
   --
   PROCEDURE p_trata_riesgos( pl_cod_cia  a2000500.cod_cia  %TYPE,
                              pl_num_poliza a2000500.num_poliza %TYPE,
                              pl_cod_ramo  a2000500.cod_ramo  %TYPE );
   --
   PROCEDURE p_trata_coberturas( pl_cod_cia    a1002090.cod_cia   %TYPE,
                                 pl_cod_ramo    a1002090.cod_ramo   %TYPE,
                                 pl_num_poliza   a2000040.num_poliza  %TYPE,
                                 pl_num_riesgo   a2000040.num_riesgo   %TYPE,
                                 pl_cod_modalidad  a1002090.cod_modalidad%TYPE );
   --
   PROCEDURE p_inserta_a2109013 ( p_nom_tabla       g2109019_mrd.nom_tabla%TYPE,
                                  p_cod_campo       g2109019.cod_campo%TYPE,
                                  p_num_regla       a2109011.num_regla%TYPE,
                                  p_num_version     a2109011.num_version%TYPE,
                                  p_mca_prim_carga  a2109011.mca_prim_carga%TYPE,
                                  p_valor           g2109017.val_campo%TYPE
                                );
   --
   PROCEDURE p_cal_desc_tw ( p_dnr_ren                   a2109010.dnr_ren%TYPE,
                             p_factor_ajuste             a2109010.factor_ajuste%TYPE,  -- Version : 1.03
                             p_descuento_tw          OUT a2109010.desc_comercial_ren%TYPE
                           );
   --
   PROCEDURE p_busca_num_renovaciones ( p_cod_cia                   a2109010.cod_cia%TYPE,
                                        p_num_poliza                a2109010.num_poliza%TYPE,
                                        p_num_renovaciones      OUT a2000030.num_renovaciones%TYPE
                                      );
   --
   FUNCTION f_num_renovaciones ( p_cod_cia                   a2109010.cod_cia%TYPE,
                                 p_num_poliza                a2109010.num_poliza%TYPE
                               ) RETURN NUMBER;
   --
   FUNCTION f_calula_riesgos ( p_cod_cia      a2000500.cod_cia     %TYPE,
                               p_num_poliza   a2000500.num_poliza%TYPE
                              ) RETURN NUMBER;
   --
   FUNCTION  f_nom_limite_ant ( p_cod_cia      a2000500.cod_cia   %TYPE,
                                p_cod_ramo     a2000500.cod_ramo  %TYPE,
                                p_num_poliza   a2000500.num_poliza%TYPE,
                                p_num_riesgo   a2000031.num_riesgo%TYPE,
                                p_cod_cob      a1002050.cod_cob   %TYPE
                              ) RETURN VARCHAR2;
   --
   FUNCTION  f_nom_limite_ren ( p_cod_cia      a2000500.cod_cia   %TYPE,
                                p_cod_ramo     a2000500.cod_ramo  %TYPE,
                                p_num_poliza   a2000500.num_poliza%TYPE,
                                p_num_riesgo   a2000031.num_riesgo%TYPE,
                                p_cod_cob      a1002050.cod_cob   %TYPE
                              ) RETURN VARCHAR2;
   --
   FUNCTION f_busca_error ( p_fec_tratamiento   a2000520.fec_tratamiento %TYPE,
                            p_num_order         a2000520.num_orden       %TYPE,
                            p_tip_mvto_batch    a2000520.tip_mvto_batch  %TYPE,
                            p_cod_cia           a2000500.cod_cia         %TYPE,
                            p_num_poliza        a2000500.num_poliza      %TYPE,
                            p_num_riesgo        a2000031.num_riesgo      %TYPE
                          ) RETURN VARCHAR2;
   --
   -- M.R., Version : 1.01
   FUNCTION f_busca_ambiente RETURN VARCHAR2;
   --
   -- M.R., Version : 1.03
   FUNCTION f_busca_max_riesgo ( p_cod_cia      g2309001.cod_cia  %TYPE,
                                 p_cod_ramo     g2309001.cod_ramo %TYPE
                               ) RETURN NUMBER;
   --
   -- M.R., Version : 1.03
   FUNCTION f_verifica_pol_riesgo ( p_cod_cia      a2000030.cod_cia     %TYPE,
                                    p_cod_ramo     a2000030.cod_ramo    %TYPE,
                                    p_num_poliza   a2000030.num_poliza  %TYPE,
                                    p_num_riesgo   a2000031.num_riesgo  %TYPE
                                   ) RETURN VARCHAR2;

   --
   -- M.R., Version : 1.03
   FUNCTION f_verifica_agt_pol ( p_cod_cia         a2000030.cod_cia          %TYPE,
                                 p_cod_agt         a2000030.cod_agt          %TYPE,
                                 p_fec_vcto_poliza a2000030.fec_efec_poliza  %TYPE
                                ) RETURN VARCHAR2;
   --
   -- M.R., Version : 1.05
   FUNCTION f_verifica_fec_vcto_pol( p_cod_cia         a2000030.cod_cia          %TYPE,
                                     p_cod_ramo        a2000030.cod_ramo         %TYPE,
                                     p_num_poliza      a2000030.num_poliza       %TYPE,
                                     p_fec_vcto_poliza a2000030.fec_efec_poliza  %TYPE
                                   ) RETURN VARCHAR2;
   --
   -- M.R., Version : 1.05
   FUNCTION f_buscar_fec_fin_prestamo( p_cod_cia         a2000030.cod_cia          %TYPE,
                                       p_cod_ramo        a2000030.cod_ramo         %TYPE,
                                       p_num_poliza      a2000030.num_poliza       %TYPE
                                     ) RETURN VARCHAR2;
   --
   PROCEDURE p_asigna_globales_menu_poliza;
   --
   PROCEDURE p_asigna_globales_menu_preren;
   --
   -- Fec. 14-Ene-15, Victor:
   PROCEDURE p_fechas_riesgo(p_cod_cia               a2000030.cod_cia         %TYPE,
                             p_num_poliza            a2000030.num_poliza      %TYPE,
                             p_num_riesgo            a2000031.num_riesgo      %TYPE,
                             p_fec_efec_riesgo  OUT  a2000031.fec_efec_riesgo %TYPE,
                             p_fec_vcto_riesgo  OUT  a2000031.fec_vcto_riesgo %TYPE );
   --
END ea_k_ap2109999_mrd;
