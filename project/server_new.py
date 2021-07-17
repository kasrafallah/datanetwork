import socket
import threading
import datetime
import os
import json
import PIL
import cv2
import time
############################################################
###                                                     ####
###              kasra fallah                           ####
###                                                     ####
############################################################

# DEFINE SEVER and useful variables
PORT = 5099
SEVER = socket.gethostbyname(socket.gethostname())
print(SEVER)
ADDR = (SEVER, PORT)
FORMAT = 'utf-8'

server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
server.bind(ADDR)

METHOD = ['PUT', 'POST', 'DELETE', 'HEAD', 'GET']
ALLOWED_METHODS = ["GET", "POST"]
HTTP_VERSION = ['HTTP/1.1', 'HTTP/1.0']
FILE_STATE = {"txt":0,"png":0,"jpg":0}
REQUEST_STATES = {'GET': 0,'PUT': 0,'POST': 0,'DELETE': 0,'HEAD': 0,'Improper': 0}
RESPONSE_STATES ={'400': 0,'501' : 0,'405' : 0,'200' : 0,'301' : 0,'403': 0}
counter_file = 1

class request:
    def __init__(self, conn, addr):
        self.conn = conn
        self.addr = addr
        self.time = datetime.datetime.now()
        self.msg = ''


    def request_header_check(self,msg):
        output = 0
        msg_Lines = msg.split('\n')
        #checking first line format
        first_line_list = msg_Lines[0].split(' ')
        if len(first_line_list) == 3:
            #checking next lines
            msg_Lines.pop(0)
            for line in msg_Lines:
                header = line.split(': ')
                if len(header) != 2 or not(first_line_list[2] in HTTP_VERSION):
                    print(first_line_list[0])
                    return 0

                else:
                    output = 1
        else:
            return 0
        if output == 1:
            if first_line_list[0] in METHOD:
                output = 2
            else:
                return 1
        if output ==2:
            if first_line_list[0] in ALLOWED_METHODS:
                output = 3
            else:
                return 2
        if output == 3:
            if first_line_list[0] == 'GET':
                file = self.msg.split("\n")[0].split(' ')[1]
                path = os.getcwd() + '\\' + 'sever_files' + '\\' + file
                if os.path.exists(path):
                    return 3
                else:
                    return 4
            else:
                output = 5
        if output == 5 and first_line_list[0] == 'POST'and self.body!="<html><body><h1>THISISFORBIDDEN!</h1></body></html>":

            return 5
        if output == 5 and first_line_list[0] == 'POST'and self.body=="<html><body><h1>THISISFORBIDDEN!</h1></body></html>":

            return 6


    def update_response_dictionary(self,response):
        temp = RESPONSE_STATES.get(response)
        temp = temp + 1
        RESPONSE_STATES.update({response: temp})
    def update_method_dictionary(self,response):
        temp = REQUEST_STATES.get(response)
        temp = temp + 1
        REQUEST_STATES.update({response: temp})
    def update_request_dictionary(self):
        self.method = self.header.split('\n')[0].split(' ')[0]
        if self.method == 'GET':
            self.update_method_dictionary('GET')
        elif self.method == 'POST':
            self.update_method_dictionary('POST')
        elif self.method == 'PUT':
            self.update_method_dictionary('PUT')
        elif self.method == 'DELETE':
            self.update_method_dictionary('DELETE')
        elif self.method == 'HEAD':
            self.update_method_dictionary('HEAD')
        else:
            self.update_method_dictionary('Improper')

    def handel_Telnet(self):
        label = True
        while label:
            if self.msg == 'number of connected clients':
                print('haji chakeratam')
                print(f'telnet response ==> number of active connections:{threading.activeCount()}')
                self.conn.send(f'number of active connections:{threading.activeCount()-1}'.encode(FORMAT))
            if self.msg == 'file type stats':
                print(f'Telnet connection:{self.addr}\nfile types states')
                self.conn.send(f'\nimage/jpg: {str(FILE_STATE.get("jpg"))}\ntext/txt: {str(FILE_STATE.get("txt"))}\nimage/png : {str(FILE_STATE.get("png"))}'.encode(FORMAT))
            if self.msg == 'request stats':
                print(f'Telnet connection:{self.addr}\nrequest stats')
                self.conn.send(f'\nGET: {str(REQUEST_STATES.get("GET"))}\nPUT: {str(REQUEST_STATES.get("PUT"))}\nPOST : {str(REQUEST_STATES.get("POST"))}\nDELETE: {str(REQUEST_STATES.get("DELETE"))}\nHEAD : {str(REQUEST_STATES.get("HEAD"))}\nImproper : {str(REQUEST_STATES.get("Improper"))}'.encode(FORMAT))
            if self.msg =='response stats':
                print(f'Telnet connection:{self.addr}\nresponse stats')
                self.conn.send(f'\n400: {str(RESPONSE_STATES.get("400"))}\n501: {str(RESPONSE_STATES.get("501"))}\n405 : {str(RESPONSE_STATES.get("405"))}\nDELETE: {str(RESPONSE_STATES.get("DELETE"))}\n200 : {str(RESPONSE_STATES.get("200"))}\n301 : {str(RESPONSE_STATES.get("301"))}\n403 : {str(RESPONSE_STATES.get("403"))}'.encode(FORMAT))
            if self.msg == 'disconnect':
                print("telnet disconnected")
                label = False
            self.msg = self.conn.recv(2048).decode(FORMAT)
        self.conn.close()


    def handel_client(self):
        #time.sleep(30)
        print(f'New connection:{self.addr} is connected\n')
        connected = True
        while connected:
            msg = self.conn.recv(2048).decode(FORMAT)
            self.msg = msg


            #check telnet connection
            if self.msg == 'number of connected clients' or self.msg == 'file type stats' or self.msg == 'request stats' or self.msg == 'response stats' or self.msg == 'disconnect':
                self.handel_Telnet()
                break
            try:#sperating body and header and save
                header = msg.split("\n\n")
                self.header = header[0]
                self.body = header[1]
            except:
                header =[msg]
                self.header = header[0]
                self.body =''

            check_num = self.request_header_check(self.header)
            print('check_num',check_num)
            self.update_request_dictionary()

            if check_num == 0:# bad request answer is  handeled here
                print(f'{self.addr} : {self.msg} ')
                self.conn.send(f'''HTTP/1.0 400 Bad Request\nConnection: close\nContent-Length: {len(msg.encode(FORMAT))}\nContent-Type: text/html\nDate: {datetime.datetime.now()}\n<html><body><h1>BADREQUEST!</h1></body></html>'''.encode(FORMAT))
                self.log('400')
                self.update_response_dictionary('400')
                connected = False
            elif check_num == 1:# Not Implemented
                print(f'{self.addr} : {self.msg} ')
                self.conn.send(f'''HTTP/1.0 501  Not Implemented\nConnection: close\nContent-Length: {len(msg.encode(FORMAT))}\nContent-Type: text/html\nDate: {datetime.datetime.now()}\n\n<html><body><h1>NOTIMPLEMENTED!</h1></body></html>'''.encode(FORMAT))
                self.log('501')
                self.update_response_dictionary('501')
                connected = False
            elif check_num == 2: #Not Allowed
                print(f'{self.addr} : {self.msg} ')
                self.conn.send(f'''HTTP/1.0 405  Not Allowed\nConnection: close\nContent-Length: {len(msg.encode(FORMAT))}\nContent-Type: text/html\nAllow: GET\nDate: {datetime.datetime.now()}\n<html><body><h1>NOTALLOWED!</h1></body></html>'''.encode(FORMAT))
                self.log('405')
                self.update_response_dictionary('405')
                connected = False
            elif check_num == 3:  # GET request

                print(f'{self.addr} :\n{self.msg} ')
                file = self.msg.split("\n")[0].split(' ')[1]
                path = os.getcwd() +'\\'+'sever_files'+'\\'+ file


                if file.split('.')[1] == 'jpg' :
                    temp = FILE_STATE.get('jpg')
                    temp = temp + 1
                    FILE_STATE.update({'jpg': temp})
                    fp = open(path, 'rb')
                    length = len(fp.read())
                elif file.split('.')[1] == 'png':
                    temp = FILE_STATE.get('png')
                    temp = temp + 1
                    FILE_STATE.update({'png': temp})
                    fp = open(path, 'rb')
                    length = len(fp.read())
                else:
                    temp = FILE_STATE.get('txt')
                    temp = temp + 1
                    FILE_STATE.update({'txt': temp})
                    fp = open(path,'r+').read()
                    length = len(fp.encode(FORMAT))

                self.conn.send(f'''HTTP/1.0 200 OK\nConnection: close\nContent-Length: {length}\nContent-Type: {file.split('.')[1]}\nAllow: GET\nDate: {datetime.datetime.now()}\n\n'''.encode(FORMAT))

                ok = self.conn.recv(2048).decode(FORMAT)
                print("client message:",ok)
                if ok =='im ready to receive':#handshake ok
                    temp = open(path, 'rb').read()
                    self.conn.send(temp)
                    self.log('200 OK')
                    self.update_response_dictionary('200')
                else:#handshake failed
                    self.log("200 Error")
                    self.update_response_dictionary('200')

                connected = False

            elif check_num == 4:#when file doesnt exsit
                print(f'{self.addr} : {self.msg} ')
                self.conn.send(f'''HTTP/1.0 301 Moved Permanently\nConnection: close\nContent-Length:{len(msg.encode(FORMAT))}\nContent-Type: text/html\nDate: {datetime.datetime.now()}\n\n<html><body><h1>MOVEDPERMANENTLY!</h1></body></html>'''.encode(FORMAT))
                self.log('301')
                self.update_response_dictionary('301')
                connected = False
            elif check_num == 5:# POST request
                print(f'{self.addr} : {self.msg} ')
                header_lines = self.header.split('\n')
                header_lines.pop(0)
                self.header_dictionary = {}
                error = 0
                for item in header_lines:
                    temp = item.split(': ')
                    temp_dict ={temp[0]:temp[1]}
                    self.header_dictionary.update(temp_dict)
                a =str(datetime.datetime.now()).split('.')[0].split(':')[0]+str(datetime.datetime.now()).split('.')[0].split(':')[1]+str(datetime.datetime.now()).split('.')[0].split(':')[2]+str(datetime.datetime.now()).split('.')[1]
                try:
                    self.type = self.header_dictionary.get('Content-Type')
                    self.length = self.header_dictionary.get('Content-Length')
                    if self.type == 'text/html':
                        file = a +'.txt'
                        file_type = 1
                    elif self.type == 'image/jpg':
                        file = a +'.jpg'
                        file_type = 0
                    elif self.type == 'image/png':
                        file = a +'.png'
                        file_type = 0
                    self.conn.send(f'''HTTP/1.0 200 OK\nConnection: close\nContent-Length:{len(self.body.encode(FORMAT))}\nContent-Type: {file.split('.')[1]}\nDate: {datetime.datetime.now()}\n\n<html><body><h1>POST!</h1></body></html>'''.encode(FORMAT))
                    self.body = self.conn.recv(int(self.length)).decode(FORMAT)
                    print('body',self.body)
                    path = os.getcwd() + '\\' + 'sever_files' + '\\' + file
                    time.sleep(0.001)
                    if file_type == 1:
                        open(path, 'w').write(self.body)
                    elif file_type == 0:
                        print(self.body)
                        open(path, 'wb').write(self.body.encode(FORMAT))
                    self.log('200')
                    self.update_response_dictionary('200')
                    connected = False
                except:
                    error = 1
                    self.conn.send('bad request'.encode(FORMAT))
                    connected = False

            elif check_num == 6:
                print(f'{self.addr} : {self.msg} ')
                self.conn.send(f'''HTTP/1.0 403 Forbidden\nConnection: close\nContent-Length: {len(msg.encode(FORMAT))}\nContent-Type: text/html\nAllow: GET\nDate: {datetime.datetime.now()}\n\n<html><body><h1>FORBIDDEN!</h1></body></html>'''.encode(FORMAT))
                self.log('403')
                self.update_response_dictionary('403')
                connected = False


        self.conn.close()

    def log(self,output_of_server):
        a = str(self.time)
        temp_dict = {a:{'Address': self.addr, "Connection": self.conn,
                     'request_type': self.msg.split("\n")[0].split(" ")[0], 'response': output_of_server,
                     'time': self.time}}
        filename = 'log.json'
        file = open(filename, "r+")
        data = file.read()
        #print('injam',file.read())
        data = data +"\n"+str(temp_dict)
        file.seek(0)
        file.write(data)
        file.close()

    def thread_handel(self):
        thread = threading.Thread(target=self.handel_client())
        print(f'haji number of active connections:{threading.activeCount()}')
        thread.start()
def theard(new_request):
    thread = threading.Thread(target=new_request.handel_client)
    thread.start()
def start():
    server.listen()
    a = SEVER
    print(f'server is listening on {a}')
    while True:
        conn, addr = server.accept() #blocking line (stop until get some request)
        new_request = request(conn, addr)
        theard(new_request)
        print(f'number of active connections:{threading.activeCount() - 1}')


print("kasra sever is starting")
start()