A3:main main.py 

main:main.c
	gcc -o main main.c -lpq
	
run_jdbc:main.java
	javac -cp postgresql-42.5.2.jar main.java
	java -cp postgresql-42.5.2.jar main.java

clean:
	rm main main.class