from fastapi import FastAPI
from pydantic import BaseModel

app = FastAPI()

# Original message to replace when using delete
original_message = "Hello World!"

# "Database" simulation
class Message:
    def __init__(self):
        self.message = original_message
        
current_message = Message()

# Request body
class MessageRequest(BaseModel):
    message: str

# Get current message
@app.get("/message")
@app.get("/message/")
def get_message():
    return {"code": 200, "message": f"{current_message.message}"}

# Change the message
@app.put("/message")
@app.put("/message/")
def patch_message(data: MessageRequest):
    current_message.message = data.message
    return {"code": 200, "message": "Success"}

# Go back to original message
@app.delete("/message")
@app.delete("/message/")
def delete_message():
    current_message.message = original_message
    return {"code": 200, "message": "Success"}
