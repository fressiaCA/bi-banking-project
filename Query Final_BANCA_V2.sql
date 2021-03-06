CREATE DATABASE DWH_FINANCIERA
GO
USE DWH_FINANCIERA
GO


--DIMENSION PRODUCTO
IF OBJECT_ID('DIM_PRODUCTOS') IS NOT NULL
DROP TABLE DIM_PRODUCTOS
GO

select Codigo_Producto,Descripcion_Producto,Tipo_Producto
--INTO DIM_PRODUCTOS
from (
select distinct
case 
		when SALDO_TARJETA IS NOT NULL and SALDO_PASIVO=0.00 then '001'
		when SALDO_ACTIVO >0.00 and SALDO_HIPOTECARIO>0 then '002'
		when SALDO_ACTIVO >0.00 and SALDO_VEHICULAR>0 then '003'
		when SALDO_ACTIVO >0.00 and SALDO_LIBREDISPONIBILIDAD>0 then '004'
		when SALDO_PASIVO >0.00 and SALDO_CTS>0 and SALDO_ACTIVO=0.00 then '005'
		when SALDO_AHORRO >0 and SALDO_PASIVO >0.00 and SALDO_CTS=0  and SALDO_ACTIVO=0.00 then '006'
		when SALDO_PASIVO >0.00 and SALDO_FONDOS>0 and SALDO_ACTIVO=0.00 then '007'
		when SALDO_PASIVO >0.00 and SALDO_CORRIENTE>0 and SALDO_ACTIVO=0.00 then '008'
		when SALDO_ACTIVO >0.00 and SALDO_CONSUMO>0 and SALDO_PASIVO=0.00 then '009'
		--else '010'
		end as Codigo_Producto,
	case 
		when SALDO_TARJETA IS NOT NULL and SALDO_PASIVO=0.00 then 'Tarjeta Credito'
		when SALDO_ACTIVO >0.00 and SALDO_HIPOTECARIO>0 then 'Hipotecario'
		when SALDO_ACTIVO >0.00 and SALDO_VEHICULAR>0 then 'Vehicular'
		when SALDO_ACTIVO >0.00 and SALDO_LIBREDISPONIBILIDAD>0 then 'Libre Disponibilidad'
		when SALDO_PASIVO >0.00 and SALDO_CTS>0 and SALDO_ACTIVO=0.00 then 'CTS'
		when SALDO_AHORRO >0 and SALDO_PASIVO >0.00 and SALDO_CTS=0 and SALDO_ACTIVO=0.00 then 'Cuenta Ahorro'
		when SALDO_PASIVO >0.00 and SALDO_FONDOS>0 and SALDO_ACTIVO=0.00 then 'Fondos Mutuos'
		when SALDO_PASIVO >0.00 and SALDO_CORRIENTE>0 and SALDO_ACTIVO=0.00 then 'Cuenta Corriente'
		when SALDO_ACTIVO >0.00 and SALDO_CONSUMO>0 and SALDO_PASIVO=0.00 then 'Producto Consumo'
		---else 'Otros'
		end as Descripcion_Producto,
		case
		when SALDO_ACTIVO >0.00  then 'Activo'
		when SALDO_PASIVO >0.00  then 'Pasivo'
		--else 'Multiproducto'
		end as Tipo_Producto
from BD_FINANCIERA.dbo.BD_PRODUCTOS

) pr
where Codigo_Producto is not null 
order by Codigo_Producto asc
GO

ALTER TABLE DIM_PRODUCTOS ALTER COLUMN Codigo_Producto CHAR(3) NOT NULL
GO

ALTER TABLE DIM_PRODUCTOS
ADD CONSTRAINT PK_Codigo_Producto PRIMARY KEY (Codigo_Producto)
GO


--DETALLE PRODUCTO

alter view v_detalle_producto as
select distinct ROW_NUMBER() OVER(ORDER BY Codigo_Cliente) [Codigo_Principal] 
      ,dp.*
from 

(
select 
     
      CONCAT(a.Codigo_Cliente,a.MES_PROCESO) as Codigo_cliente_mes ,
      a.Codigo_Cliente as codigo_Cliente,
	  case 
		when SALDO_TARJETA IS NOT NULL and SALDO_PASIVO=0.00 then '001'
		when SALDO_ACTIVO >0.00 and SALDO_HIPOTECARIO>0 then '002'
		when SALDO_ACTIVO >0.00 and SALDO_VEHICULAR>0 then '003'
		when SALDO_ACTIVO >0.00 and SALDO_LIBREDISPONIBILIDAD>0 then '004'
		when SALDO_PASIVO >0.00 and SALDO_CTS>0 and SALDO_ACTIVO=0.00 then '005'
		when SALDO_AHORRO >0 and SALDO_PASIVO >0.00 and SALDO_CTS=0  and SALDO_ACTIVO=0.00 then '006'
		when SALDO_PASIVO >0.00 and SALDO_FONDOS>0 and SALDO_ACTIVO=0.00 then '007'
		when SALDO_PASIVO >0.00 and SALDO_CORRIENTE>0 and SALDO_ACTIVO=0.00 then '008'
		when SALDO_ACTIVO >0.00 and SALDO_CONSUMO>0 and SALDO_PASIVO=0.00 then '009'
		--else '009'
	  end as Codigo_Producto,
        a.MES_PROCESO,
        SALDO_PASIVO,
		[SALDO_ACTIVO],
		[SALDO_TARJETA],
		[SALDO_AHORRO],
		[SALDO_PLAZO],
		[SALDO_CORRIENTE],
		[SALDO_FONDOS],
		[SALDO_CTS],
		[SALDO_CONSUMO],
		[SALDO_HIPOTECARIO],
		[SALDO_BOLSA],
		[SALDO_VEHICULAR],
		[SALDO_LIBREDISPONIBILIDAD]

from FACT_CLIENTE a
inner join BD_FINANCIERA.dbo.BD_PRODUCTOS b
on a.Codigo_Cliente=b.codigo 
COLLATE SQL_Latin1_General_CP1_CI_AS
and a.MES_PROCESO =b.MES_PROCESO
COLLATE SQL_Latin1_General_CP1_CI_AS
) dp
where Codigo_Producto is not null


truncate  table [dbo].[DETALLE_PRODUCTO]


INSERT INTO DETALLE_PRODUCTO
select * 
from v_detalle_producto



ALTER TABLE DETALLE_PRODUCTO ALTER COLUMN Codigo_Principal CHAR(50) NOT NULL
GO

ALTER TABLE DETALLE_PRODUCTO
ADD PRIMARY KEY (Codigo_Principal)
GO



ALTER TABLE DETALLE_PRODUCTO
ADD FOREIGN KEY (Codigo_cliente_mes) references FACT_CLIENTE(Codigo_cliente_mes)

ALTER TABLE DETALLE_PRODUCTO
ADD FOREIGN KEY (Codigo_Producto) references DIM_PRODUCTOS(Codigo_Producto)



select count(Codigo_Principal),Codigo_Principal
from [dbo].[DETALLE_PRODUCTO]
group by Codigo_Principal
having count(Codigo_Principal) >=2
--DIMENSION RANGO EDAD



[dbo].[DIM_PRODUCTOS]






IF OBJECT_ID('DIM_RANGO_EDAD') IS NOT NULL
DROP TABLE DIM_RANGO_EDAD
GO

select  distinct
case
when EDAD>=18 and EDAD<30 then '001'
when EDAD>=30 and EDAD<40 then '002'
when EDAD>=40 and EDAD<50 then '003'
when EDAD>=50 and EDAD<=65 then '004'
when EDAD>65 then '005'
else '006'
end as 'Codigo_Rango_Edad',
case
when EDAD>=18 and EDAD<30 then '<18-30>'
when EDAD>=30 and EDAD<40 then '<30-40>'
when EDAD>=40 and EDAD<50 then '<40-50>'
when EDAD>=50 and EDAD<=65 then '<50-65>'
when EDAD>65 then '>65'
else '<18'
end as 'Rango_Edad'
into DIM_RANGO_EDAD
from BD_FINANCIERA.dbo.BD_CLIENTE
order by 1 asc
GO

ALTER TABLE DIM_RANGO_EDAD
ALTER COLUMN Codigo_Rango_Edad varchar(3) not null
GO

ALTER TABLE DIM_RANGO_EDAD
ADD CONSTRAINT PK_Codigo_Rango_Edad PRIMARY KEY (Codigo_Rango_Edad)
GO

--DIMENSION SEXO

--Validamos si la dimension existe
IF OBJECT_ID('DIM_SEXO') IS NOT NULL
DROP TABLE DIM_SEXO
GO

select distinct
Codigo_Sexo =	case
				when SEXO NOT IN ('M','F') then 'J'
				else SEXO END,
Descripcion_Sexo = case
					when SEXO='M' then 'Masculino'
					when SEXO='F' then 'Femenino'
					else 'Juridica' END
INTO DIM_SEXO
from BD_FINANCIERA.dbo.BD_CLIENTE
WHERE SEXO IS NOT NULL
GO

ALTER TABLE DIM_SEXO
ALTER COLUMN Codigo_Sexo VARCHAR(3) not null
GO

ALTER TABLE DIM_SEXO
ADD CONSTRAINT PK_Codigo_Sexo PRIMARY KEY (Codigo_Sexo)
GO

-- DIMENSION UBIGEO

IF OBJECT_ID('DIM_UBIGEO') IS NOT NULL
DROP TABLE DIM_UBIGEO
GO

SELECT DISTINCT COD_UBIGEO,DEPARTAMENTO,PROVINCIA,DISTRITO   
INTO [dbo].[DIM_UBIGEO]
FROM BD_FINANCIERA.dbo.UBIGEO
GO

ALTER TABLE DIM_UBIGEO ALTER COLUMN COD_UBIGEO VARCHAR(7) NOT NULL
GO

ALTER TABLE DIM_UBIGEO
ADD CONSTRAINT PK_Codigo_Ubigeo PRIMARY KEY (COD_UBIGEO)
GO

--DIMENSION ESTADO CIVIL

IF OBJECT_ID('DIM_ESTADO_CIVIL') IS NOT NULL
DROP TABLE DIM_ESTADO_CIVIL
GO

		SELECT DISTINCT
			  Codigo_Estado_Civil = CASE WHEN ESTADO_CIVIL NOT IN ('C','S') THEN 'O'
										ELSE ESTADO_CIVIL END,
			  Descripci?n_Estado_Civil= CASE WHEN ESTADO_CIVIL='C' THEN 'CASADO'
										   WHEN ESTADO_CIVIL='S' THEN 'SOLTERO'
										   ELSE 'OTROS' END
		INTO DIM_ESTADO_CIVIL
		FROM BD_FINANCIERA.dbo.BD_CLIENTE 
		WHERE ESTADO_CIVIL IS NOT NULL
GO


ALTER TABLE DIM_ESTADO_CIVIL
ALTER COLUMN Codigo_Estado_Civil varchar(1) not null
GO

ALTER TABLE DIM_ESTADO_CIVIL
ADD CONSTRAINT PK_Codigo_Estado_Civil PRIMARY KEY (Codigo_Estado_Civil)
GO

--DIMENSION SEGMENTO

IF OBJECT_ID('DIM_SEGMENTO') IS NOT NULL
DROP TABLE DIM_SEGMENTO
GO

SELECT DISTINCT COD_SEGMENTO, DESC_SEGMENTO
INTO [dbo].[DIM_SEGMENTO]
FROM   [BD_FINANCIERA].[dbo].[SEGMENTO] 
GO

ALTER TABLE DIM_SEGMENTO
ALTER COLUMN COD_SEGMENTO VARCHAR(6) not null
GO

ALTER TABLE DIM_SEGMENTO
ADD CONSTRAINT PK_Codigo_Segmento PRIMARY KEY (COD_SEGMENTO)
GO


IF OBJECT_ID('DIM_REPORTADO_SBS') IS NOT NULL
DROP TABLE DIM_REPORTADO_SBS
GO

SELECT DISTINCT
Codigo_Reportado = REPORTADO_SBS,
Descripcion_Reportado = case when REPORTADO_SBS = 0 then 'Reportado'
							when REPORTADO_SBS = 1 then 'No Reportado' 
							END
into DIM_REPORTADO_SBS
from BD_FINANCIERA.dbo.BD_CLIENTE
GO

ALTER TABLE DIM_REPORTADO_SBS
ALTER COLUMN Codigo_Reportado varchar(1) not null
GO

ALTER TABLE DIM_REPORTADO_SBS
ADD CONSTRAINT PK_Codigo_Reportado PRIMARY KEY (Codigo_Reportado)
GO


--DIM CANAL

IF OBJECT_ID('DIM_CANAL') IS NOT NULL
DROP TABLE DIM_CANAL
GO

SELECT DISTINCT
CASE 
WHEN cv.Descripcion_Canal = 'OFICINA' THEN '01' 
WHEN cv.Descripcion_Canal = 'CAJERO' THEN '02' 
WHEN cv.Descripcion_Canal = 'INTERNET' THEN '03' 
WHEN cv.Descripcion_Canal = 'TELEFONO' THEN '04' 

END AS Codigo_Canal,* 
INTO DIM_CANAL
	FROM (
	(SELECT
	CASE 
	WHEN NTRX_OFICINA > 0 AND NTRX_OFICINA IS NOT NULL THEN 'OFICINA' 
	END AS Descripcion_Canal
	FROM BD_FINANCIERA.dbo.BD_TRANSACCIONES
	WHERE NTRX_OFICINA >0  AND NTRX_OFICINA IS NOT NULL)
	UNION ALL
	(SELECT
	CASE 
	WHEN NTRX_CAJERO > 0 AND NTRX_CAJERO IS NOT NULL THEN 'CAJERO' 
	END AS Descripcion_Canal
	FROM BD_FINANCIERA.dbo.BD_TRANSACCIONES
	WHERE NTRX_CAJERO >0  AND NTRX_CAJERO IS NOT NULL)
	UNION ALL
	(SELECT
	CASE 
	WHEN NTRX_INTERNET > 0 AND NTRX_INTERNET IS NOT NULL THEN 'INTERNET' 
	END AS Descripcion_Canal
	FROM BD_FINANCIERA.dbo.BD_TRANSACCIONES
	WHERE NTRX_INTERNET >0  AND NTRX_INTERNET IS NOT NULL)
	UNION ALL 
	(SELECT
	CASE 
	WHEN NTRX_TELEFONO > 0 AND NTRX_TELEFONO IS NOT NULL THEN 'TELEFONO' 
	END AS Descripcion_Canal
	FROM BD_FINANCIERA.dbo.BD_TRANSACCIONES
	WHERE NTRX_TELEFONO >0  AND NTRX_TELEFONO IS NOT NULL) 
	) cv
GO

ALTER TABLE DIM_CANAL
ALTER COLUMN Codigo_Canal varchar(2) not null
GO

ALTER TABLE DIM_CANAL
ADD CONSTRAINT PK_Codigo_Canal PRIMARY KEY (Codigo_Canal)
GO

--DIM  PERSONA

IF OBJECT_ID('DIM_PERSONA') IS NOT NULL
DROP TABLE DIM_PERSONA
GO

select distinct
Codigo_Persona = case when SEXO in ('M','F') then '001'
						else '002' END,
Descripcion_Persona = case when SEXO in ('M','F') then 'Persona Natural'
							else 'Persona Juridica' END
into DIM_PERSONA
from BD_FINANCIERA.dbo.BD_CLIENTE
GO


ALTER TABLE DIM_PERSONA
ALTER COLUMN Codigo_Persona varchar(3) not null
GO

ALTER TABLE DIM_PERSONA
ADD CONSTRAINT PK_Codigo_Persona PRIMARY KEY (Codigo_Persona)
GO


--DIMENSION OCUPACI?N
IF OBJECT_ID('DIM_OCUPACION') IS NOT NULL
DROP TABLE DIM_OCUPACION
--GO

select distinct
OCUPACION as Codigo_Ocupacion,
case 
when OCUPACION=1 then 'DEPENDIENTE'
when OCUPACION=2 then 'EMPRESARIO'
when OCUPACION=3 then 'INDEPENDIENTE FORMAL'
when OCUPACION=4 then 'INDEPENDIENTE INFORMAL'
when OCUPACION=5 then 'OTROS'
end as Descripcion_Ocupacion
into DIM_OCUPACION
from BD_FINANCIERA.dbo.BD_CLIENTE
GO

ALTER TABLE DIM_OCUPACION
ALTER COLUMN Codigo_Ocupacion varchar(50) not null
GO

ALTER TABLE DIM_OCUPACION
ADD CONSTRAINT PK_Codigo_Ocupacion PRIMARY KEY (Codigo_Ocupacion)
GO


--DIM_AGENCIA
IF OBJECT_ID('DIM_AGENCIA') IS NOT NULL
DROP TABLE DIM_AGENCIA
GO

--SELECT *
--INTO [dbo].[DIM_AGENCIA]
--from (

         SELECT DISTINCT COD_AGENCIA,
               BANCA = case   when BANCA != 'SIN ESPECIFICAR' then BANCA ELSE NULL END,
			   ZONA = case  when ZONA != 'SIN ESPECIFICAR' then ZONA else NULL END,
			   AGENCIA = case  when AGENCIA != 'SIN ESPECIFICAR' then AGENCIA ELSE NULL END
		  INTO [dbo].[DIM_AGENCIA]
		  FROM BD_FINANCIERA.dbo.AGENCIA
--) ag
-- where BANCA IS NOT NULL
-- GO

 
ALTER TABLE DIM_AGENCIA ALTER COLUMN COD_AGENCIA VARCHAR(7) not null
GO

ALTER TABLE DIM_AGENCIA
ADD CONSTRAINT PK_Codigo_Agencia PRIMARY KEY (COD_AGENCIA)
GO
 
--DIM_TRANSACCIONES X CANAL




IF OBJECT_ID('TRANSACCIONES') IS NOT NULL
DROP TABLE TRANSACCIONES
--GO

select  ROW_NUMBER() OVER(ORDER BY a.CODIGO) [Codigo_TRX],
        CONCAT(a.CODIGO,a.MES_PROCESO) as codigo_cliente_mes
		,a.codigo as Codigo_Cliente
		,[NTRX_OFICINA]
		,[NTRX_CAJERO]
		,[NTRX_INTERNET]
		,[NTRX_TELEFONO]
		,t.MES_PROCESO
		,CASE 
			WHEN NTRX_OFICINA > 0 AND NTRX_OFICINA IS NOT NULL THEN 'OFICINA'  
			WHEN NTRX_CAJERO > 0 AND NTRX_CAJERO IS NOT NULL THEN 'CAJERO' 
			WHEN NTRX_INTERNET > 0 AND NTRX_INTERNET IS NOT NULL THEN 'INTERNET' 
			WHEN NTRX_TELEFONO > 0 AND NTRX_TELEFONO IS NOT NULL THEN 'TELEFONO' 
		END AS Descripcion_Canal	
--INTO [dbo].[TRANSACCIONES]
from BD_FINANCIERA.[dbo].[BD_TRANSACCIONES] t
inner join BD_FINANCIERA.[dbo].BD_CLIENTE a 
on a.CODIGO=t.codigo and a.MES_PROCESO =t.MES_PROCESO
GO



ALTER TABLE TRANSACCIONES ALTER COLUMN Codigo_TRX VARCHAR(10) not null
GO
ALTER TABLE TRANSACCIONES ALTER COLUMN codigo_cliente_mes VARCHAR(16) not null
GO
ALTER TABLE TRANSACCIONES
ADD CONSTRAINT PK_COD_TRX PRIMARY KEY (Codigo_TRX)
GO


delete from TRANSACCIONES
delete from RENTABILIDAD

/************/
ALTER TABLE  TRANSACCIONES WITH NOCHECK
ADD FOREIGN KEY (codigo_cliente_mes) REFERENCES FACT_CLIENTE (codigo_cliente_mes)

select * from TRANSACCIONES

--RENYTABILIDAD
IF OBJECT_ID('RENTABILIDAD') IS NOT NULL
DROP TABLE RENTABILIDAD

SELECT 
     ROW_NUMBER() OVER(ORDER BY a.CODIGO) [Codigo_Rentabilidad],
     CONCAT(a.CODIGO,a.MES_PROCESO) as codigo_cliente_mes
	,a.codigo as Codigo_Cliente
	,r.MES_PROCESO
	,[RENTABILIDAD_MES]
	,[RENTABILIDAD_ACUMULADA]
	,[RENTABILIDAD_AHORRO]
	,[RENTABILIDAD_FONDOS]
	,[RENTABILIDAD_PLAZO]
	,[RENTABILIDAD_BOLSA]
	,[RENTABILIDAD_CTS]
	,[RENTABILIDAD_CONSUMO]
	,[RENTABILIDAD_HIPOTEACARIO]
	,[RENTAILIDAD_TARJETA]
INTO [dbo].[RENTABILIDAD]
from BD_FINANCIERA.[dbo].BD_RENTABILIDADES r
inner join BD_FINANCIERA.[dbo].BD_CLIENTE a 
on a.CODIGO=r.codigo and a.MES_PROCESO =r.MES_PROCESO


ALTER TABLE RENTABILIDAD ALTER COLUMN Codigo_Rentabilidad VARCHAR(10) not null
GO
ALTER TABLE RENTABILIDAD ALTER COLUMN codigo_cliente_mes VARCHAR(16) not null
GO
ALTER TABLE RENTABILIDAD
ADD CONSTRAINT PK_COD_RENTABILIDAD PRIMARY KEY (Codigo_Rentabilidad)
GO


/************/
ALTER TABLE  RENTABILIDAD WITH NOCHECK
ADD FOREIGN KEY (codigo_cliente_mes) REFERENCES FACT_CLIENTE (codigo_cliente_mes)


--DIM TIEMPO

create table DIM_Tiempo
(
Fecha date PRIMARY KEY,
A?o nvarchar(30),
Mes varchar(2),
desMes	nvarchar(30),
MES_PROCESO nvarchar(30),
Dia nvarchar(30),
desDia nvarchar(30),
trimestre nvarchar(30),
semestre nvarchar(30)
)

--declaracion de variables
declare @CurrentDate date, @EndDate date

set @CurrentDate= '20120101'
set @EndDate = '20151231'

--bucle de carga
while @CurrentDate <= @EndDate begin
insert into DIM_Tiempo
(
	Fecha,
	A?o,
	Mes,desMes,
	MES_PROCESO,
	Dia,
	desDia,
	trimestre,
	semestre
)
values(
	@CurrentDate,
	DATEPART(year , @CurrentDate) ,
	DATEPART(month , @CurrentDate),
	DATENAME(month, @CurrentDate),
	CAST(DATEPART(year , @CurrentDate) as char(4))
        + RIGHT('0'+CAST(DATEPART(month , @CurrentDate) AS varchar(2)),2),

	DATEPART(dw , @CurrentDate),
	DATENAME(dw, @CurrentDate),
	DATEPART(quarter , @CurrentDate),
	CASE WHEN DATEPART(quarter , @CurrentDate) < 3 THEN 1
           ELSE 2
        END

)
set @CurrentDate = dateadd(day,1,@CurrentDate)

end
GO



--FACT_CLIENTE
IF OBJECT_ID('FACT_CLIENTE') IS NOT NULL
DROP TABLE FACT_CLIENTE
GO

CREATE TABLE FACT_CLIENTE(
codigo_cliente_mes varchar(16) primary key not null,
Codigo_Cliente VARCHAR(10),
Codigo_Producto char (3) NOT NULL,
Codigo_Rango_edad varchar(3) NOT NULL,
Codigo_Sexo varchar(3) NOT NULL,
Codigo_Estado_Civil varchar(1) NOT NULL,
Codigo_Ubigeo VARCHAR(7) NOT NULL,
Codigo_Segmento VARCHAR(6) NOT NULL,
Codigo_Agencia VARCHAR(7) NOT NULL,
Codigo_Persona varchar(3) NOT NULL,
Fecha date,
Codigo_Reportado varchar(1) NOT NULL,
Codigo_Ocupacion varchar(50) NOT NULL,
Ingreso_Sueldo decimal(9,2),
INGRESO_SCORE decimal(21,2),
INGRESO_BD decimal(12,2),
INGRESO_REPORTADOCLIENTE decimal(12,0),
mes_proceso varchar(6),
CONSTRAINT FK_Producto FOREIGN KEY (Codigo_Producto) REFERENCES DIM_PRODUCTOS(Codigo_Producto),
CONSTRAINT FK_EstadoCivil FOREIGN KEY (Codigo_Estado_Civil) REFERENCES DIM_ESTADO_CIVIL(Codigo_Estado_Civil),
CONSTRAINT FK_Ocupacion FOREIGN KEY (Codigo_Ocupacion) REFERENCES DIM_OCUPACION(Codigo_Ocupacion),
CONSTRAINT FK_Persona FOREIGN KEY (Codigo_Persona) REFERENCES DIM_PERSONA(Codigo_Persona),
CONSTRAINT FK_Edad FOREIGN KEY (Codigo_Rango_Edad) REFERENCES DIM_RANGO_EDAD(Codigo_Rango_Edad),
CONSTRAINT FK_RepSBS FOREIGN KEY (Codigo_Reportado) REFERENCES DIM_REPORTADO_SBS(Codigo_Reportado),
CONSTRAINT FK_Segmento FOREIGN KEY (Codigo_Segmento) REFERENCES DIM_SEGMENTO(COD_SEGMENTO),
CONSTRAINT FK_Sexo FOREIGN KEY (Codigo_Sexo) REFERENCES DIM_SEXO(Codigo_Sexo),
CONSTRAINT FK_Ubigeo FOREIGN KEY (Codigo_Ubigeo) REFERENCES DIM_UBIGEO(COD_UBIGEO),
CONSTRAINT FK_Agencia FOREIGN KEY (Codigo_Agencia) REFERENCES DIM_AGENCIA(COD_AGENCIA),
CONSTRAINT FK_Tiempo FOREIGN KEY (Fecha) REFERENCES DIM_Tiempo(Fecha)
)
GO




select * from [dbo].[DIM_PRODUCTOS]
select * from [dbo].[DIM_AGENCIA]


ALTER TABLE DETALLE_PRODUCTO ALTER COLUMN Codigo_cliente_mes VARCHAR(16) not null
GO

alter table MiTabla add constraint PK_MiTabla primary key (Campo1, Campo2)




ALTER TABLE  DETALLE_PRODUCTO --WITH NOCHECK
ADD FOREIGN KEY (Codigo_cliente_mes) REFERENCES FACT_CLIENTE (Codigo_cliente_mes)



SELECT * FROM [dbo].[DETALLE_PRODUCTO]