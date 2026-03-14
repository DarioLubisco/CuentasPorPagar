# Referencia Técnica: Tablas Saint Administrativo — Módulo Compras & CxP

> **Fuente**: `dict_output.json` (C:\source) + esquema live de `EnterpriseAdmin_AMC` + SQL Traces `Compra_Con_Retencion.sql` / `Compra_Con_Retencion-2.sql`

Este documento describe las tablas involucradas en el procesamiento de una compra (factura de proveedor) y el módulo de Cuentas por Pagar en Saint Administrativo. Está diseñado para ser pasado como contexto a un agente IA en una nueva conversación.

---

## Relación General Entre Tablas

```
SAPROV (Proveedor)
  └── SACOMP (Encabezado Compra)
        ├── SAACXP TipoCxP='10' (Deuda principal en CxP)
        │     ├── SAPAGCXP (Detalle de pago / retención aplicada)
        │     └── SAIPACXP (Forma de pago interna de la compra)
        └── SAACXP TipoCxP='81' (Retención de IVA creada por la compra)
              └── SAPAGCXP (Enlace de la retención con la deuda principal)
```

---

## 1. `SACOMP` — Encabezado de Compras

**Propósito**: Registro maestro de cada compra (factura recibida del proveedor). Es el punto de entrada del proceso. Cada fila = una factura.

| Campo | Tipo | Descripción |
|---|---|---|
| `NumeroD` | varchar | **PK lógica**. Número de documento/factura del proveedor |
| `NroUnico` | int | Identificador único interno auto-incremental |
| `CodProv` | varchar | Código del proveedor (FK → SAPROV) |
| `TipoCom` | varchar | Tipo de compra: `H`=Compra de Mercancía |
| `CodSucu` | varchar | Código de sucursal (`00000` = principal) |
| `CodUsua` | varchar | Usuario que ingresó la compra (ej: `LREYES`) |
| `CodEsta` | varchar | **Estación/workstation** desde donde se ingresó (ej: `ADM-3`) |
| `FechaI` | datetime | Fecha de ingreso al sistema |
| `FechaE` | datetime | Fecha de emisión de la factura |
| `FechaV` | datetime | Fecha de vencimiento (para crédito) |
| `FechaP` | datetime | Fecha de pago efectivo |
| `FechaT` | datetime | Timestamp de la transacción |
| `FecCadReten` | datetime | Fecha de caducidad de la retención |
| `MtoTotal` | decimal | Monto total de la factura (con IVA) |
| `Monto` | decimal | Monto base (sin IVA) |
| `MtoTax` | decimal | Monto del IVA |
| `TGravable` | decimal | Base imponible gravada |
| `TExento` | decimal | Monto exento de IVA |
| `RetenIVA` | decimal | Monto de retención de IVA calculado |
| `**Contado**` | decimal | **Si > 0: factura pagada al momento del ingreso (CONTADO)**. Causa problema: genera pago automático en SAPAGCXP y pone Saldo=0 en SAACXP |
| `**Credito**` | decimal | **Si > 0: factura a crédito**. Queda pendiente en SAACXP con Saldo = MtoTotal |
| `CodOper` | varchar | Operación relacionada: `CXP`=genera cuenta por pagar |
| `NroCtrol` | varchar | Número de control fiscal (ej: `00-001417`) |
| `NumeroR` | varchar | Número de la retención de IVA generada |
| `Signo` | smallint | `1`=Normal, `-1`=Reversal/devolución |
| `NroUnico` | int | Referencia interna |

**⚠️ Error de entrada frecuente**: Si el operador deja `FechaV = FechaI` pero hay días de crédito reales, Saint marca `Contado > 0` en lugar de `Credito > 0`. Esto genera un pago automático falso en `SAPAGCXP` y borra el saldo en `SAACXP`.

---

## 2. `SAACXP` — Cuentas por Pagar

**Propósito**: Libro mayor de Cuentas por Pagar. Cada fila representa una obligación con un proveedor. **Una misma factura puede generar 2 filas**: la deuda principal (TipoCxP=`10`) y la retención de IVA (TipoCxP=`81`).

| Campo | Tipo | Descripción |
|---|---|---|
| `NroUnico` | int | **PK**. Identificador único del registro en CxP |
| `NroRegi` | int | FK hacia otro registro de SAACXP (usado en retenciones: apunta a la deuda principal) |
| `NumeroD` | varchar | Número de documento/factura (FK → SACOMP.NumeroD) |
| `CodProv` | varchar | Código del proveedor (FK → SAPROV) |
| `TipoCxP` | varchar | **Tipo de registro**: `10`=Deuda de factura principal, `81`=Retención de IVA |
| `Monto` | decimal | Monto original de la obligación |
| `MontoNeto` | decimal | Monto neto (descontando retenciones) |
| `**Saldo**` | decimal | **Saldo pendiente de pago**. Si = 0 → pagada. Si = Monto → pendiente |
| `SaldoAct` | decimal | Saldo acumulado del proveedor en este ciclo |
| `SaldoOrg` | decimal | Saldo original al momento de creación |
| `MtoTax` | decimal | IVA de la factura |
| `RetenIVA` | decimal | Monto de retención de IVA |
| `BaseImpo` | decimal | Base imponible |
| `TExento` | decimal | Monto exento |
| `FechaI` | datetime | Fecha de ingreso (igual a SACOMP.FechaI) |
| `FechaE` | datetime | Fecha de emisión factura |
| `FechaV` | datetime | Fecha de vencimiento |
| `FechaT` | datetime | Timestamp de transacción |
| `CodEsta` | varchar | Estación de trabajo |
| `CodUsua` | varchar | Usuario |
| `CodOper` | varchar | Operación origen: `CXP` |
| `EsUnPago` | smallint | `1`=Este registro es un pago aplicado, `0`=es una factura |
| `EsReten` | smallint | `1`=Este registro es una retención |
| `CancelT` | decimal | Monto cancelado en total |
| `EsLibroI` | smallint | `1`=Registrado en libro de compras |

**Relaciones clave**:
- `SAACXP.NumeroD` → `SACOMP.NumeroD` (JOIN para ligar factura con deuda)
- `SAACXP.NroUnico` → `SAPAGCXP.NroRegi` (los pagos aplicados a esta deuda)
- Cuando TipoCxP=`81`: `SAACXP.NroRegi` → `SAACXP.NroUnico` del TipoCxP=`10` (la retención apunta a su factura principal)

---

## 3. `SAPAGCXP` — Detalle de Pagos de CxP

**Propósito**: Tabla de pagos aplicados. Cada fila = un pago o retención aplicada a una cuenta por pagar. **Una factura puede tener 2 filas**: el pago principal y la retención de IVA.

| Campo | Tipo | Descripción |
|---|---|---|
| `NroUnico` | int | PK. Identificador único del pago |
| `NroPpal` | int | FK → `SAACXP.NroUnico` de la retención (TipoCxP=81) que origina este pago |
| `NroRegi` | int | FK → `SAACXP.NroUnico` de la deuda principal (TipoCxP=10) a la que se aplica |
| `NumeroD` | varchar | Número de documento asociado (factura original o número de retención) |
| `Monto` | decimal | Monto del pago aplicado |
| `MontoDocA` | decimal | Monto total del documento al que se aplica |
| `EsReten` | smallint | `1`=Este pago es una retención de IVA |
| `CodRete` | varchar | Código de retención (`IVA`) |
| `BaseReten` | decimal | Base sobre la que se calculó la retención |
| `RetenIVA` | decimal | Monto retenido de IVA |
| `FechaE` | datetime | Fecha de pago |
| `FechaO` | datetime | Fecha del documento original |
| `CodProv` | varchar | Código del proveedor |
| `TipoCxP` | varchar | Tipo de CxP (heredado de SAACXP) |

**Lógica del JOIN en SAACXP↔SAPAGCXP**:
```sql
-- Para ver los pagos aplicados a una deuda:
SAPAGCXP.NroRegi = SAACXP.NroUnico   -- SAACXP es la DEUDA (TipoCxP='10')
-- Para ver la retención que generó el pago:
SAPAGCXP.NroPpal = SAACXP.NroUnico   -- SAACXP es la RETENCIÓN (TipoCxP='81')
```

**⚠️ El query de referencia usa**: `SAACXP.NroUnico = SAPAGCXP.NroUnico` — esto trae los pagos donde SAACXP actúa como la retención. Para traer todo con la deuda, usar `SAPAGCXP.NroRegi = SAACXP.NroUnico`.

---

## 4. `SAIPACXP` — Forma de Pago Interna de la Compra

**Propósito**: Registra **cómo** se realizó el pago al momento del ingreso. Tabla auxiliar ligada a `SAACXP`. En el caso de compras a crédito con retención, aquí se registra la retención de IVA como forma de pago inicial al proveedor.

| Campo | Tipo | Descripción |
|---|---|---|
| `NroUnico` | int | PK. Identificador único |
| `NroPpal` | int | FK → `SAACXP.NroUnico` al que pertenece |
| `CodTarj` | varchar | Código de la forma de pago (ej: `008`=Retención IVA) |
| `Descrip` | varchar | Descripción (ej: `Retencion de IVA`) |
| `TipoPag` | int | Tipo de pago: `7`=Retención |
| `TipoTra` | int | Tipo de transacción |
| `Monto` | decimal | Monto de esta forma de pago |
| `FechaE` | datetime | Fecha de pago |
| `Factor` | decimal | Factor de cambio (tasa) |
| `MontoMEx` | decimal | Monto en moneda extranjera (USD) |
| `Refere` | varchar | Referencia de la retención (ej: `IVA`) |
| `RetencT` | decimal | Base de la retención |
| `CodOper` | varchar | Código de operación |

**Rol en el proceso**: Cuando en el trace vemos `INSERT INTO SAIPACOM` (no `SAIPACXP`, nótese que `SAIPACOM` es para compras y `SAIPACXP` para pagos), registra la forma de pago inicial. `SAIPACXP` es consultada en el módulo de CxP para ver histórico de pagos.

---

## 5. `SAPROV` — Proveedores

**Propósito**: Maestro de proveedores. Catálogo principal. Cada proveedor tiene un único `CodProv`.

| Campo | Tipo | Descripción |
|---|---|---|
| `CodProv` | varchar | **PK**. Código único del proveedor (= RIF) |
| `Descrip` | varchar | Nombre del proveedor |
| `ID3` | varchar | RIF adicional / identificador fiscal |
| `Activo` | smallint | `1`=Activo |
| `DiasCred` | int | Días de crédito por defecto |
| `EsReten` | smallint | `1`=Sujeto a retención de IVA |
| `RetenIVA` | decimal | Acumulado de retenciones de IVA procesadas |
| `PorctRet` | decimal | Porcentaje de retención aplicable |
| `Saldo` | decimal | Saldo total pendiente con este proveedor |
| `MontoMax` | decimal | Crédito máximo autorizado |
| `FechaUC` | datetime | Fecha de la última compra |
| `MontoUC` | decimal | Monto de la última compra |
| `NumeroUC` | varchar | Número de la última compra |
| `FechaUP` | datetime | Fecha del último pago |
| `MontoUP` | decimal | Monto del último pago |

---

## Flujo Completo de una Compra a Crédito con Retención (desde los traces)

Observado en `Compra_Con_Retencion.sql` — Factura 1417, Proveedor SUMINISTROS PHARMA GLOBAL, Usuario `LREYES`, Estación `ADM-3`:

```
1. UPDATE SAEXIS    → Actualiza existencias (pedido)
2. UPDATE/INSERT SAPROD  → Actualiza costos del producto
3. INSERT SALOTE    → Registra el lote de mercancía
4. INSERT SAITEMCOM → Líneas de la compra (ítems)
5. INSERT SATAXITC  → IVA por ítem
6. INSERT SACOMP    → ENCABEZADO: Contado=2490.75 (retención), Credito=24126.51
7. INSERT SATAXCOM  → Impuesto del documento
8. UPDATE SAPROV    → Actualiza último movimiento del proveedor
9. INSERT SAIPACOM  → Forma de pago: Retención de IVA (TipoPag=7, Monto=2490.75)
10. INSERT SAACXP (TipoCxP='10') → Deuda principal: Saldo=24126.51
11. EXEC SP_ADM_PROXCORREL → Genera número de retención automático
12. INSERT SAACXP (TipoCxP='81') → Registro de retención: Monto=2490.75, NroRegi=NroUnico del step 10
13. INSERT SAPAGCXP → Enlaza retención (NroPpal=NroUnico_81) con deuda (NroRegi=NroUnico_10)
14. UPDATE SACOMP   → Guarda NumeroR = número de retención generado
15. COMMIT
```

---

## La Query de Referencia Explicada

```sql
FROM dbo.SAACXP                          -- Tabla central: cada deuda/obligación
LEFT OUTER JOIN dbo.SAPAGCXP             -- Pagos aplicados a esa deuda
  ON SAACXP.NroUnico = SAPAGCXP.NroUnico -- ⚠️ Este join trae la RETENCIÓN como SAACXP (TipoCxP=81)
LEFT OUTER JOIN dbo.SAPROV               -- Datos del proveedor
  ON SAACXP.CodProv = SAPROV.CodProv
LEFT OUTER JOIN dbo.SAIPACXP             -- Formas de pago internas
  ON SAACXP.NroUnico = SAIPACXP.NroUnico
RIGHT OUTER JOIN dbo.SACOMP              -- Encabezado de la compra (driver del RIGHT JOIN)
  ON SAACXP.NumeroD = SACOMP.NumeroD    -- Trae TODAS las compras, incluso sin CxP
```

> El `RIGHT OUTER JOIN` con `SACOMP` garantiza que aparezcan **todas las facturas**, aunque no tengan registro en `SAACXP` (ej: si se ingresaron como CONTADO puro sin generar CxP). El `LEFT JOIN` con `SAPAGCXP` vía `SAACXP.NroUnico = SAPAGCXP.NroUnico` une a través del registro de **retención** (TipoCxP=`81`), por eso `SAPAGCXP.NumeroD` en ese caso muestra el número de la retención, no el de la factura.
