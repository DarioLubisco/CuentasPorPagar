import main
from uvicorn import Server, Config

print("Import successful, attempting to start server...")
config = Config(app=main.app, port=8000, host="0.0.0.0", log_level="debug")
server = Server(config=config)
server.run()




