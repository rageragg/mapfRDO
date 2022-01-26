CREATE OR REPLACE PACKAGE em_k_batch_trn AS
 --
 /* -------------------- DESCRIPCION --------------------
 || Llamador de procesos batch
 */ -----------------------------------------------------
 --
 /* -------------------- VERSION = 1.16 -------------------- */
 --
 /* -------------------- MODIFICACIONES --------------------
 || 2019/02/27 - MJORTI1 - 1.17 - (PROYECTO TRON_VIDA)
 || Se modifica para incuir nuevos procedimientos:
 || p_pre_jbcod_spto_susp_pa, p_v_jbcod_spto_susp_pa,
 || p_pre_jbsub_cod_spto_susp_pa, p_v_jbsub_cod_spto_susp_pa,
 || p_pre_jbcod_tip_spto_susp_pa,p_v_jbcod_tip_spto_susp_pa
 */ --------------------------------------------------------
 --
 PROCEDURE p_proceso;
 --
 /* -------------------- DESCRIPCION --------------------
 || Ejecuta el proceso batch
 */ -----------------------------------------------------
 --
 PROCEDURE p_pre_jbmca_multihilo;
 /* -------------------------------------------------------
 || Pre-campo del parametro : jbmca_multihilo
 */ -------------------------------------------------------
 --
 PROCEDURE p_v_jbmca_multihilo;
 /* --------------------------------------------------------
 || Valida el parametro : jbmca_multihilo
 */ --------------------------------------------------------
 --
 PROCEDURE p_v_tip_mvto_batch;
 --
 /* -------------------- DESCRIPCION --------------------
 || Valida el parametro : tip_mvto_batch
 */ -----------------------------------------------------
 --
 PROCEDURE p_pre_fec_tratamiento;
 --
 /* -------------------- DESCRIPCION --------------------
 || Pre-campo del parametro : fec_tratamiento
 */ -----------------------------------------------------
 --
 PROCEDURE p_pre_jbnum_orden;
 --
 /* -------------------- DESCRIPCION --------------------
 || Pre-campo del parametro : jbnum_orden
 */ -----------------------------------------------------
 --
 PROCEDURE p_v_jbnum_orden;
 --
 /* -------------------- DESCRIPCION --------------------
 || Valida el parametro : jbnum_orden
 */ -----------------------------------------------------
 --
 PROCEDURE p_pre_jbcod_cia;
 --
 /* -------------------- DESCRIPCION --------------------
 || Pre-campo del parametro : jbcod_cia
 */ -----------------------------------------------------
 --
 PROCEDURE p_v_jbcod_cia;
 --
 /* -------------------- DESCRIPCION --------------------
 || Valida el parametro : jbcod_cia
 */ -----------------------------------------------------
 --
 PROCEDURE p_v_jbnum_poliza_grupo;
 --
 /* -------------------- DESCRIPCION --------------------
 || Valida el parametro :jbnum_poliza_grupo
 */ -----------------------------------------------------
 --
 PROCEDURE p_v_jbnum_poliza_cliente;
 --
 /* -------------------- DESCRIPCION --------------------
 || Valida el parametro :jbnum_poliza_cliente
 */ -----------------------------------------------------
 --
 PROCEDURE p_v_jbnum_poliza;
 --
 /* -------------------- DESCRIPCION --------------------
 || Valida el parametro : jbnum_poliza
 */ -----------------------------------------------------
 --
 PROCEDURE p_pre_jbcod_ramo;
 --
 /* -------------------- DESCRIPCION --------------------
 || Pre-campo del parametro : jbcod_ramo
 */ -----------------------------------------------------
 --
 PROCEDURE p_v_jbcod_ramo;
 --
 /* -------------------- DESCRIPCION --------------------
 || Valida el parametro : jbcod_ramo
 */ -----------------------------------------------------
 --
 PROCEDURE p_pre_jbcod_sector;
 --
 /* -------------------- DESCRIPCION --------------------
 || Pre-campo del parametro : jbcod_sector
 */ -----------------------------------------------------
 --
 PROCEDURE p_v_jbcod_sector;
 --
 /* -------------------- DESCRIPCION --------------------
 || Valida el parametro : jbcod_sector
 */ -----------------------------------------------------
 --
 PROCEDURE p_pre_jbcod_nivel3;
 --
 /* -------------------- DESCRIPCION --------------------
 || Pre-campo del parametro : jbcod_nivel3
 */ -----------------------------------------------------
 --
 PROCEDURE p_v_jbcod_nivel3;
 --
 /* -------------------- DESCRIPCION --------------------
 || Valida el parametro : jbcod_nivel3
 */ -----------------------------------------------------
 --
 PROCEDURE p_pre_jbcod_nivel2;
 --
 /* -------------------- DESCRIPCION --------------------
 || Pre-campo del parametro : jbcod_nivel2
 */ -----------------------------------------------------
 --
 PROCEDURE p_v_jbcod_nivel2;
 --
 /* -------------------- DESCRIPCION --------------------
 || Valida el parametro : jbcod_nivel2
 */ -----------------------------------------------------
 --
 PROCEDURE p_pre_jbcod_nivel1;
 --
 /* -------------------- DESCRIPCION --------------------
 || Pre-campo del parametro : jbcod_nivel1
 */ -----------------------------------------------------
 --
 PROCEDURE p_v_jbcod_nivel1;
 --
 /* -------------------- DESCRIPCION --------------------
 || Valida el parametro : jbcod_nivel1
 */ -----------------------------------------------------
 --
 PROCEDURE p_pre_jbcod_agt;
 --
 /* -------------------- DESCRIPCION --------------------
 || Pre-campo del parametro : jbcod_agt
 */ -----------------------------------------------------
 --
 PROCEDURE p_v_jbcod_agt;
 --
 /* -------------------- DESCRIPCION --------------------
 || Valida el parametro : jbcod_agt
 */ -----------------------------------------------------
 --
 PROCEDURE p_pre_jbnum_riesgo;
 --
 /* -------------------- DESCRIPCION --------------------
 || Pre-campo del parametro : jbnum_riesgo
 */ -----------------------------------------------------
 --
 PROCEDURE p_pre_jbcod_spto;
 --
 /* -------------------- DESCRIPCION --------------------
 || Pre-campo del paramtro : jbcod_spto
 */ -----------------------------------------------------
 --
 PROCEDURE p_v_jbcod_spto;
 --
 /* -------------------- DESCRIPCION --------------------
 || Valida el paramtro : jbcod_spto
 */ -----------------------------------------------------
 --
 PROCEDURE p_pre_jbsub_cod_spto;
 --
 /* -------------------- DESCRIPCION --------------------
 || Pre-campo del parametro : jbsub_cod_spto
 */ -----------------------------------------------------
 --
 PROCEDURE p_v_jbsub_cod_spto;
 --
 /* -------------------- DESCRIPCION --------------------
 || Valida el parametro : jbsub_cod_spto
 */ -----------------------------------------------------
 --
 PROCEDURE p_pre_jbtxt_motivo_spto;
 --
 /* -------------------- DESCRIPCION --------------------
 || Pre-campo del parametro : jbtxt_motivo_spto
 */ -----------------------------------------------------
 --
 PROCEDURE p_v_jbtxt_motivo_spto;
 --
 /* -------------------- DESCRIPCION --------------------
 || Valida el parametro : jbtxt_motivo_spto
 */ -----------------------------------------------------
 --
  PROCEDURE p_pre_jbcod_tip_spto;
 --
 /* -------------------- DESCRIPCION --------------------
 || Pre-campo del parametro : jbcod_tip_spto
 */ -----------------------------------------------------
 --
 PROCEDURE p_v_jbcod_tip_spto;
 --
 /* -------------------- DESCRIPCION --------------------
 || Valida el parametro : jbcod_tip_spto
 */ -----------------------------------------------------
 --
  PROCEDURE p_pre_jbcod_usr_captura;
 --
 /* -------------------- DESCRIPCION --------------------
 || Pre-campo del parametro : jbcod_usr_captura
 */ -----------------------------------------------------
 --
 PROCEDURE p_v_jbcod_usr_captura;
 --
 /* -------------------- DESCRIPCION --------------------
 || Valida el parametro :  jbcod_usr_captura
 */ -----------------------------------------------------
 --
 PROCEDURE p_pre_jbcab;
 --
 /* -------------------- DESCRIPCION --------------------
 || Pre-campo de los parametros que son cabeceras
 ||          - jbcab_anulacion_batch
 ||          - jbsub_cab_anulacion_batch
 ||          - jbcab_autoriza_batch
 ||          - jbsub_cab_autoriza_batch
 */ -----------------------------------------------------
 --
 PROCEDURE p_pre_jbanulacion;
 --
 /* -------------------- DESCRIPCION --------------------
 || Pre-campo de los parametros de procesos de anulacion
 ||          - jbcod_spto_as
 ||          - jbsub_cod_spto_as
 ||          - jbcod_spto_tmp
 ||          - jbsub_cod_spto_tmp
 ||          - jbcod_spto_re
 ||          - jbsub_cod_spto_re
 */ -----------------------------------------------------
 --
 PROCEDURE p_v_jbcod_spto_as;
 --
 /* -------------------- DESCRIPCION --------------------
 || Valida el parametro : jbcod_spto_as
 */ -----------------------------------------------------
 --
 PROCEDURE p_pre_jbsub_cod_spto_as;
 --
 /* -------------------- DESCRIPCION --------------------
 || Pre-campo del parametro : jbsub_cod_spto_as
 */ -----------------------------------------------------
 --
 PROCEDURE p_v_jbsub_cod_spto_as;
 --
 /* -------------------- DESCRIPCION --------------------
 || Valida el parametro : jbsub_cod_spto_as
 */ -----------------------------------------------------
 --
 PROCEDURE p_pre_jbcod_tip_spto_as;
 --
 /* -------------------- DESCRIPCION --------------------
 || Pre-campo del parametro : jbcod_tip_spto_as
 */ -----------------------------------------------------
 --
 PROCEDURE p_v_jbcod_tip_spto_as;
 --
 /* -------------------- DESCRIPCION --------------------
 || Valida el parametro : jbcod_tip_spto_as
 */ -----------------------------------------------------
 --
 PROCEDURE p_v_jbcod_spto_tmp;
 --
 /* -------------------- DESCRIPCION --------------------
 || Valida el parametro : jbcod_spto_tmp
 */ -----------------------------------------------------
 --
 PROCEDURE p_pre_jbsub_cod_spto_tmp;
 --
 /* -------------------- DESCRIPCION --------------------
 || Pre-campo del parametro : jbsub_cod_spto_tmp
 */ -----------------------------------------------------
 --
 PROCEDURE p_v_jbsub_cod_spto_tmp;
 --
 /* -------------------- DESCRIPCION --------------------
 || Valida el parametro : jbsub_cod_spto_tmp
 */ -----------------------------------------------------
 --
 PROCEDURE p_pre_jbcod_tip_spto_tmp;
 --
 /* -------------------- DESCRIPCION --------------------
 || Pre-campo del parametro : jbcod_tip_spto_tmp
 */ -----------------------------------------------------
 --
 PROCEDURE p_v_jbcod_tip_spto_tmp;
 --
 /* -------------------- DESCRIPCION --------------------
 || Valida el parametro : jbcod_tip_spto_tmp
 */ -----------------------------------------------------
 --
 PROCEDURE p_v_jbcod_spto_aa;
 --
 /* -------------------- DESCRIPCION --------------------
 || Valida el parametro : jbcod_spto_aa
 */ -----------------------------------------------------
 --
 PROCEDURE p_pre_jbsub_cod_spto_aa;
 --
 /* -------------------- DESCRIPCION --------------------
 || Pre-campo del parametro : jbsub_cod_spto_aa
 */ -----------------------------------------------------
 --
 PROCEDURE p_v_jbsub_cod_spto_aa;
 --
 /* -------------------- DESCRIPCION --------------------
 || Valida el parametro : jbsub_cod_spto_aa
 */ -----------------------------------------------------
 --
 PROCEDURE p_pre_jbcod_tip_spto_aa;
 --
 /* -------------------- DESCRIPCION --------------------
 || Pre-campo del parametro : jbcod_tip_spto_aa
 */ -----------------------------------------------------
 --
 PROCEDURE p_v_jbcod_tip_spto_aa;
 --
 /* -------------------- DESCRIPCION --------------------
 || Valida el parametro : jbcod_tip_spto_aa
 */ -----------------------------------------------------
 --
 PROCEDURE p_v_jbcod_spto_re;
 --
 /* -------------------- DESCRIPCION --------------------
 || Valida el parametro : jbcod_spto_re
 */ -----------------------------------------------------
 --
 PROCEDURE p_pre_jbsub_cod_spto_re;
 --
 /* -------------------- DESCRIPCION --------------------
 || Pre-campo del parametro : jbsub_cod_spto_re
 */ -----------------------------------------------------
 --
 PROCEDURE p_v_jbsub_cod_spto_re;
 --
 /* -------------------- DESCRIPCION --------------------
 || Valida el parametro : jbsub_cod_spto_re
 */ -----------------------------------------------------
 --
 PROCEDURE p_pre_jbcod_tip_spto_re;
 --
 /* -------------------- DESCRIPCION --------------------
 || Pre-campo del parametro : jbcod_tip_spto_re
 */ -----------------------------------------------------
 --
 PROCEDURE p_v_jbcod_tip_spto_re;
 --
 /* -------------------- DESCRIPCION --------------------
 || Valida el parametro : jbcod_tip_spto_re
 */ -----------------------------------------------------
 --
 PROCEDURE p_pre_jbcontrol_tecnico;
 --
 /* -------------------- DESCRIPCION --------------------
 || Pre-campo de los datos de control tecnico
 ||          - jbcod_nivel_salto
 ||          - jbcod_error
 ||          - jbcod_usr_cia
 ||          - tip_autoriza_ct
 */ -----------------------------------------------------
 --
 PROCEDURE p_v_jbcod_usr_cia;
 --
 /* -------------------- DESCRIPCION --------------------
 || Valida el parametro : jbcod_usr_cia
 */ -----------------------------------------------------
 --
 PROCEDURE p_v_jbcod_nivel_salto;
 --
 /* -------------------- DESCRIPCION --------------------
 || Valida el parametro : jbcod_nivel_salto
 */ -----------------------------------------------------
 --
 PROCEDURE p_v_jbcod_error;
 --
 /* -------------------- DESCRIPCION --------------------
 || Valida el parametro : jbcod_error
 */ -----------------------------------------------------
 --
 PROCEDURE p_v_tip_autoriza_ct;
 --
 /* -------------------- DESCRIPCION --------------------
 || Valida el parametro : tip_autoriza_ct
 */ -----------------------------------------------------
 --
 PROCEDURE p_pre_jbfec_desde;
 --
 /* -------------------- DESCRIPCION --------------------
 || Pre-campo del parametro : jbfec_desde
 */ -----------------------------------------------------
 --
 PROCEDURE p_v_jbfec_desde;
 --
 /* -------------------- DESCRIPCION --------------------
 || Valida el parametro : jbfec_desde
 */ -----------------------------------------------------
 --
 PROCEDURE p_pre_jbfec_hasta;
 --
 /* -------------------- DESCRIPCION --------------------
 || Pre-campo del parametro : jbfec_hasta
 */ -----------------------------------------------------
 --
 PROCEDURE p_v_jbfec_hasta;
 --
 /* -------------------- DESCRIPCION --------------------
 || Valida el parametro : jbfec_hasta
 */ -----------------------------------------------------
 --
 PROCEDURE p_pre_jbmax_num_riesgos;
 --
 /* -------------------- DESCRIPCION --------------------
 || Pre-campo del parametro : jbmax_num_riesgos
 */ -----------------------------------------------------
 --
 PROCEDURE p_pre_jbmca_grupos;
 --
 /* -------------------- DESCRIPCION --------------------
 || Pre-campo del parametro : jbmca_grupos
 */ -----------------------------------------------------
 --
 PROCEDURE p_v_jbmca_grupos;
 --
 /* -------------------- DESCRIPCION --------------------
 || Valida el parametro : jbmca_grupos
 */ -----------------------------------------------------
 --
 PROCEDURE p_pre_jbcant_registros;
 --
 /* -------------------- DESCRIPCION --------------------
 || Pre-campo del parametro : jbcant_registros
 */ -----------------------------------------------------
 --
 PROCEDURE p_pre_jbmca_ejecuta_filtro;
 --
 /* -------------------- DESCRIPCION --------------------
 || Pre-campo del parametro : p_pre_jbmca_ejecuta_filtro
 */ -----------------------------------------------------
 --
 PROCEDURE p_v_jbmca_ejecuta_filtro;
 --
 /* -------------------- DESCRIPCION --------------------
 || Valida el parametro : p_v_jbmca_ejecuta_filtro
 */ -----------------------------------------------------
 --
 PROCEDURE p_v_jbmca_reproceso;
 --
 /* -------------------- DESCRIPCION --------------------
 || Valida el parametro : jbmca_reproceso
 */ -----------------------------------------------------
 --
 PROCEDURE p_pre_jbmca_aborta_emision;
 --
 /* -------------------- DESCRIPCION --------------------
 || Pre-campo del parametro : jbmca_aborta_emision
 */ -----------------------------------------------------
 --
 PROCEDURE p_v_jbmca_aborta_emision;
 --
 /* -------------------- DESCRIPCION --------------------
 || Valida el parametro : jbmca_aborta_emision
 */ -----------------------------------------------------
 --
  --
 PROCEDURE p_pre_jbcod_spto_susp_pa;
 --
 /* -------------------- DESCRIPCION --------------------
 || Pre-campo del parametro : jbcod_spto_susp_pa
 */ -----------------------------------------------------
 --
 PROCEDURE p_v_jbcod_spto_susp_pa;
 --
 /* -------------------- DESCRIPCION --------------------
 || Valida el parametro : jbcod_spto_susp_pa
 */ -----------------------------------------------------
 --
  --
 PROCEDURE p_pre_jbsub_cod_spto_susp_pa;
 --
 /* -------------------- DESCRIPCION --------------------
 || Pre-campo del parametro : jbsub_cod_spto_susp_pa
 */ -----------------------------------------------------
 --
 PROCEDURE p_v_jbsub_cod_spto_susp_pa;
 --
 /* -------------------- DESCRIPCION --------------------
 || Valida el parametro : jbsub_cod_spto_susp_pa
 */ -----------------------------------------------------
 --
  --
 PROCEDURE p_pre_jbcod_tip_spto_susp_pa;
 --
 /* -------------------- DESCRIPCION --------------------
 || Pre-campo del parametro : jbcod_tip_spto_susp_pa
 */ -----------------------------------------------------
 --
 PROCEDURE p_v_jbcod_tip_spto_susp_pa;
 --
 /* -------------------- DESCRIPCION --------------------
 || Valida el parametro : jbcod_tip_spto_susp_pa
 */ -----------------------------------------------------
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
                     p_num_poliza_tronador a2000500.num_poliza_tronador %TYPE DEFAULT NULL);
 --
 /* -------------------- DESCRIPCION --------------------
 || Realiza la ejecucion directa del proceso
 */ -----------------------------------------------------
 --
END em_k_batch_trn;
