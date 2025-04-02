CC = gcc
CFLAGS = -fopenmp -O2 -Wall
LDFLAGS = -lm
TARGET = main.bin

all: $(TARGET)

$(TARGET): main.c
	$(CC) $(CFLAGS) -o $(TARGET) main.c $(LDFLAGS)

clean:
	rm -f $(TARGET)