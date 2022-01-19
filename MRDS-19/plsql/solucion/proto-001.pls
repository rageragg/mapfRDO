DECLARE
    -- ----------------------------------------------------------
    -- Autor : CARRIERHOUSE, RGUERRA               Version : 1.11
    -- Fecha : 19-ene-2022                      Sismas : 
    -- Crea .: Se crea para verificar el tipo de gestos y 
    --       : su codigo, para que se mantengan igual al original
    --       : luego de la pre-renovacion
    -- ----------------------------------------------------------   
    -- 
    -- parametros
    p_num_orden             a2000500.num_orden%TYPE := 4;
    p_fec_tratamiento       DATE;
    --
    l_tip_mvto_batch        CONSTANT NUMBER(1)      := 1;
    l_tip_pre_renovacion    CONSTANT NUMBER(1)      := 2;
    --
    g_cod_cia               a2000500.cod_cia%TYPE   := 6;
    --
    -- cursor que realiza la seleccion luego de la pre-renovacion
    CURSOR c_a2000500 IS
        SELECT *
          FROM a2000500
         WHERE fec_tratamiento = p_fec_tratamiento
           AND num_orden       = p_num_orden 
           AND cod_cia         = g_cod_cia
           AND tip_situ       IN ( 3, 6 )                 
           AND tip_mvto_batch IN ( l_tip_mvto_batch, l_tip_pre_renovacion )     
         ORDER BY num_poliza, num_spto;
    --
    -- seleccionamos las polizas asociadas al proceso, antes de la renovacion
    CURSOR c_a2000030(  pc_num_poliza    a2000030.num_poliza%TYPE,
                        pc_num_spto      a2000030.num_spto%TYPE,
                        pc_num_apli      a2000030.num_apli%TYPE,
                        pc_num_apli_spto a2000030.num_apli_spto%TYPE
                     ) IS
        SELECT *
          FROM a2000030 a
          WHERE cod_cia            = g_cod_cia
            AND num_poliza         = pc_num_poliza
            AND num_spto           = pc_num_spto
            AND num_apli           = pc_num_apli
            AND num_apli_spto      = pc_num_apli_spto
            AND tip_gestor        IN ( 'TA', 'DB' );
    --
    -- seleccionamos las polizas listas para renovar
    CURSOR c_r2000030(  pc_num_poliza   r2000030.num_poliza%TYPE,
                        pc_num_spto     r2000030.num_spto%TYPE,
                        pc_num_apli     r2000030.num_apli%TYPE,
                       pc_num_apli_spto r2000030.num_apli_spto%TYPE 
                     ) IS
        SELECT *
          FROM r2000030 a
          WHERE cod_cia            = g_cod_cia
            AND num_poliza         = pc_num_poliza
            AND num_spto           = pc_num_spto
            AND num_apli           = pc_num_apli
            AND num_apli_spto      = pc_num_apli_spto;     
    --
    -- seleccionamos los recibos antes de la renovacion
    CURSOR c_a2990700(  pc_num_poliza    a2000030.num_poliza%TYPE,
                        pc_num_spto      a2000030.num_spto%TYPE,
                        pc_num_apli      a2000030.num_apli%TYPE,
                        pc_num_apli_spto a2000030.num_apli_spto%TYPE
                     ) IS
        SELECT *
          FROM a2990700 a
          WHERE cod_cia            = g_cod_cia
            AND num_poliza         = pc_num_poliza
            AND num_spto           = pc_num_spto
            AND num_apli           = pc_num_apli
            AND num_apli_spto      = pc_num_apli_spto;
    --   
    -- seleccionamos los recibos para renovar
    CURSOR c_r2990700(  pc_num_poliza    a2000030.num_poliza%TYPE,
                        pc_num_spto      a2000030.num_spto%TYPE,
                        pc_num_apli      a2000030.num_apli%TYPE,
                        pc_num_apli_spto a2000030.num_apli_spto%TYPE,
                        pc_num_recibo    r2990700.num_recibo%TYPE
                     ) IS
        SELECT *
          FROM r2990700 a
          WHERE cod_cia            = g_cod_cia
            AND num_poliza         = pc_num_poliza
            AND num_spto           = pc_num_spto
            AND num_apli           = pc_num_apli
            AND num_apli_spto      = pc_num_apli_spto
            AND num_recibo         = pc_num_recibo;
    --     
    r_reno  c_r2000030%ROWTYPE;
    r_reci  c_r2990700%ROWTYPE;
    --         
    -- procedimiento interno para aplicar cambios de la polizas a renovar
    PROCEDURE pp_modificar_rpoliza( p_orig c_a2000030%ROWTYPE ) IS 
    BEGIN 
        --
        UPDATE r2000030
           SET tip_gestor = p_orig.tip_gestor,
               tip_gestor = p_orig.cod_gestor
         WHERE cod_cia            = r_reno.cod_cia
           AND num_poliza         = r_reno.num_poliza
           AND num_spto           = r_reno.num_spto
           AND num_apli           = r_reno.num_apli
           AND num_apli_spto      = r_reno.num_apli_spto;
        --
        EXCEPTION
            WHEN NO_DATA_FOUND THEN 
                RETURN;
            WHEN OTHERS THEN 
                -- denunciar el error
                dbms_output.put_line(SQLERRM);
        --                 
    END pp_modificar_rpoliza;
    --         
    -- procedimiento interno para aplicar cambios de la polizas a renovar
    PROCEDURE pp_modificar_rrecibos( p_orig c_a2990700%ROWTYPE ) IS 
    BEGIN 
        --
        UPDATE r2990700
           SET tip_gestor = p_orig.tip_gestor,
               tip_gestor = p_orig.cod_gestor
         WHERE cod_cia            = p_orig.cod_cia
           AND num_poliza         = p_orig.num_poliza
           AND num_spto           = p_orig.num_spto
           AND num_apli           = p_orig.num_apli
           AND num_apli_spto      = p_orig.num_apli_spto
           AND num_recibo         = p_orig.num_recibo;
        --
        EXCEPTION
            WHEN NO_DATA_FOUND THEN 
                RETURN;
            WHEN OTHERS THEN 
                -- denunciar el error
                dbms_output.put_line(SQLERRM);
        --                 
    END pp_modificar_rpoliza;
    -- 
BEGIN
    --
    -- seleccionamos las polizas para su verificacion
    FOR r_batch IN c_a2000500 LOOP
        --
        -- seleccionamos los datos originales de la poliza
        FOR r_orig IN c_a2000030( r_batch.num_poliza, r_batch.num_spto, r_batch.num_apli, r_batch.num_apli_spto ) LOOP 
            --
            -- comparamos los datos originales con los datos del batch
            OPEN c_r2000030( r_orig.num_poliza, r_orig.num_spto, r_orig.num_apli, r_orig.num_apli_spto );
            FETCH c_r2000030 INTO r_reno;
            IF c_r2000030%FOUND THEN
                IF r_reno.tip_gestor != r_orig.tip_gestor OR r_reno.cod_gestor != r_orig.cod_gestor THEN 
                    --
                    -- se aplica el cambio
                    pp_modificar_rpoliza( p_orig => r_orig );
                    --
                END IF;
            END IF;
            CLOSE c_r2000030;
            --
            -- seleccionamos los recibos originales de la poliza
            FOR r_rorig IN c_a2990700( r_orig.num_poliza, r_orig.num_spto, r_orig.num_apli, r_orig.num_apli_spto ) LOOP  
                --
                -- comparamos los datos originales con los datos del batch
                OPEN c_r2990700( r_rorig.num_poliza, r_rorig.num_spto, r_rorig.num_apli, r_rorig.num_apli_spto, r_rorig.num_recibo );
                FETCH c_r2990700 INTO r_reci;
                IF c_r2990700%FOUND THEN
                    IF r_reci.tip_gestor != r_rorig.tip_gestor OR r_rorig.cod_gestor != r_rorig.cod_gestor THEN 
                        --
                        -- se aplica el cambio
                        pp_modificar_rrecibos( p_orig => r_rorig );
                        --
                    END IF;
                END IF;
                CLOSE c_r2990700;
                --
            END LOOP;
            --
        END LOOP;
        --
    END LOOP;
    --
END;