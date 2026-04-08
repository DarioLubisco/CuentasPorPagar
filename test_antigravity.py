import asyncio
from main import run_antigravity_optimizer, AntigravityRequest

async def main():
    payload = AntigravityRequest(porcentaje_flujo=0.9)
    try:
        res = await run_antigravity_optimizer(payload)
        print("Success!", res.keys() if isinstance(res, dict) else res)
    except Exception as e:
        import traceback
        traceback.print_exc()

if __name__ == "__main__":
    asyncio.run(main())
