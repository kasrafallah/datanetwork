# HTTP sever with telnet suport

## Part 1

The server is written by a "class"; To writing better the program, the main loop is written inside the "Start" function, and in the main program, we just call "Start".

      print("kasra sever is starting")
      start()

  ### 1.1 define server and global variables
  
At first I enable the server code to specify the "IP" through the "socket" library functions, then a number of required public variables are defined, as you can see in the code below.


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


### 1.2start ()

In the "Start" function, we first "listen ()" the server and then go to an unstoppable loop to get a new connection; When we get a new connection, we define a variable for the address and connection from the "Request" class, and then call it using the "Thread" function to handle the request.
        def start():
            server.listen()
            a = SEVER
            print(f'server is listening on {a}')
            while True:
                conn, addr = server.accept() #blocking line (stop until get some request)
                new_request = request(conn, addr)
                theard(new_request)
                print(f'number of active connections:{threading.activeCount() - 1}')

### 1.3thread (request class)


This function requests a variable of class type and starts a branch to check request so it send that through "request_handel ()" method in request class.
    
    def theard(new_request):
          thread = threading.Thread(target=new_request.handel_client)
          thread.start()



### 1.4 request class


The Request class is for managing requests sent by clients to the server, which has several methods, each of which we will explain.

### 1.4.1__init__ ()

In the definition function, we define only the connection, address, sending time, message content for a request as a variable.
     
     def __init__(self, conn, addr):
          self.conn = conn
          self.addr = addr
          self.time = datetime.datetime.now()
          self.msg = ''

#### 1.4.2 self.request_handel ()

This method is the largest method in the Request class. First we enter a loop from which the condition to exit is to check the client message to the server. To do this, after receiving the message, we remove the inflatable from the header and drop it in "self" into separate variables; Of course, it should be noted that because there may be wrong messages, we must use the structure of "Try" and "Except".

      try:
          header = msg.split("\n\n")
          self.header = header[0]
          self.body = header[1]
      except:
          header =[msg]
          self.header = header[0]
          self.body =''
          
Then we go to another method in this class to determine the content of the header.
check_num = self.request_header_check(self.header)
in section 1.5 we discus about how does request header check function works.
According to the number obtained from the above function, we know what our requisition says. Now we will execute each of the request modes.
#### 1.4.2.1bad request

if the check_num become 0 it means our request is not obtained with HTTP standards so we must answer that with error message. After that we log that connection and close connection.

          if check_num == 0:
              print(f'{self.addr} : {self.msg} ')
              self.conn.send(f'''HTTP/1.0 400 Bad Request\nConnection: close\nContent-Length: {len(msg.encode(FORMAT))}\nContent-Type: text/html\nDate: {datetime.datetime.now()}\n<html><body><h1>BADREQUEST!</h1></body></html>'''.encode(FORMAT))
              self.log('400')
              self.update_response_dictionary('400')
              connected = False

#### 1.4.2.2Not Implemented

If we got check_num equal to 1 it means, we get a method that is not implemented in our server so we just answer that with text that is specified in project requirement.
The code of this part is shown below:

        elif check_num == 1:# Not Implemented
            print(f'{self.addr} : {self.msg} ')
            self.conn.send(f'''HTTP/1.0 501  Not Implemented\nConnection: close\nContent-Length: {len(msg.encode(FORMAT))}\nContent-Type: text/html\nDate: {datetime.datetime.now()}\n\n<html><body><h1>NOTIMPLEMENTED!</h1></body></html>'''.encode(FORMAT))
            self.log('501')
            self.update_response_dictionary('501')
            connected = False

#### 1.4.2.3Not Allowed
If check_num become 2 it means, that we got a method in our request that is in out standard but unfortunately we couldn’t give response to that so we answer that like below

        elif check_num == 2: #Not Allowed
            print(f'{self.addr} : {self.msg} ')
            self.conn.send(f'''HTTP/1.0 405  Not Allowed\nConnection: close\nContent-Length: {len(msg.encode(FORMAT))}\nContent-Type: text/html\nAllow: GET\nDate: {datetime.datetime.now()}\n<html><body><h1>NOTALLOWED!</h1></body></html>'''.encode(FORMAT))
            self.log('405')
            self.update_response_dictionary('405')
            connected = False
#### 1.4.2.4GET

the most complicated part of implementation was handling "GET" request, for this part i use ""Handshake" protocol for obtaining buffer size and use our resources in best way
my hand shake protocol is:
            
            
<p align="center">
<image align="center" src = "images/handshake.png" width="1000">
</p>
The above protocol is executed and the same is available on the client side to store the relevant file in the client folder.
Sever code for handling GET request is shown below: 
      
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
                      if ok =='im ready to receive':
                          temp = open(path, 'rb').read()
                          self.conn.send(temp)
                          self.log('200 OK')
                          self.update_response_dictionary('200')
                      else:
                          self.log("200 Error")
                          self.update_response_dictionary('200')
                      connected = False



      
      
      


#### 1.4.2.5when file doesn't exist
      If check_num become 4 it means client wants a file that doesn’t exist in severe and we just answer server with format below:

            elif check_num == 4:
                print(f'{self.addr} : {self.msg} ')
                self.conn.send(f'''HTTP/1.0 301 Moved Permanently\nConnection: close\nContent-Length:{len(msg.encode(FORMAT))}\nContent-Type: text/html\nDate: {datetime.datetime.now()}\n\n<html><body><h1>MOVEDPERMANENTLY!</h1></body></html>'''.encode(FORMAT))
                self.log('301')
                self.update_response_dictionary('301')
                connected = False

#### 1.4.2.6 POST request

I used a "hand shake" algorithm again to execute the "POST" command; I put different paths for each type of text and photo file because the content type of these two files are different. The "HANDSHake" algorithm and the code for this section are given below

<p align="left">
<image align="left" src = "images/handshake_post.png" width="1000">
</p>

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
                    self.conn.send('im ready to receive'.encode(FORMAT))
                    self.body = self.conn.recv(int(self.length)).decode(FORMAT)
                    path = os.getcwd() + '\\' + 'sever_files' + '\\' + file
                    time.sleep(0.001)
                    if file_type == 1:
                        open(path, 'w').write(self.body)
                    elif file_type == 0:
                        print(self.body)
                        open(path, 'wb').write(self.body.encode(FORMAT))

                    self.conn.send(f'''HTTP/1.0 200 OK\nConnection: close\nContent-Length:{len(self.body.encode(FORMAT))}\nContent-Type: {file.split('.')[1]}\nDate: {datetime.datetime.now()}\n\n<html><body><h1>POST!</h1></body></html>'''.encode(FORMAT))
                    self.log('200')
                    self.update_response_dictionary('200')
                    connected = False
                except:
                    error = 1
                    self.conn.send('bad request'.encode(FORMAT))
                    connected = False

#### 1.4.2.7POST banned
      
If num_check become 6 it means, we got a banned message and we reply that as I written below:
      
            elif check_num == 6:
                print(f'{self.addr} : {self.msg} ')
                self.conn.send(f'''HTTP/1.0 403 Forbidden\nConnection: close\nContent-Length: {len(msg.encode(FORMAT))}\nContent-Type: text/html\nAllow: GET\nDate: {datetime.datetime.now()}\n\n<html><body><h1>FORBIDDEN!</h1></body></html>'''.encode(FORMAT))
                self.log('403')
                self.update_response_dictionary('403')
                connected = False

### 1.4.3 self.request_header_check()
The function of this function is to determine the type of request sent by the client. Allowed states in the form of global variables I implemented this function.
Output zero indicates that the general format of the transmission and the "HTTP" version are correct; Output one means the input method in the "HTTP" methods; Output two means the presence of these methods in the list of allowed methods; Explanation three means the presence of the "Get" method and the existence of the corresponding file;Output four is when the client wants something that is not in the folder; Output five means the free "post" command and Finally, output six means forbidden post
       
      
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

## part2 Implementing the HTTP Client
      
To implement the client, I wrote a class that establishes a connection with the server and sends the message. Also, to show the multi-thread of the server, we can use several clients and send their messages at the same time. now I'm going to explain client code
      
### 2.1 client_message ()
      
The client class, like the server class, consists of a variety of internal methods and variables, which I will explain below.
      
### 2.1.1 __init__(self, msg)
      
In the class definition that is performed in this function, the header and body of the message and connections are created and the continuation of tasks is entrusted to other methods.
      
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

### 2.1.2 msg_handel()
      
The message handle is the method that sends the message and receives the result. Undoubtedly, in the execution of "Get" and "Post" that we used the handshake algorithm, on the client-side, these items must also be replicated, which has been done.
To execute the GET request I wrote the steps within the same function, but regarding the execution of the POST request, I executed it in another method of this class. In general, in cases where the client gives forbidden requests, we are dealing with a small code, but In other cases, we need "handshake" functions

      def handel_msg(self):

    print(f'client is ready to send request to ({self.addr})')
    if self.method == 'POST':
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

### 2.2 multi-thread
To show that the server is multi-thread, all I have to do is send several messages in a short time, which I did by creating 100 requests, and the result is in the next screenshots.
for i in range (100):
  
    new = client_message(f"POST dedkme.ed HTTP/1.0\nContent-Length: 100000\nContent-Type: text/html\n\nfrfregtg")
    new.handel_msg()

now the screen shots that shows the multi-thread imposition of the serve:

<p align="center">
<image align="center" src = "images/connctions.png" width="1000">
</p>
      
## Part 3: Logging Part
      
To document the content, I wrote a "log" method in the server class and used it to update the Jason file. To do this, I put all the information in a dictionary and added each one to the end of the log file; Implemented in the following code.
      
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
And for example one line of my logging file is
      
      {'2021-07-15 19:44:45.441892': {'Address': ('192.168.56.1', 1596), 'Connection': <socket.socket fd=1540, family=AddressFamily.AF_INET, type=SocketKind.SOCK_STREAM, proto=0, laddr=('192.168.56.1', 5099), raddr=('192.168.56.1', 1596)>, 'request_type': 'POST', 'response': '200', 'time': datetime.datetime(2021, 7, 15, 19, 44, 45, 441892)}}


## part4: Telnet
To run this section, I first separated the talent structures in the Request handle code, inserted it into the talent handle loop, and implemented a talent handling method.
To respond to Tenant commands, I used dictionaries that I defined globally and used them to implement the talent answer in the following format.
      
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
