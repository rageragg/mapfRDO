DECLARE
    --
    -- parametros
    g_cod_cia               a2000500.cod_cia%TYPE;
    g_fec_tratamiento       DATE;
    g_tip_mvto_batch        a2000500.tip_mvto_batch%TYPE;
    g_num_orden             a2000500.num_orden%TYPE := 4;       
    --
    -- carga los valores globales
    PROCEDURE pp_valores_globales IS 
    BEGIN 
        --
        g_fec_tratamiento   := to_date( trn_k_global.devuelve( 'FEC_TRATAMIENTO' ), 'ddmmyyyy');
        g_cod_cia           := trn_k_global.devuelve( 'COD_CIA' );
        g_tip_mvto_batch    := trn_k_global.devuelve( 'TIP_MVTO_BATCH' );
        --
    END pp_valores_globales;
    --
    -- procesamos polizas
    PROCEDURE pp_procesar_poliza( p_num_poliza    a2000030.num_poliza%TYPE,
                                  p_num_spto      a2000030.num_spto%TYPE,
                                  p_num_apli      a2000030.num_apli%TYPE,
                                  p_num_spto_apli a2000030.num_spto_apli%TYPE
                                ) IS 
        --
        -- seleccionamos las polizas asociadas al proceso, antes de la renovacion
        CURSOR c_a2000030 IS
            SELECT rowid id, cod_fracc_pago, tip_gestor, cod_gestor
              FROM a2000030 a
             WHERE cod_cia            = g_cod_cia
               AND num_poliza         = p_num_poliza
               AND num_spto           = p_num_spto
               AND num_apli           = p_num_apli
               AND num_spto_apli      = p_num_spto_apli
               AND tip_gestor        IN ( 'TA', 'DB' );    
        -- 
        -- seleccionamos las polizas listas para renovar
        CURSOR c_r2000030 IS
            SELECT rowid id, cod_fracc_pago, tip_gestor, cod_gestor,
                   'N' actualiza_gestor,
                   'N' actualiza_fraccionamiento
              FROM r2000030 a
             WHERE cod_cia            = g_cod_cia
               AND num_poliza         = p_num_poliza;                   
        --       
        -- registros
        r_a2000030 c_a2000030%ROWTYPE;
        r_r2000030 c_r2000030%ROWTYPE;
        --
    BEGIN 
        --
        -- tomamos la poliza original
        OPEN c_a2000030;
        FETCH c_a2000030 INTO r_a2000030;
        IF c_a2000030%FOUND THEN 
            --
            OPEN c_r2000030;
            FETCH c_r2000030 INTO r_r2000030;
            IF c_r2000030%FOUND THEN
                --
                -- verificamos si el gestor cambio
                IF r_r2000030.tip_gestor != r_a2000030.tip_gestor OR r_r2000030.cod_gestor != r_a2000030.cod_gestor THEN 
                	r_r2000030.actualiza_gestor := 'S';
                END IF;
                --
                -- verificamos si el codigo de fracciones de pago cambio
                IF r_r2000030.cod_fracc_pago != r_a2000030.cod_fracc_pago THEN 
                    r_r2000030.actualiza_fraccionamiento := 'S';
                END IF;
                --
            END IF;
            CLOSE c_r2000030;
            --
            -- se actualiza el gestor
            IF r_r2000030.actualiza_gestor = 'S' THEN 
              	UPDATE r2000030
                   SET tip_gestor = r_a2000030.tip_gestor,
                       cod_gestor = r_a2000030.cod_gestor
                 WHERE rowid = r_a2000030.id;      
            END IF;
            --
            -- se actualiza el fracciones de pago
            IF r_r2000030.actualiza_fraccionamiento = 'S' THEN 
              	UPDATE r2000030
                   SET cod_fracc_pago = r_a2000030.cod_fracc_pago
                 WHERE rowid = r_a2000030.id;      
            END IF;
            --
        END IF;
        CLOSE c_a2000030;
        --
    END pp_procesar_poliza;
    --
    PROCEDURE pp_procesar_polizas IS 
      --
      -- cursor que realiza la seleccion luego de la pre-renovacion
      CURSOR c_a2000500 IS
          SELECT *
           FROM a2000500
          WHERE fec_tratamiento = g_fec_tratamiento
            AND num_orden       = g_num_orden 
            AND cod_cia         = g_cod_cia
            AND tip_mvto_batch  = g_tip_mvto_batch     
            AND tip_situ       IN ( 3, 6 )                 
          ORDER BY num_poliza, num_spto;
      --      
    BEGIN
      --
      FOR r_poliza IN c_a2000500 LOOP
        --
        pp_procesar_poliza( p_num_poliza    => r_poliza.num_poliza,
                            p_num_spto      => r_poliza.num_spto,
                            p_num_apli      => r_poliza.num_apli,
                            p_num_spto_apli => r_poliza.num_spto_apli
                          ); 
        -- 
      END LOOP;
      -- 
    END pp_procesar_polizas;
    --
BEGIN
    --
    -- se carga los valores globales del proceso
    pp_valores_globales;
    --
    --
    -- procesamos la polizas en a2000500 en prerenovacion
    pp_procesar_polizas;
    --
END;