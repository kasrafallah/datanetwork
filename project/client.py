import socket
import threading
from PIL import Image
import os
FORMAT = 'utf-8'

class client_message:
    def __init__(self,msg):
        PORT = 5099
        SEVER = socket.gethostbyname(socket.gethostname())
        print(SEVER)
        ADDR = (SEVER, PORT)
        client = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        client.connect(ADDR)
        self.addr = ADDR
        self.conn = client
        self.message = msg
        self.header = msg.split('\n\n')[0]
        try:
            self.body = msg.split('\n\n')[1]
        except:
            self.body = ''
        self.method = self.header.split('\n')[0].split(' ')[0]
    def handel_msg(self):

        print(f'client is ready to send request to ({self.addr})')
        if self.method == 'POST'and self.body != '<html><body><h1>THISISFORBIDDEN!</h1></body></html>':
            self.post_request()
        else:
            self.conn.send(self.message.encode(FORMAT))
            self.response = self.conn.recv(2048).decode(FORMAT)
            print(self.response)
            if self.method == 'GET' and self.response.split('\n\n')[0].split('\n')[0].split(' ')[1] == '200':
                self.header_response = self.response.split('\n\n')[0]
                self.body_response = self.response.split('\n\n')[1]
                if self.method == 'GET' and self.header_response.split('\n')[0].split(' ')[1] == '200':
                    self.first_line = self.header.split('\n')[0].split(' ')
                    print(self.first_line[1].split('.')[1])
                    if self.first_line[1].split('.')[1] == 'png' or self.first_line[1].split('.')[1] == 'jpg' or self.first_line[1].split('.')[1] == 'txt':
                        file = self.first_line[1]
                        path = os.getcwd() + '\\' + 'client_files' + '\\' + file
                        length = self.header_response.split('\n')[2].split(': ')[1]
                        print('buffer size is:', length)
                        if length.isnumeric():
                            self.conn.send('im ready to receive'.encode(FORMAT))
                            data = self.conn.recv(int(length))
                            print(len(data), 'bytes is delivered to client')
                            myfile = open(path, 'wb')
                            myfile.write(data)
                            myfile.close()
                            print(f'{file} is saved in client files')
                        else:
                            print('error')
                            client.send('buffer size is not defined'.encode(FORMAT))




    def post_request(self):
        self.conn.send(self.header.encode(FORMAT))
        ok = self.conn.recv(2048).decode(FORMAT)
        print(ok)
        ok = ok.split('\n\n')[0].split('\n')[0].split(' ')[2]
        if ok == 'OK':
            self.conn.send(self.body.encode(FORMAT))




path = os.getcwd() + '\\' + 'client_files' + '\\' + '2.png'
data = open(path, 'rb').read()



msg1 = f"POST /// HTTP/1.0\nContent-Length: 100000\nContent-Type: text/html\n\ni'mn posting something for test"
msg2 = f"GET 1.jpg HTTP/1.0\nContent-Length: 100000\nContent-Type: text/html\n\ni want to receive something"
msg3 = f'baaaaaad rquesttttttt frofkrofk rfjrfjr'
msg4 = f"GET usa.jpg HTTP/1.0\nContent-Length: 100000\nContent-Type: text/html\n\ni want to receive something"
msg5 = f"HEAD usa.jpg HTTP/1.0\nContent-Length: 100000\nContent-Type: text/html\n\ni want to receive something"
msg6 = f"HAJI usa.jpg HTTP/1.0\nContent-Length: 100000\nContent-Type: text/html\n\ni want to receive something"
msg7 = f"POST /// HTTP/1.0\nContent-Length: 100000\nContent-Type: text/html\n\n<html><body><h1>THISISFORBIDDEN!</h1></body></html>"

msg = [msg1,msg2,msg3,msg4,msg5,msg6,msg7]
for i in msg:

    new = client_message(i)
    new.handel_msg()


