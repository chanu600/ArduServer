CREATE OR REPLACE PACKAGE CERT_SERVICIOS.ABM_AUDITORIA
    IS
    TYPE TResultadoCurType IS REF CURSOR;
    
  cursor cEstadistica  (fechadesde date, fechahasta date )IS 
             select decode(ft,null,dt,trunc(ft)) vfecha ,
                     decode(ft,null,'00000',cod_respuesta) vcodrespuesta ,
                     decode(ft,null,'SIN CONSULTAS',DESCRIPCION) vDESCRIPCION  ,
                     decode(ft,null,0,Cantidad)vCantidad
            from         ( select     trunc(FechaDesde + rownum -1) dt     ,'00000', '', 0  --la tabla A son todas las fechas entre fdesde y hasta
                                            from dual 
                                            connect by level <= FechaHasta - FechaDesde + 1
                                         
                              )a , 
                            (  Select  trunc(L.TSTAMP) ft ,L.cod_respuesta,C.DESCRIPCION as Descripcion ,count(1) as Cantidad                             
                                           From     CODIGOS_RESPUESTA   C ,LOG  L
                                            Where   L.COD_RESPUESTA   (+)  = C.COD_RESPUESTA
                                           AND L.TSTAMP >= FechaDesde
                                            AND L.TSTAMP < FechaHasta + 1
                                            and    L.COD_OPERACION = 3 
                                            Group by  trunc(L.TSTAMP),L.cod_respuesta,C.DESCRIPCION
                           ) b
                where     a.dt = b.ft (+)
                 Order by  1,2;

    PROCEDURE Genera_Auditoria
    (
        oSPErrorCode            OUT NUMBER,
        oSPErrorDesc            OUT VARCHAR2
    );
    
    PROCEDURE getAUDITORIA
    (
        oSPErrorCode        OUT NUMBER,
        oSPErrorDesc        OUT VARCHAR2,
        oCURSOR             OUT TResultadoCurType
    );
    
    PROCEDURE EnviaError
    (
        oSPErrorCode        OUT NUMBER,
        oSPErrorDesc        OUT VARCHAR2
    );
    
    PROCEDURE GeneraEstadistica
    (
        oSPErrorCode        OUT NUMBER,
        oSPErrorDesc        OUT VARCHAR2
    );
 

 /* comentado a pedido de lean 
   PROCEDURE GeneraEstadisticaPorFecha
    (
        inddmmyyyy  in varchar2,
        oSPErrorCode        OUT NUMBER,
        oSPErrorDesc        OUT VARCHAR2
    );
   */
    PROCEDURE GeneraEstadisticaResumidoMes
    (
        oSPErrorCode        OUT NUMBER,
        oSPErrorDesc        OUT VARCHAR2
    );
    
END ABM_AUDITORIA;
/
