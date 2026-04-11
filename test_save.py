import traceback
import asyncio
import main

async def test():
    try:
        payload = {
            'CodProv': 'V023190479', 
            'BaseDiasCredito': 'EMISION', 
            'DiasNoIndexacion': 0, 
            'DiasVencimiento': 20, 
            'Descuentos': [{'DiasDesde': 0, 'DiasHasta': 3, 'Porcentaje': 10.0, 'DeduceIVA': True}], 
            'DescuentoBase_Pct': 10.0, 
            'DescuentoBase_Condicion': 'VENCIMIENTO', 
            'DescuentoBase_DeduceIVA': True, 
            'Email': 'test@test.com', 
            'IndexaIVA': True, 
            'DecimalesTasa': 4, 
            'TipoPersona': 'PJ'
        }
        res = await main.update_provider_condition('V023190479', main.ProveedorCondicion(**payload))
        print(res)
    except Exception as e:
        traceback.print_exc()

asyncio.run(test())
