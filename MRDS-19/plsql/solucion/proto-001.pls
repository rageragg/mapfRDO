declare
    --
    g_cod_cia               a1000900.cod_cia%TYPE := 6;
    g_fec_tratamiento       DATE;
    --
    -- cursor que realiza la seleccion luego de la pre-renovacion
    CURSOR cl_a2000500 IS
        SELECT *
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
begin
end;