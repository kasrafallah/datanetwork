
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

      <p align="center">
<image align="center" src = "images/handshake_post.png" width="1000">
</p>
