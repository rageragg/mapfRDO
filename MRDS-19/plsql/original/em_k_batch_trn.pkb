CREATE OR REPLACE PACKAGE BODY em_k_batch_trn AS
 --
 /**
 || Llamador para procesos batch
 ||
 */
 --
 /* -------------------- VERSION = 1.50 -------------------- */
 --
 /* -------------------- MODIFICACIONES --------------------
 || 2020/04/07 - MJORTI1 - 1.50 - (MU-2020-017612)
 || Se modifica para eliminar de fp_permite_filtro el tipo
 || movimiento batch suspension plan aportacion.
 */ --------------------------------------------------------
 --
 /* --------------------------------------------------
 || Aqui comienza la declaracion de variables GLOBALES
 */ --------------------------------------------------
  --
  g_k_si           CONSTANT VARCHAR2(1) := trn.SI;
  --
 /* ---------------------------------------------------
 || Registro donde se hace el query
 */ ---------------------------------------------------
 --
 TYPE reg_a2000500 IS RECORD
      (clave                   VARCHAR2(18)                           ,
       cod_cia                 a2000500.cod_cia                 %TYPE ,
       cod_sector              a2000500.cod_sector              %TYPE ,
       cod_ramo                a2000500.cod_ramo                %TYPE ,
       num_poliza_grupo        a2000500.num_poliza_grupo        %TYPE ,
       num_contrato            a2000500.num_contrato            %TYPE ,
       num_subcontrato         a2000500.num_subcontrato         %TYPE ,
       num_poliza_cliente      a2000500.num_poliza_cliente      %TYPE ,
       num_poliza              a2000500.num_poliza              %TYPE ,
       num_poliza_tronador     a2000500.num_poliza_tronador     %TYPE ,
       num_spto                a2000500.num_spto                %TYPE ,
       num_apli                a2000500.num_apli                %TYPE ,
       num_spto_apli           a2000500.num_spto_apli           %TYPE ,
       tip_poliza_tr           a2000500.tip_poliza_tr           %TYPE ,
       fec_efec_spto           a2000500.fec_efec_spto           %TYPE ,
       hora_desde              a2000500.hora_desde              %TYPE ,
       fec_vcto_spto           a2000500.fec_vcto_spto           %TYPE ,
       num_recibo              a2000500.num_recibo              %TYPE ,
       mca_prima_manual        a2000500.mca_prima_manual        %TYPE ,
       cod_spto                a2000500.cod_spto                %TYPE ,
       sub_cod_spto            a2000500.sub_cod_spto            %TYPE ,
       cod_tip_spto            a2000500.cod_tip_spto            %TYPE ,
       txt_motivo_spto         a2000500.txt_motivo_spto         %TYPE ,
       mca_renueva             a2000500.mca_renueva             %TYPE ,
       mca_renueva_tmp         a2000500.mca_renueva_tmp         %TYPE ,
       mca_periodicidad        a2000500.mca_periodicidad        %TYPE ,
       cant_renovaciones       a2000500.cant_renovaciones       %TYPE ,
       mca_prorrata            a2000500.mca_prorrata            %TYPE ,
       mca_devuelve_todo       a2000500.mca_devuelve_todo       %TYPE ,
       tip_spto_accion         a2000500.tip_spto_accion         %TYPE ,
       mca_pre_renovacion      a2000500.mca_pre_renovacion      %TYPE ,
       cod_usr_captura         a2000500.cod_usr_captura         %TYPE ,
       tip_autoriza_ct         a2000500.tip_autoriza_ct         %TYPE ,
       mca_anulacion_por_deuda a2000500.mca_anulacion_por_deuda %TYPE ,
       cod_negocio             a2000500.cod_negocio             %TYPE ,
       num_spto_anulado        a2000500.num_spto_anulado        %TYPE ,
       idn_val                 a2000500.idn_val                 %TYPE );
 --
 g_reg                       REG_A2000500;
 g_reg_nulo                  REG_A2000500;
 --
 g_cursor                    PLS_INTEGER;
 g_select                    VARCHAR2(2000);
 --
 g_fila                      BINARY_INTEGER;
 g_fila_c                    BINARY_INTEGER;
 --
 g_fila_c_fin                BINARY_INTEGER;
 g_select_fin                VARCHAR2(2000);
 g_where_fin                 VARCHAR2(2000);
 --
 g_trazas_activas            BOOLEAN := FALSE;
 --
 g_cod_cia                   a2000030.cod_cia              %TYPE;
 g_cod_sector                a2000030.cod_sector           %TYPE;
 g_cod_ramo                  a2000030.cod_ramo             %TYPE;
 g_cod_nivel1                a2000030.cod_nivel1           %TYPE;
 g_cod_nivel2                a2000030.cod_nivel2           %TYPE;
 g_cod_nivel3                a2000030.cod_nivel3           %TYPE;
 g_cod_agt                   a2000030.cod_agt              %TYPE;
 g_num_poliza                a2000030.num_poliza           %TYPE;
 g_num_poliza_grupo          a2000030.num_poliza_grupo     %TYPE;
 g_num_poliza_cliente        a2000030.num_poliza_cliente   %TYPE;
 --
 g_num_spto                  a2000030.num_spto             %TYPE;
 g_num_apli                  a2000030.num_apli             %TYPE;
 g_num_spto_apli             a2000030.num_spto_apli        %TYPE;
 --
 g_num_poliza_definitivo     a2000030.num_poliza           %TYPE;
 g_mca_provisional           a2000030.mca_provisional      %TYPE;
 g_num_riesgo                a2000031.num_riesgo           %TYPE;
 --
 g_tip_mvto_batch            a2000500.tip_mvto_batch       %TYPE;
 g_fec_tratamiento           a2000500.fec_tratamiento      %TYPE;
 g_num_orden                 a2000500.num_orden            %TYPE;
 g_mca_pre_renovacion        a2000500.mca_pre_renovacion   %TYPE;
 g_max_num_riesgos           a2000500.num_riesgos          %TYPE;
 g_tip_situ                  a2000500.tip_situ             %TYPE;
 --
 tip_mvto_batch_origen       a2000500.tip_mvto_batch       %TYPE;
 --
 g_cod_excepcion             a2000500.cod_excepcion        %TYPE;
 g_nom_excepcion             a2000500.nom_excepcion        %TYPE;
 g_cod_excepcion_defecto     g2000590.cod_excepcion        %TYPE;
 g_nom_excepcion_defecto     g2000590.nom_excepcion        %TYPE;
 --
 g_max_spto_vigente          a2000500.max_spto_vigente     %TYPE;
 --
 g_tip_spto                  a2991800.tip_spto             %TYPE;
 --
 g_cod_spto                  a2000500.cod_spto             %TYPE;
 g_sub_cod_spto              a2000500.sub_cod_spto         %TYPE;
 --
 g_cod_tip_spto              g2990300.cod_tip_spto         %TYPE;
 g_cod_usr_captura           a2000500.cod_usr_captura      %TYPE;
 g_txt_motivo_spto           a2000500.txt_motivo_spto      %TYPE;
 --
 g_tip_spto_as               a2991800.tip_spto             %TYPE;
 g_cod_spto_as               a2000500.cod_spto             %TYPE;
 g_sub_cod_spto_as           a2000500.sub_cod_spto         %TYPE;
 g_cod_tip_spto_as           a2000500.cod_tip_spto         %TYPE;
 --
 g_tip_spto_tmp              a2991800.tip_spto             %TYPE;
 g_cod_spto_tmp              a2000500.cod_spto             %TYPE;
 g_sub_cod_spto_tmp          a2000500.sub_cod_spto         %TYPE;
 g_cod_tip_spto_tmp          a2000500.cod_tip_spto         %TYPE;
 --
 g_tip_spto_aa               a2991800.tip_spto             %TYPE;
 g_cod_spto_aa               a2000500.cod_spto             %TYPE;
 g_sub_cod_spto_aa           a2000500.sub_cod_spto         %TYPE;
 g_cod_tip_spto_aa           a2000500.cod_tip_spto         %TYPE;
 --
 g_tip_spto_re               a2991800.tip_spto             %TYPE;
 g_cod_spto_re               a2000500.cod_spto             %TYPE;
 g_sub_cod_spto_re           a2000500.sub_cod_spto         %TYPE;
 g_cod_tip_spto_re           a2000500.cod_tip_spto         %TYPE;
 --
 g_cod_spto_susp_pa          a2991800.cod_spto             %TYPE;
 g_sub_cod_spto_susp_pa      a2991800.sub_cod_spto         %TYPE;
 g_cod_tip_spto_susp_pa      a2991800.tip_spto             %TYPE;
 --
 g_num_riesgo_autoriza       a2000221.num_riesgo           %TYPE;
 g_cod_nivel_salto           a2000221.cod_nivel_salto      %TYPE;
 g_cod_error                 a2000221.cod_error            %TYPE;
 --
 g_fec_desde                 a2000221.fec_autorizacion     %TYPE;
 g_fec_hasta                 a2000221.fec_autorizacion     %TYPE;
 --
 g_cod_usr_cia               a2000221.cod_usr_autorizacion %TYPE;
 --
 g_tip_emision               VARCHAR2(1);
 g_mca_grupos                VARCHAR2(1);
 g_mca_reproceso             VARCHAR2(1);
 g_mca_aborta_emision        VARCHAR2(1);
 g_mca_retroactivo           VARCHAR2(1);
 g_tip_autoriza_ct           VARCHAR2(1);
 g_trata_recibos_ep          BOOLEAN;
 --
 g_mca_multihilo             VARCHAR2(1);
 g_mca_ejecuta_filtro        VARCHAR2(1);
 --
 g_cod_usr                   a2000500.cod_usr              %TYPE;
 g_cod_usr_inicial           a2000500.cod_usr              %TYPE;
 g_cod_usr_g2000510          g2000510.cod_usr              %TYPE;
 g_cod_idioma                g1010010.cod_idioma           %TYPE := trn_k_global.cod_idioma;
 --
 g_cod_mensaje               g1010020.cod_mensaje          %TYPE;
 g_anx_mensaje               VARCHAR2(250);
 g_txt_mensaje               VARCHAR2(2000);
 --
 g_mca_ter_tar               VARCHAR2(1);
 g_cod_ter_erronea           NUMBER(8);
 --
 g_bloquea                   BOOLEAN;
 g_termina_cursor            BOOLEAN;
 g_hay_datos                 BOOLEAN;
 g_contador                  NUMBER;
 g_cant_registros            NUMBER;
 --
 g_tabla_df                  all_tab_columns.table_name    %TYPE;
 --
 g_val_campo                 a2000020.val_campo            %TYPE;
 g_txt_campo                 a2000020.txt_campo            %TYPE;
 g_mca_salto                 VARCHAR2(1);
 --
 g_reg_em_k_a2000030         a2000030%ROWTYPE;
 --
 g_txt_poliza_definitiva     g1010020.txt_mensaje          %TYPE;
 --
 /* -------------------------------------------------------------
 || Tabla que contiene los valores de las variables del WHERE del
 || cursor variable
 */ -------------------------------------------------------------
 --
 TYPE reg_condicion IS RECORD
      (cod_campo             VARCHAR2(30),
       val_campo             VARCHAR2(30));
 --
 TYPE tabla_condicion        IS TABLE OF REG_CONDICION
      INDEX BY BINARY_INTEGER;
 --
 g_tb_condicion              TABLA_CONDICION;
 g_tb_condicion_fin          TABLA_CONDICION;
 --
 g_k_tabla          CONSTANT all_tab_columns.table_name    %TYPE := 'A2000500';
 --
 g_lng_rowid                   PLS_INTEGER := 19;
 g_lng_num_poliza_grupo        PLS_INTEGER := trn_f_lng_columna
                                            ( g_k_tabla                ,
                                              'NUM_POLIZA_GRUPO'       );
 g_lng_num_poliza_cliente      PLS_INTEGER := trn_f_lng_columna
                                            ( g_k_tabla                ,
                                              'NUM_POLIZA_CLIENTE'     );
 g_lng_num_poliza              PLS_INTEGER := trn_f_lng_columna
                                            ( g_k_tabla                ,
                                              'NUM_POLIZA'             );
 g_lng_num_poliza_tronador     PLS_INTEGER := trn_f_lng_columna
                                            ( g_k_tabla                ,
                                              'NUM_POLIZA_TRONADOR'    );
 g_lng_tip_poliza_tr           PLS_INTEGER := trn_f_lng_columna
                                            ( g_k_tabla                ,
                                              'TIP_POLIZA_TR'          );
 g_lng_mca_prima_manual        PLS_INTEGER := trn_f_lng_columna
                                            ( g_k_tabla                ,
                                              'MCA_PRIMA_MANUAL'       );
 g_lng_cod_tip_spto            PLS_INTEGER := trn_f_lng_columna
                                            ( g_k_tabla                ,
                                              'COD_TIP_SPTO'           );
 g_lng_txt_motivo_spto         PLS_INTEGER := trn_f_lng_columna
                                            ( g_k_tabla                ,
                                              'TXT_MOTIVO_SPTO'        );
 g_lng_mca_renueva             PLS_INTEGER := trn_f_lng_columna
                                            ( g_k_tabla                ,
                                              'MCA_RENUEVA'            );
 g_lng_mca_renueva_tmp         PLS_INTEGER := trn_f_lng_columna
                                            ( g_k_tabla                ,
                                              'MCA_RENUEVA_TMP'        );
 g_lng_mca_periodicidad        PLS_INTEGER := trn_f_lng_columna
                                            ( g_k_tabla                ,
                                              'MCA_PERIODICIDAD'       );
 g_lng_mca_prorrata            PLS_INTEGER := trn_f_lng_columna
                                            ( g_k_tabla                ,
                                              'MCA_PRORRATA'           );
 g_lng_mca_devuelve_todo       PLS_INTEGER := trn_f_lng_columna
                                            ( g_k_tabla                ,
                                              'MCA_DEVUELVE_TODO'      );
 g_lng_tip_spto_accion         PLS_INTEGER := trn_f_lng_columna
                                            ( g_k_tabla                ,
                                              'TIP_SPTO_ACCION'        );
 g_lng_mca_pre_renovacion      PLS_INTEGER := trn_f_lng_columna
                                            ( g_k_tabla                ,
                                              'MCA_PRE_RENOVACION'     );
 g_lng_cod_usr_captura         PLS_INTEGER := trn_f_lng_columna
                                            ( g_k_tabla                ,
                                              'COD_USR_CAPTURA'        );
 g_lng_tip_autoriza_ct         PLS_INTEGER := trn_f_lng_columna
                                            ( g_k_tabla                ,
                                              'TIP_AUTORIZA_CT'        );
 g_lng_mca_anulacion_por_deuda PLS_INTEGER := trn_f_lng_columna
                                            ( g_k_tabla               ,
                                              'MCA_ANULACION_POR_DEUDA');
 g_lng_hora_desde              PLS_INTEGER := trn_f_lng_columna
                                            ( g_k_tabla               ,
                                              'HORA_DESDE');
 g_lng_cod_negocio             PLS_INTEGER := trn_f_lng_columna
                                            ( g_k_tabla               ,
                                              'COD_NEGOCIO');
 g_lng_idn_val                 PLS_INTEGER := trn_f_lng_columna
                                            ( g_k_tabla               ,
                                              'IDN_VAL');
 --
 /* ----------------------------------------------------
 || Aqui comienza la declaracion de constantes GLOBALES
 */ ----------------------------------------------------
 --
 g_k_rf_batch              CONSTANT a2000500.tip_mvto_batch     %TYPE := '1'                        ;
 g_k_pre_rf_batch          CONSTANT a2000500.tip_mvto_batch     %TYPE := '2'                        ;
 g_k_carga_batch           CONSTANT a2000500.tip_mvto_batch     %TYPE := '3'                        ;
 g_k_spto_batch            CONSTANT a2000500.tip_mvto_batch     %TYPE := '4'                        ;
 g_k_apli_batch            CONSTANT a2000500.tip_mvto_batch     %TYPE := '5'                        ;
 g_k_spto_apli_batch       CONSTANT a2000500.tip_mvto_batch     %TYPE := '6'                        ;
 g_k_presup_batch          CONSTANT a2000500.tip_mvto_batch     %TYPE := em.PRESUP_BATCH            ;
 g_k_autoriza_pol_batch    CONSTANT a2000500.tip_mvto_batch     %TYPE := '9'                        ;
 g_k_autoriza_ppto_batch   CONSTANT a2000500.tip_mvto_batch     %TYPE := em.AUTORIZA_PPTO_BATCH     ;
 g_k_autoriza_pre_rf_batch CONSTANT a2000500.tip_mvto_batch     %TYPE := '16'                       ;
 g_k_anulacion_batch       CONSTANT a2000500.tip_mvto_batch     %TYPE := '11'                       ;
 g_k_otros_batch           CONSTANT a2000500.tip_mvto_batch     %TYPE := '12'                       ;
 g_k_otros_batch_20        CONSTANT a2000500.tip_mvto_batch     %TYPE := '20'                       ;
 g_k_aportaciones_pactadas CONSTANT a2000500.tip_mvto_batch     %TYPE := em.APORTACION_PACTADA_BATCH;
 g_k_regularizacion_vida   CONSTANT a2000500.tip_mvto_batch     %TYPE := '17'                       ;
 g_k_anul_aport_pactada    CONSTANT a2000500.tip_mvto_batch     %TYPE := '24'                          ;
 g_k_suspension_plan_aport CONSTANT a2000500.tip_mvto_batch     %TYPE := em.SUSPENSION_PLAN_APORT_BATCH;
 --
 g_k_no_tratada          CONSTANT a2000500.tip_situ           %TYPE := '1';
 g_k_en_proceso          CONSTANT a2000500.tip_situ           %TYPE := '2';
 g_k_terminada           CONSTANT a2000500.tip_situ           %TYPE := '3';
 g_k_con_error           CONSTANT a2000500.tip_situ           %TYPE := '4';
 g_k_excepcion           CONSTANT a2000500.tip_situ           %TYPE := '5';
 g_k_retenida            CONSTANT a2000500.tip_situ           %TYPE := '6';
 g_k_rechazo_accion      CONSTANT a2000500.tip_situ           %TYPE := '7';
 g_k_tratada_con_error   CONSTANT a2000500.tip_situ           %TYPE := '0';
 --
 g_k_rechaza             CONSTANT a2000500.tip_autoriza_ct    %TYPE := '2';
 g_k_suspende            CONSTANT a2000500.tip_autoriza_ct    %TYPE := '3';
 --
 g_k_num_secu            CONSTANT a2000520.num_secu           %TYPE := 1;
 --
 g_k_sin_filtrar          CONSTANT g2000510.tip_situ_filtro%TYPE := '1';
 g_k_ya_tratado           CONSTANT g2000510.tip_situ_filtro    %TYPE := '6';
 g_k_en_proceso_monohilo  CONSTANT g2000510.tip_situ_filtro    %TYPE := '7';
 g_k_en_proceso_multihilo CONSTANT g2000510.tip_situ_filtro    %TYPE := '8';
 --
 g_k_package_r           CONSTANT VARCHAR2(14)                      := 'em_k_tablas_r_';
 --
 g_k_ini_corchete        CONSTANT VARCHAR2(1)                       := '[';
 g_k_fin_corchete        CONSTANT VARCHAR2(1)                       := ']';
 --
 g_k_comilla             CONSTANT VARCHAR2(1)                       := '''';
 --
 g_k_a30                 CONSTANT all_tab_columns.table_name  %TYPE := 'A2000030';
 g_k_p30                 CONSTANT all_tab_columns.table_name  %TYPE := 'P2000030';
 g_k_r30                 CONSTANT all_tab_columns.table_name  %TYPE := 'R2000030';
 --
 g_k_conv_rf_batch       CONSTANT a2000500.tip_mvto_batch%TYPE      := em.CONVERSION_RF_BATCH;
 --
 /* ----------------------------------------------------
 || Aqui comienza la declaracion de cursores GLOBALES
 */ ----------------------------------------------------
 --
 CURSOR cg_g2000510
      ( pc_tip_mvto_batch g2000510.tip_mvto_batch %TYPE )
 IS
        SELECT *
          FROM g2000510
         WHERE cod_cia         = g_cod_cia
           AND fec_tratamiento = g_fec_tratamiento
           AND num_orden       = g_num_orden
           AND tip_mvto_batch  = pc_tip_mvto_batch;
 --
 g_reg_g2000510      g2000510%ROWTYPE;
 g_reg_g2000510_nulo g2000510%ROWTYPE;
 --
 CURSOR cg_g2000510_fec
      ( pc_tip_mvto_batch g2000510.tip_mvto_batch %TYPE )
 IS
        SELECT MAX(fec_tratamiento)
          FROM g2000510
         WHERE tip_mvto_batch = pc_tip_mvto_batch;
 --
 CURSOR cg_g2000510_orden
      ( pc_tip_mvto_batch g2000510.tip_mvto_batch %TYPE )
 IS
        SELECT MAX(num_orden)
          FROM g2000510
         WHERE tip_mvto_batch  = pc_tip_mvto_batch
           AND fec_tratamiento = g_fec_tratamiento;
 --
 CURSOR cg_a2000500
      ( pc_tip_mvto_batch a2000500.tip_mvto_batch %TYPE )
 IS
        SELECT num_poliza_grupo
          FROM a2000500
         WHERE cod_cia           = g_cod_cia
           AND tip_mvto_batch    = pc_tip_mvto_batch
           AND num_orden         = g_num_orden
           AND fec_tratamiento   = g_fec_tratamiento
           AND num_poliza        = g_num_poliza;
 --
 CURSOR cg_a2990700
      ( pc_cod_cia       a2990700.cod_cia       %TYPE,
        pc_num_poliza    a2990700.num_poliza    %TYPE,
        pc_num_spto      a2990700.num_spto      %TYPE,
        pc_num_apli      a2990700.num_apli      %TYPE,
        pc_num_spto_apli a2990700.num_spto_apli %TYPE,
        pc_num_recibo    a2990700.num_recibo    %TYPE)
 IS
        SELECT *
          FROM a2990700
         WHERE cod_cia       = pc_cod_cia
           AND num_poliza    = pc_num_poliza
           AND num_spto      = pc_num_spto
           AND num_apli      = pc_num_apli
           AND num_spto_apli = pc_num_spto_apli
           AND num_recibo    = pc_num_recibo;
 --
 g_reg_recibo a2990700%ROWTYPE;
 --
 CURSOR cg_a2990700_ct
      ( pc_cod_cia                 a2990700.cod_cia                 %TYPE ,
        pc_num_poliza              a2990700.num_poliza              %TYPE ,
        pc_num_spto                a2990700.num_spto                %TYPE ,
        pc_mca_anulacion_por_deuda a2000500.mca_anulacion_por_deuda %TYPE ,
        pc_fec_efec_recibo         a2990700.fec_efec_recibo         %TYPE )
 IS
       SELECT SUM(NVL(imp_recibo,0))
         FROM a2990700
        WHERE cod_cia                     = pc_cod_cia
          AND num_poliza                  = pc_num_poliza
          AND (    fec_efec_recibo        > pc_fec_efec_recibo
                OR  (     fec_efec_recibo = pc_fec_efec_recibo
                      AND num_spto        > pc_num_spto
                    )
              )
          AND (    pc_mca_anulacion_por_deuda='N'
               OR (    pc_mca_anulacion_por_deuda='S'
                   AND num_spto = pc_num_spto)
               )
          AND num_apli                    = 0
          AND tip_situacion               = 'CT'
        GROUP BY fec_efec_recibo , fec_vcto_recibo;
 --
 CURSOR cg_a2990700_ct_t
      ( pc_cod_cia                 a2990700.cod_cia                 %TYPE ,
        pc_num_poliza              a2990700.num_poliza              %TYPE ,
        pc_num_spto                a2990700.num_spto                %TYPE ,
        pc_num_apli                a2990700.num_apli                %TYPE ,
        pc_num_spto_apli           a2990700.num_spto_apli           %TYPE ,
        pc_mca_anulacion_por_deuda a2000500.mca_anulacion_por_deuda %TYPE ,
        pc_fec_efec_recibo         a2990700.fec_efec_recibo         %TYPE )
 IS
       SELECT SUM(NVL(imp_recibo,0))
         FROM a2990700
        WHERE cod_cia                     = pc_cod_cia
          AND num_poliza                  = pc_num_poliza
          AND num_spto                    = pc_num_spto
          AND num_apli                    = pc_num_apli
          AND (    fec_efec_recibo        > pc_fec_efec_recibo
                OR  (     fec_efec_recibo = pc_fec_efec_recibo
                      AND num_spto_apli   > pc_num_spto_apli
                    )
              )
          AND (    pc_mca_anulacion_por_deuda='N'
               OR (    pc_mca_anulacion_por_deuda='S'
                   AND num_spto = pc_num_spto)
               )
          AND tip_situacion               = 'CT'
        GROUP BY fec_efec_recibo , fec_vcto_recibo;
 --
 CURSOR cg_a2000030_cv_ca
      ( pc_cod_cia       a2000030.cod_cia       %TYPE ,
        pc_num_poliza    a2000030.num_poliza    %TYPE ,
        pc_num_spto      a2000030.num_spto      %TYPE )
 IS
        SELECT tip_spto
          FROM a2000030
         WHERE cod_cia           = pc_cod_cia
           AND num_poliza        = pc_num_poliza
           AND num_spto          > pc_num_spto
           AND num_apli          = 0
           AND mca_spto_anulado  = 'N'
           AND tip_spto         IN ('CV','CA');
 --
 CURSOR cg_a2000030_cv_ca_t
      ( pc_cod_cia       a2000030.cod_cia       %TYPE ,
        pc_num_poliza    a2000030.num_poliza    %TYPE ,
        pc_num_spto      a2000030.num_spto      %TYPE ,
        pc_num_apli      a2000030.num_apli      %TYPE ,
        pc_num_spto_apli a2000030.num_spto_apli %TYPE )
 IS
        SELECT tip_spto
          FROM a2000030
         WHERE cod_cia           = pc_cod_cia
           AND num_poliza        = pc_num_poliza
           AND num_spto          = pc_num_spto
           AND num_apli          = pc_num_apli
           AND num_spto_apli     > pc_num_spto_apli
           AND mca_spto_anulado  = 'N'
           AND tip_spto         IN ('CV','CA');
 --
 CURSOR cg_a2990700_imp_poliza
      ( pc_cod_cia    a2990700.cod_cia    %TYPE ,
        pc_num_poliza a2990700.num_poliza %TYPE ,
        pc_num_apli   a2990700.num_apli   %TYPE )
 IS
        SELECT SUM(NVL(imp_recibo,0))
          FROM a2990700
         WHERE cod_cia          = pc_cod_cia
           AND num_poliza       = pc_num_poliza
           AND num_apli         = pc_num_apli;
 --
 CURSOR cg_a2990700_imp_recibo
      ( pc_cod_cia    a2990700.cod_cia    %TYPE ,
        pc_num_poliza a2990700.num_poliza %TYPE ,
        pc_num_apli   a2990700.num_apli   %TYPE ,
        pc_num_recibo a2990700.num_recibo %TYPE )
 IS
        SELECT SUM(NVL(imp_recibo,0))
          FROM a2990700
         WHERE cod_cia          = pc_cod_cia
           AND num_poliza       = pc_num_poliza
           AND num_apli         = pc_num_apli
           AND num_recibo       = pc_num_recibo;
 --
 /* -------------- Cursor para control de recibos negativos ---------------
 || CURSOR cg_a2990700_otros
 ||      ( pc_cod_cia    a2990700.cod_cia    %TYPE ,
 ||        pc_num_poliza a2990700.num_poliza %TYPE ,
 ||        pc_num_apli   a2990700.num_apli   %TYPE )
 || IS
 ||        SELECT imp_recibo
 ||          FROM a2990700
 ||         WHERE cod_cia          = pc_cod_cia
 ||           AND num_poliza       = pc_num_poliza
 ||           AND num_apli         = pc_num_apli
 ||           AND tip_situacion    = 'RE'
 ||           AND imp_recibo       > 0
 ||           AND GREATEST( fec_efec_recibo   , fec_remesa ) <=
 ||                       ( g_fec_tratamiento - g_num_dias_vcto_pago ) + 1;
 */ -----------------------------------------------------------------------
 --
 CURSOR cg_a2000030
      ( pc_cod_cia      a2000030.cod_cia    %TYPE ,
        pc_num_poliza   a2000030.num_poliza %TYPE ,
        pc_num_spto     a2000030.num_spto   %TYPE ,
        pc_num_spto_max a2000030.num_spto   %TYPE )
 IS
        SELECT num_spto      ,
               num_apli      ,
               num_spto_apli ,
               fec_efec_spto ,
               hora_desde    ,
               fec_vcto_spto ,
               mca_spto_tmp  ,
               tip_spto      ,
               cod_negocio
          FROM a2000030
         WHERE cod_cia           = pc_cod_cia
           AND num_poliza        = pc_num_poliza
           AND num_spto          < pc_num_spto_max
           AND num_spto          > pc_num_spto
           AND num_apli          = 0
           AND mca_spto_anulado  = 'N'
         ORDER BY num_spto DESC;
 --
 CURSOR cg_a2000030_t
      ( pc_cod_cia           a2000030.cod_cia       %TYPE ,
        pc_num_poliza        a2000030.num_poliza    %TYPE ,
        pc_num_spto          a2000030.num_spto      %TYPE ,
        pc_num_apli          a2000030.num_apli      %TYPE ,
        pc_num_spto_apli     a2000030.num_spto_apli %TYPE ,
        pc_num_spto_apli_max a2000030.num_spto_apli %TYPE )
 IS
        SELECT num_spto      ,
               num_apli      ,
               num_spto_apli ,
               fec_efec_spto ,
               hora_desde    ,
               fec_vcto_spto ,
               mca_spto_tmp  ,
               tip_spto      ,
               cod_negocio
          FROM a2000030
         WHERE cod_cia           = pc_cod_cia
           AND num_poliza        = pc_num_poliza
           AND num_spto          = pc_num_spto
           AND num_apli          = pc_num_spto
           AND num_spto_apli     < pc_num_spto_apli_max
           AND num_spto_apli     > pc_num_spto_apli
           AND mca_spto_anulado  = 'N'
         ORDER BY num_spto_apli DESC;
 --
 g_reg_30 cg_a2000030%ROWTYPE;
 --
 /* ----------------------------------------------------
 || Aqui comienza la declaracion de subprogramas LOCALES
 */ ----------------------------------------------------
 --
 /* -----------------------------------------------------
 || pp_devuelve_error :
 ||
 || Devuelve un error
 */ -----------------------------------------------------
 --
 PROCEDURE pp_devuelve_error IS
 BEGIN
  --
  IF g_cod_mensaje BETWEEN 20000
                       AND 20999
   THEN
    --
    RAISE_APPLICATION_ERROR(-g_cod_mensaje,
                            ss_k_mensaje.f_texto_idioma(g_cod_mensaje,
                                                        g_cod_idioma ) ||
                            g_anx_mensaje
                           );
    --
   ELSE
    --
    RAISE_APPLICATION_ERROR(-20000,
                            ss_k_mensaje.f_texto_idioma(g_cod_mensaje,
                                                        g_cod_idioma ) ||
                            g_anx_mensaje
                           );
    --
  END IF;
  --
 END pp_devuelve_error;
 --
 /* -----------------------------------------------------
 || pp_asigna :
 ||
 || Llama a trn_k_global.asigna
 */ -----------------------------------------------------
 --
 PROCEDURE pp_asigna(p_nom_global VARCHAR2,
                     p_val_global VARCHAR2) IS
 BEGIN
  --
  trn_k_global.asigna(p_nom_global,p_val_global);
  --
 END pp_asigna;
 --
 /* -----------------------------------------------------
 || pp_asigna :
 ||
 || Llama a trn_k_global.asigna
 */ -----------------------------------------------------
 --
 PROCEDURE pp_asigna(p_nom_global VARCHAR2,
                     p_val_global NUMBER  ) IS
 BEGIN
  --
  trn_k_global.asigna(p_nom_global,TO_CHAR(p_val_global));
  --
 END pp_asigna;
 --
 /* -----------------------------------------------------
 || pp_asigna :
 ||
 || Llama a trn_k_global.asigna
 */ -----------------------------------------------------
 --
 PROCEDURE pp_asigna(p_nom_global VARCHAR2,
                     p_val_global DATE    ) IS
 BEGIN
  --
  trn_k_global.asigna(p_nom_global,TO_CHAR(p_val_global,'ddmmyyyy'));
  --
 END pp_asigna;
 --
 /* -----------------------------------------------------
 || fp_devuelve_c :
 ||
 || Llama a trn_k_global.devuelve y retorna como VARCHAR2
 */ -----------------------------------------------------
 --
 FUNCTION fp_devuelve_c(p_nom_global VARCHAR2)
          RETURN VARCHAR2 IS
 BEGIN
  --
  RETURN trn_k_global.devuelve(p_nom_global);
  --
 END fp_devuelve_c;
 --
 /* -----------------------------------------------------
 || fp_devuelve_n :
 ||
 || Llama a trn_k_global.devuelve y retorna como NUMBER
 */ -----------------------------------------------------
 --
 FUNCTION fp_devuelve_n(p_nom_global VARCHAR2)
          RETURN NUMBER IS
 BEGIN
  --
  RETURN TO_NUMBER(trn_k_global.devuelve(p_nom_global));
  --
 END fp_devuelve_n;
 --
 /* -----------------------------------------------------
 || fp_devuelve_f :
 ||
 || Llama a trn_k_global.devuelve y retorna como DATE
 */ -----------------------------------------------------
 --
 FUNCTION fp_devuelve_f(p_nom_global VARCHAR2)
          RETURN DATE IS
 BEGIN
  --
  RETURN TO_DATE(trn_k_global.devuelve(p_nom_global),'ddmmyyyy');
  --
 END fp_devuelve_f;
 --
 /* --------------------------------------------------------
 || mx :
 ||
 || Genera la traza
 ||
 || Activa el g_trazas_activas para crear el identificador
 || de la sesion y poder mostrar quien procesa el registro
 */ --------------------------------------------------------
 --
 PROCEDURE mx(p_tit VARCHAR2,
              p_val VARCHAR2) IS
 BEGIN
  --
  g_trazas_activas := TRUE;
  pp_asigna('fic_traza','num_poliza'   );
  pp_asigna('cab_traza','batch------->');
  --
  em_k_traza.p_escribe(p_tit,
                       p_val);
  --
 END mx;
 --
 /* --------------------------------------------------------
 || mx :
 ||
 || Genera la traza
 ||
 || Activa el g_trazas_activas para crear el identificador
 || de la sesion y poder mostrar quien procesa el registro
 */ --------------------------------------------------------
 --
 PROCEDURE mx(p_tit VARCHAR2,
              p_val BOOLEAN ) IS
 BEGIN
  --
  g_trazas_activas := TRUE;
  pp_asigna('fic_traza','num_poliza'   );
  pp_asigna('cab_traza','batch------->');
  --
  em_k_traza.p_escribe(p_tit,
                       p_val);
  --
 END mx;
 --
 /* -----------------------------------------------------
 ||  fp_permite_filtro:
 ||
 */ -----------------------------------------------------
 --
 FUNCTION fp_permite_filtro (p_tip_mvto_batch IN g2000510.tip_mvto_batch %TYPE)
         RETURN BOOLEAN IS
    --
    l_permite BOOLEAN;
    --
 BEGIN
    --
    --@mx('I',' fp_permite_filtro');
    --
    l_permite := FALSE;
    --
    IF p_tip_mvto_batch IN(g_k_aportaciones_pactadas,
                           g_k_anul_aport_pactada   ,
                           g_k_regularizacion_vida  )
    THEN
       --
       l_permite := TRUE;
       --
    END IF;
    --
    RETURN l_permite;
    --
    --@mx('F',' fp_permite_filtro');
    --
 END fp_permite_filtro;
 /* -----------------------------------------------------
 || pp_val_s_n :
 ||
 || Valida los valores "S" o "N"
 */ -----------------------------------------------------
 --
 PROCEDURE pp_val_s_n(p_cod_campo VARCHAR2,
                      p_val_campo VARCHAR2) IS
 BEGIN
  --
  --@mx('I','pp_val_s_n');
  --
  IF NVL(p_val_campo,'x') NOT IN ('S','N')
   THEN
    --
    g_cod_mensaje := 20010;
    g_anx_mensaje := g_k_ini_corchete ||
                     p_cod_campo      ||
                     g_k_fin_corchete ;
    --
    pp_devuelve_error;
    --
  END IF;
  --
  --@mx('F','pp_val_s_n');
  --
 END pp_val_s_n;
 --
 /* -------------------------------------------------------
 || pp_inicio :
 ||
 || Inicializa variables
 */ -------------------------------------------------------
 --
 PROCEDURE pp_inicio IS
 BEGIN
  --
  g_mca_ter_tar     := 'S';
  g_cod_ter_erronea := 0;
  --
  em_k_a2000520.p_inicio;
  --
 END pp_inicio;
 --
 /* -------------------------------------------------------
 || fp_tip_mvto_batch_acceso :
 ||
 || Devuelve el codigo de proceso para acceder a las tablas
 */ -------------------------------------------------------
 --
 FUNCTION fp_tip_mvto_batch_acceso
   RETURN VARCHAR2 IS
  --
  l_tip_mvto_batch a2000500.tip_mvto_batch %TYPE;
  --
 BEGIN
  --
  --@mx('I','fp_tip_mvto_batch_acceso');
  --
  l_tip_mvto_batch := g_tip_mvto_batch;
  --
  IF g_tip_mvto_batch = g_k_pre_rf_batch
   THEN
    --
    l_tip_mvto_batch := g_k_rf_batch;
    --
  END IF;
  --
  --@mx('F','fp_tip_mvto_batch_acceso '||l_tip_mvto_batch);
  --
  RETURN l_tip_mvto_batch;
  --
 END fp_tip_mvto_batch_acceso;
 --
 /* -------------------------------------------------------
 || fp_hay_poliza_grupo :
 ||
 || Comprueba si en la tabla de polizas para procesos batch
 || se ha indicado una poliza grupo para la poliza
 */ -------------------------------------------------------
 --
 FUNCTION fp_hay_poliza_grupo
   RETURN VARCHAR2 IS
  --
  l_num_poliza_grupo a2000500.num_poliza_grupo %TYPE;
  --
  l_hay_poliza_grupo VARCHAR2(1);
  l_existe           BOOLEAN;
  --
 BEGIN
  --
  --@mx('I','fp_hay_poliza_grupo');
  --
  /* -------------------------------------------------------
  || Para pre-renovacion se hacen 2 lecturas porque en el
  || primer cursor solo recupera el registro si la poliza
  || fue tratada por un proceso de pre-renovacion previo.
  || En el segundo cursor recupera la poliza si se trata
  || por primera vez ya que las polizas que no han sido
  || pre-renovadas estan grabadas con el codigo de proce-
  || so de renovacion
  || En renovacion el primer cursor recupera las polizas
  || que no han sido pre-renovadas y el segundo las polizas
  || tratadas por una pre-renovacion
  */ -------------------------------------------------------
  --
  l_num_poliza_grupo := NULL;
  --
  OPEN        cg_a2000500(g_tip_mvto_batch);
  FETCH       cg_a2000500 INTO l_num_poliza_grupo;
  l_existe := cg_a2000500%FOUND;
  CLOSE       cg_a2000500;
  --
  IF NOT l_existe
   THEN
    --
    IF g_tip_mvto_batch = g_k_pre_rf_batch
     THEN
      --
      OPEN  cg_a2000500(g_k_rf_batch);
      FETCH cg_a2000500 INTO l_num_poliza_grupo;
      CLOSE cg_a2000500;
      --
     ELSIF g_tip_mvto_batch = g_k_rf_batch
         THEN
          --
          OPEN  cg_a2000500(g_k_pre_rf_batch);
          FETCH cg_a2000500 INTO l_num_poliza_grupo;
          CLOSE cg_a2000500;
          --
    END IF;
    --
  END IF;
  --
  IF l_num_poliza_grupo IS NOT NULL
   THEN
    --
    l_hay_poliza_grupo := 'S';
    --
   ELSE
    --
    l_hay_poliza_grupo := 'N';
    --
  END IF;
  --
  --@mx('F','fp_hay_poliza_grupo');
  --
  RETURN l_hay_poliza_grupo;
  --
 END fp_hay_poliza_grupo;
 --
 /* -------------------------------------------------------
 || fp_otros_batch :
 ||
 || Comprueba si el tip_mvto_batch es cualquier otro tipo
 || diferente a los predefinidos
 */ -------------------------------------------------------
 --
 FUNCTION fp_otros_batch
    RETURN BOOLEAN
 IS
 --
 BEGIN
    --
    RETURN     (    TO_NUMBER(g_tip_mvto_batch) >= TO_NUMBER(g_k_otros_batch)       )
       AND NOT (    TO_NUMBER(g_tip_mvto_batch) >= TO_NUMBER(g_k_conv_rf_batch      )
                AND TO_NUMBER(g_tip_mvto_batch) <= TO_NUMBER(g_k_otros_batch_20)    );
    --
 END fp_otros_batch;
 --
 /* -------------------------------------------------------
 || fp_tip_emision :
 ||
 || Determina el tipo de emision dependiendo del tipo de
 || proceso
 */ -------------------------------------------------------
 --
 FUNCTION fp_tip_emision
   RETURN VARCHAR2 IS
  --
  l_tip_emision VARCHAR2(1);
  --
 BEGIN
  --
  IF NVL(g_tip_mvto_batch,'x') IN (g_k_carga_batch   ,
                                   g_k_conv_rf_batch )
   THEN
    --
    l_tip_emision := 'P';
    --
    IF g_reg.num_poliza_grupo IS NOT NULL
     THEN
      --
      l_tip_emision := 'R';
      --
    END IF;
    --
   ELSIF g_tip_mvto_batch = g_k_apli_batch
       THEN
        --
        l_tip_emision := 'A';
        --
   ELSIF g_tip_mvto_batch = g_k_presup_batch
       THEN
        --
        l_tip_emision := 'C';
        --
   ELSIF g_tip_mvto_batch = g_k_spto_apli_batch
       THEN
        --
        l_tip_emision := 'U';
        --
       ELSE
        --
        l_tip_emision := 'S';
        --
  END IF;
  --
  RETURN l_tip_emision;
  --
 END fp_tip_emision;
 --
 /* -------------------------------------------------------
 || pp_devuelve_valores_val :
 ||
 || Asigna a las globales los valores recuperados en los
 || procedimientos de validacion (D.V. de tarea)
 */ -------------------------------------------------------
 --
 PROCEDURE pp_devuelve_valores_val IS
 BEGIN
   --
   pp_asigna('txt_campo',g_txt_campo);
   --
 END pp_devuelve_valores_val;
 --
 /* -------------------------------------------------------
 || pp_devuelve_valores_pre :
 ||
 || Asigna a las globales los valores recuperados en los
 || procedimientos de pre-campo (D.V. de tarea)
 */ -------------------------------------------------------
 --
 PROCEDURE pp_devuelve_valores_pre IS
 BEGIN
  --
  --@mx('I','pp_devuelve_valores_pre');
  --
  pp_asigna('val_campo',g_val_campo);
  pp_asigna('txt_campo',g_txt_campo);
  pp_asigna('mca_salto',g_mca_salto);
  --
  --@mx('F','pp_devuelve_valores_pre');
  --
 END pp_devuelve_valores_pre;
 --
 /* -------------------------------------------------------
 || fp_rec_nom_valor :
 ||
 || Recupera la descripcion del campo de la tabla g1010031
 */ -------------------------------------------------------
 --
 FUNCTION fp_rec_nom_valor
        ( p_cod_campo g1010031.cod_campo %TYPE ,
          p_cod_valor g1010031.cod_valor %TYPE )
   RETURN VARCHAR2 IS
 BEGIN
  --
  RETURN ss_f_nom_valor(p_cod_campo  ,
                        999          ,
                        p_cod_valor  ,
                        g_cod_idioma );
  --
 END fp_rec_nom_valor;
 --
 /* -------------------------------------------------------
 || pp_recupera_usuario :
 ||
 || Recupera el usuario
 */ -------------------------------------------------------
 --
 PROCEDURE pp_recupera_usuario IS
 BEGIN
  --
  --@mx('I','pp_recupera_usuario');
  --
  g_cod_usr_inicial := trn_k_global.cod_usr;
  --
  --@mx('F','pp_recupera_usuario');
  --
 END pp_recupera_usuario;
 --
 /* -------------------------------------------------------
 || pp_comprueba_usuario :
 ||
 || Comprueba que el usuario exista
 */ -------------------------------------------------------
 --
 PROCEDURE pp_comprueba_usuario IS
 BEGIN
  --
  --@mx('I','pp_comprueba_usuario');
  --
  IF g_cod_usr != g_reg.cod_usr_captura
   THEN
    --
    dc_k_g1002700.p_lee( g_cod_cia             ,
                         g_reg.cod_usr_captura );
    --
    g_cod_usr := g_reg.cod_usr_captura;
    --
  END IF;
  --
  pp_asigna('cod_usr',g_cod_usr);
  --
  --@mx('F','pp_comprueba_usuario');
  --
 END pp_comprueba_usuario;
 --
 /* -------------------------------------------------------
 || pp_inicializa_variables_g :
 ||
 || Limpia las variables
 */ -------------------------------------------------------
 --
 PROCEDURE pp_inicializa_variables_g IS
 BEGIN
  --
  --@mx('I','pp_inicializa_variables_g');
  --
  g_num_poliza_definitivo := NULL;
  --
  g_num_spto              := NULL;
  g_num_apli              := NULL;
  g_num_spto_apli         := NULL;
  --
  g_num_riesgo            := 0;
  --
  g_txt_mensaje           := NULL;
  g_mca_provisional       := 'N';
  g_mca_pre_renovacion    := 'N';
  --
  g_cod_excepcion         := NULL;
  g_nom_excepcion         := NULL;
  --
  g_max_spto_vigente      := NULL;
  --
  g_tip_situ              := g_k_en_proceso;
  --
  g_cod_usr               := g_cod_usr_inicial;
  --
  g_tip_emision           := fp_tip_emision;
  --
  --@mx('F','pp_inicializa_variables_g');
  --
 END pp_inicializa_variables_g;
 --
 /* -------------------------------------------------------
 || pp_inicia_var_parametros :
 ||
 || Limpia las variables donde se recuperan los parametros
 */ -------------------------------------------------------
 --
 PROCEDURE pp_inicia_var_parametros IS
 BEGIN
  --
  --@mx('I','pp_inicia_var_parametros ');
  --
  g_mca_multihilo           := NULL;
  --
  g_tip_mvto_batch          := NULL;
  g_fec_tratamiento         := NULL;
  g_num_orden               := NULL;
  --
  g_cod_cia                 := NULL;
  g_cod_sector              := NULL;
  g_cod_ramo                := NULL;
  g_cod_nivel1              := NULL;
  g_cod_nivel2              := NULL;
  g_cod_nivel3              := NULL;
  g_cod_agt                 := NULL;
  g_num_poliza              := NULL;
  g_num_poliza_grupo        := NULL;
  g_num_poliza_cliente      := NULL;
  --
  g_cant_registros          := NULL;
  g_max_num_riesgos         := NULL;
  g_mca_grupos              := NULL;
  --
  g_mca_reproceso           := NULL;
  --
  g_cod_spto                := NULL;
  g_sub_cod_spto            := NULL;
  --
  g_cod_tip_spto            := NULL;
  g_cod_usr_captura         := NULL;
  g_txt_motivo_spto         := NULL;
  --
  g_cod_spto_as             := NULL;
  g_sub_cod_spto_as         := NULL;
  g_cod_tip_spto_as         := NULL;
  --
  g_cod_spto_tmp            := NULL;
  g_sub_cod_spto_tmp        := NULL;
  g_cod_tip_spto_tmp        := NULL;
  --
  g_cod_spto_aa             := NULL;
  g_sub_cod_spto_aa         := NULL;
  g_cod_tip_spto_aa         := NULL;
  --
  g_cod_spto_re             := NULL;
  g_sub_cod_spto_re         := NULL;
  g_cod_tip_spto_re         := NULL;
  --
  g_cod_spto_susp_pa        := NULL;
  g_sub_cod_spto_susp_pa    := NULL;
  g_cod_tip_spto_susp_pa    := NULL;
 --
  g_num_riesgo_autoriza     := NULL;
  --
  g_cod_nivel_salto         := NULL;
  g_cod_error               := NULL;
  --
  g_fec_desde               := NULL;
  g_fec_hasta               := NULL;
  --
  g_cod_usr_cia             := NULL;
  --
  g_tip_autoriza_ct         := NULL;
  --
  g_mca_ejecuta_filtro      := NULL;
  --
  --@mx('F','pp_inicia_var_parametros ');
  --
 END pp_inicia_var_parametros;
 --
 /* -------------------------------------------------------
 || pp_muestra_parametros :
 ||
 || Visualiza los parametros de la tarea.
 */ -------------------------------------------------------
 --
 PROCEDURE pp_muestra_parametros IS
 BEGIN
  --
  --@mx('I','pp_muestra_parametros ');
  --
  --@mx('g_mca_multihilo '      ,g_mca_multihilo);
  --
  --@mx('g_tip_mvto_batch '     ,g_tip_mvto_batch);
  --@mx('g_fec_tratamiento '    ,g_fec_tratamiento);
  --@mx('g_num_orden '          ,g_num_orden);
  --
  --@mx('g_cod_cia '            ,g_cod_cia);
  --@mx('g_cod_sector '         ,g_cod_sector);
  --@mx('g_cod_ramo '           ,g_cod_ramo);
  --@mx('g_cod_nivel1 '         ,g_cod_nivel1);
  --@mx('g_cod_nivel2 '         ,g_cod_nivel2);
  --@mx('g_cod_nivel3 '         ,g_cod_nivel3);
  --@mx('g_cod_agt '            ,g_cod_agt);
  --@mx('g_num_poliza '         ,g_num_poliza);
  --@mx('g_num_poliza_grupo '   ,g_num_poliza_grupo);
  --@mx('g_num_poliza_cliente ' ,g_num_poliza_cliente);
  --
  --@mx('g_cant_registros '     ,g_cant_registros);
  --@mx('g_max_num_riesgos '    ,g_max_num_riesgos);
  --@mx('g_mca_grupos '         ,g_mca_grupos);
  --
  --@mx('g_mca_reproceso '      ,g_mca_reproceso);
  --
  --@mx('g_cod_spto '           ,g_cod_spto);
  --@mx('g_sub_cod_spto '       ,g_sub_cod_spto);
  --
  --@mx('g_cod_tip_spto '       ,g_cod_tip_spto);
  --@mx('g_cod_usr_captura '    ,g_cod_usr_captura);
  --@mx('g_txt_motivo_spto '    ,g_txt_motivo_spto);
  --
  --@mx('g_cod_spto_as '        ,g_cod_spto_as);
  --@mx('g_sub_cod_spto_as '    ,g_sub_cod_spto_as);
  --@mx('g_cod_tip_spto_as '    ,g_cod_tip_spto_as);
  --
  --@mx('g_cod_spto_tmp '       ,g_cod_spto_tmp);
  --@mx('g_sub_cod_spto_tmp '   ,g_sub_cod_spto_tmp);
  --@mx('g_cod_tip_spto_tmp '   ,g_cod_tip_spto_tmp);
  --
  --@mx('g_cod_spto_aa '        ,g_cod_spto_aa);
  --@mx('g_sub_cod_spto_aa '    ,g_sub_cod_spto_aa);
  --@mx('g_cod_tip_spto_aa '    ,g_cod_tip_spto_aa);
  --
  --@mx('g_cod_spto_re '        ,g_cod_spto_re);
  --@mx('g_sub_cod_spto_re '    ,g_sub_cod_spto_re);
  --@mx('g_cod_tip_spto_re '    ,g_cod_tip_spto_re);
  --
  --@mx('g_cod_spto_susp_pa '   ,g_cod_spto_susp_pa);
  --@mx('g_sub_cod_spto_susp_pa ',g_sub_cod_spto_susp_pa);
  --@mx('g_cod_tip_spto_susp_pa ',g_cod_tip_spto_susp_pa);
  --
  --@mx('g_num_riesgo_autoriza ',g_num_riesgo_autoriza);
  --
  --@mx('g_cod_nivel_salto '    ,g_cod_nivel_salto);
  --@mx('g_cod_error '          ,g_cod_error);
  --
  --@mx('g_fec_desde '          ,g_fec_desde);
  --@mx('g_fec_hasta '          ,g_fec_hasta);
  --
  --@mx('g_cod_usr_cia '        ,g_cod_usr_cia);
  --
  --@mx('g_tip_autoriza_ct '    ,g_tip_autoriza_ct);
  --
  --@mx('g_mca_ejecuta_filtro ' ,g_mca_ejecuta_filtro);
  --
  NULL;
  --@mx('F','pp_muestra_parametros ');
  --
 END pp_muestra_parametros;
 --
 /* -------------------------------------------------------
 || fp_excepcion :
 ||
 || Indica si la poliza esta excepcionada ejecutando el
 || procedimiento de excepcion si existe para el proceso
 */ -------------------------------------------------------
 --
 FUNCTION fp_excepcion
   RETURN BOOLEAN IS
  --
  l_excepcion BOOLEAN;
  --
 BEGIN
  --
  l_excepcion     := FALSE;
  g_cod_excepcion := NULL;
  --
  IF g_reg_g2000510.nom_prg_excepcion IS NOT NULL
   THEN
    --
    pp_asigna('cod_excepcion',g_cod_excepcion);
    pp_asigna('mca_excepcion','N'            );
    --
    trn_p_dinamico(g_reg_g2000510.nom_prg_excepcion);
    --
    l_excepcion := (fp_devuelve_c('mca_excepcion') = 'S');
    --
  END IF;
  --
  RETURN l_excepcion;
  --
 END fp_excepcion;
 --
 /* -------------------------------------------------------
 || fp_trata_recibos_ep :
 ||
 || Comprueba si se deben tratar los recibos 'EP' en las
 || anulaciones por falta de pago
 */ -------------------------------------------------------
 --
 FUNCTION fp_trata_recibos_ep
   RETURN BOOLEAN IS
  --
  CURSOR cl_g2000570
  IS
         SELECT mca_trata_recibos_ep
           FROM g2000570
          WHERE cod_cia = g_cod_cia;
  --
  l_mca_trata_recibos_ep g2000570.mca_trata_recibos_ep %TYPE;
  l_trata_recibos_ep     BOOLEAN                             := FALSE;
  --
 BEGIN
  --
  OPEN                  cl_g2000570;
  FETCH                 cl_g2000570 INTO l_mca_trata_recibos_ep;
  l_trata_recibos_ep := cl_g2000570%FOUND;
  CLOSE                 cl_g2000570;
  --
  IF l_trata_recibos_ep
   THEN
    --
    l_trata_recibos_ep := (l_mca_trata_recibos_ep = 'S');
    --
  END IF;
  --
  RETURN l_trata_recibos_ep;
  --
 END fp_trata_recibos_ep;
 --
 /* -------------------------------------------------------
 || fp_determina_fecha_anulacion :
 ||
 || Determina la fecha a tener en cuenta para comprobar
 || la deuda
 */ -------------------------------------------------------
 --
 FUNCTION fp_determina_fecha_anulacion
   RETURN DATE IS
  --
  l_fecha_anulacion a2000500.fec_tratamiento %TYPE;
  l_mca_recibo_ep   VARCHAR2(1);
  --
 BEGIN
  --
  --@mx('I','fp_determina_fecha_anulacion');
  --
  IF    g_reg_g2000510.mca_recalcula_fecha        = 'S'
     OR (     g_reg_g2000510.mca_recalcula_fecha  = 'N'
          AND g_reg_recibo.fec_vcto_pago         IS NULL
        )
   THEN
    --
    l_mca_recibo_ep := 'N';
    --
    IF g_reg_recibo.tip_situacion = 'EP'
     THEN
      --
      l_mca_recibo_ep := 'S';
      --
    END IF;
    --
    l_fecha_anulacion := em_k_g2000570.f_fec_vcto_pago(g_reg.cod_cia                 ,
                                                       g_reg.cod_sector              ,
                                                       g_reg.cod_ramo                ,
                                                       g_reg_em_k_a2000030.cod_mon   ,
                                                       g_reg_em_k_a2000030.tip_gestor,
                                                       g_reg_em_k_a2000030.cod_gestor,
                                                       g_reg_em_k_a2000030.cod_agt   ,
                                                       g_reg_recibo.fec_efec_recibo  ,
                                                       g_reg_recibo.fec_remesa       ,
                                                       l_mca_recibo_ep               );
    --
   ELSE
    --
    l_fecha_anulacion := g_reg_recibo.fec_vcto_pago;
    --
  END IF;
  --
  --@mx('F','fp_determina_fecha_anulacion '||l_fecha_anulacion);
  --
  RETURN l_fecha_anulacion;
  --
 END fp_determina_fecha_anulacion;
 --
 /* -------------------------------------------------------
 || pp_rec_max_spto_vigente :
 ||
 || Recupera el maximo suplemento de la poliza o aplicacion
 */ -------------------------------------------------------
 --
 PROCEDURE pp_rec_max_spto_vigente IS
 BEGIN
  --
  --@mx('I','pp_rec_max_spto_vigente');
  --
  IF g_reg.num_apli = 0
   THEN
    --
    g_max_spto_vigente := em_f_max_spto_1(g_reg.cod_cia    ,
                                          g_reg.num_poliza );
    --
   ELSE
    --
    g_max_spto_vigente := em_f_max_spto_apli(g_reg.cod_cia    ,
                                             g_reg.num_poliza ,
                                             g_reg.num_spto   ,
                                             g_reg.num_apli   ,
                                             99999            );
    --
  END IF;
  --
  --@mx('F','pp_rec_max_spto_vigente');
  --
 END pp_rec_max_spto_vigente;
 --
 /* -------------------------------------------------------
 || pp_recupera_parametros :
 ||
 || Recupera los parametros necesarios para la ejecucion.
 || Estos parametros los asigna la tarea
 */ -------------------------------------------------------
 --
 PROCEDURE pp_recupera_parametros IS
 BEGIN
  --
  --@mx('I','pp_recupera_parametros ');
  --
  pp_inicia_var_parametros;
  --
  g_mca_multihilo           := fp_devuelve_c('jbmca_multihilo'          );
  --
  g_tip_mvto_batch          := fp_devuelve_c('tip_mvto_batch'           );
  g_fec_tratamiento         := fp_devuelve_f('fec_tratamiento'          );
  g_num_orden               := fp_devuelve_n('jbnum_orden'              );
  --
  g_cod_cia                 := fp_devuelve_n('jbcod_cia'                );
  g_cod_sector              := fp_devuelve_n('jbcod_sector'             );
  g_cod_ramo                := fp_devuelve_n('jbcod_ramo'               );
  g_cod_nivel1              := fp_devuelve_n('jbcod_nivel1'             );
  g_cod_nivel2              := fp_devuelve_n('jbcod_nivel2'             );
  g_cod_nivel3              := fp_devuelve_n('jbcod_nivel3'             );
  g_cod_agt                 := fp_devuelve_n('jbcod_agt'                );
  g_num_poliza              := fp_devuelve_c('jbnum_poliza'             );
  g_num_poliza_grupo        := fp_devuelve_c('jbnum_poliza_grupo'       );
  g_num_poliza_cliente      := fp_devuelve_c('jbnum_poliza_cliente'     );
  --
  g_cant_registros          := fp_devuelve_n('jbcant_registros'         );
  g_max_num_riesgos         := fp_devuelve_n('jbmax_num_riesgos'        );
  g_mca_grupos              := fp_devuelve_c('jbmca_grupos'             );
  --
  g_mca_reproceso           := fp_devuelve_c('jbmca_reproceso'          );
  --
  g_cod_spto                := fp_devuelve_n('jbcod_spto'               );
  g_sub_cod_spto            := fp_devuelve_n('jbsub_cod_spto'           );
  --
  IF g_tip_mvto_batch IN (g_k_regularizacion_vida  ,
                          g_k_aportaciones_pactadas,
                          g_k_anul_aport_pactada   )
   THEN
    --
    g_cod_tip_spto            := fp_devuelve_c('jbcod_tip_spto'        );
    g_cod_usr_captura         := fp_devuelve_c('jbcod_usr_captura'     );
    g_txt_motivo_spto         := fp_devuelve_c('jbtxt_motivo_spto'     );
    --
   ELSIF     g_tip_mvto_batch  = g_k_suspension_plan_aport
   THEN
     --
     g_cod_spto_susp_pa        := fp_devuelve_c('jbcod_spto_susp_pa'    );
     g_sub_cod_spto_susp_pa    := fp_devuelve_c('jbsub_cod_spto_susp_pa');
     g_cod_tip_spto_susp_pa    := fp_devuelve_c('jbcod_tip_spto_susp_pa');
     g_txt_motivo_spto         := fp_devuelve_c('jbtxt_motivo_spto'     );
     --
  ELSIF     g_tip_mvto_batch  = g_k_anulacion_batch
     OR fp_otros_batch
   THEN
    --
    g_cod_spto_as             := fp_devuelve_n('jbcod_spto_as'          );
    g_sub_cod_spto_as         := fp_devuelve_n('jbsub_cod_spto_as'      );
    g_cod_tip_spto_as         := fp_devuelve_c('jbcod_tip_spto_as'      );
    --
    g_cod_spto_tmp            := fp_devuelve_n('jbcod_spto_tmp'         );
    g_sub_cod_spto_tmp        := fp_devuelve_n('jbsub_cod_spto_tmp'     );
    g_cod_tip_spto_tmp        := fp_devuelve_c('jbcod_tip_spto_tmp'     );
    --
    g_cod_spto_aa             := fp_devuelve_n('jbcod_spto_aa'          );
    g_sub_cod_spto_aa         := fp_devuelve_n('jbsub_cod_spto_aa'      );
    g_cod_tip_spto_aa         := fp_devuelve_c('jbcod_tip_spto_aa'      );
    --
    g_cod_spto_re             := fp_devuelve_n('jbcod_spto_re'          );
    g_sub_cod_spto_re         := fp_devuelve_n('jbsub_cod_spto_re'      );
    g_cod_tip_spto_re         := fp_devuelve_c('jbcod_tip_spto_re'      );
    --
    IF g_tip_mvto_batch = g_k_anulacion_batch
     THEN
      --
      g_trata_recibos_ep      := fp_trata_recibos_ep;
      --
    END IF;
    --
   ELSIF g_tip_mvto_batch IN ( g_k_autoriza_pol_batch  ,
                               g_k_autoriza_ppto_batch )
       THEN
        --
        g_num_riesgo_autoriza := fp_devuelve_n('jbnum_riesgo'           );
        --
        g_cod_nivel_salto     := fp_devuelve_c('jbcod_nivel_salto'      );
        g_cod_error           := fp_devuelve_n('jbcod_error'            );
        --
        g_fec_desde           := fp_devuelve_f('jbfec_desde'            );
        g_fec_hasta           := fp_devuelve_f('jbfec_hasta'            );
        --
        g_cod_usr_cia         := fp_devuelve_c('jbcod_usr_cia'          );
        --
        g_tip_autoriza_ct     := fp_devuelve_c('tip_autoriza_ct'        );
        --
  END IF;
  --
  g_mca_aborta_emision        := fp_devuelve_c('jbmca_aborta_emision'   );
  --
  g_mca_ejecuta_filtro        := NVL(trn_k_global.ref_f_global('jbmca_ejecuta_filtro'),TRN.NO);
  --
  /* -------------------------------------------------------
  || Se comentan los siguientes parametros hasta determinar
  || como tratarlos
  */ -------------------------------------------------------
  --
  --g_mca_graba_riesgos_error := fp_devuelve_c('jbmca_graba_riesgos_error');
  --
  pp_muestra_parametros;
  --@mx('F','pp_recupera_parametros ');
  --
 END pp_recupera_parametros;
 --
 /* -------------------------------------------------------
 || pp_datos_proceso :
 ||
 || Recupera los datos de la definicion del proceso.
 || Si tiene activadas las trazas, genera el indentificati-
 || vo de la sesion que se guardara en el cod_usr de la
 || tabla g2000510.
 */ -------------------------------------------------------
 --
 PROCEDURE pp_datos_proceso IS
  --
  l_tip_mvto_batch a2000500.tip_mvto_batch %TYPE;
  --
 BEGIN
  --
  --@mx(g_cod_usr_g2000510,'pp_datos_proceso ');
  --
  g_reg_g2000510          := g_reg_g2000510_nulo;
  g_cod_excepcion_defecto := NULL;
  g_nom_excepcion_defecto := NULL;
  --
  l_tip_mvto_batch := fp_tip_mvto_batch_acceso;
  --
  --@mx(g_cod_usr_g2000510,'l_tip_mvto_batch '||l_tip_mvto_batch);
  --
  OPEN  cg_g2000510(l_tip_mvto_batch);
  FETCH cg_g2000510 INTO g_reg_g2000510;
  CLOSE cg_g2000510;
  --
  IF g_reg_g2000510.nom_prg_excepcion IS NOT NULL
   THEN
    --
    g_cod_excepcion_defecto := em_k_g2000590.f_excepcion_defecto(g_cod_cia,
                                                                 'N'      );
    g_nom_excepcion_defecto := em_k_g2000590.f_nom_excepcion;
    --
  END IF;
  --
  IF g_trazas_activas AND g_mca_multihilo = 'S'
  THEN
    IF SUBSTR(g_reg_g2000510.cod_usr,1,1) = '@'
    THEN
      g_cod_usr_g2000510 := '@'||TO_CHAR(TO_NUMBER(SUBSTR(g_reg_g2000510.cod_usr,2))+1);
    ELSE
      g_cod_usr_g2000510 := '@1';
    END IF;
  ELSE
    g_cod_usr_g2000510 := g_reg_g2000510.cod_usr;
  END IF;
  --
  --@mx('F','pp_datos_proceso');
  --
 END pp_datos_proceso;
 --
 /* -------------------------------------------------------
 || pp_actualiza_filtro :
 ||
 || Actualiza la situacion del filtro
 || Si tiene las trazas activadas, actualizara el cod_usr
 || con el identificativo de la sesion.
 */ -------------------------------------------------------
 --
 PROCEDURE pp_actualiza_filtro ( p_tip_situ_filtro g2000510.tip_situ_filtro%TYPE ,
                                 p_cod_usr         g2000510.cod_usr        %TYPE )
 IS
  --
  l_tip_mvto_batch g2000510.tip_mvto_batch %TYPE;
  --
 BEGIN
  --
  --@mx(p_cod_usr,'pp_actualiza_filtro p_tip_situ_filtro '||p_tip_situ_filtro);
  --
  l_tip_mvto_batch := fp_tip_mvto_batch_acceso;
  --
  UPDATE g2000510
     SET tip_situ_filtro = p_tip_situ_filtro  ,
         cod_usr         = p_cod_usr
   WHERE cod_cia         = g_cod_cia
     AND fec_tratamiento = g_fec_tratamiento
     AND num_orden       = g_num_orden
     AND tip_mvto_batch  = l_tip_mvto_batch;
  --
  --@mx('F','pp_actualiza_filtro');
  --
 END pp_actualiza_filtro;
 --
 /* -------------------------------------------------------
 || fp_comprueba_tip_situ_filtro :
 ||
 || Comprueba la situacion del filtro para gestionar el
 || bloqueo del proceso.
 || Monohilo: comprueba que el filtro no este siendo proce-
 || cesado por otro usuario ( tip_situ_filtro != 7,8
 || Multihilo: comprueba que el filtro no este siendo proce-
 || cesado por otro usuario de forma monohilo
 */ -------------------------------------------------------
 --
 FUNCTION fp_comprueba_tip_situ_filtro
   RETURN BOOLEAN
 IS
   CURSOR cg_g2000510_bloqueo
      ( pc_tip_mvto_batch     g2000510.tip_mvto_batch  %TYPE,
        pc_tip_situ_filtro_1  g2000510.tip_situ_filtro %TYPE ,
        pc_tip_situ_filtro_2  g2000510.tip_situ_filtro %TYPE
      )
     IS
        SELECT ''
          FROM g2000510
         WHERE cod_cia         = g_cod_cia
           AND fec_tratamiento = g_fec_tratamiento
           AND num_orden       = g_num_orden
           AND tip_mvto_batch  = pc_tip_mvto_batch
           AND tip_situ_filtro NOT IN ( pc_tip_situ_filtro_1 , pc_tip_situ_filtro_2 )
         FOR UPDATE NOWAIT;
   --
   l_x_bloqueada EXCEPTION;
   PRAGMA        EXCEPTION_INIT(l_x_bloqueada,-54);
   --
   l_tip_mvto_batch a2000500.tip_mvto_batch %TYPE;
   l_reg            cg_g2000510_bloqueo%ROWTYPE;
   --
   l_retorno        BOOLEAN := TRUE;
   --
 BEGIN
  --
  --@mx('I','fp_comprueba_tip_situ_filtro ');
  --
  --@mx('g_cod_cia-->',g_cod_cia);
  --@mx('g_fec_tratamiento-->',g_fec_tratamiento);
  --@mx('g_num_orden-->',g_num_orden);
  --@mx('l_tip_mvto_batch-->',fp_tip_mvto_batch_acceso);
  --
   BEGIN
       --
       l_tip_mvto_batch := fp_tip_mvto_batch_acceso;
       --
       IF g_mca_multihilo = 'S'
       THEN
         OPEN  cg_g2000510_bloqueo(l_tip_mvto_batch,g_k_en_proceso_monohilo,g_k_en_proceso_monohilo);
       ELSE
         OPEN  cg_g2000510_bloqueo(l_tip_mvto_batch,g_k_en_proceso_monohilo,g_k_en_proceso_multihilo);
       END IF;
       --
       FETCH cg_g2000510_bloqueo INTO l_reg;
       --
       IF cg_g2000510_bloqueo%NOTFOUND
       THEN
          l_retorno := FALSE;
          --@mx('*','bloqueada por tip_situ_filtro en proceso');
       END IF;
       --
       CLOSE cg_g2000510_bloqueo;
       --
   EXCEPTION
      WHEN l_x_bloqueada
      THEN
       l_retorno  := FALSE ;
       --@mx('*','bloqueada por otro usuario');
   END;
   --
   --@mx('F','fp_comprueba_tip_situ_filtro ');
   --
   RETURN l_retorno;
   --
 END fp_comprueba_tip_situ_filtro;
 /* -------------------------------------------------------
 || pp_asigna_globales_inicio :
 ||
 || Asigna las globales del registro
 */ -------------------------------------------------------
 --
 PROCEDURE pp_asigna_globales_inicio IS
 BEGIN
  --
  --@mx('I','pp_asigna_globales_inicio ');
  --
  pp_asigna('tip_mvto_batch'        ,g_tip_mvto_batch          );
  pp_asigna('fec_tratamiento'       ,g_fec_tratamiento         );
  pp_asigna('num_orden'             ,g_num_orden               );
  pp_asigna('jbmca_aborta_emision'  ,g_mca_aborta_emision      );
  pp_asigna('g_mca_retroactivo'     ,g_mca_retroactivo         );
  --
  pp_asigna('cod_cia'               ,g_reg.cod_cia             );
  pp_asigna('cod_sector'            ,g_reg.cod_sector          );
  pp_asigna('cod_ramo'              ,g_reg.cod_ramo            );
  --
  pp_asigna('num_poliza_grupo'      ,g_reg.num_poliza_grupo    );
  pp_asigna('num_contrato'          ,g_reg.num_contrato        );
  pp_asigna('num_subcontrato'       ,g_reg.num_subcontrato     );
  pp_asigna('num_poliza_cliente'    ,g_reg.num_poliza_cliente  );
  pp_asigna('num_poliza'            ,g_reg.num_poliza          );
  --
  pp_asigna('num_riesgo'            ,g_num_riesgo              );
  pp_asigna('mca_provisional'       ,g_mca_provisional         );
  pp_asigna('num_poliza_definitivo' ,g_num_poliza_definitivo   );
  --
  pp_asigna('tip_emision'           ,g_tip_emision             );
  --
  IF g_tip_mvto_batch IN ( g_k_autoriza_pol_batch   ,
                           g_k_autoriza_ppto_batch  ,
                           g_k_autoriza_pre_rf_batch)
   THEN
    --
    pp_asigna('cod_nivel1'          ,g_cod_nivel1              );
    pp_asigna('cod_nivel2'          ,g_cod_nivel2              );
    pp_asigna('cod_nivel3'          ,g_cod_nivel3              );
    --
    pp_asigna('num_riesgo_autoriza' ,g_num_riesgo_autoriza     );
    --
    pp_asigna('cod_nivel_salto'     ,g_cod_nivel_salto         );
    pp_asigna('cod_error'           ,g_cod_error               );
    --
    pp_asigna('fec_desde'           ,g_fec_desde               );
    pp_asigna('fec_hasta'           ,g_fec_hasta               );
    --
    pp_asigna('cod_usr_cia'         ,g_cod_usr_cia             );
    --
  END IF;
  --
  dc_k_a1001800.p_lee(g_reg.cod_cia ,
                      g_reg.cod_ramo);
  --
  pp_asigna('cod_tratamiento',dc_k_a1001800.f_cod_tratamiento);
  --
  --@mx('F','pp_asigna_globales_inicio ');
  --
 END pp_asigna_globales_inicio;
 --
 /* -------------------------------------------------------
 || pp_asigna_globales_proceso :
 ||
 || Asigna las globales necesarias para el proceso
 */ -------------------------------------------------------
 --
 PROCEDURE pp_asigna_globales_proceso ( p_tip_mvto_batch   a2000500.tip_mvto_batch  %TYPE ,
                                        p_fec_efec_spto    a2000030.fec_efec_spto   %TYPE ,
                                        p_hora_desde       a2000030.hora_desde      %TYPE ,
                                        p_fec_vcto_spto    a2000030.fec_vcto_spto   %TYPE ,
                                        p_cod_spto         a2000030.cod_spto        %TYPE ,
                                        p_sub_cod_spto     a2000030.sub_cod_spto    %TYPE ,
                                        p_cod_tip_spto     a2000030.cod_tip_spto    %TYPE ,
                                        p_cod_negocio      a2000030.cod_negocio     %TYPE ,
                                        p_num_spto_anulado a2000030.num_spto_anulado%TYPE )
 IS
 --
    l_num_poliza    p2000030.num_poliza    %TYPE;
    l_num_spto      p2000030.num_spto      %TYPE;
    l_num_apli      p2000030.num_apli      %TYPE;
    l_num_spto_apli p2000030.num_spto_apli %TYPE;
 --
 BEGIN
    --
    --@mx('I','pp_asigna_globales_proceso');
    --
    pp_asigna('tip_mvto_batch'      ,p_tip_mvto_batch          );
    --
    pp_asigna('mca_renueva'         ,g_reg.mca_renueva         );
    pp_asigna('mca_renueva_tmp'     ,g_reg.mca_renueva_tmp     );
    pp_asigna('mca_periodicidad'    ,g_reg.mca_periodicidad    );
    pp_asigna('cant_renovaciones'   ,g_reg.cant_renovaciones   );
    --
    pp_asigna('mca_prima_manual'    ,g_reg.mca_prima_manual    );
    pp_asigna('mca_prorrata'        ,g_reg.mca_prorrata        );
    pp_asigna('mca_devuelve_todo'   ,g_reg.mca_devuelve_todo   );
    --
    pp_asigna('txt_motivo_spto'     ,g_reg.txt_motivo_spto     );
    --
    pp_asigna('tip_poliza_tr'       ,g_reg.tip_poliza_tr       );
    --
    pp_asigna('num_spto'            ,g_num_spto                );
    pp_asigna('num_apli'            ,g_num_apli                );
    pp_asigna('num_spto_apli'       ,g_num_spto_apli           );
    --
    pp_asigna('fec_efec_spto'       ,p_fec_efec_spto           );
    pp_asigna('hora_desde'          ,p_hora_desde              );
    pp_asigna('fec_vcto_spto'       ,p_fec_vcto_spto           );
    --
    pp_asigna('cod_spto'            ,p_cod_spto                );
    pp_asigna('sub_cod_spto'        ,p_sub_cod_spto            );
    pp_asigna('cod_tip_spto'        ,p_cod_tip_spto            );
    --
    pp_asigna('num_presupuesto'     ,''                        );
    --
    pp_asigna('tip_autoriza_ct'     ,g_reg.tip_autoriza_ct     );
    --
    pp_asigna('cod_negocio'         ,p_cod_negocio             );
    pp_asigna('num_spto_anulado'    ,p_num_spto_anulado        );
    --
    pp_asigna('idn_val'             ,g_reg.idn_val             );
    --
    IF g_tip_mvto_batch IN ( g_k_carga_batch ,
                             g_k_apli_batch  ,
                             g_k_presup_batch)
    THEN
       --
       pp_asigna('num_presupuesto'  ,g_reg.num_poliza          );
       --
       /* ---------------------------------------------------------------
       || En cargas de aplicaciones, el numero de poliza marco debe ir
       || indicado en la columna num_poliza_tronador.
       || En caso de no indicarse este dato, intenta recuperar la poliza
       || marco con que se ha grabado la aplicacion en la tabla p2000030
       || que debe estar en la columna num_poliza_tr.
       || Si esta columna tampoco indica el numero de poliza marco, asume
       || que es el mismo con que se identifica la aplicacion.
       */ ---------------------------------------------------------------
       --
       IF     g_tip_mvto_batch           = g_k_apli_batch
          AND g_reg.num_poliza_tronador IS NULL
       THEN
          --
          em_k_p2000030.p_spto_apli_presupuesto( p_cod_cia         => g_reg.cod_cia    ,
                                                 p_num_presupuesto => g_reg.num_poliza ,
                                                 p_num_spto        => l_num_spto       ,
                                                 p_num_apli        => l_num_apli       ,
                                                 p_num_spto_apli   => l_num_spto_apli  );
          --
          em_k_p2000030.p_lee(p_cod_cia       => g_reg.cod_cia    ,
                              p_num_poliza    => g_reg.num_poliza ,
                              p_num_spto      => l_num_spto       ,
                              p_num_apli      => l_num_apli       ,
                              p_num_spto_apli => l_num_spto_apli  );
          --
          l_num_poliza := em_k_p2000030.f_num_poliza_tr;
          --
          pp_asigna('num_poliza'    , NVL(l_num_poliza , g_reg.num_poliza));
          --
       ELSE
          --
          pp_asigna('num_poliza'    , g_reg.num_poliza_tronador);
          --
       END IF;
       --
    ELSIF g_tip_mvto_batch = g_k_autoriza_pol_batch
    THEN
       --
       pp_asigna('mca_presupuesto' , trn.NO                        );
       pp_asigna('tip_origen_em'   , em.TIP_ORIGEN_EM_REAL         );
       --
    ELSIF g_tip_mvto_batch = g_k_autoriza_ppto_batch
    THEN
       --
       pp_asigna('mca_presupuesto' , trn.SI                        );
       pp_asigna('tip_origen_em'   , em.TIP_ORIGEN_EM_PRESUPUESTO  );
       --
    ELSIF g_tip_mvto_batch = g_k_autoriza_pre_rf_batch
    THEN
       --
       pp_asigna('mca_presupuesto' , trn.NO                        );
       pp_asigna('tip_origen_em'   , em.TIP_ORIGEN_EM_PRERENOVACION);
       --
    END IF;
    --
    --@mx('F','pp_asigna_globales_proceso');
    --
 END pp_asigna_globales_proceso;
 --
 /* -------------------------------------------------------
 || pp_recupera_globales :
 ||
 || Recupera las globales asignadas por el proceso
 */ -------------------------------------------------------
 --
 PROCEDURE pp_recupera_globales
 IS
 --
 BEGIN
    --
    --@mx('I','pp_recupera_globales');
    --
    g_num_poliza_definitivo := fp_devuelve_c('num_poliza')     ;
    g_mca_provisional       := fp_devuelve_c('mca_provisional');
    g_num_riesgo            := fp_devuelve_n('num_riesgo')     ;
    --
    g_txt_poliza_definitiva := trn_k_global.ref_f_global('txt_poliza_definitivo');
    --
    --@mx('F','pp_recupera_globales');
    --
 END pp_recupera_globales;
 --
 /* -------------------------------------------------------
 || fp_nom_tip_spto :
 ||
 || Recupera la descripcion del tipo de suplemento
 */ -------------------------------------------------------
 --
 FUNCTION fp_nom_tip_spto(p_cod_tip_spto g2990300.cod_tip_spto %TYPE,
                          p_tip_spto     g2990300.tip_spto     %TYPE)
    RETURN VARCHAR2
 IS
 --
    CURSOR cl_g2990300
    IS
       SELECT nom_tip_spto,
              mca_inh
         FROM g2990300
        WHERE cod_cia      = g_cod_cia
          AND cod_ramo     = em.COD_RAMO_GEN
          AND cod_tip_spto = p_cod_tip_spto
          AND tip_spto     = p_tip_spto;
    --
    CURSOR cl_g2990300_1
    IS
       SELECT a.nom_tip_spto
         FROM g2990300 a
        WHERE a.cod_cia   = g_cod_cia
          AND a.cod_ramo  = em.COD_RAMO_GEN
          AND a.tip_spto  = p_tip_spto
          AND a.mca_inh   = trn.NO;
    --
    l_nom_tip_spto g2990300.nom_tip_spto %TYPE;
    l_mca_inh      g2990300.mca_inh      %TYPE;
    --
    l_existe BOOLEAN;
 --
 BEGIN
    --
    --@mx('I','fp_nom_tip_spto');
    --
    OPEN cl_g2990300;
    --
    FETCH cl_g2990300 INTO l_nom_tip_spto,
                           l_mca_inh     ;
    --
    l_existe := cl_g2990300%FOUND;
    --
    CLOSE cl_g2990300;
    --
    IF NOT l_existe
    THEN
       --
       OPEN cl_g2990300_1;
       --
       FETCH cl_g2990300_1 INTO l_nom_tip_spto;
       --
       l_existe := cl_g2990300_1%FOUND;
       --
       CLOSE cl_g2990300_1;
       --
       IF l_existe
       THEN
          --
          g_cod_mensaje := 20001   ; -- CODIGO INEXISTENTE
          g_anx_mensaje := trn.NULO;
          --
          pp_devuelve_error;
          --
       ELSE
          --
          l_nom_tip_spto := trn.NULO;
          --
       END IF;
       --
    ELSIF l_mca_inh = trn.SI
    THEN
       --
       g_cod_mensaje := 20003072; -- CAUSA/MOTIVO INHABILITADO
       g_anx_mensaje := trn.NULO;
       --
       pp_devuelve_error;
       --
    END IF;
    --
    --@mx('F','fp_nom_tip_spto');
    --
    RETURN l_nom_tip_spto;
    --
 END fp_nom_tip_spto;
 --
 /* -------------------------------------------------------
 || fp_comprueba_spto_tmp :
 ||
 || Comprueba que los parametros codigo y sub-codigo de
 || suplemento concuerden con el tipo de movimiento
 */ -------------------------------------------------------
 --
 FUNCTION fp_comprueba_spto_tmp
   RETURN BOOLEAN IS
  --
  l_retorno     BOOLEAN;
  l_tip_emision VARCHAR2(1);
  --
 BEGIN
  --
  --@mx('I','fp_comprueba_spto_tmp');
  --
  l_retorno     := TRUE;
  l_tip_emision := fp_tip_emision;
  --
  IF    g_tip_mvto_batch  = g_k_anulacion_batch
     OR fp_otros_batch
   THEN
    --
    IF     g_cod_spto_tmp           IS NOT NULL
       AND g_sub_cod_spto_tmp       IS NOT NULL
     THEN
      --
      g_tip_spto_tmp :=  em_k_a2991800.f_lee_tip_spto( g_cod_cia          ,
                                                       g_cod_spto_tmp     ,
                                                       g_sub_cod_spto_tmp ,
                                                       l_tip_emision      );
      --
      IF g_tip_spto_tmp != 'AX'
       THEN
        --
        l_retorno := FALSE;
        --
      END IF;
      --
    END IF;
    --
  END IF;
  --
  --@mx('F','fp_comprueba_spto_tmp');
  --
  RETURN l_retorno;
  --
 END fp_comprueba_spto_tmp;
 --
 /* -------------------------------------------------------
 || fp_comprueba_spto_aa :
 ||
 || Comprueba que los parametros codigo y sub-codigo de
 || suplemento concuerden con el tipo de movimiento
 */ -------------------------------------------------------
 --
 FUNCTION fp_comprueba_spto_aa
   RETURN BOOLEAN IS
  --
  l_retorno     BOOLEAN;
  l_tip_emision VARCHAR2(1);
  --
 BEGIN
  --
  --@mx('I','fp_comprueba_spto_aa');
  --
  l_retorno     := TRUE;
  l_tip_emision := fp_tip_emision;
  --
  IF    g_tip_mvto_batch  = g_k_anulacion_batch
     OR fp_otros_batch
   THEN
    --
    IF     g_cod_spto_aa            IS NOT NULL
       AND g_sub_cod_spto_aa        IS NOT NULL
     THEN
      --
      g_tip_spto_aa  :=  em_k_a2991800.f_lee_tip_spto( g_cod_cia          ,
                                                       g_cod_spto_aa      ,
                                                       g_sub_cod_spto_aa  ,
                                                       l_tip_emision      );
      --
      IF g_tip_spto_aa  != 'AA'
       THEN
        --
        l_retorno := FALSE;
        --
      END IF;
      --
    END IF;
    --
  END IF;
  --
  --@mx('F','fp_comprueba_spto_aa');
  --
  RETURN l_retorno;
  --
 END fp_comprueba_spto_aa;
 --
 /* -------------------------------------------------------
 || fp_comprueba_spto_as :
 ||
 || Comprueba que los parametros codigo y sub-codigo de su-
 || plemento concuerden con el tipo de movimiento
 */ -------------------------------------------------------
 --
 FUNCTION fp_comprueba_spto_as
   RETURN BOOLEAN IS
  --
  l_retorno     BOOLEAN;
  l_tip_emision VARCHAR2(1);
  --
 BEGIN
  --
  --@mx('I','fp_comprueba_spto_as');
  --
  l_retorno     := TRUE;
  l_tip_emision := fp_tip_emision;
  --
  IF    g_tip_mvto_batch  = g_k_anulacion_batch
     OR fp_otros_batch
   THEN
    --
    IF     g_cod_spto_as           IS NOT NULL
       AND g_sub_cod_spto_as       IS NOT NULL
     THEN
      --
      g_tip_spto_as := em_k_a2991800.f_lee_tip_spto( g_cod_cia         ,
                                                     g_cod_spto_as     ,
                                                     g_sub_cod_spto_as ,
                                                     l_tip_emision     );
      --
      IF g_tip_spto_as != 'AS'
       THEN
        --
        l_retorno := FALSE;
        --
      END IF;
      --
    END IF;
    --
  END IF;
  --
  --@mx('F','fp_comprueba_spto_as');
  --
  RETURN l_retorno;
  --
 END fp_comprueba_spto_as;
 --
 /* -------------------------------------------------------
 || fp_comprueba_spto_re :
 ||
 || Comprueba que los parametros codigo y sub-codigo de su-
 || plemento concuerden con el tipo de movimiento
 */ -------------------------------------------------------
 --
 FUNCTION fp_comprueba_spto_re
   RETURN BOOLEAN IS
  --
  l_retorno     BOOLEAN;
  l_tip_emision VARCHAR2(1);
  --
 BEGIN
  --
  --@mx('I','fp_comprueba_spto_re');
  --
  l_retorno     := TRUE;
  l_tip_emision := fp_tip_emision;
  --
  IF    g_tip_mvto_batch  = g_k_anulacion_batch
     OR fp_otros_batch
   THEN
    --
    IF     g_cod_spto_re           IS NOT NULL
       AND g_sub_cod_spto_re       IS NOT NULL
     THEN
      --
      g_tip_spto_re := em_k_a2991800.f_lee_tip_spto( g_cod_cia         ,
                                                     g_cod_spto_re     ,
                                                     g_sub_cod_spto_re ,
                                                     l_tip_emision     );
      --
      IF g_tip_spto_re != 'RE'
       THEN
        --
        l_retorno := FALSE;
        --
      END IF;
      --
    END IF;
    --
  END IF;
  --
  --@mx('F','fp_comprueba_spto_re');
  --
  RETURN l_retorno;
  --
 END fp_comprueba_spto_re;
 --
 /* -------------------------------------------------------
 || fp_comprueba_spto :
 ||
 || Comprueba que los parametros codigo y sub-codigo de su-
 || plemento concuerden con el tipo de movimiento
 */ -------------------------------------------------------
 --
 FUNCTION fp_comprueba_spto
   RETURN BOOLEAN IS
  --
  l_tip_mvto_batch a2000500.tip_mvto_batch %TYPE;
  --
  l_tip_emision    VARCHAR2(1);
  l_retorno        BOOLEAN;
  --
 BEGIN
  --
  --@mx('I','fp_comprueba_spto');
  --
  l_retorno  := TRUE;
  --
  l_tip_mvto_batch := g_tip_mvto_batch;
  l_tip_emision    := fp_tip_emision;
  --
  IF fp_otros_batch
   THEN
    --
    l_tip_mvto_batch := g_k_anulacion_batch;
    --
  END IF;
  --
  IF     g_cod_spto     IS NOT NULL
     AND g_sub_cod_spto IS NOT NULL
   THEN
     --
     g_tip_spto := em_k_a2991800.f_lee_tip_spto( g_cod_cia      ,
                                                 g_cod_spto     ,
                                                 g_sub_cod_spto ,
                                                 l_tip_emision  );
     --
     IF     l_tip_mvto_batch IN ( g_k_rf_batch     ,
                                  g_k_pre_rf_batch )
        AND g_tip_spto       != 'RF'
      THEN
       --
       l_retorno := FALSE;
       --
     ELSIF     l_tip_mvto_batch  = g_k_anulacion_batch
            AND g_tip_spto       != 'AT'
          THEN
           --
           l_retorno := FALSE;
           --
           --Proceso Anulacion Aportacion Pactada -spto tmp- se comporta
           -- como una anulaci??A?n >> aqui se permite este tipo de suplemento
           IF g_tip_mvto_batch = g_k_anul_aport_pactada
             AND g_tip_spto    =  em.ANULACION_TMP  THEN
             --
             l_retorno := TRUE;
             --
           END IF;
           --
     END IF;
     --
  END IF;
  --
  --@mx('F','fp_comprueba_spto');
  --
  RETURN l_retorno;
  --
 END fp_comprueba_spto;
 --
 /* -------------------------------------------------------
 || pp_traspasa_pre_renovacion :
 ||
 || Llama al proceso que traspasa los datos de pre-renovacion
 || de la poliza a las tablas reales
 */ -------------------------------------------------------
 --
 PROCEDURE pp_traspasa_pre_renovacion IS
 BEGIN
  --
  --@mx('I','pp_traspasa_pre_renovacion');
  --
  em_k_batch_poliza.p_traspasa_desde_r;
  --
  --@mx('F','pp_traspasa_pre_renovacion');
  --
 END pp_traspasa_pre_renovacion;
 --
 /* -------------------------------------------------------
 || pp_borra_pre_renovacion :
 ||
 || Llama al proceso que borra los datos de pre-renovacion
 || de la poliza
 */ -------------------------------------------------------
 --
 PROCEDURE pp_borra_pre_renovacion IS
 BEGIN
  --
  --@mx('I','pp_borra_pre_renovacion ');
  --
  g_reg.mca_pre_renovacion := 'N';
  --
  IF trn_k_g0000000.f_mca_partition_table = 'S'
   THEN
    --
    em_k_tablas_r.p_borra;
    --
  ELSE
    --
    trn_p_dinamico(g_k_package_r||LPAD(TO_CHAR(g_reg.cod_ramo),3,'0')
                              ||'.p_borra'
                  );
    --
  END IF;
  --
  --@mx('F','pp_borra_pre_renovacion ');
  --
 END pp_borra_pre_renovacion;
 --
 /* -------------------------------------------------------
 || pp_autoriza :
 ||
 || Llama al proceso que autoriza o rechaza la poliza
 */ -------------------------------------------------------
 --
 PROCEDURE pp_autoriza IS
  --
  l_tip_accion_rechazo g2000210.tip_accion_rechazo %TYPE;
  --
 BEGIN
  --
  --@mx('I','pp_autoriza');
  --
  em_k_ap200120.p_trata_proceso_masivo;
  --
  IF em_k_ap200120.f_trata_poliza = 'N'
   THEN
    --
    g_tip_situ := '*';
    --
   ELSE
    --
    l_tip_accion_rechazo := em_k_ap200120.f_tip_accion_rechazo;
    --
    IF l_tip_accion_rechazo IS NOT NULL
     THEN
      --
      g_txt_mensaje := fp_rec_nom_valor('TIP_ACCION_RECHAZO',
                                        l_tip_accion_rechazo);
      g_tip_situ    := g_k_rechazo_accion;
      --
    END IF;
    --
  END IF;
  --
  --@mx('F','pp_autoriza');
  --
 END pp_autoriza;
 --
 /* -------------------------------------------------------
 || pp_emite :
 ||
 || Llama al proceso que emite el movimiento
 */ -------------------------------------------------------
 --
 PROCEDURE pp_emite IS
 BEGIN
  --
  --@mx('I','pp_emite');
  --
  em_k_batch_poliza.p_emite;
  --
  --@mx('F','pp_emite');
  --
 END pp_emite;
 --
 /* -------------------------------------------------------
 || pp_comprueba_importes :
 ||
 || Comprueba que el importe total del recibo o de la poli-
 || za sea positivo
 */ -------------------------------------------------------
 --
 PROCEDURE pp_comprueba_importes IS
  --
  l_imp_recibo a2990700.imp_recibo %TYPE;
  --
 BEGIN
  --
  --@mx('I','pp_comprueba_importes');
  --
  l_imp_recibo := 0;
  --
  OPEN  cg_a2990700_imp_poliza( g_reg.cod_cia    ,
                                g_reg.num_poliza ,
                                g_reg.num_apli   );
  FETCH cg_a2990700_imp_poliza INTO l_imp_recibo;
  CLOSE cg_a2990700_imp_poliza;
  --
  IF l_imp_recibo <= 0
   THEN
     --
     g_cod_mensaje := 20003003;
     --
     pp_devuelve_error;
     --
  END IF;
  --
  l_imp_recibo := 0;
  --
  OPEN  cg_a2990700_imp_recibo( g_reg.cod_cia    ,
                                g_reg.num_poliza ,
                                g_reg.num_apli   ,
                                g_reg.num_recibo );
  FETCH cg_a2990700_imp_recibo INTO l_imp_recibo;
  CLOSE cg_a2990700_imp_recibo;
  --
  IF l_imp_recibo <= 0
   THEN
     --
     g_cod_mensaje := 20003004;
     --
     pp_devuelve_error;
     --
     /* ----------- Control de recibos negativos -------------
     || OPEN        cg_a2990700_otros( g_reg.cod_cia    ,
     ||                                g_reg.num_poliza ,
     ||                                g_reg.num_apli   );
     || FETCH       cg_a2990700_otros INTO l_imp_recibo;
     || l_existe := cg_a2990700_otros%FOUND;
     || CLOSE       cg_a2990700_otros;
     || --
     || IF NOT l_existe
     ||  THEN
     ||   --
     ||   g_cod_mensaje := 20003004;
     ||   --
     ||   pp_devuelve_error;
     ||   --
     || END IF;
     */ ------------------------------------------------------
     --
  END IF;
  --
  --@mx('F','pp_comprueba_importes');
  --
 END pp_comprueba_importes;
 --
 /* -------------------------------------------------------
 || pp_spto_cv_ca :
 ||
 || Comprueba si existen suplementos de cambio de forma de
 || pago o cambio de agente
 */ -------------------------------------------------------
 --
 PROCEDURE pp_spto_cv_ca IS
  --
  l_existe   BOOLEAN                 := FALSE;
  --
 BEGIN
  --
  --@mx('I','pp_spto_cv_ca ');
  --
  IF g_reg.num_apli = 0
   THEN
     --
     OPEN        cg_a2000030_cv_ca( g_reg.cod_cia    ,
                                    g_reg.num_poliza ,
                                    g_reg.num_spto   );
     FETCH       cg_a2000030_cv_ca INTO g_tip_spto;
     l_existe := cg_a2000030_cv_ca%FOUND;
     CLOSE       cg_a2000030_cv_ca;
     --
   ELSE
     --
     OPEN        cg_a2000030_cv_ca_t( g_reg.cod_cia       ,
                                      g_reg.num_poliza    ,
                                      g_reg.num_spto      ,
                                      g_reg.num_apli      ,
                                      g_reg.num_spto_apli );
     FETCH       cg_a2000030_cv_ca_t INTO g_tip_spto;
     l_existe := cg_a2000030_cv_ca_t%FOUND;
     CLOSE       cg_a2000030_cv_ca_t;
     --
  END IF;
  --
  IF l_existe
   THEN
     --
     g_cod_mensaje := 20003012;
     --
     pp_devuelve_error;
     --
  END IF;
  --
  --@mx('F','pp_spto_cv_ca ');
  --
 END pp_spto_cv_ca;
 --
 /* -------------------------------------------------------
 || pp_recibos_posteriores_ct :
 ||
 || Comprueba si existen recibos posteriores cobrados
 */ -------------------------------------------------------
 --
 PROCEDURE pp_recibos_posteriores_ct IS
  --
  l_imp_recibo a2990700.imp_recibo %TYPE;
  l_existe_ct  BOOLEAN                    := FALSE;
  --
 BEGIN
  --
  --@mx('I','pp_recibos_posteriores_ct ');
  --
  IF g_reg.num_apli = 0
   THEN
     --
     OPEN  cg_a2990700_ct( g_reg.cod_cia                 ,
                           g_reg.num_poliza              ,
                           g_reg.num_spto                ,
                           g_reg.mca_anulacion_por_deuda ,
                           g_reg_recibo.fec_efec_recibo  );
     --
     FETCH cg_a2990700_ct INTO l_imp_recibo;
     --
     WHILE     NOT l_existe_ct
           AND     cg_a2990700_ct%FOUND
      LOOP
        --
        IF l_imp_recibo != 0
         THEN
           --
           l_existe_ct := TRUE;
           --
         ELSE
           --
           FETCH cg_a2990700_ct INTO l_imp_recibo;
           --
        END IF;
        --
     END LOOP;
     --
     CLOSE cg_a2990700_ct;
     --
   ELSE
     --
     OPEN  cg_a2990700_ct_t( g_reg.cod_cia                 ,
                             g_reg.num_poliza              ,
                             g_reg.num_spto                ,
                             g_reg.num_apli                ,
                             g_reg.num_spto_apli           ,
                             g_reg.mca_anulacion_por_deuda ,
                             g_reg_recibo.fec_efec_recibo  );
     --
     FETCH cg_a2990700_ct_t INTO l_imp_recibo;
     --
     WHILE     NOT l_existe_ct
           AND     cg_a2990700_ct_t%FOUND
      LOOP
        --
        IF l_imp_recibo != 0
         THEN
           --
           l_existe_ct := TRUE;
           --
         ELSE
           --
           FETCH cg_a2990700_ct_t INTO l_imp_recibo;
           --
        END IF;
        --
     END LOOP;
     --
     CLOSE cg_a2990700_ct_t;
     --
  END IF;
  --
  IF l_existe_ct
   THEN
     --
     g_cod_mensaje := 20003014;
     --
     pp_devuelve_error;
     --
  END IF;
  --
  --@mx('F','pp_recibos_posteriores_ct ');
  --
 END pp_recibos_posteriores_ct;
 --
 /* -------------------------------------------------------
 || pp_comprueba_condicion_recibo :
 ||
 || Comprueba si se puede anular la poliza o suplemento
 */ -------------------------------------------------------
 --
 PROCEDURE pp_comprueba_condicion_recibo IS
  --
  l_fecha_anulacion a2000500.fec_tratamiento %TYPE;
  --
 BEGIN
  --
  --@mx('I','pp_comprueba_condicion_recibo ');
  --
  OPEN  cg_a2990700( g_reg.cod_cia       ,
                     g_reg.num_poliza    ,
                     g_reg.num_spto      ,
                     g_reg.num_apli      ,
                     g_reg.num_spto_apli ,
                     g_reg.num_recibo    );
  FETCH cg_a2990700 INTO g_reg_recibo;
  CLOSE cg_a2990700;
  --
  IF g_reg_recibo.tip_situacion = 'CT'
   THEN
    --
    g_cod_mensaje := 20003008;
    --
    pp_devuelve_error;
    --
   ELSIF     NOT g_trata_recibos_ep
         AND     g_reg_recibo.tip_situacion != 'RE'
       THEN
        --
        g_cod_mensaje := 20003013;
        --
        pp_devuelve_error;
        --
  END IF;
  --
  l_fecha_anulacion := fp_determina_fecha_anulacion;
  --
  IF l_fecha_anulacion IS NULL
   THEN
    --
    g_cod_mensaje := 20003005;
    --
    pp_devuelve_error;
    --
   ELSIF l_fecha_anulacion > g_fec_tratamiento
       THEN
        --
        g_cod_mensaje := 20003005;
        --
        pp_devuelve_error;
        --
  END IF;
  --
  pp_comprueba_importes;
  --
  pp_recibos_posteriores_ct;
  --
  --@mx('F','pp_comprueba_condicion_recibo ');
  --
 END pp_comprueba_condicion_recibo;
 --
 /* -------------------------------------------------------
 || pp_comprueba_condicion_anul :
 ||
 || Comprueba si se puede anular la poliza o suplemento
 */ -------------------------------------------------------
 --
 PROCEDURE pp_comprueba_condicion_anul IS
 BEGIN
  --
  --@mx('I','pp_comprueba_condicion_anul ');
  --
  IF     g_reg_em_k_a2000030.mca_spto_anulado = 'S'
     AND g_reg_em_k_a2000030.tip_spto        != 'RE'
   THEN
    --
    g_cod_mensaje := 20279;
    --
    pp_devuelve_error;
    --
  END IF;
  --
  IF g_tip_mvto_batch = g_k_anulacion_batch
   THEN
    --
    pp_comprueba_condicion_recibo;
    --
  END IF;
  --
  pp_spto_cv_ca;
  --
  --@mx('F','pp_comprueba_condicion_anul ');
  --
 END pp_comprueba_condicion_anul;
 --
 /* -------------------------------------------------------
 || fp_hay_posteriores :
 ||
 || Lee suplementos posteriores al que provoca la anulacion
 */ -------------------------------------------------------
 --
 FUNCTION fp_hay_posteriores
        ( p_num_spto_max      a2000030.num_spto      %TYPE ,
          p_num_spto_apli_max a2000030.num_spto_apli %TYPE )
   RETURN BOOLEAN IS
  --
  l_existe BOOLEAN := FALSE;
  --
 BEGIN
  --
  --@mx('I','fp_hay_posteriores');
  --
  IF g_reg.num_apli = 0
   THEN
     --
     OPEN        cg_a2000030( g_reg.cod_cia    ,
                              g_reg.num_poliza ,
                              g_reg.num_spto   ,
                              p_num_spto_max   );
     FETCH       cg_a2000030 INTO g_reg_30;
     l_existe := cg_a2000030%FOUND;
     CLOSE       cg_a2000030;
     --
   ELSE
     --
     OPEN        cg_a2000030_t( g_reg.cod_cia       ,
                                g_reg.num_poliza    ,
                                g_reg.num_spto      ,
                                g_reg.num_apli      ,
                                g_reg.num_spto_apli ,
                                p_num_spto_apli_max );
     FETCH       cg_a2000030_t INTO g_reg_30;
     l_existe := cg_a2000030_t%FOUND;
     CLOSE       cg_a2000030_t;
     --
  END IF;
  --
  --@mx('F','fp_hay_posteriores');
  --
  RETURN l_existe;
  --
 END fp_hay_posteriores;
 --
 /* -------------------------------------------------------
 || pp_trata_sptos_posteriores :
 ||
 || Comprueba si existen suplementos posteriores y los anu-
 || la
 */ -------------------------------------------------------
 --
 PROCEDURE pp_trata_sptos_posteriores IS
  --
  l_num_spto      a2000030.num_spto      %TYPE;
  l_num_spto_apli a2000030.num_spto_apli %TYPE;
  --
  l_cod_spto      a2000030.cod_spto      %TYPE;
  l_sub_cod_spto  a2000030.sub_cod_spto  %TYPE;
  l_cod_tip_spto  a2000030.cod_tip_spto  %TYPE;
  --
 BEGIN
  --
  --@mx('I','pp_trata_sptos_posteriores ');
  --
  l_num_spto      := 99999;
  l_num_spto_apli := 99999;
  --
  WHILE fp_hay_posteriores( l_num_spto      ,
                            l_num_spto_apli )
   LOOP
    --
    l_num_spto      := g_reg_30.num_spto;
    l_num_spto_apli := g_reg_30.num_spto_apli;
    --
    IF    g_reg_30.fec_efec_spto                  > g_reg.fec_efec_spto
       OR (     g_reg_em_k_a2000030.tip_spto NOT IN ('RF','XX','RE')
            AND g_reg.num_spto                   != 0
          )
     THEN
      --
      IF g_reg_30.tip_spto = 'AT'
       THEN
        --
        l_cod_spto       := g_cod_spto_re;
        l_sub_cod_spto   := g_sub_cod_spto_re;
        l_cod_tip_spto   := g_cod_tip_spto_re;
        --
       ELSIF g_reg_30.mca_spto_tmp = 'N'
           THEN
            --
            l_cod_spto     := g_cod_spto_as;
            l_sub_cod_spto := g_sub_cod_spto_as;
            l_cod_tip_spto := g_cod_tip_spto_as;
            --
       ELSIF g_reg_30.tip_spto IN ('SD','SP','SA','RG')
           THEN
            --
            l_cod_spto     := g_cod_spto_aa;
            l_sub_cod_spto := g_sub_cod_spto_aa;
            l_cod_tip_spto := g_cod_tip_spto_aa;
            --
           ELSE
            --
            l_cod_spto     := g_cod_spto_tmp;
            l_sub_cod_spto := g_sub_cod_spto_tmp;
            l_cod_tip_spto := g_cod_tip_spto_tmp;
            --
      END IF;
      --
      IF     l_cod_spto     IS NOT NULL
         AND l_sub_cod_spto IS NOT NULL
       THEN
        --
        /* --------------------------------------------------
        || Se asigna el g_k_spto_batch porque la emision debe
        || tratar la anulacion como un suplemento
        */ --------------------------------------------------
        --
        pp_asigna_globales_proceso( g_k_spto_batch           ,
                                    g_reg_30.fec_efec_spto   ,
                                    g_reg.hora_desde         ,
                                    g_reg_30.fec_vcto_spto   ,
                                    l_cod_spto               ,
                                    l_sub_cod_spto           ,
                                    l_cod_tip_spto           ,
                                    g_reg.cod_negocio        ,
                                    g_reg.num_spto_anulado   );
        --
        pp_emite;
        --
       ELSE
        --
        g_cod_mensaje := 80006;
        --
        pp_devuelve_error;
        --
      END IF;
      --
    END IF;
    --
  END LOOP;
  --
  --@mx('F','pp_trata_sptos_posteriores ');
  --
 END pp_trata_sptos_posteriores;
 --
 /* -------------------------------------------------------
 || pp_trata_anulacion :
 ||
 || Trata el proceso de anulacion por falta de pago
 */ -------------------------------------------------------
 --
 PROCEDURE pp_trata_anulacion IS
  --
  CURSOR cl_a2991800
  IS
         SELECT cod_spto    ,
                sub_cod_spto
           FROM a2991800
          WHERE cod_cia  = g_cod_cia
            AND tip_spto = g_reg.tip_spto_accion;
  --
  CURSOR cl_g2990300
  IS
     SELECT cod_tip_spto
       FROM g2990300
      WHERE cod_cia  = g_cod_cia
        AND cod_ramo = g_reg.cod_ramo
        AND tip_spto = g_reg.tip_spto_accion
        AND mca_inh  = trn.NO;
  --
  l_cod_spto      a2000030.cod_spto      %TYPE;
  l_sub_cod_spto  a2000030.sub_cod_spto  %TYPE;
  l_cod_tip_spto  a2000030.cod_tip_spto  %TYPE;
  --
  l_tip_spto_fondo  a2991800.tip_spto_fondo %TYPE; --
  --
 BEGIN
  --
  --@mx('I','pp_trata_anulacion');
  --
  em_k_a2000030.p_lee(g_reg.cod_cia       ,
                      g_reg.num_poliza    ,
                      g_reg.num_spto      ,
                      g_reg.num_apli      ,
                      g_reg.num_spto_apli );
  --
  g_reg_em_k_a2000030 := em_k_a2000030.f_devuelve_reg;
  --
  pp_comprueba_condicion_anul;
  --
  pp_rec_max_spto_vigente;
  --
  IF NVL(g_reg.tip_spto_accion,'XX') NOT IN ('AN','RS')
   THEN
    -- Si Spto a Anular es "Aportacion pactada"(spto tmp) SOLO se anula ese spto (no posteriores)
    l_tip_spto_fondo := trn.NULO;
    --
    IF g_reg_em_k_a2000030.cod_spto IS NOT NULL
       AND g_reg_em_k_a2000030.sub_cod_spto IS NOT NULL THEN
    --
    em_k_a2991800.p_lee(p_cod_cia         => g_reg_em_k_a2000030.cod_cia,
                        p_cod_spto        => g_reg_em_k_a2000030.cod_spto,
                        p_sub_cod_spto    => g_reg_em_k_a2000030.sub_cod_spto,
                        p_tip_ambito_spto => trn.NULO);
                        --
    l_tip_spto_fondo := em_k_a2991800.f_tip_spto_fondo;
    --
    END IF;
    --
    IF (NVL(l_tip_spto_fondo, 'XX') NOT IN (em.TIPO_SPTO_FONDO_APORT_PACTADA) )
       THEN
       --
       pp_trata_sptos_posteriores;
       --
       IF    g_reg_em_k_a2000030.tip_spto      IN ('RF','XX','RE')
          OR g_reg.num_spto                     = 0
          OR g_reg.mca_anulacion_por_deuda      = 'N'
        THEN
         --
         l_cod_spto     := g_reg.cod_spto;
         l_sub_cod_spto := g_reg.sub_cod_spto;
         l_cod_tip_spto := g_reg.cod_tip_spto;
         --
        ELSE
         --
         l_cod_spto     := g_cod_spto_as;
         l_sub_cod_spto := g_sub_cod_spto_as;
         l_cod_tip_spto := g_cod_tip_spto_as;
         --
       END IF;
    ELSE
      --
          l_cod_spto     := g_reg.cod_spto;
          l_sub_cod_spto := g_reg.sub_cod_spto;
          l_cod_tip_spto := g_reg.cod_tip_spto;
      --
    END IF;
    --
   ELSE
    --
    OPEN  cl_a2991800;
    FETCH cl_a2991800 INTO l_cod_spto    ,
                           l_sub_cod_spto;
    CLOSE cl_a2991800;
    --
    OPEN  cl_g2990300;
    FETCH cl_g2990300 INTO l_cod_tip_spto;
    CLOSE cl_g2990300;
    --
  END IF;
  --
  /* --------------------------------------------------
  || Se asigna el g_k_spto_batch porque la emision debe
  || tratar la anulacion como un suplemento
  */ --------------------------------------------------
  --
  pp_asigna_globales_proceso( g_k_spto_batch                 ,
                              g_reg.fec_efec_spto            ,
                              g_reg_em_k_a2000030.hora_desde ,
                              g_reg.fec_vcto_spto            ,
                              l_cod_spto                     ,
                              l_sub_cod_spto                 ,
                              l_cod_tip_spto                 ,
                              g_reg_em_k_a2000030.cod_negocio,
                              g_reg_em_k_a2000030.num_spto_anulado);
  --
  pp_emite;
  --
  --@mx('F','pp_trata_anulacion');
  --
 END pp_trata_anulacion;
 --
 /* -------------------------------------------------------
 || pp_comp_renovacion :
 ||
 || Comprueba que la poliza no haya sido renovada
 */ -------------------------------------------------------
 --
 PROCEDURE pp_comp_renovacion IS
  --
  l_max_spto_rf a2000030.num_spto %TYPE;
  --
 BEGIN
  --
  --@mx('I','pp_comp_renovacion');
  --
  l_max_spto_rf := em_f_max_spto_emision_rf(g_cod_cia       ,
                                            g_reg.num_poliza);
  --
  IF l_max_spto_rf > NVL(g_reg.num_spto,l_max_spto_rf)
   THEN
    --
    g_cod_mensaje := 20003020;
    --
    pp_devuelve_error;
    --
  END IF;
  --
  --@mx('F','pp_comp_renovacion');
  --
 END pp_comp_renovacion;
 --
 /* -------------------------------------------------------
 || pp_llama_proceso :
 ||
 || Llama al proceso que se encarga de tratar el movimiento
 */ -------------------------------------------------------
 --
 PROCEDURE pp_llama_proceso
 IS
 --
    l_tip_mvto_batch a2000500.tip_mvto_batch %TYPE;
 --
 BEGIN
    --
    --@mx('I','pp_llama_proceso');
    --
    pp_comprueba_usuario;
    --
    l_tip_mvto_batch := g_tip_mvto_batch;
    --
    IF fp_otros_batch
    THEN
       --
       l_tip_mvto_batch := g_k_anulacion_batch;
       --
       IF g_tip_mvto_batch = g_k_anul_aport_pactada
       THEN
          --
          trn_k_global.asigna('tip_mvto_batch_origen', g_tip_mvto_batch);
          --
       END IF;
       --
    ELSIF g_tip_mvto_batch = g_k_spto_apli_batch
    THEN
       --
       l_tip_mvto_batch := g_k_spto_batch;
       --
    ELSIF g_tip_mvto_batch = g_k_presup_batch
    THEN
       --
       l_tip_mvto_batch := g_k_carga_batch;
       --
       trn_k_global.asigna('es_ppto_batch', g_k_si);
       --
    ELSIF g_tip_mvto_batch = g_k_aportaciones_pactadas
    THEN
       --
       l_tip_mvto_batch := g_k_spto_batch;
       --
       trn_k_global.asigna('tip_mvto_batch_origen', g_tip_mvto_batch);
       --
    ELSIF g_tip_mvto_batch = g_k_regularizacion_vida
    THEN
       --
       l_tip_mvto_batch := g_k_spto_batch;
       --
       trn_k_global.asigna('tip_mvto_batch_origen', g_tip_mvto_batch);
       --
    ELSIF g_tip_mvto_batch = g_k_suspension_plan_aport
    THEN
       --
       l_tip_mvto_batch := g_k_spto_batch;
       --
       trn_k_global.asigna('tip_mvto_batch_origen', g_tip_mvto_batch);
       --
    END IF;
    --
    IF     l_tip_mvto_batch      IN ( g_k_spto_batch      ,
                                      g_k_anulacion_batch )
       AND NVL(g_reg.num_apli,0) != trn.CERO
    THEN
       --
       g_num_apli       := g_reg.num_apli;
       --
    ELSIF l_tip_mvto_batch IN (g_k_autoriza_ppto_batch, g_k_autoriza_pre_rf_batch)
    THEN
       --
       l_tip_mvto_batch := g_k_autoriza_pol_batch;
       --
    END IF;
    --
    IF l_tip_mvto_batch = g_k_anulacion_batch
    THEN
       --
       pp_trata_anulacion;
       --
    ELSE
       --
       pp_asigna_globales_proceso( l_tip_mvto_batch      ,
                                   g_reg.fec_efec_spto   ,
                                   g_reg.hora_desde      ,
                                   g_reg.fec_vcto_spto   ,
                                   g_reg.cod_spto        ,
                                   g_reg.sub_cod_spto    ,
                                   g_reg.cod_tip_spto    ,
                                   g_reg.cod_negocio     ,
                                   g_reg.num_spto_anulado);
       --
       IF     l_tip_mvto_batch           = g_k_rf_batch
          AND g_reg.mca_pre_renovacion   = trn.SI
       THEN
          --
          pp_traspasa_pre_renovacion;
          --
       ELSIF l_tip_mvto_batch = g_k_autoriza_pol_batch
       THEN
          --
          pp_autoriza;
          --
       ELSE
          --
          IF l_tip_mvto_batch = g_k_rf_batch
          THEN
             --
             pp_comp_renovacion;
             --
          END IF;
          --
          pp_emite;
          --
          IF l_tip_mvto_batch = g_k_pre_rf_batch
          THEN
             --
             g_mca_pre_renovacion := trn.SI;
             --
          END IF;
          --
       END IF;
       --
    END IF;
    --
    --@mx('F','pp_llama_proceso');
    --
 EXCEPTION
    --
    WHEN OTHERS
    THEN
       --
       g_txt_mensaje := SUBSTR(SQLERRM,1,200);
       g_tip_situ    := g_k_tratada_con_error;
       --
       --@mx('F','EXCEPTION - pp_llama_proceso');
       --
 END pp_llama_proceso;
 --
 /* -------------------------------------------------------
 || pp_comp_mca_pre_renovacion :
 ||
 || Actualiza la mca_pre_renovacion dependiendo de si exis-
 || te algun suplemento posterior a la pre-renovacion
 */ -------------------------------------------------------
 --
 PROCEDURE pp_comp_mca_pre_renovacion IS
  --
  l_num_spto   a2000030.num_spto %TYPE;
  l_num_spto_r a2000030.num_spto %TYPE;
  --
 BEGIN
  --
  --@mx('I','pp_comp_mca_pre_renovacion ');
  --
  l_num_spto             := em_f_max_spto_1( g_cod_cia        ,
                                             g_reg.num_poliza ) + 1;
  --
  em_k_r2000030.p_lee_pol( g_cod_cia        ,
                           g_reg.num_poliza );
  --
  l_num_spto_r := em_k_r2000030.f_num_spto;
  --
  IF l_num_spto_r != l_num_spto
   THEN
    --
    pp_borra_pre_renovacion;
    --
   ELSE
    --
    g_num_spto      := em_k_r2000030.f_num_spto;
    g_num_apli      := em_k_r2000030.f_num_apli;
    g_num_spto_apli := em_k_r2000030.f_num_spto_apli;
    --
  END IF;
  --
  --@mx('F','pp_comp_mca_pre_renovacion ');
  --
 END pp_comp_mca_pre_renovacion;
 --
 /* -------------------------------------------------------
 || pp_cierra_cursor :
 ||
 || Cierra el cursor variable
 */ -------------------------------------------------------
 --
 PROCEDURE pp_cierra_cursor IS
 BEGIN
  --
  --@mx('I','pp_cierra_cursor');
  --
  IF DBMS_SQL.IS_OPEN(g_cursor)
   THEN
    --
    DBMS_SQL.CLOSE_CURSOR(g_cursor);
    --
  END IF;
  --
  --@mx('F','pp_cierra_cursor');
  --
 END pp_cierra_cursor;
 --
 /* -------------------------------------------------------
 || pp_graba :
 ||
 || Graba la informacion
 */ -------------------------------------------------------
  --
 PROCEDURE pp_graba IS
 BEGIN
  --
  COMMIT;
  --
 END pp_graba;
 --
 /* -------------------------------------------------------
 || pp_borra_errores :
 ||
 || Borra los registros de la poliza de la tabla de errores
 */ -------------------------------------------------------
 --
 PROCEDURE pp_borra_errores IS
 BEGIN
  --
  --@mx('I','pp_borra_errores ');
  --
  em_k_a2000520.p_borra_poliza(g_fec_tratamiento ,
                               g_num_orden       ,
                               g_tip_mvto_batch  ,
                               g_reg.cod_cia     ,
                               g_reg.num_poliza  );
  --
  --@mx('F','pp_borra_errores ');
  --
 END pp_borra_errores;
 --
 /* -------------------------------------------------------
 || pp_graba_error :
 ||
 || Graba la tabla de errores
 */ -------------------------------------------------------
 --
 PROCEDURE pp_graba_error IS
  --
  l_reg_a2000520 a2000520%ROWTYPE;
  --
 BEGIN
  --
  --@mx('I','pp_graba_error');
  --
  l_reg_a2000520.fec_tratamiento := g_fec_tratamiento;
  l_reg_a2000520.num_orden       := g_num_orden      ;
  l_reg_a2000520.tip_mvto_batch  := g_tip_mvto_batch ;
  l_reg_a2000520.cod_cia         := g_reg.cod_cia    ;
  l_reg_a2000520.num_poliza      := g_reg.num_poliza ;
  l_reg_a2000520.num_riesgo      := g_num_riesgo     ;
  l_reg_a2000520.num_secu        := g_k_num_secu     ;
  l_reg_a2000520.txt_error       := g_txt_mensaje    ;
  l_reg_a2000520.txt_ruta_error  := NULL             ;
  --
  em_k_a2000520.p_inserta_registro(l_reg_a2000520);
  --
  --@mx('F','pp_graba_error');
  --
 END pp_graba_error;
 --
 /* -------------------------------------------------------
 || pp_trata_errores_no_aborta :
 ||
 || Recupera todos los errores que han podido generarse en
 || la poliza
 */ -------------------------------------------------------
 --
 PROCEDURE pp_trata_errores_no_aborta IS
 BEGIN
  --
  --@mx('I','pp_trata_errores_no_aborta');
  --
  IF em_k_a2000520.f_hay_errores
   THEN
    --
    g_max_spto_vigente      := NULL;
    g_num_poliza_definitivo := NULL;
    g_tip_situ              := g_k_tratada_con_error;
    --
    em_k_a2000520.p_vuelca_errores( g_fec_tratamiento ,
                                    g_num_orden       ,
                                    g_tip_mvto_batch  ,
                                    g_reg.cod_cia     ,
                                    g_reg.num_poliza  );
    --
  END IF;
  --
  --@mx('F','pp_trata_errores_no_aborta');
  --
 END pp_trata_errores_no_aborta;
 --
 /* -------------------------------------------------------
 || pp_trata_errores :
 ||
 || Comprueba si existen errores
 */ -------------------------------------------------------
 --
 PROCEDURE pp_trata_errores
 IS
 --
 BEGIN
    --
    --@mx('I','pp_trata_errores');
    --
    IF NVL(g_txt_poliza_definitiva,'X') = '*'
    THEN
       --
       g_txt_mensaje := em_k_ap200120.f_txt_no_autoriza;
       --
    END IF;
    --
    IF g_txt_mensaje IS NOT NULL
    THEN
       --
       g_num_poliza_definitivo := trn.NULO;
       g_max_spto_vigente      := trn.NULO;
       --
       pp_graba_error;
       pp_trata_errores_no_aborta;
       --
    ELSIF g_tip_situ = '*'
    THEN
       --
       /* ------------------------------------------------------------
       || La situacion es '*' cuando la poliza no ha podido tratarse
       || por el proceso de control tecnico porque se ha rechazado por
       || las validaciones de los parametros
       || Se resta 1 al contador para que no la tenga en cuenta
       */ ------------------------------------------------------------
       --
       g_num_poliza_definitivo := NULL;
       g_contador              := g_contador -1;
       --
    ELSE
       --
       pp_trata_errores_no_aborta;
       --
    END IF;
    --
    --@mx('F','pp_trata_errores');
    --
 END pp_trata_errores;
 --
 /* -------------------------------------------------------
 || pp_act_tabla_maestra :
 ||
 || Actualiza la tabla maestra
 */ -------------------------------------------------------
 --
 PROCEDURE pp_act_tabla_maestra
 IS
 --
 BEGIN
    --
    --@mx('I','pp_act_tabla_maestra');
    --
    IF     g_tip_mvto_batch           IN ( g_k_autoriza_pol_batch  ,
                                           g_k_autoriza_ppto_batch )
       AND g_tip_situ                 != g_k_tratada_con_error
       AND g_reg.tip_autoriza_ct      IN ( g_k_rechaza  ,
                                           g_k_suspende )
    THEN
       --
       /* ---------------------------------------------------
       || Si se ha rechazado el movimiento de la poliza, se
       || actualizan todos los registros de ese movimiento en
       || la tabla de control para que no los vuelva a tomar
       */ ---------------------------------------------------
       --
       UPDATE a2000500
          SET tip_situ              = g_tip_situ         ,
              fec_actu              = TRUNC(SYSDATE)
        WHERE fec_tratamiento       = g_fec_tratamiento
          AND num_orden             = g_num_orden
          AND tip_mvto_batch        = g_tip_mvto_batch
          AND cod_cia               = g_reg.cod_cia
          AND num_poliza            = g_reg.num_poliza
          AND num_spto              = g_reg.num_spto
          AND num_apli              = g_reg.num_apli
          AND num_spto_apli         = g_reg.num_spto_apli;
       --
    ELSE
       --
       IF     g_tip_situ        != g_k_tratada_con_error
          AND g_mca_provisional  = trn.SI
       THEN
          --
          g_tip_situ := g_k_retenida;
          --
       END IF;
       /* ---------------------------------------------------
       || Este IF se hace para que actualice los campos si es
       || una prerenovacion y no se presento ningun error
       */ ---------------------------------------------------
       --
       IF g_tip_mvto_batch = g_k_autoriza_pre_rf_batch
       THEN
          --
          IF  g_reg.tip_autoriza_ct != g_k_rechaza
          THEN
             --
             UPDATE a2000500
                SET tip_mvto_batch        = g_tip_mvto_batch        ,
                    tip_situ              = g_tip_situ              ,
                    num_poliza_definitivo = g_num_poliza_definitivo ,
                    mca_pre_renovacion    = g_mca_pre_renovacion    ,
                    cod_excepcion         = g_cod_excepcion         ,
                    nom_excepcion         = g_nom_excepcion         ,
                    fec_actu              = TRUNC(SYSDATE)          ,
                    max_spto_vigente      = g_max_spto_vigente
              WHERE ROWID                 = CHARTOROWID(g_reg.clave);
             --
          END IF;
          --
       ELSE
          --
          UPDATE a2000500
             SET tip_mvto_batch        = g_tip_mvto_batch        ,
                 tip_situ              = g_tip_situ              ,
                 num_poliza_definitivo = g_num_poliza_definitivo ,
                 mca_pre_renovacion    = g_mca_pre_renovacion    ,
                 cod_excepcion         = g_cod_excepcion         ,
                 nom_excepcion         = g_nom_excepcion         ,
                 fec_actu              = TRUNC(SYSDATE)          ,
                 max_spto_vigente      = g_max_spto_vigente
           WHERE ROWID                 = CHARTOROWID(g_reg.clave);
          --
       END IF;
       --
    END IF;
    --
    pp_graba;
    --
    --@mx('F','pp_act_tabla_maestra');
    --
 END pp_act_tabla_maestra;
 --
 /* -------------------------------------------------------
 || pp_trata_excepcion :
 ||
 || Actualiza los datos de excepcion si la poliza ha sido
 || excepcionada por el procedimiento
 */ -------------------------------------------------------
 --
 PROCEDURE pp_trata_excepcion IS
 BEGIN
  --
  --@mx('I','pp_trata_excepcion');
  --
  g_tip_situ      := g_k_excepcion;
  g_cod_excepcion := fp_devuelve_n('cod_excepcion');
  --
  IF g_cod_excepcion IS NULL
   THEN
    --
    g_cod_excepcion := g_cod_excepcion_defecto;
    g_nom_excepcion := g_nom_excepcion_defecto;
    --
   ELSE
    --
    em_k_g2000590.p_lee(g_cod_cia      ,
                        g_cod_excepcion);
    --
    g_nom_excepcion := em_k_g2000590.f_nom_excepcion;
    --
  END IF;
  --
  IF g_reg.mca_pre_renovacion = 'S'
   THEN
    --
    pp_borra_pre_renovacion;
    --
  END IF;
  --
  pp_act_tabla_maestra;
  --
  --@mx('F','pp_trata_excepcion');
  --
 END pp_trata_excepcion;
 --
 /* -------------------------------------------------------
 || pp_actualiza_tip_situ :
 ||
 || Actualiza la situacion de las polizas que se han queda-
 || do con situacion provisional (polizas con error y poli-
 || zas no tratadas por la autorizacion/rechazo de control
 || tecnico)
 || --
 || Las polizas que no han sido tratadas porque no han en-
 || trado por las validaciones que hace el em_k_ap200120 se
 || marcan provisionalmente con el campo tip_situ = '*' y
 || hay que actualizarlas a 1 (no tratadas)
 || Las polizas con error se marcan provisionalemente con
 || tip_situ = '0' y hay que actualizarlas a 4 (con error)
 || --
 || No se dejan con el tip_situ definitivo porque las vol-
 || veria a tomar el proceso
 || --
 || Si tiene las trazas activadas, actuliza el cod_usr
 || de la tabla g2000510 para que desaparezca el identifi-
 || cador de la sesion utilizado en las trazas.
 */ -------------------------------------------------------
 --
 PROCEDURE pp_actualiza_tip_situ IS
 BEGIN
  --
  --@mx(g_cod_usr_g2000510,'pp_actualiza_tip_situ g_cod_usr '||g_cod_usr);
  --
  IF g_tip_mvto_batch IN ( g_k_autoriza_pol_batch  ,
                           g_k_autoriza_ppto_batch )
   THEN
    --
    UPDATE a2000500
       SET tip_situ              = g_k_no_tratada
     WHERE fec_tratamiento       = g_fec_tratamiento
       AND num_orden             = g_num_orden
       AND tip_mvto_batch        = g_tip_mvto_batch
       AND tip_situ              = '*';
    --
  END IF;
  --
  UPDATE a2000500
     SET tip_situ              = g_k_con_error
   WHERE fec_tratamiento       = g_fec_tratamiento
     AND num_orden             = g_num_orden
     AND tip_mvto_batch        = g_tip_mvto_batch
     AND tip_situ              = g_k_tratada_con_error;
  --
  IF g_trazas_activas AND g_mca_multihilo = 'S'
  THEN
    --
    g_cod_usr_g2000510 := trn_k_global.cod_usr;
    --
  END IF;
  --
  pp_actualiza_filtro (g_k_ya_tratado,
                       g_cod_usr_g2000510);
  --
  pp_graba;
  --
  --@mx('F','pp_actualiza_tip_situ');
  --
 END pp_actualiza_tip_situ;
 --
 /* -------------------------------------------------------
 || fp_forma_select :
 ||
 || Forma la sentencia SELECT del cursor variable
 || --
 || Carga el g_select_fin para las sentencia de control
 || de registros ' en proceso '.
 */ -------------------------------------------------------
 --
 FUNCTION fp_forma_select
   RETURN VARCHAR2 IS
  --
  l_select VARCHAR2(2000);
  --
 BEGIN
  --
  --@mx('I','pp_forma_select');
  --
  l_select := 'SELECT ROWIDTOCHAR(ROWID)'       ||' , '||
                      'cod_cia'                 ||' , '||
                      'cod_sector'              ||' , '||
                      'cod_ramo'                ||' , '||
                      'num_poliza_grupo'        ||' , '||
                      'num_contrato'            ||' , '||
                      'num_subcontrato'         ||' , '||
                      'num_poliza_cliente'      ||' , '||
                      'num_poliza'              ||' , '||
                      'num_poliza_tronador'     ||' , '||
                      'num_spto'                ||' , '||
                      'num_apli'                ||' , '||
                      'num_spto_apli'           ||' , '||
                      'tip_poliza_tr'           ||' , '||
                      'fec_efec_spto'           ||' , '||
                      'hora_desde'              ||' , '||
                      'fec_vcto_spto'           ||' , '||
                      'num_recibo'              ||' , '||
                      'mca_prima_manual'        ||' , '||
                      'cod_spto'                ||' , '||
                      'sub_cod_spto'            ||' , '||
                      'cod_tip_spto'            ||' , '||
                      'txt_motivo_spto'         ||' , '||
                      'mca_renueva'             ||' , '||
                      'mca_renueva_tmp'         ||' , '||
                      'mca_periodicidad'        ||' , '||
                      'cant_renovaciones'       ||' , '||
                      'mca_prorrata'            ||' , '||
                      'mca_devuelve_todo'       ||' , '||
                      'tip_spto_accion'         ||' , '||
                      'mca_pre_renovacion'      ||' , '||
                      'cod_usr_captura'         ||' , '||
                      'tip_autoriza_ct'         ||' , '||
                      'mca_anulacion_por_deuda' ||' , '||
                      'cod_negocio'             ||' , '||
                      'num_spto_anulado'        ||' , '||
                      'idn_val';
  --
  --@mx('F','pp_forma_select');
  --
  RETURN l_select;
  --
 END fp_forma_select;
 --
 /* -------------------------------------------------------
 || fp_forma_from :
 ||
 || Forma la sentencia FROM del cursor variable
 ||
 || Carga el g_from_fin para las sentencia de control
 || de registros ' en proceso '.
 */ -------------------------------------------------------
 --
 FUNCTION fp_forma_from
   RETURN VARCHAR2 IS
  --
  l_from VARCHAR2(2000);
  --
 BEGIN
  --
  l_from := ' FROM a2000500';
  --
  RETURN l_from;
  --
 END fp_forma_from;
 --
 /* -------------------------------------------------------
 || pp_forma_where_fin :
 ||
 || Carga el g_where_fin para las sentencia de control
 || de registros ' en proceso '.
 */ -------------------------------------------------------
 --
 PROCEDURE pp_forma_where_fin ( p_where VARCHAR2 )
 IS
 BEGIN
  --
  --@mx('I','pp_forma_where_fin');
  --
  g_fila_c_fin := g_fila_c;
  --
  g_tb_condicion_fin := g_tb_condicion;
  --
  g_where_fin := p_where;
  --
  g_where_fin := g_where_fin ||' AND tip_situ       = :tip_situ3';
  --
  g_fila_c_fin := g_fila_c_fin + 1;
  --
  g_tb_condicion_fin(g_fila_c_fin).cod_campo := 'tip_situ3';
  g_tb_condicion_fin(g_fila_c_fin).val_campo := g_k_en_proceso;
  --
  --@mx('I','pp_forma_where_fin');
  --
 END pp_forma_where_fin;
 --
 /* -------------------------------------------------------
 || pp_rellena_tb_condicion :
 ||
 || Rellena tabla PL con los valores que se necesitan para
 || la condicion del cursor variable
 */ -------------------------------------------------------
 --
 PROCEDURE pp_rellena_tb_condicion
         ( p_cod_campo VARCHAR2 ,
           p_val_campo VARCHAR2 ) IS
 BEGIN
  --
  --@mx('I','pp_rellena_tb_condicion');
  --
  g_fila_c := g_fila_c + 1;
  --
  g_tb_condicion(g_fila_c).cod_campo := p_cod_campo;
  g_tb_condicion(g_fila_c).val_campo := p_val_campo;
  --
  --@mx('F','pp_rellena_tb_condicion');
  --
 END pp_rellena_tb_condicion;
 --
 /* -------------------------------------------------------
 || fp_forma_where :
 ||
 || Forma la sentencia WHERE del cursor variable
 ||
 || Modifica la creacion del Where para que el control del
 || tip_situ se incluya despues de la llamada al
 || pp_forma_where_fin utilizado en la sentencia de control
 || de registros ' en proceso '.
 */ -------------------------------------------------------
 --
 FUNCTION fp_forma_where
   RETURN VARCHAR2 IS
  --
  l_where VARCHAR2(2000);
  --
 BEGIN
  --
  --@mx('I','fp_forma_where');
  --
  g_fila_c     := 0;
  --
  l_where     := ' WHERE fec_tratamiento = TO_DATE(:fec_tratamiento,'||g_k_comilla
                                                  ||'DDMMYYYY'       ||g_k_comilla
                                                  ||')';
  --
  pp_rellena_tb_condicion( 'fec_tratamiento'                    ,
                           TO_CHAR(g_fec_tratamiento,'DDMMYYYY'));
  --
  l_where     := l_where ||' AND num_orden = :num_orden';
  --
  pp_rellena_tb_condicion( 'num_orden' ,
                           g_num_orden );
  --
  --
  l_where       := l_where ||' AND cod_cia          = :cod_cia';
  --
  pp_rellena_tb_condicion( 'cod_cia' ,
                           g_cod_cia );
  --
  IF g_cod_sector IS NOT NULL
   THEN
     --
     l_where    := l_where ||' AND cod_sector       = :cod_sector';
     --
     pp_rellena_tb_condicion( 'cod_sector' ,
                              g_cod_sector );
     --
  END IF;
  --
  IF g_cod_ramo IS NOT NULL
   THEN
     --
     l_where    := l_where ||' AND cod_ramo         = :cod_ramo';
     --
     pp_rellena_tb_condicion( 'cod_ramo' ,
                              g_cod_ramo );
     --
  END IF;
  --
  IF g_cod_nivel1 IS NOT NULL
   THEN
     --
     l_where    := l_where ||' AND cod_nivel1       = :cod_nivel1';
     --
     pp_rellena_tb_condicion( 'cod_nivel1' ,
                              g_cod_nivel1 );
     --
  END IF;
  --
  IF g_cod_nivel2 IS NOT NULL
   THEN
     --
     l_where    := l_where ||' AND cod_nivel2       = :cod_nivel2';
     --
     pp_rellena_tb_condicion( 'cod_nivel2' ,
                              g_cod_nivel2 );
     --
  END IF;
  --
  IF g_cod_nivel3 IS NOT NULL
   THEN
     --
     l_where    := l_where ||' AND cod_nivel3       = :cod_nivel3';
     --
     pp_rellena_tb_condicion( 'cod_nivel3' ,
                              g_cod_nivel3 );
     --
  END IF;
  --
  IF g_cod_agt IS NOT NULL
   THEN
     --
     l_where    := l_where ||' AND cod_agt          = :cod_agt';
     --
     pp_rellena_tb_condicion( 'cod_agt' ,
                              g_cod_agt );
     --
  END IF;
  --
  IF NVL(g_mca_grupos,'X') = 'N'
   THEN
     --
     l_where    := l_where ||' AND num_poliza_grupo IS NULL';
     --
   ELSIF NVL(g_mca_grupos,'X') = 'S'
       THEN
        --
        IF g_num_poliza_grupo IS NOT NULL
         THEN
           --
           l_where := l_where ||' AND num_poliza_grupo = :num_poliza_grupo';
           --
           pp_rellena_tb_condicion( 'num_poliza_grupo' ,
                                    g_num_poliza_grupo );
           --
         ELSE
           --
           l_where    := l_where ||' AND num_poliza_grupo IS NOT NULL';
           --
        END IF;
        --
  END IF;
  --
  IF g_num_poliza_cliente IS NOT NULL
   THEN
     --
     l_where    := l_where ||' AND num_poliza_cliente  = :num_poliza_cliente';
     --
     pp_rellena_tb_condicion( 'num_poliza_cliente' ,
                              g_num_poliza_cliente );
     --
  END IF;
  --
  IF g_num_poliza IS NOT NULL
   THEN
     --
     l_where    := l_where ||' AND num_poliza          = :num_poliza';
     --
     pp_rellena_tb_condicion( 'num_poliza' ,
                              g_num_poliza );
     --
  END IF;
  --
  IF g_max_num_riesgos IS NOT NULL
   THEN
     --
     l_where    := l_where ||' AND num_riesgos        <= :max_num_riesgos';
     --
     pp_rellena_tb_condicion( 'max_num_riesgos' ,
                              g_max_num_riesgos );
     --
  END IF;
  --
  IF     g_cod_spto     IS NOT NULL
     AND g_sub_cod_spto IS NOT NULL
   THEN
     --
     l_where    := l_where ||' AND cod_spto            = :cod_spto';
     --
     pp_rellena_tb_condicion( 'cod_spto' ,
                              g_cod_spto );
     --
     l_where    := l_where ||' AND sub_cod_spto        = :sub_cod_spto';
     --
     pp_rellena_tb_condicion( 'sub_cod_spto' ,
                              g_sub_cod_spto );
     --
  END IF;
  --
  IF g_tip_mvto_batch  IN ( g_k_autoriza_pol_batch  ,
                            g_k_autoriza_ppto_batch )
   THEN
     --
     IF g_tip_autoriza_ct IS NOT NULL
      THEN
        --
        l_where    := l_where ||' AND tip_autoriza_ct     = :tip_autoriza_ct';
        --
        pp_rellena_tb_condicion( 'tip_autoriza_ct' ,
                                 g_tip_autoriza_ct );
        --
      ELSE
        --
        l_where    := l_where ||' AND tip_autoriza_ct IS NOT NULL';
        --
     END IF;
     --
  END IF;
  --
  -- crea el where de comprobacion de polizas en proceso
  --
  IF g_mca_multihilo = 'S'
  THEN
    pp_forma_where_fin (l_where);
  END IF;
  --
  --@mx('g_tip_mvto_batch-->', g_tip_mvto_batch);
  --@mx('g_mca_reproceso-->', g_mca_reproceso);
  --
  IF g_tip_mvto_batch = g_k_rf_batch
   THEN
    --
    IF g_mca_reproceso = 'S'
     THEN
      --
      l_where    := l_where
                         ||' AND (    (     tip_mvto_batch  = :tip_mvto_batch1'
                         ||'            AND tip_situ       IN (:tip_situ1,:tip_situ2)'
                         ||'          )'
                         ||'       OR (     tip_mvto_batch  = :tip_mvto_batch2'
                         ||'            AND tip_situ   NOT IN (:tip_situ3,:tip_situ5)'
                      -- ||'            AND tip_situ       != :tip_situ3'
                         ||'          )'
                         ||'     )';
      --
      pp_rellena_tb_condicion( 'tip_situ2'       ,
                               g_k_con_error     );
      --
     ELSE
      --
      l_where    := l_where
                         ||' AND (    (     tip_mvto_batch  = :tip_mvto_batch1'
                         ||'            AND tip_situ        = :tip_situ1'
                         ||'          )'
                         ||'       OR (     tip_mvto_batch  = :tip_mvto_batch2'
                         ||'            AND tip_situ   NOT IN (:tip_situ3,:tip_situ5)'
                      -- ||'            AND tip_situ       != :tip_situ3'
                         ||'          )'
                         ||'     )';
      --
    END IF;
    --
    pp_rellena_tb_condicion( 'tip_mvto_batch1' ,
                             g_k_rf_batch      );
    --
    pp_rellena_tb_condicion( 'tip_mvto_batch2' ,
                             g_k_pre_rf_batch  );
    --
    pp_rellena_tb_condicion( 'tip_situ1'       ,
                             g_k_no_tratada    );
    --
    pp_rellena_tb_condicion( 'tip_situ3'       ,
                             g_k_en_proceso    );
    --
    pp_rellena_tb_condicion( 'tip_situ5'       ,
                             g_k_excepcion     );
    --
   ELSIF     g_tip_mvto_batch = g_k_pre_rf_batch
         AND g_mca_reproceso  = 'S'
       THEN
        --
        l_where    := l_where
                         ||' AND tip_mvto_batch      IN (:tip_mvto_batch1,:tip_mvto_batch2)'
                         ||' AND tip_situ            IN (:tip_situ1      ,:tip_situ2      )';
        --
        pp_rellena_tb_condicion( 'tip_mvto_batch1' ,
                                 g_k_rf_batch      );
        --
        pp_rellena_tb_condicion( 'tip_mvto_batch2' ,
                                 g_k_pre_rf_batch  );
        --
        pp_rellena_tb_condicion( 'tip_situ1'       ,
                                 g_k_no_tratada    );
        --
        pp_rellena_tb_condicion( 'tip_situ2'       ,
                                 g_k_con_error     );
        --
       ELSE
        --
        l_where    := l_where ||' AND tip_mvto_batch = :tip_mvto_batch';
        --
        IF g_tip_mvto_batch = g_k_pre_rf_batch
         THEN
          --
          pp_rellena_tb_condicion( 'tip_mvto_batch'  ,
                                   g_k_rf_batch      );
          --
         ELSE
          --
          pp_rellena_tb_condicion( 'tip_mvto_batch'  ,
                                   g_tip_mvto_batch  );
          --
        END IF;
        --
        IF g_mca_reproceso = 'S'
         THEN
          --
          l_where    := l_where ||' AND tip_situ      IN (:tip_situ1,:tip_situ2)';
          --
          pp_rellena_tb_condicion( 'tip_situ1'        ,
                                    g_k_no_tratada    );
          --
          pp_rellena_tb_condicion( 'tip_situ2'        ,
                                    g_k_con_error     );
          --
         ELSE
          --
          l_where    := l_where ||' AND tip_situ       = :tip_situ';
          --
          pp_rellena_tb_condicion( 'tip_situ'         ,
                                    g_k_no_tratada    );
          --
        END IF;
        --
  END IF;
  --
  --@mx('F','fp_forma_where');
  --
  RETURN l_where;
  --
 END fp_forma_where;
 --
 /* -------------------------------------------------------
 || fp_rownum :
 ||
 || Incluye el rownum = 1 para permitir la ejecucion
 || simultanea.
 */ -------------------------------------------------------
 --
 FUNCTION fp_rownum
   RETURN VARCHAR2 IS
  --
  l_rownum VARCHAR2(50);
  --
 BEGIN
  --
  --@mx('I','fp_rownum');
  --
  l_rownum    := ' AND ROWNUM = 1';
  --
  --@mx('F','fp_rownum');
  --
  RETURN l_rownum;
  --
 END fp_rownum;
 --
 /* -------------------------------------------------------
 || fp_forma_bloqueo :
 ||
 || Forma la sentencia para bloquear el registro en el
 || proceso multihilo
 */ -------------------------------------------------------
 --
 FUNCTION fp_forma_bloqueo
   RETURN VARCHAR2 IS
  --
  l_bloqueo VARCHAR2(2000);
  --
 BEGIN
  --
  --@mx('I','fp_forma_bloqueo');
  --
  l_bloqueo        := ' FOR UPDATE OF tip_situ NOWAIT';
  --
  --@mx('F','fp_forma_bloqueo');
  --
  RETURN l_bloqueo;
  --
 END fp_forma_bloqueo;
 --
 /* -------------------------------------------------------
 || pp_forma_cursor :
 ||
 || Forma el select del cursor variable dependiendo de los
 || parametros.
 ||
 || Monohilo :
 || Desaparece el bloqueo ya que lo gestiona a traves de
 || la g2000510.
 ||
 || Multihilo:
 || Se incluye el rownum en la sentencia.
 || Carga el g_select_fin para las sentencia de control
 || de registros ' en proceso '.
 */ -------------------------------------------------------
 --
 PROCEDURE pp_forma_cursor IS
 BEGIN
  --
  --@mx('I','pp_forma_cursor');
  --
  g_select        := NULL;
  --
  g_tb_condicion.DELETE;
  --
  IF g_mca_multihilo = 'N'
  THEN
    g_select        := fp_forma_select  ||
                       fp_forma_from    ||
                       fp_forma_where   ;
                       -- || fp_forma_bloqueo;
  ELSE
    --
    g_select        := fp_forma_select  ||
                       fp_forma_from    ||
                       fp_forma_where   ||
                       fp_rownum        || -- accede por rownum = 1 para obtener y bloquear un solo registro
                       fp_forma_bloqueo;
    --
    g_select_fin    := 'SELECT ROWIDTOCHAR(ROWID)' ||
                       ' FROM a2000500'            ||
                       g_where_fin                 || -- tip_situ = 2 ( en proceso )
                       ' AND ROWNUM = 1'            ;
  END IF;
  --
  --@mx(' ',substr(g_select,001,50));
  --@mx(' ',substr(g_select,051,50));
  --@mx(' ',substr(g_select,101,50));
  --@mx(' ',substr(g_select,151,50));
  --@mx(' ',substr(g_select,201,50));
  --@mx(' ',substr(g_select,251,50));
  --@mx(' ',substr(g_select,301,50));
  --@mx(' ',substr(g_select,351,50));
  --@mx(' ',substr(g_select,401,50));
  --@mx(' ',substr(g_select,451,50));
  --@mx(' ',substr(g_select,501,50));
  --@mx(' ',substr(g_select,551,50));
  --@mx(' ',substr(g_select,601,50));
  --@mx(' ',substr(g_select,651,50));
  --@mx(' ',substr(g_select,701,50));
  --@mx(' ',substr(g_select,751,50));
  --@mx(' ',substr(g_select,801,50));
  --@mx(' ',substr(g_select,851,50));
  --@mx(' ',substr(g_select,901,50));
  --@mx(' ',substr(g_select,951,50));
  --
  --@mx('F','pp_forma_cursor');
  --
 END pp_forma_cursor;
 --
 /* -------------------------------------------------------
 || pp_inicializa_where_fin :
 ||
 || Rellena las variables utilizadas en el where de polizas
 || en tratamiento con los datos de la tabla PL
 */ -------------------------------------------------------
 --
 PROCEDURE pp_inicializa_where_fin IS
 BEGIN
  --
  --@mx('I','pp_inicializa_where_fin');
  --
  FOR l_fila_c_fin IN 1..NVL(g_tb_condicion_fin.LAST,0)
  LOOP
    --
    DBMS_SQL.BIND_VARIABLE(g_cursor, g_tb_condicion_fin(l_fila_c_fin).cod_campo
                                   , g_tb_condicion_fin(l_fila_c_fin).val_campo );
    --
  END LOOP;
  --
  --@mx('F','pp_inicializa_where_fin');
  --
 END pp_inicializa_where_fin;
 /* -------------------------------------------------------
 || pp_inicializa_where :
 ||
 || Rellena las variables utilizadas en el where con los
 || datos de la tabla PL
 */ -------------------------------------------------------
 --
 PROCEDURE pp_inicializa_where IS
 BEGIN
  --
  --@mx('I','pp_inicializa_where');
  --
  FOR l_fila_c IN 1..NVL(g_tb_condicion.LAST,0)
  LOOP
    --
    DBMS_SQL.BIND_VARIABLE(g_cursor, g_tb_condicion(l_fila_c).cod_campo
                                   , g_tb_condicion(l_fila_c).val_campo );
    --
  END LOOP;
  --
  --@mx('F','pp_inicializa_where');
  --
 END pp_inicializa_where;
 --
 /* -------------------------------------------------------
 || pp_rec_datos_cursor :
 ||
 || Recupera los datos que selecciona el cursor
 */ -------------------------------------------------------
 --
 PROCEDURE pp_rec_datos_cursor IS
 BEGIN
  --
  --@mx('I','pp_rec_datos_cursor');
  --
  DBMS_SQL.COLUMN_VALUE(g_cursor, 1,g_reg.clave                  );
  DBMS_SQL.COLUMN_VALUE(g_cursor, 2,g_reg.cod_cia                );
  DBMS_SQL.COLUMN_VALUE(g_cursor, 3,g_reg.cod_sector             );
  DBMS_SQL.COLUMN_VALUE(g_cursor, 4,g_reg.cod_ramo               );
  DBMS_SQL.COLUMN_VALUE(g_cursor, 5,g_reg.num_poliza_grupo       );
  DBMS_SQL.COLUMN_VALUE(g_cursor, 6,g_reg.num_contrato           );
  DBMS_SQL.COLUMN_VALUE(g_cursor, 7,g_reg.num_subcontrato        );
  DBMS_SQL.COLUMN_VALUE(g_cursor, 8,g_reg.num_poliza_cliente     );
  DBMS_SQL.COLUMN_VALUE(g_cursor, 9,g_reg.num_poliza             );
  DBMS_SQL.COLUMN_VALUE(g_cursor,10,g_reg.num_poliza_tronador    );
  DBMS_SQL.COLUMN_VALUE(g_cursor,11,g_reg.num_spto               );
  DBMS_SQL.COLUMN_VALUE(g_cursor,12,g_reg.num_apli               );
  DBMS_SQL.COLUMN_VALUE(g_cursor,13,g_reg.num_spto_apli          );
  DBMS_SQL.COLUMN_VALUE(g_cursor,14,g_reg.tip_poliza_tr          );
  DBMS_SQL.COLUMN_VALUE(g_cursor,15,g_reg.fec_efec_spto          );
  DBMS_SQL.COLUMN_VALUE(g_cursor,16,g_reg.hora_desde             );
  DBMS_SQL.COLUMN_VALUE(g_cursor,17,g_reg.fec_vcto_spto          );
  DBMS_SQL.COLUMN_VALUE(g_cursor,18,g_reg.num_recibo             );
  DBMS_SQL.COLUMN_VALUE(g_cursor,19,g_reg.mca_prima_manual       );
  DBMS_SQL.COLUMN_VALUE(g_cursor,20,g_reg.cod_spto               );
  DBMS_SQL.COLUMN_VALUE(g_cursor,21,g_reg.sub_cod_spto           );
  DBMS_SQL.COLUMN_VALUE(g_cursor,22,g_reg.cod_tip_spto           );
  DBMS_SQL.COLUMN_VALUE(g_cursor,23,g_reg.txt_motivo_spto        );
  DBMS_SQL.COLUMN_VALUE(g_cursor,24,g_reg.mca_renueva            );
  DBMS_SQL.COLUMN_VALUE(g_cursor,25,g_reg.mca_renueva_tmp        );
  DBMS_SQL.COLUMN_VALUE(g_cursor,26,g_reg.mca_periodicidad       );
  DBMS_SQL.COLUMN_VALUE(g_cursor,27,g_reg.cant_renovaciones      );
  DBMS_SQL.COLUMN_VALUE(g_cursor,28,g_reg.mca_prorrata           );
  DBMS_SQL.COLUMN_VALUE(g_cursor,29,g_reg.mca_devuelve_todo      );
  DBMS_SQL.COLUMN_VALUE(g_cursor,30,g_reg.tip_spto_accion        );
  DBMS_SQL.COLUMN_VALUE(g_cursor,31,g_reg.mca_pre_renovacion     );
  DBMS_SQL.COLUMN_VALUE(g_cursor,32,g_reg.cod_usr_captura        );
  DBMS_SQL.COLUMN_VALUE(g_cursor,33,g_reg.tip_autoriza_ct        );
  DBMS_SQL.COLUMN_VALUE(g_cursor,34,g_reg.mca_anulacion_por_deuda);
  DBMS_SQL.COLUMN_VALUE(g_cursor,35,g_reg.cod_negocio            );
  DBMS_SQL.COLUMN_VALUE(g_cursor,36,g_reg.num_spto_anulado       );
  DBMS_SQL.COLUMN_VALUE(g_cursor,37,g_reg.idn_val                );

  --
  --@mx('F','pp_rec_datos_cursor');
  --
 END pp_rec_datos_cursor;
 --
 /* -------------------------------------------------------
 || pp_abre_cursor_fin :
 ||
 || Abre el cursor variable de polizas en tratamiento
 */ -------------------------------------------------------
 PROCEDURE pp_abre_cursor_fin IS
  l_reg_clave                 VARCHAR2(18);
 BEGIN
  --
  --@mx('I','pp_abre_cursor_fin');
  --
  pp_cierra_cursor;
  --
  g_cursor := DBMS_SQL.OPEN_CURSOR;
  --
  DBMS_SQL.PARSE        (g_cursor,g_select_fin,DBMS_SQL.V7);
  --
  DBMS_SQL.DEFINE_COLUMN(g_cursor, 1,l_reg_clave                  ,
                                     g_lng_rowid                  );
  --
  pp_inicializa_where_fin;
  --
  --@mx('F','pp_abre_cursor_fin');
  --
 EXCEPTION
  WHEN OTHERS
   THEN
     --
     --@mx('F','EXCEPTION - pp_abre_cursor_fin');
     --
     pp_cierra_cursor;
     --
 END pp_abre_cursor_fin;
 /* -------------------------------------------------------
 || pp_abre_cursor :
 ||
 || Abre el cursor variable
 */ -------------------------------------------------------
 --
 PROCEDURE pp_abre_cursor IS
 BEGIN
  --
  --@mx('I','pp_abre_cursor');
  --
  pp_cierra_cursor;
  --
  g_reg    := g_reg_nulo;
  --
  g_cursor := DBMS_SQL.OPEN_CURSOR;
  --
  DBMS_SQL.PARSE        (g_cursor,g_select,DBMS_SQL.V7);
  --
  DBMS_SQL.DEFINE_COLUMN(g_cursor, 1,g_reg.clave                  ,
                                     g_lng_rowid                  );
  DBMS_SQL.DEFINE_COLUMN(g_cursor, 2,g_reg.cod_cia                );
  DBMS_SQL.DEFINE_COLUMN(g_cursor, 3,g_reg.cod_sector             );
  DBMS_SQL.DEFINE_COLUMN(g_cursor, 4,g_reg.cod_ramo               );
  DBMS_SQL.DEFINE_COLUMN(g_cursor, 5,g_reg.num_poliza_grupo       ,
                                     g_lng_num_poliza_grupo       );
  DBMS_SQL.DEFINE_COLUMN(g_cursor, 6,g_reg.num_contrato           );
  DBMS_SQL.DEFINE_COLUMN(g_cursor, 7,g_reg.num_subcontrato        );
  DBMS_SQL.DEFINE_COLUMN(g_cursor, 8,g_reg.num_poliza_cliente     ,
                                     g_lng_num_poliza_cliente     );
  DBMS_SQL.DEFINE_COLUMN(g_cursor, 9,g_reg.num_poliza             ,
                                     g_lng_num_poliza             );
  DBMS_SQL.DEFINE_COLUMN(g_cursor,10,g_reg.num_poliza_tronador    ,
                                     g_lng_num_poliza_tronador    );
  DBMS_SQL.DEFINE_COLUMN(g_cursor,11,g_reg.num_spto               );
  DBMS_SQL.DEFINE_COLUMN(g_cursor,12,g_reg.num_apli               );
  DBMS_SQL.DEFINE_COLUMN(g_cursor,13,g_reg.num_spto_apli          );
  DBMS_SQL.DEFINE_COLUMN(g_cursor,14,g_reg.tip_poliza_tr          ,
                                     g_lng_tip_poliza_tr          );
  DBMS_SQL.DEFINE_COLUMN(g_cursor,15,g_reg.fec_efec_spto          );
  DBMS_SQL.DEFINE_COLUMN(g_cursor,16,g_reg.hora_desde             ,  --
                                     g_lng_hora_desde             ); --
--  DBMS_SQL.DEFINE_COLUMN(g_cursor,16,g_reg.hora_desde             );
  DBMS_SQL.DEFINE_COLUMN(g_cursor,17,g_reg.fec_vcto_spto          );
  DBMS_SQL.DEFINE_COLUMN(g_cursor,18,g_reg.num_recibo             );
  DBMS_SQL.DEFINE_COLUMN(g_cursor,19,g_reg.mca_prima_manual       ,
                                     g_lng_mca_prima_manual       );
  DBMS_SQL.DEFINE_COLUMN(g_cursor,20,g_reg.cod_spto               );
  DBMS_SQL.DEFINE_COLUMN(g_cursor,21,g_reg.sub_cod_spto           );
  DBMS_SQL.DEFINE_COLUMN(g_cursor,22,g_reg.cod_tip_spto           ,
                                     g_lng_cod_tip_spto           );
  DBMS_SQL.DEFINE_COLUMN(g_cursor,23,g_reg.txt_motivo_spto        ,
                                     g_lng_txt_motivo_spto        );
  DBMS_SQL.DEFINE_COLUMN(g_cursor,24,g_reg.mca_renueva            ,
                                     g_lng_mca_renueva            );
  DBMS_SQL.DEFINE_COLUMN(g_cursor,25,g_reg.mca_renueva_tmp        ,
                                     g_lng_mca_renueva_tmp        );
  DBMS_SQL.DEFINE_COLUMN(g_cursor,26,g_reg.mca_periodicidad       ,
                                     g_lng_mca_periodicidad       );
  DBMS_SQL.DEFINE_COLUMN(g_cursor,27,g_reg.cant_renovaciones      );
  DBMS_SQL.DEFINE_COLUMN(g_cursor,28,g_reg.mca_prorrata           ,
                                     g_lng_mca_prorrata           );
  DBMS_SQL.DEFINE_COLUMN(g_cursor,29,g_reg.mca_devuelve_todo      ,
                                     g_lng_mca_devuelve_todo      );
  DBMS_SQL.DEFINE_COLUMN(g_cursor,30,g_reg.tip_spto_accion        ,
                                     g_lng_tip_spto_accion        );
  DBMS_SQL.DEFINE_COLUMN(g_cursor,31,g_reg.mca_pre_renovacion     ,
                                     g_lng_mca_pre_renovacion     );
  DBMS_SQL.DEFINE_COLUMN(g_cursor,32,g_reg.cod_usr_captura        ,
                                     g_lng_cod_usr_captura        );
  DBMS_SQL.DEFINE_COLUMN(g_cursor,33,g_reg.tip_autoriza_ct        ,
                                     g_lng_tip_autoriza_ct        );
  DBMS_SQL.DEFINE_COLUMN(g_cursor,34,g_reg.mca_anulacion_por_deuda,
                                     g_lng_mca_anulacion_por_deuda);
  DBMS_SQL.DEFINE_COLUMN(g_cursor,35,g_reg.cod_negocio            ,
                                     g_lng_cod_negocio            );
  DBMS_SQL.DEFINE_COLUMN(g_cursor,36,g_reg.num_spto_anulado       );
  DBMS_SQL.DEFINE_COLUMN(g_cursor,37,g_reg.idn_val                ,
                                     g_lng_idn_val                );

  --
  pp_inicializa_where;
  --
  --@mx('F','pp_abre_cursor');
  --
 EXCEPTION
  WHEN OTHERS
   THEN
     --
     --@mx('F','EXCEPTION - pp_abre_cursor');
     --
     pp_cierra_cursor;
     --
 END pp_abre_cursor;
 --
 /* -------------------------------------------------------
 || pp_execute_open
 ||
 || Ejecuta la sentencia open controlando los bloqueos.
 */ -------------------------------------------------------
  --
 PROCEDURE pp_execute_open IS
  --
  l_x_bloqueada EXCEPTION;
  PRAGMA        EXCEPTION_INIT(l_x_bloqueada,-54);
  --
 BEGIN
  --
  --@mx('I','pp_execute_open');
  --
  BEGIN
   --
   -- g_termina_cursor := TRUE;
   g_fila           := DBMS_SQL.EXECUTE(g_cursor);
   --
   /* antiguio pp_lee_cursor - el fetch pasa al pp_trata_cursor
   IF DBMS_SQL.FETCH_ROWS(g_cursor) > 0
    THEN
     --
     g_termina_cursor := FALSE;
     --
     pp_rec_datos_cursor;
     --
     --@mx(g_cod_usr_g2000510,'num_poliza'||g_reg.num_poliza );
   END IF;
   --
   */
   g_bloquea := TRUE;
   --
  EXCEPTION
   --
   WHEN l_x_bloqueada
    THEN
     --
     g_bloquea := FALSE;
     --
  END;
  --
  --@mx('F','pp_execute_open');
  --
 END pp_execute_open;
 --
 /* -------------------------------------------------------
 || pp_define_cursor :
 ||
 || Define el cursor variable
 */ -------------------------------------------------------
 --
 PROCEDURE pp_define_cursor IS
 BEGIN
  --
  --@mx('I','pp_define_cursor');
  --
  g_fila          := 0;
  --
  pp_forma_cursor;
  --
  g_reg           := g_reg_nulo;
  --
  --@mx('F','pp_define_cursor');
  --
 END pp_define_cursor;
 --
 /* -------------------------------------------------------
 || pp_trata_cursor :
 ||
 || Lee y trata los registros para el proceso batch
 */ -------------------------------------------------------
 --
 PROCEDURE pp_trata_cursor IS
 BEGIN
  --
  --@mx('I','pp_trata_cursor');
  --
  g_termina_cursor := TRUE;
  --
  IF DBMS_SQL.FETCH_ROWS(g_cursor) > 0
  THEN
    --@mx(g_cod_usr_g2000510,'num_poliza '||g_reg.num_poliza );
    --
    g_termina_cursor := FALSE;
    --
    pp_rec_datos_cursor;
    --
    g_hay_datos             := TRUE;
    --
    pp_inicializa_variables_g;
    pp_asigna_globales_inicio;
    pp_borra_errores;
    pp_act_tabla_maestra;
    --
    g_tip_situ := g_k_terminada;
    --
    IF     g_tip_mvto_batch         = g_k_rf_batch
       AND g_reg.mca_pre_renovacion = 'S'
     THEN
      --
      pp_comp_mca_pre_renovacion;
      --
    END IF;
    --
    pp_asigna('mca_pre_renovacion',g_reg.mca_pre_renovacion);
    --
    IF NOT fp_excepcion
     THEN
      --
      pp_llama_proceso;
      pp_recupera_globales;
      pp_trata_errores;
      pp_act_tabla_maestra;
      --
     ELSE
      --
      pp_trata_excepcion;
      --
    END IF;
    --
    trn_k_global.borra_todas;
    --
  END IF;
  --
  --@mx('F','pp_trata_cursor');
  --
 END pp_trata_cursor;
 --
 /* -------------------------------------------------------
 || fp_fin_proceso :
 ||
 || Comprueba si existen otros procesos ejecutandose de
 || forma simultanea para actualizar la situacion de las
 || polizas.
 */ -------------------------------------------------------
 --
 FUNCTION fp_fin_proceso
   RETURN BOOLEAN IS
  --
  l_fin_proceso BOOLEAN := TRUE;
  --
 BEGIN
  --
  --@mx(g_cod_usr_g2000510,'fp_fin_proceso ');
  --
  pp_abre_cursor_fin;
  --
  g_fila           := DBMS_SQL.EXECUTE(g_cursor);
  --
  IF DBMS_SQL.FETCH_ROWS(g_cursor) > 0
   THEN
    --@mx('*','polizas procesandose');
    l_fin_proceso:= FALSE;
  END IF;
  --
  pp_cierra_cursor;
  --
  --@mx('F','fp_fin_proceso');
  --
  RETURN l_fin_proceso;
  --
 END fp_fin_proceso;
 --
 /* -------------------------------------------------------
 || fp_bloqueo_g2000510 :
 ||
 || Bloquea la tabla maestra para el control de
 || ejecuciones simultaneas. De esta forma, la sesion que
 || bloquee la tabla se encargara de actualizar el tip_situ
 || de las polizas con situacion transitoria. Si un proceso
 || se encuentra la tabla bloqueada, significa que puede
 || terminar, ya que otro proceso se encargara de actualizar
 || las tablas.
 */ -------------------------------------------------------
 --
 FUNCTION fp_bloqueo_g2000510
   RETURN BOOLEAN
 IS
   --
   CURSOR cg_g2000510_bloqueo
      ( pc_tip_mvto_batch g2000510.tip_mvto_batch %TYPE )
     IS
        SELECT ''
          FROM g2000510
         WHERE cod_cia         = g_cod_cia
           AND fec_tratamiento = g_fec_tratamiento
           AND num_orden       = g_num_orden
           AND tip_mvto_batch  = pc_tip_mvto_batch
           FOR UPDATE NOWAIT;
   --
   l_x_bloqueada EXCEPTION;
   PRAGMA        EXCEPTION_INIT(l_x_bloqueada,-54);
   --
   l_tip_mvto_batch a2000500.tip_mvto_batch %TYPE;
   l_reg            cg_g2000510_bloqueo%ROWTYPE;
   --
   l_retorno        BOOLEAN := TRUE;
   --
 BEGIN
   --
   --@mx(g_cod_usr_g2000510,'fp_bloqueo_g2000510 ');
   --
   BEGIN
       --
       l_tip_mvto_batch := fp_tip_mvto_batch_acceso;
       --
       OPEN  cg_g2000510_bloqueo(l_tip_mvto_batch);
       FETCH cg_g2000510_bloqueo INTO l_reg;
       CLOSE cg_g2000510_bloqueo;
       --
   EXCEPTION
      WHEN l_x_bloqueada
      THEN
       l_retorno  := FALSE ;
       --@mx('*','bloqueada por otro usuario');
   END;
   --
   --@mx('F','fp_bloqueo_g2000510');
   --
   RETURN l_retorno;
   --
 END fp_bloqueo_g2000510;
 --
 /* ----------------------------------------------------
 || pp_monohilo
 ||
 || Controla el proceso cuando lo ejecuta una unica
 || sesion.
 || Bloquea de forma logica la tabla g2000510 con el
 || tip_situ_filtro = '7' ( en proceso - monohilo )
 || Realiza la select de la a2000500 una sola vez.
 || No controla la sesion que debe actualizar el tip_situ
 || ya que solo puede ser ejecutada desde una sesion.
 */ ----------------------------------------------------
 PROCEDURE pp_monohilo
 IS
 BEGIN
  --
  --@mx('I','pp_monohilo');
  --
  pp_actualiza_filtro (g_k_en_proceso_monohilo,
                       g_cod_usr_g2000510);
  --
  pp_graba;
  --
  g_contador       := 1;
  g_hay_datos      := FALSE;
  g_termina_cursor := FALSE;
  --
  pp_define_cursor;
  pp_abre_cursor;
  --
  pp_execute_open;
  --
  WHILE     NOT g_termina_cursor
        AND     g_contador       <= NVL(g_cant_registros,g_contador)
   LOOP
     --
     pp_trata_cursor;
     --
     g_contador := g_contador + 1;
     --
  END LOOP;
  --
  pp_cierra_cursor;
  --
  IF NOT g_hay_datos
  THEN
     --
     pp_actualiza_filtro (g_k_ya_tratado,
                          trn_k_global.cod_usr);
     --
     pp_graba;
     --
     g_mca_ter_tar     := 'N';
     g_cod_ter_erronea := 80001;
     --
   ELSE
     --
     pp_actualiza_tip_situ;
     --
  END IF;
  --
  --@mx('F','pp_monohilo');
  --
 END pp_monohilo;
 /* ----------------------------------------------------
 || pp_multihilo
 ||
 || Controla el proceso para que se pueda ejecutar
 || simultaneamente por varias sesiones.
 || Bloquea de forma logica la tabla g2000510 con el
 || tip_situ_filtro = '8' ( en proceso - multihilo )
 || Bloquea el registro a tratar para que no pueda ser
 || tomado por otra sesion.
 */ ----------------------------------------------------
 PROCEDURE pp_multihilo
 IS
 BEGIN
  --
  --@mx('I','pp_multihilo');
  --
  --
  pp_actualiza_filtro (g_k_en_proceso_multihilo,
                       g_cod_usr_g2000510);
  --
  pp_graba;
  --
  g_contador       := 1;
  g_hay_datos      := FALSE;
  g_termina_cursor := FALSE;
  --
  pp_define_cursor;
  pp_abre_cursor;
  --
  WHILE     NOT g_termina_cursor
        AND     g_contador       <= NVL(g_cant_registros,g_contador)
   LOOP
      --
      g_bloquea := FALSE;
      --
      WHILE NOT g_bloquea
       LOOP
        --
        pp_execute_open;
        --
      END LOOP;
      --
      pp_trata_cursor;
      --
      g_contador := g_contador + 1;
      --
  END LOOP;
  --
  pp_cierra_cursor;
  --
  IF fp_fin_proceso
  THEN
     IF fp_bloqueo_g2000510
     THEN
        pp_actualiza_tip_situ;
     END IF;
  END IF;
  --
  IF NOT g_hay_datos
    THEN
      --
      g_mca_ter_tar     := 'N';
      g_cod_ter_erronea := 80001;
      --
  END IF;
  --
  --@mx('F','pp_multihilo');
  --
 END pp_multihilo;
 /* ----------------------------------------------------
 || pp_ejecuta_filtro
 ||
 */ ----------------------------------------------------
 PROCEDURE pp_ejecuta_filtro
 IS
 BEGIN
  --
  --@mx('I','pp_ejecuta_filtro');
  --
  IF g_mca_ejecuta_filtro = trn.SI
  THEN
     --
     pp_asigna('cod_cia',g_cod_cia);
     pp_asigna('num_orden',g_num_orden);
     pp_asigna('cod_ramo',g_cod_ramo);
     --
     IF g_tip_mvto_batch = g_k_aportaciones_pactadas
     THEN
        --
        pp_asigna('cod_spto',fp_devuelve_c('JBCOD_SPTO'));
        pp_asigna('sub_cod_spto',fp_devuelve_c('JBSUB_COD_SPTO'));
        pp_asigna('txt_motivo_spto',fp_devuelve_c('JBTXT_MOTIVO_SPTO'));
        pp_asigna('cod_tip_spto',fp_devuelve_c('JBCOD_TIP_SPTO'));
        pp_asigna('cod_usr_captura',fp_devuelve_c('JBCOD_USR_CAPTURA'));
        em_k_batch_filtro.p_aportacion_pactada;
        --
     ELSIF g_tip_mvto_batch = g_k_anul_aport_pactada
     THEN
        --
        em_k_batch_filtro.p_anula_aport_pactada;
        --
     ELSIF g_tip_mvto_batch = g_k_regularizacion_vida
     THEN
        --
        pp_asigna('cod_spto',fp_devuelve_c('JBCOD_SPTO'));
        pp_asigna('sub_cod_spto',fp_devuelve_c('JBSUB_COD_SPTO'));
        pp_asigna('txt_motivo_spto',fp_devuelve_c('JBTXT_MOTIVO_SPTO'));
        pp_asigna('cod_tip_spto',fp_devuelve_c('JBCOD_TIP_SPTO'));
        pp_asigna('cod_usr_captura ',fp_devuelve_c('JBCOD_USR_CAPTURA'));
        em_k_batch_filtro.p_regulariza;
        --
     END IF;
     --
  END IF;
  --
  --@mx('F','pp_ejecuta_filtro');
  --
 END pp_ejecuta_filtro;

 /* ----------------------------------------------------
 || Aqui comienza la declaracion de subprogramas LOCALES
 */ ----------------------------------------------------
 --
 /* -------------------------------------------------------
 || p_proceso :
 ||
 || Ejecuta el proceso batch
 ||
 || Se modifica para que ejecute primero pp_datos_proceso y
 || despues llame al pp_actualiza_filtro en cada uno de
 || los procedimientos pp_monohilo y pp_multihilo. De esta
 || forma lee el cod_usr de la g2000510 y lo actuliza con el
 || identificador de la sesion en caso de tener las trazas
 || activadas. Al mismo tiempo marca la situacion del filtro
 || como 'en proceso' para gestionar los bloqueos desde
 || otras sesiones.
 ||
 || Si el proceso es monohilo, el cursor obtiene todos los
 || registros a procesar. Una vez procesadas actualiza la
 || situacion directamente sin realizar los controles de
 || sesiones del proceso multihilo.
 ||
 || Si el proceso es multihilo, abre y cierra el cursor
 || por cada registro ( rownum = 1 ) de la a2000500,
 || de esta forma se permite la ejecucion simultanea.
 || Una vez termina de procesas los registros de la
 || a2000500 comprueba si existe alguna otra ejecucion
 || simultanea. Si existe, termina. En caso contrario ac-
 || tualiza la situacion de la a2000500 y el cod_usr
 || de la g2000510 ( si tiene las trazas activas ).
 */ -------------------------------------------------------
 --
 PROCEDURE p_proceso IS
 BEGIN
  --
  --@mx('I','p_proceso');
  --
  pp_recupera_parametros;
  pp_recupera_usuario;
  --
  pp_ejecuta_filtro;
  --
  pp_datos_proceso;
  --
  pp_inicio;
  --
  IF     fp_comprueba_spto
     AND fp_comprueba_spto_as
     AND fp_comprueba_spto_tmp
     AND fp_comprueba_spto_aa
     AND fp_comprueba_spto_re
   THEN
       --
       IF fp_comprueba_tip_situ_filtro
       THEN
           IF g_mca_multihilo = 'N'
           THEN
              pp_monohilo;
           ELSE
              pp_multihilo;
           END IF;
       --
       ELSIF g_tip_mvto_batch = g_k_pre_rf_batch
         AND g_reg_g2000510.tip_mvto_batch IS NULL THEN
         --
         g_mca_ter_tar     := 'N';
         g_cod_ter_erronea := 20003083;
         --
       ELSE
           g_mca_ter_tar     := 'N';
           g_cod_ter_erronea := 20017;
       END IF;
    ELSE
    --
    g_mca_ter_tar     := 'N';
    g_cod_ter_erronea := 80006;
    --
  END IF;
  --
  trn_k_global.borra_todas;
  --
  pp_asigna('txt_tarea'      ,'');
  pp_asigna('cod_ter_erronea',TO_CHAR(g_cod_ter_erronea));
  pp_asigna('mca_ter_tar'    ,        g_mca_ter_tar);
  --
  --@mx('F','p_proceso');
  --
 END p_proceso;
 --
 /* -------------------------------------------------------
 || p_pre_jbmca_multihilo :
 ||
 || Coloca una 'N' como valor por defecto
 */ -------------------------------------------------------
 --
 PROCEDURE p_pre_jbmca_multihilo IS
 BEGIN
  --
  --@mx('I','p_pre_jbmca_multihilo');
  --
  g_mca_salto     := 'N';
  g_txt_campo     := NULL;
  g_val_campo     := 'N';
  --
  pp_devuelve_valores_pre;
  --
  --@mx('F','p_pre_jbmca_multihilo');
  --
 END p_pre_jbmca_multihilo;
 /* --------------------------------------------------------
 || p_v_jbmca_multihilo :
 ||
 || Valida el parametro jbmca_multihilo
 */ --------------------------------------------------------
 --
 PROCEDURE p_v_jbmca_multihilo IS
 BEGIN
  --
  --@mx('I','p_v_jbmca_multihilo'||fp_devuelve_c('jbmca_multihilo'));
  --
  g_mca_multihilo := fp_devuelve_c('jbmca_multihilo');
  g_txt_campo     := NULL;
  --
  pp_val_s_n('jbmca_multihilo' ,
             g_mca_multihilo );
  --
  pp_devuelve_valores_val;
  --
  --@mx('F','p_v_jbmca_multihilo');
  --
 END p_v_jbmca_multihilo;
 --
 /* -------------------------------------------------------
 || p_v_tip_mvto_batch :
 ||
 || Valida el parametro tip_mvto_batch
 */ -------------------------------------------------------
 --
 PROCEDURE p_v_tip_mvto_batch
 IS
 --
 BEGIN
    --
    --@mx('I','p_v_tip_mvto_batch');
    --
    pp_inicia_var_parametros;
    --
    g_tip_mvto_batch := fp_devuelve_c('tip_mvto_batch');
    --
    IF g_tip_mvto_batch IS NULL
    THEN
       --
       g_cod_mensaje := 20003;
       g_anx_mensaje := g_k_ini_corchete||'tip_mvto_batch'||g_k_fin_corchete;
       --
       pp_devuelve_error;
       --
    END IF;
    --
    IF    g_tip_mvto_batch IN ( g_k_rf_batch             ,
                                g_k_pre_rf_batch         ,
                                g_k_spto_batch           ,
                                g_k_spto_apli_batch      ,
                                g_k_autoriza_pol_batch   ,
                                g_k_anulacion_batch      ,
                                g_k_aportaciones_pactadas,
                                g_k_suspension_plan_aport,
                                g_k_regularizacion_vida  )
       OR fp_otros_batch
    THEN
       --
       g_tabla_df := g_k_a30;
       --
    ELSIF NVL(g_tip_mvto_batch,'x') IN ( g_k_carga_batch         ,
                                         g_k_apli_batch          ,
                                         g_k_autoriza_ppto_batch ,
                                         g_k_conv_rf_batch       )
    THEN
       --
       g_tabla_df := g_k_p30;
       --
    ELSIF NVL(g_tip_mvto_batch,'x') = g_k_autoriza_pre_rf_batch
    THEN
       --
       g_tabla_df := g_k_r30;
       --
    ELSE
       --
       g_tabla_df := 'X';
       --
    END IF;
    --
    g_txt_campo := fp_rec_nom_valor('TIP_MVTO_BATCH',
                                     g_tip_mvto_batch);
    --
    pp_devuelve_valores_val;
    --
    --@mx('F','p_v_tip_mvto_batch');
    --
 END p_v_tip_mvto_batch;
 --
 /* -------------------------------------------------------
 || p_pre_fec_tratamiento :
 ||
 || Recupera la maxima fecha de tratamiento.
 || Si es pre-renovacion se recupera la fecha de la renova-
 || cion
 */ -------------------------------------------------------
 --
 PROCEDURE p_pre_fec_tratamiento IS
  --
  l_cod_cia        a2000500.cod_cia        %TYPE;
  l_tip_mvto_batch a2000500.tip_mvto_batch %TYPE;
  --
 BEGIN
  --
  --@mx('I','p_pre_fec_tratamiento');
  --
  l_cod_cia         := trn_k_global.cod_cia;
  l_tip_mvto_batch  := g_tip_mvto_batch;
  --
  g_fec_tratamiento := NULL;
  --
  g_mca_salto       := 'N';
  g_txt_campo       := NULL;
  g_val_campo       := fp_devuelve_c('val_campo');
  --
  IF g_val_campo IS NULL
   THEN
    --
    l_tip_mvto_batch := fp_tip_mvto_batch_acceso;
    --
    OPEN        cg_g2000510_fec(l_tip_mvto_batch);
    FETCH       cg_g2000510_fec INTO g_fec_tratamiento;
    --
    IF cg_g2000510_fec%FOUND
     THEN
      --
      g_val_campo := TO_CHAR(g_fec_tratamiento,'DDMMYYYY');
      --
    END IF;
    --
    CLOSE       cg_g2000510_fec;
    --
  END IF;
  --
  pp_asigna('cod_cia'       ,l_cod_cia       );
  pp_asigna('cod_ramo'      ,'999'           );
  pp_asigna('cod_idioma'    ,g_cod_idioma    );
  pp_asigna('tip_mvto_batch',g_tip_mvto_batch);
  --
  pp_devuelve_valores_pre;
  --
  --@mx('F','p_pre_fec_tratamiento');
  --
 END p_pre_fec_tratamiento;
 --
 /* -------------------------------------------------------
 || p_pre_jbnum_orden :
 ||
 || Recupera el maximo numero de orden para el proceso y
 || fecha
 */ -------------------------------------------------------
 --
 PROCEDURE p_pre_jbnum_orden IS
  --
  l_tip_mvto_batch a2000500.tip_mvto_batch %TYPE;
  --
 BEGIN
  --
  --@mx('I','p_pre_jbnum_orden');
  --
  g_fec_tratamiento := fp_devuelve_f('fec_tratamiento');
  --
  g_mca_salto       := 'N';
  g_txt_campo       := NULL;
  g_val_campo       := fp_devuelve_c('val_campo');
  --
  IF g_val_campo IS NULL
   THEN
    --
    l_tip_mvto_batch := fp_tip_mvto_batch_acceso;
    --
    OPEN        cg_g2000510_orden(l_tip_mvto_batch);
    FETCH       cg_g2000510_orden INTO g_num_orden;
    --
    IF cg_g2000510_orden%FOUND
     THEN
      --
      g_val_campo := g_num_orden;
      --
    END IF;
    --
    CLOSE       cg_g2000510_orden;
    --
  END IF;
  --
  pp_devuelve_valores_pre;
  --
  --@mx('F','p_pre_jbnum_orden');
  --
 END p_pre_jbnum_orden;
 --
 /* -------------------------------------------------------
 || p_pre_jbnum_orden :
 ||
 || Valida el parametro jbnum_orden
 */ -------------------------------------------------------
 --
 PROCEDURE p_v_jbnum_orden IS
 BEGIN
  --
  --@mx('I','p_v_jbnum_orden');
  --
  g_num_orden := fp_devuelve_n('jbnum_orden');
  --
  --@mx('F','p_v_jbnum_orden');
  --
 END p_v_jbnum_orden;
 --
 /* -------------------------------------------------------
 || p_pre_jbcod_cia :
 ||
 || Recupera el valor de la compania del usuario
 */ -------------------------------------------------------
 --
 PROCEDURE p_pre_jbcod_cia IS
 BEGIN
  --
  --@mx('I','p_pre_jbcod_cia');
  --
  g_mca_salto       := 'N';
  g_txt_campo       := NULL;
  g_val_campo       := fp_devuelve_c('val_campo');
  --
  IF g_val_campo IS NULL
   THEN
    --
    g_val_campo     := trn_k_global.cod_cia;
    --
  END IF;
  --
  pp_devuelve_valores_pre;
  --
  --@mx('F','p_pre_jbcod_cia');
  --
 END p_pre_jbcod_cia;
 --
 /* -------------------------------------------------------
 || p_v_jbcod_cia :
 ||
 || Valida el parametro jbcod_cia
 */ -------------------------------------------------------
 --
 PROCEDURE p_v_jbcod_cia IS
 BEGIN
  --
  --@mx('I','p_v_jbcod_cia');
  --
  g_cod_cia := fp_devuelve_n('jbcod_cia');
  --
  IF g_cod_cia IS NULL
   THEN
    --
    g_cod_mensaje := 20003;
    g_anx_mensaje := g_k_ini_corchete||'cod_cia'||g_k_fin_corchete;
    --
    pp_devuelve_error;
    --
  END IF;
  --
  g_txt_campo := dc_f_nom_cia(g_cod_cia);
  --
  pp_devuelve_valores_val;
  --
  --@mx('F','p_v_jbcod_cia');
  --
 END p_v_jbcod_cia;
 --
 /* -------------------------------------------------------
 || p_v_jbnum_poliza_grupo :
 ||
 || Valida el parametro jbnum_poliza_grupo
 */ -------------------------------------------------------
 --
 PROCEDURE p_v_jbnum_poliza_grupo IS
  --
  l_nom_poliza      g2990017.nom_poliza      %TYPE;
  l_nom_cort_poliza g2990017.nom_cort_poliza %TYPE;
  l_num_contrato    a2000010.num_contrato    %TYPE;
  l_tip_poliza      a2000010.tip_poliza      %TYPE;
  l_mca_riesgos     a2000010.mca_riesgos     %TYPE;
  l_fec_vcto_poliza a2000010.fec_vcto_poliza %TYPE;
  --
 BEGIN
  --
  --@mx('I','p_v_jbnum_poliza_grupo');
  --
  g_num_poliza_grupo := fp_devuelve_c('jbnum_poliza_grupo');
  g_txt_campo        := NULL;
  --
  IF g_num_poliza_grupo IS NOT NULL
   THEN
    --
    em_p_a2000010_1(g_cod_cia          ,
                    g_num_poliza_grupo ,
                    l_nom_poliza       ,
                    l_nom_cort_poliza  ,
                    l_num_contrato     ,
                    l_tip_poliza       ,
                    l_mca_riesgos      ,
                    l_fec_vcto_poliza  );
    --
    g_txt_campo := l_nom_poliza;
    --
  END IF;
  --
  pp_devuelve_valores_val;
  --
  --@mx('F','p_v_jbnum_poliza_grupo');
  --
 END p_v_jbnum_poliza_grupo;
 --
 /* -------------------------------------------------------
 || p_v_jbnum_poliza_cliente :
 ||
 || Valida el parametro jbnum_poliza_cliente
 */ -------------------------------------------------------
 --
 PROCEDURE p_v_jbnum_poliza_cliente IS
 BEGIN
  --
  --@mx('I','p_v_jbnum_poliza_cliente');
  --
  g_num_poliza_cliente := fp_devuelve_c('jbnum_poliza_cliente');
  g_txt_campo          := NULL;
  --
  IF g_num_poliza_cliente IS NOT NULL
   THEN
    --
    g_txt_campo := em_f_nom_poliza_cliente(g_cod_cia           ,
                                           g_num_poliza_cliente);
    --
  END IF;
  --
  pp_devuelve_valores_val;
  --
  --@mx('F','p_v_jbnum_poliza_cliente');
  --
 END p_v_jbnum_poliza_cliente;
 --
 /* -------------------------------------------------------
 || p_v_jbnum_poliza :
 ||
 || Valida el parametro jbnum_poliza
 */ -------------------------------------------------------
 --
 PROCEDURE p_v_jbnum_poliza IS
 BEGIN
  --
  --@mx('I','p_v_jbnum_poliza');
  --
  g_num_poliza := fp_devuelve_c('jbnum_poliza');
  g_txt_campo  := NULL;
  --
  IF g_num_poliza IS NOT NULL
   THEN
    --
    IF g_tabla_df = g_k_a30
     THEN
      --
      g_num_spto := em_k_a2000030.f_max_spto (p_cod_cia          =>  g_cod_cia      ,
                                              p_num_poliza       =>  g_num_poliza   ,
                                              p_num_spto         =>  trn.NULO       ,
                                              p_mca_spto_tmp     =>  trn.NO         ,
                                              p_mca_spto_anulado =>  trn.NO         );
      --
      em_k_a2000030.p_lee(g_cod_cia      ,
                          g_num_poliza   ,
                          g_num_spto     ,
                          0              ,
                          0              );
      --
      g_reg_em_k_a2000030 := em_k_a2000030.f_devuelve_reg;
      --
     ELSIF g_tabla_df = g_k_p30
         THEN
          --
          em_k_p2000030.p_spto_apli_presupuesto(g_cod_cia      ,
                                                g_num_poliza   ,
                                                g_num_spto     ,
                                                g_num_apli     ,
                                                g_num_spto_apli);
          --
          em_k_p2000030.p_lee(g_cod_cia      ,
                              g_num_poliza   ,
                              g_num_spto     ,
                              g_num_apli     ,
                              g_num_spto_apli);
          --
    ELSIF g_tabla_df = g_k_r30
    THEN
       --
       em_k_r2000030.p_lee_pol(p_cod_cia    => g_cod_cia   ,
                               p_num_poliza => g_num_poliza);
       --
       g_num_spto      := em_k_r2000030.f_num_spto     ;
       g_num_apli      := em_k_r2000030.f_num_apli     ;
       g_num_spto_apli := em_k_r2000030.f_num_spto_apli;
       --
       em_k_r2000030.p_lee(p_cod_cia       => g_cod_cia      ,
                           p_num_poliza    => g_num_poliza   ,
                           p_num_spto      => g_num_spto     ,
                           p_num_apli      => g_num_apli     ,
                           p_num_spto_apli => g_num_spto_apli);
       --
    END IF;
    --
  END IF;
  --
  pp_devuelve_valores_val;
  --
  --@mx('F','p_v_jbnum_poliza');
  --
 END p_v_jbnum_poliza;
 --
 /* -------------------------------------------------------
 || p_pre_jbcod_ramo :
 ||
 || Si se ha indicado una poliza salta el dato y lo deja a
 || nulos
 */ -------------------------------------------------------
 --
 PROCEDURE p_pre_jbcod_ramo IS
 BEGIN
  --
  --@mx('I','p_pre_jbcod_ramo');
  --
  g_val_campo  := fp_devuelve_c('val_campo'   );
  g_txt_campo  := NULL;
  g_mca_salto  := 'N';
  --
  g_num_poliza := fp_devuelve_c('jbnum_poliza');
  --
  g_mca_ejecuta_filtro := fp_devuelve_c('jbmca_ejecuta_filtro');
  --
  IF g_num_poliza IS NOT NULL
     OR g_mca_ejecuta_filtro = trn.NO
   THEN
    --
    g_val_campo  := NULL;
    g_txt_campo  := NULL;
    g_mca_salto  := 'S';
    --
    g_cod_ramo   := NULL;
    g_cod_sector := NULL;
    --
  END IF;
  --
  pp_devuelve_valores_pre;
  --
  --@mx('F','p_pre_jbcod_ramo');
  --
 END p_pre_jbcod_ramo;
 --
 /* -------------------------------------------------------
 || p_v_jbcod_ramo :
 ||
 || Valida el parametro jbcod_ramo
 */ -------------------------------------------------------
 --
 PROCEDURE p_v_jbcod_ramo IS
  --
  l_cod_subsector a1001800.cod_subsector %TYPE;
  l_nom_ramo      a1001800.nom_ramo      %TYPE;
  --
 BEGIN
  --
  --@mx('I','p_v_jbcod_ramo');
  --
  g_cod_ramo   := fp_devuelve_n('jbcod_ramo'  );
  g_txt_campo  := NULL;
  --
  IF g_tip_mvto_batch in (g_k_regularizacion_vida,
                          g_k_anul_aport_pactada)
   AND  g_cod_ramo IS NULL
   THEN
    --
    g_cod_mensaje := 20003;
    g_anx_mensaje := g_k_ini_corchete||'cod_spto'||g_k_fin_corchete;
    --
    pp_devuelve_error;
    --
  END IF;
  --
  IF g_cod_ramo IS NOT NULL
   THEN
    --
    dc_p_a1001800_2( g_cod_cia       ,
                     g_cod_ramo      ,
                     l_nom_ramo      ,
                     g_cod_sector    ,
                     l_cod_subsector );
    --
    g_txt_campo := l_nom_ramo;
    --
  END IF;
  --
  pp_devuelve_valores_val;
  --
  --@mx('F','p_v_jbcod_ramo');
  --
 END p_v_jbcod_ramo;
 --
 /* -------------------------------------------------------
 || p_pre_jbcod_sector :
 ||
 || Si se ha indicado un ramo, devuelve el valor del sector
 || al que pertenece y salta el dato
 */ -------------------------------------------------------
 --
 PROCEDURE p_pre_jbcod_sector IS
 BEGIN
  --
  --@mx('I','p_pre_jbcod_sector');
  --
  g_mca_salto  := 'N';
  g_txt_campo  := NULL;
  g_val_campo  := fp_devuelve_c('val_campo'   );
  --
  g_cod_ramo   := fp_devuelve_c('jbcod_ramo'  );
  g_num_poliza := fp_devuelve_c('jbnum_poliza');
  --
  IF g_cod_ramo IS NOT NULL
   THEN
    --
    g_val_campo := g_cod_sector;
    g_mca_salto := 'S';
    --
   ELSIF g_num_poliza IS NOT NULL
       THEN
        --
        g_val_campo := NULL;
        g_mca_salto := 'S';
        --
  END IF;
  --
  pp_devuelve_valores_pre;
  --
  --@mx('F','p_pre_jbcod_sector');
  --
 END p_pre_jbcod_sector;
 --
 /* -------------------------------------------------------
 || p_v_jbcod_sector :
 ||
 || Valida el parametro jbcod_sector
 */ -------------------------------------------------------
 --
 PROCEDURE p_v_jbcod_sector IS
 BEGIN
  --
  --@mx('I','p_v_jbcod_sector');
  --
  g_cod_sector := fp_devuelve_n('jbcod_sector');
  g_txt_campo  := NULL;
  --
  IF g_cod_sector IS NOT NULL
   THEN
    --
    g_txt_campo := dc_f_nom_sector(g_cod_cia   ,
                                   g_cod_sector);
    --
  END IF;
  --
  pp_devuelve_valores_val;
  --
  --@mx('F','p_v_jbcod_sector');
  --
 END p_v_jbcod_sector;
 --
 /* -------------------------------------------------------
 || p_pre_jbcod_nivel3 :
 ||
 || Si se ha indicado una poliza salta el dato y lo deja a
 || nulos
 */ -------------------------------------------------------
 --
 PROCEDURE p_pre_jbcod_nivel3 IS
 BEGIN
  --
  --@mx('I','p_pre_jbcod_nivel3');
  --
  g_val_campo  := fp_devuelve_c('val_campo'   );
  g_txt_campo  := NULL;
  g_mca_salto  := 'N';
  --
  g_num_poliza := fp_devuelve_c('jbnum_poliza');
  --
  IF g_num_poliza IS NOT NULL
   THEN
    --
    g_val_campo  := NULL;
    g_txt_campo  := NULL;
    g_mca_salto  := 'S';
    --
    g_cod_nivel3 := NULL;
    g_cod_nivel2 := NULL;
    g_cod_nivel1 := NULL;
    --
  END IF;
  --
  pp_devuelve_valores_pre;
  --
  --@mx('F','p_pre_jbcod_nivel3');
  --
 END p_pre_jbcod_nivel3;
 --
 /* -------------------------------------------------------
 || p_v_jbcod_nivel3 :
 ||
 || Valida el parametro jbcod_nivel3
 */ -------------------------------------------------------
 --
 PROCEDURE p_v_jbcod_nivel3 IS
  --
  l_nom_nivel3 a1000702.nom_nivel3 %TYPE;
  --
 BEGIN
  --
  --@mx('I','p_v_jbcod_nivel3');
  --
  g_cod_nivel3 := fp_devuelve_n('jbcod_nivel3');
  g_txt_campo  := NULL;
  --
  IF g_cod_nivel3 IS NOT NULL
   THEN
    --
    dc_p_a1000702_2(g_cod_cia    ,
                    g_cod_nivel3 ,
                    l_nom_nivel3 ,
                    g_cod_nivel1 ,
                    g_cod_nivel2 );
    --
    g_txt_campo := l_nom_nivel3;
    --
  END IF;
  --
  pp_devuelve_valores_val;
  --
  --@mx('F','p_v_jbcod_nivel3');
  --
 END p_v_jbcod_nivel3;
 --
 /* -------------------------------------------------------
 || p_pre_jbcod_nivel2 :
 ||
 || Si se ha indicado un codigo de nivel3 devuelve el valor
 || del nivel2 al que pertenece y salta el dato
 */ -------------------------------------------------------
 --
 PROCEDURE p_pre_jbcod_nivel2 IS
 BEGIN
  --
  --@mx('I','p_pre_jbcod_nivel2');
  --
  g_mca_salto  := 'N';
  g_txt_campo  := NULL;
  g_val_campo  := fp_devuelve_c('val_campo'   );
  --
  g_cod_nivel3 := fp_devuelve_c('jbcod_nivel3');
  g_num_poliza := fp_devuelve_c('jbnum_poliza');
  --
  IF g_cod_nivel3 IS NOT NULL
   THEN
    --
    g_val_campo := g_cod_nivel2;
    g_mca_salto := 'S';
    --
   ELSIF g_num_poliza IS NOT NULL
       THEN
        --
        g_val_campo  := NULL;
        g_mca_salto  := 'S';
        --
        g_cod_nivel2 := NULL;
        --
  END IF;
  --
  pp_devuelve_valores_pre;
  --
  --@mx('F','p_pre_jbcod_nivel2');
  --
 END p_pre_jbcod_nivel2;
 --
 /* -------------------------------------------------------
 || p_v_jbcod_nivel2 :
 ||
 || Valida el parametro jbcod_nivel2
 */ -------------------------------------------------------
 --
 PROCEDURE p_v_jbcod_nivel2 IS
  --
  l_nom_nivel2 a1000701.nom_nivel2 %TYPE;
  --
 BEGIN
  --
  --@mx('I','p_v_jbcod_nivel2');
  --
  g_cod_nivel2 := fp_devuelve_n('jbcod_nivel2');
  g_txt_campo  := NULL;
  --
  IF g_cod_nivel2 IS NOT NULL
   THEN
    --
    dc_p_a1000701_2(g_cod_cia    ,
                    g_cod_nivel2 ,
                    l_nom_nivel2 ,
                    g_cod_nivel1 );
    --
    g_txt_campo := l_nom_nivel2;
    --
  END IF;
  --
  pp_devuelve_valores_val;
  --
  --@mx('F','p_v_jbcod_nivel2');
  --
 END p_v_jbcod_nivel2;
 --
 /* -------------------------------------------------------
 || p_pre_jbcod_nivel1 :
 ||
 || Si se ha indicado un codigo de nivel3 o nivel2 devuelve
 || el valor del nivel1 al que pertenecen y salta el dato
 */ -------------------------------------------------------
 --
 PROCEDURE p_pre_jbcod_nivel1 IS
 BEGIN
  --
  --@mx('I','p_pre_jbcod_nivel1');
  --
  g_mca_salto  := 'N';
  g_txt_campo  := NULL;
  g_val_campo  := fp_devuelve_c('val_campo'   );
  --
  g_cod_nivel3 := fp_devuelve_c('jbcod_nivel3');
  g_cod_nivel2 := fp_devuelve_c('jbcod_nivel2');
  g_num_poliza := fp_devuelve_c('jbnum_poliza');
  --
  IF    g_cod_nivel3 IS NOT NULL
     OR g_cod_nivel2 IS NOT NULL
   THEN
    --
    g_val_campo := g_cod_nivel1;
    g_mca_salto := 'S';
    --
   ELSIF g_num_poliza IS NOT NULL
       THEN
        --
        g_val_campo  := NULL;
        g_mca_salto  := 'S';
        --
        g_cod_nivel1 := NULL;
        --
  END IF;
  --
  pp_devuelve_valores_pre;
  --
  --@mx('F','p_pre_jbcod_nivel1');
  --
 END p_pre_jbcod_nivel1;
 --
 /* -------------------------------------------------------
 || p_v_jbcod_nivel1 :
 ||
 || Valida el parametro jbcod_nivel1
 */ -------------------------------------------------------
 --
 PROCEDURE p_v_jbcod_nivel1 IS
 BEGIN
  --
  --@mx('I','p_v_jbcod_nivel1');
  --
  g_cod_nivel1 := fp_devuelve_n('jbcod_nivel1');
  g_txt_campo  := NULL;
  --
  IF g_cod_nivel1 IS NOT NULL
   THEN
    --
    g_txt_campo := dc_f_nom_nivel1(g_cod_cia   ,
                                   g_cod_nivel1);
    --
  END IF;
  --
  pp_devuelve_valores_val;
  --
  --@mx('F','p_v_jbcod_nivel1');
  --
 END p_v_jbcod_nivel1;
 --
 /* -------------------------------------------------------
 || p_pre_jbcod_agt :
 ||
 || Si se ha indicado una poliza salta el dato y lo deja a
 || nulos
 */ -------------------------------------------------------
 --
 PROCEDURE p_pre_jbcod_agt IS
 BEGIN
  --
  --@mx('I','p_pre_jbcod_agt');
  --
  g_val_campo  := fp_devuelve_c('val_campo'   );
  g_txt_campo  := NULL;
  g_mca_salto  := 'N';
  --
  g_num_poliza := fp_devuelve_c('jbnum_poliza');
  --
  IF g_num_poliza IS NOT NULL
   THEN
    --
    g_val_campo  := NULL;
    g_txt_campo  := NULL;
    g_mca_salto  := 'S';
    --
    g_cod_agt    := NULL;
    --
  END IF;
  --
  pp_devuelve_valores_pre;
  --
  --@mx('F','p_pre_jbcod_agt');
  --
 END p_pre_jbcod_agt;
 --
 /* -------------------------------------------------------
 || p_v_jbcod_agt :
 ||
 || Valida el parametro jbcod_agt
 */ -------------------------------------------------------
 --
 PROCEDURE p_v_jbcod_agt IS
  --
  l_nom        v1001390.nom_tercero  %TYPE;
  l_ape1       v1001390.ape1_tercero %TYPE;
  l_ape2       v1001390.ape2_tercero %TYPE;
  l_tip_docum  v1001390.tip_docum    %TYPE;
  l_cod_docum  v1001390.cod_docum    %TYPE;
  l_mca_fisico v1001390.mca_fisico   %TYPE;
  --
 BEGIN
  --
  --@mx('I','p_v_jbcod_agt');
  --
  g_cod_agt   := fp_devuelve_n('jbcod_agt');
  --
  g_txt_campo := NULL;
  --
  IF g_cod_agt IS NOT NULL
   THEN
    --
    dc_p_nom_ape_tercero_1(g_cod_cia       ,
                           g_cod_agt       ,
                           2               ,
                           l_nom           ,
                           l_ape1          ,
                           l_ape2          ,
                           l_mca_fisico    ,
                           l_tip_docum     ,
                           l_cod_docum     );
    --
    g_txt_campo := SUBSTR( l_nom || ' ' || l_ape1 || ' ' || l_ape2 ,1,30);
    --
  END IF;
  --
  pp_devuelve_valores_val;
  --
  --@mx('F','p_v_jbcod_agt');
  --
 END p_v_jbcod_agt;
 --
 /* -------------------------------------------------------
 || p_pre_jbnum_riesgo :
 ||
 || Salta el parametro jbnum_riesgo si no es autorizacion
 || de control tecnico y si la poliza es nula
 */ -------------------------------------------------------
 --
 PROCEDURE p_pre_jbnum_riesgo IS
 BEGIN
  --
  --@mx('I','p_pre_jbnum_riesgo');
  --
  g_mca_salto  := 'N';
  g_txt_campo  := NULL;
  g_val_campo  := fp_devuelve_c('val_campo'   );
  --
  g_num_poliza := fp_devuelve_c('jbnum_poliza');
  --
  IF    g_tip_mvto_batch NOT IN (g_k_autoriza_pol_batch ,
                                 g_k_autoriza_ppto_batch)
     OR g_num_poliza         IS NULL
   THEN
    --
    g_val_campo := NULL;
    g_mca_salto := 'S';
    --
  END IF;
  --
  pp_devuelve_valores_pre;
  --
  --@mx('F','p_pre_jbnum_riesgo');
  --
 END p_pre_jbnum_riesgo;
 --
 /* -------------------------------------------------------
 || p_pre_jbcod_spto :
 ||
 || Salta el campo para procesos de control tecnico.
 || Inicializa las globales para la lista de valores
 */ -------------------------------------------------------
 --
 PROCEDURE p_pre_jbcod_spto IS
 BEGIN
  --
  --@mx('I','p_pre_jbcod_spto');
  --
  g_mca_salto     := 'N';
  g_txt_campo     := NULL;
  g_val_campo     := fp_devuelve_c('val_campo' );
  --
  IF g_tip_mvto_batch IN ( g_k_autoriza_pol_batch  ,
                           g_k_autoriza_ppto_batch )
   THEN
    --
    g_mca_salto   := 'S';
    g_val_campo   := NULL;
    --
  END IF;
  --
  pp_asigna('valor_lista1','');
  pp_asigna('valor_lista2','');
  --
  pp_devuelve_valores_pre;
  --
  --@mx('F','p_pre_jbcod_spto');
  --
 END p_pre_jbcod_spto;
 --
 /* -------------------------------------------------------
 || p_v_jbcod_spto :
 ||
 || Valida el parametro jbcod_spto
 */ -------------------------------------------------------
 --
 PROCEDURE p_v_jbcod_spto IS
 BEGIN
  --
  --@mx('I','p_v_jbcod_spto');
  --
  g_cod_spto     := fp_devuelve_n('jbcod_spto'  );
  g_sub_cod_spto := fp_devuelve_n('valor_lista2');
  g_txt_campo    := NULL;
  --
  IF g_tip_mvto_batch IN  (g_k_regularizacion_vida ,
                           g_k_aportaciones_pactadas,
                           g_k_suspension_plan_aport)
   AND  g_cod_spto IS NULL
   THEN
    --
    g_cod_mensaje := 20003;
    g_anx_mensaje := g_k_ini_corchete||'cod_spto'||g_k_fin_corchete;
    --
    pp_devuelve_error;
    --
  END IF;
  --
  pp_asigna('valor_lista1','');
  pp_asigna('valor_lista2','');
  --
  pp_devuelve_valores_val;
  --
  --@mx('F','p_v_jbcod_spto');
  --
 END p_v_jbcod_spto;
 --
 /* -------------------------------------------------------
 || p_pre_jbsub_cod_spto :
 ||
 || Salta el parametro jbsub_cod_spto si se ha dejado a nu-
 || los el parametro jbcod_spto
 */ -------------------------------------------------------
 --
 PROCEDURE p_pre_jbsub_cod_spto IS
 BEGIN
  --
  --@mx('I','p_pre_jbsub_cod_spto');
  --
  g_mca_salto := 'N';
  g_txt_campo := NULL;
  g_val_campo := fp_devuelve_c('val_campo' );
  --
  g_cod_spto  := fp_devuelve_n('jbcod_spto');
  --
  IF g_cod_spto IS NULL
   THEN
    --
    g_val_campo := NULL;
    g_mca_salto := 'S';
    --
   ELSIF g_sub_cod_spto IS NOT NULL
       THEN
        --
        g_val_campo := g_sub_cod_spto;
        --
  END IF;
  --
  g_sub_cod_spto := NULL;
  --
  pp_asigna('valor_lista1','');
  pp_asigna('valor_lista2','');
  --
  pp_devuelve_valores_pre;
  --
  --@mx('F','p_pre_jbsub_cod_spto');
  --
 END p_pre_jbsub_cod_spto;
 --
 /* -------------------------------------------------------
 || p_v_jbsub_cod_spto :
 ||
 || Valida los parametros jbcod_spto y jbsub_cod_spto
 */ -------------------------------------------------------
 --
 PROCEDURE p_v_jbsub_cod_spto IS
 BEGIN
  --
  --@mx('I','p_v_jbsub_cod_spto');
  --
  g_cod_spto     := fp_devuelve_n('jbcod_spto'    );
  g_sub_cod_spto := fp_devuelve_n('jbsub_cod_spto');
  g_txt_campo    := NULL;
  --
  IF g_tip_mvto_batch IN (g_k_regularizacion_vida ,
                          g_k_aportaciones_pactadas,
                          g_k_suspension_plan_aport)
  AND  g_sub_cod_spto IS NULL
  THEN
    --
    g_cod_mensaje := 20003;
    g_anx_mensaje := g_k_ini_corchete||'cod_spto'||g_k_fin_corchete;
    --
    pp_devuelve_error;
    --
  END IF;
  --
  IF     g_cod_spto     IS NOT NULL
     AND g_sub_cod_spto IS NOT NULL
   THEN
    --
    IF fp_comprueba_spto
     THEN
      --
      g_txt_campo := em_k_a2991800.f_nom_spto;
      --
     ELSE
      --
      g_cod_mensaje := 80006;
      g_anx_mensaje := NULL;
      --
      pp_devuelve_error;
      --
    END IF;
    --
  END IF;
  --
  pp_devuelve_valores_val;
  --
  --@mx('F','p_v_jbsub_cod_spto');
  --
 END p_v_jbsub_cod_spto;
 --
 /* -------------------------------------------------------
 || p_pre_jbtxt_motivo_spto:
 ||
 || Si no aplica filtro salta el dato y lo deja a
 || nulos
 */ -------------------------------------------------------
 --
 PROCEDURE p_pre_jbtxt_motivo_spto IS
 BEGIN
  --
  --@mx('I','p_pre_jb txt_motivo_spto ');
  --
  g_val_campo  := fp_devuelve_c('val_campo'   );
  g_txt_campo  := NULL;
  g_mca_salto  := 'N';
  --
  g_mca_ejecuta_filtro := fp_devuelve_c('jbmca_ejecuta_filtro');
  --
  IF g_mca_ejecuta_filtro = trn.NO
   THEN
    --
    g_val_campo  := NULL;
    g_txt_campo  := NULL;
    g_mca_salto  := 'S';
    --
    g_txt_motivo_spto := NULL;
    --
  END IF;
  --
  pp_devuelve_valores_pre;
  --
  --@mx('F','p_pre_jbtxt_motivo_spto');
  --
 END p_pre_jbtxt_motivo_spto;
 --
 /* -------------------------------------------------------
 || p_v_jbtxt_motivo_spto :
 ||
 || Valida el parametro jbtxt_motivo_spto
 */ -------------------------------------------------------
 --
 PROCEDURE p_v_jbtxt_motivo_spto IS
 BEGIN
  --
  --@mx('I','p_v_jbtxt_motivo_spto');
  --
  g_txt_motivo_spto     := fp_devuelve_c('jbtxt_motivo_spto'  );
  g_txt_campo    := NULL;
  --
  IF g_tip_mvto_batch IN (g_k_regularizacion_vida ,
                          g_k_aportaciones_pactadas,
                          g_k_suspension_plan_aport)
   AND g_txt_motivo_spto is NULL
   THEN
    --
    g_cod_mensaje := 20003;
    g_anx_mensaje := g_k_ini_corchete||'txt_motivo_spto'||g_k_fin_corchete;
    --
    pp_devuelve_error;
    --
  END IF;
  --
  pp_devuelve_valores_val;
  --
  --@mx('F','p_v_jbtxt_motivo_spto');
  --
 END p_v_jbtxt_motivo_spto;
 --
 /* -------------------------------------------------------
 || p_pre_jbcod_tip_spto:
 ||
 || Si no aplica filtro salta el dato y lo deja a
 || nulos
 */ -------------------------------------------------------
 --
 PROCEDURE p_pre_jbcod_tip_spto IS
 BEGIN
  --
  --@mx('I','p_pre_jbcod_tip_spto ');
  --
  g_val_campo  := fp_devuelve_c('val_campo'   );
  g_txt_campo  := NULL;
  g_mca_salto  := 'N';
  --
  g_mca_ejecuta_filtro := fp_devuelve_c('jbmca_ejecuta_filtro');
  --
  IF g_mca_ejecuta_filtro = trn.NO
   THEN
    --
    g_val_campo  := NULL;
    g_txt_campo  := NULL;
    g_mca_salto  := 'S';
    --
    g_cod_tip_spto := NULL;
    --
  END IF;
  --
  pp_devuelve_valores_pre;
  --
  --@mx('F','p_pre_jbcod_tip_spto');
  --
 END p_pre_jbcod_tip_spto;
 --
 /* -------------------------------------------------------
 || p_v_jbcod_tip_spto :
 ||
 || Valida el parametro jbcod_tip_spto
 */ -------------------------------------------------------
 --
 PROCEDURE p_v_jbcod_tip_spto IS
  CURSOR c_g2990300
  IS
         SELECT nom_tip_spto
           FROM g2990300
          WHERE cod_cia      = g_cod_cia
            AND cod_ramo     = NVL(g_cod_ramo,999)
            AND cod_tip_spto = g_cod_tip_spto
            AND tip_spto     = g_tip_spto;
  --
  CURSOR c_g2990300_1
  IS
         SELECT a.nom_tip_spto
           FROM g2990300 a
          WHERE a.cod_cia      = g_cod_cia
            AND a.cod_ramo     = NVL(g_cod_ramo,999)
            AND a.tip_spto     = g_tip_spto;
  --
  l_nom_tip_spto g2990300.nom_tip_spto %TYPE;
  l_existe       BOOLEAN;
  --
 BEGIN
  --
  --@mx('I','p_v_jbcod_tip_spto');
  --
  g_cod_tip_spto  := fp_devuelve_c('jbcod_tip_spto'  );
  g_txt_campo     := NULL;
  --
  IF g_tip_mvto_batch IN (g_k_regularizacion_vida ,
                          g_k_aportaciones_pactadas,
                          g_k_suspension_plan_aport)
  AND g_cod_tip_spto is NULL
  THEN
    --
    g_cod_mensaje := 20003;
    g_anx_mensaje := g_k_ini_corchete||'cod_tip_spto'||g_k_fin_corchete;
    --
    pp_devuelve_error;
    --
  END IF;
  --
  OPEN        c_g2990300;
  FETCH       c_g2990300 INTO l_nom_tip_spto;
  l_existe := c_g2990300%FOUND;
  CLOSE       c_g2990300;
  --
  IF NOT l_existe
   THEN
    --
    OPEN        c_g2990300_1;
    FETCH       c_g2990300_1 INTO l_nom_tip_spto;
    l_existe := c_g2990300_1%FOUND;
    CLOSE       c_g2990300_1;
    --
    IF l_existe
     THEN
      --
      g_cod_mensaje := 20001;
      g_anx_mensaje := NULL;
      --
      pp_devuelve_error;
      --
     ELSE
      --
      l_nom_tip_spto := NULL;
      --
    END IF;
    --
  END IF;
  --
  g_txt_campo := l_nom_tip_spto;
  --
  pp_devuelve_valores_val;
  --
  --@mx('F','p_v_jbcod_tip_spto');
  --
 END p_v_jbcod_tip_spto;
 --
/* -------------------------------------------------------
 || p_pre_jbcod_usr_captura:
 ||
 || Si no aplica filtro salta el dato y lo deja a
 || nulos
 */ -------------------------------------------------------
 --
 PROCEDURE p_pre_jbcod_usr_captura IS
 BEGIN
  --
  --@mx('I','p_pre_jbcod_usr_captura ');
  --
  g_val_campo  := fp_devuelve_c('val_campo'   );
  g_txt_campo  := NULL;
  g_mca_salto  := 'N';
  --
  g_mca_ejecuta_filtro := fp_devuelve_c('jbmca_ejecuta_filtro');
  --
  IF g_mca_ejecuta_filtro = trn.NO
   THEN
    --
    g_val_campo  := NULL;
    g_txt_campo  := NULL;
    g_mca_salto  := 'S';
    --
    g_cod_usr_captura := NULL;
    --
  END IF;
  --
  pp_devuelve_valores_pre;
  --
  --@mx('F','p_pre_jbcod_usr_captura');
  --
 END p_pre_jbcod_usr_captura;
 --
 /* --------------------------------------------------------
 || p_v_jbcod_usr_captura :
 ||
 || Valida el parametro jbcod_usr_captura
 */ --------------------------------------------------------
 --
 PROCEDURE p_v_jbcod_usr_captura IS
 BEGIN
  --
  --@mx('I','p_v_jbcod_usr_cia');
  --
  g_cod_usr_captura := fp_devuelve_c('jbcod_usr_captura');
  g_txt_campo   := NULL;
  --
  IF g_cod_usr_captura IS NOT NULL
   THEN
    --
    dc_k_g1002700.p_lee(g_cod_cia         ,
                        g_cod_usr_captura );
    --
    g_txt_campo := dc_k_g1002700.f_nom_usr_cia;
    --
  END IF;
  --
  pp_devuelve_valores_val;
  --
  --@mx('F','p_v_jbcod_usr_captura');
  --
 END p_v_jbcod_usr_captura;
 --
 /* -------------------------------------------------------
 || p_pre_jbcab :
 ||
 || Salta los parametros que son cabeceras
 ||          - jbcab_anulacion_batch
 ||          - jbsub_cab_anulacion_batch
 ||          - jbcab_autoriza_batch
 ||          - jbsub_cab_autoriza_batch
 */ -------------------------------------------------------
 --
 PROCEDURE p_pre_jbcab IS
 BEGIN
  --
  --@mx('I','p_pre_jbcab');
  --
  g_mca_salto := 'S';
  g_val_campo := NULL;
  g_txt_campo := NULL;
  --
  pp_devuelve_valores_pre;
  --
  --@mx('F','p_pre_jbcab');
  --
 END p_pre_jbcab;
 --
 /* -------------------------------------------------------
 || p_pre_jbanulacion :
 ||
 || Si el proceso es anulacion se detiene en los parametros
 || especificos de este proceso:
 ||          - jbcod_spto_as
 ||          - jbsub_cod_spto_as
 ||          - jbcod_spto_tmp
 ||          - jbsub_cod_spto_tmp
 ||          - jbcod_spto_aa
 ||          - jbsub_cod_spto_aa
 ||          - jbcod_spto_re
 ||          - jbsub_cod_spto_re
 */ -------------------------------------------------------
 --
 PROCEDURE p_pre_jbanulacion IS
 BEGIN
  --
  --@mx('I','p_pre_jbanulacion');
  --
  g_mca_salto := 'S';
  g_val_campo := fp_devuelve_c('val_campo');
  g_txt_campo := NULL;
  --
  IF    g_tip_mvto_batch = g_k_anulacion_batch
     OR fp_otros_batch
   THEN
    --
    g_mca_salto := 'N';
    --
   ELSE
    --
    g_val_campo := NULL;
    g_txt_campo := NULL;
    --
  END IF;
  --
  g_sub_cod_spto_as  := NULL;
  g_sub_cod_spto_tmp := NULL;
  g_sub_cod_spto_aa  := NULL;
  g_sub_cod_spto_re  := NULL;
  --
  pp_asigna('valor_lista1','');
  pp_asigna('valor_lista2','');
  --
  pp_devuelve_valores_pre;
  --
  --@mx('F','p_pre_jbanulacion');
  --
 END p_pre_jbanulacion;
 --
 /* -------------------------------------------------------
 || p_v_jbcod_spto_as :
 ||
 || Valida el parametro jbcod_spto_as
 */ -------------------------------------------------------
 --
 PROCEDURE p_v_jbcod_spto_as IS
 BEGIN
  --
  --@mx('I','p_v_jbcod_spto_as');
  --
  g_cod_spto_as     := fp_devuelve_n('jbcod_spto_as');
  g_sub_cod_spto_as := fp_devuelve_n('valor_lista2' );
  g_txt_campo       := NULL;
  --
  pp_asigna('valor_lista1','');
  pp_asigna('valor_lista2','');
  --
  pp_devuelve_valores_val;
  --
  --@mx('F','p_v_jbcod_spto_as');
  --
 END p_v_jbcod_spto_as;
 --
 /* -------------------------------------------------------
 || p_pre_jbsub_cod_spto_as :
 ||
 || Salta el parametro jbsub_cod_spto_as si el parametro
 || jbcod_spto_as es nulo
 */ -------------------------------------------------------
 --
 PROCEDURE p_pre_jbsub_cod_spto_as IS
 BEGIN
  --
  --@mx('I','p_pre_jbsub_cod_spto_as');
  --
  g_mca_salto   := 'N';
  g_txt_campo   := NULL;
  g_val_campo   := fp_devuelve_c('val_campo'    );
  --
  g_cod_spto_as := fp_devuelve_n('jbcod_spto_as');
  --
  IF g_cod_spto_as IS NULL
   THEN
    --
    g_val_campo := NULL;
    g_txt_campo := NULL;
    g_mca_salto := 'S';
    --
   ELSIF g_sub_cod_spto_as IS NOT NULL
       THEN
        --
        g_val_campo := g_sub_cod_spto_as;
        --
  END IF;
  --
  g_sub_cod_spto_as := NULL;
  --
  pp_asigna('valor_lista1','');
  pp_asigna('valor_lista2','');
  --
  pp_devuelve_valores_pre;
  --
  --@mx('F','p_pre_jbsub_cod_spto_as');
  --
 END p_pre_jbsub_cod_spto_as;
 --
 /* -------------------------------------------------------
 || p_v_jbsub_cod_spto_as :
 ||
 || Valida el parametro jbsub_cod_spto_as
 */ -------------------------------------------------------
 --
 PROCEDURE p_v_jbsub_cod_spto_as IS
 BEGIN
  --
  --@mx('I','p_v_jbsub_cod_spto_as');
  --
  g_cod_spto_as     := fp_devuelve_n('jbcod_spto_as'    );
  g_sub_cod_spto_as := fp_devuelve_n('jbsub_cod_spto_as');
  g_txt_campo       := NULL;
  --
  IF     g_cod_spto_as     IS NOT NULL
     AND g_sub_cod_spto_as IS NOT NULL
   THEN
    --
    IF fp_comprueba_spto_as
     THEN
      --
      g_txt_campo := em_k_a2991800.f_nom_spto;
      --
     ELSE
      --
      g_cod_mensaje := 80006;
      g_anx_mensaje := NULL;
      --
      pp_devuelve_error;
      --
    END IF;
    --
  END IF;
  --
  pp_devuelve_valores_val;
  --
  --@mx('F','p_v_jbsub_cod_spto_as');
  --
 END p_v_jbsub_cod_spto_as;
 --
 /* --------------------------------------------------------
 || p_pre_jbcod_tip_spto_as :
 ||
 || Salta el parametro jbcod_tip_spto_as si los parametros
 || jbcod_spto_as y jbsub_cod_spto_as son nulos
 */ --------------------------------------------------------
 --
 PROCEDURE p_pre_jbcod_tip_spto_as IS
 BEGIN
  --
  --@mx('I','p_pre_jbcod_tip_spto_as');
  --
  g_mca_salto       := 'N';
  g_val_campo       := fp_devuelve_c('val_campo'        );
  g_txt_campo       := NULL;
  --
  g_cod_spto_as     := fp_devuelve_n('jbcod_spto_as'    );
  g_sub_cod_spto_as := fp_devuelve_n('jbsub_cod_spto_as');
  --
  IF     g_cod_spto_as     IS NULL
     AND g_sub_cod_spto_as IS NULL
   THEN
    --
    g_val_campo := NULL;
    g_mca_salto := 'S';
    --
   ELSE
    --
    pp_asigna('tip_spto',g_tip_spto_as);
    --
  END IF;
  --
  pp_asigna('valor_lista1','');
  pp_asigna('valor_lista2','');
  --
  pp_devuelve_valores_pre;
  --
  --@mx('F','p_pre_jbcod_tip_spto_as');
  --
 END p_pre_jbcod_tip_spto_as;
 --
 /* --------------------------------------------------------
 || p_v_jbcod_tip_spto_as :
 ||
 || Valida el parametro jbcod_tip_spto_as
 */ --------------------------------------------------------
 --
 PROCEDURE p_v_jbcod_tip_spto_as IS
 BEGIN
  --
  --@mx('I','p_v_jbcod_tip_spto_as');
  --
  g_cod_tip_spto_as := fp_devuelve_c('jbcod_tip_spto_as');
  g_txt_campo       := NULL;
  --
  IF g_cod_tip_spto_as IS NULL
   THEN
    --
    g_cod_mensaje := 20003;
    g_anx_mensaje := g_k_ini_corchete||'cod_tip_spto_as'||g_k_fin_corchete;
    --
    pp_devuelve_error;
    --
  END IF;
  --
  g_txt_campo := fp_nom_tip_spto(g_cod_tip_spto_as,
                                 g_tip_spto_as    );
  --
  pp_devuelve_valores_val;
  --
  --@mx('F','p_v_jbcod_tip_spto_as');
  --
 END p_v_jbcod_tip_spto_as;
 --
 /* --------------------------------------------------------
 || p_v_jbcod_spto_tmp :
 ||
 || Valida el parametro jbcod_spto_tmp
 */ --------------------------------------------------------
 --
 PROCEDURE p_v_jbcod_spto_tmp IS
 BEGIN
  --
  --@mx('I','p_v_jbcod_spto_tmp');
  --
  g_cod_spto_tmp     := fp_devuelve_n('jbcod_spto_tmp');
  g_sub_cod_spto_tmp := fp_devuelve_n('valor_lista2'  );
  g_txt_campo        := NULL;
  --
  pp_asigna('valor_lista1','');
  pp_asigna('valor_lista2','');
  --
  pp_devuelve_valores_val;
  --
  --@mx('F','p_v_jbcod_spto_tmp');
  --
 END p_v_jbcod_spto_tmp;
 --
 /* --------------------------------------------------------
 || p_pre_jbsub_cod_spto_tmp :
 ||
 || Salta el parametro jbsub_cod_spto_tmp si el parametro
 || jbcod_spto_tmp es nulo
 */ --------------------------------------------------------
 --
 PROCEDURE p_pre_jbsub_cod_spto_tmp IS
 BEGIN
  --
  --@mx('I','p_pre_jbsub_cod_spto_tmp');
  --
  g_mca_salto    := 'N';
  g_txt_campo    := NULL;
  g_val_campo    := fp_devuelve_c('val_campo'     );
  --
  g_cod_spto_tmp := fp_devuelve_n('jbcod_spto_tmp');
  --
  IF g_cod_spto_tmp IS NULL
   THEN
    --
    g_val_campo := NULL;
    g_txt_campo := NULL;
    g_mca_salto := 'S';
    --
   ELSIF g_sub_cod_spto_tmp IS NOT NULL
       THEN
        --
        g_val_campo := g_sub_cod_spto_tmp;
        --
  END IF;
  --
  g_sub_cod_spto_tmp := NULL;
  --
  pp_asigna('valor_lista1','');
  pp_asigna('valor_lista2','');
  --
  pp_devuelve_valores_pre;
  --
  --@mx('F','p_pre_jbsub_cod_spto_tmp');
  --
 END p_pre_jbsub_cod_spto_tmp;
 --
 /* --------------------------------------------------------
 || p_v_jbsub_cod_spto_tmp :
 ||
 || Valida el parametro jbsub_cod_spto_tmp
 */ --------------------------------------------------------
 --
 PROCEDURE p_v_jbsub_cod_spto_tmp IS
 BEGIN
  --
  --@mx('I','p_v_jbsub_cod_spto_tmp');
  --
  g_cod_spto_tmp     := fp_devuelve_n('jbcod_spto_tmp'    );
  g_sub_cod_spto_tmp := fp_devuelve_n('jbsub_cod_spto_tmp');
  g_txt_campo        := NULL;
  --
  IF     g_cod_spto_tmp     IS NOT NULL
     AND g_sub_cod_spto_tmp IS NOT NULL
   THEN
    --
    IF fp_comprueba_spto_tmp
     THEN
      --
      g_txt_campo := em_k_a2991800.f_nom_spto;
      --
     ELSE
      --
      g_cod_mensaje := 80006;
      g_anx_mensaje := NULL;
      --
      pp_devuelve_error;
      --
    END IF;
    --
  END IF;
  --
  pp_devuelve_valores_val;
  --
  --@mx('F','p_v_jbsub_cod_spto_tmp');
  --
 END p_v_jbsub_cod_spto_tmp;
 --
 /* --------------------------------------------------------
 || p_pre_jbcod_tip_spto_tmp :
 ||
 || Salta el parametro jbcod_tip_spto_tmp si los parametros
 || jbcod_spto_tmp y jbsub_cod_spto_tmp son nulos
 */ --------------------------------------------------------
 --
 PROCEDURE p_pre_jbcod_tip_spto_tmp IS
 BEGIN
  --
  --@mx('I','p_pre_jbcod_tip_spto_tmp');
  --
  g_mca_salto        := 'N';
  g_val_campo        := fp_devuelve_c('val_campo'         );
  g_txt_campo        := NULL;
  --
  g_cod_spto_tmp     := fp_devuelve_n('jbcod_spto_tmp'    );
  g_sub_cod_spto_tmp := fp_devuelve_n('jbsub_cod_spto_tmp');
  --
  IF     g_cod_spto_tmp     IS NULL
     AND g_sub_cod_spto_tmp IS NULL
   THEN
    --
    g_val_campo := NULL;
    g_mca_salto := 'S';
    --
   ELSE
    --
    pp_asigna('tip_spto',g_tip_spto_tmp);
    --
  END IF;
  --
  pp_devuelve_valores_pre;
  --
  --@mx('F','p_pre_jbcod_tip_spto_tmp');
  --
 END p_pre_jbcod_tip_spto_tmp;
 --
 /* --------------------------------------------------------
 || p_v_jbcod_tip_spto_tmp :
 ||
 || Valida el parametro jbcod_tip_spto_tmp
 */ --------------------------------------------------------
 --
 PROCEDURE p_v_jbcod_tip_spto_tmp IS
 BEGIN
  --
  --@mx('I','p_v_jbcod_tip_spto_tmp');
  --
  g_cod_tip_spto_tmp := fp_devuelve_c('jbcod_tip_spto_tmp');
  g_txt_campo        := NULL;
  --
  IF g_cod_tip_spto_tmp IS NULL
   THEN
    --
    g_cod_mensaje := 20003;
    g_anx_mensaje := g_k_ini_corchete||'cod_tip_spto_tmp'||g_k_fin_corchete;
    --
    pp_devuelve_error;
    --
  END IF;
  --
  g_txt_campo := fp_nom_tip_spto(g_cod_tip_spto_tmp,
                                 g_tip_spto_tmp    );
  --
  pp_devuelve_valores_val;
  --
  --@mx('F','p_v_jbcod_tip_spto_tmp');
  --
 END p_v_jbcod_tip_spto_tmp;
 --
 /* --------------------------------------------------------
 || p_v_jbcod_spto_aa :
 ||
 || Valida el parametro jbcod_spto_aa
 */ --------------------------------------------------------
 --
 PROCEDURE p_v_jbcod_spto_aa IS
 BEGIN
  --
  --@mx('I','p_v_jbcod_spto_aa');
  --
  g_cod_spto_aa     := fp_devuelve_n('jbcod_spto_aa');
  g_sub_cod_spto_aa := fp_devuelve_n('valor_lista2'  );
  g_txt_campo        := NULL;
  --
  pp_asigna('valor_lista1','');
  pp_asigna('valor_lista2','');
  --
  pp_devuelve_valores_val;
  --
  --@mx('F','p_v_jbcod_spto_aa');
  --
 END p_v_jbcod_spto_aa;
 --
 /* --------------------------------------------------------
 || p_pre_jbsub_cod_spto_aa :
 ||
 || Salta el parametro jbsub_cod_spto_aa si el parametro
 || jbcod_spto_aa es nulo
 */ --------------------------------------------------------
 --
 PROCEDURE p_pre_jbsub_cod_spto_aa IS
 BEGIN
  --
  --@mx('I','p_pre_jbsub_cod_spto_aa');
  --
  g_mca_salto    := 'N';
  g_txt_campo    := NULL;
  g_val_campo    := fp_devuelve_c('val_campo'     );
  --
  g_cod_spto_aa := fp_devuelve_n('jbcod_spto_aa');
  --
  IF g_cod_spto_aa IS NULL
   THEN
    --
    g_val_campo := NULL;
    g_txt_campo := NULL;
    g_mca_salto := 'S';
    --
   ELSIF g_sub_cod_spto_aa IS NOT NULL
       THEN
        --
        g_val_campo := g_sub_cod_spto_aa;
        --
  END IF;
  --
  g_sub_cod_spto_aa := NULL;
  --
  pp_asigna('valor_lista1','');
  pp_asigna('valor_lista2','');
  --
  pp_devuelve_valores_pre;
  --
  --@mx('F','p_pre_jbsub_cod_spto_aa');
  --
 END p_pre_jbsub_cod_spto_aa;
 --
 /* --------------------------------------------------------
 || p_v_jbsub_cod_spto_aa :
 ||
 || Valida el parametro jbsub_cod_spto_aa
 */ --------------------------------------------------------
 --
 PROCEDURE p_v_jbsub_cod_spto_aa IS
 BEGIN
  --
  --@mx('I','p_v_jbsub_cod_spto_aa');
  --
  g_cod_spto_aa     := fp_devuelve_n('jbcod_spto_aa'    );
  g_sub_cod_spto_aa := fp_devuelve_n('jbsub_cod_spto_aa');
  g_txt_campo        := NULL;
  --
  IF     g_cod_spto_aa     IS NOT NULL
     AND g_sub_cod_spto_aa IS NOT NULL
   THEN
    --
    IF fp_comprueba_spto_aa
     THEN
      --
      g_txt_campo := em_k_a2991800.f_nom_spto;
      --
     ELSE
      --
      g_cod_mensaje := 80006;
      g_anx_mensaje := NULL;
      --
      pp_devuelve_error;
      --
    END IF;
    --
  END IF;
  --
  pp_devuelve_valores_val;
  --
  --@mx('F','p_v_jbsub_cod_spto_aa');
  --
 END p_v_jbsub_cod_spto_aa;
 --
 /* --------------------------------------------------------
 || p_pre_jbcod_tip_spto_aa :
 ||
 || Salta el parametro jbcod_tip_spto_aa si los parametros
 || jbcod_spto_aa y jbsub_cod_spto_aa son nulos
 */ --------------------------------------------------------
 --
 PROCEDURE p_pre_jbcod_tip_spto_aa IS
 BEGIN
  --
  --@mx('I','p_pre_jbcod_tip_spto_aa');
  --
  g_mca_salto        := 'N';
  g_val_campo        := fp_devuelve_c('val_campo'         );
  g_txt_campo        := NULL;
  --
  g_cod_spto_aa     := fp_devuelve_n('jbcod_spto_aa'    );
  g_sub_cod_spto_aa := fp_devuelve_n('jbsub_cod_spto_aa');
  --
  IF     g_cod_spto_aa     IS NULL
     AND g_sub_cod_spto_aa IS NULL
   THEN
    --
    g_val_campo := NULL;
    g_mca_salto := 'S';
    --
   ELSE
    --
    pp_asigna('tip_spto',g_tip_spto_aa);
    --
  END IF;
  --
  pp_devuelve_valores_pre;
  --
  --@mx('F','p_pre_jbcod_tip_spto_aa');
  --
 END p_pre_jbcod_tip_spto_aa;
 --
 /* --------------------------------------------------------
 || p_v_jbcod_tip_spto_aa :
 ||
 || Valida el parametro jbcod_tip_spto_aa
 */ --------------------------------------------------------
 --
 PROCEDURE p_v_jbcod_tip_spto_aa IS
 BEGIN
  --
  --@mx('I','p_v_jbcod_tip_spto_aa');
  --
  g_cod_tip_spto_aa := fp_devuelve_c('jbcod_tip_spto_aa');
  g_txt_campo        := NULL;
  --
  IF g_cod_tip_spto_aa IS NULL
   THEN
    --
    g_cod_mensaje := 20003;
    g_anx_mensaje := g_k_ini_corchete||'cod_tip_spto_aa'||g_k_fin_corchete;
    --
    pp_devuelve_error;
    --
  END IF;
  --
  g_txt_campo := fp_nom_tip_spto(g_cod_tip_spto_aa,
                                 g_tip_spto_aa    );
  --
  pp_devuelve_valores_val;
  --
  --@mx('F','p_v_jbcod_tip_spto_aa');
  --
 END p_v_jbcod_tip_spto_aa;
 --
 /* --------------------------------------------------------
 || p_v_jbcod_spto_re :
 ||
 || Valida el parametro jbcod_spto_re
 */ --------------------------------------------------------
 --
 PROCEDURE p_v_jbcod_spto_re IS
 BEGIN
  --
  --@mx('I','p_v_jbcod_spto_re');
  --
  g_cod_spto_re     := fp_devuelve_n('jbcod_spto_re');
  g_sub_cod_spto_re := fp_devuelve_n('valor_lista2' );
  g_txt_campo       := NULL;
  --
  pp_asigna('valor_lista1','');
  pp_asigna('valor_lista2','');
  --
  pp_devuelve_valores_val;
  --
  --@mx('F','p_v_jbcod_spto_re');
  --
 END p_v_jbcod_spto_re;
 --
 /* --------------------------------------------------------
 || p_pre_jbsub_cod_spto_re :
 ||
 || Salta el parametro jbsub_cod_spto_re si el parametro
 || jbcod_spto_re es nulo
 */ --------------------------------------------------------
 --
 PROCEDURE p_pre_jbsub_cod_spto_re IS
 BEGIN
  --
  --@mx('I','p_pre_jbsub_cod_spto_re');
  --
  g_mca_salto   := 'N';
  g_txt_campo   := NULL;
  g_val_campo   := fp_devuelve_c('val_campo'    );
  --
  g_cod_spto_re := fp_devuelve_n('jbcod_spto_re');
  --
  IF g_cod_spto_re IS NULL
   THEN
    --
    g_val_campo := NULL;
    g_txt_campo := NULL;
    g_mca_salto := 'S';
    --
   ELSIF g_sub_cod_spto_re IS NOT NULL
       THEN
        --
        g_val_campo := g_sub_cod_spto_re;
        --
  END IF;
  --
  g_sub_cod_spto_re := NULL;
  --
  pp_asigna('valor_lista1','');
  pp_asigna('valor_lista2','');
  --
  pp_devuelve_valores_pre;
  --
  --@mx('F','p_pre_jbsub_cod_spto_re');
  --
 END p_pre_jbsub_cod_spto_re;
 --
 /* --------------------------------------------------------
 || p_v_jbsub_cod_spto_re :
 ||
 || Valida el parametro jbsub_cod_spto_re
 */ --------------------------------------------------------
 --
 PROCEDURE p_v_jbsub_cod_spto_re IS
 BEGIN
  --
  --@mx('I','p_v_jbsub_cod_spto_re');
  --
  g_cod_spto_re     := fp_devuelve_n('jbcod_spto_re'    );
  g_sub_cod_spto_re := fp_devuelve_n('jbsub_cod_spto_re');
  g_txt_campo       := NULL;
  --
  IF     g_cod_spto_re     IS NOT NULL
     AND g_sub_cod_spto_re IS NOT NULL
   THEN
    --
    IF fp_comprueba_spto_re
     THEN
      --
      g_txt_campo := em_k_a2991800.f_nom_spto;
      --
     ELSE
      --
      g_cod_mensaje := 80006;
      g_anx_mensaje := NULL;
      --
      pp_devuelve_error;
      --
    END IF;
    --
  END IF;
  --
  pp_devuelve_valores_val;
  --
  --@mx('F','p_v_jbsub_cod_spto_re');
  --
 END p_v_jbsub_cod_spto_re;
 --
 /* --------------------------------------------------------
 || p_pre_jbcod_tip_spto_re :
 ||
 || Salta el parametro jbcod_tip_spto_re si los parametros
 || jbcod_spto_re y jbsub_cod_spto_re son nulos
 */ --------------------------------------------------------
 --
 PROCEDURE p_pre_jbcod_tip_spto_re IS
 BEGIN
  --
  --@mx('I','p_pre_jbcod_tip_spto_re');
  --
  g_mca_salto       := 'N';
  g_val_campo       := fp_devuelve_c('val_campo'        );
  g_txt_campo       := NULL;
  --
  g_cod_spto_re     := fp_devuelve_n('jbcod_spto_re'    );
  g_sub_cod_spto_re := fp_devuelve_n('jbsub_cod_spto_re');
  --
  IF     g_cod_spto_re     IS NULL
     AND g_sub_cod_spto_re IS NULL
   THEN
    --
    g_val_campo := NULL;
    g_mca_salto := 'S';
    --
   ELSE
    --
    pp_asigna('tip_spto',g_tip_spto_re);
    --
  END IF;
  --
  pp_asigna('valor_lista1','');
  pp_asigna('valor_lista2','');
  --
  pp_devuelve_valores_pre;
  --
  --@mx('F','p_pre_jbcod_tip_spto_re');
  --
 END p_pre_jbcod_tip_spto_re;
 --
 /* --------------------------------------------------------
 || p_v_jbcod_tip_spto_re :
 ||
 || Valida el parametro jbcod_tip_spto_re
 */ --------------------------------------------------------
 --
 PROCEDURE p_v_jbcod_tip_spto_re IS
 BEGIN
  --
  --@mx('I','p_v_jbcod_tip_spto_re');
  --
  g_cod_tip_spto_re := fp_devuelve_c('jbcod_tip_spto_re');
  g_txt_campo       := NULL;
  --
  IF g_cod_tip_spto_re IS NULL
   THEN
    --
    g_cod_mensaje := 20003;
    g_anx_mensaje := g_k_ini_corchete||'cod_tip_spto_re'||g_k_fin_corchete;
    --
    pp_devuelve_error;
    --
  END IF;
  --
  g_txt_campo := fp_nom_tip_spto(g_cod_tip_spto_re,
                                 g_tip_spto_re    );
  --
  pp_devuelve_valores_val;
  --
  --@mx('F','p_v_jbcod_tip_spto_re');
  --
 END p_v_jbcod_tip_spto_re;
 --
 /* --------------------------------------------------------
 || p_pre_jbcontrol_tecnico :
 ||
 || Si el proceso es una autorizacion de control tecnico se
 || detiene en los parametros especificos de este proceso
 ||          - jbcod_nivel_salto
 ||          - jbcod_error
 ||          - jbcod_usr_cia
 ||          - tip_autoriza_ct
 */ --------------------------------------------------------
 --
 PROCEDURE p_pre_jbcontrol_tecnico IS
 BEGIN
  --
  --@mx('I','p_pre_jbcontrol_tecnico');
  --
  g_mca_salto := 'S';
  g_val_campo := fp_devuelve_c('val_campo');
  g_txt_campo := NULL;
  --
  IF g_tip_mvto_batch IN (g_k_autoriza_pol_batch  ,
                          g_k_autoriza_ppto_batch )
   THEN
    --
    pp_asigna('cod_sistema','2');
    --
    g_mca_salto := 'N';
    --
   ELSE
    --
    g_val_campo := NULL;
    --
  END IF;
  --
  pp_devuelve_valores_pre;
  --
  --@mx('F','p_pre_jbcontrol_tecnico');
  --
 END p_pre_jbcontrol_tecnico;
 --
 /* --------------------------------------------------------
 || p_v_jbcod_usr_cia :
 ||
 || Valida el parametro jbcod_usr_cia
 */ --------------------------------------------------------
 --
 PROCEDURE p_v_jbcod_usr_cia IS
 BEGIN
  --
  --@mx('I','p_v_jbcod_usr_cia');
  --
  g_cod_usr_cia := fp_devuelve_c('jbcod_usr_cia');
  g_txt_campo   := NULL;
  --
  IF g_cod_usr_cia IS NOT NULL
   THEN
    --
    g_txt_campo := dc_f_nom_usr_cia(g_cod_cia    ,
                                    g_cod_usr_cia);
    --
  END IF;
  --
  pp_devuelve_valores_val;
  --
  --@mx('F','p_v_jbcod_usr_cia');
  --
 END p_v_jbcod_usr_cia;
 --
 /* --------------------------------------------------------
 || p_v_jbcod_nivel_salto :
 ||
 || Valida el parametro jbcod_nivel_salto
 */ --------------------------------------------------------
 --
 PROCEDURE p_v_jbcod_nivel_salto IS
 BEGIN
  --
  --@mx('I','p_v_jbcod_nivel_salto');
  --
  g_cod_nivel_salto := fp_devuelve_c('jbcod_nivel_salto');
  g_txt_campo       := NULL;
  --
  IF g_cod_nivel_salto IS NOT NULL
   THEN
    --
    dc_k_g2000220.p_lee (g_cod_cia        ,
                         '2'              ,
                         g_cod_nivel_salto);
    --
    g_txt_campo := dc_k_g2000220.f_nom_nivel_salto;
    --
  END IF;
  --
  pp_devuelve_valores_val;
  --
  --@mx('F','p_v_jbcod_nivel_salto');
  --
 END p_v_jbcod_nivel_salto;
 --
 /* --------------------------------------------------------
 || p_v_jbcod_error :
 ||
 || Valida el parametro jbcod_error
 */ --------------------------------------------------------
 --
 PROCEDURE p_v_jbcod_error IS
 BEGIN
  --
  --@mx('I','p_v_jbcod_error');
  --
  g_cod_error := fp_devuelve_n('jbcod_error');
  g_txt_campo := NULL;
  --
  IF g_cod_error IS NOT NULL
   THEN
    --
    dc_k_g2000211.p_lee(g_cod_cia   ,
                        g_cod_error ,
                        g_cod_idioma);
    --
    g_txt_campo := SUBSTR(dc_k_g2000211.f_nom_error,1,30);
    --
  END IF;
  --
  pp_devuelve_valores_val;
  --
  --@mx('F','p_v_jbcod_error');
  --
 END p_v_jbcod_error;
 --
 /* --------------------------------------------------------
 || p_v_tip_autoriza_ct :
 ||
 || Valida el parametro tip_autoriza_ct
 */ --------------------------------------------------------
 --
 PROCEDURE p_v_tip_autoriza_ct IS
 BEGIN
  --
  --@mx('I','p_v_tip_autoriza_ct');
  --
  g_tip_autoriza_ct := fp_devuelve_c('tip_autoriza_ct');
  g_txt_campo       := NULL;
  --
  IF g_tip_autoriza_ct IS NOT NULL
   THEN
    --
    g_txt_campo := fp_rec_nom_valor('TIP_AUTORIZA_CT',
                                    g_tip_autoriza_ct);
    --
  END IF;
  --
  pp_devuelve_valores_val;
  --
  --@mx('F','p_v_tip_autoriza_ct');
  --
 END p_v_tip_autoriza_ct;
 --
 /* --------------------------------------------------------
 || p_pre_jbfec_desde :
 ||
 || Salta el parametro jbfec_desde si el proceso no es auto-
 || rizacion de control tecnico o si se ha indicado una po-
 || liza
 */ --------------------------------------------------------
 --
 PROCEDURE p_pre_jbfec_desde IS
 BEGIN
  --
  --@mx('I','p_pre_jbfec_desde');
  --
  g_mca_salto       := 'N';
  g_txt_campo       := NULL;
  --
  g_val_campo       := fp_devuelve_c('val_campo'        );
  g_num_poliza      := fp_devuelve_c('jbnum_poliza'     );
  g_fec_tratamiento := fp_devuelve_f('fec_tratamiento');
  --
  IF g_tip_mvto_batch NOT IN (g_k_autoriza_pol_batch ,
                              g_k_autoriza_ppto_batch)
   THEN
    --
    g_val_campo := NULL;
    g_mca_salto := 'S';
    --
   ELSIF g_num_poliza IS NOT NULL
       THEN
        --
        g_val_campo := NULL;
        g_mca_salto := 'S';
        --
   ELSIF g_val_campo IS NULL
       THEN
        --
        g_val_campo := TO_CHAR(g_fec_tratamiento,'DDMMYYYY');
        g_mca_salto := 'N';
        --
  END IF;
  --
  pp_devuelve_valores_pre;
  --
  --@mx('F','p_pre_jbfec_desde');
  --
 END p_pre_jbfec_desde;
 --
 /* --------------------------------------------------------
 || p_v_jbfec_desde :
 ||
 || Valida el parametro jbfec_desde
 */ --------------------------------------------------------
 --
 PROCEDURE p_v_jbfec_desde IS
 BEGIN
  --
  --@mx('I','p_v_jbfec_desde');
  --
  g_fec_desde  := fp_devuelve_f('jbfec_desde' );
  g_num_poliza := fp_devuelve_c('jbnum_poliza');
  g_txt_campo  := NULL;
  --
  IF     g_tip_mvto_batch IN (g_k_autoriza_pol_batch ,
                              g_k_autoriza_ppto_batch)
     AND g_num_poliza     IS NULL
     AND g_fec_desde      IS NULL
   THEN
    --
    g_cod_mensaje := 20003;
    g_anx_mensaje := g_k_ini_corchete||'fec_desde'||g_k_fin_corchete;
    --
    pp_devuelve_error;
    --
  END IF;
  --
  pp_devuelve_valores_val;
  --
  --@mx('F','p_v_jbfec_desde');
  --
 END p_v_jbfec_desde;
 --
 /* --------------------------------------------------------
 || p_pre_jbfec_hasta :
 ||
 || Salta el parametro jbfec_hasta si el proceso no es auto-
 || rizacion de control tecnico o si se ha indicado una po-
 || liza o si el parametro jbfec_desde es nulo
 */ --------------------------------------------------------
 --
 PROCEDURE p_pre_jbfec_hasta IS
 BEGIN
  --
  --@mx('I','p_pre_jbfec_hasta');
  --
  g_mca_salto  := 'N';
  g_txt_campo  := NULL;
  g_val_campo  := fp_devuelve_c('val_campo'   );
  --
  g_num_poliza := fp_devuelve_c('jbnum_poliza');
  g_fec_desde  := fp_devuelve_f('jbfec_desde' );
  --
  IF    g_tip_mvto_batch NOT IN (g_k_autoriza_pol_batch ,
                                 g_k_autoriza_ppto_batch)
   THEN
    --
    g_val_campo := NULL;
    g_mca_salto := 'S';
    --
   ELSIF    g_num_poliza IS NOT NULL
         OR g_fec_desde  IS     NULL
       THEN
        --
        g_val_campo := NULL;
        g_mca_salto := 'S';
        --
   ELSIF g_fec_desde IS NOT NULL
       THEN
        --
        g_val_campo := TO_CHAR(g_fec_desde,'DDMMYYYY');
        g_mca_salto := 'N';
        --
  END IF;
  --
  pp_devuelve_valores_pre;
  --
  --@mx('F','p_pre_jbfec_hasta');
  --
 END p_pre_jbfec_hasta;
 --
 /* --------------------------------------------------------
 || p_v_jbfec_hasta :
 ||
 || Valida el parametro jbfec_hasta
 */ --------------------------------------------------------
 --
 PROCEDURE p_v_jbfec_hasta IS
 BEGIN
  --
  --@mx('I','p_v_jbfec_hasta');
  --
  g_fec_desde := fp_devuelve_f('jbfec_desde');
  g_fec_hasta := fp_devuelve_f('jbfec_hasta');
  g_txt_campo := NULL;
  --
  IF     g_fec_desde IS NOT NULL
     AND g_fec_hasta IS     NULL
   THEN
    --
    g_cod_mensaje := 20003;
    g_anx_mensaje := g_k_ini_corchete||'fec_hasta'||g_k_fin_corchete;
    --
    pp_devuelve_error;
    --
   ELSIF g_fec_hasta < g_fec_desde
       THEN
        --
        g_cod_mensaje := 20008;
        g_anx_mensaje := NULL;
        --
        pp_devuelve_error;
        --
  END IF;
  --
  pp_devuelve_valores_val;
  --
  --@mx('F','p_v_jbfec_hasta');
  --
 END p_v_jbfec_hasta;
 --
 /* --------------------------------------------------------
 || p_pre_jbmax_num_riesgos :
 ||
 || Recupera el numero total de riesgos si se ha indicado
 || una poliza
 */ --------------------------------------------------------
 --
 PROCEDURE p_pre_jbmax_num_riesgos
 IS
 --
 BEGIN
    --
    --@mx('I','p_pre_jbmax_num_riesgos');
    --
    g_mca_salto  := trn.NO  ;
    g_txt_campo  := trn.NULO;
    --
    g_val_campo  := fp_devuelve_c('val_campo'   );
    --
    g_num_poliza := fp_devuelve_c('jbnum_poliza');
    --
    IF g_num_poliza IS NOT NULL
    THEN
       --
       IF g_tabla_df = g_k_a30
       THEN
          --
          g_val_campo := g_reg_em_k_a2000030.num_riesgos;
          g_mca_salto := trn.SI                 ;
          --
       ELSIF g_tabla_df = g_k_p30
       THEN
          --
          g_val_campo := em_k_p2000030.f_num_riesgos;
          g_mca_salto := trn.SI                     ;
          --
       ELSIF g_tabla_df = g_k_r30
       THEN
          --
          g_val_campo := em_k_r2000030.f_num_riesgos;
          g_mca_salto := trn.SI                     ;
          --
       END IF;
       --
    END IF;
    --
    pp_devuelve_valores_pre;
    --
    --@mx('F','p_pre_jbmax_num_riesgos');
    --
 END p_pre_jbmax_num_riesgos;
 --
 /* --------------------------------------------------------
 || p_pre_jbmca_grupos :
 ||
 || Si se ha indicado una poliza devuelve una S o una N
 || dependiendo de si tiene poliza grupo
 */ --------------------------------------------------------
 --
 PROCEDURE p_pre_jbmca_grupos IS
 BEGIN
  --
  --@mx('I','p_pre_jbmca_grupos');
  --
  g_mca_salto        := 'N';
  g_txt_campo        := NULL;
  g_val_campo        := fp_devuelve_c('val_campo'         );
  --
  g_num_poliza       := fp_devuelve_c('jbnum_poliza'      );
  g_num_poliza_grupo := fp_devuelve_c('jbnum_poliza_grupo');
  --
  IF g_num_poliza_grupo IS NOT NULL
   THEN
    --
    g_val_campo := 'S';
    g_mca_salto := 'S';
    --
   ELSIF g_num_poliza IS NOT NULL
       THEN
        --
        g_val_campo := fp_hay_poliza_grupo;
        g_mca_salto := 'S';
        --
  END IF;
  --
  pp_devuelve_valores_pre;
  --
  --@mx('F','p_pre_jbmca_grupos');
  --
 END p_pre_jbmca_grupos;
 --
 /* --------------------------------------------------------
 || p_v_jbmca_grupos :
 ||
 || Valida el parametro jbmca_grupos
 */ --------------------------------------------------------
 --
 PROCEDURE p_v_jbmca_grupos IS
 BEGIN
  --
  --@mx('I','p_v_jbmca_grupos');
  --
  g_mca_grupos := fp_devuelve_c('jbmca_grupos');
  g_txt_campo  := NULL;
  --
  IF g_mca_grupos IS NOT NULL
   THEN
    --
    pp_val_s_n('mca_grupos' ,
               g_mca_grupos );
    --
  END IF;
  --
  pp_devuelve_valores_val;
  --
  --@mx('F','p_v_jbmca_grupos');
  --
 END p_v_jbmca_grupos;
 --
 /* --------------------------------------------------------
 || p_pre_jbcant_registros :
 ||
 || Si ha indicado una poliza devuelve un 1 y salta el dato
 */ --------------------------------------------------------
 --
 PROCEDURE p_pre_jbcant_registros IS
 BEGIN
  --
  --@mx('I','p_pre_jbcant_registros');
  --
  g_mca_salto  := 'N';
  g_txt_campo  := NULL;
  g_val_campo  := fp_devuelve_c('val_campo'   );
  --
  g_num_poliza := fp_devuelve_c('jbnum_poliza');
  --
  IF g_num_poliza IS NOT NULL
   THEN
    --
    g_val_campo := '1';
    g_mca_salto := 'S';
    --
  END IF;
  --
  pp_devuelve_valores_pre;
  --
  --@mx('F','p_pre_jbcant_registros');
  --
 END p_pre_jbcant_registros;
 --
 /* --------------------------------------------------------
 || p_pre_jbmca_ejecuta_filtro :
 ||
 || Si el proceso ya esta filtrado salta e indica N. SI esta
 || sin filtrar indica S.
 */ --------------------------------------------------------
 --
 PROCEDURE p_pre_jbmca_ejecuta_filtro
 IS
    --
    l_cod_cia         g2000510.cod_cia        %TYPE;
    l_fec_tratamiento g2000510.fec_tratamiento%TYPE;
    l_num_orden       g2000510.num_orden      %TYPE;
    l_tip_mvto_batch  g2000510.tip_mvto_batch %TYPE;
    l_tip_situ_filtro g2000510.tip_situ_filtro%TYPE;
    --
 BEGIN
    --
    --@mx('I','p_pre_jbmca_ejecuta_filtro');
    --
    g_txt_campo       := NULL;
    --
    l_cod_cia         := TO_NUMBER (trn_k_global.ref_f_global ('JBCOD_CIA'));
    l_fec_tratamiento := TO_DATE (trn_k_global.ref_f_global ('FEC_TRATAMIENTO'), 'ddmmyyyy');
    l_num_orden       := TO_NUMBER (trn_k_global.ref_f_global('JBNUM_ORDEN'));
    l_tip_mvto_batch  := trn_k_global.ref_f_global('TIP_MVTO_BATCH');
    --
    IF fp_permite_filtro (l_tip_mvto_batch)
    THEN
       --
       em_k_g2000510.p_lee(l_cod_cia         ,
                           l_fec_tratamiento ,
                           l_num_orden       ,
                           l_tip_mvto_batch  );
       --
       l_tip_situ_filtro := em_k_g2000510.f_tip_situ_filtro;
       --
       IF l_tip_situ_filtro = g_k_sin_filtrar
       THEN
          --
          g_val_campo := trn.SI;
          g_mca_salto := trn.NO;
          --
       ELSE
          --
          g_val_campo := trn.NO;
          g_mca_salto := trn.SI;
          --
       END IF;
       --
    ELSE
       --
       g_val_campo := trn.NO;
       g_mca_salto := trn.SI;
       --
    END IF;
    --
    pp_devuelve_valores_pre;
    --
    --@mx('F','p_pre_jbmca_ejecuta_filtro');
    --
 END p_pre_jbmca_ejecuta_filtro;
 --
 /* --------------------------------------------------------
 || p_v_jbmca_ejecuta_filtro :
 ||
 || Valida el parametro jbmca_ejecuta_filtro
 */ --------------------------------------------------------
 --
 PROCEDURE p_v_jbmca_ejecuta_filtro IS
 BEGIN
  --
  --@mx('I','p_v_jbmca_ejecuta_filtro'||fp_devuelve_c('p_v_jbmca_ejecuta_filtro'));
  --
  --
  g_mca_ejecuta_filtro := fp_devuelve_c('jbmca_ejecuta_filtro');
  g_txt_campo          := NULL;
  --
  pp_val_s_n('jbmca_ejecuta_filtro',
             g_mca_ejecuta_filtro  );
  --
  pp_devuelve_valores_val;
  --
  --
  --@mx('F','p_v_jbmca_ejecuta_filtro');
  --
 END p_v_jbmca_ejecuta_filtro;
 --
 /* --------------------------------------------------------
 || p_v_jbmca_reproceso :
 ||
 || Valida el parametro jbmca_reproceso
 */ --------------------------------------------------------
 --
 PROCEDURE p_v_jbmca_reproceso IS
 BEGIN
  --
  --@mx('I','p_v_jbmca_reproceso');
  --
  g_mca_reproceso := fp_devuelve_c('jbmca_reproceso');
  g_txt_campo     := NULL;
  --
  pp_val_s_n('mca_reproceso' ,
             g_mca_reproceso );
  --
  pp_devuelve_valores_val;
  --
  --@mx('F','p_v_jbmca_reproceso');
  --
 END p_v_jbmca_reproceso;
 --
 /* --------------------------------------------------------
 || p_pre_jbmca_aborta_emision :
 ||
 || Se pone a N en los procesos de control tecnico y anula-
 || cion
 */ --------------------------------------------------------
 --
 PROCEDURE p_pre_jbmca_aborta_emision IS
 BEGIN
  --
  --@mx('I','p_pre_jbmca_aborta_emision');
  --
  g_mca_salto  := 'N';
  g_txt_campo  := NULL;
  g_val_campo  := NULL;
  --
  IF    g_tip_mvto_batch IN (g_k_autoriza_pol_batch ,
                             g_k_autoriza_ppto_batch,
                             g_k_anulacion_batch    )
     OR fp_otros_batch
   THEN
    --
    g_val_campo := 'N';
    g_mca_salto := 'S';
    --
  END IF;
  --
  pp_devuelve_valores_pre;
  --
  --@mx('F','p_pre_jbmca_aborta_emision');
  --
 END p_pre_jbmca_aborta_emision;
 --
 /* --------------------------------------------------------
 || p_v_jbmca_aborta_emision :
 ||
 || Valida el parametro jbmca_aborta_emision
 */ --------------------------------------------------------
 --
 PROCEDURE p_v_jbmca_aborta_emision IS
 BEGIN
  --
  --@mx('I','p_v_jbmca_aborta_emision');
  --
  g_mca_aborta_emision := fp_devuelve_c('jbmca_aborta_emision');
  g_txt_campo          := NULL;
  --
  pp_val_s_n('mca_aborta_emision' ,
             g_mca_aborta_emision );
  --
  pp_devuelve_valores_val;
  --
  --@mx('F','p_v_jbmca_aborta_emision');
  --
 END p_v_jbmca_aborta_emision;
 --
 /* -------------------------------------------------------
 || p_pre_jbcod_spto_susp_pa:
 ||
 || Si no aplica filtro salta el dato y lo deja a
 || nulos
 */ -------------------------------------------------------
 --
 PROCEDURE p_pre_jbcod_spto_susp_pa IS
 BEGIN
  --
  --@mx('I','p_pre_jbcod_spto_susp_pa');
  --
  g_val_campo  := fp_devuelve_n('val_campo'   );
  g_txt_campo  := NULL;
  g_mca_salto  := 'N';
  --
  g_mca_ejecuta_filtro := fp_devuelve_c('jbmca_ejecuta_filtro');
  --
  IF g_mca_ejecuta_filtro = trn.NO
   THEN
    --
    g_val_campo  := NULL;
    g_txt_campo  := NULL;
    g_mca_salto  := 'S';
    --
    g_cod_spto_susp_pa := NULL;
    --
  END IF;
  --
  pp_devuelve_valores_pre;
  --
  --@mx('F','p_pre_jbcod_spto_susp_pa');
  --
 END p_pre_jbcod_spto_susp_pa;
 --
 /* -------------------------------------------------------
 || p_v_jbcod_spto_susp_pa:
 ||
 || Valida el parametro jbcod_spto_susp_pa
 */ -------------------------------------------------------
 --
 PROCEDURE p_v_jbcod_spto_susp_pa IS
 BEGIN
  --
  --@mx('I','p_v_jbcod_spto_susp_pa');
  --
  g_cod_spto_susp_pa:= fp_devuelve_n('jbcod_spto_susp_pa');
  g_txt_campo       := NULL;
  --
  IF g_tip_mvto_batch = g_k_anul_aport_pactada
   AND g_cod_spto_susp_pa is NULL
   THEN
    --
    g_cod_mensaje := 20003;
    g_anx_mensaje :=    g_k_ini_corchete||'cod_spto_susp_pa'||g_k_fin_corchete;
    --
    pp_devuelve_error;
    --
  END IF;
  --
  pp_devuelve_valores_val;
  --
  --@mx('F','p_v_jbcod_spto_susp_pa ');
  --
 END p_v_jbcod_spto_susp_pa;
 --
/* -------------------------------------------------------
 || p_pre_jbsub_cod_spto_susp_pa:
 ||
 || Si no aplica filtro salta el dato y lo deja a
 || nulos
 */ -------------------------------------------------------
 --
 PROCEDURE p_pre_jbsub_cod_spto_susp_pa IS
 BEGIN
  --
  --@mx('I','p_pre_jbsub_cod_spto_susp_pa');
  --
  g_val_campo  := fp_devuelve_n('val_campo'   );
  g_txt_campo  := NULL;
  g_mca_salto  := 'N';
  --
  g_mca_ejecuta_filtro := fp_devuelve_c('jbmca_ejecuta_filtro');
  --
  IF g_mca_ejecuta_filtro = trn.NO
   THEN
    --
    g_val_campo  := NULL;
    g_txt_campo  := NULL;
    g_mca_salto  := 'S';
    --
    g_sub_cod_spto_susp_pa := NULL;
    --
  END IF;
  --
  pp_devuelve_valores_pre;
  --
  --@mx('F','p_pre_jbsub_cod_spto_susp_pa');
  --
 END p_pre_jbsub_cod_spto_susp_pa;
 --
 /* -------------------------------------------------------
 || p_v_jbsub_cod_spto_susp_pa:
 ||
 || Valida el parametro jbsub_cod_spto_susp_pa
 */ -------------------------------------------------------
 --
 PROCEDURE p_v_jbsub_cod_spto_susp_pa IS
 --
 l_tip_spto_fondo  a2991800.tip_spto_fondo %TYPE;
 --
 BEGIN
  --
  --@mx('I','p_v_jbcod_spto_susp_pa');
  --
  g_sub_cod_spto_susp_pa:= fp_devuelve_n('jbsub_cod_spto_susp_pa');
  g_txt_campo       := NULL;
  --
  IF g_tip_mvto_batch = g_k_anul_aport_pactada
   AND g_sub_cod_spto_susp_pa is NULL
   THEN
    --
    g_cod_mensaje := 20003;
    g_anx_mensaje :=    g_k_ini_corchete||'sub_cod_spto_susp_pa'||g_k_fin_corchete;
    --
    pp_devuelve_error;
    --
  END IF;
  --
  IF     g_cod_spto_susp_pa     IS NOT NULL
     AND g_sub_cod_spto_susp_pa IS NOT NULL
   THEN
    --
    em_k_a2991800.p_lee(p_cod_cia         => g_cod_cia,
                        p_cod_spto        => g_cod_spto_susp_pa,
                        p_sub_cod_spto    => g_sub_cod_spto_susp_pa,
                        p_tip_ambito_spto => trn.NULO);
    --
    l_tip_spto_fondo := em_k_a2991800.f_tip_spto_fondo;
    --
    IF l_tip_spto_fondo = em.TIPO_SPTO_FONDO_SUSP_PLAN_APOR
     THEN
      --
      g_txt_campo := em_k_a2991800.f_nom_spto;
      --
     ELSE
      --
      g_cod_mensaje := 80006;
      g_anx_mensaje := NULL;
      --
      pp_devuelve_error;
      --
    END IF;
    --
  END IF;
  --
  pp_devuelve_valores_val;
  --
  --@mx('F','p_v_jbsub_cod_spto_susp_pa ');
  --
 END p_v_jbsub_cod_spto_susp_pa;
 --
/* -------------------------------------------------------
 || p_pre_jbcod_tip_spto_susp_pa:
 ||
 || Si no aplica filtro salta el dato y lo deja a
 || nulos
 */ -------------------------------------------------------
 --
 PROCEDURE p_pre_jbcod_tip_spto_susp_pa IS
 BEGIN
  --
  --@mx('I','p_pre_jbcod_tip_spto_susp_pa');
  --
  g_val_campo  := fp_devuelve_c('val_campo'   );
  g_txt_campo  := NULL;
  g_mca_salto  := 'N';
  --
  g_mca_ejecuta_filtro := fp_devuelve_c('jbmca_ejecuta_filtro');
  --
  IF g_mca_ejecuta_filtro = trn.NO
   THEN
    --
    g_val_campo  := NULL;
    g_txt_campo  := NULL;
    g_mca_salto  := 'S';
    --
    g_cod_tip_spto_susp_pa := NULL;
    --
  END IF;
  --
  pp_devuelve_valores_pre;
  --
  --@mx('F','p_pre_jbcod_tip_pto_susp_pa');
  --
 END p_pre_jbcod_tip_spto_susp_pa;
 --
 /* -------------------------------------------------------
 || p_v_jbcod_tip_spto_susp_pa:
 ||
 || Valida el parametro jbcod_tip_spto_susp_pa
 */ -------------------------------------------------------
 --
 PROCEDURE p_v_jbcod_tip_spto_susp_pa IS
  CURSOR c_g2990300
  IS
         SELECT nom_tip_spto
           FROM g2990300 a
          WHERE cod_cia      = g_cod_cia
            AND cod_ramo     = (SELECT b.cod_ramo
                                  FROM a1001800 b
                                 WHERE b.cod_tratamiento   = em.TRATAMIENTO_VIDA
                                   AND b.mca_gestion_fondo = g_k_si
                                   AND b.cod_ramo          = g_cod_ramo)
            AND tip_spto     = (SELECT b.tip_spto
                                  FROM a2991800 b
                                 WHERE b.cod_cia      = g_cod_cia
                                   AND b.cod_spto     = g_cod_spto_susp_pa
                                   AND b.sub_cod_spto = g_sub_cod_spto_susp_pa)
            AND UPPER(a.nom_tip_spto) like UPPER('%SUSP%');
  --
  l_nom_tip_spto g2990300.nom_tip_spto %TYPE;
  l_existe       BOOLEAN;
  --
 BEGIN
  --
  --@mx('I','p_v_jbcod_tip_spto_susp_pa');
  --
  g_cod_tip_spto_susp_pa:= fp_devuelve_c('jbcod_tip_spto_susp_pa');
  g_txt_campo       := NULL;
  --
  IF g_tip_mvto_batch = g_k_anul_aport_pactada
   AND g_cod_tip_spto_susp_pa is NULL
   THEN
    --
    g_cod_mensaje := 20003;
    g_anx_mensaje :=    g_k_ini_corchete|| 'cod_tip_spto_susp_pa'||g_k_fin_corchete;
    --
    pp_devuelve_error;
    --
  END IF;
  --
IF g_cod_tip_spto_susp_pa is NOT NULL
     THEN
  --
  BEGIN
     --
  OPEN        c_g2990300;
  FETCH       c_g2990300 INTO l_nom_tip_spto;
  l_existe := c_g2990300%FOUND;
  CLOSE       c_g2990300;
  --
  IF NOT l_existe
   THEN
    --
      g_cod_mensaje := 20001;
      g_anx_mensaje := NULL;
      --
      pp_devuelve_error;
      --
  END IF;
  --
  END;
  --
  END IF;
  g_txt_campo := l_nom_tip_spto;
  --
  pp_devuelve_valores_val;
  --
  --@mx('F','p_v_jbcod_tip_spto_susp_pa ');
  --
 END p_v_jbcod_tip_spto_susp_pa;
 --

 /* --------------------------------------------------------
 || p_emite :
 ||
 || Realiza la ejecucion directa del proceso sin que la po-
 || liza exista en la tabla de polizas para procesos batch
 */ --------------------------------------------------------
 --
 PROCEDURE p_emite ( p_tip_mvto_batch      a2000500.tip_mvto_batch      %TYPE             ,
                     p_fec_tratamiento     a2000500.fec_tratamiento     %TYPE             ,
                     p_cod_cia             a2000500.cod_cia             %TYPE             ,
                     p_cod_ramo            a2000500.cod_ramo            %TYPE             ,
                     p_num_contrato        a2000500.num_contrato        %TYPE             ,
                     p_num_subcontrato     a2000500.num_subcontrato     %TYPE             ,
                     p_num_poliza_grupo    a2000500.num_poliza_grupo    %TYPE             ,
                     p_num_poliza_cliente  a2000500.num_poliza_cliente  %TYPE             ,
                     p_num_poliza          a2000500.num_poliza          %TYPE             ,
                     p_num_apli            a2000500.num_apli            %TYPE             ,
                     p_tip_poliza_tr       a2000500.tip_poliza_tr       %TYPE             ,
                     p_cod_spto            a2000500.cod_spto            %TYPE             ,
                     p_sub_cod_spto        a2000500.sub_cod_spto        %TYPE             ,
                     p_cod_tip_spto        a2000500.cod_tip_spto        %TYPE             ,
                     p_txt_motivo_spto     a2000500.txt_motivo_spto     %TYPE             ,
                     p_fec_efec_spto       a2000500.fec_efec_spto       %TYPE             ,
                     p_hora_desde          a2000500.hora_desde          %TYPE             ,
                     p_fec_vcto_spto       a2000500.fec_vcto_spto       %TYPE             ,
                     p_mca_renueva         a2000500.mca_renueva         %TYPE             ,
                     p_cant_renovaciones   a2000500.cant_renovaciones   %TYPE             ,
                     p_mca_renueva_tmp     a2000500.mca_renueva_tmp     %TYPE             ,
                     p_mca_periodicidad    a2000500.mca_periodicidad    %TYPE             ,
                     p_mca_devuelve_todo   a2000500.mca_devuelve_todo   %TYPE             ,
                     p_mca_prorrata        a2000500.mca_prorrata        %TYPE             ,
                     p_cod_usr             a2000500.cod_usr             %TYPE             ,
                     p_cod_negocio         a2000500.cod_negocio         %TYPE             ,
                     p_num_poliza_tronador a2000500.num_poliza_tronador %TYPE DEFAULT NULL)
 IS
 --
 BEGIN
  --
  --@mx('I','p_emite');
  --
  g_reg := g_reg_nulo;
  --
  pp_recupera_usuario;
  pp_inicializa_variables_g;
  --
  g_fec_tratamiento           := p_fec_tratamiento;
  g_tip_mvto_batch            := p_tip_mvto_batch ;
  g_num_orden                 := 0                ;
  g_mca_multihilo             := 'N'              ;
  --
  IF NVL(g_tip_mvto_batch,'x') IN ( g_k_rf_batch       ,
                                    g_k_pre_rf_batch   ,
                                    g_k_carga_batch    ,
                                    g_k_spto_batch     ,
                                    g_k_apli_batch     ,
                                    g_k_spto_apli_batch,
                                    g_k_conv_rf_batch  )
   THEN
    --
    g_cod_cia                   := p_cod_cia           ;
    g_cod_spto                  := p_cod_spto          ;
    g_sub_cod_spto              := p_sub_cod_spto      ;
    --
    g_reg.cod_cia               := g_cod_cia            ;
    g_reg.cod_ramo              := p_cod_ramo           ;
    g_reg.num_poliza_grupo      := p_num_poliza_grupo   ;
    g_reg.num_contrato          := p_num_contrato       ;
    g_reg.num_subcontrato       := p_num_subcontrato    ;
    g_reg.num_poliza_cliente    := p_num_poliza_cliente ;
    g_reg.num_poliza            := p_num_poliza         ;
    g_reg.num_apli              := p_num_apli           ;
    g_reg.tip_poliza_tr         := p_tip_poliza_tr      ;
    g_reg.fec_efec_spto         := p_fec_efec_spto      ;
    g_reg.hora_desde            := p_hora_desde         ;
    g_reg.fec_vcto_spto         := p_fec_vcto_spto      ;
    g_reg.cod_spto              := g_cod_spto           ;
    g_reg.sub_cod_spto          := g_sub_cod_spto       ;
    g_reg.cod_tip_spto          := p_cod_tip_spto       ;
    g_reg.txt_motivo_spto       := p_txt_motivo_spto    ;
    g_reg.mca_renueva           := p_mca_renueva        ;
    g_reg.mca_renueva_tmp       := p_mca_renueva_tmp    ;
    g_reg.mca_periodicidad      := p_mca_periodicidad   ;
    g_reg.cant_renovaciones     := p_cant_renovaciones  ;
    g_reg.mca_devuelve_todo     := p_mca_devuelve_todo  ;
    g_reg.mca_prorrata          := p_mca_prorrata       ;
    g_reg.cod_usr_captura       := p_cod_usr            ;
    g_reg.cod_negocio           := p_cod_negocio        ;
    g_reg.num_poliza_tronador   := p_num_poliza_tronador;
    --
    g_reg.mca_pre_renovacion    := 'N'                 ;
    pp_asigna('mca_pre_renovacion'  ,g_reg.mca_pre_renovacion);
    --
    g_mca_aborta_emision        := 'S';
    pp_asigna('jbmca_aborta_emision',g_mca_aborta_emision    );
    --
    g_tip_emision               := fp_tip_emision;
    --
    pp_asigna_globales_inicio;
    --
    pp_llama_proceso;
    --
--    IF g_tip_situ = g_k_con_error
    IF g_tip_situ = g_k_tratada_con_error
     THEN
      --
      RAISE_APPLICATION_ERROR(-20000,g_txt_mensaje);
      --
    END IF;
    --
  END IF;
  --
  --@mx('F','p_emite');
  --
 END p_emite;
 --
END em_k_batch_trn;
