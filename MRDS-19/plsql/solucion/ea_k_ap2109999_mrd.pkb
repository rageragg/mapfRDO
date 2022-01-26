create or replace package body ea_k_ap2109999_mrd as
    --
    -- --------------------- Version : 1.19 ---------------------
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
    -- Autor : Manuel Rodriguez                   Version : 1.02
    -- Fecha : 04-Mar-2015                       Sismas : 970973
    -- Modif.: Para controlar que las polizas PRE-RENOVADAS y
    --       : que tengan Control Tecnco, no se Renueven, hasta
    --       : que no sea Autorizado por el usuario.
    -- ----------------------------------------------------------
    -- Autor : Manuel Rodriguez                   Version : 1.03
    -- Fecha : 15-Abr-2015                      Sismas : 1003897
    -- Modif.: Implementar Renovacion por (Control M), solo para
    --       : las polizas que son Autorizadas por Cobros. Que el
    --       : usuario de Luis Garcia (P0308788) pueda renovar.
    --       : Que los ramos (330 y 360) puedan renovar, que los
    --       : errores de las polizas, se vean en JAVA y validar
    --       : que las polizas Rechazas/Autorizadas por Cobros y
    --       : las puestas como NO RENOVAR, no se re-carguen.
    -- ----------------------------------------------------------
    -- Autor : Manuel Rodriguez                   Version : 1.04
    -- Fecha : 23-Mar-2016                      Sismas : 1119262
    -- Modif.: El proceso (p_devuelve), busque el nombre de la
    --       : mod. ant. Los procesos (p_query,p_totaliza_query),
    --       : comparen con (prima_preren), en A2109010_MRD. Las
    --       : (f_cal_prima_riesgo_a y f_cal_prima_riesgo_n), se
    --       : depuraron para buscar Prima Anterior, correcta.
    -- ----------------------------------------------------------
    -- Autor : Manuel Rodriguez                   Version : 1.05
    -- Fecha : 29-Sep-2016                      Sismas : 1172394
    -- Modif.: Crear las funsiones (f_verifica_fec_vcto_pol) y
    --       : la (f_buscar_fec_vin_prestamo), para determinar si
    --       : la fec_vcto_pol es mayor a fec_fin_prestamo, para
    --       : que la poliza se renueve con la fec_fin_prestamo.
    -- ----------------------------------------------------------
    -- Autor : Manuel Rodriguez                   Version : 1.06
    -- Fecha : 10-Oct-2016                      Sismas : 1206128
    -- Modif.: Para restarle un mes (1), a fecha fin prestamo,
    --       : que es el mes de gracia, que se agrega al inicio.
    -- ----------------------------------------------------------
    -- Autor : Manuel Rodriguez                   Version : 1.07
    -- Fecha : 17-Oct-2016                      Sismas : 1208773
    -- Modif.: El proceso (p_actualiza_riesgo_java) porque no se
    --       : esta registrando, en S2000020, el nuevo factor,
    --       : poliza de ejemplo (6340100020744).
    -- ----------------------------------------------------------
    -- Autor : Manuel Rodriguez                   Version : 1.08
    -- Fecha : 03-Nov-2016                      Sismas : 1216034
    -- Modif.: El proceso (p_envia_correo_cargas) para ampliar
    --       : el campo (l_email_usr_cia), da error en CTL. M.
    -- ----------------------------------------------------------
    -- Autor : Manuel Rodriguez                   Version : 1.09
    -- Fecha : 06-Ene-2017                      Sismas : 1240397
    -- Modif.: Cada vez que se renueve, una poliza, actualize la
    --       : fecha FEC_ACTU=SYSDATE, en la tabla R2000030 y se
    --       : crea el proceso (p_actualiza_fec_r2000030).
    -- ----------------------------------------------------------
    -- Autor : Manuel Rodriguez                   Version : 1.10
    -- Fecha : 07-Mar-2017                      Sismas : 1244007
    -- Modif.: Cambio del nombre, Motivo del Suplemento de RF.
    -- ----------------------------------------------------------
    -- Autor : Manuel Rodriguez                   Version : 1.11
    -- Fecha : 23-May-2017                      Sismas : 1295061
    -- Modif.: Hay polizas, que fueron prerenovadas y que dieron
    --       : Control Tecnio, pero el usuario las renovo manual
    --       : y la tabla R2000221 se quedo sucia y ahora no se
    --       : pueden cargar, otra vez, con la tarea MRDEA00015.
    -- ----------------------------------------------------------
    -- Autor : Manuel Rodriguez                   Version : 1.12
    -- Fecha : 24-Ago-2017                     ITSM : IM00051302
    -- Modif.: Cambios, por modificacion de (15) Reglas, que se
    --       : les creo la Version (2), para que los Ramos en
    --       : Dollar, puedan ejecutar. El 340 US, da error.
    -- ----------------------------------------------------------
    -- Autor : Victor Borges y Manuel Rod.        Version : 1.13
    -- Fecha : 31-Oct-2017              CLARITY : MU-2017-069204
    -- Modif.: Declarar una Tabla en Memoria, para registrar los
    --       : Datos Variables, de poliza y riesgo, para que use,
    --       : solo, por la poliza que este en proceso, g_tb_dv.
    --       : Tambien, que se imprima la Poliza Grupo, cuando se
    --       : especifique en los parametros.
    --       : Tambien, se corrige el Total poliza, por Ctrl M.
    --       : Tambien, cambios a (p_aplica_reglas), porque el
    --       : cursor (cl_g2109019), tiene una tabla de mas.
    -- ----------------------------------------------------------
    -- Autor : Manuel Rodriguez                   Version : 1.14
    -- Fecha : 04-Ene-2018                     ITSM : IM00178246
    -- Modif.: Se modifica la funsion (f_campo_variable_a), para
    --       : buscar los nombres de los Datos Variables que se
    --       : enviaran a JAVA. Con la version (1.13), se quito.
    -- ----------------------------------------------------------
    -- Autor : Manuel Rodriguez                   Version : 1.15
    -- Fecha : 22-Mar-2018              CLARITY : MU-2017-069204
    -- Modif.: Modificar (p_aplicar_reglas), para quitar lo que
    --       : se comento con la version (1.13) ya que la tabla
    --       : (a2109011) se debe de usar, para que se pudan ADD
    --       : insertar, las reglas (67,68,69,70), cambio AGT.
    --       : Tambien, se agregaron varias tablas (R), para que
    --       : sean borradas antes de ser usadas por el proceso.
    -- ----------------------------------------------------------
    -- Autor : Cristina Jimenez   V1.16 cejv      Version : 1.16
    -- Fecha : 20-Aug-2018                     ITSM : IM00456590
    -- Modif.: Se coloca la comilla al valor del tip_situ; pues
    --       : genera error de Invalid number y el proceso n.
    -- ----------------------------------------------------------
    -- Autor : Manuel Rodriguez                   Version : 1.17
    -- Fecha : 22-Aug-2018                     ITSM : IM00456590
    -- Modif.: Se completa la comilla al valor del tip_situ y se
    --       : agrega la Glabal JBCOD_USR, para que tambien se
    --       : pueda enviar, desde un Script.
    -- ----------------------------------------------------------
    -- Autor : Manuel Rodriguez                   Version : 1.18
    -- Fecha : 01-Sep-2020              CLARITY : MU-2020-059353
    -- Modif.: El proceso (p_inserta_a2109010) es modificado para
    --       : actualizar el campo L_SUMA_ASEG_REN con el valor
    --       : del campo L_SUMA_ASEG, cuando el VAL_SUB_MODELO no
    --       : se encuentre en la tabla R2000020. Ejp. Ramo 346.
    -- ----------------------------------------------------------
    -- Autor : CARRIERHOUSE, RGUERRA               Version : 1.19
    -- Fecha : 18-ago-2021                      Sismas : 
    -- Modif.: Se modifica el procedimiento p_inserta_g2000510
    --       : se agrega el cursor para que automaticamente
    --       : incluya el proceso de exclusion de polizas
    -- Autor : CARRIERHOUSE, RGUERRA              Version : 1.20         
    -- Fecha : 24-ene-2022                      Sismas : 
    -- Modif.: Se agrega procedimiento P_VALIDA_GESTOR    
    -- ----------------------------------------------------------   
    --
    TYPE reg_a2109010_mrd IS RECORD
        (clave                 ROWID      ,
        num_secu_k            PLS_INTEGER,
        post_query            BOOLEAN    ,
        cod_cia               a2109010_mrd.cod_cia              %TYPE,
        num_poliza            a2109010_mrd.num_poliza           %TYPE,
        mes                   a2109010_mrd.mes                  %TYPE,
        anio                  a2109010_mrd.anio                 %TYPE,
        cod_ramo              a2109010_mrd.cod_ramo             %TYPE,
        num_spto              a2109010_mrd.num_spto             %TYPE,
        num_apli              a2109010_mrd.num_apli             %TYPE,
        num_spto_apli         a2109010_mrd.num_spto_apli        %TYPE,
        num_poliza_grupo      a2109010_mrd.num_poliza_grupo     %TYPE,
        cod_plan              a2109010_mrd.cod_plan             %TYPE,
        cod_modalidad         a2109010_mrd.cod_modalidad        %TYPE,
        cod_modalidad_ren     a2109010_mrd.cod_modalidad_ren    %TYPE,
        cant_riesgos          a2109010_mrd.cant_riesgos         %TYPE,
        num_riesgo            a2109010_mrd.num_riesgo           %TYPE,
        cod_tip_vehi          a2109010_mrd.cod_tip_vehi         %TYPE,
        tip_docum             a2109010_mrd.tip_docum            %TYPE,
        cod_docum             a2109010_mrd.cod_docum            %TYPE,
        cod_marca             a2109010_mrd.cod_marca            %TYPE,
        cod_modelo            a2109010_mrd.cod_modelo           %TYPE,
        cod_sub_modelo        a2109010_mrd.cod_sub_modelo       %TYPE,
        anio_modelo           a2109010_mrd.anio_modelo          %TYPE,
        num_chasis            a2109010_mrd.num_chasis           %TYPE,
        suma_aseg             a2109010_mrd.suma_aseg            %TYPE,
        suma_aseg_ren         a2109010_mrd.suma_aseg_ren        %TYPE,
        prima                 a2109010_mrd.prima                %TYPE,
        prima_ren             a2109010_mrd.prima_ren            %TYPE,
        prima_preren          a2109010_mrd.prima_preren         %TYPE,
        nueva_dif_prima_ren   a2109010_mrd.nueva_dif_prima_ren  %TYPE,
        nueva_var_prima       a2109010_mrd.nueva_var_prima      %TYPE,
        primanetafacturada    a2109010_mrd.primanetafacturada   %TYPE,
        tasa                  a2109010_mrd.tasa                 %TYPE,
        tasa_ren              a2109010_mrd.tasa_ren             %TYPE,
        nueva_tasa            a2109010_mrd.nueva_tasa           %TYPE,
        dnr                   a2109010_mrd.dnr                  %TYPE,
        dnr_ren               a2109010_mrd.dnr_ren              %TYPE,
        variacion_valor       a2109010_mrd.variacion_valor      %TYPE,
        variacion_valor_ren   a2109010_mrd.variacion_valor_ren  %TYPE,
        diferencia            a2109010_mrd.diferencia           %TYPE,
        diferencia_ren        a2109010_mrd.diferencia_ren       %TYPE,
        evolucion             a2109010_mrd.evolucion            %TYPE,
        evolucion_ren         a2109010_mrd.evolucion_ren        %TYPE,
        variacion             a2109010_mrd.variacion            %TYPE,
        variacion_ren         a2109010_mrd.variacion_ren        %TYPE,
        desc_comercial        a2109010_mrd.desc_comercial       %TYPE,
        desc_comercial_ren    a2109010_mrd.desc_comercial_ren   %TYPE,
        mca_siniestros        a2109010_mrd.mca_siniestros       %TYPE,
        num_siniestros        a2109010_mrd.num_siniestros       %TYPE,
        sini_pag              a2109010_mrd.sini_pag             %TYPE,
        sini_por_pag          a2109010_mrd.sini_por_pag         %TYPE,
        num_sini_menores      a2109010_mrd.num_sini_menores     %TYPE,
        num_sini_mayores      a2109010_mrd.num_sini_menores     %TYPE,
        imp_siniestros        a2109010_mrd.imp_siniestros       %TYPE,
        mca_sin_mayor_cero    a2109010_mrd.mca_sin_mayor_cero   %TYPE,
        factor_recargo        a2109010_mrd.factor_recargo       %TYPE,
        factor_ajuste         a2109010_mrd.factor_ajuste        %TYPE,
        fec_efec_riesgo       a2109010_mrd.fec_efec_riesgo      %TYPE,
        fec_vcto_riesgo       a2109010_mrd.fec_vcto_riesgo      %TYPE,
        cod_mon               a2009030_mrd.cod_mon              %TYPE,
        catastrofico          a2009030_mrd.catastrofico         %TYPE,
        fec_tratamiento       a2109010_mrd.fec_tratamiento      %TYPE,
        num_orden             a2109010_mrd.num_orden            %TYPE,
        categoria             a2109010_mrd.categoria            %TYPE,
        pct_categoria         a2109010_mrd.pct_categoria        %TYPE,
        cod_zona_vehi         a2109010_mrd.cod_zona_vehi        %TYPE,
        cod_uso_vehi          a2109010_mrd.cod_uso_vehi         %TYPE,
        num_matricula         a2109010_mrd.num_matricula        %TYPE,
        cod_cuadro_com        a2109010_mrd.cod_cuadro_com       %TYPE,
        cod_oficial           a2109010_mrd.cod_oficial          %TYPE,
        tip_benef             a2109010_mrd.tip_benef            %TYPE,
        tip_docum_benef       a2109010_mrd.tip_docum_benef      %TYPE,
        cod_docum_benef       a2109010_mrd.cod_docum_benef      %TYPE,
        importe_endoso        a2109010_mrd.importe_endoso       %TYPE,
        cod_fracc_pago        a2109010_mrd.cod_fracc_pago       %TYPE,
        pct_desc_com_pol      a2109010_mrd.pct_desc_com_pol     %TYPE,
        equipo_gas            a2109010_mrd.equipo_gas           %TYPE,
        tip_aeroambulancia    a2109010_mrd.tip_aeroambulancia   %TYPE,
        tip_estatus_riesgo    a2109010_mrd.tip_estatus_riesgo   %TYPE,
        ind_sini_acumulado    a2109010_mrd.ind_sini_acumulado   %TYPE,
        meses_vig             a2109010_mrd.meses_vig            %TYPE,
        txt_error_ct          a2109010_mrd.txt_error_ct         %TYPE,
        cod_usr               a2109010_mrd.cod_usr              %TYPE,
        txt_error_pol         a2109010_mrd.txt_error_pol        %TYPE
      );  -- Version : 1.03
    --
    greg_a2109010_mrd      REG_A2109010_MRD;
    greg_a2109010_mrd_nulo REG_A2109010_MRD;
    --
    TYPE tabla_a2109010_mrd IS TABLE OF greg_a2109010_mrd%TYPE INDEX BY BINARY_INTEGER;
    g_tb_a2109010_mrd      TABLA_A2109010_MRD;
    --
    /* --------------------------------------------------------
    || Aqui comienza la declaracion de variables GLOBALES
    */ --------------------------------------------------------
    --
    greg               a2109010_mrd%ROWTYPE;
    g_fec_tratamiento  DATE;
    g_start_date       DATE;
    g_end_date         DATE;
    g_hay_cambios   VARCHAR2(1);
    g_tiene_permiso BOOLEAN;
    g_fila           BINARY_INTEGER;
    g_fila_devuelve  BINARY_INTEGER;
    g_max_secu_query BINARY_INTEGER;
    g_max_secu_ins   BINARY_INTEGER;
    --
    /* ------------------------------------------------
    || ! ATENCION !
    || ------------------------------------------------
    || Se deben definir tantas variables "g_" como
    || parametros tenga el procedimiento "p_query"
    || Se definiran entre las etiquetas TG_GPRV
    || para que se puedan conservar en re-generaciones
    */ ------------------------------------------------
    --
    g_cod_cia               a1000900.cod_cia           %TYPE := 6;
    g_num_poliza            a2109010_mrd.num_poliza    %TYPE;
    g_num_poliza_grupo      a2109010_mrd.num_poliza_grupo %TYPE;  -- Version : 1.03
    g_cod_ramo              a2000030.cod_ramo%type;
    g_cod_rm                a2000030.cod_ramo%type;    -- Version : 1.01
    g_mes                   a2109010_mrd.mes           %TYPE;
    g_anio                  a2109010_mrd.anio          %TYPE;
    g_tip_cuenta            G2309007.TIP_CUENTA%TYPE;
    g_cod_agt               A2000030.cod_agt%TYPE;
    g_tip_mvto_batch        NUMBER (1);
    l_tip_mvto_batch        CONSTANT NUMBER ( 1 ) := 1;
    l_tip_pre_renovacion    CONSTANT NUMBER ( 1 ) := 2;
    g_num_orden             NUMBER (2);
    g_cod_usr               g1010120.cod_usr           %TYPE;
    g_cod_idioma_cp         g1010010.cod_idioma        %TYPE;
    g_cod_idioma            g1010010.cod_idioma        %TYPE;
    g_cod_mensaje_cp        g1010020.cod_mensaje       %TYPE;
    g_anx_mensaje           VARCHAR2(100);
    g_cnt_pk                PLS_INTEGER;
    g_cant_pre_renov        NUMBER(10) := 0;
    g_total_pre_renov       NUMBER(10) := 0;
    g_cant_pol_act          NUMBER(10) := 0;
    g_total_pol_act         NUMBER(10) := 0;
    g_cant_renovadas        NUMBER(10) := 0;
    g_total_renovadas       NUMBER(10) := 0;
    g_cant_regla_aplicada   NUMBER(10) := 0;
    g_cant_regla_poliza     NUMBER(10) := 0;
    g_mca_un_ramo           VARCHAR2(1);
    l_concat                VARCHAR2(30000);
    g_nom_ambiente          VARCHAR2(30); -- Version : 1.01
    g_mca_ctl_m_ren         VARCHAR2(1) := 'N'; -- Version : 1.03
    g_max_riesgo_ind        g2309001.max_riesgo_ind%TYPE := 0; -- Version : 1.03
    --
    -- Fec. 31-Oct-17 (Tabla de Memoria para los Datos Variables). Version : 1.13
    TYPE ry_dv IS RECORD ( 
      val_campo         a2000020.val_campo    %TYPE,
      txt_campo         a2000020.txt_campo    %type 
    );
    TYPE tgy_dv IS TABLE OF ry_dv INDEX BY VARCHAR2 ( 40 );
    g_tb_dv     tgy_dv;
    --
    /* ---------------------------------------------------
    || Aqui comienza la declaracion de constantes GLOBALES
    */ ---------------------------------------------------
    --
    g_k_ini_corchete CONSTANT VARCHAR2(2) := ' [';
    g_k_fin_corchete CONSTANT VARCHAR2(1) := ']';
    --
    /* ----------------------------------------------------
    || Aqui comienza la declaracion de subprogramas LOCALES
    */ ----------------------------------------------------
    --
    /**
    || Devuelve el error al llamador
    */
    PROCEDURE pp_devuelve_error IS
    BEGIN
      --
      --
      IF g_cod_mensaje_cp BETWEEN 20000 AND 20999 THEN
        --
        RAISE_APPLICATION_ERROR( -g_cod_mensaje_cp,
                                ss_k_mensaje.f_texto_idioma(  g_cod_mensaje_cp,
                                                              g_cod_idioma_cp 
                                                            ) ||
                                g_anx_mensaje
                              );
        --
      ELSE
        --
        RAISE_APPLICATION_ERROR(  -20000,
                                  ss_k_mensaje.f_texto_idioma(  g_cod_mensaje_cp,
                                                                g_cod_idioma_cp 
                                                            ) ||
                                  g_anx_mensaje
                                );
        --
      END IF;
      --
    END pp_devuelve_error;
    --
    -- ------------------------------------------------------------
    --
    /**
    || p_valida_gestor : Valida que el gestor de una poliza se mantenga luego de la pre-renovacion
    */
    PROCEDURE p_valida_gestor IS
      --
      l_fec_tratamiento       a2000500.fec_tratamiento%TYPE;
      l_num_orden             a2000500.num_orden%TYPE;
      l_tip_mvto_batch        a2000500.tip_mvto_batch%TYPE;
      l_vigente_ok            BOOLEAN := FALSE;
      l_max_spto_renovar      r2000030.num_spto%TYPE;
      --
      -- seleccionamos las polizas del batch
      CURSOR c_batch IS
        SELECT *
          FROM a2000500 
         WHERE cod_cia         = g_cod_cia  
           AND cod_ramo        = g_cod_ramo 
           AND fec_tratamiento = g_fec_tratamiento
           AND tip_mvto_batch IN (1,2)
           AND tip_situ       IN (3,6) 
         ORDER BY num_poliza;  
      --
      -- selecciono la poliza vigente
      CURSOR c_vigente( pc_num_poliza    a2000030.num_poliza%TYPE,
                        pc_num_spto      a2000030.num_spto%TYPE
                       ) IS
        SELECT *
          FROM a2000030 a
         WHERE a.cod_cia  = g_cod_cia
           AND a.cod_ramo = g_cod_ramo
           AND a.mca_poliza_anulada = 'N'
           AND a.tip_spto <> 'SM'
           AND a.num_poliza = pc_num_poliza
           AND a.num_spto = ( SELECT max(b.num_spto)
                                FROM a2000030 b
                               WHERE b.cod_cia    = a.cod_cia
                                 AND b.num_poliza = a.num_poliza
                                 AND b.mca_spto_anulado <> 'N'
                                 AND b.tip_spto <> 'SM'
                                 AND b.num_spto <= pc_num_spto    
                            )
           AND a.tip_gestor IN ('TA','DB');
      --
      -- resivos de la vigencia
      CURSOR c_recibos_vigencia(pc_num_poliza    a2990700.num_poliza%TYPE,
                                pc_num_spto      a2990700.num_spto%TYPE
                                ) IS
        SELECT DISTINCT cod_gestor, tip_gestor
          FROM a2990700 
         WHERE cod_cia    = g_cod_cia 
           AND num_poliza = pc_num_poliza
           AND num_spto   = pc_num_spto;                     
      --
      r_vigente c_vigente%ROWTYPE;
      r_recibos c_recibos_vigencia%ROWTYPE; 
      --
      -- devuelve el maximo suplemento de la renovacion
      PROCEDURE pp_max_spto_renovacion(pc_num_poliza r2000030.num_poliza%TYPE) IS
      BEGIN 
        --
        SELECT max(num_spto) 
          INTO l_max_spto_renovar
          FROM r2000030 
         WHERE cod_cia    = g_cod_cia
           AND cod_ramo   = g_cod_ramo
           AND num_poliza = pc_num_poliza;
        --
        EXCEPTION 
          WHEN OTHERS THEN
            l_max_spto_renovar := 0;
        --    
      END pp_max_spto_renovacion;    
      --
      -- evalua si se puede actualizar en funcion del gestor de los recibos
      FUNCTION pf_gestor_valido_en_recibo( pc_num_poliza    a2990700.num_poliza%TYPE,
                                           pc_num_spto      a2990700.num_spto%TYPE 
                                          ) RETURN BOOLEAN IS 
        --
        l_tg NUMBER  := 0;
        l_cg NUMBER  := 0;
        --
      BEGIN 
        --
        SELECT count( distinct cod_gestor ), count( distinct tip_gestor )
          INTO l_cg, l_tg 
          FROM a2990700 
         WHERE cod_cia    = g_cod_cia 
           AND num_poliza = pc_num_poliza
           AND num_spto   = pc_num_spto;  
        --   
        RETURN ( l_tg = 1 AND l_cg = 1 );
        --
        EXCEPTION 
          WHEN OTHERS THEN 
            RETURN FALSE;
        --    
      END pf_gestor_valido_en_recibo;
      --                                         
    BEGIN 
      --
      -- recorremos las polizas del batch
      FOR r_batch IN c_batch LOOP
        --
        -- 1.- se busca la poliza vigente en a2000030
        OPEN c_vigente( r_batch.num_poliza, r_batch.num_spto );
        FETCH c_vigente INTO r_vigente;
        l_vigente_ok := c_vigente%FOUND;
        CLOSE c_vigente; 
        -- 2.- se busca la poliza listas para renovar en r2000030
        IF l_vigente_ok THEN 
          --
          pp_max_spto_renovacion( r_vigente.num_poliza );
          --
          -- 3.- se compara los datos del gestor y forma de pago, si es diferente colocar los datos al vigente
          UPDATE r2000030 
             SET cod_fracc_pago  = r_vigente.cod_fracc_pago,
                 tip_gestor      = r_vigente.tip_gestor,
                 cod_gestor      = r_vigente.cod_gestor
           WHERE cod_cia         = g_cod_cia
             AND cod_ramo        = g_cod_ramo
             AND num_poliza      = r_vigente.num_poliza 
             AND num_spto        = l_max_spto_renovar
             AND ( cod_fracc_pago <> r_vigente.cod_fracc_pago OR 
                   tip_gestor     <> r_vigente.tip_gestor OR
                   cod_gestor     <> r_vigente.cod_gestor
                 );              
          --  
          -- se comparan los recibos, se valida la consistencia de la informacin
          IF pf_gestor_valido_en_recibo( r_vigente.num_poliza, r_vigente.num_spto ) THEN
            -- 4.- se establece la priodidad de los recibos
            OPEN c_recibos_vigencia( r_vigente.num_poliza, r_vigente.num_spto );
            FETCH c_recibos_vigencia INTO r_recibos;
            IF c_recibos_vigencia%FOUND THEN
              --
              UPDATE r2000030 
                 SET tip_gestor  = r_recibos.tip_gestor,
                     cod_gestor  = r_recibos.cod_gestor
               WHERE cod_cia         = g_cod_cia
                 AND cod_ramo        = g_cod_ramo
                 AND num_poliza      = r_vigente.num_poliza 
                 AND num_spto        = r_vigente.num_spto
                 AND ( tip_gestor   <> r_recibos.tip_gestor OR
                       cod_gestor   <> r_recibos.cod_gestor
                     );        
              --
            END IF;
            CLOSE c_recibos_vigencia;   
            --
          END IF;
          --   
        END IF;
        --
      END LOOP;
      --
      EXCEPTION 
        WHEN OTHERS THEN
            g_cod_mensaje_cp := SQLCODE;
            g_anx_mensaje := SQLERRM(SQLCODE);
            pp_devuelve_error;
            --
    END p_valida_gestor;
    --
    -- ------------------------------------------------------------
    --
    /**
    || permiso_usr :
    */
    PROCEDURE permiso_usr(p_cod_pgm programas.cod_pgm%TYPE) IS
    BEGIN
      --
      IF NOT g_tiene_permiso THEN
          --
          ss_p_permiso_usr(p_cod_pgm);
          --
          g_tiene_permiso := TRUE;
          --
      END IF;
      --
    END permiso_usr;
    --
    -- ------------------------------------------------------------
    --
    /**
    || bloquea :
    */
    PROCEDURE bloquea IS
      --
      l_num_poliza  a2109010_mrd.num_poliza           %TYPE;
      --
      l_bloqueado   EXCEPTION;
      PRAGMA        EXCEPTION_INIT(l_bloqueado,-54);
      --
    BEGIN
      --
      IF g_tb_a2109010_mrd(g_fila).clave IS NOT NULL THEN
        --
        SELECT num_poliza
          INTO l_num_poliza
          FROM a2109010_mrd
         WHERE rowid = g_tb_a2109010_mrd(g_fila).clave
           FOR UPDATE OF num_poliza NOWAIT;
        --
      ELSE
        --
        SELECT num_poliza
          INTO l_num_poliza
          FROM a2109010_mrd
         WHERE num_poliza            = g_tb_a2109010_mrd(g_fila).num_poliza
           AND mes                   = g_tb_a2109010_mrd(g_fila).mes
           AND anio                  = g_tb_a2109010_mrd(g_fila).anio
           FOR UPDATE OF num_poliza NOWAIT;
        --
      END IF;
      --
      EXCEPTION
          WHEN l_bloqueado THEN
            --
            g_cod_mensaje_cp := 20017;
            g_anx_mensaje := NULL;
            --
            pp_devuelve_error;
            --
    END bloquea;
    --
    -- ------------------------------------------------------------
    --
    /**
    || rellena_registro :
    */
    PROCEDURE rellena_registro(p_fila BINARY_INTEGER) IS
    BEGIN
      --
      greg_a2109010_mrd.cod_cia               := g_tb_a2109010_mrd(p_fila).cod_cia              ;
      greg_a2109010_mrd.num_poliza            := g_tb_a2109010_mrd(p_fila).num_poliza           ;
      greg_a2109010_mrd.mes                   := g_tb_a2109010_mrd(p_fila).mes                  ;
      greg_a2109010_mrd.anio                  := g_tb_a2109010_mrd(p_fila).anio                 ;
      greg_a2109010_mrd.cod_ramo              := g_tb_a2109010_mrd(p_fila).cod_ramo             ;
      greg_a2109010_mrd.num_spto              := g_tb_a2109010_mrd(p_fila).num_spto             ;
      greg_a2109010_mrd.num_apli              := g_tb_a2109010_mrd(p_fila).num_apli             ;
      greg_a2109010_mrd.num_spto_apli         := g_tb_a2109010_mrd(p_fila).num_spto_apli        ;
      greg_a2109010_mrd.num_poliza_grupo      := g_tb_a2109010_mrd(p_fila).num_poliza_grupo     ;
      greg_a2109010_mrd.cod_plan              := g_tb_a2109010_mrd(p_fila).cod_plan             ;
      greg_a2109010_mrd.cod_modalidad         := g_tb_a2109010_mrd(p_fila).cod_modalidad        ;
      greg_a2109010_mrd.cod_modalidad_ren     := g_tb_a2109010_mrd(p_fila).cod_modalidad_ren    ;
      greg_a2109010_mrd.cant_riesgos          := g_tb_a2109010_mrd(p_fila).cant_riesgos         ;
      greg_a2109010_mrd.num_riesgo            := g_tb_a2109010_mrd(p_fila).num_riesgo           ;
      greg_a2109010_mrd.cod_tip_vehi          := g_tb_a2109010_mrd(p_fila).cod_tip_vehi         ;
      greg_a2109010_mrd.tip_docum             := g_tb_a2109010_mrd(p_fila).tip_docum            ;
      greg_a2109010_mrd.cod_docum             := g_tb_a2109010_mrd(p_fila).cod_docum            ;
      greg_a2109010_mrd.cod_marca             := g_tb_a2109010_mrd(p_fila).cod_marca            ;
      greg_a2109010_mrd.cod_modelo            := g_tb_a2109010_mrd(p_fila).cod_modelo           ;
      greg_a2109010_mrd.cod_sub_modelo        := g_tb_a2109010_mrd(p_fila).cod_sub_modelo       ;
      greg_a2109010_mrd.anio_modelo           := g_tb_a2109010_mrd(p_fila).anio_modelo          ;
      greg_a2109010_mrd.num_chasis            := g_tb_a2109010_mrd(p_fila).num_chasis           ;
      greg_a2109010_mrd.suma_aseg             := g_tb_a2109010_mrd(p_fila).suma_aseg            ;
      greg_a2109010_mrd.suma_aseg_ren         := g_tb_a2109010_mrd(p_fila).suma_aseg_ren        ;
      greg_a2109010_mrd.prima                 := g_tb_a2109010_mrd(p_fila).prima                ;
      greg_a2109010_mrd.prima_ren             := g_tb_a2109010_mrd(p_fila).prima_ren            ;
      greg_a2109010_mrd.prima_preren          := g_tb_a2109010_mrd(p_fila).prima_preren         ;
      greg_a2109010_mrd.nueva_dif_prima_ren   := g_tb_a2109010_mrd(p_fila).nueva_dif_prima_ren  ;
      greg_a2109010_mrd.nueva_var_prima       := g_tb_a2109010_mrd(p_fila).nueva_var_prima      ;
      greg_a2109010_mrd.primanetafacturada    := g_tb_a2109010_mrd(p_fila).primanetafacturada   ;
      greg_a2109010_mrd.tasa                  := g_tb_a2109010_mrd(p_fila).tasa                 ;
      greg_a2109010_mrd.tasa_ren              := g_tb_a2109010_mrd(p_fila).tasa_ren             ;
      greg_a2109010_mrd.nueva_tasa            := g_tb_a2109010_mrd(p_fila).nueva_tasa           ;
      greg_a2109010_mrd.dnr                   := g_tb_a2109010_mrd(p_fila).dnr                  ;
      greg_a2109010_mrd.dnr_ren               := g_tb_a2109010_mrd(p_fila).dnr_ren              ;
      greg_a2109010_mrd.variacion_valor       := g_tb_a2109010_mrd(p_fila).variacion_valor      ;
      greg_a2109010_mrd.variacion_valor_ren   := g_tb_a2109010_mrd(p_fila).variacion_valor_ren  ;
      greg_a2109010_mrd.diferencia            := g_tb_a2109010_mrd(p_fila).diferencia           ;
      greg_a2109010_mrd.diferencia_ren        := g_tb_a2109010_mrd(p_fila).diferencia_ren       ;
      greg_a2109010_mrd.evolucion             := g_tb_a2109010_mrd(p_fila).evolucion            ;
      greg_a2109010_mrd.evolucion_ren         := g_tb_a2109010_mrd(p_fila).evolucion_ren        ;
      greg_a2109010_mrd.variacion             := g_tb_a2109010_mrd(p_fila).variacion            ;
      greg_a2109010_mrd.variacion_ren         := g_tb_a2109010_mrd(p_fila).variacion_ren        ;
      greg_a2109010_mrd.desc_comercial        := g_tb_a2109010_mrd(p_fila).desc_comercial       ;
      greg_a2109010_mrd.desc_comercial_ren    := g_tb_a2109010_mrd(p_fila).desc_comercial_ren   ;
      greg_a2109010_mrd.mca_siniestros        := g_tb_a2109010_mrd(p_fila).mca_siniestros       ;
      greg_a2109010_mrd.num_siniestros        := g_tb_a2109010_mrd(p_fila).num_siniestros       ;
      greg_a2109010_mrd.sini_pag              := g_tb_a2109010_mrd(p_fila).sini_pag             ;
      greg_a2109010_mrd.sini_por_pag          := g_tb_a2109010_mrd(p_fila).sini_por_pag         ;
      greg_a2109010_mrd.num_sini_menores      := g_tb_a2109010_mrd(p_fila).num_sini_menores     ;
      greg_a2109010_mrd.num_sini_mayores      := g_tb_a2109010_mrd(p_fila).num_sini_mayores     ;
      greg_a2109010_mrd.imp_siniestros        := g_tb_a2109010_mrd(p_fila).imp_siniestros       ;
      greg_a2109010_mrd.mca_sin_mayor_cero    := g_tb_a2109010_mrd(p_fila).mca_sin_mayor_cero   ;
      greg_a2109010_mrd.factor_recargo        := g_tb_a2109010_mrd(p_fila).factor_recargo       ;
      greg_a2109010_mrd.factor_ajuste         := g_tb_a2109010_mrd(p_fila).factor_ajuste        ;
      greg_a2109010_mrd.fec_efec_riesgo       := g_tb_a2109010_mrd(p_fila).fec_efec_riesgo          ;
      greg_a2109010_mrd.fec_vcto_riesgo       := g_tb_a2109010_mrd(p_fila).fec_vcto_riesgo          ;
      greg_a2109010_mrd.cod_mon               := g_tb_a2109010_mrd(p_fila).cod_mon              ;
      greg_a2109010_mrd.fec_tratamiento       := g_tb_a2109010_mrd(p_fila).fec_tratamiento      ;
      greg_a2109010_mrd.num_orden             := g_tb_a2109010_mrd(p_fila).num_orden            ;
      greg_a2109010_mrd.categoria             := g_tb_a2109010_mrd(p_fila).categoria            ;
      greg_a2109010_mrd.pct_categoria         := g_tb_a2109010_mrd(p_fila).pct_categoria        ;
      greg_a2109010_mrd.cod_zona_vehi         := g_tb_a2109010_mrd(p_fila).cod_zona_vehi        ;
      greg_a2109010_mrd.cod_uso_vehi          := g_tb_a2109010_mrd(p_fila).cod_uso_vehi         ;
      greg_a2109010_mrd.num_matricula         := g_tb_a2109010_mrd(p_fila).num_matricula        ;
      greg_a2109010_mrd.cod_cuadro_com        := g_tb_a2109010_mrd(p_fila).cod_cuadro_com       ;
      greg_a2109010_mrd.cod_oficial           := g_tb_a2109010_mrd(p_fila).cod_oficial          ;
      greg_a2109010_mrd.tip_benef             := g_tb_a2109010_mrd(p_fila).tip_benef            ;
      greg_a2109010_mrd.tip_docum_benef       := g_tb_a2109010_mrd(p_fila).tip_docum_benef      ;
      greg_a2109010_mrd.cod_docum_benef       := g_tb_a2109010_mrd(p_fila).cod_docum_benef      ;
      greg_a2109010_mrd.importe_endoso        := g_tb_a2109010_mrd(p_fila).importe_endoso       ;
      greg_a2109010_mrd.cod_fracc_pago        := g_tb_a2109010_mrd(p_fila).cod_fracc_pago       ;
      greg_a2109010_mrd.pct_desc_com_pol      := g_tb_a2109010_mrd(p_fila).pct_desc_com_pol     ;
      greg_a2109010_mrd.equipo_gas            := g_tb_a2109010_mrd(p_fila).equipo_gas           ;
      greg_a2109010_mrd.tip_aeroambulancia    := g_tb_a2109010_mrd(p_fila).tip_aeroambulancia   ;
      greg_a2109010_mrd.tip_estatus_riesgo    := g_tb_a2109010_mrd(p_fila).tip_estatus_riesgo   ;
      greg_a2109010_mrd.ind_sini_acumulado    := g_tb_a2109010_mrd(p_fila).ind_sini_acumulado   ;
      greg_a2109010_mrd.meses_vig             := g_tb_a2109010_mrd(p_fila).meses_vig            ;
      greg_a2109010_mrd.txt_error_ct          := g_tb_a2109010_mrd(p_fila).txt_error_ct         ;
      greg_a2109010_mrd.cod_usr               := g_tb_a2109010_mrd(p_fila).cod_usr              ;
      greg_a2109010_mrd.txt_error_pol         := g_tb_a2109010_mrd(p_fila).txt_error_pol        ; -- Version : 1.03
      --
    END rellena_registro;
    --
    -- ------------------------------------------------------------
    --
    /**
    || Llamada a los objetos para hacer "post-query"
    */
    PROCEDURE post_query(p_fila BINARY_INTEGER) IS
    BEGIN
      --
      /* --------------------------------------------------
      || ! ATENCION !
      || --------------------------------------------------
      || Aqui es donde se debe realizar las llamadas a los
      || objetos  que hagan el  "POST-QUERY", y actualizar
      || las posiciones de la tabla PL/SQL. Ademas, se de-
      || be realizar en el "THEN"
      || --------------------------------------------------
      || Ejemplo :
      || g_tb_<nombre_tabla>(p_fila).<nombre_campo> := xxx;
      */ --------------------------------------------------
      --
      IF NOT g_tb_a2109010_mrd(p_fila).post_query THEN
        --
        rellena_registro(p_fila);
        --
        g_tb_a2109010_mrd(p_fila).post_query := TRUE;
        --
      END IF;
      --
    END post_query;
    --
    -- ------------------------------------------------------------
    --
    /**
    || Inserta un registro en la tabla
    */
    PROCEDURE p_inserta(p_reg a2109010_mrd%ROWTYPE) IS
    BEGIN
        --
        INSERT INTO a2109010_mrd
          ( cod_cia              ,
            num_poliza           ,
            mes                  ,
            anio                 ,
            cod_ramo             ,
            num_spto             ,
            num_apli             ,
            num_spto_apli        ,
            num_poliza_grupo     ,
            cod_plan             ,
            cod_modalidad        ,
            cod_modalidad_ren    ,
            cant_riesgos         ,
            num_riesgo           ,
            cod_tip_vehi         ,
            tip_docum            ,
            cod_docum            ,
            cod_marca            ,
            cod_modelo           ,
            cod_sub_modelo       ,
            anio_modelo          ,
            num_chasis           ,
            suma_aseg            ,
            suma_aseg_ren        ,
            prima                ,
            prima_ren            ,
            prima_preren         ,
            nueva_dif_prima_ren  ,
            nueva_var_prima      ,
            primanetafacturada   ,
            tasa                 ,
            tasa_ren             ,
            nueva_tasa           ,
            dnr                  ,
            dnr_ren              ,
            variacion_valor      ,
            variacion_valor_ren  ,
            diferencia           ,
            diferencia_ren       ,
            evolucion            ,
            evolucion_ren        ,
            variacion            ,
            variacion_ren        ,
            desc_comercial       ,
            desc_comercial_ren   ,
            mca_siniestros       ,
            num_siniestros       ,
            sini_pag             ,
            sini_por_pag         ,
            num_sini_menores     ,
            num_sini_mayores     ,
            imp_siniestros       ,
            mca_sin_mayor_cero   ,
            factor_recargo       ,
            factor_ajuste        ,
            fec_efec_riesgo      ,
            fec_vcto_riesgo      ,
            fec_tratamiento      ,
            num_orden            ,
            categoria            ,
            pct_categoria        ,
            cod_zona_vehi        ,
            cod_uso_vehi         ,
            num_matricula        ,
            cod_cuadro_com       ,
            cod_oficial          ,
            tip_benef            ,
            tip_docum_benef      ,
            cod_docum_benef      ,
            importe_endoso       ,
            cod_fracc_pago       ,
            pct_desc_com_pol     ,
            equipo_gas           ,
            tip_aeroambulancia   ,
            tip_estatus_riesgo   ,
            ind_sini_acumulado   ,
            meses_vig            ,
            txt_error_ct         ,
            mca_inh              ,
            cod_usr              ,
            txt_error_pol     -- Version : 1.03
          )
      VALUES (
            p_reg.cod_cia              ,
            p_reg.num_poliza           ,
            p_reg.mes                  ,
            p_reg.anio                 ,
            p_reg.cod_ramo             ,
            p_reg.num_spto             ,
            p_reg.num_apli             ,
            p_reg.num_spto_apli        ,
            p_reg.num_poliza_grupo     ,
            p_reg.cod_plan             ,
            p_reg.cod_modalidad        ,
            p_reg.cod_modalidad_ren    ,
            p_reg.cant_riesgos         ,
            p_reg.num_riesgo           ,
            p_reg.cod_tip_vehi         ,
            p_reg.tip_docum            ,
            p_reg.cod_docum            ,
            p_reg.cod_marca            ,
            p_reg.cod_modelo           ,
            p_reg.cod_sub_modelo       ,
            p_reg.anio_modelo          ,
            p_reg.num_chasis           ,
            p_reg.suma_aseg            ,
            p_reg.suma_aseg_ren        ,
            p_reg.prima                ,
            p_reg.prima_ren            ,
            p_reg.prima_preren         ,
            p_reg.nueva_dif_prima_ren  ,
            p_reg.nueva_var_prima      ,
            p_reg.primanetafacturada   ,
            p_reg.tasa                 ,
            p_reg.tasa_ren             ,
            p_reg.nueva_tasa           ,
            p_reg.dnr                  ,
            p_reg.dnr_ren              ,
            p_reg.variacion_valor      ,
            p_reg.variacion_valor_ren  ,
            p_reg.diferencia           ,
            p_reg.diferencia_ren       ,
            p_reg.evolucion            ,
            p_reg.evolucion_ren        ,
            p_reg.variacion            ,
            p_reg.variacion_ren        ,
            p_reg.desc_comercial       ,
            p_reg.desc_comercial_ren   ,
            p_reg.mca_siniestros       ,
            p_reg.num_siniestros       ,
            p_reg.sini_pag             ,
            p_reg.sini_por_pag         ,
            p_reg.num_sini_menores     ,
            p_reg.num_sini_mayores     ,
            p_reg.imp_siniestros       ,
            p_reg.mca_sin_mayor_cero   ,
            p_reg.factor_recargo       ,
            p_reg.factor_ajuste        ,
            p_reg.fec_efec_riesgo      ,
            p_reg.fec_vcto_riesgo      ,
            p_reg.fec_tratamiento      ,
            p_reg.num_orden            ,
            p_reg.categoria            ,
            p_reg.pct_categoria        ,
            p_reg.cod_zona_vehi        ,
            p_reg.cod_uso_vehi         ,
            p_reg.num_matricula        ,
            p_reg.cod_cuadro_com       ,
            p_reg.cod_oficial          ,
            p_reg.tip_benef            ,
            p_reg.tip_docum_benef      ,
            p_reg.cod_docum_benef      ,
            p_reg.importe_endoso       ,
            p_reg.cod_fracc_pago       ,
            p_reg.pct_desc_com_pol     ,
            p_reg.equipo_gas           ,
            p_reg.tip_aeroambulancia   ,
            p_reg.tip_estatus_riesgo   ,
            p_reg.ind_sini_acumulado   ,
            p_reg.meses_vig            ,
            p_reg.txt_error_ct         ,
            'N'                        ,
            p_reg.cod_usr              ,
            p_reg.txt_error_ct    -- Version : 1.03
          );
        --
    END p_inserta;
    --
    -- ----------------------------------------------------------------------
    -- Autor : Manuel Rod.                                    Version : 1.00
    -- Fecha : 01-May-14
    -- Nota  : Insertar registro en tabla Control Fechas de Corrida.
    -- ----------------------------------------------------------------------
    PROCEDURE p_inserta_g2109022(p_reg  g2109022_mrd%ROWTYPE) IS
    BEGIN
        --
        INSERT INTO g2109022_mrd
          (  COD_CIA,
              COD_RAMO,
              ANIO,
              MES,
              FEC_CARGA_INIC,
              FEC_RENOVACION,
              MCA_CARGA_CRTL_M,
              MCA_CARGA_TAREA,
              MCA_RENOV_CRTL_M,
              MCA_RENOV_TAREA,
              MCA_RENOV_JAVA,
              MCA_INH,
              COD_USR,
              FEC_ACTU
            )
        VALUES (
              p_reg.cod_cia              ,
              p_reg.cod_ramo             ,
              p_reg.anio                 ,
              p_reg.mes                  ,
              p_reg.fec_carga_inic       ,
              p_reg.fec_renovacion       ,
              p_reg.mca_carga_crtl_m     ,
              p_reg.mca_carga_tarea      ,
              p_reg.mca_renov_crtl_m     ,
              p_reg.mca_renov_tarea      ,
              p_reg.mca_renov_java       ,
              p_reg.mca_inh              ,
              p_reg.cod_usr              ,
              p_reg.fec_actu
          );
        --
    END p_inserta_g2109022;
    --
    -- ------------------------------------------------------------
    --
    /**
    || Totaliza_query :
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
                      p_cod_modalidad_ren     a2109010_mrd.cod_modalidad_ren    %TYPE ) IS
      --
      nPrima               NUMBER;
      nPrima_Ren           NUMBER;
      nPrima_Preren        NUMBER;
      --
    BEGIN
      --
      SELECT SUM(nvl(a.prima,0)), SUM(nvl(a.prima_ren,0)) , SUM(nvl(a.prima_preren,0))
        INTO nPrima, nPrima_Ren, nPrima_Preren
        FROM A2009030 b,
            A2109010 a
       WHERE a.num_poliza            = NVL ( p_num_poliza, a.num_poliza )
         AND NVL(a.num_poliza_grupo,0) = NVL ( p_num_poliza_grupo, NVL(a.num_poliza_grupo,0) )
         AND a.mes                   = NVL ( p_mes, a.mes )
         AND a.anio                  = NVL ( p_anio, a.anio )
         --AND cod_nivel3            = NVL ( p_cod_nivel3, cod_nivel3 )
         AND ( ( p_evolucion = '0' AND a.evolucion = 'IGUAL' ) OR
               ( p_evolucion = '1' AND a.evolucion = 'SUBE'  ) OR
               ( p_evolucion = '2' AND a.evolucion = 'BAJA'  ) OR
               ( p_evolucion IS NULL ) 
             ) -- Todos
         AND a.tip_docum           = NVL ( p_tip_docum, a.tip_docum )
         AND a.cod_docum           = NVL ( p_cod_docum, a.cod_docum )
         AND a.cod_ramo            = NVL ( p_cod_ramo, a.cod_ramo )
         AND NVL(tip_coaseguro,0)  = NVL ( p_tip_coaseguro, NVL(tip_coaseguro,0) )
         AND tip_cuenta            = NVL ( p_tip_cuenta, tip_cuenta )
         AND siniestralidad       >= NVL ( p_porc_siniestros, siniestralidad )
         AND siniestralidad       <= NVL ( p_porc_siniestros, siniestralidad )
         AND ( (p_cod_ejecutivo IS NULL) OR (cod_ejecutivo = NVL( p_cod_ejecutivo, cod_ejecutivo) ) )
         AND num_chasis              = NVL ( p_num_chasis, num_chasis )
         AND NVL(a.prima_preren,0)  <= NVL ( p_prima, NVL(a.prima_preren,0) )    -- Version : 1.04
         AND NVL(nueva_var_prima,0) >= NVL ( p_variacion_d, NVL(nueva_var_prima,0) )
         AND NVL(nueva_var_prima,0) <= NVL ( p_variacion_h, NVL(nueva_var_prima,0) )
         AND NVL(dnr_ren,0)       >= NVL ( p_dnr_ren_d, NVL(dnr_ren,0) )
         AND NVL(dnr_ren,0)       <= NVL ( p_dnr_ren_h, NVL(dnr_ren,0) )
         AND a.mca_siniestros      = DECODE ( p_mca_siniestros, 1, 'N', 2, 'S', a.mca_siniestros )
         AND a.tip_estatus_riesgo  = NVL ( p_tip_estatus_riesgo, a.tip_estatus_riesgo )
         AND a.cod_modalidad_ren   = NVL ( p_cod_modalidad_ren, a.cod_modalidad_ren )
         AND ( ( p_tip_riesgo = '1' AND a.cod_modalidad_ren  = 3000 ) OR -- 1-> Ley
               ( p_tip_riesgo = '2' AND a.cod_modalidad_ren != 3000 ) OR -- 2-> No Ley
               ( p_tip_riesgo IS NULL ) 
             ) -- Todos
         AND b.num_poliza        = a.num_poliza
         AND b.mes               = a.mes
         AND b.anio              = a.anio
         AND b.cod_mon           = NVL ( p_cod_mon, b.cod_mon )
         AND b.cod_agt           = NVL ( p_cod_agt, b.cod_agt )
         AND b.tip_estatus       = NVL ( p_tip_estatus, b.tip_estatus)
         AND b.tip_resultado     = NVL ( p_tip_resultado, b.tip_resultado )
         AND b.tip_estatus_cobro = NVL ( p_tip_estatus_cobro, b.tip_estatus_cobro );
      --
      trn_k_global.asigna( 'ren_prima'         , nPrima );
      trn_k_global.asigna( 'ren_prima_ren'     , nPrima_Ren );
      trn_k_global.asigna( 'ren_prima_preren'  , nPrima_Preren );
      --
    END p_totaliza_query;
    --
    /**
    || p_query :
    */
    --
    -- ------------------------------------------------------------
    --  Cambio: Manuel Rodriguez                    Version : 1.00
    --  Fecha : 11-Jul-14
    --  Notas : Fueron agregados algunos campos en el WHERE, se
    --        : configuro la Lista EVOLUCION y se compararon todos
    --        : los campos con las dos tablas A2009030 y A2109010.
    -- ------------------------------------------------------------
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
                      p_cod_modalidad_ren     a2109010_mrd.cod_modalidad_ren    %TYPE) IS
      --
      TYPE reg_a2109010_mrd_v IS RECORD
        (clave                 ROWID      ,
          cod_cia               a2109010_mrd.cod_cia              %TYPE,
          num_poliza            a2109010_mrd.num_poliza           %TYPE,
          mes                   a2109010_mrd.mes                  %TYPE,
          anio                  a2109010_mrd.anio                 %TYPE,
          cod_ramo              a2109010_mrd.cod_ramo             %TYPE,
          num_spto              a2109010_mrd.num_spto             %TYPE,
          num_apli              a2109010_mrd.num_apli             %TYPE,
          num_spto_apli         a2109010_mrd.num_spto_apli        %TYPE,
          num_poliza_grupo      a2109010_mrd.num_poliza_grupo     %TYPE,
          cod_plan              a2109010_mrd.cod_plan             %TYPE,
          cod_modalidad         a2109010_mrd.cod_modalidad        %TYPE,
          cod_modalidad_ren     a2109010_mrd.cod_modalidad_ren    %TYPE,
          cant_riesgos          a2109010_mrd.cant_riesgos         %TYPE,
          num_riesgo            a2109010_mrd.num_riesgo           %TYPE,
          cod_tip_vehi          a2109010_mrd.cod_tip_vehi         %TYPE,
          tip_docum             a2109010_mrd.tip_docum            %TYPE,
          cod_docum             a2109010_mrd.cod_docum            %TYPE,
          cod_marca             a2109010_mrd.cod_marca            %TYPE,
          cod_modelo            a2109010_mrd.cod_modelo           %TYPE,
          cod_sub_modelo        a2109010_mrd.cod_sub_modelo       %TYPE,
          anio_modelo           a2109010_mrd.anio_modelo          %TYPE,
          num_chasis            a2109010_mrd.num_chasis           %TYPE,
          suma_aseg             a2109010_mrd.suma_aseg            %TYPE,
          suma_aseg_ren         a2109010_mrd.suma_aseg_ren        %TYPE,
          prima                 a2109010_mrd.prima                %TYPE,
          prima_ren             a2109010_mrd.prima_ren            %TYPE,
          prima_preren          a2109010_mrd.prima_preren         %TYPE,
          nueva_dif_prima_ren   a2109010_mrd.nueva_dif_prima_ren  %TYPE,
          nueva_var_prima       a2109010_mrd.nueva_var_prima      %TYPE,
          primanetafacturada    a2109010_mrd.primanetafacturada   %TYPE,
          tasa                  a2109010_mrd.tasa                 %TYPE,
          tasa_ren              a2109010_mrd.tasa_ren             %TYPE,
          nueva_tasa            a2109010_mrd.nueva_tasa           %TYPE,
          dnr                   a2109010_mrd.dnr                  %TYPE,
          dnr_ren               a2109010_mrd.dnr_ren              %TYPE,
          variacion_valor       a2109010_mrd.variacion_valor      %TYPE,
          variacion_valor_ren   a2109010_mrd.variacion_valor_ren  %TYPE,
          diferencia            a2109010_mrd.diferencia           %TYPE,
          diferencia_ren        a2109010_mrd.diferencia_ren       %TYPE,
          evolucion             a2109010_mrd.evolucion            %TYPE,
          evolucion_ren         a2109010_mrd.evolucion_ren        %TYPE,
          variacion             a2109010_mrd.variacion            %TYPE,
          variacion_ren         a2109010_mrd.variacion_ren        %TYPE,
          desc_comercial        a2109010_mrd.desc_comercial       %TYPE,
          desc_comercial_ren    a2109010_mrd.desc_comercial_ren   %TYPE,
          mca_siniestros        a2109010_mrd.mca_siniestros       %TYPE,
          num_siniestros        a2109010_mrd.num_siniestros       %TYPE,
          sini_pag              a2109010_mrd.sini_pag             %TYPE,
          sini_por_pag          a2109010_mrd.sini_por_pag         %TYPE,
          num_sini_menores      a2109010_mrd.num_sini_menores     %TYPE,
          num_sini_mayores      a2109010_mrd.num_sini_mayores     %TYPE,
          imp_siniestros        a2109010_mrd.imp_siniestros       %TYPE,
          mca_sin_mayor_cero    a2109010_mrd.mca_sin_mayor_cero   %TYPE,
          factor_recargo        a2109010_mrd.factor_recargo       %TYPE,
          factor_ajuste         a2109010_mrd.factor_ajuste        %TYPE,
          fec_efec_riesgo       a2109010_mrd.fec_efec_riesgo      %TYPE,
          fec_vcto_riesgo       a2109010_mrd.fec_vcto_riesgo      %TYPE,
          cod_mon               a2009030_mrd.cod_mon              %TYPE,
          catastrofico          a2009030_mrd.catastrofico         %TYPE,
          fec_tratamiento       a2109010_mrd.fec_tratamiento      %TYPE,
          num_orden             a2109010_mrd.num_orden            %TYPE,
          categoria             a2109010_mrd.categoria            %TYPE,
          pct_categoria         a2109010_mrd.pct_categoria        %TYPE,
          cod_zona_vehi         a2109010_mrd.cod_zona_vehi        %TYPE,
          cod_uso_vehi          a2109010_mrd.cod_uso_vehi         %TYPE,
          num_matricula         a2109010_mrd.num_matricula        %TYPE,
          cod_cuadro_com        a2109010_mrd.cod_cuadro_com       %TYPE,
          cod_oficial           a2109010_mrd.cod_oficial          %TYPE,
          tip_benef             a2109010_mrd.tip_benef            %TYPE,
          tip_docum_benef       a2109010_mrd.tip_docum_benef      %TYPE,
          cod_docum_benef       a2109010_mrd.cod_docum_benef      %TYPE,
          importe_endoso        a2109010_mrd.importe_endoso       %TYPE,
          cod_fracc_pago        a2109010_mrd.cod_fracc_pago       %TYPE,
          pct_desc_com_pol      a2109010_mrd.pct_desc_com_pol     %TYPE,
          equipo_gas            a2109010_mrd.equipo_gas           %TYPE,
          tip_aeroambulancia    a2109010_mrd.tip_aeroambulancia   %TYPE,
          tip_estatus_riesgo    a2109010_mrd.tip_estatus_riesgo   %TYPE,
          ind_sini_acumulado    a2109010_mrd.ind_sini_acumulado   %TYPE,
          meses_vig             a2109010_mrd.meses_vig            %TYPE,
          txt_error_ct          a2109010_mrd.txt_error_ct         %TYPE,
          cod_usr               a2109010_mrd.cod_usr              %TYPE,
          txt_error_pol         a2109010_mrd.txt_error_pol        %TYPE);  -- Version : 1.03
      --
      l_reg REG_A2109010_MRD_V;
      TYPE cursor_variable IS REF CURSOR RETURN l_reg%TYPE;
      l_cursor CURSOR_VARIABLE;
      --
      --l_mod_ley   a2109010_mrd.Cod_Modalidad%TYPE; borrar
      --
    BEGIN
      --
      /* ------------------------------------------
      || ! ATENCION !
      || ------------------------------------------
      || Aqui se deben asignar las variables "g_.."
      || que se definieron a nivel del BODY que a
      || su vez deben coincidir con la declaracion
      || de los parametros de este procedimiento.
      || Tambien hay que modificar el where del
      || cursor variable o crear otro cursor.
      */ ------------------------------------------
      --
      g_tb_a2109010_mrd.DELETE;
      --
      g_tiene_permiso    := FALSE;
      g_hay_cambios      := 'N';
      g_cod_usr          := trn_k_global.cod_usr;
      g_cod_idioma_cp    := trn_k_global.cod_idioma;
      g_fila             := 0;
      g_cnt_pk           := 1;
      --
      OPEN l_cursor FOR
        SELECT a.rowid                 ,
                a.cod_cia               ,  -- Version : 1.03
                a.num_poliza            ,
                a.mes                   ,
                a.anio                  ,
                a.cod_ramo              ,
                a.num_spto              ,
                a.num_apli              ,
                a.num_spto_apli         ,
                a.num_poliza_grupo      ,  -- Version : 1.03
                cod_plan              ,
                cod_modalidad         ,
                cod_modalidad_ren     ,
                cant_riesgos          ,
                num_riesgo            ,
                cod_tip_vehi          ,
                a.tip_docum           ,
                a.cod_docum           ,
                cod_marca             ,
                cod_modelo            ,
                cod_sub_modelo        ,
                anio_modelo           ,
                num_chasis            ,
                suma_aseg             ,
                suma_aseg_ren         ,
                prima                 ,
                prima_ren             ,
                a.prima_preren        ,
                nueva_dif_prima_ren   ,
                nueva_var_prima       ,
                a.primanetafacturada  ,
                tasa                  ,
                tasa_ren              ,
                nueva_tasa            ,
                dnr                   ,
                dnr_ren               ,
                variacion_valor       ,
                variacion_valor_ren   ,
                diferencia            ,
                diferencia_ren        ,
                evolucion             ,
                evolucion_ren         ,
                variacion             ,
                variacion_ren         ,
                desc_comercial        ,
                desc_comercial_ren    ,
                a.mca_siniestros      ,
                a.num_siniestros      ,
                sini_pag              ,
                sini_por_pag          ,
                num_sini_menores      ,
                num_sini_mayores      ,
                imp_siniestros        ,
                mca_sin_mayor_cero    ,
                factor_recargo        ,
                factor_ajuste         ,
                fec_efec_riesgo       ,
                fec_vcto_riesgo       ,
                b.cod_mon             ,
                b.catastrofico        ,
                a.fec_tratamiento       ,
                a.num_orden             ,
                categoria             ,
                pct_categoria         ,
                cod_zona_vehi         ,
                cod_uso_vehi          ,
                num_matricula         ,
                cod_cuadro_com        ,
                cod_oficial           ,
                tip_benef             ,
                tip_docum_benef       ,
                cod_docum_benef       ,
                importe_endoso        ,
                cod_fracc_pago        ,
                pct_desc_com_pol      ,
                equipo_gas            ,
                tip_aeroambulancia    ,
                tip_estatus_riesgo    ,
                ind_sini_acumulado    ,
                meses_vig             ,
                txt_error_ct          ,
                a.cod_usr             ,
                txt_error_pol    -- Version : 1.03
          FROM A2009030 b,
                A2109010 a
          WHERE a.num_poliza            = NVL ( p_num_poliza, a.num_poliza )
            AND NVL(a.num_poliza_grupo,0) = NVL ( p_num_poliza_grupo, NVL(a.num_poliza_grupo,0) )
            AND a.mes                   = NVL ( p_mes, a.mes )
            AND a.anio                  = NVL ( p_anio, a.anio )
            AND ( ( p_evolucion = '0' AND a.evolucion = 'IGUAL' ) OR
                  ( p_evolucion = '1' AND a.evolucion = 'SUBE'  ) OR
                  ( p_evolucion = '2' AND a.evolucion = 'BAJA'  ) OR
                  ( p_evolucion IS NULL ) -- Todos
                ) 
            AND a.tip_docum           = NVL ( p_tip_docum, a.tip_docum )
            AND a.cod_docum           = NVL ( p_cod_docum, a.cod_docum )
            AND a.cod_ramo            = NVL ( p_cod_ramo, a.cod_ramo )
            AND NVL(tip_coaseguro,0)  = NVL ( p_tip_coaseguro, NVL(tip_coaseguro,0) )
            AND tip_cuenta            = NVL ( p_tip_cuenta, tip_cuenta )
            AND siniestralidad       >= NVL ( p_porc_siniestros, siniestralidad )
            AND siniestralidad       <= NVL ( p_porc_siniestros, siniestralidad )
            AND cod_ejecutivo = NVL( p_cod_ejecutivo, cod_ejecutivo)
            AND num_chasis              = NVL ( p_num_chasis, num_chasis )
            AND NVL(a.prima_preren,0)  <= NVL ( p_prima, NVL(a.prima_preren,0) )    -- Version : 1.04
            AND NVL(nueva_var_prima,0) >= NVL ( p_variacion_d, NVL(nueva_var_prima,0) )
            AND NVL(nueva_var_prima,0) <= NVL ( p_variacion_h, NVL(nueva_var_prima,0) )
            AND NVL(dnr_ren,0)       >= NVL ( p_dnr_ren_d, NVL(dnr_ren,0) )
            AND NVL(dnr_ren,0)       <= NVL ( p_dnr_ren_h, NVL(dnr_ren,0) )
            AND a.mca_siniestros      = DECODE ( p_mca_siniestros, '1', 'N', '2', 'S', a.mca_siniestros )
            AND a.tip_estatus_riesgo  = NVL ( p_tip_estatus_riesgo, a.tip_estatus_riesgo )
            AND a.cod_modalidad_ren   = NVL ( p_cod_modalidad_ren, a.cod_modalidad_ren )
            AND ( ( p_tip_riesgo = '1' AND a.cod_modalidad_ren  = 3000 ) OR -- 1-> Ley
                  ( p_tip_riesgo = '2' AND a.cod_modalidad_ren != 3000 ) OR -- 2-> No Ley
                  ( p_tip_riesgo IS NULL ) -- Todos
                ) 
            AND cant_riesgos          = NVL ( p_cant_riesgos, cant_riesgos )
            AND b.num_poliza          = a.num_poliza
            AND b.mes                 = a.mes
            AND b.anio                = a.anio
            AND b.cod_mon             = NVL ( p_cod_mon, b.cod_mon )
            AND b.cod_agt             = NVL ( p_cod_agt, b.cod_agt )
            AND nvl(b.tip_estatus,4)  = NVL ( p_tip_estatus, nvl(b.tip_estatus,4) )
            AND nvl(b.tip_resultado,4)= NVL ( null, nvl(b.tip_resultado,4) )
            AND b.tip_estatus_cobro   = NVL ( p_tip_estatus_cobro, b.tip_estatus_cobro )
            --
      ORDER BY a.num_poliza, a.num_riesgo;
      --
      FETCH l_cursor INTO l_reg;
      --
      WHILE l_cursor%FOUND LOOP
        --
        g_fila := g_fila + 1;
        --
        g_tb_a2109010_mrd(g_fila).clave                 := l_reg.clave                ;
        g_tb_a2109010_mrd(g_fila).num_secu_k            := g_fila                     ;
        g_tb_a2109010_mrd(g_fila).post_query            := FALSE                      ;
        --
        g_tb_a2109010_mrd(g_fila).cod_cia               := l_reg.cod_cia              ;
        g_tb_a2109010_mrd(g_fila).num_poliza            := l_reg.num_poliza           ;
        g_tb_a2109010_mrd(g_fila).mes                   := l_reg.mes                  ;
        g_tb_a2109010_mrd(g_fila).anio                  := l_reg.anio                 ;
        g_tb_a2109010_mrd(g_fila).cod_ramo              := l_reg.cod_ramo             ;
        g_tb_a2109010_mrd(g_fila).num_spto              := l_reg.num_spto             ;
        g_tb_a2109010_mrd(g_fila).num_apli              := l_reg.num_apli             ;
        g_tb_a2109010_mrd(g_fila).num_spto_apli         := l_reg.num_spto_apli        ;
        g_tb_a2109010_mrd(g_fila).num_poliza_grupo      := l_reg.num_poliza_grupo     ;
        g_tb_a2109010_mrd(g_fila).cod_plan              := l_reg.cod_plan             ;
        g_tb_a2109010_mrd(g_fila).cod_modalidad         := l_reg.cod_modalidad        ;
        g_tb_a2109010_mrd(g_fila).cod_modalidad_ren     := l_reg.cod_modalidad_ren    ;
        g_tb_a2109010_mrd(g_fila).cant_riesgos          := l_reg.cant_riesgos         ;
        g_tb_a2109010_mrd(g_fila).num_riesgo            := l_reg.num_riesgo           ;
        g_tb_a2109010_mrd(g_fila).cod_tip_vehi          := l_reg.cod_tip_vehi         ;
        g_tb_a2109010_mrd(g_fila).tip_docum             := l_reg.tip_docum            ;
        g_tb_a2109010_mrd(g_fila).cod_docum             := l_reg.cod_docum            ;
        g_tb_a2109010_mrd(g_fila).cod_marca             := l_reg.cod_marca            ;
        g_tb_a2109010_mrd(g_fila).cod_modelo            := l_reg.cod_modelo           ;
        g_tb_a2109010_mrd(g_fila).cod_sub_modelo        := l_reg.cod_sub_modelo       ;
        g_tb_a2109010_mrd(g_fila).anio_modelo           := l_reg.anio_modelo          ;
        g_tb_a2109010_mrd(g_fila).num_chasis            := l_reg.num_chasis           ;
        g_tb_a2109010_mrd(g_fila).suma_aseg             := l_reg.suma_aseg            ;
        g_tb_a2109010_mrd(g_fila).suma_aseg_ren         := l_reg.suma_aseg_ren        ;
        g_tb_a2109010_mrd(g_fila).prima                 := l_reg.prima                ;
        g_tb_a2109010_mrd(g_fila).prima_ren             := l_reg.prima_ren            ;
        g_tb_a2109010_mrd(g_fila).prima_preren          := l_reg.prima_preren         ;
        g_tb_a2109010_mrd(g_fila).nueva_dif_prima_ren   := l_reg.nueva_dif_prima_ren  ;
        g_tb_a2109010_mrd(g_fila).nueva_var_prima       := l_reg.nueva_var_prima      ;
        g_tb_a2109010_mrd(g_fila).primanetafacturada    := l_reg.primanetafacturada   ;
        g_tb_a2109010_mrd(g_fila).tasa                  := l_reg.tasa                 ;
        g_tb_a2109010_mrd(g_fila).tasa_ren              := l_reg.tasa_ren             ;
        g_tb_a2109010_mrd(g_fila).nueva_tasa            := l_reg.nueva_tasa           ;
        g_tb_a2109010_mrd(g_fila).dnr                   := l_reg.dnr                  ;
        g_tb_a2109010_mrd(g_fila).dnr_ren               := l_reg.dnr_ren              ;
        g_tb_a2109010_mrd(g_fila).variacion_valor       := l_reg.variacion_valor      ;
        g_tb_a2109010_mrd(g_fila).variacion_valor_ren   := l_reg.variacion_valor_ren  ;
        g_tb_a2109010_mrd(g_fila).diferencia            := l_reg.diferencia           ;
        g_tb_a2109010_mrd(g_fila).diferencia_ren        := l_reg.diferencia_ren       ;
        g_tb_a2109010_mrd(g_fila).evolucion             := l_reg.evolucion            ;
        g_tb_a2109010_mrd(g_fila).evolucion_ren         := l_reg.evolucion_ren        ;
        g_tb_a2109010_mrd(g_fila).variacion             := l_reg.variacion            ;
        g_tb_a2109010_mrd(g_fila).variacion_ren         := l_reg.variacion_ren        ;
        g_tb_a2109010_mrd(g_fila).desc_comercial        := l_reg.desc_comercial       ;
        g_tb_a2109010_mrd(g_fila).desc_comercial_ren    := l_reg.desc_comercial_ren   ;
        g_tb_a2109010_mrd(g_fila).mca_siniestros        := l_reg.mca_siniestros       ;
        g_tb_a2109010_mrd(g_fila).num_siniestros        := l_reg.num_siniestros       ;
        g_tb_a2109010_mrd(g_fila).sini_pag              := l_reg.sini_pag             ;
        g_tb_a2109010_mrd(g_fila).sini_por_pag          := l_reg.sini_por_pag         ;
        g_tb_a2109010_mrd(g_fila).num_sini_menores      := l_reg.num_sini_menores     ;
        g_tb_a2109010_mrd(g_fila).num_sini_mayores      := l_reg.num_sini_mayores     ;
        g_tb_a2109010_mrd(g_fila).imp_siniestros        := l_reg.imp_siniestros       ;
        g_tb_a2109010_mrd(g_fila).mca_sin_mayor_cero    := l_reg.mca_sin_mayor_cero   ;
        g_tb_a2109010_mrd(g_fila).factor_recargo        := l_reg.factor_recargo       ;
        g_tb_a2109010_mrd(g_fila).factor_ajuste         := l_reg.factor_ajuste        ;
        g_tb_a2109010_mrd(g_fila).fec_efec_riesgo       := l_reg.fec_efec_riesgo      ;
        g_tb_a2109010_mrd(g_fila).fec_vcto_riesgo       := l_reg.fec_vcto_riesgo      ;
        g_tb_a2109010_mrd(g_fila).cod_mon               := l_reg.cod_mon              ;
        g_tb_a2109010_mrd(g_fila).catastrofico          := l_reg.catastrofico     ;
        g_tb_a2109010_mrd(g_fila).fec_tratamiento       := l_reg.fec_tratamiento      ;
        g_tb_a2109010_mrd(g_fila).num_orden             := l_reg.num_orden            ;
        g_tb_a2109010_mrd(g_fila).categoria             := l_reg.categoria            ;
        g_tb_a2109010_mrd(g_fila).pct_categoria         := l_reg.pct_categoria        ;
        g_tb_a2109010_mrd(g_fila).cod_zona_vehi         := l_reg.cod_zona_vehi        ;
        g_tb_a2109010_mrd(g_fila).cod_uso_vehi          := l_reg.cod_uso_vehi         ;
        g_tb_a2109010_mrd(g_fila).num_matricula         := l_reg.num_matricula        ;
        g_tb_a2109010_mrd(g_fila).cod_cuadro_com        := l_reg.cod_cuadro_com       ;
        g_tb_a2109010_mrd(g_fila).cod_oficial           := l_reg.cod_oficial          ;
        g_tb_a2109010_mrd(g_fila).tip_benef             := l_reg.tip_benef            ;
        g_tb_a2109010_mrd(g_fila).tip_docum_benef       := l_reg.tip_docum_benef      ;
        g_tb_a2109010_mrd(g_fila).cod_docum_benef       := l_reg.cod_docum_benef      ;
        g_tb_a2109010_mrd(g_fila).importe_endoso        := l_reg.importe_endoso       ;
        g_tb_a2109010_mrd(g_fila).cod_fracc_pago        := l_reg.cod_fracc_pago       ;
        g_tb_a2109010_mrd(g_fila).pct_desc_com_pol      := l_reg.pct_desc_com_pol     ;
        g_tb_a2109010_mrd(g_fila).equipo_gas            := l_reg.equipo_gas           ;
        g_tb_a2109010_mrd(g_fila).tip_aeroambulancia    := l_reg.tip_aeroambulancia   ;
        g_tb_a2109010_mrd(g_fila).tip_estatus_riesgo    := l_reg.tip_estatus_riesgo   ;
        g_tb_a2109010_mrd(g_fila).ind_sini_acumulado    := l_reg.ind_sini_acumulado   ;
        g_tb_a2109010_mrd(g_fila).meses_vig             := l_reg.meses_vig            ;
        g_tb_a2109010_mrd(g_fila).txt_error_ct          := l_reg.txt_error_ct         ;
        g_tb_a2109010_mrd(g_fila).cod_usr               := l_reg.cod_usr              ;
        g_tb_a2109010_mrd(g_fila).txt_error_pol         := l_reg.txt_error_pol        ; -- Version : 1.03
        --
        FETCH l_cursor INTO l_reg;
        --
      END LOOP;
      --
      CLOSE l_cursor;
      --
      g_max_secu_query := g_fila;
      g_max_secu_ins   := g_fila;
      --
      IF g_fila > 0 THEN
        --
        g_fila           := NULL;
        g_fila_devuelve  := NULL;
        --
        p_totaliza_query ( p_num_poliza            ,
                            p_num_poliza_grupo      ,
                            p_mes                   ,
                            p_anio                  ,
                            p_cod_agt               ,
                            p_cod_nivel3            ,
                            p_evolucion             ,
                            p_tip_estatus_riesgo    ,
                            p_tip_estatus           ,
                            p_mca_siniestros        ,
                            p_mca_balance           ,
                            p_tip_docum             ,
                            p_cod_docum             ,
                            p_cod_ramo              ,
                            p_tip_coaseguro         ,
                            p_tip_cuenta            ,
                            p_porc_balance          ,
                            p_porc_siniestros       ,
                            p_tip_resultado         ,
                            p_tip_estatus_cobro     ,
                            p_cod_ejecutivo         ,
                            p_num_chasis            ,
                            p_prima                 ,
                            p_variacion_d           ,
                            p_variacion_h           ,
                            p_dnr_ren_d             ,
                            p_dnr_ren_h             ,
                            p_cod_mon               ,
                            p_tip_riesgo            ,
                            p_cod_modalidad_ren);
        --
      ELSE   -- Fec. 4-Dic-14
        trn_k_global.asigna( 'ren_prima'         , 0 );
        trn_k_global.asigna( 'ren_prima_ren'     , 0 );
        trn_k_global.asigna( 'ren_prima_preren'  , 0 );
      END IF;
      --
    END p_query;
    --
    -- ------------------------------------------------------------
    --
    /**
    || Devuelve los campos de un registro
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
                          p_txt_error_pol         IN OUT a2109010_mrd.txt_error_pol        %TYPE -- Version : 1.03
                          ) IS
      -- Total de campos : 126
      --
      CURSOR cl_a2009030 IS
        SELECT *
          FROM a2009030
        WHERE num_poliza = p_num_poliza
          AND mes        = p_mes
          AND anio       = p_anio;
      --
      -- Buscar Nombre:
      CURSOR cr_a1001399 ( p_cod_cia           a2109010.cod_cia%TYPE,
                          p_tip_docum         a2109010.tip_docum%TYPE,
                          p_cod_docum         a2109010.cod_docum%TYPE
                        ) IS
        SELECT (nom_tercero||' '||ape1_tercero||' '||ape2_tercero)
          FROM a1001399
        WHERE cod_cia    = p_cod_cia
          AND tip_docum  = p_tip_docum
          AND cod_docum  = p_cod_docum;
      --
      -- Buscar Nombre Forma Pago:
      CURSOR cr_a1001402 ( p_cod_cia           a1001402.cod_cia%TYPE,
                          p_cod_fracc_pago    a1001402.cod_fracc_pago%TYPE
                        ) IS
        SELECT nom_fracc_pago
          FROM a1001402
          WHERE cod_cia        = p_cod_cia
            AND cod_fracc_pago = p_cod_fracc_pago;
      --
      -- Buscar Nombre Cuadro Comision:
      CURSOR cr_a1001752 ( p_cod_cia           a1001752.cod_cia%TYPE,
                          p_cod_cuadro_com    a1001752.cod_cuadro_com%TYPE
                        ) IS
        SELECT nom_cuadro_com
          FROM a1001752
        WHERE cod_cia        = p_cod_cia
          AND cod_cuadro_com = p_cod_cuadro_com;
      --
      -- Buscar Nombre:
      CURSOR cr_a2109013 (p_cod_cia           a1001752.cod_cia%TYPE) IS
        SELECT COUNT(DISTINCT mca_prim_carga)
          FROM a2109013
        WHERE cod_cia    = p_cod_cia
          AND cod_ramo   = p_cod_ramo
          AND num_poliza = p_num_poliza
          AND num_riesgo = p_num_riesgo;
      --
      reg_a2009030     cl_a2009030%ROWTYPE;
      l_cant_reglas    NUMBER(3) := 0;
      --
    BEGIN
      --
      p_num_secu_k := 0;
      --
      IF g_fila_devuelve IS NULL THEN
        --
        IF g_tb_a2109010_mrd.EXISTS(g_tb_a2109010_mrd.FIRST) THEN
            --
            g_fila_devuelve := g_tb_a2109010_mrd.FIRST;
            --
            p_num_secu_k := g_fila_devuelve;
            --
            post_query(g_fila_devuelve);
            --
            p_num_poliza            := g_tb_a2109010_mrd(g_fila_devuelve).num_poliza           ;
            p_mes                   := g_tb_a2109010_mrd(g_fila_devuelve).mes                  ;
            p_anio                  := g_tb_a2109010_mrd(g_fila_devuelve).anio                 ;
            p_cod_ramo              := g_tb_a2109010_mrd(g_fila_devuelve).cod_ramo             ;
            p_num_spto              := g_tb_a2109010_mrd(g_fila_devuelve).num_spto             ;
            p_num_apli              := g_tb_a2109010_mrd(g_fila_devuelve).num_apli             ;
            p_num_spto_apli         := g_tb_a2109010_mrd(g_fila_devuelve).num_spto_apli        ;
            p_num_poliza_grupo      := g_tb_a2109010_mrd(g_fila_devuelve).num_poliza_grupo     ;
            p_cod_plan              := g_tb_a2109010_mrd(g_fila_devuelve).cod_plan             ;
            p_cod_modalidad         := g_tb_a2109010_mrd(g_fila_devuelve).cod_modalidad        ;
            p_cod_modalidad_ren     := g_tb_a2109010_mrd(g_fila_devuelve).cod_modalidad_ren    ;
            p_cant_riesgos          := g_tb_a2109010_mrd(g_fila_devuelve).cant_riesgos         ;
            p_num_riesgo            := g_tb_a2109010_mrd(g_fila_devuelve).num_riesgo           ;
            p_cod_tip_vehi          := g_tb_a2109010_mrd(g_fila_devuelve).cod_tip_vehi         ;
            p_tip_docum             := g_tb_a2109010_mrd(g_fila_devuelve).tip_docum            ;
            p_cod_docum             := g_tb_a2109010_mrd(g_fila_devuelve).cod_docum            ;
            p_cod_marca             := g_tb_a2109010_mrd(g_fila_devuelve).cod_marca            ;
            p_cod_modelo            := g_tb_a2109010_mrd(g_fila_devuelve).cod_modelo           ;
            p_cod_sub_modelo        := g_tb_a2109010_mrd(g_fila_devuelve).cod_sub_modelo       ;
            p_anio_modelo           := g_tb_a2109010_mrd(g_fila_devuelve).anio_modelo          ;
            p_num_chasis            := g_tb_a2109010_mrd(g_fila_devuelve).num_chasis           ;
            p_suma_aseg             := g_tb_a2109010_mrd(g_fila_devuelve).suma_aseg            ;
            p_suma_aseg_ren         := g_tb_a2109010_mrd(g_fila_devuelve).suma_aseg_ren        ;
            p_prima                 := g_tb_a2109010_mrd(g_fila_devuelve).prima                ;
            p_prima_ren             := g_tb_a2109010_mrd(g_fila_devuelve).prima_ren            ;
            p_prima_preren          := g_tb_a2109010_mrd(g_fila_devuelve).prima_preren         ;
            p_nueva_dif_prima_ren   := g_tb_a2109010_mrd(g_fila_devuelve).nueva_dif_prima_ren  ;
            p_nueva_var_prima       := g_tb_a2109010_mrd(g_fila_devuelve).nueva_var_prima      ;
            p_primanetafacturada    := g_tb_a2109010_mrd(g_fila_devuelve).primanetafacturada   ;
            p_tasa                  := g_tb_a2109010_mrd(g_fila_devuelve).tasa                 ;
            p_tasa_ren              := g_tb_a2109010_mrd(g_fila_devuelve).tasa_ren             ;
            p_nueva_tasa            := g_tb_a2109010_mrd(g_fila_devuelve).nueva_tasa           ;
            p_dnr                   := g_tb_a2109010_mrd(g_fila_devuelve).dnr                  ;
            p_dnr_ren               := g_tb_a2109010_mrd(g_fila_devuelve).dnr_ren              ;
            p_variacion_valor       := g_tb_a2109010_mrd(g_fila_devuelve).variacion_valor      ;
            p_variacion_valor_ren   := g_tb_a2109010_mrd(g_fila_devuelve).variacion_valor_ren  ;
            p_diferencia            := g_tb_a2109010_mrd(g_fila_devuelve).diferencia           ;
            p_diferencia_ren        := g_tb_a2109010_mrd(g_fila_devuelve).diferencia_ren       ;
            p_evolucion             := g_tb_a2109010_mrd(g_fila_devuelve).evolucion            ;
            p_evolucion_ren         := g_tb_a2109010_mrd(g_fila_devuelve).evolucion_ren        ;
            p_variacion             := g_tb_a2109010_mrd(g_fila_devuelve).variacion            ;
            p_variacion_ren         := g_tb_a2109010_mrd(g_fila_devuelve).variacion_ren        ;
            p_desc_comercial        := g_tb_a2109010_mrd(g_fila_devuelve).desc_comercial       ;
            p_desc_comercial_ren    := g_tb_a2109010_mrd(g_fila_devuelve).desc_comercial_ren   ;
            p_mca_siniestros        := g_tb_a2109010_mrd(g_fila_devuelve).mca_siniestros       ;
            p_num_siniestros        := g_tb_a2109010_mrd(g_fila_devuelve).num_siniestros       ;
            p_sini_pag              := g_tb_a2109010_mrd(g_fila_devuelve).sini_pag             ;
            p_sini_por_pag          := g_tb_a2109010_mrd(g_fila_devuelve).sini_por_pag         ;
            p_num_sini_menores      := g_tb_a2109010_mrd(g_fila_devuelve).num_sini_menores     ;
            p_num_sini_mayores      := g_tb_a2109010_mrd(g_fila_devuelve).num_sini_mayores     ;
            p_imp_siniestros        := g_tb_a2109010_mrd(g_fila_devuelve).imp_siniestros       ;
            p_mca_sin_mayor_cero    := g_tb_a2109010_mrd(g_fila_devuelve).mca_sin_mayor_cero   ;
            p_factor_recargo        := g_tb_a2109010_mrd(g_fila_devuelve).factor_recargo       ;
            p_factor_ajuste         := g_tb_a2109010_mrd(g_fila_devuelve).factor_ajuste        ;
            p_cod_agt               := NULL;
            p_nom_intermediario     := NULL;
            p_fec_efec_riesgo       := g_tb_a2109010_mrd(g_fila_devuelve).fec_efec_riesgo          ;
            p_fec_vcto_riesgo       := g_tb_a2109010_mrd(g_fila_devuelve).fec_vcto_riesgo          ;
            p_tip_coaseguro         := NULL;
            p_cod_mon               := g_tb_a2109010_mrd(g_fila_devuelve).cod_mon              ;
            p_mca_catastrofico      := NULL;
            p_direccion             := NULL;
            p_mca_balance           := NULL;
            p_balance               := NULL;
            p_dias_vig              := NULL;
            p_dias_trans            := NULL;
            p_siniestralidad        := NULL;
            p_reaseguro_fac         := NULL;
            p_motivo                := NULL;
            p_grupo                 := NULL;
            p_mca_poliza_automatica := NULL;
            p_fec_tratamiento       := g_tb_a2109010_mrd(g_fila_devuelve).fec_tratamiento      ;
            p_tip_situ              := NULL;
            p_num_orden             := g_tb_a2109010_mrd(g_fila_devuelve).num_orden            ;
            p_tip_cuenta            := NULL;
            p_tip_estatus           := NULL;
            p_tip_resultado         := NULL;
            p_tip_estatus_cobro     := NULL;
            p_cod_cia_coaseguradora := NULL;
            p_nom_cia_coaseguradora := NULL;
            p_pct_participacion     := NULL;
            p_categoria             := g_tb_a2109010_mrd(g_fila_devuelve).categoria            ;
            p_pct_categoria         := g_tb_a2109010_mrd(g_fila_devuelve).pct_categoria        ;
            p_nom_tip_vehi          := NULL;
            p_nom_marca             := NULL;
            p_nom_modelo            := NULL;
            p_nom_sub_modelo        := NULL;
            p_nom_modalidad         := NULL;
            p_nom_modalidad_ren     := NULL;
            p_cod_zona_vehi         := g_tb_a2109010_mrd(g_fila_devuelve).cod_zona_vehi        ;
            p_nom_zona_vehi         := NULL;
            p_cod_uso_vehi          := g_tb_a2109010_mrd(g_fila_devuelve).cod_uso_vehi         ;
            p_num_matricula         := g_tb_a2109010_mrd(g_fila_devuelve).num_matricula        ;
            p_cod_cuadro_com        := g_tb_a2109010_mrd(g_fila_devuelve).cod_cuadro_com       ;
            p_cod_oficial           := g_tb_a2109010_mrd(g_fila_devuelve).cod_oficial          ;
            p_tip_benef             := g_tb_a2109010_mrd(g_fila_devuelve).tip_benef            ;
            p_tip_docum_benef       := g_tb_a2109010_mrd(g_fila_devuelve).tip_docum_benef      ;
            p_cod_docum_benef       := g_tb_a2109010_mrd(g_fila_devuelve).cod_docum_benef      ;
            p_importe_endoso        := g_tb_a2109010_mrd(g_fila_devuelve).importe_endoso       ;
            p_cod_fracc_pago        := g_tb_a2109010_mrd(g_fila_devuelve).cod_fracc_pago       ;
            p_pct_desc_com_pol      := g_tb_a2109010_mrd(g_fila_devuelve).pct_desc_com_pol     ;
            p_equipo_gas            := g_tb_a2109010_mrd(g_fila_devuelve).equipo_gas           ;
            p_tip_aeroambulancia    := g_tb_a2109010_mrd(g_fila_devuelve).tip_aeroambulancia   ;
            p_tip_estatus_riesgo    := g_tb_a2109010_mrd(g_fila_devuelve).tip_estatus_riesgo   ;
            p_ind_sini_acumulado    := g_tb_a2109010_mrd(g_fila_devuelve).ind_sini_acumulado   ;
            p_meses_vig             := g_tb_a2109010_mrd(g_fila_devuelve).meses_vig            ;
            p_txt_error_ct          := g_tb_a2109010_mrd(g_fila_devuelve).txt_error_ct         ;
            p_cod_usr               := g_tb_a2109010_mrd(g_fila_devuelve).cod_usr              ;
            p_txt_error_pol         := g_tb_a2109010_mrd(g_fila_devuelve).txt_error_pol        ; -- Version : 1.03
            --
        ELSE
            --
            p_num_secu_k            := NULL;
            --
            p_num_poliza            := NULL;
            p_mes                   := NULL;
            p_anio                  := NULL;
            p_cod_ramo              := NULL;
            p_num_spto              := NULL;
            p_num_apli              := NULL;
            p_num_spto_apli         := NULL;
            p_num_poliza_grupo      := NULL;
            p_cod_plan              := NULL;
            p_nom_plan              := NULL;
            p_cod_modalidad         := NULL;
            p_cod_modalidad_ren     := NULL;
            p_cant_riesgos          := NULL;
            p_num_riesgo            := NULL;
            p_nom_riesgo            := NULL;
            p_cod_tip_vehi          := NULL;
            p_tip_docum             := NULL;
            p_cod_docum             := NULL;
            p_nom_tomador           := NULL;
            p_cod_marca             := NULL;
            p_cod_modelo            := NULL;
            p_cod_sub_modelo        := NULL;
            p_anio_modelo           := NULL;
            p_num_chasis            := NULL;
            p_suma_aseg             := NULL;
            p_suma_aseg_ren         := NULL;
            p_prima                 := NULL;
            p_prima_ren             := NULL;
            p_prima_preren          := NULL;
            p_nueva_dif_prima_ren   := NULL;
            p_nueva_var_prima       := NULL;
            p_primanetafacturada    := NULL;
            p_tasa                  := NULL;
            p_tasa_ren              := NULL;
            p_nueva_tasa            := NULL;
            p_dnr                   := NULL;
            p_dnr_ren               := NULL;
            p_variacion_valor       := NULL;
            p_variacion_valor_ren   := NULL;
            p_diferencia            := NULL;
            p_diferencia_ren        := NULL;
            p_evolucion             := NULL;
            p_evolucion_ren         := NULL;
            p_variacion             := NULL;
            p_variacion_ren         := NULL;
            p_desc_comercial        := NULL;
            p_desc_comercial_ren    := NULL;
            p_mca_siniestros        := NULL;
            p_num_siniestros        := NULL;
            p_sini_pag              := NULL;
            p_sini_por_pag          := NULL;
            p_num_sini_menores      := NULL;
            p_num_sini_mayores      := NULL;
            p_imp_siniestros        := NULL;
            p_mca_sin_mayor_cero    := NULL;
            p_factor_recargo        := NULL;
            p_factor_ajuste         := NULL;
            p_cod_agt               := NULL;
            p_nom_intermediario     := NULL;
            p_fec_efec_riesgo       := NULL;
            p_fec_vcto_riesgo       := NULL;
            p_tip_coaseguro         := NULL;
            p_cod_mon               := NULL;
            p_mca_catastrofico      := NULL;
            p_direccion             := NULL;
            p_mca_balance           := NULL;
            p_balance               := NULL;
            p_dias_vig              := NULL;
            p_dias_trans            := NULL;
            p_siniestralidad        := NULL;
            p_reaseguro_fac         := NULL;
            p_motivo                := NULL;
            p_grupo                 := NULL;
            p_mca_poliza_automatica := NULL;
            p_fec_tratamiento       := NULL;
            p_tip_situ              := NULL;
            p_num_orden             := NULL;
            p_tip_estatus           := NULL;
            p_tip_cuenta            := NULL;
            p_tip_resultado         := NULL;
            p_tip_estatus_cobro     := NULL;
            p_cod_cia_coaseguradora := NULL;
            p_nom_cia_coaseguradora := NULL;
            p_pct_participacion     := NULL;
            p_categoria             := NULL;
            p_pct_categoria         := NULL;
            p_nom_tip_vehi          := NULL;
            p_nom_marca             := NULL;
            p_nom_modelo            := NULL;
            p_nom_sub_modelo        := NULL;
            p_nom_modalidad         := NULL;
            p_nom_modalidad_ren     := NULL;
            p_cod_zona_vehi         := NULL;
            p_nom_zona_vehi         := NULL;
            p_cod_uso_vehi          := NULL;
            p_num_matricula         := NULL;
            p_cod_cuadro_com        := NULL;
            p_cod_oficial           := NULL;
            p_tip_benef             := NULL;
            p_tip_docum_benef       := NULL;
            p_cod_docum_benef       := NULL;
            p_nom_benef             := NULL;
            p_importe_endoso        := NULL;
            p_cod_fracc_pago        := NULL;
            p_pct_desc_com_pol      := NULL;
            p_equipo_gas            := NULL;
            p_nom_equipo_gas        := NULL;
            p_tip_aeroambulancia    := NULL;
            p_nom_aeroambulancia    := NULL;
            p_tip_estatus_riesgo    := NULL;
            p_ind_sini_acumulado    := NULL;
            p_meses_vig             := NULL;
            p_txt_error_ct          := NULL;
            p_cod_usr               := NULL;
            p_txt_error_pol         := NULL;   -- Version :1.02
            --
            g_fila_devuelve := g_max_secu_query;
            --
        END IF;
        --
      ELSIF g_fila_devuelve != g_max_secu_query THEN
          --
          g_fila_devuelve := g_tb_a2109010_mrd.NEXT(g_fila_devuelve);
          --
          post_query(g_fila_devuelve);
          --
          p_num_secu_k := g_fila_devuelve;
          --
          p_num_poliza            := g_tb_a2109010_mrd(g_fila_devuelve).num_poliza           ;
          p_mes                   := g_tb_a2109010_mrd(g_fila_devuelve).mes                  ;
          p_anio                  := g_tb_a2109010_mrd(g_fila_devuelve).anio                 ;
          p_cod_ramo              := g_tb_a2109010_mrd(g_fila_devuelve).cod_ramo             ;
          p_num_spto              := g_tb_a2109010_mrd(g_fila_devuelve).num_spto             ;
          p_num_apli              := g_tb_a2109010_mrd(g_fila_devuelve).num_apli             ;
          p_num_spto_apli         := g_tb_a2109010_mrd(g_fila_devuelve).num_spto_apli        ;
          p_num_poliza_grupo      := g_tb_a2109010_mrd(g_fila_devuelve).num_poliza_grupo     ;
          p_cod_plan              := g_tb_a2109010_mrd(g_fila_devuelve).cod_plan             ;
          p_nom_plan              := NULL;
          p_cod_modalidad         := g_tb_a2109010_mrd(g_fila_devuelve).cod_modalidad        ;
          p_cod_modalidad_ren     := g_tb_a2109010_mrd(g_fila_devuelve).cod_modalidad_ren    ;
          p_cant_riesgos          := g_tb_a2109010_mrd(g_fila_devuelve).cant_riesgos         ;
          p_num_riesgo            := g_tb_a2109010_mrd(g_fila_devuelve).num_riesgo           ;
          p_nom_riesgo            := NULL;
          p_cod_tip_vehi          := g_tb_a2109010_mrd(g_fila_devuelve).cod_tip_vehi         ;
          p_tip_docum             := g_tb_a2109010_mrd(g_fila_devuelve).tip_docum            ;
          p_cod_docum             := g_tb_a2109010_mrd(g_fila_devuelve).cod_docum            ;
          p_nom_tomador           := NULL;
          p_cod_marca             := g_tb_a2109010_mrd(g_fila_devuelve).cod_marca            ;
          p_cod_modelo            := g_tb_a2109010_mrd(g_fila_devuelve).cod_modelo           ;
          p_cod_sub_modelo        := g_tb_a2109010_mrd(g_fila_devuelve).cod_sub_modelo       ;
          p_anio_modelo           := g_tb_a2109010_mrd(g_fila_devuelve).anio_modelo          ;
          p_num_chasis            := g_tb_a2109010_mrd(g_fila_devuelve).num_chasis           ;
          p_suma_aseg             := g_tb_a2109010_mrd(g_fila_devuelve).suma_aseg            ;
          p_suma_aseg_ren         := g_tb_a2109010_mrd(g_fila_devuelve).suma_aseg_ren        ;
          p_prima                 := g_tb_a2109010_mrd(g_fila_devuelve).prima                ;
          p_prima_ren             := g_tb_a2109010_mrd(g_fila_devuelve).prima_ren            ;
          p_prima_preren          := g_tb_a2109010_mrd(g_fila_devuelve).prima_preren         ;
          p_nueva_dif_prima_ren   := g_tb_a2109010_mrd(g_fila_devuelve).nueva_dif_prima_ren  ;
          p_nueva_var_prima       := g_tb_a2109010_mrd(g_fila_devuelve).nueva_var_prima      ;
          p_primanetafacturada    := g_tb_a2109010_mrd(g_fila_devuelve).primanetafacturada   ;
          p_tasa                  := g_tb_a2109010_mrd(g_fila_devuelve).tasa                 ;
          p_tasa_ren              := g_tb_a2109010_mrd(g_fila_devuelve).tasa_ren             ;
          p_nueva_tasa            := g_tb_a2109010_mrd(g_fila_devuelve).nueva_tasa           ;
          p_dnr                   := g_tb_a2109010_mrd(g_fila_devuelve).dnr                  ;
          p_dnr_ren               := g_tb_a2109010_mrd(g_fila_devuelve).dnr_ren              ;
          p_variacion_valor       := g_tb_a2109010_mrd(g_fila_devuelve).variacion_valor      ;
          p_variacion_valor_ren   := g_tb_a2109010_mrd(g_fila_devuelve).variacion_valor_ren  ;
          p_diferencia            := g_tb_a2109010_mrd(g_fila_devuelve).diferencia           ;
          p_diferencia_ren        := g_tb_a2109010_mrd(g_fila_devuelve).diferencia_ren       ;
          p_evolucion             := g_tb_a2109010_mrd(g_fila_devuelve).evolucion            ;
          p_evolucion_ren         := g_tb_a2109010_mrd(g_fila_devuelve).evolucion_ren        ;
          p_variacion             := g_tb_a2109010_mrd(g_fila_devuelve).variacion            ;
          p_variacion_ren         := g_tb_a2109010_mrd(g_fila_devuelve).variacion_ren        ;
          p_desc_comercial        := g_tb_a2109010_mrd(g_fila_devuelve).desc_comercial       ;
          p_desc_comercial_ren    := g_tb_a2109010_mrd(g_fila_devuelve).desc_comercial_ren   ;
          p_mca_siniestros        := g_tb_a2109010_mrd(g_fila_devuelve).mca_siniestros       ;
          p_num_siniestros        := g_tb_a2109010_mrd(g_fila_devuelve).num_siniestros       ;
          p_sini_pag              := g_tb_a2109010_mrd(g_fila_devuelve).sini_pag             ;
          p_sini_por_pag          := g_tb_a2109010_mrd(g_fila_devuelve).sini_por_pag         ;
          p_num_sini_menores      := g_tb_a2109010_mrd(g_fila_devuelve).num_sini_menores     ;
          p_num_sini_mayores      := g_tb_a2109010_mrd(g_fila_devuelve).num_sini_mayores     ;
          p_imp_siniestros        := g_tb_a2109010_mrd(g_fila_devuelve).imp_siniestros       ;
          p_mca_sin_mayor_cero    := g_tb_a2109010_mrd(g_fila_devuelve).mca_sin_mayor_cero   ;
          p_factor_recargo        := g_tb_a2109010_mrd(g_fila_devuelve).factor_recargo       ;
          p_factor_ajuste         := g_tb_a2109010_mrd(g_fila_devuelve).factor_ajuste        ;
          p_cod_agt               := NULL;
          p_nom_intermediario     := NULL;
          p_fec_efec_riesgo       := g_tb_a2109010_mrd(g_fila_devuelve).fec_efec_riesgo          ;
          p_fec_vcto_riesgo       := g_tb_a2109010_mrd(g_fila_devuelve).fec_vcto_riesgo          ;
          p_tip_coaseguro         := NULL;
          p_cod_mon               := g_tb_a2109010_mrd(g_fila_devuelve).cod_mon              ;
          p_mca_catastrofico      := NULL;
          p_direccion             := NULL;
          p_mca_balance           := NULL;
          p_balance               := NULL;
          p_dias_vig              := NULL;
          p_dias_trans            := NULL;
          p_siniestralidad        := NULL;
          p_reaseguro_fac         := NULL;
          p_motivo                := NULL;
          p_grupo                 := NULL;
          p_mca_poliza_automatica := NULL;
          p_fec_tratamiento       := g_tb_a2109010_mrd(g_fila_devuelve).fec_tratamiento      ;
          p_tip_situ              := NULL;
          p_num_orden             := g_tb_a2109010_mrd(g_fila_devuelve).num_orden            ;
          p_tip_cuenta            := NULL;
          p_tip_estatus           := NULL;
          p_tip_resultado         := NULL;
          p_tip_estatus_cobro     := NULL;
          p_cod_cia_coaseguradora := NULL;
          p_nom_cia_coaseguradora := NULL;
          p_pct_participacion     := NULL;
          p_categoria             := g_tb_a2109010_mrd(g_fila_devuelve).categoria            ;
          p_pct_categoria         := g_tb_a2109010_mrd(g_fila_devuelve).pct_categoria        ;
          p_nom_tip_vehi          := NULL;
          p_nom_marca             := NULL;
          p_nom_modelo            := NULL;
          p_nom_sub_modelo        := NULL;
          p_nom_modalidad         := NULL;
          p_nom_modalidad_ren     := NULL;
          p_cod_zona_vehi         := g_tb_a2109010_mrd(g_fila_devuelve).cod_zona_vehi        ;
          p_nom_zona_vehi         := NULL;
          p_cod_uso_vehi          := g_tb_a2109010_mrd(g_fila_devuelve).cod_uso_vehi         ;
          p_num_matricula         := g_tb_a2109010_mrd(g_fila_devuelve).num_matricula        ;
          p_cod_cuadro_com        := g_tb_a2109010_mrd(g_fila_devuelve).cod_cuadro_com       ;
          p_cod_oficial           := g_tb_a2109010_mrd(g_fila_devuelve).cod_oficial          ;
          p_tip_benef             := g_tb_a2109010_mrd(g_fila_devuelve).tip_benef            ;
          p_tip_docum_benef       := g_tb_a2109010_mrd(g_fila_devuelve).tip_docum_benef      ;
          p_cod_docum_benef       := g_tb_a2109010_mrd(g_fila_devuelve).cod_docum_benef      ;
          p_importe_endoso        := g_tb_a2109010_mrd(g_fila_devuelve).importe_endoso       ;
          p_cod_fracc_pago        := g_tb_a2109010_mrd(g_fila_devuelve).cod_fracc_pago       ;
          p_pct_desc_com_pol      := g_tb_a2109010_mrd(g_fila_devuelve).pct_desc_com_pol     ;
          p_equipo_gas            := g_tb_a2109010_mrd(g_fila_devuelve).equipo_gas           ;
          p_tip_aeroambulancia    := g_tb_a2109010_mrd(g_fila_devuelve).tip_aeroambulancia   ;
          p_tip_estatus_riesgo    := g_tb_a2109010_mrd(g_fila_devuelve).tip_estatus_riesgo   ;
          p_ind_sini_acumulado    := g_tb_a2109010_mrd(g_fila_devuelve).ind_sini_acumulado   ;
          p_meses_vig             := g_tb_a2109010_mrd(g_fila_devuelve).meses_vig            ;
          p_txt_error_ct          := g_tb_a2109010_mrd(g_fila_devuelve).txt_error_ct         ;
          p_cod_usr               := g_tb_a2109010_mrd(g_fila_devuelve).cod_usr              ;
          p_txt_error_pol         := g_tb_a2109010_mrd(g_fila_devuelve).txt_error_pol        ; -- Version :1.02
          --
      ELSE
          --
          p_num_secu_k := NULL;
          --
          p_num_poliza            := NULL;
          p_mes                   := NULL;
          p_anio                  := NULL;
          p_cod_ramo              := NULL;
          p_num_spto              := NULL;
          p_num_apli              := NULL;
          p_num_spto_apli         := NULL;
          p_num_poliza_grupo      := NULL;
          p_cod_plan              := NULL;
          p_nom_plan              := NULL;
          p_cod_modalidad         := NULL;
          p_cod_modalidad_ren     := NULL;
          p_cant_riesgos          := NULL;
          p_num_riesgo            := NULL;
          p_nom_riesgo            := NULL;
          p_cod_tip_vehi          := NULL;
          p_tip_docum             := NULL;
          p_cod_docum             := NULL;
          p_nom_tomador           := NULL;
          p_cod_marca             := NULL;
          p_cod_modelo            := NULL;
          p_cod_sub_modelo        := NULL;
          p_anio_modelo           := NULL;
          p_num_chasis            := NULL;
          p_suma_aseg             := NULL;
          p_suma_aseg_ren         := NULL;
          p_prima                 := NULL;
          p_prima_ren             := NULL;
          p_prima_preren          := NULL;
          p_nueva_dif_prima_ren   := NULL;
          p_nueva_var_prima       := NULL;
          p_primanetafacturada    := NULL;
          p_tasa                  := NULL;
          p_tasa_ren              := NULL;
          p_nueva_tasa            := NULL;
          p_dnr                   := NULL;
          p_dnr_ren               := NULL;
          p_variacion_valor       := NULL;
          p_variacion_valor_ren   := NULL;
          p_diferencia            := NULL;
          p_diferencia_ren        := NULL;
          p_evolucion             := NULL;
          p_evolucion_ren         := NULL;
          p_variacion             := NULL;
          p_variacion_ren         := NULL;
          p_desc_comercial        := NULL;
          p_desc_comercial_ren    := NULL;
          p_mca_siniestros        := NULL;
          p_num_siniestros        := NULL;
          p_sini_pag              := NULL;
          p_sini_por_pag          := NULL;
          p_num_sini_menores      := NULL;
          p_num_sini_mayores      := NULL;
          p_imp_siniestros        := NULL;
          p_mca_sin_mayor_cero    := NULL;
          p_factor_recargo        := NULL;
          p_factor_ajuste         := NULL;
          p_cod_agt               := NULL;
          p_nom_intermediario     := NULL;
          p_fec_efec_riesgo       := NULL;
          p_fec_vcto_riesgo       := NULL;
          p_tip_coaseguro         := NULL;
          p_cod_mon               := NULL;
          p_mca_catastrofico      := NULL;
          p_direccion             := NULL;
          p_mca_balance           := NULL;
          p_balance               := NULL;
          p_dias_vig              := NULL;
          p_dias_trans            := NULL;
          p_siniestralidad        := NULL;
          p_reaseguro_fac         := NULL;
          p_motivo                := NULL;
          p_grupo                 := NULL;
          p_mca_poliza_automatica := NULL;
          p_fec_tratamiento       := NULL;
          p_tip_situ              := NULL;
          p_num_orden             := NULL;
          p_tip_estatus           := NULL;
          p_tip_cuenta            := NULL;
          p_tip_resultado         := NULL;
          p_tip_estatus_cobro     := NULL;
          p_cod_cia_coaseguradora := NULL;
          p_nom_cia_coaseguradora := NULL;
          p_pct_participacion     := NULL;
          p_categoria             := NULL;
          p_pct_categoria         := NULL;
          p_nom_tip_vehi          := NULL;
          p_nom_marca             := NULL;
          p_nom_modelo            := NULL;
          p_nom_sub_modelo        := NULL;
          p_nom_modalidad         := NULL;
          p_nom_modalidad_ren     := NULL;
          p_cod_zona_vehi         := NULL;
          p_nom_zona_vehi         := NULL;
          p_cod_uso_vehi          := NULL;
          p_num_matricula         := NULL;
          p_cod_cuadro_com        := NULL;
          p_nom_cuadro_com        := NULL;
          p_cod_oficial           := NULL;
          p_tip_benef             := NULL;
          p_tip_docum_benef       := NULL;
          p_cod_docum_benef       := NULL;
          p_nom_benef             := NULL;
          p_importe_endoso        := NULL;
          p_cod_fracc_pago        := NULL;
          p_pct_desc_com_pol      := NULL;
          p_equipo_gas            := NULL;
          p_nom_equipo_gas        := NULL;
          p_tip_aeroambulancia    := NULL;
          p_nom_aeroambulancia    := NULL;
          p_tip_estatus_riesgo    := NULL;
          p_ind_sini_acumulado    := NULL;
          p_meses_vig             := NULL;
          p_txt_error_ct          := NULL;
          p_cod_usr               := NULL;
          p_txt_error_pol         := NULL;  -- Version : 1.03
          --
      END IF;
      --
      -- Buscar los datos de los datos generales de poliza:
      OPEN  cl_a2009030;
      FETCH cl_a2009030 INTO reg_a2009030;
      CLOSE cl_a2009030;
      --
      IF NVL(p_num_secu_k,0) != 0 THEN
        --
        p_tip_estatus       := reg_a2009030.tip_estatus;
        p_tip_resultado     := reg_a2009030.tip_resultado;
        p_tip_estatus_cobro := reg_a2009030.tip_estatus_cobro;
        --
        p_cod_ejecutivo     := reg_a2009030.cod_ejecutivo;
        p_ejecutivo_cobros  := reg_a2009030.ejecutivo_cobros;
        --
        p_nom_tomador       := reg_a2009030.tomador;
        p_cod_agt           := reg_a2009030.cod_agt;
        p_nom_intermediario := reg_a2009030.intermediario;
        p_cod_nivel3        := reg_a2009030.cod_nivel3;
        p_nom_nivel3        := reg_a2009030.nom_nivel3;
        p_cod_mon           := reg_a2009030.cod_mon;
        p_balance           := reg_a2009030.balance;
        p_motivo            := reg_a2009030.motivo;
        --
        p_nom_marca         := f_campo_variable_a(g_tb_a2109010_mrd(g_fila_devuelve).cod_cia,
                                                  g_tb_a2109010_mrd(g_fila_devuelve).num_poliza,
                                                  'COD_MARCA', 'J',  -- Version: 1.14
                                                  g_tb_a2109010_mrd(g_fila_devuelve).cod_ramo,
                                                  g_tb_a2109010_mrd(g_fila_devuelve).num_riesgo);
        --
        p_nom_modelo        := f_campo_variable_a(g_tb_a2109010_mrd(g_fila_devuelve).cod_cia,
                                                  g_tb_a2109010_mrd(g_fila_devuelve).num_poliza,
                                                  'COD_MODELO', 'J',  -- Version: 1.14
                                                  g_tb_a2109010_mrd(g_fila_devuelve).cod_ramo,
                                                  g_tb_a2109010_mrd(g_fila_devuelve).num_riesgo);
        --
        p_nom_sub_modelo    := f_campo_variable_a(g_tb_a2109010_mrd(g_fila_devuelve).cod_cia,
                                                  g_tb_a2109010_mrd(g_fila_devuelve).num_poliza,
                                                  'COD_SUB_MODELO', 'J',  -- Version: 1.14
                                                  g_tb_a2109010_mrd(g_fila_devuelve).cod_ramo,
                                                  g_tb_a2109010_mrd(g_fila_devuelve).num_riesgo);
        --
        -- Fec.: 23-Mar-16, Version : 1.04 ( Puesto en comentario, usar solo a f_nom_modalidad )
        /*p_nom_modalidad     := f_campo_variable_a(g_tb_a2109010_mrd(g_fila_devuelve).cod_cia,
                                                  g_tb_a2109010_mrd(g_fila_devuelve).num_poliza,
                                                  'COD_MODALIDAD', 'T',
                                                  g_tb_a2109010_mrd(g_fila_devuelve).cod_ramo,
                                                  g_tb_a2109010_mrd(g_fila_devuelve).num_riesgo);
        --
        IF p_cod_modalidad = p_cod_modalidad_ren THEN
            p_nom_modalidad_ren := p_nom_modalidad;
        END IF;*/
        --
        IF p_nom_modalidad IS NULL THEN -- Fec. 29-Dic-14
            p_nom_modalidad := f_nom_modalidad(g_tb_a2109010_mrd(g_fila_devuelve).cod_cia,
                                              g_tb_a2109010_mrd(g_fila_devuelve).cod_modalidad );
        END IF;
        --
        IF p_nom_modalidad_ren IS NULL THEN -- Fec. 29-Dic-14
            p_nom_modalidad_ren := f_nom_modalidad(g_tb_a2109010_mrd(g_fila_devuelve).cod_cia,
                                                  g_tb_a2109010_mrd(g_fila_devuelve).cod_modalidad_ren );
        END IF;
        --
        p_nom_tip_vehi      := f_campo_variable_a(g_tb_a2109010_mrd(g_fila_devuelve).cod_cia,
                                                  g_tb_a2109010_mrd(g_fila_devuelve).num_poliza,
                                                  'COD_TIP_VEHI', 'J',  -- Version: 1.14
                                                  g_tb_a2109010_mrd(g_fila_devuelve).cod_ramo,
                                                  g_tb_a2109010_mrd(g_fila_devuelve).num_riesgo);
        --
        p_nom_uso_vehi      := f_campo_variable_a(g_tb_a2109010_mrd(g_fila_devuelve).cod_cia,
                                                  g_tb_a2109010_mrd(g_fila_devuelve).num_poliza,
                                                  'COD_USO_VEHI', 'J',  -- Version: 1.14
                                                  g_tb_a2109010_mrd(g_fila_devuelve).cod_ramo,
                                                  g_tb_a2109010_mrd(g_fila_devuelve).num_riesgo);
        --
        p_nom_zona_vehi     := f_campo_variable_a(g_tb_a2109010_mrd(g_fila_devuelve).cod_cia,
                                                  g_tb_a2109010_mrd(g_fila_devuelve).num_poliza,
                                                  'COD_ZONA_VEHI', 'J',  -- Version: 1.14
                                                  g_tb_a2109010_mrd(g_fila_devuelve).cod_ramo,
                                                  g_tb_a2109010_mrd(g_fila_devuelve).num_riesgo);
        --
        p_nom_equipo_gas    := f_campo_variable_a(g_tb_a2109010_mrd(g_fila_devuelve).cod_cia,
                                                  g_tb_a2109010_mrd(g_fila_devuelve).num_poliza,
                                                  'COD_EQ_GAS', 'J',  -- Version: 1.14
                                                  g_tb_a2109010_mrd(g_fila_devuelve).cod_ramo,
                                                  g_tb_a2109010_mrd(g_fila_devuelve).num_riesgo);
        --
        p_nom_aeroambulancia:= f_campo_variable_a(g_tb_a2109010_mrd(g_fila_devuelve).cod_cia,
                                                  g_tb_a2109010_mrd(g_fila_devuelve).num_poliza,
                                                  'TIP_AEROAMBULANCIA', 'J',  -- Version: 1.14
                                                  g_tb_a2109010_mrd(g_fila_devuelve).cod_ramo,
                                                  g_tb_a2109010_mrd(g_fila_devuelve).num_riesgo);
        --
        p_nom_oficial       := f_campo_variable_a(g_tb_a2109010_mrd(g_fila_devuelve).cod_cia,
                                                  g_tb_a2109010_mrd(g_fila_devuelve).num_poliza,
                                                  'COD_OFICIAL', 'J',  -- Version: 1.14
                                                  g_tb_a2109010_mrd(g_fila_devuelve).cod_ramo,
                                                  0);   -- Riesgo Cero
        --
        -- Buscar Nombre Benef.:
        OPEN  cr_a1001399 (g_tb_a2109010_mrd(g_fila_devuelve).cod_cia,
                            g_tb_a2109010_mrd(g_fila_devuelve).tip_docum_benef,
                            g_tb_a2109010_mrd(g_fila_devuelve).cod_docum_benef);
        FETCH cr_a1001399 INTO p_nom_benef;
        CLOSE cr_a1001399;
        --
        -- Buscar Nombre Forma Pago:
        OPEN  cr_a1001402 (g_tb_a2109010_mrd(g_fila_devuelve).cod_cia,
                            g_tb_a2109010_mrd(g_fila_devuelve).cod_fracc_pago);
        FETCH cr_a1001402 INTO p_nom_fracc_pago;
        CLOSE cr_a1001402;
        --
        -- Buscar Nombre Cuadro Com.:
        OPEN  cr_a1001752 (g_tb_a2109010_mrd(g_fila_devuelve).cod_cia,
                            g_tb_a2109010_mrd(g_fila_devuelve).cod_cuadro_com);
        FETCH cr_a1001752 INTO p_nom_cuadro_com;
        CLOSE cr_a1001752;
        --
        -- Buscar Estatus Reglas:
        OPEN  cr_a2109013 (g_tb_a2109010_mrd(g_fila_devuelve).cod_cia);
        FETCH cr_a2109013 INTO l_cant_reglas;
        CLOSE cr_a2109013;
        IF l_cant_reglas = 0 THEN
            p_estatus_reglas := 'NO REGLAS APLICADAS';
        ELSIF l_cant_reglas = 1 THEN
            p_estatus_reglas := 'SOLO 1ra. REGLA APLICADA';
        ELSIF l_cant_reglas = 2 THEN
            p_estatus_reglas := '1ra. y 2da. REGLAS APLICADAS';
        END IF;
        --
      END IF;
      --
    END p_devuelve;
    --
    /**
    || Devuelve la PK del registro
    */
    FUNCTION f_devuelve_pk RETURN VARCHAR2 IS
      --
      l_retorno g1010031.cod_campo%TYPE;
      --
    BEGIN
      --
      IF g_cnt_pk = 1 THEN
        --
        g_cnt_pk  := 2;
        l_retorno := 'num_poliza';
        --
      ELSIF g_cnt_pk = 2 THEN
        --
        g_cnt_pk  := 3;
        l_retorno := 'mes';
        --
      ELSIF g_cnt_pk = 3 THEN
        --
        g_cnt_pk  := 4;
        l_retorno := 'anio';
        --
      ELSIF g_cnt_pk = 4 THEN
        --
        g_cnt_pk  := 1;
        l_retorno := NULL;
        --
      END IF;
      --
      RETURN l_retorno;
      --
    END f_devuelve_pk;
    --
    -- ------------------------------------------------------------
    --
    /**
    || Procedimiento para dar de alta un registro
    */
    PROCEDURE p_alta(p_cod_pgm VARCHAR2) IS
    BEGIN
      --
      g_fila := NULL;
      --
      greg_a2109010_mrd := greg_a2109010_mrd_nulo;
      --
      permiso_usr(p_cod_pgm);
      --
    END p_alta;
    --
    -- ------------------------------------------------------------
    --
    /**
    || p_modifica :
    */
    PROCEDURE p_modifica( p_num_secu_k NUMBER  ,
                          p_cod_pgm    VARCHAR2
                        ) IS
    BEGIN
      --
      IF p_num_secu_k IS NULL THEN
        --
        g_cod_mensaje_cp := 20013;
        g_anx_mensaje := NULL;
        --
        pp_devuelve_error;
        --
      END IF;
      --
      permiso_usr(p_cod_pgm);
      --
      g_fila := p_num_secu_k;
      --
      bloquea;
      --
      rellena_registro(g_fila);
      --
    END p_modifica;
    --
    -- ------------------------------------------------------------
    --
    /**
    || Borrar un registro
    */
    PROCEDURE p_borra( p_num_secu_k NUMBER  ,
                       p_cod_pgm    VARCHAR2
                     ) IS
    BEGIN
      --
      IF p_num_secu_k IS NULL THEN
        --
        g_cod_mensaje_cp := 20013;
        g_anx_mensaje := NULL;
        --
        pp_devuelve_error;
        --
      END IF;
      --
      g_fila := p_num_secu_k;
      --
      permiso_usr(p_cod_pgm);
      --
      bloquea;
      --
      IF g_tb_a2109010_mrd(g_fila).clave IS NOT NULL THEN
        --
        DELETE FROM a2109010_mrd
        WHERE rowid = g_tb_a2109010_mrd(g_fila).clave;
        --
      ELSE
        --
        DELETE FROM a2109010_mrd
        WHERE num_poliza            = g_tb_a2109010_mrd(g_fila).num_poliza
          AND mes                   = g_tb_a2109010_mrd(g_fila).mes
          AND anio                  = g_tb_a2109010_mrd(g_fila).anio;
        --
      END IF;
      --
      g_tb_a2109010_mrd.DELETE(g_fila);
      --
      g_hay_cambios := 'S';
      --
    END p_borra;
    --
    -- ------------------------------------------------------------
    --
    /**
    || p_graba :
    */
    PROCEDURE p_graba IS
      --
      l_max_secu BINARY_INTEGER;
      l_fila     BINARY_INTEGER;
      --
    BEGIN
      --
      l_max_secu := g_max_secu_ins;
      l_fila     := g_tb_a2109010_mrd.NEXT(g_max_secu_ins);
      --
      WHILE l_fila <= NVL(g_tb_a2109010_mrd.LAST,-1) LOOP
        --
        greg.cod_cia               := g_tb_a2109010_mrd(l_fila).cod_cia              ;
        greg.num_poliza            := g_tb_a2109010_mrd(l_fila).num_poliza           ;
        greg.mes                   := g_tb_a2109010_mrd(l_fila).mes                  ;
        greg.anio                  := g_tb_a2109010_mrd(l_fila).anio                 ;
        greg.cod_ramo              := g_tb_a2109010_mrd(l_fila).cod_ramo             ;
        greg.num_spto              := g_tb_a2109010_mrd(l_fila).num_spto             ;
        greg.num_apli              := g_tb_a2109010_mrd(l_fila).num_apli             ;
        greg.num_spto_apli         := g_tb_a2109010_mrd(l_fila).num_spto_apli        ;
        greg.num_poliza_grupo      := g_tb_a2109010_mrd(l_fila).num_poliza_grupo     ;
        greg.cod_plan              := g_tb_a2109010_mrd(l_fila).cod_plan             ;
        greg.cod_modalidad         := g_tb_a2109010_mrd(l_fila).cod_modalidad        ;
        greg.cod_modalidad_ren     := g_tb_a2109010_mrd(l_fila).cod_modalidad_ren    ;
        greg.cant_riesgos          := g_tb_a2109010_mrd(l_fila).cant_riesgos         ;
        greg.num_riesgo            := g_tb_a2109010_mrd(l_fila).num_riesgo           ;
        greg.cod_tip_vehi          := g_tb_a2109010_mrd(l_fila).cod_tip_vehi         ;
        greg.tip_docum             := g_tb_a2109010_mrd(l_fila).tip_docum            ;
        greg.cod_docum             := g_tb_a2109010_mrd(l_fila).cod_docum            ;
        greg.cod_marca             := g_tb_a2109010_mrd(l_fila).cod_marca            ;
        greg.cod_modelo            := g_tb_a2109010_mrd(l_fila).cod_modelo           ;
        greg.cod_sub_modelo        := g_tb_a2109010_mrd(l_fila).cod_sub_modelo       ;
        greg.anio_modelo           := g_tb_a2109010_mrd(l_fila).anio_modelo          ;
        greg.num_chasis            := g_tb_a2109010_mrd(l_fila).num_chasis           ;
        greg.suma_aseg             := g_tb_a2109010_mrd(l_fila).suma_aseg            ;
        greg.suma_aseg_ren         := g_tb_a2109010_mrd(l_fila).suma_aseg_ren        ;
        greg.prima                 := g_tb_a2109010_mrd(l_fila).prima                ;
        greg.prima_ren             := g_tb_a2109010_mrd(l_fila).prima_ren            ;
        greg.prima_preren          := g_tb_a2109010_mrd(l_fila).prima_preren         ;
        greg.nueva_dif_prima_ren   := g_tb_a2109010_mrd(l_fila).nueva_dif_prima_ren  ;
        greg.nueva_var_prima       := g_tb_a2109010_mrd(l_fila).nueva_var_prima      ;
        greg.primanetafacturada    := g_tb_a2109010_mrd(l_fila).primanetafacturada   ;
        greg.tasa                  := g_tb_a2109010_mrd(l_fila).tasa                 ;
        greg.tasa_ren              := g_tb_a2109010_mrd(l_fila).tasa_ren             ;
        greg.nueva_tasa            := g_tb_a2109010_mrd(l_fila).nueva_tasa           ;
        greg.dnr                   := g_tb_a2109010_mrd(l_fila).dnr                  ;
        greg.dnr_ren               := g_tb_a2109010_mrd(l_fila).dnr_ren              ;
        greg.variacion_valor       := g_tb_a2109010_mrd(l_fila).variacion_valor      ;
        greg.variacion_valor_ren   := g_tb_a2109010_mrd(l_fila).variacion_valor_ren  ;
        greg.diferencia            := g_tb_a2109010_mrd(l_fila).diferencia           ;
        greg.diferencia_ren        := g_tb_a2109010_mrd(l_fila).diferencia_ren       ;
        greg.evolucion             := g_tb_a2109010_mrd(l_fila).evolucion            ;
        greg.evolucion_ren         := g_tb_a2109010_mrd(l_fila).evolucion_ren        ;
        greg.variacion             := g_tb_a2109010_mrd(l_fila).variacion            ;
        greg.variacion_ren         := g_tb_a2109010_mrd(l_fila).variacion_ren        ;
        greg.desc_comercial        := g_tb_a2109010_mrd(l_fila).desc_comercial       ;
        greg.desc_comercial_ren    := g_tb_a2109010_mrd(l_fila).desc_comercial_ren   ;
        greg.mca_siniestros        := g_tb_a2109010_mrd(l_fila).mca_siniestros       ;
        greg.num_siniestros        := g_tb_a2109010_mrd(l_fila).num_siniestros       ;
        greg.sini_pag              := g_tb_a2109010_mrd(l_fila).sini_pag             ;
        greg.sini_por_pag          := g_tb_a2109010_mrd(l_fila).sini_por_pag         ;
        greg.num_sini_menores      := g_tb_a2109010_mrd(l_fila).num_sini_menores     ;
        greg.num_sini_mayores      := g_tb_a2109010_mrd(l_fila).num_sini_mayores     ;
        greg.imp_siniestros        := g_tb_a2109010_mrd(l_fila).imp_siniestros       ;
        greg.mca_sin_mayor_cero    := g_tb_a2109010_mrd(l_fila).mca_sin_mayor_cero   ;
        greg.factor_recargo        := g_tb_a2109010_mrd(l_fila).factor_recargo       ;
        greg.factor_ajuste         := g_tb_a2109010_mrd(l_fila).factor_ajuste        ;
        greg.fec_efec_riesgo       := g_tb_a2109010_mrd(l_fila).fec_efec_riesgo      ;
        greg.fec_vcto_riesgo       := g_tb_a2109010_mrd(l_fila).fec_vcto_riesgo      ;
        greg.fec_tratamiento       := g_tb_a2109010_mrd(l_fila).fec_tratamiento      ;
        greg.num_orden             := g_tb_a2109010_mrd(l_fila).num_orden            ;
        greg.categoria             := g_tb_a2109010_mrd(l_fila).categoria            ;
        greg.pct_categoria         := g_tb_a2109010_mrd(l_fila).pct_categoria        ;
        greg.cod_zona_vehi         := g_tb_a2109010_mrd(l_fila).cod_zona_vehi        ;
        greg.cod_uso_vehi          := g_tb_a2109010_mrd(l_fila).cod_uso_vehi         ;
        greg.num_matricula         := g_tb_a2109010_mrd(l_fila).num_matricula        ;
        greg.cod_cuadro_com        := g_tb_a2109010_mrd(l_fila).cod_cuadro_com       ;
        greg.cod_oficial           := g_tb_a2109010_mrd(l_fila).cod_oficial          ;
        greg.tip_benef             := g_tb_a2109010_mrd(l_fila).tip_benef            ;
        greg.tip_docum_benef       := g_tb_a2109010_mrd(l_fila).tip_docum_benef      ;
        greg.cod_docum_benef       := g_tb_a2109010_mrd(l_fila).cod_docum_benef      ;
        greg.importe_endoso        := g_tb_a2109010_mrd(l_fila).importe_endoso       ;
        greg.cod_fracc_pago        := g_tb_a2109010_mrd(l_fila).cod_fracc_pago       ;
        greg.pct_desc_com_pol      := g_tb_a2109010_mrd(l_fila).pct_desc_com_pol     ;
        greg.equipo_gas            := g_tb_a2109010_mrd(l_fila).equipo_gas           ;
        greg.tip_aeroambulancia    := g_tb_a2109010_mrd(l_fila).tip_aeroambulancia   ;
        greg.tip_estatus_riesgo    := g_tb_a2109010_mrd(l_fila).tip_estatus_riesgo   ;
        greg.ind_sini_acumulado    := g_tb_a2109010_mrd(l_fila).ind_sini_acumulado   ;
        greg.meses_vig             := g_tb_a2109010_mrd(l_fila).meses_vig            ;
        greg.txt_error_ct          := g_tb_a2109010_mrd(l_fila).txt_error_ct         ;
        greg.cod_usr               := g_tb_a2109010_mrd(l_fila).cod_usr              ;
        greg.txt_error_pol         := g_tb_a2109010_mrd(l_fila).txt_error_pol        ; -- Version : 1.03
        --
        p_inserta(greg);
        --
        g_max_secu_ins := g_max_secu_ins + 1;
        l_fila         := g_tb_a2109010_mrd.NEXT(l_fila);
        --
      END LOOP;
      --
      EXCEPTION
          WHEN DUP_VAL_ON_INDEX THEN
            --
            g_max_secu_ins   := l_max_secu;
            --
            g_cod_mensaje_cp := 20099;
            g_anx_mensaje    := g_k_ini_corchete ||
                                g_tb_a2109010_mrd(l_fila).num_poliza ||' - '||
                                TO_CHAR( g_tb_a2109010_mrd(l_fila).mes ) ||' - '||
                                TO_CHAR( g_tb_a2109010_mrd(l_fila).anio ) ||
                                g_k_fin_corchete;
            --
            g_tb_a2109010_mrd.DELETE(l_fila);
            --
            pp_devuelve_error;
            --
          WHEN OTHERS THEN
            --
            g_max_secu_ins := l_max_secu;
            --
            g_tb_a2109010_mrd.DELETE(l_fila);
            --
            g_cod_mensaje_cp := SQLCODE;
            g_anx_mensaje := SQLERRM(SQLCODE);
            --
            pp_devuelve_error;
            --
    END p_graba;
    --
    -- ------------------------------------------------
    -- Autor : Manuel Rodriguez
    -- Fecha : 27-Nov-14
    -- Nota  : Programa que se invoca desde JAVA para
    --       : para actualizar el Estatus Poliza.
    -- ------------------------------------------------
    PROCEDURE p_actualiza_estatus_java ( p_num_poliza            IN  a2109010_mrd.num_poliza           %TYPE,
                                          p_anio                  IN  a2109010_mrd.anio                 %TYPE,
                                          p_mes                   IN  a2109010_mrd.mes                  %TYPE,
                                          p_motivo                IN  a2009030_mrd.motivo               %TYPE,
                                          p_tip_estatus           IN  a2009030_mrd.tip_estatus          %TYPE
                                        ) IS
      --
      --l_total_prima_preren     a2109010.prima_preren%TYPE := 0;  borrar
      --
    BEGIN
      --
      UPDATE a2009030
         SET motivo      = p_motivo,
             tip_estatus = p_tip_estatus,
             cod_usr_modif = USER,       -- Fec.: 2-Jun-15, Version : 1.03
             fec_modificacion = SYSDATE  -- Fec.: 2-Jun-15, Version : 1.03
       WHERE num_poliza  = p_num_poliza
         AND mes         = p_mes
         AND anio        = p_anio;
      --
    END p_actualiza_estatus_java;
    --
    -- ------------------------------------------------
    -- Autor : Manuel Rodriguez
    -- Fecha : 30-Oct-14
    -- Nota  : Programa que se invoca desde JAVA para
    --       : para actualizar los campos que cambian.
    -- ------------------------------------------------
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
                                      ) IS
      --
      CURSOR cl_a2009030 IS
        SELECT NVL(tip_estatus,0)
          FROM a2009030
        WHERE num_poliza = p_Num_Poliza
          AND mes        = p_Mes
          AND anio       = p_Anio;
      --
      CURSOR cl_a2109010_r IS
        SELECT NVL(factor_ajuste,0)
          FROM a2109010
        WHERE cod_cia    = p_Cod_Cia
          AND num_poliza = p_Num_Poliza
          AND num_riesgo = p_Num_Riesgo
          AND anio       = p_Anio
          AND mes        = p_Mes;
      --
      CURSOR cl_a2109010_pr  IS
        SELECT SUM(prima_preren)
          FROM a2109010
        WHERE cod_cia    = p_Cod_Cia
          AND num_poliza = p_Num_Poliza
          AND anio       = p_Anio
          AND mes        = p_Mes;
      --
      l_tip_estatus            a2009030.tip_estatus%TYPE;
      l_factor_ajuste          a2109010.factor_ajuste%TYPE := 0;
      l_total_prima_preren     a2109010.prima_preren%TYPE := 0;
      --
    BEGIN
      --
      -- Buscar el estatus actual:
      OPEN  cl_a2009030;
      FETCH cl_a2009030 INTO l_tip_estatus;
      CLOSE cl_a2009030;
      --
      -- Buscar el factor actual:
      OPEN  cl_a2109010_r;
      FETCH cl_a2109010_r INTO l_factor_ajuste;
      CLOSE cl_a2109010_r;
      --
      IF l_factor_ajuste != p_factor_ajuste THEN
        --
        -- Actualizar tabla por riesgo:
        UPDATE a2109010
           SET prima_preren        = p_prima_preren,
               nueva_dif_prima_ren = p_nueva_dif_prima_ren,
               nueva_var_prima     = p_nueva_var_prima,
               diferencia_ren      = p_diferencia_ren,
               nueva_tasa          = p_nueva_tasa,
               evolucion_ren       = p_evolucion_ren,
               factor_ajuste       = p_factor_ajuste
         WHERE cod_cia       = p_cod_cia
           AND num_poliza    = p_num_poliza
           AND num_riesgo    = p_num_riesgo
           AND anio          = p_anio
           AND mes           = p_mes;
        --
        -- ---------------------------------------------------------------------------
        -- Fecha: 17-Oct-16, Version : 1.07
        -- Nota : Se coloca el INSERT, de primero, luego el UPDATE y se modifica el
        --      : EXCEPTION para agregar DUP_VAL_ON_INDEX.
        -- ---------------------------------------------------------------------------
        -- Se actualiza la tabla S2000020, con el valor digitado por el usuario, en JAVA.
        BEGIN
          --
          INSERT INTO s2000020
              ( FEC_TRATAMIENTO   ,
                TIP_MVTO_BATCH    ,  COD_CIA           ,  COD_RAMO          ,
                NUM_POLIZA        ,  NUM_RIESGO        ,  COD_MODALIDAD     ,
                COD_CAMPO         ,  VAL_CAMPO_ACTUAL  ,  VAL_CAMPO_NUEVO   ,
                NOM_PRG_SELECCION
              )
            VALUES
              ( TO_DATE(p_fec_tratamiento,'DDMMYYYY'),
                l_tip_mvto_batch    ,  p_cod_cia     ,  p_cod_ramo      ,
                p_num_poliza        ,  p_num_riesgo  ,  NULL ,
                'PCT_DESC_COM_RIES' ,  NULL          ,  trim(to_char(p_factor_ajuste,9999999999.999)),
                NULL
              );
          --
          EXCEPTION WHEN DUP_VAL_ON_INDEX THEN
            --
            UPDATE s2000020
               SET val_campo_nuevo = trim(to_char(p_factor_ajuste,9999999999.999))
             WHERE fec_tratamiento = p_fec_tratamiento
               AND tip_mvto_batch  = l_tip_mvto_batch
               AND cod_cia         = p_cod_cia
               AND cod_ramo        = p_cod_ramo
               AND num_poliza      = p_num_poliza
               AND num_riesgo      = p_num_riesgo
               AND cod_campo       = 'PCT_DESC_COM_RIES';
            --
        END;
        --
        p_limpia_tablas_r ( p_cod_cia,
                            p_cod_ramo,
                            p_num_poliza,
                            p_fec_tratamiento,
                            p_num_orden 
                          );
        --
        p_carga_tablas_r (  p_cod_cia,
                            p_cod_ramo,
                            p_num_poliza,
                            p_fec_tratamiento,
                            p_num_orden 
                         );
        --
        -- Buscar el totar de Prima PreRen:
        OPEN  cl_a2109010_pr;
        FETCH cl_a2109010_pr INTO l_total_prima_preren;
        CLOSE cl_a2109010_pr;
        --
        UPDATE a2009030
           SET tip_estatus  = p_tip_estatus,
               prima_preren = l_total_prima_preren,
               cod_usr      = USER,
               fec_modificacion = trunc(SYSDATE)
         WHERE cod_ramo    = p_cod_ramo
           AND num_poliza  = p_num_poliza
           AND mes         = p_mes
           AND anio        = p_anio;
        --
      ELSIF l_tip_estatus != p_tip_estatus THEN
        --
        UPDATE a2009030
           SET tip_estatus = p_tip_estatus,
               cod_usr     = USER,
               fec_modificacion = trunc(SYSDATE)
         WHERE cod_ramo    = p_cod_ramo
           AND num_poliza  = p_num_poliza
           AND mes         = p_mes
           AND anio        = p_anio;
        --
      END IF;
      --
      g_hay_cambios := 'S';
      --
    END p_actualiza_riesgo_java;
    --
    -- ------------------------------------------------
    -- Autor : Manuel Rodriguez         Version : 1.09
    -- Fecha : 06-Ene-17               Sismas: 1240397
    -- Nota  : Al renovarse, una poliza, que se pueda
    --       : actualizar a FEC_ACTU = SYSDATE.
    -- ------------------------------------------------
    PROCEDURE p_actualiza_fec_r2000030 ( p_cod_cia       IN  a2109010_mrd.num_poliza  %TYPE,
                                         p_num_poliza    IN  a2109010_mrd.num_poliza  %TYPE
                                       ) IS PRAGMA AUTONOMOUS_TRANSACTION;
      --
    BEGIN
      --
      UPDATE r2000030
         SET fec_actu = TRUNC(SYSDATE)
       WHERE cod_cia     = p_cod_cia
         AND num_poliza  = p_num_poliza;
      COMMIT;
      --
    END p_actualiza_fec_r2000030;
    --
    -- ------------------------------------------------------------
    --
    /**
    || f_hay_cambios :
    */
    FUNCTION f_hay_cambios RETURN VARCHAR2 IS
    BEGIN
        --
        RETURN g_hay_cambios;
        --
    END f_hay_cambios;
    --
    -- ------------------------------------------------------------
    --
    /**
    || Validacion del campo:num_poliza
    */
    PROCEDURE p_v_num_poliza( p_num_poliza IN  a2109010_mrd.num_poliza%TYPE) IS
    BEGIN
      --
      IF p_num_poliza IS NULL THEN
        --
        g_cod_mensaje_cp := 20003;
        g_anx_mensaje := g_k_ini_corchete||'num_poliza'||g_k_fin_corchete;
        --
        pp_devuelve_error;
        --
      END IF;
      --
      greg_a2109010_mrd.num_poliza            := p_num_poliza;
      --
    END p_v_num_poliza;
    --
    -- ------------------------------------------------------------
    --
    /**
    || Validacion del campo:cod_ramo
    */
    PROCEDURE p_v_cod_ramo(  p_cod_ramo              IN     a2109010_mrd.cod_ramo%TYPE,
                              p_nom_ramo              IN OUT a1001800.nom_ramo%type 
                          ) IS
      --
      CURSOR cl_a1001800 IS
        SELECT'S', nom_ramo
          FROM A1001800
        WHERE cod_ramo = p_cod_ramo;
      --
      CURSOR cl_ta999003 IS
        SELECT 'S'
          FROM ta999003
        WHERE cod_ramo  = p_cod_ramo
          AND cod_campo = 'COD_RAMO_AUTOMOVIL'
          AND mca_inh   = 'N';
      --
      l_existe  VARCHAR2(1) := 'N';
      --
    BEGIN
      --
      IF p_cod_ramo IS NOT NULL THEN
        --
        OPEN  cl_a1001800;
        FETCH cl_a1001800 INTO l_existe, p_nom_ramo;
        IF cl_a1001800%NOTFOUND THEN
          g_cod_mensaje_cp := 20127;
          g_anx_mensaje := g_k_ini_corchete||'cod_ramo'||g_k_fin_corchete;
          --
          pp_devuelve_error;
          --
        ELSE
          --
          OPEN  cl_ta999003;
          FETCH cl_ta999003 INTO l_existe;
          IF cl_ta999003%NOTFOUND THEN
            g_cod_mensaje_cp := 20128;
            g_anx_mensaje := g_k_ini_corchete||'cod_ramo'||g_k_fin_corchete;
            --
            pp_devuelve_error;
            --
          END IF;
          CLOSE cl_ta999003;
          --
        END IF;
        CLOSE cl_a1001800;
        --
      END IF;
      --
      greg_a2109010_mrd.cod_ramo              := p_cod_ramo;
      --
    END p_v_cod_ramo;
    --
    -- ------------------------------------------------------------
    --
    -- Validacion del campo:num_poliza_grupo
    PROCEDURE p_v_num_poliza_grupo(p_num_poliza_grupo IN a2109010_mrd.num_poliza_grupo%TYPE) IS
    BEGIN
      --
      greg_a2109010_mrd.num_poliza_grupo      := p_num_poliza_grupo;
      --
    END p_v_num_poliza_grupo;
    --
    -- ------------------------------------------------------------
    --
    /**
    || Validacion del campo:cod_modalidad_ren
    */
    PROCEDURE p_v_cod_modalidad_ren( p_cod_ramo              IN     a2109010_mrd.cod_ramo             %TYPE,
                                      p_cod_modalidad_ren     IN     a2109010_mrd.cod_modalidad_ren    %TYPE,
                                      p_nom_modalidad_ren     IN OUT G2990004.nom_modalidad            %TYPE 
                                    ) IS
      --
      CURSOR C_g2990004 IS
        SELECT nom_modalidad
          FROM g2990004
        WHERE cod_modalidad = p_cod_modalidad_ren
          AND mca_emision   = 'S'
          AND mca_inh       = 'N';
      --
      CURSOR C_A2100310 IS
        SELECT 'S'
          FROM A2100310
        WHERE cod_ramo      = p_cod_ramo
          AND cod_modalidad = p_cod_modalidad_ren;
      --
      l_existe  VARCHAR2(1) := 'N';
      --
    BEGIN
      --
      IF p_cod_modalidad_ren IS NOT NULL THEN
        --
        OPEN  C_g2990004;
        FETCH C_g2990004 INTO p_nom_modalidad_ren;
        IF C_g2990004%NOTFOUND THEN
          g_cod_mensaje_cp := 20129;
          g_anx_mensaje := g_k_ini_corchete||'cod_modalidad_ren'||g_k_fin_corchete;
          --
          pp_devuelve_error;
          --
        ELSIF p_cod_ramo IS NOT NULL THEN
          --
          OPEN  C_A2100310;
          FETCH C_A2100310 INTO l_existe;
          IF C_A2100310%NOTFOUND THEN
            g_cod_mensaje_cp := 20130;
            g_anx_mensaje := g_k_ini_corchete||'cod_modalidad_ren'||g_k_fin_corchete;
            --
            pp_devuelve_error;
            --
          END IF;
          CLOSE C_A2100310;
          --
        END IF;
        CLOSE C_g2990004;
        --
      END IF;
      --
      greg_a2109010_mrd.cod_modalidad_ren     := p_cod_modalidad_ren;
      --
    END p_v_cod_modalidad_ren;
    --
    -- ------------------------------------------------------------
    --
    /**
    || Validacion del campo:cod_mon
    */
    PROCEDURE p_v_cod_mon( p_cod_mon IN a2009030_mrd.cod_mon%TYPE) IS
    BEGIN
      --
      NULL;
      --greg_a2109010_mrd.cod_mon               := p_cod_mon;
      --
    END p_v_cod_mon;
    --
    -- ------------------------------------------------------------
    --
    /**
    || Procedimiento para iniciar el programas de mantenimiento
    */
    PROCEDURE p_inicio IS
    BEGIN
      --
      g_cod_cia       := trn_k_global.cod_cia;
      g_cod_usr       := trn_k_global.cod_usr;
      g_cod_idioma    := trn_k_global.cod_idioma;
      g_cod_idioma_cp := trn_k_global.cod_idioma;
      trn_p_ejecuta_sentencia('ALTER SESSION SET NLS_DATE_FORMAT = ''DDMMYYYY''');
      trn_p_ejecuta_sentencia('ALTER SESSION SET NLS_NUMERIC_CHARACTERS = ''.,''');
      --
    END p_inicio;
    --
    -- ------------------------------------------------------------
    --
    /**
    || Borra la tabla PL al terminar el programa
    */
    PROCEDURE p_termina IS
    BEGIN
      --
      g_tb_a2109010_mrd.DELETE;
      --
    END p_termina;
    --
    -- ------------------------------------------------------------
    --  Modifica : Manuel Ropdriguez
    --  Fecha    : 19-Feb-15
    --  Nota     : El objetivo es usar solo los parametros que se
    --           : envian y no el Cursor cl_a2000500.
    -- ------------------------------------------------------------
    PROCEDURE p_limpia_tablas_r ( p_cod_cia          a2000030.cod_cia           %TYPE,
                                  p_cod_ramo         a2000030.cod_ramo          %TYPE,
                                  p_num_poliza       a2000030.num_poliza        %TYPE,
                                  p_fec_tratamiento  a2000500.fec_tratamiento   %TYPE,
                                  p_num_orden        a2000500.num_orden         %TYPE
                                ) IS
      --
    BEGIN
      --
      trn_p_ejecuta_sentencia('ALTER SESSION SET NLS_DATE_FORMAT = ''DDMMYYYY''');
      trn_p_ejecuta_sentencia('ALTER SESSION SET NLS_NUMERIC_CHARACTERS = ''.,''');
      --
      DELETE FROM R2000020 a /* TABLA DE DATOS VARIABLES DE POLIZAS */
        WHERE a.cod_cia    = p_cod_cia
          AND a.num_poliza = p_num_poliza;
      --
      DELETE FROM R2000025 a /* TABLA DE LISTAS DE DATOS VARIABLES */
        WHERE a.cod_cia    = p_cod_cia
          AND a.num_poliza = p_num_poliza;
      --
      DELETE FROM R2000030 a /* TABLA DE DATOS FIJOS DE POLIZAS */
        WHERE a.cod_cia    = p_cod_cia
          AND a.num_poliza = p_num_poliza;
      --
      DELETE FROM R2000031 a /* TABLA DE FECHAS DE VIGENCIAS DE LOS RIEGOS */
        WHERE a.cod_cia    = p_cod_cia
          AND a.num_poliza = p_num_poliza;
      --
      DELETE FROM R2000040 a /* TABLA DE COBERTURAS DE UNA POLIZA SUPLEMENTO */
        WHERE a.cod_cia    = p_cod_cia
          AND a.num_poliza = p_num_poliza;
      --
      DELETE FROM R2000060 a /* TABLA DE TIPOS DE TERCERO */
        WHERE a.cod_cia    = p_cod_cia
          AND a.num_poliza = p_num_poliza;
      --
      DELETE FROM R2000100 a /* TABLA DE PORCENTAJES DE PARTICIPACION DE LAS COMPA?IAS */
        WHERE a.cod_cia    = p_cod_cia
          AND a.num_poliza = p_num_poliza;
      --
      DELETE FROM R2000161 a /* CONCEPTOS ECONOMICOS DE LAS CUOTAS DE LOS RECIBOS */
        WHERE a.cod_cia    = p_cod_cia
          AND a.num_poliza = p_num_poliza;
      --
      DELETE FROM R2000221 a /* TABLA DE ERRORES DE CONTROL TECNICO EN EMISION */
        WHERE a.cod_cia    = p_cod_cia
          AND a.num_poliza = p_num_poliza;
      --
      DELETE FROM R2000251 a /* COMISIONES POR POLIZA - SUPLEMENTO - AGENTE - FORMA ACTUACION */
        WHERE a.cod_cia    = p_cod_cia
          AND a.num_poliza = p_num_poliza;
      --
      DELETE FROM R2000252 a /* COMISIONES EXTERNAS POR POLIZA - SUPLEMENTO - AGENTE - TIPO DE COMISION */  -- Version: 1.15 (agregado)
        WHERE a.cod_cia    = p_cod_cia
          AND a.num_poliza = p_num_poliza;
      --
      DELETE FROM R2000253 a /* COMISIONES DE LA RENOVACION PREVIA */  -- Version: 1.15 (agregado)
        WHERE a.cod_cia    = p_cod_cia
          AND a.num_poliza = p_num_poliza;
      --
      DELETE FROM R2000260 a /* TABLA DE TEXTOS POR POLIZA */
        WHERE a.cod_cia    = p_cod_cia
          AND a.num_poliza = p_num_poliza;
      --
      DELETE FROM R2000265 a /* TABLA DE CLAUSULAS POR POLIZA PARA PRERENOVACIONES */
        WHERE a.cod_cia    = p_cod_cia
          AND a.num_poliza = p_num_poliza;
      --
      DELETE FROM R2100170 a /* CONCEPTOS DE DESGLOSE POR COBERTURA */
        WHERE a.cod_cia    = p_cod_cia
          AND a.num_poliza = p_num_poliza;
      --
      DELETE FROM R2100610 a /* TABLA REAL DE ACCESORIOS */
        WHERE a.cod_cia    = p_cod_cia
          AND a.num_poliza = p_num_poliza;
      --
      DELETE FROM R2300205 a /* FORMULARIOS POR POLIZA */
        WHERE a.cod_cia    = p_cod_cia
          AND a.num_poliza = p_num_poliza;
      --
      DELETE FROM R2300334 a /* VALORES GARANTIZADOS/RESERVA MATEMATICA VIDA */  -- Version: 1.15 (agregado)
        WHERE a.cod_cia    = p_cod_cia
          AND a.num_poliza = p_num_poliza;
      --
      DELETE FROM R2501000 a /* TABLA DEL REASEGURO CEDIDO POR UNA POLIZA A LOS CONTRATOS */
        WHERE a.cod_cia    = p_cod_cia
          AND a.num_poliza = p_num_poliza;
      --
      DELETE FROM R2501500 a /* TABLA DEL REASEGURO CEDIDO POR UNA POLIZA A COMPANIAS DE */  -- Version: 1.15 (agregado)
        WHERE a.cod_cia    = p_cod_cia
          AND a.num_poliza = p_num_poliza;
      --
      DELETE FROM R2501600 a /* HISTORICO DE REASEGURO */
        WHERE a.cod_cia    = p_cod_cia
          AND a.num_poliza = p_num_poliza;
      --
      DELETE FROM R2990320 a /* CAMPOS VAR. PARA CLAUSULAS */  -- Version: 1.15 (agregado)
        WHERE a.cod_cia    = p_cod_cia
          AND a.num_poliza = p_num_poliza;
      --
      DELETE FROM R2990700 a /* TABLA DE CUOTAS O RECIBOS DE UNA POLIZA */
        WHERE a.cod_cia    = p_cod_cia
          AND a.num_poliza = p_num_poliza;
      --
      DELETE FROM R2990701 a /* TABLA DE COMISIONES POR CUOTAS O RECIBOS DE UNA POLIZA */
        WHERE a.cod_cia    = p_cod_cia
          AND a.num_poliza = p_num_poliza;
      --
      DELETE FROM R2990702 a /* TABLA DE COMISIONES POR CUOTAS O RECIBOS DE UNA POLIZA PRERENOVADA */  -- Version: 1.15 (agregado)
        WHERE a.cod_cia    = p_cod_cia
          AND a.num_poliza = p_num_poliza;
      --
      DELETE FROM R2990800 a /* TABLA DE AGRAVANTES POR COBERTURA */  -- Version: 1.15 (agregado)
        WHERE a.cod_cia    = p_cod_cia
          AND a.num_poliza = p_num_poliza;
      --
      UPDATE a2000500
          SET tip_mvto_batch        = 1,
              tip_situ              = '1', --V1.16 cejv  comillas
              num_poliza_definitivo = NULL,
              mca_pre_renovacion     = 'N'
        WHERE cod_cia         = p_cod_cia
          AND num_poliza      = p_num_poliza
          AND fec_tratamiento = p_fec_tratamiento
          AND num_orden       = p_num_orden;
      --
    END p_limpia_tablas_r;
    --
    -- ----------------------------------------------------------------------
    -- Autor : Manuel Rod.                                    Version : 1.00
    -- Fecha : 19-Nov-13
    -- Nota  : Generar todos los ramos desde Control M y enviar Correo.
    -- ----------------------------------------------------------------------
    PROCEDURE p_carga_polizas_Ctl_M IS
      --
      l_mca_existe_mes VARCHAR2(1) := 'N';
      --
      -- Buscar Usuario Renueva Automovil:
      CURSOR C_G2309005 IS
        SELECT cod_usr_vida
          FROM G2309005
        WHERE cod_cia        = g_cod_cia
          AND cod_depto      = 'AU'
          AND mca_ren_poliza = 'S'
          AND mca_inh        = 'N'
        ORDER BY 1;
      --
      -- Buscar Ramos Caribian:
      CURSOR C_TA999003 IS
        SELECT TO_NUMBER(val_campo) val_campo
          FROM TA999003
        WHERE cod_cia   = g_cod_cia
          AND cod_campo = 'COD_RAMO_AUTOMOVIL'
          AND mca_inh   = 'N'
        ORDER BY 1;
      --
      -- Buscar ultima Fecha de Corrida, por Ramo:
      CURSOR C_g2109022 IS
        SELECT anio, mes
          FROM g2109022 a
        WHERE cod_cia  = g_cod_cia
          AND cod_ramo = g_cod_ramo
          AND fec_carga_inic IS NOT NULL
          AND fec_renovacion IS NOT NULL
          AND anio||mes = (SELECT MAX(anio||mes)
                              FROM g2109022 b
                            WHERE b.cod_cia        = a.cod_cia
                              AND b.cod_ramo       = a.cod_ramo
                              AND b.fec_carga_inic IS NOT NULL
                              AND b.fec_renovacion IS NOT NULL
                              AND b.mca_inh        = 'N'
                          )
            AND mca_inh  = 'N';
      --
      -- Verifica si existe el Mes :
      CURSOR C_g2109022_Mes IS
        SELECT 'S'
          FROM g2109022 a
        WHERE cod_cia  = g_cod_cia
          AND cod_ramo = g_cod_ramo
          AND anio     = g_anio
          AND mes      = g_mes
          AND fec_carga_inic IS NOT NULL
          AND fec_renovacion IS NULL
          AND anio||mes = (SELECT MAX(anio||mes)
                              FROM g2109022 b
                            WHERE b.cod_cia        = a.cod_cia
                              AND b.cod_ramo       = a.cod_ramo
                              AND b.fec_carga_inic IS NOT NULL
                              AND b.fec_renovacion IS NULL
                              AND b.mca_inh        = 'N'
                          )
            AND mca_inh  = 'N';
      --
      CURSOR cl_a2000500 IS
        SELECT DECODE(tip_situ, '3', 'Listas para Renovar      ',--V1.16 cejv  comillas
                                '4', 'Polizas con Errores      ',--V1.16 cejv  comillas
                                '6', 'Polizas Control Tecnico  ',--V1.16 cejv  comillas
                                    'Tipo Situs sin Definir   '||TIP_SITU) tip_situ,
                count(*) cantidad
          FROM a2000500
        WHERE fec_tratamiento = g_fec_tratamiento
          AND cod_cia         = g_cod_cia
          AND cod_ramo       IN (SELECT TO_NUMBER(val_campo) val_campo
                                    FROM TA999003
                                  WHERE cod_cia   = g_cod_cia
                                    AND cod_campo = 'COD_RAMO_AUTOMOVIL'
                                    AND mca_inh   = 'N'
                                )
        GROUP BY tip_situ
        ORDER BY 1;
      --
      reg_g2109022   g2109022_mrd%ROWTYPE;
      --
    BEGIN
      --
      -- Asignacion de valores:
      g_cod_cia        := 6;
      g_cod_agt        := NULL;
      g_tip_cuenta     := 21;
      g_mca_un_ramo    := 'N';
      --
      trn_k_global.asigna ( 'cod_idioma', 'ES' );
      trn_k_global.asigna ( 'COD_CIA', g_cod_cia );
      --
      -- Usuario que Renueva Auto: 7-May-14
      OPEN  C_G2309005;
      FETCH C_G2309005 INTO g_cod_usr;
      IF C_G2309005%FOUND THEN
          trn_k_global.asigna ('COD_USR', g_cod_usr);
      ELSE
          g_cod_usr := 'P0030991';  -- Donny
          trn_k_global.asigna ('COD_USR', 'P0030991');
      END IF;
      CLOSE C_G2309005;
      --
      -- M.R., Version : 1.01 (Buscar el nombre del ambiente)
      g_nom_ambiente := f_busca_ambiente;
      --
      -- Buscar los ramos a procesar:
      FOR I IN C_TA999003 LOOP
          --
          g_anio           := NULL;
          g_mes            := NULL;
          g_cod_ramo       := I.val_campo;
          l_mca_existe_mes := 'N';
          --
          -- Buscar Anio y Mes:
          OPEN  C_g2109022;
          FETCH C_g2109022 INTO g_anio, g_mes;
          CLOSE C_g2109022;
          --
          IF g_anio IS NOT NULL AND g_mes IS NOT NULL THEN
            --
            IF g_mes = 12 THEN
                g_anio := g_anio + 1;
                g_mes  := 1;
            ELSE
                g_mes  := g_mes + 1;
            END IF;
            --
            -- M.R., Version : 1.01 (Se agrega g_nom_ambiente)
            l_concat := chr(13)||chr(13)||'('||g_nom_ambiente||') '||'Archivo de Detalle para varios Ramos. Automatico : CONTROL-M'||chr(13)||chr(13);
            --
            g_fec_tratamiento := to_date( '01'|| LPAD( g_mes, 2, '0' ) || g_anio, 'ddmmyyyy' );
            g_cant_pre_renov  := 0;
            --
            p_carga_inicial_polizas;
            --
            g_total_pre_renov := g_total_pre_renov + g_cant_pre_renov;
            --
            -- Si se insertaron polizas, se incrementa el mes:
            IF g_cant_pre_renov > 0 THEN
                --
                -- Llenar los campos de la tabla:
                reg_g2109022.COD_CIA          := g_cod_cia;
                reg_g2109022.COD_RAMO         := g_cod_ramo;
                reg_g2109022.ANIO             := g_anio;
                reg_g2109022.MES              := g_mes;
                reg_g2109022.FEC_CARGA_INIC   := TRUNC(SYSDATE);
                reg_g2109022.FEC_RENOVACION   := NULL;
                reg_g2109022.MCA_CARGA_CRTL_M := 'S';
                reg_g2109022.MCA_CARGA_TAREA  := 'N';
                reg_g2109022.MCA_RENOV_CRTL_M := 'N';
                reg_g2109022.MCA_RENOV_TAREA  := 'N';
                reg_g2109022.MCA_RENOV_JAVA   := 'N';
                reg_g2109022.MCA_INH          := 'N';
                reg_g2109022.COD_USR          := USER;
                reg_g2109022.FEC_ACTU         := TRUNC(SYSDATE);
                --
                -- Buscar Anio y Mes:
                OPEN  C_g2109022_Mes;
                FETCH C_g2109022_Mes INTO l_mca_existe_mes;
                CLOSE C_g2109022_Mes;
                --
                -- Determina accion :
                IF l_mca_existe_mes = 'S' THEN
                  --
                  UPDATE g2109022
                    SET fec_carga_inic   = TRUNC(SYSDATE),
                        cod_usr          = USER,
                        mca_carga_crtl_m = 'S',
                        fec_actu         = TRUNC(SYSDATE)
                  WHERE cod_cia  = g_cod_cia
                    AND cod_ramo = g_cod_ramo
                    AND anio     = g_anio
                    AND mes      = g_mes;
                  --
                ELSE
                  --
                  p_inserta_g2109022(reg_g2109022);
                  --
                END IF;
                --
            END IF;
            --
          END IF;
          --
      END LOOP;
      --
      -- Envio de correo Errores de la Carga.
      --l_concat := l_concat||chr(13);
      l_concat := l_concat|| '                                                            -------------- '|| chr(13);
      l_concat := l_concat|| '                                                    Total : '||g_total_pre_renov|| chr(13);
      l_concat := l_concat||chr(13);
      l_concat := l_concat||chr(13);
      l_concat := l_concat|| '       ESTADO DE SITUACION         CANTIDAD  '|| chr(13);
      l_concat := l_concat|| '       --------------------------------        ---------------  '|| chr(13);
      --
      FOR I IN cl_a2000500 LOOP
        --
        l_concat := l_concat|| '       '|| I.Tip_Situ||'           '||I.Cantidad|| chr(13);
        --
      END LOOP;
      --
      l_concat := l_concat||chr(13);
      l_concat := l_concat||chr(13);
      l_concat := l_concat|| 'Favor de trabajar y/o verificar las polizazs Pre-Renovadas por CONTROL-M. Gracias.'|| chr(13);
      --
      -- Enviar el Correo:
      p_envia_correo_cargas(g_cod_cia,'PRERENO_AUT_AUTO',l_concat);
      --
    END p_carga_polizas_Ctl_M;
    --
    -- ----------------------------------------------------------------------
    -- Autor : Manuel Rod.                                    Version : 1.00
    -- Fecha : 19-Nov-13
    -- Nota  : Que se generen todos los ramos si el JBCOD_RAMO se deja nulo.
    --       : Se invoca a traves de la tarea (MRDEA00015).
    -- ----------------------------------------------------------------------
    PROCEDURE p_carga_polizas_tarea IS
      --
      -- Buscar Ramos Caribian:
      CURSOR C_TA999003 IS
      SELECT TO_NUMBER(val_campo) val_campo
        FROM TA999003
        WHERE cod_cia   = g_cod_cia
          AND cod_ramo  = NVL(g_cod_ramo, cod_ramo)
          AND cod_campo = 'COD_RAMO_AUTOMOVIL'
          AND mca_inh   = 'N'
      ORDER BY 1;
      --
      CURSOR cl_a2000500 IS
      SELECT DECODE(tip_situ, '1', 'No Procesada/Rechazada   ',   -- Fec. 17-Jun-15, Version : 1.03 ----V1.16 cejv  comillas
                              '3', 'Listas para Renovar      ',----V1.16 cejv  comillas
                              '4', 'Polizas con Errores      ',----V1.16 cejv  comillas
                              '6', 'Polizas Control Tecnico  ',----V1.16 cejv  comillas
                                  'Tipo Situs sin Definir   '||TIP_SITU) tip_situ,
              count(*) cantidad
        FROM a2000500
        WHERE fec_tratamiento = g_fec_tratamiento
          AND cod_cia         = g_cod_cia
          AND cod_ramo        = g_cod_rm   -- Version : 1.01
      GROUP BY tip_situ
      UNION
      SELECT DECODE(tip_situ, '1', 'No Procesada/Rechazada   ',   -- Fec. 17-Jun-15, Version : 1.03 --V1.16 cejv  comillas
                              '3', 'Listas para Renovar      ',--V1.16 cejv  comillas
                              '4', 'Polizas con Errores      ',--V1.16 cejv  comillas
                              '6', 'Polizas Control Tecnico  ',--V1.16 cejv  comillas
                                  'Tipo Situs sin Definir   '||TIP_SITU) tip_situ,
              count(*) cantidad
        FROM a2000500
        WHERE fec_tratamiento = g_fec_tratamiento
          AND cod_cia         = g_cod_cia
          AND g_cod_rm       IS NULL   -- Version : 1.01
          AND cod_ramo       IN (SELECT TO_NUMBER(val_campo) val_campo
                                  FROM TA999003
                                  WHERE cod_cia   = g_cod_cia
                                    AND cod_campo = 'COD_RAMO_AUTOMOVIL'
                                    AND mca_inh   = 'N')
      GROUP BY tip_situ
      ORDER BY 1;
      --
    BEGIN
      --
      -- Parametros de la Tarea : MRDEA00015
      g_cod_cia         := trn_k_global.devuelve('JBCOD_CIA');
      g_num_poliza      := trn_k_global.devuelve('JBNUM_POLIZA');
      g_cod_ramo        := trn_k_global.devuelve('JBCOD_RAMO');
      g_anio            := trn_k_global.devuelve('JBANIO');
      g_mes             := trn_k_global.devuelve('JBMES');
      g_cod_agt         := trn_k_global.devuelve('JBCOD_AGT');
      g_tip_cuenta      := trn_k_global.devuelve('TIP_CUENTA');
      g_tip_mvto_batch  := trn_k_global.devuelve('TIP_MVTO_BATCH');
      g_cod_usr         := trn_k_global.devuelve('JBCOD_USR');  -- Version : 1.17
      --
      g_cod_rm          := g_cod_ramo;  -- Version : 1.01
      --
      IF g_cod_usr IS NULL THEN -- Version : 1.17
        g_cod_usr := USER;  -- Version : 1.03
      END IF;
      --
      trn_k_global.asigna ('COD_USR', g_cod_usr);  -- Version : 1.03
      g_num_poliza_grupo := trn_k_global.devuelve('JBNUM_POLIZA_GRUPO'); -- Version : 1.03
      --
      -- M.R., Version : 1.01 (Buscar el nombre del ambiente)
      g_nom_ambiente := f_busca_ambiente;
      --
      IF g_cod_ramo IS NOT NULL THEN
          --
          -- M.R., Version : 1.01 (Se agrega g_nom_ambiente)
          l_concat := chr(13)||chr(13)||'('||g_nom_ambiente||') '||'Archivo de Detalle para el Ramo : '||g_Cod_Ramo||'  Tarea : MRDEA00015'||chr(13)||chr(13);
          g_mca_un_ramo := 'S';
          g_cant_pre_renov := 0; -- Fec. 1-Jul-15, Version : 1.03
          --
          p_carga_inicial_polizas;
          --
          g_total_pre_renov := g_cant_pre_renov;
          --
      ELSE
          --
          -- M.R., Version : 1.01 (Se agrega g_nom_ambiente)
          l_concat := chr(13)||chr(13)||'('||g_nom_ambiente||') '||'Archivo de Detalle para varios Ramos. Tarea : MRDEA00015'||chr(13)||chr(13);
          --
          g_mca_un_ramo := 'N';
          FOR I IN C_TA999003 LOOP
            --
            g_cod_ramo       := I.val_campo;
            g_cant_pre_renov := 0;
            trn_k_global.asigna('JBCOD_RAMO', g_cod_ramo);
            --
            p_carga_inicial_polizas;
            --
            g_total_pre_renov := g_total_pre_renov + g_cant_pre_renov;
            --
          END LOOP;
          --
      END IF;
      --
      IF g_total_pre_renov > 0 THEN
          IF g_mca_un_ramo = 'S' THEN
            trn_k_global.asigna( 'TXT_TAREA', 'CANTIDAD DE POLIZAS PRE-RENOVADAS, RAMO ('||g_cod_ramo||') CANT.: '||g_total_pre_renov );
          ELSE
            trn_k_global.asigna( 'TXT_TAREA', 'CANTIDAD DE POLIZAS PRE-RENOVADAS, CANTIDAD TOTAL : '||g_total_pre_renov );
          END IF;
      ELSE
          IF g_mca_un_ramo = 'S' THEN
            trn_k_global.asigna( 'TXT_TAREA', 'NO SE ENCONTRARON POLIZAS PARA PROCESAR, RAMO ('||g_cod_ramo||')' );
          ELSE
            trn_k_global.asigna( 'TXT_TAREA', 'NO SE ENCONTRARON POLIZAS PARA PROCESAR EN NINGUN RAMO, VERIFIQUE.' );
          END IF;
      END IF;
      --
      -- Envio de correo Errores de la Carga.
      --l_concat := l_concat||chr(13);
      l_concat := l_concat|| '                                                            -------------- '|| chr(13);
      l_concat := l_concat|| '                                                    Total : '||g_total_pre_renov|| chr(13);
      l_concat := l_concat||chr(13);
      l_concat := l_concat||chr(13);
      l_concat := l_concat|| '       ESTADO DE SITUACION         CANTIDAD  '|| chr(13);
      l_concat := l_concat|| '       --------------------------------        ---------------  '|| chr(13);
      --
      FOR I IN cl_a2000500 LOOP
        --
        l_concat := l_concat|| '       '|| I.Tip_Situ||'           '||I.Cantidad|| chr(13);
        --
      END LOOP;
      --
      l_concat := l_concat||chr(13);
      l_concat := l_concat||chr(13);
      l_concat := l_concat|| 'Favor de trabajar y/o verificar las polizazs Pre-Renovadas. Gracias.'|| chr(13);
      --
      -- Enviar el Correo:
      p_envia_correo_cargas(g_cod_cia,'PRERENO_AUT_AUTO', l_concat);
      --
    END p_carga_polizas_tarea;
    --
    -- ----------------------------------------------------------------------
    -- Autor : Manuel Rod.                                    Version : 1.00
    -- Fecha : 19-Sep-14
    -- Nota  : Se encarga de ejecutar la 2da Carga; pero ya desde la tabla
    --       : A2109010_MRD, que se invoca desde la tarea (MRDEA00017).
    -- ----------------------------------------------------------------------
    PROCEDURE p_carga_polizas_tarea_2da IS
      --
      -- Buscar Ramos Caribian:
      CURSOR C_TA999003 IS
        SELECT TO_NUMBER(val_campo) val_campo
          FROM TA999003
        WHERE cod_cia   = g_cod_cia
          AND cod_ramo  = NVL(g_cod_ramo, cod_ramo)
          AND cod_campo = 'COD_RAMO_AUTOMOVIL'
          AND mca_inh   = 'N'
        ORDER BY 1;
      --
      CURSOR cl_a2000500 IS
        SELECT DECODE(tip_situ, '1', 'No Procesada/Rechazada   ',   -- Fec. 17-Jun-15, Version : 1.03 --V1.16 cejv  comillas
                                '3', 'Listas para Renovar      ',--V1.16 cejv  comillas
                                '4', 'Polizas con Errores      ',--V1.16 cejv  comillas
                                '6', 'Polizas Control Tecnico  ',--V1.16 cejv  comillas
                                    'Tipo Situs sin Definir   '||TIP_SITU) tip_situ,
                count(*) cantidad
          FROM a2000500
        WHERE fec_tratamiento = g_fec_tratamiento
          AND cod_cia         = g_cod_cia
          AND cod_ramo        = g_cod_rm   -- Version : 1.01
          AND tip_mvto_batch  = 2   -- Version : 1.01
        GROUP BY tip_situ
        UNION
        SELECT DECODE(tip_situ, '1', 'No Procesada/Rechazada   ',   -- Fec. 17-Jun-15, Version : 1.03 --V1.16 cejv  comillas
                                '3', 'Listas para Renovar      ',--V1.16 cejv  comillas
                                '4', 'Polizas con Errores      ',--V1.16 cejv  comillas
                                '6', 'Polizas Control Tecnico  ',--V1.16 cejv  comillas
                                    'Tipo Situs sin Definir   '||TIP_SITU) tip_situ,
                count(*) cantidad
          FROM a2000500
        WHERE fec_tratamiento = g_fec_tratamiento
          AND cod_cia         = g_cod_cia
          AND g_cod_rm       IS NULL   -- Version : 1.01
          AND cod_ramo       IN (SELECT TO_NUMBER(val_campo) val_campo
                                    FROM TA999003
                                  WHERE cod_cia   = g_cod_cia
                                    AND cod_campo = 'COD_RAMO_AUTOMOVIL'
                                    AND mca_inh   = 'N'
                                )
          AND tip_mvto_batch  = 2   -- Version : 1.01
        GROUP BY tip_situ
        ORDER BY 1;
      --
    BEGIN
      --
      -- Parametros de la Tarea : MRDEA00017
      g_cod_cia         := trn_k_global.devuelve('JBCOD_CIA');
      g_num_poliza      := trn_k_global.devuelve('JBNUM_POLIZA');
      g_cod_ramo        := trn_k_global.devuelve('JBCOD_RAMO');
      g_anio            := trn_k_global.devuelve('JBANIO');
      g_mes             := trn_k_global.devuelve('JBMES');
      g_cod_agt         := trn_k_global.devuelve('JBCOD_AGT');
      g_tip_cuenta      := trn_k_global.devuelve('TIP_CUENTA');
      g_tip_mvto_batch  := trn_k_global.devuelve('TIP_MVTO_BATCH');
      g_cod_usr         := trn_k_global.devuelve('JBCOD_USR');  -- Version : 1.17
      --
      g_cod_rm          := g_cod_ramo;  -- Version : 1.01
      --
      IF g_cod_usr IS NULL THEN -- Version : 1.17
        g_cod_usr := USER;  -- Version : 1.03
      END IF;
      --
      trn_k_global.asigna ('COD_USR', g_cod_usr);  -- Version : 1.03
      g_num_poliza_grupo := trn_k_global.devuelve('JBNUM_POLIZA_GRUPO'); -- Version : 1.03
      --
      g_fec_tratamiento := to_date( '01'|| LPAD( g_mes, 2, '0' ) || g_anio, 'ddmmyyyy' );
      --
      -- M.R., Version : 1.01 (Buscar el nombre del ambiente)
      g_nom_ambiente := f_busca_ambiente;
      --
      IF g_cod_ramo IS NOT NULL THEN
          --
          -- M.R., Version : 1.01 (Se agrega g_nom_ambiente)
          l_concat := chr(13)||chr(13)||'('||g_nom_ambiente||') '||'Archivo de Detalle para el Ramo : '||g_Cod_Ramo||'  Tarea : MRDEA00017'||chr(13)||chr(13);
          g_mca_un_ramo  := 'S';
          g_cant_pol_act := 0;
          --
          p_carga_inicial_polizas_2da;
          g_total_pol_act := g_cant_pol_act;
          --
      ELSE
          --
          -- M.R., Version : 1.01 (Se agrega g_nom_ambiente)
          l_concat := chr(13)||chr(13)||'('||g_nom_ambiente||') '||'Archivo de Detalle para varios Ramos. Tarea : MRDEA00017'||chr(13)||chr(13);
          --
          g_mca_un_ramo := 'N';
          FOR I IN C_TA999003 LOOP
            --
            g_cod_ramo     := I.val_campo;
            g_cant_pol_act := 0;
            trn_k_global.asigna('JBCOD_RAMO', g_cod_ramo);
            --
            p_carga_inicial_polizas_2da;
            --
            g_total_pol_act := g_total_pol_act + g_cant_pol_act;
            --
          END LOOP;
          --
      END IF;
      --
      IF g_total_pol_act > 0 THEN
          IF g_mca_un_ramo = 'S' THEN
            trn_k_global.asigna( 'TXT_TAREA', 'CANTIDAD DE POLIZAS PRE-RENOVADAS, RAMO ('||g_cod_ramo||') CANT.: '||g_total_pol_act );
          ELSE
            trn_k_global.asigna( 'TXT_TAREA', 'CANTIDAD DE POLIZAS PRE-RENOVADAS, CANTIDAD TOTAL : '||g_total_pol_act );
          END IF;
      ELSE
          IF g_mca_un_ramo = 'S' THEN
            trn_k_global.asigna( 'TXT_TAREA', 'NO SE ENCONTRARON POLIZAS PARA PROCESAR, RAMO ('||g_cod_ramo||')' );
          ELSE
            trn_k_global.asigna( 'TXT_TAREA', 'NO SE ENCONTRARON POLIZAS PARA PROCESAR EN NINGUN RAMO, VERIFIQUE.' );
          END IF;
      END IF;
      --
      -- Envio de correo Errores de la Carga.
      --l_concat := l_concat||chr(13);
      l_concat := l_concat|| '                                                            -------------- '|| chr(13);
      l_concat := l_concat|| '                                                    Total : '||g_total_pol_act|| chr(13);
      l_concat := l_concat||chr(13);
      l_concat := l_concat||chr(13);
      l_concat := l_concat|| '       ESTADO DE SITUACION         CANTIDAD  '|| chr(13);
      l_concat := l_concat|| '       --------------------------------        ---------------  '|| chr(13);
      --
      FOR I IN cl_a2000500 LOOP
        --
        l_concat := l_concat|| '       '|| I.Tip_Situ||'           '||I.Cantidad|| chr(13);
        --
      END LOOP;
      --
      l_concat := l_concat||chr(13);
      l_concat := l_concat||chr(13);
      l_concat := l_concat|| 'Favor de trabajar y/o verificar las polizazs Pre-Renovadas, 2da Carga. Gracias.'|| chr(13);
      --
      -- Enviar el Correo:
      p_envia_correo_cargas(g_cod_cia, 'PRERENO_AUT_AUTO', l_concat);
      --
    END p_carga_polizas_tarea_2da;
    --
    -- -------------------------------------------------------------------------
    -- Modifica : Manuel Rodriguez                               Version : 1.00
    -- Fecha    : 26-Sep-14
    -- Nota     : Se encarga de realizar la 2da Carga, que es actualizar los
    --          : valores con las nuevas reglas, Tarea MRDEA00017, si la poliza
    --          : no genero errores, en la tabla A2000520.
    -- -------------------------------------------------------------------------
    PROCEDURE p_carga_inicial_polizas_2da IS
      --
      CURSOR cl_a2009030 IS
        SELECT *
          FROM a2009030 a
        WHERE cod_ramo    = g_cod_ramo
          AND mes         = g_mes
          AND anio        = g_anio
          AND num_poliza  = NVL(g_num_poliza, num_poliza)
          AND (num_poliza_grupo = g_Num_Poliza_Grupo OR g_Num_Poliza_Grupo IS NULL) -- Version : 1.03
          AND tip_estatus NOT IN (4,5,6) -- Version : 1.01, Fec.: 28-May-15 Version : 1.03 (4)
          AND NOT EXISTS (SELECT 1
                            FROM a2000520 b
                            WHERE b.fec_tratamiento = a.fec_tratamiento  -- Version : 1.01
                              AND b.num_poliza      = a.num_poliza
                          )
          AND EXISTS (SELECT 1   -- Version : 1.01 (Para que el EM_K_BATCH_TRN, no cancele, deja TIP_SITU=7)
                        FROM r2000030 c
                        WHERE c.cod_cia    = g_cod_cia
                          AND c.num_poliza = a.num_poliza
                      )
          AND EXISTS (SELECT 1   -- Version : 1.01 (Que exista la 1ra. Regla)
                        FROM a2109013 d
                        WHERE d.cod_cia        = g_cod_cia
                          AND d.cod_ramo       = a.cod_ramo
                          AND d.num_poliza     = a.num_poliza
                          AND d.anio           = a.anio
                          AND d.mes            = a.mes
                          AND d.mca_prim_carga = 'S'
                      )
          AND NOT EXISTS (SELECT 1        -- Version : 1.03 Fec. 11-Jun-15
                            FROM a2000500 f
                            WHERE f.fec_tratamiento = a.fec_tratamiento
                              AND f.num_poliza      = a.num_poliza
                              AND f.tip_situ        = '4'
                          ) -- Error en Poliza ----V1.16 cejv  comillas
          AND NOT EXISTS (SELECT 1    -- Fec.: 28-May-15, Version : 1.03 (Que no este autorizada)
                            FROM g2000210 g,
                                r2000221 f
                          WHERE f.cod_cia    = a.cod_cia    -- Version: 1.11
                            AND f.num_poliza = a.num_poliza
                            AND f.num_spto   = (SELECT MAX (b.num_spto) + 1    -- Version: 1.11
                                                  FROM a2000030 b
                                                  WHERE b.cod_cia    = a.cod_cia
                                                    AND b.num_poliza = a.num_poliza
                                                )
                            AND f.fec_autorizacion IS NOT NULL
                            AND f.mca_autorizacion = 'S'
                            AND g.cod_cia     = f.cod_cia
                            AND g.cod_error   = f.cod_error
                            AND g.tip_rechazo = '3'
                          );  -- De Auditoria
      --
      CURSOR cl_a2109010  (p_num_poliza   a2000030.num_poliza%TYPE) IS
        SELECT cod_cia, cod_ramo, num_poliza, num_riesgo, anio, mes, fec_tratamiento
          FROM a2109010
        WHERE cod_cia    = g_Cod_Cia
          AND num_poliza = p_Num_Poliza
          AND anio       = g_Anio
          AND mes        = g_Mes;
      --
      CURSOR cl_a2109010_pr  (p_num_poliza   a2000030.num_poliza%TYPE) IS
        SELECT SUM(prima_preren)
          FROM a2109010
        WHERE cod_cia    = g_Cod_Cia
          AND num_poliza = p_Num_Poliza
          AND anio       = g_Anio
          AND mes        = g_Mes;
      --
      CURSOR cl_a2109013_sp  (p_num_poliza   a2000030.num_poliza%TYPE) IS
        SELECT 'S'
          FROM a2109011 b,
              a2109013 a
        WHERE a.cod_cia    = g_Cod_Cia
          AND a.num_poliza = p_Num_Poliza
          AND a.anio       = g_Anio
          AND a.mes        = g_Mes
          --
          AND b.cod_cia         = a.cod_cia
          AND b.anio            = a.anio
          AND b.mes             = a.mes
          AND b.num_regla       = a.num_regla
          AND b.num_version     = a.num_version
          AND b.mca_suscripcion = 'S';
      --
      -- Fec. 26-May-15, Version : 1.03
      CURSOR cl_a2000500  (p_num_poliza   a2000030.num_poliza%TYPE) IS
        SELECT tip_situ
          FROM a2000500
        WHERE cod_cia         = g_Cod_Cia
          AND num_poliza      = p_Num_Poliza
          AND fec_tratamiento = g_fec_tratamiento;
      --
      l_total_prima_preren     a2109010.prima_preren%TYPE := 0;
      l_pend_suscripcion       VARCHAR2(1) := 'N';
      l_txt_error_ct           A2109010.txt_error_ct%TYPE;  -- Version : 1.03
      l_txt_error_pol          A2109010.txt_error_pol%TYPE;  -- Version : 1.03
      l_tip_situ               A2000500.Tip_Situ%TYPE;  -- Version : 1.03
      --
    BEGIN
      --
      trn_k_global.asigna('mca_ter_tar','N');  -- Version : 1.02
      --
      FOR I IN cl_a2009030 LOOP
        --
        g_cant_regla_poliza := 0;  -- Version : 1.02
        g_num_orden         := I.num_orden;  -- Version : 1.03
        --
        FOR X IN cl_a2109010 (I.num_poliza) LOOP
          --
          -- Declarar las variables de la AA2009030_MRD:
          ea_k_genera_globales.p_limpiar_valores;
          ea_k_genera_globales.p_limpiar_tablas;
          --
          ea_k_genera_globales.p_add_tables ( 'A2009030_MRD', 'TRON2000' );
          --
          ea_k_genera_globales.p_buscar_valores( 'cod_cia'      , X.cod_cia );
          ea_k_genera_globales.p_buscar_valores( 'num_poliza'   , X.num_poliza );
          ea_k_genera_globales.p_buscar_valores( 'anio'         , X.anio );
          ea_k_genera_globales.p_buscar_valores( 'mes'          , X.mes );
          --
          ea_k_genera_globales.p_genera_globales();
          --
          -- Declarar las variables de la A2109010_MRD:
          ea_k_genera_globales.p_limpiar_valores;
          ea_k_genera_globales.p_limpiar_tablas;
          --
          ea_k_genera_globales.p_add_tables ( 'A2109010_MRD', 'TRON2000' );
          --
          ea_k_genera_globales.p_buscar_valores( 'cod_cia'      , X.cod_cia );
          ea_k_genera_globales.p_buscar_valores( 'num_poliza'   , X.num_poliza );
          ea_k_genera_globales.p_buscar_valores( 'num_riesgo'   , X.num_riesgo );
          ea_k_genera_globales.p_buscar_valores( 'anio'         , X.anio );
          ea_k_genera_globales.p_buscar_valores( 'mes'          , X.mes );
          --
          ea_k_genera_globales.p_genera_globales();
          --
          g_cant_regla_aplicada := 0;
          p_aplica_reglas( g_cod_cia, 'A2109010_MRD',  0, g_cod_ramo, g_mes, g_anio, g_cant_regla_aplicada );
          --
          g_cant_regla_poliza := g_cant_regla_poliza + g_cant_regla_aplicada;
          --
        END LOOP;
        --
        l_pend_suscripcion := 'N';
        --
        -- Verifica si la Regla aplicada debe ir a Suscripcion
        OPEN  cl_a2109013_sp (I.Num_Poliza);
        FETCH cl_a2109013_sp INTO l_pend_suscripcion;
        CLOSE cl_a2109013_sp;
        --
        -- Buscar el totar de Prima PreRen:
        l_total_prima_preren := 0;
        OPEN  cl_a2109010_pr (I.Num_Poliza);
        FETCH cl_a2109010_pr INTO l_total_prima_preren;
        CLOSE cl_a2109010_pr;
        --
        IF l_pend_suscripcion = 'S' THEN
            --
            UPDATE a2009030
              SET prima_preren = l_total_prima_preren,
                  tip_estatus  = 2   -- Pendiente Suscripcion
            WHERE num_poliza  = I.num_poliza
              AND mes         = g_mes
              AND anio        = g_anio;
        ELSE
            --
            UPDATE a2009030
              SET prima_preren = l_total_prima_preren
            WHERE num_poliza  = I.num_poliza
              AND mes         = g_mes
              AND anio        = g_anio;
        END IF;
        --
        IF g_cant_regla_poliza > 0 THEN
            g_cant_pol_act := g_cant_pol_act + 1;
            --
            -- M.R., Fec. 22-Abr-15, Version : 1.03 (Movido dentro del IF)
            p_limpia_tablas_r ( g_cod_cia,
                                I.cod_ramo,
                                I.num_poliza,
                                I.fec_tratamiento,
                                I.num_orden );
            --
            p_carga_tablas_r ( g_cod_cia,
                              I.cod_ramo,
                              I.num_poliza,
                              I.fec_tratamiento,
                              I.num_orden );
            --
            -- Buscar el nuevo valor de TIP_SITU. Version : 1.03
            OPEN  cl_a2000500 (I.Num_Poliza);
            FETCH cl_a2000500 INTO l_tip_situ;
            CLOSE cl_a2000500;
            --
            -- Actualizar errores, si existen. Fec. 25-May-15, Version : 1.03
            IF l_tip_situ IN ('4','6') THEN ----V1.16 cejv  comillas
              --
              FOR X IN cl_a2109010 (I.num_poliza) LOOP
                --
                -- Buscar los Controles Tecnicos, por cada riesgo:
                l_txt_error_ct := NULL;
                IF l_tip_situ = '6' THEN --V1.16 cejv  comillas
                    l_txt_error_ct := f_trae_error_CT(g_cod_cia,
                                                      I.num_poliza,
                                                      X.num_riesgo);
                    --
                    IF l_txt_error_ct IS NOT NULL THEN
                      UPDATE a2109010
                          SET txt_error_ct  = l_txt_error_ct
                        WHERE cod_cia     = g_cod_cia
                          AND num_poliza  = I.num_poliza
                          AND num_riesgo  = X.num_riesgo
                          AND anio        = g_anio
                          AND mes         = g_mes;
                    END IF;
                    --
                END IF;
                --
                -- Buscar los Errores a nievel de Polizas:
                l_txt_error_pol := NULL;
                IF l_tip_situ = '4' THEN --V1.16 cejv  comillas
                    l_txt_error_pol := f_trae_error_POL(g_fec_tratamiento,
                                                        g_num_orden,
                                                        g_tip_mvto_batch,
                                                        g_cod_cia,
                                                        I.num_poliza,
                                                        X.num_riesgo);
                    --
                    IF l_txt_error_pol IS NOT NULL THEN
                      UPDATE a2109010
                          SET txt_error_pol = l_txt_error_pol
                        WHERE cod_cia     = g_cod_cia
                          AND num_poliza  = I.num_poliza
                          AND num_riesgo  = X.num_riesgo
                          AND anio        = g_anio
                          AND mes         = g_mes;
                    END IF;
                    --
                END IF;
                --
              END LOOP;
              --
            END IF;  -- Fin I.tip_situ
            --
        END IF;
        --
      END LOOP;
      --
      IF g_cant_pol_act > 0 THEN
          -- Fec. 11-Jun-15, Version : 1.03
          IF g_num_poliza_grupo IS NOT NULL THEN  -- Version : 1.13 (Mejora)
            l_concat := l_concat|| '       Ramo : '|| g_Cod_Ramo||'    Cantidad Polizas : '||g_cant_pol_act||'   Poliza Grupo : '||g_num_poliza_grupo|| chr(13);
          ELSIF g_num_poliza IS NOT NULL THEN  -- Version : 1.13 (Mejora)
            l_concat := l_concat|| '       Ramo : '|| g_Cod_Ramo||'    Cantidad Polizas : '||g_cant_pol_act||'   Poliza : '||g_num_poliza|| chr(13);
          ELSE
            l_concat := l_concat|| '       Ramo : '|| g_Cod_Ramo||'    Cantidad Polizas : '||g_cant_pol_act|| chr(13);
          END IF;
      END IF;
      --
      trn_k_global.asigna('mca_ter_tar','S');  -- Version : 1.02
      --
    END p_carga_inicial_polizas_2da;
    --
    -- -------------------------------------------------------------------------
    -- Modifica : Manuel Rodriguez                               Version : 1.00
    -- Fecha    : 19-Nov-13
    -- Nota     : Que se generen todos los ramos si el JBCOD_RAMO se deja nulo.
    -- -------------------------------------------------------------------------
    PROCEDURE p_carga_inicial_polizas IS
        --
        l_fec_vcto_poliza        DATE;
        l_num_renovaciones       a2000030.num_renovaciones   %TYPE;
        l_num_presupuesto        a2000030.num_presupuesto    %TYPE;
        l_nom_coaseguro          VARCHAR2(11);  -- Version : 1.03
        --
        reg_s2000031             s2000031                    %ROWTYPE;
        reg_a2000500             a2000500                    %ROWTYPE;
        --
        -- Polizas a trabajar:
        -- M.R., Fec. 24-Abr-15, Version : 1.03 (Se re-organizo y se quitaron espacios)
        CURSOR cl_a2000030 IS
          SELECT g_fec_tratamiento fec_tratamiento, g_num_orden num_orden, l_tip_mvto_batch tip_mvto_batch, cod_cia,
                cod_sector, a.cod_ramo, a.cod_nivel1, cod_nivel2, cod_nivel3, cod_agt, tip_docum, cod_docum,
                cod_mon, cod_fracc_pago, num_poliza, num_presupuesto, num_spto, num_apli,
                num_spto_apli, a.tip_poliza_tr, mca_prima_manual, fec_vcto_poliza, fec_vcto_spto,
                num_renovaciones, 1 tip_situ, 'N' mca_pre_renovacion, 'N' mca_anulacion_por_deuda, cod_usr,
                trunc( SYSDATE ) fec_actu, 999 cod_spto, 3 sub_cod_spto, cod_cuadro_com,
                tip_gestor, cod_gestor, num_riesgos, num_poliza_grupo, num_contrato,
                tip_coaseguro, fec_efec_poliza  -- Version : 1.03
            FROM a2000030 a
           WHERE cod_cia            = g_Cod_Cia
             AND cod_ramo           = NVL(g_Cod_Ramo, cod_ramo)
             AND num_poliza         = NVL(g_Num_Poliza, a.num_poliza)
             AND (num_poliza_grupo  = g_Num_Poliza_Grupo OR g_Num_Poliza_Grupo IS NULL) -- Version : 1.03
             AND mca_poliza_anulada = 'N'
             AND fec_vcto_poliza BETWEEN g_start_date AND g_end_date
             AND num_spto           = ( SELECT MAX ( b.num_spto )
                                          FROM a2000030 b
                                         WHERE b.cod_cia          = a.cod_cia
                                           AND b.num_poliza       = a.num_poliza
                                           AND b.mca_spto_anulado = 'N'
                                           AND b.mca_spto_tmp     = 'N' 
                                      )
             AND num_poliza    NOT IN ( SELECT c.num_poliza
                                          FROM a2000031 c
                                         WHERE c.cod_cia          = a.cod_cia
                                           AND c.num_poliza       = a.num_poliza
                                           AND c.mca_baja_riesgo  = 'N'
                                           AND c.mca_vigente      = 'S'
                                         GROUP BY c.num_poliza 
                                         HAVING COUNT( * ) > g_max_riesgo_ind 
                                      ) -- Version : 1.03
             --
             AND NOT EXISTS (SELECT 1    -- Fec.: 28-May-15, Version : 1.03
                               FROM a2990016 d,
                                    a2109010 h  -- Fec. 9-Jul-15 (OFIC0)
                              WHERE h.cod_cia     = a.cod_cia
                                AND h.num_poliza  = a.num_poliza
                                AND h.anio        = g_anio
                                AND h.mes         = g_mes
                                AND h.num_riesgo  = (SELECT MIN(j.num_riesgo) -- Fec. 9-Jul-15 (OFIC0)
                                                      FROM a2109010 j
                                                     WHERE j.cod_cia    = h.cod_cia
                                                       AND j.num_poliza = h.num_poliza
                                                       AND j.anio       = h.anio
                                                       AND j.mes        = h.mes
                                                    )
                                --
                                AND d.cod_cia     = h.cod_cia
                                AND d.num_poliza  = h.num_poliza
                                AND d.num_spto    = a.num_spto + 1
                                AND d.fec_mvto   >= TRUNC(h.fec_actu) -- Fec. 9-Jul-15 (OFIC0)
                                AND d.mca_rechazo = 'S'
                            )  -- Rechazada por Cobros
             --
             AND NOT EXISTS (SELECT 1    -- Fec.: 28-May-15, Version : 1.03
                               FROM a2009030 f
                              WHERE f.num_poliza  = a.num_poliza
                                AND f.mes         = g_mes
                                AND f.anio        = g_anio
                                AND f.tip_estatus = 4
                            )  -- No Renovar
             --
             AND NOT EXISTS (SELECT 1    -- Fec.: 28-May-15, Version : 1.03
                               FROM g2000210 g,
                                    r2000221 f
                              WHERE f.cod_cia    = a.cod_cia
                                AND f.num_poliza = a.num_poliza
                                AND f.num_spto   = (SELECT MAX (b.num_spto) + 1    -- Version: 1.11
                                                      FROM a2000030 b
                                                     WHERE b.cod_cia    = a.cod_cia
                                                      AND b.num_poliza = a.num_poliza
                                                   )
                                AND f.fec_autorizacion IS NOT NULL
                                AND f.mca_autorizacion = 'S'
                                AND g.cod_cia     = f.cod_cia
                                AND g.cod_error   = f.cod_error
                                AND g.tip_rechazo = '3'
                            )  -- De Auditoria
             --AND rownum <= 15 -- Solo, para pruebas. Version : 1.17
             --
             ORDER BY num_poliza;
        --
        reg_a2000030 cl_a2000030%ROWTYPE;
        --
        FUNCTION f_dato_variable ( l_cod_campo g2000020.cod_campo%TYPE ) RETURN VARCHAR2 IS
          --
          TYPE cursor_variable IS REF CURSOR;
          cl_s2000020_03 CURSOR_VARIABLE;
          --
          l_val_campo     A2000020.VAL_CAMPO%TYPE;
          --
        BEGIN
          --
          -- Buscar Modalidad:
          OPEN cl_s2000020_03 FOR
                ' SELECT a.val_campo '                              || chr( 13 ) ||
                '   FROM a2000020_'||reg_s2000031.cod_ramo || ' a ' || chr( 13 ) ||
                '  WHERE a.num_poliza         = :num_poliza '        || chr( 13 ) ||
                '     AND a.cod_cia           = :cod_cia '           || chr( 13 ) ||
                '     AND a.num_riesgo       = :num_riesgo '        || chr( 13 ) ||
                '     AND a.mca_vigente       = ''S'' '              || chr( 13 ) ||
                '     AND a.mca_vigente_apli = ''S'' '              || chr( 13 ) ||
                '     AND a.mca_baja_riesgo   = ''N'' '              || chr( 13 ) ||
                '     AND a.num_apli         = 0 '                  || chr( 13 ) ||
                '     AND a.num_spto_apli    = 0 '                  || chr( 13 ) ||
                '     AND a.cod_campo        = :cod_campo '
            USING reg_s2000031.num_poliza,reg_s2000031.cod_cia,
                  reg_s2000031.num_riesgo, l_cod_campo;
          FETCH cl_s2000020_03 INTO l_val_campo;
          CLOSE cl_s2000020_03;
          --
          RETURN l_val_campo;
          --
        END f_dato_variable;
        --
        PROCEDURE p_elimina_poliza IS
        BEGIN
          --
          -- Tablas de Buzones:
          DELETE FROM s2000020 a /* TABLA DE DATOS VARIABLES */
                WHERE a.fec_tratamiento  = reg_a2000500.fec_tratamiento
                  AND a.tip_mvto_batch   IN (1,2)
                  AND a.cod_cia          = reg_a2000500.cod_cia
                  AND a.cod_ramo         = reg_a2000500.cod_ramo
                  AND a.num_poliza       = reg_a2000500.num_poliza;
          --
          DELETE FROM s2000030 a /* TABLA DE DATOS FIJOS DE POLIZAS */
                WHERE a.fec_tratamiento  = reg_a2000500.fec_tratamiento
                  AND a.tip_mvto_batch   IN (1,2)
                  AND a.num_poliza       = reg_a2000500.num_poliza
                  AND a.cod_cia          = reg_a2000500.cod_cia
                  AND a.cod_ramo         = reg_a2000500.cod_ramo;
          --
          DELETE FROM s2000031 a /* TABLA DE RIESGOS */
                WHERE a.fec_tratamiento  = reg_a2000500.fec_tratamiento
                  AND a.tip_mvto_batch   IN (1,2)
                  AND a.cod_cia          = reg_a2000500.cod_cia
                  AND a.cod_ramo         = reg_a2000500.cod_ramo
                  AND a.num_poliza       = reg_a2000500.num_poliza;
          --
          DELETE FROM s2000040 a /* CONTRATA/DESCARTA COBERTURAS EN PROCEOS MASIVOS */
                WHERE a.fec_tratamiento  = reg_a2000500.fec_tratamiento
                  AND a.tip_mvto_batch   IN (1,2)
                  AND a.cod_cia          = reg_a2000500.cod_cia
                  AND a.num_poliza       = reg_a2000500.num_poliza;
          --
          DELETE FROM s2000060 a /* TABLA DE TIPOS DE TERCERO */
                WHERE a.fec_tratamiento  = reg_a2000500.fec_tratamiento
                  AND a.tip_mvto_batch   IN (1,2)
                  AND a.num_poliza       = reg_a2000500.num_poliza;
          --
          DELETE FROM s2000260 a /* TABLA DE TEXTOS POR POLIZA */
                WHERE a.fec_tratamiento  = reg_a2000500.fec_tratamiento
                  AND a.tip_mvto_batch   IN (1,2)
                  AND a.cod_cia          = reg_a2000500.cod_cia
                  AND a.num_poliza       = reg_a2000500.num_poliza;
          --
          -- Tablas Reales:
          DELETE FROM a2000500  /* POLIZAS PARA PROCESOS MASIVOS */
                WHERE fec_tratamiento  = reg_a2000500.fec_tratamiento
                  AND num_poliza       = reg_a2000500.num_poliza
                  AND tip_mvto_batch   IN (1,2)
                  AND cod_cia          = reg_a2000500.cod_cia
                  AND cod_ramo         = reg_a2000500.cod_ramo;
          --
          DELETE FROM A2009030 /* TABLA DE REGISTRO PARA LAS POLIZAS PENDIENTES DE COBROS */
                WHERE num_poliza = reg_a2000500.num_poliza
                  AND mes        = g_Mes
                  AND anio       = g_Anio;
          --
          DELETE FROM a2109010 /* TABLA DE REGISTRO PARA LA RENOVACION AUTOMATICA DE AUTOMOVIL */
                WHERE cod_cia    = reg_a2000500.cod_cia
                AND num_poliza = reg_a2000500.num_poliza
                AND mes        = g_Mes
                AND anio       = g_Anio;
          --
          -- Borrar Reglas por poliza. Fec. 25-May-15, Version : 1.03
          DELETE FROM a2109013
                WHERE cod_cia    = reg_a2000500.cod_cia
                  AND num_poliza = reg_a2000500.num_poliza
                  AND mes        = g_Mes
                  AND anio       = g_Anio;
          --
        END p_elimina_poliza;
        --
        PROCEDURE p_elimina_orden IS
        BEGIN
          --
          /* DELETE FROM g2000510 a  -- Fec. 12-Ene-15 (Que no lo borre)
                  WHERE a.fec_tratamiento = g_fec_tratamiento
                    AND a.num_orden      IN ( SELECT UNIQUE b.num_orden
                                                FROM a2000500 b
                                                WHERE b.fec_tratamiento = g_fec_tratamiento
                                                  AND b.cod_ramo        = NVL(g_Cod_Ramo, b.cod_ramo)
                                                  AND b.tip_mvto_batch IN ( l_tip_mvto_batch, l_tip_pre_renovacion )
                                            )
                    AND a.tip_mvto_batch IN ( l_tip_mvto_batch, l_tip_pre_renovacion );
          */
          --
          DELETE FROM a2000520 a
                WHERE a.fec_tratamiento = g_fec_tratamiento
                  AND a.num_orden      IN ( SELECT UNIQUE b.num_orden
                                              FROM a2000500 b
                                            WHERE b.fec_tratamiento = g_fec_tratamiento
                                              AND b.cod_ramo        = NVL(g_Cod_Ramo, b.cod_ramo)
                                              AND b.num_poliza      = NVL(g_num_poliza, b.num_poliza)
                                              AND b.tip_mvto_batch   IN ( l_tip_mvto_batch, l_tip_pre_renovacion )
                                          )
                  AND a.tip_mvto_batch IN ( l_tip_mvto_batch, l_tip_pre_renovacion )
                  AND a.num_poliza      = NVL(g_num_poliza, a.num_poliza);
          --
        END p_elimina_orden;
        --
        FUNCTION p_mod_p2000030_corredor( pCodAgt a2000030.cod_agt%TYPE, 
                                              pFechaFin a2000030.fec_vcto_poliza%TYPE ) RETURN DATE IS
              --
              CURSOR cl_g2109021 IS
                SELECT cod_agt
                  FROM g2109021
                WHERE cod_agt = pCodAgt;
              --
              Reg_Corredor cl_g2109021               %ROWTYPE;
              UltDia       a2000030.fec_vcto_poliza  %TYPE;
              Fecha        DATE;
            --
        BEGIN
            --
              Fecha := Add_Months ( pFechaFin, 12 );
              --
              OPEN  cl_g2109021;
              FETCH cl_g2109021 INTO Reg_Corredor;
              IF cl_g2109021%FOUND THEN
                UltDia := Last_Day ( Fecha );
                IF extract ( DAY FROM Fecha ) < 15 THEN
                  Fecha := UltDia - ( extract ( DAY FROM UltDia ) + 0 );
                ELSE
                  Fecha := UltDia;
                END IF;
              END IF;
              CLOSE cl_g2109021;
              --
              RETURN Fecha;
              --
        END p_mod_p2000030_corredor;
        --
        PROCEDURE p_inserta_a2000500 IS
              --
              l_mes_proceso        VARCHAR2 ( 4 );
              l_cod_tip_spto       a2000500.cod_tip_spto%TYPE := 1;
              --
              -- Buscar el COD_SPTO del ramo:
              CURSOR CR_G2999005 (p_cod_cia   A2000030.COD_CIA%TYPE,
                                  p_cod_ramo  A2000030.COD_RAMO%TYPE) IS
              SELECT cod_spto, sub_cod_spto
                FROM G2999005
              WHERE cod_cia  = p_cod_cia
                AND cod_ramo = p_cod_ramo
                AND tip_spto = 'RF';
              --
        BEGIN         
              --
              SELECT DECODE ( TO_CHAR(g_fec_tratamiento,'MM'), '01', 'ENE',
                                                              '02', 'FEB',
                                                              '03', 'MAR',
                                                              '04', 'ABR',
                                                              '05', 'MAY',
                                                              '06', 'JUN',
                                                              '07', 'JUL',
                                                              '08', 'AGO',
                                                              '09', 'SEP',
                                                              '10', 'OCT',
                                                              '11', 'NOV',
                                                              '12', 'DEC' )
              INTO l_mes_proceso
              FROM DUAL;
              --
              trn_k_global.asigna('mca_ter_tar','N');  -- Version : 1.02
              --
              -- Seleccion de las polizas a Renovar: Cuery Principal
              OPEN cl_a2000030;
              LOOP
                --
                FETCH cl_a2000030 INTO reg_a2000030;
                EXIT WHEN cl_a2000030%NOTFOUND;
                --
                g_cant_pre_renov := g_cant_pre_renov + 1;
                --
                -- Buscar el Cod_Spto:
                OPEN  CR_G2999005 (reg_a2000030.cod_cia, reg_a2000030.cod_ramo);
                FETCH CR_G2999005 INTO reg_a2000030.cod_spto, reg_a2000030.sub_cod_spto;
                CLOSE CR_G2999005;
                --
                l_num_presupuesto                     := reg_a2000030.num_presupuesto;
                l_num_renovaciones                    := reg_a2000030.num_renovaciones;
                reg_a2000500                          := NULL;
                --
                reg_a2000030.num_riesgos := f_calula_riesgos( reg_a2000030.cod_cia,
                                                              reg_a2000030.num_poliza );
                --
                reg_a2000500.num_orden                := g_num_orden;
                reg_a2000500.fec_tratamiento          := reg_a2000030.fec_tratamiento;
                reg_a2000500.tip_mvto_batch           := reg_a2000030.tip_mvto_batch;
                reg_a2000500.cod_cia                  := reg_a2000030.cod_cia;
                reg_a2000500.cod_sector               := reg_a2000030.cod_sector;
                reg_a2000500.cod_ramo                 := reg_a2000030.cod_ramo;
                reg_a2000500.cod_nivel1               := reg_a2000030.cod_nivel1;
                reg_a2000500.cod_nivel2               := reg_a2000030.cod_nivel2;
                reg_a2000500.cod_nivel3               := reg_a2000030.cod_nivel3;
                reg_a2000500.cod_agt                  := reg_a2000030.cod_agt;
                reg_a2000500.cod_mon                  := reg_a2000030.cod_mon;
                reg_a2000500.num_poliza               := reg_a2000030.num_poliza;
                reg_a2000500.num_spto                 := reg_a2000030.num_spto;
                reg_a2000500.num_apli                 := reg_a2000030.num_apli;
                reg_a2000500.num_spto_apli            := reg_a2000030.num_spto_apli;
                reg_a2000500.tip_poliza_tr            := reg_a2000030.tip_poliza_tr;
                reg_a2000500.mca_prima_manual         := reg_a2000030.mca_prima_manual;
                reg_a2000500.tip_situ                 := reg_a2000030.tip_situ;
                reg_a2000500.mca_pre_renovacion       := reg_a2000030.mca_pre_renovacion;
                reg_a2000500.mca_anulacion_por_deuda  := reg_a2000030.mca_anulacion_por_deuda;
                reg_a2000500.cod_usr                  := reg_a2000030.cod_usr;
                reg_a2000500.fec_actu                 := reg_a2000030.fec_actu;
                reg_a2000500.cod_spto                 := reg_a2000030.cod_spto;
                reg_a2000500.sub_cod_spto             := reg_a2000030.sub_cod_spto;
                reg_a2000500.num_riesgos              := reg_a2000030.num_riesgos;
                reg_a2000500.num_poliza_grupo         := reg_a2000030.num_poliza_grupo;
                reg_a2000500.num_contrato             := reg_a2000030.num_contrato;
                --
                l_fec_vcto_poliza                     := p_mod_p2000030_corredor  ( reg_a2000030.cod_agt,
                                                                                    reg_a2000030.fec_vcto_poliza );                                                                  
                --
                -- Fec. 30-Sep-16, Version : 1.05
                IF f_verifica_fec_vcto_pol (reg_a2000030.cod_cia, reg_a2000030.cod_ramo,
                                            reg_a2000030.num_poliza, l_fec_vcto_poliza) = 'S' THEN
                  --
                  l_fec_vcto_poliza := to_date(f_buscar_fec_fin_prestamo(reg_a2000030.cod_cia, reg_a2000030.cod_ramo,
                                                                        reg_a2000030.num_poliza),'ddmmyyyy');
                  --
                END IF;
                --
                reg_a2000500.fec_efec_spto            := reg_a2000030.fec_vcto_poliza;
                reg_a2000500.fec_vcto_spto            := l_fec_vcto_poliza;
                reg_a2000500.cod_tip_spto             := l_cod_tip_spto;
                --reg_a2000500.txt_motivo_spto          := 'RENOVACION AUTOMATICA AUTOMOVIL'||l_mes_proceso||'-'||TO_CHAR(g_fec_tratamiento,'YYYY')||', AUTOMOVIL';  Version: 1.10
                --
                -- Fec. 7-Mar-17, Version: 1.10 (Cambio texto del motivo spto)
                reg_a2000500.txt_motivo_spto          := 'AUTOMATICA DE AUTOMOVIL. '||l_mes_proceso||'-'||TO_CHAR(g_fec_tratamiento,'YYYY');
                --
                -- Elimina la data existente con el mismo criterio de ejecucion del proceso.
                p_elimina_poliza;
                --
                BEGIN
                  INSERT INTO a2000500 VALUES reg_a2000500;
                EXCEPTION WHEN OTHERS THEN
                  raise_application_error ( -20000, 'Error insertando en a2000500 ' ||
                                            reg_a2000030.num_poliza || ' ' || SQLERRM );
                END;
                --
                -- Genero globales de proceso: Version : 1.01 ( Fue movido )
                trn_k_global.asigna( 'FEC_TRATAMIENTO', to_char( g_fec_tratamiento, 'ddmmyyyy') );
                trn_k_global.asigna( 'COD_CIA', g_cod_cia );
                trn_k_global.asigna( 'TIP_MVTO_BATCH', g_tip_mvto_batch );
                --
                -- --------------------------------------------------
                -- Nombre: Cargas Globales de A2000030
                -- Fecha : 12-Sep-14
                -- Nota  : Este programacion fue transferidos desde
                --       : el proceso ea_p_ren_auto_tron_mrd.
                -- --------------------------------------------------
                --
                ea_k_genera_globales.p_limpiar_valores;
                ea_k_genera_globales.p_limpiar_tablas;
                --
                ea_k_genera_globales.p_add_tables (p_table_name => 'A2000030', p_owner => 'TRON2000' );
                --
                ea_k_genera_globales.p_buscar_valores(p_cod_campo  => 'cod_cia'      ,p_valor =>reg_a2000500.cod_cia );
                ea_k_genera_globales.p_buscar_valores(p_cod_campo  => 'num_poliza'   ,p_valor =>reg_a2000500.num_poliza );
                ea_k_genera_globales.p_buscar_valores(p_cod_campo  => 'num_spto'     ,p_valor =>reg_a2000500.num_spto );
                ea_k_genera_globales.p_buscar_valores(p_cod_campo  => 'num_apli'     ,p_valor =>reg_a2000500.num_apli );
                ea_k_genera_globales.p_buscar_valores(p_cod_campo  => 'num_spto_apli',p_valor =>reg_a2000500.num_spto_apli );
                --
                ea_k_genera_globales.p_genera_globales();
                --
                -- Fec. 30-Sep-16, Version : 1.05
                -- Colocado aqui, porque (p_buscar_valores), asigna vigencia anterior y no la calculada.
                trn_k_global.asigna( 'FEC_VCTO_POLIZA', to_char( l_fec_vcto_poliza, 'ddmmyyyy') );
                --
                -- Fec. 26-Jun-15, Version : 1.03 (Para que se inserte en la tabla a2109013)
                trn_k_global.asigna( 'NUM_RIESGO', '0' );
                --
                p_aplica_reglas( reg_a2000500.cod_cia, 'A2000030', 0, reg_a2000500.cod_ramo, g_mes, g_anio, g_cant_regla_aplicada );
                --
                -- Limpia la tabla de Memoria, por cada poliza. Version : 1.13
                g_tb_dv.delete;
                --
                p_carga_datos_variables_riesgo( reg_a2000500.cod_cia, reg_a2000500.num_poliza, 0,
                                                reg_a2000500.cod_ramo );
                --
                trn_k_global.asigna( 'num_riesgo', 0 );  -- Asigno 0 al num_riesgo por si alguna regla aplica
                p_aplica_reglas( reg_a2000500.cod_cia, 'A2000020', 1, reg_a2000500.cod_ramo, g_mes, g_anio, g_cant_regla_aplicada );
                --
                p_trata_riesgos( reg_a2000500.cod_cia, reg_a2000500.num_poliza, reg_a2000500.cod_ramo );
                --
                -- Realizar el proceso por poliza: se ejecuta el proceso batch
                p_procesar_poliza(reg_a2000500.num_poliza);  -- Version : 1.01
                --
                -- Fec.: 2-jun-15 Version : 1.03 (Se movio y se agrego a reg_a2000030)
                SELECT decode ( reg_a2000030.tip_coaseguro, 0, 'EXENTO', 1, 'LIDER', 2, 'MINORITARIO' )
                  INTO l_nom_coaseguro
                  FROM dual;
                --
                -- Fec.: 1-jun-15 Version : 1.03 (Se movio y se agrego a NUM_POLIZA_GRUPO)
                em_p_preren_gen_mrd ( g_fec_tratamiento, g_num_orden, 2, g_tip_cuenta, reg_a2000030.cod_ramo,
                                      reg_a2000030.num_poliza, reg_a2000030.cod_cia, g_anio, g_mes,
                                      reg_a2000030.fec_efec_poliza, reg_a2000030.fec_vcto_poliza, l_nom_coaseguro,
                                      reg_a2000030.tip_coaseguro, reg_a2000030.tip_docum, reg_a2000030.cod_docum,
                                      reg_a2000030.cod_agt, reg_a2000030.num_spto, reg_a2000030.num_apli,
                                      reg_a2000030.num_spto_apli, reg_a2000030.cod_mon, reg_a2000030.cod_nivel3,
                                      reg_a2000030.num_riesgos,reg_a2000030.tip_gestor,
                                      reg_a2000030.num_poliza_grupo );
                --
              END LOOP;
              --
              IF g_cant_pre_renov > 0 THEN
                -- Fec. 11-Jun-15, Version : 1.03
                IF g_num_poliza_grupo IS NOT NULL THEN  -- Version : 1.13 (Mejora)
                    l_concat := l_concat|| '       Ramo : '|| g_Cod_Ramo||'    Cantidad Polizas : '||g_cant_pre_renov||'   Poliza Grupo : '||g_num_poliza_grupo|| chr(13);
                ELSIF g_num_poliza IS NOT NULL THEN  -- Version : 1.13 (Mejora)
                    l_concat := l_concat|| '       Ramo : '|| g_Cod_Ramo||'    Cantidad Polizas : '||g_cant_pre_renov||'   Poliza : '||g_num_poliza|| chr(13);
                ELSE
                    l_concat := l_concat|| '       Ramo : '|| g_Cod_Ramo||'    Cantidad Polizas : '||g_cant_pre_renov|| chr(13);
                END IF;
              END IF;
              --
              trn_k_global.asigna('mca_ter_tar','S');  -- Version : 1.02
              --
        END p_inserta_a2000500;
        --
        PROCEDURE p_inserta_g2000510 IS
              --
              l_existe   VARCHAR2(1) := 'N';
              l_insertar BOOLEAN     := FALSE;
              l_nom_prg  g2000580.nom_prg_excepcion%TYPE; -- version : 1.19
              --
              CURSOR CL_g2000510( pc_tip_mvto_batch g2000510.tip_mvto_batch%TYPE ) IS
                SELECT 'S'
                  FROM g2000510
                WHERE cod_cia         = g_cod_cia
                  AND fec_tratamiento = g_fec_tratamiento
                  AND num_orden       = g_num_orden
                  AND tip_mvto_batch  = pc_tip_mvto_batch;
              --
              -- Fec. 18-ago-2021, Version : 1.19
              CURSOR c_prg_excepcion( pc_tip_mvto_batch g2000510.tip_mvto_batch%TYPE ) IS
                SELECT nom_prg_excepcion 
                  FROM g2000580
                WHERE cod_cia        = g_cod_cia
                  AND tip_mvto_batch = pc_tip_mvto_batch;
              -- 
              -- verifica si hay excepcion
              PROCEDURE pp_hay_excepcion( pc_tip_mvto_batch g2000510.tip_mvto_batch%TYPE ) IS 
              BEGIN 
                --
                -- Fec. 18-ago-2021, Version : 1.19, se agrega (l_nom_prg)
                OPEN  cl_g2000510( pc_tip_mvto_batch );
                FETCH cl_g2000510 INTO l_existe;
                IF cl_g2000510%NOTFOUND THEN
                  l_insertar := TRUE; 
                ELSE
                  l_insertar := FALSE;             
                END IF;
                CLOSE cl_g2000510;              
                --
              END pp_hay_excepcion;                
              --
              -- buscar programa de excepcion
              PROCEDURE pp_prg_excepcion( pc_tip_mvto_batch g2000510.tip_mvto_batch%TYPE ) IS 
              BEGIN 
                --
                -- Fec. 18-ago-2021, Version : 1.19
                OPEN c_prg_excepcion( pc_tip_mvto_batch );
                FETCH c_prg_excepcion INTO l_nom_prg;
                CLOSE c_prg_excepcion;
                --
                EXCEPTION 
                  WHEN OTHERS THEN
                      l_nom_prg := NULL;
                --       
              END pp_prg_excepcion;
              --
              -- insertamos la excepcion
              PROCEDURE pp_insertar_excepcion( pc_tip_mvto_batch g2000510.tip_mvto_batch%TYPE ) IS
              BEGIN 
                --
                -- insertamos
                INSERT INTO g2000510( cod_cia, fec_tratamiento, num_orden, tip_mvto_batch,
                                      txt_alias, tip_situ_filtro, nom_prg_excepcion,
                                      mca_recalcula_fecha, tip_fecha_base, cod_usr, fec_actu
                                    )
                              VALUES ( g_cod_cia, g_fec_tratamiento, g_num_orden, pc_tip_mvto_batch,
                                      'RENOVACION MASIVA AUTOMOVIL', '6', l_nom_prg, 
                                      'N', NULL, USER, trunc ( SYSDATE ) 
                                    );              
                --                     
              END pp_insertar_excepcion; 
              --
              PROCEDURE pp_actualiza_excepcion( pc_tip_mvto_batch g2000510.tip_mvto_batch%TYPE ) IS 
              BEGIN  
                --
                -- actualizar excepcion
                UPDATE g2000510
                  SET nom_prg_excepcion = l_nom_prg,
                      fec_actu          = trunc( sysdate ),
                      tip_situ_filtro   = '6'
                WHERE cod_cia         = g_cod_cia
                  AND fec_tratamiento = g_fec_tratamiento
                  AND num_orden       = g_num_orden
                  AND tip_mvto_batch  = pc_tip_mvto_batch;  
                --   
              END pp_actualiza_excepcion; 
              --
        BEGIN
              --
              -- Buscar el Numero de Orden:
              /*
              BEGIN
                SELECT MAX ( num_orden )
                  INTO g_num_orden
                  FROM g2000510
                WHERE fec_tratamiento = g_fec_tratamiento
                  AND tip_mvto_batch  = l_tip_mvto_batch;
              END;
              --
              g_num_orden := nvl ( g_num_orden, 3 ) + 1;
              */
              g_num_orden := 4;  -- Fec. 12-Ene-15 (Dejarlo el 4, como fijo)
              --
              -- Fec. 18-ago-2021, Version : 1.19 para tipo de movimiento 1
              pp_prg_excepcion( l_tip_mvto_batch );
              pp_hay_excepcion( l_tip_mvto_batch );
              --
              -- evaluamos el resultado de la busqueda
              IF l_insertar THEN
                --
                -- insertamos
                pp_insertar_excepcion( l_tip_mvto_batch );

              ELSE
                --
                -- actualizamos    
                pp_actualiza_excepcion( l_tip_mvto_batch );   
                --
              END IF;           
              --
        END p_inserta_g2000510;
        --
        -- ---------------------------------------
    BEGIN  -- INICIO:
      -- ---------------------------------------
      --
      trn_p_ejecuta_sentencia('ALTER SESSION SET NLS_DATE_FORMAT = ''DDMMYYYY''');
      trn_p_ejecuta_sentencia('ALTER SESSION SET NLS_NUMERIC_CHARACTERS = ''.,''');
      --
      -- Fec. 24-Ago-17 (Solo se movio para antes de p_carga_reglas_periodo), Version: 1.12
      g_start_date      := to_date( '01'|| LPAD( g_mes, 2, '0' ) || g_anio, 'ddmmyyyy' );
      g_fec_tratamiento := g_start_date;
      g_end_date        := last_day( g_start_date );
      --
      -- Realizar Carga de las Reglas, para este Periodo:
      p_carga_reglas_periodo ( g_cod_cia,
                                g_cod_ramo,
                                g_num_poliza,
                                g_anio,
                                g_mes );
      --
      -- Fec. 19-May-15, Version : 1.03
      g_max_riesgo_ind := f_busca_max_riesgo(g_cod_cia, g_cod_ramo);
      --
      p_elimina_orden;
      --
      p_inserta_g2000510;
      --
      p_inserta_a2000500;
      --
    END p_carga_inicial_polizas; -- Fin : p_carga_inicial_polizas;
    --
    -- --------------------------------------------------
    -- Autor : Manuel Rodriguez           Version : 1.01
    -- Fecha : 19-Feb-15
    -- Nota  : Se encarga de recibir la A2000500 y luego
    --       : procesar la poliza en curso.
    -- --------------------------------------------------
    PROCEDURE p_procesar_poliza (p_num_poliza  a2000500.num_poliza%TYPE) IS
      --
      l_cant_pre_ren      NUMBER(6) := 0;
      --
    BEGIN
      --
      -- Limpiar las tablas R:
      p_limpia_tablas_r ( g_cod_cia,
                          g_cod_ramo,
                          p_num_poliza,
                          g_fec_tratamiento,
                          NULL );
      --
      -- Cargar las tablas R:
      p_carga_tablas_r ( g_cod_cia,
                          g_cod_ramo,
                          p_num_poliza,
                          g_fec_tratamiento,
                          NULL );
      --
      -- Grabar tabla de Registro por riesgo:
      p_inserta_a2109010 (p_num_poliza);
      --
    END p_procesar_poliza; -- Fin : p_carga_tablas_r;
    --
    /**
    || Procedimiento para la carga de las tablas R
    */
    PROCEDURE p_carga_tablas_r ( p_cod_cia          a2000030.cod_cia           %TYPE,
                                  p_cod_ramo         a2000030.cod_ramo          %TYPE,
                                  p_num_poliza       a2000030.num_poliza        %TYPE,
                                  p_fec_tratamiento  a2000500.fec_tratamiento   %TYPE,
                                  p_num_orden        a2000500.num_orden         %TYPE
                                ) IS
      --
      l_cant_pre_ren      NUMBER(6) := 0;
      --
      CURSOR cl_a2000500 IS
        SELECT *
          FROM a2000500
         WHERE cod_cia         = p_cod_cia
           AND cod_ramo        = p_Cod_Ramo
           AND num_poliza      = NVL( p_Num_Poliza, Num_Poliza )
           AND fec_tratamiento = p_fec_tratamiento
           AND tip_mvto_batch IN ( 1, 2 )
           AND num_orden       = NVL(p_num_orden, num_orden)
         ORDER BY fec_efec_spto, fec_vcto_spto, num_poliza;
      --
      Reg   cl_a2000500%ROWTYPE;
      --
    BEGIN
      --
      trn_p_ejecuta_sentencia('ALTER SESSION SET NLS_DATE_FORMAT = ''DDMMYYYY''');
      trn_p_ejecuta_sentencia('ALTER SESSION SET NLS_NUMERIC_CHARACTERS = ''.,''');
      --
      trn_k_global.asigna ( 'COD_IDIOMA', 'ES' );
      trn_k_global.asigna ( 'COD_CIA', p_cod_cia );
      trn_k_global.asigna ( 'COD_USR', USER );
      --
      FOR reg IN cl_a2000500 LOOP
        --
        l_cant_pre_ren := l_cant_pre_ren + 1;
        --
        trn_k_global.asigna ( 'FEC_TRATAMIENTO',      to_char(reg.fec_tratamiento,'ddmmyyyy') );
        trn_k_global.asigna ( 'JBNUM_ORDEN',          to_char ( reg.num_orden ) );
        trn_k_global.asigna ( 'JBCOD_CIA',            g_Cod_Cia );
        trn_k_global.asigna ( 'TIP_MVTO_BATCH',       l_tip_pre_renovacion );
        trn_k_global.asigna ( 'JBMCA_REPROCESO',      'S' );
        trn_k_global.asigna ( 'JBMCA_ABORTA_EMISION', 'N' );
        trn_k_global.asigna ( 'JBMCA_MULTIHILO',      'N' );
        trn_k_global.asigna ( 'JBCOD_SECTOR',         NULL );
        trn_k_global.asigna ( 'JBCOD_RAMO',           NULL );
        trn_k_global.asigna ( 'JBCOD_NIVEL1',         NULL );
        trn_k_global.asigna ( 'JBCOD_NIVEL2',         NULL );
        trn_k_global.asigna ( 'JBCOD_NIVEL3',         NULL );
        trn_k_global.asigna ( 'JBCOD_AGT',            NULL );
        trn_k_global.asigna ( 'JBNUM_POLIZA',         reg.num_poliza );
        trn_k_global.asigna ( 'JBNUM_POLIZA_GRUPO',   NULL );
        trn_k_global.asigna ( 'JBNUM_POLIZA_CLIENTE', NULL );
        trn_k_global.asigna ( 'JBCANT_REGISTROS',     1 );
        trn_k_global.asigna ( 'JBMAX_NUM_RIESGOS',    reg.num_riesgos );
        trn_k_global.asigna ( 'JBMCA_GRUPOS',         NULL );
        trn_k_global.asigna ( 'JBCOD_SPTO',           reg.cod_spto );
        trn_k_global.asigna ( 'JBSUB_COD_SPTO',       reg.sub_cod_spto );
        --
        -- Ejecuta el proceso masivo:
        BEGIN
          EM_K_BATCH.P_PROCESO;
        EXCEPTION 
          WHEN OTHERS THEN
                dbms_output.put_line( sqlerrm || ' exception .. del proceso em_k_batch .. reg.num_poliza => ' || reg.num_poliza );
        END;
        --
      END LOOP;
      --
    END p_carga_tablas_r; -- Fin : p_carga_tablas_r;
    --
    -- ------------------------------------------------------------
    --
    /**
    || Procedimiento para la insertar los datos en la tabla
    */
    --
    PROCEDURE p_inserta_a2109010 (p_num_poliza  a2000030.num_poliza%TYPE) IS  -- Version : 1.01
      --
      l_cod_cia                 A2000030.cod_cia%TYPE;
      l_cod_ramo                A2000030.cod_ramo%TYPE;
      l_num_poliza              A2000030.num_poliza%TYPE;
      l_num_riesgo              A2000031.num_riesgo%TYPE;
      l_fec_efec_riesgo         A2000031.fec_efec_riesgo%TYPE;
      l_fec_efec_riesgo_v       A2000031.fec_efec_riesgo%TYPE;
      l_fec_vcto_riesgo         A2000031.fec_vcto_riesgo%TYPE;
      l_fec_efec_ries           A2000031.fec_efec_riesgo%TYPE;
      l_fec_vcto_ries           A2000031.fec_vcto_riesgo%TYPE;
      l_nom_tomador             VARCHAR2(140);
      l_cod_plan_auto           A2109010.cod_plan%TYPE;
      l_cod_modalidad           A2109010.cod_modalidad%TYPE;
      l_cod_modalidad_ren       A2109010.cod_modalidad%TYPE;
      l_cod_tip_vehi            NUMBER(3);
      l_cod_marca               NUMBER(3);
      l_cod_modelo              NUMBER(3);
      l_cod_sub_modelo          NUMBER(3);
      l_anio_modelo             NUMBER(4);
      l_num_chasis              A2109010.Num_Chasis%TYPE;
      l_suma_aseg               NUMBER(22,2) := 0;
      l_suma_aseg_ren           NUMBER(22,2) := 0;
      l_prima                   NUMBER(22,2) := 0;
      l_pri_ren                 NUMBER(22,2) := 0;
      l_prima_ren               NUMBER(22,2) := 0;
      l_prima_preren            NUMBER(22,2) := 0;
      l_nueva_dif_prima_ren     NUMBER(22,2) := 0;
      l_nueva_var_prima         NUMBER(22,2) := 0;
      l_primanetafacturada      NUMBER(22,2) := 0;
      l_tasa                    NUMBER(22,2) := 0;
      l_tasa_ren                NUMBER(22,2) := 0;
      l_nueva_tasa              NUMBER(22,2) := 0;
      l_dnr                     NUMBER(22,2) := 0;
      l_dnr_ren                 NUMBER(22,2) := 0;
      l_variacion_valor         NUMBER(22,2) := 0;
      l_variacion_valor_ren     NUMBER(22,2) := 0;
      l_diferencia              NUMBER(22,2) := 0;
      l_diferencia_ren          NUMBER(22,2) := 0;
      l_evolucion               A2109010.evolucion%TYPE;
      l_evolucion_ren           A2109010.evolucion_ren%TYPE;
      l_variacion               NUMBER(22,2) := 0;
      l_variacion_ren           NUMBER(22,2) := 0;
      l_desc_comercial          NUMBER(14,10) := 0;
      l_desc_comercial_ren      NUMBER(14,10) := 0;
      l_mca_siniestros           VARCHAR2(1);
      l_num_siniestros          NUMBER(12) := 0;
      l_sini_pag                NUMBER(22,2) := 0;
      l_sini_por_pag            NUMBER(22,2) := 0;
      l_num_sini_menores        A2109010.num_sini_menores%TYPE;
      l_num_sini_mayores        A2109010.num_sini_mayores%TYPE;
      l_imp_siniestros          A2109010.imp_siniestros%TYPE;
      l_mca_sini_mayor_cero     VARCHAR2(1);
      l_mca_balance             VARCHAR2(1);
      l_tip_cuenta              NUMBER(5);
      l_ejecutivo_cobros        A2000020.txt_campo%TYPE;
      l_nom_tip_vehi            A2000020.txt_campo%TYPE;
      l_nom_marca               A2000020.txt_campo%TYPE;
      l_nom_modelo              A2000020.txt_campo%TYPE;
      l_nom_sub_modelo          A2000020.txt_campo%TYPE;
      l_nom_modalidad           A2000020.txt_campo%TYPE;
      l_nom_modalidad_ren       A2000020.txt_campo%TYPE;
      l_cod_zona_vehi           VARCHAR2(2);
      l_nom_zona_vehi           A2000020.txt_campo%TYPE;
      l_cod_uso_vehi            NUMBER(3);
      l_nom_uso_vehi            A2000020.txt_campo%TYPE;
      l_num_matricula           VARCHAR2(10);
      l_cod_oficial             VARCHAR2(14);
      l_nom_oficial             A2000020.txt_campo%TYPE;
      l_pct_desc_com_pol        NUMBER(14,10) := 0;
      l_cod_equipo_gas          NUMBER(3);
      l_nom_equipo_gas          A2000020.txt_campo%TYPE;
      l_tip_aeroambulancia      NUMBER(1);
      l_nom_aeroambulancia      A2000020.txt_campo%TYPE;
      l_pct_categoria           taaut084_mrd.pct_ajuste%type;
      l_tip_estatus_riesgo      A2109010.tip_estatus_riesgo%TYPE;
      l_ind_sini_acumulado      A2109010.ind_sini_acumulado%TYPE;
      l_meses_vig               A2109010.meses_vig%TYPE;
      l_txt_error_ct            A2109010.txt_error_ct%TYPE;
      l_contador                NUMBER := 0;
      l_txt_error_pol           A2109010.txt_error_pol%TYPE;  -- Version : 1.03
      l_cod_modalidad_ley       A2109010.cod_modalidad%TYPE;  -- Version : 1.18
      --
      CURSOR cl_renovacion IS
        SELECT a.cod_cia, a.num_poliza, extract(MONTH FROM a.fec_tratamiento) Mes,
                extract(YEAR  FROM a.fec_tratamiento) Anio, a.cod_ramo, a.num_spto,
                a.num_apli, a.num_spto_apli, a.num_poliza_grupo,
                a.num_riesgos cant_riesgos, ries.num_riesgo, ries.nom_riesgo,
                pol.tip_docum, pol.cod_docum,
                pol.fec_efec_poliza, pol.fec_vcto_poliza,
                NVL(ren.cod_agt, pol.cod_agt) codigo_agente,
                a.cod_nivel3      cod_ofic_comercial,
                ofi.nom_nivel3    nom_ofic_comercial,
                (nom_agt.nom_tercero || ' ' || nom_agt.ape1_tercero || ' ' || nom_agt.ape2_tercero ) nom_Intermediario,
                DECODE (A.FEC_EFEC_SPTO,NULL, ADD_MONTHS(A.FEC_VCTO_SPTO,-12), A.FEC_EFEC_SPTO) fec_ini_vigencia,
                a.FEC_VCTO_SPTO fec_fin_vigencia     ,
                NVL(ren.tip_coaseguro,0)  tip_coaseguro,
                A.COD_MON                            ,
                em_k_balance_cliente_mrd.bce_poliza( a.cod_cia, a.num_poliza ) balance,
                a.FEC_TRATAMIENTO                    ,
                a.TIP_SITU                           ,
                a.NUM_ORDEN                          ,
                ren.COD_CUADRO_COM        , ren.num_poliza num_poliza_ren,
                nom_comi.NOM_CUADRO_COM   ,
                --
                endoso.TIP_BENEF                 ,
                endoso.tip_docum TIP_DOCUM_BENEF ,    -- Asegurado
                endoso.cod_docum COD_DOCUM_BENEF ,
                (nom_endoso.nom_tercero || ' ' || nom_endoso.ape1_tercero || ' ' || nom_endoso.ape2_tercero ) NOM_BENEF ,
                endoso.imp_cesion IMPORTE_ENDOSO ,
                --
                pol.cod_fracc_pago,
                fpago.nom_fracc_pago,
                --
                ries.fec_efec_riesgo, ries.fec_vcto_riesgo,
                --
                ' ' categoria                        ,
                0   factor_recargo   ,
                0   factor_ajuste    ,
                --
                a.cod_usr
          FROM a1001402 fpago,     -- Fec. 11-Jun-15, Version : 1.03 (Se organizo)
                a1001399 nom_endoso,
                a2000060 endoso,
                A1001752 nom_comi,
                a1001399 nom_agt,
                a1001332 agt,
                a1000702 ofi,
                r2000030 ren,
                a2000031 ries,
                s2000031 r,
                a2000030 pol,
                a2000500 a
          WHERE a.fec_tratamiento = g_fec_tratamiento
            AND a.num_orden       = g_num_orden
            AND a.tip_mvto_batch IN ( 1, 2 )
            AND a.cod_cia         = g_Cod_Cia
            AND a.cod_ramo        = NVL(g_Cod_Ramo, a.cod_ramo )
            AND a.num_poliza      = p_Num_Poliza   -- Version : 1.01
            --
            AND pol.cod_cia    = a.cod_cia
            AND pol.num_poliza = a.num_poliza
            AND pol.num_spto   = a.num_spto
            --
            AND r.fec_tratamiento = a.fec_tratamiento
            AND r.num_poliza      = a.num_poliza
            AND r.mca_riesgo      = 'M'
            --
            AND ries.cod_cia    = r.cod_cia
            AND ries.num_poliza = r.num_poliza
            AND ries.num_riesgo = r.num_riesgo
            AND ries.mca_baja_riesgo = 'N'
            AND ries.mca_vigente = 'S'
            --
            AND ren.cod_cia(+)    = a.cod_cia
            AND ren.num_poliza(+) = a.num_poliza
            --
            AND ofi.cod_cia    = a.cod_cia
            AND ofi.cod_nivel3 = a.cod_nivel3
            --
            AND agt.cod_cia     = a.cod_cia
            AND agt.cod_agt     = a.cod_agt
            AND agt.fec_validez = (SELECT MAX (fec_validez)
                                    FROM a1001332
                                    WHERE cod_cia = agt.cod_cia
                                      AND cod_agt = agt.cod_agt)
            --
            AND nom_agt.cod_cia(+)   = agt.cod_cia
            AND nom_agt.tip_docum(+) = agt.tip_docum
            AND nom_agt.cod_docum(+) = agt.cod_docum
            --
            AND nom_comi.cod_cia(+)        = pol.cod_cia   -- Fec. 9-Jul-15, Version : 1.03
            AND nom_comi.cod_cuadro_com(+) = pol.cod_cuadro_com
            --
            AND endoso.cod_cia(+)     = r.cod_cia
            AND endoso.num_poliza(+)  = r.num_poliza
            AND endoso.num_riesgo(+)  = r.num_riesgo
            AND endoso.tip_benef(+)   = 8
            AND endoso.mca_baja(+)    = 'N'
            AND endoso.mca_vigente(+) = 'S'
            --
            AND nom_endoso.cod_cia(+)   = endoso.cod_cia
            AND nom_endoso.tip_docum(+) = endoso.tip_docum
            AND nom_endoso.cod_docum(+) = endoso.cod_docum
            --
            AND fpago.cod_cia        = pol.cod_cia
            AND fpago.cod_fracc_pago = pol.cod_fracc_pago;
            --
      --
      -- Buscar Nombre Tomador:
      CURSOR cr_a1001399 (p_cod_cia           a2109010.cod_cia%TYPE,
                          p_tip_docum         a2109010.tip_docum%TYPE,
                          p_cod_docum         a2109010.cod_docum%TYPE) IS
        SELECT (nom_tercero||' '||ape1_tercero||' '||ape2_tercero) nom_tomador
          FROM a1001399
        WHERE cod_cia    = p_cod_cia
          AND tip_docum  = p_tip_docum
          AND cod_docum  = p_cod_docum;
      --
      -- Buscar Ramos Exceso, Version : 1.03
      CURSOR C_TA999003 IS
        SELECT TO_NUMBER(val_campo) val_campo
          FROM TA999003
         WHERE cod_cia   = g_cod_cia
           AND cod_campo = 'COD_RAMO_EXCESO'
           AND mca_inh   = 'N';
      --
      -- Buscar Modalidad Ley, Version : 1.18
      CURSOR C_TA999003_LEY IS
        SELECT TO_NUMBER(val_campo) val_campo
          FROM TA999003
         WHERE cod_cia   = g_cod_cia
           AND cod_ramo  = g_cod_ramo
           AND cod_campo = 'COD_MODALIDAD_LEY_AUTO'
           AND mca_inh   = 'N';
      --
      reg_a2109010_mrd   cl_renovacion%ROWTYPE;
      l_cod_ramo_exceso  a2000030.cod_ramo%TYPE := NULL;  -- Version : 1.03
      --
    BEGIN
      --
      trn_p_ejecuta_sentencia('ALTER SESSION SET NLS_DATE_FORMAT = ''DDMMYYYY''');
      trn_p_ejecuta_sentencia('ALTER SESSION SET NLS_NUMERIC_CHARACTERS = ''.,''');
      --
      -- M.R., Fec. 22-Abr-15, Version : 1.03
      OPEN  C_TA999003;
      FETCH C_TA999003 INTO l_cod_ramo_exceso;
      CLOSE C_TA999003;
      --
      -- M.R., Fec. 02-Sep-20, Version : 1.18
      OPEN  C_TA999003_LEY;
      FETCH C_TA999003_LEY INTO l_cod_modalidad_ley;
      CLOSE C_TA999003_LEY;
      --
      l_contador := 0;
      OPEN cl_renovacion;
      LOOP
        --
        l_contador := l_contador + 1;
        FETCH cl_renovacion INTO reg_a2109010_mrd;
        EXIT WHEN cl_renovacion%NOTFOUND;
        --
        BEGIN
          --
          -- Mover datos:
          l_cod_cia    := reg_a2109010_mrd.cod_cia;
          l_cod_ramo   := reg_a2109010_mrd.cod_ramo;
          l_num_poliza := reg_a2109010_mrd.num_poliza;
          l_num_riesgo := reg_a2109010_mrd.num_riesgo;
          --
          -- Fec. 12-Ene-15 (Vigencia anterior)
          l_fec_efec_riesgo :=  reg_a2109010_mrd.fec_efec_riesgo;
          l_fec_vcto_riesgo :=  reg_a2109010_mrd.fec_vcto_riesgo;
          --
          -- Buscar Datos:
          OPEN  cr_a1001399 (l_cod_cia, reg_a2109010_mrd.tip_docum, reg_a2109010_mrd.cod_docum);
          FETCH cr_a1001399 INTO l_nom_tomador;
          CLOSE cr_a1001399;
          --
          l_suma_aseg          := TO_NUMBER(f_campo_variable_a(l_cod_cia, l_num_poliza, 'VAL_SUB_MODELO', 'V', l_cod_ramo, l_num_riesgo));
          IF l_suma_aseg IS NULL OR l_suma_aseg = 0 THEN
              l_suma_aseg := 1;
          END IF;
          --
          l_cod_plan_auto      := TO_NUMBER(f_campo_variable_a(l_cod_cia, l_num_poliza, 'COD_PLAN_AUTO', 'V', l_cod_ramo, l_num_riesgo));
          l_num_chasis         := SUBSTR(f_campo_variable_a(l_cod_cia, l_num_poliza, 'NUM_CHASIS', 'V', l_cod_ramo, l_num_riesgo),1,30);
          l_dnr                := TO_NUMBER(f_campo_variable_a(l_cod_cia, l_num_poliza, 'PCT_DNR', 'V', l_cod_ramo, l_num_riesgo));
          l_desc_comercial     := TO_NUMBER(f_campo_variable_a(l_cod_cia, l_num_poliza, 'PCT_DESC_COM_RIES', 'V', l_cod_ramo, l_num_riesgo));
          l_tip_cuenta         := f_campo_variable_a(l_cod_cia, l_num_poliza, 'TIP_CUENTA', 'V', l_cod_ramo, 0);
          l_cod_zona_vehi      := f_campo_variable_a(l_cod_cia, l_num_poliza, 'COD_ZONA_VEHI', 'V', l_cod_ramo, l_num_riesgo);
          l_cod_uso_vehi       := TO_NUMBER(f_campo_variable_a(l_cod_cia, l_num_poliza, 'COD_USO_VEHI', 'V', l_cod_ramo, l_num_riesgo));
          l_num_matricula      := f_campo_variable_a(l_cod_cia, l_num_poliza, 'NUM_MATRICULA', 'V', l_cod_ramo, l_num_riesgo);
          l_cod_oficial        := f_campo_variable_a(l_cod_cia, l_num_poliza, 'COD_OFICIAL', 'V', l_cod_ramo, 0);
          l_pct_desc_com_pol   := TO_NUMBER(f_campo_variable_a(l_cod_cia, l_num_poliza, 'PCT_DESC_COM', 'V', l_cod_ramo, 0));
          l_cod_equipo_gas     := TO_NUMBER(f_campo_variable_a(l_cod_cia, l_num_poliza, 'COD_EQ_GAS', 'V', l_cod_ramo, l_num_riesgo));
          l_tip_aeroambulancia := TO_NUMBER(f_campo_variable_a(l_cod_cia, l_num_poliza, 'TIP_AEROAMBULANCIA', 'V', l_cod_ramo, l_num_riesgo));
          --
          l_ejecutivo_cobros   := f_campo_variable_a(l_cod_cia, l_num_poliza, 'COD_OFICIAL', 'T', l_cod_ramo, l_num_riesgo);
          l_nom_tip_vehi       := f_campo_variable_a(l_cod_cia, l_num_poliza, 'COD_TIP_VEHI', 'T', l_cod_ramo, l_num_riesgo);
          l_nom_marca          := f_campo_variable_a(l_cod_cia, l_num_poliza, 'COD_MARCA', 'T', l_cod_ramo, l_num_riesgo);
          l_nom_modelo         := f_campo_variable_a(l_cod_cia, l_num_poliza, 'COD_MODELO', 'T', l_cod_ramo, l_num_riesgo);
          l_nom_sub_modelo     := f_campo_variable_a(l_cod_cia, l_num_poliza, 'COD_SUB_MODELO', 'T', l_cod_ramo, l_num_riesgo);
          l_nom_modalidad      := f_campo_variable_a(l_cod_cia, l_num_poliza, 'COD_MODALIDAD_AUTO', 'T', l_cod_ramo, l_num_riesgo);
          l_nom_zona_vehi      := f_campo_variable_a(l_cod_cia, l_num_poliza, 'COD_ZONA_VEHI', 'T', l_cod_ramo, l_num_riesgo);
          l_nom_uso_vehi       := f_campo_variable_a(l_cod_cia, l_num_poliza, 'COD_USO_VEHI', 'T', l_cod_ramo, l_num_riesgo);
          l_nom_oficial        := f_campo_variable_a(l_cod_cia, l_num_poliza, 'COD_OFICIAL', 'T', l_cod_ramo, l_num_riesgo);
          l_nom_equipo_gas     := f_campo_variable_a(l_cod_cia, l_num_poliza, 'COD_EQ_GAS', 'T', l_cod_ramo, l_num_riesgo);
          l_nom_aeroambulancia := f_campo_variable_a(l_cod_cia, l_num_poliza, 'TIP_AEROAMBULANCIA', 'T', l_cod_ramo, l_num_riesgo);
          --
          l_prima := f_cal_prima_riesgo_a(l_cod_cia, l_cod_ramo, l_num_poliza, l_num_riesgo);
          --
          l_cod_modalidad  := TO_NUMBER(f_campo_variable_a(l_cod_cia, l_num_poliza, 'COD_MODALIDAD_AUTO', 'V', l_cod_ramo, l_num_riesgo));
          l_cod_tip_vehi   := TO_NUMBER(f_campo_variable_a(l_cod_cia, l_num_poliza, 'COD_TIP_VEHI', 'V', l_cod_ramo, l_num_riesgo));
          l_cod_marca      := TO_NUMBER(f_campo_variable_a(l_cod_cia, l_num_poliza, 'COD_MARCA', 'V', l_cod_ramo, l_num_riesgo));
          l_cod_modelo     := TO_NUMBER(f_campo_variable_a(l_cod_cia, l_num_poliza, 'COD_MODELO', 'V', l_cod_ramo, l_num_riesgo));
          l_cod_sub_modelo := TO_NUMBER(f_campo_variable_a(l_cod_cia, l_num_poliza, 'COD_SUB_MODELO', 'V', l_cod_ramo, l_num_riesgo));
          l_anio_modelo    := TO_NUMBER(f_campo_variable_a(l_cod_cia, l_num_poliza, 'ANIO_SUB_MODELO', 'V', l_cod_ramo, l_num_riesgo));
          --
          l_suma_aseg_ren  := TO_NUMBER(f_campo_variable_r(l_cod_cia, l_num_poliza, 'VAL_SUB_MODELO', 'V', l_num_riesgo));
          --
          l_cod_modalidad_ren  := TO_NUMBER(f_campo_variable_r(l_cod_cia, l_num_poliza, 'COD_MODALIDAD_AUTO', 'V', l_num_riesgo));
          --
          -- Fec. 01-Sep-20, Version: 1.18
          -- Nota: IF l_suma_aseg_ren es movido para despues de (l_cod_modalidad_ren), para usarlo.
          IF l_suma_aseg_ren IS NULL OR l_suma_aseg_ren = 0 THEN
              --
              l_suma_aseg_ren := 1;
              --
              -- Fec. 01-Sep-20, Version: 1.18
              -- Nota: Si la Modalidad no es de Ley, se igualan las SUMA_ASEG, ejemplo, ramo 346.
              IF l_suma_aseg > 0 and NVL(l_cod_modalidad_ren,0) <> l_cod_modalidad_ley THEN
                l_suma_aseg_ren := l_suma_aseg;
              END IF;
              --
          END IF;
          --
          l_dnr_ren            := TO_NUMBER(f_campo_variable_r(l_cod_cia, l_num_poliza, 'PCT_DNR', 'V', l_num_riesgo));
          l_desc_comercial_ren := TO_NUMBER(f_campo_variable_r(l_cod_cia, l_num_poliza, 'PCT_DESC_COM_RIES', 'V', l_num_riesgo));
          --
          l_nom_modalidad_ren := f_campo_variable_r(l_cod_cia, l_num_poliza, 'COD_MODALIDAD_AUTO', 'T', l_num_riesgo);
          --
          IF l_cod_modalidad_ren  IS NULL THEN
              l_cod_modalidad_ren := l_cod_modalidad;
              l_nom_modalidad_ren := l_nom_modalidad;
          END IF;
          --
          IF l_dnr_ren  IS NULL THEN
              l_dnr_ren := l_dnr;
          END IF;
          --
          IF l_desc_comercial_ren  IS NULL THEN
              l_desc_comercial_ren := l_desc_comercial;
          END IF;
          --
          l_pri_ren := f_cal_prima_renovacion(l_cod_cia, l_num_poliza, l_num_riesgo);
          --
          -- Fec. 22-Abr-15, Version : 1.03
          IF l_cod_ramo = l_cod_ramo_exceso THEN
              --
              -- Fec. 11-Jun-15, Version : 1.03  (Buscarlo a Nivel Poliza, riesgo cero)
              l_suma_aseg     := TO_NUMBER(f_campo_variable_a(l_cod_cia, l_num_poliza, 'LIMITE_RIESGO', 'V', l_cod_ramo, 0));
              l_suma_aseg_ren := l_suma_aseg;
              --
              l_num_chasis    := SUBSTR(f_campo_variable_a(l_cod_cia, l_num_poliza, 'NUM_CHASIS_EXC', 'V', l_cod_ramo, l_num_riesgo),1,30);
              --
              l_cod_modalidad := TO_NUMBER(f_campo_variable_a(l_cod_cia, l_num_poliza, 'COD_MODALIDAD', 'V', l_cod_ramo, l_num_riesgo));
              l_nom_modalidad := f_campo_variable_a(l_cod_cia, l_num_poliza, 'COD_MODALIDAD', 'T', l_cod_ramo, l_num_riesgo);
              l_cod_modalidad_ren := l_cod_modalidad;
              l_nom_modalidad_ren := l_nom_modalidad;
              --
              -- Fec. 11-Jun-15, Version : 1.03
              -- Significa que la prima no vario y por eso no grabo en R2100170.
              IF l_pri_ren = 1 THEN
                l_pri_ren := l_prima;
              END IF;
              --
          END IF;
          --
          IF reg_a2109010_mrd.num_poliza_ren IS NULL THEN
              l_prima_ren    := 1;
              l_prima_preren := 1;
          ELSE
              l_prima_ren    := l_pri_ren;
              l_prima_preren := l_pri_ren;
          END IF;
          --
          l_nueva_dif_prima_ren := l_prima_preren - l_prima;
          l_nueva_var_prima     := ROUND((l_nueva_dif_prima_ren/l_prima)*100,3);
          l_primanetafacturada  := f_cal_prima_riesgo_n (l_cod_cia, l_cod_ramo,
                                                          l_num_poliza, l_num_riesgo);
          --
          l_tasa       := ROUND(l_prima / l_suma_aseg*100,3);
          l_tasa_ren   := ROUND(l_prima_ren / l_suma_aseg_ren*100,3);
          l_nueva_tasa := ROUND(l_prima_ren / l_suma_aseg_ren*100,3);
          IF reg_a2109010_mrd.num_poliza_ren IS NULL THEN
              l_tasa_ren   := l_tasa;
              l_nueva_tasa := l_tasa;
          END IF;
          --
          -- Si es de Ley, asignar cero:
          IF l_suma_aseg = 1 THEN
              l_tasa  := 0;
          END IF;
          --
          -- Si es de Ley, asignar cero:
          IF l_suma_aseg_ren = 1 THEN
              l_tasa_ren   := 0;
              l_nueva_tasa := 0;
          END IF;
          --
          l_variacion_valor     := ROUND(((l_suma_aseg_ren/l_suma_aseg)-1)*100,3);
          l_variacion_valor_ren := ROUND(((l_suma_aseg_ren/l_suma_aseg)-1)*100,3);
          --
          l_diferencia     := l_prima_ren - l_prima;
          l_diferencia_ren := l_prima_preren - l_prima_ren;
          --
          IF l_diferencia > 0 THEN
              l_evolucion     := 'SUBE';
              l_evolucion_ren := 'SUBE';
          ELSIF l_diferencia < 0 THEN
              l_evolucion     := 'BAJA';
              l_evolucion_ren := 'BAJA';
          ELSE
              l_evolucion     := 'IGUAL';
              l_evolucion_ren := 'IGUAL';
          END IF;
          --
          l_variacion     := ROUND((l_diferencia/l_prima)*100,3);
          l_variacion_ren := ROUND((l_diferencia_ren/l_prima)*100,3);
          --
          -- Calcular fechas riesgo: Fec. 14-Ene-15
          l_fec_efec_ries := NULL;
          l_fec_vcto_ries := NULL;
          p_fechas_riesgo(l_cod_cia      ,
                          l_num_poliza   ,
                          l_num_riesgo   ,
                          l_fec_efec_ries,  -- Fecha ultima renovacion o inclusion del riesgo
                          l_fec_vcto_ries );
          --
          IF l_fec_efec_ries IS NULL THEN   -- Fec. 14-Ene-15
              l_fec_efec_ries := l_fec_efec_riesgo;
          END IF;
          --
          l_mca_siniestros := 'N';
          l_num_siniestros := 0;
          l_sini_pag  := f_cal_siniestro(l_cod_cia, l_num_poliza, l_num_riesgo,
                                          l_fec_efec_ries, l_fec_vcto_riesgo,   -- Fec. 14-Ene-15
                                          l_mca_siniestros, l_num_siniestros);
          l_sini_por_pag := l_sini_pag;
          --
          l_mca_sini_mayor_cero := 'N';
          IF l_sini_pag > 0 THEN
              l_mca_sini_mayor_cero := 'S';
          END IF;
          --
          -- Buscar los valores de Siniestros:
          p_siniestro(l_cod_cia,
                      l_Num_Poliza,
                      l_num_riesgo,
                      l_cod_Ramo,
                      l_fec_efec_ries,      -- Fec. 14-Ene-15 (Desde la ultima renovacion)
                      l_fec_vcto_riesgo,
                      l_prima,              -- se quito a l_prima_ren el 6-Oct-14
                      l_num_sini_menores,   -- OUT
                      l_num_sini_mayores,   -- OUT
                      l_imp_siniestros);    -- OUT
          --
          l_mca_balance := 'N';
          IF reg_a2109010_mrd.balance > 0 THEN
              l_mca_balance := 'S';
          END IF;
          --
          l_pct_categoria := f_pct_x_grupo_vehi(reg_a2109010_mrd.cod_cia, reg_a2109010_mrd.cod_ramo,
                                                l_cod_modalidad, l_cod_marca, l_cod_modelo,
                                                l_cod_sub_modelo, reg_a2109010_mrd.fec_tratamiento);
          --
          l_tip_estatus_riesgo := 'A';  -- Aprobado
          --
          l_ind_sini_acumulado := f_cal_ind_sini_acumulado ( p_Cod_cia          => reg_a2109010_mrd.cod_cia,
                                                              p_Cod_Ramo         => reg_a2109010_mrd.cod_ramo,
                                                              p_Num_Poliza       => reg_a2109010_mrd.num_poliza );
          --
          l_fec_efec_riesgo_v := em_f_fec_efec_ries_pol_mrd( pCod_cia          => reg_a2109010_mrd.cod_cia,
                                                              pNum_Poliza       => reg_a2109010_mrd.num_poliza,
                                                              pNum_Renovaciones => 0,
                                                              pNum_Riesgo       => reg_a2109010_mrd.num_riesgo );
          --
          l_meses_vig := months_between( l_fec_vcto_riesgo, l_fec_efec_riesgo_v );
          --
          -- Buscar los Controles Tecnicos, por cada riesgo:
          l_txt_error_ct := NULL;
          IF reg_a2109010_mrd.tip_situ = '6' THEN  -- Version : 1.17
              l_txt_error_ct := f_trae_error_CT(reg_a2109010_mrd.COD_CIA,
                                                reg_a2109010_mrd.NUM_POLIZA,
                                                reg_a2109010_mrd.NUM_RIESGO);
          END IF;
          --
          -- Buscar los Errores a nievel de Polizas, Version : 1.03
          l_txt_error_pol := NULL;
          IF reg_a2109010_mrd.tip_situ = '4' THEN  -- Version : 1.17
              l_txt_error_pol := f_trae_error_POL(reg_a2109010_mrd.FEC_TRATAMIENTO,
                                                  reg_a2109010_mrd.NUM_ORDEN,
                                                  g_tip_mvto_batch,
                                                  reg_a2109010_mrd.COD_CIA,
                                                  reg_a2109010_mrd.NUM_POLIZA,
                                                  reg_a2109010_mrd.NUM_RIESGO);
          END IF;
          --
          -- Se quitaron los campos NOM_:
          INSERT INTO a2109010
            ( COD_CIA               ,  NUM_POLIZA            ,  MES                   ,  ANIO                  ,
              COD_RAMO              ,  NUM_SPTO              ,  NUM_APLI              ,  NUM_SPTO_APLI         ,
              NUM_POLIZA_GRUPO      ,  COD_PLAN              ,  COD_MODALIDAD         ,
              COD_MODALIDAD_REN     ,  CANT_RIESGOS          ,  NUM_RIESGO            ,
              COD_TIP_VEHI          ,  TIP_DOCUM             ,  COD_DOCUM             ,
              COD_MARCA             ,  COD_MODELO            ,  COD_SUB_MODELO        ,  ANIO_MODELO           ,
              NUM_CHASIS            ,  SUMA_ASEG             ,  SUMA_ASEG_REN         ,  PRIMA                 ,
              PRIMA_REN             ,  PRIMA_PREREN          ,  NUEVA_DIF_PRIMA_REN   ,  NUEVA_VAR_PRIMA       ,
              PRIMANETAFACTURADA    ,  TASA                  ,  TASA_REN              ,  NUEVA_TASA            ,
              DNR                   ,  DNR_REN               ,  VARIACION_VALOR       ,  VARIACION_VALOR_REN   ,
              DIFERENCIA            ,  DIFERENCIA_REN        ,  EVOLUCION             ,  EVOLUCION_REN         ,
              VARIACION             ,  VARIACION_REN         ,  DESC_COMERCIAL        ,  DESC_COMERCIAL_REN    ,
              MCA_SINIESTROS        ,  NUM_SINIESTROS        ,  SINI_PAG              ,  SINI_POR_PAG          ,
              NUM_SINI_MENORES      ,  NUM_SINI_MAYORES      ,  IMP_SINIESTROS        ,
              MCA_SIN_MAYOR_CERO    ,  FACTOR_RECARGO        ,  FACTOR_AJUSTE         ,  FEC_EFEC_RIESGO       ,
              FEC_VCTO_RIESGO       ,  FEC_TRATAMIENTO       ,  NUM_ORDEN             ,
              CATEGORIA             ,  PCT_CATEGORIA         ,
              COD_ZONA_VEHI         ,
              COD_USO_VEHI          ,  NUM_MATRICULA         ,  COD_CUADRO_COM        ,
              COD_OFICIAL           ,  TIP_BENEF             ,
              TIP_DOCUM_BENEF       ,  COD_DOCUM_BENEF       ,  IMPORTE_ENDOSO        ,
              COD_FRACC_PAGO        ,  PCT_DESC_COM_POL      ,  EQUIPO_GAS            ,  TIP_AEROAMBULANCIA    ,
              TIP_ESTATUS_RIESGO    , IND_SINI_ACUMULADO     ,  MESES_VIG             ,  TXT_ERROR_CT          ,
              MCA_INH               , COD_USR                ,  FEC_ACTU              ,  TXT_ERROR_POL )  -- Version : 1.03
          VALUES
            ( reg_a2109010_mrd.COD_CIA               ,  reg_a2109010_mrd.NUM_POLIZA            ,  reg_a2109010_mrd.MES                   ,  reg_a2109010_mrd.ANIO                  ,
              reg_a2109010_mrd.COD_RAMO              ,  reg_a2109010_mrd.NUM_SPTO              ,  reg_a2109010_mrd.NUM_APLI              ,  reg_a2109010_mrd.NUM_SPTO_APLI         ,
              reg_a2109010_mrd.NUM_POLIZA_GRUPO      ,  l_COD_PLAN_AUTO                        ,  l_COD_MODALIDAD                        ,
              l_COD_MODALIDAD_REN                    ,  reg_a2109010_mrd.CANT_RIESGOS          ,  reg_a2109010_mrd.NUM_RIESGO            ,
              l_COD_TIP_VEHI                         ,  reg_a2109010_mrd.TIP_DOCUM             ,  reg_a2109010_mrd.COD_DOCUM             ,
              l_COD_MARCA                            ,  l_COD_MODELO                           ,  l_COD_SUB_MODELO                       ,  l_ANIO_MODELO           ,
              l_NUM_CHASIS                           ,  l_SUMA_ASEG                            ,  l_SUMA_ASEG_REN                        ,  l_PRIMA                 ,
              l_PRIMA_REN                            ,  l_PRIMA_PREREN                         ,  l_NUEVA_DIF_PRIMA_REN                  ,  l_NUEVA_VAR_PRIMA       ,
              l_PRIMANETAFACTURADA                   ,  l_TASA                                 ,  l_TASA_REN                             ,  l_NUEVA_TASA            ,
              l_DNR                                  ,  l_DNR_REN                              ,  l_VARIACION_VALOR                      ,  l_VARIACION_VALOR_REN   ,
              l_DIFERENCIA                           ,  l_DIFERENCIA_REN                       ,  l_EVOLUCION                            ,  l_EVOLUCION_REN         ,
              l_VARIACION                            ,  l_VARIACION_REN                        ,  l_DESC_COMERCIAL                       ,  l_DESC_COMERCIAL_REN    ,
              l_MCA_SINIESTROS                       ,  l_NUM_SINIESTROS                       ,  l_SINI_PAG                             ,  l_SINI_POR_PAG          ,
              l_NUM_SINI_MENORES                     ,  l_NUM_SINI_MAYORES                     ,  l_IMP_SINIESTROS                       ,
              l_MCA_SINI_MAYOR_CERO                  ,  reg_a2109010_mrd.FACTOR_RECARGO        ,  reg_a2109010_mrd.FACTOR_AJUSTE         ,  l_FEC_EFEC_RIESGO       ,
              l_FEC_VCTO_RIESGO                      ,  reg_a2109010_mrd.FEC_TRATAMIENTO       ,  reg_a2109010_mrd.NUM_ORDEN             ,
              reg_a2109010_mrd.CATEGORIA             ,  l_PCT_CATEGORIA                        ,
              l_COD_ZONA_VEHI                        ,
              l_COD_USO_VEHI                         ,  l_NUM_MATRICULA                        ,  reg_a2109010_mrd.COD_CUADRO_COM        ,
              l_COD_OFICIAL                          ,  reg_a2109010_mrd.TIP_BENEF             ,
              reg_a2109010_mrd.TIP_DOCUM_BENEF       ,  reg_a2109010_mrd.COD_DOCUM_BENEF       ,  reg_a2109010_mrd.IMPORTE_ENDOSO        ,
              reg_a2109010_mrd.COD_FRACC_PAGO        ,  l_PCT_DESC_COM_POL                     ,  l_COD_EQUIPO_GAS                       ,  l_TIP_AEROAMBULANCIA    ,
              l_tip_estatus_riesgo                   ,  l_ind_sini_acumulado                   ,  l_meses_vig                            ,  l_txt_error_ct          ,
              'N'                                    ,  reg_a2109010_mrd.COD_USR               ,  TRUNC(SYSDATE)                         ,  l_txt_error_pol);   -- Version : 1.03
          --
          EXCEPTION WHEN OTHERS THEN
            -- Fec. 9-Jul-15, Version : 1.03 (OFIC0)
            RAISE_APPLICATION_ERROR ( -20000, 'Error insertando en a2109010 ' ||
                                      reg_a2109010_mrd.num_poliza || ' ' || SQLERRM );
        END;
        --
        -- El proceso (em_p_preren_gen_mrd) fue movido. Fec. 1-jun-15, Version 1.03
        --
      END LOOP;
      CLOSE cl_renovacion;
      --
    END p_inserta_a2109010; -- Fin p_inserta_a2109010_mrd
    --
    -- ------------------------------------------------------------
    --
    /**
    || Procedimiento para el monto de prima factura
    */
    --
    PROCEDURE p_total_prima_facturada( lp_prima           OUT a2109010_mrd.prima         %TYPE ,
                                        lp_prima_ren       OUT a2109010_mrd.prima_ren     %TYPE ,
                                        lp_prima_preren    OUT a2009030_mrd.prima_preren  %TYPE
                                      ) IS
    BEGIN
      --
        lp_prima                := trn_k_global.devuelve('ren_prima');
        lp_prima_ren            := trn_k_global.devuelve('ren_prima_ren');
        lp_prima_preren         := trn_k_global.devuelve('ren_prima_preren');
      --
    END p_total_prima_facturada;
    --
    -- ------------------------------------------------------------
    --  Fecha: 29-Oct-14
    --  Nota : Procedimiento para renovar las polizas desde JAVA
    -- ------------------------------------------------------------
    PROCEDURE p_renovar_java  IS
      --
      k_tip_mvto_batch_pre    a2000500.tip_mvto_batch%TYPE := 2;
      l_tip_mvto_batch        a2000500.tip_mvto_batch%TYPE := 1;
      l_fila                  BINARY_INTEGER;
      l_num_poliza            a2000500.num_poliza%TYPE := '999'; -- Version : 1.01
      l_existe                BOOLEAN;  -- Version : 1.01
      --
      CURSOR   cl_a2000500 ( pFec_tratamiento    a2000500.fec_tratamiento%TYPE,
                            pNum_Orden          a2000500.num_orden%TYPE,
                            pTip_Mvto_Batch     a2000500.tip_mvto_batch%TYPE,
                            pNum_Poliza         a2000500.num_poliza%TYPE,
                            pCod_Cia            a2000500.cod_cia%TYPE
                          ) IS
        SELECT a.*, rowid
          FROM a2000500 a
        WHERE fec_tratamiento = pFec_tratamiento
          AND num_orden       = pNum_Orden
          AND tip_mvto_batch  = pTip_Mvto_Batch
          AND num_poliza      = pNum_Poliza
          AND cod_cia         = pCod_Cia
          AND NOT EXISTS (SELECT 1   -- Version : 1.01 (Renovar las que no tengan error)
                            FROM a2000520 b
                            WHERE b.fec_tratamiento = a.fec_tratamiento
                              AND b.num_poliza      = a.num_poliza
                          )
          AND EXISTS (SELECT 1   -- Version : 1.01 (Para que el EM_K_BATCH_TRN, no cancele, deja TIP_SITU=7)
                        FROM r2000030 b
                        WHERE b.cod_cia    = a.cod_cia
                          AND b.num_poliza = a.num_poliza
                      )
          AND EXISTS (SELECT 1   -- Version : 1.01 (Para que no ejecute las renovadas - 5)
                        FROM a2009030 b
                        WHERE b.fec_tratamiento = a.fec_tratamiento
                          AND b.num_poliza      = a.num_poliza
                          AND b.tip_estatus     = 1
                      )
          AND NOT EXISTS (SELECT 1   -- Version : 1.02 (Que no haya Control Tecnico sin autorizaciaon en Pre-Renovacion)
                            FROM r2000221 b
                            WHERE b.cod_cia    = a.cod_cia
                              AND b.num_poliza = a.num_poliza
                              AND b.mca_autorizacion = 'N'
                          );
      --
      -- Fec. 24-Feb-15, Version : 1.01 (Verifica Poliza ya Renovada)
      CURSOR cl_a2000500_r (  pFec_tratamiento    a2000500.fec_tratamiento%TYPE,
                              pNum_Orden          a2000500.num_orden%TYPE,
                              pTip_Mvto_Batch     a2000500.tip_mvto_batch%TYPE,
                              pNum_Poliza         a2000500.num_poliza%TYPE,
                              pCod_Cia            a2000500.cod_cia%TYPE
                          ) IS
        SELECT a.*, rowid
          FROM a2000500 a
        WHERE fec_tratamiento = pFec_tratamiento
          AND num_orden       = pNum_Orden
          AND tip_mvto_batch  = pTip_Mvto_Batch
          AND num_poliza      = pNum_Poliza
          AND cod_cia         = pCod_Cia
          AND NOT EXISTS (SELECT 1
                            FROM a2000520 b
                            WHERE b.fec_tratamiento = a.fec_tratamiento
                              AND b.num_poliza      = a.num_poliza
                          )
          AND EXISTS (SELECT 1
                        FROM a2009030 b
                        WHERE b.fec_tratamiento = a.fec_tratamiento
                          AND b.num_poliza      = a.num_poliza
                          AND b.tip_estatus     = 1
                      );
      --
      reg_a2000500 cl_a2000500%ROWTYPE;
      --
    BEGIN
      --
      FOR l_fila IN 1..g_tb_a2109010_mrd.count LOOP
        --
        OPEN cl_a2000500( g_tb_a2109010_mrd( l_fila ).fec_tratamiento,
                          g_tb_a2109010_mrd( l_fila ).num_orden,
                          k_tip_mvto_batch_pre,
                          g_tb_a2109010_mrd( l_fila ).num_poliza,
                          g_tb_a2109010_mrd( l_fila ).cod_cia );
        FETCH cl_a2000500 INTO reg_a2000500;
        l_existe := cl_a2000500%FOUND;   -- Version : 1.01
        CLOSE cl_a2000500;
        --
        -- M.R., Version : 1.01 (Listas a renovar)
        IF l_existe AND l_num_poliza != g_tb_a2109010_mrd( l_fila ).num_poliza THEN
            --
            l_num_poliza:= g_tb_a2109010_mrd( l_fila ).num_poliza;
            --
            trn_k_global.asigna ( 'FEC_TRATAMIENTO',      to_char( reg_a2000500.fec_tratamiento,'ddmmyyyy') );
            trn_k_global.asigna ( 'JBNUM_ORDEN',          to_char ( reg_a2000500.num_orden ) );
            trn_k_global.asigna ( 'JBCOD_CIA',            reg_a2000500.cod_cia );
            trn_k_global.asigna ( 'TIP_MVTO_BATCH',       l_tip_mvto_batch ); -- 1
            trn_k_global.asigna ( 'JBMCA_REPROCESO',      'S' );
            trn_k_global.asigna ( 'JBMCA_ABORTA_EMISION', 'N' );
            trn_k_global.asigna ( 'JBMCA_MULTIHILO',      'N' );
            trn_k_global.asigna ( 'JBCOD_SECTOR',         NULL );
            trn_k_global.asigna ( 'JBCOD_RAMO',           NULL );
            trn_k_global.asigna ( 'JBCOD_NIVEL1',         NULL );
            trn_k_global.asigna ( 'JBCOD_NIVEL2',         NULL );
            trn_k_global.asigna ( 'JBCOD_NIVEL3',         NULL );
            trn_k_global.asigna ( 'JBCOD_AGT',            NULL );
            trn_k_global.asigna ( 'JBNUM_POLIZA',         reg_a2000500.num_poliza );
            trn_k_global.asigna ( 'JBNUM_POLIZA_GRUPO',   NULL );
            trn_k_global.asigna ( 'JBNUM_POLIZA_CLIENTE', NULL );
            trn_k_global.asigna ( 'JBCANT_REGISTROS',     1 );
            trn_k_global.asigna ( 'JBMAX_NUM_RIESGOS',    reg_a2000500.num_riesgos );
            trn_k_global.asigna ( 'JBMCA_GRUPOS',         NULL );
            trn_k_global.asigna ( 'JBCOD_SPTO',           reg_a2000500.cod_spto );
            trn_k_global.asigna ( 'JBSUB_COD_SPTO',       reg_a2000500.sub_cod_spto );
            --
            -- Fecha: 6-Ene-17, Version : 1.09
            p_actualiza_fec_r2000030(reg_a2000500.cod_cia,
                                    reg_a2000500.num_poliza);
            --
            BEGIN
              EM_K_BATCH.P_PROCESO;
            EXCEPTION WHEN OTHERS THEN
              NULL;
            END;
            --
            -- Fec. 24-Feb-15, Version : 1.01 (Verifica que la Poliza este renovada)
            OPEN cl_a2000500_r ( reg_a2000500.fec_tratamiento,
                                reg_a2000500.num_orden,
                                l_tip_mvto_batch,
                                reg_a2000500.num_poliza,
                                reg_a2000500.cod_cia  );
            FETCH cl_a2000500_r INTO reg_a2000500;
            IF cl_a2000500_r%FOUND AND reg_a2000500.tip_situ IN (  '3', '6' ) THEN --V1.16 cejv  comillas
              --
              UPDATE a2009030
                  SET tip_estatus = 5
                WHERE num_poliza  = reg_a2000500.num_poliza
                  AND mes         = g_tb_a2109010_mrd( l_fila ).mes
                  AND anio        = g_tb_a2109010_mrd( l_fila ).anio;
              COMMIT;
              --
            END IF;
            CLOSE cl_a2000500_r;
            --
        END IF;  -- Fin l_existe
        --
      END LOOP;
      --
    END p_renovar_java; -- Fin : p_renovar;
    --
    -- ----------------------------------------------------------------------
    -- Autor : Manuel Rod.                                    Version : 1.03
    -- Fecha : 15-Abr-15
    -- Nota  : Indentificar las polizas autorizadas por Cobros y renovarlas
    --       : por Control M. Nombre archivo --> renovar_pol_Clt_M_auto.sh).
    -- ----------------------------------------------------------------------
    PROCEDURE p_renovar_pol_Ctl_M_Cobros IS
      --
      l_cod_cia               a1000900.cod_cia       %TYPE := 6;
      l_cod_ramo              a2000030.cod_ramo      %type;
      l_anio                  a2109010_mrd.anio      %TYPE;
      l_mes                   a2109010_mrd.mes       %TYPE;
      --
      -- Buscar Usuario Renueva Automovil:
      CURSOR C_G2309005 IS
        SELECT cod_usr_vida
          FROM G2309005
        WHERE cod_cia        = l_cod_cia
          AND cod_depto      = 'AU'
          AND mca_ren_poliza = 'S'
          AND mca_usr_def    = 'S' -- Usuario prinicipal
          AND mca_inh        = 'N'
          ORDER BY 1;
      --
      -- Buscar Ramos Caribian:
      CURSOR C_TA999003 IS
        SELECT TO_NUMBER(val_campo) val_campo
          FROM TA999003
        WHERE cod_cia   = l_cod_cia
          AND cod_campo = 'COD_RAMO_AUTOMOVIL'
          AND mca_inh   = 'N'
        ORDER BY 1;
      --
      -- Buscar Polizas Pre-Renovadas y Autorizadas por Cobros:
      CURSOR cl_r2000030 IS
        SELECT a.cod_cia, a.num_poliza,
              b.fec_tratamiento, b.num_orden, b.num_riesgos, b.cod_spto, b.sub_cod_spto
          FROM a2000500 b,
              r2000030 a
        WHERE a.cod_cia          = l_cod_cia
          AND a.cod_ramo         = l_cod_ramo
          AND a.mca_provisional  = 'N'
          AND a.fec_autorizacion = TRUNC(SYSDATE)
          --
          AND b.cod_cia        = a.cod_cia
          AND b.num_poliza     = a.num_poliza
          AND b.tip_situ       = '6'   -- Control Tecnico --V1.16 cejv  comillas
          AND b.tip_mvto_batch = 2   -- Pre-Renovacion
          --
          AND EXISTS (SELECT *
                        FROM r2000221 c
                        WHERE c.cod_cia    = a.cod_cia
                          AND c.num_poliza = a.num_poliza
                          AND c.num_spto   = a.num_spto
                          AND c.fec_autorizacion IS NOT NULL
                          AND c.mca_autorizacion = 'S'
                      )
          AND NOT EXISTS (SELECT 1   -- Que el Spto a renovar no exista en A2000030, activo
                            FROM a2000030 d
                            WHERE d.cod_cia            = a.cod_cia
                              AND d.num_poliza         = a.num_poliza
                              AND d.mca_poliza_anulada = 'N'
                              AND d.mca_spto_anulado   = 'N'
                              AND d.fec_efec_poliza    = a.fec_efec_poliza
                              AND d.fec_vcto_poliza    = a.fec_vcto_poliza
                          )
          AND EXISTS (SELECT 1
                        FROM a2009030 e
                        WHERE e.fec_tratamiento = b.fec_tratamiento
                          AND e.num_poliza      = b.num_poliza
                          AND e.tip_estatus     = 1
                      ); -- Renovar
      --
      -- Polizas para Procesos Masivos:
      CURSOR cl_a2000500 ( pFec_tratamiento a2000500.fec_tratamiento%TYPE, pNum_Orden a2000500.num_orden%TYPE,
                            pTip_Mvto_Batch a2000500.tip_mvto_batch%TYPE, pNum_Poliza a2000500.num_poliza%TYPE,
                            pCod_Cia a2000500.cod_cia%TYPE) IS
        SELECT a.*, rowid
          FROM a2000500 a
        WHERE fec_tratamiento = g_fec_tratamiento
          AND num_orden       = pNum_Orden
          AND tip_mvto_batch  = pTip_Mvto_Batch
          AND num_poliza      = pNum_Poliza
          AND cod_cia         = pCod_Cia;
      --
      reg_a2000500 cl_a2000500%ROWTYPE;
      --
      CURSOR cl_a2000500_re IS
        SELECT DECODE(tip_situ, '1', 'No Procesada/Rechazada   ',   -- Fec. 17-Jun-15, Version : 1.03 --V1.16 cejv  comillas
                                '3', 'Polizas Renovadas        ',--V1.16 cejv  comillas
                                '4', 'Polizas con Errores      ',--V1.16 cejv  comillas
                                '6', 'Polizas Control Tecnico  ',--V1.16 cejv  comillas
                                    'Tipo Situs sin Definir   '||TIP_SITU) tip_situ,
                count(*) cantidad
          FROM a2000500 a
        WHERE fec_tratamiento    = g_fec_tratamiento
          AND cod_cia            = l_cod_cia
          AND tip_mvto_batch     = 1     -- Renovada
          AND EXISTS (SELECT 1 
                        FROM A2009030 b
                        WHERE b.num_poliza  = a.num_poliza
                          AND b.mes         = substr(to_char(a.fec_tratamiento,'ddmmyyyy'),3,2)
                          AND b.anio        = substr(to_char(a.fec_tratamiento,'ddmmyyyy'),5,4)
                          AND b.tip_estatus = 5
                      ) -- Renovada
          AND cod_ramo IN (SELECT TO_NUMBER(val_campo) val_campo
                              FROM TA999003
                            WHERE cod_cia   = a.cod_cia
                              AND cod_campo = 'COD_RAMO_AUTOMOVIL'
                              AND mca_inh   = 'N'
                          )
          GROUP BY tip_situ
          ORDER BY 1;
      --
    BEGIN
      --
      -- Asignacion de valores:
      g_cod_agt        := NULL;
      g_tip_cuenta     := 21;
      g_mca_un_ramo    := 'N';
      g_mca_ctl_m_ren  := 'S';
      --
      trn_k_global.asigna ( 'cod_idioma', 'ES' );
      trn_k_global.asigna ( 'COD_CIA', l_cod_cia );
      --
      -- Primer usuario que Renueva Auto:
      OPEN  C_G2309005;
      FETCH C_G2309005 INTO g_cod_usr;
      IF C_G2309005%NOTFOUND THEN
          g_cod_usr := 'P0030991'; -- Donny
      END IF;
      CLOSE C_G2309005;
      trn_k_global.asigna ('COD_USR', g_cod_usr);
      --
      -- Buscar el nombre del ambiente:
      g_nom_ambiente := f_busca_ambiente;
      --
      l_concat := chr(13)||chr(13)||'('||g_nom_ambiente||') '||'Archivo de Detalle por Ramos, para Proceso de Renovacion Auto, por Control M '||chr(13)||chr(13);
      --
      l_concat := l_concat|| '       Numero de Poliza'|| chr(13);
      l_concat := l_concat|| '       -----------------------'|| chr(13); -- Version : 1.13
      --
      -- Buscar los ramos que renuevan:
      FOR X IN C_TA999003 LOOP
          --
          l_cod_ramo       := X.val_campo;
          g_cant_renovadas := 0;
          l_concat         := l_concat||chr(13);  -- Version : 1.13 (Agregar un espcio)
          --
          -- Polizas autorizads y listas a Renovar:
          FOR I IN cl_r2000030 LOOP
            --
            g_fec_tratamiento := I.fec_tratamiento;
            --
            l_mes  := to_char(g_fec_tratamiento,'mm');
            l_anio := to_char(g_fec_tratamiento,'rrrr');
            --
            trn_k_global.asigna ( 'FEC_TRATAMIENTO',      to_char(I.fec_tratamiento,'ddmmyyyy') );
            trn_k_global.asigna ( 'JBNUM_ORDEN',          to_char(I.num_orden) );
            trn_k_global.asigna ( 'JBCOD_CIA',            I.cod_cia );
            trn_k_global.asigna ( 'TIP_MVTO_BATCH',       l_tip_mvto_batch ); -- 1 Para Renovar
            trn_k_global.asigna ( 'JBMCA_REPROCESO',      'S' );
            trn_k_global.asigna ( 'JBMCA_ABORTA_EMISION', 'N' );
            trn_k_global.asigna ( 'JBMCA_MULTIHILO',      'N' );
            trn_k_global.asigna ( 'JBCOD_SECTOR',         NULL );
            trn_k_global.asigna ( 'JBCOD_RAMO',           NULL );
            trn_k_global.asigna ( 'JBCOD_NIVEL1',         NULL );
            trn_k_global.asigna ( 'JBCOD_NIVEL2',         NULL );
            trn_k_global.asigna ( 'JBCOD_NIVEL3',         NULL );
            trn_k_global.asigna ( 'JBCOD_AGT',            NULL );
            trn_k_global.asigna ( 'JBNUM_POLIZA',         I.num_poliza );
            trn_k_global.asigna ( 'JBNUM_POLIZA_GRUPO',   NULL );
            trn_k_global.asigna ( 'JBNUM_POLIZA_CLIENTE', NULL );
            trn_k_global.asigna ( 'JBCANT_REGISTROS',     1 );
            trn_k_global.asigna ( 'JBMAX_NUM_RIESGOS',    I.num_riesgos );
            trn_k_global.asigna ( 'JBMCA_GRUPOS',         NULL );
            trn_k_global.asigna ( 'JBCOD_SPTO',           I.cod_spto );
            trn_k_global.asigna ( 'JBSUB_COD_SPTO',       I.sub_cod_spto );
            --
            -- Fecha: 6-Ene-17, Version : 1.09
            p_actualiza_fec_r2000030(I.cod_cia,
                                      I.num_poliza);
            --
            -- Ejecuta el proceso masivo
            BEGIN
              EM_K_BATCH.P_PROCESO;
            EXCEPTION WHEN OTHERS THEN
              dbms_output.put_line( sqlerrm || ' exception .. del proceso em_k_batch .. reg_a2000500.num_poliza => ' || reg_a2000500.num_poliza );
            END;
            --
            -- Cambiar el campo TIP_ESTATUS, a Renovada:
            OPEN  cl_a2000500(I.fec_tratamiento, I.num_orden, l_tip_mvto_batch, I.num_poliza, l_cod_cia);
            FETCH cl_a2000500 INTO reg_a2000500;
            IF cl_a2000500%FOUND AND reg_a2000500.tip_situ IN ('3', '6') THEN --V1.16 cejv  comillas
                --
                g_cant_renovadas := g_cant_renovadas + 1;
                --
                UPDATE a2009030_mrd
                  SET tip_estatus = 5  -- Renovada
                WHERE num_poliza = I.num_poliza
                  AND mes        = l_mes
                  AND anio       = l_anio;
                COMMIT;
                --
                -- Imprimir la poliza renovada:
                l_concat := l_concat|| '       '|| I.num_poliza|| chr(13);
                --
            END IF;
            CLOSE cl_a2000500;
            --
          END LOOP;
          --
          --g_total_renovadas := g_cant_renovadas + 1; -- Version : 1.13
          g_total_renovadas := g_total_renovadas + g_cant_renovadas; -- Version : 1.13
          --
          IF g_cant_renovadas > 0 THEN
            --
            l_concat := l_concat||chr(13);
            l_concat := l_concat|| '       Ramo : '|| l_Cod_Ramo||'    Cantidad Polizas : '||g_cant_renovadas|| chr(13);
            --
          END IF;
        --
      END LOOP;
      --
      -- Envio, por correo, de las polizas renovadas.
      IF g_total_renovadas > 0 THEN
        --
        l_concat := l_concat|| '                                                            -------------- '|| chr(13);
        l_concat := l_concat|| '                                                    Total : '||g_total_renovadas|| chr(13);
        l_concat := l_concat||chr(13);
        l_concat := l_concat||chr(13);
        l_concat := l_concat|| '       ESTADO DE SITUACION           CANTIDAD  '|| chr(13);
        l_concat := l_concat|| '       --------------------------------        ---------------  '|| chr(13);
        --
        FOR I IN cl_a2000500_re LOOP
          --
          l_concat := l_concat|| '       '|| I.Tip_Situ||'             '||I.Cantidad|| chr(13);
          --
        END LOOP;
        --
        l_concat := l_concat||chr(13);
        l_concat := l_concat||chr(13);
        l_concat := l_concat|| 'Favor de verificar las polizazs Renovadas por CONTROL-M, autorizadas por Cobros. Gracias.'|| chr(13);
        --
        -- Enviar el Correo:
        p_envia_correo_cargas(l_cod_cia,
                              'RENOVAC_AUT_AUTO',
                              l_concat);
        --
      END IF;
      --
    END p_renovar_pol_Ctl_M_Cobros;
    --
    -- ----------------------------------------------------------------------
    -- Autor : Manuel Rod.                                    Version : 1.00
    -- Fecha : 30-Abr-14
    -- Nota  : Renovar todos los ramos si el JBCOD_RAMO se deja nulo.
    --       : Se invoca a traves de la tarea (MRDEA00018).
    -- ----------------------------------------------------------------------
    PROCEDURE p_renovar_polizas_Tarea IS
      --
      -- Buscar Ramos Caribian:
      CURSOR C_TA999003 IS
        SELECT TO_NUMBER(val_campo) val_campo
          FROM TA999003
          WHERE cod_cia   = g_cod_cia
            AND cod_ramo  = NVL(g_cod_ramo, cod_ramo)
            AND cod_campo = 'COD_RAMO_AUTOMOVIL'
            AND mca_inh   = 'N'
        ORDER BY 1;
      --
      CURSOR cl_a2000500 IS
        SELECT DECODE(tip_situ, '1', 'No Procesada/Rechazada   ',   -- Fec. 17-Jun-15, Version : 1.03--V1.16 cejv  comillas
                                '3', 'Polizas Renovadas        ',   -- Version : 1.01--V1.16 cejv  comillas
                                '4', 'Polizas con Errores      ',--V1.16 cejv  comillas
                                '6', 'Polizas Control Tecnico  ',--V1.16 cejv  comillas
                                    'Tipo Situs sin Definir   '||TIP_SITU) tip_situ,
                count(*) cantidad
          FROM a2000500 a
          WHERE fec_tratamiento = g_fec_tratamiento
            AND cod_cia         = g_cod_cia
            AND cod_ramo        = g_cod_rm   -- Version : 1.01
            AND tip_mvto_batch  = 1 -- Renovada
            AND EXISTS (SELECT 1 FROM A2009030 b
                        WHERE b.num_poliza  = a.num_poliza
                          AND b.mes         = substr(to_char(a.fec_tratamiento,'ddmmyyyy'),3,2)
                          AND b.anio        = substr(to_char(a.fec_tratamiento,'ddmmyyyy'),5,4)
                          AND b.tip_estatus = 5
                      ) -- Renovada
        GROUP BY tip_situ
        UNION
        SELECT DECODE(tip_situ, '1', 'No Procesada/Rechazada   ',   -- Fec. 17-Jun-15, Version : 1.03--V1.16 cejv  comillas
                                '3', 'Polizas Renovadas        ',   -- Version : 1.01--V1.16 cejv  comillas
                                '4', 'Polizas con Errores      ',--V1.16 cejv  comillas
                                '6', 'Polizas Control Tecnico  ',--V1.16 cejv  comillas
                                    'Tipo Situs sin Definir   '||TIP_SITU) tip_situ,
                count(*) cantidad
          FROM a2000500 a
          WHERE fec_tratamiento = g_fec_tratamiento
            AND cod_cia         = g_cod_cia
            AND tip_mvto_batch  = 1 -- Renovada
            AND g_cod_rm       IS NULL   -- Version : 1.01
            AND EXISTS (SELECT 1 FROM A2009030 b
                        WHERE b.num_poliza  = a.num_poliza
                          AND b.mes         = substr(to_char(a.fec_tratamiento,'ddmmyyyy'),3,2)
                          AND b.anio        = substr(to_char(a.fec_tratamiento,'ddmmyyyy'),5,4)
                          AND b.tip_estatus = 5
                      ) -- Renovada
            AND cod_ramo IN (SELECT TO_NUMBER(val_campo) val_campo
                              FROM TA999003
                              WHERE cod_cia   = g_cod_cia
                                AND cod_campo = 'COD_RAMO_AUTOMOVIL'
                                AND mca_inh   = 'N'
                            )
        GROUP BY tip_situ
        ORDER BY 1;
      --
    BEGIN
      --
      -- Parametros de la Tarea : MRDEA00018
      g_cod_cia         := trn_k_global.devuelve('JBCOD_CIA');
      g_num_poliza      := trn_k_global.devuelve('JBNUM_POLIZA');
      g_cod_ramo        := trn_k_global.devuelve('JBCOD_RAMO');
      g_anio            := trn_k_global.devuelve('JBANIO');
      g_mes             := trn_k_global.devuelve('JBMES');
      g_cod_agt         := trn_k_global.devuelve('JBCOD_AGT');
      g_tip_cuenta      := trn_k_global.devuelve('TIP_CUENTA');
      g_tip_mvto_batch  := trn_k_global.devuelve('TIP_MVTO_BATCH');
      g_cod_rm          := trn_k_global.devuelve('JBCOD_RAMO');  -- Version : 1.01
      g_cod_usr         := trn_k_global.devuelve('JBCOD_USR');  -- Version : 1.17
      --
      IF g_cod_usr IS NULL THEN -- Version : 1.17
        g_cod_usr := USER;  -- Version : 1.03
      END IF;
      --
      trn_k_global.asigna ('COD_USR', g_cod_usr);  -- Version : 1.03
      g_num_poliza_grupo := trn_k_global.devuelve('JBNUM_POLIZA_GRUPO'); -- Version : 1.03
      --
      g_fec_tratamiento := to_date( '01'|| LPAD( g_mes, 2, '0' ) || g_anio, 'ddmmyyyy' );
      --
      -- M.R., Version : 1.01 (Buscar el nombre del ambiente)
      g_nom_ambiente := f_busca_ambiente;
      --
      IF g_cod_ramo IS NOT NULL THEN
          --
          -- M.R., Version : 1.01 (Se agrega g_nom_ambiente)
          l_concat := chr(13)||chr(13)||'('||g_nom_ambiente||') '||'Archivo de Detalle para el Ramo : '||g_Cod_Ramo||'  Tarea Renovar: MRDEA00018'||chr(13)||chr(13);
          g_mca_un_ramo := 'S';
          --
          p_renovar_polizas_ramo;
          g_total_renovadas := g_cant_renovadas;
          --
      ELSE
          --
          -- M.R., Version : 1.01 (Se agrega g_nom_ambiente)
          l_concat := chr(13)||chr(13)||'('||g_nom_ambiente||') '||'Archivo de Detalle para varios Ramos. Tarea Renovar : MRDEA00018'||chr(13)||chr(13);
          --
          g_mca_un_ramo := 'N';
          FOR I IN C_TA999003 LOOP
            --
            g_cod_ramo       := I.val_campo;
            g_cant_renovadas := 0;
            --
            p_renovar_polizas_ramo;
            --
            g_total_renovadas := g_total_renovadas + g_cant_renovadas;
            --
          END LOOP;
          --
      END IF;
      --
      IF g_total_renovadas > 0 THEN
          IF g_mca_un_ramo = 'S' THEN
            trn_k_global.asigna( 'TXT_TAREA', 'CANTIDAD DE POLIZAS RENOVADAS, RAMO ('||g_cod_ramo||') CANT.: '||g_total_renovadas );
          ELSE
            trn_k_global.asigna( 'TXT_TAREA', 'CANTIDAD DE POLIZAS RENOVADAS, CANTIDAD TOTAL : '||g_total_renovadas );
          END IF;
      ELSE
          IF g_mca_un_ramo = 'S' THEN
            trn_k_global.asigna( 'TXT_TAREA', 'NO SE ENCONTRARON POLIZAS PARA RENOVAR, RAMO ('||g_cod_ramo||')' );
          ELSE
            trn_k_global.asigna( 'TXT_TAREA', 'NO SE ENCONTRARON POLIZAS PARA RENOVAR, EN NINGUN RAMO, VERIFIQUE.' );
          END IF;
      END IF;
      --
      -- Envio de correo Errores de la Carga.
      IF g_total_renovadas > 0 THEN
        --
        --l_concat := l_concat||chr(13);
        l_concat := l_concat|| '                                                            -------------- '|| chr(13);
        l_concat := l_concat|| '                                                    Total : '||g_total_renovadas|| chr(13);
        l_concat := l_concat||chr(13);
        l_concat := l_concat||chr(13);
        l_concat := l_concat|| '       ESTADO DE SITUACION         CANTIDAD  '|| chr(13);
        l_concat := l_concat|| '       --------------------------------        ---------------  '|| chr(13);
        --
        FOR I IN cl_a2000500 LOOP
          --
          l_concat := l_concat|| '       '|| I.Tip_Situ||'           '||I.Cantidad|| chr(13);
          --
        END LOOP;
        --
        l_concat := l_concat||chr(13);
        l_concat := l_concat||chr(13);
        l_concat := l_concat|| 'Favor de verificar las polizazs Renovadas por la Tarea. Gracias.'|| chr(13);
        --
      ELSE
        l_concat := l_concat||chr(13);
        l_concat := l_concat||chr(13);
        l_concat := l_concat|| 'No se encontraron Polizazs para Renovar, verificar. Por la Tarea. Gracias.'|| chr(13);
      END IF;
      --
      -- Enviar el Correo:
      p_envia_correo_cargas(g_cod_cia, 'RENOVAC_AUT_AUTO', l_concat);
      --
    END p_renovar_polizas_tarea;
    --
    -- ----------------------------------------------------------------------
    -- Autor : Manuel Rod.                                    Version : 1.00
    -- Fecha : 30-Abr-14
    -- Nota  : Renovar las Polizas por cada Ramo.
    -- ----------------------------------------------------------------------
    PROCEDURE p_renovar_polizas_ramo IS
      --
      -- Buscar Polizas Pre-Renovadas, Automovil: 30-Abr-14
      CURSOR cl_a2009030 IS
        SELECT *
          FROM a2009030 a -- Version : 1.03
          WHERE cod_ramo     = g_cod_ramo
            AND num_poliza   = NVL(g_num_poliza, num_poliza) -- Fec. 04-Mar-15, Version : 1.02
            AND (num_poliza_grupo = g_Num_Poliza_Grupo OR g_Num_Poliza_Grupo IS NULL) -- Version : 1.03
            AND anio         = g_anio
            AND mes          = g_mes
            AND tip_estatus  = 1   -- Polizas a Renovar
            AND NOT EXISTS (SELECT 1   -- Version : 1.03 (Renovar las que no tengan error)
                              FROM a2000520 b
                            WHERE b.fec_tratamiento = a.fec_tratamiento
                              AND b.num_poliza      = a.num_poliza
                          )
            AND EXISTS (SELECT 1   -- Version : 1.03 (Para que el EM_K_BATCH_TRN, no cancele, deja TIP_SITU=7)
                          FROM r2000030 b
                        WHERE b.cod_cia    = a.cod_cia
                          AND b.num_poliza = a.num_poliza
                      )
            AND NOT EXISTS (SELECT 1   -- Version : 1.03 (Que no haya Control Tecnico sin autorizaciaon en Pre-Renovacion)
                              FROM r2000221 b
                            WHERE b.cod_cia    = a.cod_cia
                              AND b.num_poliza = a.num_poliza
                              AND b.mca_autorizacion = 'N'
                          );
      --
      -- Polizas para Procesos Masivos:
      CURSOR cl_a2000500 (  pFec_tratamiento a2000500.fec_tratamiento%TYPE, pNum_Orden a2000500.num_orden%TYPE,
                            pTip_Mvto_Batch a2000500.tip_mvto_batch%TYPE, pNum_Poliza a2000500.num_poliza%TYPE,
                            pCod_Cia a2000500.cod_cia%TYPE
                        ) IS
        SELECT a.*, rowid
          FROM a2000500 a
        WHERE fec_tratamiento = g_fec_tratamiento
          AND num_orden       = pNum_Orden
          AND tip_mvto_batch  = pTip_Mvto_Batch
          AND num_poliza      = pNum_Poliza
          AND cod_cia         = pCod_Cia;
      --
      -- Fec. 24-Feb-15, Version : 1.01 (Verifica Poliza ya Renovada)
      CURSOR cl_a2000500_r ( pFec_tratamiento a2000500.fec_tratamiento%TYPE, pNum_Orden a2000500.num_orden%TYPE,
                              pTip_Mvto_Batch a2000500.tip_mvto_batch%TYPE, pNum_Poliza a2000500.num_poliza%TYPE,
                              pCod_Cia a2000500.cod_cia%TYPE
                            ) IS
        SELECT a.*, rowid
          FROM a2000500 a
        WHERE fec_tratamiento = g_fec_tratamiento
          AND num_orden       = pNum_Orden
          AND tip_mvto_batch  = pTip_Mvto_Batch
          AND num_poliza      = pNum_Poliza
          AND cod_cia         = pCod_Cia
          AND NOT EXISTS (SELECT 1
                            FROM a2000520 b
                            WHERE b.fec_tratamiento = a.fec_tratamiento
                              AND b.num_poliza      = a.num_poliza
                          );
      --
      reg_a2000500 cl_a2000500%ROWTYPE;
      --
    BEGIN
      --
      --
      g_cant_renovadas := 0;
      trn_k_global.asigna('mca_ter_tar','N');  -- Version : 1.02
      --
      -- Polizas a Renovar:
      FOR I IN cl_a2009030 LOOP
          --
          OPEN cl_a2000500( I.fec_tratamiento, I.num_orden,
                            l_tip_pre_renovacion, I.num_poliza, g_cod_cia );
          FETCH cl_a2000500 INTO reg_a2000500;
          IF cl_a2000500%FOUND THEN
            --
            g_cant_renovadas := g_cant_renovadas + 1;
            --
            trn_k_global.asigna ( 'FEC_TRATAMIENTO',      to_char(reg_a2000500.fec_tratamiento,'ddmmyyyy') );
            trn_k_global.asigna ( 'JBNUM_ORDEN',          to_char ( reg_a2000500.num_orden ) );
            trn_k_global.asigna ( 'JBCOD_CIA',            reg_a2000500.cod_cia );
            trn_k_global.asigna ( 'TIP_MVTO_BATCH',       l_tip_mvto_batch ); -- 1 Renovar
            trn_k_global.asigna ( 'JBMCA_REPROCESO',      'S' );
            trn_k_global.asigna ( 'JBMCA_ABORTA_EMISION', 'N' );
            trn_k_global.asigna ( 'JBMCA_MULTIHILO',      'N' );
            trn_k_global.asigna ( 'JBCOD_SECTOR',         NULL );
            trn_k_global.asigna ( 'JBCOD_RAMO',           NULL );
            trn_k_global.asigna ( 'JBCOD_NIVEL1',         NULL );
            trn_k_global.asigna ( 'JBCOD_NIVEL2',         NULL );
            trn_k_global.asigna ( 'JBCOD_NIVEL3',         NULL );
            trn_k_global.asigna ( 'JBCOD_AGT',            NULL );
            trn_k_global.asigna ( 'JBNUM_POLIZA',         reg_a2000500.num_poliza );
            trn_k_global.asigna ( 'JBNUM_POLIZA_GRUPO',   NULL );
            trn_k_global.asigna ( 'JBNUM_POLIZA_CLIENTE', NULL );
            trn_k_global.asigna ( 'JBCANT_REGISTROS',     1 );
            trn_k_global.asigna ( 'JBMAX_NUM_RIESGOS',    reg_a2000500.num_riesgos );
            trn_k_global.asigna ( 'JBMCA_GRUPOS',         NULL );
            trn_k_global.asigna ( 'JBCOD_SPTO',           reg_a2000500.cod_spto );
            trn_k_global.asigna ( 'JBSUB_COD_SPTO',       reg_a2000500.sub_cod_spto );
            --
            -- Fecha: 6-Ene-17, Version : 1.09
            p_actualiza_fec_r2000030(reg_a2000500.cod_cia,
                                      reg_a2000500.num_poliza);
            --
            -- Ejecuta el proceso masivo
            BEGIN
              EM_K_BATCH.P_PROCESO;
            EXCEPTION WHEN OTHERS THEN
              dbms_output.put_line( sqlerrm || ' exception .. del proceso em_k_batch .. reg_a2000500.num_poliza => ' || reg_a2000500.num_poliza );
            END;
            --
          END IF;
          CLOSE cl_a2000500;
          --
          -- Fec. 24-Feb-15, Version : 1.01 (Verifica que la Poliza este renovada)
          OPEN  cl_a2000500_r (I.fec_tratamiento, I.num_orden, l_tip_mvto_batch, I.num_poliza, g_cod_cia);
          FETCH cl_a2000500_r INTO reg_a2000500;
          IF cl_a2000500_r%FOUND AND reg_a2000500.tip_situ IN ('3', '6') THEN --V1.16 cejv  comillas
            --
            UPDATE a2009030_mrd
                SET tip_estatus = 5  -- Renovada
              WHERE num_poliza = I.num_poliza
                AND mes        = I.mes
                AND anio       = I.anio;
            COMMIT;  -- Version : 1.01
            --
          END IF;
          CLOSE cl_a2000500_r;
          --
      END LOOP;
      --
      IF g_cant_renovadas > 0 THEN
          --
          -- Fec. 11-Jun-15, Version : 1.03
          IF g_num_poliza_grupo IS NOT NULL THEN  -- Version : 1.13 (Mejora)
            l_concat := l_concat|| '       Ramo : '|| g_Cod_Ramo||'    Cantidad Polizas : '||g_cant_renovadas||'   Poliza Grupo : '||g_num_poliza_grupo|| chr(13);
          ELSIF g_num_poliza IS NOT NULL THEN  -- Version : 1.13 (Mejora)
            l_concat := l_concat|| '       Ramo : '|| g_Cod_Ramo||'    Cantidad Polizas : '||g_cant_renovadas||'   Poliza : '||g_num_poliza|| chr(13);
          ELSE
            l_concat := l_concat|| '       Ramo : '|| g_Cod_Ramo||'    Cantidad Polizas : '||g_cant_renovadas|| chr(13);
          END IF;
          --
      END IF;
      --
      trn_k_global.asigna('mca_ter_tar','S');  -- Version : 1.02
      --
    END p_renovar_polizas_ramo;
    --
    -- ------------------------------------------------------------
    --
    /**
    || Funci?n que busca el porciento por categoria de vehiculo
    */
    --
    FUNCTION f_pct_x_grupo_vehi ( p_Cod_Cia        taaut069_mrd.cod_cia        %TYPE ,
                                  p_Cod_Ramo       taaut069_mrd.cod_ramo       %TYPE ,
                                  p_Cod_Modalidad  taaut084_mrd.cod_modalidad  %type ,
                                  p_Cod_Marca      a2100400.cod_marca          %TYPE ,
                                  p_Cod_Modelo     a2100410.cod_modelo         %TYPE ,
                                  p_Cod_Sub_Modelo a2100420.cod_sub_modelo     %TYPE ,
                                  p_Fec_validez    taaut069_mrd.fec_ini_validez%TYPE 
                                ) RETURN taaut084_mrd.pct_ajuste%TYPE IS
        --
        l_Cod_Grupo         taaut069_mrd.cod_grupo        %type;
        l_Pct_Ajuste        taaut084_mrd.pct_ajuste       %type;
        --
        CURSOR cl_taaut069  IS
          SELECT cod_grupo
            FROM taaut069_mrd
          WHERE cod_cia         = p_Cod_cia
            AND cod_marca       = p_Cod_marca
            AND cod_modelo      = NVL( p_Cod_modelo, 999 )
            AND cod_ramo        = p_Cod_ramo
            AND cod_sub_modelo IN ( p_Cod_sub_modelo, 999 )
            AND p_fec_validez  BETWEEN fec_ini_validez AND fec_fin_validez
            AND mca_inh         = 'N';
        --
        CURSOR cl_taaut084 ( p_cod_grupo_vehi taaut084_mrd.cod_grupo%TYPE ) IS
          SELECT pct_ajuste
            FROM taaut084_mrd
          WHERE cod_cia        = p_cod_cia
            AND cod_grupo      = p_cod_grupo_vehi
            AND cod_ramo      IN ( p_cod_ramo,        999 )
            AND cod_modalidad IN ( p_cod_modalidad, 99999 )
            AND p_fec_validez BETWEEN fec_ini_validez AND fec_fin_validez
            AND mca_inh        = 'N'
          ORDER BY cod_ramo, cod_modalidad;
        --
      BEGIN
          --
          OPEN cl_taaut069;
          FETCH cl_taaut069 INTO l_Cod_Grupo;
          CLOSE cl_taaut069;
          --
          OPEN cl_taaut084( l_cod_grupo );
          FETCH cl_taaut084 INTO l_Pct_ajuste;
          CLOSE cl_taaut084;
          dbms_output.put_line( l_Pct_ajuste );
          --
          RETURN (l_Pct_ajuste);
      --
    END f_pct_x_grupo_vehi; -- Fin : pct_x_grupo_vehi;
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
                                      p_mca_estado_7  IN OUT G2109023.mca_estado   %TYPE 
                                    ) IS
      --
      CURSOR cl_manejo_radio_button IS
        SELECT t.rowid  ,
                t.*
          FROM G2109023 t
          WHERE t.cod_cia          = p_cod_cia
            AND t.cod_campo        = p_cod_campo
            AND t.val_campo        = p_val_campo
            AND NVL(t.mca_inh,'N') = 'N'
          ORDER BY t.cod_campo, t.num_secu;
      --
    BEGIN
        --
        p_mca_estado_1  := 'N';
        p_mca_estado_2  := 'N';
        p_mca_estado_3  := 'N';
        p_mca_estado_4  := 'N';
        p_mca_estado_5  := 'N';
        p_mca_estado_6  := 'N';
        p_mca_estado_7  := 'N';
        --
        FOR reg IN cl_manejo_radio_button LOOP
          BEGIN
            IF reg.num_secu = 1 THEN
              p_mca_estado_1  := reg.mca_estado;
            ELSIF reg.num_secu = 2 THEN
              p_mca_estado_2  := reg.mca_estado;
            ELSIF reg.num_secu = 3 THEN
              p_mca_estado_3  := reg.mca_estado;
            ELSIF reg.num_secu = 4 THEN
              p_mca_estado_4  := reg.mca_estado;
            ELSIF reg.num_secu = 5 THEN
              p_mca_estado_5  := reg.mca_estado;
            ELSIF reg.num_secu = 6 THEN
              p_mca_estado_6  := reg.mca_estado;
            ELSIF reg.num_secu = 7 THEN
              p_mca_estado_7  := reg.mca_estado;
            END IF;
            --
          END;
        END LOOP;
        --
    END p_manejo_radio_button;
    --
    -- --------------------------------------------------
    -- Autor : Manuel Rodriguez           Version : 1.00
    -- Fecha : 28-Feb-14
    -- Nota  : Bucar el Valor del Campo Variable que se
    --       : envie, para X poliza y X riesgo.
    -- --------------------------------------------------
    -- Fecha  : 04-Ene-18                 Version : 1.14
    -- Lectura: V:Valor, T:Texto, J:Java, R:Riesgo
    -- Nota   : Los (J,R) no se encuentran en g_tb_dv.
    -- --------------------------------------------------
    FUNCTION f_campo_variable_a( p_cod_cia      a2000020.cod_cia%TYPE,
                                  p_num_poliza   a2000020.num_poliza%TYPE,
                                  p_cod_campo    a2000020.cod_campo%TYPE,
                                  p_tip_campo    VARCHAR2,  -- V, T, J, R  Version : 1.14
                                  p_cod_ramo     a2000020.cod_ramo%TYPE,
                                  p_num_riesgo   a2000020.num_riesgo%TYPE
                                ) RETURN VARCHAR2 IS
      --
      TYPE cursor_variable IS REF CURSOR;
      cl_a2000020 CURSOR_VARIABLE;
      --
      l_val_campo    A2000020_340.VAL_CAMPO%TYPE;
      l_txt_campo    A2000020_340.TXT_CAMPO%TYPE;
      --
    BEGIN
      --
      -- Buscar Dato Variabll:
      --
      -- Fec. 31-Oct-17. Buscar los Datos en la Memoria. Version : 1.13
      BEGIN
        l_val_campo := g_tb_dv( p_num_riesgo||'-'||p_cod_campo ).val_campo;
        l_txt_campo := g_tb_dv( p_num_riesgo||'-'||p_cod_campo ).txt_campo;
      EXCEPTION WHEN OTHERS THEN
        l_val_campo := null;
        l_txt_campo := null;
      END;
      --
      -- Fec. 05-Ene-18. Datos variables para poliza y riesgo base. Version : 1.14
      IF p_tip_campo = 'R' THEN
          --
          OPEN cl_a2000020 FOR
              ' SELECT val_campo '                     || chr( 13 ) ||
              '   FROM a2000020_'||p_cod_ramo          || chr( 13 ) ||
              '  WHERE num_poliza        = :1 '        || chr( 13 ) ||
              '    AND cod_cia           = :2 '        || chr( 13 ) ||
              '    AND num_riesgo        = :3 '        || chr( 13 ) ||
              '    AND mca_vigente       = ''S'' '     || chr( 13 ) ||
              '    AND mca_vigente_apli  = ''S'' '     || chr( 13 ) ||
              '    AND mca_baja_riesgo   = ''N'' '     || chr( 13 ) ||
              '    AND num_apli          = 0 '         || chr( 13 ) ||
              '    AND num_spto_apli     = 0 '         || chr( 13 ) ||
              '    AND cod_campo         = :4 '
          USING p_num_poliza, p_cod_cia, p_num_riesgo, p_cod_campo;
          FETCH cl_a2000020 INTO l_val_campo;
          CLOSE cl_a2000020;
          --
      END IF;
      --
      -- Fec. 04-Ene-18. Datos variables para P_DEVUELVE (JAVA). Version : 1.14
      IF p_tip_campo = 'J' THEN
          --
          OPEN cl_a2000020 FOR
              ' SELECT txt_campo '                     || chr( 13 ) ||
              '   FROM a2000020_'||p_cod_ramo          || chr( 13 ) ||
              '  WHERE num_poliza        = :1 '        || chr( 13 ) ||
              '    AND cod_cia           = :2 '        || chr( 13 ) ||
              '    AND num_riesgo        = :3 '        || chr( 13 ) ||
              '    AND mca_vigente       = ''S'' '     || chr( 13 ) ||
              '    AND mca_vigente_apli  = ''S'' '     || chr( 13 ) ||
              '    AND mca_baja_riesgo   = ''N'' '     || chr( 13 ) ||
              '    AND num_apli          = 0 '         || chr( 13 ) ||
              '    AND num_spto_apli     = 0 '         || chr( 13 ) ||
              '    AND cod_campo         = :4 '
          USING p_num_poliza, p_cod_cia, p_num_riesgo, p_cod_campo;
          FETCH cl_a2000020 INTO l_txt_campo;
          CLOSE cl_a2000020;
          --
      END IF;
      --
      -- Fec. 31-Oct-17. Retornar el valor. Version : 1.13
      IF p_tip_campo IN ('V','R') THEN  -- Version : 1.13 (Agregue la letra R)
        RETURN l_val_campo;
      ELSE
        RETURN l_txt_campo;
      END IF;
      --
      -- Fec. 31-Oct-17. Puesto en comentario. Version : 1.13
      /*
        IF p_tip_campo = 'V' THEN
            --
            OPEN cl_a2000020 FOR
                ' SELECT val_campo '                     || chr( 13 ) ||
                '   FROM a2000020_'||p_cod_ramo          || chr( 13 ) ||
                '  WHERE num_poliza        = :1 '        || chr( 13 ) ||
                '    AND cod_cia           = :2 '        || chr( 13 ) ||
                '    AND num_riesgo        = :3 '        || chr( 13 ) ||
                '    AND mca_vigente       = ''S'' '     || chr( 13 ) ||
                '    AND mca_vigente_apli  = ''S'' '     || chr( 13 ) ||
                '    AND mca_baja_riesgo   = ''N'' '     || chr( 13 ) ||
                '    AND num_apli          = 0 '         || chr( 13 ) ||
                '    AND num_spto_apli     = 0 '         || chr( 13 ) ||
                '    AND cod_campo         = :4 '
            USING p_num_poliza, p_cod_cia, p_num_riesgo, p_cod_campo;
            FETCH cl_a2000020 INTO l_val_campo;
            CLOSE cl_a2000020;
            --
            RETURN l_val_campo;
            --
        ELSE
            --
            OPEN cl_a2000020 FOR
                ' SELECT txt_campo '                     || chr( 13 ) ||
                '   FROM a2000020_'||p_cod_ramo          || chr( 13 ) ||
                '  WHERE num_poliza        = :1 '        || chr( 13 ) ||
                '    AND cod_cia           = :2 '        || chr( 13 ) ||
                '    AND num_riesgo        = :3 '        || chr( 13 ) ||
                '    AND mca_vigente       = ''S'' '     || chr( 13 ) ||
                '    AND mca_vigente_apli  = ''S'' '     || chr( 13 ) ||
                '    AND mca_baja_riesgo   = ''N'' '     || chr( 13 ) ||
                '    AND num_apli          = 0 '         || chr( 13 ) ||
                '    AND num_spto_apli     = 0 '         || chr( 13 ) ||
                '    AND cod_campo         = :4 '
            USING p_num_poliza, p_cod_cia, p_num_riesgo, p_cod_campo;
            FETCH cl_a2000020 INTO l_txt_campo;
            CLOSE cl_a2000020;
            --
            RETURN l_txt_campo;
            --
        END IF;
      */
      --
    END f_campo_variable_a;
    --
    -- --------------------------------------------------
    -- Autor : Manuel Rodriguez           Version : 1.00
    -- Fecha : 04-Mar-14
    -- Nota  : Bucar el Valor del Campo Variable que se
    --       : en la tabla (R).
    -- --------------------------------------------------
    FUNCTION f_campo_variable_r( p_cod_cia      a2000020.cod_cia%TYPE,
                                  p_num_poliza   a2000020.num_poliza%TYPE,
                                  p_cod_campo    a2000020.cod_campo%TYPE,
                                  p_tip_campo    VARCHAR2,  -- V o T
                                  p_num_riesgo   a2000020.num_riesgo%TYPE
                                ) RETURN VARCHAR2 IS
        --
        -- Buscar Datos Ren.:
        CURSOR cr_r2000020 IS
          SELECT val_campo, txt_campo
            FROM r2000020
          WHERE cod_cia    = p_cod_cia
            AND num_poliza = p_num_poliza
            AND num_riesgo = p_num_riesgo
            AND cod_campo  = p_cod_campo;
        --
        l_val_campo    A2000020.VAL_CAMPO%TYPE;
        l_txt_campo    A2000020.TXT_CAMPO%TYPE;
        --
    BEGIN
      --
      -- Buscar Dato Variabll:
      OPEN  cr_r2000020;
      FETCH cr_r2000020 INTO l_val_campo, l_txt_campo;
      IF cr_r2000020%FOUND THEN
          --
          IF p_tip_campo = 'V' THEN
            RETURN l_val_campo;
          ELSE
            RETURN l_txt_campo;
          END IF;
          --
      ELSE
          RETURN NULL;
      END IF;
      CLOSE cr_r2000020;
      --
    END f_campo_variable_r;
    --
    -- --------------------------------------------------
    -- Autor : Manuel Rodriguez           Version : 1.00
    -- Fecha : 05-Mar-14
    -- Nota  : Calcular la prima del riesgo.
    -- --------------------------------------------------
    FUNCTION f_cal_prima_riesgo_a (p_cod_cia      a2000020.cod_cia%TYPE,
                                    p_cod_ramo     a2000020.cod_ramo%TYPE,
                                    p_num_poliza   a2000020.num_poliza%TYPE,
                                    p_num_riesgo   a2000020.num_riesgo%TYPE
                                  ) RETURN NUMBER IS
        --
        TYPE cursor_variable IS REF CURSOR;
        cl_a2100170 CURSOR_VARIABLE;
        --
        l_imp_prima    A2100170.IMP_SPTO%TYPE := 0;
        --
    BEGIN
      --
      -- Fec. 31-Mar-16, Vercion : 1.04 (Agregado a2000030 Y Modificado a2100170) (Buscar Prima Anterior)
      -- Fec. 12-Abr-16, Vercion : 1.04 (Que los spto, nominativos (SM), no se tomen en cuenta)
      -- Sumar la Prima:
      OPEN cl_a2100170 FOR
            ' SELECT SUM(imp_anual)'                || chr( 13 ) ||
            '   FROM a2100170_'||p_cod_ramo||' t'   || chr( 13 ) ||
            '  WHERE num_poliza    = :1 '           || chr( 13 ) ||
            '    AND cod_cia       = :2 '           || chr( 13 ) ||
            '    AND num_riesgo    = :3 '           || chr( 13 ) ||
            '    AND num_apli      = 0 '            || chr( 13 ) ||
            '    AND num_spto_apli = 0 '            || chr( 13 ) ||
            '    AND num_spto      = (SELECT MAX(x.num_spto) '                     || chr( 13 ) ||
            '                           FROM a2100170_'||p_cod_ramo||' y'||' ,'    || chr( 13 ) ||
            '                                a2000030'||' x'                       || chr( 13 ) ||
            '                          WHERE x.cod_cia            = t.cod_cia'     || chr( 13 ) ||
            '                            AND x.num_poliza         = t.num_poliza'  || chr( 13 ) ||
            '                            AND x.mca_poliza_anulada = ''N'''         || chr( 13 ) ||
            '                            AND x.mca_spto_anulado   = ''N'''         || chr( 13 ) ||
            '                            AND x.mca_spto_tmp       = ''N'''         || chr( 13 ) ||
            '                            AND y.cod_cia    = x.cod_cia'       || chr( 13 ) ||
            '                            AND y.num_poliza = x.num_poliza'    || chr( 13 ) ||
            '                            AND y.num_spto   = x.num_spto'      || chr( 13 ) ||
            '                            AND y.num_riesgo = t.num_riesgo)'   || chr( 13 ) ||
            '    AND EXISTS (SELECT 1 '                           || chr( 13 ) ||
            '                  FROM a2100170_'||p_cod_ramo||' z'  || chr( 13 ) ||
            '                 WHERE z.cod_cia    = t.cod_cia'     || chr( 13 ) ||
            '                   AND z.num_poliza = t.num_poliza'  || chr( 13 ) ||
            '                   AND z.num_spto   = t.num_spto'    || chr( 13 ) ||
            '                   AND z.num_riesgo = t.num_riesgo)'
      USING p_num_poliza, p_cod_cia, p_num_riesgo;
      FETCH cl_a2100170 INTO l_imp_prima;
      CLOSE cl_a2100170;
      --
      IF l_imp_prima IS NULL OR l_imp_prima = 0 THEN
          l_imp_prima := 1;
      END IF;
      --
      RETURN l_imp_prima;
      --
    END f_cal_prima_riesgo_a;
    --
    -- --------------------------------------------------
    -- Autor : Manuel Rodriguez           Version : 1.00
    -- Fecha : 16-Oct-14
    -- Nota  : Calcular prima neta o facturada.
    -- --------------------------------------------------
    FUNCTION f_cal_prima_riesgo_n ( p_cod_cia      a2000031.cod_cia%TYPE,
                                    p_cod_ramo     a2000030.cod_ramo%TYPE,
                                    p_num_poliza   a2000031.num_poliza%TYPE,
                                    p_num_riesgo   a2000031.num_riesgo%TYPE
                                  ) RETURN NUMBER IS
        --
        -- Calcular la Prima Neta:
        TYPE cursor_variable IS REF CURSOR;
        cl_a2100170 CURSOR_VARIABLE;
        --
        l_imp_prima_neta    A2100170.IMP_SPTO%TYPE := 0;
        --
    BEGIN
      --
      -- Fec. 31-Mar-16, Vercion : 1.04 (Agregado a2000030 Y Modificado a2100170) (Buscar Prima Anterior)
      -- Fec. 12-Abr-16, Vercion : 1.04 (Que los spto, nominativos (SM), no se tomen en cuenta)
      -- Sumar la Prima Neta:
      OPEN cl_a2100170 FOR
            ' SELECT SUM(imp_anual)'                || chr( 13 ) ||
            '   FROM a2100170_'||p_cod_ramo||' t'   || chr( 13 ) ||
            '  WHERE num_poliza    = :1 '           || chr( 13 ) ||
            '    AND cod_cia       = :2 '           || chr( 13 ) ||
            '    AND num_riesgo    = :3 '           || chr( 13 ) ||
            '    AND num_apli      = 0 '            || chr( 13 ) ||
            '    AND num_spto_apli = 0 '            || chr( 13 ) ||
            '    AND num_spto      = (SELECT MAX(x.num_spto) '                     || chr( 13 ) ||
            '                           FROM a2100170_'||p_cod_ramo||' y'||' ,'    || chr( 13 ) ||
            '                                a2000030'||' x'                       || chr( 13 ) ||
            '                          WHERE x.cod_cia            = t.cod_cia'     || chr( 13 ) ||
            '                            AND x.num_poliza         = t.num_poliza'  || chr( 13 ) ||
            '                            AND x.mca_poliza_anulada = ''N'''         || chr( 13 ) ||
            '                            AND x.mca_spto_anulado   = ''N'''         || chr( 13 ) ||
            '                            AND x.mca_spto_tmp       = ''N'''         || chr( 13 ) ||
            '                            AND y.cod_cia    = x.cod_cia'       || chr( 13 ) ||
            '                            AND y.num_poliza = x.num_poliza'    || chr( 13 ) ||
            '                            AND y.num_spto   = x.num_spto'      || chr( 13 ) ||
            '                            AND y.num_riesgo = t.num_riesgo)'   || chr( 13 ) ||
            '    AND EXISTS (SELECT 1 '                           || chr( 13 ) ||
            '                  FROM a2100170_'||p_cod_ramo||' z'  || chr( 13 ) ||
            '                 WHERE z.cod_cia    = t.cod_cia'     || chr( 13 ) ||
            '                   AND z.num_poliza = t.num_poliza'  || chr( 13 ) ||
            '                   AND z.num_spto   = t.num_spto'    || chr( 13 ) ||
            '                   AND z.num_riesgo = t.num_riesgo)' || chr( 13 ) ||
            '    AND cod_cob      <> (SELECT cod_cob FROM a1002050 WHERE tip_cob = 8)'
      USING p_num_poliza, p_cod_cia, p_num_riesgo;
      FETCH cl_a2100170 INTO l_imp_prima_neta;
      CLOSE cl_a2100170;
      --
      IF l_imp_prima_neta IS NULL OR l_imp_prima_neta = 0 THEN
          l_imp_prima_neta := 1;
      END IF;
      --
      RETURN l_imp_prima_neta;
      --
    END f_cal_prima_riesgo_n;
    --
    -- --------------------------------------------------
    -- Autor : Manuel Rodriguez           Version : 1.00
    -- Fecha : 05-Mar-14
    -- Nota  : Calcular la prima del riesgo.
    -- --------------------------------------------------
    FUNCTION f_cal_prima_renovacion(p_cod_cia      a2000020.cod_cia%TYPE,
                                    p_num_poliza   a2000020.num_poliza%TYPE,
                                    p_num_riesgo   a2000020.num_riesgo%TYPE
                                    ) RETURN NUMBER IS
        --
        -- Buscar Datos Ren.:
        CURSOR cl_r2100170 IS
          SELECT SUM(imp_anual)
            FROM r2100170
          WHERE cod_cia    = p_cod_cia
            AND num_poliza = p_num_poliza
            AND num_riesgo = NVL(p_num_riesgo, num_riesgo);
          --
        l_imp_prima    A2100170.IMP_SPTO%TYPE := 0;
        --
    BEGIN
      --
      -- Sumar la Prima:
      OPEN  cl_r2100170;
      FETCH cl_r2100170 INTO l_imp_prima;
      CLOSE cl_r2100170;
      --
      IF l_imp_prima IS NULL OR l_imp_prima = 0 THEN
          l_imp_prima := 1;
      END IF;
      --
      RETURN l_imp_prima;
      --
    END f_cal_prima_renovacion;
    --
    -- --------------------------------------------------
    -- Autor : Manuel Rodriguez           Version : 1.00
    -- Fecha : 06-Mar-14
    -- Nota  : Calcular el monto del Siniestro.
    -- --------------------------------------------------
    FUNCTION f_cal_siniestro(p_cod_cia          a2000020.cod_cia         %TYPE,
                              p_num_poliza       a2000020.num_poliza      %TYPE,
                              p_num_riesgo       a2000020.num_riesgo      %TYPE,
                              p_fec_efec_riesgo  a2000031.fec_efec_riesgo %TYPE,  -- Fec. 14-Ene-15
                              p_fec_vcto_riesgo  a2000031.fec_vcto_riesgo %TYPE,  -- Fec. 14-Ene-15
                              p_mca_siniestro    IN OUT VARCHAR2,
                              p_num_siniestros   IN OUT NUMBER
                            ) RETURN NUMBER IS
      --
      -- Buscar Cantidad Siniestro:
      CURSOR cr_a7000900 IS
        SELECT COUNT(NUM_SINI) cant_siniestro
          FROM a7000900
        WHERE cod_cia    = p_cod_cia
          AND num_poliza = p_num_poliza
          AND num_riesgo = p_num_riesgo
          AND fec_sini  BETWEEN p_fec_efec_riesgo AND p_fec_vcto_riesgo;
      --
      -- Buscar Monto Siniestro:
      CURSOR cr_a7001000 IS
        SELECT c.cod_mon cod_mon_pol, d.cod_mon cod_mon_exp, d.imp_val_neto  -- Version : 1.03
          FROM a7001000 d,
              a7000900 c
        WHERE c.cod_cia    = p_cod_cia
          AND c.num_poliza = p_num_poliza
          AND c.num_riesgo = p_num_riesgo
          AND c.fec_sini  BETWEEN p_fec_efec_riesgo AND p_fec_vcto_riesgo
          --
          AND d.num_sini = c.num_sini;
      --
      l_imp_siniestros   a2109010.imp_siniestros%TYPE := 0;
      l_imp_val_neto     a7001000.imp_val_neto%TYPE := 0;  -- Version : 1.03
      l_val_cambio       a1000500.val_cambio%TYPE;  -- Version : 1.03
      --
    BEGIN
      --
      -- Cantidad de Siniestros:
      OPEN  cr_a7000900;
      FETCH cr_a7000900 INTO p_num_siniestros;
      CLOSE cr_a7000900;
      --
      -- Version : 1.03 (Para calcular el impote, de acuerdo a la moneda)
      FOR I IN cr_a7001000 LOOP
        --
        l_val_cambio := dc_f_val_cambio(3, TRUNC(SYSDATE));
        --
        IF I.cod_mon_pol = 1 AND I.cod_mon_pol != I.cod_mon_exp THEN
            l_imp_val_neto := I.imp_val_neto * l_val_cambio;
        ELSIF I.cod_mon_pol = 3 AND I.cod_mon_pol != I.cod_mon_exp THEN
            l_imp_val_neto := I.imp_val_neto/l_val_cambio;
        ELSE
            l_imp_val_neto := I.imp_val_neto;
        END IF;
        --
        l_imp_siniestros := l_imp_siniestros + l_imp_val_neto;
        --
      END LOOP;
      --
      IF p_num_siniestros > 0 THEN
          p_mca_siniestro := 'S';
      END IF;
      --
      RETURN l_imp_siniestros;
      --
    END f_cal_siniestro;
    --
    -- --------------------------------------------------
    -- Autor : Manuel Rodriguez           Version : 1.00
    -- Fecha : 07-Oct-14
    -- Nota  : Calcular Indice Siniestro Acumulado.
    -- --------------------------------------------------
    FUNCTION f_cal_ind_sini_acumulado(p_cod_cia            a2000030.cod_cia%TYPE,
                                      p_cod_ramo           a2000030.cod_ramo%TYPE,
                                      p_num_poliza         a2000030.num_poliza%TYPE
                                      ) RETURN NUMBER IS
        --
        -- Buscar Monto Siniestros:
        CURSOR cr_a7001000 IS
          SELECT a.cod_mon cod_mon_pol, b.cod_mon cod_mon_exp, b.imp_val_neto  -- Version : 1.03
            FROM a7001000 b,
                a7000900 a
          WHERE a.cod_cia         = p_cod_cia
            AND a.num_poliza      = p_num_poliza
            AND b.num_sini        = a.num_sini
            AND b.mca_calcula_rva = 'S';
        --
        TYPE cursor_variable IS REF CURSOR;
        cl_a2100170 CURSOR_VARIABLE;
        --
        l_ind_sini_acumulado      a2109010.ind_sini_acumulado %TYPE := 0;
        l_monto_siniestros        a7001000.imp_val_neto       %TYPE := 0;
        l_total_prima_acumulada   a7001000.imp_val_neto       %TYPE := 0;
        l_imp_val_neto            a7001000.imp_val_neto%TYPE := 0;  -- Version : 1.03
        l_val_cambio              a1000500.val_cambio%TYPE;  -- Version : 1.03
        --
    BEGIN
      --
      -- Version : 1.03 (Para calcular el impote, de acuerdo a la moneda)
      FOR I IN cr_a7001000 LOOP
        --
        l_val_cambio := dc_f_val_cambio(3, TRUNC(SYSDATE));
        --
        IF I.cod_mon_pol = 1 AND I.cod_mon_pol != I.cod_mon_exp THEN
            l_imp_val_neto := I.imp_val_neto * l_val_cambio;
        ELSIF I.cod_mon_pol = 3 AND I.cod_mon_pol != I.cod_mon_exp THEN
            l_imp_val_neto := I.imp_val_neto/l_val_cambio;
        ELSE
            l_imp_val_neto := I.imp_val_neto;
        END IF;
        --
        l_monto_siniestros := l_monto_siniestros + l_imp_val_neto;
        --
      END LOOP;
      --
      -- Dinamico por Ramos, Total Prima:
      OPEN cl_a2100170 FOR
            ' SELECT SUM(imp_spto)'                 || chr( 13 ) ||
            '   FROM a2100170_'||p_cod_ramo||' t'   || chr( 13 ) ||
            '  WHERE num_poliza    = :1 '           || chr( 13 ) ||
            '    AND cod_cia       = :2 '           || chr( 13 ) ||
            '    AND num_apli      = 0 '            || chr( 13 ) ||
            '    AND num_spto_apli = 0 '            || chr( 13 ) ||
            '    AND cod_eco      <> 50 '
      USING p_num_poliza, p_cod_cia;
      FETCH cl_a2100170 INTO l_total_prima_acumulada;   -- Sin el Impuesto ITBIS
      CLOSE cl_a2100170;
      --
      IF l_total_prima_acumulada  > 0 THEN
          l_ind_sini_acumulado := ROUND((l_monto_siniestros/l_total_prima_acumulada)*100,3);
      END IF;
      --
      RETURN l_ind_sini_acumulado;
      --
    END f_cal_ind_sini_acumulado;
    --
    -- ----------------------------------------------------
    -- Autor : Manuel Rodriguez             Version : 1.00
    -- Fecha : 13-Mar-14
    -- Nota  : Buscar los Controles Tecnicos, por riesgos.
    -- ----------------------------------------------------
    FUNCTION f_trae_error_CT(p_cod_cia         a2000500.cod_cia%TYPE,
                              p_num_Poliza      a2000500.num_poliza%TYPE,
                              p_num_riesgo      a2109010.num_riesgo%TYPE
                            ) RETURN VARCHAR2 IS
      --
      -- Declaracion de variables:
      l_txt_error_ct      a2109010.txt_error_ct%TYPE;
      --
      -- Buscar Controles
      CURSOR cr_ctl_tec IS
        SELECT r.cod_error, r.num_poliza, r.num_spto, r.num_apli,
              r.num_spto_apli, ct.nom_error
          FROM g2000211 ct,
              r2000221 r
        WHERE r.cod_cia          = p_cod_cia
          AND r.num_poliza       = p_num_poliza
          AND r.num_riesgo      IN (0, p_num_riesgo) -- Riesgo cero y el a trabjar
          AND r.mca_autorizacion = 'N'
          --
          AND ct.cod_cia   = r.cod_cia
          AND ct.cod_error = r.cod_error
          --
          AND EXISTS (SELECT 1
                        FROM r2000030 p
                        WHERE p.cod_cia    = r.cod_cia
                          AND p.num_poliza = r.num_poliza
                          AND p.num_spto   = r.num_spto
                      );
      --
    BEGIN
      --
      -- Buscar los Controles Tecnicos:
      FOR I IN cr_ctl_tec LOOP
        --
        l_txt_error_ct := Substr(l_txt_error_ct||'Codigo : '||I.cod_error||'  Nombre : '||I.nom_error||chr(13),0,2000);
        --
      END LOOP;
      --
      RETURN l_txt_error_ct;
      --
    END f_trae_error_CT;
    --
    -- ----------------------------------------------------
    -- Autor : Manuel Rodriguez             Version : 1.03
    -- Fecha : 06-MaY-15
    -- Nota  : Buscar Errores de las Polizas, por riesgos.
    -- ----------------------------------------------------
    FUNCTION f_trae_error_POL(p_fec_tratamiento   a2000520.fec_tratamiento %TYPE,
                              p_num_orden         a2000520.num_orden       %TYPE,
                              p_tip_mvto_batch    a2000520.tip_mvto_batch  %TYPE,
                              p_cod_cia           a2000500.cod_cia         %TYPE,
                              p_num_Poliza        a2000500.num_poliza      %TYPE,
                              p_num_riesgo        a2109010.num_riesgo      %TYPE
                              ) RETURN VARCHAR2 IS
      --
      -- Declaracion de variables:
      l_txt_error_pol      a2109010.txt_error_pol%TYPE;
      --
      -- Buscar Errores por Riesgo:
      CURSOR cl_a2000520_r IS
        SELECT num_poliza, num_riesgo, txt_error
          FROM a2000520
        WHERE fec_tratamiento = p_fec_tratamiento
          AND num_orden       = p_num_orden
          AND tip_mvto_batch  = p_tip_mvto_batch
          AND cod_cia         = p_cod_cia
          AND num_poliza      = p_num_poliza
          AND num_riesgo      = p_num_riesgo;
      --
      -- Buscar Errores por Poliza:
      CURSOR cl_a2000520_p IS
        SELECT num_poliza, num_riesgo, txt_error
          FROM a2000520
        WHERE fec_tratamiento = p_fec_tratamiento
          AND num_orden       = p_num_orden
          AND tip_mvto_batch  = p_tip_mvto_batch
          AND cod_cia         = p_cod_cia
          AND num_poliza      = p_num_poliza
          AND num_riesgo      = 0;
      --
      -- Buscar Errores por Poliza: Fec. 5-Jun-15
      CURSOR cl_a2009030 IS
        SELECT tip_situ
          FROM a2009030
        WHERE num_poliza = p_num_poliza
          AND mes        = g_mes
          AND anio       = g_anio;
      --
    BEGIN
      --
      -- Buscar los errores de riesgo:
      FOR I IN cl_a2000520_r LOOP
        --
        l_txt_error_pol := Substr(l_txt_error_pol||I.txt_error||chr(13),0,2000);
        --
      END LOOP;
      --
      -- Buscar los errores de poliza:
      IF l_txt_error_pol IS NULL THEN
          --
          FOR I IN cl_a2000520_p LOOP
            --
            l_txt_error_pol := Substr(l_txt_error_pol||I.txt_error||chr(13),0,2000);
            --
          END LOOP;
          --
      END IF;
      --
      -- Como no se grabo el error en A2000520, se busca en A2009030: Fec. 5-Jun-15
      IF l_txt_error_pol IS NULL THEN
          --
          OPEN  cl_a2009030;
          FETCH cl_a2009030 INTO l_txt_error_pol;
          CLOSE cl_a2009030;
          --
      END IF;
      --
      RETURN l_txt_error_pol;
      --
    END f_trae_error_POL;
    --
    -- --------------------------------------------------
    -- Autor : Manuel Rodriguez           Version : 1.00
    -- Fecha : 11-Feb-14
    -- Nota  : Creado para enviar la notificacion a cada
    --       : usuario que ejecute las tareas indicadas.
    -- --------------------------------------------------
    PROCEDURE p_envia_correo_cargas(p_cod_cia    g1009100.cod_cia%TYPE,
                                    p_nom_forma  g1009100.nom_forma%TYPE,
                                    p_mensage    g1009100.html_message%TYPE
                                    ) IS
      --
      -- Declaracio Variables:
      l_email_usr_cia   g1009100.to_names      %TYPE;  -- Fec. 3-Nov-16, Version : 1.08
      l_cod_usr         g1002700.cod_usr       %TYPE;
      --
      -- Declaracio Cursores:
      --
      CURSOR c1_G1009100 IS
        SELECT *
          FROM G1009100
        WHERE cod_cia   =  p_cod_cia
          AND nom_forma =  p_nom_forma;
      --
      l_reg_G1009100    c1_G1009100%ROWTYPE;
      --
      CURSOR cl_g1002700 IS
        SELECT Email_Usr_Cia
          FROM G1002700
        WHERE Cod_Cia     = p_cod_cia
          AND cod_usr_cia = l_cod_usr;
        --
      -- Buscar Usuarios que renuevan Automovil. Version : 1.03
      CURSOR C_G2309005 IS
        SELECT a.cod_usr_vida, b.Email_Usr_Cia, mca_ren_poliza, mca_impres_pol
          FROM G1002700 b,
              G2309005 a
        WHERE a.cod_cia        = g_cod_cia
          AND a.cod_depto      = 'AU'
          --AND a.mca_ren_poliza = 'S'
          AND a.mca_inh        = 'N'
          --
          AND b.cod_cia     = a.cod_cia
          AND b.cod_usr_cia = a.cod_usr_vida
        ORDER BY 1;
      --
    BEGIN
      --
      BEGIN
        l_cod_usr := trn_k_global.devuelve('COD_USR');
      EXCEPTION WHEN OTHERS THEN
        l_cod_usr := USER;
      END;
      --
      OPEN  c1_G1009100;
      FETCH c1_G1009100 INTO l_reg_G1009100;
      CLOSE c1_G1009100;
      --
      l_email_usr_cia := NULL;
      OPEN  cl_g1002700;
      FETCH cl_g1002700 INTO l_email_usr_cia;
      CLOSE cl_g1002700;
      --
      -- El objetivo es que si el usuario que corre la tarea no tiene su
      -- E-Mail grabado, entonces se l envie el reporte al User Defaul.
      IF l_email_usr_cia IS NULL THEN
          IF l_reg_G1009100.To_Names IS NOT NULL THEN
            l_email_usr_cia := l_reg_G1009100.To_Names;
            l_reg_G1009100.To_Names := NULL;
          ELSIF l_reg_G1009100.Cc_Names IS NOT NULL THEN
            l_email_usr_cia := l_reg_G1009100.Cc_Names;
            l_reg_G1009100.Cc_Names := NULL;
          ELSIF l_reg_G1009100.Bcc_Names IS NOT NULL THEN
            l_email_usr_cia := l_reg_G1009100.Bcc_Names;
            l_reg_G1009100.Bcc_Names := NULL;
          END IF;
      ELSIF l_email_usr_cia IS NOT NULL AND l_reg_G1009100.To_Names IS NOT NULL AND
            l_email_usr_cia != l_reg_G1009100.To_Names THEN  -- Version 1.03 (Le llegue a los dos user)
            --
            l_email_usr_cia := l_reg_G1009100.To_Names||'; '||l_email_usr_cia;
            --
      END IF;
      --
      -- M.R., Fec. 17-Abr-15, Version : 1.03
      -- Enviar, archivo, a todos los de Automovil, si la Renovacion es por Control-M:
      IF g_mca_ctl_m_ren = 'S' THEN
        --
        l_email_usr_cia := NULL;
        -- Depura o clasifica, solo, los usarios de automovil: (AU)
        FOR I IN C_G2309005 LOOP
          IF I.Mca_Ren_Poliza = 'S' THEN
              IF l_email_usr_cia IS NULL THEN
                l_email_usr_cia := I.email_usr_cia;
              ELSE
                l_email_usr_cia := l_email_usr_cia||'; '||I.email_usr_cia;
              END IF;
          ELSIF I.mca_impres_pol = 'S' AND I.email_usr_cia IS NOT NULL THEN
              l_reg_G1009100.Cc_Names := l_reg_G1009100.Cc_Names||'; '||I.email_usr_cia;
          END IF;
        END LOOP;
        --
      END IF;
      --
      p_send_mail (l_reg_G1009100.from_name,
                    l_email_usr_cia,          --l_reg_G1009100.To_Names,
                    l_reg_G1009100.subject ||' Ejecutado el : '||to_char(SYSDATE,'dd-mon-yyyy  HH12:MI:SS'),
                    l_reg_G1009100.message ||' '||to_char(g_fec_tratamiento,'dd-mon-yyyy  HH12:MI:SS  ')||p_mensage,
                    l_reg_G1009100.Html_Message,
                    l_reg_G1009100.Cc_Names ,
                    l_reg_G1009100.Bcc_Names,
                    l_reg_G1009100.filename1,
                    l_reg_G1009100.filetype1,
                    l_reg_G1009100.filename2,
                    l_reg_G1009100.filetype2,
                    l_reg_G1009100.filename3,
                    l_reg_G1009100.filetype3 );
      --
    END p_envia_correo_cargas;
    --
    -- --------------------------------------------------
    -- Autor : Manuel Rodriguez           Version : 1.00
    -- Fecha : 04-Jul-14
    -- Nota  : Bucar el Nombre de la Marca
    -- --------------------------------------------------
    FUNCTION f_nom_marca( p_cod_cia      a2000020.cod_cia%TYPE,
                          p_cod_marca    a2100400.cod_marca%TYPE
                        ) RETURN VARCHAR2 IS
        --
        CURSOR cr_a2100400 IS
          SELECT nom_marca
            FROM A2100400 
          WHERE cod_cia   = p_cod_cia
            AND cod_marca = p_cod_marca;
        --
        l_nom_marca    A2100400.nom_marca%TYPE;
        --
    BEGIN
      --
      OPEN  cr_a2100400;
      FETCH cr_a2100400 INTO l_nom_marca;
      CLOSE cr_a2100400;
      --
      RETURN l_nom_marca;
      --
    END f_nom_marca;
    --
    -- --------------------------------------------------
    -- Autor : Manuel Rodriguez           Version : 1.00
    -- Fecha : 29-Dic-14
    -- Nota  : Bucar el Nombre de la Modalidad
    -- --------------------------------------------------
    FUNCTION f_nom_modalidad( p_cod_cia        g2990004.cod_cia%TYPE,
                              p_cod_modalidad  g2990004.cod_modalidad%TYPE
                              ) RETURN VARCHAR2 IS
        --
        CURSOR cr_g2990004 IS
          SELECT nom_modalidad
            FROM g2990004
          WHERE cod_cia       = p_cod_cia
            AND cod_modalidad = p_cod_modalidad
            AND mca_inh       = 'N';
        --
        l_nom_modalidad    g2990004.nom_modalidad%TYPE;
        --
    BEGIN
      --
      OPEN  cr_g2990004;
      FETCH cr_g2990004 INTO l_nom_modalidad;
      CLOSE cr_g2990004;
      --
      RETURN l_nom_modalidad;
      --
    END f_nom_modalidad;
    --
    -- --------------------------------------------------
    -- Autor : Manuel Rodriguez           Version : 1.00
    -- Fecha : 22-Oct-14
    -- Nota  : Calcular el Descuentro TW
    -- --------------------------------------------------
    FUNCTION f_cal_desc_tw ( p_dnr_ren          a2109010.dnr_ren%TYPE,
                              p_factor_ajuste    a2109010.factor_ajuste%TYPE
                            ) RETURN NUMBER IS
        --
        l_descuento_tw       a2109010.desc_comercial_ren%TYPE := 0;
        --
    BEGIN
      --
      --
      l_descuento_tw := ( ( (100 + p_dnr_ren) * (100 + p_factor_ajuste) )/100 ) - 100;
      --
      RETURN l_descuento_tw;
      --
    END f_cal_desc_tw;
    --
    -- ----------------------------------------------------------------------
    -- Autor : Manuel Rod.                                    Version : 1.00
    -- Fecha : 07-Ago-14
    -- Nota  : Partiendo desde la tabla de Meses de Corrida, verificar si
    --       : elguna poliza, en proceso de Renovacion, ha sufrido algun
    --       : movimiento para notificar al area de Suscripcio.
    --       : Este proceso correra por C.M. (Nomb.: ver_pol_auto_spto.sh).
    --       : (Version : 1.03 Fec. 11-Jun-15, cambio de campos, g por l).
    -- ----------------------------------------------------------------------
    PROCEDURE p_verifica_spto_poliza IS
      --
      l_cod_cia               a1000900.cod_cia       %TYPE := 6;
      l_num_poliza            a2000030.num_poliza    %TYPE;
      l_cod_ramo              a2000030.cod_ramo      %type;
      l_anio                  a2109010_mrd.anio      %TYPE;
      l_mes                   a2109010_mrd.mes       %TYPE;
      l_num_spto              a2000030.num_spto      %TYPE;
      l_num_spto_ult          a2000030.num_spto      %TYPE;
      --
      l_fec_sysdate           DATE := SYSDATE;
      l_cant_polizas          NUMBER(6) := 0;
      l_cant_pol_mod_spto     NUMBER(6) := 0;
      --
      -- Buscar Mes Cargado y sin Renovar:
      CURSOR C_g2109022 IS
        SELECT *
          FROM g2109022 a
          WHERE cod_cia = l_cod_cia
            AND fec_carga_inic IS NOT NULL
            AND fec_renovacion IS NULL
            AND mca_inh = 'N';
      --
      -- Busca Polizas a Renovar:
      CURSOR cl_a2009030_ren  IS
        SELECT num_poliza, num_spto
          FROM a2009030
          WHERE cod_ramo      = l_cod_ramo
            AND mes           = l_mes
            AND anio          = l_anio
            AND tip_estatus NOT IN (5, 6);
      --
      -- Busca Polizas con Movimientos:
      CURSOR cl_a2000030  IS
        SELECT num_spto
          FROM a2000030 a
          WHERE cod_cia    = l_cod_cia
            AND cod_ramo   = l_cod_ramo
            AND num_poliza = l_num_poliza
            AND mca_poliza_anulada = 'N'
            AND num_spto   = ( SELECT MAX(b.num_spto)
                                FROM a2000030 b
                                WHERE b.cod_cia          = a.cod_cia
                                  AND b.num_poliza       = a.num_poliza
                                  AND b.mca_spto_anulado = 'N'
                                  AND b.mca_spto_tmp     = 'N'
                            );
      --
      -- Buscar polizas modificadas:
      CURSOR cl_a2009030_mod IS
        SELECT num_poliza, num_spto
          FROM a2009030
        WHERE fec_modificacion = l_fec_sysdate
          AND mca_pol_mod_spto = 'S';
      --
    BEGIN
      --
      l_concat := chr(13)||chr(13)||'Archivo de Polizas Actualizadas por Spto. Ramos de Automovil'||chr(13)||chr(13);
      l_concat := l_concat||chr(13);
      l_concat := l_concat||chr(13);
      --
      -- Buscar los ramos a procesar:
      FOR I IN C_g2109022 LOOP
          --
          l_cod_ramo       := I.cod_ramo;
          l_anio           := I.anio;
          l_mes            := I.mes;
          --
          IF l_anio IS NOT NULL AND l_mes IS NOT NULL THEN
            --
            -- Buscar las polizas en Pre-Renovacion:
            FOR X IN cl_a2009030_ren LOOP
                --
                l_cant_polizas := l_cant_polizas + 1;
                --
                l_num_poliza := X.num_poliza;
                l_num_spto   := X.num_spto;
                --
                -- Verifica movimiento de spto:
                OPEN  CL_A2000030;
                FETCH CL_A2000030 INTO l_num_spto_ult;
                CLOSE CL_A2000030;
                --
                -- Compara los spto encontrados:
                IF l_num_spto <> l_num_spto_ult THEN
                  --
                  l_cant_pol_mod_spto := l_cant_pol_mod_spto + 1;
                  --
                  -- Actualizar la poliza, ya que vario su contenido:
                  UPDATE a2009030
                    SET mca_pol_mod_spto = 'S',
                        fec_modificacion = l_fec_sysdate
                  WHERE num_poliza = l_num_poliza
                    AND mes        = l_mes
                    AND anio       = l_anio;
                  --
                END IF;
                --
            END LOOP;
            --
          END IF;
          --
      END LOOP;
      --
      -- Envio de correo por Spto:
      IF l_cant_pol_mod_spto > 0 THEN
        --
        l_concat := l_concat||chr(13);
        l_concat := l_concat||chr(13);
        l_concat := l_concat|| '       NUMERO DE POLIZA                      NO. SPTO  '|| chr(13);
        l_concat := l_concat|| '       ------------------------------        ---------------  '|| chr(13);
        l_concat := l_concat||chr(13);
        --
        -- Buscar polizas modificadas:
        FOR I IN cl_a2009030_mod LOOP
          --
          l_concat := l_concat|| '       '|| I.num_poliza||'             '||I.num_spto|| chr(13);
          --
        END LOOP;
        --
        l_concat := l_concat||chr(13);
        l_concat := l_concat||chr(13);
        l_concat := l_concat|| 'Favor de atender y/o verificar las polizazs enviadas en este archivo. Gracias.'|| chr(13);
        l_concat := l_concat||chr(13);
        --
      ELSE
        l_concat := l_concat||chr(13);
        l_concat := l_concat||chr(13);
        l_concat := l_concat|| 'No se encontraron polizas modificadas, para este dia.'|| chr(13);
        l_concat := l_concat||chr(13);
        l_concat := l_concat||chr(13);
        l_concat := l_concat||chr(13);
        l_concat := l_concat|| 'Proceso de verificacion finalizado satisfactoriamente. Gracias.'|| chr(13);
        l_concat := l_concat||chr(13);
      END IF;
      --
      -- Enviar el Correo:
      p_envia_correo_cargas(l_cod_cia, 'PRERENO_AUT_AUTO', l_concat);
      --
    END p_verifica_spto_poliza;
    --
    -- ----------------------------------------------------------------------
    -- Autor : Manuel Rodriguez                               Version : 1.00
    -- Fecha : 08-Ago-14
    -- Nota  : Este proceso se encarga de calcular los siniestros menores,
    --       : los mayores y el monto del siniestro.
    --       : (Me lo envio Victor Borge, por E-Mail).
    -- ----------------------------------------------------------------------
    PROCEDURE p_siniestro(pcod_cia         a7000900.cod_cia    %TYPE,
                          pnum_poliza      a7000900.num_poliza %TYPE,
                          pnum_riesgo      a7000900.num_riesgo %TYPE,
                          pcod_Ramo        a7000900.cod_ramo   %TYPE,
                          pfec_efec_riesgo a7000900.fec_sini   %TYPE,
                          pfec_vcto_riesgo a7000900.fec_sini   %TYPE,
                          pimp_prima       a2100170.imp_spto   %TYPE,
                          psini_menores    IN OUT NUMBER,
                          psini_mayores    IN OUT NUMBER,
                          pmonto_Sini      IN OUT NUMBER 
                        ) IS
      --
      -- Datos fijos de siniestros:
      CURSOR cl_siniestros IS
        SELECT num_sini, cod_cia, fec_sini, cod_mon cod_mon_pol  -- Version : 1.03
          FROM a7000900
        WHERE cod_cia    = pcod_cia
          AND num_poliza = pnum_poliza
          AND num_riesgo = pnum_riesgo
          AND fec_sini   BETWEEN pfec_efec_riesgo AND pfec_vcto_riesgo;
      --
      -- Buscar Monto Siniestro:  Version : 1.03
      CURSOR cr_a7001000 (p_num_sini   a7001000.num_sini%TYPE) IS
        SELECT cod_mon cod_mon_exp, imp_val_neto
          FROM a7001000
        WHERE cod_cia  = pcod_cia
          AND num_sini = p_num_sini;
      --
      -- Datos de siniestros menores:
      CURSOR cl_taaut117(plfec_sini a7000900.fec_sini%TYPE) IS
        SELECT imp_max_sini, pct_max_sini
          FROM taaut117_mrd
        WHERE cod_cia   = pcod_cia
          AND cod_ramo IN ( pCod_Ramo, 999 )
          AND plfec_sini  BETWEEN fec_efec_sini AND fec_vcto_sini
          AND mca_inh   = 'N';
      --
      nimp_max_sini              taaut117_mrd.imp_max_sini %TYPE := 0;
      npct_max_sini              taaut117_mrd.pct_max_sini %TYPE := 0;
      l_imp_siniestros           a7001000.imp_val_neto%TYPE := 0;
      l_imp_val_neto             a7001000.imp_val_neto%TYPE := 0;  -- Version : 1.03
      l_val_cambio               a1000500.val_cambio%TYPE;  -- Version : 1.03
      l_importe_siniestros       a7001000.imp_val_neto%TYPE := 0;  -- Version : 1.03
      --
    BEGIN
      --
      psini_menores := 0;
      psini_mayores := 0;
      pmonto_Sini   := 0;
      --
      -- Version : 1.03 (Buscar el valor de la moneda, en dollar)
      l_val_cambio := dc_f_val_cambio(3, TRUNC(SYSDATE));
      --
      FOR reg IN cl_siniestros LOOP
        --
        -- Version : 1.03 (Calcular el Importe por Expediente y Moneda)
        l_importe_siniestros := 0;
        FOR I IN cr_a7001000(reg.num_sini) LOOP
          --
          IF reg.cod_mon_pol = 1 AND reg.cod_mon_pol != I.cod_mon_exp THEN
              l_imp_val_neto := I.imp_val_neto * l_val_cambio;
          ELSIF reg.cod_mon_pol = 3 AND reg.cod_mon_pol != I.cod_mon_exp THEN
              l_imp_val_neto := I.imp_val_neto/l_val_cambio;
          ELSE
              l_imp_val_neto := I.imp_val_neto;
          END IF;
          --
          l_importe_siniestros := l_importe_siniestros + l_imp_val_neto;
          --
        END LOOP;
        --
        -- Version : 1.03 (Calcular monto en pesos, para determinar siniestros mayores y menores)
        IF reg.cod_mon_pol = 3 THEN
            l_imp_siniestros := l_importe_siniestros * l_val_cambio;
        ELSE
            l_imp_siniestros := l_importe_siniestros;
        END IF;
        --
        IF l_imp_siniestros > 0 THEN
          --
          OPEN  cl_taaut117(reg.fec_sini);
          FETCH cl_taaut117 INTO nimp_max_sini, npct_max_sini;
          IF cl_taaut117%NOTFOUND THEN
            nimp_max_sini := 0;
            npct_max_sini := 0;
          END IF;
          CLOSE cl_taaut117;
          --
          IF (l_imp_siniestros < nimp_max_sini   ) OR
              (l_imp_siniestros * 100 / pimp_prima < npct_max_sini  ) THEN
              --
              psini_menores := psini_menores + 1;
          ELSE
              psini_mayores := psini_mayores + 1;
          END IF;
          --
        END IF;
        --
        pMonto_Sini := pMonto_Sini + l_importe_siniestros; -- Version : 1.03
        --
      END LOOP;
      --
      psini_mayores := psini_mayores + TRUNC ( psini_menores / 2 );
      psini_menores := MOD( psini_menores, 2 );
      --
    END p_siniestro;
    --
    -- ----------------------------------------------------------------------
    -- Autor : Manuel Rod.                                    Version : 1.00
    -- Fecha : 11-Ago-14
    -- Nota  : Partiendo desde la tabla de Meses de Corrida, verificar si
    --       : alguna poliza, en proceso de Renovacion, ha sufrido algun
    --       : movimiento para notificar al area de Suscripcion.
    --       : Este proceso correra por C.M. (Nomb.: ver_pol_auto_sini.sh).
    --       : (Version : 1.03 Fec. 11-Jun-15, cambio de campos, g por l).
    -- ----------------------------------------------------------------------
    PROCEDURE p_verifica_sini_poliza IS
      --
      l_cod_cia               a1000900.cod_cia       %TYPE := 6;
      l_num_poliza            a2000030.num_poliza    %TYPE;
      l_cod_ramo              a2000030.cod_ramo      %type;
      l_anio                  a2109010_mrd.anio      %TYPE;
      l_mes                   a2109010_mrd.mes       %TYPE;
      l_fec_sysdate           DATE := SYSDATE;
      l_cant_polizas          NUMBER(6) := 0;
      l_cant_pol_mod_sini     NUMBER(6) := 0;
      l_mca_siniestro         VARCHAR2(1);
      l_num_sini_menores      a2109010_mrd.num_sini_menores%TYPE := 0;
      l_num_sini_mayores      a2109010_mrd.num_sini_mayores%TYPE := 0;
      l_imp_siniestros        a2109010_mrd.imp_siniestros%TYPE := 0;
      --
      -- Buscar Mes Cargado y sin Renovar:
      CURSOR C_g2109022 IS
        SELECT *
          FROM g2109022 a
        WHERE cod_cia = l_cod_cia
          AND fec_carga_inic IS NOT NULL
          AND fec_renovacion IS NULL
          AND mca_inh = 'N';
      --
      -- Busca Polizas a Renovar:
      CURSOR cl_a2009030_ren  IS
        SELECT num_poliza, fec_tratamiento
          FROM a2009030
        WHERE cod_ramo      = l_cod_ramo
          AND mes           = l_mes
          AND anio          = l_anio
          AND tip_estatus NOT IN (5, 6);
      --
      -- Busca Riesgos por Polizas:
      CURSOR cl_a2109010 (p_num_poliza      a2000030.num_poliza%TYPE,
                          p_fec_tratamiento a2109010.fec_tratamiento%TYPE
                        ) IS
        SELECT cod_ramo, num_poliza, num_riesgo, prima_ren,
              fec_efec_riesgo, fec_vcto_riesgo,
              num_sini_menores, num_sini_mayores, imp_siniestros
          FROM a2109010 a
        WHERE cod_cia         = l_cod_cia
          AND fec_tratamiento = p_fec_tratamiento
          AND num_poliza      = p_num_poliza;
      --
      -- Buscar polizas modificadas:
      CURSOR cl_a2009030_mod IS
        SELECT num_poliza, num_spto
          FROM a2009030
        WHERE fec_modificacion = l_fec_sysdate
          AND mca_pol_mod_spto = 'S';
      --
    BEGIN
      --
      l_concat := chr(13)||chr(13)||'Archivo de Polizas con Siniestrospor Spto. Ramos de Automovil'||chr(13)||chr(13);
      l_concat := l_concat||chr(13);
      l_concat := l_concat||chr(13);
      --
      -- Buscar los ramos a procesar:
      FOR I IN C_g2109022 LOOP
          --
          l_cod_ramo       := I.cod_ramo;
          l_anio           := I.anio;
          l_mes            := I.mes;
          --
          IF l_anio IS NOT NULL AND l_mes IS NOT NULL THEN
            --
            -- Buscar las polizas en Pre-Renovacion:
            FOR X IN cl_a2009030_ren LOOP
                --
                l_num_poliza   := X.Num_Poliza;  -- Version : 1.03 Fec. 11-Jun-15 (nuevo)
                l_cant_polizas := l_cant_polizas + 1;
                --
                -- Buscar los Riesgos por Polizas:
                FOR Y IN cl_a2109010 (X.Num_Poliza, X.fec_tratamiento) LOOP
                  --
                  -- Buscar los valores del riesgo en Siniestro:
                  p_siniestro(l_cod_cia,
                              X.Num_Poliza,
                              Y.num_riesgo,
                              Y.cod_Ramo,
                              Y.fec_efec_riesgo,
                              Y.fec_vcto_riesgo,
                              Y.prima_ren,
                              l_num_sini_menores,
                              l_num_sini_mayores,
                              l_imp_siniestros);
                  --
                  IF Y.num_sini_menores != l_num_sini_menores OR
                    Y.num_sini_mayores != l_num_sini_mayores OR
                    Y.imp_siniestros   != l_imp_siniestros THEN
                    --
                    l_mca_siniestro := 'S';
                    EXIT;
                    --
                  END IF;
                  --
                END LOOP;
                --
                -- Validar el resultado:
                IF l_mca_siniestro = 'S' THEN
                  --
                  l_cant_pol_mod_sini := l_cant_pol_mod_sini + 1;
                  --
                  -- Actualizar la poliza, ya que existe siniestro:
                  UPDATE a2009030
                    SET mca_pol_mod_sini = 'S',
                        fec_modificacion = l_fec_sysdate
                  WHERE num_poliza = l_num_poliza
                    AND mes        = l_mes
                    AND anio       = l_anio;
                  --
                END IF;
                --
            END LOOP;
            --
          END IF;
          --
      END LOOP;
      --
      -- Envio de correo por Siniestro:
      IF l_cant_pol_mod_sini > 0 THEN
        --
        l_concat := l_concat||chr(13);
        l_concat := l_concat||chr(13);
        l_concat := l_concat|| '       NUMERO DE POLIZA                      NO. SPTO  '|| chr(13);
        l_concat := l_concat|| '       ------------------------------        ---------------  '|| chr(13);
        l_concat := l_concat||chr(13);
        --
        -- Buscar polizas modificadas:
        FOR I IN cl_a2009030_mod LOOP
          --
          l_concat := l_concat|| '       '|| I.num_poliza||'             '||I.num_spto|| chr(13);
          --
        END LOOP;
        --
        l_concat := l_concat||chr(13);
        l_concat := l_concat||chr(13);
        l_concat := l_concat|| 'Favor de atender y/o verificar las polizazs enviadas en este archivo. Gracias.'|| chr(13);
        l_concat := l_concat||chr(13);
        --
      ELSE
        l_concat := l_concat||chr(13);
        l_concat := l_concat||chr(13);
        l_concat := l_concat|| 'No se encontraron polizas modificadas, para este dia.'|| chr(13);
        l_concat := l_concat||chr(13);
        l_concat := l_concat||chr(13);
        l_concat := l_concat||chr(13);
        l_concat := l_concat|| 'Proceso de verificacion finalizado satisfactoriamente. Gracias.'|| chr(13);
        l_concat := l_concat||chr(13);
      END IF;
      --
      -- Enviar el Correo:
      p_envia_correo_cargas(l_cod_cia, 'PRERENO_AUT_AUTO', l_concat);
      --
    END p_verifica_sini_poliza;
    --
    -- ------------------------------------------------------------------------
    -- Autor : Manuel Rodriguez                                 Version : 1.00
    -- Fecha : 08-Sep-14
    -- Nota  : Se encarga de seleccionar las Reglas que esten activas para el
    --       : Periodo en curso.
    -- ------------------------------------------------------------------------
    PROCEDURE p_carga_reglas_periodo ( p_Cod_Cia      a2109013.cod_cia   %TYPE,
                                        p_cod_ramo     a2109013.cod_ramo  %TYPE,
                                        p_num_poliza   a2109013.num_poliza%TYPE,
                                        p_Anio         a2109013.anio      %TYPE,
                                        p_Mes          a2109013.mes       %TYPE 
                                      ) IS
      --
      -- Encabezado de Reglas:
      CURSOR cl_g2109017 IS
        SELECT *
          FROM g2109017 a  -- Fec. 24-Ago-17, Version: 1.12
        WHERE cod_cia = p_Cod_Cia
          AND mca_inh = 'N'
          AND fec_validez = (SELECT MAX(fec_validez) -- Fec. 24-Ago-17, Version: 1.12
                                FROM g2109017 b
                              WHERE b.cod_cia      = a.cod_cia
                                AND b.num_regla    = a.num_regla
                                AND b.fec_validez <= g_fec_tratamiento
                            )
          AND num_version = (SELECT MAX(num_version) -- Fec. 24-Ago-17, Version: 1.12
                                FROM g2109017 c
                              WHERE c.cod_cia   = a.cod_cia
                                AND c.num_regla = a.num_regla
                            );
      --
      -- Detalle de Reglas:
      CURSOR cl_g2109018 (  p_num_regla   g2109017.num_regla%TYPE,
                            P_num_version g2109017.num_version%TYPE
                        ) IS
        SELECT *
          FROM g2109018
        WHERE cod_cia     = p_Cod_Cia
          AND num_regla   = p_num_regla
          AND num_version = p_num_version
          AND mca_inh     = 'N';
      --
      -- Encabezado Reglas por Perido:
      CURSOR cl_a2109011 IS
        SELECT 'S'
          FROM a2109011
        WHERE cod_cia = p_Cod_Cia
          AND anio    = p_Anio
          AND mes     = p_Mes
          AND mca_inh = 'N';
      --
      l_existe            VARCHAR2(1) := 'N';
      --
    BEGIN
      --
      -- Verifica si existe:
      OPEN  cl_a2109011;
      FETCH cl_a2109011 INTO l_existe;
      IF cl_a2109011%FOUND THEN
          --
          -- Borra encabezado Regla periodo:
          DELETE FROM a2109011
          WHERE cod_cia = p_cod_cia
            AND anio    = p_anio
            AND mes     = p_mes;
          --
          -- Borra detalle Regla periodo:
          DELETE FROM a2109012
          WHERE cod_cia = p_cod_cia
            AND anio    = p_anio
            AND mes     = p_mes;
          --
          -- Movido a p_elimina_poliza, Fec. 25-May-15, Version : 1.03
          -- DELETE FROM a2109013
          --
      END IF;
      CLOSE cl_a2109011;
      --
      FOR I IN cl_g2109017 LOOP
        --
        -- Inserta el encabezado Reglas Periodo:
        INSERT INTO a2109011
                ( COD_CIA           ,
                  NUM_REGLA         ,
                  NUM_VERSION       ,
                  ANIO              ,
                  MES               ,
                  NUM_NIVEL_JER     ,
                  MCA_PRIM_CARGA    ,
                  MCA_SUSCRIPCION   ,
                  COD_CAMPO         ,
                  VAL_CAMPO         ,
                  FEC_VALIDEZ       ,
                  MCA_INH           ,
                  COD_USR           ,
                  FEC_ACTU
                )
        VALUES ( I.cod_cia         ,
                  I.num_regla       ,
                  I.num_version     ,
                  P_anio            ,
                  P_mes             ,
                  I.num_nivel_jer   ,
                  I.mca_prim_carga  ,
                  I.mca_suscripcion ,
                  I.cod_campo       ,
                  I.val_campo       ,
                  I.fec_validez     ,
                  'N'               ,
                  USER              ,
                  TRUNC(SYSDATE)
                );
        --
        IF SQL%FOUND THEN
          --
          -- Inserta el detalle Reglas Periodo:
          FOR X IN cl_g2109018 (I.num_regla, I.num_version) LOOP
            --
            INSERT INTO a2109012
                    ( COD_CIA               ,
                      NUM_REGLA             ,
                      NUM_VERSION           ,
                      NUM_DETALLE           ,
                      ANIO                  ,
                      MES                   ,
                      EXP_ANTECEDENTE       ,
                      TIP_COMPARADOR        ,
                      EXP_CONSECUENTE       ,
                      MCA_ABRE_AGRUPACION   ,
                      MCA_CIERRA_AGRUPACION ,
                      TIP_CONECTOR_LOGICO   ,
                      MCA_INH               ,
                      COD_USR               ,
                      FEC_ACTU
                    )
            VALUES ( X.cod_cia               ,
                      X.num_regla             ,
                      X.num_version           ,
                      X.num_Detalle           ,
                      P_anio                  ,
                      P_mes                   ,
                      X.exp_antecedente       ,
                      X.tip_comparador        ,
                      X.exp_consecuente       ,
                      X.mca_abre_agrupacion   ,
                      X.mca_cierra_agrupacion ,
                      X.tip_conector_logico   ,
                      'N'                     ,
                      USER                    ,
                      TRUNC(SYSDATE)
                    );
            --
          END LOOP;
          --
        END IF;
        --
      END LOOP;
      --
    END p_carga_reglas_periodo;
    --
    -- --------------------------------------------------
    -- Autor  : Victor Borge              Version : 1.00
    -- Indenta: Manuel Rodriguez
    -- Fecha  : 09-Sep-14
    -- Nota   : Aplicar la Reglas
    -- --------------------------------------------------
    PROCEDURE p_aplica_reglas( p_cod_cia                   g2109019_mrd.cod_cia  %TYPE,  -- Version: 1.15 (indentar)
                                p_nom_tabla                 g2109019_mrd.nom_tabla%TYPE,
                                p_tip_nivel                 g2000020.tip_nivel    %TYPE,
                                p_cod_ramo                  g2000020.cod_ramo     %TYPE,
                                p_mes                       a2109011_mrd.mes      %TYPE,
                                p_anio                      a2109011_mrd.anio     %TYPE,
                                p_cant_regla_aplicada IN OUT VARCHAR2,
                                p_owner                     all_tab_columns.owner %TYPE DEFAULT 'TRON2000'
                              ) IS
      --
      -- Fec. 26-Jun-15, Version : 1.03 (Se agrego la tabla a2109011)
      CURSOR cl_g2109019 IS
        SELECT x.cod_campo, x.nom_prg_actualizacion
          FROM g2109019_mrd x
          INNER JOIN all_tab_columns c
            ON c.owner       = p_owner
            AND c.table_name  = x.nom_tabla
            AND c.column_name = x.cod_campo
          INNER JOIN a2109011 a      -- Version: 1.13 (se comenta).  Version: 1.15 (lo activa)
            ON a.cod_cia   = p_cod_cia
            AND a.anio      = p_anio
            AND a.mes       = p_mes
            AND a.cod_campo = x.cod_campo
          WHERE x.cod_cia   = p_cod_cia
            AND x.nom_tabla = p_nom_tabla
            AND x.mca_inh   = 'N'
          ORDER BY a.num_regla, c.column_id;   -- Version: 1.13 (se comenta).  Version: 1.15 (lo activa)
      --
      CURSOR cl_g2109019_dv( pl_cod_ramo g2000020.cod_ramo%TYPE ) IS
        SELECT x.cod_campo, x.nom_prg_actualizacion
          FROM g2109019_mrd x
          INNER JOIN g2000020 c
            ON c.cod_cia   = x.cod_cia
            AND c.cod_ramo  = pl_cod_ramo
            AND c.cod_campo = x.cod_campo
            AND c.tip_nivel = p_tip_nivel
          WHERE x.cod_cia   = p_cod_cia
            AND x.nom_tabla = p_nom_tabla
            AND x.mca_inh   = 'N'
          ORDER BY c.num_secu;
      --
      CURSOR cl_g2109019_cob( pl_cod_ramo a1002150.cod_ramo%TYPE ) IS
        SELECT x.cod_campo, x.nom_prg_actualizacion
          FROM g2109019_mrd x
          INNER JOIN a1002150 c
            ON c.cod_cia       = x.cod_cia
            AND c.cod_ramo      = pl_cod_ramo
            AND c.cod_modalidad = 99999
            AND c.cod_cob       = substr( x.cod_campo, 1, 4 )
            AND c.fec_validez = ( SELECT MAX( y.fec_validez )
                                    FROM a1002150 y
                                  WHERE y.cod_cia       = c.cod_cia
                                    AND y.cod_ramo      = c.cod_ramo
                                    AND y.cod_modalidad = c.cod_modalidad
                                    AND y.cod_cob       = c.cod_cob)  -- Version: 1.13
                                    --AND y.fec_validez   = c.fec_validez )  Version: 1.13
          WHERE x.cod_cia   = p_cod_cia
            AND x.nom_tabla = p_nom_tabla
            AND x.mca_inh   = 'N'
          ORDER BY c.num_secu;
      --
      TYPE ty_g2109019 IS TABLE OF cl_g2109019%ROWTYPE INDEX BY BINARY_INTEGER;
      t_g2109019 ty_g2109019;
      --
      CURSOR cl_a2109011( pl_cod_campo a2109011_mrd.cod_campo%TYPE ) IS
        SELECT r.*
          FROM a2109011_mrd r
          WHERE r.cod_cia   = p_cod_cia
            AND r.cod_campo = pl_cod_campo
            AND r.anio      = p_anio
            AND r.mes       = p_mes
            AND r.mca_inh   = 'N'
            AND r.num_version = ( SELECT MAX( x.num_version )
                                    FROM a2109011_mrd x
                                  WHERE x.cod_cia   = r.cod_cia
                                    AND x.num_regla = r.num_regla
                                    AND x.anio      = r.anio
                                    AND x.mes       = r.mes )
          ORDER BY r.num_nivel_jer, r.num_regla;
      --
      CURSOR cl_a2109012( pl_cod_cia   a2109012_mrd.cod_cia  %TYPE,
                          pl_num_regla  a2109012_mrd.num_regla %TYPE,
                          pl_num_version a2109012_mrd.num_version%TYPE,
                          pl_anio     a2109012_mrd.anio    %TYPE,
                          pl_mes     a2109012_mrd.mes    %TYPE ) IS
        SELECT d.*
          FROM a2109012_mrd d
          WHERE d.cod_cia     = pl_cod_cia
            AND d.num_regla   = pl_num_regla
            AND d.num_version = pl_num_version
            AND d.anio        = pl_anio
            AND d.mes         = pl_mes
            AND d.mca_inh     = 'N'
          ORDER BY d.num_detalle;
      --
      l_mca_aplica_regla                 VARCHAR2( 1 );
      l_valor                            VARCHAR2( 100 );
      l_expresion_filtro                 VARCHAR2( 32767 ):= NULL;
      l_exp_antecedente                  a2109012_mrd.exp_antecedente   %TYPE;
      l_exp_consecuente                  a2109012_mrd.exp_consecuente   %TYPE;
      l_mca_abre_agrupacion              VARCHAR2( 3 );
      l_mca_cierra_agrupacion            VARCHAR2( 3 );
      --
    BEGIN
      --
      t_g2109019.delete;
      IF p_tip_nivel = 0 THEN
        OPEN  cl_g2109019;
        FETCH cl_g2109019 BULK COLLECT INTO t_g2109019;
        CLOSE cl_g2109019;
      ELSIF p_tip_nivel = 6 THEN
        OPEN  cl_g2109019_cob( p_cod_ramo );
        FETCH cl_g2109019_cob BULK COLLECT INTO t_g2109019;
        CLOSE cl_g2109019_cob;
      ELSE
        OPEN  cl_g2109019_dv( p_cod_ramo );
        FETCH cl_g2109019_dv BULK COLLECT INTO t_g2109019;
        CLOSE cl_g2109019_dv;
      END IF;
      --
      FOR I IN 1..t_g2109019.count LOOP
        --
        FOR reg_a2109011 IN cl_a2109011( t_g2109019(i).cod_campo ) LOOP
          --
          l_mca_aplica_regla:= 'S';
          l_expresion_filtro:= NULL;
          FOR reg_a2109012 IN cl_a2109012( reg_a2109011.cod_cia,
                                            reg_a2109011.num_regla,
                                            reg_a2109011.num_version,
                                            reg_a2109011.anio,
                                            reg_a2109011.mes ) LOOP
            --
            IF reg_a2109012.mca_abre_agrupacion = 'S' THEN
              l_mca_abre_agrupacion := ' ( ';
            ELSE
              l_mca_abre_agrupacion := '';
            END IF;
            --
            IF reg_a2109012.mca_cierra_agrupacion = 'S' THEN
              l_mca_cierra_agrupacion := ' ) ';
            ELSE
              l_mca_cierra_agrupacion := '';
            END IF;
            --
            l_exp_antecedente := NVL(ea_k_genera_globales.f_genera_valor( reg_a2109012.exp_antecedente ),'0');
            l_exp_consecuente := NVL(ea_k_genera_globales.f_genera_valor( reg_a2109012.exp_consecuente ),'0');
            --
            l_expresion_filtro:= nvl( l_expresion_filtro, 'BEGIN'|| ' ' || ' IF ' ) ||
                                  nvl( reg_a2109012.tip_conector_logico, '' ) || ' ' ||
                                  l_mca_abre_agrupacion || l_exp_antecedente || ' ' ||
                                  reg_a2109012.tip_comparador || ' ' || l_exp_consecuente ||
                                  l_mca_cierra_agrupacion || ' ';
            --
          END LOOP;
          --
          IF l_expresion_filtro IS NOT NULL THEN
              --
              l_expresion_filtro:= l_expresion_filtro || 'THEN :1 := :2; ELSE :1 := :3; END IF;' || ' ' || 'END;';
              EXECUTE IMMEDIATE l_expresion_filtro  USING IN OUT l_mca_aplica_regla, 'S', 'N';
              --
          END IF;
          --
          IF l_mca_aplica_regla = 'S' THEN
            --
            p_cant_regla_aplicada := p_cant_regla_aplicada + 1;
            --
            l_valor := ea_k_genera_globales.f_genera_valor( reg_a2109011.val_campo );
            --
            -- Se encarga de grabar la regla:
            p_inserta_a2109013( p_nom_tabla,
                                t_g2109019(i).cod_campo,
                                reg_a2109011.num_regla,
                                reg_a2109011.num_version,
                                reg_a2109011.mca_prim_carga,
                                l_valor
                                );
            --
            trn_k_global.asigna( 'VAL_CAMPO', l_valor );
            trn_k_global.asigna( 'COD_CAMPO', t_g2109019(i).cod_campo );
            trn_k_global.asigna( 'NUM_REGLA', reg_a2109011.Num_Regla );
            trn_k_global.asigna( t_g2109019(i).cod_campo, l_valor );
            --
            IF t_g2109019(i).nom_prg_actualizacion IS NOT NULL THEN
              trn_p_dinamico( t_g2109019(i).nom_prg_actualizacion );
            END IF;
            --
          END IF;
          --
        END LOOP;
        --
      END LOOP;
      --
    END p_aplica_reglas;
    --
    -- --------------------------------------------------
    -- Autor  : Victor Borge              Version : 1.00
    -- Indenta: Manuel Rodriguez
    -- Fecha  : 09-Sep-14
    -- Nota   : Cargar los datos variables de riesgos.
    -- --------------------------------------------------
    PROCEDURE p_carga_datos_variables_riesgo( pl_cod_cia    a2000020.cod_cia    %TYPE,
                                              pl_num_poliza a2000020.num_poliza %TYPE,
                                              pl_num_riesgo a2000020.num_riesgo %TYPE,
                                              pl_cod_ramo  a2000020.cod_ramo  %TYPE ) IS
      --
      TYPE cursor_variable IS REF CURSOR;
      cl_a2000020 CURSOR_VARIABLE;
      --
      TYPE rec_dv IS RECORD ( 
        cod_campo         a2000020.cod_campo    %TYPE,
        val_campo         a2000020.val_campo    %TYPE,    -- Version : 1.13
        txt_campo         a2000020.txt_campo    %type 
      );  -- Version : 1.13
      --
      reg_dv    rec_dv;
      TYPE ty_dv IS TABLE OF reg_dv%TYPE  INDEX BY BINARY_INTEGER;
      tb_dv     ty_dv;
      --
    BEGIN
      --
      -- Se agrega a txt_campo. Version : 1.13
      OPEN cl_a2000020 FOR
        'SELECT a.cod_campo, a.val_campo, a.txt_campo
            FROM a2000020_' ||  pl_cod_ramo ||  ' a
          WHERE a.num_poliza    = :num_poliza
            AND a.cod_cia     = :cod_cia
            AND a.num_apli     = 0
            AND a.num_riesgo    = :num_riesgo
            AND a.mca_vigente   = ''S''
            AND a.mca_vigente_apli = ''S''
            AND a.mca_baja_riesgo = ''N'''
      USING pl_num_poliza, pl_cod_cia, pl_num_riesgo;
      FETCH cl_a2000020 BULK COLLECT INTO tb_dv;
      CLOSE cl_a2000020;
      --
      FOR indx IN 1..tb_dv.count LOOP
        trn_k_global.asigna( tb_dv(indx).cod_campo, tb_dv(indx).val_campo );
        --
        -- Registrar los valores en la memoria. Version : 1.13
        g_tb_dv( pl_num_riesgo||'-'|| tb_dv(indx).cod_campo ).val_campo:= tb_dv(indx).val_campo;
        g_tb_dv( pl_num_riesgo||'-'|| tb_dv(indx).cod_campo ).txt_campo:= tb_dv(indx).txt_campo;
      END LOOP;
      --
    END p_carga_datos_variables_riesgo;
    --
    -- --------------------------------------------------
    -- Autor  : Victor Borge              Version : 1.00
    -- Indenta: Manuel Rodriguez
    -- Fecha  : 09-Sep-14
    -- Nota   : Trabajar los riesgos
    -- --------------------------------------------------
    PROCEDURE p_trata_riesgos ( pl_cod_cia  a2000500.cod_cia     %TYPE,
                                pl_num_poliza a2000500.num_poliza%TYPE,
                                pl_cod_ramo  a2000500.cod_ramo   %TYPE ) IS
      --
      CURSOR cl_a2000031 IS
        SELECT *
          FROM a2000031
        WHERE cod_cia         = pl_cod_cia
          AND num_poliza      = pl_num_poliza
          AND mca_baja_riesgo = 'N'
          AND mca_vigente     = 'S';
      --
      l_mca_riesgo        s2000031.mca_riesgo%TYPE;
      --
    BEGIN
      --
      FOR reg_riesgos IN cl_a2000031 LOOP
        --
        ea_k_genera_globales.p_limpiar_valores;
        ea_k_genera_globales.p_limpiar_tablas;
        --
        ea_k_genera_globales.p_add_tables ( 'A2000031', 'TRON2000' );
        --
        ea_k_genera_globales.p_buscar_valores( 'cod_cia'      , reg_riesgos.cod_cia );
        ea_k_genera_globales.p_buscar_valores( 'num_poliza'   , reg_riesgos.num_poliza );
        ea_k_genera_globales.p_buscar_valores( 'num_spto'     , reg_riesgos.num_spto );
        ea_k_genera_globales.p_buscar_valores( 'num_apli'     , reg_riesgos.num_apli );
        ea_k_genera_globales.p_buscar_valores( 'num_spto_apli', reg_riesgos.num_spto_apli );
        ea_k_genera_globales.p_buscar_valores( 'num_riesgo'   , reg_riesgos.num_riesgo );
        --
        ea_k_genera_globales.p_genera_globales();
        --
        l_mca_riesgo := 'M';
        IF reg_riesgos.mca_baja_riesgo = 'S' THEN
            l_mca_riesgo := 'B';
        END IF;
        trn_k_global.asigna('mca_riesgo', l_mca_riesgo);
        --
        p_aplica_reglas( g_cod_cia, 'A2000031',  0, pl_cod_ramo, g_mes, g_anio, g_cant_regla_aplicada );
        --
        p_carga_datos_variables_riesgo( reg_riesgos.cod_cia,   reg_riesgos.num_poliza,
                                        reg_riesgos.num_riesgo, pl_cod_ramo );
        --
        p_aplica_reglas( g_cod_cia, 'A2000020', 2, pl_cod_ramo,  g_mes, g_anio, g_cant_regla_aplicada );
        --
        p_trata_coberturas( g_cod_cia, pl_cod_ramo, reg_riesgos.num_poliza,
                            reg_riesgos.num_riesgo, trn_k_global.devuelve( 'COD_MODALIDAD_AUTO' ) );
        --
        p_aplica_reglas( g_cod_cia, 'A2000040', 6, pl_cod_ramo,  g_mes, g_anio, g_cant_regla_aplicada );
        --
      END LOOP;
      --
    END p_trata_riesgos;
    --
    -- --------------------------------------------------
    -- Autor  : Victor Borge              Version : 1.00
    -- Indenta: Manuel Rodriguez
    -- Fecha  : 09-Sep-14
    -- Nota   : Trabajar las coberturas
    -- --------------------------------------------------
    PROCEDURE p_trata_coberturas( pl_cod_cia       a1002090.cod_cia   %TYPE,
                                  pl_cod_ramo      a1002090.cod_ramo   %TYPE,
                                  pl_num_poliza    a2000040.num_poliza  %TYPE,
                                  pl_num_riesgo    a2000040.num_riesgo   %TYPE,
                                  pl_cod_modalidad a1002090.cod_modalidad%TYPE 
                                ) IS
      --
      TYPE cursor_var IS REF CURSOR;
      cl_cob cursor_var;
      TYPE ty_rec_cob IS RECORD ( cod_cob         a2000040_999.cod_cob    %TYPE,
                                  cod_limite      a2000040_999.cod_limite   %TYPE,
                                  cod_franquicia  a2000040_999.cod_franquicia %TYPE,
                                  suma_aseg       a2000040_999.suma_aseg   %TYPE,
                                  tasa_cob        a2000040_999.tasa_cob    %TYPE,
                                  mca_seleccion   s2000040.mca_seleccion   %TYPE,
                                  tip_cob         a1002050.tip_cob      %TYPE,
                                  mca_tip_capital a1002150.mca_tip_capital  %TYPE );
      TYPE ty_cob IS TABLE OF ty_rec_cob INDEX BY BINARY_INTEGER;
      t_cob ty_cob;
      --
    BEGIN
      --
      t_cob.delete;
      --
      OPEN cl_cob FOR
        'SELECT c.cod_cob, c.cod_limite, c.cod_franquicia, c.suma_aseg, c.tasa_cob,
                decode( c.mca_baja_cob, ''N'', ''B'', ''*'' ) mca_seleccion, d.tip_cob, n.mca_tip_capital
            FROM a1002090 t
          INNER JOIN a1002050 d
              ON d.cod_cia     = t.cod_cia
            AND d.cod_cob     = t.cod_cob
          INNER JOIN a1002150 n
              ON n.cod_cia     = t.cod_cia
            AND n.cod_ramo     = t.cod_ramo
            AND n.cod_modalidad  = 99999
            AND n.cod_cob     = t.cod_cob
            AND n.fec_validez   = t.fec_validez
            LEFT JOIN a2000040_' || pl_cod_ramo || ' c
              ON c.num_poliza    = :pl_num_poliza
            AND c.cod_cia     = t.cod_cia
            AND c.num_riesgo    = :pl_num_riesgo
            AND c.mca_vigente   = ''S''
            AND c.mca_vigente_apli = ''S''
          WHERE t.cod_cia     = :pl_cod_cia
            AND t.cod_ramo     = :pl_cod_ramo
            AND t.cod_modalidad  = :pl_cod_modalidad
            AND t.fec_validez   = ( SELECT MAX( z.fec_validez)
                                      FROM a1002090 z
                                      WHERE z.cod_cia    = t.cod_cia
                                        AND z.cod_ramo    = t.cod_ramo
                                        AND z.cod_modalidad = t.cod_modalidad
                                        AND z.cod_cob    = t.cod_cob )'
      USING pl_num_poliza, pl_num_riesgo, pl_cod_cia, pl_cod_ramo, pl_cod_modalidad;
      FETCH cl_cob BULK COLLECT INTO t_cob;
      CLOSE cl_cob;
      --
      FOR I IN 1..t_cob.count LOOP
        trn_k_global.asigna( t_cob(i).cod_cob || '=>COD_LIMITE'     , t_cob( i ).cod_limite  );
        trn_k_global.asigna( t_cob(i).cod_cob || '=>COD_FRANQUICIA' , t_cob( i ).cod_franquicia  );
        trn_k_global.asigna( t_cob(i).cod_cob || '=>SUMA_ASEG'      , t_cob( i ).suma_aseg  );
        trn_k_global.asigna( t_cob(i).cod_cob || '=>TASA_COB'       , t_cob( i ).tasa_cob  );
        trn_k_global.asigna( t_cob(i).cod_cob || '=>MCA_SELECCION'  , t_cob( i ).mca_seleccion  );
        trn_k_global.asigna( t_cob(i).cod_cob || '=>TIP_COB'        , t_cob( i ).tip_cob  );
        trn_k_global.asigna( t_cob(i).cod_cob || '=>MCA_TIP_CAPITAL', t_cob( i ).mca_tip_capital  );
      END LOOP;
      --
    END p_trata_coberturas;
    --
    -- --------------------------------------------------------
    -- Autor : Manuel Rodriguez                 Version : 1.00
    -- Fecha : 09-Oct-14
    -- Nota  : Grabar las reglas a aplicar por poliza y riesgo
    -- --------------------------------------------------------
    PROCEDURE p_inserta_a2109013 ( p_nom_tabla       g2109019_mrd.nom_tabla%TYPE,
                                    p_cod_campo       g2109019.cod_campo%TYPE,
                                    p_num_regla       a2109011.num_regla%TYPE,
                                    p_num_version     a2109011.num_version%TYPE,
                                    p_mca_prim_carga  a2109011.mca_prim_carga%TYPE,
                                    p_valor           g2109017.val_campo%TYPE
                                  ) IS
        --
        l_cod_cia          a2000030.cod_cia        %TYPE;
        l_cod_ramo         a2000030.cod_ramo       %TYPE;
        l_num_poliza       a2000030.num_poliza     %TYPE;
        l_num_riesgo       a2109010.num_riesgo     %TYPE;
        l_existe           VARCHAR2(1);
        --
        CURSOR cr_a2109013 IS
          SELECT 'S'
            FROM a2109013
          WHERE cod_cia     = l_cod_cia
            AND cod_ramo    = l_cod_ramo
            AND num_poliza  = l_num_poliza
            AND num_riesgo  = l_num_riesgo
            AND anio        = g_anio
            AND mes         = g_mes
            AND nom_tabla   = p_nom_tabla
            AND cod_campo   = p_cod_campo
            AND num_regla   = p_num_regla
            AND num_version = p_num_version;
        --
    BEGIN
      --
      --
      l_cod_cia         := trn_k_global.devuelve('COD_CIA');
      l_cod_ramo        := trn_k_global.devuelve('COD_RAMO');
      l_num_poliza      := trn_k_global.devuelve('NUM_POLIZA');
      l_num_riesgo      := trn_k_global.devuelve('NUM_RIESGO');
      --
      l_existe := 'N';
      OPEN  cr_a2109013;
      FETCH cr_a2109013 INTO l_existe;
      CLOSE cr_a2109013;
      --
      IF l_existe = 'N' THEN
          --
          INSERT INTO a2109013
            ( COD_CIA           ,
              COD_RAMO          ,
              NUM_POLIZA        ,
              NUM_RIESGO        ,
              ANIO              ,
              MES               ,
              NOM_TABLA         ,
              COD_CAMPO         ,
              NUM_REGLA         ,
              NUM_VERSION       ,
              MCA_PRIM_CARGA    ,
              VALOR             ,
              MCA_INH           ,
              COD_USR           ,
              FEC_ACTU
              )
          VALUES
            ( l_cod_cia         ,
              l_cod_ramo        ,
              l_num_poliza      ,
              l_num_riesgo      ,
              g_anio            ,
              g_mes             ,
              p_nom_tabla       ,
              p_cod_campo       ,
              p_num_regla       ,
              p_num_version     ,
              p_mca_prim_carga  ,
              p_valor           ,
              'N'               ,
              USER              ,
              SYSDATE
              );
          --
      ELSE
          --
          UPDATE a2109013
            SET valor = p_valor
          WHERE cod_cia     = l_cod_cia
            AND cod_ramo    = l_cod_ramo
            AND num_poliza  = l_num_poliza
            AND num_riesgo  = l_num_riesgo
            AND anio        = g_anio
            AND mes         = g_mes
            AND nom_tabla   = p_nom_tabla
            AND cod_campo   = p_cod_campo
            AND num_regla   = p_num_regla
            AND num_version = p_num_version;
          --
      END IF;
      --
    END p_inserta_a2109013;
    --
    -- --------------------------------------------------
    -- Autor : Manuel Rodriguez           Version : 1.00
    -- Fecha : 22-Oct-14
    -- Nota  : Calcular el Descuentro TW
    -- --------------------------------------------------
    PROCEDURE p_cal_desc_tw ( p_dnr_ren                   a2109010.dnr_ren%TYPE,
                              p_factor_ajuste             a2109010.factor_ajuste%TYPE,  -- Version : 1.03
                              p_descuento_tw          OUT a2109010.desc_comercial_ren%TYPE
                            ) IS
      --
    BEGIN
      --
      --
      p_descuento_tw := ( ( (100 + p_dnr_ren) * (100 + p_factor_ajuste) )/100 ) - 100; -- Version : 1.03
      --
    END p_cal_desc_tw;
    --
    -- --------------------------------------------------
    -- Autor : Manuel Rodriguez           Version : 1.00
    -- Fecha : 23-Oct-14
    -- Nota  : Buscar la cantidad de renovaciones
    -- --------------------------------------------------
    PROCEDURE p_busca_num_renovaciones ( p_cod_cia                   a2109010.cod_cia%TYPE,
                                          p_num_poliza                a2109010.num_poliza%TYPE,
                                          p_num_renovaciones      OUT a2000030.num_renovaciones%TYPE
                                        ) IS
      --
      -- Busca Total Renovaciones:
      CURSOR cl_a2000030  IS
        SELECT num_renovaciones
          FROM a2000030 a
        WHERE cod_cia    = p_cod_cia
          AND num_poliza = p_num_poliza
          AND mca_poliza_anulada = 'N'
          AND num_spto   = ( SELECT MAX(b.num_spto)
                                FROM a2000030 b
                              WHERE b.cod_cia          = a.cod_cia
                                AND b.num_poliza       = a.num_poliza
                                AND b.mca_spto_anulado = 'N'
                                AND b.mca_spto_tmp     = 'N'
                            );
      --
    BEGIN
      --
      --
      OPEN  cl_a2000030;
      FETCH cl_a2000030 INTO p_num_renovaciones;
      CLOSE cl_a2000030;
      --
    END p_busca_num_renovaciones;
    --
    -- --------------------------------------------------
    -- Autor : Manuel Rodriguez           Version : 1.00
    -- Fecha : 23-Oct-14
    -- Nota  : Buscar la cantidad de renovaciones
    -- --------------------------------------------------
    FUNCTION f_num_renovaciones ( p_cod_cia                   a2109010.cod_cia%TYPE,
                                  p_num_poliza                a2109010.num_poliza%TYPE
                                ) RETURN NUMBER IS
      --
      -- Busca Total Renovaciones:
      CURSOR cl_a2000030  IS
        SELECT num_renovaciones
          FROM a2000030 a
          WHERE cod_cia    = p_cod_cia
            AND num_poliza = p_num_poliza
            AND mca_poliza_anulada = 'N'
            AND num_spto   = ( SELECT MAX(b.num_spto)
                                FROM a2000030 b
                                WHERE b.cod_cia          = a.cod_cia
                                  AND b.num_poliza       = a.num_poliza
                                  AND b.mca_spto_anulado = 'N'
                                  AND b.mca_spto_tmp     = 'N'
                            );
      --
      l_num_renovaciones a2000030.num_renovaciones%TYPE;
      --
    BEGIN
      --
      OPEN  cl_a2000030;
      FETCH cl_a2000030 INTO l_num_renovaciones;
      CLOSE cl_a2000030;
      --
      RETURN l_num_renovaciones;
      --
    END f_num_renovaciones;
    --
    -- --------------------------------------------------
    -- Autor  : Victor Borge              Version : 1.00
    -- Indenta: Manuel Rodriguez
    -- Fecha  : 09-Sep-14
    -- Nota   : Trabajar los riesgos
    -- --------------------------------------------------
    FUNCTION f_calula_riesgos ( p_cod_cia      a2000500.cod_cia     %TYPE,
                                p_num_poliza   a2000500.num_poliza%TYPE
                                ) RETURN NUMBER IS
      --
      CURSOR cl_a2000031 IS
      SELECT COUNT(*)
        FROM a2000031
        WHERE cod_cia         = p_cod_cia
          AND num_poliza      = p_num_poliza
          AND mca_baja_riesgo = 'N'
          AND mca_vigente     = 'S';
      --
      l_num_riesgos        a2000030.num_riesgos%TYPE;
      --
    BEGIN
      --
      OPEN  cl_a2000031;
      FETCH cl_a2000031 INTO l_num_riesgos;
      CLOSE cl_a2000031;
      --
      RETURN l_num_riesgos;
      --
    END f_calula_riesgos;
    --
    -- --------------------------------------------------
    -- Autor : Manuel Rodriguez           Version : 1.00
    -- Fecha : 03-Nov-14
    -- Nota  : Buscar el nombre del Limite anterior.
    -- --------------------------------------------------
    FUNCTION  f_nom_limite_ant ( p_cod_cia      a2000500.cod_cia   %TYPE,
                                  p_cod_ramo     a2000500.cod_ramo  %TYPE,
                                  p_num_poliza   a2000500.num_poliza%TYPE,
                                  p_num_riesgo   a2000031.num_riesgo%TYPE,
                                  p_cod_cob      a1002050.cod_cob   %TYPE
                                ) RETURN VARCHAR2 IS
      --
      l_cod_limite          a2000040.COD_LIMITE%TYPE;
      l_nom_limite          g2000400.NOM_LIMITE%TYPE;
      --
      -- Suma de cobertura
      TYPE cursor_var IS REF CURSOR;
      cl_a2000040 cursor_var;
      --
      CURSOR cl_g2000400 IS
        SELECT nom_limite
          FROM G2000400
          WHERE cod_cia    = p_cod_cia
            AND cod_ramo   = p_cod_ramo
            AND cod_cob    = p_cod_cob
            AND cod_limite = l_cod_limite;
      --
    BEGIN
      --
      -- Valor de la Cobertura de Accesorios:
      OPEN  cl_a2000040 FOR
        'SELECT cod_limite '                            || chr( 13 ) ||
        '  FROM a2000040_'||p_cod_ramo                  || chr( 13 ) ||
        ' WHERE num_poliza       = :p_num_poliza'       || chr( 13 ) ||
        '   AND cod_cia          = :p_cod_cia'          || chr( 13 ) ||
        '   AND num_apli         = 0'                   || chr( 13 ) ||
        '   AND num_riesgo       = :p_num_riesgo'       || chr( 13 ) ||
        '   AND cod_cob          = :p_cod_cob'          || chr( 13 ) ||
        '   AND mca_baja_riesgo  = ''N'''               || chr( 13 ) ||
        '   AND mca_vigente      = ''S'''               || chr( 13 ) ||
        '   AND mca_baja_cob     = ''N'''
      USING p_num_poliza, p_cod_cia, p_num_riesgo, p_cod_cob;
      FETCH cl_a2000040 INTO l_cod_limite;
      CLOSE cl_a2000040;
      --
      OPEN  cl_g2000400;
      FETCH cl_g2000400 INTO l_nom_limite;
      CLOSE cl_g2000400;
      --
      RETURN l_nom_limite;
      --
    END f_nom_limite_ant;
    --
    -- --------------------------------------------------
    -- Autor : Manuel Rodriguez           Version : 1.00
    -- Fecha : 03-Nov-14
    -- Nota  : Buscar el nombre del Limite anterior.
    -- --------------------------------------------------
    FUNCTION  f_nom_limite_ren ( p_cod_cia      a2000500.cod_cia   %TYPE,
                                  p_cod_ramo     a2000500.cod_ramo  %TYPE,
                                  p_num_poliza   a2000500.num_poliza%TYPE,
                                  p_num_riesgo   a2000031.num_riesgo%TYPE,
                                  p_cod_cob      a1002050.cod_cob   %TYPE
                                ) RETURN VARCHAR2 IS
      --
      l_cod_limite          a2000040.COD_LIMITE%TYPE;
      l_nom_limite          g2000400.NOM_LIMITE%TYPE;
      --
      CURSOR cl_r2000040 IS
        SELECT cod_limite
          FROM r2000040
          WHERE cod_cia    = p_cod_cia
            AND num_poliza = p_num_poliza
            AND num_riesgo = p_num_riesgo
            AND cod_cob    = p_cod_cob;
      --
      CURSOR cl_g2000400 IS
        SELECT nom_limite
          FROM G2000400
          WHERE cod_cia    = p_cod_cia
            AND cod_ramo   = p_cod_ramo
            AND cod_cob    = p_cod_cob
            AND cod_limite = l_cod_limite;
      --
    BEGIN
      --
      OPEN  cl_r2000040;
      FETCH cl_r2000040 INTO l_cod_limite;
      CLOSE cl_r2000040;
      --
      OPEN  cl_g2000400;
      FETCH cl_g2000400 INTO l_nom_limite;
      CLOSE cl_g2000400;
      --
      RETURN l_nom_limite;
      --
    END f_nom_limite_ren;
    --
    -- --------------------------------------------------
    -- Autor : Manuel Rodriguez           Version : 1.00
    -- Fecha : 05-Nov-14
    -- Nota  : Buscar el Error presentado.
    -- --------------------------------------------------
    FUNCTION f_busca_error ( p_fec_tratamiento   a2000520.fec_tratamiento %TYPE,
                              p_num_order         a2000520.num_orden       %TYPE,
                              p_tip_mvto_batch    a2000520.tip_mvto_batch  %TYPE,
                              p_cod_cia           a2000500.cod_cia         %TYPE,
                              p_num_poliza        a2000500.num_poliza      %TYPE,
                              p_num_riesgo        a2000031.num_riesgo      %TYPE
                            ) RETURN VARCHAR2 IS
      --
      l_txt_error          a2000520.txt_error%TYPE;
      --
      CURSOR cl_a2000520_r IS
      SELECT txt_error
        FROM a2000520
        WHERE fec_tratamiento = p_fec_tratamiento
          AND num_orden       = p_num_order
          AND tip_mvto_batch  = p_tip_mvto_batch
          AND cod_cia         = p_cod_cia
          AND num_poliza      = p_num_poliza
          AND num_riesgo      = p_num_riesgo;
      --
      CURSOR cl_a2000520 IS
      SELECT txt_error
        FROM a2000520
        WHERE fec_tratamiento = p_fec_tratamiento
          AND num_orden       = p_num_order
          AND tip_mvto_batch  = p_tip_mvto_batch
          AND cod_cia         = p_cod_cia
          AND num_poliza      = p_num_poliza;
      --
    BEGIN
      --
      OPEN  cl_a2000520_r;
      FETCH cl_a2000520_r INTO l_txt_error;
      IF cl_a2000520_r%NOTFOUND THEN
        --
        OPEN  cl_a2000520;
        FETCH cl_a2000520 INTO l_txt_error;
        CLOSE cl_a2000520;
        --
      END IF;
      CLOSE cl_a2000520_r;
      --
      RETURN l_txt_error;
      --
    END f_busca_error;
    --
    -- --------------------------------------------------
    -- Autor : Manuel Rodriguez           Version : 1.01
    -- Fecha : 11-Feb-15
    -- Nota  : Buscar el  Nombre del Ambiete.
    -- --------------------------------------------------
    FUNCTION f_busca_ambiente RETURN VARCHAR2 IS
      --
      l_nom_ambiente  VARCHAR2(30);
      --
      CURSOR cr_ambiente IS
      SELECT upper(sys_context('userenv','instance_name'))
        FROM dual;
      --
    BEGIN
      --
      OPEN  cr_ambiente;
      FETCH cr_ambiente INTO l_nom_ambiente;
      CLOSE cr_ambiente;
      --
      RETURN l_nom_ambiente;
      --
    END f_busca_ambiente;
    --
    -- --------------------------------------------------
    -- Autor : Manuel Rodriguez           Version : 1.03
    -- Fecha : 19-May-15
    -- Nota  : Buscar maximo de riesgo individual.
    -- --------------------------------------------------
    FUNCTION f_busca_max_riesgo ( p_cod_cia      g2309001.cod_cia  %TYPE,
                                  p_cod_ramo     g2309001.cod_ramo %TYPE
                                ) RETURN NUMBER IS
      --
      CURSOR cl_g2309001 IS
      SELECT max_riesgo_ind
        FROM g2309001
        WHERE cod_cia  = p_cod_cia
          AND cod_ramo = p_cod_ramo
          AND mca_inh  = 'N';
      --
      l_max_riesgo_ind    g2309001.max_riesgo_ind%TYPE := 0;
      --
    BEGIN
      --
      OPEN  cl_g2309001;
      FETCH cl_g2309001 INTO l_max_riesgo_ind;
      CLOSE cl_g2309001;
      --
      RETURN l_max_riesgo_ind;
      --
    END f_busca_max_riesgo;
    --
    -- ----------------------------------------------------
    -- Autor : Manuel Rodriguez             Version : 1.03
    -- Fecha : 12-Jun-15
    -- Nota  : Verifica Poliza y riesgo de baja. Regla 66.
    -- ----------------------------------------------------
    FUNCTION f_verifica_pol_riesgo ( p_cod_cia      a2000030.cod_cia     %TYPE,
                                      p_cod_ramo     a2000030.cod_ramo    %TYPE,
                                      p_num_poliza   a2000030.num_poliza  %TYPE,
                                      p_num_riesgo   a2000031.num_riesgo  %TYPE
                                    ) RETURN VARCHAR2 IS
      --
      l_cod_ramo_exceso       a2000030.cod_ramo    %TYPE := NULL;
      l_num_poliza_base       a2000031.num_poliza  %TYPE;
      l_num_riesgo_base       a2000031.num_riesgo  %TYPE;
      l_mca_pol_anulada       VARCHAR2(1) := 'N';
      l_mca_baja_riesgo       VARCHAR2(1) := 'N';
      --
      -- Busca Poliza:
      CURSOR cl_a2000030  IS
        SELECT 'S'
          FROM a2000030 a
        WHERE cod_cia    = p_cod_cia
          AND num_poliza = l_num_poliza_base
          AND mca_poliza_anulada = 'S'
          AND num_spto   = ( SELECT MAX(b.num_spto)
                                FROM a2000030 b
                              WHERE b.cod_cia          = a.cod_cia
                                AND b.num_poliza       = a.num_poliza
                                AND b.mca_spto_anulado = 'N'
                                AND b.mca_spto_tmp     = 'N'
                            );
      --
      -- Verifica el risgo:
      CURSOR cl_a2000031 IS
        SELECT 'S'
          FROM a2000031 a
        WHERE cod_cia         = p_cod_cia
          AND num_poliza      = l_num_poliza_base
          AND num_riesgo      = l_num_riesgo_base
          AND mca_baja_riesgo = 'S'
          AND mca_vigente     = 'S'
          AND num_spto   = ( SELECT MAX(b.num_spto)
                                FROM a2000031 b
                              WHERE b.cod_cia    = a.cod_cia
                                AND b.num_poliza = a.num_poliza
                                AND b.num_riesgo = a.num_riesgo
                                AND b.num_spto IN ( SELECT c.num_spto
                                                      FROM a2000030 c
                                                      WHERE c.cod_cia          = b.cod_cia
                                                        AND c.num_poliza       = b.num_poliza
                                                        AND c.mca_spto_anulado = 'N'
                                                        AND c.mca_spto_tmp     = 'N'
                                                  )
                            );
      --
      -- Buscar Ramo Exceso:
      CURSOR C_TA999003 IS
        SELECT TO_NUMBER(val_campo) val_campo
          FROM TA999003
        WHERE cod_cia   = g_cod_cia
          AND cod_campo = 'COD_RAMO_EXCESO'
          AND mca_inh   = 'N';
      --
    BEGIN
      --
      -- M.R., Fec. 22-Abr-15, Version : 1.03
      OPEN  C_TA999003;
      FETCH C_TA999003 INTO l_cod_ramo_exceso;
      CLOSE C_TA999003;
      --
      IF p_cod_ramo = l_cod_ramo_exceso THEN
          --
          -- Fec. 5-ene-18, Version : 1.14 (Se cambia la letra (V) por la (R) de riesgo base)
          l_num_poliza_base := TO_NUMBER(f_campo_variable_a(p_cod_cia, p_num_poliza, 'NUM_POLIZA_BASE', 'R', p_cod_ramo, p_num_riesgo));
          l_num_riesgo_base := TO_NUMBER(f_campo_variable_a(p_cod_cia, p_num_poliza, 'NUM_RIESGO_BASE', 'R', p_cod_ramo, p_num_riesgo));
          TRN_K_GLOBAL.asigna('mca_riesgo', 'M');
          --
          OPEN  cl_a2000030;
          FETCH cl_a2000030 INTO l_mca_pol_anulada;
          CLOSE cl_a2000030;
          IF l_mca_pol_anulada = 'S' THEN
            TRN_K_GLOBAL.asigna('mca_riesgo', 'B');
            RETURN CHR(39)||l_mca_pol_anulada||CHR(39);
          ELSE
            --
            OPEN  cl_a2000031;
            FETCH cl_a2000031 INTO l_mca_baja_riesgo;
            CLOSE cl_a2000031;
            --
            IF l_mca_baja_riesgo = 'S' THEN
                TRN_K_GLOBAL.asigna('mca_riesgo', 'B');
            END IF;
            --
            RETURN CHR(39)||l_mca_baja_riesgo||CHR(39);
            --
          END IF;
          --
      ELSE -- Esto es para los demas ramos:
          RETURN CHR(39)||l_mca_baja_riesgo||CHR(39);
      END IF;
      --
    END f_verifica_pol_riesgo;
    --
    -- -----------------------------------------------------
    -- Autor : Manuel Rodriguez              Version : 1.03
    -- Fecha : 25-Jun-15
    -- Nota  : Verifica si el Agente esta desactivado. Las
    --       : reclas son (68, 69, 70, 67), para los campos
    --       : COD_GESTOR, COD_NIVEL3, TIP_GESTOR, COD_AGT.
    -- -----------------------------------------------------
    FUNCTION f_verifica_agt_pol ( p_cod_cia         a2000030.cod_cia          %TYPE,
                                  p_cod_agt         a2000030.cod_agt          %TYPE,
                                  p_fec_vcto_poliza a2000030.fec_efec_poliza  %TYPE
                                  ) RETURN VARCHAR2 IS
      --
      l_mca_inh               a1001332.mca_inh        %TYPE;
      l_tip_situacion         a1001332.tip_situacion  %TYPE;
      l_agt_anulado           VARCHAR2(1) := 'N';
      --
      -- Busca Poliza:
      CURSOR cl_a1001332  IS
        SELECT mca_inh, tip_situacion
          FROM a1001332 a
        WHERE a.cod_cia     = p_cod_cia
          AND a.cod_agt     = p_cod_agt
          AND a.fec_validez = (SELECT MAX(fec_validez)
                                  FROM a1001332 b
                                WHERE b.cod_cia = a.cod_cia
                                  AND b.cod_agt = a.cod_agt
                                  AND b.fec_validez <= p_fec_vcto_poliza
                              );
      --
    BEGIN
      --
      --
      OPEN  cl_a1001332;
      FETCH cl_a1001332 INTO l_mca_inh, l_tip_situacion;
      CLOSE cl_a1001332;
      IF l_mca_inh = 'S'  OR l_tip_situacion = 2 THEN
          l_agt_anulado := 'S';
      END IF;
      --
      RETURN CHR(39)||l_agt_anulado||CHR(39);
      --
    END f_verifica_agt_pol;
    --
    -- -----------------------------------------------------
    -- Autor : Manuel Rodriguez           Version :    1.05
    -- Fecha : 29-Sep-16
    -- Nota  : Verifica si la Fecha de Vigencia de la Poliza
    --       : es mayor a la Fecha Fin del Prestamo.
    -- -----------------------------------------------------
    FUNCTION f_verifica_fec_vcto_pol( p_cod_cia         a2000030.cod_cia          %TYPE,
                                      p_cod_ramo        a2000030.cod_ramo         %TYPE,
                                      p_num_poliza      a2000030.num_poliza       %TYPE,
                                      p_fec_vcto_poliza a2000030.fec_efec_poliza  %TYPE
                                    ) RETURN VARCHAR2 IS
      --
      l_mca_fec_mayor         VARCHAR2(1) := 'N';
      l_fec_fin_prestamo      a2000030.fec_vcto_poliza%TYPE;
      l_fec_vcto_poliza       a2000030.fec_vcto_poliza%TYPE;
      l_num_periodo           NUMBER(4) := 0;
      l_num_periodos          NUMBER(4) := 0;
      --
      CURSOR cr_a2000030 IS
        SELECT fec_vcto_poliza
          FROM a2000030 a
          WHERE a.cod_cia    = p_cod_cia
            AND a.cod_ramo   = p_cod_ramo
            AND a.num_poliza = p_num_poliza
            AND a.mca_poliza_anulada = 'N'
            AND a.num_spto = (SELECT max(num_spto)
                                FROM a2000030 b
                              WHERE b.cod_cia          = a.cod_cia
                                AND b.num_poliza       = a.num_poliza
                                AND b.mca_spto_anulado = 'N'
                                AND b.mca_spto_tmp     = 'N'
                            );
      --
      CURSOR cr_a2000020_346 IS
        SELECT to_date(val_campo,'ddmmyyyy')
          FROM a2000020_346
          WHERE cod_cia     = p_cod_cia
            AND cod_ramo    = p_cod_ramo
            AND num_poliza  = p_num_poliza
            AND cod_campo   = 'FEC_FIN_PRESTAMO'
            AND mca_vigente = 'S';
      --
      CURSOR cr_a2000020_346_P IS
        SELECT to_number(val_campo)
          FROM a2000020_346
          WHERE cod_cia     = p_cod_cia
            AND cod_ramo    = p_cod_ramo
            AND num_poliza  = p_num_poliza
            AND cod_campo   = 'NUM_PERIODO'
            AND mca_vigente = 'S';
      --
      CURSOR cr_a2000020_346_PS IS
        SELECT to_number(val_campo)
          FROM a2000020_346
          WHERE cod_cia     = p_cod_cia
            AND cod_ramo    = p_cod_ramo
            AND num_poliza  = p_num_poliza
            AND cod_campo   = 'NUM_PERIODOS'
            AND mca_vigente = 'S';
      --
    BEGIN
      --
      OPEN  cr_a2000020_346;
      FETCH cr_a2000020_346 INTO l_fec_fin_prestamo;
      IF cr_a2000020_346%FOUND THEN   -- Version : 1.06 (Restar el mes de gracia)
        SELECT add_months(l_fec_fin_prestamo, -1)
          INTO l_fec_fin_prestamo
          FROM dual;
      END IF;
      CLOSE cr_a2000020_346;
      --
      OPEN  cr_a2000020_346_p;
      FETCH cr_a2000020_346_p INTO l_num_periodo;
      CLOSE cr_a2000020_346_p;
      --
      OPEN  cr_a2000020_346_ps;
      FETCH cr_a2000020_346_ps INTO l_num_periodos;
      CLOSE cr_a2000020_346_ps;
      --
      IF p_fec_vcto_poliza > l_fec_fin_prestamo AND l_num_periodos > l_num_periodo THEN
          l_mca_fec_mayor := 'S';
      END IF;
      --
      RETURN l_mca_fec_mayor;
      --
    END f_verifica_fec_vcto_pol;
    --
    -- -----------------------------------------------------
    -- Autor : Manuel Rodriguez           Version :    1.05
    -- Fecha : 29-Sep-16
    -- Nota  : Buscar la Fecha Fin del Prestamo.
    -- -----------------------------------------------------
    FUNCTION f_buscar_fec_fin_prestamo( p_cod_cia         a2000030.cod_cia          %TYPE,
                                        p_cod_ramo        a2000030.cod_ramo         %TYPE,
                                        p_num_poliza      a2000030.num_poliza       %TYPE
                                      ) RETURN VARCHAR2 IS
      --
      l_fec_fin_prestamo      VARCHAR2(8);
      l_fec_fin_prestamo_f    a2000030.fec_vcto_poliza%TYPE;  -- Version : 1.06
      --
      CURSOR cr_a2000020_346 IS
        SELECT to_date(val_campo,'ddmmyyyy')  -- Version : 1.06
          FROM a2000020_346
        WHERE cod_cia     = p_cod_cia
          AND cod_ramo    = p_cod_ramo
          AND num_poliza  = p_num_poliza
          AND cod_campo   = 'FEC_FIN_PRESTAMO'
          AND mca_vigente = 'S';
      --
    BEGIN
      --
      OPEN  cr_a2000020_346;
      FETCH cr_a2000020_346 INTO l_fec_fin_prestamo_f;
      IF cr_a2000020_346%FOUND THEN   -- Version : 1.06 (Restar el mes de gracia)
        --
        SELECT add_months(l_fec_fin_prestamo_f, -1)
          INTO l_fec_fin_prestamo_f
          FROM dual;
        --
        l_fec_fin_prestamo := to_char(l_fec_fin_prestamo_f,'ddmmyyyy');
        --
      END IF;
      CLOSE cr_a2000020_346;
      --
      RETURN l_fec_fin_prestamo;
      --
    END f_buscar_fec_fin_prestamo;
    --
    -- Se llama desde JAVA:
    PROCEDURE p_asigna_globales_menu_poliza IS
    BEGIN
      --
      trn_k_global.asigna('c_mca_poliza',     'P');
      trn_k_global.asigna('c_consulta',       'S');
      trn_k_global.asigna('c_externo',        'S');
      trn_k_global.asigna('c_cod_cia',         trn_k_global.cod_cia);
      trn_k_global.asigna('c_fecha_consulta',     '');
      --
    END;
    --
    -- Se llama desde JAVA:
    PROCEDURE p_asigna_globales_menu_preren IS
      --
      nNum_Spto a2000030.num_spto%type;
      --
    BEGIN
      --
      trn_k_global.asigna('c_mca_poliza',     'R');
      trn_k_global.asigna('c_consulta',       'S');
      trn_k_global.asigna('c_externo',        'S');
      trn_k_global.asigna('c_cod_cia',         trn_k_global.cod_cia);
      --
      BEGIN
        SELECT MAX(num_spto)
          INTO nNum_Spto
          FROM a2000030
          WHERE cod_cia    = trn_k_global.cod_cia
            AND num_poliza = trn_k_global.devuelve('c_num_poliza');
      EXCEPTION WHEN OTHERS THEN
        NULL;
      END;
      --
      trn_k_global.asigna('c_num_spto',        nNum_spto + 1 );
      trn_k_global.asigna('c_fecha_consulta',  '');
      --
    END p_asigna_globales_menu_preren;
    --
    -- --------------------------------------------------------------
    -- Autor : Victor Borges
    -- Fecha : 14-Ene-15
    -- Nota  : Buscar las fechas del riesgo para el calculo del DNR.
    -- --------------------------------------------------------------
    PROCEDURE p_fechas_riesgo(p_cod_cia               a2000030.cod_cia         %TYPE,
                              p_num_poliza            a2000030.num_poliza      %TYPE,
                              p_num_riesgo            a2000031.num_riesgo      %TYPE,
                              p_fec_efec_riesgo  OUT  a2000031.fec_efec_riesgo %TYPE,
                              p_fec_vcto_riesgo  OUT  a2000031.fec_vcto_riesgo %TYPE ) IS
      --
      CURSOR cl_fec_riesgos IS
        SELECT xx.num_poliza, r.num_riesgo, r.num_spto,
              decode( xx.tip_spto, 'RF', xx.fec_actu, r.fec_efec_riesgo ) fec_efec_riesgo,
              r.fec_vcto_riesgo, r.mca_baja_riesgo, xx.num_renovaciones
          FROM a2000030 xx
          INNER JOIN a2000031 r
              ON r.cod_cia       = xx.cod_cia
              AND r.num_poliza    = xx.num_poliza
              AND r.num_spto      = xx.num_spto
              AND r.num_apli      = xx.num_apli
              AND r.num_spto_apli = xx.num_spto_apli
              AND r.num_riesgo    = p_num_riesgo
          WHERE xx.cod_cia          = p_cod_cia
            AND xx.num_poliza       = p_num_poliza
            AND xx.mca_spto_anulado = 'N'
            AND xx.num_renovaciones = (SELECT MAX(y.num_renovaciones)
                                        FROM a2000030 y
                                        WHERE y.cod_cia          = xx.cod_cia
                                          AND y.num_poliza       = xx.num_poliza
                                          AND y.mca_spto_anulado = 'N'
                                          AND y.mca_spto_tmp     = 'N'
                                      )
        ORDER BY r.num_spto;
      --
      reg_fec_riesgos   cl_fec_riesgos%ROWTYPE;
      --
      l_fec_efec_riesgo a2000031.fec_efec_riesgo %TYPE;
      l_fec_vcto_riesgo a2000031.fec_vcto_riesgo %TYPE;
      l_fec_efec_actual a2000031.fec_efec_riesgo %TYPE;
      l_num_riesgo      a2000031.num_riesgo      %TYPE := 0;
      l_num_poliza      a2000030.num_poliza      %TYPE := '0';
      l_mca_baja_riesgo a2000031.mca_baja_riesgo %TYPE;
      --
    BEGIN
      --
      FOR reg_fec_riesgos IN cl_fec_riesgos LOOP
        --
        IF (l_num_riesgo = 0) OR (l_num_poliza = '0') THEN
            --
            l_fec_efec_riesgo  := reg_fec_riesgos.fec_efec_riesgo;
            l_num_poliza       := reg_fec_riesgos.num_poliza;
            l_num_riesgo       := reg_fec_riesgos.num_riesgo;
            l_fec_vcto_riesgo  := reg_fec_riesgos.fec_vcto_riesgo;
            --
        ELSE
            IF (reg_fec_riesgos.mca_baja_riesgo = 'N' AND
                l_mca_baja_riesgo = 'S' AND
                l_fec_efec_actual <> reg_fec_riesgos.fec_efec_riesgo   ) THEN
              --
              l_fec_efec_riesgo := reg_fec_riesgos.fec_efec_riesgo;
              l_fec_vcto_riesgo := reg_fec_riesgos.fec_vcto_riesgo;
              --
            END IF;
        END IF;
        --
        l_mca_baja_riesgo := reg_fec_riesgos.mca_baja_riesgo;
        l_fec_efec_actual := reg_fec_riesgos.fec_efec_riesgo;
        --
      END LOOP;
      --
      p_fec_efec_riesgo := l_fec_efec_riesgo;
      p_fec_vcto_riesgo := l_fec_vcto_riesgo;
      --
    END p_fechas_riesgo;
   --
END ea_k_ap2109999_mrd;
