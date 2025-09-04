class Message:
   def __init__(self,txt):
       self.m=txt
   def __str__(self):
       return f"{self.m}"


class SecureMessage(Message):
    pass
