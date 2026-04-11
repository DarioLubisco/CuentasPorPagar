import asyncio
import main

async def read():
    res = await main.get_provider_conditions()
    for prov in res['data']:
        if prov.get('DescuentoBase_Pct', 0) > 0 or len(prov.get('Descuentos', [])) > 0:
            print("Prov", prov['CodProv'], "Descuentos:", prov.get('Descuentos', []), "Base_DeduceIVA:", prov.get('DescuentoBase_DeduceIVA'))

if __name__ == '__main__':
    asyncio.run(read())
